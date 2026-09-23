import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/security/security_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/report_models.dart';
import '../reports_providers.dart';
import 'report_shimmer_box.dart';

/// "Pengeluaran per kategori" card: an interactive donut chart with a legend
/// of the top categories (expense, income, or net) for the selected month.
/// The total and per-category percentages stay masked until the chart is
/// tapped or a legend row is clicked.
class CategoryDonutCard extends ConsumerWidget {
  const CategoryDonutCard({super.key});

  static String _titleFor(ReportMode mode) => switch (mode) {
    ReportMode.expense => 'Pengeluaran per kategori',
    ReportMode.income => 'Pemasukan per kategori',
    ReportMode.net => 'Per kategori (bersih)',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoryBreakdownProvider);
    final mode = ref.watch(selectedReportModeProvider);
    final hideBalance = ref.watch(hideBalanceProvider);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      delay: 80.ms,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _titleFor(mode),
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.lg),
          categories.when(
            data: (items) => _DonutBody(
              items: items,
              mode: mode,
              hideBalance: hideBalance,
            ),
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

class _DonutBody extends StatefulWidget {
  const _DonutBody({
    required this.items,
    required this.mode,
    required this.hideBalance,
  });

  final List<CategorySpending> items;
  final ReportMode mode;
  final bool hideBalance;

  @override
  State<_DonutBody> createState() => _DonutBodyState();
}

class _DonutBodyState extends State<_DonutBody> {
  int? _touchedIndex;
  bool _holdingTotal = false;

  Color _colorFor(int index, CategorySpending item, List<Color> palette) {
    if (widget.mode == ReportMode.net) {
      return item.totalCents >= 0 ? AppColors.income : AppColors.expense;
    }
    return palette[index % palette.length];
  }

  String get _emptyLabel => switch (widget.mode) {
    ReportMode.expense => 'Belum ada pengeluaran bulan ini',
    ReportMode.income => 'Belum ada pemasukan bulan ini',
    ReportMode.net => 'Belum ada transaksi bulan ini',
  };

  String get _centerLabel => switch (widget.mode) {
    ReportMode.expense => 'Total belanja',
    ReportMode.income => 'Total pemasukan',
    ReportMode.net => 'Total bersih',
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final items = widget.items;
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
            _emptyLabel,
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
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      if (event is! FlTapUpEvent) return;
                      final section = response?.touchedSection?.touchedSectionIndex;
                      setState(() {
                        if (section != null && section >= 0) {
                          if (_touchedIndex == section) {
                            _touchedIndex = null;
                            _holdingTotal = false;
                          } else {
                            _touchedIndex = section;
                            _holdingTotal = false;
                          }
                        } else {
                          _touchedIndex = null;
                          _holdingTotal = !_holdingTotal;
                        }
                      });
                    },
                  ),
                  sections: [
                    for (var i = 0; i < items.length; i++)
                      PieChartSectionData(
                        value: items[i].totalCents.abs().toDouble(),
                        color: _colorFor(i, items[i], palette),
                        radius: _touchedIndex == i ? 26 : 20,
                        showTitle: false,
                      ),
                  ],
                  centerSpaceRadius: 44,
                  sectionsSpace: 2,
                ),
              ).animate().fadeIn(duration: 300.ms),
              SizedBox(
                width: 104,
                child: _DonutCenterContent(
                  touchedItem: _touchedIndex != null && _touchedIndex! < items.length
                      ? items[_touchedIndex!]
                      : null,
                  showTotal: _holdingTotal,
                  total: total,
                  centerLabel: _centerLabel,
                  hideBalance: widget.hideBalance,
                ),
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
                _LegendRow(
                  color: _colorFor(i, items[i], palette),
                  name: items[i].name,
                  sharePercent: (items[i].share * 100).round(),
                  highlighted: _touchedIndex == i,
                  hideBalance: widget.hideBalance,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DonutCenterContent extends StatelessWidget {
  const _DonutCenterContent({
    required this.touchedItem,
    required this.showTotal,
    required this.total,
    required this.centerLabel,
    required this.hideBalance,
  });

  final CategorySpending? touchedItem;
  final bool showTotal;
  final int total;
  final String centerLabel;
  final bool hideBalance;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (touchedItem != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            touchedItem!.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: textTheme.labelSmall?.copyWith(color: scheme.outline),
          ),
          Text(
            formatRupiahCompact(touchedItem!.totalCents),
            textAlign: TextAlign.center,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          Text(
            '${(touchedItem!.share * 100).round()}%',
            style: textTheme.labelSmall?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      );
    }

    if (showTotal || !hideBalance) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formatRupiahCompact(total),
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          Text(centerLabel, style: textTheme.labelSmall?.copyWith(color: scheme.outline)),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(LucideIcons.eye, size: 18, color: scheme.outline),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Ketuk untuk lihat total',
          textAlign: TextAlign.center,
          style: textTheme.labelSmall?.copyWith(color: scheme.outline),
        ),
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.name,
    required this.sharePercent,
    required this.highlighted,
    required this.hideBalance,
  });

  final Color color;
  final String name;
  final int sharePercent;
  final bool highlighted;
  final bool hideBalance;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              name,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: highlighted ? FontWeight.w700 : FontWeight.w400,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          hideBalance
              ? HoldToReveal(
                  builder: (context, revealed) => Text(
                    revealed ? '$sharePercent%' : '••%',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: revealed ? null : scheme.outline,
                    ),
                  ),
                )
              : Text(
                  '$sharePercent%',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ],
      ),
    );
  }
}
