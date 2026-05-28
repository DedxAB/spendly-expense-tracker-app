import 'package:flutter/material.dart';
import 'package:spendly/core/theme/app_design_tokens.dart';
import 'package:spendly/core/widgets/dialog_actions_row.dart';

Future<String?> showAppTextInputDialog(
  BuildContext context, {
  required String title,
  String? message,
  String hintText = '',
  String confirmText = 'Save',
  String cancelText = 'Cancel',
  TextInputType keyboardType = TextInputType.text,
  TextCapitalization textCapitalization = TextCapitalization.none,
  String initialValue = '',
}) async {
  return showDialog<String>(
    context: context,
    useRootNavigator: true,
    builder: (dialogContext) {
      final theme = Theme.of(dialogContext);
      final titleStyle = theme.textTheme.titleLarge;
      final messageStyle = theme.textTheme.bodyMedium?.copyWith(height: 1.45);
      final surfaceColor = theme.colorScheme.surface;
      return _AppTextInputDialog(
        title: title,
        titleStyle: titleStyle,
        message: message,
        messageStyle: messageStyle,
        hintText: hintText,
        confirmText: confirmText,
        cancelText: cancelText,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        initialValue: initialValue,
        surfaceColor: surfaceColor,
      );
    },
  );
}

class _AppTextInputDialog extends StatefulWidget {
  const _AppTextInputDialog({
    required this.title,
    required this.titleStyle,
    required this.message,
    required this.messageStyle,
    required this.hintText,
    required this.confirmText,
    required this.cancelText,
    required this.keyboardType,
    required this.textCapitalization,
    required this.initialValue,
    required this.surfaceColor,
  });

  final String title;
  final TextStyle? titleStyle;
  final String? message;
  final TextStyle? messageStyle;
  final String hintText;
  final String confirmText;
  final String cancelText;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final String initialValue;
  final Color surfaceColor;

  @override
  State<_AppTextInputDialog> createState() => _AppTextInputDialogState();
}

class _AppTextInputDialogState extends State<_AppTextInputDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rootNav = Navigator.of(context, rootNavigator: true);
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      backgroundColor: widget.surfaceColor,
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
      title: Text(widget.title, style: widget.titleStyle),
      content: SizedBox(
        width: AppModalSizes.dialogContentWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.message != null &&
                widget.message!.trim().isNotEmpty) ...[
              Text(widget.message!, style: widget.messageStyle),
              const SizedBox(height: AppSpacing.sm),
            ],
            TextField(
              controller: _controller,
              keyboardType: widget.keyboardType,
              textCapitalization: widget.textCapitalization,
              autofocus: true,
              decoration: InputDecoration(hintText: widget.hintText),
            ),
          ],
        ),
      ),
      actions: [
        DialogActionsRow(
          cancelText: widget.cancelText,
          confirmText: widget.confirmText,
          onCancel: () => rootNav.pop(null),
          onConfirm: () {
            final value = _controller.text.trim();
            if (value.isEmpty) return;
            rootNav.pop(value);
          },
        ),
      ],
    );
  }
}
