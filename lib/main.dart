import "package:sentry_flutter/sentry_flutter.dart";
import "package:hive_flutter/hive_flutter.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "dart:async";

import "./common.dart";
import "./ihp/datasync.dart";
import "./components/dashboard.dart";
import "./contacts.dart";

main() {
  if (kReleaseMode) {
    runZonedGuarded(() async {
      await SentryFlutter.init(
        (options) {
          options.dsn =
              "https://03823024300841c6a2396624062d1ea6@o1159580.ingest.sentry.io/6266817";
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
  await Hive.openBox(mainDatabaseName);

  String currentUserId = await currentUserIdWithDefault();
  if (kReleaseMode) {
    Sentry.configureScope(
      (scope) => scope.user = SentryUser(id: currentUserId),
    );
  }

  DataSyncController.config = IHPConfig.getConfig();
  await DataSyncController.newSession(currentUserId);

  await initializeContacts();

  return runApp(const Dashboard());
}
