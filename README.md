# in_app_logview

[![pub package](https://img.shields.io/pub/v/in_app_logview.svg)](https://pub.dev/packages/in_app_logview)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A Flutter package that displays real-time application logs within a debug build, featuring a console-like UI with filtering, search, and integration with popular logging packages.

## Features

- 🎯 **Real-time log capture** - View logs as they happen
- 🎨 **Console-like UI** - Dark theme with monospaced font, mimicking a standard console
- 🔍 **Search & Filter** - Real-time search and log level filtering
- 📋 **Copy to Clipboard** - Copy all visible logs with one click
- 🎛️ **Auto-scroll** - Automatically scrolls to new logs (can be paused)
- 🚀 **Easy Integration** - Minimal setup required
- 🔌 **Logger Integration** - Works with `logger` and `flutter_logs` packages
- 🐛 **Debug Mode Only** - Automatically disabled in release builds

## Screenshots

The log viewer provides a console-like interface with:

- Dark background (similar to VS Code terminal)
- Color-coded log levels (debug, info, warning, error)
- Search bar for filtering logs
- Level filter dropdown
- Control buttons (pause auto-scroll, clear, copy, close)

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  in_app_logview: ^0.1.0
```

Then run:

```bash
flutter pub get
```

## Quick Start

### 1. Initialize the Log Viewer

In your `main.dart`, initialize the log viewer before `runApp()`:

```dart
import 'package:in_app_logview/in_app_logview.dart';

void main() {
  LogView.initialize();
  runApp(MyApp());
}
```

### 2. Wrap Your App (Optional)

To show the floating button that opens the log viewer, wrap your app with `LogViewWrapper`:

```dart
import 'package:in_app_logview/in_app_logview.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LogViewWrapper(
        child: MyHomePage(),
      ),
    );
  }
}
```

### 3. Add Logs

You can add logs programmatically:

```dart
import 'package:in_app_logview/in_app_logview.dart';

// Simple log
LogView.addLog('This is a debug message');

// With log level
LogView.addLog('This is an error', level: LogLevel.error);

// With tag
LogView.addLog('User logged in', level: LogLevel.info, tag: 'Auth');
```

### 4. Open/Close Programmatically

```dart
// Open the log viewer
LogView.open(context);

// Close the log viewer
LogView.close();

// Toggle the log viewer
LogView.toggle(context);

// Check if open
if (LogView.isOpen) {
  // Do something
}
```

## Usage Examples

### Basic Usage

```dart
import 'package:flutter/material.dart';
import 'package:in_app_logview/in_app_logview.dart';

void main() {
  LogView.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LogViewWrapper(
        child: HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My App')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            LogView.addLog('Button pressed', level: LogLevel.info);
          },
          child: Text('Press Me'),
        ),
      ),
    );
  }
}
```

### Custom Floating Button Position

```dart
LogViewWrapper(
  buttonPosition: FloatingButtonPosition.topLeft, // or topRight, bottomLeft, bottomRight
  child: MyHomePage(),
)
```

## Integration with Logging Packages

### Integration with `logger` Package

To integrate with the [`logger`](https://pub.dev/packages/logger) package:

1. Add `logger` to your `pubspec.yaml`:

```yaml
dependencies:
  logger: ^2.0.0
  in_app_logview: ^0.1.0
```

2. Create a custom `LogOutput`:

```dart
import 'package:logger/logger.dart';
import 'package:in_app_logview/in_app_logview.dart';

class InAppLogOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    for (final line in event.lines) {
      LogView.addLogFromString(
        line,
        level: _mapLevel(event.level),
        tag: event.origin?.toString(),
      );
    }
  }

  LogLevel _mapLevel(Level level) {
    if (level.value >= Level.error.value) {
      return LogLevel.error;
    } else if (level.value >= Level.warning.value) {
      return LogLevel.warning;
    } else if (level.value >= Level.info.value) {
      return LogLevel.info;
    } else {
      return LogLevel.debug;
    }
  }
}
```

3. Use it with your Logger:

```dart
final logger = Logger(
  output: InAppLogOutput(),
);

logger.d('Debug message');
logger.i('Info message');
logger.w('Warning message');
logger.e('Error message');
```

### Integration with `flutter_logs` Package

To integrate with the [`flutter_logs`](https://pub.dev/packages/flutter_logs) package:

1. Add `flutter_logs` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_logs: ^3.0.0
  in_app_logview: ^0.1.0
```

2. Set up a custom log handler:

```dart
import 'package:flutter_logs/flutter_logs.dart';
import 'package:in_app_logview/in_app_logview.dart';

void setupLogging() {
  FlutterLogs.setCustomLogHandler((logLevel, message, stackTrace) {
    LogLevel level;
    switch (logLevel) {
      case 'ERROR':
      case 'E':
        level = LogLevel.error;
        break;
      case 'WARNING':
      case 'W':
        level = LogLevel.warning;
        break;
      case 'INFO':
      case 'I':
        level = LogLevel.info;
        break;
      case 'DEBUG':
      case 'D':
      default:
        level = LogLevel.debug;
        break;
    }

    final fullMessage = stackTrace != null ? '$message\n$stackTrace' : message;
    LogView.addLog(fullMessage, level: level, tag: 'flutter_logs');
  });
}
```

3. Use it in your app:

```dart
void main() {
  LogView.initialize();
  setupLogging();
  runApp(MyApp());
}

// Then use flutter_logs as normal
FlutterLogs.logInfo('MyTag', 'Info message');
FlutterLogs.logError('MyTag', 'Error message');
```

## Log Levels

The package supports four log levels:

- `LogLevel.debug` - Debug messages (grey)
- `LogLevel.info` - Informational messages (blue)
- `LogLevel.warning` - Warning messages (orange)
- `LogLevel.error` - Error messages (red)

## Log Viewer Features

### Search

Type in the search bar to filter logs by content. The search is case-insensitive and matches both the log message and tag.

### Filter by Level

Use the dropdown in the search bar to filter logs by level (All Levels, Debug, Info, Warning, Error).

### Auto-scroll

The log viewer automatically scrolls to the bottom when new logs arrive. Click the pause button to disable auto-scrolling.

### Clear Logs

Click the clear button to remove all logs from the viewer.

### Copy to Clipboard

Click the copy button to copy all visible (filtered) logs to the clipboard.

### Close

Click the close button (X) to close the log viewer overlay.

## API Reference

### LogView Class

#### Methods

- `LogView.initialize()` - Initializes the log capture system. Call this in `main()` before `runApp()`.
- `LogView.open(BuildContext? context)` - Opens the log viewer overlay.
- `LogView.close()` - Closes the log viewer overlay.
- `LogView.toggle(BuildContext? context)` - Toggles the log viewer overlay.
- `LogView.addLog(String message, {LogLevel level = LogLevel.debug, String? tag})` - Adds a log entry programmatically.

#### Properties

- `LogView.isOpen` - Returns `true` if the log viewer is currently open.

### LogViewWrapper Widget

A widget that wraps your app and provides the floating log button.

**Parameters:**

- `child` (required) - The widget to wrap.
- `buttonPosition` (optional) - Position of the floating button. Default: `FloatingButtonPosition.bottomRight`.

### FloatingButtonPosition Enum

- `FloatingButtonPosition.bottomRight` (default)
- `FloatingButtonPosition.bottomLeft`
- `FloatingButtonPosition.topRight`
- `FloatingButtonPosition.topLeft`

## Platform Support

This package works on all Flutter-supported platforms:

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## Debug Mode Only

The log viewer and floating button only appear in debug mode (`kDebugMode`). In release builds, all log viewer functionality is automatically disabled, ensuring zero performance impact in production.

## Performance Considerations

- The package keeps a maximum of 10,000 logs in memory to prevent excessive memory usage.
- Logs are stored in memory only (not persisted to disk).
- The UI updates efficiently using streams, ensuring smooth performance even with many logs.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Author

Created with ❤️ for the Flutter community.

## Support

If you encounter any issues or have questions, please file an issue on the [GitHub repository](https://github.com/yourusername/in_app_logview).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Note:** This package is designed for development and debugging purposes. It automatically disables itself in release builds to ensure optimal production performance.
