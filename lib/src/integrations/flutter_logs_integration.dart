import '../log_capture.dart';
import '../models/log_entry.dart';

/// Integration helper for the `flutter_logs` package.
///
/// To use this, set up a custom log handler:
///
/// ```dart
/// import 'package:flutter_logs/flutter_logs.dart';
/// import 'package:in_app_logview/integrations/flutter_logs_integration.dart';
///
/// FlutterLogs.setCustomLogHandler((logLevel, message, stackTrace) {
///   FlutterLogsIntegration.handleLog(logLevel, message, stackTrace);
/// });
/// ```
class FlutterLogsIntegration {
  /// Handles a log from flutter_logs and forwards it to in_app_logview.
  static void handleLog(
    String logLevel,
    String message,
    StackTrace? stackTrace,
  ) {
    final level = _mapLogLevel(logLevel);
    final fullMessage = stackTrace != null ? '$message\n$stackTrace' : message;

    LogCapture().addLogFromString(
      fullMessage,
      level: level,
      tag: 'flutter_logs',
    );
  }

  static LogLevel _mapLogLevel(String level) {
    switch (level.toLowerCase()) {
      case 'error':
      case 'e':
        return LogLevel.error;
      case 'warning':
      case 'w':
        return LogLevel.warning;
      case 'info':
      case 'i':
        return LogLevel.info;
      case 'debug':
      case 'd':
      default:
        return LogLevel.debug;
    }
  }
}
