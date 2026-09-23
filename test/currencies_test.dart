import 'package:flutter_test/flutter_test.dart';
import 'package:pencatatan_keuangan/core/constants/currencies.dart';

void main() {
  group('Currency list & ISO 4217 database', () {
    test('contains a comprehensive list of world currencies', () {
      expect(currencies.length, greaterThanOrEqualTo(150));
    });

    test('IDR is default currency with correct flag and symbol', () {
      expect(defaultCurrency.code, 'IDR');
      expect(defaultCurrency.symbol, 'Rp');
      expect(defaultCurrency.flag, '🇮🇩');
      expect(defaultCurrency.countryCode, 'ID');
      expect(defaultCurrency.decimalDigits, 0);

      final found = Currency.maybeFromCode('idr');
      expect(found, isNotNull);
      expect(found?.code, 'IDR');
      expect(found?.symbol, 'Rp');
      expect(found?.flag, '🇮🇩');
    });

    test('all currencies have non-empty required fields and unique codes', () {
      final seenCodes = <String>{};
      for (final c in currencies) {
        expect(c.code.length, 3, reason: 'Invalid code length for ${c.code}');
        expect(c.code, c.code.toUpperCase(), reason: 'Code not uppercase: ${c.code}');
        expect(c.symbol.isNotEmpty, isTrue, reason: 'Empty symbol for ${c.code}');
        expect(c.flag.isNotEmpty, isTrue, reason: 'Empty flag for ${c.code}');
        expect(c.name.isNotEmpty, isTrue, reason: 'Empty name for ${c.code}');
        expect(c.countryCode.isNotEmpty, isTrue, reason: 'Empty countryCode for ${c.code}');
        expect(seenCodes.add(c.code), isTrue, reason: 'Duplicate code found: ${c.code}');
      }
    });

    test('searchCurrencies filters correctly by query', () {
      final results = searchCurrencies('rupiah');
      expect(results.any((c) => c.code == 'IDR'), isTrue);

      final dollarResults = searchCurrencies('USD');
      expect(dollarResults.any((c) => c.code == 'USD'), isTrue);
    });
  });
}
