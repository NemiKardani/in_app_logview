import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'log_view_overlay.dart';

/// A floating button that appears in debug mode to open the log viewer.
class FloatingLogButton extends StatefulWidget {
  /// The position of the floating button.
  final FloatingButtonPosition position;

  /// Creates a floating log button.
  const FloatingLogButton({
    super.key,
    this.position = FloatingButtonPosition.bottomRight,
  });

  @override
  State<FloatingLogButton> createState() => _FloatingLogButtonState();
}

class _FloatingLogButtonState extends State<FloatingLogButton> {
  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: widget.position == FloatingButtonPosition.bottomRight ||
              widget.position == FloatingButtonPosition.bottomLeft
          ? 20
          : null,
      top: widget.position == FloatingButtonPosition.topRight ||
              widget.position == FloatingButtonPosition.topLeft
          ? 20
          : null,
      right: widget.position == FloatingButtonPosition.bottomRight ||
              widget.position == FloatingButtonPosition.topRight
          ? 20
          : null,
      left: widget.position == FloatingButtonPosition.bottomLeft ||
              widget.position == FloatingButtonPosition.topLeft
          ? 20
          : null,
      child: FloatingActionButton(
        onPressed: () => LogViewOverlay.toggle(context),
        backgroundColor: const Color(0xFF2D2D2D),
        child: const Icon(
          Icons.bug_report,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Enum for floating button positions.
enum FloatingButtonPosition {
  bottomRight,
  bottomLeft,
  topRight,
  topLeft,
}

