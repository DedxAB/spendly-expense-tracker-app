import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:spendly/features/settings/presentation/providers/settings_provider.dart';

enum PrivacyLockStatus { booting, locked, unlocked }

class PrivacyLockController extends StateNotifier<PrivacyLockStatus> {
  PrivacyLockController(this._ref) : super(PrivacyLockStatus.booting);

  final Ref _ref;
  DateTime? _backgroundedAt;
  bool _hasSeenEnabledState = false;
  bool _settingsResolvedOnce = false;
  bool _lastPrivacyEnabled = false;

  static const _gracePeriod = Duration(seconds: 30);

  void onSettingsChanged(bool enabled) {
    if (!enabled) {
      _hasSeenEnabledState = false;
      _settingsResolvedOnce = true;
      _lastPrivacyEnabled = false;
      state = PrivacyLockStatus.unlocked;
      _backgroundedAt = null;
      return;
    }

    final justEnabledInSession = _settingsResolvedOnce && !_lastPrivacyEnabled;
    _settingsResolvedOnce = true;
    _lastPrivacyEnabled = true;

    if (justEnabledInSession && !_hasSeenEnabledState) {
      _hasSeenEnabledState = true;
      state = PrivacyLockStatus.unlocked;
      return;
    }

    if (state == PrivacyLockStatus.booting) {
      state = PrivacyLockStatus.locked;
    }
  }

  void onAppLifecycleChanged(AppLifecycleState lifecycleState) {
    final enabled =
        _ref.read(settingsStreamProvider).valueOrNull?.privacyLockEnabled ??
        false;
    if (!enabled) return;

    if (lifecycleState == AppLifecycleState.resumed) {
      if (_backgroundedAt != null) {
        final away = DateTime.now().difference(_backgroundedAt!);
        _backgroundedAt = null;
        if (!away.isNegative && away <= _gracePeriod) {
          if (state == PrivacyLockStatus.locked) {
            state = PrivacyLockStatus.unlocked;
          }
          return;
        }
        state = PrivacyLockStatus.locked;
      }
    } else if (lifecycleState == AppLifecycleState.paused ||
        lifecycleState == AppLifecycleState.hidden) {
      _backgroundedAt = DateTime.now();
    }
  }

  Future<bool> authenticate() async {
    if (state != PrivacyLockStatus.locked) return true;
    try {
      final auth = LocalAuthentication();
      final result = await auth.authenticate(
        localizedReason: 'Verify it is you to unlock Spendly.',
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
      if (result) {
        state = PrivacyLockStatus.unlocked;
      }
      return result;
    } on LocalAuthException {
      return false;
    }
  }

  void resetForColdStart() {
    state = PrivacyLockStatus.booting;
    _backgroundedAt = null;
  }
}

final privacyLockProvider = StateNotifierProvider<PrivacyLockController, PrivacyLockStatus>(
  (ref) => PrivacyLockController(ref),
);
