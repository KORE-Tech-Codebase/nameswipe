import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error }

abstract final class AppLogger {
  static LogLevel _minLevel = LogLevel.debug;

  static void setMinLevel(LogLevel level) {
    _minLevel = level;
  }

  static void debug(String message, {String tag = 'APP', Object? error}) {
    _log(LogLevel.debug, message, tag: tag, error: error);
  }

  static void info(String message, {String tag = 'APP', Object? error}) {
    _log(LogLevel.info, message, tag: tag, error: error);
  }

  static void warning(String message, {String tag = 'APP', Object? error}) {
    _log(LogLevel.warning, message, tag: tag, error: error);
  }

  static void error(String message, {String tag = 'APP', Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  static void _log(
    LogLevel level,
    String message, {
    String tag = 'APP',
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (level.index < _minLevel.index) return;
    if (!kDebugMode) return;

    final prefix = _levelPrefix(level);
    final logMessage = '$prefix [$tag] $message';

    developer.log(
      logMessage,
      name: tag,
      error: error,
      stackTrace: stackTrace,
      level: _levelToInt(level),
    );
  }

  static String _levelPrefix(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '[DEBUG]';
      case LogLevel.info:
        return '[INFO]';
      case LogLevel.warning:
        return '[WARN]';
      case LogLevel.error:
        return '[ERROR]';
    }
  }

  static int _levelToInt(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
    }
  }
}
