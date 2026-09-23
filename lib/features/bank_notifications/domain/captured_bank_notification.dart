import '../../../core/utils/formatters.dart';

enum CapturedNotificationStatus {
  pending,
  confirmed,
  dismissed;

  static CapturedNotificationStatus fromRaw(String raw) => switch (raw) {
    'confirmed' => CapturedNotificationStatus.confirmed,
    'dismissed' => CapturedNotificationStatus.dismissed,
    _ => CapturedNotificationStatus.pending,
  };

  String get raw => switch (this) {
    CapturedNotificationStatus.pending => 'pending',
    CapturedNotificationStatus.confirmed => 'confirmed',
    CapturedNotificationStatus.dismissed => 'dismissed',
  };
}

/// A raw notification captured from a mapped app, with its parsed
/// nominal/direction guess, awaiting user confirmation into a real
/// transaction.
class CapturedBankNotification {
  const CapturedBankNotification({
    required this.id,
    required this.packageName,
    required this.appLabel,
    this.title,
    required this.content,
    this.parsedAmountCents,
    this.direction,
    this.accountId,
    this.status = CapturedNotificationStatus.pending,
    this.transactionId,
    required this.postedAt,
    required this.createdAt,
  });

  final int id;
  final String packageName;
  final String appLabel;
  final String? title;
  final String content;
  final int? parsedAmountCents;

  /// 'income' | 'expense' | null when direction couldn't be detected.
  final String? direction;
  final int? accountId;
  final CapturedNotificationStatus status;
  final int? transactionId;
  final DateTime postedAt;
  final DateTime createdAt;

  bool get isIncome => direction == 'income';
  bool get isExpense => direction == 'expense';

  /// Whether the auto-parse is confident enough to prefill a confirm form
  /// without the user having to fix anything.
  bool get needsCorrection =>
      parsedAmountCents == null || direction == null || accountId == null;

  String get formattedAmount =>
      parsedAmountCents != null ? formatRupiah(parsedAmountCents!) : '—';
}
