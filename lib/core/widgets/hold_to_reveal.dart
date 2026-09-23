import 'package:flutter/material.dart';

/// Wraps a sensitive value (a total, a percentage, …) that should stay
/// masked until the user actively looks at it — tap to toggle it on/off, or
/// press-and-hold to peek while the finger is down.
///
/// Used by chart cards so numbers only surface on hold or click instead of
/// sitting on screen permanently.
class HoldToReveal extends StatefulWidget {
  const HoldToReveal({required this.builder, super.key});

  /// Builds the widget's content; [revealed] is true while the value should
  /// be shown (toggled on via tap, or currently being held).
  final Widget Function(BuildContext context, bool revealed) builder;

  @override
  State<HoldToReveal> createState() => _HoldToRevealState();
}

class _HoldToRevealState extends State<HoldToReveal> {
  bool _toggled = false;
  bool _holding = false;

  bool get _revealed => _toggled || _holding;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _toggled = !_toggled),
      onLongPressStart: (_) => setState(() => _holding = true),
      onLongPressEnd: (_) => setState(() => _holding = false),
      onLongPressCancel: () => setState(() => _holding = false),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 150),
        child: KeyedSubtree(
          key: ValueKey(_revealed),
          child: widget.builder(context, _revealed),
        ),
      ),
    );
  }
}
