import 'package:flutter/material.dart';
import 'package:spendly/core/theme/app_button_styles.dart';
import 'package:spendly/core/theme/app_design_tokens.dart';

class DialogActionsRow extends StatelessWidget {
  const DialogActionsRow({
    super.key,
    required this.onCancel,
    required this.onConfirm,
    this.cancelText = 'Cancel',
    this.confirmText = 'Save',
    this.confirmColor,
  });

  final VoidCallback onCancel;
  final VoidCallback? onConfirm;
  final String cancelText;
  final String confirmText;
  final Color? confirmColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const buttonHeight = 48.0;
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: buttonHeight,
            child: OutlinedButton(
              style: AppButtonStyles.danger(context),
              onPressed: onCancel,
              child: Text(cancelText),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: SizedBox(
            height: buttonHeight,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: confirmColor ?? scheme.primary,
                foregroundColor: confirmColor == null
                    ? scheme.onPrimary
                    : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              onPressed: onConfirm,
              child: Text(confirmText),
            ),
          ),
        ),
      ],
    );
  }
}
