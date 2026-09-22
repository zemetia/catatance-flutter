import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/widgets.dart';
import '../budget_providers.dart';

/// One row card for a category budget: icon, name, spent-of-limit, a thin
/// progress bar, and a "remaining • days left" caption colored by [BudgetStatus].
class BudgetProgressCard extends StatelessWidget {
  const BudgetProgressCard({
    required this.budget,
    this.delay = Duration.zero,
    this.onTap,
    super.key,
  });

  final BudgetItem budget;
  final Duration delay;
  final VoidCallback? onTap;

  Color _statusColor(BuildContext context) => switch (budget.status) {
    BudgetStatus.safe => AppColors.income,
    BudgetStatus.caution => AppColors.warning,
    BudgetStatus.over => AppColors.expense,
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final statusColor = _statusColor(context);
    final caption = budget.status == BudgetStatus.over
        ? 'Melebihi anggaran • ${budget.daysLeft} hari'
        : '${formatRupiahCompact(budget.remainingCents)} tersisa • ${budget.daysLeft} hari';

    return AppCard(
      delay: delay,
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(icon: budget.icon, shape: BoxShape.rectangle),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        budget.name,
                        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      '${formatRupiahCompact(budget.spentCents)} of ${formatRupiahCompact(budget.limitCents)}',
                      style: textTheme.bodySmall?.copyWith(color: scheme.outline),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  child: LinearProgressIndicator(
                    value: budget.progress == 0 ? 0.02 : budget.progress,
                    minHeight: 6,
                    backgroundColor: scheme.outline.withValues(alpha: 0.15),
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  caption,
                  style: textTheme.bodySmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
