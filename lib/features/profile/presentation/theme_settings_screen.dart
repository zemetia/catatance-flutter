import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_color_theme.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/theme_providers.dart';
import '../../../core/widgets/widgets.dart';

class ThemeSettingsScreen extends ConsumerWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(themeSettingsProvider);
    final notifier = ref.read(themeSettingsProvider.notifier);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tema Tampilan'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // Live Preview Card
          AppCard(
            color: scheme.primaryContainer.withValues(alpha: 0.2),
            padding: const EdgeInsets.all(AppSpacing.lg),
            backgroundLayers: const [
              Positioned(
                right: -30,
                top: -30,
                child: DecorativeCircle(size: 140, alpha: 0.15),
              ),
            ],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pratinjau Tema',
                      style: textTheme.labelLarge?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Text(
                        settings.colorTheme.label,
                        style: textTheme.labelSmall?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Saldo Bersih',
                  style: textTheme.bodySmall?.copyWith(color: scheme.outline),
                ),
                const SizedBox(height: 2),
                Text(
                  'Rp 12.500.000',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    FilledButton.icon(
                      onPressed: () {},
                      icon: const Icon(LucideIcons.plus, size: 16),
                      label: const Text('Catat'),
                      style: FilledButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                      child: const Text('Rincian'),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(duration: 200.ms),

          const SizedBox(height: AppSpacing.lg),

          // Mode Tampilan Section
          Text(
            'Mode Tampilan',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Sesuaikan pencahayaan layar dengan lingkunganmu.',
            style: textTheme.bodySmall?.copyWith(color: scheme.outline),
          ),
          const SizedBox(height: AppSpacing.sm),

          Row(
            children: [
              Expanded(
                child: _ModeOptionCard(
                  icon: LucideIcons.sun,
                  label: 'Terang',
                  selected: settings.themeMode == ThemeMode.light,
                  onTap: () => notifier.setThemeMode(ThemeMode.light),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _ModeOptionCard(
                  icon: LucideIcons.moon,
                  label: 'Gelap',
                  selected: settings.themeMode == ThemeMode.dark,
                  onTap: () => notifier.setThemeMode(ThemeMode.dark),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _ModeOptionCard(
                  icon: LucideIcons.smartphone,
                  label: 'Sistem',
                  selected: settings.themeMode == ThemeMode.system,
                  onTap: () => notifier.setThemeMode(ThemeMode.system),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          // Palet Warna Section
          Text(
            'Pilihan Warna Utama',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Pilih warna kesukaanmu agar tidak jenuh dan lebih nyaman di mata.',
            style: textTheme.bodySmall?.copyWith(color: scheme.outline),
          ),
          const SizedBox(height: AppSpacing.md),

          for (var i = 0; i < AppColorTheme.values.length; i++) ...[
            _ColorThemeTile(
              theme: AppColorTheme.values[i],
              isSelected: settings.colorTheme == AppColorTheme.values[i],
              onTap: () => notifier.setColorTheme(AppColorTheme.values[i]),
            ).animate().fadeIn(
              delay: Duration(milliseconds: 30 * i),
              duration: 200.ms,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _ModeOptionCard extends StatelessWidget {
  const _ModeOptionCard({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: AnimatedContainer(
        duration: 180.ms,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: selected
              ? scheme.primary.withValues(alpha: 0.12)
              : scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: selected ? scheme.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 22,
              color: selected ? scheme.primary : scheme.outline,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? scheme.primary : scheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorThemeTile extends StatelessWidget {
  const _ColorThemeTile({
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  final AppColorTheme theme;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: AnimatedContainer(
        duration: 180.ms,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? scheme.primary.withValues(alpha: 0.10)
              : scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: isSelected ? scheme.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Color Swatches Trio
            Row(
              children: [
                _ColorDot(color: theme.primary, size: 24),
                Transform.translate(
                  offset: const Offset(-8, 0),
                  child: _ColorDot(color: theme.secondary, size: 20),
                ),
                Transform.translate(
                  offset: const Offset(-16, 0),
                  child: _ColorDot(color: theme.tertiary, size: 16),
                ),
              ],
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    theme.label,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected ? scheme.primary : scheme.onSurface,
                    ),
                  ),
                  Text(
                    theme.subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.primary,
                ),
                child: Icon(
                  LucideIcons.check,
                  size: 16,
                  color: scheme.onPrimary,
                ),
              )
            else
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: scheme.outline.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.surface,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }
}
