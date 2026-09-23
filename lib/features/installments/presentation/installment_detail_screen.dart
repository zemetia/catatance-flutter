import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/widgets.dart';
import '../../accounts/presentation/account_providers.dart';
import '../../categories/presentation/category_providers.dart';
import '../domain/installment.dart';
import '../domain/installment_payment.dart';
import 'installment_providers.dart';
import 'widgets/installment_payment_bottom_sheet.dart';

class InstallmentDetailScreen extends ConsumerWidget {
  const InstallmentDetailScreen({required this.installmentId, super.key});

  final int installmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final installmentAsync = ref.watch(installmentDetailProvider(installmentId));
    final paymentsAsync = ref.watch(installmentPaymentsProvider(installmentId));

    return Scaffold(
      body: SafeArea(
        child: installmentAsync.when(
          data: (installment) {
            if (installment == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Cicilan tidak ditemukan'),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton(
                      onPressed: () => context.pop(),
                      child: const Text('Kembali'),
                    ),
                  ],
                ),
              );
            }

            final isCompleted = installment.isCompleted;
            final isOverdue = installment.isOverdue;
            final accounts = ref.watch(accountListProvider).value ?? const [];
            final categories =
                ref.watch(allCategoriesProvider).value ?? const [];
            final linkedAccount = installment.accountId != null
                ? accounts.where((a) => a.id == installment.accountId).firstOrNull
                : null;
            final linkedCategory = installment.categoryId != null
                ? categories
                    .where((c) => c.id == installment.categoryId)
                    .firstOrNull
                : null;

            return Column(
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
                          'Detail Cicilan',
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
                            context.push('/installments/${installment.id}/edit');
                          } else if (action == 'delete') {
                            _confirmDelete(context, ref, installment);
                          }
                        },
                        itemBuilder: (ctx) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(LucideIcons.pencil, size: 18),
                                SizedBox(width: AppSpacing.sm),
                                Text('Edit Cicilan'),
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
                                  'Hapus Cicilan',
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
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      0,
                      AppSpacing.md,
                      AppSpacing.xl,
                    ),
                    children: [
                      AppCard(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          children: [
                            IconBadge(
                              icon: LucideIcons.credit_card,
                              color: isCompleted ? AppColors.income : scheme.primary,
                              size: 28,
                              padding: const EdgeInsets.all(AppSpacing.md),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              installment.name,
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
                                color: (isCompleted
                                        ? AppColors.income
                                        : scheme.primary)
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                installment.status.label,
                                style: textTheme.labelMedium?.copyWith(
                                  color: isCompleted
                                      ? AppColors.income
                                      : scheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: scheme.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    isCompleted
                                        ? 'Status Pelunasan'
                                        : 'Sisa Tagihan',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      isCompleted
                                          ? 'Lunas Penuh'
                                          : installment.formattedRemainingAmount,
                                      style: textTheme.headlineMedium?.copyWith(
                                        color: isCompleted
                                            ? AppColors.income
                                            : scheme.primary,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: installment.progress,
                                      minHeight: 8,
                                      backgroundColor:
                                          scheme.surfaceContainerHighest,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        isCompleted
                                            ? AppColors.income
                                            : scheme.primary,
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
                                          'Terbayar: ${installment.formattedPaidAmount} (${installment.progressPercentage})',
                                          style: textTheme.bodySmall?.copyWith(
                                            color: scheme.outline,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.xs),
                                      Text(
                                        'Total: ${installment.formattedTotalAmount}',
                                        style: textTheme.bodySmall?.copyWith(
                                          color: scheme.outline,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Angsuran ke-${installment.paidInstallments + (isCompleted ? 0 : 1)} dari ${installment.tenorMonths} '
                                    '(${installment.formattedInstallmentAmount}/bulan)',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: scheme.outline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

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
                                      'Jatuh tempo adalah ${installment.formattedNextDueDate} (${installment.daysUntilDue?.abs()} hari yang lalu).',
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

                      AppCard(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          children: [
                            _DetailRow(
                              icon: LucideIcons.calendar,
                              label: 'Tanggal Mulai',
                              value: installment.formattedStartDate,
                            ),
                            const Divider(height: 24),
                            _DetailRow(
                              icon: LucideIcons.clock,
                              label: 'Jatuh Tempo Berikutnya',
                              value: installment.formattedNextDueDate,
                              valueColor: isOverdue ? AppColors.expense : null,
                            ),
                            if (linkedAccount != null) ...[
                              const Divider(height: 24),
                              _DetailRow(
                                icon: linkedAccount.type.icon,
                                label: 'Dompet Sumber',
                                value:
                                    '${linkedAccount.name} (${linkedAccount.formattedBalanceCompact})',
                              ),
                            ],
                            if (linkedCategory != null) ...[
                              const Divider(height: 24),
                              _DetailRow(
                                icon: linkedCategory.iconData,
                                label: 'Kategori',
                                value: linkedCategory.name,
                              ),
                            ],
                            if (installment.note != null &&
                                installment.note!.isNotEmpty) ...[
                              const Divider(height: 24),
                              _DetailRow(
                                icon: LucideIcons.file_text,
                                label: 'Catatan',
                                value: installment.note!,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      if (!isCompleted) ...[
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 50,
                                child: FilledButton.icon(
                                  onPressed: () =>
                                      InstallmentPaymentBottomSheet.show(
                                    context,
                                    installment,
                                  ),
                                  icon: const Icon(LucideIcons.banknote, size: 18),
                                  label: const FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text('Bayar Cicilan'),
                                  ),
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm,
                                    ),
                                    backgroundColor: scheme.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: SizedBox(
                                height: 50,
                                child: OutlinedButton.icon(
                                  onPressed: () =>
                                      _confirmPayoff(context, ref, installment),
                                  icon: const Icon(LucideIcons.circle_check, size: 18),
                                  label: const FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text('Lunasi Sisa'),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm,
                                    ),
                                    foregroundColor: AppColors.income,
                                    side: const BorderSide(
                                      color: AppColors.income,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],

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
                          if (!isCompleted)
                            TextButton.icon(
                              onPressed: () =>
                                  InstallmentPaymentBottomSheet.show(
                                context,
                                installment,
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
                                      'Semua pembayaran cicilan akan tercatat di sini.',
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

  static Future<void> _confirmPayoff(
    BuildContext context,
    WidgetRef ref,
    Installment installment,
  ) async {
    final notifier = ref.read(installmentActionProvider.notifier);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Lunasi Cicilan?'),
        content: Text(
          'Lunasi sisa cicilan "${installment.name}" sebesar ${installment.formattedRemainingAmount} sekaligus?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.income),
            child: const Text('Lunasi'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await notifier.payoffRemaining(installment.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cicilan berhasil dilunasi')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal melunasi: $e')),
          );
        }
      }
    }
  }

  static Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Installment installment,
  ) async {
    final notifier = ref.read(installmentActionProvider.notifier);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Cicilan?'),
        content: Text(
          'Yakin ingin menghapus "${installment.name}" beserta riwayat pembayarannya? Transaksi yang sudah tercatat sebelumnya tidak akan dihapus.',
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

    if (confirmed == true) {
      try {
        await notifier.deleteInstallment(installment.id);
        if (context.mounted) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cicilan berhasil dihapus')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus cicilan: $e')),
          );
        }
      }
    }
  }

  static Future<void> _confirmDeletePayment(
    BuildContext context,
    WidgetRef ref,
    InstallmentPayment payment,
  ) async {
    final notifier = ref.read(installmentActionProvider.notifier);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Pembayaran?'),
        content: Text(
          'Hapus catatan pembayaran sebesar ${formatRupiah(payment.amountCents)}? '
          '${payment.isLinkedToTransaction ? 'Transaksi terkait dan saldo dompet akan dikembalikan.' : ''} '
          'Sisa tagihan akan disesuaikan kembali.',
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

    if (confirmed == true) {
      try {
        await notifier.deletePayment(payment.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pembayaran berhasil dihapus')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus pembayaran: $e')),
          );
        }
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
  const _PaymentItemTile({required this.payment, required this.onDelete});

  final InstallmentPayment payment;
  final VoidCallback onDelete;

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
                  formatDate(payment.paymentDate),
                  style: textTheme.labelSmall?.copyWith(color: scheme.outline),
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
