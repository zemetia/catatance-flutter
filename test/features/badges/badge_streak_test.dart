import 'package:flutter_test/flutter_test.dart';
import 'package:pencatatan_keuangan/features/badges/domain/badge_streak.dart';

void main() {
  test('empty activity has no streak', () {
    expect(computeStreakDays(const [], DateTime(2026, 1, 10)), equals(0));
  });

  test('counts consecutive days ending today', () {
    final now = DateTime(2026, 1, 10);
    final dates = [
      DateTime(2026, 1, 10),
      DateTime(2026, 1, 9),
      DateTime(2026, 1, 8),
    ];
    expect(computeStreakDays(dates, now), equals(3));
  });

  test('still counts a streak ending yesterday (grace before today logs)', () {
    final now = DateTime(2026, 1, 10);
    final dates = [DateTime(2026, 1, 9), DateTime(2026, 1, 8)];
    expect(computeStreakDays(dates, now), equals(2));
  });

  test('a gap two days ago breaks the streak', () {
    final now = DateTime(2026, 1, 10);
    final dates = [DateTime(2026, 1, 10), DateTime(2026, 1, 7)];
    expect(computeStreakDays(dates, now), equals(1));
  });
}
