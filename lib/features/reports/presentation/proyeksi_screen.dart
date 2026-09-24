import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/widgets.dart';
import 'widgets/proyeksi/balance_curve_chart_card.dart';
import 'widgets/proyeksi/budget_health_card.dart';
import 'widgets/proyeksi/daily_allowance_row.dart';
import 'widgets/proyeksi/projection_details_card.dart';
import 'widgets/proyeksi/proyeksi_agenda_card.dart';
import 'widgets/proyeksi/proyeksi_header_card.dart';
import 'widgets/proyeksi/proyeksi_insights_card.dart';
import 'widgets/proyeksi/proyeksi_tip_banner.dart';
import 'widgets/proyeksi/score_breakdown_card.dart';

class ProyeksiScreen extends StatelessWidget {
  const ProyeksiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proyeksi'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: CircleIconButton(
              icon: LucideIcons.plus,
              onTap: () => context.push('/transactions/add'),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            FloatingNavBar.clearance,
          ),
          children: [
            Text(
              'Perkiraan sampai akhir bulan',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const ProyeksiHeaderCard(),
            const SizedBox(height: AppSpacing.md),
            MenuSection(
              items: [
                MenuSectionItem(
                  icon: LucideIcons.message_circle_question_mark,
                  label: 'Boleh nggak beli sesuatu?',
                  description: 'Simulasi dampak ke kas & budget',
                  onTap: () => context.push('/reports/proyeksi/simulasi'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const BalanceCurveChartCard(),
            const SizedBox(height: AppSpacing.md),
            const DailyAllowanceRow(),
            const SizedBox(height: AppSpacing.md),
            const ScoreBreakdownCard(),
            const SizedBox(height: AppSpacing.md),
            const ProjectionDetailsCard(),
            const SizedBox(height: AppSpacing.md),
            const ProyeksiInsightsCard(),
            const SizedBox(height: AppSpacing.md),
            BudgetHealthCard(onTap: () => context.push('/budget')),
            const SizedBox(height: AppSpacing.md),
            const ProyeksiAgendaCard(),
            const SizedBox(height: AppSpacing.md),
            const ProyeksiTipBanner(),
          ],
        ),
      ),
    );
  }
}
