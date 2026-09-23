import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Raw notification handed over from the native queue — not yet parsed or
/// persisted, see `BankNotificationRepository.syncFromBridge`.
class RawCapturedNotification {
  const RawCapturedNotification({
    required this.packageName,
    required this.appLabel,
    this.title,
    required this.content,
    required this.postedAt,
  });

  final String packageName;
  final String appLabel;
  final String? title;
  final String content;
  final DateTime postedAt;
}

/// Platform channel bridge to Android's `NotificationListenerService`
/// (`BankNotificationListenerService.kt`) — see `MainActivity.kt`'s
/// `BANK_NOTIFICATIONS_CHANNEL` handler for the native side. All methods
/// fail safe (no-op / empty) on non-Android platforms.
class BankNotificationBridge {
  BankNotificationBridge({MethodChannel? channel})
    : _channel =
          channel ??
          const MethodChannel('com.zemetia.pencatatan_keuangan/bank_notifications');

  final MethodChannel _channel;

  bool get _supported => Platform.isAndroid;

  /// Whether the user has granted this app notification-access ("special
  /// access") via system settings.
  Future<bool> isListenerEnabled() async {
    if (!_supported) return false;
    try {
      final enabled = await _channel.invokeMethod<bool>('isListenerEnabled');
      return enabled ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  /// Opens the system's notification-access settings screen so the user
  /// can enable/disable this app's listener.
  Future<void> openListenerSettings() async {
    if (!_supported) return;
    try {
      await _channel.invokeMethod<void>('openListenerSettings');
    } on MissingPluginException {
      // no-op
    } on PlatformException {
      // no-op
    }
  }

  /// Reads and clears the native durable queue of notifications captured
  /// from watched packages since the last drain.
  Future<List<RawCapturedNotification>> drainPendingNotifications() async {
    if (!_supported) return const [];
    try {
      final raw = await _channel.invokeMethod<List<Object?>>(
        'drainPendingNotifications',
      );
      if (raw == null) return const [];

      return raw
          .cast<Map<Object?, Object?>>()
          .map(
            (entry) => RawCapturedNotification(
              packageName: entry['packageName'] as String? ?? '',
              appLabel: entry['appLabel'] as String? ?? '',
              title: entry['title'] as String?,
              content: entry['content'] as String? ?? '',
              postedAt: DateTime.fromMillisecondsSinceEpoch(
                (entry['postedAt'] as num?)?.toInt() ??
                    DateTime.now().millisecondsSinceEpoch,
              ),
            ),
          )
          .where((item) => item.packageName.isNotEmpty && item.content.isNotEmpty)
          .toList();
    } on MissingPluginException {
      return const [];
    } on PlatformException {
      return const [];
    }
  }

  /// Tells the native listener which package names it should actually
  /// queue notifications for — called after every mapping change so the
  /// service (which can run without the Flutter engine alive) stays in
  /// sync via its own `SharedPreferences`.
  Future<void> updateWatchedPackages(List<String> packageNames) async {
    if (!_supported) return;
    try {
      await _channel.invokeMethod<void>('updateWatchedPackages', packageNames);
    } on MissingPluginException {
      // no-op
    } on PlatformException {
      // no-op
    }
  }
}

final bankNotificationBridgeProvider = Provider<BankNotificationBridge>((ref) {
  return BankNotificationBridge();
});
