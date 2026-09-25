import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/services/backup_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/widgets.dart';
import 'backup_providers.dart';
import 'widgets/settings_toggle_tile.dart';

class BackupScreen extends ConsumerWidget {
  const BackupScreen({super.key});

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _onBackupNow(BuildContext context, WidgetRef ref) async {
    final error = await ref.read(backupScreenProvider.notifier).backupNow();
    if (!context.mounted) return;
    _showMessage(
      context,
      error == null ? 'Cadangan baru berhasil dibuat' : 'Gagal membuat cadangan: $error',
    );
  }

  Future<void> _onRestore(BuildContext context, WidgetRef ref, BackupFile backup) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Pulihkan backup ini?'),
        content: Text(
          'Semua data saat ini akan ditimpa dengan data dari cadangan '
          '${_formatDate(backup.createdAt)}. Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: const Text('Pulihkan'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final error = await ref.read(backupScreenProvider.notifier).restore(backup);
    if (!context.mounted) return;
    _showMessage(
      context,
      error == null ? 'Data berhasil dipulihkan dari cadangan' : 'Gagal memulihkan: $error',
    );
  }

  Future<void> _onDelete(BuildContext context, WidgetRef ref, BackupFile backup) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus backup ini?'),
        content: Text(
          'Cadangan ${_formatDate(backup.createdAt)} akan dihapus permanen dari perangkat.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final error = await ref.read(backupScreenProvider.notifier).delete(backup);
    if (!context.mounted) return;
    if (error != null) _showMessage(context, 'Gagal menghapus: $error');
  }

  static String _formatDate(DateTime date) =>
      DateFormat('d MMM yyyy • HH:mm', 'id_ID').format(date);

  static String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(backupScreenProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Data'), centerTitle: false),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Gagal memuat: $err')),
        data: (state) => ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            _BackupLocationCard(path: state.backupDirPath),
            const SizedBox(height: AppSpacing.lg),
            _BackupNowCard(
              lastBackupAt: state.lastBackupAt,
              isWorking: state.isWorking,
              onTap: () => _onBackupNow(context, ref),
            ),
            const SizedBox(height: AppSpacing.lg),
            SettingsToggleSection(
              title: 'Otomatis',
              children: [
                SettingsToggleTile(
                  icon: LucideIcons.refresh_cw,
                  label: 'Auto Backup Harian',
                  description: 'Cadangkan otomatis sekali sehari saat aplikasi dibuka',
                  value: state.autoBackupEnabled,
                  onChanged: (value) =>
                      ref.read(backupScreenProvider.notifier).setAutoBackupEnabled(value),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Riwayat Backup (${state.backups.length})',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.outline,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (state.backups.isEmpty)
              const EmptyStateCard(
                icon: LucideIcons.hard_drive,
                title: 'Belum ada backup',
                description: 'Cadangan yang kamu buat akan muncul di sini.',
              )
            else
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                child: Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Column(
                    children: [
                      for (var i = 0; i < state.backups.length; i++) ...[
                        if (i > 0)
                          Divider(
                            height: 1,
                            indent: AppSpacing.xl + AppSpacing.md,
                            color: Theme.of(
                              context,
                            ).colorScheme.outlineVariant.withValues(alpha: 0.4),
                          ),
                        _BackupRow(
                          backup: state.backups[i],
                          isWorking: state.isWorking,
                          onRestore: () => _onRestore(context, ref, state.backups[i]),
                          onDelete: () => _onDelete(context, ref, state.backups[i]),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BackupLocationCard extends StatelessWidget {
  const _BackupLocationCard({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(
            icon: LucideIcons.folder,
            color: scheme.primary,
            shape: BoxShape.rectangle,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lokasi Backup',
                  style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  path,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'File database (.sqlite) disimpan di folder ini pada '
                  'penyimpanan perangkat.',
                  style: textTheme.bodySmall?.copyWith(color: scheme.outline),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BackupNowCard extends StatelessWidget {
  const _BackupNowCard({
    required this.lastBackupAt,
    required this.isWorking,
    required this.onTap,
  });

  final DateTime? lastBackupAt;
  final bool isWorking;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final subtitle = lastBackupAt == null
        ? 'Belum pernah dicadangkan'
        : 'Terakhir dicadangkan: ${BackupScreen._formatDate(lastBackupAt!)}';

    return AppCard(
      child: Row(
        children: [
          IconBadge(icon: LucideIcons.hard_drive_upload, color: scheme.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cadangkan data sekarang',
                  style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(color: scheme.outline),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          FilledButton(
            onPressed: isWorking ? null : onTap,
            child: isWorking
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Backup'),
          ),
        ],
      ),
    );
  }
}

class _BackupRow extends StatelessWidget {
  const _BackupRow({
    required this.backup,
    required this.isWorking,
    required this.onRestore,
    required this.onDelete,
  });

  final BackupFile backup;
  final bool isWorking;
  final VoidCallback onRestore;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          IconBadge(
            icon: LucideIcons.database,
            color: scheme.primary,
            size: 18,
            shape: BoxShape.rectangle,
            padding: const EdgeInsets.all(AppSpacing.xs),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  BackupScreen._formatDate(backup.createdAt),
                  style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  BackupScreen._formatSize(backup.sizeBytes),
                  style: textTheme.bodySmall?.copyWith(color: scheme.outline),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: isWorking ? null : onRestore,
            tooltip: 'Pulihkan',
            icon: Icon(LucideIcons.rotate_ccw, size: 20, color: scheme.primary),
          ),
          IconButton(
            onPressed: isWorking ? null : onDelete,
            tooltip: 'Hapus',
            icon: Icon(LucideIcons.trash, size: 20, color: AppColors.expense),
          ),
        ],
      ),
    );
  }
}
