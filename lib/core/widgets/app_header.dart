import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spendly/core/theme/app_design_tokens.dart';
import 'package:spendly/core/theme/app_icons.dart';
import 'package:spendly/features/user/presentation/providers/user_profile_provider.dart';

enum AppHeaderMode {
  home,
  back,
  calendar,
  title,
}

class AppHeader extends ConsumerWidget implements PreferredSizeWidget {
  const AppHeader({
    super.key,
    this.mode = AppHeaderMode.title,
    this.title,
    this.onLeadingTap,
  });

  final AppHeaderMode mode;
  final String? title;
  final VoidCallback? onLeadingTap;

  @override
  Size get preferredSize => const Size.fromHeight(70);

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHome = mode == AppHeaderMode.home;
    final hasLeading = mode != AppHeaderMode.title;

    return AppBar(
      toolbarHeight: 70,
      automaticallyImplyLeading: false,
      titleSpacing: hasLeading ? 0 : AppSpacing.smPlus,
      centerTitle: !isHome,
      leadingWidth: hasLeading ? 60 : null,
      leading: hasLeading ? _buildLeading(context, ref) : null,
      title: _buildTitle(context, ref),
      actions: [
        _IconCard(
          icon: AppIcons.settings,
          onTap: () => context.push('/settings'),
        ),
        const SizedBox(width: 8),
        _IconCard(
          icon: AppIcons.bell,
          showDot: isHome,
          onTap: () => context.push('/notifications'),
        ),
        const SizedBox(width: AppSpacing.smPlus),
      ],
    );
  }

  Widget _buildLeading(BuildContext context, WidgetRef ref) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: AppSpacing.smPlus),
        child: _buildIcon(context, ref),
      ),
    );
  }

  Widget _buildIcon(BuildContext context, WidgetRef ref) {
    switch (mode) {
      case AppHeaderMode.home:
        return _buildAvatar(context, ref);
      case AppHeaderMode.back:
        return _IconCard(
          icon: AppIcons.arrowBack,
          onTap: onLeadingTap ?? () => Navigator.of(context).maybePop(),
        );
      case AppHeaderMode.calendar:
        return _IconCard(
          icon: AppIcons.calendar,
          onTap: onLeadingTap ?? () => context.push('/calendar'),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget? _buildTitle(BuildContext context, WidgetRef ref) {
    switch (mode) {
      case AppHeaderMode.home:
        return _buildGreeting(context, ref);
      case AppHeaderMode.back:
      case AppHeaderMode.calendar:
      case AppHeaderMode.title:
        if (title == null) return null;
        return Text(
          title!,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        );
    }
  }

  Widget _buildAvatar(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final imageUrl = (profile?.imageUrl?.trim().isNotEmpty ?? false)
        ? profile!.imageUrl!.trim()
        : null;

    return InkWell(
      onTap: () => context.push('/settings'),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: imageUrl == null
            ? const _AvatarFallback()
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const _AvatarFallback(),
              ),
      ),
    );
  }

  Widget _buildGreeting(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final name = profile?.name.trim() ?? 'User';
    final firstName = name.contains(' ') ? name.split(' ').first : name;

    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Hi, $firstName',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _greeting(),
            style: TextStyle(
              color: context.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconCard extends StatelessWidget {
  const _IconCard({
    required this.icon,
    required this.onTap,
    this.showDot = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: context.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: context.border),
            ),
            child: Icon(icon, size: 22, color: context.textPrimary),
          ),
          if (showDot)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: context.homeAccentGreen,
                  shape: BoxShape.circle,
                  border: Border.all(color: context.background, width: 1.2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFFF59E0B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(AppIcons.user, size: 24, color: context.background),
    );
  }
}
