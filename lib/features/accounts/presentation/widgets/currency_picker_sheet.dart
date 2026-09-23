import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../../core/constants/currencies.dart';
import '../../../../core/theme/app_spacing.dart';

/// Shows a bottom sheet to search and pick any world currency (ISO 4217).
Future<Currency?> showCurrencyPickerSheet(
  BuildContext context, {
  required Currency selected,
}) {
  return showModalBottomSheet<Currency>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => _CurrencyPickerSheet(selected: selected),
  );
}

class _CurrencyPickerSheet extends StatefulWidget {
  const _CurrencyPickerSheet({required this.selected});

  final Currency selected;

  @override
  State<_CurrencyPickerSheet> createState() => _CurrencyPickerSheetState();
}

class _CurrencyPickerSheetState extends State<_CurrencyPickerSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final filteredCurrencies = searchCurrencies(_query);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pilih Mata Uang',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Pilih mata uang utama untuk dompet ini.',
                    style: textTheme.bodySmall?.copyWith(color: scheme.outline),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _query = val),
                    decoration: InputDecoration(
                      hintText: 'Cari kode, nama, atau negara (IDR, USD, dll)...',
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
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (_query.isEmpty) ...[
                    Text(
                      'Populer',
                      style: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.outline,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: majorCurrencies.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(width: AppSpacing.xs),
                        itemBuilder: (context, index) {
                          final c = majorCurrencies[index];
                          final isSelected = c.code == widget.selected.code;
                          return FilterChip(
                            avatar: Text(c.flag, style: const TextStyle(fontSize: 16)),
                            label: Text('${c.code} · ${c.symbol}'),
                            selected: isSelected,
                            onSelected: (_) => Navigator.of(context).pop(c),
                            showCheckmark: false,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: filteredCurrencies.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.coins, size: 40, color: scheme.outline),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Mata uang tidak ditemukan',
                            style: textTheme.bodyMedium?.copyWith(
                              color: scheme.outline,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: filteredCurrencies.length,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      itemBuilder: (context, index) {
                        final currency = filteredCurrencies[index];
                        final isSelected = currency.code == widget.selected.code;

                        return Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? scheme.primary.withValues(alpha: 0.10)
                                : Colors.transparent,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusMd),
                          ),
                          child: ListTile(
                            dense: true,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusMd),
                            ),
                            leading: Container(
                              width: 40,
                              height: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: scheme.surfaceContainerHigh,
                                borderRadius:
                                    BorderRadius.circular(AppSpacing.radiusSm),
                              ),
                              child: Text(
                                currency.flag,
                                style: const TextStyle(fontSize: 22),
                              ),
                            ),
                            title: Row(
                              children: [
                                Text(
                                  currency.code,
                                  style: textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: scheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    currency.symbol,
                                    style: textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: scheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Text(
                              '${currency.nameId} (${currency.name})',
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodySmall?.copyWith(
                                color: scheme.outline,
                              ),
                            ),
                            trailing: isSelected
                                ? Icon(
                                    LucideIcons.check,
                                    color: scheme.primary,
                                    size: 20,
                                  )
                                : null,
                            onTap: () => Navigator.of(context).pop(currency),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
