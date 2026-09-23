import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

/// Fetches live currency-pair exchange rates from Yahoo Finance's public
/// chart API (the same data `yfinance` scrapes), used to convert a transfer
/// amount when the source and destination wallets use different currencies.
class ExchangeRateService {
  /// Returns how many units of [to] one unit of [from] is worth.
  ///
  /// e.g. `fetchRate('USD', 'IDR')` returns ~16000 (1 USD = ~16000 IDR).
  Future<double> fetchRate(String from, String to) async {
    if (from == to) return 1.0;

    final symbol = '$from$to=X';
    final uri = Uri.https('query1.finance.yahoo.com', '/v8/finance/chart/$symbol');

    final response = await http.get(
      uri,
      headers: const {'User-Agent': 'Mozilla/5.0'},
    );
    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil kurs $from/$to (${response.statusCode})');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final results = (body['chart'] as Map<String, dynamic>)['result'] as List?;
    if (results == null || results.isEmpty) {
      throw Exception('Kurs $from/$to tidak ditemukan');
    }

    final meta = (results.first as Map<String, dynamic>)['meta'] as Map<String, dynamic>;
    final price = meta['regularMarketPrice'] as num?;
    if (price == null) {
      throw Exception('Kurs $from/$to tidak tersedia');
    }
    return price.toDouble();
  }
}

final exchangeRateServiceProvider = Provider<ExchangeRateService>((ref) {
  return ExchangeRateService();
});

/// Live exchange rate for a `(fromCode, toCode)` currency pair.
/// Returns `1.0` immediately for a same-currency pair without a network call.
final exchangeRateProvider =
    FutureProvider.autoDispose.family<double, (String from, String to)>((
  ref,
  pair,
) {
  final (from, to) = pair;
  if (from == to) return Future.value(1.0);
  return ref.watch(exchangeRateServiceProvider).fetchRate(from, to);
});
