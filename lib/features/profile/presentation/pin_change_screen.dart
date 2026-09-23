import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/security/security_providers.dart';
import '../../../core/widgets/widgets.dart';

/// "Ubah PIN" — verify the current PIN, then choose and confirm a new one.
class PinChangeScreen extends ConsumerStatefulWidget {
  const PinChangeScreen({super.key});

  @override
  ConsumerState<PinChangeScreen> createState() => _PinChangeScreenState();
}

enum _ChangeStep { verify, create, confirm }

class _PinChangeScreenState extends ConsumerState<PinChangeScreen> {
  _ChangeStep _step = _ChangeStep.verify;
  String? _newPin;

  Future<String?> _onVerifySubmit(String pin) async {
    final correct = await ref.read(pinRepositoryProvider).verifyPin(pin);
    if (!correct) return 'PIN saat ini salah';
    setState(() => _step = _ChangeStep.create);
    return null;
  }

  Future<String?> _onCreateSubmit(String pin) async {
    setState(() {
      _newPin = pin;
      _step = _ChangeStep.confirm;
    });
    return null;
  }

  Future<String?> _onConfirmSubmit(String pin) async {
    if (pin != _newPin) {
      setState(() {
        _step = _ChangeStep.create;
        _newPin = null;
      });
      return 'PIN tidak cocok, coba lagi dari awal';
    }
    await ref.read(pinRepositoryProvider).setPin(pin);
    if (mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('PIN berhasil diubah')));
      Navigator.of(context).pop(true);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final Widget step;
    switch (_step) {
      case _ChangeStep.verify:
        step = PinEntryStep(
          key: const ValueKey('verify'),
          title: 'Masukkan PIN saat ini',
          subtitle: 'Verifikasi identitas Anda sebelum mengubah PIN',
          onSubmit: _onVerifySubmit,
        );
      case _ChangeStep.create:
        step = PinEntryStep(
          key: const ValueKey('create'),
          title: 'Buat PIN baru',
          subtitle: 'Masukkan 6 digit PIN baru',
          onSubmit: _onCreateSubmit,
        );
      case _ChangeStep.confirm:
        step = PinEntryStep(
          key: const ValueKey('confirm'),
          title: 'Konfirmasi PIN baru',
          subtitle: 'Masukkan ulang PIN baru yang sama',
          onSubmit: _onConfirmSubmit,
        );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Ubah PIN'), centerTitle: false),
      body: SafeArea(child: step),
    );
  }
}
