import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../domain/report_models.dart';
import 'reports_providers.dart';

/// The month currently shown on the "Kalender Cashflow" screen (day-of-month
/// ignored) — deliberately separate from [selectedReportMonthProvider] so
/// navigating this screen never disturbs the main Statistik screen's month.
final kalenderCashflowMonthProvider = StateProvider.autoDispose<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});

/// The day currently selected in the calendar grid, whose transactions show
/// in the detail list below it. Defaults to today.
final kalenderSelectedDateProvider = StateProvider.autoDispose<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

/// Wallet the calendar is filtered to, or `null` for all wallets. Also the
/// wallet pre-selected when adding a transaction from a calendar day.
final kalenderWalletFilterProvider =
    StateProvider.autoDispose<int?>((ref) => null);

final kalenderMonthCashflowProvider =
    StreamProvider.autoDispose<List<DailyCashflow>>((ref) {
  final month = ref.watch(kalenderCashflowMonthProvider);
  final start = DateTime(month.year, month.month);
  final endExclusive = DateTime(month.year, month.month + 1);
  final accountId = ref.watch(kalenderWalletFilterProvider);
  return ref
      .watch(reportsRepositoryProvider)
      .watchDailyCashflow(start, endExclusive, accountId: accountId);
});

final kalenderMonthIncomeProvider = StreamProvider.autoDispose<int>((ref) {
  final month = ref.watch(kalenderCashflowMonthProvider);
  final start = DateTime(month.year, month.month);
  final endExclusive = DateTime(month.year, month.month + 1);
  final accountId = ref.watch(kalenderWalletFilterProvider);
  return ref
      .watch(reportsRepositoryProvider)
      .watchTotalIncome(start, endExclusive, accountId: accountId);
});

final kalenderMonthExpenseProvider = StreamProvider.autoDispose<int>((ref) {
  final month = ref.watch(kalenderCashflowMonthProvider);
  final start = DateTime(month.year, month.month);
  final endExclusive = DateTime(month.year, month.month + 1);
  final accountId = ref.watch(kalenderWalletFilterProvider);
  return ref
      .watch(reportsRepositoryProvider)
      .watchTotalExpense(start, endExclusive, accountId: accountId);
});

final kalenderMonthNetProvider = StreamProvider.autoDispose<int>((ref) {
  final month = ref.watch(kalenderCashflowMonthProvider);
  final start = DateTime(month.year, month.month);
  final endExclusive = DateTime(month.year, month.month + 1);
  final accountId = ref.watch(kalenderWalletFilterProvider);
  return ref.watch(reportsRepositoryProvider).watchTotal(
        start,
        endExclusive,
        mode: ReportMode.net,
        accountId: accountId,
      );
});

final kalenderSelectedDateTransactionsProvider =
    StreamProvider.autoDispose<List<CashflowTransaction>>((ref) {
  final date = ref.watch(kalenderSelectedDateProvider);
  final accountId = ref.watch(kalenderWalletFilterProvider);
  return ref
      .watch(reportsRepositoryProvider)
      .watchTransactionsForDate(date, accountId: accountId);
});

typedef DailyCashflowSummary = ({int incomeCents, int expenseCents, int netCents});

/// Total income, expense, and net for the selected day in "Kalender Cashflow".
final kalenderSelectedDateSummaryProvider =
    Provider.autoDispose<DailyCashflowSummary>((ref) {
  final txAsync = ref.watch(kalenderSelectedDateTransactionsProvider);
  final items = txAsync.value ?? const [];
  var income = 0;
  var expense = 0;
  for (final item in items) {
    if (item.isTransfer) continue;
    if (item.isIncome) {
      income += item.amountCents;
    } else {
      expense += item.amountCents;
    }
  }
  return (
    incomeCents: income,
    expenseCents: expense,
    netCents: income - expense,
  );
});
