import 'package:freezed_annotation/freezed_annotation.dart';

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
    DateTime? lastBudgetAlertAt,
    required DateTime updatedAt,
  }) = _SettingsEntity;

  factory SettingsEntity.fromJson(Map<String, dynamic> json) =>
      _$SettingsEntityFromJson(json);
}
