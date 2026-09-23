import 'package:drift/drift.dart';

/// Records the first moment a badge (Lencana) was unlocked, keyed by the
/// static catalog key in `features/badges/domain/badge_catalog.dart`
/// (never a Drift row id — the catalog itself is in-memory, not persisted).
/// Once a row exists for a `badgeKey`, that badge stays unlocked even if the
/// live metric it was computed from later regresses (e.g. a savings-rate
/// badge after a spendier month) — achievements are meant to be sticky.
class EarnedBadges extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get badgeKey => text().unique()();
  DateTimeColumn get earnedAt => dateTime().withDefault(currentDateAndTime)();
}
