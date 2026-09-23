import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../bank_notification_providers.dart';

/// Drains the native bank-notification queue into pending captures on app
/// start and every time the app returns to the foreground — mirrors
/// `AppLockGate`'s `WidgetsBindingObserver` re-lock-on-resume pattern.
/// No-ops safely on platforms without the native listener (see
/// `BankNotificationBridge`).
class BankNotificationSyncObserver extends ConsumerStatefulWidget {
  const BankNotificationSyncObserver({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<BankNotificationSyncObserver> createState() =>
      _BankNotificationSyncObserverState();
}

class _BankNotificationSyncObserverState
    extends ConsumerState<BankNotificationSyncObserver>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _sync();
    }
  }

  void _sync() {
    // Re-check listener-access status too: the user typically grants it from
    // the system's notification-access settings screen (a separate Activity)
    // and then returns here via `resumed`, so the settings screen's status
    // card must re-fetch rather than keep showing its stale "belum aktif"
    // result from before the user left the app.
    ref.invalidate(notificationListenerStatusProvider);
    ref.read(bankNotificationSyncProvider.notifier).sync();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
