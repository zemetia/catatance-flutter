import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';

/// "Title" + optional "Lihat semua" link + a tinted "+" add button — used
/// above the savings-goal and wallet sections.
class BudgetSectionHeader extends StatelessWidget {
  const BudgetSectionHeader({
    required this.title,
    this.onAdd,
    this.onSeeAll,
    super.key,
  });

  final String title;
  final VoidCallback? onAdd;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Text(title, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        ),
        CircleIconButton(
          icon: LucideIcons.plus,
          onTap: onAdd,
          backgroundColor: scheme.primary,
          size: 18,
        ),
        if (onSeeAll != null) ...[
          const SizedBox(width: AppSpacing.sm),
          TextButton(
            onPressed: onSeeAll,
            child: const Text('Lihat semua'),
          ),
        ],
      ],
    );
  }
}
