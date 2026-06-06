import 'package:flutter/material.dart';

class AppDatePickerTheme {
  static DatePickerThemeData darkBoxy() {
    const surface = Color(0xFF0E0E0E);
    const border = Color(0xFF4A4A4A);
    const divider = Color(0xFF2A2A2A);
    const selected = Colors.white;

    return DatePickerThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      headerBackgroundColor: surface,
      headerForegroundColor: Colors.white,
      dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return selected;
        return Colors.transparent;
      }),
      dayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.black;
        return Colors.white;
      }),
      dayOverlayColor: const WidgetStatePropertyAll(Colors.transparent),
      dayStyle: const TextStyle(fontWeight: FontWeight.w600),
      dayShape: const WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      todayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.black;
        return Colors.white;
      }),
      todayBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return selected;
        return Colors.transparent;
      }),
      todayBorder: const BorderSide(color: border),
      yearForegroundColor: const WidgetStatePropertyAll(Colors.white),
      yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return selected;
        return Colors.transparent;
      }),
      yearShape: const WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      rangeSelectionBackgroundColor: const Color(0xFF1E1E1E),
      dividerColor: divider,
      rangePickerBackgroundColor: surface,
      rangePickerSurfaceTintColor: Colors.transparent,
      rangePickerShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      rangePickerHeaderBackgroundColor: surface,
      rangePickerHeaderForegroundColor: Colors.white,
      rangePickerHeaderHeadlineStyle: const TextStyle(
        fontWeight: FontWeight.w700,
      ),
      rangePickerHeaderHelpStyle: const TextStyle(fontWeight: FontWeight.w600),
      rangePickerElevation: 0,
      rangePickerShadowColor: Colors.transparent,
      cancelButtonStyle: TextButton.styleFrom(foregroundColor: Colors.white),
      confirmButtonStyle: TextButton.styleFrom(foregroundColor: Colors.white),
    );
  }
}
