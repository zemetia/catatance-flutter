import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../core/database/app_database.dart';
import '../data/badge_repository.dart';
import '../domain/badge_progress.dart';
import '../domain/badge_tier.dart';

final badgeRepositoryProvider = Provider<BadgeRepository>((ref) {
  return BadgeRepository(ref.watch(appDatabaseProvider));
});

/// Live progress for every badge in the catalog, recomputed whenever any
/// table a badge depends on changes.
final badgeProgressListProvider =
    StreamProvider.autoDispose<List<BadgeProgress>>((ref) {
  return ref.watch(badgeRepositoryProvider).watchAll();
});

/// How many badges are unlocked out of the full catalog.
class BadgeSummary {
  const BadgeSummary({required this.unlockedCount, required this.totalCount});

  final int unlockedCount;
  final int totalCount;

  double get ratio => totalCount == 0 ? 0 : unlockedCount / totalCount;
}

final badgeSummaryProvider = Provider.autoDispose<BadgeSummary>((ref) {
  final badges = ref.watch(badgeProgressListProvider).value ?? const [];
  return BadgeSummary(
    unlockedCount: badges.where((b) => b.isUnlocked).length,
    totalCount: badges.length,
  );
});

/// Tier filter shown as chips at the top of the Lencana screen — `null`
/// means "Semua" (no filter).
final badgeTierFilterProvider = StateProvider.autoDispose<BadgeTier?>(
  (ref) => null,
);

/// Whether to show only unlocked badges.
final badgeUnlockedOnlyFilterProvider = StateProvider.autoDispose<bool>(
  (ref) => false,
);

final filteredBadgesProvider = Provider.autoDispose<List<BadgeProgress>>((
  ref,
) {
  final badges = ref.watch(badgeProgressListProvider).value ?? const [];
  final tier = ref.watch(badgeTierFilterProvider);
  final unlockedOnly = ref.watch(badgeUnlockedOnlyFilterProvider);

  return badges.where((b) {
    if (tier != null && b.definition.tier != tier) return false;
    if (unlockedOnly && !b.isUnlocked) return false;
    return true;
  }).toList();
});
