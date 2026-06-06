// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TransactionEntity _$TransactionEntityFromJson(Map<String, dynamic> json) {
  return _TransactionEntity.fromJson(json);
}

/// @nodoc
mixin _$TransactionEntity {
  String get id => throw _privateConstructorUsedError;
  TransactionType get type => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String get categoryId => throw _privateConstructorUsedError;
  PaymentMode get paymentMode => throw _privateConstructorUsedError;
  CardType? get cardType => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String? get recurringRuleId => throw _privateConstructorUsedError;
  bool get isRecurringInstance => throw _privateConstructorUsedError;
  bool get isDeleted => throw _privateConstructorUsedError;

  /// Serializes this TransactionEntity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TransactionEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TransactionEntityCopyWith<TransactionEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TransactionEntityCopyWith<$Res> {
  factory $TransactionEntityCopyWith(
    TransactionEntity value,
    $Res Function(TransactionEntity) then,
  ) = _$TransactionEntityCopyWithImpl<$Res, TransactionEntity>;
  @useResult
  $Res call({
    String id,
    TransactionType type,
    double amount,
    String categoryId,
    PaymentMode paymentMode,
    CardType? cardType,
    String? note,
    DateTime date,
    DateTime createdAt,
    DateTime updatedAt,
    String? recurringRuleId,
    bool isRecurringInstance,
    bool isDeleted,
  });
}

/// @nodoc
class _$TransactionEntityCopyWithImpl<$Res, $Val extends TransactionEntity>
    implements $TransactionEntityCopyWith<$Res> {
  _$TransactionEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TransactionEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? amount = null,
    Object? categoryId = null,
    Object? paymentMode = null,
    Object? cardType = freezed,
    Object? note = freezed,
    Object? date = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? recurringRuleId = freezed,
    Object? isRecurringInstance = null,
    Object? isDeleted = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as TransactionType,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            categoryId: null == categoryId
                ? _value.categoryId
                : categoryId // ignore: cast_nullable_to_non_nullable
                      as String,
            paymentMode: null == paymentMode
                ? _value.paymentMode
                : paymentMode // ignore: cast_nullable_to_non_nullable
                      as PaymentMode,
            cardType: freezed == cardType
                ? _value.cardType
                : cardType // ignore: cast_nullable_to_non_nullable
                      as CardType?,
            note: freezed == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                      as String?,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            recurringRuleId: freezed == recurringRuleId
                ? _value.recurringRuleId
                : recurringRuleId // ignore: cast_nullable_to_non_nullable
                      as String?,
            isRecurringInstance: null == isRecurringInstance
                ? _value.isRecurringInstance
                : isRecurringInstance // ignore: cast_nullable_to_non_nullable
                      as bool,
            isDeleted: null == isDeleted
                ? _value.isDeleted
                : isDeleted // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TransactionEntityImplCopyWith<$Res>
    implements $TransactionEntityCopyWith<$Res> {
  factory _$$TransactionEntityImplCopyWith(
    _$TransactionEntityImpl value,
    $Res Function(_$TransactionEntityImpl) then,
  ) = __$$TransactionEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    TransactionType type,
    double amount,
    String categoryId,
    PaymentMode paymentMode,
    CardType? cardType,
    String? note,
    DateTime date,
    DateTime createdAt,
    DateTime updatedAt,
    String? recurringRuleId,
    bool isRecurringInstance,
    bool isDeleted,
  });
}

/// @nodoc
class __$$TransactionEntityImplCopyWithImpl<$Res>
    extends _$TransactionEntityCopyWithImpl<$Res, _$TransactionEntityImpl>
    implements _$$TransactionEntityImplCopyWith<$Res> {
  __$$TransactionEntityImplCopyWithImpl(
    _$TransactionEntityImpl _value,
    $Res Function(_$TransactionEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TransactionEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? amount = null,
    Object? categoryId = null,
    Object? paymentMode = null,
    Object? cardType = freezed,
    Object? note = freezed,
    Object? date = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? recurringRuleId = freezed,
    Object? isRecurringInstance = null,
    Object? isDeleted = null,
  }) {
    return _then(
      _$TransactionEntityImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as TransactionType,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        categoryId: null == categoryId
            ? _value.categoryId
            : categoryId // ignore: cast_nullable_to_non_nullable
                  as String,
        paymentMode: null == paymentMode
            ? _value.paymentMode
            : paymentMode // ignore: cast_nullable_to_non_nullable
                  as PaymentMode,
        cardType: freezed == cardType
            ? _value.cardType
            : cardType // ignore: cast_nullable_to_non_nullable
                  as CardType?,
        note: freezed == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as String?,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        recurringRuleId: freezed == recurringRuleId
            ? _value.recurringRuleId
            : recurringRuleId // ignore: cast_nullable_to_non_nullable
                  as String?,
        isRecurringInstance: null == isRecurringInstance
            ? _value.isRecurringInstance
            : isRecurringInstance // ignore: cast_nullable_to_non_nullable
                  as bool,
        isDeleted: null == isDeleted
            ? _value.isDeleted
            : isDeleted // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TransactionEntityImpl implements _TransactionEntity {
  const _$TransactionEntityImpl({
    required this.id,
    required this.type,
    required this.amount,
    required this.categoryId,
    required this.paymentMode,
    this.cardType,
    this.note,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    this.recurringRuleId,
    this.isRecurringInstance = false,
    this.isDeleted = false,
  });

  factory _$TransactionEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$TransactionEntityImplFromJson(json);

  @override
  final String id;
  @override
  final TransactionType type;
  @override
  final double amount;
  @override
  final String categoryId;
  @override
  final PaymentMode paymentMode;
  @override
  final CardType? cardType;
  @override
  final String? note;
  @override
  final DateTime date;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final String? recurringRuleId;
  @override
  @JsonKey()
  final bool isRecurringInstance;
  @override
  @JsonKey()
  final bool isDeleted;

  @override
  String toString() {
    return 'TransactionEntity(id: $id, type: $type, amount: $amount, categoryId: $categoryId, paymentMode: $paymentMode, cardType: $cardType, note: $note, date: $date, createdAt: $createdAt, updatedAt: $updatedAt, recurringRuleId: $recurringRuleId, isRecurringInstance: $isRecurringInstance, isDeleted: $isDeleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransactionEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.paymentMode, paymentMode) ||
                other.paymentMode == paymentMode) &&
            (identical(other.cardType, cardType) ||
                other.cardType == cardType) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.recurringRuleId, recurringRuleId) ||
                other.recurringRuleId == recurringRuleId) &&
            (identical(other.isRecurringInstance, isRecurringInstance) ||
                other.isRecurringInstance == isRecurringInstance) &&
            (identical(other.isDeleted, isDeleted) ||
                other.isDeleted == isDeleted));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    type,
    amount,
    categoryId,
    paymentMode,
    cardType,
    note,
    date,
    createdAt,
    updatedAt,
    recurringRuleId,
    isRecurringInstance,
    isDeleted,
  );

  /// Create a copy of TransactionEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TransactionEntityImplCopyWith<_$TransactionEntityImpl> get copyWith =>
      __$$TransactionEntityImplCopyWithImpl<_$TransactionEntityImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TransactionEntityImplToJson(this);
  }
}

abstract class _TransactionEntity implements TransactionEntity {
  const factory _TransactionEntity({
    required final String id,
    required final TransactionType type,
    required final double amount,
    required final String categoryId,
    required final PaymentMode paymentMode,
    final CardType? cardType,
    final String? note,
    required final DateTime date,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final String? recurringRuleId,
    final bool isRecurringInstance,
    final bool isDeleted,
  }) = _$TransactionEntityImpl;

  factory _TransactionEntity.fromJson(Map<String, dynamic> json) =
      _$TransactionEntityImpl.fromJson;

  @override
  String get id;
  @override
  TransactionType get type;
  @override
  double get amount;
  @override
  String get categoryId;
  @override
  PaymentMode get paymentMode;
  @override
  CardType? get cardType;
  @override
  String? get note;
  @override
  DateTime get date;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  String? get recurringRuleId;
  @override
  bool get isRecurringInstance;
  @override
  bool get isDeleted;

  /// Create a copy of TransactionEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TransactionEntityImplCopyWith<_$TransactionEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
