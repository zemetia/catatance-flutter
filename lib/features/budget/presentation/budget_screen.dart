import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/widgets.dart';
import '../../accounts/presentation/account_providers.dart';
import 'budget_providers.dart';
import 'widgets/budget_progress_card.dart';
import 'widgets/budget_section_header.dart';
import 'widgets/savings_goal_card.dart';
import 'widgets/wallet_summary_card.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  void _comingSoon(BuildContext context, String label) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$label segera hadir')));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final budgets = ref.watch(budgetListProvider);
    final goals = ref.watch(savingsGoalListProvider);
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
                  onTap: () => _comingSoon(context, 'Tambah anggaran'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            if (budgets.isEmpty)
              const EmptyStateCard(
                icon: LucideIcons.piggy_bank,
                title: 'Belum ada anggaran',
                description:
                    'Belum ada anggaran aktif. Buat dulu di tab Anggaran.',
              )
            else
              for (var i = 0; i < budgets.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.md),
                BudgetProgressCard(
                  budget: budgets[i],
                  delay: Duration(milliseconds: 40 * i),
                ),
              ],
            const SizedBox(height: AppSpacing.lg),
            BudgetSectionHeader(
              title: 'Target nabung',
              onAdd: () => _comingSoon(context, 'Target nabung'),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (goals.isEmpty)
              const EmptyStateCard(
                icon: LucideIcons.target,
                title: 'Belum ada savings goal',
                description: 'Belum ada target nabung. Bikin yuk.',
              )
            else
              for (var i = 0; i < goals.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.md),
                SavingsGoalCard(
                  goal: goals[i],
                  gradient: _goalGradients[i % _goalGradients.length](scheme),
                  delay: Duration(milliseconds: 40 * i),
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

typedef _GradientBuilder = Gradient Function(ColorScheme scheme);

final List<_GradientBuilder> _goalGradients = [
  (scheme) => LinearGradient(
    colors: [scheme.primary, scheme.tertiary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  (scheme) => LinearGradient(
    colors: [scheme.secondary, scheme.primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  (scheme) => LinearGradient(
    colors: [scheme.tertiary, scheme.secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
];
