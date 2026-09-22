# Project Structure

Feature-first. Each feature owns its full vertical slice; shared code lives in `core/`.

```
lib/
├── main.dart                      # entry point, bootstraps ProviderScope + App
├── app.dart                       # MaterialApp.router, theme + router wiring
│
├── core/                          # shared across all features
│   ├── theme/                     # design tokens, ThemeData, dark/light
│   │   ├── app_theme.dart
│   │   ├── app_colors.dart
│   │   └── app_spacing.dart
│   ├── router/
│   │   └── app_router.dart        # go_router config, all routes
│   ├── database/
│   │   ├── app_database.dart      # @DriftDatabase, migrations
│   │   └── tables/                # one file per table (accounts, categories, transactions)
│   ├── utils/
│   │   └── formatters.dart        # currency (Rupiah), date formatting
│   └── widgets/                   # shared/reusable widgets — flat files, see COMPONENTS.md
│       ├── app_card.dart
│       ├── app_shell.dart
│       ├── circle_icon_button.dart
│       ├── decorative_circle.dart
│       ├── empty_state_card.dart
│       ├── icon_badge.dart
│       ├── initials_avatar.dart
│       ├── menu_section.dart
│       ├── stat_card.dart
│       ├── suggestion_card.dart
│       ├── floating_nav_bar/      # only widget with its own folder (multi-part)
│       │   └── floating_nav_bar.dart
│       └── widgets.dart           # barrel export
│
├── features/
│   ├── dashboard/
│   │   └── presentation/          # home screen, summary cards
│   │       └── widgets/
│   ├── transactions/
│   │   ├── data/                  # empty — repository not yet implemented
│   │   ├── domain/                # empty — freezed models not yet implemented
│   │   └── presentation/          # screens only (add/list); no widgets/ subfolder yet
│   ├── categories/                # empty — no files in data/, domain/, or presentation/ yet
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── accounts/
│   │   ├── data/                  # account_repository.dart
│   │   ├── domain/                # account.dart (freezed)
│   │   └── presentation/          # account_providers.dart only; no screen yet
│   ├── budget/
│   │   └── presentation/          # budget_screen.dart, budget_providers.dart
│   │       └── widgets/           # progress/goal/wallet summary cards
│   ├── profile/
│   │   └── presentation/          # profile_screen.dart
│   │       └── widgets/           # header/balance cards
│   └── reports/
│       ├── data/                  # reports_repository.dart
│       ├── domain/                # report_models.dart (freezed)
│       └── presentation/          # multiple report screens (bulanan, kalender, proyeksi, radar harga)
│           └── widgets/           # charts (fl_chart) and shimmer placeholders
│
test/
└── widget_test.dart               # default smoke test only — no per-feature tests yet
```

## Rules

- A feature's `domain/` never imports from `data/` or `presentation/` — dependency direction is `presentation → data → domain`.
- `core/` never imports from `features/*`.
- Cross-feature communication happens through a shared provider in `core/` or by passing IDs, never by importing another feature's internals.
- Generated files (`*.freezed.dart`, `*.g.dart`) sit next to their source file, not in a separate folder.
- A feature's `presentation/widgets/` subfolder holds widgets used only within that feature; promote a widget to `core/widgets/` once a second feature needs it (see [COMPONENTS.md](./COMPONENTS.md)).

## Known gaps (as of this writing)

- `transactions/data/` and `transactions/domain/` are empty — transaction screens currently have no repository or freezed model backing them yet.
- `categories/` has no implementation at all (empty `data/`, `domain/`, `presentation/`).
- `accounts/presentation/` has providers but no screen.
- `test/` has only the default `widget_test.dart` — no feature-level widget or unit tests yet, despite the mirrored structure described above being the target layout.
- `app_typography.dart` and `constants/app_constants.dart` referenced in earlier drafts of this doc do not exist in `core/theme/` / `core/constants/` — typography lives inline in `app_theme.dart` via `google_fonts`, and there is no `core/constants/` folder yet.
