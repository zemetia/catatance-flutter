import '../../../core/utils/formatters.dart';
import 'debt_type.dart';

/// Domain entity representing an Utang (debt) or Piutang (receivable).
class Debt {
  const Debt({
    required this.id,
    required this.type,
    required this.personName,
    required this.amountCents,
    this.paidAmountCents = 0,
    this.dueDate,
    required this.transactionDate,
    this.status = DebtStatus.unpaid,
    this.note,
    this.accountId,
    required this.createdAt,
  });

  final int id;
  final DebtType type;
  final String personName;
  final int amountCents;
  final int paidAmountCents;
  final DateTime? dueDate;
  final DateTime transactionDate;
  final DebtStatus status;
  final String? note;
  final int? accountId;
  final DateTime createdAt;

  /// Remaining unpaid balance.
  int get remainingCents {
    final rem = amountCents - paidAmountCents;
    return rem < 0 ? 0 : rem;
  }

  /// Whether the debt has been fully settled.
  bool get isSettled => status == DebtStatus.paid || remainingCents == 0;

  /// Progress of repayments from 0.0 to 1.0.
  double get progress {
    if (amountCents <= 0) return 1.0;
    return (paidAmountCents / amountCents).clamp(0.0, 1.0);
  }

  /// Percentage string (e.g. `65%`).
  String get progressPercentage => '${(progress * 100).toInt()}%';

  /// Whether the payment deadline has passed and it is still unpaid.
  bool isOverdueAt(DateTime reference) {
    if (isSettled || dueDate == null) return false;
    final due = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    final ref = DateTime(reference.year, reference.month, reference.day);
    return ref.isAfter(due);
  }

  bool get isOverdue => isOverdueAt(DateTime.now());

  /// Number of days remaining until due date (negative if overdue).
  int? daysUntilDueAt(DateTime reference) {
    if (dueDate == null) return null;
    final due = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    final ref = DateTime(reference.year, reference.month, reference.day);
    return due.difference(ref).inDays;
  }

  int? get daysUntilDue => daysUntilDueAt(DateTime.now());

  /// Human-readable Indonesian due status badge label for a specific reference date.
  String dueStatusLabelAt(DateTime reference) {
    if (isSettled) return 'Lunas';
    if (dueDate == null) return 'Tanpa tempo';

    final days = daysUntilDueAt(reference);
    if (days == null) return 'Tanpa tempo';
    if (days < 0) return 'Lewat tempo ${days.abs()} hari';
    if (days == 0) return 'Jatuh tempo hari ini';
    if (days == 1) return 'Jatuh tempo besok';
    return 'Jatuh tempo $days hari lagi';
  }

  /// Human-readable Indonesian due status badge label at current time.
  String get dueStatusLabel => dueStatusLabelAt(DateTime.now());

  String get formattedAmount => formatRupiah(amountCents);
  String get formattedPaid => formatRupiah(paidAmountCents);
  String get formattedRemaining => formatRupiah(remainingCents);
  String get formattedTransactionDate => formatDate(transactionDate);
  String get formattedDueDate =>
      dueDate != null ? formatDate(dueDate!) : 'Tanpa tempo';

  Debt copyWith({
    int? id,
    DebtType? type,
    String? personName,
    int? amountCents,
    int? paidAmountCents,
    DateTime? dueDate,
    DateTime? transactionDate,
    DebtStatus? status,
    String? note,
    int? accountId,
    DateTime? createdAt,
  }) {
    return Debt(
      id: id ?? this.id,
      type: type ?? this.type,
      personName: personName ?? this.personName,
      amountCents: amountCents ?? this.amountCents,
      paidAmountCents: paidAmountCents ?? this.paidAmountCents,
      dueDate: dueDate ?? this.dueDate,
      transactionDate: transactionDate ?? this.transactionDate,
      status: status ?? this.status,
      note: note ?? this.note,
      accountId: accountId ?? this.accountId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
