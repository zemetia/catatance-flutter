# Architecture

## Bootstrap flow

```
main.dart
  → ProviderScope (Riverpod root)
    → App (app.dart)
      → MaterialApp.router
          theme: buildAppTheme()        (core/theme/app_theme.dart)
          routerConfig: appRouter       (core/router/app_router.dart)
```

`main.dart` stays minimal: `WidgetsFlutterBinding.ensureInitialized()`, any pre-app-start async setup (e.g. opening the Drift DB, loading `.env` if used), then `runApp(const ProviderScope(child: App()))`.

## Layering

```
presentation  →  data  →  domain
   (widgets,       (repository,    (freezed
   providers)       Drift queries)   entities)
```

- **domain/**: pure Dart, no Flutter/Drift imports. `freezed` models + value objects (e.g. `Money`, if introduced).
- **data/**: repository classes that wrap Drift table access, return domain models (map Drift row → freezed model here, not in presentation).
- **presentation/**: Riverpod providers/notifiers call repositories; widgets only read providers via `ref.watch`/`ref.read`, never touch `data/` or the database directly.

## Dependency injection

Riverpod providers *are* the DI mechanism — no separate service locator (`get_it`) needed at this scale.

- Singletons (database instance, repositories) → `Provider`
- Derived/computed state → `Provider` / `FutureProvider` / `StreamProvider`
- Mutable feature state → `NotifierProvider` / `AsyncNotifierProvider`

Example wiring (`features/transactions/presentation/transaction_providers.dart`):

```dart
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return TransactionRepository(db);
});

final transactionListProvider =
    AsyncNotifierProvider<TransactionListNotifier, List<Transaction>>(
  TransactionListNotifier.new,
);
```

## Database access

`appDatabaseProvider` (in `core/database/app_database.dart`) is the single source of truth — one `AppDatabase` instance for the app's lifetime, provided via `Provider<AppDatabase>`. Repositories take the database instance through the constructor; never instantiate `AppDatabase()` a second time anywhere.

## Error handling

- Repository methods throw typed exceptions (e.g. `TransactionNotFoundException`) rather than returning nulls for "not found".
- `AsyncNotifier`/`FutureProvider` surfaces failures as `AsyncError` automatically — UI handles via `.when(data:, error:, loading:)`.
- No global try/catch swallowing errors silently; if a Sentry-equivalent crash reporter is added later, wire it at the `PlatformDispatcher.instance.onError` level in `main.dart`.
