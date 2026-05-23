// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SettingsEntity _$SettingsEntityFromJson(Map<String, dynamic> json) {
  return _SettingsEntity.fromJson(json);
}

/// @nodoc
mixin _$SettingsEntity {
  int get id => throw _privateConstructorUsedError;
  double get monthlyBudget => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  bool get budgetAlertsEnabled => throw _privateConstructorUsedError;
  bool get dailyReminderEnabled => throw _privateConstructorUsedError;
  bool get privacyLockEnabled => throw _privateConstructorUsedError;
  DateTime? get lastBudgetAlertAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this SettingsEntity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SettingsEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SettingsEntityCopyWith<SettingsEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SettingsEntityCopyWith<$Res> {
  factory $SettingsEntityCopyWith(
    SettingsEntity value,
    $Res Function(SettingsEntity) then,
  ) = _$SettingsEntityCopyWithImpl<$Res, SettingsEntity>;
  @useResult
  $Res call({
    int id,
    double monthlyBudget,
    String currency,
    bool budgetAlertsEnabled,
    bool dailyReminderEnabled,
    bool privacyLockEnabled,
    DateTime? lastBudgetAlertAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$SettingsEntityCopyWithImpl<$Res, $Val extends SettingsEntity>
    implements $SettingsEntityCopyWith<$Res> {
  _$SettingsEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SettingsEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? monthlyBudget = null,
    Object? currency = null,
    Object? budgetAlertsEnabled = null,
    Object? dailyReminderEnabled = null,
    Object? privacyLockEnabled = null,
    Object? lastBudgetAlertAt = freezed,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            monthlyBudget: null == monthlyBudget
                ? _value.monthlyBudget
                : monthlyBudget // ignore: cast_nullable_to_non_nullable
                      as double,
            currency: null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as String,
            budgetAlertsEnabled: null == budgetAlertsEnabled
                ? _value.budgetAlertsEnabled
                : budgetAlertsEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            dailyReminderEnabled: null == dailyReminderEnabled
                ? _value.dailyReminderEnabled
                : dailyReminderEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            privacyLockEnabled: null == privacyLockEnabled
                ? _value.privacyLockEnabled
                : privacyLockEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            lastBudgetAlertAt: freezed == lastBudgetAlertAt
                ? _value.lastBudgetAlertAt
                : lastBudgetAlertAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SettingsEntityImplCopyWith<$Res>
    implements $SettingsEntityCopyWith<$Res> {
  factory _$$SettingsEntityImplCopyWith(
    _$SettingsEntityImpl value,
    $Res Function(_$SettingsEntityImpl) then,
  ) = __$$SettingsEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    double monthlyBudget,
    String currency,
    bool budgetAlertsEnabled,
    bool dailyReminderEnabled,
    bool privacyLockEnabled,
    DateTime? lastBudgetAlertAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$SettingsEntityImplCopyWithImpl<$Res>
    extends _$SettingsEntityCopyWithImpl<$Res, _$SettingsEntityImpl>
    implements _$$SettingsEntityImplCopyWith<$Res> {
  __$$SettingsEntityImplCopyWithImpl(
    _$SettingsEntityImpl _value,
    $Res Function(_$SettingsEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SettingsEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? monthlyBudget = null,
    Object? currency = null,
    Object? budgetAlertsEnabled = null,
    Object? dailyReminderEnabled = null,
    Object? privacyLockEnabled = null,
    Object? lastBudgetAlertAt = freezed,
    Object? updatedAt = null,
  }) {
    return _then(
      _$SettingsEntityImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        monthlyBudget: null == monthlyBudget
            ? _value.monthlyBudget
            : monthlyBudget // ignore: cast_nullable_to_non_nullable
                  as double,
        currency: null == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as String,
        budgetAlertsEnabled: null == budgetAlertsEnabled
            ? _value.budgetAlertsEnabled
            : budgetAlertsEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        dailyReminderEnabled: null == dailyReminderEnabled
            ? _value.dailyReminderEnabled
            : dailyReminderEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        privacyLockEnabled: null == privacyLockEnabled
            ? _value.privacyLockEnabled
            : privacyLockEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        lastBudgetAlertAt: freezed == lastBudgetAlertAt
            ? _value.lastBudgetAlertAt
            : lastBudgetAlertAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SettingsEntityImpl implements _SettingsEntity {
  const _$SettingsEntityImpl({
    this.id = 1,
    this.monthlyBudget = 0,
    this.currency = 'INR',
    this.budgetAlertsEnabled = false,
    this.dailyReminderEnabled = false,
    this.privacyLockEnabled = false,
    this.lastBudgetAlertAt,
    required this.updatedAt,
  });

  factory _$SettingsEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$SettingsEntityImplFromJson(json);

  @override
  @JsonKey()
  final int id;
  @override
  @JsonKey()
  final double monthlyBudget;
  @override
  @JsonKey()
  final String currency;
  @override
  @JsonKey()
  final bool budgetAlertsEnabled;
  @override
  @JsonKey()
  final bool dailyReminderEnabled;
  @override
  @JsonKey()
  final bool privacyLockEnabled;
  @override
  final DateTime? lastBudgetAlertAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'SettingsEntity(id: $id, monthlyBudget: $monthlyBudget, currency: $currency, budgetAlertsEnabled: $budgetAlertsEnabled, dailyReminderEnabled: $dailyReminderEnabled, privacyLockEnabled: $privacyLockEnabled, lastBudgetAlertAt: $lastBudgetAlertAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SettingsEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.monthlyBudget, monthlyBudget) ||
                other.monthlyBudget == monthlyBudget) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.budgetAlertsEnabled, budgetAlertsEnabled) ||
                other.budgetAlertsEnabled == budgetAlertsEnabled) &&
            (identical(other.dailyReminderEnabled, dailyReminderEnabled) ||
                other.dailyReminderEnabled == dailyReminderEnabled) &&
            (identical(other.privacyLockEnabled, privacyLockEnabled) ||
                other.privacyLockEnabled == privacyLockEnabled) &&
            (identical(other.lastBudgetAlertAt, lastBudgetAlertAt) ||
                other.lastBudgetAlertAt == lastBudgetAlertAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    monthlyBudget,
    currency,
    budgetAlertsEnabled,
    dailyReminderEnabled,
    privacyLockEnabled,
    lastBudgetAlertAt,
    updatedAt,
  );

  /// Create a copy of SettingsEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SettingsEntityImplCopyWith<_$SettingsEntityImpl> get copyWith =>
      __$$SettingsEntityImplCopyWithImpl<_$SettingsEntityImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SettingsEntityImplToJson(this);
  }
}

abstract class _SettingsEntity implements SettingsEntity {
  const factory _SettingsEntity({
    final int id,
    final double monthlyBudget,
    final String currency,
    final bool budgetAlertsEnabled,
    final bool dailyReminderEnabled,
    final bool privacyLockEnabled,
    final DateTime? lastBudgetAlertAt,
    required final DateTime updatedAt,
  }) = _$SettingsEntityImpl;

  factory _SettingsEntity.fromJson(Map<String, dynamic> json) =
      _$SettingsEntityImpl.fromJson;

  @override
  int get id;
  @override
  double get monthlyBudget;
  @override
  String get currency;
  @override
  bool get budgetAlertsEnabled;
  @override
  bool get dailyReminderEnabled;
  @override
  bool get privacyLockEnabled;
  @override
  DateTime? get lastBudgetAlertAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of SettingsEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SettingsEntityImplCopyWith<_$SettingsEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
