import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/widgets.dart';
import '../../accounts/presentation/account_providers.dart';
import '../domain/debt.dart';
import '../domain/debt_payment.dart';
import '../domain/debt_type.dart';
import 'debt_providers.dart';
import 'widgets/payment_bottom_sheet.dart';

class DebtDetailScreen extends ConsumerWidget {
  const DebtDetailScreen({
    required this.debtId,
    super.key,
  });

  final int debtId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final debtAsync = ref.watch(debtDetailProvider(debtId));
    final paymentsAsync = ref.watch(debtPaymentsProvider(debtId));

    return Scaffold(
      body: SafeArea(
        child: debtAsync.when(
          data: (debt) {
            if (debt == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Catatan tidak ditemukan'),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton(
                      onPressed: () => context.pop(),
                      child: const Text('Kembali'),
                    ),
                  ],
                ),
              );
            }

            final isSettled = debt.isSettled;
            final isOverdue = debt.isOverdue;
            final color = debt.type.color;
            final accounts = ref.watch(accountListProvider).value ?? const [];
            final linkedAccount = debt.accountId != null
                ? accounts.where((a) => a.id == debt.accountId).firstOrNull
                : null;

            return Column(
              children: [
                // Top App Bar
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
                          'Detail ${debt.type.label}',
                          textAlign: TextAlign.center,
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(LucideIcons.ellipsis_vertical),
                        onSelected: (action) {
                          if (action == 'edit') {
                            context.push('/debts/${debt.id}/edit');
                          } else if (action == 'delete') {
                            _confirmDelete(context, ref, debt);
                          }
                        },
                        itemBuilder: (ctx) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(LucideIcons.pencil, size: 18),
                                SizedBox(width: AppSpacing.sm),
                                Text('Edit Catatan'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  LucideIcons.trash,
                                  size: 18,
                                  color: scheme.error,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  'Hapus Catatan',
                                  style: TextStyle(color: scheme.error),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Scrollable Content
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      0,
                      AppSpacing.md,
                      AppSpacing.xl,
                    ),
                    children: [
                      // Header Card with Person Info
                      AppCard(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          children: [
                            InitialsAvatar(name: debt.personName, radius: 32),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              debt.personName,
                              style: textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                debt.type.title,
                                style: textTheme.labelMedium?.copyWith(
                                  color: color,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),

                            // Balance Breakdown
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: scheme.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    isSettled
                                        ? 'Status Pelunasan'
                                        : 'Sisa yang Belum Lunas',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      isSettled
                                          ? 'Lunas Penuh'
                                          : formatRupiah(debt.remainingCents),
                                      style: textTheme.headlineMedium?.copyWith(
                                        color: isSettled
                                            ? AppColors.income
                                            : color,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: debt.progress,
                                      minHeight: 8,
                                      backgroundColor:
                                          scheme.surfaceContainerHighest,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        isSettled ? AppColors.income : color,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Terbayar: ${debt.formattedPaid} (${debt.progressPercentage})',
                                          style: textTheme.bodySmall?.copyWith(
                                            color: scheme.outline,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.xs),
                                      Flexible(
                                        child: Text(
                                          'Total: ${debt.formattedAmount}',
                                          style: textTheme.bodySmall?.copyWith(
                                            color: scheme.outline,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Overdue Alert Banner if applicable
                      if (isOverdue) ...[
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.expenseContainer,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.expense.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                LucideIcons.triangle_alert,
                                color: AppColors.expense,
                                size: 24,
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Sudah Lewat Tanggal Jatuh Tempo!',
                                      style: textTheme.titleSmall?.copyWith(
                                        color: AppColors.expense,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Batas tempo adalah ${debt.formattedDueDate} (${debt.daysUntilDue?.abs()} hari yang lalu).',
                                      style: textTheme.bodySmall?.copyWith(
                                        color: AppColors.expense,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],

                      // Transaction Info Card
                      AppCard(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          children: [
                            _DetailRow(
                              icon: LucideIcons.calendar,
                              label: 'Tanggal Transaksi',
                              value: debt.formattedTransactionDate,
                            ),
                            const Divider(height: 24),
                            _DetailRow(
                              icon: LucideIcons.clock,
                              label: 'Jatuh Tempo',
                              value: debt.formattedDueDate,
                              valueColor: isOverdue ? AppColors.expense : null,
                            ),
                            if (debt.note != null && debt.note!.isNotEmpty) ...[
                              const Divider(height: 24),
                              _DetailRow(
                                icon: LucideIcons.file_text,
                                label: 'Catatan',
                                value: debt.note!,
                              ),
                            ],
                            if (linkedAccount != null) ...[
                              const Divider(height: 24),
                              _DetailRow(
                                icon: linkedAccount.type.icon,
                                label: 'Dompet Terkait',
                                value:
                                    '${linkedAccount.name} (${linkedAccount.formattedBalanceCompact})',
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Action Buttons
                      if (!isSettled) ...[
                        Row(
                          children: [
                            Expanded(
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(minHeight: 48),
                                child: FilledButton(
                                  onPressed: () => PaymentBottomSheet.show(
                                    context,
                                    debt,
                                  ),
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm,
                                      vertical: AppSpacing.sm,
                                    ),
                                    backgroundColor: color,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(LucideIcons.banknote, size: 18),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            debt.type.paymentActionLabel,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(minHeight: 48),
                                child: OutlinedButton(
                                  onPressed: () => _confirmSettle(
                                    context,
                                    ref,
                                    debt,
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm,
                                      vertical: AppSpacing.sm,
                                    ),
                                    foregroundColor: AppColors.income,
                                    side: const BorderSide(
                                      color: AppColors.income,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(LucideIcons.circle_check, size: 18),
                                      SizedBox(width: 6),
                                      Flexible(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            'Lunasi Penuh',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],

                      // Copy Reminder Action
                      SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () => _copyReminderText(context, debt),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(LucideIcons.copy, size: 18),
                              const SizedBox(width: AppSpacing.sm),
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    debt.type == DebtType.debt
                                        ? 'Salin Konfirmasi Pelunasan'
                                        : 'Salin Pesan Tagihan (WhatsApp)',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Payment History Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Riwayat Pembayaran',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!isSettled)
                            TextButton.icon(
                              onPressed: () => PaymentBottomSheet.show(
                                context,
                                debt,
                              ),
                              icon: const Icon(LucideIcons.plus, size: 16),
                              label: const Text('Catat Bayar'),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),

                      paymentsAsync.when(
                        data: (payments) {
                          if (payments.isEmpty) {
                            return AppCard(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      LucideIcons.receipt_text,
                                      size: 36,
                                      color: scheme.outline,
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    Text(
                                      'Belum ada riwayat pembayaran',
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Semua pembayaran cicilan atau pelunasan akan tercatat di sini.',
                                      textAlign: TextAlign.center,
                                      style: textTheme.bodySmall?.copyWith(
                                        color: scheme.outline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return Column(
                            children: payments.map((payment) {
                              return Padding(
                                padding:
                                    const EdgeInsets.only(bottom: AppSpacing.xs),
                                child: _PaymentItemTile(
                                  payment: payment,
                                  walletName: payment.accountId != null
                                      ? accounts
                                          .where(
                                            (a) => a.id == payment.accountId,
                                          )
                                          .firstOrNull
                                          ?.name
                                      : null,
                                  onDelete: () => _confirmDeletePayment(
                                    context,
                                    ref,
                                    payment,
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(AppSpacing.md),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (err, _) => Center(
                          child: Text('Gagal memuat pembayaran: $err'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  static Future<void> _confirmSettle(
    BuildContext context,
    WidgetRef ref,
    Debt debt,
  ) async {
    final notifier = ref.read(debtActionProvider.notifier);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Lunasi Catatan?'),
        content: Text(
          'Tandai catatan pinjaman ini telah lunas sepenuhnya dengan mencatat pelunasan sisa sebesar ${formatRupiah(debt.remainingCents)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.income,
            ),
            child: const Text('Lunasi'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final messenger = ScaffoldMessenger.of(context);
      try {
        await notifier.settleDebt(debt.id);
        messenger.showSnackBar(
          const SnackBar(content: Text('Catatan berhasil dilunasi')),
        );
      } catch (e) {
        messenger.showSnackBar(
          SnackBar(content: Text('Gagal melunasi: $e')),
        );
      }
    }
  }

  static void _copyReminderText(BuildContext context, Debt debt) {
    final message = debt.type == DebtType.debt
        ? 'Halo ${debt.personName}, ini catatan mengenai pinjaman saya sebesar ${formatRupiah(debt.amountCents)} dengan sisa ${formatRupiah(debt.remainingCents)}.${debt.dueDate != null ? ' Jatuh tempo pada ${debt.formattedDueDate}.' : ''} Terima kasih 🙏'
        : 'Halo ${debt.personName}, sekadar mengingatkan mengenai pinjaman sebesar ${formatRupiah(debt.amountCents)} dengan sisa yang belum dilunasi ${formatRupiah(debt.remainingCents)}.${debt.dueDate != null ? ' Jatuh tempo pada ${debt.formattedDueDate}.' : ''} Mohon konfirmasinya jika sudah ditransfer ya. Terima kasih banyak 🙏';

    Clipboard.setData(ClipboardData(text: message));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Teks pengingat berhasil disalin ke clipboard!'),
      ),
    );
  }

  static Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Debt debt,
  ) async {
    final notifier = ref.read(debtActionProvider.notifier);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Catatan?'),
        content: Text(
          'Yakin ingin menghapus catatan untuk "${debt.personName}" beserta semua riwayat pembayarannya?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final messenger = ScaffoldMessenger.of(context);
      final nav = Navigator.of(context);
      if (nav.canPop()) {
        nav.pop();
      }
      try {
        await notifier.deleteDebt(debt.id);
        messenger.showSnackBar(
          const SnackBar(content: Text('Catatan berhasil dihapus')),
        );
      } catch (e) {
        messenger.showSnackBar(
          SnackBar(content: Text('Gagal menghapus catatan: $e')),
        );
      }
    }
  }

  static Future<void> _confirmDeletePayment(
    BuildContext context,
    WidgetRef ref,
    DebtPayment payment,
  ) async {
    final notifier = ref.read(debtActionProvider.notifier);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Pembayaran?'),
        content: Text(
          'Hapus catatan pembayaran sebesar ${formatRupiah(payment.amountCents)}? Sisa tagihan akan disesuaikan kembali.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final messenger = ScaffoldMessenger.of(context);
      try {
        await notifier.deletePayment(payment.id);
        messenger.showSnackBar(
          const SnackBar(content: Text('Pembayaran berhasil dihapus')),
        );
      } catch (e) {
        messenger.showSnackBar(
          SnackBar(content: Text('Gagal menghapus pembayaran: $e')),
        );
      }
    }
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: scheme.onSurfaceVariant),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(color: scheme.outline),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: textTheme.bodyMedium?.copyWith(
                  color: valueColor ?? scheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PaymentItemTile extends StatelessWidget {
  const _PaymentItemTile({
    required this.payment,
    required this.onDelete,
    this.walletName,
  });

  final DebtPayment payment;
  final VoidCallback onDelete;
  final String? walletName;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.income.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.check,
              size: 16,
              color: AppColors.income,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatRupiah(payment.amountCents),
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.income,
                  ),
                ),
                Text(
                  walletName != null
                      ? '${formatDate(payment.paymentDate)} · $walletName'
                      : formatDate(payment.paymentDate),
                  style: textTheme.labelSmall?.copyWith(
                    color: scheme.outline,
                  ),
                ),
                if (payment.note != null && payment.note!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    payment.note!,
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.trash, size: 18),
            color: scheme.error,
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
