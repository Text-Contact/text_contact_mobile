import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
// import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import './common.dart' as common;

part 'main.g.dart';

main() {
  if (kReleaseMode) {
    runZonedGuarded(() async {
      await SentryFlutter.init(
        (options) {
          options.dsn =
              'https://03823024300841c6a2396624062d1ea6@o1159580.ingest.sentry.io/6266817';
        },
      );
      initializeApplication();
    }, (exception, stackTrace) async {
      await Sentry.captureException(exception, stackTrace: stackTrace);
    });
  } else {
    initializeApplication();
  }
}

initializeApplication() async {
  await Hive.initFlutter();
  await Hive.openBox('settings');
  String currentUserId = await common.currentUserId();
  const ihpWebSocketUrl = String.fromEnvironment('IHP_WEBSOCKET_URL',
      defaultValue: "wss://text.contact/DataSyncController");

  final websocketChannel = WebSocketChannel.connect(Uri.parse(ihpWebSocketUrl));
  return runApp(const Application());
}

@swidget
Widget application() {
  return MaterialApp(
    title: 'Text Contact',
    theme: ThemeData(),
    home: Text("Hello"),
  );
}
