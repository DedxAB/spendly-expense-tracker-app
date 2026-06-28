import 'package:drift/drift.dart';

class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  RealColumn get amount => real()();
  IntColumn get amountPaise =>
      integer().named('amount_paise').withDefault(const Constant(0))();
  TextColumn get categoryId => text().named('category_id')();
  TextColumn get paymentMode => text().named('payment_mode')();
  TextColumn get cardType => text().named('card_type').nullable()();
  TextColumn get note => text().nullable()();
  IntColumn get date => integer()();
  IntColumn get createdAt => integer().named('created_at')();
  IntColumn get updatedAt => integer().named('updated_at')();
  TextColumn get recurringRuleId =>
      text().named('recurring_rule_id').nullable()();
  BoolColumn get isRecurringInstance => boolean()
      .named('is_recurring_instance')
      .withDefault(const Constant(false))();
  BoolColumn get isDeleted =>
      boolean().named('is_deleted').withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [];
}

class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get icon => text()();
  TextColumn get color => text()();
  TextColumn get type => text()();
  IntColumn get createdAt => integer().named('created_at')();
  IntColumn get updatedAt => integer().named('updated_at')();
  BoolColumn get isDeleted =>
      boolean().named('is_deleted').withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class RecurringRules extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get type => text().withDefault(const Constant('expense'))();
  RealColumn get amount => real()();
  IntColumn get amountPaise =>
      integer().named('amount_paise').withDefault(const Constant(0))();
  TextColumn get categoryId => text().named('category_id')();
  TextColumn get paymentMode => text().named('payment_mode')();
  TextColumn get frequency => text()();
  TextColumn get note => text().nullable()();
  IntColumn get startDate => integer().named('start_date')();
  IntColumn get nextDueDate => integer().named('next_due_date')();
  IntColumn get createdAt => integer().named('created_at')();
  IntColumn get updatedAt => integer().named('updated_at')();
  BoolColumn get isActive =>
      boolean().named('is_active').withDefault(const Constant(true))();
  BoolColumn get isDeleted =>
      boolean().named('is_deleted').withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Settings extends Table {
  IntColumn get id => integer()();
  RealColumn get monthlyBudget =>
      real().named('monthly_budget').withDefault(const Constant(0))();
  IntColumn get monthlyBudgetPaise =>
      integer().named('monthly_budget_paise').withDefault(const Constant(0))();
  TextColumn get currency => text().withDefault(const Constant('INR'))();
  TextColumn get themeMode =>
      text().named('theme_mode').withDefault(const Constant('system'))();
  BoolColumn get transactionHintsSeen => boolean()
      .named('transaction_hints_seen')
      .withDefault(const Constant(false))();
  BoolColumn get dailyReminderEnabled => boolean()
      .named('daily_reminder_enabled')
      .withDefault(const Constant(false))();
  IntColumn get dailyReminderTime => integer()
      .named('daily_reminder_time')
      .withDefault(const Constant(1200))();
  BoolColumn get recurringBillRemindersEnabled => boolean()
      .named('recurring_bill_reminders_enabled')
      .withDefault(const Constant(false))();
  BoolColumn get lendDueRemindersEnabled => boolean()
      .named('lend_due_reminders_enabled')
      .withDefault(const Constant(false))();
  BoolColumn get goalRemindersEnabled => boolean()
      .named('goal_reminders_enabled')
      .withDefault(const Constant(false))();
  BoolColumn get privacyLockEnabled => boolean()
      .named('privacy_lock_enabled')
      .withDefault(const Constant(false))();
  BoolColumn get showAmountsEnabled => boolean()
      .named('show_amounts_enabled')
      .withDefault(const Constant(true))();
  IntColumn get lastBudgetAlertAt =>
      integer().named('last_budget_alert_at').nullable()();
  IntColumn get updatedAt => integer().named('updated_at')();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LendEntries extends Table {
  TextColumn get id => text()();
  TextColumn get personId => text().named('person_id')();
  TextColumn get type => text()();
  RealColumn get amount => real()();
  IntColumn get amountPaise =>
      integer().named('amount_paise').withDefault(const Constant(0))();
  IntColumn get date => integer()();
  IntColumn get dueDate => integer().named('due_date').nullable()();
  TextColumn get note => text().nullable()();
  BoolColumn get isSettled =>
      boolean().named('is_settled').withDefault(const Constant(false))();
  RealColumn get settledAmount =>
      real().named('settled_amount').withDefault(const Constant(0))();
  IntColumn get settledAmountPaise =>
      integer().named('settled_amount_paise').withDefault(const Constant(0))();
  IntColumn get settledAt => integer().named('settled_at').nullable()();
  IntColumn get createdAt => integer().named('created_at')();
  IntColumn get updatedAt => integer().named('updated_at')();
  BoolColumn get isDeleted =>
      boolean().named('is_deleted').withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class UserProfiles extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text().withDefault(const Constant('User'))();
  TextColumn get imageUrl => text().named('image_url').nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get phone => text().nullable()();
  BoolColumn get onboardingCompleted => boolean()
      .named('onboarding_completed')
      .withDefault(const Constant(false))();
  IntColumn get createdAt => integer().named('created_at')();
  IntColumn get updatedAt => integer().named('updated_at')();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LendPeople extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get createdAt => integer().named('created_at')();
  IntColumn get updatedAt => integer().named('updated_at')();
  BoolColumn get isDeleted =>
      boolean().named('is_deleted').withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LendSettlementEvents extends Table {
  TextColumn get id => text()();
  TextColumn get entryId => text().named('entry_id')();
  TextColumn get personId => text().named('person_id')();
  RealColumn get amount => real()();
  IntColumn get amountPaise =>
      integer().named('amount_paise').withDefault(const Constant(0))();
  IntColumn get date => integer()();
  IntColumn get createdAt => integer().named('created_at')();
  BoolColumn get isDeleted =>
      boolean().named('is_deleted').withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class MonthlyReflections extends Table {
  TextColumn get monthKey => text().named('month_key')();
  TextColumn get note => text()();
  IntColumn get updatedAt => integer().named('updated_at')();

  @override
  Set<Column<Object>> get primaryKey => {monthKey};
}

class CategoryBudgets extends Table {
  TextColumn get monthKey => text().named('month_key')();
  TextColumn get categoryId => text().named('category_id')();
  RealColumn get budgetAmount => real().named('budget_amount')();
  IntColumn get budgetAmountPaise =>
      integer().named('budget_amount_paise').withDefault(const Constant(0))();
  IntColumn get updatedAt => integer().named('updated_at')();

  @override
  Set<Column<Object>> get primaryKey => {monthKey, categoryId};
}

class ActivityEvents extends Table {
  TextColumn get id => text()();
  TextColumn get kind => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  IntColumn get occurredAt => integer().named('occurred_at')();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class AppUsageDays extends Table {
  TextColumn get dateKey => text().named('date_key')();
  IntColumn get totalSeconds =>
      integer().named('total_seconds').withDefault(const Constant(0))();
  IntColumn get updatedAt => integer().named('updated_at')();

  @override
  Set<Column<Object>> get primaryKey => {dateKey};
}

class GoalFunds extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get category => text()();
  RealColumn get targetAmount => real().named('target_amount')();
  IntColumn get targetAmountPaise =>
      integer().named('target_amount_paise').withDefault(const Constant(0))();
  RealColumn get savedAmount =>
      real().named('saved_amount').withDefault(const Constant(0))();
  IntColumn get savedAmountPaise =>
      integer().named('saved_amount_paise').withDefault(const Constant(0))();
  IntColumn get targetDate => integer().named('target_date')();
  RealColumn get monthlyContribution =>
      real().named('monthly_contribution').withDefault(const Constant(0))();
  IntColumn get monthlyContributionPaise => integer()
      .named('monthly_contribution_paise')
      .withDefault(const Constant(0))();
  RealColumn get recentDelta =>
      real().named('recent_delta').withDefault(const Constant(0))();
  IntColumn get recentDeltaPaise =>
      integer().named('recent_delta_paise').withDefault(const Constant(0))();
  RealColumn get monthlyExpense =>
      real().named('monthly_expense').withDefault(const Constant(0))();
  IntColumn get monthlyExpensePaise =>
      integer().named('monthly_expense_paise').withDefault(const Constant(0))();
  BoolColumn get isEmergency =>
      boolean().named('is_emergency').withDefault(const Constant(false))();
  IntColumn get createdAt => integer().named('created_at')();
  IntColumn get updatedAt => integer().named('updated_at')();
  BoolColumn get isDeleted =>
      boolean().named('is_deleted').withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class GoalContributions extends Table {
  TextColumn get id => text()();
  TextColumn get goalId => text().named('goal_id')();
  RealColumn get amount => real()();
  IntColumn get amountPaise =>
      integer().named('amount_paise').withDefault(const Constant(0))();
  TextColumn get note => text().nullable()();
  IntColumn get createdAt => integer().named('created_at')();
  BoolColumn get isDeleted =>
      boolean().named('is_deleted').withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
