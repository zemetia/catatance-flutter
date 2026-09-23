import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'pin_hasher.dart';

/// Persists the app-lock PIN (salted hash only) and the security toggles
/// via the platform keystore/keychain (`flutter_secure_storage`) — never
/// SQLite, since this data must stay encrypted at rest even if the DB file
/// is copied off the device.
class PinRepository {
  PinRepository({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _pinSaltKey = 'security.pin_salt';
  static const _pinHashKey = 'security.pin_hash';
  static const _appLockEnabledKey = 'security.app_lock_enabled';
  static const _biometricEnabledKey = 'security.biometric_enabled';
  static const _hideBalanceKey = 'security.hide_balance';

  Future<bool> hasPin() async {
    final hash = await _storage.read(key: _pinHashKey);
    return hash != null && hash.isNotEmpty;
  }

  Future<void> setPin(String pin) async {
    final derived = PinHasher.create(pin);
    await _storage.write(key: _pinSaltKey, value: derived.salt);
    await _storage.write(key: _pinHashKey, value: derived.hash);
  }

  Future<bool> verifyPin(String pin) async {
    final salt = await _storage.read(key: _pinSaltKey);
    final hash = await _storage.read(key: _pinHashKey);
    if (salt == null || hash == null) return false;
    return PinHasher.verify(pin, PinHash(salt: salt, hash: hash));
  }

  /// Removes the PIN and turns app lock off — used when the user can't
  /// recover their PIN (there is no backend to reset it against).
  Future<void> clearPin() async {
    await _storage.delete(key: _pinSaltKey);
    await _storage.delete(key: _pinHashKey);
    await setAppLockEnabled(false);
    await setBiometricEnabled(false);
  }

  Future<bool> getAppLockEnabled() => _readBool(_appLockEnabledKey);

  Future<void> setAppLockEnabled(bool value) =>
      _writeBool(_appLockEnabledKey, value);

  Future<bool> getBiometricEnabled() => _readBool(_biometricEnabledKey);

  Future<void> setBiometricEnabled(bool value) =>
      _writeBool(_biometricEnabledKey, value);

  Future<bool> getHideBalance() => _readBool(_hideBalanceKey);

  Future<void> setHideBalance(bool value) =>
      _writeBool(_hideBalanceKey, value);

  Future<bool> _readBool(String key) async {
    final raw = await _storage.read(key: key);
    return raw == 'true';
  }

  Future<void> _writeBool(String key, bool value) =>
      _storage.write(key: key, value: value.toString());
}
