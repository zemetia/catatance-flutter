import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../insights_providers.dart';
import '../report_shimmer_box.dart';

/// "Yang perlu diperhatian": a short list of at-a-glance callouts — whether
/// there's been any spending today, progress on the newest unfinished
/// savings goal, and this month's single biggest-spend day. Rows that don't
/// apply (e.g. no savings goals yet) are simply omitted; the whole card
/// hides itself if nothing applies.
class ProyeksiInsightsCard extends ConsumerWidget {
  const ProyeksiInsightsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spending = ref.watch(spendingInsightsProvider);
    final goalAsync = ref.watch(savingsGoalInsightProvider);
    final textTheme = Theme.of(context).textTheme;

    if (spending == null || goalAsync.isLoading) {
      return const AppCard(child: ReportShimmerBox(width: double.infinity, height: 90));
    }

    final goal = goalAsync.value;
    final rows = <Widget>[];

    if (spending.todayExpenseCents <= 0) {
      rows.add(
        const _InsightRow(
          icon: LucideIcons.piggy_bank,
          color: AppColors.income,
          text: 'Hari ini belum ada belanja. Bagus, tahan ya!',
        ),
      );
    }

    if (goal != null) {
      rows.add(
        _InsightRow(
          icon: LucideIcons.target,
          color: AppColors.income,
          text:
              '${goal.name} ${goal.progressPercent}% — '
              '${formatRupiahCompact(goal.remainingCents)} lagi.',
        ),
      );
    }

    if (spending.worstDay != null) {
      final now = DateTime.now();
      final date = DateTime(now.year, now.month, spending.worstDay!.day);
      rows.add(
        _InsightRow(
          icon: LucideIcons.trending_up,
          text:
              'Hari terboros ${formatDateShort(date)} '
              '(${formatRupiahCompact(spending.worstDay!.amountCents)}) • '
              'belanja ${spending.daysWithExpense} dari ${spending.daysElapsed} hari.',
        ),
      );
    }

    if (rows.isEmpty) return const SizedBox.shrink();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Yang perlu diperhatian',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.md),
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.sm),
            rows[i],
          ],
        ],
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({required this.icon, required this.text, this.color});

  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconBadge(icon: icon, color: color, size: 16, shape: BoxShape.rectangle),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ),
      ],
    );
  }
}
