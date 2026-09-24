import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../core/database/app_database.dart';
import '../data/data_management_repository.dart';

final dataManagementRepositoryProvider = Provider<DataManagementRepository>((
  ref,
) {
  return DataManagementRepository(ref.watch(appDatabaseProvider));
});

/// Editable identity shown on the profile header and the "Akun" screen.
class UserProfile {
  const UserProfile({
    required this.displayName,
    required this.email,
    this.phone = '',
  });

  final String displayName;
  final String email;
  final String phone;

  UserProfile copyWith({String? displayName, String? email, String? phone}) {
    return UserProfile(
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }
}

final userProfileProvider = StateProvider<UserProfile>(
  (ref) => const UserProfile(
    displayName: 'Pengguna',
    email: 'pengguna@email.com',
  ),
);

/// Display language for "Bahasa" — UI-only, doesn't retranslate the app yet.
enum AppLanguage {
  indonesia('Bahasa Indonesia', 'ID'),
  english('English', 'EN');

  const AppLanguage(this.label, this.badge);

  final String label;
  final String badge;
}

final appLanguageProvider = StateProvider<AppLanguage>(
  (ref) => AppLanguage.indonesia,
);

/// Toggle set for "Notifikasi".
class NotificationSettings {
  const NotificationSettings({
    this.budgetAlerts = true,
    this.billReminders = true,
    this.weeklySummary = true,
    this.transactionCapture = false,
    this.promoUpdates = false,
  });

  final bool budgetAlerts;
  final bool billReminders;
  final bool weeklySummary;
  final bool transactionCapture;
  final bool promoUpdates;

  NotificationSettings copyWith({
    bool? budgetAlerts,
    bool? billReminders,
    bool? weeklySummary,
    bool? transactionCapture,
    bool? promoUpdates,
  }) {
    return NotificationSettings(
      budgetAlerts: budgetAlerts ?? this.budgetAlerts,
      billReminders: billReminders ?? this.billReminders,
      weeklySummary: weeklySummary ?? this.weeklySummary,
      transactionCapture: transactionCapture ?? this.transactionCapture,
      promoUpdates: promoUpdates ?? this.promoUpdates,
    );
  }
}

final notificationSettingsProvider = StateProvider<NotificationSettings>(
  (ref) => const NotificationSettings(),
);

/// Number-format style for "Preferensi" — Rupiah is the only currency for
/// now, so this only affects thousands/decimal separators.
enum NumberFormatStyle {
  indonesia('1.000.000,00', 'Titik ribuan, koma desimal'),
  international('1,000,000.00', 'Koma ribuan, titik desimal');

  const NumberFormatStyle(this.sample, this.description);

  final String sample;
  final String description;
}

class PreferencesSettings {
  const PreferencesSettings({
    this.numberFormat = NumberFormatStyle.indonesia,
    this.roundToWholeRupiah = true,
  });

  final NumberFormatStyle numberFormat;
  final bool roundToWholeRupiah;

  PreferencesSettings copyWith({
    NumberFormatStyle? numberFormat,
    bool? roundToWholeRupiah,
  }) {
    return PreferencesSettings(
      numberFormat: numberFormat ?? this.numberFormat,
      roundToWholeRupiah: roundToWholeRupiah ?? this.roundToWholeRupiah,
    );
  }
}

final preferencesProvider = StateProvider<PreferencesSettings>(
  (ref) => const PreferencesSettings(),
);
