import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF111111);
  static const onPrimary = Color(0xFFF5F5F5);
  static const emerald = primary;

  static const darkBackgroundColor = Color(0xFF050505);
  static const darkSurfaceColor = Color(0xFF101112);
  static const darkSurfaceBorderColor = Color(0xFF26282B);
  static const darkTextPrimaryColor = Color(0xFFF5F5F5);
  static const darkTextSecondaryColor = Color(0xFF9A9A9A);
  static const success = Color(0xFF38D97A);
  static const danger = Color(0xFFFF5C6C);
  static const accent = Color(0xFF8B5CF6);

  static const income = success;
  static const expense = danger;

  static const darkBackground = darkBackgroundColor;
  static const darkSurface = darkSurfaceColor;
  static const darkSurfaceAlt = darkSurfaceColor;
  static const darkTextPrimary = darkTextPrimaryColor;
  static const darkTextSecondary = darkTextSecondaryColor;

  static const homeCard = darkSurfaceColor;
  static const homeCardSoft = darkSurfaceColor;
  static const homeCardMuted = Color(0xFF121314);
  static const homeBorder = darkSurfaceBorderColor;
  static const homeBorderSoft = Color(0xFF1B1D20);
  static const homeAccentGreen = success;
  static const homeAccentPurple = accent;
  static const homeAccentRed = danger;

  static const lightBackground = Color(0xFFF7F7F7);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceAlt = Color(0xFFF0F0F0);
  static const lightTextPrimary = Color(0xFF111111);
  static const lightTextSecondary = Color(0xFF666666);

  static const borderLight = Color(0xFFE0E0E0);
  static const borderDark = darkSurfaceBorderColor;

  static Color background(Brightness b) =>
      b == Brightness.dark ? darkBackgroundColor : lightBackground;
  static Color surface(Brightness b) =>
      b == Brightness.dark ? darkSurfaceColor : lightSurface;
  static Color surfaceAlt(Brightness b) =>
      b == Brightness.dark ? darkSurfaceColor : lightSurfaceAlt;
  static Color textPrimary(Brightness b) =>
      b == Brightness.dark ? darkTextPrimaryColor : lightTextPrimary;
  static Color textSecondary(Brightness b) =>
      b == Brightness.dark ? darkTextSecondaryColor : lightTextSecondary;
  static Color border(Brightness b) =>
      b == Brightness.dark ? darkSurfaceBorderColor : borderLight;
}

extension ThemeColors on BuildContext {
  Brightness get _b => Theme.of(this).brightness;
  Color get surface => AppColors.surface(_b);
  Color get surfaceAlt => AppColors.surfaceAlt(_b);
  Color get background => AppColors.background(_b);
  Color get textPrimary => AppColors.textPrimary(_b);
  Color get textSecondary => AppColors.textSecondary(_b);
  Color get border => AppColors.border(_b);
  Color get surfaceBorder => AppColors.homeBorder;
  Color get homeCard => AppColors.homeCard;
  Color get homeCardSoft => AppColors.homeCardSoft;
  Color get homeCardMuted => AppColors.homeCardMuted;
  Color get homeBorder => AppColors.homeBorder;
  Color get homeBorderSoft => AppColors.homeBorderSoft;
  Color get homeAccentGreen => AppColors.homeAccentGreen;
  Color get homeAccentPurple => AppColors.homeAccentPurple;
  Color get homeAccentRed => AppColors.homeAccentRed;
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
  static const card = 24.0;
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

class AppFontSizes {
  static const double caption = 10;
  static const double small = 11;
  static const double label = 12;
  static const double body = 13;
  static const double bodyLarge = 14;
  static const double button = 14;
  static const double subhead = 15;
  static const double title = 16;
  static const double heading = 18;
  static const double largeHeading = 20;
  static const double display = 22;
  static const double largeDisplay = 28;
  static const double hero = 32;
}
