import 'package:spendly/features/settings/domain/entities/settings_entity.dart';

abstract class SettingsRepository {
  Stream<SettingsEntity> watchSettings();

  Future<void> setBudget(double budget);

  Future<void> setNotificationPreferences({
    required bool budgetAlertsEnabled,
    required bool dailyReminderEnabled,
  });

  Future<void> markBudgetAlertNotified(DateTime at);

  Future<void> setPrivacyLockEnabled(bool enabled);

  Future<void> setShowAmountsEnabled(bool enabled);

  Future<String> exportJson();

  Future<void> importJson(String payload);

  Future<void> clearAllData();
}
