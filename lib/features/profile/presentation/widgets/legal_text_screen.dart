import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

/// A single heading + body pair within a [LegalTextScreen].
class LegalSection {
  const LegalSection({required this.heading, required this.body});

  final String heading;
  final String body;
}

/// Shared scaffold for static long-form legal/help copy (Kebijakan Privasi,
/// Syarat & Ketentuan) — a title, an updated-at caption, and a list of
/// heading/body sections.
class LegalTextScreen extends StatelessWidget {
  const LegalTextScreen({
    required this.title,
    required this.updatedAt,
    required this.sections,
    super.key,
  });

  final String title;
  final String updatedAt;
  final List<LegalSection> sections;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(title), centerTitle: false),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text(
            'Terakhir diperbarui: $updatedAt',
            style: textTheme.bodySmall?.copyWith(color: scheme.outline),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final section in sections) ...[
            Text(
              section.heading,
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              section.body,
              style: textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ],
      ),
    );
  }
}
