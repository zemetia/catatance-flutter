/// Values pre-filled on `AddTransactionScreen` when it is opened from another
/// screen (e.g. a day in "Kalender Cashflow"), passed as the route `extra`.
class AddTransactionPrefill {
  const AddTransactionPrefill({this.date, this.accountId});

  /// Day to record the transaction on (current time-of-day is kept).
  final DateTime? date;

  /// Wallet to pre-select; `null` falls back to the default wallet.
  final int? accountId;
}
