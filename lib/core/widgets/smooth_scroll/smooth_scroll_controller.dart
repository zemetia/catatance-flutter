import 'package:flutter/material.dart';

/// Extension methods on [ScrollController] for butter-smooth animated scrolling.
extension SmoothScrollExtensions on ScrollController {
  /// Smoothly animates the scroll position to the target [offset].
  Future<void> smoothScrollTo(
    double offset, {
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.fastLinearToSlowEaseIn,
  }) {
    if (!hasClients) return Future.value();
    final clampedOffset = offset.clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    return animateTo(
      clampedOffset,
      duration: duration,
      curve: curve,
    );
  }

  /// Smoothly scrolls to the very top (offset 0).
  Future<void> smoothScrollToTop({
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.fastLinearToSlowEaseIn,
  }) {
    return smoothScrollTo(0.0, duration: duration, curve: curve);
  }

  /// Smoothly scrolls to the bottom ([position.maxScrollExtent]).
  Future<void> smoothScrollToBottom({
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.fastLinearToSlowEaseIn,
  }) {
    if (!hasClients) return Future.value();
    return smoothScrollTo(
      position.maxScrollExtent,
      duration: duration,
      curve: curve,
    );
  }

  /// Smoothly scrolls by a relative delta.
  Future<void> smoothScrollBy(
    double delta, {
    Duration duration = const Duration(milliseconds: 350),
    Curve curve = Curves.easeOutCubic,
  }) {
    if (!hasClients) return Future.value();
    return smoothScrollTo(
      offset + delta,
      duration: duration,
      curve: curve,
    );
  }
}

/// A specialized [ScrollController] that tracks threshold state
/// (e.g., scrolled past header) for driving animated floating buttons or app bars.
class SmoothScrollController extends ScrollController {
  SmoothScrollController({
    this._threshold = 200.0,
    super.initialScrollOffset,
    super.keepScrollOffset,
    super.debugLabel,
  })  : isPastThreshold = ValueNotifier<bool>(false) {
    addListener(_handleScroll);
  }

  final double _threshold;

  /// ValueNotifier indicating whether user scrolled past [_threshold].
  final ValueNotifier<bool> isPastThreshold;

  void _handleScroll() {
    if (!hasClients) return;
    final past = offset > _threshold;
    if (isPastThreshold.value != past) {
      isPastThreshold.value = past;
    }
  }

  @override
  void dispose() {
    removeListener(_handleScroll);
    isPastThreshold.dispose();
    super.dispose();
  }
}
