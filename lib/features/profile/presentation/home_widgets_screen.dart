import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/home_widget_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/widgets.dart';
import '../../accounts/presentation/account_providers.dart';
import 'home_widgets_providers.dart';

class HomeWidgetsScreen extends ConsumerWidget {
  const HomeWidgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keep native Android/iOS widget synchronized with latest balance & settings
    ref.watch(homeWidgetSyncProvider);

    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Widget Layar Utama'),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Panduan Pemasangan',
            icon: const Icon(LucideIcons.info),
            onPressed: () => _showInstallationGuide(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        children: [
          const _WidgetInfoBanner(),
          const SizedBox(height: AppSpacing.lg),

          // Primary Implemented Widget Section
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.incomeContainer,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Text(
                  'SIAP PAKAI',
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.income,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Total Saldo & Akses Cepat (+)',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Pantau saldo saat ini secara real-time dan akses langsung pencatatan transaksi melalui tombol (+).',
            style: textTheme.bodySmall?.copyWith(color: scheme.outline),
          ),
          const SizedBox(height: AppSpacing.md),

          // Live Interactive Widget Preview
          const _LiveTotalBalanceWidgetCard(),
          const SizedBox(height: AppSpacing.md),

          // Action Buttons
          const _WidgetActionButtons(),
          const SizedBox(height: AppSpacing.lg),

          // Customization settings for active widget
          const _WidgetSettingsCard(),
          const SizedBox(height: AppSpacing.xl),

          // Upcoming Widgets Showcase
          const _UpcomingWidgetsSection(),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  static void _showInstallationGuide(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _WidgetGuideSheet(),
    );
  }
}

/// Top informative banner explaining homescreen widgets
class _WidgetInfoBanner extends StatelessWidget {
  const _WidgetInfoBanner();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      color: scheme.primaryContainer.withValues(alpha: 0.16),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(
              LucideIcons.layout_grid,
              color: scheme.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Widget di Homescreen HP',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Pasang widget di layar depan HP Anda untuk mengecek keuangan tanpa perlu membuka aplikasi.',
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                InkWell(
                  onTap: () => HomeWidgetsScreen._showInstallationGuide(context),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Lihat cara pasang di HP',
                        style: textTheme.labelMedium?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        LucideIcons.arrow_right,
                        size: 14,
                        color: scheme.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Live Interactive Preview of Widget #1: Total Saldo + '+' Quick Access
class _LiveTotalBalanceWidgetCard extends ConsumerWidget {
  const _LiveTotalBalanceWidgetCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalBalance = ref.watch(totalBalanceProvider);
    final accounts = ref.watch(accountListProvider).value ?? const [];
    final settings = ref.watch(homeWidgetSettingsProvider);
    final isHidden = ref.watch(homeWidgetPreviewHideBalanceProvider);

    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Visual theme styling based on chosen style
    final Color cardBackground;
    final Color cardBorder;
    switch (settings.cardStyle) {
      case WidgetCardStyle.darkFintech:
        cardBackground = const Color(0xFF131922);
        cardBorder = const Color(0xFF2A3546);
        break;
      case WidgetCardStyle.themeAccent:
        cardBackground = scheme.surfaceContainerHigh;
        cardBorder = scheme.primary.withValues(alpha: 0.4);
        break;
      case WidgetCardStyle.minimalist:
        cardBackground = scheme.surfaceContainerHighest;
        cardBorder = scheme.outlineVariant;
        break;
    }

    final balanceDisplay = isHidden ? 'Rp ••••••••' : formatRupiah(totalBalance);
    final subtitle = settings.showActiveWalletsCount && accounts.isNotEmpty
        ? '${accounts.length} Dompet Aktif • Sinkron Otomatis'
        : 'Pencatatan Keuangan • Real-time';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pratinjau Widget (Ukuran 4x2)',
              style: textTheme.labelMedium?.copyWith(
                color: scheme.outline,
                fontWeight: FontWeight.w600,
              ),
            ),
            IconButton(
              tooltip: isHidden ? 'Tampilkan Saldo' : 'Sembunyikan Saldo',
              visualDensity: VisualDensity.compact,
              icon: Icon(
                isHidden ? LucideIcons.eye_off : LucideIcons.eye,
                size: 18,
                color: scheme.primary,
              ),
              onPressed: () {
                ref.read(homeWidgetPreviewHideBalanceProvider.notifier).state =
                    !isHidden;
              },
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),

        // Widget Container (Simulating Launcher AppWidget)
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Mengetuk area kartu membuka Beranda aplikasi.',
                  ),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md + 4,
              ),
              decoration: BoxDecoration(
                color: cardBackground,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                border: Border.all(color: cardBorder, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Info Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: scheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              'TOTAL SALDO',
                              style: textTheme.labelSmall?.copyWith(
                                color: scheme.outline,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          balanceDisplay,
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: textTheme.bodySmall?.copyWith(
                            color: scheme.outline,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: AppSpacing.md),

                  // Quick Access "+" Action Button
                  Tooltip(
                    message: 'Quick access ke tambah transaksi',
                    child: Material(
                      color: scheme.primary,
                      shape: const CircleBorder(),
                      elevation: 4,
                      child: InkWell(
                        onTap: () {
                          context.push('/transactions/add');
                        },
                        customBorder: const CircleBorder(),
                        child: Container(
                          width: 52,
                          height: 52,
                          alignment: Alignment.center,
                          child: Icon(
                            LucideIcons.plus,
                            color: scheme.onPrimary,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Action Buttons under the active widget
class _WidgetActionButtons extends ConsumerWidget {
  const _WidgetActionButtons();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        // Pin to Home Screen Button
        Expanded(
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
            icon: const Icon(LucideIcons.sparkles, size: 18),
            label: const Text(
              'Pasang ke Layar',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () async {
              final service = ref.read(homeWidgetServiceProvider);
              final success = await service.requestPinWidget();

              if (!context.mounted) return;

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Permintaan pasang widget dikirimkan ke launcher HP!',
                    ),
                    backgroundColor: AppColors.income,
                  ),
                );
              } else {
                // If direct pinning is not supported on launcher, show the manual guide
                HomeWidgetsScreen._showInstallationGuide(context);
              }
            },
          ),
        ),

        const SizedBox(width: AppSpacing.sm),

        // Test Quick Access Button
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
          icon: Icon(LucideIcons.plus, size: 18, color: scheme.primary),
          label: const Text('Tes (+)'),
          onPressed: () => context.push('/transactions/add'),
        ),
      ],
    );
  }
}

/// Settings and customizations for the active widget
class _WidgetSettingsCard extends ConsumerWidget {
  const _WidgetSettingsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(homeWidgetSettingsProvider);
    final notifier = ref.read(homeWidgetSettingsProvider.notifier);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pengaturan Widget',
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Privacy toggle
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Sembunyikan Saldo secara Default'),
            subtitle: Text(
              'Tampilkan Rp •••••••• demi privasi saat HP dilihat orang lain',
              style: textTheme.bodySmall?.copyWith(color: scheme.outline),
            ),
            value: settings.hideBalanceByDefault,
            onChanged: (val) {
              notifier.state = settings.copyWith(hideBalanceByDefault: val);
              ref.read(homeWidgetPreviewHideBalanceProvider.notifier).state =
                  val;
            },
          ),

          const Divider(),

          // Show wallet count
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Tampilkan Info Dompet'),
            subtitle: Text(
              'Tampilkan rincian jumlah dompet aktif di bawah saldo',
              style: textTheme.bodySmall?.copyWith(color: scheme.outline),
            ),
            value: settings.showActiveWalletsCount,
            onChanged: (val) {
              notifier.state = settings.copyWith(showActiveWalletsCount: val);
            },
          ),

          const Divider(),

          // Card Style Selector
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Gaya Tampilan Pratinjau',
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              for (final style in WidgetCardStyle.values)
                ChoiceChip(
                  label: Text(style.label),
                  selected: settings.cardStyle == style,
                  onSelected: (selected) {
                    if (selected) {
                      notifier.state = settings.copyWith(cardStyle: style);
                    }
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Showcase of other widget designs (Pilihan widget lainnya)
class _UpcomingWidgetsSection extends StatelessWidget {
  const _UpcomingWidgetsSection();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Text(
                'PILIHAN LAINNYA',
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.outline,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Varian Desain Widget',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Desain widget tambahan yang dapat dipasang di layar utama pada pembaruan mendatang.',
          style: textTheme.bodySmall?.copyWith(color: scheme.outline),
        ),
        const SizedBox(height: AppSpacing.md),

        // Widget #2: Quick Action Bar (4x1)
        _UpcomingWidgetCard(
          title: 'Pintasan Cepat Transaksi',
          sizeTag: 'Ukuran 4x1',
          description:
              'Akses langsung 1-ketuk untuk mencatat pengeluaran, pemasukan, atau transfer dompet.',
          previewWidget: const _QuickActionBarPreview(),
        ),

        const SizedBox(height: AppSpacing.md),

        // Widget #3: Monthly Budget Tracker (4x2)
        _UpcomingWidgetCard(
          title: 'Monitoring Anggaran Bulanan',
          sizeTag: 'Ukuran 4x2',
          description:
              'Pantau progres penggunaan anggaran bulan ini dan sisa limit belanja.',
          previewWidget: const _BudgetTrackerPreview(),
        ),

        const SizedBox(height: AppSpacing.md),

        // Widget #4: Daily Expense & Recent (4x2)
        _UpcomingWidgetCard(
          title: 'Pengeluaran Hari Ini & Terkini',
          sizeTag: 'Ukuran 4x2',
          description:
              'Ringkasan pengeluaran hari ini dan dua transaksi terakhir Anda.',
          previewWidget: const _DailyExpensePreview(),
        ),

        const SizedBox(height: AppSpacing.md),

        // Widget #5: Compact Minimalist Balance (2x1)
        _UpcomingWidgetCard(
          title: 'Saldo Minimalis Ringkas',
          sizeTag: 'Ukuran 2x1',
          description:
              'Widget hemat ruang yang menampilkan saldo bersih dan tren keuangan.',
          previewWidget: const _CompactBalancePreview(),
        ),
      ],
    );
  }
}

/// Generic upcoming widget wrapper with "Segera Hadir" badge
class _UpcomingWidgetCard extends StatelessWidget {
  const _UpcomingWidgetCard({
    required this.title,
    required this.sizeTag,
    required this.description,
    required this.previewWidget,
  });

  final String title;
  final String sizeTag;
  final String description;
  final Widget previewWidget;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Text(
                  sizeTag,
                  style: textTheme.labelSmall?.copyWith(
                    color: scheme.outline,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Text(
                  'Segera Hadir',
                  style: textTheme.labelSmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: textTheme.bodySmall?.copyWith(color: scheme.outline),
          ),
          const SizedBox(height: AppSpacing.md),

          // Render Preview Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: const Color(0xFF131922),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: const Color(0xFF2A3546), width: 1.5),
            ),
            child: previewWidget,
          ),
        ],
      ),
    );
  }
}

/// Preview: Quick Action Bar (4x1)
class _QuickActionBarPreview extends StatelessWidget {
  const _QuickActionBarPreview();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionPill(
            icon: LucideIcons.arrow_up_right,
            label: 'Pengeluaran',
            color: AppColors.expense,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _ActionPill(
            icon: LucideIcons.arrow_down_left,
            label: 'Pemasukan',
            color: AppColors.income,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _ActionPill(
            icon: LucideIcons.arrow_left_right,
            label: 'Transfer',
            color: const Color(0xFF339AF0),
          ),
        ),
      ],
    );
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Preview: Budget Tracker (4x2)
class _BudgetTrackerPreview extends StatelessWidget {
  const _BudgetTrackerPreview();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Anggaran Bulan Ini',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.income.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Terkendali (68%)',
                style: TextStyle(
                  color: AppColors.income,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Sisa Rp 1.450.000',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Terpakai Rp 3.050.000 dari Rp 4.500.000',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 10),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: 0.68,
            backgroundColor: const Color(0xFF1E293B),
            valueColor: const AlwaysStoppedAnimation(Color(0xFF10B981)),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

/// Preview: Daily Expense & Recent Transactions (4x2)
class _DailyExpensePreview extends StatelessWidget {
  const _DailyExpensePreview();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Pengeluaran Hari Ini',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Rp 124.000',
              style: TextStyle(
                color: AppColors.expense,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Divider(color: Color(0xFF2A3546), height: 1),
        const SizedBox(height: 8),
        _MiniTransactionRow(
          title: 'Makan Siang Padang',
          category: 'Makanan',
          amount: '-Rp 35.000',
        ),
        const SizedBox(height: 6),
        _MiniTransactionRow(
          title: 'Kopi Susu Gula Aren',
          category: 'Minuman',
          amount: '-Rp 24.000',
        ),
      ],
    );
  }
}

class _MiniTransactionRow extends StatelessWidget {
  const _MiniTransactionRow({
    required this.title,
    required this.category,
    required this.amount,
  });

  final String title;
  final String category;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                category,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 9),
              ),
            ],
          ),
        ),
        Text(
          amount,
          style: const TextStyle(
            color: Color(0xFFF87171),
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// Preview: Compact Minimalist Balance (2x1)
class _CompactBalancePreview extends StatelessWidget {
  const _CompactBalancePreview();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'SALDO',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Rp 15.450.000',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            LucideIcons.arrow_up_right,
            color: Color(0xFF10B981),
            size: 16,
          ),
        ),
      ],
    );
  }
}

/// Bottom sheet guide for installing widgets on Android and iOS
class _WidgetGuideSheet extends StatelessWidget {
  const _WidgetGuideSheet();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        MediaQuery.of(context).padding.bottom + AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Cara Memasang Widget di Layar HP',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Ikuti panduan berikut sesuai tipe perangkat Anda:',
              style: textTheme.bodySmall?.copyWith(color: scheme.outline),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Android Steps
            _PlatformStepsCard(
              platformName: 'Android',
              icon: Icons.android,
              steps: const [
                'Pergi ke layar utama (homescreen) ponsel Anda.',
                'Tekan dan tahan area kosong di layar hingga muncul menu.',
                'Ketuk menu "Widget".',
                'Cari aplikasi "Pencatatan Keuangan".',
                'Pilih widget "Total Saldo & Transaksi" lalu seret ke layar utama.',
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // iOS Steps
            _PlatformStepsCard(
              platformName: 'iOS (iPhone / iPad)',
              icon: Icons.apple,
              steps: const [
                'Sentuh dan tahan area kosong di layar hingga ikon bergoyang.',
                'Ketuk tombol "+" di pojok kiri atas layar.',
                'Cari "Pencatatan Keuangan" di daftar widget.',
                'Pilih ukuran widget yang Anda sukai.',
                'Ketuk "Tambah Widget" (Add Widget).',
              ],
            ),

            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Mengerti'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlatformStepsCard extends StatelessWidget {
  const _PlatformStepsCard({
    required this.platformName,
    required this.icon,
    required this.steps,
  });

  final String platformName;
  final IconData icon;
  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: scheme.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                platformName,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          for (var i = 0; i < steps.length; i++) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      steps[i],
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
