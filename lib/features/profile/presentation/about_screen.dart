import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import 'widgets/settings_toggle_tile.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _appVersion = '1.0.0';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Tentang Aplikasi'), centerTitle: false),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                  ),
                  child: Icon(LucideIcons.wallet, size: 34, color: scheme.primary),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Catatance',
                  style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  'Versi $_appVersion',
                  style: textTheme.bodyMedium?.copyWith(color: scheme.outline),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 200.ms),
          const SizedBox(height: AppSpacing.xl),
          SettingsToggleSection(
            children: [
              SettingsLinkTile(
                icon: LucideIcons.file_text,
                label: 'Kebijakan Privasi',
                onTap: () => context.push('/profile/privacy-policy'),
              ),
              SettingsLinkTile(
                icon: LucideIcons.scroll_text,
                label: 'Syarat & Ketentuan',
                onTap: () => context.push('/profile/terms'),
              ),
              SettingsLinkTile(
                icon: LucideIcons.life_buoy,
                label: 'Bantuan',
                onTap: () => context.push('/profile/help'),
              ),
              SettingsLinkTile(
                icon: LucideIcons.message_square,
                label: 'Kirim Masukan',
                onTap: () => context.push('/profile/feedback'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: Text(
              'Dibuat dengan Flutter · © 2026 Zemetia',
              style: textTheme.bodySmall?.copyWith(color: scheme.outline),
            ),
          ),
        ],
      ),
    );
  }
}
