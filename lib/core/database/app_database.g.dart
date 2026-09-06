// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountPaiseMeta = const VerificationMeta(
    'amountPaise',
  );
  @override
  late final GeneratedColumn<int> amountPaise = GeneratedColumn<int>(
    'amount_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentModeMeta = const VerificationMeta(
    'paymentMode',
  );
  @override
  late final GeneratedColumn<String> paymentMode = GeneratedColumn<String>(
    'payment_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cardTypeMeta = const VerificationMeta(
    'cardType',
  );
  @override
  late final GeneratedColumn<String> cardType = GeneratedColumn<String>(
    'card_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<int> date = GeneratedColumn<int>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recurringRuleIdMeta = const VerificationMeta(
    'recurringRuleId',
  );
  @override
  late final GeneratedColumn<String> recurringRuleId = GeneratedColumn<String>(
    'recurring_rule_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isRecurringInstanceMeta =
      const VerificationMeta('isRecurringInstance');
  @override
  late final GeneratedColumn<bool> isRecurringInstance = GeneratedColumn<bool>(
    'is_recurring_instance',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_recurring_instance" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    amount,
    amountPaise,
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
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Transaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('amount_paise')) {
      context.handle(
        _amountPaiseMeta,
        amountPaise.isAcceptableOrUnknown(
          data['amount_paise']!,
          _amountPaiseMeta,
        ),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('payment_mode')) {
      context.handle(
        _paymentModeMeta,
        paymentMode.isAcceptableOrUnknown(
          data['payment_mode']!,
          _paymentModeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentModeMeta);
    }
    if (data.containsKey('card_type')) {
      context.handle(
        _cardTypeMeta,
        cardType.isAcceptableOrUnknown(data['card_type']!, _cardTypeMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('recurring_rule_id')) {
      context.handle(
        _recurringRuleIdMeta,
        recurringRuleId.isAcceptableOrUnknown(
          data['recurring_rule_id']!,
          _recurringRuleIdMeta,
        ),
      );
    }
    if (data.containsKey('is_recurring_instance')) {
      context.handle(
        _isRecurringInstanceMeta,
        isRecurringInstance.isAcceptableOrUnknown(
          data['is_recurring_instance']!,
          _isRecurringInstanceMeta,
        ),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      amountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_paise'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      paymentMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_mode'],
      )!,
      cardType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_type'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}date'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      recurringRuleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurring_rule_id'],
      ),
      isRecurringInstance: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_recurring_instance'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final String id;
  final String type;
  final double amount;
  final int amountPaise;
  final String categoryId;
  final String paymentMode;
  final String? cardType;
  final String? note;
  final int date;
  final int createdAt;
  final int updatedAt;
  final String? recurringRuleId;
  final bool isRecurringInstance;
  final bool isDeleted;
  const Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.amountPaise,
    required this.categoryId,
    required this.paymentMode,
    this.cardType,
    this.note,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    this.recurringRuleId,
    required this.isRecurringInstance,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['amount'] = Variable<double>(amount);
    map['amount_paise'] = Variable<int>(amountPaise);
    map['category_id'] = Variable<String>(categoryId);
    map['payment_mode'] = Variable<String>(paymentMode);
    if (!nullToAbsent || cardType != null) {
      map['card_type'] = Variable<String>(cardType);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['date'] = Variable<int>(date);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || recurringRuleId != null) {
      map['recurring_rule_id'] = Variable<String>(recurringRuleId);
    }
    map['is_recurring_instance'] = Variable<bool>(isRecurringInstance);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      type: Value(type),
      amount: Value(amount),
      amountPaise: Value(amountPaise),
      categoryId: Value(categoryId),
      paymentMode: Value(paymentMode),
      cardType: cardType == null && nullToAbsent
          ? const Value.absent()
          : Value(cardType),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      date: Value(date),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      recurringRuleId: recurringRuleId == null && nullToAbsent
          ? const Value.absent()
          : Value(recurringRuleId),
      isRecurringInstance: Value(isRecurringInstance),
      isDeleted: Value(isDeleted),
    );
  }

  factory Transaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      amount: serializer.fromJson<double>(json['amount']),
      amountPaise: serializer.fromJson<int>(json['amountPaise']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      paymentMode: serializer.fromJson<String>(json['paymentMode']),
      cardType: serializer.fromJson<String?>(json['cardType']),
      note: serializer.fromJson<String?>(json['note']),
      date: serializer.fromJson<int>(json['date']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      recurringRuleId: serializer.fromJson<String?>(json['recurringRuleId']),
      isRecurringInstance: serializer.fromJson<bool>(
        json['isRecurringInstance'],
      ),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'amount': serializer.toJson<double>(amount),
      'amountPaise': serializer.toJson<int>(amountPaise),
      'categoryId': serializer.toJson<String>(categoryId),
      'paymentMode': serializer.toJson<String>(paymentMode),
      'cardType': serializer.toJson<String?>(cardType),
      'note': serializer.toJson<String?>(note),
      'date': serializer.toJson<int>(date),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'recurringRuleId': serializer.toJson<String?>(recurringRuleId),
      'isRecurringInstance': serializer.toJson<bool>(isRecurringInstance),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  Transaction copyWith({
    String? id,
    String? type,
    double? amount,
    int? amountPaise,
    String? categoryId,
    String? paymentMode,
    Value<String?> cardType = const Value.absent(),
    Value<String?> note = const Value.absent(),
    int? date,
    int? createdAt,
    int? updatedAt,
    Value<String?> recurringRuleId = const Value.absent(),
    bool? isRecurringInstance,
    bool? isDeleted,
  }) => Transaction(
    id: id ?? this.id,
    type: type ?? this.type,
    amount: amount ?? this.amount,
    amountPaise: amountPaise ?? this.amountPaise,
    categoryId: categoryId ?? this.categoryId,
    paymentMode: paymentMode ?? this.paymentMode,
    cardType: cardType.present ? cardType.value : this.cardType,
    note: note.present ? note.value : this.note,
    date: date ?? this.date,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    recurringRuleId: recurringRuleId.present
        ? recurringRuleId.value
        : this.recurringRuleId,
    isRecurringInstance: isRecurringInstance ?? this.isRecurringInstance,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      amount: data.amount.present ? data.amount.value : this.amount,
      amountPaise: data.amountPaise.present
          ? data.amountPaise.value
          : this.amountPaise,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      paymentMode: data.paymentMode.present
          ? data.paymentMode.value
          : this.paymentMode,
      cardType: data.cardType.present ? data.cardType.value : this.cardType,
      note: data.note.present ? data.note.value : this.note,
      date: data.date.present ? data.date.value : this.date,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      recurringRuleId: data.recurringRuleId.present
          ? data.recurringRuleId.value
          : this.recurringRuleId,
      isRecurringInstance: data.isRecurringInstance.present
          ? data.isRecurringInstance.value
          : this.isRecurringInstance,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('categoryId: $categoryId, ')
          ..write('paymentMode: $paymentMode, ')
          ..write('cardType: $cardType, ')
          ..write('note: $note, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('recurringRuleId: $recurringRuleId, ')
          ..write('isRecurringInstance: $isRecurringInstance, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    amount,
    amountPaise,
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
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.type == this.type &&
          other.amount == this.amount &&
          other.amountPaise == this.amountPaise &&
          other.categoryId == this.categoryId &&
          other.paymentMode == this.paymentMode &&
          other.cardType == this.cardType &&
          other.note == this.note &&
          other.date == this.date &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.recurringRuleId == this.recurringRuleId &&
          other.isRecurringInstance == this.isRecurringInstance &&
          other.isDeleted == this.isDeleted);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<String> id;
  final Value<String> type;
  final Value<double> amount;
  final Value<int> amountPaise;
  final Value<String> categoryId;
  final Value<String> paymentMode;
  final Value<String?> cardType;
  final Value<String?> note;
  final Value<int> date;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String?> recurringRuleId;
  final Value<bool> isRecurringInstance;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.amount = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.paymentMode = const Value.absent(),
    this.cardType = const Value.absent(),
    this.note = const Value.absent(),
    this.date = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.recurringRuleId = const Value.absent(),
    this.isRecurringInstance = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsCompanion.insert({
    required String id,
    required String type,
    required double amount,
    this.amountPaise = const Value.absent(),
    required String categoryId,
    required String paymentMode,
    this.cardType = const Value.absent(),
    this.note = const Value.absent(),
    required int date,
    required int createdAt,
    required int updatedAt,
    this.recurringRuleId = const Value.absent(),
    this.isRecurringInstance = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       amount = Value(amount),
       categoryId = Value(categoryId),
       paymentMode = Value(paymentMode),
       date = Value(date),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Transaction> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<double>? amount,
    Expression<int>? amountPaise,
    Expression<String>? categoryId,
    Expression<String>? paymentMode,
    Expression<String>? cardType,
    Expression<String>? note,
    Expression<int>? date,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? recurringRuleId,
    Expression<bool>? isRecurringInstance,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (amount != null) 'amount': amount,
      if (amountPaise != null) 'amount_paise': amountPaise,
      if (categoryId != null) 'category_id': categoryId,
      if (paymentMode != null) 'payment_mode': paymentMode,
      if (cardType != null) 'card_type': cardType,
      if (note != null) 'note': note,
      if (date != null) 'date': date,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (recurringRuleId != null) 'recurring_rule_id': recurringRuleId,
      if (isRecurringInstance != null)
        'is_recurring_instance': isRecurringInstance,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsCompanion copyWith({
    Value<String>? id,
    Value<String>? type,
    Value<double>? amount,
    Value<int>? amountPaise,
    Value<String>? categoryId,
    Value<String>? paymentMode,
    Value<String?>? cardType,
    Value<String?>? note,
    Value<int>? date,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<String?>? recurringRuleId,
    Value<bool>? isRecurringInstance,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      amountPaise: amountPaise ?? this.amountPaise,
      categoryId: categoryId ?? this.categoryId,
      paymentMode: paymentMode ?? this.paymentMode,
      cardType: cardType ?? this.cardType,
      note: note ?? this.note,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      recurringRuleId: recurringRuleId ?? this.recurringRuleId,
      isRecurringInstance: isRecurringInstance ?? this.isRecurringInstance,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (amountPaise.present) {
      map['amount_paise'] = Variable<int>(amountPaise.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (paymentMode.present) {
      map['payment_mode'] = Variable<String>(paymentMode.value);
    }
    if (cardType.present) {
      map['card_type'] = Variable<String>(cardType.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (date.present) {
      map['date'] = Variable<int>(date.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (recurringRuleId.present) {
      map['recurring_rule_id'] = Variable<String>(recurringRuleId.value);
    }
    if (isRecurringInstance.present) {
      map['is_recurring_instance'] = Variable<bool>(isRecurringInstance.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('categoryId: $categoryId, ')
          ..write('paymentMode: $paymentMode, ')
          ..write('cardType: $cardType, ')
          ..write('note: $note, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('recurringRuleId: $recurringRuleId, ')
          ..write('isRecurringInstance: $isRecurringInstance, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    icon,
    color,
    type,
    createdAt,
    updatedAt,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final String id;
  final String name;
  final String icon;
  final String color;
  final String type;
  final int createdAt;
  final int updatedAt;
  final bool isDeleted;
  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['icon'] = Variable<String>(icon);
    map['color'] = Variable<String>(color);
    map['type'] = Variable<String>(type);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      icon: Value(icon),
      color: Value(color),
      type: Value(type),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String>(json['icon']),
      color: serializer.fromJson<String>(json['color']),
      type: serializer.fromJson<String>(json['type']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String>(icon),
      'color': serializer.toJson<String>(color),
      'type': serializer.toJson<String>(type),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  Category copyWith({
    String? id,
    String? name,
    String? icon,
    String? color,
    String? type,
    int? createdAt,
    int? updatedAt,
    bool? isDeleted,
  }) => Category(
    id: id ?? this.id,
    name: name ?? this.name,
    icon: icon ?? this.icon,
    color: color ?? this.color,
    type: type ?? this.type,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      type: data.type.present ? data.type.value : this.type,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('type: $type, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, icon, color, type, createdAt, updatedAt, isDeleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.type == this.type &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> icon;
  final Value<String> color;
  final Value<String> type;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.type = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String name,
    required String icon,
    required String color,
    required String type,
    required int createdAt,
    required int updatedAt,
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       icon = Value(icon),
       color = Value(color),
       type = Value(type),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Category> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<String>? color,
    Expression<String>? type,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (type != null) 'type': type,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? icon,
    Value<String>? color,
    Value<String>? type,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('type: $type, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecurringRulesTable extends RecurringRules
    with TableInfo<$RecurringRulesTable, RecurringRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('expense'),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountPaiseMeta = const VerificationMeta(
    'amountPaise',
  );
  @override
  late final GeneratedColumn<int> amountPaise = GeneratedColumn<int>(
    'amount_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentModeMeta = const VerificationMeta(
    'paymentMode',
  );
  @override
  late final GeneratedColumn<String> paymentMode = GeneratedColumn<String>(
    'payment_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _frequencyMeta = const VerificationMeta(
    'frequency',
  );
  @override
  late final GeneratedColumn<String> frequency = GeneratedColumn<String>(
    'frequency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<int> startDate = GeneratedColumn<int>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nextDueDateMeta = const VerificationMeta(
    'nextDueDate',
  );
  @override
  late final GeneratedColumn<int> nextDueDate = GeneratedColumn<int>(
    'next_due_date',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    type,
    amount,
    amountPaise,
    categoryId,
    paymentMode,
    frequency,
    note,
    startDate,
    nextDueDate,
    createdAt,
    updatedAt,
    isActive,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecurringRule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('amount_paise')) {
      context.handle(
        _amountPaiseMeta,
        amountPaise.isAcceptableOrUnknown(
          data['amount_paise']!,
          _amountPaiseMeta,
        ),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('payment_mode')) {
      context.handle(
        _paymentModeMeta,
        paymentMode.isAcceptableOrUnknown(
          data['payment_mode']!,
          _paymentModeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentModeMeta);
    }
    if (data.containsKey('frequency')) {
      context.handle(
        _frequencyMeta,
        frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta),
      );
    } else if (isInserting) {
      context.missing(_frequencyMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('next_due_date')) {
      context.handle(
        _nextDueDateMeta,
        nextDueDate.isAcceptableOrUnknown(
          data['next_due_date']!,
          _nextDueDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nextDueDateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecurringRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringRule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      amountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_paise'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      paymentMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_mode'],
      )!,
      frequency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frequency'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_date'],
      )!,
      nextDueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_due_date'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $RecurringRulesTable createAlias(String alias) {
    return $RecurringRulesTable(attachedDatabase, alias);
  }
}

class RecurringRule extends DataClass implements Insertable<RecurringRule> {
  final String id;
  final String title;
  final String type;
  final double amount;
  final int amountPaise;
  final String categoryId;
  final String paymentMode;
  final String frequency;
  final String? note;
  final int startDate;
  final int nextDueDate;
  final int createdAt;
  final int updatedAt;
  final bool isActive;
  final bool isDeleted;
  const RecurringRule({
    required this.id,
    required this.title,
    required this.type,
    required this.amount,
    required this.amountPaise,
    required this.categoryId,
    required this.paymentMode,
    required this.frequency,
    this.note,
    required this.startDate,
    required this.nextDueDate,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['type'] = Variable<String>(type);
    map['amount'] = Variable<double>(amount);
    map['amount_paise'] = Variable<int>(amountPaise);
    map['category_id'] = Variable<String>(categoryId);
    map['payment_mode'] = Variable<String>(paymentMode);
    map['frequency'] = Variable<String>(frequency);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['start_date'] = Variable<int>(startDate);
    map['next_due_date'] = Variable<int>(nextDueDate);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['is_active'] = Variable<bool>(isActive);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  RecurringRulesCompanion toCompanion(bool nullToAbsent) {
    return RecurringRulesCompanion(
      id: Value(id),
      title: Value(title),
      type: Value(type),
      amount: Value(amount),
      amountPaise: Value(amountPaise),
      categoryId: Value(categoryId),
      paymentMode: Value(paymentMode),
      frequency: Value(frequency),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      startDate: Value(startDate),
      nextDueDate: Value(nextDueDate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isActive: Value(isActive),
      isDeleted: Value(isDeleted),
    );
  }

  factory RecurringRule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringRule(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      type: serializer.fromJson<String>(json['type']),
      amount: serializer.fromJson<double>(json['amount']),
      amountPaise: serializer.fromJson<int>(json['amountPaise']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      paymentMode: serializer.fromJson<String>(json['paymentMode']),
      frequency: serializer.fromJson<String>(json['frequency']),
      note: serializer.fromJson<String?>(json['note']),
      startDate: serializer.fromJson<int>(json['startDate']),
      nextDueDate: serializer.fromJson<int>(json['nextDueDate']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'type': serializer.toJson<String>(type),
      'amount': serializer.toJson<double>(amount),
      'amountPaise': serializer.toJson<int>(amountPaise),
      'categoryId': serializer.toJson<String>(categoryId),
      'paymentMode': serializer.toJson<String>(paymentMode),
      'frequency': serializer.toJson<String>(frequency),
      'note': serializer.toJson<String?>(note),
      'startDate': serializer.toJson<int>(startDate),
      'nextDueDate': serializer.toJson<int>(nextDueDate),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'isActive': serializer.toJson<bool>(isActive),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  RecurringRule copyWith({
    String? id,
    String? title,
    String? type,
    double? amount,
    int? amountPaise,
    String? categoryId,
    String? paymentMode,
    String? frequency,
    Value<String?> note = const Value.absent(),
    int? startDate,
    int? nextDueDate,
    int? createdAt,
    int? updatedAt,
    bool? isActive,
    bool? isDeleted,
  }) => RecurringRule(
    id: id ?? this.id,
    title: title ?? this.title,
    type: type ?? this.type,
    amount: amount ?? this.amount,
    amountPaise: amountPaise ?? this.amountPaise,
    categoryId: categoryId ?? this.categoryId,
    paymentMode: paymentMode ?? this.paymentMode,
    frequency: frequency ?? this.frequency,
    note: note.present ? note.value : this.note,
    startDate: startDate ?? this.startDate,
    nextDueDate: nextDueDate ?? this.nextDueDate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isActive: isActive ?? this.isActive,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  RecurringRule copyWithCompanion(RecurringRulesCompanion data) {
    return RecurringRule(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      type: data.type.present ? data.type.value : this.type,
      amount: data.amount.present ? data.amount.value : this.amount,
      amountPaise: data.amountPaise.present
          ? data.amountPaise.value
          : this.amountPaise,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      paymentMode: data.paymentMode.present
          ? data.paymentMode.value
          : this.paymentMode,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      note: data.note.present ? data.note.value : this.note,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      nextDueDate: data.nextDueDate.present
          ? data.nextDueDate.value
          : this.nextDueDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurringRule(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('categoryId: $categoryId, ')
          ..write('paymentMode: $paymentMode, ')
          ..write('frequency: $frequency, ')
          ..write('note: $note, ')
          ..write('startDate: $startDate, ')
          ..write('nextDueDate: $nextDueDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isActive: $isActive, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    type,
    amount,
    amountPaise,
    categoryId,
    paymentMode,
    frequency,
    note,
    startDate,
    nextDueDate,
    createdAt,
    updatedAt,
    isActive,
    isDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringRule &&
          other.id == this.id &&
          other.title == this.title &&
          other.type == this.type &&
          other.amount == this.amount &&
          other.amountPaise == this.amountPaise &&
          other.categoryId == this.categoryId &&
          other.paymentMode == this.paymentMode &&
          other.frequency == this.frequency &&
          other.note == this.note &&
          other.startDate == this.startDate &&
          other.nextDueDate == this.nextDueDate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isActive == this.isActive &&
          other.isDeleted == this.isDeleted);
}

class RecurringRulesCompanion extends UpdateCompanion<RecurringRule> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> type;
  final Value<double> amount;
  final Value<int> amountPaise;
  final Value<String> categoryId;
  final Value<String> paymentMode;
  final Value<String> frequency;
  final Value<String?> note;
  final Value<int> startDate;
  final Value<int> nextDueDate;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<bool> isActive;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const RecurringRulesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.type = const Value.absent(),
    this.amount = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.paymentMode = const Value.absent(),
    this.frequency = const Value.absent(),
    this.note = const Value.absent(),
    this.startDate = const Value.absent(),
    this.nextDueDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isActive = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecurringRulesCompanion.insert({
    required String id,
    required String title,
    this.type = const Value.absent(),
    required double amount,
    this.amountPaise = const Value.absent(),
    required String categoryId,
    required String paymentMode,
    required String frequency,
    this.note = const Value.absent(),
    required int startDate,
    required int nextDueDate,
    required int createdAt,
    required int updatedAt,
    this.isActive = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       amount = Value(amount),
       categoryId = Value(categoryId),
       paymentMode = Value(paymentMode),
       frequency = Value(frequency),
       startDate = Value(startDate),
       nextDueDate = Value(nextDueDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<RecurringRule> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? type,
    Expression<double>? amount,
    Expression<int>? amountPaise,
    Expression<String>? categoryId,
    Expression<String>? paymentMode,
    Expression<String>? frequency,
    Expression<String>? note,
    Expression<int>? startDate,
    Expression<int>? nextDueDate,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<bool>? isActive,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (type != null) 'type': type,
      if (amount != null) 'amount': amount,
      if (amountPaise != null) 'amount_paise': amountPaise,
      if (categoryId != null) 'category_id': categoryId,
      if (paymentMode != null) 'payment_mode': paymentMode,
      if (frequency != null) 'frequency': frequency,
      if (note != null) 'note': note,
      if (startDate != null) 'start_date': startDate,
      if (nextDueDate != null) 'next_due_date': nextDueDate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isActive != null) 'is_active': isActive,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecurringRulesCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? type,
    Value<double>? amount,
    Value<int>? amountPaise,
    Value<String>? categoryId,
    Value<String>? paymentMode,
    Value<String>? frequency,
    Value<String?>? note,
    Value<int>? startDate,
    Value<int>? nextDueDate,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<bool>? isActive,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return RecurringRulesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      amountPaise: amountPaise ?? this.amountPaise,
      categoryId: categoryId ?? this.categoryId,
      paymentMode: paymentMode ?? this.paymentMode,
      frequency: frequency ?? this.frequency,
      note: note ?? this.note,
      startDate: startDate ?? this.startDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (amountPaise.present) {
      map['amount_paise'] = Variable<int>(amountPaise.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (paymentMode.present) {
      map['payment_mode'] = Variable<String>(paymentMode.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(frequency.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<int>(startDate.value);
    }
    if (nextDueDate.present) {
      map['next_due_date'] = Variable<int>(nextDueDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringRulesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('categoryId: $categoryId, ')
          ..write('paymentMode: $paymentMode, ')
          ..write('frequency: $frequency, ')
          ..write('note: $note, ')
          ..write('startDate: $startDate, ')
          ..write('nextDueDate: $nextDueDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isActive: $isActive, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _monthlyBudgetMeta = const VerificationMeta(
    'monthlyBudget',
  );
  @override
  late final GeneratedColumn<double> monthlyBudget = GeneratedColumn<double>(
    'monthly_budget',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _monthlyBudgetPaiseMeta =
      const VerificationMeta('monthlyBudgetPaise');
  @override
  late final GeneratedColumn<int> monthlyBudgetPaise = GeneratedColumn<int>(
    'monthly_budget_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('INR'),
  );
  static const VerificationMeta _themeModeMeta = const VerificationMeta(
    'themeMode',
  );
  @override
  late final GeneratedColumn<String> themeMode = GeneratedColumn<String>(
    'theme_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('system'),
  );
  static const VerificationMeta _transactionHintsSeenMeta =
      const VerificationMeta('transactionHintsSeen');
  @override
  late final GeneratedColumn<bool> transactionHintsSeen = GeneratedColumn<bool>(
    'transaction_hints_seen',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("transaction_hints_seen" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _dailyReminderEnabledMeta =
      const VerificationMeta('dailyReminderEnabled');
  @override
  late final GeneratedColumn<bool> dailyReminderEnabled = GeneratedColumn<bool>(
    'daily_reminder_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("daily_reminder_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _privacyLockEnabledMeta =
      const VerificationMeta('privacyLockEnabled');
  @override
  late final GeneratedColumn<bool> privacyLockEnabled = GeneratedColumn<bool>(
    'privacy_lock_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("privacy_lock_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _preventScreenshotsEnabledMeta =
      const VerificationMeta('preventScreenshotsEnabled');
  @override
  late final GeneratedColumn<bool> preventScreenshotsEnabled =
      GeneratedColumn<bool>(
        'prevent_screenshots_enabled',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("prevent_screenshots_enabled" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _showAmountsEnabledMeta =
      const VerificationMeta('showAmountsEnabled');
  @override
  late final GeneratedColumn<bool> showAmountsEnabled = GeneratedColumn<bool>(
    'show_amounts_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("show_amounts_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _lastBudgetAlertAtMeta = const VerificationMeta(
    'lastBudgetAlertAt',
  );
  @override
  late final GeneratedColumn<int> lastBudgetAlertAt = GeneratedColumn<int>(
    'last_budget_alert_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    monthlyBudget,
    monthlyBudgetPaise,
    currency,
    themeMode,
    transactionHintsSeen,
    dailyReminderEnabled,
    privacyLockEnabled,
    preventScreenshotsEnabled,
    showAmountsEnabled,
    lastBudgetAlertAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('monthly_budget')) {
      context.handle(
        _monthlyBudgetMeta,
        monthlyBudget.isAcceptableOrUnknown(
          data['monthly_budget']!,
          _monthlyBudgetMeta,
        ),
      );
    }
    if (data.containsKey('monthly_budget_paise')) {
      context.handle(
        _monthlyBudgetPaiseMeta,
        monthlyBudgetPaise.isAcceptableOrUnknown(
          data['monthly_budget_paise']!,
          _monthlyBudgetPaiseMeta,
        ),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('theme_mode')) {
      context.handle(
        _themeModeMeta,
        themeMode.isAcceptableOrUnknown(data['theme_mode']!, _themeModeMeta),
      );
    }
    if (data.containsKey('transaction_hints_seen')) {
      context.handle(
        _transactionHintsSeenMeta,
        transactionHintsSeen.isAcceptableOrUnknown(
          data['transaction_hints_seen']!,
          _transactionHintsSeenMeta,
        ),
      );
    }
    if (data.containsKey('daily_reminder_enabled')) {
      context.handle(
        _dailyReminderEnabledMeta,
        dailyReminderEnabled.isAcceptableOrUnknown(
          data['daily_reminder_enabled']!,
          _dailyReminderEnabledMeta,
        ),
      );
    }
    if (data.containsKey('privacy_lock_enabled')) {
      context.handle(
        _privacyLockEnabledMeta,
        privacyLockEnabled.isAcceptableOrUnknown(
          data['privacy_lock_enabled']!,
          _privacyLockEnabledMeta,
        ),
      );
    }
    if (data.containsKey('prevent_screenshots_enabled')) {
      context.handle(
        _preventScreenshotsEnabledMeta,
        preventScreenshotsEnabled.isAcceptableOrUnknown(
          data['prevent_screenshots_enabled']!,
          _preventScreenshotsEnabledMeta,
        ),
      );
    }
    if (data.containsKey('show_amounts_enabled')) {
      context.handle(
        _showAmountsEnabledMeta,
        showAmountsEnabled.isAcceptableOrUnknown(
          data['show_amounts_enabled']!,
          _showAmountsEnabledMeta,
        ),
      );
    }
    if (data.containsKey('last_budget_alert_at')) {
      context.handle(
        _lastBudgetAlertAtMeta,
        lastBudgetAlertAt.isAcceptableOrUnknown(
          data['last_budget_alert_at']!,
          _lastBudgetAlertAtMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      monthlyBudget: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}monthly_budget'],
      )!,
      monthlyBudgetPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monthly_budget_paise'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      themeMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme_mode'],
      )!,
      transactionHintsSeen: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}transaction_hints_seen'],
      )!,
      dailyReminderEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}daily_reminder_enabled'],
      )!,
      privacyLockEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}privacy_lock_enabled'],
      )!,
      preventScreenshotsEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}prevent_screenshots_enabled'],
      )!,
      showAmountsEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_amounts_enabled'],
      )!,
      lastBudgetAlertAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_budget_alert_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final int id;
  final double monthlyBudget;
  final int monthlyBudgetPaise;
  final String currency;
  final String themeMode;
  final bool transactionHintsSeen;
  final bool dailyReminderEnabled;
  final bool privacyLockEnabled;
  final bool preventScreenshotsEnabled;
  final bool showAmountsEnabled;
  final int? lastBudgetAlertAt;
  final int updatedAt;
  const Setting({
    required this.id,
    required this.monthlyBudget,
    required this.monthlyBudgetPaise,
    required this.currency,
    required this.themeMode,
    required this.transactionHintsSeen,
    required this.dailyReminderEnabled,
    required this.privacyLockEnabled,
    required this.preventScreenshotsEnabled,
    required this.showAmountsEnabled,
    this.lastBudgetAlertAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['monthly_budget'] = Variable<double>(monthlyBudget);
    map['monthly_budget_paise'] = Variable<int>(monthlyBudgetPaise);
    map['currency'] = Variable<String>(currency);
    map['theme_mode'] = Variable<String>(themeMode);
    map['transaction_hints_seen'] = Variable<bool>(transactionHintsSeen);
    map['daily_reminder_enabled'] = Variable<bool>(dailyReminderEnabled);
    map['privacy_lock_enabled'] = Variable<bool>(privacyLockEnabled);
    map['prevent_screenshots_enabled'] = Variable<bool>(
      preventScreenshotsEnabled,
    );
    map['show_amounts_enabled'] = Variable<bool>(showAmountsEnabled);
    if (!nullToAbsent || lastBudgetAlertAt != null) {
      map['last_budget_alert_at'] = Variable<int>(lastBudgetAlertAt);
    }
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      id: Value(id),
      monthlyBudget: Value(monthlyBudget),
      monthlyBudgetPaise: Value(monthlyBudgetPaise),
      currency: Value(currency),
      themeMode: Value(themeMode),
      transactionHintsSeen: Value(transactionHintsSeen),
      dailyReminderEnabled: Value(dailyReminderEnabled),
      privacyLockEnabled: Value(privacyLockEnabled),
      preventScreenshotsEnabled: Value(preventScreenshotsEnabled),
      showAmountsEnabled: Value(showAmountsEnabled),
      lastBudgetAlertAt: lastBudgetAlertAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastBudgetAlertAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      id: serializer.fromJson<int>(json['id']),
      monthlyBudget: serializer.fromJson<double>(json['monthlyBudget']),
      monthlyBudgetPaise: serializer.fromJson<int>(json['monthlyBudgetPaise']),
      currency: serializer.fromJson<String>(json['currency']),
      themeMode: serializer.fromJson<String>(json['themeMode']),
      transactionHintsSeen: serializer.fromJson<bool>(
        json['transactionHintsSeen'],
      ),
      dailyReminderEnabled: serializer.fromJson<bool>(
        json['dailyReminderEnabled'],
      ),
      privacyLockEnabled: serializer.fromJson<bool>(json['privacyLockEnabled']),
      preventScreenshotsEnabled: serializer.fromJson<bool>(
        json['preventScreenshotsEnabled'],
      ),
      showAmountsEnabled: serializer.fromJson<bool>(json['showAmountsEnabled']),
      lastBudgetAlertAt: serializer.fromJson<int?>(json['lastBudgetAlertAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'monthlyBudget': serializer.toJson<double>(monthlyBudget),
      'monthlyBudgetPaise': serializer.toJson<int>(monthlyBudgetPaise),
      'currency': serializer.toJson<String>(currency),
      'themeMode': serializer.toJson<String>(themeMode),
      'transactionHintsSeen': serializer.toJson<bool>(transactionHintsSeen),
      'dailyReminderEnabled': serializer.toJson<bool>(dailyReminderEnabled),
      'privacyLockEnabled': serializer.toJson<bool>(privacyLockEnabled),
      'preventScreenshotsEnabled': serializer.toJson<bool>(
        preventScreenshotsEnabled,
      ),
      'showAmountsEnabled': serializer.toJson<bool>(showAmountsEnabled),
      'lastBudgetAlertAt': serializer.toJson<int?>(lastBudgetAlertAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  Setting copyWith({
    int? id,
    double? monthlyBudget,
    int? monthlyBudgetPaise,
    String? currency,
    String? themeMode,
    bool? transactionHintsSeen,
    bool? dailyReminderEnabled,
    bool? privacyLockEnabled,
    bool? preventScreenshotsEnabled,
    bool? showAmountsEnabled,
    Value<int?> lastBudgetAlertAt = const Value.absent(),
    int? updatedAt,
  }) => Setting(
    id: id ?? this.id,
    monthlyBudget: monthlyBudget ?? this.monthlyBudget,
    monthlyBudgetPaise: monthlyBudgetPaise ?? this.monthlyBudgetPaise,
    currency: currency ?? this.currency,
    themeMode: themeMode ?? this.themeMode,
    transactionHintsSeen: transactionHintsSeen ?? this.transactionHintsSeen,
    dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
    privacyLockEnabled: privacyLockEnabled ?? this.privacyLockEnabled,
    preventScreenshotsEnabled:
        preventScreenshotsEnabled ?? this.preventScreenshotsEnabled,
    showAmountsEnabled: showAmountsEnabled ?? this.showAmountsEnabled,
    lastBudgetAlertAt: lastBudgetAlertAt.present
        ? lastBudgetAlertAt.value
        : this.lastBudgetAlertAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      id: data.id.present ? data.id.value : this.id,
      monthlyBudget: data.monthlyBudget.present
          ? data.monthlyBudget.value
          : this.monthlyBudget,
      monthlyBudgetPaise: data.monthlyBudgetPaise.present
          ? data.monthlyBudgetPaise.value
          : this.monthlyBudgetPaise,
      currency: data.currency.present ? data.currency.value : this.currency,
      themeMode: data.themeMode.present ? data.themeMode.value : this.themeMode,
      transactionHintsSeen: data.transactionHintsSeen.present
          ? data.transactionHintsSeen.value
          : this.transactionHintsSeen,
      dailyReminderEnabled: data.dailyReminderEnabled.present
          ? data.dailyReminderEnabled.value
          : this.dailyReminderEnabled,
      privacyLockEnabled: data.privacyLockEnabled.present
          ? data.privacyLockEnabled.value
          : this.privacyLockEnabled,
      preventScreenshotsEnabled: data.preventScreenshotsEnabled.present
          ? data.preventScreenshotsEnabled.value
          : this.preventScreenshotsEnabled,
      showAmountsEnabled: data.showAmountsEnabled.present
          ? data.showAmountsEnabled.value
          : this.showAmountsEnabled,
      lastBudgetAlertAt: data.lastBudgetAlertAt.present
          ? data.lastBudgetAlertAt.value
          : this.lastBudgetAlertAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('id: $id, ')
          ..write('monthlyBudget: $monthlyBudget, ')
          ..write('monthlyBudgetPaise: $monthlyBudgetPaise, ')
          ..write('currency: $currency, ')
          ..write('themeMode: $themeMode, ')
          ..write('transactionHintsSeen: $transactionHintsSeen, ')
          ..write('dailyReminderEnabled: $dailyReminderEnabled, ')
          ..write('privacyLockEnabled: $privacyLockEnabled, ')
          ..write('preventScreenshotsEnabled: $preventScreenshotsEnabled, ')
          ..write('showAmountsEnabled: $showAmountsEnabled, ')
          ..write('lastBudgetAlertAt: $lastBudgetAlertAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    monthlyBudget,
    monthlyBudgetPaise,
    currency,
    themeMode,
    transactionHintsSeen,
    dailyReminderEnabled,
    privacyLockEnabled,
    preventScreenshotsEnabled,
    showAmountsEnabled,
    lastBudgetAlertAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting &&
          other.id == this.id &&
          other.monthlyBudget == this.monthlyBudget &&
          other.monthlyBudgetPaise == this.monthlyBudgetPaise &&
          other.currency == this.currency &&
          other.themeMode == this.themeMode &&
          other.transactionHintsSeen == this.transactionHintsSeen &&
          other.dailyReminderEnabled == this.dailyReminderEnabled &&
          other.privacyLockEnabled == this.privacyLockEnabled &&
          other.preventScreenshotsEnabled == this.preventScreenshotsEnabled &&
          other.showAmountsEnabled == this.showAmountsEnabled &&
          other.lastBudgetAlertAt == this.lastBudgetAlertAt &&
          other.updatedAt == this.updatedAt);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<int> id;
  final Value<double> monthlyBudget;
  final Value<int> monthlyBudgetPaise;
  final Value<String> currency;
  final Value<String> themeMode;
  final Value<bool> transactionHintsSeen;
  final Value<bool> dailyReminderEnabled;
  final Value<bool> privacyLockEnabled;
  final Value<bool> preventScreenshotsEnabled;
  final Value<bool> showAmountsEnabled;
  final Value<int?> lastBudgetAlertAt;
  final Value<int> updatedAt;
  const SettingsCompanion({
    this.id = const Value.absent(),
    this.monthlyBudget = const Value.absent(),
    this.monthlyBudgetPaise = const Value.absent(),
    this.currency = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.transactionHintsSeen = const Value.absent(),
    this.dailyReminderEnabled = const Value.absent(),
    this.privacyLockEnabled = const Value.absent(),
    this.preventScreenshotsEnabled = const Value.absent(),
    this.showAmountsEnabled = const Value.absent(),
    this.lastBudgetAlertAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  SettingsCompanion.insert({
    this.id = const Value.absent(),
    this.monthlyBudget = const Value.absent(),
    this.monthlyBudgetPaise = const Value.absent(),
    this.currency = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.transactionHintsSeen = const Value.absent(),
    this.dailyReminderEnabled = const Value.absent(),
    this.privacyLockEnabled = const Value.absent(),
    this.preventScreenshotsEnabled = const Value.absent(),
    this.showAmountsEnabled = const Value.absent(),
    this.lastBudgetAlertAt = const Value.absent(),
    required int updatedAt,
  }) : updatedAt = Value(updatedAt);
  static Insertable<Setting> custom({
    Expression<int>? id,
    Expression<double>? monthlyBudget,
    Expression<int>? monthlyBudgetPaise,
    Expression<String>? currency,
    Expression<String>? themeMode,
    Expression<bool>? transactionHintsSeen,
    Expression<bool>? dailyReminderEnabled,
    Expression<bool>? privacyLockEnabled,
    Expression<bool>? preventScreenshotsEnabled,
    Expression<bool>? showAmountsEnabled,
    Expression<int>? lastBudgetAlertAt,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (monthlyBudget != null) 'monthly_budget': monthlyBudget,
      if (monthlyBudgetPaise != null)
        'monthly_budget_paise': monthlyBudgetPaise,
      if (currency != null) 'currency': currency,
      if (themeMode != null) 'theme_mode': themeMode,
      if (transactionHintsSeen != null)
        'transaction_hints_seen': transactionHintsSeen,
      if (dailyReminderEnabled != null)
        'daily_reminder_enabled': dailyReminderEnabled,
      if (privacyLockEnabled != null)
        'privacy_lock_enabled': privacyLockEnabled,
      if (preventScreenshotsEnabled != null)
        'prevent_screenshots_enabled': preventScreenshotsEnabled,
      if (showAmountsEnabled != null)
        'show_amounts_enabled': showAmountsEnabled,
      if (lastBudgetAlertAt != null) 'last_budget_alert_at': lastBudgetAlertAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  SettingsCompanion copyWith({
    Value<int>? id,
    Value<double>? monthlyBudget,
    Value<int>? monthlyBudgetPaise,
    Value<String>? currency,
    Value<String>? themeMode,
    Value<bool>? transactionHintsSeen,
    Value<bool>? dailyReminderEnabled,
    Value<bool>? privacyLockEnabled,
    Value<bool>? preventScreenshotsEnabled,
    Value<bool>? showAmountsEnabled,
    Value<int?>? lastBudgetAlertAt,
    Value<int>? updatedAt,
  }) {
    return SettingsCompanion(
      id: id ?? this.id,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      monthlyBudgetPaise: monthlyBudgetPaise ?? this.monthlyBudgetPaise,
      currency: currency ?? this.currency,
      themeMode: themeMode ?? this.themeMode,
      transactionHintsSeen: transactionHintsSeen ?? this.transactionHintsSeen,
      dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
      privacyLockEnabled: privacyLockEnabled ?? this.privacyLockEnabled,
      preventScreenshotsEnabled:
          preventScreenshotsEnabled ?? this.preventScreenshotsEnabled,
      showAmountsEnabled: showAmountsEnabled ?? this.showAmountsEnabled,
      lastBudgetAlertAt: lastBudgetAlertAt ?? this.lastBudgetAlertAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (monthlyBudget.present) {
      map['monthly_budget'] = Variable<double>(monthlyBudget.value);
    }
    if (monthlyBudgetPaise.present) {
      map['monthly_budget_paise'] = Variable<int>(monthlyBudgetPaise.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (themeMode.present) {
      map['theme_mode'] = Variable<String>(themeMode.value);
    }
    if (transactionHintsSeen.present) {
      map['transaction_hints_seen'] = Variable<bool>(
        transactionHintsSeen.value,
      );
    }
    if (dailyReminderEnabled.present) {
      map['daily_reminder_enabled'] = Variable<bool>(
        dailyReminderEnabled.value,
      );
    }
    if (privacyLockEnabled.present) {
      map['privacy_lock_enabled'] = Variable<bool>(privacyLockEnabled.value);
    }
    if (preventScreenshotsEnabled.present) {
      map['prevent_screenshots_enabled'] = Variable<bool>(
        preventScreenshotsEnabled.value,
      );
    }
    if (showAmountsEnabled.present) {
      map['show_amounts_enabled'] = Variable<bool>(showAmountsEnabled.value);
    }
    if (lastBudgetAlertAt.present) {
      map['last_budget_alert_at'] = Variable<int>(lastBudgetAlertAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('id: $id, ')
          ..write('monthlyBudget: $monthlyBudget, ')
          ..write('monthlyBudgetPaise: $monthlyBudgetPaise, ')
          ..write('currency: $currency, ')
          ..write('themeMode: $themeMode, ')
          ..write('transactionHintsSeen: $transactionHintsSeen, ')
          ..write('dailyReminderEnabled: $dailyReminderEnabled, ')
          ..write('privacyLockEnabled: $privacyLockEnabled, ')
          ..write('preventScreenshotsEnabled: $preventScreenshotsEnabled, ')
          ..write('showAmountsEnabled: $showAmountsEnabled, ')
          ..write('lastBudgetAlertAt: $lastBudgetAlertAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $UserProfilesTable extends UserProfiles
    with TableInfo<$UserProfilesTable, UserProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('User'),
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _onboardingCompletedMeta =
      const VerificationMeta('onboardingCompleted');
  @override
  late final GeneratedColumn<bool> onboardingCompleted = GeneratedColumn<bool>(
    'onboarding_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("onboarding_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    imageUrl,
    email,
    phone,
    onboardingCompleted,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('onboarding_completed')) {
      context.handle(
        _onboardingCompletedMeta,
        onboardingCompleted.isAcceptableOrUnknown(
          data['onboarding_completed']!,
          _onboardingCompletedMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      onboardingCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}onboarding_completed'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UserProfilesTable createAlias(String alias) {
    return $UserProfilesTable(attachedDatabase, alias);
  }
}

class UserProfile extends DataClass implements Insertable<UserProfile> {
  final int id;
  final String name;
  final String? imageUrl;
  final String? email;
  final String? phone;
  final bool onboardingCompleted;
  final int createdAt;
  final int updatedAt;
  const UserProfile({
    required this.id,
    required this.name,
    this.imageUrl,
    this.email,
    this.phone,
    required this.onboardingCompleted,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    map['onboarding_completed'] = Variable<bool>(onboardingCompleted);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  UserProfilesCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesCompanion(
      id: Value(id),
      name: Value(name),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      onboardingCompleted: Value(onboardingCompleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfile(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      email: serializer.fromJson<String?>(json['email']),
      phone: serializer.fromJson<String?>(json['phone']),
      onboardingCompleted: serializer.fromJson<bool>(
        json['onboardingCompleted'],
      ),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'email': serializer.toJson<String?>(email),
      'phone': serializer.toJson<String?>(phone),
      'onboardingCompleted': serializer.toJson<bool>(onboardingCompleted),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  UserProfile copyWith({
    int? id,
    String? name,
    Value<String?> imageUrl = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    bool? onboardingCompleted,
    int? createdAt,
    int? updatedAt,
  }) => UserProfile(
    id: id ?? this.id,
    name: name ?? this.name,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    email: email.present ? email.value : this.email,
    phone: phone.present ? phone.value : this.phone,
    onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UserProfile copyWithCompanion(UserProfilesCompanion data) {
    return UserProfile(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      email: data.email.present ? data.email.value : this.email,
      phone: data.phone.present ? data.phone.value : this.phone,
      onboardingCompleted: data.onboardingCompleted.present
          ? data.onboardingCompleted.value
          : this.onboardingCompleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfile(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('onboardingCompleted: $onboardingCompleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    imageUrl,
    email,
    phone,
    onboardingCompleted,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfile &&
          other.id == this.id &&
          other.name == this.name &&
          other.imageUrl == this.imageUrl &&
          other.email == this.email &&
          other.phone == this.phone &&
          other.onboardingCompleted == this.onboardingCompleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UserProfilesCompanion extends UpdateCompanion<UserProfile> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> imageUrl;
  final Value<String?> email;
  final Value<String?> phone;
  final Value<bool> onboardingCompleted;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  const UserProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.onboardingCompleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  UserProfilesCompanion.insert({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.onboardingCompleted = const Value.absent(),
    required int createdAt,
    required int updatedAt,
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<UserProfile> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? imageUrl,
    Expression<String>? email,
    Expression<String>? phone,
    Expression<bool>? onboardingCompleted,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (imageUrl != null) 'image_url': imageUrl,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (onboardingCompleted != null)
        'onboarding_completed': onboardingCompleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  UserProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? imageUrl,
    Value<String?>? email,
    Value<String?>? phone,
    Value<bool>? onboardingCompleted,
    Value<int>? createdAt,
    Value<int>? updatedAt,
  }) {
    return UserProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (onboardingCompleted.present) {
      map['onboarding_completed'] = Variable<bool>(onboardingCompleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('onboardingCompleted: $onboardingCompleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $LendPeopleTable extends LendPeople
    with TableInfo<$LendPeopleTable, LendPeopleData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LendPeopleTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    createdAt,
    updatedAt,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lend_people';
  @override
  VerificationContext validateIntegrity(
    Insertable<LendPeopleData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LendPeopleData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LendPeopleData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $LendPeopleTable createAlias(String alias) {
    return $LendPeopleTable(attachedDatabase, alias);
  }
}

class LendPeopleData extends DataClass implements Insertable<LendPeopleData> {
  final String id;
  final String name;
  final int createdAt;
  final int updatedAt;
  final bool isDeleted;
  const LendPeopleData({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  LendPeopleCompanion toCompanion(bool nullToAbsent) {
    return LendPeopleCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
    );
  }

  factory LendPeopleData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LendPeopleData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  LendPeopleData copyWith({
    String? id,
    String? name,
    int? createdAt,
    int? updatedAt,
    bool? isDeleted,
  }) => LendPeopleData(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  LendPeopleData copyWithCompanion(LendPeopleCompanion data) {
    return LendPeopleData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LendPeopleData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt, updatedAt, isDeleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LendPeopleData &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted);
}

class LendPeopleCompanion extends UpdateCompanion<LendPeopleData> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const LendPeopleCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LendPeopleCompanion.insert({
    required String id,
    required String name,
    required int createdAt,
    required int updatedAt,
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LendPeopleData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LendPeopleCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return LendPeopleCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LendPeopleCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LendEntriesTable extends LendEntries
    with TableInfo<$LendEntriesTable, LendEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LendEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _personIdMeta = const VerificationMeta(
    'personId',
  );
  @override
  late final GeneratedColumn<String> personId = GeneratedColumn<String>(
    'person_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountPaiseMeta = const VerificationMeta(
    'amountPaise',
  );
  @override
  late final GeneratedColumn<int> amountPaise = GeneratedColumn<int>(
    'amount_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<int> date = GeneratedColumn<int>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSettledMeta = const VerificationMeta(
    'isSettled',
  );
  @override
  late final GeneratedColumn<bool> isSettled = GeneratedColumn<bool>(
    'is_settled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_settled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _settledAmountMeta = const VerificationMeta(
    'settledAmount',
  );
  @override
  late final GeneratedColumn<double> settledAmount = GeneratedColumn<double>(
    'settled_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _settledAmountPaiseMeta =
      const VerificationMeta('settledAmountPaise');
  @override
  late final GeneratedColumn<int> settledAmountPaise = GeneratedColumn<int>(
    'settled_amount_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _settledAtMeta = const VerificationMeta(
    'settledAt',
  );
  @override
  late final GeneratedColumn<int> settledAt = GeneratedColumn<int>(
    'settled_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    personId,
    type,
    amount,
    amountPaise,
    date,
    note,
    isSettled,
    settledAmount,
    settledAmountPaise,
    settledAt,
    createdAt,
    updatedAt,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lend_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<LendEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('person_id')) {
      context.handle(
        _personIdMeta,
        personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta),
      );
    } else if (isInserting) {
      context.missing(_personIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('amount_paise')) {
      context.handle(
        _amountPaiseMeta,
        amountPaise.isAcceptableOrUnknown(
          data['amount_paise']!,
          _amountPaiseMeta,
        ),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('is_settled')) {
      context.handle(
        _isSettledMeta,
        isSettled.isAcceptableOrUnknown(data['is_settled']!, _isSettledMeta),
      );
    }
    if (data.containsKey('settled_amount')) {
      context.handle(
        _settledAmountMeta,
        settledAmount.isAcceptableOrUnknown(
          data['settled_amount']!,
          _settledAmountMeta,
        ),
      );
    }
    if (data.containsKey('settled_amount_paise')) {
      context.handle(
        _settledAmountPaiseMeta,
        settledAmountPaise.isAcceptableOrUnknown(
          data['settled_amount_paise']!,
          _settledAmountPaiseMeta,
        ),
      );
    }
    if (data.containsKey('settled_at')) {
      context.handle(
        _settledAtMeta,
        settledAt.isAcceptableOrUnknown(data['settled_at']!, _settledAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LendEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LendEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      personId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}person_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      amountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_paise'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}date'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      isSettled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_settled'],
      )!,
      settledAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}settled_amount'],
      )!,
      settledAmountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}settled_amount_paise'],
      )!,
      settledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}settled_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $LendEntriesTable createAlias(String alias) {
    return $LendEntriesTable(attachedDatabase, alias);
  }
}

class LendEntry extends DataClass implements Insertable<LendEntry> {
  final String id;
  final String personId;
  final String type;
  final double amount;
  final int amountPaise;
  final int date;
  final String? note;
  final bool isSettled;
  final double settledAmount;
  final int settledAmountPaise;
  final int? settledAt;
  final int createdAt;
  final int updatedAt;
  final bool isDeleted;
  const LendEntry({
    required this.id,
    required this.personId,
    required this.type,
    required this.amount,
    required this.amountPaise,
    required this.date,
    this.note,
    required this.isSettled,
    required this.settledAmount,
    required this.settledAmountPaise,
    this.settledAt,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['person_id'] = Variable<String>(personId);
    map['type'] = Variable<String>(type);
    map['amount'] = Variable<double>(amount);
    map['amount_paise'] = Variable<int>(amountPaise);
    map['date'] = Variable<int>(date);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['is_settled'] = Variable<bool>(isSettled);
    map['settled_amount'] = Variable<double>(settledAmount);
    map['settled_amount_paise'] = Variable<int>(settledAmountPaise);
    if (!nullToAbsent || settledAt != null) {
      map['settled_at'] = Variable<int>(settledAt);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  LendEntriesCompanion toCompanion(bool nullToAbsent) {
    return LendEntriesCompanion(
      id: Value(id),
      personId: Value(personId),
      type: Value(type),
      amount: Value(amount),
      amountPaise: Value(amountPaise),
      date: Value(date),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      isSettled: Value(isSettled),
      settledAmount: Value(settledAmount),
      settledAmountPaise: Value(settledAmountPaise),
      settledAt: settledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(settledAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
    );
  }

  factory LendEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LendEntry(
      id: serializer.fromJson<String>(json['id']),
      personId: serializer.fromJson<String>(json['personId']),
      type: serializer.fromJson<String>(json['type']),
      amount: serializer.fromJson<double>(json['amount']),
      amountPaise: serializer.fromJson<int>(json['amountPaise']),
      date: serializer.fromJson<int>(json['date']),
      note: serializer.fromJson<String?>(json['note']),
      isSettled: serializer.fromJson<bool>(json['isSettled']),
      settledAmount: serializer.fromJson<double>(json['settledAmount']),
      settledAmountPaise: serializer.fromJson<int>(json['settledAmountPaise']),
      settledAt: serializer.fromJson<int?>(json['settledAt']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'personId': serializer.toJson<String>(personId),
      'type': serializer.toJson<String>(type),
      'amount': serializer.toJson<double>(amount),
      'amountPaise': serializer.toJson<int>(amountPaise),
      'date': serializer.toJson<int>(date),
      'note': serializer.toJson<String?>(note),
      'isSettled': serializer.toJson<bool>(isSettled),
      'settledAmount': serializer.toJson<double>(settledAmount),
      'settledAmountPaise': serializer.toJson<int>(settledAmountPaise),
      'settledAt': serializer.toJson<int?>(settledAt),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  LendEntry copyWith({
    String? id,
    String? personId,
    String? type,
    double? amount,
    int? amountPaise,
    int? date,
    Value<String?> note = const Value.absent(),
    bool? isSettled,
    double? settledAmount,
    int? settledAmountPaise,
    Value<int?> settledAt = const Value.absent(),
    int? createdAt,
    int? updatedAt,
    bool? isDeleted,
  }) => LendEntry(
    id: id ?? this.id,
    personId: personId ?? this.personId,
    type: type ?? this.type,
    amount: amount ?? this.amount,
    amountPaise: amountPaise ?? this.amountPaise,
    date: date ?? this.date,
    note: note.present ? note.value : this.note,
    isSettled: isSettled ?? this.isSettled,
    settledAmount: settledAmount ?? this.settledAmount,
    settledAmountPaise: settledAmountPaise ?? this.settledAmountPaise,
    settledAt: settledAt.present ? settledAt.value : this.settledAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  LendEntry copyWithCompanion(LendEntriesCompanion data) {
    return LendEntry(
      id: data.id.present ? data.id.value : this.id,
      personId: data.personId.present ? data.personId.value : this.personId,
      type: data.type.present ? data.type.value : this.type,
      amount: data.amount.present ? data.amount.value : this.amount,
      amountPaise: data.amountPaise.present
          ? data.amountPaise.value
          : this.amountPaise,
      date: data.date.present ? data.date.value : this.date,
      note: data.note.present ? data.note.value : this.note,
      isSettled: data.isSettled.present ? data.isSettled.value : this.isSettled,
      settledAmount: data.settledAmount.present
          ? data.settledAmount.value
          : this.settledAmount,
      settledAmountPaise: data.settledAmountPaise.present
          ? data.settledAmountPaise.value
          : this.settledAmountPaise,
      settledAt: data.settledAt.present ? data.settledAt.value : this.settledAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LendEntry(')
          ..write('id: $id, ')
          ..write('personId: $personId, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('date: $date, ')
          ..write('note: $note, ')
          ..write('isSettled: $isSettled, ')
          ..write('settledAmount: $settledAmount, ')
          ..write('settledAmountPaise: $settledAmountPaise, ')
          ..write('settledAt: $settledAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    personId,
    type,
    amount,
    amountPaise,
    date,
    note,
    isSettled,
    settledAmount,
    settledAmountPaise,
    settledAt,
    createdAt,
    updatedAt,
    isDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LendEntry &&
          other.id == this.id &&
          other.personId == this.personId &&
          other.type == this.type &&
          other.amount == this.amount &&
          other.amountPaise == this.amountPaise &&
          other.date == this.date &&
          other.note == this.note &&
          other.isSettled == this.isSettled &&
          other.settledAmount == this.settledAmount &&
          other.settledAmountPaise == this.settledAmountPaise &&
          other.settledAt == this.settledAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted);
}

class LendEntriesCompanion extends UpdateCompanion<LendEntry> {
  final Value<String> id;
  final Value<String> personId;
  final Value<String> type;
  final Value<double> amount;
  final Value<int> amountPaise;
  final Value<int> date;
  final Value<String?> note;
  final Value<bool> isSettled;
  final Value<double> settledAmount;
  final Value<int> settledAmountPaise;
  final Value<int?> settledAt;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const LendEntriesCompanion({
    this.id = const Value.absent(),
    this.personId = const Value.absent(),
    this.type = const Value.absent(),
    this.amount = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.date = const Value.absent(),
    this.note = const Value.absent(),
    this.isSettled = const Value.absent(),
    this.settledAmount = const Value.absent(),
    this.settledAmountPaise = const Value.absent(),
    this.settledAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LendEntriesCompanion.insert({
    required String id,
    required String personId,
    required String type,
    required double amount,
    this.amountPaise = const Value.absent(),
    required int date,
    this.note = const Value.absent(),
    this.isSettled = const Value.absent(),
    this.settledAmount = const Value.absent(),
    this.settledAmountPaise = const Value.absent(),
    this.settledAt = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       personId = Value(personId),
       type = Value(type),
       amount = Value(amount),
       date = Value(date),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LendEntry> custom({
    Expression<String>? id,
    Expression<String>? personId,
    Expression<String>? type,
    Expression<double>? amount,
    Expression<int>? amountPaise,
    Expression<int>? date,
    Expression<String>? note,
    Expression<bool>? isSettled,
    Expression<double>? settledAmount,
    Expression<int>? settledAmountPaise,
    Expression<int>? settledAt,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (personId != null) 'person_id': personId,
      if (type != null) 'type': type,
      if (amount != null) 'amount': amount,
      if (amountPaise != null) 'amount_paise': amountPaise,
      if (date != null) 'date': date,
      if (note != null) 'note': note,
      if (isSettled != null) 'is_settled': isSettled,
      if (settledAmount != null) 'settled_amount': settledAmount,
      if (settledAmountPaise != null)
        'settled_amount_paise': settledAmountPaise,
      if (settledAt != null) 'settled_at': settledAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LendEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? personId,
    Value<String>? type,
    Value<double>? amount,
    Value<int>? amountPaise,
    Value<int>? date,
    Value<String?>? note,
    Value<bool>? isSettled,
    Value<double>? settledAmount,
    Value<int>? settledAmountPaise,
    Value<int?>? settledAt,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return LendEntriesCompanion(
      id: id ?? this.id,
      personId: personId ?? this.personId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      amountPaise: amountPaise ?? this.amountPaise,
      date: date ?? this.date,
      note: note ?? this.note,
      isSettled: isSettled ?? this.isSettled,
      settledAmount: settledAmount ?? this.settledAmount,
      settledAmountPaise: settledAmountPaise ?? this.settledAmountPaise,
      settledAt: settledAt ?? this.settledAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (personId.present) {
      map['person_id'] = Variable<String>(personId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (amountPaise.present) {
      map['amount_paise'] = Variable<int>(amountPaise.value);
    }
    if (date.present) {
      map['date'] = Variable<int>(date.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (isSettled.present) {
      map['is_settled'] = Variable<bool>(isSettled.value);
    }
    if (settledAmount.present) {
      map['settled_amount'] = Variable<double>(settledAmount.value);
    }
    if (settledAmountPaise.present) {
      map['settled_amount_paise'] = Variable<int>(settledAmountPaise.value);
    }
    if (settledAt.present) {
      map['settled_at'] = Variable<int>(settledAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LendEntriesCompanion(')
          ..write('id: $id, ')
          ..write('personId: $personId, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('date: $date, ')
          ..write('note: $note, ')
          ..write('isSettled: $isSettled, ')
          ..write('settledAmount: $settledAmount, ')
          ..write('settledAmountPaise: $settledAmountPaise, ')
          ..write('settledAt: $settledAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LendSettlementEventsTable extends LendSettlementEvents
    with TableInfo<$LendSettlementEventsTable, LendSettlementEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LendSettlementEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entryIdMeta = const VerificationMeta(
    'entryId',
  );
  @override
  late final GeneratedColumn<String> entryId = GeneratedColumn<String>(
    'entry_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _personIdMeta = const VerificationMeta(
    'personId',
  );
  @override
  late final GeneratedColumn<String> personId = GeneratedColumn<String>(
    'person_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountPaiseMeta = const VerificationMeta(
    'amountPaise',
  );
  @override
  late final GeneratedColumn<int> amountPaise = GeneratedColumn<int>(
    'amount_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<int> date = GeneratedColumn<int>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entryId,
    personId,
    amount,
    amountPaise,
    date,
    createdAt,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lend_settlement_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<LendSettlementEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entry_id')) {
      context.handle(
        _entryIdMeta,
        entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entryIdMeta);
    }
    if (data.containsKey('person_id')) {
      context.handle(
        _personIdMeta,
        personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta),
      );
    } else if (isInserting) {
      context.missing(_personIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('amount_paise')) {
      context.handle(
        _amountPaiseMeta,
        amountPaise.isAcceptableOrUnknown(
          data['amount_paise']!,
          _amountPaiseMeta,
        ),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LendSettlementEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LendSettlementEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      entryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_id'],
      )!,
      personId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}person_id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      amountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_paise'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}date'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $LendSettlementEventsTable createAlias(String alias) {
    return $LendSettlementEventsTable(attachedDatabase, alias);
  }
}

class LendSettlementEvent extends DataClass
    implements Insertable<LendSettlementEvent> {
  final String id;
  final String entryId;
  final String personId;
  final double amount;
  final int amountPaise;
  final int date;
  final int createdAt;
  final bool isDeleted;
  const LendSettlementEvent({
    required this.id,
    required this.entryId,
    required this.personId,
    required this.amount,
    required this.amountPaise,
    required this.date,
    required this.createdAt,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entry_id'] = Variable<String>(entryId);
    map['person_id'] = Variable<String>(personId);
    map['amount'] = Variable<double>(amount);
    map['amount_paise'] = Variable<int>(amountPaise);
    map['date'] = Variable<int>(date);
    map['created_at'] = Variable<int>(createdAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  LendSettlementEventsCompanion toCompanion(bool nullToAbsent) {
    return LendSettlementEventsCompanion(
      id: Value(id),
      entryId: Value(entryId),
      personId: Value(personId),
      amount: Value(amount),
      amountPaise: Value(amountPaise),
      date: Value(date),
      createdAt: Value(createdAt),
      isDeleted: Value(isDeleted),
    );
  }

  factory LendSettlementEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LendSettlementEvent(
      id: serializer.fromJson<String>(json['id']),
      entryId: serializer.fromJson<String>(json['entryId']),
      personId: serializer.fromJson<String>(json['personId']),
      amount: serializer.fromJson<double>(json['amount']),
      amountPaise: serializer.fromJson<int>(json['amountPaise']),
      date: serializer.fromJson<int>(json['date']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entryId': serializer.toJson<String>(entryId),
      'personId': serializer.toJson<String>(personId),
      'amount': serializer.toJson<double>(amount),
      'amountPaise': serializer.toJson<int>(amountPaise),
      'date': serializer.toJson<int>(date),
      'createdAt': serializer.toJson<int>(createdAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  LendSettlementEvent copyWith({
    String? id,
    String? entryId,
    String? personId,
    double? amount,
    int? amountPaise,
    int? date,
    int? createdAt,
    bool? isDeleted,
  }) => LendSettlementEvent(
    id: id ?? this.id,
    entryId: entryId ?? this.entryId,
    personId: personId ?? this.personId,
    amount: amount ?? this.amount,
    amountPaise: amountPaise ?? this.amountPaise,
    date: date ?? this.date,
    createdAt: createdAt ?? this.createdAt,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  LendSettlementEvent copyWithCompanion(LendSettlementEventsCompanion data) {
    return LendSettlementEvent(
      id: data.id.present ? data.id.value : this.id,
      entryId: data.entryId.present ? data.entryId.value : this.entryId,
      personId: data.personId.present ? data.personId.value : this.personId,
      amount: data.amount.present ? data.amount.value : this.amount,
      amountPaise: data.amountPaise.present
          ? data.amountPaise.value
          : this.amountPaise,
      date: data.date.present ? data.date.value : this.date,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LendSettlementEvent(')
          ..write('id: $id, ')
          ..write('entryId: $entryId, ')
          ..write('personId: $personId, ')
          ..write('amount: $amount, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entryId,
    personId,
    amount,
    amountPaise,
    date,
    createdAt,
    isDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LendSettlementEvent &&
          other.id == this.id &&
          other.entryId == this.entryId &&
          other.personId == this.personId &&
          other.amount == this.amount &&
          other.amountPaise == this.amountPaise &&
          other.date == this.date &&
          other.createdAt == this.createdAt &&
          other.isDeleted == this.isDeleted);
}

class LendSettlementEventsCompanion
    extends UpdateCompanion<LendSettlementEvent> {
  final Value<String> id;
  final Value<String> entryId;
  final Value<String> personId;
  final Value<double> amount;
  final Value<int> amountPaise;
  final Value<int> date;
  final Value<int> createdAt;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const LendSettlementEventsCompanion({
    this.id = const Value.absent(),
    this.entryId = const Value.absent(),
    this.personId = const Value.absent(),
    this.amount = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.date = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LendSettlementEventsCompanion.insert({
    required String id,
    required String entryId,
    required String personId,
    required double amount,
    this.amountPaise = const Value.absent(),
    required int date,
    required int createdAt,
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       entryId = Value(entryId),
       personId = Value(personId),
       amount = Value(amount),
       date = Value(date),
       createdAt = Value(createdAt);
  static Insertable<LendSettlementEvent> custom({
    Expression<String>? id,
    Expression<String>? entryId,
    Expression<String>? personId,
    Expression<double>? amount,
    Expression<int>? amountPaise,
    Expression<int>? date,
    Expression<int>? createdAt,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entryId != null) 'entry_id': entryId,
      if (personId != null) 'person_id': personId,
      if (amount != null) 'amount': amount,
      if (amountPaise != null) 'amount_paise': amountPaise,
      if (date != null) 'date': date,
      if (createdAt != null) 'created_at': createdAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LendSettlementEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? entryId,
    Value<String>? personId,
    Value<double>? amount,
    Value<int>? amountPaise,
    Value<int>? date,
    Value<int>? createdAt,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return LendSettlementEventsCompanion(
      id: id ?? this.id,
      entryId: entryId ?? this.entryId,
      personId: personId ?? this.personId,
      amount: amount ?? this.amount,
      amountPaise: amountPaise ?? this.amountPaise,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entryId.present) {
      map['entry_id'] = Variable<String>(entryId.value);
    }
    if (personId.present) {
      map['person_id'] = Variable<String>(personId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (amountPaise.present) {
      map['amount_paise'] = Variable<int>(amountPaise.value);
    }
    if (date.present) {
      map['date'] = Variable<int>(date.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LendSettlementEventsCompanion(')
          ..write('id: $id, ')
          ..write('entryId: $entryId, ')
          ..write('personId: $personId, ')
          ..write('amount: $amount, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MonthlyReflectionsTable extends MonthlyReflections
    with TableInfo<$MonthlyReflectionsTable, MonthlyReflection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MonthlyReflectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _monthKeyMeta = const VerificationMeta(
    'monthKey',
  );
  @override
  late final GeneratedColumn<String> monthKey = GeneratedColumn<String>(
    'month_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [monthKey, note, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'monthly_reflections';
  @override
  VerificationContext validateIntegrity(
    Insertable<MonthlyReflection> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('month_key')) {
      context.handle(
        _monthKeyMeta,
        monthKey.isAcceptableOrUnknown(data['month_key']!, _monthKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_monthKeyMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    } else if (isInserting) {
      context.missing(_noteMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {monthKey};
  @override
  MonthlyReflection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MonthlyReflection(
      monthKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}month_key'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $MonthlyReflectionsTable createAlias(String alias) {
    return $MonthlyReflectionsTable(attachedDatabase, alias);
  }
}

class MonthlyReflection extends DataClass
    implements Insertable<MonthlyReflection> {
  final String monthKey;
  final String note;
  final int updatedAt;
  const MonthlyReflection({
    required this.monthKey,
    required this.note,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['month_key'] = Variable<String>(monthKey);
    map['note'] = Variable<String>(note);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  MonthlyReflectionsCompanion toCompanion(bool nullToAbsent) {
    return MonthlyReflectionsCompanion(
      monthKey: Value(monthKey),
      note: Value(note),
      updatedAt: Value(updatedAt),
    );
  }

  factory MonthlyReflection.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MonthlyReflection(
      monthKey: serializer.fromJson<String>(json['monthKey']),
      note: serializer.fromJson<String>(json['note']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'monthKey': serializer.toJson<String>(monthKey),
      'note': serializer.toJson<String>(note),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  MonthlyReflection copyWith({
    String? monthKey,
    String? note,
    int? updatedAt,
  }) => MonthlyReflection(
    monthKey: monthKey ?? this.monthKey,
    note: note ?? this.note,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  MonthlyReflection copyWithCompanion(MonthlyReflectionsCompanion data) {
    return MonthlyReflection(
      monthKey: data.monthKey.present ? data.monthKey.value : this.monthKey,
      note: data.note.present ? data.note.value : this.note,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MonthlyReflection(')
          ..write('monthKey: $monthKey, ')
          ..write('note: $note, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(monthKey, note, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MonthlyReflection &&
          other.monthKey == this.monthKey &&
          other.note == this.note &&
          other.updatedAt == this.updatedAt);
}

class MonthlyReflectionsCompanion extends UpdateCompanion<MonthlyReflection> {
  final Value<String> monthKey;
  final Value<String> note;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const MonthlyReflectionsCompanion({
    this.monthKey = const Value.absent(),
    this.note = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MonthlyReflectionsCompanion.insert({
    required String monthKey,
    required String note,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : monthKey = Value(monthKey),
       note = Value(note),
       updatedAt = Value(updatedAt);
  static Insertable<MonthlyReflection> custom({
    Expression<String>? monthKey,
    Expression<String>? note,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (monthKey != null) 'month_key': monthKey,
      if (note != null) 'note': note,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MonthlyReflectionsCompanion copyWith({
    Value<String>? monthKey,
    Value<String>? note,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return MonthlyReflectionsCompanion(
      monthKey: monthKey ?? this.monthKey,
      note: note ?? this.note,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (monthKey.present) {
      map['month_key'] = Variable<String>(monthKey.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MonthlyReflectionsCompanion(')
          ..write('monthKey: $monthKey, ')
          ..write('note: $note, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoryBudgetsTable extends CategoryBudgets
    with TableInfo<$CategoryBudgetsTable, CategoryBudget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoryBudgetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _monthKeyMeta = const VerificationMeta(
    'monthKey',
  );
  @override
  late final GeneratedColumn<String> monthKey = GeneratedColumn<String>(
    'month_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _budgetAmountMeta = const VerificationMeta(
    'budgetAmount',
  );
  @override
  late final GeneratedColumn<double> budgetAmount = GeneratedColumn<double>(
    'budget_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _budgetAmountPaiseMeta = const VerificationMeta(
    'budgetAmountPaise',
  );
  @override
  late final GeneratedColumn<int> budgetAmountPaise = GeneratedColumn<int>(
    'budget_amount_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    monthKey,
    categoryId,
    budgetAmount,
    budgetAmountPaise,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'category_budgets';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryBudget> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('month_key')) {
      context.handle(
        _monthKeyMeta,
        monthKey.isAcceptableOrUnknown(data['month_key']!, _monthKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_monthKeyMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('budget_amount')) {
      context.handle(
        _budgetAmountMeta,
        budgetAmount.isAcceptableOrUnknown(
          data['budget_amount']!,
          _budgetAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_budgetAmountMeta);
    }
    if (data.containsKey('budget_amount_paise')) {
      context.handle(
        _budgetAmountPaiseMeta,
        budgetAmountPaise.isAcceptableOrUnknown(
          data['budget_amount_paise']!,
          _budgetAmountPaiseMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {monthKey, categoryId};
  @override
  CategoryBudget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryBudget(
      monthKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}month_key'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      budgetAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}budget_amount'],
      )!,
      budgetAmountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}budget_amount_paise'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CategoryBudgetsTable createAlias(String alias) {
    return $CategoryBudgetsTable(attachedDatabase, alias);
  }
}

class CategoryBudget extends DataClass implements Insertable<CategoryBudget> {
  final String monthKey;
  final String categoryId;
  final double budgetAmount;
  final int budgetAmountPaise;
  final int updatedAt;
  const CategoryBudget({
    required this.monthKey,
    required this.categoryId,
    required this.budgetAmount,
    required this.budgetAmountPaise,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['month_key'] = Variable<String>(monthKey);
    map['category_id'] = Variable<String>(categoryId);
    map['budget_amount'] = Variable<double>(budgetAmount);
    map['budget_amount_paise'] = Variable<int>(budgetAmountPaise);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  CategoryBudgetsCompanion toCompanion(bool nullToAbsent) {
    return CategoryBudgetsCompanion(
      monthKey: Value(monthKey),
      categoryId: Value(categoryId),
      budgetAmount: Value(budgetAmount),
      budgetAmountPaise: Value(budgetAmountPaise),
      updatedAt: Value(updatedAt),
    );
  }

  factory CategoryBudget.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryBudget(
      monthKey: serializer.fromJson<String>(json['monthKey']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      budgetAmount: serializer.fromJson<double>(json['budgetAmount']),
      budgetAmountPaise: serializer.fromJson<int>(json['budgetAmountPaise']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'monthKey': serializer.toJson<String>(monthKey),
      'categoryId': serializer.toJson<String>(categoryId),
      'budgetAmount': serializer.toJson<double>(budgetAmount),
      'budgetAmountPaise': serializer.toJson<int>(budgetAmountPaise),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  CategoryBudget copyWith({
    String? monthKey,
    String? categoryId,
    double? budgetAmount,
    int? budgetAmountPaise,
    int? updatedAt,
  }) => CategoryBudget(
    monthKey: monthKey ?? this.monthKey,
    categoryId: categoryId ?? this.categoryId,
    budgetAmount: budgetAmount ?? this.budgetAmount,
    budgetAmountPaise: budgetAmountPaise ?? this.budgetAmountPaise,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CategoryBudget copyWithCompanion(CategoryBudgetsCompanion data) {
    return CategoryBudget(
      monthKey: data.monthKey.present ? data.monthKey.value : this.monthKey,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      budgetAmount: data.budgetAmount.present
          ? data.budgetAmount.value
          : this.budgetAmount,
      budgetAmountPaise: data.budgetAmountPaise.present
          ? data.budgetAmountPaise.value
          : this.budgetAmountPaise,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryBudget(')
          ..write('monthKey: $monthKey, ')
          ..write('categoryId: $categoryId, ')
          ..write('budgetAmount: $budgetAmount, ')
          ..write('budgetAmountPaise: $budgetAmountPaise, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    monthKey,
    categoryId,
    budgetAmount,
    budgetAmountPaise,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryBudget &&
          other.monthKey == this.monthKey &&
          other.categoryId == this.categoryId &&
          other.budgetAmount == this.budgetAmount &&
          other.budgetAmountPaise == this.budgetAmountPaise &&
          other.updatedAt == this.updatedAt);
}

class CategoryBudgetsCompanion extends UpdateCompanion<CategoryBudget> {
  final Value<String> monthKey;
  final Value<String> categoryId;
  final Value<double> budgetAmount;
  final Value<int> budgetAmountPaise;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const CategoryBudgetsCompanion({
    this.monthKey = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.budgetAmount = const Value.absent(),
    this.budgetAmountPaise = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoryBudgetsCompanion.insert({
    required String monthKey,
    required String categoryId,
    required double budgetAmount,
    this.budgetAmountPaise = const Value.absent(),
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : monthKey = Value(monthKey),
       categoryId = Value(categoryId),
       budgetAmount = Value(budgetAmount),
       updatedAt = Value(updatedAt);
  static Insertable<CategoryBudget> custom({
    Expression<String>? monthKey,
    Expression<String>? categoryId,
    Expression<double>? budgetAmount,
    Expression<int>? budgetAmountPaise,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (monthKey != null) 'month_key': monthKey,
      if (categoryId != null) 'category_id': categoryId,
      if (budgetAmount != null) 'budget_amount': budgetAmount,
      if (budgetAmountPaise != null) 'budget_amount_paise': budgetAmountPaise,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoryBudgetsCompanion copyWith({
    Value<String>? monthKey,
    Value<String>? categoryId,
    Value<double>? budgetAmount,
    Value<int>? budgetAmountPaise,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return CategoryBudgetsCompanion(
      monthKey: monthKey ?? this.monthKey,
      categoryId: categoryId ?? this.categoryId,
      budgetAmount: budgetAmount ?? this.budgetAmount,
      budgetAmountPaise: budgetAmountPaise ?? this.budgetAmountPaise,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (monthKey.present) {
      map['month_key'] = Variable<String>(monthKey.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (budgetAmount.present) {
      map['budget_amount'] = Variable<double>(budgetAmount.value);
    }
    if (budgetAmountPaise.present) {
      map['budget_amount_paise'] = Variable<int>(budgetAmountPaise.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoryBudgetsCompanion(')
          ..write('monthKey: $monthKey, ')
          ..write('categoryId: $categoryId, ')
          ..write('budgetAmount: $budgetAmount, ')
          ..write('budgetAmountPaise: $budgetAmountPaise, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActivityEventsTable extends ActivityEvents
    with TableInfo<$ActivityEventsTable, ActivityEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivityEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<int> occurredAt = GeneratedColumn<int>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    title,
    description,
    occurredAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activity_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActivityEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActivityEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivityEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}occurred_at'],
      )!,
    );
  }

  @override
  $ActivityEventsTable createAlias(String alias) {
    return $ActivityEventsTable(attachedDatabase, alias);
  }
}

class ActivityEvent extends DataClass implements Insertable<ActivityEvent> {
  final String id;
  final String kind;
  final String title;
  final String description;
  final int occurredAt;
  const ActivityEvent({
    required this.id,
    required this.kind,
    required this.title,
    required this.description,
    required this.occurredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['kind'] = Variable<String>(kind);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['occurred_at'] = Variable<int>(occurredAt);
    return map;
  }

  ActivityEventsCompanion toCompanion(bool nullToAbsent) {
    return ActivityEventsCompanion(
      id: Value(id),
      kind: Value(kind),
      title: Value(title),
      description: Value(description),
      occurredAt: Value(occurredAt),
    );
  }

  factory ActivityEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivityEvent(
      id: serializer.fromJson<String>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      occurredAt: serializer.fromJson<int>(json['occurredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kind': serializer.toJson<String>(kind),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'occurredAt': serializer.toJson<int>(occurredAt),
    };
  }

  ActivityEvent copyWith({
    String? id,
    String? kind,
    String? title,
    String? description,
    int? occurredAt,
  }) => ActivityEvent(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    title: title ?? this.title,
    description: description ?? this.description,
    occurredAt: occurredAt ?? this.occurredAt,
  );
  ActivityEvent copyWithCompanion(ActivityEventsCompanion data) {
    return ActivityEvent(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivityEvent(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('occurredAt: $occurredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, kind, title, description, occurredAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivityEvent &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.title == this.title &&
          other.description == this.description &&
          other.occurredAt == this.occurredAt);
}

class ActivityEventsCompanion extends UpdateCompanion<ActivityEvent> {
  final Value<String> id;
  final Value<String> kind;
  final Value<String> title;
  final Value<String> description;
  final Value<int> occurredAt;
  final Value<int> rowid;
  const ActivityEventsCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActivityEventsCompanion.insert({
    required String id,
    required String kind,
    required String title,
    required String description,
    required int occurredAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       kind = Value(kind),
       title = Value(title),
       description = Value(description),
       occurredAt = Value(occurredAt);
  static Insertable<ActivityEvent> custom({
    Expression<String>? id,
    Expression<String>? kind,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? occurredAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActivityEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? kind,
    Value<String>? title,
    Value<String>? description,
    Value<int>? occurredAt,
    Value<int>? rowid,
  }) {
    return ActivityEventsCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      description: description ?? this.description,
      occurredAt: occurredAt ?? this.occurredAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<int>(occurredAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivityEventsCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppUsageDaysTable extends AppUsageDays
    with TableInfo<$AppUsageDaysTable, AppUsageDay> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppUsageDaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateKeyMeta = const VerificationMeta(
    'dateKey',
  );
  @override
  late final GeneratedColumn<String> dateKey = GeneratedColumn<String>(
    'date_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalSecondsMeta = const VerificationMeta(
    'totalSeconds',
  );
  @override
  late final GeneratedColumn<int> totalSeconds = GeneratedColumn<int>(
    'total_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [dateKey, totalSeconds, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_usage_days';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppUsageDay> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date_key')) {
      context.handle(
        _dateKeyMeta,
        dateKey.isAcceptableOrUnknown(data['date_key']!, _dateKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_dateKeyMeta);
    }
    if (data.containsKey('total_seconds')) {
      context.handle(
        _totalSecondsMeta,
        totalSeconds.isAcceptableOrUnknown(
          data['total_seconds']!,
          _totalSecondsMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {dateKey};
  @override
  AppUsageDay map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppUsageDay(
      dateKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_key'],
      )!,
      totalSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_seconds'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AppUsageDaysTable createAlias(String alias) {
    return $AppUsageDaysTable(attachedDatabase, alias);
  }
}

class AppUsageDay extends DataClass implements Insertable<AppUsageDay> {
  final String dateKey;
  final int totalSeconds;
  final int updatedAt;
  const AppUsageDay({
    required this.dateKey,
    required this.totalSeconds,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date_key'] = Variable<String>(dateKey);
    map['total_seconds'] = Variable<int>(totalSeconds);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  AppUsageDaysCompanion toCompanion(bool nullToAbsent) {
    return AppUsageDaysCompanion(
      dateKey: Value(dateKey),
      totalSeconds: Value(totalSeconds),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppUsageDay.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppUsageDay(
      dateKey: serializer.fromJson<String>(json['dateKey']),
      totalSeconds: serializer.fromJson<int>(json['totalSeconds']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'dateKey': serializer.toJson<String>(dateKey),
      'totalSeconds': serializer.toJson<int>(totalSeconds),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  AppUsageDay copyWith({String? dateKey, int? totalSeconds, int? updatedAt}) =>
      AppUsageDay(
        dateKey: dateKey ?? this.dateKey,
        totalSeconds: totalSeconds ?? this.totalSeconds,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AppUsageDay copyWithCompanion(AppUsageDaysCompanion data) {
    return AppUsageDay(
      dateKey: data.dateKey.present ? data.dateKey.value : this.dateKey,
      totalSeconds: data.totalSeconds.present
          ? data.totalSeconds.value
          : this.totalSeconds,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppUsageDay(')
          ..write('dateKey: $dateKey, ')
          ..write('totalSeconds: $totalSeconds, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(dateKey, totalSeconds, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppUsageDay &&
          other.dateKey == this.dateKey &&
          other.totalSeconds == this.totalSeconds &&
          other.updatedAt == this.updatedAt);
}

class AppUsageDaysCompanion extends UpdateCompanion<AppUsageDay> {
  final Value<String> dateKey;
  final Value<int> totalSeconds;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const AppUsageDaysCompanion({
    this.dateKey = const Value.absent(),
    this.totalSeconds = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppUsageDaysCompanion.insert({
    required String dateKey,
    this.totalSeconds = const Value.absent(),
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : dateKey = Value(dateKey),
       updatedAt = Value(updatedAt);
  static Insertable<AppUsageDay> custom({
    Expression<String>? dateKey,
    Expression<int>? totalSeconds,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (dateKey != null) 'date_key': dateKey,
      if (totalSeconds != null) 'total_seconds': totalSeconds,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppUsageDaysCompanion copyWith({
    Value<String>? dateKey,
    Value<int>? totalSeconds,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return AppUsageDaysCompanion(
      dateKey: dateKey ?? this.dateKey,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (dateKey.present) {
      map['date_key'] = Variable<String>(dateKey.value);
    }
    if (totalSeconds.present) {
      map['total_seconds'] = Variable<int>(totalSeconds.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppUsageDaysCompanion(')
          ..write('dateKey: $dateKey, ')
          ..write('totalSeconds: $totalSeconds, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GoalFundsTable extends GoalFunds
    with TableInfo<$GoalFundsTable, GoalFund> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalFundsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetAmountMeta = const VerificationMeta(
    'targetAmount',
  );
  @override
  late final GeneratedColumn<double> targetAmount = GeneratedColumn<double>(
    'target_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetAmountPaiseMeta = const VerificationMeta(
    'targetAmountPaise',
  );
  @override
  late final GeneratedColumn<int> targetAmountPaise = GeneratedColumn<int>(
    'target_amount_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _savedAmountMeta = const VerificationMeta(
    'savedAmount',
  );
  @override
  late final GeneratedColumn<double> savedAmount = GeneratedColumn<double>(
    'saved_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _savedAmountPaiseMeta = const VerificationMeta(
    'savedAmountPaise',
  );
  @override
  late final GeneratedColumn<int> savedAmountPaise = GeneratedColumn<int>(
    'saved_amount_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _targetDateMeta = const VerificationMeta(
    'targetDate',
  );
  @override
  late final GeneratedColumn<int> targetDate = GeneratedColumn<int>(
    'target_date',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monthlyContributionMeta =
      const VerificationMeta('monthlyContribution');
  @override
  late final GeneratedColumn<double> monthlyContribution =
      GeneratedColumn<double>(
        'monthly_contribution',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _monthlyContributionPaiseMeta =
      const VerificationMeta('monthlyContributionPaise');
  @override
  late final GeneratedColumn<int> monthlyContributionPaise =
      GeneratedColumn<int>(
        'monthly_contribution_paise',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _recentDeltaMeta = const VerificationMeta(
    'recentDelta',
  );
  @override
  late final GeneratedColumn<double> recentDelta = GeneratedColumn<double>(
    'recent_delta',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _recentDeltaPaiseMeta = const VerificationMeta(
    'recentDeltaPaise',
  );
  @override
  late final GeneratedColumn<int> recentDeltaPaise = GeneratedColumn<int>(
    'recent_delta_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _monthlyExpenseMeta = const VerificationMeta(
    'monthlyExpense',
  );
  @override
  late final GeneratedColumn<double> monthlyExpense = GeneratedColumn<double>(
    'monthly_expense',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _monthlyExpensePaiseMeta =
      const VerificationMeta('monthlyExpensePaise');
  @override
  late final GeneratedColumn<int> monthlyExpensePaise = GeneratedColumn<int>(
    'monthly_expense_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isEmergencyMeta = const VerificationMeta(
    'isEmergency',
  );
  @override
  late final GeneratedColumn<bool> isEmergency = GeneratedColumn<bool>(
    'is_emergency',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_emergency" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    category,
    targetAmount,
    targetAmountPaise,
    savedAmount,
    savedAmountPaise,
    targetDate,
    monthlyContribution,
    monthlyContributionPaise,
    recentDelta,
    recentDeltaPaise,
    monthlyExpense,
    monthlyExpensePaise,
    isEmergency,
    createdAt,
    updatedAt,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goal_funds';
  @override
  VerificationContext validateIntegrity(
    Insertable<GoalFund> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('target_amount')) {
      context.handle(
        _targetAmountMeta,
        targetAmount.isAcceptableOrUnknown(
          data['target_amount']!,
          _targetAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetAmountMeta);
    }
    if (data.containsKey('target_amount_paise')) {
      context.handle(
        _targetAmountPaiseMeta,
        targetAmountPaise.isAcceptableOrUnknown(
          data['target_amount_paise']!,
          _targetAmountPaiseMeta,
        ),
      );
    }
    if (data.containsKey('saved_amount')) {
      context.handle(
        _savedAmountMeta,
        savedAmount.isAcceptableOrUnknown(
          data['saved_amount']!,
          _savedAmountMeta,
        ),
      );
    }
    if (data.containsKey('saved_amount_paise')) {
      context.handle(
        _savedAmountPaiseMeta,
        savedAmountPaise.isAcceptableOrUnknown(
          data['saved_amount_paise']!,
          _savedAmountPaiseMeta,
        ),
      );
    }
    if (data.containsKey('target_date')) {
      context.handle(
        _targetDateMeta,
        targetDate.isAcceptableOrUnknown(data['target_date']!, _targetDateMeta),
      );
    } else if (isInserting) {
      context.missing(_targetDateMeta);
    }
    if (data.containsKey('monthly_contribution')) {
      context.handle(
        _monthlyContributionMeta,
        monthlyContribution.isAcceptableOrUnknown(
          data['monthly_contribution']!,
          _monthlyContributionMeta,
        ),
      );
    }
    if (data.containsKey('monthly_contribution_paise')) {
      context.handle(
        _monthlyContributionPaiseMeta,
        monthlyContributionPaise.isAcceptableOrUnknown(
          data['monthly_contribution_paise']!,
          _monthlyContributionPaiseMeta,
        ),
      );
    }
    if (data.containsKey('recent_delta')) {
      context.handle(
        _recentDeltaMeta,
        recentDelta.isAcceptableOrUnknown(
          data['recent_delta']!,
          _recentDeltaMeta,
        ),
      );
    }
    if (data.containsKey('recent_delta_paise')) {
      context.handle(
        _recentDeltaPaiseMeta,
        recentDeltaPaise.isAcceptableOrUnknown(
          data['recent_delta_paise']!,
          _recentDeltaPaiseMeta,
        ),
      );
    }
    if (data.containsKey('monthly_expense')) {
      context.handle(
        _monthlyExpenseMeta,
        monthlyExpense.isAcceptableOrUnknown(
          data['monthly_expense']!,
          _monthlyExpenseMeta,
        ),
      );
    }
    if (data.containsKey('monthly_expense_paise')) {
      context.handle(
        _monthlyExpensePaiseMeta,
        monthlyExpensePaise.isAcceptableOrUnknown(
          data['monthly_expense_paise']!,
          _monthlyExpensePaiseMeta,
        ),
      );
    }
    if (data.containsKey('is_emergency')) {
      context.handle(
        _isEmergencyMeta,
        isEmergency.isAcceptableOrUnknown(
          data['is_emergency']!,
          _isEmergencyMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GoalFund map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GoalFund(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      targetAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_amount'],
      )!,
      targetAmountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_amount_paise'],
      )!,
      savedAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}saved_amount'],
      )!,
      savedAmountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}saved_amount_paise'],
      )!,
      targetDate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_date'],
      )!,
      monthlyContribution: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}monthly_contribution'],
      )!,
      monthlyContributionPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monthly_contribution_paise'],
      )!,
      recentDelta: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}recent_delta'],
      )!,
      recentDeltaPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recent_delta_paise'],
      )!,
      monthlyExpense: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}monthly_expense'],
      )!,
      monthlyExpensePaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monthly_expense_paise'],
      )!,
      isEmergency: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_emergency'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $GoalFundsTable createAlias(String alias) {
    return $GoalFundsTable(attachedDatabase, alias);
  }
}

class GoalFund extends DataClass implements Insertable<GoalFund> {
  final String id;
  final String title;
  final String category;
  final double targetAmount;
  final int targetAmountPaise;
  final double savedAmount;
  final int savedAmountPaise;
  final int targetDate;
  final double monthlyContribution;
  final int monthlyContributionPaise;
  final double recentDelta;
  final int recentDeltaPaise;
  final double monthlyExpense;
  final int monthlyExpensePaise;
  final bool isEmergency;
  final int createdAt;
  final int updatedAt;
  final bool isDeleted;
  const GoalFund({
    required this.id,
    required this.title,
    required this.category,
    required this.targetAmount,
    required this.targetAmountPaise,
    required this.savedAmount,
    required this.savedAmountPaise,
    required this.targetDate,
    required this.monthlyContribution,
    required this.monthlyContributionPaise,
    required this.recentDelta,
    required this.recentDeltaPaise,
    required this.monthlyExpense,
    required this.monthlyExpensePaise,
    required this.isEmergency,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['category'] = Variable<String>(category);
    map['target_amount'] = Variable<double>(targetAmount);
    map['target_amount_paise'] = Variable<int>(targetAmountPaise);
    map['saved_amount'] = Variable<double>(savedAmount);
    map['saved_amount_paise'] = Variable<int>(savedAmountPaise);
    map['target_date'] = Variable<int>(targetDate);
    map['monthly_contribution'] = Variable<double>(monthlyContribution);
    map['monthly_contribution_paise'] = Variable<int>(monthlyContributionPaise);
    map['recent_delta'] = Variable<double>(recentDelta);
    map['recent_delta_paise'] = Variable<int>(recentDeltaPaise);
    map['monthly_expense'] = Variable<double>(monthlyExpense);
    map['monthly_expense_paise'] = Variable<int>(monthlyExpensePaise);
    map['is_emergency'] = Variable<bool>(isEmergency);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  GoalFundsCompanion toCompanion(bool nullToAbsent) {
    return GoalFundsCompanion(
      id: Value(id),
      title: Value(title),
      category: Value(category),
      targetAmount: Value(targetAmount),
      targetAmountPaise: Value(targetAmountPaise),
      savedAmount: Value(savedAmount),
      savedAmountPaise: Value(savedAmountPaise),
      targetDate: Value(targetDate),
      monthlyContribution: Value(monthlyContribution),
      monthlyContributionPaise: Value(monthlyContributionPaise),
      recentDelta: Value(recentDelta),
      recentDeltaPaise: Value(recentDeltaPaise),
      monthlyExpense: Value(monthlyExpense),
      monthlyExpensePaise: Value(monthlyExpensePaise),
      isEmergency: Value(isEmergency),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
    );
  }

  factory GoalFund.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GoalFund(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      category: serializer.fromJson<String>(json['category']),
      targetAmount: serializer.fromJson<double>(json['targetAmount']),
      targetAmountPaise: serializer.fromJson<int>(json['targetAmountPaise']),
      savedAmount: serializer.fromJson<double>(json['savedAmount']),
      savedAmountPaise: serializer.fromJson<int>(json['savedAmountPaise']),
      targetDate: serializer.fromJson<int>(json['targetDate']),
      monthlyContribution: serializer.fromJson<double>(
        json['monthlyContribution'],
      ),
      monthlyContributionPaise: serializer.fromJson<int>(
        json['monthlyContributionPaise'],
      ),
      recentDelta: serializer.fromJson<double>(json['recentDelta']),
      recentDeltaPaise: serializer.fromJson<int>(json['recentDeltaPaise']),
      monthlyExpense: serializer.fromJson<double>(json['monthlyExpense']),
      monthlyExpensePaise: serializer.fromJson<int>(
        json['monthlyExpensePaise'],
      ),
      isEmergency: serializer.fromJson<bool>(json['isEmergency']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'category': serializer.toJson<String>(category),
      'targetAmount': serializer.toJson<double>(targetAmount),
      'targetAmountPaise': serializer.toJson<int>(targetAmountPaise),
      'savedAmount': serializer.toJson<double>(savedAmount),
      'savedAmountPaise': serializer.toJson<int>(savedAmountPaise),
      'targetDate': serializer.toJson<int>(targetDate),
      'monthlyContribution': serializer.toJson<double>(monthlyContribution),
      'monthlyContributionPaise': serializer.toJson<int>(
        monthlyContributionPaise,
      ),
      'recentDelta': serializer.toJson<double>(recentDelta),
      'recentDeltaPaise': serializer.toJson<int>(recentDeltaPaise),
      'monthlyExpense': serializer.toJson<double>(monthlyExpense),
      'monthlyExpensePaise': serializer.toJson<int>(monthlyExpensePaise),
      'isEmergency': serializer.toJson<bool>(isEmergency),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  GoalFund copyWith({
    String? id,
    String? title,
    String? category,
    double? targetAmount,
    int? targetAmountPaise,
    double? savedAmount,
    int? savedAmountPaise,
    int? targetDate,
    double? monthlyContribution,
    int? monthlyContributionPaise,
    double? recentDelta,
    int? recentDeltaPaise,
    double? monthlyExpense,
    int? monthlyExpensePaise,
    bool? isEmergency,
    int? createdAt,
    int? updatedAt,
    bool? isDeleted,
  }) => GoalFund(
    id: id ?? this.id,
    title: title ?? this.title,
    category: category ?? this.category,
    targetAmount: targetAmount ?? this.targetAmount,
    targetAmountPaise: targetAmountPaise ?? this.targetAmountPaise,
    savedAmount: savedAmount ?? this.savedAmount,
    savedAmountPaise: savedAmountPaise ?? this.savedAmountPaise,
    targetDate: targetDate ?? this.targetDate,
    monthlyContribution: monthlyContribution ?? this.monthlyContribution,
    monthlyContributionPaise:
        monthlyContributionPaise ?? this.monthlyContributionPaise,
    recentDelta: recentDelta ?? this.recentDelta,
    recentDeltaPaise: recentDeltaPaise ?? this.recentDeltaPaise,
    monthlyExpense: monthlyExpense ?? this.monthlyExpense,
    monthlyExpensePaise: monthlyExpensePaise ?? this.monthlyExpensePaise,
    isEmergency: isEmergency ?? this.isEmergency,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  GoalFund copyWithCompanion(GoalFundsCompanion data) {
    return GoalFund(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      category: data.category.present ? data.category.value : this.category,
      targetAmount: data.targetAmount.present
          ? data.targetAmount.value
          : this.targetAmount,
      targetAmountPaise: data.targetAmountPaise.present
          ? data.targetAmountPaise.value
          : this.targetAmountPaise,
      savedAmount: data.savedAmount.present
          ? data.savedAmount.value
          : this.savedAmount,
      savedAmountPaise: data.savedAmountPaise.present
          ? data.savedAmountPaise.value
          : this.savedAmountPaise,
      targetDate: data.targetDate.present
          ? data.targetDate.value
          : this.targetDate,
      monthlyContribution: data.monthlyContribution.present
          ? data.monthlyContribution.value
          : this.monthlyContribution,
      monthlyContributionPaise: data.monthlyContributionPaise.present
          ? data.monthlyContributionPaise.value
          : this.monthlyContributionPaise,
      recentDelta: data.recentDelta.present
          ? data.recentDelta.value
          : this.recentDelta,
      recentDeltaPaise: data.recentDeltaPaise.present
          ? data.recentDeltaPaise.value
          : this.recentDeltaPaise,
      monthlyExpense: data.monthlyExpense.present
          ? data.monthlyExpense.value
          : this.monthlyExpense,
      monthlyExpensePaise: data.monthlyExpensePaise.present
          ? data.monthlyExpensePaise.value
          : this.monthlyExpensePaise,
      isEmergency: data.isEmergency.present
          ? data.isEmergency.value
          : this.isEmergency,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GoalFund(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('category: $category, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('targetAmountPaise: $targetAmountPaise, ')
          ..write('savedAmount: $savedAmount, ')
          ..write('savedAmountPaise: $savedAmountPaise, ')
          ..write('targetDate: $targetDate, ')
          ..write('monthlyContribution: $monthlyContribution, ')
          ..write('monthlyContributionPaise: $monthlyContributionPaise, ')
          ..write('recentDelta: $recentDelta, ')
          ..write('recentDeltaPaise: $recentDeltaPaise, ')
          ..write('monthlyExpense: $monthlyExpense, ')
          ..write('monthlyExpensePaise: $monthlyExpensePaise, ')
          ..write('isEmergency: $isEmergency, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    category,
    targetAmount,
    targetAmountPaise,
    savedAmount,
    savedAmountPaise,
    targetDate,
    monthlyContribution,
    monthlyContributionPaise,
    recentDelta,
    recentDeltaPaise,
    monthlyExpense,
    monthlyExpensePaise,
    isEmergency,
    createdAt,
    updatedAt,
    isDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GoalFund &&
          other.id == this.id &&
          other.title == this.title &&
          other.category == this.category &&
          other.targetAmount == this.targetAmount &&
          other.targetAmountPaise == this.targetAmountPaise &&
          other.savedAmount == this.savedAmount &&
          other.savedAmountPaise == this.savedAmountPaise &&
          other.targetDate == this.targetDate &&
          other.monthlyContribution == this.monthlyContribution &&
          other.monthlyContributionPaise == this.monthlyContributionPaise &&
          other.recentDelta == this.recentDelta &&
          other.recentDeltaPaise == this.recentDeltaPaise &&
          other.monthlyExpense == this.monthlyExpense &&
          other.monthlyExpensePaise == this.monthlyExpensePaise &&
          other.isEmergency == this.isEmergency &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted);
}

class GoalFundsCompanion extends UpdateCompanion<GoalFund> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> category;
  final Value<double> targetAmount;
  final Value<int> targetAmountPaise;
  final Value<double> savedAmount;
  final Value<int> savedAmountPaise;
  final Value<int> targetDate;
  final Value<double> monthlyContribution;
  final Value<int> monthlyContributionPaise;
  final Value<double> recentDelta;
  final Value<int> recentDeltaPaise;
  final Value<double> monthlyExpense;
  final Value<int> monthlyExpensePaise;
  final Value<bool> isEmergency;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const GoalFundsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.category = const Value.absent(),
    this.targetAmount = const Value.absent(),
    this.targetAmountPaise = const Value.absent(),
    this.savedAmount = const Value.absent(),
    this.savedAmountPaise = const Value.absent(),
    this.targetDate = const Value.absent(),
    this.monthlyContribution = const Value.absent(),
    this.monthlyContributionPaise = const Value.absent(),
    this.recentDelta = const Value.absent(),
    this.recentDeltaPaise = const Value.absent(),
    this.monthlyExpense = const Value.absent(),
    this.monthlyExpensePaise = const Value.absent(),
    this.isEmergency = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GoalFundsCompanion.insert({
    required String id,
    required String title,
    required String category,
    required double targetAmount,
    this.targetAmountPaise = const Value.absent(),
    this.savedAmount = const Value.absent(),
    this.savedAmountPaise = const Value.absent(),
    required int targetDate,
    this.monthlyContribution = const Value.absent(),
    this.monthlyContributionPaise = const Value.absent(),
    this.recentDelta = const Value.absent(),
    this.recentDeltaPaise = const Value.absent(),
    this.monthlyExpense = const Value.absent(),
    this.monthlyExpensePaise = const Value.absent(),
    this.isEmergency = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       category = Value(category),
       targetAmount = Value(targetAmount),
       targetDate = Value(targetDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<GoalFund> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? category,
    Expression<double>? targetAmount,
    Expression<int>? targetAmountPaise,
    Expression<double>? savedAmount,
    Expression<int>? savedAmountPaise,
    Expression<int>? targetDate,
    Expression<double>? monthlyContribution,
    Expression<int>? monthlyContributionPaise,
    Expression<double>? recentDelta,
    Expression<int>? recentDeltaPaise,
    Expression<double>? monthlyExpense,
    Expression<int>? monthlyExpensePaise,
    Expression<bool>? isEmergency,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (category != null) 'category': category,
      if (targetAmount != null) 'target_amount': targetAmount,
      if (targetAmountPaise != null) 'target_amount_paise': targetAmountPaise,
      if (savedAmount != null) 'saved_amount': savedAmount,
      if (savedAmountPaise != null) 'saved_amount_paise': savedAmountPaise,
      if (targetDate != null) 'target_date': targetDate,
      if (monthlyContribution != null)
        'monthly_contribution': monthlyContribution,
      if (monthlyContributionPaise != null)
        'monthly_contribution_paise': monthlyContributionPaise,
      if (recentDelta != null) 'recent_delta': recentDelta,
      if (recentDeltaPaise != null) 'recent_delta_paise': recentDeltaPaise,
      if (monthlyExpense != null) 'monthly_expense': monthlyExpense,
      if (monthlyExpensePaise != null)
        'monthly_expense_paise': monthlyExpensePaise,
      if (isEmergency != null) 'is_emergency': isEmergency,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GoalFundsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? category,
    Value<double>? targetAmount,
    Value<int>? targetAmountPaise,
    Value<double>? savedAmount,
    Value<int>? savedAmountPaise,
    Value<int>? targetDate,
    Value<double>? monthlyContribution,
    Value<int>? monthlyContributionPaise,
    Value<double>? recentDelta,
    Value<int>? recentDeltaPaise,
    Value<double>? monthlyExpense,
    Value<int>? monthlyExpensePaise,
    Value<bool>? isEmergency,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return GoalFundsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      targetAmount: targetAmount ?? this.targetAmount,
      targetAmountPaise: targetAmountPaise ?? this.targetAmountPaise,
      savedAmount: savedAmount ?? this.savedAmount,
      savedAmountPaise: savedAmountPaise ?? this.savedAmountPaise,
      targetDate: targetDate ?? this.targetDate,
      monthlyContribution: monthlyContribution ?? this.monthlyContribution,
      monthlyContributionPaise:
          monthlyContributionPaise ?? this.monthlyContributionPaise,
      recentDelta: recentDelta ?? this.recentDelta,
      recentDeltaPaise: recentDeltaPaise ?? this.recentDeltaPaise,
      monthlyExpense: monthlyExpense ?? this.monthlyExpense,
      monthlyExpensePaise: monthlyExpensePaise ?? this.monthlyExpensePaise,
      isEmergency: isEmergency ?? this.isEmergency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (targetAmount.present) {
      map['target_amount'] = Variable<double>(targetAmount.value);
    }
    if (targetAmountPaise.present) {
      map['target_amount_paise'] = Variable<int>(targetAmountPaise.value);
    }
    if (savedAmount.present) {
      map['saved_amount'] = Variable<double>(savedAmount.value);
    }
    if (savedAmountPaise.present) {
      map['saved_amount_paise'] = Variable<int>(savedAmountPaise.value);
    }
    if (targetDate.present) {
      map['target_date'] = Variable<int>(targetDate.value);
    }
    if (monthlyContribution.present) {
      map['monthly_contribution'] = Variable<double>(monthlyContribution.value);
    }
    if (monthlyContributionPaise.present) {
      map['monthly_contribution_paise'] = Variable<int>(
        monthlyContributionPaise.value,
      );
    }
    if (recentDelta.present) {
      map['recent_delta'] = Variable<double>(recentDelta.value);
    }
    if (recentDeltaPaise.present) {
      map['recent_delta_paise'] = Variable<int>(recentDeltaPaise.value);
    }
    if (monthlyExpense.present) {
      map['monthly_expense'] = Variable<double>(monthlyExpense.value);
    }
    if (monthlyExpensePaise.present) {
      map['monthly_expense_paise'] = Variable<int>(monthlyExpensePaise.value);
    }
    if (isEmergency.present) {
      map['is_emergency'] = Variable<bool>(isEmergency.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalFundsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('category: $category, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('targetAmountPaise: $targetAmountPaise, ')
          ..write('savedAmount: $savedAmount, ')
          ..write('savedAmountPaise: $savedAmountPaise, ')
          ..write('targetDate: $targetDate, ')
          ..write('monthlyContribution: $monthlyContribution, ')
          ..write('monthlyContributionPaise: $monthlyContributionPaise, ')
          ..write('recentDelta: $recentDelta, ')
          ..write('recentDeltaPaise: $recentDeltaPaise, ')
          ..write('monthlyExpense: $monthlyExpense, ')
          ..write('monthlyExpensePaise: $monthlyExpensePaise, ')
          ..write('isEmergency: $isEmergency, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GoalContributionsTable extends GoalContributions
    with TableInfo<$GoalContributionsTable, GoalContribution> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalContributionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _goalIdMeta = const VerificationMeta('goalId');
  @override
  late final GeneratedColumn<String> goalId = GeneratedColumn<String>(
    'goal_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountPaiseMeta = const VerificationMeta(
    'amountPaise',
  );
  @override
  late final GeneratedColumn<int> amountPaise = GeneratedColumn<int>(
    'amount_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    goalId,
    amount,
    amountPaise,
    note,
    createdAt,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goal_contributions';
  @override
  VerificationContext validateIntegrity(
    Insertable<GoalContribution> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('goal_id')) {
      context.handle(
        _goalIdMeta,
        goalId.isAcceptableOrUnknown(data['goal_id']!, _goalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_goalIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('amount_paise')) {
      context.handle(
        _amountPaiseMeta,
        amountPaise.isAcceptableOrUnknown(
          data['amount_paise']!,
          _amountPaiseMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GoalContribution map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GoalContribution(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      goalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}goal_id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      amountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_paise'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $GoalContributionsTable createAlias(String alias) {
    return $GoalContributionsTable(attachedDatabase, alias);
  }
}

class GoalContribution extends DataClass
    implements Insertable<GoalContribution> {
  final String id;
  final String goalId;
  final double amount;
  final int amountPaise;
  final String? note;
  final int createdAt;
  final bool isDeleted;
  const GoalContribution({
    required this.id,
    required this.goalId,
    required this.amount,
    required this.amountPaise,
    this.note,
    required this.createdAt,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['goal_id'] = Variable<String>(goalId);
    map['amount'] = Variable<double>(amount);
    map['amount_paise'] = Variable<int>(amountPaise);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  GoalContributionsCompanion toCompanion(bool nullToAbsent) {
    return GoalContributionsCompanion(
      id: Value(id),
      goalId: Value(goalId),
      amount: Value(amount),
      amountPaise: Value(amountPaise),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      isDeleted: Value(isDeleted),
    );
  }

  factory GoalContribution.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GoalContribution(
      id: serializer.fromJson<String>(json['id']),
      goalId: serializer.fromJson<String>(json['goalId']),
      amount: serializer.fromJson<double>(json['amount']),
      amountPaise: serializer.fromJson<int>(json['amountPaise']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'goalId': serializer.toJson<String>(goalId),
      'amount': serializer.toJson<double>(amount),
      'amountPaise': serializer.toJson<int>(amountPaise),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<int>(createdAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  GoalContribution copyWith({
    String? id,
    String? goalId,
    double? amount,
    int? amountPaise,
    Value<String?> note = const Value.absent(),
    int? createdAt,
    bool? isDeleted,
  }) => GoalContribution(
    id: id ?? this.id,
    goalId: goalId ?? this.goalId,
    amount: amount ?? this.amount,
    amountPaise: amountPaise ?? this.amountPaise,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  GoalContribution copyWithCompanion(GoalContributionsCompanion data) {
    return GoalContribution(
      id: data.id.present ? data.id.value : this.id,
      goalId: data.goalId.present ? data.goalId.value : this.goalId,
      amount: data.amount.present ? data.amount.value : this.amount,
      amountPaise: data.amountPaise.present
          ? data.amountPaise.value
          : this.amountPaise,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GoalContribution(')
          ..write('id: $id, ')
          ..write('goalId: $goalId, ')
          ..write('amount: $amount, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, goalId, amount, amountPaise, note, createdAt, isDeleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GoalContribution &&
          other.id == this.id &&
          other.goalId == this.goalId &&
          other.amount == this.amount &&
          other.amountPaise == this.amountPaise &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.isDeleted == this.isDeleted);
}

class GoalContributionsCompanion extends UpdateCompanion<GoalContribution> {
  final Value<String> id;
  final Value<String> goalId;
  final Value<double> amount;
  final Value<int> amountPaise;
  final Value<String?> note;
  final Value<int> createdAt;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const GoalContributionsCompanion({
    this.id = const Value.absent(),
    this.goalId = const Value.absent(),
    this.amount = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GoalContributionsCompanion.insert({
    required String id,
    required String goalId,
    required double amount,
    this.amountPaise = const Value.absent(),
    this.note = const Value.absent(),
    required int createdAt,
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       goalId = Value(goalId),
       amount = Value(amount),
       createdAt = Value(createdAt);
  static Insertable<GoalContribution> custom({
    Expression<String>? id,
    Expression<String>? goalId,
    Expression<double>? amount,
    Expression<int>? amountPaise,
    Expression<String>? note,
    Expression<int>? createdAt,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (goalId != null) 'goal_id': goalId,
      if (amount != null) 'amount': amount,
      if (amountPaise != null) 'amount_paise': amountPaise,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GoalContributionsCompanion copyWith({
    Value<String>? id,
    Value<String>? goalId,
    Value<double>? amount,
    Value<int>? amountPaise,
    Value<String?>? note,
    Value<int>? createdAt,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return GoalContributionsCompanion(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      amount: amount ?? this.amount,
      amountPaise: amountPaise ?? this.amountPaise,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (goalId.present) {
      map['goal_id'] = Variable<String>(goalId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (amountPaise.present) {
      map['amount_paise'] = Variable<int>(amountPaise.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalContributionsCompanion(')
          ..write('id: $id, ')
          ..write('goalId: $goalId, ')
          ..write('amount: $amount, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpenseContributionsTable extends ExpenseContributions
    with TableInfo<$ExpenseContributionsTable, ExpenseContribution> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpenseContributionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expenseIdMeta = const VerificationMeta(
    'expenseId',
  );
  @override
  late final GeneratedColumn<String> expenseId = GeneratedColumn<String>(
    'expense_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _personNameMeta = const VerificationMeta(
    'personName',
  );
  @override
  late final GeneratedColumn<String> personName = GeneratedColumn<String>(
    'person_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountPaiseMeta = const VerificationMeta(
    'amountPaise',
  );
  @override
  late final GeneratedColumn<int> amountPaise = GeneratedColumn<int>(
    'amount_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isSettledMeta = const VerificationMeta(
    'isSettled',
  );
  @override
  late final GeneratedColumn<bool> isSettled = GeneratedColumn<bool>(
    'is_settled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_settled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _settledAtMeta = const VerificationMeta(
    'settledAt',
  );
  @override
  late final GeneratedColumn<int> settledAt = GeneratedColumn<int>(
    'settled_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    expenseId,
    personName,
    amount,
    amountPaise,
    isSettled,
    settledAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expense_contributions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExpenseContribution> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('expense_id')) {
      context.handle(
        _expenseIdMeta,
        expenseId.isAcceptableOrUnknown(data['expense_id']!, _expenseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_expenseIdMeta);
    }
    if (data.containsKey('person_name')) {
      context.handle(
        _personNameMeta,
        personName.isAcceptableOrUnknown(data['person_name']!, _personNameMeta),
      );
    } else if (isInserting) {
      context.missing(_personNameMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('amount_paise')) {
      context.handle(
        _amountPaiseMeta,
        amountPaise.isAcceptableOrUnknown(
          data['amount_paise']!,
          _amountPaiseMeta,
        ),
      );
    }
    if (data.containsKey('is_settled')) {
      context.handle(
        _isSettledMeta,
        isSettled.isAcceptableOrUnknown(data['is_settled']!, _isSettledMeta),
      );
    }
    if (data.containsKey('settled_at')) {
      context.handle(
        _settledAtMeta,
        settledAt.isAcceptableOrUnknown(data['settled_at']!, _settledAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExpenseContribution map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExpenseContribution(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      expenseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}expense_id'],
      )!,
      personName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}person_name'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      amountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_paise'],
      )!,
      isSettled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_settled'],
      )!,
      settledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}settled_at'],
      ),
    );
  }

  @override
  $ExpenseContributionsTable createAlias(String alias) {
    return $ExpenseContributionsTable(attachedDatabase, alias);
  }
}

class ExpenseContribution extends DataClass
    implements Insertable<ExpenseContribution> {
  final String id;
  final String expenseId;
  final String personName;
  final double amount;
  final int amountPaise;
  final bool isSettled;
  final int? settledAt;
  const ExpenseContribution({
    required this.id,
    required this.expenseId,
    required this.personName,
    required this.amount,
    required this.amountPaise,
    required this.isSettled,
    this.settledAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['expense_id'] = Variable<String>(expenseId);
    map['person_name'] = Variable<String>(personName);
    map['amount'] = Variable<double>(amount);
    map['amount_paise'] = Variable<int>(amountPaise);
    map['is_settled'] = Variable<bool>(isSettled);
    if (!nullToAbsent || settledAt != null) {
      map['settled_at'] = Variable<int>(settledAt);
    }
    return map;
  }

  ExpenseContributionsCompanion toCompanion(bool nullToAbsent) {
    return ExpenseContributionsCompanion(
      id: Value(id),
      expenseId: Value(expenseId),
      personName: Value(personName),
      amount: Value(amount),
      amountPaise: Value(amountPaise),
      isSettled: Value(isSettled),
      settledAt: settledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(settledAt),
    );
  }

  factory ExpenseContribution.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExpenseContribution(
      id: serializer.fromJson<String>(json['id']),
      expenseId: serializer.fromJson<String>(json['expenseId']),
      personName: serializer.fromJson<String>(json['personName']),
      amount: serializer.fromJson<double>(json['amount']),
      amountPaise: serializer.fromJson<int>(json['amountPaise']),
      isSettled: serializer.fromJson<bool>(json['isSettled']),
      settledAt: serializer.fromJson<int?>(json['settledAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'expenseId': serializer.toJson<String>(expenseId),
      'personName': serializer.toJson<String>(personName),
      'amount': serializer.toJson<double>(amount),
      'amountPaise': serializer.toJson<int>(amountPaise),
      'isSettled': serializer.toJson<bool>(isSettled),
      'settledAt': serializer.toJson<int?>(settledAt),
    };
  }

  ExpenseContribution copyWith({
    String? id,
    String? expenseId,
    String? personName,
    double? amount,
    int? amountPaise,
    bool? isSettled,
    Value<int?> settledAt = const Value.absent(),
  }) => ExpenseContribution(
    id: id ?? this.id,
    expenseId: expenseId ?? this.expenseId,
    personName: personName ?? this.personName,
    amount: amount ?? this.amount,
    amountPaise: amountPaise ?? this.amountPaise,
    isSettled: isSettled ?? this.isSettled,
    settledAt: settledAt.present ? settledAt.value : this.settledAt,
  );
  ExpenseContribution copyWithCompanion(ExpenseContributionsCompanion data) {
    return ExpenseContribution(
      id: data.id.present ? data.id.value : this.id,
      expenseId: data.expenseId.present ? data.expenseId.value : this.expenseId,
      personName: data.personName.present
          ? data.personName.value
          : this.personName,
      amount: data.amount.present ? data.amount.value : this.amount,
      amountPaise: data.amountPaise.present
          ? data.amountPaise.value
          : this.amountPaise,
      isSettled: data.isSettled.present ? data.isSettled.value : this.isSettled,
      settledAt: data.settledAt.present ? data.settledAt.value : this.settledAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseContribution(')
          ..write('id: $id, ')
          ..write('expenseId: $expenseId, ')
          ..write('personName: $personName, ')
          ..write('amount: $amount, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('isSettled: $isSettled, ')
          ..write('settledAt: $settledAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    expenseId,
    personName,
    amount,
    amountPaise,
    isSettled,
    settledAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExpenseContribution &&
          other.id == this.id &&
          other.expenseId == this.expenseId &&
          other.personName == this.personName &&
          other.amount == this.amount &&
          other.amountPaise == this.amountPaise &&
          other.isSettled == this.isSettled &&
          other.settledAt == this.settledAt);
}

class ExpenseContributionsCompanion
    extends UpdateCompanion<ExpenseContribution> {
  final Value<String> id;
  final Value<String> expenseId;
  final Value<String> personName;
  final Value<double> amount;
  final Value<int> amountPaise;
  final Value<bool> isSettled;
  final Value<int?> settledAt;
  final Value<int> rowid;
  const ExpenseContributionsCompanion({
    this.id = const Value.absent(),
    this.expenseId = const Value.absent(),
    this.personName = const Value.absent(),
    this.amount = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.isSettled = const Value.absent(),
    this.settledAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpenseContributionsCompanion.insert({
    required String id,
    required String expenseId,
    required String personName,
    required double amount,
    this.amountPaise = const Value.absent(),
    this.isSettled = const Value.absent(),
    this.settledAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       expenseId = Value(expenseId),
       personName = Value(personName),
       amount = Value(amount);
  static Insertable<ExpenseContribution> custom({
    Expression<String>? id,
    Expression<String>? expenseId,
    Expression<String>? personName,
    Expression<double>? amount,
    Expression<int>? amountPaise,
    Expression<bool>? isSettled,
    Expression<int>? settledAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (expenseId != null) 'expense_id': expenseId,
      if (personName != null) 'person_name': personName,
      if (amount != null) 'amount': amount,
      if (amountPaise != null) 'amount_paise': amountPaise,
      if (isSettled != null) 'is_settled': isSettled,
      if (settledAt != null) 'settled_at': settledAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpenseContributionsCompanion copyWith({
    Value<String>? id,
    Value<String>? expenseId,
    Value<String>? personName,
    Value<double>? amount,
    Value<int>? amountPaise,
    Value<bool>? isSettled,
    Value<int?>? settledAt,
    Value<int>? rowid,
  }) {
    return ExpenseContributionsCompanion(
      id: id ?? this.id,
      expenseId: expenseId ?? this.expenseId,
      personName: personName ?? this.personName,
      amount: amount ?? this.amount,
      amountPaise: amountPaise ?? this.amountPaise,
      isSettled: isSettled ?? this.isSettled,
      settledAt: settledAt ?? this.settledAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (expenseId.present) {
      map['expense_id'] = Variable<String>(expenseId.value);
    }
    if (personName.present) {
      map['person_name'] = Variable<String>(personName.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (amountPaise.present) {
      map['amount_paise'] = Variable<int>(amountPaise.value);
    }
    if (isSettled.present) {
      map['is_settled'] = Variable<bool>(isSettled.value);
    }
    if (settledAt.present) {
      map['settled_at'] = Variable<int>(settledAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseContributionsCompanion(')
          ..write('id: $id, ')
          ..write('expenseId: $expenseId, ')
          ..write('personName: $personName, ')
          ..write('amount: $amount, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('isSettled: $isSettled, ')
          ..write('settledAt: $settledAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $RecurringRulesTable recurringRules = $RecurringRulesTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $UserProfilesTable userProfiles = $UserProfilesTable(this);
  late final $LendPeopleTable lendPeople = $LendPeopleTable(this);
  late final $LendEntriesTable lendEntries = $LendEntriesTable(this);
  late final $LendSettlementEventsTable lendSettlementEvents =
      $LendSettlementEventsTable(this);
  late final $MonthlyReflectionsTable monthlyReflections =
      $MonthlyReflectionsTable(this);
  late final $CategoryBudgetsTable categoryBudgets = $CategoryBudgetsTable(
    this,
  );
  late final $ActivityEventsTable activityEvents = $ActivityEventsTable(this);
  late final $AppUsageDaysTable appUsageDays = $AppUsageDaysTable(this);
  late final $GoalFundsTable goalFunds = $GoalFundsTable(this);
  late final $GoalContributionsTable goalContributions =
      $GoalContributionsTable(this);
  late final $ExpenseContributionsTable expenseContributions =
      $ExpenseContributionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    transactions,
    categories,
    recurringRules,
    settings,
    userProfiles,
    lendPeople,
    lendEntries,
    lendSettlementEvents,
    monthlyReflections,
    categoryBudgets,
    activityEvents,
    appUsageDays,
    goalFunds,
    goalContributions,
    expenseContributions,
  ];
}

typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      required String id,
      required String type,
      required double amount,
      Value<int> amountPaise,
      required String categoryId,
      required String paymentMode,
      Value<String?> cardType,
      Value<String?> note,
      required int date,
      required int createdAt,
      required int updatedAt,
      Value<String?> recurringRuleId,
      Value<bool> isRecurringInstance,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<String> id,
      Value<String> type,
      Value<double> amount,
      Value<int> amountPaise,
      Value<String> categoryId,
      Value<String> paymentMode,
      Value<String?> cardType,
      Value<String?> note,
      Value<int> date,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<String?> recurringRuleId,
      Value<bool> isRecurringInstance,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentMode => $composableBuilder(
    column: $table.paymentMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cardType => $composableBuilder(
    column: $table.cardType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurringRuleId => $composableBuilder(
    column: $table.recurringRuleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRecurringInstance => $composableBuilder(
    column: $table.isRecurringInstance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMode => $composableBuilder(
    column: $table.paymentMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cardType => $composableBuilder(
    column: $table.cardType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurringRuleId => $composableBuilder(
    column: $table.recurringRuleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRecurringInstance => $composableBuilder(
    column: $table.isRecurringInstance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentMode => $composableBuilder(
    column: $table.paymentMode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cardType =>
      $composableBuilder(column: $table.cardType, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get recurringRuleId => $composableBuilder(
    column: $table.recurringRuleId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isRecurringInstance => $composableBuilder(
    column: $table.isRecurringInstance,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTable,
          Transaction,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (
            Transaction,
            BaseReferences<_$AppDatabase, $TransactionsTable, Transaction>,
          ),
          Transaction,
          PrefetchHooks Function()
        > {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<int> amountPaise = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String> paymentMode = const Value.absent(),
                Value<String?> cardType = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> date = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String?> recurringRuleId = const Value.absent(),
                Value<bool> isRecurringInstance = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                type: type,
                amount: amount,
                amountPaise: amountPaise,
                categoryId: categoryId,
                paymentMode: paymentMode,
                cardType: cardType,
                note: note,
                date: date,
                createdAt: createdAt,
                updatedAt: updatedAt,
                recurringRuleId: recurringRuleId,
                isRecurringInstance: isRecurringInstance,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String type,
                required double amount,
                Value<int> amountPaise = const Value.absent(),
                required String categoryId,
                required String paymentMode,
                Value<String?> cardType = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required int date,
                required int createdAt,
                required int updatedAt,
                Value<String?> recurringRuleId = const Value.absent(),
                Value<bool> isRecurringInstance = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion.insert(
                id: id,
                type: type,
                amount: amount,
                amountPaise: amountPaise,
                categoryId: categoryId,
                paymentMode: paymentMode,
                cardType: cardType,
                note: note,
                date: date,
                createdAt: createdAt,
                updatedAt: updatedAt,
                recurringRuleId: recurringRuleId,
                isRecurringInstance: isRecurringInstance,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTable,
      Transaction,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (
        Transaction,
        BaseReferences<_$AppDatabase, $TransactionsTable, Transaction>,
      ),
      Transaction,
      PrefetchHooks Function()
    >;
typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      required String id,
      required String name,
      required String icon,
      required String color,
      required String type,
      required int createdAt,
      required int updatedAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> icon,
      Value<String> color,
      Value<String> type,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
          Category,
          PrefetchHooks Function()
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                icon: icon,
                color: color,
                type: type,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String icon,
                required String color,
                required String type,
                required int createdAt,
                required int updatedAt,
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                icon: icon,
                color: color,
                type: type,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
      Category,
      PrefetchHooks Function()
    >;
typedef $$RecurringRulesTableCreateCompanionBuilder =
    RecurringRulesCompanion Function({
      required String id,
      required String title,
      Value<String> type,
      required double amount,
      Value<int> amountPaise,
      required String categoryId,
      required String paymentMode,
      required String frequency,
      Value<String?> note,
      required int startDate,
      required int nextDueDate,
      required int createdAt,
      required int updatedAt,
      Value<bool> isActive,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$RecurringRulesTableUpdateCompanionBuilder =
    RecurringRulesCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> type,
      Value<double> amount,
      Value<int> amountPaise,
      Value<String> categoryId,
      Value<String> paymentMode,
      Value<String> frequency,
      Value<String?> note,
      Value<int> startDate,
      Value<int> nextDueDate,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<bool> isActive,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

class $$RecurringRulesTableFilterComposer
    extends Composer<_$AppDatabase, $RecurringRulesTable> {
  $$RecurringRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentMode => $composableBuilder(
    column: $table.paymentMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nextDueDate => $composableBuilder(
    column: $table.nextDueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecurringRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecurringRulesTable> {
  $$RecurringRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMode => $composableBuilder(
    column: $table.paymentMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextDueDate => $composableBuilder(
    column: $table.nextDueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecurringRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecurringRulesTable> {
  $$RecurringRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentMode => $composableBuilder(
    column: $table.paymentMode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<int> get nextDueDate => $composableBuilder(
    column: $table.nextDueDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$RecurringRulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecurringRulesTable,
          RecurringRule,
          $$RecurringRulesTableFilterComposer,
          $$RecurringRulesTableOrderingComposer,
          $$RecurringRulesTableAnnotationComposer,
          $$RecurringRulesTableCreateCompanionBuilder,
          $$RecurringRulesTableUpdateCompanionBuilder,
          (
            RecurringRule,
            BaseReferences<_$AppDatabase, $RecurringRulesTable, RecurringRule>,
          ),
          RecurringRule,
          PrefetchHooks Function()
        > {
  $$RecurringRulesTableTableManager(
    _$AppDatabase db,
    $RecurringRulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurringRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecurringRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecurringRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<int> amountPaise = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String> paymentMode = const Value.absent(),
                Value<String> frequency = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> startDate = const Value.absent(),
                Value<int> nextDueDate = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecurringRulesCompanion(
                id: id,
                title: title,
                type: type,
                amount: amount,
                amountPaise: amountPaise,
                categoryId: categoryId,
                paymentMode: paymentMode,
                frequency: frequency,
                note: note,
                startDate: startDate,
                nextDueDate: nextDueDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isActive: isActive,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String> type = const Value.absent(),
                required double amount,
                Value<int> amountPaise = const Value.absent(),
                required String categoryId,
                required String paymentMode,
                required String frequency,
                Value<String?> note = const Value.absent(),
                required int startDate,
                required int nextDueDate,
                required int createdAt,
                required int updatedAt,
                Value<bool> isActive = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecurringRulesCompanion.insert(
                id: id,
                title: title,
                type: type,
                amount: amount,
                amountPaise: amountPaise,
                categoryId: categoryId,
                paymentMode: paymentMode,
                frequency: frequency,
                note: note,
                startDate: startDate,
                nextDueDate: nextDueDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isActive: isActive,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecurringRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecurringRulesTable,
      RecurringRule,
      $$RecurringRulesTableFilterComposer,
      $$RecurringRulesTableOrderingComposer,
      $$RecurringRulesTableAnnotationComposer,
      $$RecurringRulesTableCreateCompanionBuilder,
      $$RecurringRulesTableUpdateCompanionBuilder,
      (
        RecurringRule,
        BaseReferences<_$AppDatabase, $RecurringRulesTable, RecurringRule>,
      ),
      RecurringRule,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableCreateCompanionBuilder =
    SettingsCompanion Function({
      Value<int> id,
      Value<double> monthlyBudget,
      Value<int> monthlyBudgetPaise,
      Value<String> currency,
      Value<String> themeMode,
      Value<bool> transactionHintsSeen,
      Value<bool> dailyReminderEnabled,
      Value<bool> privacyLockEnabled,
      Value<bool> preventScreenshotsEnabled,
      Value<bool> showAmountsEnabled,
      Value<int?> lastBudgetAlertAt,
      required int updatedAt,
    });
typedef $$SettingsTableUpdateCompanionBuilder =
    SettingsCompanion Function({
      Value<int> id,
      Value<double> monthlyBudget,
      Value<int> monthlyBudgetPaise,
      Value<String> currency,
      Value<String> themeMode,
      Value<bool> transactionHintsSeen,
      Value<bool> dailyReminderEnabled,
      Value<bool> privacyLockEnabled,
      Value<bool> preventScreenshotsEnabled,
      Value<bool> showAmountsEnabled,
      Value<int?> lastBudgetAlertAt,
      Value<int> updatedAt,
    });

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get monthlyBudget => $composableBuilder(
    column: $table.monthlyBudget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get monthlyBudgetPaise => $composableBuilder(
    column: $table.monthlyBudgetPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get transactionHintsSeen => $composableBuilder(
    column: $table.transactionHintsSeen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dailyReminderEnabled => $composableBuilder(
    column: $table.dailyReminderEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get privacyLockEnabled => $composableBuilder(
    column: $table.privacyLockEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get preventScreenshotsEnabled => $composableBuilder(
    column: $table.preventScreenshotsEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showAmountsEnabled => $composableBuilder(
    column: $table.showAmountsEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastBudgetAlertAt => $composableBuilder(
    column: $table.lastBudgetAlertAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get monthlyBudget => $composableBuilder(
    column: $table.monthlyBudget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monthlyBudgetPaise => $composableBuilder(
    column: $table.monthlyBudgetPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get transactionHintsSeen => $composableBuilder(
    column: $table.transactionHintsSeen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dailyReminderEnabled => $composableBuilder(
    column: $table.dailyReminderEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get privacyLockEnabled => $composableBuilder(
    column: $table.privacyLockEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get preventScreenshotsEnabled => $composableBuilder(
    column: $table.preventScreenshotsEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showAmountsEnabled => $composableBuilder(
    column: $table.showAmountsEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastBudgetAlertAt => $composableBuilder(
    column: $table.lastBudgetAlertAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get monthlyBudget => $composableBuilder(
    column: $table.monthlyBudget,
    builder: (column) => column,
  );

  GeneratedColumn<int> get monthlyBudgetPaise => $composableBuilder(
    column: $table.monthlyBudgetPaise,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get themeMode =>
      $composableBuilder(column: $table.themeMode, builder: (column) => column);

  GeneratedColumn<bool> get transactionHintsSeen => $composableBuilder(
    column: $table.transactionHintsSeen,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get dailyReminderEnabled => $composableBuilder(
    column: $table.dailyReminderEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get privacyLockEnabled => $composableBuilder(
    column: $table.privacyLockEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get preventScreenshotsEnabled => $composableBuilder(
    column: $table.preventScreenshotsEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get showAmountsEnabled => $composableBuilder(
    column: $table.showAmountsEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastBudgetAlertAt => $composableBuilder(
    column: $table.lastBudgetAlertAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          Setting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<double> monthlyBudget = const Value.absent(),
                Value<int> monthlyBudgetPaise = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<bool> transactionHintsSeen = const Value.absent(),
                Value<bool> dailyReminderEnabled = const Value.absent(),
                Value<bool> privacyLockEnabled = const Value.absent(),
                Value<bool> preventScreenshotsEnabled = const Value.absent(),
                Value<bool> showAmountsEnabled = const Value.absent(),
                Value<int?> lastBudgetAlertAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
              }) => SettingsCompanion(
                id: id,
                monthlyBudget: monthlyBudget,
                monthlyBudgetPaise: monthlyBudgetPaise,
                currency: currency,
                themeMode: themeMode,
                transactionHintsSeen: transactionHintsSeen,
                dailyReminderEnabled: dailyReminderEnabled,
                privacyLockEnabled: privacyLockEnabled,
                preventScreenshotsEnabled: preventScreenshotsEnabled,
                showAmountsEnabled: showAmountsEnabled,
                lastBudgetAlertAt: lastBudgetAlertAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<double> monthlyBudget = const Value.absent(),
                Value<int> monthlyBudgetPaise = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<bool> transactionHintsSeen = const Value.absent(),
                Value<bool> dailyReminderEnabled = const Value.absent(),
                Value<bool> privacyLockEnabled = const Value.absent(),
                Value<bool> preventScreenshotsEnabled = const Value.absent(),
                Value<bool> showAmountsEnabled = const Value.absent(),
                Value<int?> lastBudgetAlertAt = const Value.absent(),
                required int updatedAt,
              }) => SettingsCompanion.insert(
                id: id,
                monthlyBudget: monthlyBudget,
                monthlyBudgetPaise: monthlyBudgetPaise,
                currency: currency,
                themeMode: themeMode,
                transactionHintsSeen: transactionHintsSeen,
                dailyReminderEnabled: dailyReminderEnabled,
                privacyLockEnabled: privacyLockEnabled,
                preventScreenshotsEnabled: preventScreenshotsEnabled,
                showAmountsEnabled: showAmountsEnabled,
                lastBudgetAlertAt: lastBudgetAlertAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      Setting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
      Setting,
      PrefetchHooks Function()
    >;
typedef $$UserProfilesTableCreateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> imageUrl,
      Value<String?> email,
      Value<String?> phone,
      Value<bool> onboardingCompleted,
      required int createdAt,
      required int updatedAt,
    });
typedef $$UserProfilesTableUpdateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> imageUrl,
      Value<String?> email,
      Value<String?> phone,
      Value<bool> onboardingCompleted,
      Value<int> createdAt,
      Value<int> updatedAt,
    });

class $$UserProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get onboardingCompleted => $composableBuilder(
    column: $table.onboardingCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get onboardingCompleted => $composableBuilder(
    column: $table.onboardingCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<bool> get onboardingCompleted => $composableBuilder(
    column: $table.onboardingCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProfilesTable,
          UserProfile,
          $$UserProfilesTableFilterComposer,
          $$UserProfilesTableOrderingComposer,
          $$UserProfilesTableAnnotationComposer,
          $$UserProfilesTableCreateCompanionBuilder,
          $$UserProfilesTableUpdateCompanionBuilder,
          (
            UserProfile,
            BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>,
          ),
          UserProfile,
          PrefetchHooks Function()
        > {
  $$UserProfilesTableTableManager(_$AppDatabase db, $UserProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<bool> onboardingCompleted = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
              }) => UserProfilesCompanion(
                id: id,
                name: name,
                imageUrl: imageUrl,
                email: email,
                phone: phone,
                onboardingCompleted: onboardingCompleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<bool> onboardingCompleted = const Value.absent(),
                required int createdAt,
                required int updatedAt,
              }) => UserProfilesCompanion.insert(
                id: id,
                name: name,
                imageUrl: imageUrl,
                email: email,
                phone: phone,
                onboardingCompleted: onboardingCompleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProfilesTable,
      UserProfile,
      $$UserProfilesTableFilterComposer,
      $$UserProfilesTableOrderingComposer,
      $$UserProfilesTableAnnotationComposer,
      $$UserProfilesTableCreateCompanionBuilder,
      $$UserProfilesTableUpdateCompanionBuilder,
      (
        UserProfile,
        BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>,
      ),
      UserProfile,
      PrefetchHooks Function()
    >;
typedef $$LendPeopleTableCreateCompanionBuilder =
    LendPeopleCompanion Function({
      required String id,
      required String name,
      required int createdAt,
      required int updatedAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$LendPeopleTableUpdateCompanionBuilder =
    LendPeopleCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

class $$LendPeopleTableFilterComposer
    extends Composer<_$AppDatabase, $LendPeopleTable> {
  $$LendPeopleTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LendPeopleTableOrderingComposer
    extends Composer<_$AppDatabase, $LendPeopleTable> {
  $$LendPeopleTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LendPeopleTableAnnotationComposer
    extends Composer<_$AppDatabase, $LendPeopleTable> {
  $$LendPeopleTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$LendPeopleTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LendPeopleTable,
          LendPeopleData,
          $$LendPeopleTableFilterComposer,
          $$LendPeopleTableOrderingComposer,
          $$LendPeopleTableAnnotationComposer,
          $$LendPeopleTableCreateCompanionBuilder,
          $$LendPeopleTableUpdateCompanionBuilder,
          (
            LendPeopleData,
            BaseReferences<_$AppDatabase, $LendPeopleTable, LendPeopleData>,
          ),
          LendPeopleData,
          PrefetchHooks Function()
        > {
  $$LendPeopleTableTableManager(_$AppDatabase db, $LendPeopleTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LendPeopleTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LendPeopleTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LendPeopleTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LendPeopleCompanion(
                id: id,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int createdAt,
                required int updatedAt,
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LendPeopleCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LendPeopleTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LendPeopleTable,
      LendPeopleData,
      $$LendPeopleTableFilterComposer,
      $$LendPeopleTableOrderingComposer,
      $$LendPeopleTableAnnotationComposer,
      $$LendPeopleTableCreateCompanionBuilder,
      $$LendPeopleTableUpdateCompanionBuilder,
      (
        LendPeopleData,
        BaseReferences<_$AppDatabase, $LendPeopleTable, LendPeopleData>,
      ),
      LendPeopleData,
      PrefetchHooks Function()
    >;
typedef $$LendEntriesTableCreateCompanionBuilder =
    LendEntriesCompanion Function({
      required String id,
      required String personId,
      required String type,
      required double amount,
      Value<int> amountPaise,
      required int date,
      Value<String?> note,
      Value<bool> isSettled,
      Value<double> settledAmount,
      Value<int> settledAmountPaise,
      Value<int?> settledAt,
      required int createdAt,
      required int updatedAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$LendEntriesTableUpdateCompanionBuilder =
    LendEntriesCompanion Function({
      Value<String> id,
      Value<String> personId,
      Value<String> type,
      Value<double> amount,
      Value<int> amountPaise,
      Value<int> date,
      Value<String?> note,
      Value<bool> isSettled,
      Value<double> settledAmount,
      Value<int> settledAmountPaise,
      Value<int?> settledAt,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

class $$LendEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $LendEntriesTable> {
  $$LendEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get personId => $composableBuilder(
    column: $table.personId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSettled => $composableBuilder(
    column: $table.isSettled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get settledAmount => $composableBuilder(
    column: $table.settledAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get settledAmountPaise => $composableBuilder(
    column: $table.settledAmountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get settledAt => $composableBuilder(
    column: $table.settledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LendEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $LendEntriesTable> {
  $$LendEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get personId => $composableBuilder(
    column: $table.personId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSettled => $composableBuilder(
    column: $table.isSettled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get settledAmount => $composableBuilder(
    column: $table.settledAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get settledAmountPaise => $composableBuilder(
    column: $table.settledAmountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get settledAt => $composableBuilder(
    column: $table.settledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LendEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LendEntriesTable> {
  $$LendEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get personId =>
      $composableBuilder(column: $table.personId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => column,
  );

  GeneratedColumn<int> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<bool> get isSettled =>
      $composableBuilder(column: $table.isSettled, builder: (column) => column);

  GeneratedColumn<double> get settledAmount => $composableBuilder(
    column: $table.settledAmount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get settledAmountPaise => $composableBuilder(
    column: $table.settledAmountPaise,
    builder: (column) => column,
  );

  GeneratedColumn<int> get settledAt =>
      $composableBuilder(column: $table.settledAt, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$LendEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LendEntriesTable,
          LendEntry,
          $$LendEntriesTableFilterComposer,
          $$LendEntriesTableOrderingComposer,
          $$LendEntriesTableAnnotationComposer,
          $$LendEntriesTableCreateCompanionBuilder,
          $$LendEntriesTableUpdateCompanionBuilder,
          (
            LendEntry,
            BaseReferences<_$AppDatabase, $LendEntriesTable, LendEntry>,
          ),
          LendEntry,
          PrefetchHooks Function()
        > {
  $$LendEntriesTableTableManager(_$AppDatabase db, $LendEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LendEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LendEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LendEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> personId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<int> amountPaise = const Value.absent(),
                Value<int> date = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<bool> isSettled = const Value.absent(),
                Value<double> settledAmount = const Value.absent(),
                Value<int> settledAmountPaise = const Value.absent(),
                Value<int?> settledAt = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LendEntriesCompanion(
                id: id,
                personId: personId,
                type: type,
                amount: amount,
                amountPaise: amountPaise,
                date: date,
                note: note,
                isSettled: isSettled,
                settledAmount: settledAmount,
                settledAmountPaise: settledAmountPaise,
                settledAt: settledAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String personId,
                required String type,
                required double amount,
                Value<int> amountPaise = const Value.absent(),
                required int date,
                Value<String?> note = const Value.absent(),
                Value<bool> isSettled = const Value.absent(),
                Value<double> settledAmount = const Value.absent(),
                Value<int> settledAmountPaise = const Value.absent(),
                Value<int?> settledAt = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LendEntriesCompanion.insert(
                id: id,
                personId: personId,
                type: type,
                amount: amount,
                amountPaise: amountPaise,
                date: date,
                note: note,
                isSettled: isSettled,
                settledAmount: settledAmount,
                settledAmountPaise: settledAmountPaise,
                settledAt: settledAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LendEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LendEntriesTable,
      LendEntry,
      $$LendEntriesTableFilterComposer,
      $$LendEntriesTableOrderingComposer,
      $$LendEntriesTableAnnotationComposer,
      $$LendEntriesTableCreateCompanionBuilder,
      $$LendEntriesTableUpdateCompanionBuilder,
      (LendEntry, BaseReferences<_$AppDatabase, $LendEntriesTable, LendEntry>),
      LendEntry,
      PrefetchHooks Function()
    >;
typedef $$LendSettlementEventsTableCreateCompanionBuilder =
    LendSettlementEventsCompanion Function({
      required String id,
      required String entryId,
      required String personId,
      required double amount,
      Value<int> amountPaise,
      required int date,
      required int createdAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$LendSettlementEventsTableUpdateCompanionBuilder =
    LendSettlementEventsCompanion Function({
      Value<String> id,
      Value<String> entryId,
      Value<String> personId,
      Value<double> amount,
      Value<int> amountPaise,
      Value<int> date,
      Value<int> createdAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

class $$LendSettlementEventsTableFilterComposer
    extends Composer<_$AppDatabase, $LendSettlementEventsTable> {
  $$LendSettlementEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entryId => $composableBuilder(
    column: $table.entryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get personId => $composableBuilder(
    column: $table.personId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LendSettlementEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $LendSettlementEventsTable> {
  $$LendSettlementEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entryId => $composableBuilder(
    column: $table.entryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get personId => $composableBuilder(
    column: $table.personId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LendSettlementEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LendSettlementEventsTable> {
  $$LendSettlementEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entryId =>
      $composableBuilder(column: $table.entryId, builder: (column) => column);

  GeneratedColumn<String> get personId =>
      $composableBuilder(column: $table.personId, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => column,
  );

  GeneratedColumn<int> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$LendSettlementEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LendSettlementEventsTable,
          LendSettlementEvent,
          $$LendSettlementEventsTableFilterComposer,
          $$LendSettlementEventsTableOrderingComposer,
          $$LendSettlementEventsTableAnnotationComposer,
          $$LendSettlementEventsTableCreateCompanionBuilder,
          $$LendSettlementEventsTableUpdateCompanionBuilder,
          (
            LendSettlementEvent,
            BaseReferences<
              _$AppDatabase,
              $LendSettlementEventsTable,
              LendSettlementEvent
            >,
          ),
          LendSettlementEvent,
          PrefetchHooks Function()
        > {
  $$LendSettlementEventsTableTableManager(
    _$AppDatabase db,
    $LendSettlementEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LendSettlementEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LendSettlementEventsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LendSettlementEventsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> entryId = const Value.absent(),
                Value<String> personId = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<int> amountPaise = const Value.absent(),
                Value<int> date = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LendSettlementEventsCompanion(
                id: id,
                entryId: entryId,
                personId: personId,
                amount: amount,
                amountPaise: amountPaise,
                date: date,
                createdAt: createdAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String entryId,
                required String personId,
                required double amount,
                Value<int> amountPaise = const Value.absent(),
                required int date,
                required int createdAt,
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LendSettlementEventsCompanion.insert(
                id: id,
                entryId: entryId,
                personId: personId,
                amount: amount,
                amountPaise: amountPaise,
                date: date,
                createdAt: createdAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LendSettlementEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LendSettlementEventsTable,
      LendSettlementEvent,
      $$LendSettlementEventsTableFilterComposer,
      $$LendSettlementEventsTableOrderingComposer,
      $$LendSettlementEventsTableAnnotationComposer,
      $$LendSettlementEventsTableCreateCompanionBuilder,
      $$LendSettlementEventsTableUpdateCompanionBuilder,
      (
        LendSettlementEvent,
        BaseReferences<
          _$AppDatabase,
          $LendSettlementEventsTable,
          LendSettlementEvent
        >,
      ),
      LendSettlementEvent,
      PrefetchHooks Function()
    >;
typedef $$MonthlyReflectionsTableCreateCompanionBuilder =
    MonthlyReflectionsCompanion Function({
      required String monthKey,
      required String note,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$MonthlyReflectionsTableUpdateCompanionBuilder =
    MonthlyReflectionsCompanion Function({
      Value<String> monthKey,
      Value<String> note,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$MonthlyReflectionsTableFilterComposer
    extends Composer<_$AppDatabase, $MonthlyReflectionsTable> {
  $$MonthlyReflectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get monthKey => $composableBuilder(
    column: $table.monthKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MonthlyReflectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $MonthlyReflectionsTable> {
  $$MonthlyReflectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get monthKey => $composableBuilder(
    column: $table.monthKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MonthlyReflectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MonthlyReflectionsTable> {
  $$MonthlyReflectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get monthKey =>
      $composableBuilder(column: $table.monthKey, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$MonthlyReflectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MonthlyReflectionsTable,
          MonthlyReflection,
          $$MonthlyReflectionsTableFilterComposer,
          $$MonthlyReflectionsTableOrderingComposer,
          $$MonthlyReflectionsTableAnnotationComposer,
          $$MonthlyReflectionsTableCreateCompanionBuilder,
          $$MonthlyReflectionsTableUpdateCompanionBuilder,
          (
            MonthlyReflection,
            BaseReferences<
              _$AppDatabase,
              $MonthlyReflectionsTable,
              MonthlyReflection
            >,
          ),
          MonthlyReflection,
          PrefetchHooks Function()
        > {
  $$MonthlyReflectionsTableTableManager(
    _$AppDatabase db,
    $MonthlyReflectionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MonthlyReflectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MonthlyReflectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MonthlyReflectionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> monthKey = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MonthlyReflectionsCompanion(
                monthKey: monthKey,
                note: note,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String monthKey,
                required String note,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => MonthlyReflectionsCompanion.insert(
                monthKey: monthKey,
                note: note,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MonthlyReflectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MonthlyReflectionsTable,
      MonthlyReflection,
      $$MonthlyReflectionsTableFilterComposer,
      $$MonthlyReflectionsTableOrderingComposer,
      $$MonthlyReflectionsTableAnnotationComposer,
      $$MonthlyReflectionsTableCreateCompanionBuilder,
      $$MonthlyReflectionsTableUpdateCompanionBuilder,
      (
        MonthlyReflection,
        BaseReferences<
          _$AppDatabase,
          $MonthlyReflectionsTable,
          MonthlyReflection
        >,
      ),
      MonthlyReflection,
      PrefetchHooks Function()
    >;
typedef $$CategoryBudgetsTableCreateCompanionBuilder =
    CategoryBudgetsCompanion Function({
      required String monthKey,
      required String categoryId,
      required double budgetAmount,
      Value<int> budgetAmountPaise,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$CategoryBudgetsTableUpdateCompanionBuilder =
    CategoryBudgetsCompanion Function({
      Value<String> monthKey,
      Value<String> categoryId,
      Value<double> budgetAmount,
      Value<int> budgetAmountPaise,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$CategoryBudgetsTableFilterComposer
    extends Composer<_$AppDatabase, $CategoryBudgetsTable> {
  $$CategoryBudgetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get monthKey => $composableBuilder(
    column: $table.monthKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get budgetAmount => $composableBuilder(
    column: $table.budgetAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get budgetAmountPaise => $composableBuilder(
    column: $table.budgetAmountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoryBudgetsTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoryBudgetsTable> {
  $$CategoryBudgetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get monthKey => $composableBuilder(
    column: $table.monthKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get budgetAmount => $composableBuilder(
    column: $table.budgetAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get budgetAmountPaise => $composableBuilder(
    column: $table.budgetAmountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoryBudgetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoryBudgetsTable> {
  $$CategoryBudgetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get monthKey =>
      $composableBuilder(column: $table.monthKey, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get budgetAmount => $composableBuilder(
    column: $table.budgetAmount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get budgetAmountPaise => $composableBuilder(
    column: $table.budgetAmountPaise,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CategoryBudgetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoryBudgetsTable,
          CategoryBudget,
          $$CategoryBudgetsTableFilterComposer,
          $$CategoryBudgetsTableOrderingComposer,
          $$CategoryBudgetsTableAnnotationComposer,
          $$CategoryBudgetsTableCreateCompanionBuilder,
          $$CategoryBudgetsTableUpdateCompanionBuilder,
          (
            CategoryBudget,
            BaseReferences<
              _$AppDatabase,
              $CategoryBudgetsTable,
              CategoryBudget
            >,
          ),
          CategoryBudget,
          PrefetchHooks Function()
        > {
  $$CategoryBudgetsTableTableManager(
    _$AppDatabase db,
    $CategoryBudgetsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoryBudgetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoryBudgetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoryBudgetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> monthKey = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<double> budgetAmount = const Value.absent(),
                Value<int> budgetAmountPaise = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoryBudgetsCompanion(
                monthKey: monthKey,
                categoryId: categoryId,
                budgetAmount: budgetAmount,
                budgetAmountPaise: budgetAmountPaise,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String monthKey,
                required String categoryId,
                required double budgetAmount,
                Value<int> budgetAmountPaise = const Value.absent(),
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CategoryBudgetsCompanion.insert(
                monthKey: monthKey,
                categoryId: categoryId,
                budgetAmount: budgetAmount,
                budgetAmountPaise: budgetAmountPaise,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoryBudgetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoryBudgetsTable,
      CategoryBudget,
      $$CategoryBudgetsTableFilterComposer,
      $$CategoryBudgetsTableOrderingComposer,
      $$CategoryBudgetsTableAnnotationComposer,
      $$CategoryBudgetsTableCreateCompanionBuilder,
      $$CategoryBudgetsTableUpdateCompanionBuilder,
      (
        CategoryBudget,
        BaseReferences<_$AppDatabase, $CategoryBudgetsTable, CategoryBudget>,
      ),
      CategoryBudget,
      PrefetchHooks Function()
    >;
typedef $$ActivityEventsTableCreateCompanionBuilder =
    ActivityEventsCompanion Function({
      required String id,
      required String kind,
      required String title,
      required String description,
      required int occurredAt,
      Value<int> rowid,
    });
typedef $$ActivityEventsTableUpdateCompanionBuilder =
    ActivityEventsCompanion Function({
      Value<String> id,
      Value<String> kind,
      Value<String> title,
      Value<String> description,
      Value<int> occurredAt,
      Value<int> rowid,
    });

class $$ActivityEventsTableFilterComposer
    extends Composer<_$AppDatabase, $ActivityEventsTable> {
  $$ActivityEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ActivityEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivityEventsTable> {
  $$ActivityEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ActivityEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivityEventsTable> {
  $$ActivityEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );
}

class $$ActivityEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActivityEventsTable,
          ActivityEvent,
          $$ActivityEventsTableFilterComposer,
          $$ActivityEventsTableOrderingComposer,
          $$ActivityEventsTableAnnotationComposer,
          $$ActivityEventsTableCreateCompanionBuilder,
          $$ActivityEventsTableUpdateCompanionBuilder,
          (
            ActivityEvent,
            BaseReferences<_$AppDatabase, $ActivityEventsTable, ActivityEvent>,
          ),
          ActivityEvent,
          PrefetchHooks Function()
        > {
  $$ActivityEventsTableTableManager(
    _$AppDatabase db,
    $ActivityEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivityEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivityEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivityEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> occurredAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivityEventsCompanion(
                id: id,
                kind: kind,
                title: title,
                description: description,
                occurredAt: occurredAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String kind,
                required String title,
                required String description,
                required int occurredAt,
                Value<int> rowid = const Value.absent(),
              }) => ActivityEventsCompanion.insert(
                id: id,
                kind: kind,
                title: title,
                description: description,
                occurredAt: occurredAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ActivityEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActivityEventsTable,
      ActivityEvent,
      $$ActivityEventsTableFilterComposer,
      $$ActivityEventsTableOrderingComposer,
      $$ActivityEventsTableAnnotationComposer,
      $$ActivityEventsTableCreateCompanionBuilder,
      $$ActivityEventsTableUpdateCompanionBuilder,
      (
        ActivityEvent,
        BaseReferences<_$AppDatabase, $ActivityEventsTable, ActivityEvent>,
      ),
      ActivityEvent,
      PrefetchHooks Function()
    >;
typedef $$AppUsageDaysTableCreateCompanionBuilder =
    AppUsageDaysCompanion Function({
      required String dateKey,
      Value<int> totalSeconds,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$AppUsageDaysTableUpdateCompanionBuilder =
    AppUsageDaysCompanion Function({
      Value<String> dateKey,
      Value<int> totalSeconds,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$AppUsageDaysTableFilterComposer
    extends Composer<_$AppDatabase, $AppUsageDaysTable> {
  $$AppUsageDaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get dateKey => $composableBuilder(
    column: $table.dateKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalSeconds => $composableBuilder(
    column: $table.totalSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppUsageDaysTableOrderingComposer
    extends Composer<_$AppDatabase, $AppUsageDaysTable> {
  $$AppUsageDaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get dateKey => $composableBuilder(
    column: $table.dateKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalSeconds => $composableBuilder(
    column: $table.totalSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppUsageDaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppUsageDaysTable> {
  $$AppUsageDaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get dateKey =>
      $composableBuilder(column: $table.dateKey, builder: (column) => column);

  GeneratedColumn<int> get totalSeconds => $composableBuilder(
    column: $table.totalSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppUsageDaysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppUsageDaysTable,
          AppUsageDay,
          $$AppUsageDaysTableFilterComposer,
          $$AppUsageDaysTableOrderingComposer,
          $$AppUsageDaysTableAnnotationComposer,
          $$AppUsageDaysTableCreateCompanionBuilder,
          $$AppUsageDaysTableUpdateCompanionBuilder,
          (
            AppUsageDay,
            BaseReferences<_$AppDatabase, $AppUsageDaysTable, AppUsageDay>,
          ),
          AppUsageDay,
          PrefetchHooks Function()
        > {
  $$AppUsageDaysTableTableManager(_$AppDatabase db, $AppUsageDaysTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppUsageDaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppUsageDaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppUsageDaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> dateKey = const Value.absent(),
                Value<int> totalSeconds = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppUsageDaysCompanion(
                dateKey: dateKey,
                totalSeconds: totalSeconds,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String dateKey,
                Value<int> totalSeconds = const Value.absent(),
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AppUsageDaysCompanion.insert(
                dateKey: dateKey,
                totalSeconds: totalSeconds,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppUsageDaysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppUsageDaysTable,
      AppUsageDay,
      $$AppUsageDaysTableFilterComposer,
      $$AppUsageDaysTableOrderingComposer,
      $$AppUsageDaysTableAnnotationComposer,
      $$AppUsageDaysTableCreateCompanionBuilder,
      $$AppUsageDaysTableUpdateCompanionBuilder,
      (
        AppUsageDay,
        BaseReferences<_$AppDatabase, $AppUsageDaysTable, AppUsageDay>,
      ),
      AppUsageDay,
      PrefetchHooks Function()
    >;
typedef $$GoalFundsTableCreateCompanionBuilder =
    GoalFundsCompanion Function({
      required String id,
      required String title,
      required String category,
      required double targetAmount,
      Value<int> targetAmountPaise,
      Value<double> savedAmount,
      Value<int> savedAmountPaise,
      required int targetDate,
      Value<double> monthlyContribution,
      Value<int> monthlyContributionPaise,
      Value<double> recentDelta,
      Value<int> recentDeltaPaise,
      Value<double> monthlyExpense,
      Value<int> monthlyExpensePaise,
      Value<bool> isEmergency,
      required int createdAt,
      required int updatedAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$GoalFundsTableUpdateCompanionBuilder =
    GoalFundsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> category,
      Value<double> targetAmount,
      Value<int> targetAmountPaise,
      Value<double> savedAmount,
      Value<int> savedAmountPaise,
      Value<int> targetDate,
      Value<double> monthlyContribution,
      Value<int> monthlyContributionPaise,
      Value<double> recentDelta,
      Value<int> recentDeltaPaise,
      Value<double> monthlyExpense,
      Value<int> monthlyExpensePaise,
      Value<bool> isEmergency,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

class $$GoalFundsTableFilterComposer
    extends Composer<_$AppDatabase, $GoalFundsTable> {
  $$GoalFundsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetAmount => $composableBuilder(
    column: $table.targetAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetAmountPaise => $composableBuilder(
    column: $table.targetAmountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get savedAmount => $composableBuilder(
    column: $table.savedAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get savedAmountPaise => $composableBuilder(
    column: $table.savedAmountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get monthlyContribution => $composableBuilder(
    column: $table.monthlyContribution,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get monthlyContributionPaise => $composableBuilder(
    column: $table.monthlyContributionPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get recentDelta => $composableBuilder(
    column: $table.recentDelta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recentDeltaPaise => $composableBuilder(
    column: $table.recentDeltaPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get monthlyExpense => $composableBuilder(
    column: $table.monthlyExpense,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get monthlyExpensePaise => $composableBuilder(
    column: $table.monthlyExpensePaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEmergency => $composableBuilder(
    column: $table.isEmergency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GoalFundsTableOrderingComposer
    extends Composer<_$AppDatabase, $GoalFundsTable> {
  $$GoalFundsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetAmount => $composableBuilder(
    column: $table.targetAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetAmountPaise => $composableBuilder(
    column: $table.targetAmountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get savedAmount => $composableBuilder(
    column: $table.savedAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get savedAmountPaise => $composableBuilder(
    column: $table.savedAmountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get monthlyContribution => $composableBuilder(
    column: $table.monthlyContribution,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monthlyContributionPaise => $composableBuilder(
    column: $table.monthlyContributionPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get recentDelta => $composableBuilder(
    column: $table.recentDelta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recentDeltaPaise => $composableBuilder(
    column: $table.recentDeltaPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get monthlyExpense => $composableBuilder(
    column: $table.monthlyExpense,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monthlyExpensePaise => $composableBuilder(
    column: $table.monthlyExpensePaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEmergency => $composableBuilder(
    column: $table.isEmergency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GoalFundsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GoalFundsTable> {
  $$GoalFundsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get targetAmount => $composableBuilder(
    column: $table.targetAmount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetAmountPaise => $composableBuilder(
    column: $table.targetAmountPaise,
    builder: (column) => column,
  );

  GeneratedColumn<double> get savedAmount => $composableBuilder(
    column: $table.savedAmount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get savedAmountPaise => $composableBuilder(
    column: $table.savedAmountPaise,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get monthlyContribution => $composableBuilder(
    column: $table.monthlyContribution,
    builder: (column) => column,
  );

  GeneratedColumn<int> get monthlyContributionPaise => $composableBuilder(
    column: $table.monthlyContributionPaise,
    builder: (column) => column,
  );

  GeneratedColumn<double> get recentDelta => $composableBuilder(
    column: $table.recentDelta,
    builder: (column) => column,
  );

  GeneratedColumn<int> get recentDeltaPaise => $composableBuilder(
    column: $table.recentDeltaPaise,
    builder: (column) => column,
  );

  GeneratedColumn<double> get monthlyExpense => $composableBuilder(
    column: $table.monthlyExpense,
    builder: (column) => column,
  );

  GeneratedColumn<int> get monthlyExpensePaise => $composableBuilder(
    column: $table.monthlyExpensePaise,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isEmergency => $composableBuilder(
    column: $table.isEmergency,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$GoalFundsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GoalFundsTable,
          GoalFund,
          $$GoalFundsTableFilterComposer,
          $$GoalFundsTableOrderingComposer,
          $$GoalFundsTableAnnotationComposer,
          $$GoalFundsTableCreateCompanionBuilder,
          $$GoalFundsTableUpdateCompanionBuilder,
          (GoalFund, BaseReferences<_$AppDatabase, $GoalFundsTable, GoalFund>),
          GoalFund,
          PrefetchHooks Function()
        > {
  $$GoalFundsTableTableManager(_$AppDatabase db, $GoalFundsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalFundsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalFundsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalFundsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<double> targetAmount = const Value.absent(),
                Value<int> targetAmountPaise = const Value.absent(),
                Value<double> savedAmount = const Value.absent(),
                Value<int> savedAmountPaise = const Value.absent(),
                Value<int> targetDate = const Value.absent(),
                Value<double> monthlyContribution = const Value.absent(),
                Value<int> monthlyContributionPaise = const Value.absent(),
                Value<double> recentDelta = const Value.absent(),
                Value<int> recentDeltaPaise = const Value.absent(),
                Value<double> monthlyExpense = const Value.absent(),
                Value<int> monthlyExpensePaise = const Value.absent(),
                Value<bool> isEmergency = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GoalFundsCompanion(
                id: id,
                title: title,
                category: category,
                targetAmount: targetAmount,
                targetAmountPaise: targetAmountPaise,
                savedAmount: savedAmount,
                savedAmountPaise: savedAmountPaise,
                targetDate: targetDate,
                monthlyContribution: monthlyContribution,
                monthlyContributionPaise: monthlyContributionPaise,
                recentDelta: recentDelta,
                recentDeltaPaise: recentDeltaPaise,
                monthlyExpense: monthlyExpense,
                monthlyExpensePaise: monthlyExpensePaise,
                isEmergency: isEmergency,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String category,
                required double targetAmount,
                Value<int> targetAmountPaise = const Value.absent(),
                Value<double> savedAmount = const Value.absent(),
                Value<int> savedAmountPaise = const Value.absent(),
                required int targetDate,
                Value<double> monthlyContribution = const Value.absent(),
                Value<int> monthlyContributionPaise = const Value.absent(),
                Value<double> recentDelta = const Value.absent(),
                Value<int> recentDeltaPaise = const Value.absent(),
                Value<double> monthlyExpense = const Value.absent(),
                Value<int> monthlyExpensePaise = const Value.absent(),
                Value<bool> isEmergency = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GoalFundsCompanion.insert(
                id: id,
                title: title,
                category: category,
                targetAmount: targetAmount,
                targetAmountPaise: targetAmountPaise,
                savedAmount: savedAmount,
                savedAmountPaise: savedAmountPaise,
                targetDate: targetDate,
                monthlyContribution: monthlyContribution,
                monthlyContributionPaise: monthlyContributionPaise,
                recentDelta: recentDelta,
                recentDeltaPaise: recentDeltaPaise,
                monthlyExpense: monthlyExpense,
                monthlyExpensePaise: monthlyExpensePaise,
                isEmergency: isEmergency,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GoalFundsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GoalFundsTable,
      GoalFund,
      $$GoalFundsTableFilterComposer,
      $$GoalFundsTableOrderingComposer,
      $$GoalFundsTableAnnotationComposer,
      $$GoalFundsTableCreateCompanionBuilder,
      $$GoalFundsTableUpdateCompanionBuilder,
      (GoalFund, BaseReferences<_$AppDatabase, $GoalFundsTable, GoalFund>),
      GoalFund,
      PrefetchHooks Function()
    >;
typedef $$GoalContributionsTableCreateCompanionBuilder =
    GoalContributionsCompanion Function({
      required String id,
      required String goalId,
      required double amount,
      Value<int> amountPaise,
      Value<String?> note,
      required int createdAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$GoalContributionsTableUpdateCompanionBuilder =
    GoalContributionsCompanion Function({
      Value<String> id,
      Value<String> goalId,
      Value<double> amount,
      Value<int> amountPaise,
      Value<String?> note,
      Value<int> createdAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

class $$GoalContributionsTableFilterComposer
    extends Composer<_$AppDatabase, $GoalContributionsTable> {
  $$GoalContributionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get goalId => $composableBuilder(
    column: $table.goalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GoalContributionsTableOrderingComposer
    extends Composer<_$AppDatabase, $GoalContributionsTable> {
  $$GoalContributionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get goalId => $composableBuilder(
    column: $table.goalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GoalContributionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GoalContributionsTable> {
  $$GoalContributionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get goalId =>
      $composableBuilder(column: $table.goalId, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$GoalContributionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GoalContributionsTable,
          GoalContribution,
          $$GoalContributionsTableFilterComposer,
          $$GoalContributionsTableOrderingComposer,
          $$GoalContributionsTableAnnotationComposer,
          $$GoalContributionsTableCreateCompanionBuilder,
          $$GoalContributionsTableUpdateCompanionBuilder,
          (
            GoalContribution,
            BaseReferences<
              _$AppDatabase,
              $GoalContributionsTable,
              GoalContribution
            >,
          ),
          GoalContribution,
          PrefetchHooks Function()
        > {
  $$GoalContributionsTableTableManager(
    _$AppDatabase db,
    $GoalContributionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalContributionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalContributionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalContributionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> goalId = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<int> amountPaise = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GoalContributionsCompanion(
                id: id,
                goalId: goalId,
                amount: amount,
                amountPaise: amountPaise,
                note: note,
                createdAt: createdAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String goalId,
                required double amount,
                Value<int> amountPaise = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required int createdAt,
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GoalContributionsCompanion.insert(
                id: id,
                goalId: goalId,
                amount: amount,
                amountPaise: amountPaise,
                note: note,
                createdAt: createdAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GoalContributionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GoalContributionsTable,
      GoalContribution,
      $$GoalContributionsTableFilterComposer,
      $$GoalContributionsTableOrderingComposer,
      $$GoalContributionsTableAnnotationComposer,
      $$GoalContributionsTableCreateCompanionBuilder,
      $$GoalContributionsTableUpdateCompanionBuilder,
      (
        GoalContribution,
        BaseReferences<
          _$AppDatabase,
          $GoalContributionsTable,
          GoalContribution
        >,
      ),
      GoalContribution,
      PrefetchHooks Function()
    >;
typedef $$ExpenseContributionsTableCreateCompanionBuilder =
    ExpenseContributionsCompanion Function({
      required String id,
      required String expenseId,
      required String personName,
      required double amount,
      Value<int> amountPaise,
      Value<bool> isSettled,
      Value<int?> settledAt,
      Value<int> rowid,
    });
typedef $$ExpenseContributionsTableUpdateCompanionBuilder =
    ExpenseContributionsCompanion Function({
      Value<String> id,
      Value<String> expenseId,
      Value<String> personName,
      Value<double> amount,
      Value<int> amountPaise,
      Value<bool> isSettled,
      Value<int?> settledAt,
      Value<int> rowid,
    });

class $$ExpenseContributionsTableFilterComposer
    extends Composer<_$AppDatabase, $ExpenseContributionsTable> {
  $$ExpenseContributionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get expenseId => $composableBuilder(
    column: $table.expenseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get personName => $composableBuilder(
    column: $table.personName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSettled => $composableBuilder(
    column: $table.isSettled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get settledAt => $composableBuilder(
    column: $table.settledAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExpenseContributionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpenseContributionsTable> {
  $$ExpenseContributionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get expenseId => $composableBuilder(
    column: $table.expenseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get personName => $composableBuilder(
    column: $table.personName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSettled => $composableBuilder(
    column: $table.isSettled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get settledAt => $composableBuilder(
    column: $table.settledAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExpenseContributionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpenseContributionsTable> {
  $$ExpenseContributionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get expenseId =>
      $composableBuilder(column: $table.expenseId, builder: (column) => column);

  GeneratedColumn<String> get personName => $composableBuilder(
    column: $table.personName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSettled =>
      $composableBuilder(column: $table.isSettled, builder: (column) => column);

  GeneratedColumn<int> get settledAt =>
      $composableBuilder(column: $table.settledAt, builder: (column) => column);
}

class $$ExpenseContributionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExpenseContributionsTable,
          ExpenseContribution,
          $$ExpenseContributionsTableFilterComposer,
          $$ExpenseContributionsTableOrderingComposer,
          $$ExpenseContributionsTableAnnotationComposer,
          $$ExpenseContributionsTableCreateCompanionBuilder,
          $$ExpenseContributionsTableUpdateCompanionBuilder,
          (
            ExpenseContribution,
            BaseReferences<
              _$AppDatabase,
              $ExpenseContributionsTable,
              ExpenseContribution
            >,
          ),
          ExpenseContribution,
          PrefetchHooks Function()
        > {
  $$ExpenseContributionsTableTableManager(
    _$AppDatabase db,
    $ExpenseContributionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpenseContributionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpenseContributionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ExpenseContributionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> expenseId = const Value.absent(),
                Value<String> personName = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<int> amountPaise = const Value.absent(),
                Value<bool> isSettled = const Value.absent(),
                Value<int?> settledAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpenseContributionsCompanion(
                id: id,
                expenseId: expenseId,
                personName: personName,
                amount: amount,
                amountPaise: amountPaise,
                isSettled: isSettled,
                settledAt: settledAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String expenseId,
                required String personName,
                required double amount,
                Value<int> amountPaise = const Value.absent(),
                Value<bool> isSettled = const Value.absent(),
                Value<int?> settledAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpenseContributionsCompanion.insert(
                id: id,
                expenseId: expenseId,
                personName: personName,
                amount: amount,
                amountPaise: amountPaise,
                isSettled: isSettled,
                settledAt: settledAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExpenseContributionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExpenseContributionsTable,
      ExpenseContribution,
      $$ExpenseContributionsTableFilterComposer,
      $$ExpenseContributionsTableOrderingComposer,
      $$ExpenseContributionsTableAnnotationComposer,
      $$ExpenseContributionsTableCreateCompanionBuilder,
      $$ExpenseContributionsTableUpdateCompanionBuilder,
      (
        ExpenseContribution,
        BaseReferences<
          _$AppDatabase,
          $ExpenseContributionsTable,
          ExpenseContribution
        >,
      ),
      ExpenseContribution,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$RecurringRulesTableTableManager get recurringRules =>
      $$RecurringRulesTableTableManager(_db, _db.recurringRules);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db, _db.userProfiles);
  $$LendPeopleTableTableManager get lendPeople =>
      $$LendPeopleTableTableManager(_db, _db.lendPeople);
  $$LendEntriesTableTableManager get lendEntries =>
      $$LendEntriesTableTableManager(_db, _db.lendEntries);
  $$LendSettlementEventsTableTableManager get lendSettlementEvents =>
      $$LendSettlementEventsTableTableManager(_db, _db.lendSettlementEvents);
  $$MonthlyReflectionsTableTableManager get monthlyReflections =>
      $$MonthlyReflectionsTableTableManager(_db, _db.monthlyReflections);
  $$CategoryBudgetsTableTableManager get categoryBudgets =>
      $$CategoryBudgetsTableTableManager(_db, _db.categoryBudgets);
  $$ActivityEventsTableTableManager get activityEvents =>
      $$ActivityEventsTableTableManager(_db, _db.activityEvents);
  $$AppUsageDaysTableTableManager get appUsageDays =>
      $$AppUsageDaysTableTableManager(_db, _db.appUsageDays);
  $$GoalFundsTableTableManager get goalFunds =>
      $$GoalFundsTableTableManager(_db, _db.goalFunds);
  $$GoalContributionsTableTableManager get goalContributions =>
      $$GoalContributionsTableTableManager(_db, _db.goalContributions);
  $$ExpenseContributionsTableTableManager get expenseContributions =>
      $$ExpenseContributionsTableTableManager(_db, _db.expenseContributions);
}
