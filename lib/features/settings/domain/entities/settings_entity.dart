import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:spendly/core/constants/app_enums.dart';

part 'settings_entity.freezed.dart';
part 'settings_entity.g.dart';

@freezed
class SettingsEntity with _$SettingsEntity {
  const factory SettingsEntity({
    @Default(1) int id,
    @Default(0) double monthlyBudget,
    @Default('INR') String currency,
    @Default(false) bool budgetAlertsEnabled,
    @Default(false) bool dailyReminderEnabled,
    @Default(false) bool privacyLockEnabled,
    @Default(true) bool showAmountsEnabled,
    @Default(AppThemeMode.system) AppThemeMode themeMode,
    DateTime? lastBudgetAlertAt,
    required DateTime updatedAt,
  }) = _SettingsEntity;

  factory SettingsEntity.fromJson(Map<String, dynamic> json) =>
      _$SettingsEntityFromJson(json);
}
