import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../projection_providers.dart';
import '../report_shimmer_box.dart';

/// "Dari mana skornya?": the three score components as labeled progress
/// bars, out of their own max (40/30/30).
class ScoreBreakdownCard extends ConsumerWidget {
  const ScoreBreakdownCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projection = ref.watch(monthProjectionProvider);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (projection == null) {
      return const AppCard(child: ReportShimmerBox(width: double.infinity, height: 140));
    }

    Widget row(String label, int value, int max) {
      final progress = max == 0 ? 0.0 : (value / max).clamp(0.0, 1.0);
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(label, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                ),
                Text(
                  '$value/$max',
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              child: LinearProgressIndicator(
                value: progress == 0 ? 0.02 : progress,
                minHeight: 8,
                backgroundColor: scheme.primary.withValues(alpha: 0.12),
                color: scheme.primary,
              ),
            ),
          ],
        ),
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dari mana skornya?',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.md),
          row('Arus kas (pemasukan vs belanja)', projection.cashflowScore, 40),
          row('Arah saldo akhir bulan', projection.balanceDirectionScore, 30),
          row('Kepatuhan budget', projection.budgetComplianceScore, 30),
        ],
      ),
    );
  }
}
