import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../security/security_providers.dart';
import '../../theme/app_spacing.dart';
import '../pin_pad/pin_pad.dart';

/// Full-screen PIN (+ optional biometric) gate shown by [AppLockGate]
/// whenever the app is locked. Not routed via go_router — it sits above
/// the router's own navigator stack so it can cover any screen.
class PinUnlockScreen extends ConsumerStatefulWidget {
  const PinUnlockScreen({super.key});

  @override
  ConsumerState<PinUnlockScreen> createState() => _PinUnlockScreenState();
}

class _PinUnlockScreenState extends ConsumerState<PinUnlockScreen> {
  String _entered = '';
  bool _hasError = false;
  int _shakeSignal = 0;
  bool _checking = false;
  bool _triedBiometricThisLock = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final settings = ref.read(securitySettingsProvider).value;
    if (settings != null &&
        settings.biometricEnabled &&
        !_triedBiometricThisLock) {
      _triedBiometricThisLock = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _tryBiometric());
    }
  }

  Future<void> _tryBiometric() async {
    // Delay briefly so Android FragmentActivity transition completes before prompt
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    final biometrics = ref.read(biometricAuthServiceProvider);
    final ok = await biometrics.authenticate(
      reason: 'Buka kunci Pencatatan Keuangan',
    );
    if (ok && mounted) {
      ref.read(appLockProvider.notifier).unlock();
    }
  }

  Future<void> _onDigit(String digit) async {
    if (_checking || _entered.length >= kPinLength) return;
    setState(() {
      _entered += digit;
      _hasError = false;
    });
    if (_entered.length == kPinLength) {
      await _verify();
    }
  }

  void _onBackspace() {
    if (_checking || _entered.isEmpty) return;
    setState(() => _entered = _entered.substring(0, _entered.length - 1));
  }

  Future<void> _verify() async {
    setState(() => _checking = true);
    final repo = ref.read(pinRepositoryProvider);
    final correct = await repo.verifyPin(_entered);
    if (!mounted) return;
    if (correct) {
      ref.read(appLockProvider.notifier).unlock();
      return;
    }
    setState(() {
      _checking = false;
      _hasError = true;
      _entered = '';
      _shakeSignal++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(securitySettingsProvider).value;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              children: [
                const Spacer(),
                Icon(Icons.lock_outline, size: 40, color: scheme.primary),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Masukkan PIN',
                  style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _hasError ? 'PIN salah, coba lagi' : 'PIN 6 digit untuk membuka aplikasi',
                  style: textTheme.bodyMedium?.copyWith(
                    color: _hasError ? scheme.error : scheme.outline,
                  ),
                ).animate(target: _hasError ? 1 : 0).shakeX(amount: 4),
                const SizedBox(height: AppSpacing.xl),
                PinDotsIndicator(
                  filledCount: _entered.length,
                  hasError: _hasError,
                  shakeSignal: _shakeSignal,
                ),
                const Spacer(),
                PinNumberPad(
                  onDigit: _onDigit,
                  onBackspace: _onBackspace,
                  onBiometricTap:
                      settings?.biometricEnabled == true ? _tryBiometric : null,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
