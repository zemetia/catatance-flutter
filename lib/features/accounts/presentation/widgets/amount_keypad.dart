import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../../core/theme/app_spacing.dart';

/// On-screen numeric keypad for entering a whole-Rupiah amount, used by the
/// new-wallet ("Saldo awal") and transfer-between-wallets ("Nominal") forms.
///
/// Reports each keypress via [onKey]: `'0'`-`'9'` to append a digit,
/// `'backspace'` to remove the last one. The decimal `'.'` key is rendered
/// for layout parity with the reference design but is a no-op — amounts are
/// always stored as whole Rupiah, never fractional.
class AmountKeypad extends StatelessWidget {
  const AmountKeypad({required this.onKey, super.key});

  final ValueChanged<String> onKey;

  static const _keys = [
    '1', '2', '3', //
    '4', '5', '6', //
    '7', '8', '9', //
    '.', '0', 'backspace',
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      childAspectRatio: 1.6,
      children: [
        for (final key in _keys) _KeypadButton(label: key, onTap: onKey),
      ],
    );
  }
}

class _KeypadButton extends StatelessWidget {
  const _KeypadButton({required this.label, required this.onTap});

  final String label;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: () => onTap(label),
        child: Center(
          child: label == 'backspace'
              ? Icon(LucideIcons.delete, size: 20, color: scheme.onSurface)
              : Text(
                  label,
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
        ),
      ),
    );
  }
}
