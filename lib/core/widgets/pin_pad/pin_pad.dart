import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../theme/app_spacing.dart';

const int kPinLength = 6;

/// Row of [kPinLength] dots showing how many digits have been entered.
/// Pass a rising [shakeSignal] value to replay the "wrong PIN" shake.
class PinDotsIndicator extends StatelessWidget {
  const PinDotsIndicator({
    required this.filledCount,
    this.shakeSignal = 0,
    this.hasError = false,
    super.key,
  });

  final int filledCount;
  final int shakeSignal;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      key: ValueKey(shakeSignal),
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < kPinLength; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < filledCount
                    ? (hasError ? scheme.error : scheme.primary)
                    : Colors.transparent,
                border: Border.all(
                  color: hasError
                      ? scheme.error
                      : scheme.outline.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
            ),
          ),
      ],
    ).animate(key: ValueKey(shakeSignal)).shakeX(
          amount: shakeSignal > 0 ? 8 : 0,
          duration: 400.ms,
        );
  }
}

/// Numeric keypad (1-9, optional biometric shortcut, 0, backspace) used by
/// the unlock, PIN-setup, and change-PIN screens.
class PinNumberPad extends StatelessWidget {
  const PinNumberPad({
    required this.onDigit,
    required this.onBackspace,
    this.onBiometricTap,
    super.key,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback? onBiometricTap;

  @override
  Widget build(BuildContext context) {
    final rows = <List<Widget>>[
      for (var row = 0; row < 3; row++)
        [
          for (var col = 1; col <= 3; col++)
            _PinPadKey.digit('${row * 3 + col}', onDigit),
        ],
      [
        if (onBiometricTap != null)
          _PinPadKey.icon(LucideIcons.fingerprint_pattern, onBiometricTap!)
        else
          const SizedBox.shrink(),
        _PinPadKey.digit('0', onDigit),
        _PinPadKey.icon(LucideIcons.delete, onBackspace),
      ],
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: row),
          ),
      ],
    );
  }
}

class _PinPadKey extends StatelessWidget {
  const _PinPadKey({this.label, this.icon, required this.onTap});

  factory _PinPadKey.digit(String label, ValueChanged<String> onDigit) {
    return _PinPadKey(label: label, onTap: () => onDigit(label));
  }

  factory _PinPadKey.icon(IconData icon, VoidCallback onTap) {
    return _PinPadKey(icon: icon, onTap: onTap);
  }

  final String? label;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: 72,
      height: 60,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          onTap: onTap,
          child: Center(
            child: label != null
                ? Text(
                    label!,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : Icon(icon, color: scheme.onSurface, size: 24),
          ),
        ),
      ),
    );
  }
}
