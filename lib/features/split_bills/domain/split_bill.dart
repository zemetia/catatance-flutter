import '../../../core/utils/formatters.dart';

/// How a patungan's total is divided among participants.
enum SplitBillMode {
  equal,
  custom;

  String get label => switch (this) {
        SplitBillMode.equal => 'Bagi rata',
        SplitBillMode.custom => 'Beban berbeda-beda',
      };

  String get description => switch (this) {
        SplitBillMode.equal => 'Semua orang membayar nominal yang sama',
        SplitBillMode.custom => 'Tiap orang bisa membayar nominal berbeda',
      };
}

/// A named participant's share of a patungan, as entered on the form.
/// Not persisted as its own row — becomes a `receivable` `Debt` on save.
class SplitBillParticipant {
  const SplitBillParticipant({required this.name, required this.amountCents});

  final String name;
  final int amountCents;

  String get formattedAmount => formatRupiah(amountCents);
}

/// Domain entity for a patungan (group bill) event: the single expense
/// transaction the payer paid, and how it was divided between the payer
/// and named participants.
class SplitBill {
  const SplitBill({
    required this.id,
    required this.transactionId,
    required this.totalAmountCents,
    required this.payerIncluded,
    required this.payerShareCents,
    this.note,
    required this.date,
    required this.createdAt,
  });

  final int id;
  final int transactionId;
  final int totalAmountCents;
  final bool payerIncluded;
  final int payerShareCents;
  final String? note;
  final DateTime date;
  final DateTime createdAt;

  /// Total portion owed back to the payer by the other participants.
  int get totalReceivableCents => totalAmountCents - payerShareCents;

  String get formattedTotal => formatRupiah(totalAmountCents);
  String get formattedPayerShare => formatRupiah(payerShareCents);
  String get formattedReceivable => formatRupiah(totalReceivableCents);
}
