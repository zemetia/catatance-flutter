import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/widgets.dart';
import '../laporan_bulanan_providers.dart';
import 'report_shimmer_box.dart';

/// "Selisih (masuk - keluar)" hero card: the selected month's net
/// (income − expense), plus a three-column Pemasukan/Pengeluaran/Transaksi
/// row underneath — always all three, independent of the
/// [laporanBulananModeProvider] toggle used by the breakdown cards below it.
class LaporanSummaryCard extends ConsumerWidget {
  const LaporanSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final income = ref.watch(laporanIncomeProvider);
    final expense = ref.watch(laporanExpenseProvider);
    final count = ref.watch(laporanTransactionCountProvider);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final net = income.value != null && expense.value != null
        ? income.value! - expense.value!
        : null;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selisih (masuk - keluar)',
            style: textTheme.bodyMedium?.copyWith(color: scheme.outline),
          ),
          const SizedBox(height: AppSpacing.xs),
          net == null
              ? const ReportShimmerBox(width: 140, height: 32)
              : Text(
                  '${net >= 0 ? '+' : '-'}${formatRupiahCompact(net.abs())}',
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: net >= 0 ? AppColors.income : AppColors.expense,
                  ),
                ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Belum ada pembanding periode sebelumnya',
            style: textTheme.bodySmall?.copyWith(color: scheme.outline),
          ),
          const Divider(height: AppSpacing.lg + AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  icon: LucideIcons.arrow_down_left,
                  label: 'Pemasukan',
                  color: AppColors.income,
                  value: income,
                ),
              ),
              Expanded(
                child: _MiniStat(
                  icon: LucideIcons.arrow_up_right,
                  label: 'Pengeluaran',
                  color: AppColors.expense,
                  value: expense,
                ),
              ),
              Expanded(
                child: _MiniStat(
                  icon: LucideIcons.receipt,
                  label: 'Transaksi',
                  color: scheme.primary,
                  value: count,
                  isCount: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.label,
    required this.color,
    required this.value,
    this.isCount = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final AsyncValue<int> value;
  final bool isCount;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(label, style: textTheme.bodySmall?.copyWith(color: scheme.outline)),
          ],
        ),
        const SizedBox(height: 2),
        value.when(
          data: (amount) => Text(
            isCount ? '$amount' : formatRupiahCompact(amount),
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: isCount ? null : color,
            ),
          ),
          loading: () => const ReportShimmerBox(width: 60, height: 18),
          error: (err, st) => Text('—', style: textTheme.titleMedium),
        ),
      ],
    );
  }
}
