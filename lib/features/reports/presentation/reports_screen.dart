import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/widgets.dart';
import 'reports_providers.dart';
import 'widgets/category_donut_card.dart';
import 'widgets/expense_bar_chart_card.dart';
import 'widgets/month_summary_card.dart';
import 'widgets/monthly_trend_card.dart';
import 'widgets/net_worth_card.dart';
import 'widgets/report_mode_switch.dart';
import 'widgets/report_month_selector.dart';
import 'widgets/top_categories_card.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  void _comingSoon(BuildContext context, String label) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$label segera hadir')));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedReportMonthProvider);
    final selectedMode = ref.watch(selectedReportModeProvider);
    final months = reportMonthOptions();

    final menuItems = [
      MenuSectionItem(
        icon: LucideIcons.sparkles,
        label: 'Proyeksi',
        description: 'Skor kesehatan + jatah harian aman',
        onTap: () => context.push('/reports/proyeksi'),
      ),
      MenuSectionItem(
        icon: LucideIcons.notebook_text,
        label: 'Laporan bulanan',
        description: 'Rincian kategori, tag & ekspor',
        onTap: () => context.push('/reports/laporan-bulanan'),
      ),
      MenuSectionItem(
        icon: LucideIcons.trending_up,
        label: 'Radar Harga',
        description: 'Pantau harga barang langgananmu',
        onTap: () => context.push('/reports/radar-harga'),
      ),
      MenuSectionItem(
        icon: LucideIcons.calendar_days,
        label: 'Kalender Cashflow',
        description: 'Arus harian + jatuh tempo',
        onTap: () => context.push('/reports/kalender-cashflow'),
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            FloatingNavBar.clearance,
          ),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Statistik',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      Text(
                        'Ringkasan belanja',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                CircleIconButton(
                  icon: LucideIcons.calendar_days,
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                  onTap: () => _comingSoon(context, 'Pilih tanggal'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            ReportMonthSelector(
              months: months,
              selected: selectedMonth,
              onSelected: (month) =>
                  ref.read(selectedReportMonthProvider.notifier).state = month,
            ),
            const SizedBox(height: AppSpacing.md),
            ReportModeSwitch(
              selected: selectedMode,
              onChanged: (mode) =>
                  ref.read(selectedReportModeProvider.notifier).state = mode,
            ),
            const SizedBox(height: AppSpacing.md),
            NetWorthCard(onTap: () => _comingSoon(context, 'Detail kekayaan bersih')),
            const SizedBox(height: AppSpacing.md),
            const MonthSummaryCard(),
            const SizedBox(height: AppSpacing.md),
            const ExpenseBarChartCard(),
            const SizedBox(height: AppSpacing.md),
            const CategoryDonutCard(),
            const SizedBox(height: AppSpacing.md),
            const MonthlyTrendCard(),
            const SizedBox(height: AppSpacing.md),
            MenuSection(items: menuItems),
            const SizedBox(height: AppSpacing.md),
            TopCategoriesCard(onSeeAll: () => _comingSoon(context, 'Semua kategori')),
            const SizedBox(height: AppSpacing.md),
            SuggestionCard(
              eyebrow: 'Saran untukmu',
              title: 'Belum ada budget bulan ini',
              description: 'Fokuskan pengeluaran rapi — mulai dari 1 budget untuk Lainnya.',
              icon: LucideIcons.chart_pie,
              onTap: () => _comingSoon(context, 'Buat budget'),
            ),
          ],
        ),
      ),
    );
  }
}
