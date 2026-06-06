enum TransactionType { income, expense }

enum PaymentMode { cash, upi, card }

enum CardType { debit, credit }

enum AppThemeMode { system, light, dark }

enum RecurringFrequency { daily, weekly, monthly, yearly }

enum LendEntryType { lent, borrowed }

extension TransactionTypeX on TransactionType {
  String get value {
    switch (this) {
      case TransactionType.income:
        return 'income';
      case TransactionType.expense:
        return 'expense';
    }
  }

  static TransactionType fromValue(String value) {
    switch (value.toLowerCase()) {
      case 'income':
        return TransactionType.income;
      case 'expense':
      default:
        return TransactionType.expense;
    }
  }
}

extension PaymentModeX on PaymentMode {
  String get label {
    switch (this) {
      case PaymentMode.cash:
        return 'Cash';
      case PaymentMode.upi:
        return 'UPI';
      case PaymentMode.card:
        return 'Card';
    }
  }

  String get value {
    switch (this) {
      case PaymentMode.cash:
        return 'cash';
      case PaymentMode.upi:
        return 'upi';
      case PaymentMode.card:
        return 'card';
    }
  }

  static PaymentMode fromValue(String value) {
    switch (value.toLowerCase()) {
      case 'upi':
        return PaymentMode.upi;
      case 'card':
        return PaymentMode.card;
      case 'cash':
      default:
        return PaymentMode.cash;
    }
  }
}

extension CardTypeX on CardType {
  String get label {
    switch (this) {
      case CardType.debit:
        return 'Debit';
      case CardType.credit:
        return 'Credit';
    }
  }

  String get value {
    switch (this) {
      case CardType.debit:
        return 'debit';
      case CardType.credit:
        return 'credit';
    }
  }

  static CardType fromValue(String value) {
    switch (value.toLowerCase()) {
      case 'credit':
        return CardType.credit;
      case 'debit':
      default:
        return CardType.debit;
    }
  }
}

String transactionPaymentLabel({
  required TransactionType type,
  required PaymentMode paymentMode,
  CardType? cardType,
}) {
  if (paymentMode != PaymentMode.card) {
    return paymentMode.label;
  }

  if (type == TransactionType.expense && cardType != null) {
    return 'Card · ${cardType.label}';
  }

  return 'Card';
}

extension AppThemeModeX on AppThemeMode {
  String get value {
    switch (this) {
      case AppThemeMode.system:
        return 'system';
      case AppThemeMode.light:
        return 'light';
      case AppThemeMode.dark:
        return 'dark';
    }
  }

  static AppThemeMode fromValue(String value) {
    switch (value.toLowerCase()) {
      case 'light':
        return AppThemeMode.light;
      case 'dark':
        return AppThemeMode.dark;
      case 'system':
      default:
        return AppThemeMode.system;
    }
  }
}

extension RecurringFrequencyX on RecurringFrequency {
  String get value {
    switch (this) {
      case RecurringFrequency.daily:
        return 'daily';
      case RecurringFrequency.weekly:
        return 'weekly';
      case RecurringFrequency.monthly:
        return 'monthly';
      case RecurringFrequency.yearly:
        return 'yearly';
    }
  }

  static RecurringFrequency fromValue(String value) {
    switch (value.toLowerCase()) {
      case 'daily':
        return RecurringFrequency.daily;
      case 'weekly':
        return RecurringFrequency.weekly;
      case 'yearly':
        return RecurringFrequency.yearly;
      case 'monthly':
      default:
        return RecurringFrequency.monthly;
    }
  }
}

extension LendEntryTypeX on LendEntryType {
  String get value {
    switch (this) {
      case LendEntryType.lent:
        return 'lent';
      case LendEntryType.borrowed:
        return 'borrowed';
    }
  }

  static LendEntryType fromValue(String value) {
    switch (value.toLowerCase()) {
      case 'borrowed':
        return LendEntryType.borrowed;
      case 'lent':
      default:
        return LendEntryType.lent;
    }
  }
}
