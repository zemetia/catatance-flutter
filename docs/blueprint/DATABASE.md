# Database — Drift (SQLite)

Local-first: all financial data lives on-device in SQLite via Drift. No backend by default.

## Setup

- `core/database/app_database.dart` — `@DriftDatabase(tables: [...])` class, single instance via `appDatabaseProvider`.
- `core/database/tables/` — one file per table, using Drift's Dart-defined tables (`Table` subclass), not raw SQL, so types + null-safety are enforced.
- Connection: `drift_flutter`'s `driftDatabase(name: ...)`, file stored via `path_provider` (`getApplicationDocumentsDirectory()`).

### Crash/interruption durability

`_openConnection()` passes `native: DriftNativeOptions(setup: (db) { ... })` to run these PRAGMAs on every connection before Drift uses it:

- `PRAGMA journal_mode = WAL` — writes go to an append-only `.wal` file instead of being applied in place, so an app crash or an OS/app update killed mid-write can never leave the main `.sqlite` file half-written; SQLite replays or discards the incomplete WAL frames on next open.
- `PRAGMA synchronous = NORMAL` — the mode SQLite recommends pairing with WAL: still fsyncs at every checkpoint (durable against app/OS crash), only trades away the very last uncommitted transaction against actual power loss, in exchange for much faster writes than `FULL`.
- `PRAGMA busy_timeout = 5000` — avoids spurious "database is locked" errors if two connections briefly overlap.

Requires `sqlite3` as a **direct** `pubspec.yaml` dependency (not just transitive via `drift`/`drift_flutter`) for the `CommonDatabase` setup-callback type. Never change the `name` passed to `driftDatabase()` or the resolved directory — either would make the app open a fresh, empty database and orphan every existing user's data.

## Core schema (starting point)

```dart
class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get type => text()();        // cash, bank, e-wallet, etc.
  IntColumn get initialBalanceCents => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get icon => text()();
  TextColumn get type => text()();        // income | expense
  IntColumn get colorValue => integer()();
}

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get accountId => integer().references(Accounts, #id)();
  IntColumn get categoryId => integer().references(Categories, #id)();
  IntColumn get amountCents => integer()();   // always positive; sign derived from category type
  TextColumn get note => text().nullable()();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Debts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => text()();            // 'debt' | 'receivable'
  TextColumn get personName => text()();
  IntColumn get amountCents => integer()();
  IntColumn get paidAmountCents => integer().withDefault(const Constant(0))();
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get transactionDate => dateTime()();
  TextColumn get status => text().withDefault(const Constant('unpaid'))(); // 'unpaid' | 'paid'
  TextColumn get note => text().nullable()();
  IntColumn get accountId => integer().nullable().references(Accounts, #id)();
  IntColumn get splitBillId => integer().nullable().references(SplitBills, #id)(); // set when auto-generated from a patungan participant
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class DebtPayments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get debtId => integer().references(Debts, #id)();
  IntColumn get amountCents => integer()();
  DateTimeColumn get paymentDate => dateTime()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// Patungan (group bill): one expense transaction for the full amount paid,
// grouped via this table, with a Debts (type='receivable') row auto-created
// per named participant's share — linked back through Debts.splitBillId so
// repayment reuses the existing Utang & Piutang flow rather than duplicating it.
class SplitBills extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get transactionId => integer().references(Transactions, #id)();
  IntColumn get totalAmountCents => integer()();
  BoolColumn get payerIncluded => boolean().withDefault(const Constant(true))();
  IntColumn get payerShareCents => integer().withDefault(const Constant(0))();
  TextColumn get note => text().nullable()();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// Cicilan (installment plan): fixed monthly amount over a fixed tenor.
// When both accountId and categoryId are set, paying an installment also
// deducts the wallet balance and inserts a real Transactions row so the
// payment shows up in Transaksi/Laporan/Dasbor, not just its own screen.
// paidAmountCents sums actual amounts paid (not paidInstallments * fixed
// amount) so a custom/partial payment never drifts the progress math.
class Installments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get totalAmountCents => integer()();
  IntColumn get tenorMonths => integer()();
  IntColumn get installmentAmountCents => integer()();
  IntColumn get paidInstallments => integer().withDefault(const Constant(0))();
  IntColumn get paidAmountCents => integer().withDefault(const Constant(0))();
  DateTimeColumn get startDate => dateTime()();
  IntColumn get accountId => integer().nullable().references(Accounts, #id)();
  IntColumn get categoryId => integer().nullable().references(Categories, #id)();
  TextColumn get note => text().nullable()();
  TextColumn get status =>
      text().withDefault(const Constant('active'))(); // 'active' | 'completed'
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class InstallmentPayments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get installmentId => integer().references(Installments, #id)();
  IntColumn get amountCents => integer()();
  DateTimeColumn get paymentDate => dateTime()();
  IntColumn get transactionId =>
      integer().nullable().references(Transactions, #id)();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Budgets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId => integer().references(Categories, #id)();
  IntColumn get limitCents => integer()();
  TextColumn get periodType =>
      text().withDefault(const Constant('monthly'))(); // monthly | weekly | custom
  DateTimeColumn get customStartDate => dateTime().nullable()();
  DateTimeColumn get customEndDate => dateTime().nullable()();
  BoolColumn get carryOverEnabled => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
```

A `Budgets` row is a recurring *configuration*, not a per-period instance —
for `monthly`/`weekly` the active period's actual date range is always
resolved live from "now" (`resolveBudgetPeriod` in
`features/budget/domain/budget_period_type.dart`), never stored, so a
recurring budget doesn't need a new row each period. `custom` uses the
stored `customStartDate`/`customEndDate` as a one-off inclusive range
instead. "Bawa sisa periode lalu" (`carryOverEnabled`) adds the *previous*
recurring period's unspent balance on top of the current period's limit;
not meaningful for `custom` (no natural predecessor period).

## Money handling

- **Always store amounts as integers in the smallest currency unit** (Rupiah has no subunit in practice, so store whole Rupiah as `int`, never `double`).
- Never do arithmetic on formatted currency strings — format only at the presentation edge with `intl`'s `NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ')`.

## Migrations

- Bump `schemaVersion` in `AppDatabase` on any table/column change.
- Add a `MigrationStrategy` step (`from`, `to`) — never silently drop/recreate tables once the app has shipped.
- Document each migration with a one-line comment: what changed and why.

## Repository pattern

Each feature's `data/<domain>_repository.dart` wraps its table(s):

```dart
class TransactionRepository {
  TransactionRepository(this._db);
  final AppDatabase _db;

  Stream<List<Transaction>> watchAll() =>
      _db.select(_db.transactions).watch().map(
        (rows) => rows.map(_toDomain).asBroadcastStream as List<Transaction>,
      );

  Future<int> insert(TransactionDraft draft) =>
      _db.into(_db.transactions).insert(draft.toCompanion());
}
```

Widgets and providers never call `_db.select(...)` directly — only through a repository method.

## Codegen

Drift + freezed both use `build_runner`:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Run this after any table, freezed model, or json_serializable change. `*.g.dart` / `*.freezed.dart` files are committed to the repo (not gitignored) so CI/other machines don't need to regenerate to build.
