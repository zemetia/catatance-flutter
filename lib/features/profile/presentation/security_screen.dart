import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import 'profile_settings_providers.dart';
import 'widgets/settings_toggle_tile.dart';

class SecurityScreen extends ConsumerWidget {
  const SecurityScreen({super.key});

  void _comingSoon(BuildContext context, String label) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$label segera hadir')));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(securitySettingsProvider);
    final notifier = ref.read(securitySettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Keamanan'), centerTitle: false),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          SettingsToggleSection(
            title: 'Kunci Aplikasi',
            children: [
              SettingsToggleTile(
                icon: LucideIcons.lock,
                label: 'Kunci Otomatis',
                description: 'Minta PIN setiap kali aplikasi dibuka',
                value: settings.appLockEnabled,
                onChanged: (value) {
                  notifier.state = settings.copyWith(appLockEnabled: value);
                  if (value) _comingSoon(context, 'Pengaturan PIN');
                },
              ),
              SettingsToggleTile(
                icon: LucideIcons.fingerprint_pattern,
                label: 'Sidik Jari / Face ID',
                description: 'Gunakan biometrik perangkat sebagai kunci',
                value: settings.biometricEnabled,
                onChanged: (value) =>
                    notifier.state = settings.copyWith(biometricEnabled: value),
              ),
              SettingsToggleTile(
                icon: LucideIcons.eye_off,
                label: 'Sembunyikan Saldo',
                description: 'Sensor nominal saldo di halaman utama',
                value: settings.hideBalance,
                onChanged: (value) =>
                    notifier.state = settings.copyWith(hideBalance: value),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SettingsToggleSection(
            title: 'Lainnya',
            children: [
              SettingsLinkTile(
                icon: LucideIcons.key_round,
                label: 'Ubah PIN',
                onTap: () => _comingSoon(context, 'Ubah PIN'),
              ),
              SettingsLinkTile(
                icon: LucideIcons.log_out,
                label: 'Keluar dari Perangkat Lain',
                onTap: () => _comingSoon(context, 'Keluar dari perangkat lain'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
