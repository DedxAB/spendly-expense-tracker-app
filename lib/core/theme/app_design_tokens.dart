import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF111111);
  static const onPrimary = Color(0xFFF5F5F5);
  static const emerald = primary;

  static const income = Color(0xFF5BE39A);
  static const expense = Color(0xFFFF7A7A);

  static const lightBackground = Color(0xFFF7F7F7);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceAlt = Color(0xFFF0F0F0);
  static const lightTextPrimary = Color(0xFF111111);
  static const lightTextSecondary = Color(0xFF666666);

  static const darkBackground = Color(0xFF000000);
  static const darkSurface = Color(0xFF0E0E0E);
  static const darkSurfaceAlt = Color(0xFF0E0E0E);
  static const darkTextPrimary = Color(0xFFF2F2F2);
  static const darkTextSecondary = Color(0xFFABABAB);

  static const borderLight = Color(0xFFE0E0E0);
  static const borderDark = Color(0xFF212121);

  static Color background(Brightness b) =>
      b == Brightness.dark ? darkBackground : lightBackground;
  static Color surface(Brightness b) =>
      b == Brightness.dark ? darkSurface : lightSurface;
  static Color surfaceAlt(Brightness b) =>
      b == Brightness.dark ? darkSurfaceAlt : lightSurfaceAlt;
  static Color textPrimary(Brightness b) =>
      b == Brightness.dark ? darkTextPrimary : lightTextPrimary;
  static Color textSecondary(Brightness b) =>
      b == Brightness.dark ? darkTextSecondary : lightTextSecondary;
  static Color border(Brightness b) =>
      b == Brightness.dark ? borderDark : borderLight;
}

extension ThemeColors on BuildContext {
  Brightness get _b => Theme.of(this).brightness;
  Color get surface => AppColors.surface(_b);
  Color get surfaceAlt => AppColors.surfaceAlt(_b);
  Color get background => AppColors.background(_b);
  Color get textPrimary => AppColors.textPrimary(_b);
  Color get textSecondary => AppColors.textSecondary(_b);
  Color get border => AppColors.border(_b);
}

class AppSpacing {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const smPlus = 12.0;
  static const sm = 16.0;
  static const mdPlus = 20.0;
  static const md = 24.0;
  static const lg = 32.0;
  static const xl = 40.0;
}

class AppRadii {
  static const sm = 6.0;
  static const md = 10.0;
  static const lg = 14.0;
  static const xl = 20.0;
  static const premiumCard = 16.0;
  static const pill = 999.0;
}

class AppModalSizes {
  static const dialogContentWidth = 520.0;
  static const dialogMaxWidth = 560.0;
  static const sheetMaxWidth = 720.0;
  static const horizontalInset = 16.0;
  static const verticalInset = 24.0;
}

class AppElevation {
  static const card = 0.0;
  static const fab = 0.0;
  static const premiumCard = 18.0;
}
