import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:spendly/core/constants/app_enums.dart';
import 'package:spendly/core/database/app_database.dart';
import 'package:spendly/core/database/database_providers.dart';
import 'package:spendly/core/database/mappers.dart';
import 'package:spendly/features/insights/domain/entities/expense_slice.dart';
import 'package:spendly/features/insights/domain/entities/income_expense_bar.dart';
import 'package:spendly/features/insights/domain/entities/insight_point.dart';
import 'package:spendly/features/insights/domain/entities/monthly_reflection_entity.dart';
import 'package:spendly/features/insights/domain/repositories/insights_repository.dart';

class InsightsRepositoryImpl implements InsightsRepository {
  InsightsRepositoryImpl(this._ref);

  final Ref _ref;

  Stream<List<Transaction>> _watchActiveTransactions() {
    final db = _ref.read(appDatabaseProvider);
    final signal = db.watchContributionChanges();
    List<Transaction>? last;
    final controller = StreamController<List<Transaction>>();
    final sub1 = db.watchAllActiveTransactions().listen(
      (v) { last = v; controller.add(v); },
      onError: controller.addError,
      onDone: controller.close,
    );
    final sub2 = signal.listen((_) {
      if (last != null) controller.add(last!);
    });
    controller.onCancel = () { sub1.cancel(); sub2.cancel(); };
    return controller.stream;
  }

  DateTime _startOfMonth(DateTime month) =>
      DateTime(month.year, month.month, 1);

  DateTime _endOfMonthExclusive(DateTime month) =>
      DateTime(month.year, month.month + 1, 1);

  DateTime _startOfYear(DateTime date) => DateTime(date.year, 1, 1);

  DateTime _endOfYearExclusive(DateTime date) => DateTime(date.year + 1, 1, 1);

  bool _inMonth(DateTime date, DateTime month) {
    final start = _startOfMonth(month);
    final end = _endOfMonthExclusive(month);
    return !date.isBefore(start) && date.isBefore(end);
  }

  bool _inYear(DateTime date, DateTime yearRef) {
    final start = _startOfYear(yearRef);
    final end = _endOfYearExclusive(yearRef);
    return !date.isBefore(start) && date.isBefore(end);
  }

  bool _inPeriod(DateTime date, DateTime period, {required bool yearly}) {
    if (yearly) return _inYear(date, period);
    return _inMonth(date, period);
  }

  Future<Map<String, double>> _settledSums(Iterable<Transaction> rows) async {
    final expenseIds = rows
        .where((r) => r.type == 'expense')
        .map((r) => r.id)
        .toList();
    if (expenseIds.isEmpty) return const {};
    return _ref
        .read(appDatabaseProvider)
        .getSettledContributionSums(expenseIds);
  }

  double _effective(double raw, String id, Map<String, double> settled) {
    return raw - (settled[id] ?? 0);
  }

  @override
  Stream<List<InsightPoint>> watchTrend(
    DateTime period, {
    required bool yearly,
  }) {
    return _watchActiveTransactions().asyncMap((
      rows,
    ) async {
      final settled = await _settledSums(rows);
      final totals = <DateTime, double>{};
      if (yearly) {
        for (int m = 1; m <= 12; m++) {
          totals[DateTime(period.year, m, 1)] = 0.0;
        }
      } else {
        final daysInMonth = DateTime(period.year, period.month + 1, 0).day;
        for (int d = 1; d <= daysInMonth; d++) {
          totals[DateTime(period.year, period.month, d)] = 0.0;
        }
      }

      for (final row in rows) {
        if (row.type != TransactionType.expense.value) continue;
        final date = DateTime.fromMillisecondsSinceEpoch(row.date);
        if (!_inPeriod(date, period, yearly: yearly)) continue;
        final bucket = yearly
            ? DateTime(date.year, date.month, 1)
            : DateTime(date.year, date.month, date.day);

        if (totals.containsKey(bucket)) {
          totals[bucket] = totals[bucket]! + _effective(row.amount, row.id, settled);
        }
      }

      final points =
          totals.entries
              .map((e) => InsightPoint(date: e.key, value: e.value))
              .toList(growable: false)
            ..sort((a, b) => a.date.compareTo(b.date));
      return points;
    });
  }

  @override
  Stream<List<ExpenseSlice>> watchExpenseDistribution(
    DateTime period, {
    required bool yearly,
  }) {
    final db = _ref.read(appDatabaseProvider);
    return db.watchAllActiveTransactions().asyncMap((rows) async {
      final settled = await _settledSums(rows);
      final filtered = rows.where((row) {
        if (row.type != TransactionType.expense.value) return false;
        final date = DateTime.fromMillisecondsSinceEpoch(row.date);
        return _inPeriod(date, period, yearly: yearly);
      });
      final categories = await db.getCategories();
      final nameById = {
        for (final category in categories)
          category.id: (category.name, category.color),
      };
      final totals = <String, double>{};
      for (final row in filtered) {
        final name = nameById[row.categoryId]?.$1 ?? 'Other';
        totals[name] = (totals[name] ?? 0) + _effective(row.amount, row.id, settled);
      }
      return totals.entries
          .map((entry) {
            final color = nameById.entries
                .firstWhere(
                  (element) => element.value.$1 == entry.key,
                  orElse: () => const MapEntry('', ('Other', '#94A3B8')),
                )
                .value
                .$2;
            return ExpenseSlice(
              category: entry.key,
              color: color,
              total: entry.value,
            );
          })
          .toList(growable: false)
        ..sort((a, b) => b.total.compareTo(a.total));
    });
  }

  @override
  Stream<Map<String, double>> watchIncomeVsExpense(
    DateTime period, {
    required bool yearly,
  }) {
    return _watchActiveTransactions().asyncMap((
      rows,
    ) async {
      final settled = await _settledSums(rows);
      final filtered = rows.where((row) {
        final date = DateTime.fromMillisecondsSinceEpoch(row.date);
        return _inPeriod(date, period, yearly: yearly);
      });
      final income = filtered
          .where((row) => row.type == TransactionType.income.value)
          .fold<double>(0, (sum, row) => sum + row.amount);
      final expense = filtered
          .where((row) => row.type == TransactionType.expense.value)
          .fold<double>(0, (sum, row) => sum + _effective(row.amount, row.id, settled));
      return {'income': income, 'expense': expense};
    });
  }

  @override
  Stream<List<IncomeExpenseBar>> watchYearlyIncomeVsExpense(int year) {
    return _watchActiveTransactions().asyncMap((
      rows,
    ) async {
      final settled = await _settledSums(rows);
      final result = <IncomeExpenseBar>[];
      for (var month = 1; month <= 12; month++) {
        final monthlyRows = rows.where((row) {
          final d = DateTime.fromMillisecondsSinceEpoch(row.date);
          return d.year == year && d.month == month;
        });
        final income = monthlyRows
            .where((row) => row.type == TransactionType.income.value)
            .fold<double>(0, (sum, row) => sum + row.amount);
        final expense = monthlyRows
            .where((row) => row.type == TransactionType.expense.value)
            .fold<double>(0, (sum, row) => sum + _effective(row.amount, row.id, settled));
        result.add(
          IncomeExpenseBar(
            label: DateFormat('MMM').format(DateTime(year, month)),
            income: income,
            expense: expense,
          ),
        );
      }
      return result;
    });
  }

  @override
  Stream<Map<String, double>> watchPaymentModeBreakdown(
    DateTime period, {
    required bool yearly,
  }) {
    return _watchActiveTransactions().asyncMap((
      rows,
    ) async {
      final settled = await _settledSums(rows);
      final expenseRows = rows.where((row) {
        if (row.type != TransactionType.expense.value) return false;
        final date = DateTime.fromMillisecondsSinceEpoch(row.date);
        return _inPeriod(date, period, yearly: yearly);
      });
      final totals = <String, double>{'upi': 0, 'cash': 0, 'card': 0};
      var totalExpense = 0.0;
      for (final row in expenseRows) {
        final effective = _effective(row.amount, row.id, settled);
        totals[row.paymentMode] = (totals[row.paymentMode] ?? 0) + effective;
        totalExpense += effective;
      }
      if (totalExpense <= 0) return {'upi': 0, 'cash': 0, 'card': 0};
      return {
        'upi': ((totals['upi'] ?? 0) / totalExpense) * 100,
        'cash': ((totals['cash'] ?? 0) / totalExpense) * 100,
        'card': ((totals['card'] ?? 0) / totalExpense) * 100,
      };
    });
  }

  @override
  Stream<double> watchProjectedExpense(DateTime month) {
    return _watchActiveTransactions().asyncMap((
      rows,
    ) async {
      final settled = await _settledSums(rows);
      final now = DateTime.now();
      final start = _startOfMonth(month);
      final end = _endOfMonthExclusive(month);
      final totalDays = DateTime(month.year, month.month + 1, 0).day;
      final elapsedDays = now.isBefore(start)
          ? 0
          : now.isAfter(end)
          ? totalDays
          : now.day;
      final expense = rows
          .where((row) {
            if (row.type != TransactionType.expense.value) return false;
            final date = DateTime.fromMillisecondsSinceEpoch(row.date);
            return _inMonth(date, month);
          })
          .fold<double>(0, (sum, row) => sum + _effective(row.amount, row.id, settled));
      if (elapsedDays <= 0) return 0;
      final projected = (expense / elapsedDays) * totalDays;
      return projected.isFinite ? projected : 0;
    });
  }

  @override
  Stream<double?> watchExpenseChangePercent(
    DateTime period, {
    required bool yearly,
  }) {
    final previousPeriod = yearly
        ? DateTime(period.year - 1, 1, 1)
        : DateTime(period.year, period.month - 1, 1);
    return _watchActiveTransactions().asyncMap((
      rows,
    ) async {
      final settled = await _settledSums(rows);
      final current = rows
          .where((row) {
            if (row.type != TransactionType.expense.value) return false;
            final date = DateTime.fromMillisecondsSinceEpoch(row.date);
            return _inPeriod(date, period, yearly: yearly);
          })
          .fold<double>(0, (sum, row) => sum + _effective(row.amount, row.id, settled));
      final previous = rows
          .where((row) {
            if (row.type != TransactionType.expense.value) return false;
            final date = DateTime.fromMillisecondsSinceEpoch(row.date);
            return _inPeriod(date, previousPeriod, yearly: yearly);
          })
          .fold<double>(0, (sum, row) => sum + _effective(row.amount, row.id, settled));
      if (previous <= 0) return null;
      return ((current - previous) / previous) * 100;
    });
  }

  @override
  Stream<MonthlyReflectionEntity?> watchMonthlyReflection(String monthKey) {
    return _ref
        .read(appDatabaseProvider)
        .watchMonthlyReflection(monthKey)
        .map((row) => row?.toEntity());
  }

  @override
  Future<void> saveMonthlyReflection({
    required String monthKey,
    required String note,
  }) async {
    await _ref
        .read(appDatabaseProvider)
        .upsertMonthlyReflection(
          MonthlyReflectionsCompanion.insert(
            monthKey: monthKey,
            note: note.trim(),
            updatedAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );
  }
}

final insightsRepositoryProvider = Provider<InsightsRepository>((ref) {
  return InsightsRepositoryImpl(ref);
});
