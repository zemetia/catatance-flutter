import 'package:flutter_test/flutter_test.dart';
import 'package:pencatatan_keuangan/core/constants/currencies.dart';

void main() {
  group('Currencies Data List', () {
    test('contains a comprehensive list of world currencies', () {
      expect(currencies.length, greaterThanOrEqualTo(150));
    });

    test('all currencies have unique codes', () {
      final codes = <String>{};
      for (final currency in currencies) {
        expect(codes.contains(currency.code), isFalse,
            reason: 'Duplicate currency code: ${currency.code}');
        codes.add(currency.code);
      }
    });

    test('all currencies have valid non-empty fields', () {
      for (final c in currencies) {
        expect(c.code.length, equals(3), reason: 'Code ${c.code} must be 3 letters');
        expect(c.code, equals(c.code.toUpperCase()));
        expect(c.symbol.isNotEmpty, isTrue, reason: 'Symbol for ${c.code} is empty');
        expect(c.symbolNative.isNotEmpty, isTrue, reason: 'Native symbol for ${c.code} is empty');
        expect(c.flag.isNotEmpty, isTrue, reason: 'Flag for ${c.code} is empty');
        expect(c.countryCode.length, equals(2), reason: 'CountryCode for ${c.code} must be 2 letters');
        expect(c.name.isNotEmpty, isTrue, reason: 'Name for ${c.code} is empty');
        expect(c.nameId.isNotEmpty, isTrue, reason: 'NameId for ${c.code} is empty');
        expect(c.decimalDigits, greaterThanOrEqualTo(0));
      }
    });

    test('verifies IDR details match Indonesian Rupiah', () {
      final idr = Currency.fromCode('IDR');
      expect(idr.code, equals('IDR'));
      expect(idr.symbol, equals('Rp'));
      expect(idr.flag, equals('🇮🇩'));
      expect(idr.countryCode, equals('ID'));
      expect(idr.decimalDigits, equals(0));
      expect(idr.nameId, equals('Rupiah Indonesia'));
    });

    test('verifies major currencies lookup', () {
      final usd = Currency.fromCode('usd'); // case-insensitive
      expect(usd.code, equals('USD'));
      expect(usd.symbol, equals(r'$'));
      expect(usd.flag, equals('🇺🇸'));

      final eur = Currency.fromCode('EUR');
      expect(eur.code, equals('EUR'));
      expect(eur.symbol, equals('€'));
      expect(eur.flag, equals('🇪🇺'));

      final jpy = Currency.fromCode('JPY');
      expect(jpy.code, equals('JPY'));
      expect(jpy.symbol, equals('¥'));
      expect(jpy.flag, equals('🇯🇵'));
      expect(jpy.decimalDigits, equals(0));
    });

    test('maybeFromCode returns null for unknown or null', () {
      expect(Currency.maybeFromCode(null), isNull);
      expect(Currency.maybeFromCode(''), isNull);
      expect(Currency.maybeFromCode('XYZ999'), isNull);
    });

    test('searchCurrencies finds by code, name, and symbol', () {
      final searchRupiah = searchCurrencies('rupiah');
      expect(searchRupiah.any((c) => c.code == 'IDR'), isTrue);

      final searchByCode = searchCurrencies('IDR');
      expect(searchByCode.any((c) => c.code == 'IDR'), isTrue);

      final searchBySymbol = searchCurrencies('Rp');
      expect(searchBySymbol.any((c) => c.code == 'IDR'), isTrue);
    });

    test('serialization toJson and fromJson roundtrip', () {
      final idr = Currency.fromCode('IDR');
      final json = idr.toJson();
      final reconstructed = Currency.fromJson(json);
      expect(reconstructed, equals(idr));
      expect(reconstructed.symbol, equals('Rp'));
      expect(reconstructed.flag, equals('🇮🇩'));
    });
  });
}
