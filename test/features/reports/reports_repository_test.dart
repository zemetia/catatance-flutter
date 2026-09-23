import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pencatatan_keuangan/core/database/app_database.dart';
import 'package:pencatatan_keuangan/features/reports/data/reports_repository.dart';
import 'package:pencatatan_keuangan/features/reports/domain/report_models.dart';

void main() {
  late AppDatabase db;
  late ReportsRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = ReportsRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('ReportsRepository calculates net worth with seeded data', () async {
    final netWorth = await repository.watchNetWorth().first;
    expect(netWorth, greaterThan(0));
  });

  test('ReportsRepository returns daily spending for current week', () async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
    final endExclusive = DateTime(now.year, now.month, now.day + 1);

    final daily = await repository.watchDailyExpense(start, endExclusive).first;
    expect(daily, isNotEmpty);
  });

  test('ReportsRepository returns category breakdown for current month', () async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month);
    final endExclusive = DateTime(now.year, now.month + 1);

    final breakdown = await repository.watchCategoryBreakdown(start, endExclusive).first;
    expect(breakdown, isNotEmpty);
    expect(breakdown.first.totalCents, greaterThan(0));
  });

  test('ReportsRepository returns monthly trend across 5 months', () async {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);

    final trend = await repository.watchMonthlyTrend(currentMonth, monthsCount: 5).first;
    expect(trend.length, equals(5));
    expect(trend.any((m) => m.totalCents > 0), isTrue);
  });

  test('ReportsRepository returns income totals and breakdown for current month', () async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month);
    final endExclusive = DateTime(now.year, now.month + 1);

    final total = await repository
        .watchTotal(start, endExclusive, mode: ReportMode.income)
        .first;
    expect(total, greaterThan(0));

    final breakdown = await repository
        .watchCategoryBreakdown(start, endExclusive, mode: ReportMode.income)
        .first;
    expect(breakdown, isNotEmpty);
    expect(breakdown.first.totalCents, greaterThan(0));
  });

  test('ReportsRepository net total equals income minus expense for current month', () async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month);
    final endExclusive = DateTime(now.year, now.month + 1);

    final expense = await repository.watchTotalExpense(start, endExclusive).first;
    final income = await repository.watchTotalIncome(start, endExclusive).first;
    final net = await repository
        .watchTotal(start, endExclusive, mode: ReportMode.net)
        .first;

    expect(net, equals(income - expense));
  });

  test('ReportsRepository net category breakdown carries signed totals', () async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month);
    final endExclusive = DateTime(now.year, now.month + 1);

    final breakdown = await repository
        .watchCategoryBreakdown(start, endExclusive, mode: ReportMode.net)
        .first;
    expect(breakdown, isNotEmpty);
    expect(breakdown.any((c) => c.totalCents < 0), isTrue);
    expect(breakdown.any((c) => c.totalCents > 0), isTrue);
    for (final entry in breakdown) {
      expect(entry.share, greaterThanOrEqualTo(0));
      expect(entry.share, lessThanOrEqualTo(1));
    }
  });
}
