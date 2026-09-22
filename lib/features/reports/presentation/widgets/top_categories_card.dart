import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/report_models.dart';
import '../reports_providers.dart';
import 'report_shimmer_box.dart';

/// "Kategori teratas" card: the top expense categories for the selected
/// month with a share bar per row.
class TopCategoriesCard extends ConsumerWidget {
  const TopCategoriesCard({this.onSeeAll, super.key});

  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoryBreakdownProvider);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      delay: 200.ms,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Kategori teratas',
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              TextButton(onPressed: onSeeAll, child: const Text('Lihat semua')),
            ],
          ),
          categories.when(
            data: (items) => items.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    child: Text(
                      'Belum ada pengeluaran bulan ini',
                      style: textTheme.bodySmall?.copyWith(color: scheme.outline),
                    ),
                  )
                : Column(
                    children: [
                      for (final item in items.take(5))
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.sm),
                          child: _CategoryRow(item: item),
                        ),
                    ],
                  ),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: ReportShimmerBox(width: double.infinity, height: 48),
            ),
            error: (err, st) => Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Text(
                'Gagal memuat data',
                style: textTheme.bodySmall?.copyWith(color: scheme.error),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.item});

  final CategorySpending item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final percentLabel = '${(item.share * 100).round()}%';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                item.name,
                style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              percentLabel,
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
            value: item.share.clamp(0, 1),
            minHeight: 8,
            backgroundColor: scheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(scheme.primary),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${formatRupiahCompact(item.totalCents)} • $percentLabel',
          style: textTheme.bodySmall?.copyWith(color: scheme.outline),
        ),
      ],
    );
  }
}
