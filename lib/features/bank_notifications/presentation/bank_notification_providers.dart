import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart'
    hide BankNotificationMapping, CapturedBankNotification;
import '../data/bank_notification_bridge.dart';
import '../data/bank_notification_repository.dart';
import '../domain/bank_notification_mapping.dart';
import '../domain/captured_bank_notification.dart';

export '../data/bank_notification_bridge.dart' show bankNotificationBridgeProvider;

final bankNotificationRepositoryProvider = Provider<BankNotificationRepository>((ref) {
  return BankNotificationRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(bankNotificationBridgeProvider),
  );
});

/// Live list of saved sender→wallet mappings.
final bankMappingListProvider = StreamProvider.autoDispose<List<BankNotificationMapping>>((
  ref,
) {
  return ref.watch(bankNotificationRepositoryProvider).watchMappings();
});

/// Live list of captured notifications still awaiting user confirmation.
final pendingCapturesProvider = StreamProvider.autoDispose<List<CapturedBankNotification>>((
  ref,
) {
  return ref.watch(bankNotificationRepositoryProvider).watchPendingCaptures();
});

/// Whether the user has granted this app notification access.
final notificationListenerStatusProvider = FutureProvider.autoDispose<bool>((ref) {
  return ref.watch(bankNotificationBridgeProvider).isListenerEnabled();
});

/// Manages mapping create/update/delete, keeping the native listener's
/// watched-package set in sync after every mutation.
class BankMappingActionNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> createMapping(BankNotificationMappingDraft draft) async {
    final repo = ref.read(bankNotificationRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.insertMapping(draft);
      await _syncWatchedPackages();
    });
    if (state.hasError) throw state.error!;
  }

  Future<void> updateMapping(int id, BankNotificationMappingDraft draft) async {
    final repo = ref.read(bankNotificationRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.updateMapping(id, draft);
      await _syncWatchedPackages();
    });
    if (state.hasError) throw state.error!;
  }

  Future<void> deleteMapping(int id) async {
    final repo = ref.read(bankNotificationRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.deleteMapping(id);
      await _syncWatchedPackages();
    });
    if (state.hasError) throw state.error!;
  }

  Future<void> _syncWatchedPackages() async {
    final repo = ref.read(bankNotificationRepositoryProvider);
    final bridge = ref.read(bankNotificationBridgeProvider);
    await bridge.updateWatchedPackages(await repo.watchedPackageNames());
  }
}

final bankMappingActionProvider = AsyncNotifierProvider<BankMappingActionNotifier, void>(
  BankMappingActionNotifier.new,
);

/// Confirming/dismissing a captured notification into a real transaction.
class CapturedNotificationActionNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> confirm(
    int id, {
    required int accountId,
    required int categoryId,
    required int amountCents,
    required DateTime date,
    String? note,
  }) async {
    final repo = ref.read(bankNotificationRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => repo.confirmCapture(
        id,
        accountId: accountId,
        categoryId: categoryId,
        amountCents: amountCents,
        date: date,
        note: note,
      ),
    );
    if (state.hasError) throw state.error!;
  }

  Future<void> dismiss(int id) async {
    final repo = ref.read(bankNotificationRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => repo.dismissCapture(id));
    if (state.hasError) throw state.error!;
  }
}

final capturedNotificationActionProvider =
    AsyncNotifierProvider<CapturedNotificationActionNotifier, void>(
      CapturedNotificationActionNotifier.new,
    );

/// Drains the native queue into pending captures — called on app start and
/// resume by `BankNotificationSyncObserver`.
class BankNotificationSyncNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> sync() async {
    final repo = ref.read(bankNotificationRepositoryProvider);
    state = await AsyncValue.guard(() => repo.syncFromBridge());
  }
}

final bankNotificationSyncProvider = AsyncNotifierProvider<BankNotificationSyncNotifier, void>(
  BankNotificationSyncNotifier.new,
);
