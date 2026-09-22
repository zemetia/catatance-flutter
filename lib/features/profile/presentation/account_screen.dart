import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/widgets.dart';
import 'profile_settings_providers.dart';

class AccountScreen extends HookConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final profile = ref.watch(userProfileProvider);

    final nameController = useTextEditingController(text: profile.displayName);
    final emailController = useTextEditingController(text: profile.email);
    final phoneController = useTextEditingController(text: profile.phone);

    void save() {
      ref.read(userProfileProvider.notifier).state = profile.copyWith(
        displayName: nameController.text.trim().isEmpty
            ? profile.displayName
            : nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
      );
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Profil diperbarui')));
      Navigator.of(context).pop();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Akun'), centerTitle: false),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Center(
            child: InitialsAvatar(name: profile.displayName, radius: 40),
          ).animate().fadeIn(duration: 200.ms),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Nama Lengkap',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: scheme.outline,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: 'Nama kamu'),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Email',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: scheme.outline,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: 'nama@email.com'),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Nomor Telepon',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: scheme.outline,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(hintText: '08xx-xxxx-xxxx'),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: save,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
              ),
              child: const Text('Simpan Perubahan'),
            ),
          ),
        ],
      ),
    );
  }
}
