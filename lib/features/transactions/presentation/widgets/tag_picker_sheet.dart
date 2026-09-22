import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../../core/theme/app_spacing.dart';

/// Bottom sheet for selecting and adding tags to a transaction.
Future<List<String>?> showTagPickerSheet(
  BuildContext context, {
  required List<String> initialTags,
}) {
  return showModalBottomSheet<List<String>>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
    ),
    builder: (context) => _TagPickerSheet(initialTags: initialTags),
  );
}

class _TagPickerSheet extends HookWidget {
  const _TagPickerSheet({required this.initialTags});

  final List<String> initialTags;

  static const _defaultTags = [
    'Pribadi',
    'Kantor',
    'Keluarga',
    'Liburan',
    'Hobi',
    'MakanLuar',
    'BelanjaOnline',
    'Darurat',
    'Langganan',
    'Sedekah',
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final selectedTags = useState<Set<String>>(initialTags.toSet());
    final allTags = useState<List<String>>([
      ..._defaultTags,
      ...initialTags.where((t) => !_defaultTags.contains(t)),
    ]);
    final customTagController = useTextEditingController();

    void toggleTag(String tag) {
      final current = Set<String>.from(selectedTags.value);
      if (current.contains(tag)) {
        current.remove(tag);
      } else {
        current.add(tag);
      }
      selectedTags.value = current;
    }

    void addCustomTag() {
      final raw = customTagController.text.trim().replaceAll('#', '');
      if (raw.isNotEmpty) {
        if (!allTags.value.contains(raw)) {
          allTags.value = [...allTags.value, raw];
        }
        selectedTags.value = {...selectedTags.value, raw};
        customTagController.clear();
      }
    }

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xs + 2),
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(LucideIcons.tag, size: 20, color: scheme.primary),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Pilih & Tambah Tag',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Input custom tag
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: customTagController,
                    decoration: InputDecoration(
                      hintText: 'Tambah tag baru...',
                      prefixIcon: const Icon(LucideIcons.hash, size: 18),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      filled: true,
                      fillColor: scheme.surfaceContainerHigh,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => addCustomTag(),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                IconButton.filledTonal(
                  onPressed: addCustomTag,
                  icon: const Icon(LucideIcons.plus, size: 20),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            Text(
              'Tag populer:',
              style: textTheme.labelSmall?.copyWith(color: scheme.outline),
            ),
            const SizedBox(height: AppSpacing.xs),

            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final tag in allTags.value)
                  FilterChip(
                    avatar: selectedTags.value.contains(tag)
                        ? const Icon(LucideIcons.check, size: 14)
                        : const Icon(LucideIcons.hash, size: 14),
                    label: Text(tag),
                    selected: selectedTags.value.contains(tag),
                    onSelected: (_) => toggleTag(tag),
                    selectedColor: scheme.primary.withValues(alpha: 0.18),
                    checkmarkColor: scheme.primary,
                  ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).pop(selectedTags.value.toList());
              },
              icon: const Icon(LucideIcons.check, size: 18),
              label: Text(
                selectedTags.value.isEmpty
                    ? 'Selesai (Tanpa Tag)'
                    : 'Gunakan ${selectedTags.value.length} Tag',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
