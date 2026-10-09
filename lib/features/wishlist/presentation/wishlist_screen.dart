import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/widgets.dart';
import '../domain/wishlist_item.dart';
import 'widgets/wishlist_item_card.dart';
import 'widgets/wishlist_summary_hero.dart';
import 'wishlist_providers.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  Future<void> _handleQuickCancelAndSave(
    BuildContext context,
    WidgetRef ref,
    WishlistItem item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Lepaskan & Berhemat?'),
        content: Text(
          'Hebat! Dengan tidak membeli "${item.name}", kamu baru saja '
          'menyelamatkan ${item.formattedPrice}!\n\n'
          'Barang ini akan ditandai sebagai keberhasilan menahan diri dari belanja impulsif.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Kembali'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            icon: const Icon(LucideIcons.sparkles, size: 16),
            label: const Text('Ya, Berhemat!'),
            style: FilledButton.styleFrom(backgroundColor: Colors.green.shade700),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(wishlistActionProvider.notifier).cancelAndSave(
            item.id,
            reason: 'Memutuskan untuk berhemat setelah evaluasi',
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text('Selamat! Kamu menghemat ${item.formattedPrice} 🎉'),
              backgroundColor: Colors.green.shade800,
            ),
          );
      }
    }
  }

  Future<void> _handleDelete(
    BuildContext context,
    WidgetRef ref,
    WishlistItem item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Hapus wishlist?'),
        content: Text('Hapus "${item.name}" dari daftar wishlist?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogCtx).colorScheme.error,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(wishlistActionProvider.notifier).deleteItem(item.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('Item wishlist dihapus')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final summaryAsync = ref.watch(wishlistSummaryProvider);
    final items = ref.watch(filteredWishlistListProvider);
    final allItems = ref.watch(wishlistListProvider).value ?? const [];
    final activeFilter = ref.watch(wishlistFilterProvider);

    final summary = summaryAsync.value ??
        const WishlistSummary(
          totalSavedCents: 0,
          coolingCount: 0,
          readyCount: 0,
          totalCount: 0,
        );

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            FloatingNavBar.clearance,
          ),
          children: [
            Row(
              children: [
                CircleIconButton(
                  icon: LucideIcons.arrow_left,
                  onTap: () => context.pop(),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Wishlist Anti-Impulsif',
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Tunda 30 hari untuk pikiran jernih',
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                CircleIconButton(
                  icon: LucideIcons.plus,
                  backgroundColor: scheme.primary,
                  onTap: () => context.push('/wishlist/new'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            WishlistSummaryHero(summary: summary),
            const SizedBox(height: AppSpacing.lg),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final filter in WishlistFilter.values) ...[
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: FilterChip(
                        selected: activeFilter == filter,
                        label: Text(
                          _filterLabel(filter, allItems),
                          style: TextStyle(
                            fontWeight: activeFilter == filter
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                        onSelected: (_) {
                          ref.read(wishlistFilterProvider.notifier).setFilter(filter);
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (items.isEmpty) ...[
              if (allItems.isEmpty) ...[
                const EmptyStateCard(
                  icon: LucideIcons.hourglass,
                  title: 'Belum Ada Wishlist Impian',
                  description:
                      'Mau checkout barang mahal? Jangan buru-buru! Masukkan ke sini '
                      'dan beri jeda 30 hari agar kamu yakin apakah benar-benar butuh.',
                ),
                const SizedBox(height: AppSpacing.md),
                FilledButton.icon(
                  onPressed: () => context.push('/wishlist/new'),
                  icon: const Icon(LucideIcons.plus, size: 16),
                  label: const Text('Tambah Wishlist Pertama'),
                ),
              ] else
                EmptyStateCard(
                  icon: LucideIcons.search_x,
                  title: 'Tidak Ada Barang',
                  description:
                      'Tidak ada barang wishlist di kategori "${activeFilter.label}".',
                ),
            ] else ...[
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.sm),
                WishlistItemCard(
                  item: items[i],
                  delay: Duration(milliseconds: 30 * i),
                  onTap: () => context.push('/wishlist/${items[i].id}'),
                  onDelete: () => _handleDelete(context, ref, items[i]),
                  onCancelAndSave: (items[i].isCoolingOff || items[i].isReady)
                      ? () => _handleQuickCancelAndSave(context, ref, items[i])
                      : null,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  String _filterLabel(WishlistFilter filter, List<WishlistItem> all) {
    final count = switch (filter) {
      WishlistFilter.all => all.length,
      WishlistFilter.cooling => all.where((i) => i.isCoolingOff).length,
      WishlistFilter.ready => all.where((i) => i.isReady).length,
      WishlistFilter.saved => all.where((i) => i.isCancelled).length,
      WishlistFilter.done =>
        all.where((i) => i.isPurchased || i.isConverted).length,
    };
    return '${filter.label} ($count)';
  }
}
