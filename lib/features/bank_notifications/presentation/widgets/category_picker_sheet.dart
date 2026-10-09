import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../categories/domain/category_item.dart';

/// Shows a bottom sheet allowing the user to select a category when
/// confirming a captured notification into a transaction.
Future<CategoryItem?> showCategoryPickerSheet(
  BuildContext context, {
  required List<CategoryItem> categories,
  required CategoryItem? selected,
  required bool isExpense,
}) {
  return showModalBottomSheet<CategoryItem>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
    ),
    builder: (context) => _CategoryPickerSheet(
      categories: categories,
      selected: selected,
      isExpense: isExpense,
    ),
  );
}

class _CategoryPickerSheet extends StatefulWidget {
  const _CategoryPickerSheet({
    required this.categories,
    required this.selected,
    required this.isExpense,
  });

  final List<CategoryItem> categories;
  final CategoryItem? selected;
  final bool isExpense;

  @override
  State<_CategoryPickerSheet> createState() => _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends State<_CategoryPickerSheet> {
  late final TextEditingController _searchController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final sorted = List<CategoryItem>.from(widget.categories)
      ..sort((a, b) {
        final cmp = b.usageCount.compareTo(a.usageCount);
        if (cmp != 0) return cmp;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

    final filtered = _query.trim().isEmpty
        ? sorted
        : sorted
            .where((c) =>
                c.name.toLowerCase().contains(_query.trim().toLowerCase()))
            .toList();

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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pilih Kategori',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.isExpense
                            ? 'Kategori pengeluaran'
                            : 'Kategori pemasukan',
                        style: textTheme.bodySmall
                            ?.copyWith(color: scheme.outline),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _query = val),
              decoration: InputDecoration(
                hintText: 'Cari kategori...',
                prefixIcon: const Icon(LucideIcons.search, size: 20),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(LucideIcons.x, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: scheme.surfaceContainerHigh,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.55,
              ),
              child: filtered.isEmpty
                  ? Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.search_x,
                                size: 36, color: scheme.outline),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Tidak ada kategori yang cocok',
                              style: textTheme.bodyMedium?.copyWith(
                                color: scheme.outline,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      itemCount: filtered.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: AppSpacing.sm,
                        mainAxisSpacing: AppSpacing.sm,
                        childAspectRatio: 0.85,
                      ),
                      itemBuilder: (context, index) {
                        final cat = filtered[index];
                        final isSelected = widget.selected?.id == cat.id;

                        return Material(
                          color: isSelected
                              ? cat.color.withValues(alpha: 0.16)
                              : scheme.surfaceContainerHigh,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusLg),
                          child: InkWell(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusLg),
                            onTap: () => Navigator.of(context).pop(cat),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xs,
                                vertical: AppSpacing.xs + 2,
                              ),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(AppSpacing.radiusLg),
                                border: Border.all(
                                  color: isSelected
                                      ? cat.color
                                      : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 19,
                                    backgroundColor:
                                        cat.color.withValues(alpha: 0.2),
                                    child: Icon(cat.iconData,
                                        color: cat.color, size: 19),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    cat.name,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: textTheme.labelSmall?.copyWith(
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? cat.color
                                          : scheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 1.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: cat.usageCount > 0
                                          ? cat.color.withValues(alpha: 0.14)
                                          : scheme.surfaceContainerHighest
                                              .withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${cat.usageCount}x',
                                      style: textTheme.labelSmall?.copyWith(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: cat.usageCount > 0
                                            ? cat.color
                                            : scheme.outline,
                                      ),
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
