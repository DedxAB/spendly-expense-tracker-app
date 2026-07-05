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
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.18,
        color: primary,
      ),
      headlineMedium: TextStyle(
        fontFamily: headingFamily,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.24,
        color: primary,
      ),
      headlineSmall: TextStyle(
        fontFamily: headingFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.25,
        color: primary,
      ),
      titleLarge: TextStyle(
        fontFamily: headingFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.28,
        color: primary,
      ),
      titleMedium: TextStyle(
        fontFamily: headingFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.3,
        color: primary,
      ),
      titleSmall: TextStyle(
        fontFamily: headingFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        height: 1.32,
        color: primary,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.56,
        color: secondary,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.5,
        color: secondary,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.45,
        color: secondary,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.35,
        color: secondary,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        height: 1.38,
        color: secondary,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.15,
        height: 1.35,
        color: secondary,
      ),
    );
  }

  static TextStyle screenTitle(BuildContext context) =>
      Theme.of(context).textTheme.headlineMedium!;

  static TextStyle sectionTitle(BuildContext context) =>
      Theme.of(context).textTheme.titleLarge!;

  static TextStyle cardTitle(BuildContext context) =>
      Theme.of(context).textTheme.titleMedium!;

  static TextStyle rowTitle(BuildContext context) =>
      Theme.of(context).textTheme.bodyLarge!.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.w500,
      );

  static TextStyle metadata(BuildContext context) =>
      Theme.of(context).textTheme.labelSmall!;

  static TextStyle amount(
    BuildContext context, {
    Color? color,
    double fontSize = 20,
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
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.16,
    color: color,
  );
}
