import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pencatatan_keuangan/core/database/app_database.dart';
import 'package:pencatatan_keuangan/features/badges/data/badge_repository.dart';
import 'package:pencatatan_keuangan/features/badges/domain/badge_definition.dart';

void main() {
  late AppDatabase db;
  late BadgeRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = BadgeRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('BadgeRepository returns one progress entry per catalog badge', () async {
    final progress = await repository.watchAll().first;
    expect(progress.length, equals(badgeCatalog.length));
    expect(
      progress.map((p) => p.definition.key).toSet(),
      equals(badgeCatalog.map((b) => b.key).toSet()),
    );
  });

  test('first_transaction badge is unlocked by seeded data', () async {
    final progress = await repository.watchAll().first;
    final firstTransaction =
        progress.firstWhere((p) => p.definition.key == 'first_transaction');
    expect(firstTransaction.isUnlocked, isTrue);
  });

  test('unlocking a badge persists it to EarnedBadges', () async {
    await repository.watchAll().first;
    final earned = await db.select(db.earnedBadges).get();
    expect(earned, isNotEmpty);
    expect(earned.any((e) => e.badgeKey == 'first_transaction'), isTrue);
  });

  test('a badge far from its target stays locked', () async {
    final progress = await repository.watchAll().first;
    final legend =
        progress.firstWhere((p) => p.definition.key == 'transactions_1000');
    expect(legend.isUnlocked, isFalse);
    expect(legend.progressRatio, lessThan(1));
  });
}
