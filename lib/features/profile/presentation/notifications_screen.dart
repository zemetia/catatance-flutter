import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import 'profile_settings_providers.dart';
import 'widgets/settings_toggle_tile.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notificationSettingsProvider);
    final notifier = ref.read(notificationSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifikasi'), centerTitle: false),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          SettingsToggleSection(
            title: 'Pengingat',
            children: [
              SettingsToggleTile(
                icon: LucideIcons.chart_pie,
                label: 'Peringatan Anggaran',
                description: 'Beri tahu saat pengeluaran mendekati limit budget',
                value: settings.budgetAlerts,
                onChanged: (value) =>
                    notifier.state = settings.copyWith(budgetAlerts: value),
              ),
              SettingsToggleTile(
                icon: LucideIcons.calendar_clock,
                label: 'Pengingat Tagihan',
                description: 'Ingatkan sebelum jatuh tempo tagihan rutin',
                value: settings.billReminders,
                onChanged: (value) =>
                    notifier.state = settings.copyWith(billReminders: value),
              ),
              SettingsToggleTile(
                icon: LucideIcons.chart_bar,
                label: 'Ringkasan Mingguan',
                description: 'Kirim rekap pemasukan & pengeluaran tiap minggu',
                value: settings.weeklySummary,
                onChanged: (value) =>
                    notifier.state = settings.copyWith(weeklySummary: value),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SettingsToggleSection(
            title: 'Lainnya',
            children: [
              SettingsToggleTile(
                icon: LucideIcons.scan_line,
                label: 'Tangkap Notifikasi Bank',
                description: 'Deteksi transaksi otomatis dari notifikasi bank',
                value: settings.transactionCapture,
                onChanged: (value) =>
                    notifier.state = settings.copyWith(transactionCapture: value),
              ),
              SettingsToggleTile(
                icon: LucideIcons.megaphone,
                label: 'Promo & Pembaruan',
                description: 'Info fitur baru dan penawaran dari kami',
                value: settings.promoUpdates,
                onChanged: (value) =>
                    notifier.state = settings.copyWith(promoUpdates: value),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
