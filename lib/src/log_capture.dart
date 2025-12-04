import 'dart:async';

import 'models/log_entry.dart';

/// Manages the capture and streaming of log entries.
class LogCapture {
  static final LogCapture _instance = LogCapture._internal();
  factory LogCapture() => _instance;
  LogCapture._internal();

  final StreamController<LogEntry> _logController =
      StreamController<LogEntry>.broadcast();
  final List<LogEntry> _logs = [];
  final int _maxLogs = 100000; // Maximum number of logs to keep in memory

  /// Stream of log entries.
  Stream<LogEntry> get logStream => _logController.stream;

  /// List of all captured logs.
  List<LogEntry> get logs => List.unmodifiable(_logs);

  /// Whether log capture is enabled.
  bool _isEnabled = false;

  /// Initializes log capture.
  ///
  /// Note: This package primarily captures logs through:
  /// - Programmatic calls via LogView.addLog()
  /// - Integration with logging packages (logger, flutter_logs)
  /// - Custom print wrappers (see README for examples)
  void initialize() {
    if (_isEnabled) return;
    _isEnabled = true;
  }

  /// Adds a log entry to the stream and list.
  void addLog(LogEntry entry) {
    if (!_isEnabled) return;
    _addLog(entry);
  }

  void _addLog(LogEntry entry) {
    _logs.add(entry);

    // Limit the number of logs in memory
    if (_logs.length > _maxLogs) {
      _logs.removeAt(0);
    }

    _logController.add(entry);
  }

  /// Adds a log entry from a string message.
  void addLogFromString(
    String message, {
    LogLevel level = LogLevel.debug,
    String? tag,
  }) {
    addLog(LogEntry.fromString(message, level: level, tag: tag));
  }

  /// Clears all logs.
  void clearLogs() {
    _logs.clear();
    // Emit a special event to notify listeners
    _logController.add(LogEntry(
      timestamp: DateTime.now(),
      message: '--- Logs cleared ---',
      level: LogLevel.info,
    ));
  }

  /// Disposes the log capture system.
  void dispose() {
    _isEnabled = false;
    _logController.close();
  }

  /// Gets the current log count.
  int get logCount => _logs.length;
}
