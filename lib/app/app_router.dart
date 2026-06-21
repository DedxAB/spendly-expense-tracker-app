import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spendly/core/constants/app_enums.dart';
import 'package:spendly/core/theme/app_design_tokens.dart';
import 'package:spendly/core/theme/app_icons.dart';
import 'package:spendly/features/activity/presentation/pages/activity_screen_time_page.dart';
import 'package:spendly/features/categories/presentation/pages/categories_page.dart';
import 'package:spendly/features/cloud_sync/data/repositories/cloud_sync_repository_impl.dart';
import 'package:spendly/features/home/presentation/pages/home_page.dart';
import 'package:spendly/features/insights/presentation/pages/insights_page.dart';
import 'package:spendly/features/lend/presentation/pages/lend_page.dart';
import 'package:spendly/features/lend/presentation/pages/lend_person_detail_page.dart';
import 'package:spendly/features/goals/presentation/pages/goals_page.dart';
import 'package:spendly/features/recurring/presentation/pages/recurring_page.dart';
import 'package:spendly/features/settings/presentation/pages/budget_page.dart';
import 'package:spendly/features/settings/presentation/pages/notifications_page.dart';
import 'package:spendly/features/settings/presentation/pages/settings_page.dart';
import 'package:spendly/features/transactions/presentation/pages/add_transaction_page.dart';
import 'package:spendly/features/transactions/presentation/pages/calendar_page.dart';
import 'package:spendly/features/transactions/presentation/pages/transactions_page.dart';
import 'package:spendly/features/user/presentation/pages/profile_onboarding_page.dart';
import 'package:spendly/features/user/presentation/providers/user_profile_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),
      GoRoute(
        path: '/onboarding/profile',
        builder: (context, state) => const ProfileOnboardingPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (context, state) => const HomePage()),
          GoRoute(
            path: '/transactions',
            builder: (context, state) => const TransactionsPage(),
          ),
          GoRoute(
            path: '/goals',
            builder: (context, state) => const GoalsPage(),
          ),
          GoRoute(
            path: '/budget',
            builder: (context, state) => const BudgetPage(),
          ),
          GoRoute(
            path: '/insights',
            builder: (context, state) => const InsightsPage(),
          ),
        ],
      ),
      GoRoute(
        path: '/transactions/new',
        builder: (context, state) {
          final rawType = state.uri.queryParameters['type'];
          final initialType = switch (rawType) {
            'income' => TransactionType.income,
            'expense' => TransactionType.expense,
            'investment' => TransactionType.investment,
            _ => null,
          };
          return AddTransactionPage(initialType: initialType);
        },
      ),
      GoRoute(
        path: '/calendar',
        builder: (context, state) => const CalendarPage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/activity',
        builder: (context, state) => const ActivityScreenTimePage(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: '/categories',
        builder: (context, state) => const CategoriesPage(),
      ),
      GoRoute(
        path: '/recurring',
        builder: (context, state) => const RecurringPage(),
      ),
      GoRoute(path: '/lend', builder: (context, state) => const LendPage()),
      GoRoute(
        path: '/lend/:personId',
        builder: (context, state) {
          final personId = state.pathParameters['personId'] ?? '';
          return LendPersonDetailPage(personId: personId);
        },
      ),
    ],
  );
});

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    ref.read(cloudSyncRepositoryProvider).runDailyBackupIfNeeded();
    final profile = await ref.read(userProfileProvider.future);
    if (!mounted) return;
    if (profile.onboardingCompleted) {
      context.go('/home');
      return;
    }
    context.go('/onboarding/profile');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: CurvedAnimation(parent: _controller, curve: Curves.easeOut),
        child: Center(
          child: Text(
            'Spendly',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  int _indexForLocation(String location) {
    if (location.startsWith('/transactions')) return 1;
    if (location.startsWith('/insights')) return 2;
    if (location.startsWith('/budget')) return 3;
    if (location.startsWith('/goals')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final selectedIndex = _indexForLocation(location);
    final items = [
      _ShellNavItem(
        icon: AppIcons.home,
        selectedIcon: AppIcons.home,
        label: 'Home',
      ),
      _ShellNavItem(
        icon: AppIcons.history,
        selectedIcon: AppIcons.history,
        label: 'History',
      ),
      _ShellNavItem(
        icon: AppIcons.analytics,
        selectedIcon: AppIcons.analytics,
        label: 'Analytics',
      ),
      _ShellNavItem(
        icon: AppIcons.budget,
        selectedIcon: AppIcons.budget,
        label: 'Budget',
      ),
      _ShellNavItem(
        icon: AppIcons.goals,
        selectedIcon: AppIcons.goals,
        label: 'Goals',
      ),
    ];

    return Scaffold(
      body: child,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          height: 62,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: context.surface,
            border: Border(
              top: BorderSide(color: context.border),
            ),
          ),
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _ShellNavTile(
                    item: items[i],
                    selected: i == selectedIndex,
                    onTap: () {
                      if (i == 0) {
                        context.go('/home');
                        return;
                      }
                      if (i == 1) {
                        context.go('/transactions');
                        return;
                      }
                      if (i == 2) {
                        context.go('/insights');
                        return;
                      }
                      if (i == 3) {
                        context.go('/budget');
                        return;
                      }
                      if (i == 4) {
                        context.go('/goals');
                      }
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShellNavItem {
  _ShellNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

class _ShellNavTile extends StatelessWidget {
  const _ShellNavTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _ShellNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.md),
      onTap: onTap,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 0,
            left: 12,
            right: 12,
            child: Container(
              height: 2,
              color: selected ? context.textPrimary : Colors.transparent,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                selected ? item.selectedIcon : item.icon,
                size: 19,
                color: AppIcons.getColorForIcon(
                  selected ? item.selectedIcon : item.icon,
                  label: item.label,
                  brightness: Theme.of(context).brightness,
                ).withValues(alpha: selected ? 1.0 : 0.62),
              ),
              const SizedBox(height: 4),
              Text(
                item.label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  letterSpacing: 0,
                  color: selected
                      ? context.textPrimary
                      : context.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
