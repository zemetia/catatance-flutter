import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../projection_providers.dart';
import '../report_shimmer_box.dart';
import 'health_score_ring.dart';

/// Hero card: the health-score ring plus the projected end-of-month balance
/// and how it compares to today's balance.
class ProyeksiHeaderCard extends ConsumerWidget {
  const ProyeksiHeaderCard({super.key});

  Color _scoreColor(int score) {
    if (score >= 80) return AppColors.income;
    if (score >= 50) return AppColors.warning;
    return AppColors.expense;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projection = ref.watch(monthProjectionProvider);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (projection == null) {
      return AppCard(
        child: Row(
          children: [
            const ReportShimmerBox(width: 128, height: 128),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  ReportShimmerBox(width: 80, height: 16),
                  SizedBox(height: AppSpacing.sm),
                  ReportShimmerBox(width: 140, height: 28),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final color = _scoreColor(projection.healthScore);
    final delta = projection.deltaFromNowCents;
    final deltaColor = delta >= 0 ? AppColors.income : AppColors.expense;
    final deltaLabel = delta >= 0
        ? 'Naik ${formatRupiahCompact(delta)} dari saldo awal'
        : 'Turun ${formatRupiahCompact(-delta)} dari saldo awal';

    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          HealthScoreRing(score: projection.healthScore, color: color),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.circle_check_big, size: 16, color: color),
                    const SizedBox(width: 4),
                    Text(
                      projection.healthLabel,
                      style: textTheme.titleMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Proyeksi akhir bulan',
                  style: textTheme.bodyMedium?.copyWith(color: scheme.outline),
                ),
                Text(
                  formatRupiahCompact(projection.projectedEndBalanceCents),
                  style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  deltaLabel,
                  style: textTheme.bodySmall?.copyWith(
                    color: deltaColor,
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
