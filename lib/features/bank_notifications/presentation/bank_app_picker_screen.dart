import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/theme/app_spacing.dart';
import '../domain/known_bank_apps.dart';

/// Full-page picker for choosing a notification-source app when creating a
/// bank-notification mapping: a searchable, sectioned list of
/// [knownBankApps], plus a custom package name/label entry for apps not in
/// the preset list. Pushed as its own route (rather than a bottom sheet) so
/// the growing preset list — and its search bar — has real room to breathe.
class BankAppPickerScreen extends StatefulWidget {
  const BankAppPickerScreen({super.key});

  @override
  State<BankAppPickerScreen> createState() => _BankAppPickerScreenState();
}

class _BankAppPickerScreenState extends State<BankAppPickerScreen> {
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

    final query = _query.trim().toLowerCase();
    final filtered = query.isEmpty
        ? knownBankApps
        : knownBankApps
              .where(
                (app) =>
                    app.label.toLowerCase().contains(query) ||
                    app.packageName.toLowerCase().contains(query) ||
                    app.section.toLowerCase().contains(query),
              )
              .toList();

    final sections = <String>[];
    final bySection = <String, List<KnownBankApp>>{};
    for (final app in filtered) {
      bySection.putIfAbsent(app.section, () {
        sections.add(app.section);
        return [];
      }).add(app);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Pilih Aplikasi'), centerTitle: false),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Cari nama aplikasi atau bank...',
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
          ),
          Expanded(
            child: sections.isEmpty
                ? _NotFoundState(
                    query: _searchController.text.trim(),
                    onUseCustom: (app) => Navigator.of(context).pop(app),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      0,
                      AppSpacing.md,
                      AppSpacing.xxl,
                    ),
                    children: [
                      for (final section in sections) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                          child: Text(
                            section,
                            style: textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: scheme.outline,
                            ),
                          ),
                        ),
                        for (final app in bySection[section]!) ...[
                          _AppOption(
                            label: app.label,
                            subtitle: app.packageName,
                            onTap: () => Navigator.of(context).pop(app),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                        ],
                        const SizedBox(height: AppSpacing.sm),
                      ],
                      Center(
                        child: TextButton.icon(
                          onPressed: () => _showCustomEntrySheet(context),
                          icon: const Icon(LucideIcons.pencil, size: 16),
                          label: const Text('Aplikasi lainnya (manual)'),
                          style: TextButton.styleFrom(foregroundColor: scheme.primary),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCustomEntrySheet(BuildContext context) async {
    final app = await showModalBottomSheet<KnownBankApp>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => const _CustomAppEntrySheet(),
    );
    if (app != null && context.mounted) {
      Navigator.of(context).pop(app);
    }
  }
}

class _NotFoundState extends StatelessWidget {
  const _NotFoundState({required this.query, required this.onUseCustom});

  final String query;
  final ValueChanged<KnownBankApp> onUseCustom;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.search_x, size: 40, color: scheme.outline),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Aplikasi "$query" tidak ditemukan',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: scheme.outline),
            ),
            const SizedBox(height: AppSpacing.md),
            TextButton.icon(
              onPressed: () async {
                final app = await showModalBottomSheet<KnownBankApp>(
                  context: context,
                  showDragHandle: true,
                  isScrollControlled: true,
                  builder: (context) => const _CustomAppEntrySheet(),
                );
                if (app != null) onUseCustom(app);
              },
              icon: const Icon(LucideIcons.pencil, size: 16),
              label: const Text('Tambahkan secara manual'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppOption extends StatelessWidget {
  const _AppOption({required this.label, required this.subtitle, required this.onTap});

  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            children: [
              Icon(LucideIcons.landmark, size: 20, color: scheme.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(color: scheme.outline),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(LucideIcons.chevron_right, size: 18, color: scheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet for typing a custom package name/label when the app isn't
/// in the [knownBankApps] preset list.
class _CustomAppEntrySheet extends StatefulWidget {
  const _CustomAppEntrySheet();

  @override
  State<_CustomAppEntrySheet> createState() => _CustomAppEntrySheetState();
}

class _CustomAppEntrySheetState extends State<_CustomAppEntrySheet> {
  final _labelController = TextEditingController();
  final _packageController = TextEditingController();

  @override
  void dispose() {
    _labelController.dispose();
    _packageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.md + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aplikasi Lainnya',
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _labelController,
              decoration: const InputDecoration(
                labelText: 'Nama aplikasi',
                hintText: 'mis. Bank Jago',
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _packageController,
              decoration: const InputDecoration(
                labelText: 'Package name Android',
                hintText: 'mis. com.jago.digitalBanking',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  final label = _labelController.text.trim();
                  final package = _packageController.text.trim();
                  if (label.isEmpty || package.isEmpty) return;
                  Navigator.of(context).pop(
                    KnownBankApp(
                      packageName: package,
                      label: label,
                      section: 'Manual',
                    ),
                  );
                },
                child: const Text('Gunakan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
