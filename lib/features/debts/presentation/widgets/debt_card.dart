import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/initials_avatar.dart';
import '../../domain/debt.dart';
import '../../domain/debt_type.dart';

class DebtCard extends StatelessWidget {
  const DebtCard({
    required this.debt,
    this.accountName,
    this.onTap,
    this.onPaymentTap,
    this.onDeleteTap,
    this.delay = Duration.zero,
    super.key,
  });

  final Debt debt;
  final String? accountName;
  final VoidCallback? onTap;
  final VoidCallback? onPaymentTap;
  final VoidCallback? onDeleteTap;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final isSettled = debt.isSettled;
    final isOverdue = debt.isOverdue;

    Color badgeBg;
    Color badgeFg;

    if (isSettled) {
      badgeBg = AppColors.incomeContainer;
      badgeFg = AppColors.income;
    } else if (isOverdue) {
      badgeBg = AppColors.expenseContainer;
      badgeFg = AppColors.expense;
    } else if (debt.dueDate != null && (debt.daysUntilDue ?? 99) <= 3) {
      badgeBg = AppColors.warning.withValues(alpha: 0.15);
      badgeFg = AppColors.warning;
    } else {
      badgeBg = scheme.surfaceContainerHighest;
      badgeFg = scheme.onSurfaceVariant;
    }

    final days = debt.daysUntilDue;
    String statusDueDateLabel;
    if (isSettled) {
      statusDueDateLabel = 'Lunas';
    } else if (isOverdue) {
      final daysText = days != null ? '${days.abs()} hari' : '';
      statusDueDateLabel = debt.dueDate != null
          ? 'Lewat tempo $daysText (${formatDateShort(debt.dueDate!)})'
          : 'Lewat tempo';
    } else if (debt.dueDate != null) {
      final daysText = days != null
          ? (days == 0
              ? 'hari ini'
              : days == 1
                  ? 'besok'
                  : '$days hari lagi')
          : '';
      statusDueDateLabel = 'Tempo: ${formatDateShort(debt.dueDate!)} ($daysText)';
    } else {
      statusDueDateLabel = 'Tanpa tempo';
    }

    return Slidable(
      key: ValueKey('debt_${debt.id}'),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: isSettled ? 0.22 : 0.44,
        children: [
          if (!isSettled && onPaymentTap != null)
            SlidableAction(
              onPressed: (_) => onPaymentTap!(),
              backgroundColor: debt.type.color,
              foregroundColor: Colors.white,
              icon: LucideIcons.banknote,
              label: debt.type == DebtType.debt ? 'Bayar' : 'Terima',
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(AppSpacing.radiusXl),
              ),
            ),
          if (onDeleteTap != null)
            SlidableAction(
              onPressed: (_) => onDeleteTap!(),
              backgroundColor: scheme.error,
              foregroundColor: scheme.onError,
              icon: LucideIcons.trash,
              label: 'Hapus',
              borderRadius: isSettled
                  ? BorderRadius.circular(AppSpacing.radiusXl)
                  : const BorderRadius.horizontal(
                      right: Radius.circular(AppSpacing.radiusXl),
                    ),
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
                InitialsAvatar(
                  name: debt.personName,
                  radius: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        debt.personName,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formatDate(debt.transactionDate),
                        style: textTheme.labelSmall?.copyWith(
                          color: scheme.outline,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 150),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          isSettled ? 'Lunas' : formatRupiah(debt.remainingCents),
                          style: textTheme.titleMedium?.copyWith(
                            color: isSettled ? AppColors.income : debt.type.color,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          isSettled
                              ? formatRupiah(debt.amountCents)
                              : 'dari ${formatRupiah(debt.amountCents)}',
                          style: textTheme.labelSmall?.copyWith(
                            color: scheme.outline,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // 1. Debt Type Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: debt.type.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        debt.type == DebtType.debt
                            ? LucideIcons.arrow_up_right
                            : LucideIcons.arrow_down_left,
                        size: 11,
                        color: debt.type.color,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        debt.type.label,
                        style: textTheme.labelSmall?.copyWith(
                          color: debt.type.color,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // 2. Status & Due Date Unified Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSettled) ...[
                        Icon(
                          LucideIcons.circle_check_big,
                          size: 11,
                          color: badgeFg,
                        ),
                        const SizedBox(width: 3),
                      ] else if (isOverdue) ...[
                        Icon(
                          LucideIcons.circle_alert,
                          size: 11,
                          color: badgeFg,
                        ),
                        const SizedBox(width: 3),
                      ] else ...[
                        Icon(
                          LucideIcons.clock,
                          size: 11,
                          color: badgeFg,
                        ),
                        const SizedBox(width: 3),
                      ],
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 180),
                        child: Text(
                          statusDueDateLabel,
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
                // 3. Linked Wallet Badge
                if (accountName != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.wallet,
                          size: 11,
                          color: scheme.onSurfaceVariant,
                        ),
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
            if (debt.note != null && debt.note!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                debt.note!,
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: debt.progress,
                minHeight: 6,
                backgroundColor: scheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isSettled ? AppColors.income : debt.type.color,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isSettled
                  ? 'Terbayar lunas (${formatRupiah(debt.amountCents)})'
                  : 'Terbayar: ${formatRupiah(debt.paidAmountCents)} (${debt.progressPercentage})',
              style: textTheme.labelSmall?.copyWith(
                color: scheme.outline,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
