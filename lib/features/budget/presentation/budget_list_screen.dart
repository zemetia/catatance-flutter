import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/widgets.dart';
import 'budget_providers.dart';
import 'widgets/budget_progress_card.dart';

/// "Semua Anggaran" — full list of every configured budget, reachable from
/// Profile and from the Anggaran tab's "Lihat semua".
class BudgetListScreen extends ConsumerWidget {
  const BudgetListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final budgets = ref.watch(liveBudgetListProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
              child: Row(
                children: [
                  CircleIconButton(
                    icon: LucideIcons.chevron_left,
                    backgroundColor: scheme.surfaceContainerHigh,
                    onTap: () => context.pop(),
                  ),
                  Expanded(
                    child: Text(
                      'Semua Anggaran',
                      textAlign: TextAlign.center,
                      style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  CircleIconButton(
                    icon: LucideIcons.plus,
                    backgroundColor: scheme.surfaceContainerHigh,
                    onTap: () => context.push('/budget/new'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: budgets.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: EmptyStateCard(
                        icon: LucideIcons.piggy_bank,
                        title: 'Belum ada anggaran',
                        description: 'Buat anggaran per kategori untuk mulai memantau batas pengeluaranmu.',
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        0,
                        AppSpacing.md,
                        AppSpacing.xl,
                      ),
                      itemCount: budgets.length,
                      itemBuilder: (context, index) {
                        final budget = budgets[index];
                        return Padding(
                          padding: EdgeInsets.only(top: index > 0 ? AppSpacing.md : 0),
                          child: Dismissible(
                            key: ValueKey('budget-${budget.id}'),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (_) => _confirmDelete(context, budget.name),
                            onDismissed: (_) =>
                                ref.read(budgetActionProvider.notifier).deleteBudget(budget.id),
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.error,
                                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                              ),
                              child: const Icon(LucideIcons.trash, color: Colors.white),
                            ),
                            child: BudgetProgressCard(
                              budget: budget,
                              delay: Duration(milliseconds: 30 * index),
                              onTap: () => context.push('/budget/${budget.id}/edit'),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Anggaran?'),
        content: Text('Yakin ingin menghapus anggaran untuk "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }
}
