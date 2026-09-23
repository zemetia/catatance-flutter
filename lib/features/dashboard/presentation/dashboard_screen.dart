import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/widgets.dart';
import '../../accounts/presentation/account_providers.dart';
import '../../debts/presentation/widgets/dashboard_debt_card.dart';
import '../../profile/presentation/profile_settings_providers.dart';
import '../../reports/presentation/reports_providers.dart';
import '../../transactions/presentation/transaction_providers.dart';
import '../../transactions/presentation/widgets/transaction_tile.dart';
import 'dashboard_providers.dart';
import 'widgets/balance_overview_card.dart';
import 'widgets/dashboard_greeting_header.dart';
import 'widgets/dismissible_tip_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tipVisible = ref.watch(dashboardTipVisibleProvider);
    final userProfile = ref.watch(userProfileProvider);
    final totalBalance = ref.watch(totalBalanceProvider);
    final thisMonthIncome = ref.watch(thisMonthIncomeProvider).value ?? 0;
    final thisMonthExpense = ref.watch(thisMonthExpenseProvider).value ?? 0;
    final recentTransactions =
        ref.watch(dashboardRecentTransactionsProvider).value ?? const [];
    final monthDailyExpense =
        ref.watch(thisMonthDailyExpenseProvider).value ?? const [];

    final savings = (thisMonthIncome - thisMonthExpense).clamp(0, thisMonthIncome);
    final savingsPercent = thisMonthIncome > 0
        ? (savings / thisMonthIncome * 100).round()
        : 0;
    final savingsDesc = thisMonthIncome > 0
        ? 'Bulan ini nabung $savingsPercent% (${formatRupiah(savings)})'
        : 'Belum ada pemasukan bulan ini';

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
            DashboardGreetingHeader(
              displayName: userProfile.displayName,
              levelLabel: 'Pemula • 0',
              notificationCount: 1,
            ),
            const SizedBox(height: AppSpacing.lg),
            BalanceOverviewCard(
              balanceCents: totalBalance,
              walletLabel: 'Total Saldo',
              dailyExpenseCents: monthDailyExpense,
              onWalletTap: () => context.push('/wallets'),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: 'Pemasukan',
                    amountCents: thisMonthIncome,
                    icon: LucideIcons.arrow_down_left,
                    color: AppColors.income,
                    delay: const Duration(milliseconds: 40),
                    compact: true,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: StatCard(
                    label: 'Pengeluaran',
                    amountCents: thisMonthExpense,
                    icon: LucideIcons.arrow_up_right,
                    color: AppColors.expense,
                    delay: const Duration(milliseconds: 80),
                    compact: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const DashboardDebtCard(),
            const SizedBox(height: AppSpacing.md),
            const SuggestionCard(
              eyebrow: 'Saran untukmu',
              title: 'Belum ada budget bulan ini',
              description:
                  'Fokuskan pengeluaran rapi — mulai dari 1 budget untuk Lainnya.',
              icon: LucideIcons.chart_pie,
            ),
            if (recentTransactions.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Transaksi Terbaru',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/transactions'),
                    child: const Text('Lihat semua'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              AppCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                child: Column(
                  children: [
                    for (var i = 0; i < recentTransactions.length; i++) ...[
                      if (i > 0)
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                        ),
                      TransactionTile(
                        item: recentTransactions[i],
                        onTap: () => context.push('/transactions'),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            if (tipVisible) ...[
              const SizedBox(height: AppSpacing.lg),
              Text('Untukmu', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              DismissibleTipCard(
                title: 'Nabung jalan!',
                description: savingsDesc,
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
