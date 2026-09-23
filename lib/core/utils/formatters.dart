import 'package:intl/intl.dart';

import '../constants/currencies.dart';

/// Formats any monetary amount according to the given [Currency] (defaults to IDR).
String formatCurrency(int amount, {Currency currency = defaultCurrency}) {
  if (currency.code == 'IDR') return formatRupiah(amount);

  final formatter = NumberFormat.currency(
    symbol: '${currency.symbol} ',
    decimalDigits: currency.decimalDigits,
  );
  return formatter.format(amount);
}

/// Formats an integer amount for display in input fields and transaction summaries
/// according to [Currency]. Uses 0 decimal digits so users can input and view
/// integer amounts cleanly without intrusive decimals.
/// e.g. IDR 50000 -> `Rp 50.000`, USD 50 -> `$ 50`, EUR 100 -> `€ 100`.
String formatCurrencyInput(int amount, {Currency currency = defaultCurrency}) {
  if (currency.code == 'IDR') return formatRupiah(amount);

  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: '${currency.symbol} ',
    decimalDigits: 0,
  );
  return formatter.format(amount);
}

/// Compact currency formatting for tight spaces (chart labels, wallet tiles):
/// e.g. IDR 13500000 -> `Rp13,5jt`, USD 1500 -> `$1.5k`.
String formatCurrencyCompact(int amount, {Currency currency = defaultCurrency}) {
  if (currency.code == 'IDR') return formatRupiahCompact(amount);

  final magnitude = amount.abs();
  final sign = amount < 0 ? '-' : '';
  final sym = currency.symbol;

  if (magnitude >= 1000000000) {
    return '$sym$sign${_trimmed(magnitude / 1000000000)}B';
  }
  if (magnitude >= 1000000) {
    return '$sym$sign${_trimmed(magnitude / 1000000)}M';
  }
  if (magnitude >= 1000) {
    return '$sym$sign${_trimmed(magnitude / 1000)}k';
  }
  return formatCurrency(amount, currency: currency);
}

/// All monetary amounts are stored as whole-Rupiah integers.
/// Format only at the presentation edge — never do arithmetic on the
/// formatted string this returns.
String formatRupiah(int amount) {
  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  return formatter.format(amount);
}

/// Compact Rupiah formatting for tight spaces (chart labels, stat tiles):
/// `523000` → `Rp523rb`, `13500000` → `Rp13,5jt`. Never use for arithmetic.
String formatRupiahCompact(int amount) {
  final magnitude = amount.abs();
  final sign = amount < 0 ? '-' : '';

  if (magnitude >= 1000000000) {
    return 'Rp$sign${_trimmed(magnitude / 1000000000)}M';
  }
  if (magnitude >= 1000000) {
    return 'Rp$sign${_trimmed(magnitude / 1000000)}jt';
  }
  if (magnitude >= 1000) {
    return 'Rp$sign${_trimmed(magnitude / 1000)}rb';
  }
  return formatRupiah(amount);
}

String _trimmed(double value) => NumberFormat('#,##0.#', 'id_ID').format(value);

String formatDate(DateTime date) {
  return DateFormat('d MMMM y', 'id_ID').format(date);
}

String formatDateShort(DateTime date) {
  return DateFormat('d MMM', 'id_ID').format(date);
}

/// Time-of-day greeting in Indonesian, e.g. for a dashboard header.
String greetingForNow([DateTime? now]) {
  final hour = (now ?? DateTime.now()).hour;
  if (hour < 10) return 'Selamat pagi';
  if (hour < 15) return 'Selamat siang';
  if (hour < 18) return 'Selamat sore';
  return 'Selamat malam';
}
