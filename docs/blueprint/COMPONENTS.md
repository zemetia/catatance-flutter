# Components — Widget Conventions

## File convention (actual)

In practice, shared widgets in `core/widgets/` are flat single files, exported from the `widgets.dart` barrel:

```
core/widgets/
├── app_card.dart
├── stat_card.dart
├── icon_badge.dart
├── ...
└── widgets.dart            # barrel export — `export 'app_card.dart'; export 'stat_card.dart'; ...`
```

A widget only gets its own folder once it's more than a single implementation file (e.g. it needs generated code, sub-widgets, or assets alongside it) — `floating_nav_bar/` is the one example of this today:

```
core/widgets/floating_nav_bar/
└── floating_nav_bar.dart
```

For simple one-off widgets used by a single feature, a single file inside that feature's `presentation/widgets/` is fine — promote to `core/widgets/` (flat file, added to the barrel) only once reused by a second feature.

## Composition rules

- Prefer composition over configuration: many small widgets (`TransactionTile`, `AmountText`, `CategoryIcon`) over one widget with a dozen boolean flags.
- Widgets that read state: `ConsumerWidget` / `HookConsumerWidget`. Pure presentational widgets (no `ref`): plain `StatelessWidget`.
- Every custom widget class gets a `const` constructor where possible — enables Flutter's widget rebuild optimizations.
- No business logic inside `build()` beyond simple presentational branching — computation belongs in the provider/notifier or a plain Dart helper in `core/utils/`.

## Styling

- No inline `Color(0x...)`, raw `EdgeInsets.all(<number>)`, or hardcoded `TextStyle` — always pull from `core/theme/` (see [DESIGN_SYSTEM.md](./DESIGN_SYSTEM.md)).
- Animations via `flutter_animate` extension methods (`.fadeIn()`, `.slideY()`) instead of manual `AnimationController` for simple entrance/exit effects. Reach for a raw `AnimationController` only for complex, interruptible, or gesture-driven animation.

## Loading & empty states

- Every screen showing async data must handle three states explicitly: loading (shimmer, not a spinner, for list/card content), empty (friendly illustration/message), error (`AppErrorView` with retry action).
- Shimmer placeholders should mirror the shape of the real content (e.g. `TransactionTileShimmer` matches `TransactionTile`'s layout).

## Lists

- Use `flutter_slidable` for row-level actions (edit/delete) on transaction/account/category list items — swipe actions, not long-press context menus, for the primary delete/edit gesture.
- Use `ListView.builder`/`SliverList` for any potentially-long list — never `Column` + `.map()` for data-bound lists.

## Testing

- Widget tests live in `test/features/<domain>/presentation/`, mirroring the `lib/` path.
- Test behavior (does tapping delete call the repository method) not implementation details (internal widget tree shape).
