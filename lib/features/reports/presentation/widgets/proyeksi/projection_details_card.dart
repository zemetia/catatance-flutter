import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../projection_providers.dart';
import '../report_shimmer_box.dart';

/// "Rincian": this month's actual income/expense, the rest-of-month expense
/// estimate plus current balance, and the resulting end-of-month projection.
class ProjectionDetailsCard extends ConsumerWidget {
  const ProjectionDetailsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projection = ref.watch(monthProjectionProvider);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (projection == null) {
      return const AppCard(child: ReportShimmerBox(width: double.infinity, height: 180));
    }

    Widget sectionLabel(String text) => Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Text(
        text,
        style: textTheme.labelMedium?.copyWith(
          color: scheme.outline,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    Widget line(String label, String value, {Color? valueColor}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: textTheme.bodyMedium)),
          Text(
            value,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rincian', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          sectionLabel('BULAN INI'),
          line(
            'Pengeluaran bulan ini',
            '-${formatRupiahCompact(projection.expenseThisMonthCents)}',
            valueColor: AppColors.expense,
          ),
          line(
            'Pemasukan bulan ini',
            '+${formatRupiahCompact(projection.incomeThisMonthCents)}',
            valueColor: AppColors.income,
          ),
          sectionLabel('SISA BULAN'),
          line(
            'Perkiraan belanja sisa bulan',
            '-${formatRupiahCompact(projection.projectedRemainingSpendCents)}',
            valueColor: AppColors.expense,
          ),
          line('Saldo sekarang', formatRupiahCompact(projection.currentBalanceCents)),
          const Divider(height: AppSpacing.lg),
          line(
            'Proyeksi akhir bulan',
            formatRupiahCompact(projection.projectedEndBalanceCents),
          ),
        ],
      ),
    );
  }
}
