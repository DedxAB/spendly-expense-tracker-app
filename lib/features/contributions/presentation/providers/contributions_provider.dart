import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/features/contributions/data/repositories/contributions_repository_impl.dart';
import 'package:spendly/features/contributions/domain/entities/contribution_entity.dart';

final contributionsProvider =
    FutureProvider.family<List<ContributionEntity>, String>((ref, expenseId) {
  final repo = ref.read(contributionsRepositoryProvider);
  return repo.getContributions(expenseId);
});

final contributionStreamProvider =
    StreamProvider.family<List<ContributionEntity>, String>((ref, expenseId) {
  final repo = ref.read(contributionsRepositoryProvider);
  return repo.watchContributions(expenseId);
});

class ContributionActions {
  ContributionActions(this._ref);
  final Ref _ref;

  Future<void> addContributors(
    String expenseId,
    List<({String personName, double amount})> items,
  ) async {
    final repo = _ref.read(contributionsRepositoryProvider);
    await repo.addContributions(expenseId, items);
  }

  Future<void> settle(String id) async {
    final repo = _ref.read(contributionsRepositoryProvider);
    await repo.settleContribution(id);
  }

  Future<void> unsettle(String id) async {
    final repo = _ref.read(contributionsRepositoryProvider);
    await repo.unsettleContribution(id);
  }

  Future<void> remove(String id) async {
    final repo = _ref.read(contributionsRepositoryProvider);
    await repo.removeContribution(id);
  }

  Future<void> replaceForExpense(
    String expenseId,
    List<({String personName, double amount})> items,
  ) async {
    final repo = _ref.read(contributionsRepositoryProvider);
    await repo.removeAllForExpense(expenseId);
    if (items.isNotEmpty) {
      await repo.addContributions(expenseId, items);
    }
  }
}

final contributionActionsProvider = Provider(ContributionActions.new);
