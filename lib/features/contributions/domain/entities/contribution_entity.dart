class ContributionEntity {
  final String id;
  final String expenseId;
  final String personName;
  final double amount;
  final bool isSettled;
  final DateTime? settledAt;

  const ContributionEntity({
    required this.id,
    required this.expenseId,
    required this.personName,
    required this.amount,
    this.isSettled = false,
    this.settledAt,
  });

  ContributionEntity copyWith({
    String? id,
    String? expenseId,
    String? personName,
    double? amount,
    bool? isSettled,
    DateTime? settledAt,
  }) {
    return ContributionEntity(
      id: id ?? this.id,
      expenseId: expenseId ?? this.expenseId,
      personName: personName ?? this.personName,
      amount: amount ?? this.amount,
      isSettled: isSettled ?? this.isSettled,
      settledAt: settledAt ?? this.settledAt,
    );
  }
}
