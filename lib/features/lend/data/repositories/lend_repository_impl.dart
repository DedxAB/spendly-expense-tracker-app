import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/core/constants/app_enums.dart';
import 'package:spendly/core/database/app_database.dart';
import 'package:spendly/core/database/database_providers.dart';
import 'package:spendly/core/database/mappers.dart';
import 'package:spendly/core/utils/money.dart';
import 'package:spendly/features/lend/domain/entities/lend_entry_entity.dart';
import 'package:spendly/features/lend/domain/entities/lend_person_entity.dart';
import 'package:spendly/features/lend/domain/entities/lend_settlement_event_entity.dart';
import 'package:spendly/features/lend/domain/repositories/lend_repository.dart';
import 'package:uuid/uuid.dart';

class LendRepositoryImpl implements LendRepository {
  LendRepositoryImpl(this._ref);

  final Ref _ref;

  AppDatabase get _db => _ref.read(appDatabaseProvider);

  @override
  Stream<List<LendPersonEntity>> watchPeople() {
    return _db.watchLendPeople().map(
      (rows) => rows.map((e) => e.toEntity()).toList(growable: false),
    );
  }

  @override
  Stream<List<LendEntryEntity>> watchAllEntries() {
    return _db.watchLendEntries().map(
      (rows) => rows.map((e) => e.toEntity()).toList(growable: false),
    );
  }

  @override
  Stream<List<LendEntryEntity>> watchEntriesByPerson(String personId) {
    return _db
        .watchLendEntriesByPerson(personId)
        .map((rows) => rows.map((e) => e.toEntity()).toList(growable: false));
  }

  @override
  Stream<List<LendSettlementEventEntity>> watchSettlementEventsByPerson(
    String personId,
  ) {
    return _db
        .watchLendSettlementEventsByPerson(personId)
        .map((rows) => rows.map((e) => e.toEntity()).toList(growable: false));
  }

  @override
  Future<void> addPerson(String name) async {
    final now = DateTime.now();
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    await _db.upsertLendPerson(
      LendPeopleCompanion.insert(
        id: const Uuid().v4(),
        name: trimmed,
        createdAt: now.millisecondsSinceEpoch,
        updatedAt: now.millisecondsSinceEpoch,
        isDeleted: const Value(false),
      ),
    );
  }

  @override
  Future<void> renamePerson({
    required String personId,
    required String name,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final current = await _db.getLendPersonById(personId);
    if (current == null || current.isDeleted) return;
    await _db.updateLendPersonName(personId, trimmed);
  }

  @override
  Future<void> addEntry({
    required String personId,
    required LendEntryType type,
    required double amount,
    required DateTime date,
    String? note,
  }) async {
    final normalizedAmount = Money.normalize(amount);
    if (normalizedAmount <= 0) return;
    final now = DateTime.now();
    final normalizedNote = note?.trim().isEmpty == true ? null : note?.trim();
    await _db.upsertLendEntry(
      LendEntriesCompanion.insert(
        id: const Uuid().v4(),
        personId: personId,
        type: type.value,
        amount: normalizedAmount,
        amountPaise: Value(Money.toPaise(normalizedAmount)),
        date: date.millisecondsSinceEpoch,
        note: Value(normalizedNote),
        isSettled: const Value(false),
        settledAmount: const Value(0),
        settledAmountPaise: const Value(0),
        createdAt: now.millisecondsSinceEpoch,
        updatedAt: now.millisecondsSinceEpoch,
        isDeleted: const Value(false),
      ),
    );
  }

  @override
  Future<void> updateEntry({
    required String entryId,
    required String personId,
    required LendEntryType type,
    required double amount,
    required DateTime date,
    String? note,
  }) async {
    final current = await _db.getLendEntryById(entryId);
    if (current == null || current.isDeleted) return;

    final normalizedAmount = Money.normalize(amount);
    if (normalizedAmount <= 0) return;

    final settlementEvents = await _db.getLendSettlementEventsByEntry(entryId);
    final settledTotal = Money.normalize(
      settlementEvents.fold<double>(0, (sum, event) => sum + event.amount),
    );
    final effectiveAmount = normalizedAmount < settledTotal
        ? settledTotal
        : normalizedAmount;
    final normalizedNote = note?.trim().isEmpty == true ? null : note?.trim();
    final isSettled = settledTotal >= effectiveAmount;
    final resolvedSettledAtEpoch = isSettled
        ? current.settledAt ??
              (settlementEvents.isNotEmpty ? settlementEvents.first.date : null)
        : null;
    final now = DateTime.now();

    await _db.updateLendEntry(
      entryId,
      LendEntriesCompanion(
        personId: Value(personId),
        type: Value(type.value),
        amount: Value(effectiveAmount),
        amountPaise: Value(Money.toPaise(effectiveAmount)),
        date: Value(date.millisecondsSinceEpoch),
        note: Value(normalizedNote),
        isSettled: Value(isSettled),
        settledAmount: Value(settledTotal),
        settledAmountPaise: Value(Money.toPaise(settledTotal)),
        settledAt: Value(resolvedSettledAtEpoch),
        updatedAt: Value(now.millisecondsSinceEpoch),
      ),
    );
  }

  @override
  Future<void> applySettlement({
    required String entryId,
    required double amount,
    required DateTime settledAt,
  }) async {
    final normalizedAmount = Money.normalize(amount);
    if (normalizedAmount <= 0) return;
    final current = await _db.getLendEntryById(entryId);
    if (current == null || current.isDeleted) return;
    final cappedAmount = Money.normalize(
      normalizedAmount.clamp(0, current.amount).toDouble(),
    );
    final now = DateTime.now();
    await _db.upsertLendSettlementEvent(
      LendSettlementEventsCompanion.insert(
        id: const Uuid().v4(),
        entryId: entryId,
        personId: current.personId,
        amount: cappedAmount,
        amountPaise: Value(Money.toPaise(cappedAmount)),
        date: settledAt.millisecondsSinceEpoch,
        createdAt: now.millisecondsSinceEpoch,
        isDeleted: const Value(false),
      ),
    );
    final events = await _db.getLendSettlementEventsByEntry(entryId);
    final nextSettled = events
        .fold<double>(0, (sum, event) => sum + event.amount)
        .clamp(0, current.amount)
        .toDouble();
    final normalizedSettled = Money.normalize(nextSettled);
    final isFullySettled = normalizedSettled >= current.amount;
    await _db.setLendEntrySettled(
      entryId,
      isFullySettled,
      settledAmount: normalizedSettled,
      settledAtEpoch: settledAt.millisecondsSinceEpoch,
    );
  }

  @override
  Future<void> clearSettlement(String entryId) async {
    final current = await _db.getLendEntryById(entryId);
    if (current == null || current.isDeleted) return;
    final lastEvent = await _db.getLastLendSettlementEvent(entryId);
    if (lastEvent == null) return;
    await _db.softDeleteLendSettlementEvent(lastEvent.id);
    final events = await _db.getLendSettlementEventsByEntry(entryId);
    final nextSettled = events
        .fold<double>(0, (sum, event) => sum + event.amount)
        .clamp(0, current.amount)
        .toDouble();
    final normalizedSettled = Money.normalize(nextSettled);
    await _db.setLendEntrySettled(
      entryId,
      normalizedSettled >= current.amount,
      settledAmount: normalizedSettled,
      settledAtEpoch: events.isEmpty ? null : events.first.date,
    );
  }

  @override
  Future<void> deleteEntry(String entryId) async {
    await _db.softDeleteLendEntry(entryId);
  }

  @override
  Future<void> deletePerson(String personId) async {
    await _db.softDeleteLendPerson(personId);
  }
}

final lendRepositoryProvider = Provider<LendRepository>((ref) {
  return LendRepositoryImpl(ref);
});
