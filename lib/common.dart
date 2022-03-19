library common;

import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

Future<String> currentUserId() async {
  const uuid = Uuid();
  final settings = await Hive.openBox("settings");
  String? maybeUserId = settings.get("userId");
  if (maybeUserId == null) {
    String defaultId = uuid.v1();
    await settings.put("userId", defaultId);
    return defaultId;
  } else {
    return maybeUserId;
  }
}
