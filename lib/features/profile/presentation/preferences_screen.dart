import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/widgets.dart';
import 'profile_settings_providers.dart';
import 'widgets/settings_toggle_tile.dart';

class PreferencesScreen extends ConsumerWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final prefs = ref.watch(preferencesProvider);
    final notifier = ref.read(preferencesProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Preferensi'), centerTitle: false),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text(
            'Mata Uang',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          MenuSection(
            items: [
              MenuSectionItem(
                icon: LucideIcons.banknote,
                label: 'Rupiah (IDR)',
                description: 'Satu-satunya mata uang yang didukung saat ini',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Format Angka',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Pilih cara pemisah ribuan dan desimal ditampilkan.',
            style: textTheme.bodySmall?.copyWith(color: scheme.outline),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final style in NumberFormatStyle.values) ...[
            _FormatOptionCard(
              style: style,
              selected: prefs.numberFormat == style,
              onTap: () => notifier.state = prefs.copyWith(numberFormat: style),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          const SizedBox(height: AppSpacing.lg),
          SettingsToggleSection(
            children: [
              SettingsToggleTile(
                icon: LucideIcons.circle_dot,
                label: 'Bulatkan ke Rupiah Penuh',
                description: 'Sembunyikan sen/desimal di tampilan nominal',
                value: prefs.roundToWholeRupiah,
                onChanged: (value) =>
                    notifier.state = prefs.copyWith(roundToWholeRupiah: value),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FormatOptionCard extends StatelessWidget {
  const _FormatOptionCard({
    required this.style,
    required this.selected,
    required this.onTap,
  });

  final NumberFormatStyle style;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: selected
              ? scheme.primary.withValues(alpha: 0.10)
              : scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: selected ? scheme.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    style.sample,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                      color: selected ? scheme.primary : scheme.onSurface,
                    ),
                  ),
                  Text(
                    style.description,
                    style: textTheme.bodySmall?.copyWith(color: scheme.outline),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(LucideIcons.circle_check_big, size: 20, color: scheme.primary)
            else
              Icon(
                LucideIcons.circle,
                size: 20,
                color: scheme.outline.withValues(alpha: 0.4),
              ),
          ],
        ),
      ),
    );
  }
}
