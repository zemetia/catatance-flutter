import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Small color-key row explaining the calendar grid's day-cell tinting.
class CashflowLegend extends StatelessWidget {
  const CashflowLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        _LegendDot(color: AppColors.income, label: 'Masuk'),
        SizedBox(width: AppSpacing.md),
        _LegendDot(color: AppColors.expense, label: 'Keluar'),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: textTheme.bodySmall?.copyWith(color: scheme.outline)),
      ],
    );
  }
}
