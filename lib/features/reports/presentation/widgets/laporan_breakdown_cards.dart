import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../categories/domain/category_item.dart';
import '../laporan_bulanan_providers.dart';
import 'report_shimmer_box.dart';

/// "Per kategori" card for the Laporan Bulanan screen: one row per category
/// with its share bar and transaction count, for whichever side of the
/// ledger [laporanBulananModeProvider] currently selects.
class LaporanCategoryBreakdownCard extends ConsumerWidget {
  const LaporanCategoryBreakdownCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(laporanCategoryBreakdownProvider);

    return _BreakdownCardShell(
      title: 'Per kategori',
      emptyLabel: 'Belum ada transaksi berkategori bulan ini',
      itemsAsync: items,
      rowBuilder: (item) => _BreakdownRow(
        color: Color(item.colorValue),
        icon: CategoryItem.iconFor(item.icon),
        label: item.name,
        amountCents: item.totalCents,
        share: item.share,
        count: item.count,
      ),
    );
  }
}

/// "Per tag" card: one row per `#tag` found in this month's transaction
/// notes. Rows share [_BreakdownRow]'s layout with [LaporanCategoryBreakdownCard]
/// but always use a generic tag icon/color since tags have no stored color.
class LaporanTagBreakdownCard extends ConsumerWidget {
  const LaporanTagBreakdownCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(laporanTagBreakdownProvider);
    final scheme = Theme.of(context).colorScheme;

    return _BreakdownCardShell(
      title: 'Per tag',
      emptyLabel: 'Belum ada tag bulan ini',
      itemsAsync: items,
      rowBuilder: (item) => _BreakdownRow(
        color: scheme.tertiary,
        icon: LucideIcons.hash,
        label: '#${item.tag}',
        amountCents: item.totalCents,
        share: item.share,
        count: item.count,
      ),
    );
  }
}

class _BreakdownCardShell<T> extends StatelessWidget {
  const _BreakdownCardShell({
    required this.title,
    required this.emptyLabel,
    required this.itemsAsync,
    required this.rowBuilder,
  });

  final String title;
  final String emptyLabel;
  final AsyncValue<List<T>> itemsAsync;
  final Widget Function(T item) rowBuilder;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.md),
          itemsAsync.when(
            data: (list) => list.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    child: Text(
                      emptyLabel,
                      style: textTheme.bodySmall?.copyWith(color: scheme.outline),
                    ),
                  )
                : Column(children: [for (final item in list) rowBuilder(item)]),
            loading: () => const Column(
              children: [
                ReportShimmerBox(width: double.infinity, height: 48),
                SizedBox(height: AppSpacing.sm),
                ReportShimmerBox(width: double.infinity, height: 48),
              ],
            ),
            error: (err, st) => Text(
              'Gagal memuat data',
              style: textTheme.bodySmall?.copyWith(color: scheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.color,
    required this.icon,
    required this.label,
    required this.amountCents,
    required this.share,
    required this.count,
  });

  final Color color;
  final IconData icon;
  final String label;
  final int amountCents;
  final double share;
  final int count;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(icon: icon, color: color, size: 18, shape: BoxShape.rectangle),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                formatRupiahCompact(amountCents.abs()),
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            child: LinearProgressIndicator(
              value: share.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: scheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${(share * 100).round()}% • ${count}x',
            style: textTheme.labelSmall?.copyWith(color: scheme.outline),
          ),
        ],
      ),
    );
  }
}
