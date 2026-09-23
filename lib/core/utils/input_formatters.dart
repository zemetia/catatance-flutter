import 'package:flutter/services.dart';

import '../constants/currencies.dart';
import 'formatters.dart';

/// Formats a numeric `TextField`'s raw digits into a live `Rp 1.234.567` (or
/// `$ 1,234`, `€ 1.234`, ...) display as the user types — shared by any
/// nominal-entry field that wants the system's native numeric keyboard
/// instead of a custom keypad widget. Defaults to Rupiah when no [currency]
/// is given.
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  ThousandsSeparatorInputFormatter({this.currency = defaultCurrency});

  final Currency currency;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      final text = formatCurrencyInput(0, currency: currency);
      return TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }

    final digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty || digits == '0') {
      final text = formatCurrencyInput(0, currency: currency);
      return TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }

    final capped = digits.length > 12 ? digits.substring(0, 12) : digits;
    final number = int.tryParse(capped) ?? 0;
    final formatted = formatCurrencyInput(number, currency: currency);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
