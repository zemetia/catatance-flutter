import 'package:flutter/material.dart';

/// A soft translucent circle used as a decorative backdrop layer on
/// [AppCard]s (e.g. the balance card's concentric-ring background).
class DecorativeCircle extends StatelessWidget {
  const DecorativeCircle({required this.size, this.color, this.alpha = 0.12, super.key});

  final double size;
  final Color? color;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    final base = color ?? Theme.of(context).colorScheme.primary;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: base.withValues(alpha: alpha),
      ),
    );
  }
}
