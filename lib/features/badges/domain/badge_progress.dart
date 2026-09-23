import '../../../core/utils/formatters.dart';
import 'badge_definition.dart';
import 'badge_metric_type.dart';

/// A [BadgeDefinition] combined with the user's live progress towards it.
class BadgeProgress {
  const BadgeProgress({
    required this.definition,
    required this.currentValue,
    required this.isUnlocked,
    this.unlockedAt,
  });

  final BadgeDefinition definition;

  /// Raw current value in the same unit as [BadgeDefinition.target].
  final int currentValue;

  /// True once earned — sticky, backed by an `EarnedBadges` row, so it
  /// stays true even if [currentValue] later dips back below the target.
  final bool isUnlocked;

  final DateTime? unlockedAt;

  double get progressRatio {
    if (definition.target <= 0) return 1;
    return (currentValue / definition.target).clamp(0, 1).toDouble();
  }

  int get progressPercent => (progressRatio * 100).round();

  /// Short "12/50 transaksi" / "68% tercapai" style label matching the
  /// badge's [BadgeMetricType].
  String get valueLabel => switch (definition.metricType) {
        BadgeMetricType.count =>
          '$currentValue/${definition.target} ${_countUnitFor(definition.key)}',
        BadgeMetricType.percentage =>
          '${currentValue.clamp(0, 999)}% dari target ${definition.target}%',
        BadgeMetricType.streak =>
          '$currentValue/${definition.target} hari beruntun',
        BadgeMetricType.amount =>
          '${formatRupiahCompact(currentValue)} / ${formatRupiahCompact(definition.target)}',
      };

  static String _countUnitFor(String key) {
    if (key.startsWith('transactions') || key == 'first_transaction') {
      return 'transaksi';
    }
    if (key.startsWith('categories')) return 'kategori';
    if (key.startsWith('wallets')) return 'dompet';
    if (key.startsWith('transfers')) return 'transfer';
    if (key.startsWith('goal_completed')) return 'target';
    if (key == 'goal_first') return 'target';
    if (key == 'budget_first') return 'anggaran';
    if (key == 'debt_paid_1') return 'utang';
    if (key == 'receivable_paid_1') return 'piutang';
    if (key == 'installment_completed_1') return 'cicilan';
    return '';
  }
}
