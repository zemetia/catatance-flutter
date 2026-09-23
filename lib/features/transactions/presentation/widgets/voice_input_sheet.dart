import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../../core/constants/currencies.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';

class VoiceInputResult {
  const VoiceInputResult({
    required this.amount,
    required this.note,
    this.suggestedCategoryName,
    this.isIncome,
  });

  final int amount;
  final String note;
  final String? suggestedCategoryName;
  final bool? isIncome;
}

/// Bottom sheet for voice transaction recording & simulated speech-to-text recognition.
Future<VoiceInputResult?> showVoiceInputSheet(
  BuildContext context, {
  Currency currency = defaultCurrency,
}) {
  return showModalBottomSheet<VoiceInputResult>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
    ),
    builder: (context) => _VoiceInputSheet(currency: currency),
  );
}

class _VoiceInputSheet extends HookWidget {
  const _VoiceInputSheet({this.currency = defaultCurrency});

  final Currency currency;

  static const _samples = [
    (
      text: 'Makan siang bakso 35 ribu',
      amount: 35000,
      note: 'Makan siang bakso',
      category: 'Makanan & Minuman',
      income: false,
    ),
    (
      text: 'Beli kopi Kenangan 24 ribu',
      amount: 24000,
      note: 'Kopi Kenangan Mantan',
      category: 'Makanan & Minuman',
      income: false,
    ),
    (
      text: 'Bensin motor Pertamax 50 ribu',
      amount: 50000,
      note: 'Bensin motor Pertamax',
      category: 'Transportasi',
      income: false,
    ),
    (
      text: 'Belanja bulanan supermarket 385 ribu',
      amount: 385000,
      note: 'Belanja bulanan supermarket',
      category: 'Belanja & Kebutuhan',
      income: false,
    ),
    (
      text: 'Gaji sampingan freelance 2 juta',
      amount: 2000000,
      note: 'Honor sampingan freelance',
      category: 'Freelance & Projek',
      income: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final isRecording = useState(true);
    final recognizedText = useState('Mendengarkan suara Anda...');
    final extractedAmount = useState<int?>(null);
    final extractedNote = useState<String?>(null);
    final extractedCategory = useState<String?>(null);
    final isIncome = useState<bool?>(null);

    void applySample(
      String fullText,
      int amount,
      String note,
      String category,
      bool income,
    ) {
      isRecording.value = false;
      recognizedText.value = fullText;
      extractedAmount.value = amount;
      extractedNote.value = note;
      extractedCategory.value = category;
      isIncome.value = income;
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
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xs + 2),
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(LucideIcons.mic, size: 20, color: scheme.primary),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Input Transaksi Suara',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Pulsing mic orb
            Center(
              child: GestureDetector(
                onTap: () {
                  isRecording.value = !isRecording.value;
                  if (isRecording.value) {
                    recognizedText.value = 'Mendengarkan suara Anda...';
                    extractedAmount.value = null;
                  }
                },
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        scheme.primary,
                        scheme.primary.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: scheme.primary.withValues(alpha: 0.35),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    isRecording.value ? LucideIcons.mic : LucideIcons.mic_off,
                    color: scheme.onPrimary,
                    size: 36,
                  ),
                ),
              )
                  .animate(
                    target: isRecording.value ? 1 : 0,
                    onPlay: (c) => isRecording.value ? c.repeat(reverse: true) : null,
                  )
                  .scaleXY(begin: 1.0, end: 1.08, duration: 800.ms),
            ),
            const SizedBox(height: AppSpacing.md),

            // Waveform simulation
            if (isRecording.value)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 4,
                    height: 14.0 + (index % 3) * 10,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scaleY(
                        begin: 0.4,
                        end: 1.4,
                        duration: Duration(milliseconds: 300 + index * 120),
                      );
                }),
              ),
            const SizedBox(height: AppSpacing.sm),

            Text(
              recognizedText.value,
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: extractedAmount.value != null ? scheme.onSurface : scheme.outline,
              ),
            ),

            if (extractedAmount.value != null) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: scheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: scheme.primary.withValues(alpha: 0.15),
                      child: Icon(LucideIcons.sparkles, color: scheme.primary, size: 18),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hasil ekstraksi cerdas:',
                            style: textTheme.bodySmall?.copyWith(color: scheme.outline),
                          ),
                          Text(
                            'Nominal: ${formatCurrencyInput(extractedAmount.value!, currency: currency)}',
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (extractedNote.value != null)
                            Text(
                              'Catatan: ${extractedNote.value}',
                              style: textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.md),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Atau coba contoh suara:',
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.outline,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final s in _samples)
                  ActionChip(
                    avatar: const Icon(LucideIcons.mic, size: 14),
                    label: Text(s.text),
                    labelStyle: textTheme.bodySmall,
                    backgroundColor: scheme.surfaceContainerHigh,
                    onPressed: () => applySample(s.text, s.amount, s.note, s.category, s.income),
                  ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: extractedAmount.value == null
                  ? null
                  : () {
                      Navigator.of(context).pop(
                        VoiceInputResult(
                          amount: extractedAmount.value!,
                          note: extractedNote.value ?? recognizedText.value,
                          suggestedCategoryName: extractedCategory.value,
                          isIncome: isIncome.value,
                        ),
                      );
                    },
              icon: const Icon(LucideIcons.check, size: 18),
              label: const Text('Gunakan Catatan Suara Ini'),
            ),
          ],
        ),
      ),
    );
  }
}
