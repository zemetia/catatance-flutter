import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

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
        ? 'Melebihi anggaran • ${budget.periodLabel}'
        : '${formatRupiahCompact(budget.remainingCents)} tersisa • ${budget.periodLabel}';

    return AppCard(
      delay: delay,
      onTap: onTap,
      color: statusColor.withValues(alpha: 0.06),
      backgroundLayers: [
        Positioned(
          right: -28,
          top: -28,
          child: DecorativeCircle(size: 92, color: statusColor, alpha: 0.08),
        ),
      ],
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(icon: budget.icon, color: statusColor, shape: BoxShape.rectangle),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              budget.name,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          if (budget.carryOverCents > 0) ...[
                            const SizedBox(width: AppSpacing.xs),
                            Icon(LucideIcons.repeat, size: 13, color: statusColor),
                          ],
                        ],
                      ),
                    ),
                    Text(
                      '${formatRupiahCompact(budget.spentCents)} of ${formatRupiahCompact(budget.totalLimitCents)}',
                      style: textTheme.bodySmall?.copyWith(color: scheme.outline),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  child: LinearProgressIndicator(
                    value: budget.progress == 0 ? 0.02 : budget.progress,
                    minHeight: 8,
                    backgroundColor: statusColor.withValues(alpha: 0.14),
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
