import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Circular progress ring showing the health score (0–100) as a filled arc
/// out of 100, with the numeric score centered inside.
class HealthScoreRing extends StatelessWidget {
  const HealthScoreRing({
    required this.score,
    required this.color,
    this.size = 128,
    this.strokeWidth = 12,
    super.key,
  });

  final int score;
  final Color color;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: (score / 100).clamp(0.0, 1.0)),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutCubic,
        builder: (context, value, _) {
          return CustomPaint(
            painter: _RingPainter(
              progress: value,
              color: color,
              trackColor: scheme.outlineVariant.withValues(alpha: 0.3),
              strokeWidth: strokeWidth,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$score',
                    style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    'skor',
                    style: textTheme.bodySmall?.copyWith(color: scheme.outline),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, 2 * math.pi, false, trackPaint);

    if (progress <= 0) return;
    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * progress, false, fgPaint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.trackColor != trackColor;
}
