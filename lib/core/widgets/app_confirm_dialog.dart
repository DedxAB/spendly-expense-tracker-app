import 'package:flutter/material.dart';
import 'package:spendly/core/theme/app_design_tokens.dart';
import 'package:spendly/core/widgets/dialog_actions_row.dart';

Future<bool> showAppDeleteConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmText = 'Delete',
}) async {
  final result = await showDialog<bool>(
    context: context,
    useRootNavigator: true,
    builder: (dialogContext) {
      final rootNav = Navigator.of(dialogContext, rootNavigator: true);
      final theme = Theme.of(dialogContext);
      final titleStyle = theme.textTheme.titleLarge;
      final messageStyle = theme.textTheme.bodyMedium?.copyWith(height: 1.45);
      final surfaceColor = theme.colorScheme.surface;
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        backgroundColor: surfaceColor,
        surfaceTintColor: Colors.transparent,
        titlePadding: const EdgeInsets.fromLTRB(
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.xs,
        ),
        contentPadding: const EdgeInsets.fromLTRB(
          AppSpacing.sm,
          0,
          AppSpacing.sm,
          AppSpacing.sm,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(
          AppSpacing.sm,
          0,
          AppSpacing.sm,
          AppSpacing.sm,
        ),
        title: Text(title, style: titleStyle),
        content: SizedBox(
          width: AppModalSizes.dialogContentWidth,
          child: Text(message, style: messageStyle),
        ),
        actions: [
          DialogActionsRow(
            cancelText: 'Cancel',
            confirmText: confirmText,
            confirmColor: const Color(0xFFD94545),
            onCancel: () => rootNav.pop(false),
            onConfirm: () => rootNav.pop(true),
          ),
        ],
      );
    },
  );
  return result == true;
}
