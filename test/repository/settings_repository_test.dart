import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendly/core/database/app_database.dart';
import 'package:spendly/core/database/database_providers.dart';
import 'package:spendly/features/settings/data/repositories/settings_repository_impl.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('export and import preserve activity and usage history', () async {
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.insertActivityEvent(
      ActivityEventsCompanion.insert(
        id: 'event-1',
        kind: 'sync',
        title: 'Cloud backup',
        description: 'Manual backup completed.',
        occurredAt: now,
      ),
    );
    await db.addScreenTimeSeconds(120);

    final payload = await container.read(settingsRepositoryProvider).exportJson();
    final decoded = jsonDecode(payload) as Map<String, dynamic>;
    final data = decoded['data'] as Map<String, dynamic>;

    expect(data['activityEvents'], isA<List>());
    expect(data['appUsageDays'], isA<List>());
    expect((data['activityEvents'] as List).length, 1);
    expect((data['appUsageDays'] as List).length, 1);

    await db.clearAllAndReseed();

    expect(await db.getActivityEvents(), isEmpty);
    expect(await db.getAppUsageDays(), isEmpty);

    await container.read(settingsRepositoryProvider).importJson(payload);

    final restoredEvents = await db.getActivityEvents();
    final restoredUsage = await db.getAppUsageDays();

    expect(restoredEvents, hasLength(2));
    expect(
      restoredEvents.any((event) => event.id == 'event-1' && event.kind == 'sync'),
      isTrue,
    );
    expect(
      restoredEvents.any((event) => event.kind == 'privacy' && event.title == 'Imported JSON'),
      isTrue,
    );
    expect(restoredUsage, hasLength(1));
    expect(restoredUsage.single.totalSeconds, 120);
  });
}
