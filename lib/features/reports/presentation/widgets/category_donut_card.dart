import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/report_models.dart';
import '../reports_providers.dart';
import 'report_shimmer_box.dart';

/// "Pengeluaran per kategori" card: a donut chart with a legend of the top
/// expense categories for the selected month.
class CategoryDonutCard extends ConsumerWidget {
  const CategoryDonutCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoryBreakdownProvider);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      delay: 80.ms,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pengeluaran per kategori',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.lg),
          categories.when(
            data: (items) => _DonutBody(items: items),
            loading: () => const SizedBox(
              height: 140,
              child: Center(child: ReportShimmerBox(width: 140, height: 140)),
            ),
            error: (err, st) => SizedBox(
              height: 140,
              child: Center(
                child: Text(
                  'Gagal memuat data',
                  style: textTheme.bodySmall?.copyWith(color: scheme.error),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutBody extends StatelessWidget {
  const _DonutBody({required this.items});

  final List<CategorySpending> items;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final palette = [
      scheme.primary,
      scheme.secondary,
      scheme.tertiary,
      const Color(0xFFB57BFF),
      const Color(0xFFFF6B9A),
    ];

    if (items.isEmpty) {
      return SizedBox(
        height: 140,
        child: Center(
          child: Text(
            'Belum ada pengeluaran bulan ini',
            style: textTheme.bodySmall?.copyWith(color: scheme.outline),
          ),
        ),
      );
    }

    final total = items.fold<int>(0, (sum, item) => sum + item.totalCents);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 140,
          height: 140,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sections: [
                    for (var i = 0; i < items.length; i++)
                      PieChartSectionData(
                        value: items[i].totalCents.toDouble(),
                        color: palette[i % palette.length],
                        radius: 20,
                        showTitle: false,
                      ),
                  ],
                  centerSpaceRadius: 48,
                  sectionsSpace: 2,
                ),
              ).animate().fadeIn(duration: 300.ms),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formatRupiahCompact(total),
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  Text('Total belanja', style: textTheme.labelSmall?.copyWith(color: scheme.outline)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < items.length && i < 5; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: palette[i % palette.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          items[i].name,
                          style: textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${(items[i].share * 100).round()}%',
                        style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
