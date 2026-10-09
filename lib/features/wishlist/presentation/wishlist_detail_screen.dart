import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/widgets.dart';
import '../domain/wishlist_item.dart';
import 'wishlist_providers.dart';

class WishlistDetailScreen extends ConsumerWidget {
  const WishlistDetailScreen({required this.wishlistId, super.key});

  final int wishlistId;

  Future<void> _handleCancelAndSave(
    BuildContext context,
    WidgetRef ref,
    WishlistItem item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Lepaskan & Berhemat! 🎉'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hebat! Menyadari bahwa kita tidak benar-benar butuh suatu barang '
              'adalah tingkat literasi finansial tertinggi.',
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Dengan membatalkan "${item.name}", kamu berhasil menyelamatkan '
              '${item.formattedPrice}!',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            icon: const Icon(LucideIcons.sparkles, size: 16),
            label: const Text('Simpan Uangku!'),
            style: FilledButton.styleFrom(backgroundColor: Colors.green.shade700),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(wishlistActionProvider.notifier).cancelAndSave(
            item.id,
            reason: 'Memutuskan untuk menahan diri & menghemat uang',
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text('Selamat! Kamu berhasil menghemat ${item.formattedPrice} 🎉'),
              backgroundColor: Colors.green.shade800,
            ),
          );
      }
    }
  }

  Future<void> _handleConvertToGoal(
    BuildContext context,
    WidgetRef ref,
    WishlistItem item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Jadikan Target Tabungan?'),
        content: Text(
          'Karena kamu masih menginginkannya setelah masa tunggu, '
          'mari beli dengan cara sehat: menabungnya terlebih dahulu tanpa mengorbankan cashflow!\n\n'
          'Nama dan estimasi harga akan otomatis disalin ke Target Tabungan baru.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            icon: const Icon(LucideIcons.target, size: 16),
            label: const Text('Buka Target Tabungan'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(wishlistActionProvider.notifier).markConverted(
            item.id,
            note: 'Dialihkan ke Target Tabungan',
          );
      if (context.mounted) {
        final uri = Uri(
          path: '/savings-goals/new',
          queryParameters: {
            'name': item.name,
            'target': item.estimatedPriceCents.toString(),
          },
        );
        context.push(uri.toString());
      }
    }
  }

  Future<void> _handleMarkPurchased(
    BuildContext context,
    WidgetRef ref,
    WishlistItem item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Tandai Telah Dibeli?'),
        content: Text(
          'Apakah kamu sudah membeli "${item.name}"? '
          'Item ini akan ditandai sebagai pembelian yang telah melalui pertimbangan matang.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: const Text('Ya, Sudah Dibeli'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(wishlistActionProvider.notifier).markPurchased(item.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('Item ditandai telah dibeli')));
      }
    }
  }

  Future<void> _handleExtendPeriod(
    BuildContext context,
    WidgetRef ref,
    WishlistItem item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Perpanjang Masa Tunggu?'),
        content: const Text(
          'Masih ragu-ragu? Beri waktu 14 hari tambahan agar pikiran semakin tenang.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: const Text('+14 Hari'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(wishlistActionProvider.notifier).extendPeriod(item.id, 14);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('Masa tunggu diperpanjang 14 hari')));
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
          ..showSnackBar(const SnackBar(content: Text('Wishlist dihapus')));
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final itemAsync = ref.watch(wishlistItemProvider(wishlistId));
    final item = itemAsync.value;

    if (item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Wishlist')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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
                  child: Text(
                    item.name,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                CircleIconButton(
                  icon: LucideIcons.pencil,
                  onTap: () => context.push('/wishlist/${item.id}/edit'),
                ),
                const SizedBox(width: AppSpacing.xs),
                CircleIconButton(
                  icon: LucideIcons.trash,
                  onTap: () => _handleDelete(context, ref, item),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Main Status Banner
            _HeroStatusCard(item: item),
            const SizedBox(height: AppSpacing.lg),

            // Item Details Card
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconBadge(
                        icon: item.iconOption.iconData,
                        color: scheme.primary,
                        size: 26,
                        alpha: 0.2,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.formattedPrice,
                              style: textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: scheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: AppSpacing.xl),
                  _DetailRow(
                    label: 'Masa Tunggu',
                    value: '${item.coolingDays} Hari',
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _DetailRow(
                    label: 'Mulai Dicatat',
                    value: formatDate(item.createdAt),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _DetailRow(
                    label: 'Selesai Evaluasi',
                    value: formatDate(item.readyAt),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _DetailRow(
                    label: 'Prioritas',
                    value: item.priorityLabel,
                  ),
                  if (item.url != null && item.url!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    _DetailRow(
                      label: 'Link / Info Toko',
                      value: item.url!,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Refleksi Awal
            if (item.reason != null && item.reason!.isNotEmpty) ...[
              AppCard(
                color: scheme.surfaceContainerHigh,
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.message_square_quote, size: 18),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'Alasan Ingin Beli (Waktu Dulu)',
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '"${item.reason}"',
                      style: textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            // 3 Pertanyaan Refleksi Finansial
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.brain, size: 20, color: Colors.purpleAccent),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Refleksi Kepala Dingin',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _ReflectionPrompt(
                    number: '1',
                    question: 'Apakah hidupmu baik-baik saja selama masa tunggu tanpa barang ini?',
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _ReflectionPrompt(
                    number: '2',
                    question: 'Apakah barang ini memberi nilai nyata, atau hanya dopamin belanja?',
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _ReflectionPrompt(
                    number: '3',
                    question: 'Jika uang ${item.formattedPrice} ditabung, seberapa tenang masa depanmu?',
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Action Buttons
            if (!item.isDecided) ...[
              Text(
                'Keputusan Akhir',
                style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Button 1: Lepaskan & Hemat (Hero Action)
              FilledButton.icon(
                onPressed: () => _handleCancelAndSave(context, ref, item),
                icon: const Icon(LucideIcons.sparkles, size: 20),
                label: Text(
                  'Lepaskan & Berhemat (${item.formattedPrice})',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Button 2: Jadikan Target Tabungan
              FilledButton.tonalIcon(
                onPressed: () => _handleConvertToGoal(context, ref, item),
                icon: const Icon(LucideIcons.target, size: 20),
                label: const Text(
                  'Jadikan Target Tabungan (Nabung Dulu)',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Button 3: Beli Sekarang
              OutlinedButton.icon(
                onPressed: () => _handleMarkPurchased(context, ref, item),
                icon: const Icon(LucideIcons.shopping_cart, size: 18),
                label: const Text('Beli Sekarang (Sudah Matang)'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Button 4: Perpanjang masa tunggu
              if (item.isReady)
                TextButton.icon(
                  onPressed: () => _handleExtendPeriod(context, ref, item),
                  icon: const Icon(LucideIcons.plus, size: 16),
                  label: const Text('Masih ragu? Perpanjang +14 hari lagi'),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HeroStatusCard extends StatelessWidget {
  const _HeroStatusCard({required this.item});

  final WishlistItem item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (item.isCancelled) {
      return AppCard(
        color: Colors.green.withValues(alpha: 0.15),
        border: Border.all(color: Colors.green.withValues(alpha: 0.4), width: 1.5),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            const Icon(LucideIcons.party_popper, size: 40, color: Colors.green),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Uang Berhasil Diselamatkan! 🎉',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Kamu berhasil menghemat ${item.formattedSaved}. Keputusan hebat menahan belanja impulsif!',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    if (item.isConverted) {
      return AppCard(
        color: Colors.blue.withValues(alpha: 0.15),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.4)),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            const Icon(LucideIcons.target, size: 40, color: Colors.blue),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Dialihkan ke Target Tabungan 🎯',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Barang ini sedang kamu tabung secara terencana dan bijak.',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    if (item.isPurchased) {
      return AppCard(
        color: scheme.surfaceContainerHigh,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Icon(LucideIcons.circle_check, size: 36, color: scheme.outline),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Telah Dibeli Secara Sadar ✓',
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Dibeli setelah melalui masa pertimbangan yang matang.',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(color: scheme.outline),
            ),
          ],
        ),
      );
    }

    if (item.isReady) {
      return AppCard(
        color: Colors.amber.withValues(alpha: 0.18),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.5), width: 1.5),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            const Icon(LucideIcons.sparkles, size: 40, color: Colors.amber),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Masa Tunggu Selesai! ✨',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Waktunya evaluasi dengan kepala dingin. Apakah kamu masih benar-benar menginginkannya?',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    // Cooling off
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.timer, size: 28, color: scheme.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Sisa ${item.daysRemaining} Hari Lagi',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: scheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: item.progress,
              minHeight: 8,
              backgroundColor: scheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${item.progressPercentInt}% dari ${item.coolingDays} hari masa tunggu telah terlewati.',
            style: textTheme.bodySmall?.copyWith(color: scheme.outline),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(color: scheme.outline),
        ),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _ReflectionPrompt extends StatelessWidget {
  const _ReflectionPrompt({required this.number, required this.question});

  final String number;
  final String question;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: textTheme.labelSmall?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            question,
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
