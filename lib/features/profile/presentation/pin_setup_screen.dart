import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/security/security_providers.dart';
import '../../../core/widgets/widgets.dart';

/// "Buat PIN" — two steps: choose a 6-digit PIN, then confirm it. On
/// success, persists the PIN and enables app lock, then pops `true`.
class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key});

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

enum _SetupStep { create, confirm }

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  _SetupStep _step = _SetupStep.create;
  String? _firstPin;

  Future<String?> _onCreateSubmit(String pin) async {
    setState(() {
      _firstPin = pin;
      _step = _SetupStep.confirm;
    });
    return null;
  }

  Future<String?> _onConfirmSubmit(String pin) async {
    if (pin != _firstPin) {
      setState(() {
        _step = _SetupStep.create;
        _firstPin = null;
      });
      return 'PIN tidak cocok, coba lagi dari awal';
    }
    await ref.read(pinRepositoryProvider).setPin(pin);
    await ref.read(securitySettingsProvider.notifier).onPinCreated();
    if (mounted) Navigator.of(context).pop(true);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat PIN'), centerTitle: false),
      body: SafeArea(
        child: _step == _SetupStep.create
            ? PinEntryStep(
                key: const ValueKey('create'),
                title: 'Buat PIN baru',
                subtitle: 'Masukkan 6 digit PIN untuk mengunci aplikasi',
                onSubmit: _onCreateSubmit,
              )
            : PinEntryStep(
                key: const ValueKey('confirm'),
                title: 'Konfirmasi PIN',
                subtitle: 'Masukkan ulang PIN yang sama',
                onSubmit: _onConfirmSubmit,
              ),
      ),
    );
  }
}
