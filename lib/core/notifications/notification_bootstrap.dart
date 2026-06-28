import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/core/database/database_providers.dart';
import 'package:spendly/core/database/mappers.dart';
import 'package:spendly/core/notifications/local_notification_service.dart';
import 'package:spendly/features/settings/presentation/providers/settings_provider.dart';

final notificationBootstrapProvider = FutureProvider<void>((ref) async {
  final notif = ref.read(localNotificationServiceProvider);
  await notif.initialize();

  final db = ref.read(appDatabaseProvider);
  final settings = ref.read(settingsStreamProvider).valueOrNull;

  if (settings == null) return;

  // Reschedule daily reminder
  if (settings.dailyReminderEnabled) {
    final hour = settings.dailyReminderTime ~/ 60;
    final minute = settings.dailyReminderTime % 60;
    await notif.scheduleDailyReminder(hour: hour, minute: minute);
  } else {
    await notif.cancelDailyReminder();
  }

  // Reschedule recurring bill reminders
  if (settings.recurringBillRemindersEnabled) {
    final rules = await db.getRecurringRules();
    final now = DateTime.now();
    for (final rule in rules) {
      if (!rule.isActive || rule.isDeleted) continue;
      final nextDue = DateTime.fromMillisecondsSinceEpoch(rule.nextDueDate);
      if (nextDue.isBefore(now)) continue;
      final entity = rule.toEntity();
      await notif.scheduleRecurringBillReminder(
        ruleId: entity.id,
        title: entity.title,
        amount: entity.amount,
        nextDueDate: entity.nextDueDate,
      );
    }
  }

  // Reschedule lend/borrow due reminders
  if (settings.lendDueRemindersEnabled) {
    final entries = await db.getLendEntries();
    final now = DateTime.now();
    for (final entry in entries) {
      if (entry.isDeleted || entry.isSettled || entry.dueDate == null) continue;
      final due = DateTime.fromMillisecondsSinceEpoch(entry.dueDate!);
      if (due.isBefore(now)) continue;
      final person = await db.getLendPersonById(entry.personId);
      if (person == null || person.isDeleted) continue;
      final entity = entry.toEntity();
      await notif.scheduleLendDueReminder(
        entryId: entity.id,
        personName: person.name,
        entryType: entity.type,
        amount: entity.amount,
        dueDate: entity.dueDate!,
      );
    }
  }

  // Reschedule goal reminders
  if (settings.goalRemindersEnabled) {
    final funds = await db.getGoalFunds();
    final now = DateTime.now();
    for (final fund in funds) {
      if (fund.isDeleted) continue;
      final targetDate = DateTime.fromMillisecondsSinceEpoch(fund.targetDate);
      if (targetDate.isBefore(now)) continue;
      await notif.scheduleGoalReminder(
        goalId: fund.id,
        title: fund.title,
        targetDate: targetDate,
      );
    }
  }
});
