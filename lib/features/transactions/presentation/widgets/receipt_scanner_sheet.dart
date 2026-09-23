import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../../core/constants/currencies.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';

class ReceiptScanResult {
  const ReceiptScanResult({
    required this.amount,
    required this.note,
    this.suggestedCategoryName,
  });

  final int amount;
  final String note;
  final String? suggestedCategoryName;
}

/// Bottom sheet simulating receipt OCR camera scanner with sample receipts.
Future<ReceiptScanResult?> showReceiptScannerSheet(
  BuildContext context, {
  Currency currency = defaultCurrency,
}) {
  return showModalBottomSheet<ReceiptScanResult>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
    ),
    builder: (context) => _ReceiptScannerSheet(currency: currency),
  );
}

class _ReceiptScannerSheet extends HookWidget {
  const _ReceiptScannerSheet({this.currency = defaultCurrency});

  final Currency currency;

  static const _receiptSamples = [
    (
      merchant: 'Indomaret Point',
      items: 'Roti, Susu UHT, Air Mineral',
      amount: 48500,
      category: 'Belanja & Kebutuhan',
    ),
    (
      merchant: 'SPBU Pertamina',
      items: 'Pertamax Turbo 12 Liter',
      amount: 175000,
      category: 'Transportasi',
    ),
    (
      merchant: 'Kopi Kenangan',
      items: '2x Kopi Kenangan Mantan R',
      amount: 48000,
      category: 'Makanan & Minuman',
    ),
    (
      merchant: 'Apotek Kimia Farma',
      items: 'Paracetamol, Vitamin C 500mg',
      amount: 62000,
      category: 'Kesehatan',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final selectedSample = useState<(
      {String merchant, String items, int amount, String category}
    )?>(_receiptSamples.first);
    final isScanning = useState(false);

    void simulateScan(
      ({String merchant, String items, int amount, String category}) sample,
    ) {
      isScanning.value = true;
      Future.delayed(600.ms, () {
        selectedSample.value = sample;
        isScanning.value = false;
      });
    }

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.lg,
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
                  child: Icon(LucideIcons.scan_line, size: 20, color: scheme.primary),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Scan Struk Pembayaran (OCR)',
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

            // Viewfinder box
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              child: Container(
                height: 170,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(
                    color: scheme.primary.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Corner guides
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: scheme.primary, width: 3),
                            left: BorderSide(color: scheme.primary, width: 3),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: scheme.primary, width: 3),
                            right: BorderSide(color: scheme.primary, width: 3),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: scheme.primary, width: 3),
                            left: BorderSide(color: scheme.primary, width: 3),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: scheme.primary, width: 3),
                            right: BorderSide(color: scheme.primary, width: 3),
                          ),
                        ),
                      ),
                    ),

                    // Scanning line animation
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            boxShadow: [
                              BoxShadow(
                                color: scheme.primary.withValues(alpha: 0.8),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      )
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .slideY(begin: 0.1, end: 70.0, duration: 1500.ms),
                    ),

                    // Struk preview content
                    if (selectedSample.value != null && !isScanning.value)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.receipt, color: scheme.primary, size: 28),
                          const SizedBox(height: 6),
                          Text(
                            selectedSample.value!.merchant,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            selectedSample.value!.items,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            formatCurrencyInput(selectedSample.value!.amount, currency: currency),
                            style: TextStyle(
                              color: scheme.primary,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      )
                    else if (isScanning.value)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          const Text(
                            'Membaca teks struk...',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.md),
            Text(
              'Pilih simulasi struk untuk scan:',
              style: textTheme.labelSmall?.copyWith(color: scheme.outline),
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final s in _receiptSamples)
                  ChoiceChip(
                    avatar: const Icon(LucideIcons.receipt, size: 14),
                    label: Text('${s.merchant} (${formatCurrencyCompact(s.amount, currency: currency)})'),
                    selected: selectedSample.value?.merchant == s.merchant,
                    onSelected: (_) => simulateScan(s),
                  ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: selectedSample.value == null
                  ? null
                  : () {
                      final item = selectedSample.value!;
                      Navigator.of(context).pop(
                        ReceiptScanResult(
                          amount: item.amount,
                          note: '${item.merchant} - ${item.items}',
                          suggestedCategoryName: item.category,
                        ),
                      );
                    },
              icon: const Icon(LucideIcons.circle_check, size: 18),
              label: Text(
                'Terapkan Struk (${formatCurrencyInput(selectedSample.value?.amount ?? 0, currency: currency)})',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
