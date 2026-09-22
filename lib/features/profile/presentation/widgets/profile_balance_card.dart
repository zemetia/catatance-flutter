import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/widgets.dart';

/// Compact saldo summary shown on the profile page, with a shortcut to the
/// full wallet list.
class ProfileBalanceCard extends StatelessWidget {
  const ProfileBalanceCard({
    required this.balanceCents,
    required this.walletCount,
    this.onTap,
    super.key,
  });

  final int balanceCents;
  final int walletCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      color: scheme.primaryContainer.withValues(alpha: 0.18),
      padding: const EdgeInsets.all(AppSpacing.lg),
      onTap: onTap,
      delay: 40.ms,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total saldo',
                  style: textTheme.bodyMedium?.copyWith(color: scheme.outline),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  formatRupiah(balanceCents),
                  style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  '$walletCount dompet',
                  style: textTheme.bodySmall?.copyWith(color: scheme.outline),
                ),
              ],
            ),
          ),
          Icon(LucideIcons.chevron_right, size: 20, color: scheme.outline),
        ],
      ),
    );
  }
}
