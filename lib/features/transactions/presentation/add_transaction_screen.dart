import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../accounts/domain/account.dart';
import '../../accounts/presentation/account_providers.dart';
import '../../accounts/presentation/widgets/amount_keypad.dart';
import '../../accounts/presentation/widgets/wallet_picker_sheet.dart';
import '../../budget/presentation/budget_providers.dart';
import '../../categories/domain/category_item.dart';
import '../../categories/presentation/category_providers.dart';
import 'transaction_providers.dart';
import 'widgets/budget_info_card.dart';
import 'widgets/category_picker_sheet.dart';
import 'widgets/receipt_scanner_sheet.dart';
import 'widgets/split_bill_sheet.dart';
import 'widgets/tag_picker_sheet.dart';
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
    final budgets = ref.watch(budgetListProvider);

    // Form states
    final isExpense = useState(true);
    final amountDigits = useState('');
    final selectedAccount = useState<Account?>(null);
    final selectedCategory = useState<CategoryItem?>(null);
    final noteController = useTextEditingController();
    final selectedDate = useState<DateTime>(DateTime.now());
    final selectedTags = useState<List<String>>([]);
    final splitBillDetails = useState<SplitBillResult?>(null);
    final isKeypadExpanded = useState(true);
    final isSubmitting = useState(false);

    // Filter categories based on expense / income
    final currentCategories = useMemoized(
      () => allCategories.where((c) => isExpense.value ? !c.isIncome : c.isIncome).toList(),
      [allCategories, isExpense.value],
    );

    // Auto-select initial account & category
    useEffect(() {
      if (accounts.isNotEmpty && selectedAccount.value == null) {
        selectedAccount.value =
            accounts.where((a) => a.isDefault).firstOrNull ??
            (accounts.isNotEmpty ? accounts.first : null);
      }
      return null;
    }, [accounts]);

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

    // Check if selected category has an active budget
    final activeBudget = useMemoized(() {
      if (!isExpense.value || selectedCategory.value == null) return null;
      return budgets
          .where(
            (b) =>
                b.name.toLowerCase() ==
                selectedCategory.value!.name.toLowerCase(),
          )
          .firstOrNull;
    }, [budgets, selectedCategory.value, isExpense.value]);

    // Handlers
    void addPresetAmount(int add) {
      final current = amount;
      final next = current + add;
      amountDigits.value = next.toString();
    }

    void clearAmount() {
      amountDigits.value = '';
    }

    Future<void> pickAccount() async {
      final picked = await showWalletPickerSheet(
        context,
        title: 'Pilih Dompet / Akun',
        accounts: accounts,
        selected: selectedAccount.value,
      );
      if (picked != null) selectedAccount.value = picked;
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
      final result = await showVoiceInputSheet(context);
      if (result != null) {
        amountDigits.value = result.amount.toString();
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
      final result = await showReceiptScannerSheet(context);
      if (result != null) {
        isExpense.value = true; // Struk default to expense
        amountDigits.value = result.amount.toString();
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
      final result = await showSplitBillSheet(context, initialAmount: amount);
      if (result != null) {
        splitBillDetails.value = result;
        amountDigits.value = result.finalAmount.toString();

        final splitNote = result.onlyMyShare
            ? '[Patungan ${result.personCount} org (Total: ${formatRupiahCompact(result.totalAmount)})]'
            : '[Patungan ${result.personCount} org @ ${formatRupiahCompact(result.amountPerPerson)}]';

        if (noteController.text.isEmpty) {
          noteController.text = splitNote;
        } else if (!noteController.text.contains('Patungan')) {
          noteController.text = '${noteController.text} $splitNote';
        }
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

      final controller = TextEditingController(text: '1000000');
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
                decoration: const InputDecoration(
                  prefixText: 'Rp ',
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
              onPressed: () {
                final limit = int.tryParse(controller.text) ?? 1000000;
                final newBudget = BudgetItem(
                  id: DateTime.now().millisecondsSinceEpoch,
                  name: cat.name,
                  icon: cat.iconData,
                  spentCents: 0,
                  limitCents: limit,
                  daysLeft: 8,
                );
                ref.read(budgetListProvider.notifier).update((list) => [...list, newBudget]);
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Anggaran untuk ${cat.name} berhasil dibuat')),
                );
              },
              child: const Text('Simpan Anggaran'),
            ),
          ],
        ),
      );
    }

    Future<void> submitTransaction() async {
      if (amount <= 0 || selectedAccount.value == null || selectedCategory.value == null) {
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
          accountId: selectedAccount.value!.id,
          categoryId: selectedCategory.value!.id,
          amountCents: amount,
          note: finalNote.isEmpty ? null : finalNote,
          date: selectedDate.value,
        );

        // If category is in budgeting, update local budget provider
        if (isExpense.value && activeBudget != null) {
          ref.read(budgetListProvider.notifier).update((list) {
            return list.map((b) {
              if (b.name.toLowerCase() == activeBudget.name.toLowerCase()) {
                return b.copyWith(spentCents: b.spentCents + amount);
              }
              return b;
            }).toList();
          });
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${isExpense.value ? "Pengeluaran" : "Pemasukan"} sebesar ${formatRupiah(amount)} tersimpan',
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
              splitBillDetails.value = null;
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
                        GestureDetector(
                          onTap: () {
                            isKeypadExpanded.value = !isKeypadExpanded.value;
                          },
                          child: Text(
                            formatRupiah(amount),
                            style: textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: amount > 0
                                  ? (isExpense.value
                                      ? AppColors.expense
                                      : AppColors.income)
                                  : scheme.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        // Quick increment chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ActionChip(
                                label: const Text('+10rb'),
                                visualDensity: VisualDensity.compact,
                                onPressed: () => addPresetAmount(10000),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              ActionChip(
                                label: const Text('+50rb'),
                                visualDensity: VisualDensity.compact,
                                onPressed: () => addPresetAmount(50000),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              ActionChip(
                                label: const Text('+100rb'),
                                visualDensity: VisualDensity.compact,
                                onPressed: () => addPresetAmount(100000),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              ActionChip(
                                label: const Text('+500rb'),
                                visualDensity: VisualDensity.compact,
                                onPressed: () => addPresetAmount(500000),
                              ),
                              if (amount > 0) ...[
                                const SizedBox(width: AppSpacing.xs),
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
                  const SizedBox(height: AppSpacing.lg),

                  // 3. Dompet & Kategori Card
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
                                      (selectedAccount.value?.color ?? scheme.primary)
                                          .withValues(alpha: 0.18),
                                  child: Icon(
                                    selectedAccount.value?.type.icon ??
                                        LucideIcons.wallet,
                                    color: selectedAccount.value?.color ??
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
                                        selectedAccount.value?.name ?? 'Pilih Dompet',
                                        style: textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (selectedAccount.value != null)
                                  Text(
                                    formatRupiahCompact(
                                      selectedAccount.value!.balanceCents,
                                    ),
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

                  // 4. Tambah Catatan (Notes input)
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

                  // Split bill indicator badge
                  if (splitBillDetails.value != null) ...[
                    const SizedBox(height: AppSpacing.xs + 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        border: Border.all(
                          color: scheme.primary.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(LucideIcons.users, size: 16, color: scheme.primary),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'Patungan ${splitBillDetails.value!.personCount} orang • ${formatRupiah(splitBillDetails.value!.amountPerPerson)}/org',
                              style: textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: scheme.primary,
                              ),
                            ),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(LucideIcons.x, size: 14),
                            onPressed: () {
                              splitBillDetails.value = null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),

                  // 5. Action chips row [suara, scan struk, patungan, tanggal transaksi, tag]
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Tanggal Transaksi (default hari ini)
                        ActionChip(
                          avatar: const Icon(LucideIcons.calendar, size: 16),
                          label: Text(dateLabel),
                          backgroundColor: scheme.surfaceContainerHigh,
                          onPressed: pickDate,
                        ),
                        const SizedBox(width: AppSpacing.xs),

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

                        // Patungan
                        ActionChip(
                          avatar: const Icon(LucideIcons.users, size: 16),
                          label: Text(
                            splitBillDetails.value != null
                                ? 'Patungan (${splitBillDetails.value!.personCount})'
                                : 'Patungan',
                          ),
                          backgroundColor: splitBillDetails.value != null
                              ? scheme.primary.withValues(alpha: 0.2)
                              : scheme.surfaceContainerHigh,
                          onPressed: handleSplitBill,
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
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // 6. Budget (jika kategori terpilih masuk dalam pembudgetan)
                  if (isExpense.value && selectedCategory.value != null) ...[
                    BudgetInfoCard(
                      category: selectedCategory.value,
                      budget: activeBudget,
                      currentAmount: amount,
                      onCreateBudget: handleCreateQuickBudget,
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  // 7. Interactive Keypad
                  if (isKeypadExpanded.value)
                    AmountKeypad(
                      onKey: (key) {
                        if (key == 'backspace') {
                          if (amountDigits.value.isNotEmpty) {
                            amountDigits.value = amountDigits.value.substring(
                              0,
                              amountDigits.value.length - 1,
                            );
                          }
                        } else if (key != '.' && amountDigits.value.length < 12) {
                          amountDigits.value = amountDigits.value == '0'
                              ? key
                              : amountDigits.value + key;
                        }
                      },
                    ),
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
                                ? 'Simpan Pengeluaran (${formatRupiah(amount)})'
                                : 'Simpan Pemasukan (${formatRupiah(amount)})',
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
