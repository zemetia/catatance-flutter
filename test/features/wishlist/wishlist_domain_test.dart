import 'package:flutter_test/flutter_test.dart';
import 'package:pencatatan_keuangan/features/wishlist/domain/wishlist_item.dart';

void main() {
  group('WishlistItem Domain Tests', () {
    test('computes isCoolingOff and daysRemaining correctly for active item', () {
      final now = DateTime.now();
      final item = WishlistItem(
        id: 1,
        name: 'Headphones ANC',
        estimatedPriceCents: 2500000,
        createdAt: now.subtract(const Duration(days: 10)),
        readyAt: now.add(const Duration(days: 20)),
        coolingDays: 30,
        status: 'cooling_off',
      );

      expect(item.isCoolingOff, isTrue);
      expect(item.isReady, isFalse);
      expect(item.isCancelled, isFalse);
      expect(item.daysRemaining, greaterThanOrEqualTo(20));
      expect(item.progress, greaterThan(0.0));
      expect(item.progress, lessThan(1.0));
      expect(item.formattedPrice, contains('2.500.000'));
    });

    test('computes isReady when cooling period has elapsed', () {
      final now = DateTime.now();
      final item = WishlistItem(
        id: 2,
        name: 'Mechanical Keyboard',
        estimatedPriceCents: 1500000,
        createdAt: now.subtract(const Duration(days: 35)),
        readyAt: now.subtract(const Duration(days: 5)),
        coolingDays: 30,
        status: 'cooling_off',
      );

      expect(item.isCoolingOff, isFalse);
      expect(item.isReady, isTrue);
      expect(item.daysRemaining, 0);
      expect(item.progress, 1.0);
    });

    test('cancelled item correctly reflects saved status and amount', () {
      final now = DateTime.now();
      final item = WishlistItem(
        id: 3,
        name: 'Sneakers Hype',
        estimatedPriceCents: 1800000,
        createdAt: now.subtract(const Duration(days: 30)),
        readyAt: now,
        status: 'cancelled',
        savedAmountCents: 1800000,
        decisionDate: now,
      );

      expect(item.isCancelled, isTrue);
      expect(item.isDecided, isTrue);
      expect(item.formattedSaved, contains('1.800.000'));
    });
  });

  group('WishlistSummary Tests', () {
    test('formats total saved properly', () {
      const summary = WishlistSummary(
        totalSavedCents: 4500000,
        coolingCount: 3,
        readyCount: 1,
        totalCount: 5,
      );

      expect(summary.totalSavedCents, 4500000);
      expect(summary.coolingCount, 3);
      expect(summary.readyCount, 1);
      expect(summary.formattedTotalSaved, contains('4.500.000'));
    });
  });
}
