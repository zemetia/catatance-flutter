import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/security/security_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../transactions/presentation/add_transaction_prefill.dart';
import '../../../transactions/presentation/transaction_providers.dart';
import '../../../transactions/presentation/widgets/transaction_detail_sheet.dart';
import '../../domain/report_models.dart';
import '../kalender_cashflow_providers.dart';
import 'report_shimmer_box.dart';

/// Transaction list and daily cashflow summary for the selected date on the
/// "Kalender Cashflow" screen, showing daily income, expense, and net.
class CashflowDayDetail extends ConsumerWidget {
  const CashflowDayDetail({super.key});

  static final _dayDateFormatter = DateFormat('EEEE, d MMMM y', 'id_ID');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(kalenderSelectedDateProvider);
    final transactions = ref.watch(kalenderSelectedDateTransactionsProvider);
    final summary = ref.watch(kalenderSelectedDateSummaryProvider);
    final hideBalance = ref.watch(hideBalanceProvider);
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final formattedDate = _dayDateFormatter.format(selectedDate);
    final now = DateTime.now();
    final isToday = selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Arus Kas Harian',
                          style: textTheme.labelMedium?.copyWith(
                            color: scheme.outline,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (isToday) ...[
                          const SizedBox(width: AppSpacing.xs),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: scheme.primary.withValues(alpha: 0.12),
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusSm),
                            ),
                            child: Text(
                              'Hari Ini',
                              style: textTheme.labelSmall?.copyWith(
                                color: scheme.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formattedDate,
                      style: textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                tooltip: 'Tambah transaksi di tanggal ini',
                icon: const Icon(LucideIcons.plus),
                onPressed: () => context.push(
                  '/transactions/add',
                  extra: AddTransactionPrefill(
                    date: selectedDate,
                    accountId: ref.read(kalenderWalletFilterProvider),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _DailyStatTile(
                    icon: LucideIcons.arrow_down_left,
                    iconColor: AppColors.income,
                    label: 'Pemasukan',
                    amountCents: summary.incomeCents,
                    prefix: '+',
                    color: AppColors.income,
                    hideBalance: hideBalance,
                  ),
                ),
                Container(
                  height: 36,
                  width: 1,
                  color: scheme.outlineVariant.withValues(alpha: 0.5),
                ),
                Expanded(
                  child: _DailyStatTile(
                    icon: LucideIcons.arrow_up_right,
                    iconColor: AppColors.expense,
                    label: 'Pengeluaran',
                    amountCents: summary.expenseCents,
                    prefix: '-',
                    color: AppColors.expense,
                    hideBalance: hideBalance,
                  ),
                ),
                Container(
                  height: 36,
                  width: 1,
                  color: scheme.outlineVariant.withValues(alpha: 0.5),
                ),
                Expanded(
                  child: _DailyStatTile(
                    icon: LucideIcons.scale,
                    iconColor: summary.netCents >= 0
                        ? AppColors.income
                        : AppColors.expense,
                    label: 'Bersih',
                    amountCents: summary.netCents.abs(),
                    prefix: summary.netCents < 0 ? '-' : '+',
                    color: summary.netCents >= 0
                        ? AppColors.income
                        : AppColors.expense,
                    hideBalance: hideBalance,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Text(
                'Transaksi',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              transactions.maybeWhen(
                data: (items) => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Text(
                    '${items.length}',
                    style: textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                orElse: () => const SizedBox.shrink(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          transactions.when(
            data: (items) {
              if (items.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Row(
                    children: [
                      Icon(LucideIcons.sparkles,
                          size: 18, color: scheme.outline),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Nggak ada arus kas di tanggal ini. Hari tenang.',
                          style: textTheme.bodyMedium
                              ?.copyWith(color: scheme.outline),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Column(
                children: [
                  for (var i = 0; i < items.length; i++) ...[
                    if (i > 0) const Divider(height: AppSpacing.lg),
                    _CashflowTransactionRow(item: items[i]),
                  ],
                ],
              );
            },
            loading: () => const Column(
              children: [
                ReportShimmerBox(width: double.infinity, height: 44),
                SizedBox(height: AppSpacing.sm),
                ReportShimmerBox(width: double.infinity, height: 44),
              ],
            ),
            error: (err, st) => Text(
              'Gagal memuat transaksi hari ini.',
              style: textTheme.bodyMedium?.copyWith(color: scheme.outline),
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyStatTile extends StatelessWidget {
  const _DailyStatTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.amountCents,
    required this.prefix,
    required this.color,
    required this.hideBalance,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final int amountCents;
  final String prefix;
  final Color color;
  final bool hideBalance;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final text = '$prefix${formatRupiahCompact(amountCents)}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: textTheme.labelSmall?.copyWith(
                    color: scheme.outline,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          hideBalance
              ? HoldToReveal(
                  builder: (context, revealed) => FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      revealed ? text : '••••',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: revealed ? color : scheme.outline,
                      ),
                    ),
                  ),
                )
              : FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    text,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class _CashflowTransactionRow extends ConsumerWidget {
  const _CashflowTransactionRow({required this.item});

  final CashflowTransaction item;

  static final _timeFormatter = DateFormat('HH:mm', 'id_ID');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final amountPrefix = item.isTransfer ? '' : (item.isIncome ? '+' : '-');
    final amountColor = item.isTransfer
        ? scheme.outline
        : (item.isIncome ? AppColors.income : scheme.onSurface);
    final formattedTime = _timeFormatter.format(item.date);

    return InkWell(
      onTap: () async {
        final txItem = await ref
            .read(transactionRepositoryProvider)
            .getItem(item.id);
        if (!context.mounted) return;
        if (txItem != null) {
          await showTransactionDetailSheet(context, item: txItem);
        }
      },
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.xs,
          horizontal: AppSpacing.xs,
        ),
        child: Row(
          children: [
            IconBadge(
              icon: item.iconData,
              color: item.categoryColor,
              shape: BoxShape.rectangle,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.isTransfer
                        ? formattedTime
                        : '${item.categoryName} • ${item.accountName} • $formattedTime',
                    style: textTheme.bodySmall?.copyWith(color: scheme.outline),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '$amountPrefix${formatRupiah(item.amountCents)}',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: amountColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
