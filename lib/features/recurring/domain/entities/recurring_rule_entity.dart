import 'package:spendly/core/constants/app_enums.dart';

class RecurringRuleEntity {
  const RecurringRuleEntity({
    required this.id,
    required this.title,
    required this.type,
    required this.amount,
    required this.categoryId,
    required this.paymentMode,
    this.cardType,
    required this.frequency,
    this.note,
    required this.startDate,
    required this.nextDueDate,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.isDeleted = false,
  });

  final String id;
  final String title;
  final TransactionType type;
  final double amount;
  final String categoryId;
  final PaymentMode paymentMode;
  final CardType? cardType;
  final RecurringFrequency frequency;
  final String? note;
  final DateTime startDate;
  final DateTime nextDueDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final bool isDeleted;

  double get monthlyAmount => frequency.monthlyEquivalent(amount);

  RecurringRuleEntity copyWith({
    String? id,
    String? title,
    TransactionType? type,
    double? amount,
    String? categoryId,
    PaymentMode? paymentMode,
    CardType? cardType,
    RecurringFrequency? frequency,
    String? note,
    DateTime? startDate,
    DateTime? nextDueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    bool? isDeleted,
  }) {
    return RecurringRuleEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      paymentMode: paymentMode ?? this.paymentMode,
      cardType: cardType ?? this.cardType,
      frequency: frequency ?? this.frequency,
      note: note ?? this.note,
      startDate: startDate ?? this.startDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.value,
      'amount': amount,
      'categoryId': categoryId,
      'paymentMode': paymentMode.value,
      'cardType': cardType?.value,
      'frequency': frequency.value,
      'note': note,
      'startDate': startDate.toIso8601String(),
      'nextDueDate': nextDueDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
      'isDeleted': isDeleted,
    };
  }

  factory RecurringRuleEntity.fromJson(Map<String, dynamic> json) {
    return RecurringRuleEntity(
      id: json['id'] as String,
      title: json['title'] as String,
      type: TransactionTypeX.fromValue(
        (json['type'] as String?) ?? TransactionType.expense.value,
      ),
      amount: (json['amount'] as num).toDouble(),
      categoryId: json['categoryId'] as String,
      paymentMode: PaymentModeX.fromValue(json['paymentMode'] as String),
      cardType: (json['cardType'] as String?) == null
          ? null
          : CardTypeX.fromValue(json['cardType'] as String),
      frequency: RecurringFrequencyX.fromValue(json['frequency'] as String),
      note: json['note'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      nextDueDate: DateTime.parse(json['nextDueDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }
}
