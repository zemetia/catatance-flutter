import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pencatatan_keuangan/core/database/app_database.dart' as db;
import 'package:pencatatan_keuangan/features/bank_notifications/data/bank_notification_bridge.dart';
import 'package:pencatatan_keuangan/features/bank_notifications/data/bank_notification_repository.dart';
import 'package:pencatatan_keuangan/features/bank_notifications/domain/bank_notification_mapping.dart';

class FakeBankNotificationBridge implements BankNotificationBridge {
  List<String> lastWatched = [];
  List<RawCapturedNotification> queue = [];

  @override
  Future<bool> isListenerEnabled() async => true;

  @override
  Future<void> openListenerSettings() async {}

  @override
  Future<List<RawCapturedNotification>> drainPendingNotifications() async {
    final copy = List<RawCapturedNotification>.from(queue);
    queue.clear();
    return copy;
  }

  @override
  Future<void> updateWatchedPackages(List<String> packageNames) async {
    lastWatched = List<String>.from(packageNames);
  }
}

void main() {
  late db.AppDatabase database;
  late FakeBankNotificationBridge bridge;
  late BankNotificationRepository repository;

  setUp(() {
    database = db.AppDatabase(NativeDatabase.memory());
    bridge = FakeBankNotificationBridge();
    repository = BankNotificationRepository(database, bridge);
  });

  tearDown(() async {
    await database.close();
  });

  test('insertMapping saves canonical package name for blu', () async {
    final id = await repository.insertMapping(
      const BankNotificationMappingDraft(
        packageName: 'com.bcadigital.blu',
        appLabel: 'blu by BCA Digital',
        accountId: 1,
      ),
    );

    final mappings = await repository.watchMappings().first;
    expect(mappings.any((m) => m.id == id), isTrue);
    final saved = mappings.firstWhere((m) => m.id == id);
    expect(saved.packageName, 'id.co.bcadigital.blu');
  });

  test('watchedPackageNames includes both canonical and aliases for BCA and Blu', () async {
    await repository.insertMapping(
      const BankNotificationMappingDraft(
        packageName: 'id.co.bcadigital.blu',
        appLabel: 'blu by BCA Digital',
        accountId: 1,
      ),
    );
    await repository.insertMapping(
      const BankNotificationMappingDraft(
        packageName: 'com.bca',
        appLabel: 'BCA mobile',
        accountId: 1,
      ),
    );

    final watched = await repository.watchedPackageNames();
    expect(watched, contains('id.co.bcadigital.blu'));
    expect(watched, contains('com.bcadigital.blu'));
    expect(watched, contains('com.bca'));
    expect(watched, contains('com.bca.mybca'));
  });

  test('syncFromBridge captures notification with combined title and content', () async {
    await repository.insertMapping(
      const BankNotificationMappingDraft(
        packageName: 'com.bca',
        appLabel: 'BCA mobile',
        accountId: 1,
      ),
    );

    bridge.queue.add(
      RawCapturedNotification(
        packageName: 'com.bca',
        appLabel: 'BCA mobile',
        title: 'm-Transfer',
        content: 'BERHASIL ke 1234567890 sebesar Rp 50.000,00',
        postedAt: DateTime.now(),
      ),
    );

    await repository.syncFromBridge();

    final captures = await repository.watchPendingCaptures().first;
    expect(captures.length, 1);
    final capture = captures.first;
    expect(capture.parsedAmountCents, 50000);
    expect(capture.direction, 'expense');
    expect(capture.accountId, 1);
  });

  test('simulateNotification inserts pending capture correctly', () async {
    await repository.insertMapping(
      const BankNotificationMappingDraft(
        packageName: 'id.co.bcadigital.blu',
        appLabel: 'blu by BCA Digital',
        accountId: 1,
      ),
    );

    await repository.simulateNotification(
      packageName: 'id.co.bcadigital.blu',
      appLabel: 'blu by BCA Digital',
      title: 'Transfer Berhasil',
      content: 'Kamu telah mengirimkan Rp50.000 ke Budi Santoso',
    );

    final captures = await repository.watchPendingCaptures().first;
    expect(captures.length, 1);
    final capture = captures.first;
    expect(capture.packageName, 'id.co.bcadigital.blu');
    expect(capture.parsedAmountCents, 50000);
    expect(capture.direction, 'expense');
    expect(capture.accountId, 1);
  });
}
