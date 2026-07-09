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
  String? requiredLabel,
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
        requiredLabel: requiredLabel,
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
    this.requiredLabel,
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
  final String? requiredLabel;

  @override
  State<_AppTextInputDialog> createState() => _AppTextInputDialogState();
}

class _AppTextInputDialogState extends State<_AppTextInputDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue,
  );
  var _formAttempted = false;

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
            if (widget.requiredLabel != null) ...[
              Row(
                children: [
                  Text(
                    widget.requiredLabel!,
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: AppFontSizes.label,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Text(
                    ' *',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: AppFontSizes.label,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],
            TextField(
              controller: _controller,
              keyboardType: widget.keyboardType,
              textCapitalization: widget.textCapitalization,
              autofocus: true,
              decoration: InputDecoration(hintText: widget.hintText),
            ),
            if (widget.requiredLabel != null &&
                _formAttempted &&
                _controller.text.trim().isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'Name is required',
                  style: TextStyle(color: Colors.red, fontSize: AppFontSizes.label),
                ),
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
            setState(() {
              _formAttempted = true;
            });
            final value = _controller.text.trim();
            if (value.isEmpty) return;
            rootNav.pop(value);
          },
        ),
      ],
    );
  }
}
