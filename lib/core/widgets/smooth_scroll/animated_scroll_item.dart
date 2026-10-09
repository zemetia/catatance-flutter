import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Wraps list or card items with a staggered, fluid entrance animation
/// (fade + subtle slide up + micro-scale spring).
class AnimatedScrollItem extends StatelessWidget {
  const AnimatedScrollItem({
    required this.child,
    this.index = 0,
    this.staggerMs = 35,
    this.maxDelayMs = 350,
    this.duration = const Duration(milliseconds: 380),
    this.slideBegin = 0.08,
    this.curve = Curves.easeOutCubic,
    this.enabled = true,
    super.key,
  });

  final Widget child;

  /// Index of the item in the list, used to calculate cascade delay.
  final int index;

  /// Delay step in milliseconds per index.
  final int staggerMs;

  /// Maximum delay cap so items deep in a list don't wait indefinitely.
  final int maxDelayMs;

  /// Animation duration for each item.
  final Duration duration;

  /// Relative vertical starting slide offset (e.g. 0.08 = 8% slide up).
  final double slideBegin;

  /// Easing curve for entrance.
  final Curve curve;

  /// Whether animation is active. Set false to disable entrance animations (e.g. in tests).
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    final delay = Duration(
      milliseconds: (index * staggerMs).clamp(0, maxDelayMs),
    );

    return child
        .animate(delay: delay)
        .fadeIn(
          duration: duration,
          curve: curve,
        )
        .slideY(
          begin: slideBegin,
          end: 0.0,
          duration: duration,
          curve: curve,
        );
  }
}
