# Best Practice — Dart/Flutter Conventions

## Lint

- `flutter analyze` must exit 0 before any task is done.
- `analysis_options.yaml` extends `flutter_lints`; do not weaken rules without a documented reason added as a comment next to the disabled rule.

## Language

- `import type`-equivalent: no direct Dart concept, but keep imports sorted (package: then relative) and avoid unused imports — `flutter analyze` catches this.
- Prefer `final`/`const` everywhere possible; a mutable top-level or instance variable needs a reason.
- Null-safety: no `!` unless the nullability is genuinely impossible and provably so — prefer `??`, pattern matching, or restructuring to avoid the null case.
- Use Dart 3 pattern matching / records where they simplify code (e.g. destructuring a repository result) instead of nested if/else on nullable fields.

## Naming

- Files: `snake_case.dart`. Classes: `PascalCase`. Providers/variables: `camelCase`.
- Provider variables always end in `Provider` (see [STATE.md](./STATE.md)).
- Freezed model files: `<entity>.dart` containing `@freezed class Entity with _$Entity`.

## Anti-patterns to avoid

- `StatefulWidget` used to hold data that should be a Riverpod provider (anything another widget needs, or that should survive a rebuild higher up the tree).
- Business logic (calculations, formatting decisions, DB calls) inside `build()`.
- Passing `BuildContext` into repositories/notifiers — keep `data/`/`domain/` Flutter-free where possible.
- Catching exceptions only to `print()` them — either handle, rethrow as a typed exception, or let `AsyncValue.guard` capture it.
- God widgets: a `build()` method over ~100 lines is a sign to extract child widgets.
- Hardcoded strings for user-facing text scattered across widgets — centralize once localization (`intl`/ARB files) is introduced.

## Testing expectations

- New repository methods get a unit test using an in-memory Drift database (`NativeDatabase.memory()`).
- New notifiers/providers get a test using `ProviderContainer` + `addTearDown(container.dispose)`.
- Widget tests for screens with non-trivial interaction logic (forms, swipe-to-delete confirmation).

## Codegen discipline

- After editing any `@freezed`, `@JsonSerializable`, `@riverpod`, or Drift table: run
  ```bash
  dart run build_runner build --delete-conflicting-outputs
  ```
- Never hand-edit a generated (`*.g.dart`, `*.freezed.dart`) file.
