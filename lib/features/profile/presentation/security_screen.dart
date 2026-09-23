import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/security/security_providers.dart';
import '../../../core/theme/app_spacing.dart';
import 'widgets/pin_confirm_screen.dart';
import 'widgets/settings_toggle_tile.dart';

class SecurityScreen extends ConsumerWidget {
  const SecurityScreen({super.key});

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _onAppLockChanged(
    BuildContext context,
    WidgetRef ref,
    bool value,
    bool hasPin,
  ) async {
    final notifier = ref.read(securitySettingsProvider.notifier);
    if (value) {
      if (hasPin) {
        await notifier.setAppLockEnabled(true);
        return;
      }
      // No PIN yet — must create one before the lock can turn on.
      await context.push<bool>('/profile/security/pin-setup');
      return;
    }

    // Turning protection off requires proving you know the current PIN.
    final confirmed = await showPinConfirmScreen(
      context,
      title: 'Matikan Kunci Otomatis',
      subtitle: 'Masukkan PIN Anda untuk mematikan kunci aplikasi',
    );
    if (confirmed == true) {
      await notifier.setAppLockEnabled(false);
    }
  }

  Future<void> _onBiometricChanged(
    BuildContext context,
    WidgetRef ref,
    bool value,
    bool hasPin,
  ) async {
    final notifier = ref.read(securitySettingsProvider.notifier);
    if (!value) {
      await notifier.setBiometricEnabled(false);
      return;
    }
    if (!hasPin) {
      _showMessage(context, 'Aktifkan Kunci Otomatis dan buat PIN terlebih dahulu');
      return;
    }
    final biometrics = ref.read(biometricAuthServiceProvider);
    final available = await biometrics.isAvailable();
    if (!available) {
      if (context.mounted) {
        _showMessage(context, 'Sidik jari / Face ID tidak tersedia di perangkat ini');
      }
      return;
    }
    final verified = await biometrics.authenticate(
      reason: 'Konfirmasi sidik jari / Face ID untuk mengaktifkan',
    );
    if (verified) {
      await notifier.setBiometricEnabled(true);
    } else if (context.mounted) {
      _showMessage(context, 'Verifikasi biometrik gagal');
    }
  }

  Future<void> _onChangePinTap(
    BuildContext context,
    WidgetRef ref,
    bool hasPin,
  ) async {
    if (!hasPin) {
      _showMessage(context, 'Aktifkan Kunci Otomatis terlebih dahulu untuk membuat PIN');
      return;
    }
    await context.push<bool>('/profile/security/pin-change');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(securitySettingsProvider);
    final notifier = ref.read(securitySettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Keamanan'), centerTitle: false),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Gagal memuat: $err')),
        data: (settings) => ListView(
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
                  onChanged: (value) =>
                      _onAppLockChanged(context, ref, value, settings.hasPin),
                ),
                SettingsToggleTile(
                  icon: LucideIcons.fingerprint_pattern,
                  label: 'Sidik Jari / Face ID',
                  description: 'Gunakan biometrik perangkat sebagai kunci',
                  value: settings.biometricEnabled,
                  onChanged: (value) =>
                      _onBiometricChanged(context, ref, value, settings.hasPin),
                ),
                SettingsToggleTile(
                  icon: LucideIcons.eye_off,
                  label: 'Sembunyikan Saldo',
                  description: 'Sensor nominal saldo di halaman utama',
                  value: settings.hideBalance,
                  onChanged: notifier.setHideBalance,
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
                  onTap: () => _onChangePinTap(context, ref, settings.hasPin),
                ),
                SettingsLinkTile(
                  icon: LucideIcons.log_out,
                  label: 'Keluar dari Perangkat Lain',
                  onTap: () =>
                      _showMessage(context, 'Keluar dari perangkat lain segera hadir'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
