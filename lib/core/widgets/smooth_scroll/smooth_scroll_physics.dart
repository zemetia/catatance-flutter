import 'package:flutter/material.dart';

/// Custom bouncing scroll physics finely tuned for a fluid, luxurious feel.
///
/// Features a gentle mass, balanced stiffness, and critically damped spring
/// that eliminates harsh sudden stops while preserving smooth momentum.
class SmoothScrollPhysics extends BouncingScrollPhysics {
  const SmoothScrollPhysics({super.parent});

  @override
  SmoothScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return SmoothScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => SpringDescription.withDampingRatio(
        mass: 0.5,
        stiffness: 100.0,
        ratio: 1.25,
      );

  @override
  double get minFlingVelocity => 40.0;

  @override
  double get maxFlingVelocity => 8000.0;

  @override
  double frictionFactor(double overscrollFraction) {
    // Smoother resistance curve when entering overscroll
    return 0.52 * (1 - overscrollFraction);
  }
}
