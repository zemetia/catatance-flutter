import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../../core/theme/app_colors.dart';
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
      color: scheme.primaryContainer.withValues(alpha: 0.14),
      backgroundLayers: const [
        Positioned(right: -36, top: -36, child: DecorativeCircle(size: 130, alpha: 0.10)),
      ],
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
          for (var i = 0; i < accounts.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.sm),
            _AccountRow(
              account: accounts[i],
              color: AppColors.walletPalette[i % AppColors.walletPalette.length],
              onTap: onAccountTap == null ? null : () => onAccountTap!(accounts[i]),
            ),
          ],
        ],
      ),
    );
  }
}

/// One wallet row, styled as a small tinted card matching this project's
/// "colored panel" pattern rather than a bare divided list row.
class _AccountRow extends StatelessWidget {
  const _AccountRow({required this.account, required this.color, this.onTap});

  final Account account;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: scheme.surface.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            children: [
              IconBadge(icon: account.type.icon, color: color, shape: BoxShape.rectangle),
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
                account.formattedBalanceCompact,
                style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: AppSpacing.xs),
              Icon(LucideIcons.chevron_right, size: 18, color: scheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}
