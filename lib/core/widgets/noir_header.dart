import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spendly/core/theme/app_design_tokens.dart';
import 'package:spendly/core/theme/app_icons.dart';

class NoirHeader extends ConsumerWidget implements PreferredSizeWidget {
  const NoirHeader({
    super.key,
    this.showLeading = false,
    this.leadingAsCard = true,
    this.leadingIcon = Icons.arrow_back,
    this.leadingIconColor,
    this.onLeadingTap,
    this.title,
  });

  final bool showLeading;
  final bool leadingAsCard;
  final IconData leadingIcon;
  final Color? leadingIconColor;
  final VoidCallback? onLeadingTap;
  final String? title;

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      toolbarHeight: 70,
      centerTitle: false,
      titleSpacing: 0,
      title: title != null
          ? Padding(
              padding: const EdgeInsets.only(left: AppSpacing.sm),
              child: Text(
                title!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
      leading: showLeading
          ? leadingAsCard
              ? Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.sm),
                  child: _IconCard(
                    icon: leadingIcon,
                    onTap: onLeadingTap ?? () {},
                  ),
                )
              : IconButton(
                  icon: Icon(
                    leadingIcon,
                    size: 22,
                    color: leadingIconColor ??
                        AppIcons.getColorForIcon(
                          leadingIcon,
                          brightness: Theme.of(context).brightness,
                        ),
                  ),
                  onPressed: onLeadingTap,
                )
          : const SizedBox.shrink(),
      leadingWidth: showLeading ? (leadingAsCard ? 64 : 56) : 0,
      actions: [
        _IconCard(
          icon: AppIcons.settings,
          onTap: () => context.push('/settings'),
        ),
        const SizedBox(width: 8),
        _IconCard(
          icon: AppIcons.bell,
          onTap: () => context.push('/notifications'),
        ),
        const SizedBox(width: AppSpacing.sm),
      ],
    );
  }
}

class _IconCard extends StatelessWidget {
  const _IconCard({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.border),
        ),
        child: Icon(icon, size: 20, color: context.textPrimary),
      ),
    );
  }
}
