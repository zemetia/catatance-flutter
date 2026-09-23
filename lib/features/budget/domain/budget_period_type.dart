/// How a budget's active period repeats/is defined.
enum BudgetPeriodType {
  monthly,
  weekly,
  custom;

  static BudgetPeriodType fromRaw(String raw) => switch (raw) {
    'weekly' => BudgetPeriodType.weekly,
    'custom' => BudgetPeriodType.custom,
    _ => BudgetPeriodType.monthly,
  };

  String get raw => switch (this) {
    BudgetPeriodType.monthly => 'monthly',
    BudgetPeriodType.weekly => 'weekly',
    BudgetPeriodType.custom => 'custom',
  };

  String get label => switch (this) {
    BudgetPeriodType.monthly => 'Bulanan',
    BudgetPeriodType.weekly => 'Mingguan',
    BudgetPeriodType.custom => 'Custom',
  };
}

/// A resolved `[start, endExclusive)` date range for one budget period.
class BudgetPeriod {
  const BudgetPeriod({required this.start, required this.endExclusive});

  final DateTime start;
  final DateTime endExclusive;

  /// Last calendar day actually included in the period (inclusive).
  DateTime get lastIncludedDay => endExclusive.subtract(const Duration(days: 1));

  int daysLeftFrom(DateTime reference) {
    final today = DateTime(reference.year, reference.month, reference.day);
    final end = DateTime(endExclusive.year, endExclusive.month, endExclusive.day);
    return end.difference(today).inDays.clamp(0, 366);
  }
}

/// Resolves the period containing [reference] for a recurring [type]
/// (weeks start Monday). For [BudgetPeriodType.custom], the stored
/// [customStart]/[customEndInclusive] are used verbatim.
BudgetPeriod resolveBudgetPeriod(
  BudgetPeriodType type,
  DateTime reference, {
  DateTime? customStart,
  DateTime? customEndInclusive,
}) {
  final today = DateTime(reference.year, reference.month, reference.day);
  switch (type) {
    case BudgetPeriodType.monthly:
      final start = DateTime(today.year, today.month, 1);
      final end = DateTime(today.year, today.month + 1, 1);
      return BudgetPeriod(start: start, endExclusive: end);
    case BudgetPeriodType.weekly:
      final start = today.subtract(Duration(days: today.weekday - 1));
      final end = start.add(const Duration(days: 7));
      return BudgetPeriod(start: start, endExclusive: end);
    case BudgetPeriodType.custom:
      final start = customStart != null
          ? DateTime(customStart.year, customStart.month, customStart.day)
          : today;
      final endInclusive = customEndInclusive != null
          ? DateTime(
              customEndInclusive.year,
              customEndInclusive.month,
              customEndInclusive.day,
            )
          : start;
      return BudgetPeriod(
        start: start,
        endExclusive: endInclusive.add(const Duration(days: 1)),
      );
  }
}

/// The recurring period immediately preceding the one containing
/// [reference]. Not meaningful for [BudgetPeriodType.custom] (returns null)
/// since a custom range has no natural predecessor.
BudgetPeriod? resolvePreviousBudgetPeriod(
  BudgetPeriodType type,
  DateTime reference,
) {
  switch (type) {
    case BudgetPeriodType.monthly:
      final current = resolveBudgetPeriod(type, reference);
      final prevStart = DateTime(current.start.year, current.start.month - 1, 1);
      return BudgetPeriod(start: prevStart, endExclusive: current.start);
    case BudgetPeriodType.weekly:
      final current = resolveBudgetPeriod(type, reference);
      final prevStart = current.start.subtract(const Duration(days: 7));
      return BudgetPeriod(start: prevStart, endExclusive: current.start);
    case BudgetPeriodType.custom:
      return null;
  }
}
