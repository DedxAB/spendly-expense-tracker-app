import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spendly/core/constants/app_constants.dart';
import 'package:spendly/features/transactions/domain/entities/transaction_entity.dart';
class Formatters {
  static final NumberFormat _inrFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: AppConstants.currencySymbol,
    decimalDigits: 2,
  );

  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _shortDateFormat = DateFormat('dd MMM');

  static String rawCurrency(num value) => _inrFormat.format(value);

  static String currency(num value) => rawCurrency(value);

  static String date(DateTime date) => _dateFormat.format(date);

  static String shortDate(DateTime date) => _shortDateFormat.format(date);

  static String transactionDateLabel(TransactionEntity tx) {
    final now = DateTime.now();
    final d = tx.date;
    if (d.year == now.year && d.month == now.month && d.day == now.day) {
      return 'Today, ${DateFormat('h:mm a').format(d)}';
    }
    return _dateFormat.format(d);
  }

  static Color parseHexColor(
    String hex, {
    Color fallback = const Color(0xFFFFFFFF),
  }) {
    try {
      final normalized = hex.replaceFirst('#', '');
      final value = int.parse('FF$normalized', radix: 16);
      return Color(value);
    } catch (_) {
      // Invalid hex string; return fallback color.
      return fallback;
    }
  }
}
