export 'src/log_capture.dart';
export 'src/log_viewer.dart';
export 'src/log_view_overlay.dart';
export 'src/floating_log_button.dart';
export 'src/models/log_entry.dart' show LogEntry, LogLevel;
export 'src/integrations/logger_integration.dart';
export 'src/integrations/flutter_logs_integration.dart';
export 'src/integrations/dio_interceptor_integration.dart';

// Re-export logger package for convenience (optional dependency)
export 'package:logger/logger.dart'
    show
        Logger,
        Level,
        LogFilter,
        LogPrinter,
        LogOutput,
        PrettyPrinter,
        SimplePrinter;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:logger/logger.dart' as logger_package;

import 'src/floating_log_button.dart';
import 'src/log_capture.dart';
import 'src/log_view_overlay.dart';
import 'src/models/log_entry.dart';
import 'src/integrations/logger_integration.dart';

/// Main class for managing the in-app log viewer.
class InAppLog {
  static logger_package.Logger? _defaultLogger;
  static bool _useLogger = false;

  /// Initializes the log capture system.
  ///
  /// Call this in your main() function before runApp():
  ///
  /// **Basic usage (default methods):**
  /// ```dart
  /// void main() {
  ///   InAppLog.initialize();
  ///   runApp(MyApp());
  /// }
  /// ```
  ///
  /// **Use logger package with default style:**
  /// ```dart
  /// void main() {
  ///   InAppLog.initialize(useLogger: true);
  ///   runApp(MyApp());
  /// }
  /// ```
  ///
  /// **Use logger package with PrettyPrinter:**
  /// ```dart
  /// void main() {
  ///   InAppLog.initialize(
  ///     useLogger: true,
  ///     printer: PrettyPrinter(
  ///       methodCount: 2,
  ///       colors: true,
  ///       printEmojis: true,
  ///     ),
  ///   );
  ///   runApp(MyApp());
  /// }
  /// ```
  ///
  /// **Use logger package with SimplePrinter:**
  /// ```dart
  /// void main() {
  ///   InAppLog.initialize(
  ///     useLogger: true,
  ///     printer: SimplePrinter(),
  ///   );
  ///   runApp(MyApp());
  /// }
  /// ```
  ///
  /// **Custom logger configuration:**
  /// ```dart
  /// void main() {
  ///   InAppLog.initialize(
  ///     useLogger: true,
  ///     printer: PrettyPrinter(
  ///       methodCount: 2,
  ///       errorMethodCount: 8,
  ///       lineLength: 120,
  ///       colors: true,
  ///       printEmojis: true,
  ///     ),
  ///     level: Level.debug,
  ///   );
  ///   runApp(MyApp());
  /// }
  /// ```
  static void initialize({
    bool enabled = true,
    bool useLogger = false,
    logger_package.LogPrinter? printer,
    logger_package.LogFilter? filter,
    logger_package.Level? level,
  }) {
    if (enabled) {
      LogCapture().initialize();
    }

    _useLogger = useLogger && enabled;

    if (_useLogger) {
      _defaultLogger = LoggerIntegration.createLogger(
        filter: filter,
        printer: printer ?? logger_package.SimplePrinter(),
        level: level,
      );
    } else {
      _defaultLogger = null;
    }
  }

  /// Returns the default logger instance if logger package is enabled.
  /// Returns null if using default methods.
  static logger_package.Logger? get defaultLogger => _defaultLogger;

  /// Returns whether logger package is being used.
  static bool get isUsingLogger => _useLogger;

  /// Opens the log viewer overlay.
  ///
  /// ```dart
  /// InAppLog.open(context);
  /// ```
  static void open(BuildContext? context) {
    LogViewOverlay.open(context);
  }

  /// Closes the log viewer overlay.
  ///
  /// ```dart
  /// InAppLog.close();
  /// ```
  static void close() {
    LogViewOverlay.close();
  }

  /// Toggles the log viewer overlay.
  ///
  /// ```dart
  /// InAppLog.toggle(context);
  /// ```
  static void toggle(BuildContext? context) {
    LogViewOverlay.toggle(context);
  }

  /// Returns whether the log viewer is currently open.
  static bool get isOpen => LogViewOverlay.isOpen;

  /// Enables the log viewer.
  ///
  /// ```dart
  /// InAppLog.enable();
  /// ```
  static void enable() {
    LogViewOverlay.enable();
  }

  /// Disables the log viewer (useful for production or hiding).
  ///
  /// ```dart
  /// InAppLog.disable();
  /// ```
  static void disable() {
    LogViewOverlay.disable();
  }

  /// Returns whether the log viewer is enabled.
  static bool get isEnabled => LogViewOverlay.isEnabled;

  /// Adds a log entry programmatically.
  ///
  /// ```dart
  /// InAppLog.addLog('This is a debug message', level: LogLevel.debug);
  /// ```
  static void addLog(
    String message, {
    LogLevel level = LogLevel.debug,
    String? tag,
  }) {
    LogCapture().addLogFromString(message, level: level, tag: tag);
  }

  /// Adds a debug level log entry.
  ///
  /// If logger package is enabled via initialize(), this will use the logger.
  /// Otherwise, it uses the default method.
  ///
  /// ```dart
  /// InAppLog.debug('Debug message');
  /// InAppLog.debug('Debug message', tag: 'MyTag');
  /// ```
  static void debug(String message, {String? tag}) {
    if (_useLogger && _defaultLogger != null) {
      _defaultLogger!.d(message);
    } else {
      addLog(message, level: LogLevel.debug, tag: tag);
    }
  }

  /// Adds an info level log entry.
  ///
  /// If logger package is enabled via initialize(), this will use the logger.
  /// Otherwise, it uses the default method.
  ///
  /// ```dart
  /// InAppLog.info('Info message');
  /// InAppLog.info('Info message', tag: 'MyTag');
  /// ```
  static void info(String message, {String? tag}) {
    if (_useLogger && _defaultLogger != null) {
      _defaultLogger!.i(message);
    } else {
      addLog(message, level: LogLevel.info, tag: tag);
    }
  }

  /// Adds a warning level log entry.
  ///
  /// If logger package is enabled via initialize(), this will use the logger.
  /// Otherwise, it uses the default method.
  ///
  /// ```dart
  /// InAppLog.warning('Warning message');
  /// InAppLog.warning('Warning message', tag: 'MyTag');
  /// ```
  static void warning(String message, {String? tag}) {
    if (_useLogger && _defaultLogger != null) {
      _defaultLogger!.w(message);
    } else {
      addLog(message, level: LogLevel.warning, tag: tag);
    }
  }

  /// Adds an error level log entry.
  ///
  /// If logger package is enabled via initialize(), this will use the logger.
  /// Otherwise, it uses the default method.
  ///
  /// ```dart
  /// InAppLog.error('Error message');
  /// InAppLog.error('Error message', tag: 'MyTag');
  /// ```
  static void error(String message,
      {String? tag, Object? error, StackTrace? stackTrace}) {
    if (_useLogger && _defaultLogger != null) {
      _defaultLogger!.e(message, error: error, stackTrace: stackTrace);
    } else {
      addLog(message, level: LogLevel.error, tag: tag);
    }
  }

  /// Creates a Logger instance from the `logger` package configured to output to in_app_logview.
  ///
  /// This is a convenience method for developers who want to use the `logger` package
  /// instead of the default InAppLog methods.
  ///
  /// **Usage:**
  ///
  /// ```dart
  /// // Simple usage
  /// final logger = InAppLog.createLogger();
  /// logger.d('Debug message');
  /// logger.i('Info message');
  /// logger.w('Warning message');
  /// logger.e('Error message');
  /// ```
  ///
  /// **Custom configuration:**
  ///
  /// ```dart
  /// final logger = InAppLog.createLogger(
  ///   printer: PrettyPrinter(
  ///     methodCount: 2,
  ///     colors: true,
  ///     printEmojis: true,
  ///   ),
  ///   level: Level.debug,
  /// );
  /// ```
  ///
  /// **Note:** This requires the `logger` package. If you prefer not to use it,
  /// you can use InAppLog.debug(), InAppLog.info(), etc. directly.
  ///
  /// See: https://pub.dev/packages/logger
  static logger_package.Logger createLogger({
    logger_package.LogFilter? filter,
    logger_package.LogPrinter? printer,
    logger_package.Level? level,
  }) {
    return LoggerIntegration.createLogger(
      filter: filter,
      printer: printer,
      level: level,
    );
  }
}

/// A widget that wraps your app and provides the floating log button.
///
/// Usage:
/// ```dart
/// MaterialApp(
///   home: LogViewWrapper(
///     child: MyHomePage(),
///   ),
/// )
/// ```
class LogViewWrapper extends StatelessWidget {
  /// The child widget to wrap.
  final Widget child;

  /// The position of the floating log button.
  final FloatingButtonPosition buttonPosition;

  /// Creates a LogViewWrapper.
  const LogViewWrapper({
    super.key,
    required this.child,
    this.buttonPosition = FloatingButtonPosition.bottomRight,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (kDebugMode && LogViewOverlay.isEnabled)
          FloatingLogButton(position: buttonPosition),
      ],
    );
  }
}
