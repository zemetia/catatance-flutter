import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/savings_goal.dart';

/// Interactive preview card matching the reference mock.
class SavingsGoalPreviewCard extends StatelessWidget {
  const SavingsGoalPreviewCard({
    required this.name,
    required this.iconOption,
    required this.gradient,
    required this.targetAmountCents,
    this.currentAmountCents = 0,
    this.targetDate,
    this.autoSaveEnabled = false,
    this.autoSaveAmountCents = 0,
    this.autoSaveFrequency = 'monthly',
    this.showProgress = false,
    super.key,
  });

  final String name;
  final SavingsGoalIconOption iconOption;
  final LinearGradient gradient;
  final int targetAmountCents;
  final int currentAmountCents;
  final DateTime? targetDate;
  final bool autoSaveEnabled;
  final int autoSaveAmountCents;
  final String autoSaveFrequency;
  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final displayName = name.trim().isEmpty ? 'cth: Liburan Bali' : name.trim();
    final hasTarget = targetAmountCents > 0;
    final progress = hasTarget
        ? (currentAmountCents / targetAmountCents).clamp(0.0, 1.0)
        : 0.0;
    final deadlineText = targetDate != null
        ? 'Target: ${formatDate(targetDate!)}'
        : 'Tanpa deadline';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF14161A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Upper gradient banner with dotted watermark and icon badge
          SizedBox(
            height: 135,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Gradient fill
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: gradient,
                  ),
                ),
                // Dotted pattern overlay
                const CustomPaint(
                  painter: _DottedPatternPainter(),
                ),
                // Watermark icon on the right
                Positioned(
                  right: -12,
                  bottom: -16,
                  child: Transform.rotate(
                    angle: -0.22,
                    child: Opacity(
                      opacity: 0.22,
                      child: Icon(
                        iconOption.iconData,
                        size: 110,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // Top-left circular icon badge (dark translucent background matching mock)
                Positioned(
                  left: AppSpacing.md,
                  top: AppSpacing.md,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      iconOption.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                // Autosave status pill on top-right if enabled and progress mode is active
                if (showProgress && autoSaveEnabled && autoSaveAmountCents > 0)
                  Positioned(
                    right: AppSpacing.md,
                    top: AppSpacing.md,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                        border: Border.all(
                          color: const Color(0xFFC6FF3D).withValues(alpha: 0.6),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            LucideIcons.zap,
                            size: 12,
                            color: Color(0xFFC6FF3D),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Autosave Aktif',
                            style: textTheme.labelSmall?.copyWith(
                              color: const Color(0xFFC6FF3D),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Lower card content
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      LucideIcons.calendar,
                      size: 13,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      deadlineText,
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (hasTarget && !showProgress) ...[
                      const Spacer(),
                      Text(
                        'Target: ${formatRupiahCompact(targetAmountCents)}',
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
                if (showProgress && hasTarget) ...[
                  const SizedBox(height: AppSpacing.sm),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    child: LinearProgressIndicator(
                      value: progress == 0 ? 0.02 : progress,
                      minHeight: 6,
                      backgroundColor: Colors.white.withValues(alpha: 0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        gradient.colors.last,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Terkumpul: ${formatRupiah(currentAmountCents)}',
                        style: textTheme.labelSmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                      Text(
                        '${(progress * 100).round()}%',
                        style: textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
                if (showProgress && autoSaveEnabled && autoSaveAmountCents > 0) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Ditabung otomatis: ${formatRupiahCompact(autoSaveAmountCents)} / $autoSaveFrequency',
                      style: textTheme.labelSmall?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DottedPatternPainter extends CustomPainter {
  const _DottedPatternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    const spacing = 14.0;
    const radius = 1.4;

    for (double x = spacing / 2; x < size.width; x += spacing) {
      for (double y = spacing / 2; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
