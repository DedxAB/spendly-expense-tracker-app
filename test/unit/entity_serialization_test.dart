import 'package:flutter_test/flutter_test.dart';
import 'package:spendly/core/constants/app_enums.dart';
import 'package:spendly/features/transactions/domain/entities/transaction_entity.dart';

void main() {
  test('TransactionEntity json round-trip', () {
    final now = DateTime.now();
    final entity = TransactionEntity(
      id: 'tx-1',
      type: TransactionType.expense,
      amount: 120.5,
      categoryId: 'cat_food',
      paymentMode: PaymentMode.upi,
      cardType: CardType.credit,
      note: 'Lunch',
      date: now,
      createdAt: now,
      updatedAt: now,
    );

    final json = entity.toJson();
    final decoded = TransactionEntity.fromJson(json);

    expect(decoded.id, entity.id);
    expect(decoded.amount, entity.amount);
    expect(decoded.paymentMode, PaymentMode.upi);
    expect(decoded.cardType, CardType.credit);
  });
}
