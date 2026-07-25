import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:spendly/core/lock/privacy_lock_controller.dart';
import 'package:spendly/core/theme/app_design_tokens.dart';
import 'package:spendly/core/theme/app_icons.dart';
import 'package:spendly/core/widgets/app_toast.dart';
import 'package:spendly/features/activity/data/repositories/activity_repository_impl.dart';
import 'package:spendly/features/settings/presentation/providers/settings_provider.dart';

class PrivacyLockGate extends ConsumerStatefulWidget {
  const PrivacyLockGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<PrivacyLockGate> createState() => _PrivacyLockGateState();
}

class _PrivacyLockGateState extends ConsumerState<PrivacyLockGate>
    with WidgetsBindingObserver {
  bool _authenticating = false;
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
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    ref.read(privacyLockProvider.notifier).onAppLifecycleChanged(state);

    if (state == AppLifecycleState.resumed) {
      _visible = true;
      _lastUsageTick = DateTime.now();
    } else if (state == AppLifecycleState.inactive) {
      _flushUsage();
      _visible = false;
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _flushUsage();
      _visible = false;
    }
  }

  Future<void> _flushUsage() async {
    if (!mounted) return;
    final now = DateTime.now();
    final last = _lastUsageTick;
    _lastUsageTick = now;
    if (last == null || !_visible) return;

    final elapsed = now.difference(last);
    if (elapsed.inSeconds < 1 || elapsed.inMinutes > 10) return;
    if (!mounted) return;
    await ref.read(activityRepositoryProvider).addScreenTime(elapsed);
  }

  Future<void> _unlock() async {
    if (_authenticating) return;
    setState(() => _authenticating = true);
    try {
      await ref.read(privacyLockProvider.notifier).authenticate();
    } on LocalAuthException {
      if (!mounted) return;
      showAppToast(
        context,
        'Could not verify identity. Check biometrics or device lock settings.',
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
    final controller = ref.read(privacyLockProvider.notifier);
    controller.onSettingsChanged(enabled);

    if (!enabled) {
      return widget.child;
    }

    final status = ref.watch(privacyLockProvider);

    if (status == PrivacyLockStatus.unlocked) {
      return widget.child;
    }

    if (status == PrivacyLockStatus.locked && !_authenticating) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final current = ref.read(privacyLockProvider);
        if (current != PrivacyLockStatus.locked || _authenticating) return;
        _unlock();
      });
    }

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
                  color: Color(0xFF3DD07B),
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
                style: TextStyle(
                  color: Color(0xFFBDBDBD),
                  fontSize: AppFontSizes.bodyLarge,
                ),
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
                    authenticating ? 'Verifying...' : 'Try again',
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
