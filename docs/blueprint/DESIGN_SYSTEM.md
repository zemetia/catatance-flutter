# Design System

## Theming engine

`flex_color_scheme` generates the full Material 3 `ThemeData` (light + dark) from a small seed palette — do not hand-write `ColorScheme` fields individually.

`core/theme/app_theme.dart`:

```dart
ThemeData buildLightTheme() => FlexThemeData.light(
      scheme: FlexScheme.money,           // or a custom FlexSchemeColor
      useMaterial3: true,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
    );

ThemeData buildDarkTheme() => FlexThemeData.dark(
      scheme: FlexScheme.money,
      useMaterial3: true,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
    );
```

Wire both into `MaterialApp.router(theme:, darkTheme:, themeMode: ThemeMode.system)` (or a Riverpod-backed theme mode toggle later).

## Tokens

`core/theme/app_colors.dart` — semantic colors beyond what `ColorScheme` covers (e.g. `income`, `expense`, `warning`), derived from the same seed so light/dark stay consistent:

```dart
class AppColors {
  static const income = Color(0xFF2E7D32);
  static const expense = Color(0xFFC62828);
}
```

`core/theme/app_spacing.dart` — spacing scale, used everywhere instead of magic numbers:

```dart
class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}
```

`core/theme/app_typography.dart` — text style helpers layered on `Theme.of(context).textTheme`, using `google_fonts` for the family.

## Typography

Pick one Google Font pairing and commit to it project-wide (e.g. `Plus Jakarta Sans` or `Inter` for a clean fintech look). Never mix ad-hoc `TextStyle(fontFamily: ...)` calls — always go through `Theme.of(context).textTheme.*` or a documented `AppTypography` helper.

## Iconography

`flutter_lucide` for consistent line icons across the app; category icons can additionally use `flutter_svg` for custom illustrated icon sets if added later.

## Motion

- Entrance animations: `flutter_animate` (`.fadeIn(duration: 200.ms).slideY(begin: 0.1)`) on list items and cards.
- Loading: `shimmer` package, styled with `AppColors` base/highlight tuned per light/dark theme — never a bare `CircularProgressIndicator` for content placeholders.
- Keep animation durations short (150–300ms) and consistent — define shared durations as constants in `app_theme.dart` rather than repeating magic ms values.

## Visual style

Target a clean, modern "fintech dashboard" look: generous whitespace (`AppSpacing.md`/`lg` between sections), soft elevation/shadows over hard borders, rounded corners (12–16px radius) via `FlexThemeData`'s `subThemesData`, and a single accent color for primary actions (add transaction, save).
