import 'package:spendly/core/constants/app_enums.dart';
import 'package:spendly/features/lend/domain/entities/lend_entry_entity.dart';
import 'package:spendly/features/lend/domain/entities/lend_person_entity.dart';
import 'package:spendly/features/lend/domain/entities/lend_settlement_event_entity.dart';

abstract class LendRepository {
  Stream<List<LendPersonEntity>> watchPeople();

  Stream<List<LendEntryEntity>> watchAllEntries();

  Stream<List<LendEntryEntity>> watchEntriesByPerson(String personId);
  Stream<List<LendSettlementEventEntity>> watchSettlementEventsByPerson(
    String personId,
  );

  Future<void> addPerson(String name);
  Future<void> renamePerson({required String personId, required String name});

  Future<void> addEntry({
    required String personId,
    required LendEntryType type,
    required double amount,
    required DateTime date,
    DateTime? dueDate,
    String? note,
  });

  Future<void> updateEntry({
    required String entryId,
    required String personId,
    required LendEntryType type,
    required double amount,
    required DateTime date,
    DateTime? dueDate,
    String? note,
  });

  Future<void> applySettlement({
    required String entryId,
    required double amount,
    required DateTime settledAt,
  });

  Future<void> clearSettlement(String entryId);

  Future<void> deleteEntry(String entryId);

  Future<void> deletePerson(String personId);
}
