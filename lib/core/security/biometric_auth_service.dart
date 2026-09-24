import 'package:local_auth/local_auth.dart';

/// Thin wrapper around `local_auth` so providers/widgets never touch the
/// plugin API directly.
class BiometricAuthService {
  BiometricAuthService({LocalAuthentication? auth})
    : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  /// Whether this device has biometric hardware enrolled and usable
  /// (fingerprint, Face ID, etc.) — check before offering the toggle.
  Future<bool> isAvailable() async {
    final supported = await _auth.isDeviceSupported();
    if (!supported) return false;
    return _auth.canCheckBiometrics;
  }

  /// Shows the system biometric prompt. Returns `false` (not an exception)
  /// on any failure — lockout, no biometrics enrolled, user cancel, or the
  /// hardware being unavailable — so callers can fall back to the PIN pad.
  Future<bool> authenticate({required String reason}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }
}
