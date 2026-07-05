import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spendly/core/theme/app_date_picker_theme.dart';
import 'package:spendly/core/theme/app_design_tokens.dart';
import 'package:spendly/core/theme/app_typography.dart';

class AppTheme {
  static ThemeData lightTheme() {
    const scheme = ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.primary,
      surface: AppColors.lightSurface,
      error: AppColors.expense,
      onPrimary: AppColors.onPrimary,
      onSurface: AppColors.lightTextPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.lightBackground,
      textTheme: AppTypography.textTheme(Brightness.light),
      fontFamily: AppTypography.bodyFamily,
      iconTheme: const IconThemeData(color: Color(0xFF4B4B4B)),
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: AppElevation.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          side: const BorderSide(color: Color(0xFFF1F1F1)),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2E2E2E)),
        actionsIconTheme: const IconThemeData(color: Color(0xFF2E2E2E)),
        titleTextStyle: AppTypography.textTheme(
          Brightness.light,
        ).titleLarge?.copyWith(color: AppColors.lightTextPrimary),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      ),
      dividerColor: AppColors.borderLight,
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.lightSurface,
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: AppModalSizes.horizontalInset,
          vertical: AppModalSizes.verticalInset,
        ),
        constraints: const BoxConstraints(
          maxWidth: AppModalSizes.dialogMaxWidth,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          side: const BorderSide(color: AppColors.borderLight),
        ),
      ),
      datePickerTheme: AppDatePickerTheme.lightBoxy(),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.lightSurface,
        surfaceTintColor: Colors.transparent,
        constraints: const BoxConstraints(
          maxWidth: AppModalSizes.sheetMaxWidth,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurfaceAlt,
        labelStyle: AppTypography.textTheme(Brightness.light).bodySmall
            ?.copyWith(
              color: const Color(0xFF6E6E6E),
              fontWeight: FontWeight.w600,
            ),
        floatingLabelStyle: AppTypography.textTheme(Brightness.light).bodySmall
            ?.copyWith(
              color: AppColors.lightTextSecondary,
              fontWeight: FontWeight.w700,
            ),
        hintStyle: AppTypography.textTheme(
          Brightness.light,
        ).bodySmall?.copyWith(color: const Color(0xFF8A8A8A)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        side: const BorderSide(color: AppColors.borderLight),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          textStyle: AppTypography.textTheme(
            Brightness.light,
          ).bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          side: const BorderSide(color: AppColors.borderLight),
          textStyle: AppTypography.textTheme(
            Brightness.light,
          ).bodySmall?.copyWith(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: AppTypography.textTheme(
            Brightness.light,
          ).labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: AppElevation.fab,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
      ),
    );
  }

  static ThemeData darkTheme() {
    const scheme = ColorScheme.dark(
      primary: AppColors.onPrimary,
      secondary: AppColors.onPrimary,
      surface: AppColors.darkSurface,
      error: AppColors.expense,
      onPrimary: AppColors.darkBackground,
      onSurface: AppColors.darkTextPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: AppTypography.textTheme(Brightness.dark),
      fontFamily: AppTypography.bodyFamily,
      iconTheme: const IconThemeData(color: Color(0xFFD4D4D4)),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: AppElevation.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          side: const BorderSide(color: AppColors.borderDark),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFE4E4E4)),
        actionsIconTheme: const IconThemeData(color: Color(0xFFE4E4E4)),
        titleTextStyle: AppTypography.textTheme(
          Brightness.dark,
        ).titleLarge?.copyWith(color: AppColors.darkTextPrimary),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),
      dividerColor: AppColors.borderDark,
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: AppModalSizes.horizontalInset,
          vertical: AppModalSizes.verticalInset,
        ),
        constraints: const BoxConstraints(
          maxWidth: AppModalSizes.dialogMaxWidth,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          side: const BorderSide(color: AppColors.borderDark),
        ),
      ),
      datePickerTheme: AppDatePickerTheme.darkBoxy(),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        constraints: const BoxConstraints(
          maxWidth: AppModalSizes.sheetMaxWidth,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        labelStyle: AppTypography.textTheme(Brightness.dark).bodySmall
            ?.copyWith(
              color: const Color(0xFF8D8D8D),
              fontWeight: FontWeight.w600,
            ),
        floatingLabelStyle: AppTypography.textTheme(Brightness.dark).bodySmall
            ?.copyWith(
              color: const Color(0xFFC9C9C9),
              fontWeight: FontWeight.w700,
            ),
        hintStyle: AppTypography.textTheme(
          Brightness.dark,
        ).bodySmall?.copyWith(color: const Color(0xFF777777)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: AppColors.onPrimary, width: 1.2),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        side: const BorderSide(color: AppColors.borderDark),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          backgroundColor: AppColors.onPrimary,
          foregroundColor: AppColors.darkBackground,
          textStyle: AppTypography.textTheme(
            Brightness.dark,
          ).bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          side: const BorderSide(color: AppColors.borderDark),
          textStyle: AppTypography.textTheme(
            Brightness.dark,
          ).bodySmall?.copyWith(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: AppTypography.textTheme(
            Brightness.dark,
          ).labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.onPrimary,
        foregroundColor: AppColors.darkBackground,
        elevation: AppElevation.fab,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
      ),
    );
  }
}
