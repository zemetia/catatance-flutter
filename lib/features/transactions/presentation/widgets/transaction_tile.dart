import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/transaction_item.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    required this.item,
    this.onTap,
    super.key,
  });

  final TransactionItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final isIncome = item.isIncome;
    final amountPrefix = item.isTransfer ? '' : (isIncome ? '+' : '-');
    final amountColor = item.isTransfer
        ? scheme.outline
        : (isIncome ? AppColors.income : scheme.onSurface);
    final formattedDate = DateFormat('d MMM • HH:mm', 'id_ID').format(item.date);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.xs,
        ),
        child: Row(
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
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.isTransfer
                        ? formattedDate
                        : '${item.categoryName} • ${item.accountName} • $formattedDate',
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.outline,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '$amountPrefix${formatCurrencyInput(item.amountCents, currency: item.accountCurrency)}',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: amountColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
