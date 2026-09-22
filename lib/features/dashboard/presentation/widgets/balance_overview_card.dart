import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/widgets.dart';

/// Large hero card showing total balance across wallets, with a decorative
/// concentric-circle backdrop and a small trend sparkline.
class BalanceOverviewCard extends StatelessWidget {
  const BalanceOverviewCard({
    required this.balanceCents,
    required this.walletLabel,
    this.trend = const [0.3, 0.35, 0.45, 0.4, 0.5, 0.55, 0.7, 0.6, 0.8, 1],
    this.onWalletTap,
    super.key,
  });

  final int balanceCents;
  final String walletLabel;
  final List<double> trend;
  final VoidCallback? onWalletTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      color: scheme.primaryContainer.withValues(alpha: 0.18),
      padding: const EdgeInsets.all(AppSpacing.lg),
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
          InkWell(
            onTap: onWalletTap,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            child: Row(
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
          ),
          const SizedBox(height: AppSpacing.lg),
          _TrendSparkline(values: trend, color: scheme.primary),
        ],
      ),
    );
  }
}

class _TrendSparkline extends StatelessWidget {
  const _TrendSparkline({required this.values, required this.color});

  final List<double> values;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final highlightIndex = values.length - 1;

    return SizedBox(
      height: 36,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < values.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.xs),
            Container(
              width: 6,
              height: 36 * values[i].clamp(0.1, 1.0),
              decoration: BoxDecoration(
                color: i == highlightIndex
                    ? color
                    : scheme.outline.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
