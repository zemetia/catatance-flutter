import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../projection_providers.dart';
import '../report_shimmer_box.dart';

/// One-line budget-health summary card: "Semua N budget aman" when nothing
/// is over/close to its limit, otherwise how many need attention.
class BudgetHealthCard extends ConsumerWidget {
  const BudgetHealthCard({this.onTap, super.key});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projection = ref.watch(monthProjectionProvider);
    final textTheme = Theme.of(context).textTheme;

    if (projection == null) {
      return const AppCard(child: ReportShimmerBox(width: double.infinity, height: 24));
    }

    final health = projection.budgetHealth;
    if (health.total == 0) {
      return AppCard(
        onTap: onTap,
        child: Row(
          children: [
            const IconBadge(icon: LucideIcons.chart_pie, shape: BoxShape.rectangle),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                'Belum ada budget bulan ini',
                style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }

    final atRisk = health.cautionCount + health.overCount;
    final allSafe = atRisk == 0;
    final color = allSafe ? AppColors.income : AppColors.warning;
    final label = allSafe
        ? 'Semua ${health.total} budget aman'
        : '$atRisk dari ${health.total} budget perlu perhatian';

    return AppCard(
      onTap: onTap,
      color: color.withValues(alpha: 0.06),
      child: Row(
        children: [
          IconBadge(
            icon: allSafe ? LucideIcons.circle_check_big : LucideIcons.triangle_alert,
            color: color,
            shape: BoxShape.rectangle,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              label,
              style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
