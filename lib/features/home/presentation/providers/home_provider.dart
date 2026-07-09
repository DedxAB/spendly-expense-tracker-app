import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/core/constants/app_enums.dart';
import 'package:spendly/features/home/domain/entities/dashboard_summary.dart';
import 'package:spendly/features/settings/presentation/providers/settings_provider.dart';
import 'package:spendly/features/transactions/data/repositories/transactions_repository_impl.dart';
import 'package:spendly/features/transactions/presentation/providers/transactions_provider.dart';

final dashboardSummaryProvider = Provider<AsyncValue<DashboardSummary>>((ref) {
  final totals = ref.watch(monthlyTotalsProvider);
  final settings = ref.watch(settingsStreamProvider);

  return totals.whenData((map) {
    final budget = settings.valueOrNull?.monthlyBudget ?? 0;
    final income = map['income'] ?? 0;
    final expense = map['expense'] ?? 0;
    final investment = map['grossInvestment'] ?? map['investment'] ?? 0;
    final balance = map['balance'] ?? 0;

    return DashboardSummary(
      currentBalance: balance,
      monthlyIncome: income,
      monthlyExpense: expense,
      monthlyInvestment: investment,
      remainingBudget: budget - expense,
    );
  });
});

final todaySpentProvider = StreamProvider<double>((ref) {
  final now = DateTime.now();
  final monthStart = DateTime(now.year, now.month, 1);

  return ref
      .watch(transactionsRepositoryProvider)
      .watchByMonth(monthStart, type: TransactionType.expense.value)
      .map((items) {
        return items
            .where(
              (item) =>
                  item.date.year == now.year &&
                  item.date.month == now.month &&
                  item.date.day == now.day,
            )
            .fold<double>(0, (sum, item) => sum + (item.amount - item.recoveredAmount));
      });
});

final currentMonthDailyIncomeExpenseProvider = StreamProvider<({List<double> income, List<double> expense})>((ref) {
  final now = DateTime.now();
  final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
  final repo = ref.watch(transactionsRepositoryProvider);
  return repo.watchAll().map((items) {
    final income = List<double>.filled(daysInMonth, 0);
    final expense = List<double>.filled(daysInMonth, 0);
    for (final item in items) {
      if (item.date.year != now.year || item.date.month != now.month) continue;
      final day = item.date.day - 1;
      if (day < 0 || day >= daysInMonth) continue;
      if (item.type == TransactionType.income) {
        income[day] += item.amount;
      } else if (item.type == TransactionType.expense) {
        expense[day] += item.amount - item.recoveredAmount;
      }
    }
    return (income: income, expense: expense);
  });
});

final yesterdaySpentProvider = StreamProvider<double>((ref) {
  final now = DateTime.now();
  final yesterday = now.subtract(const Duration(days: 1));
  final monthStart = DateTime(yesterday.year, yesterday.month, 1);

  return ref
      .watch(transactionsRepositoryProvider)
      .watchByMonth(monthStart, type: TransactionType.expense.value)
      .map((items) {
        return items
            .where(
              (item) =>
                  item.date.year == yesterday.year &&
                  item.date.month == yesterday.month &&
                  item.date.day == yesterday.day,
            )
            .fold<double>(0, (sum, item) => sum + (item.amount - item.recoveredAmount));
      });
});
