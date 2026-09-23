import '../../../core/utils/formatters.dart';

/// Domain entity representing a single recorded payment towards an
/// installment plan. [transactionId] is set when the payment also created a
/// real Transaction row (wallet + category were both linked at pay time).
class InstallmentPayment {
  const InstallmentPayment({
    required this.id,
    required this.installmentId,
    required this.amountCents,
    required this.paymentDate,
    this.transactionId,
    this.note,
    required this.createdAt,
  });

  final int id;
  final int installmentId;
  final int amountCents;
  final DateTime paymentDate;
  final int? transactionId;
  final String? note;
  final DateTime createdAt;

  bool get isLinkedToTransaction => transactionId != null;

  String get formattedAmount => formatRupiah(amountCents);
  String get formattedPaymentDate => formatDate(paymentDate);
}
