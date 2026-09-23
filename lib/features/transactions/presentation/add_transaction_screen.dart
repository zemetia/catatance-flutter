import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/currencies.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/input_formatters.dart';
export '../../../core/utils/input_formatters.dart' show ThousandsSeparatorInputFormatter;
import '../../accounts/domain/account.dart';
import '../../accounts/presentation/account_providers.dart';
import '../../accounts/presentation/widgets/wallet_picker_sheet.dart';
import '../../budget/presentation/budget_providers.dart';
import '../../categories/domain/category_item.dart';
import '../../categories/presentation/category_providers.dart';
import '../../savings_goals/presentation/savings_goal_providers.dart';
import '../../split_bills/presentation/split_bill_form_screen.dart';
import 'transaction_providers.dart';
import 'widgets/budget_info_card.dart';
import 'widgets/category_picker_sheet.dart';
import 'widgets/receipt_scanner_sheet.dart';
import 'widgets/tag_picker_sheet.dart';
import 'widgets/target_picker_sheet.dart';
import 'widgets/transaction_type_switch.dart';
import 'widgets/voice_input_sheet.dart';

/// Screen for recording a new transaction (+ FAB action).
///
/// Features:
/// - Switch between Pengeluaran (Expense) & Pemasukan (Income)
/// - Large nominal display with quick addition chips & interactive keypad
/// - Account & Category selectors
/// - Note input ("tambah catatan")
/// - Quick actions:
///   - Suara (Voice recognition input)
///   - Scan Struk (Receipt OCR scanner)
///   - Patungan (Split bill calculator)
///   - Tanggal Transaksi (default today, custom date picker)
///   - Tag (Multi-tag selector & chip manager)
///   - Budget (Live budget status if selected category is budgeted)
class AddTransactionScreen extends HookConsumerWidget {
  const AddTransactionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Repositories & Data Providers
    final accounts = ref.watch(accountListProvider).value ?? const <Account>[];
    final allCategories = ref.watch(allCategoriesProvider).value ?? const <CategoryItem>[];
    final budgets = ref.watch(liveBudgetListProvider);
    final savingsGoals =
        ref.watch(savingsGoalListProvider).value ?? const <SavingsGoal>[];

    // Form states
    final isExpense = useState(true);
    final amountDigits = useState('');
    final userSelectedAccount = useState<Account?>(null);
    final selectedCategory = useState<CategoryItem?>(null);
    final noteController = useTextEditingController();
    final selectedDate = useState<DateTime>(DateTime.now());
    final selectedTags = useState<List<String>>([]);
    final selectedGoal = useState<SavingsGoal?>(null);
    final isSubmitting = useState(false);

    // Target tabungan only applies to Pemasukan — clear it when switching
    // to Pengeluaran so a stale target never gets silently reused.
    useEffect(() {
      if (isExpense.value && selectedGoal.value != null) {
        selectedGoal.value = null;
      }
      return null;
    }, [isExpense.value]);

    // Resolved account: explicit user selection or default account
    final selectedAccount = userSelectedAccount.value ??
        (accounts.isNotEmpty
            ? (accounts.where((a) => a.isDefault).firstOrNull ?? accounts.first)
            : null);

    // Current wallet currency
    final currentCurrency = selectedAccount?.currency ?? defaultCurrency;

    final amountController = useTextEditingController(
      text: formatCurrencyInput(0, currency: currentCurrency),
    );

    // Filter categories based on expense / income
    final currentCategories = useMemoized(
      () => allCategories.where((c) => isExpense.value ? !c.isIncome : c.isIncome).toList(),
      [allCategories, isExpense.value],
    );

    // Keep nominal text controller synced with current currency
    useEffect(() {
      final currentNum =
          int.tryParse(amountDigits.value.isEmpty ? '0' : amountDigits.value) ?? 0;
      final formatted = formatCurrencyInput(currentNum, currency: currentCurrency);
      amountController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
      return null;
    }, [currentCurrency]);

    useEffect(() {
      if (currentCategories.isNotEmpty) {
        final current = selectedCategory.value;
        if (current == null ||
            (isExpense.value && current.isIncome) ||
            (!isExpense.value && !current.isIncome)) {
          selectedCategory.value = currentCategories.first;
        }
      }
      return null;
    }, [currentCategories, isExpense.value]);

    final amount =
        int.tryParse(amountDigits.value.isEmpty ? '0' : amountDigits.value) ?? 0;

    // Presets adjusted by currency
    final presets = useMemoized(() {
      if (currentCurrency.code == 'IDR') {
        return const [
          (amount: 10000, label: '+10rb'),
          (amount: 50000, label: '+50rb'),
          (amount: 100000, label: '+100rb'),
          (amount: 500000, label: '+500rb'),
        ];
      }
      if (currentCurrency.decimalDigits == 0 &&
          (currentCurrency.code == 'JPY' ||
              currentCurrency.code == 'KRW' ||
              currentCurrency.code == 'VND')) {
        return [
          (amount: 1000, label: '+${currentCurrency.symbol}1rb'),
          (amount: 5000, label: '+${currentCurrency.symbol}5rb'),
          (amount: 10000, label: '+${currentCurrency.symbol}10rb'),
          (amount: 50000, label: '+${currentCurrency.symbol}50rb'),
        ];
      }
      return [
        (amount: 10, label: '+${currentCurrency.symbol}10'),
        (amount: 50, label: '+${currentCurrency.symbol}50'),
        (amount: 100, label: '+${currentCurrency.symbol}100'),
        (amount: 500, label: '+${currentCurrency.symbol}500'),
      ];
    }, [currentCurrency]);

    // Check if selected category has an active budget
    final activeBudget = useMemoized(() {
      if (!isExpense.value || selectedCategory.value == null) return null;
      return budgets
          .where((b) => b.categoryId == selectedCategory.value!.id)
          .firstOrNull;
    }, [budgets, selectedCategory.value, isExpense.value]);

    // Handlers
    void updateAmountValue(int nextAmount) {
      if (nextAmount <= 0) {
        amountDigits.value = '';
        final text = formatCurrencyInput(0, currency: currentCurrency);
        amountController.value = TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      } else {
        final digits = nextAmount.toString();
        amountDigits.value = digits;
        final formatted = formatCurrencyInput(nextAmount, currency: currentCurrency);
        amountController.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
    }

    void addPresetAmount(int add) {
      final current = amount;
      updateAmountValue(current + add);
    }

    void clearAmount() {
      updateAmountValue(0);
    }

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
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: scheme.copyWith(primary: scheme.primary),
            ),
            child: child!,
          );
        },
      );
      if (picked != null) selectedDate.value = picked;
    }

    Future<void> handleVoiceInput() async {
      final result = await showVoiceInputSheet(context, currency: currentCurrency);
      if (result != null) {
        updateAmountValue(result.amount);
        noteController.text = result.note;
        if (result.isIncome != null) {
          isExpense.value = !result.isIncome!;
        }
        if (result.suggestedCategoryName != null) {
          final matched = allCategories.where(
            (c) => c.name.toLowerCase() == result.suggestedCategoryName!.toLowerCase(),
          ).firstOrNull;
          if (matched != null) {
            isExpense.value = !matched.isIncome;
            selectedCategory.value = matched;
          }
        }
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Catatan & nominal dari suara berhasil diterapkan'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }

    Future<void> handleReceiptScan() async {
      final result = await showReceiptScannerSheet(context, currency: currentCurrency);
      if (result != null) {
        isExpense.value = true; // Struk default to expense
        updateAmountValue(result.amount);
        noteController.text = result.note;
        if (result.suggestedCategoryName != null) {
          final matched = allCategories.where(
            (c) => c.name.toLowerCase() == result.suggestedCategoryName!.toLowerCase(),
          ).firstOrNull;
          if (matched != null) {
            selectedCategory.value = matched;
          }
        }
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Hasil scan struk berhasil diterapkan'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }

    Future<void> handleSplitBill() async {
      if (amount <= 0 || selectedAccount == null || selectedCategory.value == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Isi nominal, dompet, dan kategori dulu sebelum patungan'),
          ),
        );
        return;
      }

      final saved = await context.push<bool>(
        '/split-bills/new',
        extra: SplitBillFormArgs(
          accountId: selectedAccount.id,
          accountName: selectedAccount.name,
          categoryId: selectedCategory.value!.id,
          categoryName: selectedCategory.value!.name,
          totalAmountCents: amount,
          date: selectedDate.value,
          currency: currentCurrency,
          note: noteController.text.trim().isEmpty ? null : noteController.text.trim(),
        ),
      );

      // The split bill screen already created the transaction + piutang
      // directly, so this screen's own "Simpan Transaksi" must not run
      // again for the same amount — leave along with it.
      if (saved == true && context.mounted && context.canPop()) {
        context.pop();
      }
    }

    Future<void> handlePickTags() async {
      final result = await showTagPickerSheet(
        context,
        initialTags: selectedTags.value,
      );
      if (result != null) {
        selectedTags.value = result;
      }
    }

    void handleCreateQuickBudget() {
      final cat = selectedCategory.value;
      if (cat == null) return;

      final defaultBudget = currentCurrency.code == 'IDR' ? '1000000' : '500';
      final controller = TextEditingController(text: defaultBudget);
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Buat Anggaran: ${cat.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Tentukan batas pengeluaran bulanan untuk kategori ini:'),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixText: '${currentCurrency.symbol} ',
                  labelText: 'Batas Anggaran Bulanan',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () async {
                final fallbackLimit = currentCurrency.code == 'IDR' ? 1000000 : 500;
                final limit = int.tryParse(controller.text) ?? fallbackLimit;
                await ref.read(budgetActionProvider.notifier).createBudget(
                  BudgetDraft(
                    categoryId: cat.id,
                    limitCents: limit,
                    periodType: BudgetPeriodType.monthly,
                    carryOverEnabled: false,
                  ),
                );
                if (ctx.mounted) Navigator.of(ctx).pop();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Anggaran untuk ${cat.name} berhasil dibuat')),
                  );
                }
              },
              child: const Text('Simpan Anggaran'),
            ),
          ],
        ),
      );
    }

    Future<void> submitTransaction() async {
      if (amount <= 0 || selectedAccount == null || selectedCategory.value == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mohon masukkan nominal dan pilih kategori.')),
        );
        return;
      }

      isSubmitting.value = true;
      try {
        final repo = ref.read(transactionRepositoryProvider);

        // Build note string including tags if not already present
        String? finalNote = noteController.text.trim();
        if (selectedTags.value.isNotEmpty) {
          final tagString = selectedTags.value.map((t) => '#$t').join(' ');
          finalNote = finalNote.isEmpty ? tagString : '$finalNote $tagString';
        }

        await repo.insert(
          accountId: selectedAccount.id,
          categoryId: selectedCategory.value!.id,
          amountCents: amount,
          note: finalNote.isEmpty ? null : finalNote,
          date: selectedDate.value,
          savingsGoalId: !isExpense.value ? selectedGoal.value?.id : null,
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${isExpense.value ? "Pengeluaran" : "Pemasukan"} sebesar ${formatCurrencyInput(amount, currency: currentCurrency)} tersimpan',
              ),
            ),
          );
          if (context.canPop()) {
            context.pop();
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menyimpan transaksi: $e')),
          );
        }
      } finally {
        isSubmitting.value = false;
      }
    }

    // Format transaction date display
    final now = DateTime.now();
    final isToday = selectedDate.value.year == now.year &&
        selectedDate.value.month == now.month &&
        selectedDate.value.day == now.day;
    final isYesterday = selectedDate.value.year == now.year &&
        selectedDate.value.month == now.month &&
        selectedDate.value.day == now.day - 1;
    final dateLabel = isToday
        ? 'Hari ini, ${DateFormat('d MMM', 'id_ID').format(selectedDate.value)}'
        : isYesterday
            ? 'Kemarin, ${DateFormat('d MMM', 'id_ID').format(selectedDate.value)}'
            : DateFormat('d MMM yyyy', 'id_ID').format(selectedDate.value);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.x),
          onPressed: () => context.pop(),
        ),
        title: Text(isExpense.value ? 'Catat Pengeluaran' : 'Catat Pemasukan'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Bersihkan',
            icon: const Icon(LucideIcons.rotate_ccw, size: 20),
            onPressed: () {
              clearAmount();
              noteController.clear();
              selectedTags.value = [];
              selectedGoal.value = null;
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                children: [
                  // 1. Switch Pengeluaran / Pemasukan
                  TransactionTypeSwitch(
                    isExpense: isExpense.value,
                    onChanged: (val) {
                      isExpense.value = val;
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // 2. Nominal (Besar)
                  Center(
                    child: Column(
                      children: [
                        Text(
                          isExpense.value ? 'NOMINAL PENGELUARAN' : 'NOMINAL PEMASUKAN',
                          style: textTheme.labelMedium?.copyWith(
                            color: scheme.outline,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        IntrinsicWidth(
                          child: TextField(
                            controller: amountController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              ThousandsSeparatorInputFormatter(currency: currentCurrency),
                            ],
                            textAlign: TextAlign.center,
                            style: textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: amount > 0
                                  ? (isExpense.value
                                      ? AppColors.expense
                                      : AppColors.income)
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
                        const SizedBox(height: AppSpacing.sm),

                        // Quick increment chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (final preset in presets) ...[
                                ActionChip(
                                  label: Text(preset.label),
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () => addPresetAmount(preset.amount),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                              ],
                              if (amount > 0) ...[
                                ActionChip(
                                  avatar: const Icon(LucideIcons.x, size: 14),
                                  label: const Text('Reset'),
                                  visualDensity: VisualDensity.compact,
                                  onPressed: clearAmount,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // 3. Tambah Catatan (Notes input) - Directly below Nominal
                  Container(
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                    child: TextField(
                      controller: noteController,
                      maxLines: 2,
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText: 'Tambah catatan transaksi...',
                        prefixIcon: const Icon(LucideIcons.pencil_line, size: 20),
                        suffixIcon: noteController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(LucideIcons.x, size: 16),
                                onPressed: () => noteController.clear(),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.md,
                        ),
                      ),
                    ),
                  ),

                  // Active tags display
                  if (selectedTags.value.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs + 2),
                    Wrap(
                      spacing: AppSpacing.xs,
                      children: [
                        for (final tag in selectedTags.value)
                          Chip(
                            avatar: const Icon(LucideIcons.hash, size: 12),
                            label: Text(tag),
                            visualDensity: VisualDensity.compact,
                            onDeleted: () {
                              selectedTags.value = selectedTags.value
                                  .where((t) => t != tag)
                                  .toList();
                            },
                          ),
                      ],
                    ),
                  ],

                  const SizedBox(height: AppSpacing.sm),

                  // Action chips row [suara, scan struk, patungan, tanggal transaksi (default hari ini), tag, budget]
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Suara
                        ActionChip(
                          avatar: const Icon(LucideIcons.mic, size: 16),
                          label: const Text('Suara'),
                          backgroundColor: scheme.surfaceContainerHigh,
                          onPressed: handleVoiceInput,
                        ),
                        const SizedBox(width: AppSpacing.xs),

                        // Scan Struk
                        ActionChip(
                          avatar: const Icon(LucideIcons.scan_line, size: 16),
                          label: const Text('Scan Struk'),
                          backgroundColor: scheme.surfaceContainerHigh,
                          onPressed: handleReceiptScan,
                        ),
                        const SizedBox(width: AppSpacing.xs),

                        if (isExpense.value) ...[
                          // Patungan (only for Pengeluaran — split-bill
                          // produces an expense + piutang, not an income)
                          ActionChip(
                            avatar: const Icon(LucideIcons.users, size: 16),
                            label: const Text('Patungan'),
                            backgroundColor: scheme.surfaceContainerHigh,
                            onPressed: handleSplitBill,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                        ] else ...[
                          // Target (only for Pemasukan — links the income
                          // to a savings goal's saved amount)
                          ActionChip(
                            avatar: Icon(
                              LucideIcons.target,
                              size: 16,
                              color: selectedGoal.value != null
                                  ? scheme.primary
                                  : null,
                            ),
                            label: Text(
                              selectedGoal.value?.name ?? 'Target',
                            ),
                            backgroundColor: selectedGoal.value != null
                                ? scheme.primary.withValues(alpha: 0.18)
                                : scheme.surfaceContainerHigh,
                            onPressed: pickTarget,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                        ],

                        // Tanggal Transaksi (default hari ini)
                        ActionChip(
                          avatar: const Icon(LucideIcons.calendar, size: 16),
                          label: Text(dateLabel),
                          backgroundColor: scheme.surfaceContainerHigh,
                          onPressed: pickDate,
                        ),
                        const SizedBox(width: AppSpacing.xs),

                        // Tag
                        ActionChip(
                          avatar: const Icon(LucideIcons.tag, size: 16),
                          label: Text(
                            selectedTags.value.isEmpty
                                ? 'Tag'
                                : '${selectedTags.value.length} Tag',
                          ),
                          backgroundColor: selectedTags.value.isNotEmpty
                              ? scheme.primary.withValues(alpha: 0.2)
                              : scheme.surfaceContainerHigh,
                          onPressed: handlePickTags,
                        ),
                        if (isExpense.value) ...[
                          const SizedBox(width: AppSpacing.xs),
                          // Budget (jika kategori terpilih masuk dalam pembudgetan)
                          ActionChip(
                            avatar: Icon(
                              activeBudget != null
                                  ? LucideIcons.shield_check
                                  : LucideIcons.wallet,
                              size: 16,
                              color: activeBudget != null
                                  ? scheme.primary
                                  : scheme.outline,
                            ),
                            label: Text(
                              activeBudget != null
                                  ? 'Budget: ${activeBudget.name}'
                                  : 'Budget',
                            ),
                            backgroundColor: activeBudget != null
                                ? scheme.primary.withValues(alpha: 0.18)
                                : scheme.surfaceContainerHigh,
                            onPressed: () {
                              if (activeBudget == null) {
                                handleCreateQuickBudget();
                              }
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // 4. Dompet & Kategori Card
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                    ),
                    child: Column(
                      children: [
                        // Dompet Selector
                        InkWell(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                          onTap: pickAccount,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor:
                                      (selectedAccount?.color ?? scheme.primary)
                                          .withValues(alpha: 0.18),
                                  child: Icon(
                                    selectedAccount?.type.icon ??
                                        LucideIcons.wallet,
                                    color: selectedAccount?.color ??
                                        scheme.primary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Sumber Dana / Dompet',
                                        style: textTheme.bodySmall?.copyWith(
                                          color: scheme.outline,
                                        ),
                                      ),
                                      Text(
                                        selectedAccount?.name ?? 'Pilih Dompet',
                                        style: textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (selectedAccount != null)
                                  Text(
                                    selectedAccount.formattedBalanceCompact,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: scheme.outline,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                const SizedBox(width: AppSpacing.xs),
                                Icon(
                                  LucideIcons.chevron_right,
                                  size: 18,
                                  color: scheme.outline,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Divider(
                          color: scheme.outline.withValues(alpha: 0.12),
                          height: AppSpacing.lg,
                        ),

                        // Kategori Selector
                        InkWell(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                          onTap: pickCategory,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor:
                                      (selectedCategory.value?.color ?? scheme.primary)
                                          .withValues(alpha: 0.2),
                                  child: Icon(
                                    selectedCategory.value?.iconData ??
                                        LucideIcons.tag,
                                    color: selectedCategory.value?.color ??
                                        scheme.primary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Kategori',
                                        style: textTheme.bodySmall?.copyWith(
                                          color: scheme.outline,
                                        ),
                                      ),
                                      Text(
                                        selectedCategory.value?.name ?? 'Pilih Kategori',
                                        style: textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  LucideIcons.chevron_right,
                                  size: 18,
                                  color: scheme.outline,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Horizontal quick category selector chips
                  if (currentCategories.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final cat in currentCategories.take(5)) ...[
                            ChoiceChip(
                              avatar: Icon(cat.iconData, size: 14, color: cat.color),
                              label: Text(cat.name),
                              selected: selectedCategory.value?.id == cat.id,
                              onSelected: (selected) {
                                if (selected) selectedCategory.value = cat;
                              },
                            ),
                            const SizedBox(width: AppSpacing.xs),
                          ],
                          ActionChip(
                            label: const Text('Lainnya...'),
                            onPressed: pickCategory,
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),

                  // 5. Budget (jika kategori terpilih masuk dalam pembudgetan)
                  if (isExpense.value && selectedCategory.value != null) ...[
                    BudgetInfoCard(
                      category: selectedCategory.value,
                      budget: activeBudget,
                      currentAmount: amount,
                      currency: currentCurrency,
                      onCreateBudget: handleCreateQuickBudget,
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ],
              ),
            ),

            // Bottom Submit Button
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: FilledButton(
                onPressed: (amount > 0 && !isSubmitting.value)
                    ? submitTransaction
                    : null,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: isExpense.value
                      ? scheme.primary
                      : AppColors.income,
                ),
                child: isSubmitting.value
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isExpense.value
                                ? LucideIcons.arrow_up_right
                                : LucideIcons.arrow_down_left,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            isExpense.value
                                ? 'Simpan Pengeluaran (${formatCurrencyInput(amount, currency: currentCurrency)})'
                                : 'Simpan Pemasukan (${formatCurrencyInput(amount, currency: currentCurrency)})',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
