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
        savedAmount: const Value(0),
        savedAmountPaise: const Value(0),
        targetDate: targetDate.millisecondsSinceEpoch,
        monthlyContribution: Value(normalizedMonthly),
        monthlyContributionPaise: Value(Money.toPaise(normalizedMonthly)),
        recentDelta: const Value(0),
        recentDeltaPaise: const Value(0),
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

  Future<void> updateGoal({
    required String goalId,
    required String title,
    required String category,
    required double targetAmount,
    required double savedAmount,
    required DateTime targetDate,
    required double monthlyContribution,
  }) async {
    final db = _ref.read(appDatabaseProvider);
    final rows = await db.watchActiveGoals().first;
    GoalFund? existing;
    for (final row in rows) {
      if (row.id == goalId) {
        existing = row;
        break;
      }
    }
    if (existing == null) return;

    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final normalizedTarget = Money.normalize(targetAmount);
    final normalizedSaved = Money.normalize(savedAmount.clamp(0, targetAmount));
    final normalizedMonthly = Money.normalize(monthlyContribution);

    await (db.update(
      db.goalFunds,
    )..where((tbl) => tbl.id.equals(goalId))).write(
      GoalFundsCompanion(
        title: Value(title),
        category: Value(category),
        targetAmount: Value(normalizedTarget),
        targetAmountPaise: Value(Money.toPaise(normalizedTarget)),
        targetDate: Value(targetDate.millisecondsSinceEpoch),
        monthlyContribution: Value(normalizedMonthly),
        monthlyContributionPaise: Value(Money.toPaise(normalizedMonthly)),
        updatedAt: Value(nowMs),
      ),
    );

    final delta = Money.normalize(normalizedSaved - existing.savedAmount);
    if (delta != 0) {
      await db.addGoalContribution(
        goalId: goalId,
        amount: delta,
        note: 'Balance adjustment',
      );
    }
  }

  Future<GoalFund?> _getGoalFundById(String goalId) async {
    final funds = await _ref.read(appDatabaseProvider).getGoalFunds();
    for (final f in funds) {
      if (f.id == goalId) return f;
    }
    return null;
  }

  Future<double> addToEmergencyFund(
    double amount, {
    String fundId = 'emergency',
    String? note,
  }) async {
    final normalized = Money.normalize(amount);
    if (normalized <= 0) return 0;

    final fund = await _getGoalFundById(fundId);
    if (fund == null) return 0;
    final remaining = Money.normalize(fund.targetAmount - fund.savedAmount);
    if (remaining <= 0) return 0;
    final clamped = normalized > remaining ? remaining : normalized;

    await _ref
        .read(appDatabaseProvider)
        .addGoalContribution(goalId: fundId, amount: clamped, note: note);
    return clamped;
  }

  Future<bool> removeFromEmergencyFund(
    String fundId,
    double amount, {
    String? note,
  }) async {
    final normalized = Money.normalize(amount);
    if (normalized <= 0) return false;
    final ok = await _ref
        .read(appDatabaseProvider)
        .addGoalContribution(
          goalId: fundId,
          amount: -normalized,
          note: note ?? 'Withdrawn',
        );
    return ok;
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
        savedAmount: const Value(0),
        savedAmountPaise: const Value(0),
        targetDate: now.add(const Duration(days: 365)).millisecondsSinceEpoch,
        monthlyContribution: const Value(0),
        monthlyContributionPaise: const Value(0),
        recentDelta: const Value(0),
        recentDeltaPaise: const Value(0),
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

  Future<void> updateEmergencyFund({
    required String fundId,
    required String title,
    required double targetAmount,
    required double savedAmount,
    required double monthlyExpense,
  }) async {
    final db = _ref.read(appDatabaseProvider);
    final rows = await db.watchEmergencyGoalFunds().first;
    GoalFund? existing;
    for (final row in rows) {
      if (row.id == fundId) {
        existing = row;
        break;
      }
    }
    if (existing == null) return;

    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final normalizedTarget = Money.normalize(targetAmount);
    final normalizedSaved = Money.normalize(savedAmount.clamp(0, targetAmount));
    final normalizedExpense = Money.normalize(monthlyExpense);

    await (db.update(
      db.goalFunds,
    )..where((tbl) => tbl.id.equals(fundId))).write(
      GoalFundsCompanion(
        title: Value(title),
        category: const Value('Emergency'),
        targetAmount: Value(normalizedTarget),
        targetAmountPaise: Value(Money.toPaise(normalizedTarget)),
        monthlyExpense: Value(normalizedExpense),
        monthlyExpensePaise: Value(Money.toPaise(normalizedExpense)),
        updatedAt: Value(nowMs),
      ),
    );

    final delta = Money.normalize(normalizedSaved - existing.savedAmount);
    if (delta != 0) {
      await db.addGoalContribution(
        goalId: fundId,
        amount: delta,
        note: 'Balance adjustment',
      );
    }
  }

  Future<double> addToGoal(
    String goalId,
    double amount, {
    String? note,
  }) async {
    final normalized = Money.normalize(amount);
    if (normalized <= 0) return 0;

    final goal = await _getGoalFundById(goalId);
    if (goal == null) return 0;
    final remaining = Money.normalize(goal.targetAmount - goal.savedAmount);
    if (remaining <= 0) return 0;
    final clamped = normalized > remaining ? remaining : normalized;

    await _ref
        .read(appDatabaseProvider)
        .addGoalContribution(goalId: goalId, amount: clamped, note: note);
    return clamped;
  }

  Future<bool> removeFromGoal(
    String goalId,
    double amount, {
    String? note,
  }) async {
    final normalized = Money.normalize(amount);
    if (normalized <= 0) return false;
    final ok = await _ref
        .read(appDatabaseProvider)
        .addGoalContribution(
          goalId: goalId,
          amount: -normalized,
          note: note ?? 'Withdrawn',
        );
    return ok;
  }

  Future<void> deleteGoal(String goalId) async {
    await _ref.read(appDatabaseProvider).softDeleteGoalFund(goalId);
  }

  Future<void> deleteContribution(String contributionId) async {
    await _ref.read(appDatabaseProvider).softDeleteGoalContribution(contributionId);
  }
}

final goalsActionsProvider = Provider<GoalsActions>((ref) {
  return GoalsActions(ref);
});
