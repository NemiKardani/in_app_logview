import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'log_viewer.dart';

/// Manages the overlay that displays the log viewer.
class LogViewOverlay {
  static OverlayEntry? _overlayEntry;
  static bool _isOpen = false;
  static bool _isEnabled = true;

  /// Enables the log viewer.
  static void enable() {
    _isEnabled = true;
  }

  /// Disables the log viewer (useful for production or hiding).
  static void disable() {
    _isEnabled = false;
    close();
  }

  /// Returns whether the log viewer is enabled.
  static bool get isEnabled => _isEnabled;

  /// Opens the log viewer overlay.
  static void open(BuildContext? context) {
    if (!kDebugMode) return;
    if (!_isEnabled) return;
    if (_isOpen) return;

    final overlayContext = context ?? _getRootContext();
    if (overlayContext == null) {
      debugPrint('LogView: Could not find context to show overlay');
      return;
    }

    final overlay = Overlay.maybeOf(overlayContext);
    if (overlay == null) {
      debugPrint('LogView: Could not find overlay');
      return;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => _LogViewOverlayWidget(),
    );

    overlay.insert(_overlayEntry!);
    _isOpen = true;
  }

  /// Closes the log viewer overlay.
  static void close() {
    if (!_isOpen) return;
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isOpen = false;
  }

  /// Toggles the log viewer overlay.
  static void toggle(BuildContext? context) {
    if (_isOpen) {
      close();
    } else {
      open(context);
    }
  }

  /// Returns whether the log viewer is currently open.
  static bool get isOpen => _isOpen;

  /// Gets the root context from the navigator.
  static BuildContext? _getRootContext() {
    try {
      return WidgetsBinding.instance.focusManager.primaryFocus?.context;
    } catch (e) {
      return null;
    }
  }
}

/// The overlay widget that contains the log viewer.
class _LogViewOverlayWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () {
          // Close on tap outside
          LogViewOverlay.close();
        },
        child: Container(
          color: Colors.black.withValues(alpha: 0.3),
          child: Center(
            child: GestureDetector(
              onTap: () {}, // Prevent tap from propagating
              child: Container(
                margin: EdgeInsets.all(
                  MediaQuery.of(context).size.width < 600 ? 8 : 20,
                ),
                child: const LogViewer(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
