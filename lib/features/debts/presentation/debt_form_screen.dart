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
import '../data/debt_repository.dart';
import '../domain/debt_type.dart';
import 'debt_providers.dart';

class DebtFormScreen extends HookConsumerWidget {
  const DebtFormScreen({
    this.debtId,
    super.key,
  });

  final int? debtId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final isEdit = debtId != null;
    final existingDebtAsync =
        isEdit ? ref.watch(debtDetailProvider(debtId!)) : null;
    final accounts = ref.watch(accountListProvider).value ?? const <Account>[];

    final type = useState<DebtType>(DebtType.debt);
    final amountController = useTextEditingController();
    final nameController = useTextEditingController();
    final noteController = useTextEditingController();
    final transactionDate = useState<DateTime>(DateTime.now());
    final dueDate = useState<DateTime?>(null);
    final hasDueDate = useState<bool>(false);
    final selectedAccount = useState<Account?>(null);
    final isInitialized = useState<bool>(false);
    final isAccountInitialized = useState<bool>(false);
    final isSaving = useState<bool>(false);

    // Re-render when amount changes for live formatting preview
    useValueListenable(amountController);

    // Populate data when in edit mode
    if (isEdit && !isInitialized.value && existingDebtAsync?.value != null) {
      final existing = existingDebtAsync!.value!;
      type.value = existing.type;
      amountController.text = existing.amountCents.toString();
      nameController.text = existing.personName;
      noteController.text = existing.note ?? '';
      transactionDate.value = existing.transactionDate;
      dueDate.value = existing.dueDate;
      hasDueDate.value = existing.dueDate != null;
      isInitialized.value = true;
    }

    if (isEdit &&
        !isAccountInitialized.value &&
        existingDebtAsync?.value != null &&
        accounts.isNotEmpty) {
      final existing = existingDebtAsync!.value!;
      if (existing.accountId != null) {
        selectedAccount.value =
            accounts.where((a) => a.id == existing.accountId).firstOrNull;
      }
      isAccountInitialized.value = true;
    }

    int parseAmount() {
      final clean = amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
      return int.tryParse(clean) ?? 0;
    }

    Future<void> submit() async {
      final amount = parseAmount();
      if (amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Masukkan nominal yang valid')),
        );
        return;
      }

      final name = nameController.text.trim();
      if (name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              type.value == DebtType.debt
                  ? 'Masukkan nama pemberi pinjaman'
                  : 'Masukkan nama peminjam',
            ),
          ),
        );
        return;
      }

      final notifier = ref.read(debtActionProvider.notifier);
      isSaving.value = true;
      try {
        final existing = existingDebtAsync?.value;
        final draft = DebtDraft(
          type: type.value,
          personName: name,
          amountCents: amount,
          paidAmountCents: isEdit ? (existing?.paidAmountCents ?? 0) : 0,
          dueDate: hasDueDate.value ? dueDate.value : null,
          transactionDate: transactionDate.value,
          note: noteController.text.trim().isEmpty
              ? null
              : noteController.text.trim(),
          accountId: selectedAccount.value?.id,
          clearAccount: selectedAccount.value == null,
        );

        if (isEdit) {
          await notifier.updateDebt(debtId!, draft);
        } else {
          await notifier.createDebt(draft);
        }

        if (context.mounted) {
          final messenger = ScaffoldMessenger.of(context);
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            context.go('/debts');
          }
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                isEdit
                    ? 'Catatan berhasil diperbarui'
                    : 'Catatan ${type.value.label.toLowerCase()} berhasil disimpan',
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

    final currentColor = type.value.color;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
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
                      isEdit ? 'Edit Catatan' : 'Catat Utang / Piutang',
                      textAlign: TextAlign.center,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40), // Balancer
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Form Body
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.xl,
                ),
                children: [
                  // Type Switcher
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        _TypeSelectionButton(
                          title: 'Utang Saya',
                          subtitle: 'Saya pinjam uang',
                          icon: LucideIcons.arrow_up_right,
                          isSelected: type.value == DebtType.debt,
                          activeColor: DebtType.debt.color,
                          onTap: () => type.value = DebtType.debt,
                        ),
                        _TypeSelectionButton(
                          title: 'Piutang Saya',
                          subtitle: 'Dipinjam orang lain',
                          icon: LucideIcons.arrow_down_left,
                          isSelected: type.value == DebtType.receivable,
                          activeColor: DebtType.receivable.color,
                          onTap: () => type.value = DebtType.receivable,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Amount Card
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
                          'Nominal Pinjaman',
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
                            color: currentColor,
                            fontWeight: FontWeight.w800,
                          ),
                          decoration: InputDecoration(
                            prefixText: 'Rp ',
                            prefixStyle: textTheme.headlineMedium?.copyWith(
                              color: currentColor,
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
                              label: '+50rb',
                              onTap: () {
                                final cur = parseAmount();
                                amountController.text = (cur + 50000).toString();
                              },
                            ),
                            _AmountChip(
                              label: '+100rb',
                              onTap: () {
                                final cur = parseAmount();
                                amountController.text = (cur + 100000).toString();
                              },
                            ),
                            _AmountChip(
                              label: '+500rb',
                              onTap: () {
                                final cur = parseAmount();
                                amountController.text = (cur + 500000).toString();
                              },
                            ),
                            _AmountChip(
                              label: '+1jt',
                              onTap: () {
                                final cur = parseAmount();
                                amountController.text = (cur + 1000000).toString();
                              },
                            ),
                            _AmountChip(
                              label: 'Reset',
                              onTap: () {
                                amountController.clear();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Person Name Input
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: type.value == DebtType.debt
                          ? 'Pemberi Pinjaman (Nama Orang / Lembaga)'
                          : 'Peminjam (Nama Orang / Pihak Terkait)',
                      hintText: 'Misal: Kak Sarah, Budi, Bank Mandiri',
                      prefixIcon: const Icon(LucideIcons.user, size: 20),
                      suffixIcon: nameController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(LucideIcons.x, size: 18),
                              onPressed: () => nameController.clear(),
                            )
                          : null,
                      filled: true,
                      fillColor: scheme.surfaceContainerHigh,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Transaction Date
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: transactionDate.value,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        transactionDate.value = picked;
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
                                  'Tanggal Transaksi / Pinjam',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: scheme.outline,
                                  ),
                                ),
                                Text(
                                  formatDate(transactionDate.value),
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

                  // Due Date Section (Optional)
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
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(LucideIcons.clock, size: 20),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Text(
                                      'Atur Jatuh Tempo',
                                      style: textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: hasDueDate.value,
                              onChanged: (val) {
                                hasDueDate.value = val;
                                if (val && dueDate.value == null) {
                                  dueDate.value = DateTime.now().add(
                                    const Duration(days: 14),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                        if (hasDueDate.value) ...[
                          const SizedBox(height: AppSpacing.sm),
                          InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate:
                                    dueDate.value ?? DateTime.now().add(
                                  const Duration(days: 7),
                                ),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2035),
                              );
                              if (picked != null) {
                                dueDate.value = picked;
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    dueDate.value != null
                                        ? formatDate(dueDate.value!)
                                        : 'Pilih Tanggal',
                                    style: textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Icon(
                                    LucideIcons.calendar_days,
                                    size: 18,
                                    color: scheme.primary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _PresetChip(
                                label: '+7 Hari',
                                onTap: () => dueDate.value =
                                    DateTime.now().add(const Duration(days: 7)),
                              ),
                              _PresetChip(
                                label: '+14 Hari',
                                onTap: () => dueDate.value =
                                    DateTime.now().add(const Duration(days: 14)),
                              ),
                              _PresetChip(
                                label: '+1 Bulan',
                                onTap: () => dueDate.value =
                                    DateTime.now().add(const Duration(days: 30)),
                              ),
                              _PresetChip(
                                label: '+3 Bulan',
                                onTap: () => dueDate.value =
                                    DateTime.now().add(const Duration(days: 90)),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Account / Wallet Selection (Optional)
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
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(LucideIcons.wallet, size: 20),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Text(
                                      'Dompet Terkait (Opsional)',
                                      style: textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (selectedAccount.value != null) ...[
                              const SizedBox(width: AppSpacing.xs),
                              TextButton(
                                onPressed: () => selectedAccount.value = null,
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Hapus',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: scheme.error,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        InkWell(
                          onTap: () async {
                            final picked = await showWalletPickerSheet(
                              context,
                              title: 'Pilih Dompet Terkait',
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

                  // Note Input
                  TextField(
                    controller: noteController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Catatan Tambahan (Opsional)',
                      hintText: 'Misal: Untuk modal usaha, pinjaman makan...',
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

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      onPressed: isSaving.value ? null : submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: currentColor,
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
                              isEdit ? 'Perbarui Catatan' : 'Simpan Transaksi',
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

class _TypeSelectionButton extends StatelessWidget {
  const _TypeSelectionButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final Color activeColor;
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
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? activeColor : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? activeColor : scheme.onSurfaceVariant,
                size: 22,
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  style: textTheme.titleSmall?.copyWith(
                    color: isSelected ? activeColor : scheme.onSurface,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  ),
                  maxLines: 1,
                ),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  subtitle,
                  style: textTheme.labelSmall?.copyWith(
                    color: scheme.outline,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                ),
              ),
            ],
          ),
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

class _PresetChip extends StatelessWidget {
  const _PresetChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
      ),
    );
  }
}
