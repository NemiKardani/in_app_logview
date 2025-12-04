/// Represents a single log entry with timestamp, message, level, and optional tag.
class LogEntry {
  /// The timestamp when the log was created.
  final DateTime timestamp;

  /// The log message content.
  final String message;

  /// The log level (debug, info, warning, error).
  final LogLevel level;

  /// Optional tag or source identifier.
  final String? tag;

  /// Creates a new [LogEntry].
  LogEntry({
    required this.timestamp,
    required this.message,
    required this.level,
    this.tag,
  });

  /// Creates a [LogEntry] from a string message with automatic level detection.
  factory LogEntry.fromString(
    String message, {
    LogLevel level = LogLevel.debug,
    String? tag,
  }) {
    return LogEntry(
      timestamp: DateTime.now(),
      message: message,
      level: level,
      tag: tag,
    );
  }

  /// Returns a formatted string representation of the log entry.
  String get formattedMessage {
    final timeStr = '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}.'
        '${timestamp.millisecond.toString().padLeft(3, '0')}';
    final levelStr = level.logIcon.toUpperCase().padRight(7);
    final tagStr = tag != null ? '[$tag] ' : '';
    return '[$timeStr] $levelStr $tagStr$message';
  }

  /// Returns a formatted string representation without timestamp.
  String get formattedMessageWithoutTime {
    final levelStr = level.logIcon.toUpperCase().padRight(7);
    final tagStr = tag != null ? '[$tag] ' : '';
    return '$levelStr $tagStr$message';
  }

  @override
  String toString() => formattedMessage;
}

/// Enum representing different log levels.
enum LogLevel {
  debug,
  info,
  warning,
  error;

  /// Returns a color representation for the log level.
  /// This is a helper for UI display purposes.
  int get colorValue {
    switch (this) {
      case LogLevel.debug:
        return 0xFF9E9E9E; // Grey
      case LogLevel.info:
        return 0xFF2196F3; // Blue
      case LogLevel.warning:
        return 0xFFFF9800; // Orange
      case LogLevel.error:
        return 0xFFF44336; // Red
    }
  }

  String get logIcon {
    switch (this) {
      case LogLevel.debug:
        return '🐛';
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
    }
  }
}
