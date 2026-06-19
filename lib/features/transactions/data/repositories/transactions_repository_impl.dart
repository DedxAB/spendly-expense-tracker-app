import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/core/constants/app_enums.dart';
import 'package:spendly/core/database/database_providers.dart';
import 'package:spendly/core/database/mappers.dart';
import 'package:spendly/core/utils/money.dart';
import 'package:spendly/features/activity/data/repositories/activity_repository_impl.dart';
import 'package:spendly/features/transactions/domain/entities/transaction_entity.dart';
import 'package:spendly/features/transactions/domain/repositories/transactions_repository.dart';

class TransactionsRepositoryImpl implements TransactionsRepository {
  TransactionsRepositoryImpl(this._ref);

  final Ref _ref;

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

  @override
  Stream<List<TransactionEntity>> watchAll() {
    return _ref
        .read(appDatabaseProvider)
        .watchAllActiveTransactions()
        .map(
          (rows) => rows.map((row) => row.toEntity()).toList(growable: false),
        );
  }

  @override
  Stream<List<TransactionEntity>> watchByMonth(
    DateTime month, {
    String? categoryId,
    String? type,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) {
    return _ref
        .read(appDatabaseProvider)
        .watchTransactionsByMonth(
          month,
          categoryId: categoryId,
          type: type,
          dateFrom: dateFrom,
          dateTo: dateTo,
        )
        .map(
          (rows) => rows.map((row) => row.toEntity()).toList(growable: false),
        );
  }

  @override
  Stream<Map<String, double>> watchMonthlyTotals(DateTime month) {
    return _ref.read(appDatabaseProvider).watchTransactionsByMonth(month).map((
      rows,
    ) {
      final income = rows
          .where((row) => row.type == 'income')
          .fold<double>(0, (sum, row) => sum + row.amount);
      final expense = rows
          .where((row) => row.type == 'expense')
          .fold<double>(0, (sum, row) => sum + row.amount);
      final netInvestment = rows
          .where((row) => row.type == 'investment')
          .fold<double>(0, (sum, row) => sum + row.amount);
      final grossInvestment = rows
          .where((row) => row.type == 'investment' && row.amount > 0)
          .fold<double>(0, (sum, row) => sum + row.amount);
      return {
        'income': income,
        'expense': expense,
        'investment': netInvestment,
        'grossInvestment': grossInvestment,
        'balance': income - expense - netInvestment,
      };
    });
  }

  @override
  Stream<List<TransactionEntity>> watchRecent({int limit = 5}) {
    return _ref
        .read(appDatabaseProvider)
        .watchRecentTransactions(limit: limit)
        .map(
          (rows) => rows.map((row) => row.toEntity()).toList(growable: false),
        );
  }
}

final transactionsRepositoryProvider = Provider<TransactionsRepository>((ref) {
  return TransactionsRepositoryImpl(ref);
});
