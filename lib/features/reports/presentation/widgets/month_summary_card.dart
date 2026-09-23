import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/security/security_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/widgets.dart';
import '../reports_providers.dart';
import 'report_shimmer_box.dart';

/// Full-width card below [NetWorthCard] breaking the selected month's total
/// down into pengeluaran, pemasukan, and bersih — always all three,
/// regardless of the active [selectedReportModeProvider].
class MonthSummaryCard extends ConsumerWidget {
  const MonthSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final income = ref.watch(selectedMonthIncomeProvider);
    final expense = ref.watch(selectedMonthExpenseProvider);
    final net = ref.watch(selectedMonthNetProvider);
    final scheme = Theme.of(context).colorScheme;

    return AppCard(
      child: Column(
        children: [
          _SummaryRow(
            icon: LucideIcons.arrow_up_right,
            label: 'Pengeluaran',
            color: AppColors.expense,
            value: expense,
          ),
          const Divider(height: AppSpacing.lg),
          _SummaryRow(
            icon: LucideIcons.arrow_down_left,
            label: 'Pemasukan',
            color: AppColors.income,
            value: income,
          ),
          const Divider(height: AppSpacing.lg),
          _SummaryRow(
            icon: LucideIcons.scale,
            label: 'Bersih',
            color: scheme.primary,
            value: net,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends ConsumerWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.color,
    required this.value,
  });

  final IconData icon;
  final String label;
  final Color color;
  final AsyncValue<int> value;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hideBalance = ref.watch(hideBalanceProvider);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        IconBadge(icon: icon, color: color, size: 16, shape: BoxShape.rectangle),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(label, style: textTheme.bodyMedium?.copyWith(color: scheme.outline)),
        ),
        value.when(
          data: (amount) => hideBalance
              ? HoldToReveal(
                  builder: (context, revealed) => Text(
                    revealed ? formatRupiah(amount) : 'Rp ••••••••',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: revealed ? color : scheme.outline,
                    ),
                  ),
                )
              : Text(
                  formatRupiah(amount),
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
          loading: () => const ReportShimmerBox(width: 90, height: 20),
          error: (err, st) => Text('—', style: textTheme.titleMedium),
        ),
      ],
    );
  }
}
