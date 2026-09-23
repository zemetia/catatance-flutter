import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/security/security_providers.dart';
import '../../../../core/widgets/widgets.dart';

/// `state.extra` payload for the `/profile/security/pin-confirm` route.
class PinConfirmArgs {
  const PinConfirmArgs({required this.title, required this.subtitle});

  final String title;
  final String subtitle;
}

/// Full-screen PIN re-entry used to confirm a sensitive change (turning
/// app lock off). Returns `true` once the current PIN is verified, or
/// `null`/`false` if the user backs out.
Future<bool?> showPinConfirmScreen(
  BuildContext context, {
  required String title,
  required String subtitle,
}) {
  return context.push<bool>(
    '/profile/security/pin-confirm',
    extra: PinConfirmArgs(title: title, subtitle: subtitle),
  );
}

class PinConfirmScreen extends ConsumerWidget {
  const PinConfirmScreen({required this.title, required this.subtitle, super.key});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Konfirmasi PIN'), centerTitle: false),
      body: SafeArea(
        child: PinEntryStep(
          title: title,
          subtitle: subtitle,
          onSubmit: (pin) async {
            final correct = await ref.read(pinRepositoryProvider).verifyPin(pin);
            if (!correct) return 'PIN salah';
            if (context.mounted) Navigator.of(context).pop(true);
            return null;
          },
        ),
      ),
    );
  }
}
