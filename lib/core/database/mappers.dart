import 'package:drift/drift.dart';
import 'package:spendly/core/constants/app_enums.dart';
import 'package:spendly/core/database/app_database.dart';
import 'package:spendly/core/utils/money.dart';
import 'package:spendly/features/categories/domain/entities/category_entity.dart';
import 'package:spendly/features/insights/domain/entities/monthly_reflection_entity.dart';
import 'package:spendly/features/lend/domain/entities/lend_entry_entity.dart';
import 'package:spendly/features/lend/domain/entities/lend_person_entity.dart';
import 'package:spendly/features/lend/domain/entities/lend_settlement_event_entity.dart';
import 'package:spendly/features/recurring/domain/entities/recurring_rule_entity.dart';
import 'package:spendly/features/settings/domain/entities/settings_entity.dart';
import 'package:spendly/features/transactions/domain/entities/transaction_entity.dart';
import 'package:spendly/features/user/domain/entities/user_profile_entity.dart';

extension TransactionMapper on Transaction {
  TransactionEntity toEntity() {
    final rawCardType = cardType;
    return TransactionEntity(
      id: id,
      type: TransactionTypeX.fromValue(type),
      amount: amountPaise > 0 ? Money.fromPaise(amountPaise) : amount,
      categoryId: categoryId,
      paymentMode: PaymentModeX.fromValue(paymentMode),
      cardType: rawCardType == null ? null : CardTypeX.fromValue(rawCardType),
      note: note,
      date: DateTime.fromMillisecondsSinceEpoch(date),
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt),
      recurringRuleId: recurringRuleId,
      isRecurringInstance: isRecurringInstance,
      isDeleted: isDeleted,
    );
  }
}

extension CategoryMapper on Category {
  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      name: name,
      icon: icon,
      color: color,
      type: TransactionTypeX.fromValue(type),
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt),
      isDeleted: isDeleted,
    );
  }
}

extension SettingMapper on Setting {
  SettingsEntity toEntity() {
    return SettingsEntity(
      id: id,
      monthlyBudget: monthlyBudgetPaise > 0
          ? Money.fromPaise(monthlyBudgetPaise)
          : monthlyBudget,
      currency: currency,
      budgetAlertsEnabled: transactionHintsSeen,
      dailyReminderEnabled: dailyReminderEnabled,
      privacyLockEnabled: privacyLockEnabled,
      lastBudgetAlertAt: lastBudgetAlertAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(lastBudgetAlertAt!),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt),
    );
  }
}

extension RecurringRuleMapper on RecurringRule {
  RecurringRuleEntity toEntity() {
    return RecurringRuleEntity(
      id: id,
      title: title,
      type: TransactionTypeX.fromValue(type),
      amount: amountPaise > 0 ? Money.fromPaise(amountPaise) : amount,
      categoryId: categoryId,
      paymentMode: PaymentModeX.fromValue(paymentMode),
      frequency: RecurringFrequencyX.fromValue(frequency),
      note: note,
      startDate: DateTime.fromMillisecondsSinceEpoch(startDate),
      nextDueDate: DateTime.fromMillisecondsSinceEpoch(nextDueDate),
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt),
      isActive: isActive,
      isDeleted: isDeleted,
    );
  }
}

extension UserProfileMapper on UserProfile {
  UserProfileEntity toEntity() {
    return UserProfileEntity(
      id: id,
      name: name,
      imageUrl: imageUrl,
      email: email,
      phone: phone,
      onboardingCompleted: onboardingCompleted,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt),
    );
  }
}

extension LendPersonMapper on LendPeopleData {
  LendPersonEntity toEntity() {
    return LendPersonEntity(
      id: id,
      name: name,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt),
      isDeleted: isDeleted,
    );
  }
}

extension LendEntryMapper on LendEntry {
  LendEntryEntity toEntity() {
    return LendEntryEntity(
      id: id,
      personId: personId,
      type: LendEntryTypeX.fromValue(type),
      amount: amountPaise > 0 ? Money.fromPaise(amountPaise) : amount,
      date: DateTime.fromMillisecondsSinceEpoch(date),
      note: note,
      isSettled: isSettled,
      settledAmount: settledAmountPaise > 0
          ? Money.fromPaise(settledAmountPaise)
          : settledAmount,
      settledAt: settledAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(settledAt!),
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt),
      isDeleted: isDeleted,
    );
  }
}

extension LendSettlementEventMapper on LendSettlementEvent {
  LendSettlementEventEntity toEntity() {
    return LendSettlementEventEntity(
      id: id,
      entryId: entryId,
      personId: personId,
      amount: amountPaise > 0 ? Money.fromPaise(amountPaise) : amount,
      date: DateTime.fromMillisecondsSinceEpoch(date),
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
      isDeleted: isDeleted,
    );
  }
}

extension MonthlyReflectionMapper on MonthlyReflection {
  MonthlyReflectionEntity toEntity() {
    return MonthlyReflectionEntity(
      monthKey: monthKey,
      note: note,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt),
    );
  }
}

TransactionsCompanion transactionToCompanion(TransactionEntity entity) {
  return TransactionsCompanion.insert(
    id: entity.id,
    type: entity.type.value,
    amount: entity.amount,
    amountPaise: Value(Money.toPaise(entity.amount)),
    categoryId: entity.categoryId,
    paymentMode: entity.paymentMode.value,
    cardType: Value(entity.cardType?.value),
    note: Value(entity.note),
    date: entity.date.millisecondsSinceEpoch,
    createdAt: entity.createdAt.millisecondsSinceEpoch,
    updatedAt: entity.updatedAt.millisecondsSinceEpoch,
    recurringRuleId: Value(entity.recurringRuleId),
    isRecurringInstance: Value(entity.isRecurringInstance),
    isDeleted: Value(entity.isDeleted),
  );
}

CategoriesCompanion categoryToCompanion(CategoryEntity entity) {
  return CategoriesCompanion.insert(
    id: entity.id,
    name: entity.name,
    icon: entity.icon,
    color: entity.color,
    type: entity.type.value,
    createdAt: entity.createdAt.millisecondsSinceEpoch,
    updatedAt: entity.updatedAt.millisecondsSinceEpoch,
    isDeleted: Value(entity.isDeleted),
  );
}

SettingsCompanion settingsToCompanion(SettingsEntity entity) {
  return SettingsCompanion.insert(
    id: Value(entity.id),
    monthlyBudget: Value(entity.monthlyBudget),
    monthlyBudgetPaise: Value(Money.toPaise(entity.monthlyBudget)),
    currency: Value(entity.currency),
    themeMode: const Value('dark'),
    transactionHintsSeen: Value(entity.budgetAlertsEnabled),
    dailyReminderEnabled: Value(entity.dailyReminderEnabled),
    privacyLockEnabled: Value(entity.privacyLockEnabled),
    lastBudgetAlertAt: Value(entity.lastBudgetAlertAt?.millisecondsSinceEpoch),
    updatedAt: entity.updatedAt.millisecondsSinceEpoch,
  );
}

RecurringRulesCompanion recurringRuleToCompanion(RecurringRuleEntity entity) {
  return RecurringRulesCompanion.insert(
    id: entity.id,
    title: entity.title,
    type: Value(entity.type.value),
    amount: entity.amount,
    amountPaise: Value(Money.toPaise(entity.amount)),
    categoryId: entity.categoryId,
    paymentMode: entity.paymentMode.value,
    frequency: entity.frequency.value,
    note: Value(entity.note),
    startDate: entity.startDate.millisecondsSinceEpoch,
    nextDueDate: entity.nextDueDate.millisecondsSinceEpoch,
    createdAt: entity.createdAt.millisecondsSinceEpoch,
    updatedAt: entity.updatedAt.millisecondsSinceEpoch,
    isActive: Value(entity.isActive),
    isDeleted: Value(entity.isDeleted),
  );
}

UserProfilesCompanion userProfileToCompanion(UserProfileEntity entity) {
  return UserProfilesCompanion.insert(
    id: Value(entity.id),
    name: Value(entity.name),
    imageUrl: Value(entity.imageUrl),
    email: Value(entity.email),
    phone: Value(entity.phone),
    onboardingCompleted: Value(entity.onboardingCompleted),
    createdAt: entity.createdAt.millisecondsSinceEpoch,
    updatedAt: entity.updatedAt.millisecondsSinceEpoch,
  );
}

LendPeopleCompanion lendPersonToCompanion(LendPersonEntity entity) {
  return LendPeopleCompanion.insert(
    id: entity.id,
    name: entity.name,
    createdAt: entity.createdAt.millisecondsSinceEpoch,
    updatedAt: entity.updatedAt.millisecondsSinceEpoch,
    isDeleted: Value(entity.isDeleted),
  );
}

LendEntriesCompanion lendEntryToCompanion(LendEntryEntity entity) {
  return LendEntriesCompanion.insert(
    id: entity.id,
    personId: entity.personId,
    type: entity.type.value,
    amount: entity.amount,
    amountPaise: Value(Money.toPaise(entity.amount)),
    date: entity.date.millisecondsSinceEpoch,
    note: Value(entity.note),
    isSettled: Value(entity.isSettled),
    settledAmount: Value(entity.settledAmount),
    settledAmountPaise: Value(Money.toPaise(entity.settledAmount)),
    settledAt: Value(entity.settledAt?.millisecondsSinceEpoch),
    createdAt: entity.createdAt.millisecondsSinceEpoch,
    updatedAt: entity.updatedAt.millisecondsSinceEpoch,
    isDeleted: Value(entity.isDeleted),
  );
}

LendSettlementEventsCompanion lendSettlementEventToCompanion(
  LendSettlementEventEntity entity,
) {
  return LendSettlementEventsCompanion.insert(
    id: entity.id,
    entryId: entity.entryId,
    personId: entity.personId,
    amount: entity.amount,
    amountPaise: Value(Money.toPaise(entity.amount)),
    date: entity.date.millisecondsSinceEpoch,
    createdAt: entity.createdAt.millisecondsSinceEpoch,
    isDeleted: Value(entity.isDeleted),
  );
}

MonthlyReflectionsCompanion monthlyReflectionToCompanion(
  MonthlyReflectionEntity entity,
) {
  return MonthlyReflectionsCompanion.insert(
    monthKey: entity.monthKey,
    note: entity.note,
    updatedAt: entity.updatedAt.millisecondsSinceEpoch,
  );
}
