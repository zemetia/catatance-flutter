import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/widgets.dart';

/// "Agenda bulan ini": always the empty state today, since this app has no
/// recurring-bill/scheduled-income feature yet (only savings-goal autosave,
/// which isn't a "tagihan"). Revisit once such a feature exists — don't
/// fabricate agenda items from installment/debt due dates without a
/// dedicated design pass.
class ProyeksiAgendaCard extends StatelessWidget {
  const ProyeksiAgendaCard({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const IconBadge(icon: LucideIcons.calendar_clock, shape: BoxShape.rectangle),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Agenda bulan ini',
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Belum ada tagihan atau pemasukan otomatis bulan ini.',
            style: textTheme.bodyMedium?.copyWith(color: scheme.outline),
          ),
        ],
      ),
    );
  }
}
