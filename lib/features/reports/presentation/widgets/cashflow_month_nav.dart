import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';

/// "< Sep 2026 >" pill row for switching the month the "Kalender Cashflow"
/// screen's grid and summary aggregate.
class CashflowMonthNav extends StatelessWidget {
  const CashflowMonthNav({
    required this.month,
    required this.onPrevious,
    required this.onNext,
    super.key,
  });

  final DateTime month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final label = DateFormat('MMM y', 'id_ID').format(month);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleIconButton(
          icon: LucideIcons.chevron_left,
          onTap: onPrevious,
          backgroundColor: scheme.surfaceContainerHigh,
        ),
        const SizedBox(width: AppSpacing.md),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          ),
          child: Text(
            label,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        CircleIconButton(
          icon: LucideIcons.chevron_right,
          onTap: onNext,
          backgroundColor: scheme.surfaceContainerHigh,
        ),
      ],
    );
  }
}
