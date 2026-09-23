import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/circle_icon_button.dart';
import '../../accounts/domain/account.dart';
import '../../accounts/presentation/account_providers.dart';
import '../../accounts/presentation/widgets/wallet_picker_sheet.dart';
import '../../categories/domain/category_item.dart';
import '../../categories/presentation/category_providers.dart';
import '../data/installment_repository.dart';
import 'installment_providers.dart';
import 'widgets/category_picker_sheet.dart';

class InstallmentFormScreen extends HookConsumerWidget {
  const InstallmentFormScreen({this.installmentId, super.key});

  final int? installmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final isEdit = installmentId != null;
    final existingAsync =
        isEdit ? ref.watch(installmentDetailProvider(installmentId!)) : null;
    final accounts = ref.watch(accountListProvider).value ?? const <Account>[];
    final expenseCategories =
        ref.watch(expenseCategoriesProvider).value ?? const <CategoryItem>[];

    final nameController = useTextEditingController();
    final installmentAmountController = useTextEditingController();
    final tenorController = useTextEditingController(text: '12');
    final noteController = useTextEditingController();
    final startDate = useState<DateTime>(DateTime.now());
    final selectedAccount = useState<Account?>(null);
    final selectedCategory = useState<CategoryItem?>(null);
    final isInitialized = useState<bool>(false);
    final isRelationsInitialized = useState<bool>(false);
    final isSaving = useState<bool>(false);

    useValueListenable(installmentAmountController);
    useValueListenable(tenorController);

    if (isEdit && !isInitialized.value && existingAsync?.value != null) {
      final existing = existingAsync!.value!;
      nameController.text = existing.name;
      installmentAmountController.text =
          existing.installmentAmountCents.toString();
      tenorController.text = existing.tenorMonths.toString();
      noteController.text = existing.note ?? '';
      startDate.value = existing.startDate;
      isInitialized.value = true;
    }

    if (isEdit &&
        !isRelationsInitialized.value &&
        existingAsync?.value != null &&
        (accounts.isNotEmpty || expenseCategories.isNotEmpty)) {
      final existing = existingAsync!.value!;
      if (existing.accountId != null) {
        selectedAccount.value =
            accounts.where((a) => a.id == existing.accountId).firstOrNull;
      }
      if (existing.categoryId != null) {
        selectedCategory.value = expenseCategories
            .where((c) => c.id == existing.categoryId)
            .firstOrNull;
      }
      isRelationsInitialized.value = true;
    }

    // Auto-select the "Cicilan & Pinjaman" default category for a new plan
    // the first time categories load, so payments are connected to a
    // Transaction/report bucket out of the box unless the user changes it.
    if (!isEdit && selectedCategory.value == null && expenseCategories.isNotEmpty) {
      selectedCategory.value = expenseCategories
          .where((c) => c.name == 'Cicilan & Pinjaman')
          .firstOrNull;
    }

    int parseInstallmentAmount() {
      final clean =
          installmentAmountController.text.replaceAll(RegExp(r'[^0-9]'), '');
      return int.tryParse(clean) ?? 0;
    }

    int parseTenor() {
      final clean = tenorController.text.replaceAll(RegExp(r'[^0-9]'), '');
      return int.tryParse(clean) ?? 0;
    }

    final perMonth = parseInstallmentAmount();
    final tenor = parseTenor();
    final totalAmount = perMonth * tenor;

    Future<void> submit() async {
      final name = nameController.text.trim();
      if (name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Masukkan nama cicilan')),
        );
        return;
      }
      if (perMonth <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Masukkan nominal cicilan per bulan')),
        );
        return;
      }
      if (tenor <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Masukkan tenor (jumlah bulan)')),
        );
        return;
      }

      final notifier = ref.read(installmentActionProvider.notifier);
      isSaving.value = true;
      try {
        final draft = InstallmentDraft(
          name: name,
          totalAmountCents: totalAmount,
          tenorMonths: tenor,
          installmentAmountCents: perMonth,
          startDate: startDate.value,
          accountId: selectedAccount.value?.id,
          categoryId: selectedCategory.value?.id,
          note: noteController.text.trim().isEmpty
              ? null
              : noteController.text.trim(),
          clearAccount: selectedAccount.value == null,
          clearCategory: selectedCategory.value == null,
        );

        if (isEdit) {
          await notifier.updateInstallment(installmentId!, draft);
        } else {
          await notifier.createInstallment(draft);
        }

        if (context.mounted) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isEdit
                    ? 'Cicilan berhasil diperbarui'
                    : 'Cicilan berhasil disimpan',
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

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                0,
              ),
              child: Row(
                children: [
                  CircleIconButton(
                    icon: LucideIcons.chevron_left,
                    backgroundColor: scheme.surfaceContainerHigh,
                    onTap: () => context.pop(),
                  ),
                  Expanded(
                    child: Text(
                      isEdit ? 'Edit Cicilan' : 'Tambah Cicilan',
                      textAlign: TextAlign.center,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.xl,
                ),
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nama Cicilan',
                      hintText: 'Misal: Cicilan HP Samsung S24',
                      prefixIcon: const Icon(LucideIcons.credit_card, size: 20),
                      filled: true,
                      fillColor: scheme.surfaceContainerHigh,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Installment amount per month
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
                          'Cicilan per Bulan',
                          style: textTheme.labelMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        TextField(
                          controller: installmentAmountController,
                          keyboardType: TextInputType.number,
                          style: textTheme.headlineMedium?.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.w800,
                          ),
                          decoration: InputDecoration(
                            prefixText: 'Rp ',
                            prefixStyle: textTheme.headlineMedium?.copyWith(
                              color: scheme.primary,
                              fontWeight: FontWeight.w800,
                            ),
                            hintText: '0',
                            border: InputBorder.none,
                          ),
                        ),
                        if (perMonth > 0) ...[
                          Text(
                            formatRupiah(perMonth),
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
                              label: '+50rb',
                              onTap: () => installmentAmountController.text =
                                  (perMonth + 50000).toString(),
                            ),
                            _AmountChip(
                              label: '+100rb',
                              onTap: () => installmentAmountController.text =
                                  (perMonth + 100000).toString(),
                            ),
                            _AmountChip(
                              label: '+500rb',
                              onTap: () => installmentAmountController.text =
                                  (perMonth + 500000).toString(),
                            ),
                            _AmountChip(
                              label: 'Reset',
                              onTap: () => installmentAmountController.clear(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Tenor
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(LucideIcons.calendar_clock, size: 20),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'Tenor (Bulan)',
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextField(
                          controller: tenorController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            suffixText: 'bulan',
                            filled: true,
                            fillColor: scheme.surface,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [3, 6, 12, 24, 36].map((months) {
                            final isSelected = tenor == months;
                            return _TenorChip(
                              label: '$months',
                              isSelected: isSelected,
                              onTap: () =>
                                  tenorController.text = months.toString(),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Computed total
                  if (perMonth > 0 && tenor > 0)
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Harga',
                            style: textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            formatRupiah(totalAmount),
                            style: textTheme.titleMedium?.copyWith(
                              color: scheme.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: AppSpacing.md),

                  // Start date
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: startDate.value,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035),
                      );
                      if (picked != null) {
                        startDate.value = picked;
                      }
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
                          const Icon(LucideIcons.calendar, size: 20),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tanggal Mulai / Jatuh Tempo Pertama',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: scheme.outline,
                                  ),
                                ),
                                Text(
                                  formatDate(startDate.value),
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            LucideIcons.chevron_right,
                            size: 16,
                            color: scheme.outline,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Wallet
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(LucideIcons.wallet, size: 20),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  'Dompet Sumber (Opsional)',
                                  style: textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            if (selectedAccount.value != null)
                              TextButton(
                                onPressed: () => selectedAccount.value = null,
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Hapus',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: scheme.error,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Text(
                          'Pilih dompet agar pembayaran otomatis memotong saldo dan tercatat sebagai transaksi.',
                          style: textTheme.labelSmall?.copyWith(
                            color: scheme.outline,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        InkWell(
                          onTap: () async {
                            final picked = await showWalletPickerSheet(
                              context,
                              title: 'Pilih Dompet Sumber',
                              accounts: accounts,
                              selected: selectedAccount.value,
                            );
                            if (picked != null) {
                              selectedAccount.value = picked;
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: scheme.surface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                if (selectedAccount.value != null) ...[
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: selectedAccount.value!.color
                                          .withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      selectedAccount.value!.type.icon,
                                      size: 16,
                                      color: selectedAccount.value!.color,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          selectedAccount.value!.name,
                                          style: textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          'Saldo: ${selectedAccount.value!.formattedBalanceCompact}',
                                          style: textTheme.bodySmall?.copyWith(
                                            color: scheme.outline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ] else ...[
                                  Icon(
                                    LucideIcons.circle_plus,
                                    size: 20,
                                    color: scheme.outline,
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Text(
                                      'Pilih dompet (misal: BCA, Dompet Tunai)',
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: scheme.outline,
                                      ),
                                    ),
                                  ),
                                ],
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
                  const SizedBox(height: AppSpacing.md),

                  // Category
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(LucideIcons.tag, size: 20),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'Kategori Pengeluaran',
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        InkWell(
                          onTap: () async {
                            final picked =
                                await showInstallmentCategoryPickerSheet(
                              context,
                              categories: expenseCategories,
                              selected: selectedCategory.value,
                            );
                            if (picked != null) {
                              selectedCategory.value = picked;
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: scheme.surface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                if (selectedCategory.value != null) ...[
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor: selectedCategory.value!
                                        .color
                                        .withValues(alpha: 0.2),
                                    child: Icon(
                                      selectedCategory.value!.iconData,
                                      size: 14,
                                      color: selectedCategory.value!.color,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Text(
                                      selectedCategory.value!.name,
                                      style: textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ] else ...[
                                  Icon(
                                    LucideIcons.circle_plus,
                                    size: 20,
                                    color: scheme.outline,
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Text(
                                      'Pilih kategori',
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: scheme.outline,
                                      ),
                                    ),
                                  ),
                                ],
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
                  const SizedBox(height: AppSpacing.md),

                  TextField(
                    controller: noteController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Catatan Tambahan (Opsional)',
                      hintText: 'Misal: Cicilan tanpa bunga 0%, dari toko X...',
                      prefixIcon: const Icon(LucideIcons.file_text, size: 20),
                      filled: true,
                      fillColor: scheme.surfaceContainerHigh,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      onPressed: isSaving.value ? null : submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: scheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: isSaving.value
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              isEdit ? 'Perbarui Cicilan' : 'Simpan Cicilan',
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
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _TenorChip extends StatelessWidget {
  const _TenorChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? scheme.primary : scheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? scheme.primary : scheme.outlineVariant,
          ),
        ),
        child: Text(
          '$label bln',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected ? scheme.onPrimary : scheme.onSurface,
          ),
        ),
      ),
    );
  }
}
