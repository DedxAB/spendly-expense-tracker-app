import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:spendly/app/app_router.dart';
import 'package:spendly/core/notifications/local_notification_service.dart';
import 'package:spendly/core/theme/app_design_tokens.dart';
import 'package:spendly/core/theme/app_icons.dart';
import 'package:spendly/core/theme/app_theme.dart';
import 'package:spendly/features/activity/data/repositories/activity_repository_impl.dart';
import 'package:spendly/features/home/presentation/providers/home_provider.dart';
import 'package:spendly/features/recurring/presentation/providers/recurring_provider.dart';
import 'package:spendly/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:spendly/features/settings/presentation/providers/settings_provider.dart';

class SpendlyApp extends ConsumerWidget {
  const SpendlyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(recurringBootstrapProvider);
    ref.listen(settingsStreamProvider, (previous, next) async {
      final settings = next.valueOrNull;
      if (settings == null) return;
      final notifications = ref.read(localNotificationServiceProvider);
      await notifications.initialize();
      if (settings.dailyReminderEnabled) {
        await notifications.scheduleDailyReminder();
      } else {
        await notifications.cancelDailyReminder();
      }
    });
    ref.listen(dashboardSummaryProvider, (previous, next) async {
      final summary = next.valueOrNull;
      final settings = ref.read(settingsStreamProvider).valueOrNull;
      if (summary == null || settings == null) return;
      if (!settings.budgetAlertsEnabled) return;
      if (summary.remainingBudget >= 0) return;
      final now = DateTime.now();
      final last = settings.lastBudgetAlertAt;
      final alreadySentToday =
          last != null &&
          last.year == now.year &&
          last.month == now.month &&
          last.day == now.day;
      if (alreadySentToday) return;
      await ref
          .read(localNotificationServiceProvider)
          .showBudgetAlert(summary.remainingBudget.abs());
      await ref.read(settingsRepositoryProvider).markBudgetAlertNotified(now);
    });
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Spendly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme(),
      themeMode: ThemeMode.dark,
      routerConfig: router,
      builder: (context, child) {
        return PrivacyLockGate(child: child ?? const SizedBox.shrink());
      },
    );
  }
}

class PrivacyLockGate extends ConsumerStatefulWidget {
  const PrivacyLockGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<PrivacyLockGate> createState() => _PrivacyLockGateState();
}

class _PrivacyLockGateState extends ConsumerState<PrivacyLockGate>
    with WidgetsBindingObserver {
  bool _locked = true;
  bool _authenticating = false;
  bool _hasSeenEnabledState = false;
  bool _settingsResolvedOnce = false;
  bool _lastPrivacyEnabled = false;
  bool _visible = true;
  DateTime? _lastUsageTick;
  Timer? _usageTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _lastUsageTick = DateTime.now();
    _usageTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _flushUsage();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _usageTimer?.cancel();
    _flushUsage();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _visible = true;
      _lastUsageTick = DateTime.now();
      return;
    }
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _flushUsage();
      _visible = false;
    }

    final enabled =
        ref.read(settingsStreamProvider).valueOrNull?.privacyLockEnabled ??
        false;
    if (!enabled) return;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      setState(() => _locked = true);
    }
  }

  Future<void> _flushUsage() async {
    final now = DateTime.now();
    final last = _lastUsageTick;
    _lastUsageTick = now;
    if (last == null || !_visible || !_isContentVisible()) return;

    final elapsed = now.difference(last);
    if (elapsed.inSeconds < 1 || elapsed.inMinutes > 10) return;
    await ref.read(activityRepositoryProvider).addScreenTime(elapsed);
  }

  bool _isContentVisible() {
    final settings = ref.read(settingsStreamProvider).valueOrNull;
    if (settings == null) return false;
    if (!settings.privacyLockEnabled) return true;
    return !_locked;
  }

  Future<void> _unlock() async {
    if (_authenticating) return;
    setState(() => _authenticating = true);
    try {
      final authenticated = await LocalAuthentication().authenticate(
        localizedReason: 'Verify it is you to unlock Spendly.',
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
      if (!mounted) return;
      if (authenticated) {
        setState(() => _locked = false);
      }
    } on LocalAuthException catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not verify identity. Check biometrics or device lock settings.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _authenticating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsStreamProvider);
    final value = settings.valueOrNull;
    if (value == null) {
      return const _PrivacyBootScreen();
    }

    final enabled = value.privacyLockEnabled;
    if (!enabled) {
      _hasSeenEnabledState = false;
      _settingsResolvedOnce = true;
      _lastPrivacyEnabled = false;
      _locked = true;
      return widget.child;
    }
    final justEnabledInSession = _settingsResolvedOnce && !_lastPrivacyEnabled;
    _settingsResolvedOnce = true;
    _lastPrivacyEnabled = true;
    if (justEnabledInSession && !_hasSeenEnabledState) {
      _hasSeenEnabledState = true;
      _locked = false;
      return widget.child;
    }
    if (!_locked) return widget.child;

    return _PrivacyLockScreen(
      authenticating: _authenticating,
      onUnlock: _unlock,
    );
  }
}

class _PrivacyBootScreen extends StatelessWidget {
  const _PrivacyBootScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

class _PrivacyLockScreen extends StatelessWidget {
  const _PrivacyLockScreen({
    required this.authenticating,
    required this.onUnlock,
  });

  final bool authenticating;
  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: const Color(0xFF142119),
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  border: Border.all(color: const Color(0xFF2F6F46)),
                ),
                child: const Icon(
                  AppIcons.shield,
                  color: Color(0xFF57F28F),
                  size: 34,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Privacy Shield',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'Unlock Spendly to view your financial data.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFFBDBDBD), fontSize: 14),
              ),
              const SizedBox(height: AppSpacing.mdPlus),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  onPressed: authenticating ? null : onUnlock,
                  icon: authenticating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(AppIcons.shield, size: 18),
                  label: Text(
                    authenticating ? 'Verifying...' : 'Unlock with biometrics',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
