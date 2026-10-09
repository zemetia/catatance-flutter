import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'smooth_scroll_physics.dart';

/// App-wide [ScrollBehavior] providing fluid physics, multi-input device
/// drag support (touch, mouse, trackpad, stylus), and clean overscroll handling.
class SmoothScrollBehavior extends MaterialScrollBehavior {
  const SmoothScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const SmoothScrollPhysics();
  }

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    // With SmoothScrollPhysics's natural bounce, suppress the harsh Android
    // stretch distortion to maintain a clean, consistent fintech look across platforms.
    return child;
  }
}
