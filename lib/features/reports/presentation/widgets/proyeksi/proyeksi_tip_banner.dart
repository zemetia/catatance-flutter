import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/utils/formatters.dart';
import '../../projection_providers.dart';

/// A single highlighted closing line summarizing the projection — tone
/// (reassuring vs. urging action) follows the health score, not just the
/// delta's sign.
class ProyeksiTipBanner extends ConsumerWidget {
  const ProyeksiTipBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projection = ref.watch(monthProjectionProvider);
    if (projection == null) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final delta = projection.deltaFromNowCents;
    final amount = formatRupiahCompact(delta.abs());

    final String message;
    if (delta >= 0) {
      message = 'Proyeksi naik $amount dari saldo awal. Pertahankan pola ini!';
    } else if (projection.healthScore >= 80) {
      message = 'Proyeksi turun $amount dari saldo awal. Masih aman, tapi jaga ritme ya.';
    } else if (projection.healthScore >= 50) {
      message =
          'Proyeksi turun $amount dari saldo awal. Mulai kurangi pengeluaran non-esensial.';
    } else {
      message =
          'Proyeksi turun $amount dari saldo awal. Saldo berisiko menipis, evaluasi pengeluaran sekarang.';
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.sparkles, size: 18, color: scheme.onPrimary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
