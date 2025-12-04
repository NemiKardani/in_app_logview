import 'package:flutter_test/flutter_test.dart';

import 'package:in_app_logview/in_app_logview.dart';

void main() {
  group('LogView', () {
    test('initialize should enable log capture', () {
      InAppLog.initialize();
      expect(LogCapture().logCount, 0);
    });

    test('addLog should add a log entry', () {
      InAppLog.initialize();
      InAppLog.addLog('Test message', level: LogLevel.info);
      expect(LogCapture().logs.length, 1);
      expect(LogCapture().logs.first.message, 'Test message');
      expect(LogCapture().logs.first.level, LogLevel.info);
    });

    test('addLog with tag should include tag', () {
      InAppLog.initialize();
      InAppLog.addLog('Test message', level: LogLevel.debug, tag: 'TestTag');
      expect(LogCapture().logs.first.tag, 'TestTag');
    });

    test('clearLogs should clear all logs', () {
      InAppLog.initialize();
      InAppLog.addLog('Message 1');
      InAppLog.addLog('Message 2');
      expect(LogCapture().logs.length, 2);
      LogCapture().clearLogs();
      expect(LogCapture().logs.length, 0);
    });
  });

  group('LogEntry', () {
    test('formattedMessage should include timestamp and level', () {
      final entry = LogEntry(
        timestamp: DateTime(2024, 1, 1, 12, 30, 45, 123),
        message: 'Test message',
        level: LogLevel.info,
      );
      final formatted = entry.formattedMessage;
      expect(formatted, contains('INFO'));
      expect(formatted, contains('Test message'));
      expect(formatted, contains('12:30:45'));
    });

    test('formattedMessage with tag should include tag', () {
      final entry = LogEntry(
        timestamp: DateTime.now(),
        message: 'Test message',
        level: LogLevel.debug,
        tag: 'MyTag',
      );
      expect(entry.formattedMessage, contains('[MyTag]'));
    });
  });
}
