import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/currencies.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/input_formatters.dart';
import '../../../accounts/domain/account.dart';
import '../../../accounts/presentation/account_providers.dart';
import '../../../accounts/presentation/widgets/wallet_picker_sheet.dart';
import '../../../categories/domain/category_item.dart';
import '../../../categories/presentation/category_providers.dart';
import '../../../savings_goals/presentation/savings_goal_providers.dart';
import '../batch_transaction_providers.dart';
import 'category_picker_sheet.dart';
import 'target_picker_sheet.dart';
import 'transaction_type_switch.dart';

/// Bottom sheet for adding or editing a single staged row in the Batch
/// Transaction screen. Mirrors the core fields of [AddTransactionScreen]
/// (type, nominal, dompet, kategori, catatan, tanggal, target for income)
/// without its voice/scan/split-bill/budget extras — those act on one
/// transaction immediately, which doesn't fit a staged-then-processed row.
Future<BatchTransactionDraft?> showBatchDraftFormSheet(
  BuildContext context, {
  required int localId,
  BatchTransactionDraft? initial,
}) {
  return showModalBottomSheet<BatchTransactionDraft>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => _BatchDraftFormSheet(localId: localId, initial: initial),
  );
}

class _BatchDraftFormSheet extends HookConsumerWidget {
  const _BatchDraftFormSheet({required this.localId, this.initial});

  final int localId;
  final BatchTransactionDraft? initial;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final accounts = ref.watch(accountListProvider).value ?? const <Account>[];
    final allCategories =
        ref.watch(allCategoriesProvider).value ?? const <CategoryItem>[];
    final savingsGoals =
        ref.watch(savingsGoalListProvider).value ?? const <SavingsGoal>[];

    final isExpense = useState(initial?.isExpense ?? true);
    final amountDigits = useState(initial?.amountCents.toString() ?? '');
    final userSelectedAccount = useState<Account?>(
      initial == null
          ? null
          : accounts.where((a) => a.id == initial!.accountId).firstOrNull,
    );
    final selectedCategory = useState<CategoryItem?>(
      initial == null
          ? null
          : allCategories.where((c) => c.id == initial!.categoryId).firstOrNull,
    );
    final selectedGoal = useState<SavingsGoal?>(
      initial?.savingsGoalId == null
          ? null
          : savingsGoals.where((g) => g.id == initial!.savingsGoalId).firstOrNull,
    );
    final noteController = useTextEditingController(text: initial?.note ?? '');
    final selectedDate = useState<DateTime>(initial?.date ?? DateTime.now());

    final selectedAccount = userSelectedAccount.value ??
        (accounts.isNotEmpty
            ? (accounts.where((a) => a.isDefault).firstOrNull ?? accounts.first)
            : null);
    final currentCurrency = selectedAccount?.currency ?? defaultCurrency;

    final amountController = useTextEditingController(
      text: formatCurrencyInput(
        int.tryParse(amountDigits.value.isEmpty ? '0' : amountDigits.value) ?? 0,
        currency: currentCurrency,
      ),
    );

    final currentCategories = useMemoized(
      () => allCategories.where((c) => isExpense.value ? !c.isIncome : c.isIncome).toList(),
      [allCategories, isExpense.value],
    );

    useEffect(() {
      if (currentCategories.isNotEmpty) {
        final current = selectedCategory.value;
        if (current == null ||
            (isExpense.value && current.isIncome) ||
            (!isExpense.value && !current.isIncome)) {
          selectedCategory.value = currentCategories.first;
        }
      }
      if (isExpense.value && selectedGoal.value != null) {
        selectedGoal.value = null;
      }
      return null;
    }, [currentCategories, isExpense.value]);

    final amount = int.tryParse(amountDigits.value.isEmpty ? '0' : amountDigits.value) ?? 0;

    Future<void> pickAccount() async {
      final picked = await showWalletPickerSheet(
        context,
        title: 'Pilih Dompet / Akun',
        accounts: accounts,
        selected: selectedAccount,
      );
      if (picked != null) userSelectedAccount.value = picked;
    }

    Future<void> pickCategory() async {
      final picked = await showCategoryPickerSheet(
        context,
        categories: currentCategories,
        selected: selectedCategory.value,
        isExpense: isExpense.value,
      );
      if (picked != null) selectedCategory.value = picked;
    }

    Future<void> pickTarget() async {
      final picked = await showTargetPickerSheet(
        context,
        goals: savingsGoals,
        selected: selectedGoal.value,
      );
      selectedGoal.value = picked;
    }

    Future<void> pickDate() async {
      final picked = await showDatePicker(
        context: context,
        initialDate: selectedDate.value,
        firstDate: DateTime(2020),
        lastDate: DateTime.now().add(const Duration(days: 365)),
      );
      if (picked != null) selectedDate.value = picked;
    }

    final now = DateTime.now();
    final isToday = selectedDate.value.year == now.year &&
        selectedDate.value.month == now.month &&
        selectedDate.value.day == now.day;
    final dateLabel = isToday
        ? 'Hari ini, ${DateFormat('d MMM', 'id_ID').format(selectedDate.value)}'
        : DateFormat('d MMM yyyy', 'id_ID').format(selectedDate.value);

    final canSave = amount > 0 && selectedAccount != null && selectedCategory.value != null;

    void save() {
      final account = selectedAccount;
      final category = selectedCategory.value;
      if (amount <= 0 || account == null || category == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mohon masukkan nominal dan pilih kategori.')),
        );
        return;
      }
      Navigator.of(context).pop(
        BatchTransactionDraft(
          localId: localId,
          isExpense: isExpense.value,
          amountCents: amount,
          accountId: account.id,
          accountName: account.name,
          accountCurrencyCode: account.currencyCode,
          categoryId: category.id,
          categoryName: category.name,
          note: noteController.text.trim().isEmpty ? null : noteController.text.trim(),
          date: selectedDate.value,
          savingsGoalId: !isExpense.value ? selectedGoal.value?.id : null,
          savingsGoalName: !isExpense.value ? selectedGoal.value?.name : null,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    initial == null ? 'Tambah Transaksi' : 'Ubah Transaksi',
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            TransactionTypeSwitch(
              isExpense: isExpense.value,
              onChanged: (val) => isExpense.value = val,
            ),
            const SizedBox(height: AppSpacing.md),
            Center(
              child: IntrinsicWidth(
                child: TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    ThousandsSeparatorInputFormatter(currency: currentCurrency),
                  ],
                  textAlign: TextAlign.center,
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: amount > 0
                        ? (isExpense.value ? AppColors.expense : AppColors.income)
                        : scheme.onSurface,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  onChanged: (val) {
                    final clean = val.replaceAll(RegExp(r'[^\d]'), '');
                    amountDigits.value = clean == '0' ? '' : clean;
                  },
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: noteController,
              decoration: InputDecoration(
                hintText: 'Catatan (opsional)',
                prefixIcon: const Icon(LucideIcons.pencil_line, size: 20),
                filled: true,
                fillColor: scheme.surfaceContainerHigh,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                ActionChip(
                  avatar: Icon(
                    selectedAccount?.type.icon ?? LucideIcons.wallet,
                    size: 16,
                    color: selectedAccount?.color,
                  ),
                  label: Text(selectedAccount?.name ?? 'Pilih Dompet'),
                  backgroundColor: scheme.surfaceContainerHigh,
                  onPressed: pickAccount,
                ),
                ActionChip(
                  avatar: Icon(
                    selectedCategory.value?.iconData ?? LucideIcons.tag,
                    size: 16,
                    color: selectedCategory.value?.color,
                  ),
                  label: Text(selectedCategory.value?.name ?? 'Pilih Kategori'),
                  backgroundColor: scheme.surfaceContainerHigh,
                  onPressed: pickCategory,
                ),
                ActionChip(
                  avatar: const Icon(LucideIcons.calendar, size: 16),
                  label: Text(dateLabel),
                  backgroundColor: scheme.surfaceContainerHigh,
                  onPressed: pickDate,
                ),
                if (!isExpense.value)
                  ActionChip(
                    avatar: Icon(
                      LucideIcons.target,
                      size: 16,
                      color: selectedGoal.value != null ? scheme.primary : null,
                    ),
                    label: Text(selectedGoal.value?.name ?? 'Target'),
                    backgroundColor: selectedGoal.value != null
                        ? scheme.primary.withValues(alpha: 0.18)
                        : scheme.surfaceContainerHigh,
                    onPressed: pickTarget,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: canSave ? save : null,
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              child: Text(initial == null ? 'Tambahkan ke Batch' : 'Simpan Perubahan'),
            ),
          ],
        ),
      ),
    );
  }
}
