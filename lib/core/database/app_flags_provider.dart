import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/core/database/database_providers.dart';

const appFlagSwipeHintSeen = 'swipe_hint_seen';

final swipeHintSeenProvider = FutureProvider<bool>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final value = await db.getAppFlag(appFlagSwipeHintSeen);
  return value == '1';
});

final swipeHintSeenActionsProvider = Provider<void Function()>((ref) {
  return () async {
    final db = ref.read(appDatabaseProvider);
    await db.setAppFlag(appFlagSwipeHintSeen, '1');
    ref.invalidate(swipeHintSeenProvider);
  };
});