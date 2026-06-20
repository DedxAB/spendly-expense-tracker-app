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
          color: const Color(0xFF0E0E0E),
          border: Border.all(color: AppColors.borderDark),
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        child: const Icon(
          Icons.info_outline,
          size: 18,
          color: Color(0xFFD2D2D2),
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
                  style: const TextStyle(
                    color: Color(0xFFD0D0D0),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _SwipeHintRow(
                  color: AppColors.income,
                  background: const Color(0xFF11261B),
                  icon: AppIcons.edit,
                  text: leftActionLabel,
                ),
                const SizedBox(height: AppSpacing.sm),
                _SwipeHintRow(
                  color: AppColors.expense,
                  background: const Color(0xFF2A1313),
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
        border: Border.all(color: AppColors.borderDark),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.16),
              border: Border.all(color: color.withValues(alpha: 0.35)),
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
