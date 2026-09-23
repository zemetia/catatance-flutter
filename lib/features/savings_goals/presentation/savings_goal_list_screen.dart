import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/widgets.dart';
import 'savings_goal_providers.dart';
import 'widgets/quick_deposit_sheet.dart';
import 'widgets/savings_calculator_sheet.dart';
import 'widgets/savings_goal_item_card.dart';

/// Complete, high-grade fintech Target Tabungan screen featuring an overview hero card,
/// quick deposit sheet, savings simulation calculator, search, filtering, and smart presets.
class SavingsGoalListScreen extends HookConsumerWidget {
  const SavingsGoalListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final selectedFilter = useState(0); // 0: Semua, 1: Berjalan, 2: Tercapai
    final selectedSort = useState('deadline'); // 'deadline', 'progress', 'amount', 'name'
    final isBalanceHidden = useState(false);
    final isSearchOpen = useState(false);
    final searchController = useTextEditingController();
    final searchQuery = useValueListenable(searchController);

    final goals = ref.watch(savingsGoalListProvider).value ?? const <SavingsGoal>[];
    final totalTarget = ref.watch(totalSavingsTargetProvider);
    final totalSaved = ref.watch(totalSavedAmountProvider);
    final achievedCount = ref.watch(achievedGoalsCountProvider);
    final monthlyAutoSave = ref.watch(totalMonthlyAutoSaveProvider);
    final activeAutoSaveCount = ref.watch(activeAutoSaveCountProvider);
    final nearestGoal = ref.watch(nearestSavingsGoalProvider);

    final remainingTotal = (totalTarget - totalSaved).clamp(0, totalTarget);
    final overallProgress = totalTarget > 0 ? (totalSaved / totalTarget).clamp(0.0, 1.0) : 0.0;
    final overallProgressPercent = (overallProgress * 100).round();

    // Filter by tab & search query
    var filteredGoals = goals.where((g) {
      if (selectedFilter.value == 1 && g.isAchieved) return false;
      if (selectedFilter.value == 2 && !g.isAchieved) return false;
      if (searchQuery.text.trim().isNotEmpty) {
        final query = searchQuery.text.trim().toLowerCase();
        return g.name.toLowerCase().contains(query);
      }
      return true;
    }).toList();

    // Sorting
    filteredGoals.sort((a, b) {
      switch (selectedSort.value) {
        case 'progress':
          return b.progress.compareTo(a.progress);
        case 'amount':
          return b.targetAmountCents.compareTo(a.targetAmountCents);
        case 'name':
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case 'deadline':
        default:
          if (a.targetDate == null && b.targetDate == null) return 0;
          if (a.targetDate == null) return 1;
          if (b.targetDate == null) return -1;
          return a.targetDate!.compareTo(b.targetDate!);
      }
    });

    // Milestone insight
    final highProgressGoal = goals.where((g) => !g.isAchieved && g.progress >= 0.70).firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Target Tabungan'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isSearchOpen.value ? LucideIcons.search_x : LucideIcons.search,
              size: 20,
            ),
            tooltip: 'Cari target',
            onPressed: () {
              isSearchOpen.value = !isSearchOpen.value;
              if (!isSearchOpen.value) {
                searchController.clear();
              }
            },
          ),
          IconButton(
            icon: const Icon(LucideIcons.calculator, size: 20),
            tooltip: 'Simulasi tabungan',
            onPressed: () => SavingsCalculatorSheet.show(context),
          ),
          IconButton(
            icon: const Icon(LucideIcons.plus),
            tooltip: 'Tambah target baru',
            onPressed: () => context.push('/savings-goals/new'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            FloatingNavBar.clearance,
          ),
          children: [
            // Search field when toggled open
            if (isSearchOpen.value) ...[
              Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Cari nama target tabungan...',
                    prefixIcon: const Icon(LucideIcons.search, size: 18),
                    suffixIcon: searchQuery.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(LucideIcons.x, size: 16),
                            onPressed: () => searchController.clear(),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ],

            // 1. Top Summary Hero Banner
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    scheme.primary,
                    scheme.primary.withValues(alpha: 0.8),
                    const Color(0xFF0F172A),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Title, Eye Icon & Achievement Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Total Terkumpul',
                            style: textTheme.labelMedium?.copyWith(
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: () => isBalanceHidden.value = !isBalanceHidden.value,
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                isBalanceHidden.value ? LucideIcons.eye_off : LucideIcons.eye,
                                size: 16,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          '$achievedCount / ${goals.length} Tercapai',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Large Balance
                  Text(
                    isBalanceHidden.value ? 'Rp ••••••••' : formatRupiah(totalSaved),
                    style: textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Overall Target Progress Line
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isBalanceHidden.value
                            ? 'Target: Rp ••••••••'
                            : 'dari target ${formatRupiah(totalTarget)}',
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '$overallProgressPercent%',
                        style: const TextStyle(
                          color: Color(0xFFC6FF3D),
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: overallProgress == 0 ? 0.02 : overallProgress,
                      minHeight: 7,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFC6FF3D),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // 3 Mini Stat Pills
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Row(
                      children: [
                        _StatColumn(
                          label: 'Sisa Target',
                          value: isBalanceHidden.value
                              ? '••••••'
                              : formatRupiahCompact(remainingTotal),
                          icon: LucideIcons.target,
                        ),
                        _statDivider(),
                        _StatColumn(
                          label: 'Autosave',
                          value: activeAutoSaveCount > 0
                              ? '${formatRupiahCompact(monthlyAutoSave)}/bln'
                              : 'Nonaktif',
                          icon: LucideIcons.zap,
                          iconColor: const Color(0xFFC6FF3D),
                        ),
                        _statDivider(),
                        _StatColumn(
                          label: 'Terdekat',
                          value: nearestGoal != null
                              ? nearestGoal.deadlineStatusLabel
                              : 'Tanpa tgl',
                          icon: LucideIcons.calendar,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // 2. Quick Action Hub
            Row(
              children: [
                _QuickActionTile(
                  icon: LucideIcons.plus,
                  label: 'Target Baru',
                  color: scheme.primary,
                  onTap: () => context.push('/savings-goals/new'),
                ),
                const SizedBox(width: AppSpacing.sm),
                _QuickActionTile(
                  icon: LucideIcons.coins,
                  label: 'Nabung Cepat',
                  color: const Color(0xFF2DD4BF),
                  onTap: () => QuickDepositSheet.show(context, goals: goals),
                ),
                const SizedBox(width: AppSpacing.sm),
                _QuickActionTile(
                  icon: LucideIcons.calculator,
                  label: 'Simulasi',
                  color: const Color(0xFFFBBF24),
                  onTap: () => SavingsCalculatorSheet.show(context),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // 3. Motivational / Milestone Banner (if goals exist)
            if (goals.isNotEmpty) ...[
              if (highProgressGoal != null)
                _MilestoneBanner(
                  icon: LucideIcons.flame,
                  iconColor: const Color(0xFFFF7043),
                  title: 'Sedikit lagi tercapai! 🔥',
                  message:
                      'Target "${highProgressGoal.name}" sudah ${highProgressGoal.progressPercentage}. Kurang ${highProgressGoal.formattedRemaining} lagi!',
                  actionLabel: 'Nabung Sekarang',
                  onAction: () => QuickDepositSheet.show(
                    context,
                    goals: goals,
                    initialGoalId: highProgressGoal.id,
                  ),
                )
              else if (achievedCount > 0 && achievedCount == goals.length)
                const _MilestoneBanner(
                  icon: LucideIcons.trophy,
                  iconColor: Color(0xFFFBBF24),
                  title: 'Luar biasa! Semua impian tercapai 🎉',
                  message:
                      'Seluruh target tabunganmu telah berhasil 100%. Saatnya bikin impian baru!',
                )
              else if (activeAutoSaveCount == 0)
                _MilestoneBanner(
                  icon: LucideIcons.sparkles,
                  iconColor: const Color(0xFF38BDF8),
                  title: 'Nabung Lebih Santai dengan Autosave',
                  message:
                      'Atur autosave pada targetmu agar saldo tersisih otomatis secara berkala.',
                  actionLabel: 'Pelajari',
                  onAction: () => SavingsCalculatorSheet.show(context),
                ),
              const SizedBox(height: AppSpacing.md),
            ],

            // 4. Filter & Sort Row
            Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(
                          label: 'Semua (${goals.length})',
                          isSelected: selectedFilter.value == 0,
                          onTap: () => selectedFilter.value = 0,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        _FilterChip(
                          label: 'Berjalan (${goals.length - achievedCount})',
                          isSelected: selectedFilter.value == 1,
                          onTap: () => selectedFilter.value = 1,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        _FilterChip(
                          label: 'Tercapai ($achievedCount)',
                          isSelected: selectedFilter.value == 2,
                          onTap: () => selectedFilter.value = 2,
                        ),
                      ],
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  initialValue: selectedSort.value,
                  icon: Icon(
                    LucideIcons.arrow_down_up,
                    size: 18,
                    color: scheme.outline,
                  ),
                  tooltip: 'Urutkan target',
                  onSelected: (val) => selectedSort.value = val,
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: 'deadline',
                      child: Text('Deadline Terdekat'),
                    ),
                    const PopupMenuItem(
                      value: 'progress',
                      child: Text('Progres Tertinggi'),
                    ),
                    const PopupMenuItem(
                      value: 'amount',
                      child: Text('Nominal Target Terbesar'),
                    ),
                    const PopupMenuItem(
                      value: 'name',
                      child: Text('Nama (A-Z)'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // 5. Goals List or Empty State with Presets
            if (filteredGoals.isEmpty) ...[
              if (searchQuery.text.isNotEmpty)
                EmptyStateCard(
                  icon: LucideIcons.search,
                  title: 'Target tidak ditemukan',
                  description:
                      'Tidak ada target tabungan yang cocok dengan "${searchQuery.text}".',
                )
              else if (selectedFilter.value != 0)
                EmptyStateCard(
                  icon: LucideIcons.target,
                  title: 'Tidak ada target di tab ini',
                  description: selectedFilter.value == 1
                      ? 'Semua target tabunganmu sudah tercapai penuh!'
                      : 'Belum ada target yang mencapai 100%. Ayo semangat menabung!',
                )
              else ...[
                const EmptyStateCard(
                  icon: LucideIcons.target,
                  title: 'Belum ada target tabungan',
                  description:
                      'Mulai buat target impianmu sekarang dengan target nominal & autosave teratur!',
                ),
                const SizedBox(height: AppSpacing.lg),

                // Inspiration Presets
                Text(
                  'Inspirasi Target Populer',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _InspirationPresetsGrid(),
              ],
            ] else ...[
              for (var i = 0; i < filteredGoals.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.md),
                SavingsGoalItemCard(
                  goal: filteredGoals[i],
                  delay: Duration(milliseconds: 30 * i),
                  onTap: () => context.push('/savings-goals/${filteredGoals[i].id}'),
                  onDeposit: () => QuickDepositSheet.show(
                    context,
                    goals: goals,
                    initialGoalId: filteredGoals[i].id,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/savings-goals/new'),
        icon: const Icon(LucideIcons.plus),
        label: const Text('Target Baru'),
      ),
    );
  }

  Widget _statDivider() {
    return Container(
      height: 28,
      width: 1,
      color: Colors.white.withValues(alpha: 0.15),
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 11,
                color: iconColor ?? Colors.white70,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: scheme.outline.withValues(alpha: 0.12),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MilestoneBanner extends StatelessWidget {
  const _MilestoneBanner({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: iconColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: TextStyle(
                    color: scheme.outline,
                    fontSize: 12,
                  ),
                ),
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: onAction,
                    child: Text(
                      '$actionLabel →',
                      style: TextStyle(
                        color: scheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InspirationPresetsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final presets = [
      (
        '🏖️ Liburan Impian',
        'plane',
        0,
        5000000,
        'Liburan',
      ),
      (
        '💻 Gadget / Laptop',
        'laptop',
        1,
        12000000,
        'Elektronik',
      ),
      (
        '🛡️ Dana Darurat',
        'health',
        2,
        15000000,
        'Darurat',
      ),
      (
        '🚗 Kendaraan / DP',
        'car',
        3,
        25000000,
        'Kendaraan',
      ),
    ];

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: presets.map((p) {
        return InkWell(
          onTap: () {
            context.push(
              '/savings-goals/new?name=${Uri.encodeComponent(p.$1)}&icon=${p.$2}&gradient=${p.$3}&target=${p.$4}',
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  p.$1,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  formatRupiahCompact(p.$4),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? scheme.primary
              : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : scheme.onSurface,
          ),
        ),
      ),
    );
  }
}
