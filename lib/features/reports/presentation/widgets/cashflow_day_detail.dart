import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/report_models.dart';
import '../kalender_cashflow_providers.dart';
import 'report_shimmer_box.dart';

/// Transaction list for the selected date on the "Kalender Cashflow" screen,
/// or a friendly "hari tenang" message when it has none.
class CashflowDayDetail extends ConsumerWidget {
  const CashflowDayDetail({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(kalenderSelectedDateProvider);
    final transactions = ref.watch(kalenderSelectedDateTransactionsProvider);
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final formattedDate = DateFormat('EEEE, d MMMM y', 'id_ID').format(selectedDate);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            formattedDate,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          transactions.when(
            data: (items) {
              if (items.isEmpty) {
                return Text(
                  'Nggak ada arus hari ini. Hari tenang.',
                  style: textTheme.bodyMedium?.copyWith(color: scheme.outline),
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

class _CashflowTransactionRow extends StatelessWidget {
  const _CashflowTransactionRow({required this.item});

  final CashflowTransaction item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final amountPrefix = item.isTransfer ? '' : (item.isIncome ? '+' : '-');
    final amountColor = item.isTransfer
        ? scheme.outline
        : (item.isIncome ? AppColors.income : scheme.onSurface);
    final formattedTime = DateFormat('HH:mm', 'id_ID').format(item.date);

    return Row(
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
    );
  }
}
