import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:spendly/features/insights/data/repositories/insights_repository_impl.dart';
import 'package:spendly/features/settings/presentation/providers/settings_provider.dart';

enum InsightsViewMode { monthly, yearly }

final insightsSelectedMonthProvider = StateProvider<DateTime>(
  (_) => DateTime(DateTime.now().year, DateTime.now().month, 1),
);

final insightsViewModeProvider = StateProvider<InsightsViewMode>(
  (_) => InsightsViewMode.monthly,
);

final insightsMonthKeyProvider = Provider<String>((ref) {
  final month = ref.watch(insightsSelectedMonthProvider);
  return DateFormat('yyyy-MM').format(month);
});

final expenseDistributionProvider = StreamProvider((ref) {
  final period = ref.watch(insightsSelectedMonthProvider);
  final yearly = ref.watch(insightsViewModeProvider) == InsightsViewMode.yearly;
  return ref
      .watch(insightsRepositoryProvider)
      .watchExpenseDistribution(period, yearly: yearly);
});

final dailyTrendProvider = StreamProvider((ref) {
  final period = ref.watch(insightsSelectedMonthProvider);
  final yearly = ref.watch(insightsViewModeProvider) == InsightsViewMode.yearly;
  return ref
      .watch(insightsRepositoryProvider)
      .watchTrend(period, yearly: yearly);
});

final incomeVsExpenseProvider = StreamProvider((ref) {
  final period = ref.watch(insightsSelectedMonthProvider);
  final yearly = ref.watch(insightsViewModeProvider) == InsightsViewMode.yearly;
  return ref
      .watch(insightsRepositoryProvider)
      .watchIncomeVsExpense(period, yearly: yearly);
});

final yearlyIncomeVsExpenseProvider = StreamProvider((ref) {
  final period = ref.watch(insightsSelectedMonthProvider);
  return ref
      .watch(insightsRepositoryProvider)
      .watchYearlyIncomeVsExpense(period.year);
});

final paymentModeBreakdownProvider = StreamProvider((ref) {
  final period = ref.watch(insightsSelectedMonthProvider);
  final yearly = ref.watch(insightsViewModeProvider) == InsightsViewMode.yearly;
  return ref
      .watch(insightsRepositoryProvider)
      .watchPaymentModeBreakdown(period, yearly: yearly);
});

final projectedExpenseProvider = StreamProvider((ref) {
  final month = ref.watch(insightsSelectedMonthProvider);
  return ref.watch(insightsRepositoryProvider).watchProjectedExpense(month);
});

final expenseChangePercentProvider = StreamProvider((ref) {
  final period = ref.watch(insightsSelectedMonthProvider);
  final yearly = ref.watch(insightsViewModeProvider) == InsightsViewMode.yearly;
  return ref
      .watch(insightsRepositoryProvider)
      .watchExpenseChangePercent(period, yearly: yearly);
});

final monthlyBudgetProvider = Provider<double>((ref) {
  final settings = ref.watch(settingsStreamProvider).valueOrNull;
  return settings?.monthlyBudget ?? 0;
});

final monthlyReflectionProvider = StreamProvider((ref) {
  final monthKey = ref.watch(insightsMonthKeyProvider);
  return ref.watch(insightsRepositoryProvider).watchMonthlyReflection(monthKey);
});

final saveMonthlyReflectionProvider =
    Provider<Future<void> Function(String note)>((ref) {
      return (note) {
        final monthKey = ref.read(insightsMonthKeyProvider);
        return ref
            .read(insightsRepositoryProvider)
            .saveMonthlyReflection(monthKey: monthKey, note: note);
      };
    });

DateTime _previousPeriod(DateTime period, bool yearly) {
  return yearly
      ? DateTime(period.year - 1, 1, 1)
      : DateTime(period.year, period.month - 1, 1);
}

final previousExpenseDistributionProvider = StreamProvider((ref) {
  final period = ref.watch(insightsSelectedMonthProvider);
  final yearly = ref.watch(insightsViewModeProvider) == InsightsViewMode.yearly;
  return ref
      .watch(insightsRepositoryProvider)
      .watchExpenseDistribution(_previousPeriod(period, yearly), yearly: yearly);
});

final previousIncomeVsExpenseProvider = StreamProvider((ref) {
  final period = ref.watch(insightsSelectedMonthProvider);
  final yearly = ref.watch(insightsViewModeProvider) == InsightsViewMode.yearly;
  return ref
      .watch(insightsRepositoryProvider)
      .watchIncomeVsExpense(_previousPeriod(period, yearly), yearly: yearly);
});
