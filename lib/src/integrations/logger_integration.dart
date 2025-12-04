import 'package:logger/logger.dart' as logger_package;

import '../log_capture.dart';
import '../models/log_entry.dart';

/// Integration helper for the `logger` package.
///
/// This provides a ready-to-use LogOutput implementation that forwards
/// all logger package logs to in_app_logview.
///
/// **Usage:**
///
/// 1. Add `logger` to your `pubspec.yaml`:
/// ```yaml
/// dependencies:
///   logger: ^2.0.0
///   in_app_logview: ^0.1.0
/// ```
///
/// 2. Set up the logger with InAppLogOutput:
/// ```dart
/// import 'package:logger/logger.dart';
/// import 'package:in_app_logview/in_app_logview.dart';
///
/// // Option 1: Use the provided helper method
/// final logger = InAppLog.createLogger();
///
/// // Option 2: Manual setup
/// final logger = Logger(
///   output: InAppLogOutput(),
/// );
///
/// logger.d('Debug message');
/// logger.i('Info message');
/// logger.w('Warning message');
/// logger.e('Error message');
/// ```
///
/// **Note:** The logger package is an optional dependency. If you don't
/// want to use it, you can use InAppLog.debug(), InAppLog.info(), etc. directly.
class InAppLogOutput extends logger_package.LogOutput {
  @override
  void output(logger_package.OutputEvent event) {
    for (final line in event.lines) {
      LogCapture().addLogFromString(
        line,
        level: _mapLevel(event.level),
        tag: 'logger',
      );
    }
  }

  LogLevel _mapLevel(logger_package.Level level) {
    // Level values from logger package:
    // Level.trace = 500
    // Level.debug = 700
    // Level.info = 800
    // Level.warning = 900
    // Level.error = 1000
    // Level.fatal = 1200

    if (level.value >= logger_package.Level.fatal.value) {
      return LogLevel.error;
    } else if (level.value >= logger_package.Level.error.value) {
      return LogLevel.error;
    } else if (level.value >= logger_package.Level.warning.value) {
      return LogLevel.warning;
    } else if (level.value >= logger_package.Level.info.value) {
      return LogLevel.info;
    } else {
      return LogLevel.debug;
    }
  }
}

/// Helper class for logger package integration.
class LoggerIntegration {
  /// Creates a Logger instance configured to output to in_app_logview.
  ///
  /// This is a convenience method that sets up a Logger with InAppLogOutput.
  ///
  /// ```dart
  /// final logger = InAppLog.createLogger();
  /// logger.d('Debug message');
  /// ```
  ///
  /// You can also customize the logger:
  /// ```dart
  /// final logger = InAppLog.createLogger(
  ///   printer: PrettyPrinter(),
  ///   level: Level.debug,
  /// );
  /// ```
  static logger_package.Logger createLogger({
    logger_package.LogFilter? filter,
    logger_package.LogPrinter? printer,
    logger_package.Level? level,
  }) {
    return logger_package.Logger(
      filter: filter,
      printer: printer ?? logger_package.SimplePrinter(),
      output: InAppLogOutput(),
      level: level,
    );
  }

  /// Maps a logger Level to a LogLevel.
  ///
  /// This is a helper method that you can use in your custom LogOutput.
  static LogLevel mapLevel(logger_package.Level level) {
    if (level.value >= logger_package.Level.fatal.value) {
      return LogLevel.error;
    } else if (level.value >= logger_package.Level.error.value) {
      return LogLevel.error;
    } else if (level.value >= logger_package.Level.warning.value) {
      return LogLevel.warning;
    } else if (level.value >= logger_package.Level.info.value) {
      return LogLevel.info;
    } else {
      return LogLevel.debug;
    }
  }
}
