import 'package:flutter/material.dart';
import 'package:spendly/core/theme/app_design_tokens.dart';
import 'package:spendly/core/theme/app_icons.dart';
import 'package:spendly/core/theme/app_typography.dart';
import 'package:spendly/core/widgets/app_modal_surface.dart';

class SwipeActionsInfoButton extends StatelessWidget {
  const SwipeActionsInfoButton({
    super.key,
    this.tooltip = 'Swipe actions',
    this.title = 'Swipe actions',
    this.message = 'Swipe cards horizontally to reveal actions.',
    this.leftActionLabel = 'Swipe right to edit',
    this.rightActionLabel = 'Swipe left to delete',
  });

  final String tooltip;
  final String title;
  final String message;
  final String leftActionLabel;
  final String rightActionLabel;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      onPressed: () => _showSheet(context),
      icon: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.surface,
          border: Border.all(color: context.border),
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        child: Icon(
          Icons.info_outline,
          size: 18,
          color: context.textSecondary,
        ),
      ),
    );
  }

  void _showSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      showDragHandle: false,
      builder: (sheetContext) {
        return AppModalSurface(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTypography.sectionTitle(sheetContext),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      icon: const Icon(Icons.close, size: 18),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: TextStyle(
                    color: context.textSecondary,
                    fontSize: AppFontSizes.body,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _SwipeHintRow(
                  color: AppColors.income,
                  background: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF11261B)
                      : const Color(0xFFE6F7E6),
                  icon: AppIcons.edit,
                  text: leftActionLabel,
                ),
                const SizedBox(height: AppSpacing.sm),
                _SwipeHintRow(
                  color: AppColors.expense,
                  background: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF2A1313)
                      : const Color(0xFFFDE8E8),
                  icon: AppIcons.trash,
                  text: rightActionLabel,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SwipeHintRow extends StatelessWidget {
  const _SwipeHintRow({
    required this.color,
    required this.background,
    required this.icon,
    required this.text,
  });

  final Color color;
  final Color background;
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: context.border),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.textPrimary.withValues(alpha: 0.16),
              border: Border.all(color: color.withValues(alpha: 0.35)),
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                        color: context.textPrimary,
                        fontSize: AppFontSizes.bodyLarge,
                        fontWeight: FontWeight.w600,
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
