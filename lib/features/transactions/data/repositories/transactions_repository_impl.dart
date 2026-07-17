import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/core/constants/app_enums.dart';
import 'package:spendly/core/database/app_database.dart';
import 'package:spendly/core/database/database_providers.dart';
import 'package:spendly/core/database/mappers.dart';
import 'package:spendly/core/utils/money.dart';
import 'package:spendly/features/activity/data/repositories/activity_repository_impl.dart';
import 'package:spendly/features/transactions/domain/entities/transaction_entity.dart';
import 'package:spendly/features/transactions/domain/repositories/transactions_repository.dart';

class TransactionsRepositoryImpl implements TransactionsRepository {
  TransactionsRepositoryImpl(this._ref);

  final Ref _ref;

  Stream<List<T>> _withContributionSignal<T>(Stream<List<T>> source) {
    final db = _ref.read(appDatabaseProvider);
    final signal = db.watchContributionChanges();
    List<T>? last;
    final controller = StreamController<List<T>>();
    final sub1 = source.listen(
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

  @override
  Future<void> add(TransactionEntity transaction) async {
    final normalized = transaction.copyWith(
      amount: Money.normalize(transaction.amount),
    );
    await _ref
        .read(appDatabaseProvider)
        .upsertTransaction(transactionToCompanion(normalized));
    await _ref
        .read(activityRepositoryProvider)
        .recordEvent(
          kind: 'transaction',
          title: 'Added transaction',
          description:
              '${normalized.type.name} of ₹${normalized.amount.toStringAsFixed(2)} recorded (${transactionPaymentLabel(type: normalized.type, paymentMode: normalized.paymentMode, cardType: normalized.cardType)})',
        );
  }

  @override
  Future<void> update(TransactionEntity transaction) async {
    final normalized = transaction.copyWith(
      amount: Money.normalize(transaction.amount),
    );
    await _ref
        .read(appDatabaseProvider)
        .upsertTransaction(transactionToCompanion(normalized));
    await _ref
        .read(activityRepositoryProvider)
        .recordEvent(
          kind: 'transaction',
          title: 'Updated transaction',
          description:
              '${normalized.type.name} of ₹${normalized.amount.toStringAsFixed(2)} updated (${transactionPaymentLabel(type: normalized.type, paymentMode: normalized.paymentMode, cardType: normalized.cardType)})',
        );
  }

  @override
  Future<void> restore(String transactionId) async {
    await _ref.read(appDatabaseProvider).restoreTransaction(transactionId);
    await _ref
        .read(activityRepositoryProvider)
        .recordEvent(
          kind: 'transaction',
          title: 'Restored transaction',
          description: 'A deleted transaction was restored.',
        );
  }

  @override
  Future<void> softDelete(String transactionId) async {
    await _ref.read(appDatabaseProvider).softDeleteTransaction(transactionId);
    await _ref
        .read(activityRepositoryProvider)
        .recordEvent(
          kind: 'transaction',
          title: 'Deleted transaction',
          description: 'A transaction was moved out of active history.',
        );
  }

  Future<List<TransactionEntity>> _withEffectiveAmounts(
    List<Transaction> rows,
  ) async {
    final expenseIds = rows
        .where((r) => r.type == 'expense')
        .map((r) => r.id)
        .toList();
    final settledSums =
        expenseIds.isEmpty ? const <String, double>{} : await _ref
            .read(appDatabaseProvider)
            .getSettledContributionSums(expenseIds);
    return rows.map((row) {
      final entity = row.toEntity();
      final recovered = settledSums[row.id] ?? 0;
      return recovered > 0 ? entity.copyWith(recoveredAmount: recovered) : entity;
    }).toList(growable: false);
  }

  @override
  Stream<List<TransactionEntity>> watchAll() {
    return _withContributionSignal(
      _ref.read(appDatabaseProvider).watchAllActiveTransactions(),
    ).asyncMap((rows) => _withEffectiveAmounts(rows));
  }

  @override
  Stream<List<TransactionEntity>> watchByMonth(
    DateTime month, {
    String? categoryId,
    String? type,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) {
    return _withContributionSignal(
      _ref.read(appDatabaseProvider).watchTransactionsByMonth(
        month,
        categoryId: categoryId,
        type: type,
        dateFrom: dateFrom,
        dateTo: dateTo,
      ),
    ).asyncMap((rows) => _withEffectiveAmounts(rows));
  }

  @override
  Stream<Map<String, double>> watchMonthlyTotals(DateTime month) {
    return _withContributionSignal(
      _ref.read(appDatabaseProvider).watchTransactionsByMonth(month),
    ).asyncMap((rows) async {
      final expenseIds = rows
          .where((r) => r.type == 'expense')
          .map((r) => r.id)
          .toList();
      final settledSums =
          expenseIds.isEmpty ? const <String, double>{} : await _ref
              .read(appDatabaseProvider)
              .getSettledContributionSums(expenseIds);

      double effective(double raw, String id) {
        final r = settledSums[id] ?? 0;
        return raw - r;
      }

      final income = rows
          .where((row) => row.type == 'income')
          .fold<double>(0, (sum, row) => sum + row.amount);
      final expense = rows
          .where((row) => row.type == 'expense')
          .fold<double>(0, (sum, row) => sum + effective(row.amount, row.id));
      final netInvestment = rows
          .where((row) => row.type == 'investment' && row.categoryId != 'cat_goal_transfer')
          .fold<double>(0, (sum, row) => sum + row.amount);
      final grossInvestment = rows
          .where((row) => row.type == 'investment' && row.amount > 0 && row.categoryId != 'cat_goal_transfer')
          .fold<double>(0, (sum, row) => sum + row.amount);
      final goalTransfers = rows
          .where((row) => row.categoryId == 'cat_goal_transfer')
          .fold<double>(0, (sum, row) => sum + row.amount);
      return {
        'income': income,
        'expense': expense,
        'investment': netInvestment,
        'grossInvestment': grossInvestment,
        'goalTransfers': goalTransfers,
        'balance': income - expense - netInvestment,
      };
    });
  }

  @override
  Stream<List<TransactionEntity>> watchRecent({int limit = 5}) {
    return _withContributionSignal(
      _ref.read(appDatabaseProvider).watchRecentTransactions(limit: limit, excludeCategoryId: 'cat_goal_transfer'),
    ).asyncMap((rows) => _withEffectiveAmounts(rows));
  }
}

final transactionsRepositoryProvider = Provider<TransactionsRepository>((ref) {
  return TransactionsRepositoryImpl(ref);
});
