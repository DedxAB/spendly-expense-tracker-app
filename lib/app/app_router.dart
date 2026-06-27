import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import 'package:spendly/core/constants/app_enums.dart';
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
        builder: (context, state, child) => AppShell(
          currentLocation: state.uri.toString(),
          child: child,
        ),
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

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.currentLocation, required this.child});

  final String currentLocation;
  final Widget child;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  int _indexForLocation(String location) {
    if (location.startsWith('/transactions')) return 1;
    if (location.startsWith('/insights')) return 2;
    if (location.startsWith('/budget')) return 3;
    if (location.startsWith('/goals')) return 4;
    return 0;
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = _indexForLocation(widget.currentLocation);
  }

  @override
  void didUpdateWidget(covariant AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newIdx = _indexForLocation(widget.currentLocation);
    if (newIdx != _selectedIndex) {
      setState(() => _selectedIndex = newIdx);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _selectedIndex;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final accent = isDark ? Colors.white : Colors.black;

    final items = [
      LiquidGlassTabBarItem(icon: AppIcons.home, label: 'Home'),
      LiquidGlassTabBarItem(icon: AppIcons.history, label: 'History'),
      LiquidGlassTabBarItem(icon: AppIcons.analytics, label: 'Analytics'),
      LiquidGlassTabBarItem(icon: AppIcons.budget, label: 'Budget'),
      LiquidGlassTabBarItem(icon: AppIcons.goals, label: 'Goals'),
    ];

    return Scaffold(
      body: Stack(
        children: [
          widget.child,
          LiquidGlassBottomNavBar.withImpeller(
            items: items,
            selectedIndex: selectedIndex,
            onChanged: (i) {
              setState(() => _selectedIndex = i);
              if (i == 0) { context.go('/home'); return; }
              if (i == 1) { context.go('/transactions'); return; }
              if (i == 2) { context.go('/insights'); return; }
              if (i == 3) { context.go('/budget'); return; }
              if (i == 4) { context.go('/goals'); }
            },
            width: screenWidth - 32,
            height: 54,
            margin: const EdgeInsets.only(bottom: 8),
            itemStyle: LiquidGlassNavItemStyle(
              selectedColor: isDark ? const Color(0xFF64B5F6) : const Color(0xFF0A84FF),
              unselectedColor: accent.withValues(alpha: 0.35),
              iconSize: 20,
              labelFontSize: 9,
              iconLabelGap: 1,
            ),
            pillStyle: const LiquidGlassNavPillStyle(
              mode: LiquidGlassPillMode.impellerOnly,
              show: true,
              animated: true,
              growHeight: 3,
              distortion: 0.06,
              distortionWidth: 10,
              magnification: 1.02,
              travelStiffness: 280,
              travelDamping: 31.4,
            ),
            style: LiquidGlassBottomNavBar.defaultStyle.copyWith(
              refraction: const LiquidGlassRefraction(
                distortion: 0.05,
                distortionWidth: 20,
                chromaticAberration: 0.003,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
