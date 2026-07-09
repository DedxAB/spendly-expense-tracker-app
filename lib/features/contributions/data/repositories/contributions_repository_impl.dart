import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/core/database/app_database.dart';
import 'package:spendly/core/database/database_providers.dart';
import 'package:spendly/core/database/mappers.dart';
import 'package:spendly/features/contributions/domain/entities/contribution_entity.dart';
import 'package:spendly/features/contributions/domain/repositories/contributions_repository.dart';

class ContributionsRepositoryImpl implements ContributionsRepository {
  ContributionsRepositoryImpl(this._ref);
  final Ref _ref;

  AppDatabase get _db => _ref.read(appDatabaseProvider);

  @override
  Stream<List<ContributionEntity>> watchContributions(String expenseId) {
    return _db.watchExpenseContributions(expenseId).asyncMap(
      (rows) async => rows.map((r) => r.toContributionEntity()).toList(),
    );
  }

  @override
  Future<List<ContributionEntity>> getContributions(String expenseId) async {
    final rows = await _db.getExpenseContributionsForExpense(expenseId);
    return rows.map((r) => r.toContributionEntity()).toList();
  }

  @override
  Future<void> addContributions(
    String expenseId,
    List<({String personName, double amount})> items,
  ) async {
    await _db.addExpenseContributionsBatch(
      items.map((i) => (expenseId: expenseId, personName: i.personName, amount: i.amount)).toList(),
    );
  }

  @override
  Future<void> settleContribution(String id) async {
    await _db.settleExpenseContribution(id);
  }

  @override
  Future<void> unsettleContribution(String id) async {
    await _db.unsettleExpenseContribution(id);
  }

  @override
  Future<void> removeContribution(String id) async {
    await (_db.delete(_db.expenseContributions)
      ..where((tbl) => tbl.id.equals(id))).go();
  }

  @override
  Future<void> removeAllForExpense(String expenseId) async {
    await (_db.delete(_db.expenseContributions)
      ..where((tbl) => tbl.expenseId.equals(expenseId))).go();
  }
}

final contributionsRepositoryProvider = Provider<ContributionsRepository>((ref) {
  return ContributionsRepositoryImpl(ref);
});
