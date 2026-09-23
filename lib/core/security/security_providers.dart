import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'biometric_auth_service.dart';
import 'pin_repository.dart';

final pinRepositoryProvider = Provider<PinRepository>((ref) => PinRepository());

final biometricAuthServiceProvider = Provider<BiometricAuthService>(
  (ref) => BiometricAuthService(),
);

/// Persisted security preferences, loaded once from secure storage.
class SecuritySettings {
  const SecuritySettings({
    required this.hasPin,
    required this.appLockEnabled,
    required this.biometricEnabled,
    required this.hideBalance,
  });

  final bool hasPin;
  final bool appLockEnabled;
  final bool biometricEnabled;
  final bool hideBalance;

  SecuritySettings copyWith({
    bool? hasPin,
    bool? appLockEnabled,
    bool? biometricEnabled,
    bool? hideBalance,
  }) {
    return SecuritySettings(
      hasPin: hasPin ?? this.hasPin,
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      hideBalance: hideBalance ?? this.hideBalance,
    );
  }
}

class SecuritySettingsNotifier extends AsyncNotifier<SecuritySettings> {
  PinRepository get _repo => ref.read(pinRepositoryProvider);

  @override
  Future<SecuritySettings> build() async {
    final hasPin = await _repo.hasPin();
    final appLockEnabled = await _repo.getAppLockEnabled();
    final biometricEnabled = await _repo.getBiometricEnabled();
    final hideBalance = await _repo.getHideBalance();
    return SecuritySettings(
      hasPin: hasPin,
      // App lock can only be truly on if a PIN actually exists.
      appLockEnabled: appLockEnabled && hasPin,
      biometricEnabled: biometricEnabled && hasPin,
      hideBalance: hideBalance,
    );
  }

  /// Called once a new PIN has been created (initial setup or reset) —
  /// enables app lock as part of the same action.
  Future<void> onPinCreated() async {
    await _repo.setAppLockEnabled(true);
    final current = state.value ?? await future;
    state = AsyncData(current.copyWith(hasPin: true, appLockEnabled: true));
  }

  Future<void> setAppLockEnabled(bool value) async {
    await _repo.setAppLockEnabled(value);
    final current = state.value;
    if (current != null) state = AsyncData(current.copyWith(appLockEnabled: value));
  }

  Future<void> setBiometricEnabled(bool value) async {
    await _repo.setBiometricEnabled(value);
    final current = state.value;
    if (current != null) {
      state = AsyncData(current.copyWith(biometricEnabled: value));
    }
  }

  Future<void> setHideBalance(bool value) async {
    await _repo.setHideBalance(value);
    final current = state.value;
    if (current != null) state = AsyncData(current.copyWith(hideBalance: value));
  }

  /// PIN was forgotten — wipes it and turns the lock off entirely.
  Future<void> resetPin() async {
    await _repo.clearPin();
    final current = state.value;
    if (current != null) {
      state = AsyncData(
        current.copyWith(
          hasPin: false,
          appLockEnabled: false,
          biometricEnabled: false,
        ),
      );
    }
  }
}

final securitySettingsProvider =
    AsyncNotifierProvider<SecuritySettingsNotifier, SecuritySettings>(
  SecuritySettingsNotifier.new,
);

/// Convenient selector for whether balances/numbers should be hidden across
/// the app (Profile > Keamanan > Sembunyikan Saldo).
final hideBalanceProvider = Provider<bool>((ref) {
  return ref.watch(securitySettingsProvider).value?.hideBalance ?? false;
});

/// Whether the app-lock screen should currently be covering the app.
///
/// Starts `true` so a cold start always requires unlocking when app lock is
/// on; [AppLockGate] flips it back to `false` after a successful PIN or
/// biometric check, and re-locks whenever the app is backgrounded.
class AppLockNotifier extends Notifier<bool> {
  /// How long the app can sit backgrounded before the next resume demands
  /// the PIN/fingerprint again — short app switches (checking a bank SMS,
  /// answering a call) stay unlocked.
  static const gracePeriod = Duration(minutes: 5);

  DateTime? _backgroundedAt;

  @override
  bool build() => true;

  void lock() => state = true;

  void unlock() => state = false;

  /// Call when the app is paused/inactive — starts the grace-period timer
  /// instead of locking right away.
  void notePaused() {
    _backgroundedAt = DateTime.now();
  }

  /// Call when the app resumes — locks only if it was backgrounded longer
  /// than [gracePeriod].
  void noteResumed() {
    final backgroundedAt = _backgroundedAt;
    _backgroundedAt = null;
    if (backgroundedAt != null &&
        DateTime.now().difference(backgroundedAt) >= gracePeriod) {
      state = true;
    }
  }
}

final appLockProvider = NotifierProvider<AppLockNotifier, bool>(
  AppLockNotifier.new,
);
