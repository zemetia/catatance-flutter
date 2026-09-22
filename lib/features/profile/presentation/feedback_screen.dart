import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/theme/app_spacing.dart';

enum _FeedbackCategory {
  bug('Laporkan Bug'),
  suggestion('Saran Fitur'),
  other('Lainnya');

  const _FeedbackCategory(this.label);

  final String label;
}

class FeedbackScreen extends HookConsumerWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final category = useState(_FeedbackCategory.suggestion);
    final messageController = useTextEditingController();

    void submit() {
      if (messageController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('Tulis masukanmu dulu, ya')));
        return;
      }
      messageController.clear();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Terima kasih! Masukanmu sudah kami terima.')),
        );
      Navigator.of(context).pop();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Kirim Masukan'), centerTitle: false),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text(
            'Kategori',
            style: textTheme.labelLarge?.copyWith(
              color: scheme.outline,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final option in _FeedbackCategory.values)
                ChoiceChip(
                  label: Text(option.label),
                  selected: category.value == option,
                  onSelected: (_) => category.value = option,
                  selectedColor: scheme.primary.withValues(alpha: 0.16),
                  labelStyle: TextStyle(
                    color: category.value == option
                        ? scheme.primary
                        : scheme.onSurface,
                    fontWeight: category.value == option
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                  side: BorderSide(
                    color: category.value == option
                        ? scheme.primary
                        : scheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Pesan',
            style: textTheme.labelLarge?.copyWith(
              color: scheme.outline,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: messageController,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText: 'Ceritakan bug yang kamu temui atau fitur yang kamu inginkan...',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: submit,
              icon: const Icon(LucideIcons.send, size: 18),
              label: const Text('Kirim'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
