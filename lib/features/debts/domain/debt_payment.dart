import '../../../core/utils/formatters.dart';

/// Domain entity representing a payment or installment recorded for a debt/receivable.
class DebtPayment {
  const DebtPayment({
    required this.id,
    required this.debtId,
    required this.amountCents,
    required this.paymentDate,
    this.note,
    this.accountId,
    this.transactionId,
    required this.createdAt,
  });

  final int id;
  final int debtId;
  final int amountCents;
  final DateTime paymentDate;
  final String? note;
  final int? accountId;
  final int? transactionId;
  final DateTime createdAt;

  String get formattedAmount => formatRupiah(amountCents);
  String get formattedPaymentDate => formatDate(paymentDate);
}
