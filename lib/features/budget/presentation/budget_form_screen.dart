import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/widgets.dart';
import '../../categories/domain/category_item.dart';
import '../../categories/presentation/category_providers.dart';
import 'budget_providers.dart';
import 'widgets/budget_category_picker_sheet.dart';

/// Create/edit screen for a category budget (Anggaran): pick the expense
/// category, set a limit, choose how the period repeats (monthly/weekly/
/// custom range), and optionally carry over the previous period's leftover.
class BudgetFormScreen extends HookConsumerWidget {
  const BudgetFormScreen({this.budgetId, this.initialCategoryId, super.key});

  final int? budgetId;
  final int? initialCategoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final isEdit = budgetId != null;
    final existingAsync = isEdit ? ref.watch(budgetDetailProvider(budgetId!)) : null;
    final expenseCategories =
        ref.watch(expenseCategoriesProvider).value ?? const <CategoryItem>[];
    final existingBudgets = ref.watch(budgetConfigListProvider).value ?? const [];

    final selectedCategory = useState<CategoryItem?>(null);
    final amountController = useTextEditingController();
    final periodType = useState<BudgetPeriodType>(BudgetPeriodType.monthly);
    final customStart = useState<DateTime>(DateTime.now());
    final customEnd = useState<DateTime>(DateTime.now().add(const Duration(days: 6)));
    final carryOverEnabled = useState<bool>(false);
    final isInitialized = useState<bool>(false);
    final isSaving = useState<bool>(false);

    useValueListenable(amountController);

    if (isEdit && !isInitialized.value && existingAsync?.value != null) {
      final existing = existingAsync!.value!;
      amountController.text = existing.limitCents.toString();
      periodType.value = existing.periodType;
      if (existing.customStartDate != null) customStart.value = existing.customStartDate!;
      if (existing.customEndDate != null) customEnd.value = existing.customEndDate!;
      carryOverEnabled.value = existing.carryOverEnabled;
      isInitialized.value = true;
    }

    if (!isEdit && selectedCategory.value == null && expenseCategories.isNotEmpty) {
      final preselect = initialCategoryId != null
          ? expenseCategories.where((c) => c.id == initialCategoryId).firstOrNull
          : null;
      if (preselect != null) selectedCategory.value = preselect;
    }

    if (isEdit &&
        selectedCategory.value == null &&
        existingAsync?.value != null &&
        expenseCategories.isNotEmpty) {
      final existing = existingAsync!.value!;
      selectedCategory.value =
          expenseCategories.where((c) => c.id == existing.categoryId).firstOrNull;
    }

    int parseAmount() {
      final clean = amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
      return int.tryParse(clean) ?? 0;
    }

    final excludedCategoryIds = existingBudgets
        .where((b) => !isEdit || b.id != budgetId)
        .map((b) => b.categoryId)
        .toSet();

    final previewPeriod = resolveBudgetPeriod(
      periodType.value,
      DateTime.now(),
      customStart: customStart.value,
      customEndInclusive: customEnd.value,
    );
    final previewLabel = periodType.value == BudgetPeriodType.monthly
        ? 'Berulang tiap bulan • mulai ${formatDate(previewPeriod.start)}'
        : periodType.value == BudgetPeriodType.weekly
            ? 'Berulang tiap minggu • ${formatDate(previewPeriod.start)} - ${formatDate(previewPeriod.lastIncludedDay)}'
            : '${formatDate(previewPeriod.start)} - ${formatDate(previewPeriod.lastIncludedDay)}';

    Future<void> submit() async {
      final category = selectedCategory.value;
      if (category == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih kategori pengeluaran dulu')),
        );
        return;
      }
      final amount = parseAmount();
      if (amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Masukkan batas anggaran yang valid')),
        );
        return;
      }
      if (periodType.value == BudgetPeriodType.custom &&
          customEnd.value.isBefore(customStart.value)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tanggal selesai harus setelah tanggal mulai')),
        );
        return;
      }

      isSaving.value = true;
      try {
        final draft = BudgetDraft(
          categoryId: category.id,
          limitCents: amount,
          periodType: periodType.value,
          customStartDate: periodType.value == BudgetPeriodType.custom ? customStart.value : null,
          customEndDate: periodType.value == BudgetPeriodType.custom ? customEnd.value : null,
          carryOverEnabled: carryOverEnabled.value,
        );

        if (isEdit) {
          await ref.read(budgetActionProvider.notifier).updateBudget(budgetId!, draft);
        } else {
          await ref.read(budgetActionProvider.notifier).createBudget(draft);
        }

        if (context.mounted) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isEdit ? 'Anggaran berhasil diperbarui' : 'Anggaran ${category.name} berhasil dibuat',
              ),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menyimpan: $e')),
          );
        }
      } finally {
        isSaving.value = false;
      }
    }

    final accentColor = selectedCategory.value?.color ?? scheme.primary;

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
                      isEdit ? 'Edit Anggaran' : 'Anggaran Baru',
                      textAlign: TextAlign.center,
                      style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.xl),
                children: [
                  // Category
                  Text(
                    'Kategori',
                    style: textTheme.labelMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  InkWell(
                    onTap: () async {
                      final picked = await showBudgetCategoryPickerSheet(
                        context,
                        categories: expenseCategories,
                        selected: selectedCategory.value,
                        excludedCategoryIds: excludedCategoryIds,
                      );
                      if (picked != null) selectedCategory.value = picked;
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          if (selectedCategory.value != null) ...[
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: accentColor.withValues(alpha: 0.18),
                              child: Icon(selectedCategory.value!.iconData, color: accentColor, size: 18),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                selectedCategory.value!.name,
                                style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ] else ...[
                            Icon(LucideIcons.circle_plus, size: 20, color: scheme.outline),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                'Pilih kategori pengeluaran',
                                style: textTheme.bodyMedium?.copyWith(color: scheme.outline),
                              ),
                            ),
                          ],
                          Icon(LucideIcons.chevron_right, size: 18, color: scheme.outline),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Amount
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Batas Anggaran',
                          style: textTheme.labelMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        TextField(
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          style: textTheme.headlineMedium?.copyWith(
                            color: accentColor,
                            fontWeight: FontWeight.w800,
                          ),
                          decoration: InputDecoration(
                            prefixText: 'Rp ',
                            prefixStyle: textTheme.headlineMedium?.copyWith(
                              color: accentColor,
                              fontWeight: FontWeight.w800,
                            ),
                            hintText: '0',
                            border: InputBorder.none,
                          ),
                        ),
                        if (parseAmount() > 0) ...[
                          Text(
                            formatRupiah(parseAmount()),
                            style: textTheme.labelLarge?.copyWith(
                              color: scheme.outline,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                        ],
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _AmountChip(
                              label: '+500rb',
                              onTap: () => amountController.text =
                                  (parseAmount() + 500000).toString(),
                            ),
                            _AmountChip(
                              label: '+1jt',
                              onTap: () => amountController.text =
                                  (parseAmount() + 1000000).toString(),
                            ),
                            _AmountChip(
                              label: '+5jt',
                              onTap: () => amountController.text =
                                  (parseAmount() + 5000000).toString(),
                            ),
                            _AmountChip(
                              label: 'Reset',
                              onTap: () => amountController.clear(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Period type
                  Text(
                    'Periode',
                    style: textTheme.labelMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        for (final type in BudgetPeriodType.values)
                          _PeriodTypeButton(
                            label: type.label,
                            isSelected: periodType.value == type,
                            accentColor: accentColor,
                            onTap: () => periodType.value = type,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  if (periodType.value == BudgetPeriodType.custom) ...[
                    Row(
                      children: [
                        Expanded(
                          child: _DateField(
                            label: 'Mulai',
                            date: customStart.value,
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: customStart.value,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2035),
                              );
                              if (picked != null) {
                                customStart.value = picked;
                                if (customEnd.value.isBefore(picked)) {
                                  customEnd.value = picked;
                                }
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _DateField(
                            label: 'Selesai',
                            date: customEnd.value,
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: customEnd.value,
                                firstDate: customStart.value,
                                lastDate: DateTime(2035),
                              );
                              if (picked != null) customEnd.value = picked;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        Icon(LucideIcons.calendar_days, size: 16, color: scheme.outline),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            previewLabel,
                            style: textTheme.bodySmall?.copyWith(color: scheme.outline),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Carry-over
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(LucideIcons.repeat, size: 20, color: accentColor),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bawa sisa periode lalu',
                                style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                periodType.value == BudgetPeriodType.custom
                                    ? 'Tidak berlaku untuk periode custom (sekali pakai)'
                                    : 'Sisa anggaran periode sebelumnya ditambahkan ke periode ini',
                                style: textTheme.bodySmall?.copyWith(color: scheme.outline),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: carryOverEnabled.value,
                          onChanged: periodType.value == BudgetPeriodType.custom
                              ? null
                              : (val) => carryOverEnabled.value = val,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      onPressed: isSaving.value ? null : submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: accentColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: isSaving.value
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              isEdit ? 'Perbarui Anggaran' : 'Simpan Anggaran',
                              style: textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PeriodTypeButton extends StatelessWidget {
  const _PeriodTypeButton({
    required this.label,
    required this.isSelected,
    required this.accentColor,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? accentColor.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? accentColor : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: textTheme.labelMedium?.copyWith(
              color: isSelected ? accentColor : scheme.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.label, required this.date, required this.onTap});

  final String label;
  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: textTheme.labelSmall?.copyWith(color: scheme.outline)),
            Text(
              formatDateShort(date),
              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountChip extends StatelessWidget {
  const _AmountChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: scheme.onSurfaceVariant),
        ),
      ),
    );
  }
}
