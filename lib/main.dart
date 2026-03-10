import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:namora/app.dart';
import 'package:namora/bootstrap.dart';
import 'package:namora/providers/provider_observer.dart';
import 'package:namora/utils/logger/app_logger.dart';

void main() {
  runZonedGuarded(
    () async {
      await Bootstrap.init();

      FlutterError.onError = (details) {
        AppLogger.error(
          'Flutter error: ${details.exceptionAsString()}',
          tag: 'FlutterError',
          error: details.exception,
          stackTrace: details.stack,
        );
      };

      runApp(
        ProviderScope(
          observers: [AppProviderObserver()],
          child: const App(),
        ),
      );
    },
    (error, stackTrace) {
      AppLogger.error(
        'Unhandled error',
        tag: 'Main',
        error: error,
        stackTrace: stackTrace,
      );
    },
  );
}
