import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/transaction_item.dart';
import '../transaction_providers.dart';

/// Shows a comprehensive, beautifully styled bottom sheet displaying the
/// full details of a transaction, with a confirmation action to delete it.
Future<void> showTransactionDetailSheet(
  BuildContext context, {
  required TransactionItem item,
  VoidCallback? onDeleted,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSpacing.radiusXl),
      ),
    ),
    builder: (sheetContext) => TransactionDetailSheet(
      item: item,
      onDeleted: onDeleted,
    ),
  );
}

class TransactionDetailSheet extends ConsumerWidget {
  const TransactionDetailSheet({
    required this.item,
    this.onDeleted,
    super.key,
  });

  final TransactionItem item;
  final VoidCallback? onDeleted;

  static final _fullDateFormatter =
      DateFormat('EEEE, d MMMM yyyy • HH:mm', 'id_ID');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final isIncome = item.isIncome;
    final isTransfer = item.isTransfer;

    final typeLabel = isTransfer
        ? 'Transfer'
        : (isIncome ? 'Pemasukan' : 'Pengeluaran');

    final typeColor = isTransfer
        ? scheme.primary
        : (isIncome ? AppColors.income : AppColors.expense);

    final amountPrefix = isTransfer ? '' : (isIncome ? '+' : '-');
    final formattedAmount =
        '$amountPrefix${formatCurrencyInput(item.amountCents, currency: item.accountCurrency)}';
    final formattedDate = _fullDateFormatter.format(item.date);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.xs,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header icon badge & type pill
            Center(
              child: Column(
                children: [
                  IconBadge(
                    icon: item.iconData,
                    color: item.categoryColor,
                    size: 32,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    shape: BoxShape.rectangle,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Text(
                      typeLabel,
                      style: textTheme.labelMedium?.copyWith(
                        color: typeColor,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    formattedAmount,
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: typeColor,
                    ),
                  ),
                  if (item.note != null && item.note!.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.note!.trim(),
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Detail fields card
            AppCard(
              enableAnimation: false,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Column(
                children: [
                  _DetailRow(
                    icon: LucideIcons.calendar,
                    label: 'Tanggal & Waktu',
                    value: formattedDate,
                  ),
                  const Divider(height: 1),
                  _DetailRow(
                    icon: LucideIcons.tag,
                    label: 'Kategori',
                    value: item.categoryName,
                    iconColor: item.categoryColor,
                  ),
                  const Divider(height: 1),
                  _DetailRow(
                    icon: LucideIcons.wallet,
                    label: isTransfer && item.toAccountName != null
                        ? 'Dari Rekening'
                        : 'Rekening / Dompet',
                    value: item.accountName,
                  ),
                  if (isTransfer && item.toAccountName != null) ...[
                    const Divider(height: 1),
                    _DetailRow(
                      icon: LucideIcons.arrow_right_left,
                      label: 'Ke Rekening',
                      value: item.toAccountName!,
                    ),
                  ],
                  if (item.note != null && item.note!.trim().isNotEmpty) ...[
                    const Divider(height: 1),
                    _DetailRow(
                      icon: LucideIcons.file_text,
                      label: 'Catatan',
                      value: item.note!.trim(),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Delete action button
            OutlinedButton.icon(
              icon: const Icon(LucideIcons.trash, color: Colors.red, size: 18),
              label: const Text(
                'Hapus Transaksi',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.red.withValues(alpha: 0.4)),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              onPressed: () => _handleDelete(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Hapus Transaksi?'),
        content: Text(
          'Yakin ingin menghapus transaksi "${item.title}"? Saldo dompet akan disesuaikan kembali.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (context.mounted) {
      Navigator.of(context).pop(); // Close detail bottom sheet
    }

    await ref.read(transactionRepositoryProvider).delete(item.id);
    onDeleted?.call();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaksi berhasil dihapus'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: iconColor ?? scheme.outline,
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.outline,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
