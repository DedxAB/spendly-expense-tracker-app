import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/core/constants/app_enums.dart';
import 'package:spendly/core/database/app_database.dart';
import 'package:spendly/core/database/database_providers.dart';
import 'package:spendly/core/database/mappers.dart';
import 'package:spendly/core/notifications/local_notification_service.dart';
import 'package:spendly/core/utils/money.dart';
import 'package:spendly/features/recurring/domain/entities/recurring_rule_entity.dart';
import 'package:spendly/features/recurring/domain/repositories/recurring_repository.dart';
import 'package:uuid/uuid.dart';

class RecurringRepositoryImpl implements RecurringRepository {
  RecurringRepositoryImpl(this._ref);

  final Ref _ref;

  AppDatabase get _db => _ref.read(appDatabaseProvider);
  LocalNotificationService get _notif => _ref.read(localNotificationServiceProvider);

  Future<bool> _billNotificationsEnabled() async {
    final settings = await _db.getSettingsRow();
    return settings?.recurringBillRemindersEnabled ?? false;
  }

  Future<void> _scheduleBillNotificationIfEnabled(RecurringRuleEntity rule) async {
    if (!rule.isActive || rule.isDeleted) return;
    final enabled = await _billNotificationsEnabled();
    if (!enabled) return;
    if (rule.nextDueDate.isBefore(DateTime.now())) return;
    await _notif.scheduleRecurringBillReminder(
      ruleId: rule.id,
      title: rule.title,
      amount: rule.amount,
      nextDueDate: rule.nextDueDate,
    );
  }

  @override
  Future<void> addOrUpdate(RecurringRuleEntity rule) async {
    final normalized = rule.copyWith(amount: Money.normalize(rule.amount));
    await _db.upsertRecurringRule(recurringRuleToCompanion(normalized));

    if (rule.isActive && !rule.isDeleted) {
      await _scheduleBillNotificationIfEnabled(normalized);
    } else {
      await _notif.cancelRecurringBillReminder(rule.id);
    }
  }

  @override
  Future<RecurringRuleEntity?> getById(String ruleId) async {
    final row = await _db.getRecurringRuleById(ruleId);
    return row?.toEntity();
  }

  @override
  Future<void> setActive(String ruleId, bool isActive) async {
    await _db.setRecurringRuleActive(ruleId, isActive);
    if (isActive) {
      final row = await _db.getRecurringRuleById(ruleId);
      if (row != null) {
        await _scheduleBillNotificationIfEnabled(row.toEntity());
      }
    } else {
      await _notif.cancelRecurringBillReminder(ruleId);
    }
  }

  @override
  Future<void> updateFrequency(
    String ruleId,
    RecurringFrequency frequency,
  ) async {
    final existing = await _db.getRecurringRuleById(ruleId);
    if (existing == null) return;
    await _db.upsertRecurringRule(
      existing
          .copyWith(
            frequency: frequency.value,
            updatedAt: DateTime.now().millisecondsSinceEpoch,
          )
          .toCompanion(true),
    );
    final updated = await _db.getRecurringRuleById(ruleId);
    if (updated != null) {
      await _scheduleBillNotificationIfEnabled(updated.toEntity());
    }
  }

  @override
  Future<void> softDelete(String ruleId) async {
    await _db.softDeleteRecurringRule(ruleId);
    await _notif.cancelRecurringBillReminder(ruleId);
  }

  @override
  Future<void> deleteThisAndFuture({
    required String ruleId,
    required DateTime fromDate,
  }) async {
    final fromDayStart = DateTime(
      fromDate.year,
      fromDate.month,
      fromDate.day,
    ).millisecondsSinceEpoch;
    await _db.transaction(() async {
      await _db.setRecurringRuleActive(ruleId, false);
      await _db.softDeleteTransactionsByRecurringRuleFromDate(
        ruleId,
        fromDayStart,
      );
    });
    await _notif.cancelRecurringBillReminder(ruleId);
  }

  @override
  Stream<List<RecurringRuleEntity>> watchAll() {
    return _db.watchRecurringRules().map(
      (rows) => rows.map((row) => row.toEntity()).toList(growable: false),
    );
  }

  @override
  Future<int> processDueRules() async {
    final now = DateTime.now();
    final dueRows = await _db.getDueRecurringRules(now.millisecondsSinceEpoch);
    if (dueRows.isEmpty) return 0;

    var createdCount = 0;
    await _db.transaction(() async {
      for (final row in dueRows) {
        var nextDue = DateTime.fromMillisecondsSinceEpoch(row.nextDueDate);
        var safety = 0;
        while (!nextDue.isAfter(now) && safety < 120) {
          final dayStart = DateTime(
            nextDue.year,
            nextDue.month,
            nextDue.day,
          ).millisecondsSinceEpoch;
          final dayEnd = DateTime(
            nextDue.year,
            nextDue.month,
            nextDue.day + 1,
          ).millisecondsSinceEpoch;
          final exists = await _db.hasActiveRecurringOccurrenceOnDate(
            ruleId: row.id,
            dayStartEpoch: dayStart,
            dayEndExclusiveEpoch: dayEnd,
          );
          if (exists) {
            nextDue = _advanceDate(
              nextDue,
              RecurringFrequencyX.fromValue(row.frequency),
            );
            safety++;
            continue;
          }

          final transactionDate = DateTime(
            nextDue.year,
            nextDue.month,
            nextDue.day,
            now.hour,
            now.minute,
          );
          await _db.upsertTransaction(
            TransactionsCompanion.insert(
              id: const Uuid().v4(),
              type: row.type,
              amount: Money.normalize(row.amount),
              amountPaise: Value(Money.toPaise(row.amount)),
              categoryId: row.categoryId,
              paymentMode: PaymentModeX.fromValue(row.paymentMode).value,
              note: Value(
                row.note == null || row.note!.trim().isEmpty
                    ? 'Recurring: ${row.title}'
                    : 'Recurring: ${row.title} - ${row.note}',
              ),
              date: transactionDate.millisecondsSinceEpoch,
              createdAt: now.millisecondsSinceEpoch,
              updatedAt: now.millisecondsSinceEpoch,
              recurringRuleId: Value(row.id),
              isRecurringInstance: const Value(true),
              isDeleted: const Value(false),
            ),
          );
          createdCount++;
          nextDue = _advanceDate(
            nextDue,
            RecurringFrequencyX.fromValue(row.frequency),
          );
          safety++;
        }

        await _db.updateRecurringRuleNextDue(
          row.id,
          nextDue.millisecondsSinceEpoch,
        );
      }
    });

    if (createdCount > 0) {
      final rules = await _db.getRecurringRules();
      for (final rule in rules) {
        if (!rule.isActive || rule.isDeleted) continue;
        final nextDueDate = DateTime.fromMillisecondsSinceEpoch(
          rule.nextDueDate,
        );
        if (nextDueDate.isBefore(DateTime.now())) continue;
        final entity = rule.toEntity();
        await _scheduleBillNotificationIfEnabled(entity);
      }
    }

    return createdCount;
  }

  DateTime _advanceDate(DateTime date, RecurringFrequency frequency) {
    switch (frequency) {
      case RecurringFrequency.daily:
        return date.add(const Duration(days: 1));
      case RecurringFrequency.weekly:
        return date.add(const Duration(days: 7));
      case RecurringFrequency.monthly:
        return DateTime(date.year, date.month + 1, date.day);
      case RecurringFrequency.yearly:
        return DateTime(date.year + 1, date.month, date.day);
    }
  }
}

final recurringRepositoryProvider = Provider<RecurringRepository>((ref) {
  return RecurringRepositoryImpl(ref);
});
