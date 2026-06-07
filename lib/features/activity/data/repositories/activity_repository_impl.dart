import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/core/database/app_database.dart';
import 'package:spendly/core/database/database_providers.dart';
import 'package:uuid/uuid.dart';

class ActivityEventEntry {
  const ActivityEventEntry({
    required this.id,
    required this.kind,
    required this.title,
    required this.description,
    required this.occurredAt,
  });

  final String id;
  final String kind;
  final String title;
  final String description;
  final DateTime occurredAt;
}

class AppUsageDayEntry {
  const AppUsageDayEntry({
    required this.dateKey,
    required this.totalSeconds,
    required this.updatedAt,
  });

  final String dateKey;
  final int totalSeconds;
  final DateTime updatedAt;
}

class ActivityRepository {
  ActivityRepository(this._ref);

  final Ref _ref;

  Stream<List<ActivityEventEntry>> watchRecentEvents({int days = 3}) {
    return _ref
        .read(appDatabaseProvider)
        .watchRecentActivityEvents(days: days)
        .map(
          (rows) => rows
              .map(
                (row) => ActivityEventEntry(
                  id: row.id,
                  kind: row.kind,
                  title: row.title,
                  description: row.description,
                  occurredAt: DateTime.fromMillisecondsSinceEpoch(
                    row.occurredAt,
                  ),
                ),
              )
              .toList(growable: false),
        );
  }

  Stream<List<AppUsageDayEntry>> watchRecentUsageDays({int days = 4}) {
    return _ref
        .read(appDatabaseProvider)
        .watchRecentAppUsageDays(days: days)
        .map(
          (rows) => rows
              .map(
                (row) => AppUsageDayEntry(
                  dateKey: row.dateKey,
                  totalSeconds: row.totalSeconds,
                  updatedAt: DateTime.fromMillisecondsSinceEpoch(row.updatedAt),
                ),
              )
              .toList(growable: false),
        );
  }

  Stream<List<AppUsageDayEntry>> watchAllUsageDays() {
    return _ref
        .read(appDatabaseProvider)
        .watchAllAppUsageDays()
        .map(
          (rows) => rows
              .map(
                (row) => AppUsageDayEntry(
                  dateKey: row.dateKey,
                  totalSeconds: row.totalSeconds,
                  updatedAt: DateTime.fromMillisecondsSinceEpoch(row.updatedAt),
                ),
              )
              .toList(growable: false),
        );
  }

  Future<void> recordEvent({
    required String kind,
    required String title,
    required String description,
  }) async {
    final now = DateTime.now();
    await _ref
        .read(appDatabaseProvider)
        .insertActivityEvent(
          ActivityEventsCompanion.insert(
            id: const Uuid().v4(),
            kind: kind,
            title: title,
            description: description,
            occurredAt: now.millisecondsSinceEpoch,
          ),
        );
  }

  Future<void> addScreenTime(Duration duration) async {
    await _ref
        .read(appDatabaseProvider)
        .addScreenTimeSeconds(duration.inSeconds);
  }
}

final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  return ActivityRepository(ref);
});

final recentActivityEventsProvider = StreamProvider((ref) {
  return ref.watch(activityRepositoryProvider).watchRecentEvents(days: 3);
});

final recentUsageDaysProvider = StreamProvider((ref) {
  return ref.watch(activityRepositoryProvider).watchRecentUsageDays(days: 4);
});

final allUsageDaysProvider = StreamProvider((ref) {
  return ref.watch(activityRepositoryProvider).watchAllUsageDays();
});
