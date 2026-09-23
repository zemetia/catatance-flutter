import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../security/security_providers.dart';
import 'pin_unlock_screen.dart';

/// Wraps the whole app (below [MaterialApp.router]'s `builder`) and shows
/// [PinUnlockScreen] on top of everything whenever app lock is enabled and
/// currently locked — cold start, or after the app was backgrounded.
class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final settings = ref.read(securitySettingsProvider).value;
    if (settings == null || !settings.appLockEnabled) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // Don't lock right away — start the grace-period timer so brief app
      // switches don't demand the PIN/fingerprint again.
      ref.read(appLockProvider.notifier).notePaused();
    } else if (state == AppLifecycleState.resumed) {
      ref.read(appLockProvider.notifier).noteResumed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(securitySettingsProvider);
    final locked = ref.watch(appLockProvider);

    return settingsAsync.when(
      loading: () => widget.child,
      error: (_, _) => widget.child,
      data: (settings) {
        final shouldLock = settings.appLockEnabled && settings.hasPin && locked;
        return Stack(
          children: [
            widget.child,
            if (shouldLock) const PinUnlockScreen(),
          ],
        );
      },
    );
  }
}
