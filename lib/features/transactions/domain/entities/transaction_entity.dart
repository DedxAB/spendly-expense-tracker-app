import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:spendly/core/constants/app_enums.dart';

part 'transaction_entity.freezed.dart';
part 'transaction_entity.g.dart';

@freezed
class TransactionEntity with _$TransactionEntity {
  const factory TransactionEntity({
    required String id,
    required TransactionType type,
    required double amount,
    required String categoryId,
    required PaymentMode paymentMode,
    CardType? cardType,
    String? note,
    required DateTime date,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? recurringRuleId,
    @Default(false) bool isRecurringInstance,
    @Default(false) bool isDeleted,
    @Default(0) double recoveredAmount,
  }) = _TransactionEntity;

  factory TransactionEntity.fromJson(Map<String, dynamic> json) =>
      _$TransactionEntityFromJson(json);
}
