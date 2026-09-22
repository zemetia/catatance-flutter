# Flutter Template — Pencatatan Keuangan

## CRITICAL — Read Before Anything Else

> These two files are the most important context in this project. Read them at the start of every task, before touching any blueprint section or code.

| File | Purpose |
|---|---|
| [docs/knowledge/THIS.md](docs/knowledge/THIS.md) | Developer style, project identity, do's & don'ts, ongoing insights |
| [docs/knowledge/LEARN.md](docs/knowledge/LEARN.md) | Past mistakes and corrections — read to avoid repeating them |

**Writing rules:**
- After any task where a new insight or preference is discovered → append to `THIS.md`
- When the user corrects the AI, or the AI self-identifies a mistake → append to `LEARN.md` immediately using format: `[YYYY-MM-DD] - [problem] - [solution] - [lesson]`

---

> **AI agents — before planning any fix or feature:** identify which blueprint sections cover the affected area, read them first, then plan. Do not guess at patterns — the blueprint is the source of truth.

## Blueprint

| Section | File |
|---|---|
| Index + hard constraints + checklists | [docs/blueprint/INDEX.md](docs/blueprint/INDEX.md) |
| Project structure + file locations | [docs/blueprint/STRUCTURE.md](docs/blueprint/STRUCTURE.md) |
| App lifecycle, DI, provider wiring | [docs/blueprint/ARCHITECTURE.md](docs/blueprint/ARCHITECTURE.md) |
| Riverpod state patterns | [docs/blueprint/STATE.md](docs/blueprint/STATE.md) |
| Drift schema + migrations | [docs/blueprint/DATABASE.md](docs/blueprint/DATABASE.md) |
| Widget structure + four-file rule | [docs/blueprint/COMPONENTS.md](docs/blueprint/COMPONENTS.md) |
| Design tokens, theme, typography | [docs/blueprint/DESIGN_SYSTEM.md](docs/blueprint/DESIGN_SYSTEM.md) |
| go_router routes + navigation | [docs/blueprint/ROUTING.md](docs/blueprint/ROUTING.md) |
| Dart/Flutter conventions, lint, anti-patterns | [docs/blueprint/BEST_PRACTICE.md](docs/blueprint/BEST_PRACTICE.md) |
| Knowledge system rules | [docs/blueprint/KNOWLEDGE.md](docs/blueprint/KNOWLEDGE.md) |

## Stack snapshot

Flutter (stable) · Dart 3 · Riverpod (+ riverpod_generator) · go_router · Drift (SQLite) · freezed + json_serializable · flex_color_scheme · google_fonts · flutter_animate · fl_chart · flutter_slidable · shimmer · flutter_hooks

## Non-negotiables

- State: Riverpod only — no raw `StatefulWidget` state for anything beyond pure local UI (animation controllers, text field focus)
- Data access: never touch Drift tables from a widget — go through a repository in `features/<domain>/data/`
- Models crossing layers: `freezed` immutable classes only — no plain mutable classes for domain entities
- Colors & spacing: design tokens from `core/theme/` only — no raw `Color(0x...)` or magic numbers in widgets
- Navigation: `go_router` only — no `Navigator.push` with raw routes
- Money values: store as integer (cents/smallest unit) in DB, format with `intl` at the UI edge only — never do arithmetic on formatted strings
- Every new widget follows the four-file rule — see [COMPONENTS.md](docs/blueprint/COMPONENTS.md)
- `flutter analyze` must exit 0 before any task is considered done
- Feature code lives under `lib/features/<domain>/{data,domain,presentation}` — never add cross-feature imports directly; go through `core/` or a shared contract
