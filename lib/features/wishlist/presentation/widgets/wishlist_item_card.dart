import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/icon_badge.dart';
import '../../domain/wishlist_item.dart';

class WishlistItemCard extends StatelessWidget {
  const WishlistItemCard({
    required this.item,
    required this.onTap,
    this.onDelete,
    this.onCancelAndSave,
    this.delay = Duration.zero,
    super.key,
  });

  final WishlistItem item;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onCancelAndSave;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final cardContent = AppCard(
      onTap: onTap,
      delay: delay,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconBadge(
                icon: item.iconOption.iconData,
                color: _getBadgeColor(scheme),
                size: 22,
                alpha: 0.16,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _PriorityBadge(priority: item.priority),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.formattedPrice,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: item.isCancelled ? Colors.green : scheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (item.reason != null && item.reason!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: scheme.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.quote, size: 12, color: scheme.outline),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.reason!,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          _StatusFooter(item: item),
        ],
      ),
    );

    if (onDelete == null && onCancelAndSave == null) {
      return cardContent;
    }

    return Slidable(
      key: ValueKey(item.id),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        children: [
          if (item.isCoolingOff || item.isReady)
            SlidableAction(
              onPressed: (_) => onCancelAndSave?.call(),
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
              icon: LucideIcons.shield_check,
              label: 'Hemat',
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(AppSpacing.radiusLg),
              ),
            ),
          SlidableAction(
            onPressed: (_) => onDelete?.call(),
            backgroundColor: scheme.error,
            foregroundColor: scheme.onError,
            icon: LucideIcons.trash,
            label: 'Hapus',
            borderRadius: BorderRadius.horizontal(
              right: Radius.circular(AppSpacing.radiusLg),
            ),
          ),
        ],
      ),
      child: cardContent,
    );
  }

  Color _getBadgeColor(ColorScheme scheme) {
    if (item.isCancelled) return Colors.green;
    if (item.isConverted) return Colors.blue;
    if (item.isReady) return Colors.amber;
    if (item.isPurchased) return scheme.outline;
    return scheme.primary;
  }
}

class _StatusFooter extends StatelessWidget {
  const _StatusFooter({required this.item});

  final WishlistItem item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (item.isCancelled) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(LucideIcons.sparkles, size: 14, color: Colors.green),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Berhasil hemat ${item.formattedSaved}! 🎉',
                style: textTheme.labelSmall?.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (item.isConverted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(LucideIcons.target, size: 14, color: Colors.blue),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Dialihkan ke Target Tabungan 🎯',
                style: textTheme.labelSmall?.copyWith(
                  color: Colors.blue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (item.isPurchased) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Row(
          children: [
            Icon(LucideIcons.circle_check, size: 14, color: scheme.outline),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Sudah dibeli secara sadar ✓',
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.outline,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (item.isReady) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.amber.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(color: Colors.amber.withValues(alpha: 0.45)),
        ),
        child: Row(
          children: [
            const Icon(LucideIcons.sparkles, size: 15, color: Colors.amber),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Masa tunggu selesai! Ketuk untuk evaluasi ⚡',
                style: textTheme.labelSmall?.copyWith(
                  color: Colors.amber,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const Icon(LucideIcons.chevron_right, size: 14, color: Colors.amber),
          ],
        ),
      );
    }

    // Still in cooling off
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(LucideIcons.timer, size: 13, color: scheme.primary),
                const SizedBox(width: 4),
                Text(
                  'Sisa ${item.daysRemaining} hari lagi',
                  style: textTheme.labelSmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            Text(
              '${item.progressPercentInt}% terlewati',
              style: textTheme.labelSmall?.copyWith(
                color: scheme.outline,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: item.progress,
            minHeight: 5,
            backgroundColor: scheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
          ),
        ),
      ],
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.priority});

  final String priority;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final (label, color) = switch (priority) {
      'high' => ('Tinggi', Colors.orange),
      'low' => ('Rendah', Colors.grey),
      _ => ('Sedang', Colors.blue),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        label,
        style: textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}
