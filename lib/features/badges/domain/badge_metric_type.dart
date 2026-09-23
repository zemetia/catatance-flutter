/// How a badge's `currentValue`/`targetValue` pair should be read and
/// displayed — same two numbers, different meaning per type.
enum BadgeMetricType {
  /// A running tally that only ever grows (e.g. total transactions).
  count,

  /// A relative share, stored as whole percent (0-100) of some ratio
  /// (e.g. how far into a savings goal, or the month's savings rate).
  percentage,

  /// Consecutive days of activity, reset by any gap.
  streak,

  /// A money amount in cents, compared against a target amount.
  amount,
}
