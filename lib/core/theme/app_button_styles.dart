import 'package:flutter/material.dart';
import 'package:spendly/core/theme/app_design_tokens.dart';

class AppButtonStyles {
  const AppButtonStyles._();

  static ButtonStyle primary(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FilledButton.styleFrom(
      minimumSize: const Size(0, 48),
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      textStyle: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }

  static ButtonStyle secondary(BuildContext context) {
    final border = Theme.of(context).dividerColor;
    return OutlinedButton.styleFrom(
      minimumSize: const Size(0, 48),
      side: BorderSide(color: border),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
    );
  }

  static ButtonStyle danger(BuildContext context) {
    return OutlinedButton.styleFrom(
      minimumSize: const Size(0, 48),
      foregroundColor: const Color(0xFFFF9A9A),
      side: const BorderSide(color: Color(0xFF7A2A2A)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
    );
  }

  static ButtonStyle ghost(BuildContext context) {
    return TextButton.styleFrom(
      minimumSize: const Size(0, 46),
      textStyle: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}
