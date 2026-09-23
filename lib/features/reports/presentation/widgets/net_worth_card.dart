import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/security/security_providers.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/widgets.dart';
import '../reports_providers.dart';
import 'report_shimmer_box.dart';

/// "Kekayaan bersih" summary row: opening balances plus all-time income
/// minus all-time expense.
class NetWorthCard extends ConsumerWidget {
  const NetWorthCard({this.onTap, super.key});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final netWorth = ref.watch(netWorthProvider);
    final hideBalance = ref.watch(hideBalanceProvider);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          IconBadge(icon: LucideIcons.piggy_bank, shape: BoxShape.rectangle),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kekayaan bersih',
                  style: textTheme.bodyMedium?.copyWith(color: scheme.outline),
                ),
                const SizedBox(height: 2),
                netWorth.when(
                  data: (value) => hideBalance
                      ? HoldToReveal(
                          builder: (context, revealed) => Text(
                            revealed ? formatRupiahCompact(value) : 'Rp ••••••••',
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: revealed ? null : scheme.outline,
                            ),
                          ),
                        )
                      : Text(
                          formatRupiahCompact(value),
                          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                        ),
                  loading: () => const ReportShimmerBox(width: 100, height: 22),
                  error: (err, st) => Text('—', style: textTheme.titleLarge),
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
