# Routing — go_router

`core/router/app_router.dart` holds the single `GoRouter` instance, exposed via a `Provider<GoRouter>` so it can later depend on auth/onboarding state if needed.

## Structure

```dart
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/', name: 'dashboard', builder: (_, __) => const DashboardScreen()),
          GoRoute(path: '/transactions', name: 'transactions', builder: (_, __) => const TransactionListScreen()),
          GoRoute(path: '/reports', name: 'reports', builder: (_, __) => const ReportsScreen()),
        ],
      ),
      GoRoute(
        path: '/transactions/:id',
        name: 'transaction-detail',
        builder: (context, state) => TransactionDetailScreen(id: state.pathParameters['id']!),
      ),
    ],
  );
});
```

- `ShellRoute` hosts the persistent bottom navigation bar (`AppShell`) for the main tabs (Dashboard, Transactions, Reports, Settings).
- Detail/edit screens (transaction detail, add transaction) live outside the shell as full-screen routes.

## Naming & navigation

- Every route has a `name:` — navigate with `context.pushNamed('transaction-detail', pathParameters: {'id': id})`, never a hardcoded path string.
- Use `context.push` for screens the user should be able to back out of (detail, forms); use `context.go` for tab switches inside the shell.

## Rules

- No `Navigator.push(MaterialPageRoute(...))` anywhere — breaks deep-linking and the back-button contract `go_router` manages.
- Route params that are IDs: pass as `String`/`int` path parameters, not full objects — refetch via provider by ID inside the destination screen so deep links work standalone.
