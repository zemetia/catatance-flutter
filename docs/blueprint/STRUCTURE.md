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
│   │   └── presentation/          # account_providers.dart, wallet_list_screen.dart
│   │       │                      # ("Semua dompet"), wallet_form_screen.dart
│   │       │                      # ("Dompet baru"), wallet_transfer_screen.dart
│   │       └── widgets/           # amount_keypad.dart, wallet_picker_sheet.dart
│   ├── budget/
│   │   ├── data/                  # budget_repository.dart
│   │   ├── domain/                # budget.dart, budget_period_type.dart
│   │   └── presentation/          # budget_screen.dart (Anggaran tab), budget_list_screen.dart
│   │       │                      # ("Semua Anggaran"), budget_form_screen.dart (create/edit),
│   │       │                      # budget_providers.dart
│   │       └── widgets/           # progress/goal/wallet summary cards, category picker sheet
│   ├── profile/
│   │   └── presentation/          # profile_screen.dart
│   │       └── widgets/           # header/balance cards
│   ├── debts/
│   │   ├── data/                  # debt_repository.dart
│   │   ├── domain/                # debt.dart, debt_payment.dart, debt_type.dart
│   │   └── presentation/          # debt_providers.dart, debt_list_screen.dart,
│   │       │                      # debt_form_screen.dart, debt_detail_screen.dart
│   │       └── widgets/           # debt_card.dart, debt_summary_header.dart, payment_bottom_sheet.dart
│   ├── reports/
│   │   ├── data/                  # reports_repository.dart
│   │   ├── domain/                # report_models.dart (freezed)
│   │   └── presentation/          # multiple report screens (bulanan, kalender, proyeksi, radar harga)
│   │       └── widgets/           # charts (fl_chart) and shimmer placeholders
│   ├── split_bills/                # Patungan (group bill): pay for a group, one expense
│   │   ├── data/                  # split_bill_repository.dart
│   │   ├── domain/                # split_bill.dart
│   │   └── presentation/          # split_bill_providers.dart, split_bill_form_screen.dart
│   │                              # (route /split-bills/new, opened from AddTransactionScreen's
│   │                              #  "Patungan" chip); participant shares become Debts
│   │                              #  (type=receivable) rows via Debts.splitBillId, so
│   │                              #  repayment reuses the existing debts feature as-is
│   ├── installments/               # Cicilan: fixed monthly amount over a fixed tenor
│   │   ├── data/                  # installment_repository.dart
│   │   ├── domain/                # installment.dart, installment_payment.dart, installment_status.dart
│   │   └── presentation/          # installment_providers.dart, installment_list_screen.dart,
│   │       │                      # installment_form_screen.dart (route /installments/new,
│   │       │                      # /installments/:id/edit), installment_detail_screen.dart
│   │       │                      # (route /installments/:id, opened from Profile > "Cicilan")
│   │       └── widgets/           # installment_card.dart, installment_summary_header.dart,
│   │                              # installment_payment_bottom_sheet.dart, category_picker_sheet.dart
│   │
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
- `accounts/presentation/` now has wallet screens (list/new/transfer) but no edit-wallet screen yet.
- `test/database/` and `test/features/` have real repository/database tests; `test/widget_test.dart` is a stale default smoke test (looks for old placeholder text/`NavigationBar`) that predates the current shell UI and currently fails — needs updating to match `AppShell`/`FloatingNavBar`, not a regression from any single feature change.
- `app_typography.dart` and `constants/app_constants.dart` referenced in earlier drafts of this doc do not exist in `core/theme/` / `core/constants/` — typography lives inline in `app_theme.dart` via `google_fonts`, and there is no `core/constants/` folder yet.
