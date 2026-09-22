# State Management — Riverpod

## Provider types & when to use them

| Type | Use for |
|---|---|
| `Provider` | Singletons, derived read-only values (repositories, computed totals) |
| `FutureProvider` | One-shot async reads (e.g. initial load) |
| `StreamProvider` | Live Drift query streams (e.g. `watchAll()` on a table) |
| `NotifierProvider` | Synchronous mutable state (e.g. selected date range filter) |
| `AsyncNotifierProvider` | Mutable state backed by async operations (create/update/delete transaction) |

Prefer `StreamProvider` fed by Drift's `.watch()` queries for any list that should live-update when the DB changes (transaction list, account balances) — avoids manual cache invalidation.

## Naming convention

- Provider variable: `<thing>Provider` — e.g. `transactionListProvider`, `selectedAccountProvider`
- Notifier class: `<Thing>Notifier` — e.g. `TransactionListNotifier`

## Pattern: list backed by Drift stream

```dart
final transactionListProvider = StreamProvider.autoDispose<List<Transaction>>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.watchAll();
});
```

## Pattern: mutation via AsyncNotifier

```dart
class TransactionFormNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> submit(TransactionDraft draft) async {
    state = const AsyncLoading();
    final repo = ref.read(transactionRepositoryProvider);
    state = await AsyncValue.guard(() => repo.insert(draft));
  }
}
```

## Widget consumption

- Use `ConsumerWidget` / `HookConsumerWidget` (when local hooks like `useTextEditingController` are needed) — not `StatefulWidget` + manual `ProviderScope` reads.
- Always branch on `AsyncValue` explicitly:

```dart
transactions.when(
  data: (items) => TransactionList(items: items),
  loading: () => const TransactionListShimmer(),
  error: (err, st) => AppErrorView(message: err.toString()),
);
```

## Rules

- Never call `ref.read` inside `build()` for a value the widget should reactively update on — use `ref.watch`.
- `ref.read` is only for one-off actions (button `onPressed`, `initState`-equivalent via `ref.listen`).
- Use `.autoDispose` on providers scoped to a single screen (form state, filters) to avoid memory leaks; keep app-wide singletons (database, theme mode) without `.autoDispose`.
- Local, purely visual state (animation controller value, whether a tooltip is open) stays as widget-local `useState`/`StatefulWidget` — does not need a provider.
