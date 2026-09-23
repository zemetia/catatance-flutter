import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pencatatan_keuangan/core/constants/currencies.dart';
import 'package:pencatatan_keuangan/core/utils/formatters.dart';
import 'package:pencatatan_keuangan/core/utils/input_formatters.dart';
import 'package:pencatatan_keuangan/features/transactions/presentation/add_transaction_screen.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  group('formatCurrencyInput unit tests', () {
    test('formats IDR amounts with Rp prefix and dots separator', () {
      expect(formatCurrencyInput(0), equals('Rp 0'));
      expect(formatCurrencyInput(50000), equals('Rp 50.000'));
      expect(formatCurrencyInput(12500000), equals('Rp 12.500.000'));
    });

    test('formats USD amounts with \$ prefix without forced cents', () {
      final usd = Currency.fromCode('USD');
      expect(formatCurrencyInput(0, currency: usd), equals(r'$ 0'));
      expect(formatCurrencyInput(50, currency: usd), equals(r'$ 50'));
      expect(formatCurrencyInput(1000, currency: usd), equals(r'$ 1.000'));
      expect(formatCurrencyInput(1500, currency: usd), equals(r'$ 1.500'));
    });

    test('formats EUR amounts with € prefix', () {
      final eur = Currency.fromCode('EUR');
      expect(formatCurrencyInput(0, currency: eur), equals('€ 0'));
      expect(formatCurrencyInput(100, currency: eur), equals('€ 100'));
      expect(formatCurrencyInput(2500, currency: eur), equals('€ 2.500'));
    });

    test('formats JPY and GBP amounts with their native symbols', () {
      final jpy = Currency.fromCode('JPY');
      expect(formatCurrencyInput(0, currency: jpy), equals('¥ 0'));
      expect(formatCurrencyInput(1000, currency: jpy), equals('¥ 1.000'));

      final gbp = Currency.fromCode('GBP');
      expect(formatCurrencyInput(50, currency: gbp), equals('£ 50'));
    });
  });

  group('ThousandsSeparatorInputFormatter with currency', () {
    test('defaults to IDR and formats appropriately', () {
      final formatter = ThousandsSeparatorInputFormatter();
      const oldValue = TextEditingValue(text: 'Rp 0');
      const newValue = TextEditingValue(text: 'Rp 05');

      final result = formatter.formatEditUpdate(oldValue, newValue);
      expect(result.text, equals('Rp 5'));
    });

    test('formats with USD currency', () {
      final usd = Currency.fromCode('USD');
      final formatter = ThousandsSeparatorInputFormatter(currency: usd);

      // Empty input -> $ 0
      final emptyResult = formatter.formatEditUpdate(
        const TextEditingValue(text: r'$ 5'),
        const TextEditingValue(text: ''),
      );
      expect(emptyResult.text, equals(r'$ 0'));

      // 0 input -> $ 0
      final zeroResult = formatter.formatEditUpdate(
        const TextEditingValue(text: r'$ 0'),
        const TextEditingValue(text: r'$ 00'),
      );
      expect(zeroResult.text, equals(r'$ 0'));

      // Typing 50 -> $ 50
      final fiftyResult = formatter.formatEditUpdate(
        const TextEditingValue(text: r'$ 5'),
        const TextEditingValue(text: r'$ 50'),
      );
      expect(fiftyResult.text, equals(r'$ 50'));

      // Typing 1000 -> $ 1.000
      final thousandResult = formatter.formatEditUpdate(
        const TextEditingValue(text: r'$ 100'),
        const TextEditingValue(text: r'$ 1000'),
      );
      expect(thousandResult.text, equals(r'$ 1.000'));
    });

    test('formats with EUR currency', () {
      final eur = Currency.fromCode('EUR');
      final formatter = ThousandsSeparatorInputFormatter(currency: eur);

      final result = formatter.formatEditUpdate(
        const TextEditingValue(text: '€ 0'),
        const TextEditingValue(text: '€ 075'),
      );
      expect(result.text, equals('€ 75'));
    });
  });
}
