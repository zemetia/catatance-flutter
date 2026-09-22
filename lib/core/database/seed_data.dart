import 'package:drift/drift.dart';

import 'app_database.dart';

/// Populates SQLite database with realistic Indonesian personal finance data
/// including Accounts (BCA, Mandiri, GoPay, Tunai), Categories (Income & Expense),
/// and historical Transactions across multiple months.
Future<void> seedInitialData(AppDatabase db) async {
  await db.transaction(() async {
    // 1. Accounts
    final bcaId = await db
        .into(db.accounts)
        .insert(
          AccountsCompanion.insert(
            name: 'BCA',
            type: 'bank',
            initialBalanceCents: const Value(12500000),
            colorValue: const Value(0xFF1E88E5),
            isDefault: const Value(true),
          ),
        );
    final mandiriId = await db
        .into(db.accounts)
        .insert(
          AccountsCompanion.insert(
            name: 'Mandiri',
            type: 'bank',
            initialBalanceCents: const Value(5200000),
            colorValue: const Value(0xFFFFB300),
            isDefault: const Value(false),
          ),
        );
    final gopayId = await db
        .into(db.accounts)
        .insert(
          AccountsCompanion.insert(
            name: 'GoPay',
            type: 'e-wallet',
            initialBalanceCents: const Value(750000),
            colorValue: const Value(0xFF00AED6),
            isDefault: const Value(false),
          ),
        );
    final tunaiId = await db
        .into(db.accounts)
        .insert(
          AccountsCompanion.insert(
            name: 'Dompet Tunai',
            type: 'cash',
            initialBalanceCents: const Value(850000),
            colorValue: const Value(0xFF43A047),
            isDefault: const Value(false),
          ),
        );

    // 2. Categories - Expense
    final catMakan = await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Makanan & Minuman',
            icon: 'utensils',
            type: 'expense',
            colorValue: 0xFFFF6B6B,
          ),
        );
    final catTransport = await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Transportasi',
            icon: 'car',
            type: 'expense',
            colorValue: 0xFF339AF0,
          ),
        );
    final catBelanja = await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Belanja & Kebutuhan',
            icon: 'shopping-bag',
            type: 'expense',
            colorValue: 0xFFCC5DE8,
          ),
        );
    final catTagihan = await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Tagihan & Utilitas',
            icon: 'zap',
            type: 'expense',
            colorValue: 0xFFFCC419,
          ),
        );
    final catHiburan = await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Hiburan & Liburan',
            icon: 'gamepad-2',
            type: 'expense',
            colorValue: 0xFFFF922B,
          ),
        );
    final catKesehatan = await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Kesehatan',
            icon: 'heart-pulse',
            type: 'expense',
            colorValue: 0xFF51CF66,
          ),
        );
    final catPendidikan = await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Pendidikan',
            icon: 'graduation-cap',
            type: 'expense',
            colorValue: 0xFF20C997,
          ),
        );
    final catSosial = await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Hadiah & Sosial',
            icon: 'gift',
            type: 'expense',
            colorValue: 0xFFFF8787,
          ),
        );
    final catLainnya = await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Lain-lain',
            icon: 'receipt',
            type: 'expense',
            colorValue: 0xFF868E96,
          ),
        );

    // Categories - Income
    final catGaji = await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Gaji Bulanan',
            icon: 'briefcase',
            type: 'income',
            colorValue: 0xFF2F9E44,
          ),
        );
    final catBonus = await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Bonus & THR',
            icon: 'award',
            type: 'income',
            colorValue: 0xFF37B24D,
          ),
        );
    final catInvestasi = await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Hasil Investasi',
            icon: 'trending-up',
            type: 'income',
            colorValue: 0xFF1C7ED6,
          ),
        );
    final catFreelance = await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Freelance & Projek',
            icon: 'laptop',
            type: 'income',
            colorValue: 0xFF1098AD,
          ),
        );
    final catUangMasuk = await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Hadiah & Uang Masuk',
            icon: 'circle-dollar-sign',
            type: 'income',
            colorValue: 0xFF748FFC,
          ),
        );

    // 3. Transactions
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 12, 30);

    // --- This Month's Income ---
    await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            accountId: bcaId,
            categoryId: catGaji,
            amountCents: 15000000,
            note: const Value('Gaji Pokok Bulanan'),
            date: DateTime(now.year, now.month, 1, 9, 0),
          ),
        );
    await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            accountId: mandiriId,
            categoryId: catFreelance,
            amountCents: 4500000,
            note: const Value('Projek Desain UI Mobile'),
            date: DateTime(
              now.year,
              now.month,
              (now.day > 10 ? 10 : now.day),
              14,
              0,
            ),
          ),
        );
    await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            accountId: bcaId,
            categoryId: catInvestasi,
            amountCents: 650000,
            note: const Value('Dividen Saham BBCA'),
            date: DateTime(
              now.year,
              now.month,
              (now.day > 15 ? 15 : now.day),
              10,
              30,
            ),
          ),
        );
    await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            accountId: gopayId,
            categoryId: catUangMasuk,
            amountCents: 500000,
            note: const Value('Hadiah Ulang Tahun dari Keluarga'),
            date: DateTime(
              now.year,
              now.month,
              (now.day > 18 ? 18 : now.day),
              16,
              0,
            ),
          ),
        );
    await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            accountId: bcaId,
            categoryId: catBonus,
            amountCents: 2000000,
            note: const Value('Bonus Kinerja Kuartal'),
            date: DateTime(
              now.year,
              now.month,
              (now.day > 12 ? 12 : now.day),
              9,
              30,
            ),
          ),
        );
    await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            accountId: gopayId,
            categoryId: catUangMasuk,
            amountCents: 150000,
            note: const Value('Hadiah Ulang Tahun'),
            date: DateTime(
              now.year,
              now.month,
              (now.day > 6 ? 6 : now.day),
              16,
              0,
            ),
          ),
        );

    // --- Past 7 Days (Daily expense) ---
    // Day 0 (today)
    await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            accountId: tunaiId,
            categoryId: catMakan,
            amountCents: 35000,
            note: const Value('Makan Siang Ayam Geprek'),
            date: today,
          ),
        );
    await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            accountId: gopayId,
            categoryId: catMakan,
            amountCents: 24000,
            note: const Value('Kopi Kenangan Mantan Large'),
            date: today.subtract(const Duration(hours: 3)),
          ),
        );

    // Day 1 (yesterday)
    final day1 = today.subtract(const Duration(days: 1));
    await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            accountId: mandiriId,
            categoryId: catTransport,
            amountCents: 150000,
            note: const Value('Bensin Pertamax'),
            date: day1,
          ),
        );
    await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            accountId: bcaId,
            categoryId: catMakan,
            amountCents: 115000,
            note: const Value('Makan Malam Bakmi GM'),
            date: day1.subtract(const Duration(hours: 2)),
          ),
        );

    // Day 2
    final day2 = today.subtract(const Duration(days: 2));
    await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            accountId: bcaId,
            categoryId: catBelanja,
            amountCents: 385000,
            note: const Value('Belanja Mingguan Supermarket'),
            date: day2,
          ),
        );
    await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            accountId: gopayId,
            categoryId: catTransport,
            amountCents: 40000,
            note: const Value('Ojek Online Gojek'),
            date: day2.subtract(const Duration(hours: 4)),
          ),
        );

    // Day 3
    final day3 = today.subtract(const Duration(days: 3));
    await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            accountId: bcaId,
            categoryId: catTagihan,
            amountCents: 450000,
            note: const Value('Token Listrik PLN'),
            date: day3,
          ),
        );
    await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            accountId: tunaiId,
            categoryId: catMakan,
            amountCents: 45000,
            note: const Value('Makan Siang Nasi Padang'),
            date: day3.subtract(const Duration(hours: 3)),
          ),
        );

    // Day 4
    final day4 = today.subtract(const Duration(days: 4));
    await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            accountId: bcaId,
            categoryId: catHiburan,
            amountCents: 186000,
            note: const Value('Langganan Netflix & Spotify'),
            date: day4,
          ),
        );
    await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            accountId: gopayId,
            categoryId: catKesehatan,
            amountCents: 125000,
            note: const Value('Vitamin & Obat Apotek'),
            date: day4.subtract(const Duration(hours: 5)),
          ),
        );

    // Day 5
    final day5 = today.subtract(const Duration(days: 5));
    await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            accountId: mandiriId,
            categoryId: catPendidikan,
            amountCents: 250000,
            note: const Value('Buku Belajar Pemrograman'),
            date: day5,
          ),
        );
    await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            accountId: bcaId,
            categoryId: catMakan,
            amountCents: 175000,
            note: const Value('Makan Malam Ramen'),
            date: day5.subtract(const Duration(hours: 2)),
          ),
        );

    // Day 6
    final day6 = today.subtract(const Duration(days: 6));
    await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            accountId: mandiriId,
            categoryId: catTransport,
            amountCents: 220000,
            note: const Value('Ganti Oli & Servis Motor'),
            date: day6,
          ),
        );
    await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            accountId: tunaiId,
            categoryId: catBelanja,
            amountCents: 65000,
            note: const Value('Camilan & Buah Pasar'),
            date: day6.subtract(const Duration(hours: 4)),
          ),
        );

    // --- Major monthly expenses earlier this month ---
    await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            accountId: bcaId,
            categoryId: catBelanja,
            amountCents: 1250000,
            note: const Value('Belanja Bulanan Hypermart'),
            date: DateTime(now.year, now.month, (now.day > 3 ? 3 : 1), 11, 0),
          ),
        );
    await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            accountId: bcaId,
            categoryId: catTagihan,
            amountCents: 385000,
            note: const Value('Tagihan Internet Indihome'),
            date: DateTime(now.year, now.month, (now.day > 5 ? 5 : 1), 10, 0),
          ),
        );
    await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            accountId: mandiriId,
            categoryId: catSosial,
            amountCents: 200000,
            note: const Value('Donasi Yayasan Peduli Sesama'),
            date: DateTime(now.year, now.month, (now.day > 8 ? 8 : 1), 15, 30),
          ),
        );

    // --- Past 4 Months Data (for Monthly Trend & Reports history) ---
    for (var m = 1; m <= 4; m++) {
      final pastDate = DateTime(now.year, now.month - m, 1);
      final monthYear = pastDate.year;
      final monthNum = pastDate.month;

      // Income
      await db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              accountId: bcaId,
              categoryId: catGaji,
              amountCents: 15000000,
              note: const Value('Gaji Pokok Bulanan'),
              date: DateTime(monthYear, monthNum, 1, 9, 0),
            ),
          );
      await db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              accountId: mandiriId,
              categoryId: catFreelance,
              amountCents: 2500000 + (m * 400000),
              note: const Value('Honor Sampingan & Konsultasi'),
              date: DateTime(monthYear, monthNum, 15, 14, 0),
            ),
          );

      // Expenses
      await db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              accountId: bcaId,
              categoryId: catBelanja,
              amountCents: 1400000 + (m * 80000),
              note: const Value('Belanja Bulanan Rumah Tangga'),
              date: DateTime(monthYear, monthNum, 3, 11, 0),
            ),
          );
      await db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              accountId: bcaId,
              categoryId: catTagihan,
              amountCents: 780000,
              note: const Value('Listrik, Air & Internet'),
              date: DateTime(monthYear, monthNum, 5, 10, 0),
            ),
          );
      await db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              accountId: mandiriId,
              categoryId: catTransport,
              amountCents: 520000,
              note: const Value('Bensin & Transportasi Bulanan'),
              date: DateTime(monthYear, monthNum, 10, 8, 30),
            ),
          );
      await db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              accountId: gopayId,
              categoryId: catMakan,
              amountCents: 980000 - (m * 50000),
              note: const Value('Makan di Luar & Kuliner'),
              date: DateTime(monthYear, monthNum, 18, 19, 0),
            ),
          );
      await db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              accountId: bcaId,
              categoryId: catHiburan,
              amountCents: 350000,
              note: const Value('Liburan Akhir Pekan'),
              date: DateTime(monthYear, monthNum, 22, 16, 0),
            ),
          );
      await db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              accountId: tunaiId,
              categoryId: catLainnya,
              amountCents: 180000,
              note: const Value('Pengeluaran Tak Terduga'),
              date: DateTime(monthYear, monthNum, 26, 13, 0),
            ),
          );
    }
  });
}
