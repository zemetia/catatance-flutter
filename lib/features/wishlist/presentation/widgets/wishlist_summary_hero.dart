import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/decorative_circle.dart';
import '../../../../core/widgets/icon_badge.dart';
import '../../domain/wishlist_item.dart';

class WishlistSummaryHero extends StatelessWidget {
  const WishlistSummaryHero({
    required this.summary,
    super.key,
  });

  final WishlistSummary summary;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final hasSaved = summary.totalSavedCents > 0;

    return AppCard(
      color: hasSaved
          ? scheme.primaryContainer.withValues(alpha: 0.35)
          : scheme.surfaceContainerHigh,
      border: Border.all(
        color: (hasSaved ? scheme.primary : scheme.outline).withValues(alpha: 0.25),
        width: 1.5,
      ),
      backgroundLayers: [
        Positioned(
          top: -30,
          right: -30,
          child: DecorativeCircle(
            size: 140,
            color: hasSaved ? scheme.primary : scheme.outline,
            alpha: 0.12,
          ),
        ),
      ],
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(
                icon: LucideIcons.hourglass,
                color: scheme.primary,
                size: 22,
                alpha: 0.2,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Uang Diselamatkan',
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      summary.formattedTotalSaved,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: hasSaved ? scheme.primary : scheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              if (summary.readyCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.sparkles, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${summary.readyCount} siap evaluasi',
                        style: textTheme.labelSmall?.copyWith(
                          color: Colors.amber,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: scheme.surface.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Row(
              children: [
                _StatPill(
                  icon: LucideIcons.timer,
                  label: 'Masa tunggu',
                  value: '${summary.coolingCount}',
                  color: scheme.primary,
                ),
                const SizedBox(width: AppSpacing.lg),
                _StatPill(
                  icon: LucideIcons.check_check,
                  label: 'Siap putuskan',
                  value: '${summary.readyCount}',
                  color: Colors.amber,
                ),
                const SizedBox(width: AppSpacing.lg),
                _StatPill(
                  icon: LucideIcons.shield_check,
                  label: 'Total barang',
                  value: '${summary.totalCount}',
                  color: scheme.outline,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '💡 Trik 30 Hari: Menunda pembelian memberi ruang bagi logika untuk mengalahkan dorongan impulsif sesaat.',
            style: textTheme.bodySmall?.copyWith(
              color: scheme.outline,
              fontStyle: FontStyle.italic,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
