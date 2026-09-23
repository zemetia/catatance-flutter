import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../core/services/home_widget_service.dart';
import '../../../core/utils/formatters.dart';
import '../../accounts/presentation/account_providers.dart';

enum WidgetCardStyle {
  darkFintech('Fintech Gelap', 'Nuansa modern hitam kontras tinggi'),
  themeAccent('Aksen Tema', 'Mengikuti warna tema aplikasi aktif'),
  minimalist('Minimalis Bersih', 'Tampilan ringkas tanpa aksen berlebih');

  const WidgetCardStyle(this.label, this.description);
  final String label;
  final String description;
}

class HomeWidgetSettings {
  const HomeWidgetSettings({
    this.hideBalanceByDefault = false,
    this.showActiveWalletsCount = true,
    this.cardStyle = WidgetCardStyle.darkFintech,
  });

  final bool hideBalanceByDefault;
  final bool showActiveWalletsCount;
  final WidgetCardStyle cardStyle;

  HomeWidgetSettings copyWith({
    bool? hideBalanceByDefault,
    bool? showActiveWalletsCount,
    WidgetCardStyle? cardStyle,
  }) {
    return HomeWidgetSettings(
      hideBalanceByDefault: hideBalanceByDefault ?? this.hideBalanceByDefault,
      showActiveWalletsCount:
          showActiveWalletsCount ?? this.showActiveWalletsCount,
      cardStyle: cardStyle ?? this.cardStyle,
    );
  }
}

final homeWidgetSettingsProvider = StateProvider<HomeWidgetSettings>((ref) {
  return const HomeWidgetSettings();
});

/// Local toggle for the live preview inside the app (peek/hide balance).
final homeWidgetPreviewHideBalanceProvider = StateProvider<bool>((ref) {
  return ref.watch(homeWidgetSettingsProvider).hideBalanceByDefault;
});

/// Syncs the native widget whenever total balance or settings change.
final homeWidgetSyncProvider = Provider<void>((ref) {
  final totalBalance = ref.watch(totalBalanceProvider);
  final accounts = ref.watch(accountListProvider).value ?? const [];
  final settings = ref.watch(homeWidgetSettingsProvider);
  final service = ref.watch(homeWidgetServiceProvider);

  final formattedBalance = settings.hideBalanceByDefault
      ? 'Rp ••••••••'
      : formatRupiah(totalBalance);

  final subtitle = settings.showActiveWalletsCount && accounts.isNotEmpty
      ? '${accounts.length} Dompet Aktif • Real-time'
      : 'Pencatatan Keuangan • Real-time';

  service.updateWidgetData(
    balanceCents: totalBalance,
    formattedBalance: formattedBalance,
    subtitle: subtitle,
  );
});
