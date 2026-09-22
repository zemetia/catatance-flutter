import 'package:flutter/material.dart';

/// A circular avatar showing the first letter of [name] on the primary
/// color — used for the greeting header and the profile identity card.
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({required this.name, this.radius = 26, super.key});

  final String name;
  final double radius;

  String get _initial =>
      name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final style = radius >= 30 ? textTheme.headlineSmall : textTheme.titleMedium;

    return CircleAvatar(
      radius: radius,
      backgroundColor: scheme.primary,
      child: Text(
        _initial,
        style: style?.copyWith(color: scheme.onPrimary, fontWeight: FontWeight.w700),
      ),
    );
  }
}
