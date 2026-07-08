import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:spendly/core/constants/app_enums.dart';
import 'package:spendly/core/database/default_categories.dart';
import 'package:spendly/core/database/tables.dart';
import 'package:spendly/core/utils/money.dart';
import 'package:uuid/uuid.dart';

part 'app_database.g.dart';

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final file = await _resolveDatabaseFile();
    return NativeDatabase.createInBackground(file);
  });
}

Future<File> _resolveDatabaseFile() async {
  try {
    final dir = await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, 'spendly.sqlite'));
  } catch (_) {
    return File(p.join(Directory.systemTemp.path, 'spendly.sqlite'));
  }
}

@DriftDatabase(
  tables: [
    Transactions,
    Categories,
    RecurringRules,
    Settings,
    UserProfiles,
    LendPeople,
    LendEntries,
    LendSettlementEvents,
    MonthlyReflections,
    CategoryBudgets,
    ActivityEvents,
    AppUsageDays,
    GoalFunds,
    GoalContributions,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  Future<bool> _hasColumn(String tableName, String columnName) async {
    final rows = await customSelect('PRAGMA table_info($tableName);').get();
    return rows.any((row) => row.read<String>('name') == columnName);
  }

  @override
  int get schemaVersion => 22;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _ensureDefaultSettings();
      await _ensureDefaultUserProfile();
      await seedDefaultCategoriesIfNeeded();
    },
    onUpgrade: (m, from, to) async {
      if (from < 3) {
        await m.createTable(recurringRules);
      }
      if (from < 4) {
        await m.addColumn(settings, settings.transactionHintsSeen);
      }
      if (from < 5) {
        await m.createTable(userProfiles);
        await _ensureDefaultUserProfile();
      }
      if (from < 6) {
        await m.addColumn(userProfiles, userProfiles.onboardingCompleted);
      }
      if (from < 7) {
        await customStatement('DROP TABLE IF EXISTS investments;');
      }
      if (from < 8) {
        await m.createTable(lendPeople);
        await m.createTable(lendEntries);
      }
      if (from < 9) {
        await m.createTable(monthlyReflections);
      }
      if (from < 10) {
        await m.addColumn(transactions, transactions.recurringRuleId);
        await m.addColumn(transactions, transactions.isRecurringInstance);
        await m.addColumn(recurringRules, recurringRules.type);
      }
      if (from < 11) {
        await m.addColumn(lendEntries, lendEntries.settledAt);
      }
      if (from < 12) {
        await m.addColumn(lendEntries, lendEntries.settledAmount);
      }
      if (from < 13) {
        await m.createTable(lendSettlementEvents);
      }
      if (from < 14) {
        final hasDailyReminder = await _hasColumn(
          'settings',
          'daily_reminder_enabled',
        );
        if (!hasDailyReminder) {
          await m.addColumn(settings, settings.dailyReminderEnabled);
        }

        final hasLastBudgetAlert = await _hasColumn(
          'settings',
          'last_budget_alert_at',
        );
        if (!hasLastBudgetAlert) {
          await m.addColumn(settings, settings.lastBudgetAlertAt);
        }
      }
      if (from < 15) {
        await m.createTable(categoryBudgets);
      }
      if (from < 16) {
        await m.addColumn(transactions, transactions.amountPaise);
        await m.addColumn(recurringRules, recurringRules.amountPaise);
        await m.addColumn(settings, settings.monthlyBudgetPaise);
        await m.addColumn(lendEntries, lendEntries.amountPaise);
        await m.addColumn(lendEntries, lendEntries.settledAmountPaise);
        await m.addColumn(
          lendSettlementEvents,
          lendSettlementEvents.amountPaise,
        );
        await m.addColumn(categoryBudgets, categoryBudgets.budgetAmountPaise);

        await customStatement(
          'UPDATE transactions SET amount_paise = CAST(ROUND(amount * 100.0) AS INTEGER) WHERE amount_paise = 0;',
        );
        await customStatement(
          'UPDATE recurring_rules SET amount_paise = CAST(ROUND(amount * 100.0) AS INTEGER) WHERE amount_paise = 0;',
        );
        await customStatement(
          'UPDATE settings SET monthly_budget_paise = CAST(ROUND(monthly_budget * 100.0) AS INTEGER) WHERE monthly_budget_paise = 0;',
        );
        await customStatement(
          'UPDATE lend_entries SET amount_paise = CAST(ROUND(amount * 100.0) AS INTEGER) WHERE amount_paise = 0;',
        );
        await customStatement(
          'UPDATE lend_entries SET settled_amount_paise = CAST(ROUND(settled_amount * 100.0) AS INTEGER) WHERE settled_amount_paise = 0;',
        );
        await customStatement(
          'UPDATE lend_settlement_events SET amount_paise = CAST(ROUND(amount * 100.0) AS INTEGER) WHERE amount_paise = 0;',
        );
        await customStatement(
          'UPDATE category_budgets SET budget_amount_paise = CAST(ROUND(budget_amount * 100.0) AS INTEGER) WHERE budget_amount_paise = 0;',
        );
      }
      if (from < 17) {
        final hasPrivacyLock = await _hasColumn(
          'settings',
          'privacy_lock_enabled',
        );
        if (!hasPrivacyLock) {
          await m.addColumn(settings, settings.privacyLockEnabled);
        }
      }
      if (from < 18) {
        await m.createTable(activityEvents);
        await m.createTable(appUsageDays);
      }
      if (from < 19) {
        await m.createTable(goalFunds);
        await m.createTable(goalContributions);
      }
      if (from < 20) {
        await m.addColumn(transactions, transactions.cardType);
      }
      if (from < 21) {
        final hasShowAmounts = await _hasColumn(
          'settings',
          'show_amounts_enabled',
        );
        if (!hasShowAmounts) {
          await m.addColumn(settings, settings.showAmountsEnabled);
        }
      }
      if (from < 22) {
        await customStatement(
          "UPDATE transactions SET category_id = 'cat_goal_transfer' "
          "WHERE category_id = 'cat_stocks' "
          "AND (note LIKE '-> %' OR note LIKE '<- %');",
        );
      }
    },
    beforeOpen: (details) async {
      if (details.versionNow >= 12) {
        await customStatement(
          'UPDATE lend_entries SET settled_amount = 0 WHERE settled_amount IS NULL;',
        );
      }

      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_transactions_active_date '
        'ON transactions (is_deleted, date);',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_transactions_type '
        'ON transactions (type);',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_transactions_category '
        'ON transactions (category_id);',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_categories_active_type '
        'ON categories (is_deleted, type);',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_goal_funds_active_emergency '
        'ON goal_funds (is_deleted, is_emergency);',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_goal_contributions_goal '
        'ON goal_contributions (goal_id, is_deleted);',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_recurring_rules_active '
        'ON recurring_rules (is_deleted);',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_lend_entries_person '
        'ON lend_entries (person_id, is_deleted);',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_lend_people_active '
        'ON lend_people (is_deleted);',
      );

      await seedDefaultCategoriesIfNeeded();
    },
  );

  Future<void> _ensureDefaultSettings() async {
    await into(settings).insertOnConflictUpdate(
      SettingsCompanion.insert(
        id: const Value(1),
        monthlyBudget: const Value(0),
        monthlyBudgetPaise: const Value(0),
        currency: const Value('INR'),
        themeMode: const Value('system'),
        transactionHintsSeen: const Value(false),
        dailyReminderEnabled: const Value(false),
        privacyLockEnabled: const Value(false),
        showAmountsEnabled: const Value(true),
        lastBudgetAlertAt: const Value(null),
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  Future<void> _ensureDefaultUserProfile() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await into(userProfiles).insertOnConflictUpdate(
      UserProfilesCompanion.insert(
        id: const Value(1),
        name: const Value('User'),
        imageUrl: const Value(null),
        email: const Value(null),
        phone: const Value(null),
        onboardingCompleted: const Value(false),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<void> seedDefaultCategoriesIfNeeded() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    for (final seed in defaultCategories) {
      final existing = await (select(categories)
            ..where((tbl) => tbl.id.equals(seed.id)))
          .getSingleOrNull();
      if (existing != null) continue;
      await into(categories).insert(
        CategoriesCompanion.insert(
          id: seed.id,
          name: seed.name,
          icon: seed.icon,
          color: seed.color,
          type: seed.type.value,
          createdAt: now,
          updatedAt: now,
          isDeleted: const Value(false),
        ),
      );
    }
  }

  Stream<List<Transaction>> watchRecentTransactions({int limit = 5, String? excludeCategoryId}) {
    final query = (select(transactions)
      ..where((tbl) => tbl.isDeleted.equals(false))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)])
      ..limit(limit));
    if (excludeCategoryId != null) {
      query.where((tbl) => tbl.categoryId.equals(excludeCategoryId).not());
    }
    return query.watch();
  }

  Stream<List<Transaction>> watchTransactionsByMonth(
    DateTime month, {
    String? type,
    String? categoryId,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) {
    final start = dateFrom != null
        ? DateTime(
            dateFrom.year,
            dateFrom.month,
            dateFrom.day,
          ).millisecondsSinceEpoch
        : DateTime(month.year, month.month, 1).millisecondsSinceEpoch;
    final end = dateTo != null
        ? DateTime(
            dateTo.year,
            dateTo.month,
            dateTo.day + 1,
          ).millisecondsSinceEpoch
        : DateTime(month.year, month.month + 1, 1).millisecondsSinceEpoch;
    final query = select(transactions)
      ..where((tbl) => tbl.isDeleted.equals(false))
      ..where((tbl) => tbl.date.isBiggerOrEqualValue(start))
      ..where((tbl) => tbl.date.isSmallerThanValue(end));

    if (type != null && type.isNotEmpty) {
      query.where((tbl) => tbl.type.equals(type));
    }
    if (categoryId != null && categoryId.isNotEmpty) {
      query.where((tbl) => tbl.categoryId.equals(categoryId));
    }

    query.orderBy([(tbl) => OrderingTerm.desc(tbl.date)]);
    return query.watch();
  }

  Stream<List<Transaction>> watchAllActiveTransactions() {
    final query = select(transactions)
      ..where((tbl) => tbl.isDeleted.equals(false))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)]);
    return query.watch();
  }

  Future<void> upsertTransaction(TransactionsCompanion companion) async {
    await into(transactions).insertOnConflictUpdate(companion);
  }

  Future<void> softDeleteTransaction(String id) async {
    await (update(transactions)..where((tbl) => tbl.id.equals(id))).write(
      TransactionsCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  Future<void> softDeleteTransactionsByRecurringRuleFromDate(
    String ruleId,
    int fromDateEpoch,
  ) async {
    await (update(transactions)
          ..where((tbl) => tbl.isDeleted.equals(false))
          ..where((tbl) => tbl.recurringRuleId.equals(ruleId))
          ..where((tbl) => tbl.date.isBiggerOrEqualValue(fromDateEpoch)))
        .write(
          TransactionsCompanion(
            isDeleted: const Value(true),
            updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
          ),
        );
  }

  Future<bool> hasActiveRecurringOccurrenceOnDate({
    required String ruleId,
    required int dayStartEpoch,
    required int dayEndExclusiveEpoch,
  }) async {
    final countExpr = transactions.id.count();
    final query = selectOnly(transactions)
      ..addColumns([countExpr])
      ..where(transactions.isDeleted.equals(false))
      ..where(transactions.recurringRuleId.equals(ruleId))
      ..where(transactions.date.isBiggerOrEqualValue(dayStartEpoch))
      ..where(transactions.date.isSmallerThanValue(dayEndExclusiveEpoch));
    final row = await query.getSingle();
    final count = row.read(countExpr) ?? 0;
    return count > 0;
  }

  Future<RecurringRule?> getRecurringRuleById(String ruleId) {
    final query = select(recurringRules)..where((tbl) => tbl.id.equals(ruleId));
    return query.getSingleOrNull();
  }

  Future<void> restoreTransaction(String id) async {
    await (update(transactions)..where((tbl) => tbl.id.equals(id))).write(
      TransactionsCompanion(
        isDeleted: const Value(false),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  Stream<List<Category>> watchCategories({String? type}) {
    final query = select(categories)
      ..where((tbl) => tbl.isDeleted.equals(false));
    if (type != null && type.isNotEmpty) {
      query.where((tbl) => tbl.type.equals(type));
    }
    query.orderBy([(tbl) => OrderingTerm.asc(tbl.name)]);
    return query.watch();
  }

  Future<List<Category>> getCategories() {
    final query = select(categories)
      ..where((tbl) => tbl.isDeleted.equals(false));
    return query.get();
  }

  Future<void> upsertCategory(CategoriesCompanion companion) async {
    await into(categories).insertOnConflictUpdate(companion);
  }

  Future<void> softDeleteCategory(String id) async {
    await (update(categories)..where((tbl) => tbl.id.equals(id))).write(
      CategoriesCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  Stream<List<RecurringRule>> watchRecurringRules() {
    final query = select(recurringRules)
      ..where((tbl) => tbl.isDeleted.equals(false))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.nextDueDate)]);
    return query.watch();
  }

  Future<List<RecurringRule>> getRecurringRules() {
    final query = select(recurringRules)
      ..where((tbl) => tbl.isDeleted.equals(false));
    return query.get();
  }

  Future<List<RecurringRule>> getDueRecurringRules(int nowEpoch) {
    final query = select(recurringRules)
      ..where(
        (tbl) =>
            tbl.isDeleted.equals(false) &
            tbl.isActive.equals(true) &
            tbl.nextDueDate.isSmallerOrEqualValue(nowEpoch),
      )
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.nextDueDate)]);
    return query.get();
  }

  Future<void> upsertRecurringRule(RecurringRulesCompanion companion) async {
    await into(recurringRules).insertOnConflictUpdate(companion);
  }

  Future<void> softDeleteRecurringRule(String id) async {
    await (update(recurringRules)..where((tbl) => tbl.id.equals(id))).write(
      RecurringRulesCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  Future<void> setRecurringRuleActive(String id, bool isActive) async {
    await (update(recurringRules)..where((tbl) => tbl.id.equals(id))).write(
      RecurringRulesCompanion(
        isActive: Value(isActive),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  Future<void> updateRecurringRuleNextDue(String id, int nextDueEpoch) async {
    await (update(recurringRules)..where((tbl) => tbl.id.equals(id))).write(
      RecurringRulesCompanion(
        nextDueDate: Value(nextDueEpoch),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  Stream<Setting?> watchSettingsRow() {
    final query = select(settings)..where((tbl) => tbl.id.equals(1));
    return query.watchSingleOrNull();
  }

  Future<Setting?> getSettingsRow() {
    final query = select(settings)..where((tbl) => tbl.id.equals(1));
    return query.getSingleOrNull();
  }

  Future<void> upsertSettings(SettingsCompanion companion) async {
    await into(settings).insertOnConflictUpdate(companion);
  }

  Stream<UserProfile?> watchUserProfileRow() {
    final query = select(userProfiles)..where((tbl) => tbl.id.equals(1));
    return query.watchSingleOrNull();
  }

  Future<UserProfile?> getUserProfileRow() {
    final query = select(userProfiles)..where((tbl) => tbl.id.equals(1));
    return query.getSingleOrNull();
  }

  Future<void> upsertUserProfile(UserProfilesCompanion companion) async {
    await into(userProfiles).insertOnConflictUpdate(companion);
  }

  Stream<List<LendPeopleData>> watchLendPeople() {
    final query = select(lendPeople)
      ..where((tbl) => tbl.isDeleted.equals(false))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]);
    return query.watch();
  }

  Future<List<LendPeopleData>> getLendPeople() {
    final query = select(lendPeople)
      ..where((tbl) => tbl.isDeleted.equals(false))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]);
    return query.get();
  }

  Future<LendPeopleData?> getLendPersonById(String personId) {
    final query = select(lendPeople)..where((tbl) => tbl.id.equals(personId));
    return query.getSingleOrNull();
  }

  Future<void> upsertLendPerson(LendPeopleCompanion companion) async {
    await into(lendPeople).insertOnConflictUpdate(companion);
  }

  Future<void> updateLendPersonName(String personId, String name) async {
    await (update(lendPeople)..where((tbl) => tbl.id.equals(personId))).write(
      LendPeopleCompanion(
        name: Value(name),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  Future<void> softDeleteLendPerson(String personId) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await (update(lendPeople)..where((tbl) => tbl.id.equals(personId))).write(
      LendPeopleCompanion(isDeleted: const Value(true), updatedAt: Value(now)),
    );
    await (update(
      lendEntries,
    )..where((tbl) => tbl.personId.equals(personId))).write(
      LendEntriesCompanion(isDeleted: const Value(true), updatedAt: Value(now)),
    );
    await (update(lendSettlementEvents)
          ..where((tbl) => tbl.personId.equals(personId)))
        .write(const LendSettlementEventsCompanion(isDeleted: Value(true)));
  }

  Stream<List<LendEntry>> watchLendEntries() {
    final query = select(lendEntries)
      ..where((tbl) => tbl.isDeleted.equals(false))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)]);
    return query.watch();
  }

  Stream<List<LendEntry>> watchLendEntriesByPerson(String personId) {
    final query = select(lendEntries)
      ..where((tbl) => tbl.isDeleted.equals(false))
      ..where((tbl) => tbl.personId.equals(personId))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)]);
    return query.watch();
  }

  Stream<List<LendSettlementEvent>> watchLendSettlementEventsByPerson(
    String personId,
  ) {
    final query = select(lendSettlementEvents)
      ..where((tbl) => tbl.isDeleted.equals(false))
      ..where((tbl) => tbl.personId.equals(personId))
      ..orderBy([
        (tbl) => OrderingTerm.desc(tbl.date),
        (tbl) => OrderingTerm.desc(tbl.createdAt),
      ]);
    return query.watch();
  }

  Future<List<LendEntry>> getLendEntries() {
    final query = select(lendEntries)
      ..where((tbl) => tbl.isDeleted.equals(false))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)]);
    return query.get();
  }

  Future<void> upsertLendEntry(LendEntriesCompanion companion) async {
    await into(lendEntries).insertOnConflictUpdate(companion);
  }

  Future<void> updateLendEntry(
    String entryId,
    LendEntriesCompanion companion,
  ) async {
    await (update(
      lendEntries,
    )..where((tbl) => tbl.id.equals(entryId))).write(companion);
  }

  Future<void> upsertLendSettlementEvent(
    LendSettlementEventsCompanion companion,
  ) async {
    await into(lendSettlementEvents).insertOnConflictUpdate(companion);
  }

  Future<LendEntry?> getLendEntryById(String entryId) {
    final query = select(lendEntries)..where((tbl) => tbl.id.equals(entryId));
    return query.getSingleOrNull();
  }

  Future<List<LendSettlementEvent>> getLendSettlementEventsByEntry(
    String entryId,
  ) {
    final query = select(lendSettlementEvents)
      ..where((tbl) => tbl.isDeleted.equals(false))
      ..where((tbl) => tbl.entryId.equals(entryId))
      ..orderBy([
        (tbl) => OrderingTerm.desc(tbl.date),
        (tbl) => OrderingTerm.desc(tbl.createdAt),
      ]);
    return query.get();
  }

  Future<List<LendSettlementEvent>> getLendSettlementEvents() {
    final query = select(lendSettlementEvents)
      ..where((tbl) => tbl.isDeleted.equals(false))
      ..orderBy([
        (tbl) => OrderingTerm.desc(tbl.date),
        (tbl) => OrderingTerm.desc(tbl.createdAt),
      ]);
    return query.get();
  }

  Future<LendSettlementEvent?> getLastLendSettlementEvent(String entryId) {
    final query = (select(lendSettlementEvents)
      ..where((tbl) => tbl.isDeleted.equals(false))
      ..where((tbl) => tbl.entryId.equals(entryId))
      ..orderBy([
        (tbl) => OrderingTerm.desc(tbl.date),
        (tbl) => OrderingTerm.desc(tbl.createdAt),
      ])
      ..limit(1));
    return query.getSingleOrNull();
  }

  Future<void> softDeleteLendSettlementEvent(String eventId) async {
    await (update(lendSettlementEvents)..where((tbl) => tbl.id.equals(eventId)))
        .write(const LendSettlementEventsCompanion(isDeleted: Value(true)));
  }

  Future<void> softDeleteLendEntry(String entryId) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await (update(lendEntries)..where((tbl) => tbl.id.equals(entryId))).write(
      LendEntriesCompanion(isDeleted: const Value(true), updatedAt: Value(now)),
    );
    await (update(lendSettlementEvents)
          ..where((tbl) => tbl.entryId.equals(entryId)))
        .write(const LendSettlementEventsCompanion(isDeleted: Value(true)));
  }

  Future<void> setLendEntrySettled(
    String entryId,
    bool isSettled, {
    double? settledAmount,
    int? settledAtEpoch,
  }) async {
    await (update(lendEntries)..where((tbl) => tbl.id.equals(entryId))).write(
      LendEntriesCompanion(
        isSettled: Value(isSettled),
        settledAmount: Value(settledAmount ?? 0),
        settledAmountPaise: Value(Money.toPaise(settledAmount ?? 0)),
        settledAt: Value(isSettled ? settledAtEpoch : null),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  Stream<MonthlyReflection?> watchMonthlyReflection(String monthKey) {
    final query = select(monthlyReflections)
      ..where((tbl) => tbl.monthKey.equals(monthKey));
    return query.watchSingleOrNull();
  }

  Future<List<MonthlyReflection>> getMonthlyReflections() {
    return select(monthlyReflections).get();
  }

  Future<void> upsertMonthlyReflection(
    MonthlyReflectionsCompanion companion,
  ) async {
    await into(monthlyReflections).insertOnConflictUpdate(companion);
  }

  Stream<List<CategoryBudget>> watchCategoryBudgetsForMonth(String monthKey) {
    final query = select(categoryBudgets)
      ..where((tbl) => tbl.monthKey.equals(monthKey));
    return query.watch();
  }

  Future<List<CategoryBudget>> getCategoryBudgetsForMonth(String monthKey) {
    final query = select(categoryBudgets)
      ..where((tbl) => tbl.monthKey.equals(monthKey));
    return query.get();
  }

  Future<void> upsertCategoryBudget(CategoryBudgetsCompanion companion) async {
    await into(categoryBudgets).insertOnConflictUpdate(companion);
  }

  Stream<List<ActivityEvent>> watchRecentActivityEvents({int days = 3}) {
    final cutoff = DateTime.now()
        .subtract(Duration(days: days))
        .millisecondsSinceEpoch;
    final query = select(activityEvents)
      ..where((tbl) => tbl.occurredAt.isBiggerOrEqualValue(cutoff))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.occurredAt)])
      ..limit(100);
    return query.watch();
  }

  Future<List<ActivityEvent>> getActivityEvents() {
    final query = select(activityEvents)
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.occurredAt)]);
    return query.get();
  }

  Future<void> insertActivityEvent(ActivityEventsCompanion companion) async {
    await into(activityEvents).insert(companion);
    final cutoff = DateTime.now()
        .subtract(const Duration(days: 3))
        .millisecondsSinceEpoch;
    await (delete(activityEvents)
          ..where((tbl) => tbl.occurredAt.isSmallerThanValue(cutoff)))
        .go();
  }

  Stream<List<AppUsageDay>> watchRecentAppUsageDays({int days = 4}) {
    final now = DateTime.now();
    final cutoffDate = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: days - 1));
    final cutoffKey = _usageDateKey(cutoffDate);
    final query = select(appUsageDays)
      ..where((tbl) => tbl.dateKey.isBiggerOrEqualValue(cutoffKey))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.dateKey)]);
    return query.watch();
  }

  Stream<List<AppUsageDay>> watchAllAppUsageDays() {
    final query = select(appUsageDays)
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.dateKey)]);
    return query.watch();
  }

  Future<List<AppUsageDay>> getAppUsageDays() {
    final query = select(appUsageDays)
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.dateKey)]);
    return query.get();
  }

  Future<void> addScreenTimeSeconds(int seconds) async {
    if (seconds <= 0) return;
    final now = DateTime.now();
    final dateKey = _usageDateKey(now);
    await customStatement(
      '''
      INSERT INTO app_usage_days (date_key, total_seconds, updated_at)
      VALUES (?, ?, ?)
      ON CONFLICT(date_key) DO UPDATE SET
        total_seconds = total_seconds + excluded.total_seconds,
        updated_at = excluded.updated_at;
      ''',
      [dateKey, seconds, now.millisecondsSinceEpoch],
    );
  }

  Stream<GoalFund?> watchEmergencyGoalFund() {
    final query = (select(goalFunds)
      ..where((tbl) => tbl.isDeleted.equals(false))
      ..where((tbl) => tbl.isEmergency.equals(true))
      ..limit(1));
    return query.watchSingleOrNull();
  }

  Stream<List<GoalFund>> watchEmergencyGoalFunds() {
    final query = (select(goalFunds)
      ..where((tbl) => tbl.isDeleted.equals(false))
      ..where((tbl) => tbl.isEmergency.equals(true))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.createdAt)]));
    return query.watch();
  }

  Stream<List<GoalFund>> watchActiveGoals() {
    final query = (select(goalFunds)
      ..where((tbl) => tbl.isDeleted.equals(false))
      ..where((tbl) => tbl.isEmergency.equals(false))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.targetDate)]));
    return query.watch();
  }

  Stream<List<GoalContribution>> watchGoalContributions(String goalId) {
    final query = (select(goalContributions)
      ..where((tbl) => tbl.isDeleted.equals(false))
      ..where((tbl) => tbl.goalId.equals(goalId))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]));
    return query.watch();
  }

  Future<List<GoalFund>> getGoalFunds() {
    final query = select(goalFunds)
      ..where((tbl) => tbl.isDeleted.equals(false));
    return query.get();
  }

  Future<List<GoalContribution>> getGoalContributions() {
    final query = select(goalContributions)
      ..where((tbl) => tbl.isDeleted.equals(false));
    return query.get();
  }

  Future<void> upsertGoalFund(GoalFundsCompanion companion) async {
    await into(goalFunds).insertOnConflictUpdate(companion);
  }

  Future<void> softDeleteGoalFund(String goalId) async {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    await (update(goalFunds)..where((tbl) => tbl.id.equals(goalId))).write(
      GoalFundsCompanion(isDeleted: const Value(true), updatedAt: Value(nowMs)),
    );
    await (update(goalContributions)..where((tbl) => tbl.goalId.equals(goalId)))
        .write(const GoalContributionsCompanion(isDeleted: Value(true)));
  }

  Future<bool> addGoalContribution({
    required String goalId,
    required double amount,
    String? note,
  }) async {
    if (amount == 0) return false;
    final normalized = Money.normalize(amount);
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    var applied = false;
    await transaction(() async {
      final goal = await (select(
        goalFunds,
      )..where((tbl) => tbl.id.equals(goalId))).getSingleOrNull();
      if (goal == null) return;
      final nextSavedRaw = goal.savedAmount + normalized;
      if (nextSavedRaw < 0) return;

      await into(goalContributions).insert(
        GoalContributionsCompanion.insert(
          id: const Uuid().v4(),
          goalId: goalId,
          amount: normalized,
          amountPaise: Value(Money.toPaise(normalized)),
          note: Value(note),
          createdAt: nowMs,
          isDeleted: const Value(false),
        ),
      );
      final nextSaved = Money.normalize(nextSavedRaw);
      await (update(goalFunds)..where((tbl) => tbl.id.equals(goalId))).write(
        GoalFundsCompanion(
          savedAmount: Value(nextSaved),
          savedAmountPaise: Value(Money.toPaise(nextSaved)),
          recentDelta: Value(normalized),
          recentDeltaPaise: Value(Money.toPaise(normalized)),
          updatedAt: Value(nowMs),
        ),
      );
      applied = true;
    });
    return applied;
  }

  Future<void> softDeleteGoalContribution(String contributionId) async {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    await transaction(() async {
      final contribution =
          await (select(goalContributions)
                ..where((tbl) => tbl.id.equals(contributionId))
                ..where((tbl) => tbl.isDeleted.equals(false)))
              .getSingleOrNull();
      if (contribution == null) return;

      await (update(goalContributions)
            ..where((tbl) => tbl.id.equals(contributionId)))
          .write(const GoalContributionsCompanion(isDeleted: Value(true)));

      final goal = await (select(
        goalFunds,
      )..where((tbl) => tbl.id.equals(contribution.goalId))).getSingleOrNull();
      if (goal == null) return;
      final nextSaved = Money.normalize(
        (goal.savedAmount - contribution.amount).clamp(0, double.infinity),
      );
      await (update(
        goalFunds,
      )..where((tbl) => tbl.id.equals(contribution.goalId))).write(
        GoalFundsCompanion(
          savedAmount: Value(nextSaved),
          savedAmountPaise: Value(Money.toPaise(nextSaved)),
          recentDelta: Value(0),
          recentDeltaPaise: Value(0),
          updatedAt: Value(nowMs),
        ),
      );
    });
  }

  String _usageDateKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> replaceAllData({
    required List<CategoriesCompanion> categoryRows,
    required List<TransactionsCompanion> transactionRows,
    required List<RecurringRulesCompanion> recurringRuleRows,
    required List<LendPeopleCompanion> lendPeopleRows,
    required List<LendEntriesCompanion> lendEntryRows,
    required List<LendSettlementEventsCompanion> lendSettlementEventRows,
    required List<MonthlyReflectionsCompanion> monthlyReflectionRows,
    required List<CategoryBudgetsCompanion> categoryBudgetRows,
    required List<ActivityEventsCompanion> activityEventRows,
    required List<AppUsageDaysCompanion> appUsageDayRows,
    List<GoalFundsCompanion> goalFundRows = const [],
    List<GoalContributionsCompanion> goalContributionRows = const [],
    required SettingsCompanion settingsRow,
    required UserProfilesCompanion userProfileRow,
  }) async {
    await transaction(() async {
      await delete(transactions).go();
      await delete(categories).go();
      await delete(recurringRules).go();
      await delete(lendEntries).go();
      await delete(lendSettlementEvents).go();
      await delete(lendPeople).go();
      await delete(monthlyReflections).go();
      await delete(categoryBudgets).go();
      await delete(activityEvents).go();
      await delete(appUsageDays).go();
      await delete(goalContributions).go();
      await delete(goalFunds).go();
      await delete(settings).go();
      await delete(userProfiles).go();
      if (categoryRows.isNotEmpty) {
        await batch((b) => b.insertAll(categories, categoryRows));
      }
      if (transactionRows.isNotEmpty) {
        await batch((b) => b.insertAll(transactions, transactionRows));
      }
      if (recurringRuleRows.isNotEmpty) {
        await batch((b) => b.insertAll(recurringRules, recurringRuleRows));
      }
      if (lendPeopleRows.isNotEmpty) {
        await batch((b) => b.insertAll(lendPeople, lendPeopleRows));
      }
      if (lendEntryRows.isNotEmpty) {
        await batch((b) => b.insertAll(lendEntries, lendEntryRows));
      }
      if (lendSettlementEventRows.isNotEmpty) {
        await batch(
          (b) => b.insertAll(lendSettlementEvents, lendSettlementEventRows),
        );
      }
      if (monthlyReflectionRows.isNotEmpty) {
        await batch(
          (b) => b.insertAll(monthlyReflections, monthlyReflectionRows),
        );
      }
      if (categoryBudgetRows.isNotEmpty) {
        await batch((b) => b.insertAll(categoryBudgets, categoryBudgetRows));
      }
      if (activityEventRows.isNotEmpty) {
        await batch((b) => b.insertAll(activityEvents, activityEventRows));
      }
      if (appUsageDayRows.isNotEmpty) {
        await batch((b) => b.insertAll(appUsageDays, appUsageDayRows));
      }
      if (goalFundRows.isNotEmpty) {
        await batch((b) => b.insertAll(goalFunds, goalFundRows));
      }
      if (goalContributionRows.isNotEmpty) {
        await batch(
          (b) => b.insertAll(goalContributions, goalContributionRows),
        );
      }
      await into(settings).insertOnConflictUpdate(settingsRow);
      await into(userProfiles).insertOnConflictUpdate(userProfileRow);
    });
  }

  Future<void> clearAllAndReseed() async {
    await transaction(() async {
      await delete(transactions).go();
      await delete(categories).go();
      await delete(recurringRules).go();
      await delete(lendEntries).go();
      await delete(lendSettlementEvents).go();
      await delete(lendPeople).go();
      await delete(monthlyReflections).go();
      await delete(categoryBudgets).go();
      await delete(activityEvents).go();
      await delete(appUsageDays).go();
      await delete(goalContributions).go();
      await delete(goalFunds).go();
      await delete(settings).go();
      await delete(userProfiles).go();
      await _ensureDefaultSettings();
      await _ensureDefaultUserProfile();
      await seedDefaultCategoriesIfNeeded();
    });
  }
}
