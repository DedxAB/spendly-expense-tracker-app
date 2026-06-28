import 'package:spendly/core/constants/app_enums.dart';

class LendEntryEntity {
  const LendEntryEntity({
    required this.id,
    required this.personId,
    required this.type,
    required this.amount,
    required this.date,
    this.dueDate,
    this.note,
    this.isSettled = false,
    this.settledAmount = 0,
    this.settledAt,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  final String id;
  final String personId;
  final LendEntryType type;
  final double amount;
  final DateTime date;
  final DateTime? dueDate;
  final String? note;
  final bool isSettled;
  final double settledAmount;
  final DateTime? settledAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  LendEntryEntity copyWith({
    String? id,
    String? personId,
    LendEntryType? type,
    double? amount,
    DateTime? date,
    DateTime? dueDate,
    String? note,
    bool? isSettled,
    double? settledAmount,
    DateTime? settledAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return LendEntryEntity(
      id: id ?? this.id,
      personId: personId ?? this.personId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      dueDate: dueDate ?? this.dueDate,
      note: note ?? this.note,
      isSettled: isSettled ?? this.isSettled,
      settledAmount: settledAmount ?? this.settledAmount,
      settledAt: settledAt ?? this.settledAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'personId': personId,
      'type': type.value,
      'amount': amount,
      'date': date.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'note': note,
      'isSettled': isSettled,
      'settledAmount': settledAmount,
      'settledAt': settledAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }

  factory LendEntryEntity.fromJson(Map<String, dynamic> json) {
    return LendEntryEntity(
      id: json['id'] as String,
      personId: json['personId'] as String,
      type: LendEntryTypeX.fromValue(json['type'] as String),
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.parse(json['dueDate'] as String),
      note: json['note'] as String?,
      isSettled: json['isSettled'] as bool? ?? false,
      settledAmount: (json['settledAmount'] as num?)?.toDouble() ?? 0,
      settledAt: json['settledAt'] == null
          ? null
          : DateTime.parse(json['settledAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }
}
