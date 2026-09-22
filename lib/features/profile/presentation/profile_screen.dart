import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/theme_providers.dart';
import '../../../core/widgets/widgets.dart';
import 'profile_settings_providers.dart';
import 'widgets/profile_balance_card.dart';
import 'widgets/profile_header_card.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _comingSoon(BuildContext context, String label) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$label segera hadir')));
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Keluar akun?'),
        content: const Text('Kamu perlu masuk kembali untuk mengakses data.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      _comingSoon(context, 'Keluar akun');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSettings = ref.watch(themeSettingsProvider);
    final modeLabel = switch (themeSettings.themeMode) {
      ThemeMode.dark => 'Gelap',
      ThemeMode.light => 'Terang',
      ThemeMode.system => 'Sistem',
    };
    final profile = ref.watch(userProfileProvider);
    final language = ref.watch(appLanguageProvider);

    final accountItems = [
      MenuSectionItem(
        icon: LucideIcons.user,
        label: 'Akun',
        description: 'Data diri dan info akunmu',
        onTap: () => context.push('/profile/account'),
      ),
      MenuSectionItem(
        icon: LucideIcons.sliders_horizontal,
        label: 'Preferensi',
        description: 'Atur mata uang dan format angka',
        onTap: () => context.push('/profile/preferences'),
      ),
      MenuSectionItem(
        icon: LucideIcons.bell,
        label: 'Notifikasi',
        description: 'Kelola pengingat dan pemberitahuan',
        onTap: () => context.push('/profile/notifications'),
      ),
      MenuSectionItem(
        icon: LucideIcons.shield_check,
        label: 'Keamanan',
        description: 'PIN, biometrik, dan proteksi akun',
        onTap: () => context.push('/profile/security'),
      ),
      MenuSectionItem(
        icon: LucideIcons.database,
        label: 'Backup & Data',
        description: 'Cadangkan dan pulihkan datamu',
        onTap: () => _comingSoon(context, 'Backup & Data'),
      ),
    ];

    final appearanceItems = [
      MenuSectionItem(
        icon: LucideIcons.palette,
        label: 'Tema',
        description: '${themeSettings.colorTheme.label} • $modeLabel',
        onTap: () => context.push('/settings/theme'),
      ),
      MenuSectionItem(
        icon: LucideIcons.languages,
        label: 'Bahasa',
        description: language.label,
        onTap: () => context.push('/profile/language'),
      ),
      MenuSectionItem(
        icon: LucideIcons.layout_grid,
        label: 'Widget',
        description: 'Atur widget layar utama',
        onTap: () => _comingSoon(context, 'Widget'),
      ),
    ];

    final featureItems = [
      MenuSectionItem(
        icon: LucideIcons.users,
        label: 'Dompet Bareng',
        description: 'Kelola dompet bersama keluarga/tim',
        onTap: () => _comingSoon(context, 'Dompet Bareng'),
      ),
      MenuSectionItem(
        icon: LucideIcons.wallet,
        label: 'Semua Dompet',
        description: 'Lihat dan kelola semua dompetmu',
        onTap: () => context.push('/wallets'),
      ),
      MenuSectionItem(
        icon: LucideIcons.chart_pie,
        label: 'Semua Budget',
        description: 'Pantau anggaran tiap kategori',
        onTap: () => _comingSoon(context, 'Semua Budget'),
      ),
      MenuSectionItem(
        icon: LucideIcons.target,
        label: 'Semua Target',
        description: 'Lacak progres target tabunganmu',
        onTap: () => _comingSoon(context, 'Semua Target'),
      ),
      MenuSectionItem(
        icon: LucideIcons.hand_coins,
        label: 'Utang & Piutang',
        description: 'Catat pinjaman yang belum lunas',
        onTap: () => _comingSoon(context, 'Utang & Piutang'),
      ),
      MenuSectionItem(
        icon: LucideIcons.credit_card,
        label: 'Cicilan',
        description: 'Pantau jadwal dan sisa cicilan',
        onTap: () => _comingSoon(context, 'Cicilan'),
      ),
      MenuSectionItem(
        icon: LucideIcons.trophy,
        label: 'Tantangan',
        description: 'Ikuti tantangan hemat mingguan',
        onTap: () => _comingSoon(context, 'Tantangan'),
      ),
      MenuSectionItem(
        icon: LucideIcons.zap,
        label: 'Otomatis',
        description: 'Atur transaksi berulang otomatis',
        onTap: () => _comingSoon(context, 'Otomatis'),
      ),
      MenuSectionItem(
        icon: LucideIcons.mic,
        label: 'Voice',
        description: 'Catat transaksi lewat suara',
        onTap: () => _comingSoon(context, 'Voice'),
      ),
      MenuSectionItem(
        icon: LucideIcons.scan_line,
        label: 'Tangkap Notifikasi',
        description: 'Deteksi transaksi dari notifikasi bank',
        onTap: () => _comingSoon(context, 'Tangkap Notifikasi'),
      ),
      MenuSectionItem(
        icon: LucideIcons.bot,
        label: 'Tanya AI',
        description: 'Tanya jawab soal keuanganmu',
        onTap: () => _comingSoon(context, 'Tanya AI'),
      ),
      MenuSectionItem(
        icon: LucideIcons.award,
        label: 'Lencana',
        description: 'Koleksi pencapaianmu di aplikasi',
        onTap: () => _comingSoon(context, 'Lencana'),
      ),
      MenuSectionItem(
        icon: LucideIcons.heart_handshake,
        label: 'Dukung Developer',
        description: 'Bantu pengembangan aplikasi ini',
        onTap: () => _comingSoon(context, 'Dukung Developer'),
      ),
    ];

    final supportItems = [
      MenuSectionItem(
        icon: LucideIcons.life_buoy,
        label: 'Bantuan',
        description: 'Pusat bantuan dan pertanyaan umum',
        onTap: () => context.push('/profile/help'),
      ),
      MenuSectionItem(
        icon: LucideIcons.info,
        label: 'Tentang Aplikasi',
        description: 'Versi aplikasi dan info pengembang',
        onTap: () => context.push('/profile/about'),
      ),
      MenuSectionItem(
        icon: LucideIcons.file_text,
        label: 'Kebijakan Privasi',
        description: 'Cara kami menjaga data pribadimu',
        onTap: () => context.push('/profile/privacy-policy'),
      ),
      MenuSectionItem(
        icon: LucideIcons.file_text,
        label: 'Syarat & Ketentuan',
        description: 'Ketentuan penggunaan aplikasi',
        onTap: () => context.push('/profile/terms'),
      ),
      MenuSectionItem(
        icon: LucideIcons.message_square,
        label: 'Kirim Masukan',
        description: 'Sampaikan saran atau laporkan bug',
        onTap: () => context.push('/profile/feedback'),
      ),
    ];

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
            Text(
              'Profil',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.lg),
            ProfileHeaderCard(
              displayName: profile.displayName,
              email: profile.email,
              onEditTap: () => context.push('/profile/account'),
            ),
            const SizedBox(height: AppSpacing.md),
            ProfileBalanceCard(
              balanceCents: 0,
              walletCount: 1,
              onTap: () => context.push('/wallets'),
            ),
            const SizedBox(height: AppSpacing.lg),
            MenuSection(
              title: 'Akun & Keamanan',
              items: accountItems,
              delay: const Duration(milliseconds: 40),
            ),
            const SizedBox(height: AppSpacing.lg),
            MenuSection(
              title: 'Tampilan & Bahasa',
              items: appearanceItems,
              delay: const Duration(milliseconds: 80),
            ),
            const SizedBox(height: AppSpacing.lg),
            MenuSection(
              title: 'Fitur',
              items: featureItems,
              delay: const Duration(milliseconds: 120),
            ),
            const SizedBox(height: AppSpacing.lg),
            MenuSection(
              title: 'Dukungan',
              items: supportItems,
              delay: const Duration(milliseconds: 160),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _confirmLogout(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.expense,
                  side: BorderSide(color: AppColors.expense.withValues(alpha: 0.4)),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                ),
                icon: const Icon(LucideIcons.log_out, size: 18),
                label: const Text('Keluar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
