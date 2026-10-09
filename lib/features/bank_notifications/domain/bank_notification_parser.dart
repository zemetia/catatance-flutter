/// Pure, side-effect-free heuristics for turning a bank/e-wallet
/// notification's text into a nominal amount + transaction direction guess.
/// Every bank formats its notifications differently, so this is a best
/// effort — callers must always let the user confirm/correct the result
/// before it becomes a real transaction (see `CapturedBankNotification`).
library;

final _primaryAmountPattern = RegExp(
  r'(?:Rp\.?|IDR)\s*[\d][\d.,]*',
  caseSensitive: false,
);

final _fallbackAmountPattern = RegExp(
  r'(?:sebesar|nominal|jumlah)\s*:?\s*(?:Rp\.?|IDR)?\s*[\d][\d.,]*',
  caseSensitive: false,
);

/// Rupiah has no everyday subunit, so the parsed amount is stored as a
/// whole-Rupiah integer — matching how every other amount in this app is
/// stored (see `formatters.dart`).
int? parseAmountCents(String text) {
  var match = _primaryAmountPattern.firstMatch(text);
  match ??= _fallbackAmountPattern.firstMatch(text);
  if (match == null) return null;

  var raw = match.group(0)!;
  // If the amount ends with decimal cents like ,00 or .00 (e.g. "Rp 50.000,00"),
  // strip the trailing two zero digits and separator so 50.000 doesn't turn into 5.000.000.
  raw = raw.replaceAll(RegExp(r'[,.]\d{2}$'), '');

  final digits = raw.replaceAll(RegExp(r'[^\d]'), '');
  if (digits.isEmpty) return null;

  return int.tryParse(digits);
}

const _incomeKeywords = [
  'transfer masuk',
  'dana masuk',
  'uang masuk',
  'menerima',
  'diterima',
  'penerimaan',
  'kredit',
  'top up berhasil',
  'saldo bertambah',
  'transfer dari',
  'm-transfer dari',
  'menerima transfer',
  'terima transfer',
  'terima uang',
  'setoran',
  'setor tunai',
  'cashback',
  'pengembalian dana',
  'refund',
  'ada transfer masuk',
  'masuk ke rekening',
];

const _expenseKeywords = [
  'transfer keluar',
  'transfer ke',
  'transfer berhasil',
  'm-transfer ke',
  'm-transfer berhasil',
  'm-transfer',
  'mengirimkan',
  'kirim uang',
  'kirim ke',
  'kirim saldo',
  'pembayaran',
  'pembelian',
  'debit',
  'penarikan',
  'tarik tunai',
  'transaksi qris',
  'qris berhasil',
  'qris',
  'bayar',
  'belanja',
  'berhasil bayar',
  'berhasil transfer',
  'telah dibayar',
  'pemotongan',
  'autodebet',
  'tagihan',
  'blupay',
  'checkout',
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

