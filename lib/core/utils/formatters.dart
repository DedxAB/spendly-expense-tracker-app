import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spendly/core/constants/app_constants.dart';
import 'package:spendly/core/utils/amount_visibility.dart';

class Formatters {
  static final NumberFormat _inrFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: AppConstants.currencySymbol,
    decimalDigits: 2,
  );

  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _shortDateFormat = DateFormat('dd MMM');

  static String rawCurrency(num value) => _inrFormat.format(value);

  static String currency(num value) {
    final formatted = rawCurrency(value);
    if (AmountVisibilityController.isVisible) return formatted;
    return AmountVisibilityController.mask(formatted);
  }

  static String date(DateTime date) => _dateFormat.format(date);

  static String shortDate(DateTime date) => _shortDateFormat.format(date);

  static Color parseHexColor(String hex) {
    final normalized = hex.replaceFirst('#', '');
    final value = int.parse('FF$normalized', radix: 16);
    return Color(value);
  }
}
