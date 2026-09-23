import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import 'pin_pad.dart';

/// One step of a PIN flow (verify current / create new / confirm new) —
/// shows a title, the dot indicator, and the keypad, and calls [onSubmit]
/// once 6 digits are entered. [onSubmit] returns an error message to show
/// (and shake) or `null` on success; the parent screen owns what happens
/// next (advance to the next step, pop, etc).
class PinEntryStep extends StatefulWidget {
  const PinEntryStep({
    required this.title,
    required this.subtitle,
    required this.onSubmit,
    super.key,
  });

  final String title;
  final String subtitle;
  final Future<String?> Function(String pin) onSubmit;

  @override
  State<PinEntryStep> createState() => _PinEntryStepState();
}

class _PinEntryStepState extends State<PinEntryStep> {
  String _entered = '';
  String? _errorText;
  int _shakeSignal = 0;
  bool _checking = false;

  Future<void> _onDigit(String digit) async {
    if (_checking || _entered.length >= kPinLength) return;
    setState(() {
      _entered += digit;
      _errorText = null;
    });
    if (_entered.length == kPinLength) {
      setState(() => _checking = true);
      final error = await widget.onSubmit(_entered);
      if (!mounted) return;
      if (error == null) {
        setState(() => _checking = false);
        return;
      }
      setState(() {
        _checking = false;
        _errorText = error;
        _entered = '';
        _shakeSignal++;
      });
    }
  }

  void _onBackspace() {
    if (_checking || _entered.isEmpty) return;
    setState(() => _entered = _entered.substring(0, _entered.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasError = _errorText != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          const Spacer(),
          Text(
            widget.title,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            hasError ? _errorText! : widget.subtitle,
            style: textTheme.bodyMedium?.copyWith(
              color: hasError ? scheme.error : scheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          PinDotsIndicator(
            filledCount: _entered.length,
            hasError: hasError,
            shakeSignal: _shakeSignal,
          ),
          const Spacer(),
          PinNumberPad(onDigit: _onDigit, onBackspace: _onBackspace),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
