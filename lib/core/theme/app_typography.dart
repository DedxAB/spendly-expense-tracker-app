import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spendly/core/theme/app_design_tokens.dart';
class AppTypography {
  static const String headingFamily = 'General Sans';
  static const String bodyFamily = 'Inter';

  static TextTheme textTheme(Brightness brightness) {
    final primary = brightness == Brightness.dark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final secondary = brightness == Brightness.dark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return TextTheme(
      headlineLarge: TextStyle(
        fontFamily: headingFamily,
        fontSize: AppFontSizes.largeDisplay,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.18,
        color: primary,
      ),
      headlineMedium: TextStyle(
        fontFamily: headingFamily,
        fontSize: AppFontSizes.display,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.24,
        color: primary,
      ),
      headlineSmall: TextStyle(
        fontFamily: headingFamily,
        fontSize: AppFontSizes.largeHeading,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.25,
        color: primary,
      ),
      titleLarge: TextStyle(
        fontFamily: headingFamily,
        fontSize: AppFontSizes.heading,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.28,
        color: primary,
      ),
      titleMedium: TextStyle(
        fontFamily: headingFamily,
        fontSize: AppFontSizes.title,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.3,
        color: primary,
      ),
      titleSmall: TextStyle(
        fontFamily: headingFamily,
        fontSize: AppFontSizes.bodyLarge,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        height: 1.32,
        color: primary,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: AppFontSizes.title,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.56,
        color: secondary,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: AppFontSizes.subhead,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.5,
        color: secondary,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: AppFontSizes.body,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.45,
        color: secondary,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: AppFontSizes.body,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.35,
        color: secondary,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: AppFontSizes.label,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        height: 1.38,
        color: secondary,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: AppFontSizes.caption,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.15,
        height: 1.35,
        color: secondary,
      ),
    );
  }

  static TextStyle screenTitle(BuildContext context) =>
      Theme.of(context).textTheme.headlineMedium ?? AppTypography._fallbackStyle(context, 24);

  static TextStyle sectionTitle(BuildContext context) =>
      Theme.of(context).textTheme.titleLarge ?? AppTypography._fallbackStyle(context, 20);

  static TextStyle cardTitle(BuildContext context) =>
      Theme.of(context).textTheme.titleMedium ?? AppTypography._fallbackStyle(context, 16);

  static TextStyle rowTitle(BuildContext context) =>
      (Theme.of(context).textTheme.bodyLarge ?? AppTypography._fallbackStyle(context, 14)).copyWith(
        color: Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.w500,
      );

  static TextStyle metadata(BuildContext context) =>
      Theme.of(context).textTheme.labelSmall ?? AppTypography._fallbackStyle(context, 11);

  static TextStyle _fallbackStyle(BuildContext context, double size) =>
      TextStyle(fontSize: size, color: Theme.of(context).colorScheme.onSurface);

  static TextStyle amount(
    BuildContext context, {
    Color? color,
    double fontSize = AppFontSizes.largeHeading,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
      height: 1.16,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle amountStyle(Color color) => GoogleFonts.inter(
    fontSize: AppFontSizes.largeHeading,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.16,
    color: color,
  );
}
