import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/widgets.dart';

/// Large hero card showing total balance across wallets, with a decorative
/// concentric-circle backdrop and a per-day expense bar strip for the
/// current month. The whole card is tappable, opening the wallets list.
class BalanceOverviewCard extends StatelessWidget {
  const BalanceOverviewCard({
    required this.balanceCents,
    required this.walletLabel,
    this.dailyExpenseCents = const [],
    this.onWalletTap,
    super.key,
  });

  final int balanceCents;
  final String walletLabel;

  /// Expense total per day of the current month, one entry per day
  /// (index 0 = the 1st). Empty while still loading.
  final List<int> dailyExpenseCents;
  final VoidCallback? onWalletTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      color: scheme.primaryContainer.withValues(alpha: 0.18),
      padding: const EdgeInsets.all(AppSpacing.lg),
      onTap: onWalletTap,
      backgroundLayers: const [
        Positioned(right: -40, top: -40, child: DecorativeCircle(size: 160, alpha: 0.12)),
        Positioned(right: -10, top: -10, child: DecorativeCircle(size: 100, alpha: 0.16)),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total saldo',
            style: textTheme.bodyMedium?.copyWith(color: scheme.outline),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            formatRupiah(balanceCents),
            style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: scheme.tertiary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(walletLabel, style: textTheme.bodyMedium),
              const SizedBox(width: AppSpacing.xs),
              Icon(LucideIcons.chevron_right, size: 16, color: scheme.outline),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _DailyExpenseBarStrip(
            valuesCents: dailyExpenseCents,
            color: scheme.primary,
            trackColor: scheme.outline,
          ),
        ],
      ),
    );
  }
}

/// One bar per day of the current month, full card width (an `Expanded`
/// bar each, with a thin gap between), height proportional to that day's
/// expense. Today's bar is highlighted.
class _DailyExpenseBarStrip extends StatelessWidget {
  const _DailyExpenseBarStrip({
    required this.valuesCents,
    required this.color,
    required this.trackColor,
  });

  final List<int> valuesCents;
  final Color color;
  final Color trackColor;

  @override
  Widget build(BuildContext context) {
    if (valuesCents.isEmpty) return const SizedBox(height: 36);

    final maxValue = valuesCents.fold<int>(0, (max, v) => v > max ? v : max);
    final todayIndex = DateTime.now().day - 1;

    return SizedBox(
      height: 36,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < valuesCents.length; i++) ...[
            if (i > 0) const SizedBox(width: 2),
            Expanded(
              child: Container(
                height: maxValue == 0
                    ? 36 * 0.08
                    : 36 * (valuesCents[i] / maxValue).clamp(0.08, 1.0),
                decoration: BoxDecoration(
                  color: i == todayIndex
                      ? color
                      : trackColor.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
