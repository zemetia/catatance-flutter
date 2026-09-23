import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/icon_badge.dart';
import '../../domain/installment.dart';

class InstallmentCard extends StatelessWidget {
  const InstallmentCard({
    required this.installment,
    this.accountName,
    this.onTap,
    this.onPaymentTap,
    this.onDeleteTap,
    this.delay = Duration.zero,
    super.key,
  });

  final Installment installment;
  final String? accountName;
  final VoidCallback? onTap;
  final VoidCallback? onPaymentTap;
  final VoidCallback? onDeleteTap;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final isCompleted = installment.isCompleted;
    final isOverdue = installment.isOverdue;
    final dueLabel = installment.dueStatusLabel;

    Color badgeBg;
    Color badgeFg;
    if (isCompleted) {
      badgeBg = AppColors.incomeContainer;
      badgeFg = AppColors.income;
    } else if (isOverdue) {
      badgeBg = AppColors.expenseContainer;
      badgeFg = AppColors.expense;
    } else if ((installment.daysUntilDue ?? 99) <= 3) {
      badgeBg = AppColors.warning.withValues(alpha: 0.15);
      badgeFg = AppColors.warning;
    } else {
      badgeBg = scheme.surfaceContainerHighest;
      badgeFg = scheme.onSurfaceVariant;
    }

    final accentColor = isCompleted ? AppColors.income : scheme.primary;

    return Slidable(
      key: ValueKey('installment_${installment.id}'),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: isCompleted ? 0.22 : 0.44,
        children: [
          if (!isCompleted && onPaymentTap != null)
            SlidableAction(
              onPressed: (_) => onPaymentTap!(),
              backgroundColor: scheme.primary,
              foregroundColor: Colors.white,
              icon: LucideIcons.banknote,
              label: 'Bayar',
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            ),
          if (onDeleteTap != null)
            SlidableAction(
              onPressed: (_) => onDeleteTap!(),
              backgroundColor: scheme.error,
              foregroundColor: scheme.onError,
              icon: LucideIcons.trash,
              label: 'Hapus',
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            ),
        ],
      ),
      child: AppCard(
        delay: delay,
        padding: const EdgeInsets.all(AppSpacing.md),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconBadge(
                  icon: LucideIcons.credit_card,
                  color: accentColor,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        installment.name,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${installment.paidInstallments}/${installment.tenorMonths} bulan • '
                        '${installment.formattedInstallmentAmount}/bln',
                        style: textTheme.labelSmall?.copyWith(
                          color: scheme.outline,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isCompleted
                          ? 'Lunas'
                          : installment.formattedRemainingAmount,
                      style: textTheme.titleMedium?.copyWith(
                        color: isCompleted ? AppColors.income : accentColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'dari ${installment.formattedTotalAmount}',
                      style: textTheme.labelSmall?.copyWith(
                        color: scheme.outline,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isCompleted) ...[
                        Icon(LucideIcons.circle_check_big,
                            size: 11, color: badgeFg),
                        const SizedBox(width: 3),
                      ] else if (isOverdue) ...[
                        Icon(LucideIcons.circle_alert, size: 11, color: badgeFg),
                        const SizedBox(width: 3),
                      ],
                      Flexible(
                        child: Text(
                          dueLabel,
                          style: textTheme.labelSmall?.copyWith(
                            color: badgeFg,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                if (accountName != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.wallet,
                            size: 11, color: scheme.onSurfaceVariant),
                        const SizedBox(width: 3),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 130),
                          child: Text(
                            accountName!,
                            style: textTheme.labelSmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: installment.progress,
                minHeight: 6,
                backgroundColor: scheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(accentColor),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    isCompleted
                        ? 'Terbayar lunas'
                        : 'Terbayar: ${installment.formattedPaidAmount} (${installment.progressPercentage})',
                    style: textTheme.labelSmall?.copyWith(
                      color: scheme.outline,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                if (!isCompleted)
                  Text(
                    'Tempo: ${formatDateShort(installment.nextDueDate!)}',
                    style: textTheme.labelSmall?.copyWith(
                      color: scheme.outline,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
