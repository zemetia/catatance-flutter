import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/widgets.dart';
import 'dashboard_providers.dart';
import 'widgets/balance_overview_card.dart';
import 'widgets/dashboard_greeting_header.dart';
import 'widgets/dismissible_tip_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tipVisible = ref.watch(dashboardTipVisibleProvider);

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
            const DashboardGreetingHeader(
              displayName: 'Pengguna',
              levelLabel: 'Pemula • 0',
              notificationCount: 1,
            ),
            const SizedBox(height: AppSpacing.lg),
            const BalanceOverviewCard(
              balanceCents: 0,
              walletLabel: 'Dompet Utama',
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: 'Pemasukan',
                    amountCents: 0,
                    icon: LucideIcons.arrow_down_left,
                    color: AppColors.income,
                    delay: const Duration(milliseconds: 40),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: StatCard(
                    label: 'Pengeluaran',
                    amountCents: 0,
                    icon: LucideIcons.arrow_up_right,
                    color: AppColors.expense,
                    delay: const Duration(milliseconds: 80),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const SuggestionCard(
              eyebrow: 'Saran untukmu',
              title: 'Belum ada budget bulan ini',
              description:
                  'Fokuskan pengeluaran rapi — mulai dari 1 budget untuk Lainnya.',
              icon: LucideIcons.chart_pie,
            ),
            if (tipVisible) ...[
              const SizedBox(height: AppSpacing.lg),
              Text('Untukmu', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              DismissibleTipCard(
                title: 'Nabung jalan!',
                description: 'Bulan ini nabung 0% (Rp 0)',
                icon: LucideIcons.piggy_bank,
                onDismiss: () =>
                    ref.read(dashboardTipVisibleProvider.notifier).state =
                        false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
