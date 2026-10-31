import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../categories/domain/category_item.dart';

/// Shows a bottom sheet allowing the user to select a category.
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

    final cleanQuery = _query.trim().toLowerCase();
    final filtered = (cleanQuery.isEmpty
        ? widget.categories
        : widget.categories
            .where((c) => c.name.toLowerCase().contains(cleanQuery)))
        .toList()
      ..sort((a, b) {
        final cmp = b.usageCount.compareTo(a.usageCount);
        if (cmp != 0) return cmp;
        return a.name.compareTo(b.name);
      });

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
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.outline,
                        ),
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
            Flexible(
              child: ConstrainedBox(
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
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        itemCount: filtered.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: AppSpacing.sm,
                          mainAxisSpacing: AppSpacing.sm,
                          childAspectRatio: 1.02,
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
                                      radius: 20,
                                      backgroundColor:
                                          cat.color.withValues(alpha: 0.2),
                                      child: Icon(cat.iconData,
                                          color: cat.color, size: 20),
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
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
