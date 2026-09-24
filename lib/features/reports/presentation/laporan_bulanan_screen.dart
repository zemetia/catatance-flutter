import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/widgets.dart';
import '../domain/report_models.dart';
import 'laporan_bulanan_providers.dart';
import 'widgets/laporan_breakdown_cards.dart';
import 'widgets/laporan_daily_chart_card.dart';
import 'widgets/laporan_summary_card.dart';

/// "Laporan bulanan" detail screen (pushed from Statistik): a single
/// month's net summary, a per-day spending chart, and a Pengeluaran/
/// Pemasukan breakdown by category and by `#tag`.
class LaporanBulananScreen extends ConsumerWidget {
  const LaporanBulananScreen({super.key});

  void _comingSoon(BuildContext context, String label) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$label segera hadir')));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(laporanBulananMonthProvider);
    final mode = ref.watch(laporanBulananModeProvider);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    void changeMonth(int delta) {
      ref.read(laporanBulananMonthProvider.notifier).state =
          DateTime(month.year, month.month + delta);
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                children: [
                  Row(
                    children: [
                      CircleIconButton(
                        icon: LucideIcons.chevron_left,
                        backgroundColor: scheme.surfaceContainerHigh,
                        onTap: () => context.pop(),
                      ),
                      Expanded(
                        child: Text(
                          'Laporan bulanan',
                          textAlign: TextAlign.center,
                          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      CircleIconButton(
                        icon: LucideIcons.download,
                        backgroundColor: scheme.surfaceContainerHigh,
                        onTap: () => _comingSoon(context, 'Ekspor laporan'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleIconButton(
                        icon: LucideIcons.chevron_left,
                        size: 18,
                        onTap: () => changeMonth(-1),
                      ),
                      SizedBox(
                        width: 180,
                        child: Text(
                          DateFormat('MMMM yyyy', 'id_ID').format(month),
                          textAlign: TextAlign.center,
                          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      CircleIconButton(
                        icon: LucideIcons.chevron_right,
                        size: 18,
                        onTap: () => changeMonth(1),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const LaporanSummaryCard(),
                  const SizedBox(height: AppSpacing.md),
                  const LaporanDailyChartCard(),
                  const SizedBox(height: AppSpacing.md),
                  _ExpenseIncomeToggle(
                    selected: mode,
                    onChanged: (m) => ref.read(laporanBulananModeProvider.notifier).state = m,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const LaporanCategoryBreakdownCard(),
                  const SizedBox(height: AppSpacing.md),
                  const LaporanTagBreakdownCard(),
                  const SizedBox(height: AppSpacing.md),
                  OutlinedButton.icon(
                    onPressed: () => _comingSoon(context, 'Laporan tahunan'),
                    icon: const Icon(LucideIcons.grid_3x3, size: 18),
                    label: Text('Lihat laporan tahun ${month.year}'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      side: BorderSide(color: scheme.primary.withValues(alpha: 0.5)),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: FilledButton.icon(
                onPressed: () => _comingSoon(context, 'Ekspor laporan'),
                icon: const Icon(LucideIcons.upload, size: 18),
                label: const Text('Ekspor'),
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseIncomeToggle extends StatelessWidget {
  const _ExpenseIncomeToggle({required this.selected, required this.onChanged});

  final ReportMode selected;
  final ValueChanged<ReportMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Widget item(ReportMode mode) {
      final isSelected = mode == selected;
      return Expanded(
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: InkWell(
            onTap: () => onChanged(mode),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: isSelected ? scheme.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              alignment: Alignment.center,
              child: Text(
                mode.label,
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? scheme.onPrimary : scheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: Row(
        children: [item(ReportMode.expense), item(ReportMode.income)],
      ),
    );
  }
}
