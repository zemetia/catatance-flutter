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
            currencyCode: const Value('IDR'),
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
            currencyCode: const Value('IDR'),
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
            currencyCode: const Value('IDR'),
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
            currencyCode: const Value('IDR'),
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
            name: 'Makanan Kebutuhan',
            icon: 'utensils',
            type: 'expense',
            colorValue: 0xFFFF6B6B,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Nongkrong',
            icon: 'coffee',
            type: 'expense',
            colorValue: 0xFFE8590C,
          ),
        );
    final catTransport = await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Transport',
            icon: 'car',
            type: 'expense',
            colorValue: 0xFF339AF0,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'BBM',
            icon: 'fuel',
            type: 'expense',
            colorValue: 0xFFF76707,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Tol',
            icon: 'route',
            type: 'expense',
            colorValue: 0xFF495057,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Parkir',
            icon: 'square-parking',
            type: 'expense',
            colorValue: 0xFF1C7ED6,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Langganan',
            icon: 'repeat',
            type: 'expense',
            colorValue: 0xFF7048E8,
          ),
        );
    final catHiburan = await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Hiburan',
            icon: 'gamepad-2',
            type: 'expense',
            colorValue: 0xFFFF922B,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Streaming',
            icon: 'tv',
            type: 'expense',
            colorValue: 0xFF9775FA,
          ),
        );
    final catBelanja = await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Belanja',
            icon: 'shopping-bag',
            type: 'expense',
            colorValue: 0xFFCC5DE8,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Fashion',
            icon: 'shirt',
            type: 'expense',
            colorValue: 0xFFF06595,
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
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Asuransi',
            icon: 'shield',
            type: 'expense',
            colorValue: 0xFF15AABF,
          ),
        );
    final catPendidikan = await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Edukasi',
            icon: 'graduation-cap',
            type: 'expense',
            colorValue: 0xFF20C997,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Internet',
            icon: 'wifi',
            type: 'expense',
            colorValue: 0xFF228BE6,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Pulsa/Kuota',
            icon: 'smartphone',
            type: 'expense',
            colorValue: 0xFF4C6EF5,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Donasi',
            icon: 'hand-heart',
            type: 'expense',
            colorValue: 0xFFE64980,
          ),
        );
    final catSosial = await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Memberkati',
            icon: 'gift',
            type: 'expense',
            colorValue: 0xFFFF8787,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Rumah',
            icon: 'house',
            type: 'expense',
            colorValue: 0xFFAE8F6F,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Hutang',
            icon: 'hand-coins',
            type: 'expense',
            colorValue: 0xFFE03131,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Cicilan',
            icon: 'credit-card',
            type: 'expense',
            colorValue: 0xFF6C5CE7,
          ),
        );
    final catTagihan = await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Listrik/Air',
            icon: 'zap',
            type: 'expense',
            colorValue: 0xFFFCC419,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Anak',
            icon: 'baby',
            type: 'expense',
            colorValue: 0xFFFFA8A8,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Hewan Peliharaan',
            icon: 'dog',
            type: 'expense',
            colorValue: 0xFFD9822B,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Pengiriman',
            icon: 'package',
            type: 'expense',
            colorValue: 0xFF868E96,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Game',
            icon: 'joystick',
            type: 'expense',
            colorValue: 0xFF7950F2,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Kecantikan',
            icon: 'sparkles',
            type: 'expense',
            colorValue: 0xFFF783AC,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Kebugaran',
            icon: 'dumbbell',
            type: 'expense',
            colorValue: 0xFF12B886,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Rokok',
            icon: 'cigarette',
            type: 'expense',
            colorValue: 0xFF495057,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Alkohol',
            icon: 'wine',
            type: 'expense',
            colorValue: 0xFFC2255C,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Perjalanan',
            icon: 'plane',
            type: 'expense',
            colorValue: 0xFF1C7ED6,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Hotel',
            icon: 'hotel',
            type: 'expense',
            colorValue: 0xFF862E9C,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Laundry',
            icon: 'washing-machine',
            type: 'expense',
            colorValue: 0xFF4DABF7,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Top up',
            icon: 'wallet',
            type: 'expense',
            colorValue: 0xFF37B24D,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Gift',
            icon: 'gift',
            type: 'expense',
            colorValue: 0xFFFF8787,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Aset Digital',
            icon: 'bitcoin',
            type: 'expense',
            colorValue: 0xFFF08C00,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Dukungan Kreatifitas',
            icon: 'palette',
            type: 'expense',
            colorValue: 0xFFAE3EC9,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Kencan',
            icon: 'heart',
            type: 'expense',
            colorValue: 0xFFE64980,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'E-commerce',
            icon: 'shopping-cart',
            type: 'expense',
            colorValue: 0xFFCC5DE8,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Sewa Fashion',
            icon: 'shirt',
            type: 'expense',
            colorValue: 0xFFF06595,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'App store',
            icon: 'app-window',
            type: 'expense',
            colorValue: 0xFF495057,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Kantor',
            icon: 'briefcase',
            type: 'expense',
            colorValue: 0xFF5F3DC4,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Acara',
            icon: 'party-popper',
            type: 'expense',
            colorValue: 0xFFF59F00,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Terapi',
            icon: 'stethoscope',
            type: 'expense',
            colorValue: 0xFF51CF66,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Adjustment',
            icon: 'scale',
            type: 'expense',
            colorValue: 0xFF868E96,
          ),
        );
    final catLainnya = await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Lainnya',
            icon: 'receipt',
            type: 'expense',
            colorValue: 0xFF868E96,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Biaya Admin Transfer',
            icon: 'banknote',
            type: 'expense',
            colorValue: 0xFF868E96,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Transfer',
            icon: 'arrow-left-right',
            type: 'transfer',
            colorValue: 0xFF3D7FFF,
          ),
        );

    // Categories - Income
    final catGaji = await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Gaji',
            icon: 'briefcase',
            type: 'income',
            colorValue: 0xFF2F9E44,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Project Sampingan',
            icon: 'briefcase-business',
            type: 'income',
            colorValue: 0xFF0CA678,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Passive Income',
            icon: 'piggy-bank',
            type: 'income',
            colorValue: 0xFF37B24D,
          ),
        );
    final catBonus = await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Bonus',
            icon: 'award',
            type: 'income',
            colorValue: 0xFF37B24D,
          ),
        );
    final catInvestasi = await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Investasi',
            icon: 'trending-up',
            type: 'income',
            colorValue: 0xFF1C7ED6,
          ),
        );
    final catFreelance = await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Freelance',
            icon: 'laptop',
            type: 'income',
            colorValue: 0xFF1098AD,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Jual Barang',
            icon: 'shopping-bag',
            type: 'income',
            colorValue: 0xFFCC5DE8,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Cashback',
            icon: 'percent',
            type: 'income',
            colorValue: 0xFFF08C00,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Sewa',
            icon: 'key',
            type: 'income',
            colorValue: 0xFFAE8F6F,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Royalti',
            icon: 'coins',
            type: 'income',
            colorValue: 0xFFF59F00,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Deviden',
            icon: 'landmark',
            type: 'income',
            colorValue: 0xFF1C7ED6,
          ),
        );
    final catUangMasuk = await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Gift',
            icon: 'gift',
            type: 'income',
            colorValue: 0xFF748FFC,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Afiliasi',
            icon: 'handshake',
            type: 'income',
            colorValue: 0xFF0CA678,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Sosial Media',
            icon: 'at-sign',
            type: 'income',
            colorValue: 0xFFE64980,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Tip',
            icon: 'hand-coins',
            type: 'income',
            colorValue: 0xFF37B24D,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Airdrop',
            icon: 'gem',
            type: 'income',
            colorValue: 0xFF7950F2,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Pinjaman',
            icon: 'hand-coins',
            type: 'income',
            colorValue: 0xFFE8590C,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Piutang',
            icon: 'hand-coins',
            type: 'income',
            colorValue: 0xFF2F9E44,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Adjustment',
            icon: 'scale',
            type: 'income',
            colorValue: 0xFF868E96,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Lainnya',
            icon: 'receipt',
            type: 'income',
            colorValue: 0xFF868E96,
          ),
        );

    // 3. Budgets (Anggaran) — monthly limits for the most common expense
    // categories, one with carry-over enabled as a demo.
    await db
        .into(db.budgets)
        .insert(
          BudgetsCompanion.insert(
            categoryId: catMakan,
            limitCents: 2000000,
            periodType: const Value('monthly'),
          ),
        );
    await db
        .into(db.budgets)
        .insert(
          BudgetsCompanion.insert(
            categoryId: catTransport,
            limitCents: 800000,
            periodType: const Value('monthly'),
          ),
        );
    await db
        .into(db.budgets)
        .insert(
          BudgetsCompanion.insert(
            categoryId: catBelanja,
            limitCents: 2000000,
            periodType: const Value('monthly'),
            carryOverEnabled: const Value(true),
          ),
        );

    // 4. Transactions
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

    // 5. Debts & Receivables (Utang & Piutang)
    final seedNow = DateTime.now();

    // 4.1 Utang ke Kak Sarah (aktif, ada cicilan)
    final debtSarahId = await db.into(db.debts).insert(
          DebtsCompanion.insert(
            type: 'debt',
            personName: 'Kak Sarah',
            amountCents: 2500000,
            paidAmountCents: const Value(1000000),
            transactionDate: seedNow.subtract(const Duration(days: 15)),
            dueDate: Value(seedNow.add(const Duration(days: 14))),
            status: const Value('unpaid'),
            note: const Value('Pinjam dana darurat servis motor'),
            accountId: Value(bcaId),
          ),
        );
    await db.into(db.debtPayments).insert(
          DebtPaymentsCompanion.insert(
            debtId: debtSarahId,
            amountCents: 1000000,
            paymentDate: seedNow.subtract(const Duration(days: 5)),
            note: const Value('Cicilan pertama transfer BCA'),
          ),
        );

    // 4.2 Piutang ke Rian Pratama (aktif, ada cicilan)
    final recRianId = await db.into(db.debts).insert(
          DebtsCompanion.insert(
            type: 'receivable',
            personName: 'Rian Pratama',
            amountCents: 750000,
            paidAmountCents: const Value(250000),
            transactionDate: seedNow.subtract(const Duration(days: 10)),
            dueDate: Value(seedNow.add(const Duration(days: 5))),
            status: const Value('unpaid'),
            note: const Value('Talangan tiket konser musik'),
            accountId: Value(gopayId),
          ),
        );
    await db.into(db.debtPayments).insert(
          DebtPaymentsCompanion.insert(
            debtId: recRianId,
            amountCents: 250000,
            paymentDate: seedNow.subtract(const Duration(days: 3)),
            note: const Value('Transfer via GoPay'),
          ),
        );

    // 4.3 Piutang ke Dimas Setiawan (lewat tempo)
    await db.into(db.debts).insert(
          DebtsCompanion.insert(
            type: 'receivable',
            personName: 'Dimas Setiawan',
            amountCents: 300000,
            paidAmountCents: const Value(0),
            transactionDate: seedNow.subtract(const Duration(days: 20)),
            dueDate: Value(seedNow.subtract(const Duration(days: 3))),
            status: const Value('unpaid'),
            note: const Value('Patungan makan malam & karaoke'),
            accountId: Value(mandiriId),
          ),
        );

    // 4.4 Utang ke Budi Santoso (lunas)
    final debtBudiId = await db.into(db.debts).insert(
          DebtsCompanion.insert(
            type: 'debt',
            personName: 'Budi Santoso',
            amountCents: 500000,
            paidAmountCents: const Value(500000),
            transactionDate: seedNow.subtract(const Duration(days: 30)),
            dueDate: Value(seedNow.subtract(const Duration(days: 10))),
            status: const Value('paid'),
            note: const Value('Beli perlengkapan kerja & kabel'),
            accountId: Value(bcaId),
          ),
        );
    await db.into(db.debtPayments).insert(
          DebtPaymentsCompanion.insert(
            debtId: debtBudiId,
            amountCents: 500000,
            paymentDate: seedNow.subtract(const Duration(days: 10)),
            note: const Value('Pelunasan penuh via transfer Mandiri'),
          ),
        );

    // 5. Target Tabungan (Savings Goals)
    // 5.1 Liburan Bali (matching the user reference mock)
    await db.into(db.savingsGoals).insert(
          SavingsGoalsCompanion.insert(
            name: 'Liburan Bali',
            iconKey: const Value('plane'),
            gradientIndex: const Value(1), // Periwinkle/Indigo
            targetAmountCents: 10000000,
            currentAmountCents: const Value(4500000),
            targetDate: Value(seedNow.add(const Duration(days: 120))),
            autoSaveEnabled: const Value(true),
            autoSaveAmountCents: const Value(500000),
            autoSaveFrequency: const Value('monthly'),
            sourceAccountId: Value(bcaId),
            note: const Value('Tabungan tiket pesawat dan hotel di Ubud & Seminyak'),
          ),
        );

    // 5.2 Beli Laptop Kerja
    await db.into(db.savingsGoals).insert(
          SavingsGoalsCompanion.insert(
            name: 'Beli Laptop Baru',
            iconKey: const Value('laptop'),
            gradientIndex: const Value(0), // Coral Rose
            targetAmountCents: 18000000,
            currentAmountCents: const Value(12000000),
            targetDate: Value(seedNow.add(const Duration(days: 60))),
            autoSaveEnabled: const Value(false),
            autoSaveAmountCents: const Value(0),
            autoSaveFrequency: const Value('monthly'),
            sourceAccountId: Value(mandiriId),
            note: const Value('Upgrade Macbook Pro untuk coding dan desain'),
          ),
        );

    // 5.3 Dana Darurat (Tanpa deadline, autosave aktif)
    await db.into(db.savingsGoals).insert(
          SavingsGoalsCompanion.insert(
            name: 'Dana Darurat',
            iconKey: const Value('health'),
            gradientIndex: const Value(2), // Emerald Mint
            targetAmountCents: 30000000,
            currentAmountCents: const Value(15000000),
            autoSaveEnabled: const Value(true),
            autoSaveAmountCents: const Value(1000000),
            autoSaveFrequency: const Value('monthly'),
            sourceAccountId: Value(bcaId),
            note: const Value('Penyangga 6 bulan biaya hidup untuk keamanan finansial'),
          ),
        );
  });
}

/// Schema v13: expands the income/expense category set to the granular list
/// used by [seedInitialData]. Renames the old broad categories in place (so
/// existing transactions keep pointing at the same row) and inserts the
/// newly added categories that didn't exist before.
Future<void> expandCategoriesV13(AppDatabase db) async {
  Future<void> rename(String oldName, String type, String newName, String newIcon) async {
    await (db.update(db.categories)
          ..where((c) => c.name.equals(oldName) & c.type.equals(type)))
        .write(CategoriesCompanion(name: Value(newName), icon: Value(newIcon)));
  }

  await rename('Makanan & Minuman', 'expense', 'Makanan Kebutuhan', 'utensils');
  await rename('Transportasi', 'expense', 'Transport', 'car');
  await rename('Belanja & Kebutuhan', 'expense', 'Belanja', 'shopping-bag');
  await rename('Tagihan & Utilitas', 'expense', 'Listrik/Air', 'zap');
  await rename('Hiburan & Liburan', 'expense', 'Hiburan', 'gamepad-2');
  await rename('Pendidikan', 'expense', 'Edukasi', 'graduation-cap');
  await rename('Hadiah & Sosial', 'expense', 'Memberkati', 'gift');
  await rename('Lain-lain', 'expense', 'Lainnya', 'receipt');
  await rename('Cicilan & Pinjaman', 'expense', 'Cicilan', 'credit-card');
  await rename('Gaji Bulanan', 'income', 'Gaji', 'briefcase');
  await rename('Bonus & THR', 'income', 'Bonus', 'award');
  await rename('Hasil Investasi', 'income', 'Investasi', 'trending-up');
  await rename('Freelance & Projek', 'income', 'Freelance', 'laptop');
  await rename('Hadiah & Uang Masuk', 'income', 'Gift', 'gift');

  Future<void> add(String name, String icon, String type, int colorValue) async {
    await db.into(db.categories).insert(
          CategoriesCompanion.insert(
            name: name,
            icon: icon,
            type: type,
            colorValue: colorValue,
          ),
        );
  }

  // New expense categories.
  await add('Nongkrong', 'coffee', 'expense', 0xFFE8590C);
  await add('BBM', 'fuel', 'expense', 0xFFF76707);
  await add('Tol', 'route', 'expense', 0xFF495057);
  await add('Parkir', 'square-parking', 'expense', 0xFF1C7ED6);
  await add('Langganan', 'repeat', 'expense', 0xFF7048E8);
  await add('Streaming', 'tv', 'expense', 0xFF9775FA);
  await add('Fashion', 'shirt', 'expense', 0xFFF06595);
  await add('Asuransi', 'shield', 'expense', 0xFF15AABF);
  await add('Internet', 'wifi', 'expense', 0xFF228BE6);
  await add('Pulsa/Kuota', 'smartphone', 'expense', 0xFF4C6EF5);
  await add('Donasi', 'hand-heart', 'expense', 0xFFE64980);
  await add('Rumah', 'house', 'expense', 0xFFAE8F6F);
  await add('Hutang', 'hand-coins', 'expense', 0xFFE03131);
  await add('Anak', 'baby', 'expense', 0xFFFFA8A8);
  await add('Hewan Peliharaan', 'dog', 'expense', 0xFFD9822B);
  await add('Pengiriman', 'package', 'expense', 0xFF868E96);
  await add('Game', 'joystick', 'expense', 0xFF7950F2);
  await add('Kecantikan', 'sparkles', 'expense', 0xFFF783AC);
  await add('Kebugaran', 'dumbbell', 'expense', 0xFF12B886);
  await add('Rokok', 'cigarette', 'expense', 0xFF495057);
  await add('Alkohol', 'wine', 'expense', 0xFFC2255C);
  await add('Perjalanan', 'plane', 'expense', 0xFF1C7ED6);
  await add('Hotel', 'hotel', 'expense', 0xFF862E9C);
  await add('Laundry', 'washing-machine', 'expense', 0xFF4DABF7);
  await add('Top up', 'wallet', 'expense', 0xFF37B24D);
  await add('Gift', 'gift', 'expense', 0xFFFF8787);
  await add('Aset Digital', 'bitcoin', 'expense', 0xFFF08C00);
  await add('Dukungan Kreatifitas', 'palette', 'expense', 0xFFAE3EC9);
  await add('Kencan', 'heart', 'expense', 0xFFE64980);
  await add('E-commerce', 'shopping-cart', 'expense', 0xFFCC5DE8);
  await add('Sewa Fashion', 'shirt', 'expense', 0xFFF06595);
  await add('App store', 'app-window', 'expense', 0xFF495057);
  await add('Kantor', 'briefcase', 'expense', 0xFF5F3DC4);
  await add('Acara', 'party-popper', 'expense', 0xFFF59F00);
  await add('Terapi', 'stethoscope', 'expense', 0xFF51CF66);
  await add('Adjustment', 'scale', 'expense', 0xFF868E96);

  // New income categories.
  await add('Project Sampingan', 'briefcase-business', 'income', 0xFF0CA678);
  await add('Passive Income', 'piggy-bank', 'income', 0xFF37B24D);
  await add('Jual Barang', 'shopping-bag', 'income', 0xFFCC5DE8);
  await add('Cashback', 'percent', 'income', 0xFFF08C00);
  await add('Sewa', 'key', 'income', 0xFFAE8F6F);
  await add('Royalti', 'coins', 'income', 0xFFF59F00);
  await add('Deviden', 'landmark', 'income', 0xFF1C7ED6);
  await add('Afiliasi', 'handshake', 'income', 0xFF0CA678);
  await add('Sosial Media', 'at-sign', 'income', 0xFFE64980);
  await add('Tip', 'hand-coins', 'income', 0xFF37B24D);
  await add('Airdrop', 'gem', 'income', 0xFF7950F2);
  await add('Pinjaman', 'hand-coins', 'income', 0xFFE8590C);
  await add('Adjustment', 'scale', 'income', 0xFF868E96);
  await add('Lainnya', 'receipt', 'income', 0xFF868E96);
}
