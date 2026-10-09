import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pencatatan_keuangan/core/database/app_database.dart' hide WishlistItem;
import 'package:pencatatan_keuangan/features/wishlist/data/wishlist_repository.dart';

void main() {
  late AppDatabase db;
  late WishlistRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = WishlistRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('watchAll loads initial seeded wishlist items', () async {
    final list = await repository.watchAll().first;
    expect(list.length, greaterThanOrEqualTo(3));

    final keyboard = list.firstWhere((w) => w.name.contains('Keyboard'));
    expect(keyboard.estimatedPriceCents, 1650000);
    expect(keyboard.status, 'cooling_off');

    final watch = list.firstWhere((w) => w.name.contains('Smartwatch'));
    expect(watch.status, 'ready');

    final sneakers = list.firstWhere((w) => w.name.contains('Sneakers'));
    expect(sneakers.status, 'cancelled');
    expect(sneakers.savedAmountCents, 1850000);
  });

  test('insert and getItem work as expected', () async {
    final id = await repository.insert(
      const WishlistDraft(
        name: 'Coffee Maker Espresso',
        estimatedPriceCents: 2200000,
        reason: 'Mau ngopi sendiri di rumah biar lebih hemat daripada cafe',
        coolingDays: 14,
        priority: 'high',
        iconKey: 'coffee',
      ),
    );

    final item = await repository.getItem(id);
    expect(item, isNotNull);
    expect(item!.name, 'Coffee Maker Espresso');
    expect(item.estimatedPriceCents, 2200000);
    expect(item.coolingDays, 14);
    expect(item.priority, 'high');
    expect(item.iconKey, 'coffee');
    expect(item.isCoolingOff, isTrue);
  });

  test('cancelAndSave updates status to cancelled and records savedAmount', () async {
    final id = await repository.insert(
      const WishlistDraft(
        name: 'Action Camera 4K',
        estimatedPriceCents: 3500000,
      ),
    );

    final success = await repository.cancelAndSave(
      id,
      reason: 'Sadar jarang jalan-jalan outdoor. Uang diselamatkan!',
    );
    expect(success, isTrue);

    final item = await repository.getItem(id);
    expect(item!.status, 'cancelled');
    expect(item.savedAmountCents, 3500000);
    expect(item.isCancelled, isTrue);
    expect(item.decisionDate, isNotNull);
  });

  test('markPurchased and markConverted update status correctly', () async {
    final id1 = await repository.insert(
      const WishlistDraft(
        name: 'Ergonomic Chair',
        estimatedPriceCents: 1800000,
      ),
    );
    final id2 = await repository.insert(
      const WishlistDraft(
        name: 'iPad Mini',
        estimatedPriceCents: 7500000,
      ),
    );

    await repository.markPurchased(id1);
    await repository.markConverted(id2);

    final item1 = await repository.getItem(id1);
    final item2 = await repository.getItem(id2);

    expect(item1!.isPurchased, isTrue);
    expect(item2!.isConverted, isTrue);
  });

  test('extendCoolingPeriod adds extra days to readyAt', () async {
    final id = await repository.insert(
      const WishlistDraft(
        name: 'Drone Mini',
        estimatedPriceCents: 4000000,
        coolingDays: 7,
      ),
    );

    final before = await repository.getItem(id);
    await repository.extendCoolingPeriod(id, 14);
    final after = await repository.getItem(id);

    expect(after!.coolingDays, before!.coolingDays + 14);
    expect(after.readyAt.difference(before.readyAt).inDays, 14);
  });

  test('delete removes item from database', () async {
    final id = await repository.insert(
      const WishlistDraft(
        name: 'Temporary Item',
        estimatedPriceCents: 500000,
      ),
    );

    final count = await repository.delete(id);
    expect(count, 1);

    final item = await repository.getItem(id);
    expect(item, isNull);
  });
}
