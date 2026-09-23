import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/decorative_circle.dart';
import '../../../../core/widgets/icon_badge.dart';
import '../debt_providers.dart';

/// Dashboard overview card for Utang & Piutang (Debts & Receivables).
class DashboardDebtCard extends ConsumerWidget {
  const DashboardDebtCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final summary = ref.watch(debtSummaryProvider);

    final hasActive =
        summary.activeDebtCount > 0 || summary.activeReceivableCount > 0;

    return AppCard(
      onTap: () => context.push('/debts'),
      padding: const EdgeInsets.all(AppSpacing.md),
      backgroundLayers: [
        Positioned(
          right: -30,
          top: -30,
          child: DecorativeCircle(size: 110, color: scheme.primary, alpha: 0.08),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconBadge(
                    icon: LucideIcons.hand_coins,
                    color: scheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Utang & Piutang',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    hasActive ? 'Kelola' : 'Catat',
                    style: textTheme.labelMedium?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    LucideIcons.chevron_right,
                    size: 16,
                    color: scheme.primary,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (hasActive) ...[
            Row(
              children: [
                Expanded(
                  child: _DebtStatPanel(
                    icon: LucideIcons.arrow_up_right,
                    color: AppColors.expense,
                    label: 'Utang Saya',
                    amountCents: summary.totalDebtRemainingCents,
                    caption: '${summary.activeDebtCount} pinjaman',
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _DebtStatPanel(
                    icon: LucideIcons.arrow_down_left,
                    color: AppColors.income,
                    label: 'Piutang Saya',
                    amountCents: summary.totalReceivableRemainingCents,
                    caption: '${summary.activeReceivableCount} tagihan',
                  ),
                ),
              ],
            ),
            if (summary.overdueCount > 0) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.expenseContainer.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      LucideIcons.triangle_alert,
                      size: 14,
                      color: AppColors.expense,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        '${summary.overdueCount} tagihan melewati jatuh tempo',
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.expense,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ] else ...[
            Text(
              'Tidak ada tanggungan utang atau piutang aktif saat ini.',
              style: textTheme.bodySmall?.copyWith(
                color: scheme.outline,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Tinted rounded panel for one side (debt/receivable) of [DashboardDebtCard].
class _DebtStatPanel extends StatelessWidget {
  const _DebtStatPanel({
    required this.icon,
    required this.color,
    required this.label,
    required this.amountCents,
    required this.caption,
  });

  final IconData icon;
  final Color color;
  final String label;
  final int amountCents;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatRupiah(amountCents),
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: color),
              maxLines: 1,
            ),
          ),
          Text(caption, style: textTheme.labelSmall?.copyWith(color: scheme.outline)),
        ],
      ),
    );
  }
}
