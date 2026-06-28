// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SettingsEntityImpl _$$SettingsEntityImplFromJson(Map<String, dynamic> json) =>
    _$SettingsEntityImpl(
      id: (json['id'] as num?)?.toInt() ?? 1,
      monthlyBudget: (json['monthlyBudget'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'INR',
      budgetAlertsEnabled: json['budgetAlertsEnabled'] as bool? ?? false,
      dailyReminderEnabled: json['dailyReminderEnabled'] as bool? ?? false,
      dailyReminderTime: (json['dailyReminderTime'] as num?)?.toInt() ?? 1200,
      recurringBillRemindersEnabled:
          json['recurringBillRemindersEnabled'] as bool? ?? false,
      lendDueRemindersEnabled:
          json['lendDueRemindersEnabled'] as bool? ?? false,
      goalRemindersEnabled: json['goalRemindersEnabled'] as bool? ?? false,
      privacyLockEnabled: json['privacyLockEnabled'] as bool? ?? false,
      showAmountsEnabled: json['showAmountsEnabled'] as bool? ?? true,
      themeMode:
          $enumDecodeNullable(_$AppThemeModeEnumMap, json['themeMode']) ??
          AppThemeMode.system,
      lastBudgetAlertAt: json['lastBudgetAlertAt'] == null
          ? null
          : DateTime.parse(json['lastBudgetAlertAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$SettingsEntityImplToJson(
  _$SettingsEntityImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'monthlyBudget': instance.monthlyBudget,
  'currency': instance.currency,
  'budgetAlertsEnabled': instance.budgetAlertsEnabled,
  'dailyReminderEnabled': instance.dailyReminderEnabled,
  'dailyReminderTime': instance.dailyReminderTime,
  'recurringBillRemindersEnabled': instance.recurringBillRemindersEnabled,
  'lendDueRemindersEnabled': instance.lendDueRemindersEnabled,
  'goalRemindersEnabled': instance.goalRemindersEnabled,
  'privacyLockEnabled': instance.privacyLockEnabled,
  'showAmountsEnabled': instance.showAmountsEnabled,
  'themeMode': _$AppThemeModeEnumMap[instance.themeMode]!,
  'lastBudgetAlertAt': instance.lastBudgetAlertAt?.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$AppThemeModeEnumMap = {
  AppThemeMode.system: 'system',
  AppThemeMode.light: 'light',
  AppThemeMode.dark: 'dark',
};
