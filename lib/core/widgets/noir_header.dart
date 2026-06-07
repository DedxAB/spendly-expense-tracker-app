import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spendly/core/theme/app_design_tokens.dart';
import 'package:spendly/features/user/presentation/providers/user_profile_provider.dart';

class NoirHeader extends ConsumerWidget implements PreferredSizeWidget {
  const NoirHeader({
    super.key,
    this.showLeading = false,
    this.leadingIcon = Icons.calendar_month_outlined,
    this.onLeadingTap,
    this.onProfileTap,
    this.showProfileAction = true,
  });

  final bool showLeading;
  final IconData leadingIcon;
  final VoidCallback? onLeadingTap;
  final VoidCallback? onProfileTap;
  final bool showProfileAction;

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final imageUrl = (profile?.imageUrl?.trim().isNotEmpty ?? false)
        ? profile!.imageUrl!.trim()
        : null;

    return AppBar(
      toolbarHeight: 72,
      centerTitle: true,
      title: Text(
        'Spendly',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.9,
        ),
      ),
      leading: showLeading
          ? IconButton(
              icon: Icon(leadingIcon, size: 22),
              onPressed: onLeadingTap,
            )
          : const SizedBox.shrink(),
      leadingWidth: showLeading ? 56 : 0,
      actions: showProfileAction
          ? [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: InkWell(
                  onTap: onProfileTap ?? () => context.push('/settings'),
                  borderRadius: BorderRadius.zero,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      border: Border.all(color: AppColors.borderDark),
                    ),
                    child: imageUrl == null
                        ? const Icon(Icons.person, size: 18)
                        : Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.person, size: 18),
                          ),
                  ),
                ),
              ),
            ]
          : const [],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, thickness: 1, color: AppColors.borderDark),
      ),
    );
  }
}
