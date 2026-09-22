import 'package:freezed_annotation/freezed_annotation.dart';

part 'report_models.freezed.dart';

/// Total expense for a single category within a date range, plus its share
/// of the range's overall expense total.
@freezed
abstract class CategorySpending with _$CategorySpending {
  const factory CategorySpending({
    required int categoryId,
    required String name,
    required String icon,
    required int colorValue,
    required int totalCents,
    required double share,
  }) = _CategorySpending;
}

/// Total expense for a single calendar day.
@freezed
abstract class DailySpending with _$DailySpending {
  const factory DailySpending({
    required DateTime date,
    required int totalCents,
  }) = _DailySpending;
}

/// Total expense for a single calendar month.
@freezed
abstract class MonthlySpending with _$MonthlySpending {
  const factory MonthlySpending({
    required DateTime month,
    required int totalCents,
  }) = _MonthlySpending;
}
