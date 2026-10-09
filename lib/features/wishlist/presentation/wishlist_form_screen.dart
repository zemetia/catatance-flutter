import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/input_formatters.dart';
import '../../../core/widgets/widgets.dart';
import '../data/wishlist_repository.dart';
import '../domain/wishlist_item.dart';
import 'wishlist_providers.dart';

class WishlistFormScreen extends HookConsumerWidget {
  const WishlistFormScreen({
    this.wishlistId,
    this.initialName,
    this.initialPriceCents,
    super.key,
  });

  final int? wishlistId;
  final String? initialName;
  final int? initialPriceCents;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final existingItem = wishlistId != null
        ? ref.watch(wishlistItemProvider(wishlistId!)).value
        : null;

    final nameController = useTextEditingController(text: initialName ?? '');
    final priceController = useTextEditingController();
    final reasonController = useTextEditingController();
    final urlController = useTextEditingController();

    final coolingDays = useState(30);
    final priority = useState('medium');
    final selectedIconKey = useState('shopping-bag');
    final isInitialized = useState(false);

    // Initialize state if editing
    useEffect(() {
      if (existingItem != null && !isInitialized.value) {
        nameController.text = existingItem.name;
        priceController.text = formatCurrencyInput(existingItem.estimatedPriceCents);
        reasonController.text = existingItem.reason ?? '';
        urlController.text = existingItem.url ?? '';
        coolingDays.value = existingItem.coolingDays;
        priority.value = existingItem.priority;
        selectedIconKey.value = existingItem.iconKey;
        isInitialized.value = true;
      } else if (existingItem == null && initialPriceCents != null && !isInitialized.value) {
        priceController.text = formatCurrencyInput(initialPriceCents!);
        isInitialized.value = true;
      }
      return null;
    }, [existingItem]);

    int parseAmount() {
      final digits = priceController.text.replaceAll(RegExp(r'[^\d]'), '');
      return int.tryParse(digits) ?? 0;
    }

    void addAmount(int add) {
      final current = parseAmount();
      final updated = current + add;
      priceController.text = formatCurrencyInput(updated);
    }

    Future<void> submit() async {
      final name = nameController.text.trim();
      if (name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nama barang tidak boleh kosong')),
        );
        return;
      }

      final price = parseAmount();
      if (price <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Estimasi harga harus lebih dari Rp 0')),
        );
        return;
      }

      final draft = WishlistDraft(
        name: name,
        estimatedPriceCents: price,
        reason: reasonController.text.trim().isNotEmpty ? reasonController.text.trim() : null,
        url: urlController.text.trim().isNotEmpty ? urlController.text.trim() : null,
        coolingDays: coolingDays.value,
        priority: priority.value,
        iconKey: selectedIconKey.value,
      );

      try {
        if (wishlistId != null) {
          await ref.read(wishlistActionProvider.notifier).updateItem(wishlistId!, draft);
        } else {
          await ref.read(wishlistActionProvider.notifier).createItem(draft);
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                wishlistId != null ? 'Wishlist diperbarui' : 'Wishlist berhasil disimpan!',
              ),
            ),
          );
          context.pop();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menyimpan: $e')),
          );
        }
      }
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
                    wishlistId != null ? 'Edit Wishlist' : 'Tambah ke Wishlist',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Mindset Tip Banner
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: scheme.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.lightbulb, size: 22, color: Colors.amber),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Tunda 30 Hari: Beri jeda waktu sebelum membeli. 70% keinginan impulsif akan hilang dengan sendirinya!',
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Nama Barang
            Text(
              'Nama Barang Impian',
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.xs),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'Contoh: Mechanical Keyboard, Sepatu Sneakers...',
                filled: true,
                fillColor: scheme.surfaceContainerHigh,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Estimasi Harga
            Text(
              'Estimasi Harga',
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.xs),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              inputFormatters: [ThousandsSeparatorInputFormatter()],
              decoration: InputDecoration(
                hintText: 'Rp 0',
                filled: true,
                fillColor: scheme.surfaceContainerHigh,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              children: [
                ActionChip(
                  label: const Text('+100rb'),
                  onPressed: () => addAmount(100000),
                ),
                ActionChip(
                  label: const Text('+500rb'),
                  onPressed: () => addAmount(500000),
                ),
                ActionChip(
                  label: const Text('+1jt'),
                  onPressed: () => addAmount(1000000),
                ),
                ActionChip(
                  label: const Text('+5jt'),
                  onPressed: () => addAmount(5000000),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Jeda Cooling-off Period
            Text(
              'Masa Tunggu (Cooling-off Period)',
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              'Pilih berapa lama kamu ingin menunda sebelum memutuskan membeli:',
              style: textTheme.bodySmall?.copyWith(color: scheme.outline),
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                ChoiceChip(
                  label: const Text('7 Hari'),
                  selected: coolingDays.value == 7,
                  onSelected: (s) {
                    if (s) coolingDays.value = 7;
                  },
                ),
                ChoiceChip(
                  label: const Text('14 Hari'),
                  selected: coolingDays.value == 14,
                  onSelected: (s) {
                    if (s) coolingDays.value = 14;
                  },
                ),
                ChoiceChip(
                  label: const Text('30 Hari (Rekomendasi ⭐)'),
                  selected: coolingDays.value == 30,
                  onSelected: (s) {
                    if (s) coolingDays.value = 30;
                  },
                ),
                ChoiceChip(
                  label: const Text('60 Hari'),
                  selected: coolingDays.value == 60,
                  onSelected: (s) {
                    if (s) coolingDays.value = 60;
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Alasan / Pertanyaan Reflektif
            Text(
              'Refleksi Diri: Kenapa ingin membeli?',
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              'Tulis alasanmu sekarang. Nanti baca kembali setelah masa tunggu selesai:',
              style: textTheme.bodySmall?.copyWith(color: scheme.outline),
            ),
            const SizedBox(height: AppSpacing.xs),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Misal: Untuk produktivitas kerja remote, atau sekadar ingin karena lagi diskon?',
                filled: true,
                fillColor: scheme.surfaceContainerHigh,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Prioritas
            Text(
              'Tingkat Keinginan / Prioritas',
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('Rendah')),
                    selected: priority.value == 'low',
                    onSelected: (s) {
                      if (s) priority.value = 'low';
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('Sedang')),
                    selected: priority.value == 'medium',
                    onSelected: (s) {
                      if (s) priority.value = 'medium';
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('Tinggi')),
                    selected: priority.value == 'high',
                    onSelected: (s) {
                      if (s) priority.value = 'high';
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Ikon Preset
            Text(
              'Pilih Ikon',
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.xs),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final opt in WishlistIcons.options) ...[
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.xs),
                      child: ChoiceChip(
                        avatar: Text(opt.emoji),
                        label: Text(opt.label),
                        selected: selectedIconKey.value == opt.key,
                        onSelected: (s) {
                          if (s) selectedIconKey.value = opt.key;
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Link Produk Opsional
            Text(
              'Link Toko / Produk (Opsional)',
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.xs),
            TextField(
              controller: urlController,
              decoration: InputDecoration(
                hintText: 'https://tokopedia.com/... atau catatan toko',
                filled: true,
                fillColor: scheme.surfaceContainerHigh,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Submit Button
            FilledButton.icon(
              onPressed: submit,
              icon: const Icon(LucideIcons.hourglass, size: 18),
              label: Text(
                wishlistId != null ? 'Perbarui Wishlist' : 'Mulai Tunda 30 Hari',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
