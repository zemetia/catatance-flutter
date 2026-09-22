# Blueprint Index

Cross-linked reference for AI agents. Every path is a backlink. Read this file first; navigate to specific docs via the table below.

---

## Document Map

| File | Coverage | Use When |
|---|---|---|
| [STRUCTURE.md](./STRUCTURE.md) | Every folder, file location, barrel exports | Finding where something lives |
| [ARCHITECTURE.md](./ARCHITECTURE.md) | App bootstrap, provider tree, DI, layering rules | Debugging system-level issues, wiring new features |
| [STATE.md](./STATE.md) | Riverpod providers/notifiers, async state patterns | Any state, loading/error handling |
| [DATABASE.md](./DATABASE.md) | Drift schema, tables, migrations, repositories | Any DB model or query work |
| [COMPONENTS.md](./COMPONENTS.md) | Four-file rule, widget composition, shared widgets | Building or modifying UI |
| [DESIGN_SYSTEM.md](./DESIGN_SYSTEM.md) | Theme tokens, typography, spacing, flex_color_scheme | Applying styles, adding tokens |
| [ROUTING.md](./ROUTING.md) | go_router setup, route names, guards, deep links | Adding a screen, navigation logic |
| [BEST_PRACTICE.md](./BEST_PRACTICE.md) | Dart/Flutter conventions, lint, anti-patterns | All code changes |
| [KNOWLEDGE.md](./KNOWLEDGE.md) | Rules for THIS.md + LEARN.md — the learning system | Before every task; after every correction or new insight |

---

## Stack Reference

| Package | Purpose | Config / Entry |
|---|---|---|
| flutter_riverpod / riverpod_annotation | State management | [lib/core/](../../lib/core/) providers |
| hooks_riverpod / flutter_hooks | Hooks-style local widget state | used inside `HookConsumerWidget` |
| go_router | Routing | [lib/core/router/](../../lib/core/router/) |
| drift + sqlite3_flutter_libs | Local database | [lib/core/database/](../../lib/core/database/) |
| freezed_annotation / json_annotation | Immutable models, serialization | `*.freezed.dart` / `*.g.dart` (generated) |
| flex_color_scheme | Theming | [lib/core/theme/](../../lib/core/theme/) |
| google_fonts | Typography | [lib/core/theme/](../../lib/core/theme/) |
| flutter_animate | Micro-interactions | used directly in widgets |
| fl_chart | Charts (spending, trends) | `features/reports/presentation` |
| flutter_slidable | Swipe actions on list items | transaction list widgets |
| shimmer | Loading skeletons | shared loading widgets |
| flutter_svg / flutter_lucide | Icons & vector assets | shared widgets |
| flutter_dotenv | Env config (optional, only if cloud sync is added) | `.env` at root |
| intl | Currency (Rupiah) & date formatting | `core/utils/formatters.dart` |

---

## Canonical Import Paths

```dart
// Theme
import 'package:pencatatan_keuangan/core/theme/app_theme.dart';
import 'package:pencatatan_keuangan/core/theme/app_colors.dart';
import 'package:pencatatan_keuangan/core/theme/app_spacing.dart';

// Router
import 'package:pencatatan_keuangan/core/router/app_router.dart';

// Database
import 'package:pencatatan_keuangan/core/database/app_database.dart';

// Utils
import 'package:pencatatan_keuangan/core/utils/formatters.dart';

// Shared widgets
import 'package:pencatatan_keuangan/core/widgets/widgets.dart';

// Feature (example: transactions)
import 'package:pencatatan_keuangan/features/transactions/domain/transaction.dart';
import 'package:pencatatan_keuangan/features/transactions/data/transaction_repository.dart';
import 'package:pencatatan_keuangan/features/transactions/presentation/transaction_list_screen.dart';
```

---

## Hard Constraints

| # | Rule | Violation |
|---|---|---|
| 1 | State only via Riverpod providers/notifiers | Raw `setState` for cross-widget or persisted state |
| 2 | Widgets never query Drift directly | Bypasses repository layer, breaks testability |
| 3 | `flutter analyze` must exit 0 | Lint/type errors |
| 4 | Domain models are `freezed` classes | Mutable plain classes for entities |
| 5 | Money stored as integer smallest-unit in DB | Float rounding errors in balances |
| 6 | Navigation only via `go_router` (`context.push`/`go`) | Raw `Navigator.push(MaterialPageRoute(...))` |
| 7 | Colors/spacing only from `core/theme/` tokens | Raw `Color(0xFF...)` or magic numbers in widgets |
| 8 | No cross-feature imports between `features/*` | Import via `core/` shared contracts instead |
| 9 | Every generated file (`*.freezed.dart`, `*.g.dart`) is committed only if `build_runner` was actually run | Stale generated code |
| 10 | Async state exposed as `AsyncValue<T>` (Riverpod) — always handle loading/error/data | Unhandled future/error in UI |

---

## File Creation Checklists

### New Feature Domain (e.g. `budgets`)

- [ ] `lib/features/budgets/domain/budget.dart` — freezed model
- [ ] `lib/features/budgets/data/budget_repository.dart` — Drift-backed repository
- [ ] `lib/features/budgets/presentation/budget_providers.dart` — Riverpod providers/notifiers
- [ ] `lib/features/budgets/presentation/budget_list_screen.dart` — screen widget
- [ ] Route registered in [ROUTING.md](./ROUTING.md) / `lib/core/router/app_router.dart`
- [ ] Table added to [DATABASE.md](./DATABASE.md) / `lib/core/database/app_database.dart` (if persisted)

### New Shared Widget

- [ ] `lib/core/widgets/<widget_name>/<widget_name>.dart` — implementation
- [ ] `lib/core/widgets/<widget_name>/<widget_name>.g.dart` (if applicable)
- [ ] Export added to `lib/core/widgets/widgets.dart` barrel
- [ ] Follows four-file rule in [COMPONENTS.md](./COMPONENTS.md)

### New Drift Table

- [ ] Table class added in `lib/core/database/tables/`
- [ ] Registered in `@DriftDatabase(tables: [...])` in `app_database.dart`
- [ ] Schema version bumped + migration step added
- [ ] Repository method added in the owning feature's `data/`
