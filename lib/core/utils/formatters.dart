import 'package:intl/intl.dart';

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
