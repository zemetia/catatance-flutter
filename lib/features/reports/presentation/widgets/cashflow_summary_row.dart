import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/security/security_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/widgets.dart';
import '../kalender_cashflow_providers.dart';
import 'report_shimmer_box.dart';

/// Masuk / Keluar / Bersih three-column summary for the selected month on
/// the "Kalender Cashflow" screen.
class CashflowSummaryRow extends ConsumerWidget {
  const CashflowSummaryRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final income = ref.watch(kalenderMonthIncomeProvider);
    final expense = ref.watch(kalenderMonthExpenseProvider);
    final net = ref.watch(kalenderMonthNetProvider);

    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: _SummaryColumn(
              label: 'Masuk',
              value: income,
              color: AppColors.income,
              prefix: '+',
            ),
          ),
          Expanded(
            child: _SummaryColumn(
              label: 'Keluar',
              value: expense,
              color: AppColors.expense,
              prefix: '-',
            ),
          ),
          Expanded(
            child: _SummaryColumn(
              label: 'Bersih',
              value: net,
              color: null,
              prefix: '',
              signed: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryColumn extends ConsumerWidget {
  const _SummaryColumn({
    required this.label,
    required this.value,
    required this.color,
    required this.prefix,
    this.signed = false,
  });

  final String label;
  final AsyncValue<int> value;
  final Color? color;
  final String prefix;
  final bool signed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hideBalance = ref.watch(hideBalanceProvider);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textTheme.bodySmall?.copyWith(color: scheme.outline)),
        const SizedBox(height: 2),
        value.when(
          data: (amount) {
            final resolvedColor = color ??
                (amount < 0 ? AppColors.expense : AppColors.income);
            final resolvedPrefix = signed ? (amount < 0 ? '-' : '+') : prefix;
            final text =
                '$resolvedPrefix${formatRupiahCompact(amount.abs())}';
            return hideBalance
                ? HoldToReveal(
                    builder: (context, revealed) => Text(
                      revealed ? text : '••••',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: revealed ? resolvedColor : scheme.outline,
                      ),
                    ),
                  )
                : Text(
                    text,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: resolvedColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  );
          },
          loading: () => const ReportShimmerBox(width: 70, height: 18),
          error: (err, st) => Text('—', style: textTheme.titleSmall),
        ),
      ],
    );
  }
}
