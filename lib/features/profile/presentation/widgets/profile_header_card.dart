import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';

/// Top-of-profile identity block: avatar, name, email, and an edit action.
class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({
    required this.displayName,
    required this.email,
    this.onEditTap,
    super.key,
  });

  final String displayName;
  final String email;
  final VoidCallback? onEditTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InitialsAvatar(name: displayName, radius: 32),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                email,
                style: textTheme.bodyMedium?.copyWith(color: scheme.outline),
              ),
            ],
          ),
        ),
        CircleIconButton(
          icon: LucideIcons.pencil,
          onTap: onEditTap,
          size: 18,
          backgroundColor: scheme.surfaceContainerHighest,
        ),
      ],
    ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.06, end: 0);
  }
}
