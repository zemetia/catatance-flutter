import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../accounts/domain/account.dart';

/// "Total saldo" header plus one tappable row per wallet/account.
class WalletSummaryCard extends StatelessWidget {
  const WalletSummaryCard({
    required this.accounts,
    required this.totalBalanceCents,
    this.delay = Duration.zero,
    this.onAccountTap,
    super.key,
  });

  final List<Account> accounts;
  final int totalBalanceCents;
  final Duration delay;
  final ValueChanged<Account>? onAccountTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      delay: delay,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total saldo',
            style: textTheme.bodyMedium?.copyWith(color: scheme.outline),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            formatRupiahCompact(totalBalanceCents),
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.md),
          Divider(height: 1, color: scheme.outline.withValues(alpha: 0.15)),
          for (final account in accounts) ...[
            const SizedBox(height: AppSpacing.md),
            InkWell(
              onTap: onAccountTap == null ? null : () => onAccountTap!(account),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              child: Row(
                children: [
                  IconBadge(icon: account.type.icon, shape: BoxShape.rectangle),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.name,
                          style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          account.type.label,
                          style: textTheme.bodySmall?.copyWith(color: scheme.outline),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    formatRupiahCompact(account.balanceCents),
                    style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Icon(LucideIcons.chevron_right, size: 18, color: scheme.outline),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
