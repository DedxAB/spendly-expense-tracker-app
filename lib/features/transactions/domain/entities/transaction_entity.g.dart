// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TransactionEntityImpl _$$TransactionEntityImplFromJson(
  Map<String, dynamic> json,
) => _$TransactionEntityImpl(
  id: json['id'] as String,
  type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
  amount: (json['amount'] as num).toDouble(),
  categoryId: json['categoryId'] as String,
  paymentMode: $enumDecode(_$PaymentModeEnumMap, json['paymentMode']),
  cardType: $enumDecodeNullable(_$CardTypeEnumMap, json['cardType']),
  note: json['note'] as String?,
  date: DateTime.parse(json['date'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  recurringRuleId: json['recurringRuleId'] as String?,
  isRecurringInstance: json['isRecurringInstance'] as bool? ?? false,
  isDeleted: json['isDeleted'] as bool? ?? false,
);

Map<String, dynamic> _$$TransactionEntityImplToJson(
  _$TransactionEntityImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': _$TransactionTypeEnumMap[instance.type]!,
  'amount': instance.amount,
  'categoryId': instance.categoryId,
  'paymentMode': _$PaymentModeEnumMap[instance.paymentMode]!,
  'cardType': _$CardTypeEnumMap[instance.cardType],
  'note': instance.note,
  'date': instance.date.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'recurringRuleId': instance.recurringRuleId,
  'isRecurringInstance': instance.isRecurringInstance,
  'isDeleted': instance.isDeleted,
};

const _$TransactionTypeEnumMap = {
  TransactionType.income: 'income',
  TransactionType.expense: 'expense',
  TransactionType.investment: 'investment',
};

const _$PaymentModeEnumMap = {
  PaymentMode.cash: 'cash',
  PaymentMode.upi: 'upi',
  PaymentMode.card: 'card',
};

const _$CardTypeEnumMap = {CardType.debit: 'debit', CardType.credit: 'credit'};
