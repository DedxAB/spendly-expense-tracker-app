import 'package:flutter_test/flutter_test.dart';
import 'package:spendly/core/constants/app_enums.dart';
import 'package:spendly/features/recurring/domain/entities/recurring_rule_entity.dart';

void main() {
  RecurringRuleEntity rule(RecurringFrequency frequency, double amount) {
    final now = DateTime(2026, 1, 1);
    return RecurringRuleEntity(
      id: 'rule-1',
      title: 'Subscription',
      type: TransactionType.expense,
      amount: amount,
      categoryId: 'cat-1',
      paymentMode: PaymentMode.upi,
      frequency: frequency,
      startDate: now,
      nextDueDate: now,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('RecurringFrequencyX.monthlyEquivalent', () {
    test('monthly is unchanged', () {
      expect(
        RecurringFrequency.monthly.monthlyEquivalent(150),
        closeTo(150, 0.001),
      );
    });

    test('yearly is divided by twelve', () {
      expect(
        RecurringFrequency.yearly.monthlyEquivalent(500),
        closeTo(41.6667, 0.001),
      );
    });

    test('weekly scales by ~4.35', () {
      expect(
        RecurringFrequency.weekly.monthlyEquivalent(100),
        closeTo(434.8, 0.5),
      );
    });

    test('daily scales by ~30.44', () {
      expect(
        RecurringFrequency.daily.monthlyEquivalent(7),
        closeTo(213.06, 0.5),
      );
    });
  });

  test('monthly + yearly rules total a monthly equivalent, not a raw sum', () {
    final rules = [
      rule(RecurringFrequency.monthly, 150),
      rule(RecurringFrequency.yearly, 500),
    ];

    final total = rules.fold<double>(0, (sum, r) => sum + r.monthlyAmount);

    expect(total, closeTo(191.6667, 0.001));
    expect(total, lessThan(650));
  });
}
