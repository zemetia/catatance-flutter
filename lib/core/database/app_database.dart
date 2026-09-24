import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_meta_storage.dart';
import 'seed_data.dart';
import 'tables/accounts_table.dart';
import 'tables/bank_notification_mappings_table.dart';
import 'tables/budgets_table.dart';
import 'tables/captured_bank_notifications_table.dart';
import 'tables/categories_table.dart';
import 'tables/debt_payments_table.dart';
import 'tables/debts_table.dart';
import 'tables/earned_badges_table.dart';
import 'tables/installment_payments_table.dart';
import 'tables/installments_table.dart';
import 'tables/savings_goals_table.dart';
import 'tables/split_bills_table.dart';
import 'tables/transactions_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Accounts,
    Categories,
    Transactions,
    Debts,
    DebtPayments,
    Budgets,
    SavingsGoals,
    Installments,
    InstallmentPayments,
    SplitBills,
    BankNotificationMappings,
    CapturedBankNotifications,
    EarnedBadges,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 15;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await seedInitialData(this);
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        // Wallet color tagging + a single default wallet (added for the
        // "Semua dompet" screen's color swatches and default-wallet flag).
        await m.addColumn(accounts, accounts.colorValue);
        await m.addColumn(accounts, accounts.isDefault);
      }
      if (from < 3) {
        // Multi-currency support for wallets (ISO 4217 code, e.g. IDR, USD).
        await m.addColumn(accounts, accounts.currencyCode);
      }
      if (from < 4) {
        // Debts and receivables tracking (Utang & Piutang)
        await m.createTable(debts);
        await m.createTable(debtPayments);
      }
      if (from < 5) {
        // Per-category budgets (Anggaran): monthly/weekly/custom period,
        // optional carry-over of the previous period's remaining balance.
        await m.createTable(budgets);
      }
      if (from < 6) {
        // Target tabungan (Savings Goals) with icons, color gradient cards, and autosave.
        await m.createTable(savingsGoals);
      }
      if (from < 7) {
        // Cicilan (installment plans): fixed monthly amount over a fixed
        // tenor, optionally linked to a wallet + category so paying an
        // installment also creates a real Transaction and updates the
        // wallet balance.
        await m.createTable(installments);
        await m.createTable(installmentPayments);
        await into(categories).insert(
          CategoriesCompanion.insert(
            name: 'Cicilan & Pinjaman',
            icon: 'credit-card',
            type: 'expense',
            colorValue: 0xFF6C5CE7,
          ),
        );
      }
      if (from < 8) {
        // Patungan (split bills): record one expense transaction for the
        // full bill paid, grouped via `SplitBills`, with a `Debts`
        // receivable auto-generated per named participant's share.
        await m.createTable(splitBills);
        await m.addColumn(debts, debts.splitBillId);
      }
      if (from < 9) {
        // Tangkap Notifikasi Bank: map a notification source app to a
        // wallet (`BankNotificationMappings`), and queue captured
        // notifications for user confirmation before they become a real
        // Transaction (`CapturedBankNotifications`).
        await m.createTable(bankNotificationMappings);
        await m.createTable(capturedBankNotifications);
      }
      if (from < 10) {
        // Transfer antar dompet: optional admin fee, recorded as a real
        // expense Transaction from the source wallet.
        await into(categories).insert(
          CategoriesCompanion.insert(
            name: 'Biaya Admin Transfer',
            icon: 'banknote',
            type: 'expense',
            colorValue: 0xFF868E96,
          ),
        );
      }
      if (from < 11) {
        // Transfer antar dompet now records itself as its own pair of
        // Transactions (one 'transfer_out' from the source wallet, one
        // 'transfer_in' into the destination wallet) instead of only
        // silently mutating both balances — a distinct category type (not
        // 'expense'/'income') keeps these out of income/expense reports
        // while still showing up in the Transaksi ledger.
        await into(categories).insert(
          CategoriesCompanion.insert(
            name: 'Transfer Keluar',
            icon: 'arrow-up-right',
            type: 'transfer_out',
            colorValue: 0xFFE8590C,
          ),
        );
        await into(categories).insert(
          CategoriesCompanion.insert(
            name: 'Transfer Masuk',
            icon: 'arrow-down-left',
            type: 'transfer_in',
            colorValue: 0xFF2F9E44,
          ),
        );
      }
      if (from < 12) {
        // Lencana (badges): unlocked achievements are recorded here (keyed
        // by the in-memory catalog's badge key) so they stay unlocked even
        // if the live metric they were computed from later regresses.
        await m.createTable(earnedBadges);
      }
      if (from < 13) {
        // Expands the broad category set into the granular list users
        // actually pick from (BBM, Tol, Parkir, Langganan, Pinjaman, ...).
        // Renames existing rows in place so old transactions/budgets keep
        // pointing at the same categoryId, then inserts the new ones.
        await expandCategoriesV13(this);
      }
      if (from < 14) {
        // Utang & Piutang payments can now optionally be linked to a
        // wallet: paying off a debt debits it (expense, 'Hutang'),
        // receiving a receivable payment credits it (income, 'Piutang'),
        // recorded as a real Transaction linked via `transactionId` — same
        // pattern as `InstallmentPayments`. 'Piutang' didn't exist yet.
        await m.addColumn(debtPayments, debtPayments.accountId);
        await m.addColumn(debtPayments, debtPayments.transactionId);
        await into(categories).insert(
          CategoriesCompanion.insert(
            name: 'Piutang',
            icon: 'hand-coins',
            type: 'income',
            colorValue: 0xFF2F9E44,
          ),
        );
      }
      if (from < 15) {
        // Transfer antar dompet now records itself as ONE Transaction (not
        // a 'transfer_out' + 'transfer_in' pair) — `toAccountId`/
        // `toAmountCents` capture the destination wallet and (for a
        // cross-currency transfer) the credited amount, so the ledger shows
        // a single "Transfer dari A ke B" row instead of two. The old
        // 'Transfer Keluar'/'Transfer Masuk' categories are left in place
        // so already-recorded transfer pairs keep displaying correctly.
        await m.addColumn(transactions, transactions.toAccountId);
        await m.addColumn(transactions, transactions.toAmountCents);
        await into(categories).insert(
          CategoriesCompanion.insert(
            name: 'Transfer',
            icon: 'arrow-left-right',
            type: 'transfer',
            colorValue: 0xFF3D7FFF,
          ),
        );
      }
    },
    beforeOpen: (OpeningDetails details) async {
      await customStatement('PRAGMA foreign_keys = ON;');
      final existing = await (select(accounts)..limit(1)).get();
      if (existing.isEmpty) {
        final resetByUser = await const AppMetaStorage().wasDataResetByUser();
        if (!resetByUser) {
          await seedInitialData(this);
        }
      }
    },
  );

  /// Wipes every user-entered record (wallets, transactions, debts,
  /// budgets, savings goals, installments, split bills, bank-notification
  /// captures/mappings, earned badges) while leaving `Categories` (shared
  /// reference data the app needs to keep functioning) untouched. The
  /// user's name/profile isn't stored in this database at all (see
  /// `userProfileProvider`), so there's nothing to preserve there.
  ///
  /// Also marks the reset in [AppMetaStorage] so `beforeOpen` doesn't
  /// mistake the resulting empty `accounts` table for a fresh install and
  /// re-populate it with demo seed data on the next app launch.
  Future<void> resetAllData() async {
    await transaction(() async {
      await delete(capturedBankNotifications).go();
      await delete(bankNotificationMappings).go();
      await delete(installmentPayments).go();
      await delete(installments).go();
      await delete(debtPayments).go();
      await delete(debts).go();
      await delete(splitBills).go();
      await delete(budgets).go();
      await delete(savingsGoals).go();
      await delete(earnedBadges).go();
      await delete(transactions).go();
      await delete(accounts).go();
    });
    await const AppMetaStorage().markDataResetByUser();
  }
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'pencatatan_keuangan');
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
