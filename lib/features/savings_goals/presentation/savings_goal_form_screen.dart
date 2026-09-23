import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../accounts/presentation/account_providers.dart';
import 'savings_goal_providers.dart';
import 'widgets/gallery_theme_sheet.dart';
import 'widgets/savings_goal_preview_card.dart';

/// Form screen for creating or editing a Target Tabungan matching the reference mockup.
class SavingsGoalFormScreen extends HookConsumerWidget {
  const SavingsGoalFormScreen({
    this.goalId,
    this.initialName,
    this.initialIconKey,
    this.initialGradientIndex,
    this.initialTargetAmountCents,
    this.initialTargetDate,
    super.key,
  });

  final int? goalId;
  final String? initialName;
  final String? initialIconKey;
  final int? initialGradientIndex;
  final int? initialTargetAmountCents;
  final DateTime? initialTargetDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Load existing goal if editing
    final existingGoal = goalId != null
        ? ref.watch(savingsGoalDetailProvider(goalId!)).value
        : null;

    final nameController = useTextEditingController();
    final targetAmountController = useTextEditingController();
    final autoSaveAmountController = useTextEditingController();
    final noteController = useTextEditingController();

    final selectedIconKey = useState(initialIconKey ?? 'plane');
    final selectedGradientIndex = useState(initialGradientIndex ?? 1);
    final targetDate = useState<DateTime?>(initialTargetDate);
    final noDeadline = useState(initialTargetDate == null);
    final autoSaveEnabled = useState(false);
    final autoSaveFrequency = useState('monthly');
    final selectedAccountId = useState<int?>(null);
    final initialDepositAmount = useState<int>(0);

    final isInitialized = useState(false);

    // Populate existing values when editing or initial values when creating
    useEffect(() {
      if (existingGoal != null && !isInitialized.value) {
        nameController.text = existingGoal.name;
        targetAmountController.text =
            NumberFormat('#,###', 'id_ID').format(existingGoal.targetAmountCents);
        selectedIconKey.value = existingGoal.iconKey;
        selectedGradientIndex.value = existingGoal.gradientIndex;
        targetDate.value = existingGoal.targetDate;
        noDeadline.value = existingGoal.targetDate == null;
        autoSaveEnabled.value = existingGoal.autoSaveEnabled;
        if (existingGoal.autoSaveAmountCents > 0) {
          autoSaveAmountController.text = NumberFormat('#,###', 'id_ID')
              .format(existingGoal.autoSaveAmountCents);
        }
        autoSaveFrequency.value = existingGoal.autoSaveFrequency;
        selectedAccountId.value = existingGoal.sourceAccountId;
        if (existingGoal.note != null) {
          noteController.text = existingGoal.note!;
        }
        isInitialized.value = true;
      } else if (existingGoal == null && !isInitialized.value) {
        if (initialName != null) {
          nameController.text = initialName!;
        }
        if (initialTargetAmountCents != null && initialTargetAmountCents! > 0) {
          targetAmountController.text =
              NumberFormat('#,###', 'id_ID').format(initialTargetAmountCents);
        }
        if (initialTargetDate != null) {
          targetDate.value = initialTargetDate;
          noDeadline.value = false;
        }
        isInitialized.value = true;
      }
      return null;
    }, [existingGoal]);

    // Accounts for wallet selector
    final accounts = ref.watch(accountListProvider).value ?? const [];
    useEffect(() {
      if (selectedAccountId.value == null && accounts.isNotEmpty) {
        // Pick default wallet if available, else first
        final defaultWallet = accounts.firstWhere(
          (a) => a.isDefault,
          orElse: () => accounts.first,
        );
        selectedAccountId.value = defaultWallet.id;
      }
      return null;
    }, [accounts]);

    final name = useValueListenable(nameController);
    final targetText = useValueListenable(targetAmountController);
    final autoSaveText = useValueListenable(autoSaveAmountController);

    final targetAmount = _parseAmount(targetText.text);
    final autoSaveAmount = _parseAmount(autoSaveText.text);

    final selectedIconOption = SavingsGoalIcons.get(selectedIconKey.value);
    final selectedGradient =
        SavingsGoalGradients.at(selectedGradientIndex.value);

    final actionState = ref.watch(savingsGoalActionProvider);
    final isSubmitting = actionState is AsyncLoading;
    final canSubmit = name.text.trim().isNotEmpty &&
        targetAmount > 0 &&
        !isSubmitting &&
        (!autoSaveEnabled.value || autoSaveAmount > 0);

    Future<void> submit() async {
      if (!canSubmit) return;

      final draft = SavingsGoalDraft(
        name: name.text.trim(),
        iconKey: selectedIconKey.value,
        gradientIndex: selectedGradientIndex.value,
        targetAmountCents: targetAmount,
        currentAmountCents: goalId == null ? initialDepositAmount.value : 0,
        targetDate: noDeadline.value ? null : targetDate.value,
        autoSaveEnabled: autoSaveEnabled.value,
        autoSaveAmountCents: autoSaveEnabled.value ? autoSaveAmount : 0,
        autoSaveFrequency: autoSaveFrequency.value,
        sourceAccountId: selectedAccountId.value,
        note: noteController.text.trim().isNotEmpty
            ? noteController.text.trim()
            : null,
      );

      final notifier = ref.read(savingsGoalActionProvider.notifier);
      if (goalId == null) {
        await notifier.createGoal(draft);
      } else {
        await notifier.updateGoal(goalId!, draft);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              goalId == null
                  ? 'Target tabungan berhasil dibuat! 🎉'
                  : 'Perubahan target berhasil disimpan',
            ),
            backgroundColor: const Color(0xFF2E7D32),
          ),
        );
        context.pop();
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.x),
          onPressed: () => context.pop(),
        ),
        title: Text(goalId == null ? 'Target tabungan' : 'Edit target tabungan'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  // 1. Interactive Preview Card matching mockup
                  SavingsGoalPreviewCard(
                    name: name.text,
                    iconOption: selectedIconOption,
                    gradient: selectedGradient,
                    targetAmountCents: targetAmount,
                    currentAmountCents: goalId != null
                        ? (existingGoal?.currentAmountCents ?? 0)
                        : initialDepositAmount.value,
                    targetDate: noDeadline.value ? null : targetDate.value,
                    autoSaveEnabled: autoSaveEnabled.value,
                    autoSaveAmountCents: autoSaveAmount,
                    autoSaveFrequency: autoSaveFrequency.value,
                    showProgress: goalId != null,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // 2. Nama Target Input Card
                  _FormSectionCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            LucideIcons.pencil,
                            size: 20,
                            color: scheme.primary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nama target',
                                style: textTheme.labelSmall?.copyWith(
                                  color: scheme.outline,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              TextField(
                                controller: nameController,
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                                decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  border: InputBorder.none,
                                  hintText: 'cth: Liburan Bali',
                                ),
                                textCapitalization: TextCapitalization.words,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // 3. Ikon Selector Card
                  _FormSectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ikon',
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        SizedBox(
                          height: 60,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: SavingsGoalIcons.options.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: AppSpacing.sm),
                            itemBuilder: (context, index) {
                              final opt = SavingsGoalIcons.options[index];
                              final isSelected =
                                  selectedIconKey.value == opt.key;

                              return InkWell(
                                onTap: () => selectedIconKey.value = opt.key,
                                borderRadius: BorderRadius.circular(16),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF1E2228)
                                        : scheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFFC6FF3D) // Lime highlight
                                          : Colors.transparent,
                                      width: 2.2,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: const Color(0xFFC6FF3D)
                                                  .withValues(alpha: 0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    opt.emoji,
                                    style: const TextStyle(fontSize: 26),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // 4. Warna & Gradien Card
                  _FormSectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Warna',
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        // Swatches grid (2 rows: 5 swatches top, 3 swatches bottom matching mock)
                        LayoutBuilder(
                          builder: (context, constraints) {
                            const countPerRow = 5;
                            const spacing = 10.0;
                            final swatchSize = ((constraints.maxWidth - (countPerRow - 1) * spacing) / countPerRow)
                                .clamp(44.0, 56.0);

                            Widget buildSwatch(int i) {
                              final gradient = SavingsGoalGradients.at(i);
                              final isSelected = selectedGradientIndex.value == i;

                              return InkWell(
                                onTap: () => selectedGradientIndex.value = i,
                                borderRadius: BorderRadius.circular(14),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  width: swatchSize,
                                  height: swatchSize,
                                  decoration: BoxDecoration(
                                    gradient: gradient,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.transparent,
                                      width: isSelected ? 3 : 1,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: gradient.colors.first
                                                  .withValues(alpha: 0.5),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  alignment: Alignment.center,
                                  child: isSelected
                                      ? const Icon(
                                          LucideIcons.check,
                                          size: 20,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                              );
                            }

                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: List.generate(5, (i) => buildSwatch(i)),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    for (var i = 5; i < 8; i++) ...[
                                      buildSwatch(i),
                                      if (i < 7) const SizedBox(width: spacing),
                                    ],
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                // Auto-assign a gradient based on current name/icon
                                final hash =
                                    (name.text.hashCode ^ selectedIconKey.value.hashCode).abs();
                                selectedGradientIndex.value =
                                    hash % SavingsGoalGradients.presets.length;
                              },
                              icon: const Icon(LucideIcons.sparkles, size: 16),
                              label: const Text('atau biarkan otomatis'),
                              style: TextButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 1),
                        InkWell(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => GalleryThemeSheet(
                                selectedIndex: selectedGradientIndex.value,
                                onSelect: (idx) =>
                                    selectedGradientIndex.value = idx,
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.sm,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: scheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    LucideIcons.images,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Text(
                                    'Pilih dari galeri',
                                    style: textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Icon(
                                  LucideIcons.chevron_right,
                                  size: 18,
                                  color: scheme.outline,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // 5. Target Tabungan (Nominal & Deadline)
                  _FormSectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: scheme.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                LucideIcons.target,
                                size: 18,
                                color: scheme.primary,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              'Target Nominal Tabungan',
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextField(
                          controller: targetAmountController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            _ThousandSeparatorFormatter(),
                          ],
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                          decoration: InputDecoration(
                            prefixText: 'Rp ',
                            prefixStyle: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: scheme.primary,
                            ),
                            hintText: '0',
                            filled: true,
                            fillColor: scheme.surfaceContainerHighest,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        // Quick increment chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _QuickAddChip(
                                label: '+1 Jt',
                                onTap: () => _addToController(
                                  targetAmountController,
                                  1000000,
                                ),
                              ),
                              _QuickAddChip(
                                label: '+5 Jt',
                                onTap: () => _addToController(
                                  targetAmountController,
                                  5000000,
                                ),
                              ),
                              _QuickAddChip(
                                label: '+10 Jt',
                                onTap: () => _addToController(
                                  targetAmountController,
                                  10000000,
                                ),
                              ),
                              _QuickAddChip(
                                label: '+25 Jt',
                                onTap: () => _addToController(
                                  targetAmountController,
                                  25000000,
                                ),
                              ),
                              _QuickAddChip(
                                label: 'Reset',
                                isReset: true,
                                onTap: () => targetAmountController.text = '',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        const Divider(height: 1),
                        const SizedBox(height: AppSpacing.sm),

                        // Deadline Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Batas Waktu (Deadline)',
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  noDeadline.value
                                      ? 'Tabung santai tanpa batas waktu'
                                      : targetDate.value != null
                                          ? 'Jatuh tempo: ${formatDate(targetDate.value!)}'
                                          : 'Pilih tanggal target',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: scheme.outline,
                                  ),
                                ),
                              ],
                            ),
                            Switch.adaptive(
                              value: !noDeadline.value,
                              onChanged: (hasDeadline) async {
                                noDeadline.value = !hasDeadline;
                                if (hasDeadline && targetDate.value == null) {
                                  final now = DateTime.now();
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate:
                                        now.add(const Duration(days: 90)),
                                    firstDate:
                                        now.add(const Duration(days: 1)),
                                    lastDate:
                                        now.add(const Duration(days: 3650)),
                                  );
                                  if (picked != null) {
                                    targetDate.value = picked;
                                  } else {
                                    noDeadline.value = true;
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                        if (!noDeadline.value && targetDate.value != null) ...[
                          const SizedBox(height: AppSpacing.xs),
                          OutlinedButton.icon(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: targetDate.value ?? DateTime.now(),
                                firstDate: DateTime.now()
                                    .add(const Duration(days: 1)),
                                lastDate: DateTime.now()
                                    .add(const Duration(days: 3650)),
                              );
                              if (picked != null) {
                                targetDate.value = picked;
                              }
                            },
                            icon: const Icon(LucideIcons.calendar, size: 16),
                            label: Text(
                              'Ganti tanggal: ${formatDate(targetDate.value!)}',
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // 6. Autosave (Tabung Otomatis Switch on/off)
                  _FormSectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFC6FF3D)
                                        .withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    LucideIcons.zap,
                                    size: 18,
                                    color: Color(0xFFC6FF3D),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Autosave (Tabung Otomatis)',
                                      style: textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      'Nabung terjadwal otomatis dari dompet',
                                      style: textTheme.bodySmall?.copyWith(
                                        color: scheme.outline,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Switch.adaptive(
                              value: autoSaveEnabled.value,
                              activeTrackColor: const Color(0xFFC6FF3D),
                              onChanged: (val) {
                                autoSaveEnabled.value = val;
                                if (val && autoSaveAmountController.text.isEmpty) {
                                  // Suggest an autosave amount (e.g. 500.000 or target / 10)
                                  final suggested = targetAmount > 0
                                      ? (targetAmount / 10).round()
                                      : 500000;
                                  autoSaveAmountController.text =
                                      NumberFormat('#,###', 'id_ID')
                                          .format(suggested);
                                }
                              },
                            ),
                          ],
                        ),

                        // Sub-options when Autosave is turned ON
                        if (autoSaveEnabled.value) ...[
                          const SizedBox(height: AppSpacing.md),
                          const Divider(height: 1),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Nominal ditabung per periode',
                            style: textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          TextField(
                            controller: autoSaveAmountController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              _ThousandSeparatorFormatter(),
                            ],
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                            decoration: InputDecoration(
                              prefixText: 'Rp ',
                              prefixStyle: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: scheme.primary,
                              ),
                              hintText: '500.000',
                              filled: true,
                              fillColor: scheme.surfaceContainerHighest,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _QuickAddChip(
                                  label: '+100 Rb',
                                  onTap: () => _addToController(
                                    autoSaveAmountController,
                                    100000,
                                  ),
                                ),
                                _QuickAddChip(
                                  label: '+250 Rb',
                                  onTap: () => _addToController(
                                    autoSaveAmountController,
                                    250000,
                                  ),
                                ),
                                _QuickAddChip(
                                  label: '+500 Rb',
                                  onTap: () => _addToController(
                                    autoSaveAmountController,
                                    500000,
                                  ),
                                ),
                                _QuickAddChip(
                                  label: '+1 Jt',
                                  onTap: () => _addToController(
                                    autoSaveAmountController,
                                    1000000,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Frekuensi Menabung',
                            style: textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          SegmentedButton<String>(
                            segments: const [
                              ButtonSegment(
                                value: 'daily',
                                label: Text('Harian'),
                              ),
                              ButtonSegment(
                                value: 'weekly',
                                label: Text('Mingguan'),
                              ),
                              ButtonSegment(
                                value: 'monthly',
                                label: Text('Bulanan'),
                              ),
                            ],
                            selected: {autoSaveFrequency.value},
                            onSelectionChanged: (set) =>
                                autoSaveFrequency.value = set.first,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Sumber Dompet Pendebetan',
                            style: textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          if (accounts.isEmpty)
                            const Text('Belum ada dompet terdaftar')
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: scheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  isExpanded: true,
                                  value: selectedAccountId.value,
                                  items: accounts.map((acc) {
                                    return DropdownMenuItem<int>(
                                      value: acc.id,
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 12,
                                            height: 12,
                                            decoration: BoxDecoration(
                                              color: Color(acc.colorValue),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: AppSpacing.sm),
                                          Text(
                                            acc.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            formatRupiah(acc.balanceCents),
                                            style: TextStyle(
                                              color: scheme.outline,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (id) =>
                                      selectedAccountId.value = id,
                                ),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // 7. Catatan / Motivasi Tambahan (opsional)
                  _FormSectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Catatan / Alasan Menabung (Opsional)',
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        TextField(
                          controller: noteController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText:
                                'Tulis motivasi atau tujuan spesifik tabungan ini...',
                            hintStyle: textTheme.bodySmall?.copyWith(
                              color: scheme.outline,
                            ),
                            filled: true,
                            fillColor: scheme.surfaceContainerHighest,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),

            // Bottom CTA Button matching the mockup
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: scheme.surface,
                border: Border(
                  top: BorderSide(
                    color: scheme.outline.withValues(alpha: 0.1),
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: canSubmit ? submit : null,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27),
                    ),
                    backgroundColor: const Color(0xFF23272E),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              goalId == null ? 'Buat target' : 'Simpan perubahan',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            const Icon(
                              LucideIcons.arrow_right,
                              size: 18,
                              color: Colors.white,
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static int _parseAmount(String text) {
    final cleaned = text.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(cleaned) ?? 0;
  }

  static void _addToController(
    TextEditingController controller,
    int addAmount,
  ) {
    final current = _parseAmount(controller.text);
    final next = current + addAmount;
    controller.text = NumberFormat('#,###', 'id_ID').format(next);
  }
}

class _FormSectionCard extends StatelessWidget {
  const _FormSectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: scheme.outline.withValues(alpha: 0.08),
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: child,
    );
  }
}

class _QuickAddChip extends StatelessWidget {
  const _QuickAddChip({
    required this.label,
    required this.onTap,
    this.isReset = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool isReset;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(right: 6, top: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isReset
                ? scheme.error.withValues(alpha: 0.12)
                : scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isReset
                  ? scheme.error.withValues(alpha: 0.4)
                  : scheme.outline.withValues(alpha: 0.15),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isReset ? scheme.error : scheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _ThousandSeparatorFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat('#,###', 'id_ID');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue();
    final value = int.parse(digits);
    final formatted = _formatter.format(value);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
