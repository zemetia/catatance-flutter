import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../budget/presentation/budget_providers.dart';
import '../../../categories/domain/category_item.dart';

/// Renders budgeting feedback for the currently selected category.
///
/// If the category has an active budget, shows current progress, remaining limit,
/// and live impact of the transaction nominal.
/// If not budgeted, provides a quick option to set a budget.
class BudgetInfoCard extends StatelessWidget {
  const BudgetInfoCard({
    required this.category,
    required this.budget,
    required this.currentAmount,
    this.onCreateBudget,
    super.key,
  });

  final CategoryItem? category;
  final BudgetItem? budget;
  final int currentAmount;
  final VoidCallback? onCreateBudget;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (category == null) return const SizedBox.shrink();

    // 1. Case: Category is in budgeting
    if (budget != null) {
      final b = budget!;
      final newSpent = b.spentCents + currentAmount;
      final isOverBudget = newSpent > b.limitCents;
      final remainingAfter = b.limitCents - newSpent;

      final progressNow = (b.spentCents / (b.limitCents == 0 ? 1 : b.limitCents))
          .clamp(0.0, 1.0);
      final progressWithNew =
          (newSpent / (b.limitCents == 0 ? 1 : b.limitCents)).clamp(0.0, 1.0);

      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isOverBudget
              ? AppColors.expense.withValues(alpha: 0.1)
              : scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: isOverBudget
                ? AppColors.expense.withValues(alpha: 0.4)
                : scheme.primary.withValues(alpha: 0.25),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: isOverBudget
                      ? AppColors.expense.withValues(alpha: 0.18)
                      : scheme.primary.withValues(alpha: 0.18),
                  child: Icon(
                    isOverBudget
                        ? LucideIcons.triangle_alert
                        : LucideIcons.shield_check,
                    size: 16,
                    color: isOverBudget ? AppColors.expense : scheme.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Masuk Pembudgetan: ${b.name}',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isOverBudget ? AppColors.expense : scheme.onSurface,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs + 2,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isOverBudget
                        ? AppColors.expense.withValues(alpha: 0.16)
                        : scheme.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Text(
                    isOverBudget ? 'Over Budget' : 'Aktif',
                    style: textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isOverBudget ? AppColors.expense : scheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              child: SizedBox(
                height: 8,
                child: Stack(
                  children: [
                    Container(
                      color: scheme.surfaceContainerHighest,
                    ),
                    FractionallySizedBox(
                      widthFactor: progressWithNew,
                      child: Container(
                        color: isOverBudget
                            ? AppColors.expense
                            : scheme.primary.withValues(alpha: 0.5),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: progressNow,
                      child: Container(
                        color: scheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs + 2),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Terpakai: ${formatRupiahCompact(b.spentCents)} / ${formatRupiahCompact(b.limitCents)}',
                  style: textTheme.bodySmall?.copyWith(color: scheme.outline),
                ),
                Text(
                  '${(progressNow * 100).toInt()}%',
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),

            if (currentAmount > 0)
              Text(
                isOverBudget
                    ? '⚠️ Melebihi sisa limit sebesar ${formatRupiah(newSpent - b.limitCents)}!'
                    : 'Sisa anggaran setelah transaksi: ${formatRupiah(remainingAfter)}',
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isOverBudget ? AppColors.expense : AppColors.income,
                ),
              ),
          ],
        ),
      );
    }

    // 2. Case: Category is not in budgeting yet
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: scheme.outline.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.piggy_bank, size: 18, color: scheme.outline),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Kategori "${category!.name}" belum dibudgetkan',
              style: textTheme.bodySmall?.copyWith(color: scheme.outline),
            ),
          ),
          if (onCreateBudget != null)
            TextButton(
              onPressed: onCreateBudget,
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              ),
              child: const Text('Buat Anggaran'),
            ),
        ],
      ),
    );
  }
}
