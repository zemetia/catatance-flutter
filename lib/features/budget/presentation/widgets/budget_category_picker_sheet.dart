import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../categories/domain/category_item.dart';

/// Bottom sheet for picking the expense category a budget applies to.
/// [excludedCategoryIds] hides categories that already have a budget so a
/// new budget can't silently duplicate one (irrelevant when editing, since
/// the budget's own current category should still be selectable).
Future<CategoryItem?> showBudgetCategoryPickerSheet(
  BuildContext context, {
  required List<CategoryItem> categories,
  required CategoryItem? selected,
  Set<int> excludedCategoryIds = const {},
}) {
  final selectable = categories
      .where((c) => c.id == selected?.id || !excludedCategoryIds.contains(c.id))
      .toList();

  return showModalBottomSheet<CategoryItem>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
    ),
    builder: (context) => _BudgetCategoryPickerSheet(
      categories: selectable,
      selected: selected,
    ),
  );
}

class _BudgetCategoryPickerSheet extends StatelessWidget {
  const _BudgetCategoryPickerSheet({required this.categories, required this.selected});

  final List<CategoryItem> categories;
  final CategoryItem? selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Pilih Kategori Pengeluaran',
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (categories.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Text(
                  'Semua kategori pengeluaran sudah punya anggaran.',
                  style: textTheme.bodyMedium?.copyWith(color: scheme.outline),
                ),
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.55),
                child: GridView.builder(
                  shrinkWrap: true,
                  itemCount: categories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: AppSpacing.sm,
                    mainAxisSpacing: AppSpacing.sm,
                    childAspectRatio: 0.95,
                  ),
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final isSelected = selected?.id == cat.id;

                    return Material(
                      color: isSelected
                          ? cat.color.withValues(alpha: 0.16)
                          : scheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                        onTap: () => Navigator.of(context).pop(cat),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                            border: Border.all(
                              color: isSelected ? cat.color : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: cat.color.withValues(alpha: 0.2),
                                child: Icon(cat.iconData, color: cat.color, size: 20),
                              ),
                              const SizedBox(height: AppSpacing.xs + 2),
                              Text(
                                cat.name,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.labelSmall?.copyWith(
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? cat.color : scheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
