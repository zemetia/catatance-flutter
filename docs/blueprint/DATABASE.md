# Database — Drift (SQLite)

Local-first: all financial data lives on-device in SQLite via Drift. No backend by default.

## Setup

- `core/database/app_database.dart` — `@DriftDatabase(tables: [...])` class, single instance via `appDatabaseProvider`.
- `core/database/tables/` — one file per table, using Drift's Dart-defined tables (`Table` subclass), not raw SQL, so types + null-safety are enforced.
- Connection: `sqlite3_flutter_libs` for native SQLite bundling, file stored via `path_provider` (`getApplicationDocumentsDirectory()`).

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
```

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
