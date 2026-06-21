import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/core/constants/app_enums.dart';
import 'package:spendly/features/settings/presentation/providers/settings_provider.dart';

final themeModeProvider = Provider<ThemeMode>((ref) {
  final settings = ref.watch(settingsStreamProvider).valueOrNull;
  final mode = settings?.themeMode ?? AppThemeMode.system;
  switch (mode) {
    case AppThemeMode.light:
      return ThemeMode.light;
    case AppThemeMode.dark:
      return ThemeMode.dark;
    case AppThemeMode.system:
      return ThemeMode.system;
  }
});
