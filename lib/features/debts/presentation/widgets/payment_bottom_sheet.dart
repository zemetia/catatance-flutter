import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../accounts/domain/account.dart';
import '../../../accounts/presentation/account_providers.dart';
import '../../../accounts/presentation/widgets/wallet_picker_sheet.dart';
import '../../data/debt_repository.dart';
import '../../domain/debt.dart';
import '../../domain/debt_type.dart';
import '../debt_providers.dart';

class PaymentBottomSheet extends HookConsumerWidget {
  const PaymentBottomSheet({
    required this.debt,
    super.key,
  });

  final Debt debt;

  static Future<void> show(BuildContext context, Debt debt) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PaymentBottomSheet(debt: debt),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final isDebt = debt.type == DebtType.debt;
    final remaining = debt.remainingCents;

    final accounts = ref.watch(accountListProvider).value ?? const <Account>[];
    final selectedAccount = useState<Account?>(null);

    final amountController = useTextEditingController(
      text: remaining > 0 ? remaining.toString() : '',
    );
    useValueListenable(amountController);
    final noteController = useTextEditingController();
    final selectedDate = useState<DateTime>(DateTime.now());
    final isSubmitting = useState<bool>(false);

    int parseAmount() {
      final clean = amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
      return int.tryParse(clean) ?? 0;
    }

    Future<void> submit() async {
      final amount = parseAmount();
      if (amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Masukkan nominal pembayaran')),
        );
        return;
      }

      int finalAmount = amount;
      final notifier = ref.read(debtActionProvider.notifier);
      if (amount > remaining) {
        final proceed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Nominal Melebihi Sisa'),
            content: Text(
              'Nominal yang dimasukkan (${formatRupiah(amount)}) melebihi sisa pinjaman (${formatRupiah(remaining)}). Lanjutkan dengan mencatat pelunasan penuh sebesar ${formatRupiah(remaining)}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Lanjutkan'),
              ),
            ],
          ),
        );
        if (proceed != true) return;
        finalAmount = remaining;
      }

      isSubmitting.value = true;
      try {
        await notifier.recordPayment(
              DebtPaymentDraft(
                debtId: debt.id,
                amountCents: finalAmount,
                paymentDate: selectedDate.value,
                note: noteController.text.trim().isEmpty
                    ? null
                    : noteController.text.trim(),
                accountId: selectedAccount.value?.id,
              ),
            );

        if (context.mounted) {
          final messenger = ScaffoldMessenger.of(context);
          Navigator.of(context).pop();
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                'Pembayaran ${formatRupiah(finalAmount)} berhasil dicatat',
              ),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal mencatat pembayaran: $e')),
          );
        }
      } finally {
        isSubmitting.value = false;
      }
    }

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
        top: AppSpacing.md,
        left: AppSpacing.md,
        right: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isDebt ? 'Bayar Utang' : 'Terima Pembayaran',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Pihak: ${debt.personName}',
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 130),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: debt.type.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Sisa Tagihan',
                        style: textTheme.labelSmall?.copyWith(
                          color: debt.type.color,
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          formatRupiah(remaining),
                          style: textTheme.titleSmall?.copyWith(
                            color: debt.type.color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Nominal Pembayaran',
              style: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: debt.type.color,
              ),
              decoration: InputDecoration(
                prefixText: 'Rp ',
                prefixStyle: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: debt.type.color,
                ),
                hintText: '0',
                filled: true,
                fillColor: scheme.surfaceContainerHigh,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            if (parseAmount() > 0) ...[
              const SizedBox(height: 4),
              Text(
                formatRupiah(parseAmount()),
                style: textTheme.labelLarge?.copyWith(
                  color: scheme.outline,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  label: const Text('Lunasi Penuh'),
                  onPressed: () {
                    amountController.text = remaining.toString();
                  },
                ),
                if (remaining > 100000)
                  ActionChip(
                    label: const Text('Setengah (50%)'),
                    onPressed: () {
                      amountController.text = (remaining ~/ 2).toString();
                    },
                  ),
                ActionChip(
                  label: const Text('+50rb'),
                  onPressed: () {
                    final curr = parseAmount();
                    amountController.text = (curr + 50000).toString();
                  },
                ),
                ActionChip(
                  label: const Text('+100rb'),
                  onPressed: () {
                    final curr = parseAmount();
                    amountController.text = (curr + 100000).toString();
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate.value,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) {
                  selectedDate.value = picked;
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.calendar,
                      size: 20,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tanggal Pembayaran',
                            style: textTheme.labelSmall?.copyWith(
                              color: scheme.outline,
                            ),
                          ),
                          Text(
                            formatDate(selectedDate.value),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Dompet (Opsional)',
                    style: textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
            const SizedBox(height: AppSpacing.xs),
            InkWell(
              onTap: () async {
                final picked = await showWalletPickerSheet(
                  context,
                  title: 'Pilih Dompet',
                  accounts: accounts,
                  selected: selectedAccount.value,
                );
                if (picked != null) {
                  selectedAccount.value = picked;
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHigh,
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedAccount.value!.name,
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Saldo: ${selectedAccount.value!.formattedBalanceCompact}',
                              style: textTheme.bodySmall?.copyWith(
                                color: scheme.outline,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Icon(
                        LucideIcons.wallet,
                        size: 20,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Tidak ada — hanya catat pembayaran',
                          style: textTheme.bodyMedium?.copyWith(
                            color: scheme.outline,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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
            TextField(
              controller: noteController,
              decoration: InputDecoration(
                labelText: 'Catatan Pembayaran (Opsional)',
                hintText: 'Misal: Transfer BCA, cicilan ke-1...',
                prefixIcon: const Icon(LucideIcons.notepad_text, size: 20),
                filled: true,
                fillColor: scheme.surfaceContainerHigh,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: isSubmitting.value ? null : submit,
                style: FilledButton.styleFrom(
                  backgroundColor: debt.type.color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: isSubmitting.value
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Simpan Pembayaran',
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
    );
  }
}
