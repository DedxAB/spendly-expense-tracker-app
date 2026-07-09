import 'package:spendly/features/contributions/domain/entities/contribution_entity.dart';

abstract class ContributionsRepository {
  Stream<List<ContributionEntity>> watchContributions(String expenseId);
  Future<List<ContributionEntity>> getContributions(String expenseId);
  Future<void> addContributions(
    String expenseId,
    List<({String personName, double amount})> items,
  );
  Future<void> settleContribution(String id);
  Future<void> unsettleContribution(String id);
  Future<void> removeContribution(String id);
  Future<void> removeAllForExpense(String expenseId);
}
