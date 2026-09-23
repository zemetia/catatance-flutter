import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/widgets.dart';
import '../../accounts/presentation/account_providers.dart';
import '../../savings_goals/presentation/savings_goal_providers.dart';
import '../../savings_goals/presentation/widgets/savings_goal_item_card.dart';
import 'budget_providers.dart';
import 'widgets/budget_progress_card.dart';
import 'widgets/budget_section_header.dart';
import 'widgets/wallet_summary_card.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final budgets = ref.watch(liveBudgetListProvider);
    final goals = ref.watch(savingsGoalListProvider).value ?? const [];
    final periodLabel = ref.watch(currentBudgetPeriodLabelProvider);
    final accounts = ref.watch(accountListProvider).value ?? const [];
    final totalBalance = ref.watch(totalBalanceProvider);

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
                        'Anggaran',
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '$periodLabel • ${budgets.length} aktif',
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                CircleIconButton(
                  icon: LucideIcons.plus,
                  backgroundColor: scheme.primary,
                  onTap: () => context.push('/budget/new'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            if (budgets.isNotEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push('/budget/all'),
                  child: const Text('Lihat semua'),
                ),
              ),
            if (budgets.isEmpty)
              const EmptyStateCard(
                icon: LucideIcons.piggy_bank,
                title: 'Belum ada anggaran',
                description:
                    'Belum ada anggaran aktif. Buat anggaran per kategori untuk mulai memantau.',
              )
            else
              for (var i = 0; i < budgets.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.md),
                BudgetProgressCard(
                  budget: budgets[i],
                  delay: Duration(milliseconds: 40 * i),
                  onTap: () => context.push('/budget/${budgets[i].id}/edit'),
                ),
              ],
            const SizedBox(height: AppSpacing.lg),
            BudgetSectionHeader(
              title: 'Target nabung',
              onAdd: () => context.push('/savings-goals/new'),
              onSeeAll: () => context.push('/savings-goals'),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (goals.isEmpty)
              const EmptyStateCard(
                icon: LucideIcons.target,
                title: 'Belum ada target nabung',
                description: 'Bikin target tabungan impianmu dengan autosave sekarang yuk.',
              )
            else
              for (var i = 0; i < goals.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.md),
                SavingsGoalItemCard(
                  goal: goals[i],
                  delay: Duration(milliseconds: 40 * i),
                  onTap: () => context.push('/savings-goals/${goals[i].id}'),
                ),
              ],
            const SizedBox(height: AppSpacing.lg),
            BudgetSectionHeader(
              title: 'Dompet',
              onAdd: () => context.push('/wallets/new'),
              onSeeAll: () => context.push('/wallets'),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (accounts.isEmpty)
              const EmptyStateCard(
                icon: LucideIcons.wallet,
                title: 'Belum ada dompet',
                description: 'Tambahkan bank, e-wallet, atau tunai untuk mulai mencatat.',
              )
            else
              WalletSummaryCard(
                accounts: accounts,
                totalBalanceCents: totalBalance,
                onAccountTap: (account) => context.push('/wallets'),
              ),
          ],
        ),
      ),
    );
  }
}
