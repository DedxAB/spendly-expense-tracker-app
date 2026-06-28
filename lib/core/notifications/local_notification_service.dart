import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/core/constants/app_enums.dart';
import 'package:spendly/core/utils/formatters.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int _dailyReminderId = 9001;
  static const int _budgetAlertId = 9002;
  static const int _recurringBillBase = 10000;
  static const int _lendDueBase = 20000;
  static const int _goalBase = 30000;
  static const int _idRange = 10000;

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    tz.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(settings);
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    _initialized = true;
  }

  int _billId(String ruleId) =>
      _recurringBillBase + (ruleId.hashCode.abs() % _idRange);

  int _lendId(String entryId) =>
      _lendDueBase + (entryId.hashCode.abs() % _idRange);

  int _goalId(String goalId) =>
      _goalBase + (goalId.hashCode.abs() % _idRange);

  // ─── Daily Reminder ────────────────────────────────────────

  Future<void> scheduleDailyReminder({int hour = 20, int minute = 0}) async {
    await initialize();
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    await _plugin.zonedSchedule(
      _dailyReminderId,
      'Daily spending check-in',
      'Take 20 seconds to log today\'s spending in Spendly.',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder_channel',
          'Daily reminders',
          channelDescription: 'Daily app reminder notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelDailyReminder() {
    return _plugin.cancel(_dailyReminderId);
  }

  // ─── Budget Alert ──────────────────────────────────────────

  Future<void> showBudgetAlert(double overBy) async {
    await initialize();
    await _plugin.show(
      _budgetAlertId,
      'Budget exceeded',
      'You are over budget by ${Formatters.currency(overBy)} this month.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'budget_alert_channel',
          'Budget alerts',
          channelDescription: 'Budget threshold notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  // ─── Recurring Bill Reminder ───────────────────────────────

  Future<void> scheduleRecurringBillReminder({
    required String ruleId,
    required String title,
    required double amount,
    required DateTime nextDueDate,
  }) async {
    await initialize();
    final scheduled = tz.TZDateTime.from(nextDueDate, tz.local);
    final now = tz.TZDateTime.now(tz.local);
    if (scheduled.isBefore(now)) return;

    await _plugin.zonedSchedule(
      _billId(ruleId),
      'Bill due: $title',
      '${Formatters.currency(amount)} is due today.',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'recurring_bill_channel',
          'Recurring bills',
          channelDescription: 'Recurring bill due date reminders',
          importance: Importance.high,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
    );
  }

  Future<void> cancelRecurringBillReminder(String ruleId) async {
    await _plugin.cancel(_billId(ruleId));
  }

  Future<void> rescheduleRecurringBillReminder({
    required String ruleId,
    required String title,
    required double amount,
    required DateTime nextDueDate,
  }) async {
    await cancelRecurringBillReminder(ruleId);
    await scheduleRecurringBillReminder(
      ruleId: ruleId,
      title: title,
      amount: amount,
      nextDueDate: nextDueDate,
    );
  }

  // ─── Lend / Borrow Due Reminder ────────────────────────────

  Future<void> scheduleLendDueReminder({
    required String entryId,
    required String personName,
    required LendEntryType entryType,
    required double amount,
    required DateTime dueDate,
  }) async {
    await initialize();
    final scheduled = tz.TZDateTime.from(dueDate, tz.local);
    final now = tz.TZDateTime.now(tz.local);
    if (scheduled.isBefore(now)) return;

    final prefix = entryType == LendEntryType.lent ? 'Lent to' : 'Borrowed from';
    await _plugin.zonedSchedule(
      _lendId(entryId),
      '$prefix $personName',
      '${Formatters.currency(amount)} is due today.',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'lend_due_channel',
          'Lend / borrow reminders',
          channelDescription: 'Lend and borrow due date reminders',
          importance: Importance.high,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
    );
  }

  Future<void> cancelLendDueReminder(String entryId) async {
    await _plugin.cancel(_lendId(entryId));
  }

  Future<void> rescheduleLendDueReminder({
    required String entryId,
    required String personName,
    required LendEntryType entryType,
    required double amount,
    required DateTime dueDate,
  }) async {
    await cancelLendDueReminder(entryId);
    await scheduleLendDueReminder(
      entryId: entryId,
      personName: personName,
      entryType: entryType,
      amount: amount,
      dueDate: dueDate,
    );
  }

  // ─── Goal Reminder ─────────────────────────────────────────

  Future<void> scheduleGoalReminder({
    required String goalId,
    required String title,
    required DateTime targetDate,
  }) async {
    await initialize();
    final scheduled = tz.TZDateTime.from(targetDate, tz.local);
    final now = tz.TZDateTime.now(tz.local);
    if (scheduled.isBefore(now)) return;

    await _plugin.zonedSchedule(
      _goalId(goalId),
      'Goal target: $title',
      'Your savings goal target date is today.',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'goal_channel',
          'Goal reminders',
          channelDescription: 'Savings goal target date reminders',
          importance: Importance.high,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
    );
  }

  Future<void> cancelGoalReminder(String goalId) async {
    await _plugin.cancel(_goalId(goalId));
  }

  Future<void> rescheduleGoalReminder({
    required String goalId,
    required String title,
    required DateTime targetDate,
  }) async {
    await cancelGoalReminder(goalId);
    await scheduleGoalReminder(
      goalId: goalId,
      title: title,
      targetDate: targetDate,
    );
  }

  // ─── Bulk Operations ───────────────────────────────────────

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
    _initialized = false;
  }
}

final localNotificationServiceProvider = Provider<LocalNotificationService>((ref) {
  return LocalNotificationService();
});
