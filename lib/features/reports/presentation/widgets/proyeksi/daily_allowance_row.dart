import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../projection_providers.dart';
import '../report_shimmer_box.dart';

/// Three-column stat row: safe daily allowance, average spend/day, and days
/// left in the month.
class DailyAllowanceRow extends ConsumerWidget {
  const DailyAllowanceRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projection = ref.watch(monthProjectionProvider);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (projection == null) {
      return AppCard(
        child: Row(
          children: const [
            Expanded(child: ReportShimmerBox(width: double.infinity, height: 40)),
            SizedBox(width: AppSpacing.md),
            Expanded(child: ReportShimmerBox(width: double.infinity, height: 40)),
            SizedBox(width: AppSpacing.md),
            Expanded(child: ReportShimmerBox(width: double.infinity, height: 40)),
          ],
        ),
      );
    }

    Widget stat(String label, String value, {Color? valueColor}) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(color: scheme.outline),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: valueColor,
              ),
            ),
          ],
        ),
      );
    }

    return AppCard(
      child: IntrinsicHeight(
        child: Row(
          children: [
            stat(
              'Jatah harian aman',
              formatRupiahCompact(projection.dailySafeAllowanceCents),
              valueColor: scheme.primary,
            ),
            VerticalDivider(width: AppSpacing.md, color: scheme.outlineVariant.withValues(alpha: 0.4)),
            stat('Rata-rata belanja/\nhari', formatRupiahCompact(projection.avgDailySpendCents)),
            VerticalDivider(width: AppSpacing.md, color: scheme.outlineVariant.withValues(alpha: 0.4)),
            stat('Hari tersisa', '${projection.daysRemaining}'),
          ],
        ),
      ),
    );
  }
}
