import 'package:flutter/foundation.dart';
import "package:hive_flutter/hive_flutter.dart";
import "package:uuid/uuid.dart";

const mainDatabaseName = "text_contact_database";

Future<String> currentUserIdWithDefault() async {
  const uuid = Uuid();
  final settings = await Hive.openBox(mainDatabaseName);
  String? maybeUserId = settings.get("userId");
  if (maybeUserId == null) {
    String defaultId = uuid.v1();
    await settings.put("userId", defaultId);
    return defaultId;
  } else {
    return maybeUserId;
  }
}

class IHPConfig {
  Uri websocketEndpoint;
  Uri newSessionEndpoint;

  IHPConfig(
      {required this.websocketEndpoint, required this.newSessionEndpoint});

  static IHPConfig getConfig() {
    if (kReleaseMode) {
      return IHPConfig(
          websocketEndpoint: Uri.parse("wss://text.contact/DataSyncController"),
          newSessionEndpoint: Uri.parse("https://text.contact/NewSession"));
    } else {
      return IHPConfig(
          websocketEndpoint:
              Uri.parse("wss://textcontact.ngrok.io/DataSyncController"),
          newSessionEndpoint:
              Uri.parse("https://textcontact.ngrok.io/NewSession"));
    }
  }
}
