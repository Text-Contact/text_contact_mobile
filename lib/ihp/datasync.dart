import 'package:flutter/foundation.dart';
import "package:json_annotation/json_annotation.dart";
import "package:http/http.dart" as http;
import "package:http/retry.dart";
import "dart:convert";
import "dart:async";
import "dart:math";
import "dart:io";
import "../common.dart";

part "datasync.g.dart";

@JsonSerializable()
class DataSyncResult {
  String tag;
  int requestId;
  List<Map<String, dynamic>> result;

  DataSyncResult(this.tag, this.requestId, this.result);
  factory DataSyncResult.fromJson(Map<String, dynamic> json) =>
      _$DataSyncResultFromJson(json);
}

@JsonSerializable()
class DataSyncError {
  String tag;
  int requestId;
  String errorMessage;

  DataSyncError(this.tag, this.requestId, this.errorMessage);
  factory DataSyncError.fromJson(Map<String, dynamic> json) =>
      _$DataSyncErrorFromJson(json);
}

class DataSyncController {
  static IHPConfig? config;
  static DataSyncController? instance;
  static String? sessionCookie;

  static DataSyncController getInstance() {
    DataSyncController.instance ??= DataSyncController();
    return DataSyncController.instance!;
  }

  static IHPConfig getConfig() {
    if (DataSyncController.config == null) {
      throw Exception("DataSyncController.config Is Not Defined");
    } else {
      return DataSyncController.config!;
    }
  }

  var pendingRequests = [];
  WebSocket? connection;
  Future<WebSocket>? pendingConnection;
  Future<dynamic>? reconnectTimeout;
  var outbox = [];

  int requestIdCounter = 0;
  bool receivedFirstResponse = false;

  Map<String, dynamic> eventListeners = {
    "message": [],
    "close": [],
    "reconnect": []
  };

  static newSession(userId) async {
    final client = RetryClient(http.Client(),
        retries: 3, when: (response) => response.statusCode != 200);

    final endpoint = DataSyncController.getConfig()
        .newSessionEndpoint
        .replace(queryParameters: {"userId": userId});

    try {
      final response = await client.post(endpoint);
      final cookie = response.headers["set-cookie"];
      sessionCookie = cookie;
    } catch (error) {
      if (!kReleaseMode) print(error);
    } finally {
      client.close();
    }
  }

  startConnection() async {
    if (connection != null) return connection;
    if (pendingConnection != null) return await pendingConnection;

    Future<WebSocket> connect() {
      final Completer<WebSocket> _completer = Completer();

      final endpoint = DataSyncController.getConfig().websocketEndpoint;
      WebSocket.connect(endpoint.toString(),
              headers: {"Cookie": DataSyncController.sessionCookie})
          .then((socket) async {
        if (socket.readyState == WebSocket.open) {
          Stream.castFrom(socket).listen(
              (message) => onMessage(message as String),
              onDone: () => onClose(socket.closeReason),
              onError: (error) => _completer.completeError(error),
              cancelOnError: true);
        }
        _completer.complete(socket);
      }).onError((error, stacktrace) {
        _completer.completeError(error!, stacktrace);
      });

      return _completer.future;
    }

    wait(int timeout) {
      return Future.delayed(Duration(seconds: timeout));
    }

    const maxRetries = 32;
    const maxDelayExponent = 6; // 2 ^ 6 ~> 1 min

    for (var i = 0; i < maxRetries; i++) {
      pendingConnection = connect();

      try {
        final socket = await pendingConnection;
        pendingConnection = null;
        connection = socket;

        // Flush Outbox
        for (final pendingMessage in outbox) {
          connection!.add(pendingMessage);
        }
        outbox = [];

        return connection;
      } catch (error) {
        if (!kReleaseMode) print(error);
        final time = pow(2, min(i, maxDelayExponent)).toInt();
        if (!kReleaseMode) print("Retrying in " + time.toString() + " seconds");
        await wait(time);
      }
    }
  }

  parseMessage(String message) {
    Map<String, dynamic> deserialized = jsonDecode(message);
    if (deserialized["tag"] == "DataSyncResult") {
      return DataSyncResult.fromJson(deserialized);
    } else if (deserialized["tag"] == "DataSyncError") {
      return DataSyncError.fromJson(deserialized);
    } else {
      throw Exception("Failed to parseMessage");
    }
  }

  onMessage(String payload) {
    final decoded = parseMessage(payload);
    final requestId = decoded.requestId;
    final request = pendingRequests
        .firstWhere((request) => request["requestId"] == requestId);

    // Remove request from array, as we don"t need it anymore.
    // If we don"t remove it we will build up a lot of memory
    // and slow down the app over time
    pendingRequests.remove(request);

    receivedFirstResponse = true;

    if (request != null) {
      Completer completer = request["completer"];

      if (decoded.tag == "DataSyncError") {
        completer.completeError(Exception(decoded.errorMessage));
      } else {
        completer.complete(decoded);
      }
    } else {
      if (decoded.tag == "FailedToDecodeMessageError") {
        throw Exception(decoded.errorMessage);
      }

      for (final eventListenerCallback in eventListeners["message"]) {
        eventListenerCallback(decoded);
      }
    }
  }

  onClose(String? closeReason) {
    connection = null;
    for (final listener in eventListeners["close"]) {
      listener(closeReason);
    }

    retryToReconnect();
  }

  Future<dynamic> sendMessage(payload) async {
    final Completer _completer = Completer();

    payload["requestId"] = ++requestIdCounter;
    pendingRequests
        .add({"requestId": payload["requestId"], "completer": _completer});

    if (connection == null) {
      outbox.add(jsonEncode(payload));

      final isFirstMessage = requestIdCounter == 1;
      if (isFirstMessage) {
        connection = await startConnection();
      }
    } else {
      connection!.add(jsonEncode(payload));
    }

    return _completer.future;
  }

  retryToReconnect() {
    if (connection != null) return;

    if (reconnectTimeout != null) {
      reconnectTimeout = null;
    }

    reconnectTimeout =
        Future.delayed(const Duration(seconds: 1)).then((_) async {
      if (!kReleaseMode) print("Trying to reconnect DataSync ...");
      await startConnection();

      for (final listener in eventListeners["reconnect"]) {
        listener();
      }
    });
  }
}

class DataSubscription {}
