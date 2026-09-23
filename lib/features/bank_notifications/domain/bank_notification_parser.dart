/// Pure, side-effect-free heuristics for turning a bank/e-wallet
/// notification's text into a nominal amount + transaction direction guess.
/// Every bank formats its notifications differently, so this is a best
/// effort — callers must always let the user confirm/correct the result
/// before it becomes a real transaction (see `CapturedBankNotification`).
library;

final _amountPattern = RegExp(r'Rp\.?\s?[\d][\d.,]*');

/// Rupiah has no everyday subunit, so the parsed amount is stored as a
/// whole-Rupiah integer — matching how every other amount in this app is
/// stored (see `formatters.dart`).
int? parseAmountCents(String text) {
  final match = _amountPattern.firstMatch(text);
  if (match == null) return null;

  final digits = match.group(0)!.replaceAll(RegExp(r'[^\d]'), '');
  if (digits.isEmpty) return null;

  return int.tryParse(digits);
}

const _incomeKeywords = [
  'menerima',
  'diterima',
  'penerimaan',
  'transfer masuk',
  'dana masuk',
  'uang masuk',
  'kredit',
  'top up berhasil',
  'saldo bertambah',
];

const _expenseKeywords = [
  'pembayaran',
  'pembelian',
  'debit',
  'transfer keluar',
  'penarikan',
  'tarik tunai',
  'transaksi qris',
  'bayar',
  'belanja',
];

/// Returns `'income'`, `'expense'`, or `null` when no keyword matched —
/// callers should treat `null` as "needs manual correction".
String? detectDirection(String text) {
  final lower = text.toLowerCase();

  for (final keyword in _incomeKeywords) {
    if (lower.contains(keyword)) return 'income';
  }
  for (final keyword in _expenseKeywords) {
    if (lower.contains(keyword)) return 'expense';
  }
  return null;
}
