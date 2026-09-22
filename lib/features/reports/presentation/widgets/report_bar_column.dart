import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_spacing.dart';

/// One labeled, animated column in a simple bar chart (used by the weekly
/// expense chart and the 5-month trend chart).
class ReportBarColumn extends StatelessWidget {
  const ReportBarColumn({
    required this.valueLabel,
    required this.axisLabel,
    required this.heightFraction,
    required this.highlighted,
    this.maxBarHeight = 120,
    super.key,
  });

  final String valueLabel;
  final String axisLabel;
  final double heightFraction;
  final bool highlighted;
  final double maxBarHeight;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final barHeight = 8.0 + heightFraction.clamp(0, 1) * (maxBarHeight - 8.0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          valueLabel,
          textAlign: TextAlign.center,
          style: textTheme.labelSmall?.copyWith(
            color: highlighted ? scheme.primary : scheme.outline,
            fontWeight: highlighted ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          height: barHeight,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: highlighted ? scheme.primary : scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
        ).animate().scaleY(
              begin: 0,
              end: 1,
              duration: 320.ms,
              curve: Curves.easeOutCubic,
              alignment: Alignment.bottomCenter,
            ),
        const SizedBox(height: AppSpacing.xs),
        Text(axisLabel, style: textTheme.labelSmall?.copyWith(color: scheme.outline)),
      ],
    );
  }
}
