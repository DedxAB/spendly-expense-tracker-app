import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/core/database/app_database.dart';
import 'package:spendly/core/database/database_providers.dart';
import 'package:spendly/core/utils/money.dart';
import 'package:uuid/uuid.dart';

class GoalItem {
  const GoalItem({
    required this.id,
    required this.title,
    required this.category,
    required this.targetAmount,
    required this.savedAmount,
    required this.targetDate,
    required this.monthlyContribution,
    required this.recentDelta,
  });

  final String id;
  final String title;
  final String category;
  final double targetAmount;
  final double savedAmount;
  final DateTime targetDate;
  final double monthlyContribution;
  final double recentDelta;

  double get progress => targetAmount <= 0
      ? 0
      : (savedAmount / targetAmount).clamp(0, 1).toDouble();

  double get remaining =>
      (targetAmount - savedAmount).clamp(0, double.infinity);
}

class EmergencyFund {
  const EmergencyFund({
    required this.id,
    required this.title,
    required this.currentAmount,
    required this.targetAmount,
    required this.monthlyExpense,
    required this.lastUpdated,
  });

  final String id;
  final String title;
  final double currentAmount;
  final double targetAmount;
  final double monthlyExpense;
  final DateTime lastUpdated;

  double get progress => targetAmount <= 0
      ? 0
      : (currentAmount / targetAmount).clamp(0, 1).toDouble();

  double get monthsCovered =>
      monthlyExpense <= 0 ? 0 : (currentAmount / monthlyExpense);
}

class GoalContributionItem {
  const GoalContributionItem({
    required this.id,
    required this.goalId,
    required this.amount,
    required this.note,
    required this.createdAt,
  });

  final String id;
  final String goalId;
  final double amount;
  final String? note;
  final DateTime createdAt;
}

class GoalsState {
  const GoalsState({required this.emergencyFund, required this.goals});

  final EmergencyFund emergencyFund;
  final List<GoalItem> goals;

  double get totalTarget =>
      emergencyFund.targetAmount +
      goals.fold(0.0, (sum, goal) => sum + goal.targetAmount);

  double get totalSaved =>
      emergencyFund.currentAmount +
      goals.fold(0.0, (sum, goal) => sum + goal.savedAmount);

  double get totalProgress =>
      totalTarget <= 0 ? 0 : (totalSaved / totalTarget).clamp(0, 1).toDouble();

  double get monthlyGoalCommitment =>
      goals.fold(0.0, (sum, goal) => sum + goal.monthlyContribution);
}

extension on GoalFund {
  GoalItem toGoalItem() {
    return GoalItem(
      id: id,
      title: title,
      category: category,
      targetAmount: targetAmount,
      savedAmount: savedAmount,
      targetDate: DateTime.fromMillisecondsSinceEpoch(targetDate),
      monthlyContribution: monthlyContribution,
      recentDelta: recentDelta,
    );
  }

  EmergencyFund toEmergencyFund() {
    return EmergencyFund(
      id: id,
      title: title,
      currentAmount: savedAmount,
      targetAmount: targetAmount,
      monthlyExpense: monthlyExpense,
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(updatedAt),
    );
  }
}

extension on GoalContribution {
  GoalContributionItem toItem() {
    return GoalContributionItem(
      id: id,
      goalId: goalId,
      amount: amount,
      note: note,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
    );
  }
}

final emergencyFundProvider = StreamProvider<EmergencyFund>((ref) {
  return ref.watch(appDatabaseProvider).watchEmergencyGoalFund().map((row) {
    if (row == null) {
      return EmergencyFund(
        id: 'emergency',
        title: 'Emergency Fund',
        currentAmount: 0,
        targetAmount: 0,
        monthlyExpense: 0,
        lastUpdated: DateTime.now(),
      );
    }
    return row.toEmergencyFund();
  });
});

final emergencyFundsProvider = StreamProvider<List<EmergencyFund>>((ref) {
  return ref
      .watch(appDatabaseProvider)
      .watchEmergencyGoalFunds()
      .map(
        (rows) =>
            rows.map((row) => row.toEmergencyFund()).toList(growable: false),
      );
});

final goalsListProvider = StreamProvider<List<GoalItem>>((ref) {
  return ref
      .watch(appDatabaseProvider)
      .watchActiveGoals()
      .map(
        (rows) => rows.map((row) => row.toGoalItem()).toList(growable: false),
      );
});

final goalContributionsProvider =
    StreamProvider.family<List<GoalContributionItem>, String>((ref, goalId) {
      return ref
          .watch(appDatabaseProvider)
          .watchGoalContributions(goalId)
          .map(
            (rows) => rows.map((row) => row.toItem()).toList(growable: false),
          );
    });

class GoalsActions {
  GoalsActions(this._ref);

  final Ref _ref;

  Future<void> addGoal({
    required String title,
    required String category,
    required double targetAmount,
    required double initialSaved,
    required DateTime targetDate,
    required double monthlyContribution,
  }) async {
    final db = _ref.read(appDatabaseProvider);
    final now = DateTime.now();
    final nowMs = now.millisecondsSinceEpoch;
    final normalizedTarget = Money.normalize(targetAmount);
    final normalizedSaved = Money.normalize(
      initialSaved.clamp(0, targetAmount),
    );
    final normalizedMonthly = Money.normalize(monthlyContribution);

    final goalId = const Uuid().v4();
    await db.upsertGoalFund(
      GoalFundsCompanion.insert(
        id: goalId,
        title: title,
        category: category,
        targetAmount: normalizedTarget,
        targetAmountPaise: Value(Money.toPaise(normalizedTarget)),
        savedAmount: Value(normalizedSaved),
        savedAmountPaise: Value(Money.toPaise(normalizedSaved)),
        targetDate: targetDate.millisecondsSinceEpoch,
        monthlyContribution: Value(normalizedMonthly),
        monthlyContributionPaise: Value(Money.toPaise(normalizedMonthly)),
        recentDelta: Value(normalizedSaved),
        recentDeltaPaise: Value(Money.toPaise(normalizedSaved)),
        monthlyExpense: const Value(0),
        monthlyExpensePaise: const Value(0),
        isEmergency: const Value(false),
        createdAt: nowMs,
        updatedAt: nowMs,
        isDeleted: const Value(false),
      ),
    );

    if (normalizedSaved > 0) {
      await db.addGoalContribution(
        goalId: goalId,
        amount: normalizedSaved,
        note: 'Initial balance',
      );
    }
  }

  Future<void> addToEmergencyFund(
    double amount, {
    String fundId = 'emergency',
  }) async {
    final normalized = Money.normalize(amount);
    if (normalized <= 0) return;
    await _ref
        .read(appDatabaseProvider)
        .addGoalContribution(goalId: fundId, amount: normalized);
  }

  Future<bool> removeFromEmergencyFund(String fundId, double amount) async {
    final normalized = Money.normalize(amount);
    if (normalized <= 0) return false;
    return _ref
        .read(appDatabaseProvider)
        .addGoalContribution(
          goalId: fundId,
          amount: -normalized,
          note: 'Withdrawn',
        );
  }

  Future<void> addEmergencyFund({
    required String title,
    required double targetAmount,
    required double initialSaved,
    required double monthlyExpense,
  }) async {
    final db = _ref.read(appDatabaseProvider);
    final now = DateTime.now();
    final nowMs = now.millisecondsSinceEpoch;
    final target = Money.normalize(targetAmount);
    final saved = Money.normalize(initialSaved.clamp(0, targetAmount));
    final expense = Money.normalize(monthlyExpense);
    final goalId = const Uuid().v4();
    await db.upsertGoalFund(
      GoalFundsCompanion.insert(
        id: goalId,
        title: title,
        category: 'Emergency',
        targetAmount: target,
        targetAmountPaise: Value(Money.toPaise(target)),
        savedAmount: Value(saved),
        savedAmountPaise: Value(Money.toPaise(saved)),
        targetDate: now.add(const Duration(days: 365)).millisecondsSinceEpoch,
        monthlyContribution: const Value(0),
        monthlyContributionPaise: const Value(0),
        recentDelta: Value(saved),
        recentDeltaPaise: Value(Money.toPaise(saved)),
        monthlyExpense: Value(expense),
        monthlyExpensePaise: Value(Money.toPaise(expense)),
        isEmergency: const Value(true),
        createdAt: nowMs,
        updatedAt: nowMs,
        isDeleted: const Value(false),
      ),
    );
    if (saved > 0) {
      await db.addGoalContribution(
        goalId: goalId,
        amount: saved,
        note: 'Initial balance',
      );
    }
  }

  Future<void> addToGoal(String goalId, double amount) async {
    final normalized = Money.normalize(amount);
    if (normalized <= 0) return;
    await _ref
        .read(appDatabaseProvider)
        .addGoalContribution(goalId: goalId, amount: normalized);
  }

  Future<bool> removeFromGoal(String goalId, double amount) async {
    final normalized = Money.normalize(amount);
    if (normalized <= 0) return false;
    return _ref
        .read(appDatabaseProvider)
        .addGoalContribution(
          goalId: goalId,
          amount: -normalized,
          note: 'Withdrawn',
        );
  }

  Future<void> deleteGoal(String goalId) async {
    await _ref.read(appDatabaseProvider).softDeleteGoalFund(goalId);
  }

  Future<void> deleteContribution(String contributionId) async {
    await _ref
        .read(appDatabaseProvider)
        .softDeleteGoalContribution(contributionId);
  }
}

final goalsActionsProvider = Provider<GoalsActions>((ref) {
  return GoalsActions(ref);
});
