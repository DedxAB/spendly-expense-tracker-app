import 'package:flutter_test/flutter_test.dart';
import 'package:spendly/core/constants/app_enums.dart';

void main() {
  GoalContributionSource parse(String? value) =>
      GoalContributionSourceX.fromValue(value);
  group('GoalContributionSourceX.value', () {
    test('manual maps to "manual"', () {
      expect(GoalContributionSource.manual.value, 'manual');
    });

    test('interest maps to "interest"', () {
      expect(GoalContributionSource.interest.value, 'interest');
    });
  });

  group('GoalContributionSourceX.label', () {
    test('manual is labelled Contribution', () {
      expect(GoalContributionSource.manual.label, 'Contribution');
    });

    test('interest is labelled Interest', () {
      expect(GoalContributionSource.interest.label, 'Interest');
    });
  });

  group('GoalContributionSource parsing', () {
    test('parses known values', () {
      expect(parse('manual'), GoalContributionSource.manual);
      expect(parse('interest'), GoalContributionSource.interest);
    });

    test('is case-insensitive', () {
      expect(parse('INTEREST'), GoalContributionSource.interest);
      expect(parse('Manual'), GoalContributionSource.manual);
    });

    test('null falls back to manual (legacy rows and old backups)', () {
      expect(parse(null), GoalContributionSource.manual);
    });

    test('unknown values fall back to manual (forward compatibility)', () {
      expect(parse('bonus'), GoalContributionSource.manual);
      expect(parse(''), GoalContributionSource.manual);
    });

    test('round-trips through the persisted string form', () {
      for (final source in GoalContributionSource.values) {
        expect(parse(source.value), source);
      }
    });
  });
}
