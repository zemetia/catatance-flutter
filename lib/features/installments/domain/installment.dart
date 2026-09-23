import '../../../core/utils/formatters.dart';
import 'installment_status.dart';

/// Adds [months] to [date], clamping the day to the target month's last day
/// (e.g. 31 Jan + 1 month -> 28/29 Feb, not an overflowed early-March date).
DateTime addMonthsClamped(DateTime date, int months) {
  final totalMonths = date.month - 1 + months;
  final year = date.year + totalMonths ~/ 12;
  final month = totalMonths % 12 + 1;
  final daysInMonth = DateTime(year, month + 1, 0).day;
  final day = date.day > daysInMonth ? daysInMonth : date.day;
  return DateTime(year, month, day);
}

/// Domain entity representing a Cicilan (installment plan): a fixed monthly
/// amount paid over a fixed number of months, optionally linked to a wallet
/// and category so each payment also lands as a real transaction.
class Installment {
  const Installment({
    required this.id,
    required this.name,
    required this.totalAmountCents,
    required this.tenorMonths,
    required this.installmentAmountCents,
    this.paidInstallments = 0,
    this.paidAmountCents = 0,
    required this.startDate,
    this.accountId,
    this.categoryId,
    this.note,
    this.status = InstallmentStatus.active,
    required this.createdAt,
  });

  final int id;
  final String name;
  final int totalAmountCents;
  final int tenorMonths;
  final int installmentAmountCents;
  final int paidInstallments;
  final int paidAmountCents;
  final DateTime startDate;
  final int? accountId;
  final int? categoryId;
  final String? note;
  final InstallmentStatus status;
  final DateTime createdAt;

  bool get isCompleted =>
      status == InstallmentStatus.completed ||
      paidAmountCents >= totalAmountCents;

  int get remainingInstallments {
    final rem = tenorMonths - paidInstallments;
    return rem < 0 ? 0 : rem;
  }

  int get remainingAmountCents {
    final rem = totalAmountCents - paidAmountCents;
    return rem < 0 ? 0 : rem;
  }

  /// Progress by amount actually paid, not installment count — stays
  /// accurate even if a payment differs from the fixed monthly amount.
  double get progress {
    if (totalAmountCents <= 0) return 1.0;
    return (paidAmountCents / totalAmountCents).clamp(0.0, 1.0);
  }

  String get progressPercentage => '${(progress * 100).toInt()}%';

  /// The next unpaid installment's due date, or null once completed.
  DateTime? get nextDueDate {
    if (isCompleted) return null;
    return addMonthsClamped(startDate, paidInstallments);
  }

  bool isOverdueAt(DateTime reference) {
    if (isCompleted) return false;
    final due = nextDueDate;
    if (due == null) return false;
    final dueDay = DateTime(due.year, due.month, due.day);
    final refDay = DateTime(reference.year, reference.month, reference.day);
    return refDay.isAfter(dueDay);
  }

  bool get isOverdue => isOverdueAt(DateTime.now());

  int? daysUntilDueAt(DateTime reference) {
    final due = nextDueDate;
    if (due == null) return null;
    final dueDay = DateTime(due.year, due.month, due.day);
    final refDay = DateTime(reference.year, reference.month, reference.day);
    return dueDay.difference(refDay).inDays;
  }

  int? get daysUntilDue => daysUntilDueAt(DateTime.now());

  String dueStatusLabelAt(DateTime reference) {
    if (isCompleted) return 'Lunas';
    final days = daysUntilDueAt(reference);
    if (days == null) return 'Tanpa jadwal';
    if (days < 0) return 'Lewat tempo ${days.abs()} hari';
    if (days == 0) return 'Jatuh tempo hari ini';
    if (days == 1) return 'Jatuh tempo besok';
    return 'Jatuh tempo $days hari lagi';
  }

  String get dueStatusLabel => dueStatusLabelAt(DateTime.now());

  String get formattedTotalAmount => formatRupiah(totalAmountCents);
  String get formattedInstallmentAmount => formatRupiah(installmentAmountCents);
  String get formattedPaidAmount => formatRupiah(paidAmountCents);
  String get formattedRemainingAmount => formatRupiah(remainingAmountCents);
  String get formattedStartDate => formatDate(startDate);
  String get formattedNextDueDate =>
      nextDueDate != null ? formatDate(nextDueDate!) : 'Lunas';

  Installment copyWith({
    int? id,
    String? name,
    int? totalAmountCents,
    int? tenorMonths,
    int? installmentAmountCents,
    int? paidInstallments,
    int? paidAmountCents,
    DateTime? startDate,
    int? accountId,
    int? categoryId,
    String? note,
    InstallmentStatus? status,
    DateTime? createdAt,
  }) {
    return Installment(
      id: id ?? this.id,
      name: name ?? this.name,
      totalAmountCents: totalAmountCents ?? this.totalAmountCents,
      tenorMonths: tenorMonths ?? this.tenorMonths,
      installmentAmountCents:
          installmentAmountCents ?? this.installmentAmountCents,
      paidInstallments: paidInstallments ?? this.paidInstallments,
      paidAmountCents: paidAmountCents ?? this.paidAmountCents,
      startDate: startDate ?? this.startDate,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      note: note ?? this.note,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
