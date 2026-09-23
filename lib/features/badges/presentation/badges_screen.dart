import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/widgets.dart';
import '../domain/badge_progress.dart';
import '../domain/badge_tier.dart';
import 'badge_providers.dart';
import 'widgets/badge_card.dart';
import 'widgets/badge_card_shimmer.dart';
import 'widgets/badge_detail_sheet.dart';

class BadgesScreen extends ConsumerWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final badgesAsync = ref.watch(badgeProgressListProvider);
    final summary = ref.watch(badgeSummaryProvider);
    final filteredBadges = ref.watch(filteredBadgesProvider);
    final tierFilter = ref.watch(badgeTierFilterProvider);
    final unlockedOnly = ref.watch(badgeUnlockedOnlyFilterProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                0,
              ),
              child: Row(
                children: [
                  CircleIconButton(
                    icon: LucideIcons.chevron_left,
                    backgroundColor: scheme.surfaceContainerHigh,
                    onTap: () => context.pop(),
                  ),
                  Expanded(
                    child: Text(
                      'Lencana',
                      textAlign: TextAlign.center,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            Expanded(
              child: badgesAsync.when(
                data: (_) => _BadgesContent(
                  summary: summary,
                  filteredBadges: filteredBadges,
                  tierFilter: tierFilter,
                  unlockedOnly: unlockedOnly,
                ),
                loading: () => const _BadgesLoading(),
                error: (err, _) =>
                    Center(child: Text('Gagal memuat lencana: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgesContent extends ConsumerWidget {
  const _BadgesContent({
    required this.summary,
    required this.filteredBadges,
    required this.tierFilter,
    required this.unlockedOnly,
  });

  final BadgeSummary summary;
  final List<BadgeProgress> filteredBadges;
  final BadgeTier? tierFilter;
  final bool unlockedOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: AppCard(
              child: Row(
                children: [
                  IconBadge(
                    icon: LucideIcons.award,
                    size: 26,
                    padding: const EdgeInsets.all(AppSpacing.md),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${summary.unlockedCount} dari ${summary.totalCount} lencana diraih',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                          child: LinearProgressIndicator(
                            value: summary.ratio == 0 ? 0.02 : summary.ratio,
                            minHeight: 6,
                            backgroundColor: scheme.outline.withValues(alpha: 0.15),
                            color: scheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          sliver: SliverToBoxAdapter(
            child: SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _FilterChip(
                    label: 'Semua',
                    selected: tierFilter == null,
                    onTap: () =>
                        ref.read(badgeTierFilterProvider.notifier).state = null,
                  ),
                  for (final tier in BadgeTier.values) ...[
                    const SizedBox(width: AppSpacing.sm),
                    _FilterChip(
                      label: tier.label,
                      color: tier.color,
                      selected: tierFilter == tier,
                      onTap: () => ref
                          .read(badgeTierFilterProvider.notifier)
                          .state = tier,
                    ),
                  ],
                  const SizedBox(width: AppSpacing.sm),
                  _FilterChip(
                    label: 'Diraih saja',
                    icon: LucideIcons.circle_check_big,
                    selected: unlockedOnly,
                    onTap: () => ref
                        .read(badgeUnlockedOnlyFilterProvider.notifier)
                        .state = !unlockedOnly,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (filteredBadges.isEmpty)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            sliver: SliverToBoxAdapter(
              child: EmptyStateCard(
                icon: LucideIcons.award,
                title: 'Belum ada lencana di sini',
                description: 'Coba ubah filter atau terus catat aktivitas keuanganmu.',
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.xl,
            ),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.sm,
                crossAxisSpacing: AppSpacing.sm,
                childAspectRatio: 0.82,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final progress = filteredBadges[index];
                  return BadgeCard(
                    progress: progress,
                    delay: Duration(milliseconds: 30 * (index % 8)),
                    onTap: () => showBadgeDetailSheet(context, progress),
                  );
                },
                childCount: filteredBadges.length,
              ),
            ),
          ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = color ?? scheme.primary;

    return Material(
      color: selected ? accent.withValues(alpha: 0.16) : scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: selected ? accent : scheme.outline),
                const SizedBox(width: AppSpacing.xs),
              ],
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: selected ? accent : scheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BadgesLoading extends StatelessWidget {
  const _BadgesLoading();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 0.82,
      ),
      itemCount: 8,
      itemBuilder: (context, index) => const BadgeCardShimmer(),
    );
  }
}
