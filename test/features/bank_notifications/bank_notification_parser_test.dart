import 'package:flutter_test/flutter_test.dart';
import 'package:pencatatan_keuangan/features/bank_notifications/domain/bank_notification_parser.dart';
import 'package:pencatatan_keuangan/features/bank_notifications/domain/known_bank_apps.dart';

void main() {
  group('BankNotificationParser', () {
    test('parses standard rupiah formats correctly', () {
      expect(parseAmountCents('Rp 50.000'), 50000);
      expect(parseAmountCents('Rp50.000'), 50000);
      expect(parseAmountCents('Rp. 50.000'), 50000);
      expect(parseAmountCents('Rp 1.500.000'), 1500000);
    });

    test('parses case-insensitive and IDR currency formats', () {
      expect(parseAmountCents('RP 50.000'), 50000);
      expect(parseAmountCents('rp 50.000'), 50000);
      expect(parseAmountCents('IDR 50.000'), 50000);
      expect(parseAmountCents('idr 100,000'), 100000);
    });

    test('strips trailing decimal cents (,00 and .00) accurately', () {
      expect(parseAmountCents('Rp 50.000,00'), 50000);
      expect(parseAmountCents('Rp. 150.000,00'), 150000);
      expect(parseAmountCents('RP 2.500.000,00'), 2500000);
      expect(parseAmountCents('IDR 75,000.00'), 75000);
      expect(parseAmountCents('Rp 10.000,50'), 10000);
    });

    test('parses fallback format with sebesar/nominal/jumlah', () {
      expect(parseAmountCents('Transfer sebesar 50.000 berhasil'), 50000);
      expect(parseAmountCents('Nominal: 75.000 telah didebet'), 75000);
    });

    test('handles BCA mobile notification text accurately', () {
      const text =
          'm-Transfer: BERHASIL ke 1234567890 sebesar Rp 50.000,00 pada 09/10';
      expect(parseAmountCents(text), 50000);
      expect(detectDirection(text), 'expense');
    });

    test('handles blu by BCA Digital notification text accurately', () {
      const expenseText =
          'Transfer berhasil! Kamu telah mengirimkan Rp50.000 ke Budi Santoso';
      expect(parseAmountCents(expenseText), 50000);
      expect(detectDirection(expenseText), 'expense');

      const incomeText =
          'Hore! Ada transfer masuk sebesar Rp 100.000 dari Sdr Andi';
      expect(parseAmountCents(incomeText), 100000);
      expect(detectDirection(incomeText), 'income');
    });

    test('handles myBCA notification text accurately', () {
      const text = 'Transfer ke Rekening 888888 sebesar Rp 100.000 berhasil';
      expect(parseAmountCents(text), 100000);
      expect(detectDirection(text), 'expense');
    });

    test('handles QRIS payments accurately', () {
      const text =
          'Transaksi QRIS berhasil! Pembayaran sebesar Rp 25.000 di Kopi Kenangan';
      expect(parseAmountCents(text), 25000);
      expect(detectDirection(text), 'expense');
    });

    test('handles BCA debit and credit mutation text accurately', () {
      const debitText =
          'Transaksi Debit Rekening 123456 Sebesar Rp. 1.250.000,00 Berhasil';
      expect(parseAmountCents(debitText), 1250000);
      expect(detectDirection(debitText), 'expense');

      const creditText =
          'Transaksi Kredit Rekening 123456 Sebesar Rp. 5.000.000,00 Berhasil';
      expect(parseAmountCents(creditText), 5000000);
      expect(detectDirection(creditText), 'income');
    });
  });

  group('KnownBankApps & Aliases', () {
    test('resolves legacy package names to verified Play Store packages', () {
      expect(
        canonicalBankPackage('com.bcadigital.blu'),
        'id.co.bcadigital.blu',
      );
      expect(
        canonicalBankPackage('com.bca.mybca.omni.android'),
        'com.bca.mybca',
      );
      expect(canonicalBankPackage('com.bca'), 'com.bca');
      expect(
        canonicalBankPackage('id.co.bcadigital.blu'),
        'id.co.bcadigital.blu',
      );
    });

    test('knownBankApps contains correct package names for BCA ecosystem', () {
      final bcaMobile = knownBankApps.firstWhere(
        (app) => app.label == 'BCA mobile',
      );
      expect(bcaMobile.packageName, 'com.bca');

      final myBca = knownBankApps.firstWhere((app) => app.label == 'myBCA');
      expect(myBca.packageName, 'com.bca.mybca');

      final blu = knownBankApps.firstWhere(
        (app) => app.label == 'blu by BCA Digital',
      );
      expect(blu.packageName, 'id.co.bcadigital.blu');
    });
  });
}
