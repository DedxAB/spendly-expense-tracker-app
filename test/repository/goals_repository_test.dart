import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendly/core/database/app_database.dart';
import 'package:spendly/core/database/database_providers.dart';
import 'package:spendly/features/goals/presentation/providers/goals_provider.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('new database starts with empty goals and can add a goal', () async {
    expect(await db.watchActiveGoals().first, isEmpty);
    expect(await db.watchEmergencyGoalFunds().first, isEmpty);

    await container
        .read(goalsActionsProvider)
        .addGoal(
          title: 'Trip',
          category: 'Travel',
          targetAmount: 50000,
          initialSaved: 5000,
          targetDate: DateTime.now().add(const Duration(days: 180)),
          monthlyContribution: 7500,
        );

    final goals = await db.watchActiveGoals().first;
    expect(goals, hasLength(1));
    expect(goals.single.title, 'Trip');
    expect(goals.single.savedAmount, 5000);

    final contributions = await db
        .watchGoalContributions(goals.single.id)
        .first;
    expect(contributions, hasLength(1));
    expect(contributions.single.amount, 5000);
  });

  test('existing goal can be updated', () async {
    await container
        .read(goalsActionsProvider)
        .addGoal(
          title: 'Trip',
          category: 'Travel',
          targetAmount: 50000,
          initialSaved: 5000,
          targetDate: DateTime.now().add(const Duration(days: 180)),
          monthlyContribution: 7500,
        );

    final createdGoal = (await db.watchActiveGoals().first).single;

    await container
        .read(goalsActionsProvider)
        .updateGoal(
          goalId: createdGoal.id,
          title: 'Japan Trip',
          category: 'Vacation',
          targetAmount: 65000,
          savedAmount: 8000,
          targetDate: DateTime.now().add(const Duration(days: 240)),
          monthlyContribution: 9000,
        );

    final updatedGoal = (await db.watchActiveGoals().first).single;
    expect(updatedGoal.title, 'Japan Trip');
    expect(updatedGoal.category, 'Vacation');
    expect(updatedGoal.targetAmount, 65000);
    expect(updatedGoal.savedAmount, 8000);
    expect(updatedGoal.monthlyContribution, 9000);

    final contributions = await db.watchGoalContributions(createdGoal.id).first;
    expect(contributions, hasLength(2));
    expect(
      contributions.any(
        (item) => item.amount == 3000 && item.note == 'Balance adjustment',
      ),
      isTrue,
    );
  });
}
