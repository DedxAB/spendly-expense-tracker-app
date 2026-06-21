import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:spendly/features/activity/data/repositories/activity_repository_impl.dart';
import 'package:spendly/features/cloud_sync/data/services/cloud_sync_exceptions.dart';
import 'package:spendly/features/cloud_sync/data/services/drive_service.dart';
import 'package:spendly/features/cloud_sync/data/services/google_auth_service.dart';
import 'package:spendly/features/cloud_sync/domain/entities/cloud_sync_state.dart';
import 'package:spendly/features/cloud_sync/domain/entities/drive_backup_info.dart';
import 'package:spendly/features/cloud_sync/domain/entities/google_profile_entity.dart';
import 'package:spendly/features/cloud_sync/domain/repositories/cloud_sync_repository.dart';
import 'package:spendly/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:uuid/uuid.dart';

class CloudSyncRepositoryImpl implements CloudSyncRepository {
  CloudSyncRepositoryImpl(
    this._ref, {
    GoogleAuthService? authService,
    DriveService? driveService,
  }) : _authService = authService ?? _ref.read(googleAuthServiceProvider),
       _driveService = driveService ?? _ref.read(driveServiceProvider);

  static const _metaFileName = 'cloud_sync_meta.json';

  final Ref _ref;
  final GoogleAuthService _authService;
  final DriveService _driveService;

  @override
  Future<CloudSyncState> loadState() async {
    final meta = await _readMeta();
    final account = await _authService.getSignedInAccount(silentOnly: true);

    return CloudSyncState(
      isConnected: (account?.email ?? meta.connectedEmail) != null,
      connectedEmail: account?.email ?? meta.connectedEmail,
      automaticDailyBackup: meta.automaticDailyBackup,
      lastBackupAt: meta.lastBackupAt,
    );
  }

  @override
  Future<CloudSyncState> connectAccount() async {
    final account = await _authService.signIn();
    final current = await loadState();
    final localMeta = await _readMeta();
    await _writeMeta(
      _CloudSyncMeta(
        automaticDailyBackup: current.automaticDailyBackup,
        lastBackupAt: current.lastBackupAt,
        connectedEmail: account.email,
        deviceId: localMeta.deviceId,
      ),
    );
    await _ref
        .read(activityRepositoryProvider)
        .recordEvent(
          kind: 'sync',
          title: 'Connected cloud sync',
          description: 'Google Drive backup connected for ${account.email}.',
        );
    return current.copyWith(isConnected: true, connectedEmail: account.email);
  }

  @override
  Future<CloudSyncState> disconnectAccount() async {
    await _authService.signOut();

    final current = await loadState();
    final localMeta = await _readMeta();
    await _writeMeta(
      _CloudSyncMeta(
        automaticDailyBackup: false,
        lastBackupAt: current.lastBackupAt,
        connectedEmail: null,
        deviceId: localMeta.deviceId,
      ),
    );
    await _ref
        .read(activityRepositoryProvider)
        .recordEvent(
          kind: 'sync',
          title: 'Disconnected cloud sync',
          description: 'Google Drive backup was disconnected.',
        );

    return current.copyWith(
      isConnected: false,
      clearConnectedEmail: true,
      automaticDailyBackup: false,
      isProcessing: false,
    );
  }

  @override
  Future<GoogleProfileEntity?> fetchGoogleProfile() async {
    final account = await _authService.getSignedInAccount(silentOnly: true);
    if (account == null) {
      return null;
    }
    return GoogleProfileEntity(
      email: account.email,
      displayName: account.name,
      photoUrl: account.photoUrl,
    );
  }

  @override
  Future<CloudSyncState> setAutomaticDailyBackup(bool enabled) async {
    final current = await loadState();
    final localMeta = await _readMeta();
    await _writeMeta(
      _CloudSyncMeta(
        automaticDailyBackup: enabled,
        lastBackupAt: current.lastBackupAt,
        connectedEmail: current.connectedEmail,
        deviceId: localMeta.deviceId,
      ),
    );
    await _ref
        .read(activityRepositoryProvider)
        .recordEvent(
          kind: 'sync',
          title: 'Sync config',
          description:
              'Daily cloud backup ${enabled ? 'enabled' : 'disabled'}.',
        );
    return current.copyWith(automaticDailyBackup: enabled);
  }

  @override
  Future<CloudSyncState> backupNow() async {
    return _performBackup(interactiveIfNeeded: true);
  }

  Future<CloudSyncState> _performBackup({
    required bool interactiveIfNeeded,
  }) async {
    final current = await loadState();
    final localMeta = await _readMeta();
    if (!current.isConnected) {
      final account = await _authService.getSignedInAccount(
        silentOnly: !interactiveIfNeeded,
      );
      if (account == null) {
        throw const CloudSyncAuthException('Not connected to Google account.');
      }
      await _writeMeta(
        _CloudSyncMeta(
          automaticDailyBackup: current.automaticDailyBackup,
          lastBackupAt: current.lastBackupAt,
          connectedEmail: account.email,
          deviceId: localMeta.deviceId,
        ),
      );
    }
    final payload = await _ref.read(settingsRepositoryProvider).exportJson();
    final decoded = jsonDecode(payload);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Export payload is not valid JSON object');
    }
    decoded['deviceId'] = localMeta.deviceId;
    await _driveService.backupToDrive(
      decoded,
      interactiveIfNeeded: interactiveIfNeeded,
    );
    final account = await _authService.getSignedInAccount(silentOnly: true);

    final backupAt = DateTime.now();
    await _writeMeta(
      _CloudSyncMeta(
        automaticDailyBackup: current.automaticDailyBackup,
        lastBackupAt: backupAt,
        connectedEmail: account?.email ?? current.connectedEmail,
        deviceId: localMeta.deviceId,
      ),
    );
    await _ref
        .read(activityRepositoryProvider)
        .recordEvent(
          kind: 'sync',
          title: interactiveIfNeeded ? 'Cloud backup' : 'Auth sync',
          description: interactiveIfNeeded
              ? 'Manual Google Drive backup completed securely.'
              : 'Automatic daily cloud backup completed securely.',
        );
    return current.copyWith(
      isConnected: true,
      connectedEmail: account?.email ?? current.connectedEmail,
      lastBackupAt: backupAt,
    );
  }

  @override
  Future<String?> getDeviceId() async {
    final meta = await _readMeta();
    return meta.deviceId;
  }

  @override
  Future<DriveBackupInfo?> getBackupInfo() async {
    final current = await loadState();
    if (!current.isConnected) {
      throw const CloudSyncAuthException('Not connected to Google account.');
    }
    final result = await _driveService.fetchBackup(interactiveIfNeeded: true);
    if (result == null) return null;
    return result.$1;
  }

  @override
  Future<void> restoreFromDrive() async {
    final current = await loadState();
    if (!current.isConnected) {
      throw const CloudSyncAuthException('Not connected to Google account.');
    }

    final dir = await getApplicationDocumentsDirectory();

    final timestamp = DateTime.now();
    final fileName =
        'spendly_pre_restore_'
        '${timestamp.year}-'
        '${timestamp.month.toString().padLeft(2, '0')}-'
        '${timestamp.day.toString().padLeft(2, '0')}_'
        '${timestamp.hour.toString().padLeft(2, '0')}-'
        '${timestamp.minute.toString().padLeft(2, '0')}-'
        '${timestamp.second.toString().padLeft(2, '0')}'
        '.json';

    final localExport = await _ref.read(settingsRepositoryProvider).exportJson();
    final localBackupFile = File(p.join(dir.path, fileName));
    await localBackupFile.writeAsString(localExport, flush: true);

    final localDecoded = jsonDecode(localExport) as Map<String, dynamic>;
    final localData = localDecoded['data'] as Map<String, dynamic>?;
    final localTxns = localData?['transactions'] as List?;
    final localProfile = localData?['userProfile'] as Map<String, dynamic>?;
    final isFreshInstall = (localTxns?.isEmpty ?? true) &&
        (localProfile?['name'] == null || localProfile?['name'] == 'User');

    final driveResult = await _driveService.fetchBackup(
      interactiveIfNeeded: true,
    );

    if (driveResult == null) {
      throw const CloudSyncBackupNotFoundException(
        'No backup found in Google Drive.',
      );
    }

    final drivePayload = driveResult.$2;

    final localMaxTs = _extractMaxTimestamp(localDecoded);
    final driveMaxTs = _extractMaxTimestamp(drivePayload);
    final driveIsNewer = driveMaxTs > localMaxTs;

    if (driveIsNewer) {
      await _ref
          .read(settingsRepositoryProvider)
          .importJson(jsonEncode(drivePayload));

      await _ref
          .read(activityRepositoryProvider)
          .recordEvent(
            kind: 'sync',
            title: 'Cloud restore',
            description:
                'Drive backup restored. '
                'Local data was older, Drive backup preserved.',
          );
    } else {
      if (!isFreshInstall) {
        await _driveService.backupToDrive(
          localDecoded,
          interactiveIfNeeded: true,
        );
      }

      final freshPayload = await _driveService.restoreFromDrive(
        interactiveIfNeeded: true,
      );
      await _ref
          .read(settingsRepositoryProvider)
          .importJson(jsonEncode(freshPayload));

      await _ref
          .read(activityRepositoryProvider)
          .recordEvent(
            kind: 'sync',
            title: 'Cloud restore',
            description: isFreshInstall
                ? 'Drive backup restored onto a new device.'
                : 'Drive backup restored. '
                    'Local data backed up to Drive first.',
          );
    }
  }

  static int _extractMaxTimestamp(Map<String, dynamic> payload) {
    int maxMs = 0;
    final data = payload['data'] as Map<String, dynamic>?;
    if (data == null) return maxMs;

    void scanItem(Map<String, dynamic>? item, List<String> fields) {
      if (item == null) return;
      for (final field in fields) {
        final val = item[field];
        if (val is int && val > maxMs) {
          maxMs = val;
        } else if (val is String) {
          final dt = DateTime.tryParse(val);
          if (dt != null) {
            final ms = dt.millisecondsSinceEpoch;
            if (ms > maxMs) maxMs = ms;
          }
        }
      }
    }

    void scanList(String key, List<String> fields) {
      final items = data[key] as List?;
      if (items == null) return;
      for (final item in items) {
        if (item is Map<String, dynamic>) {
          scanItem(item, fields);
        }
      }
    }

    scanItem(data['settings'] as Map<String, dynamic>?, ['updatedAt']);
    scanItem(data['userProfile'] as Map<String, dynamic>?, ['updatedAt', 'createdAt']);
    scanList('categories', ['updatedAt', 'createdAt']);
    scanList('transactions', ['updatedAt', 'createdAt', 'date']);
    scanList('recurringRules', ['updatedAt', 'createdAt']);
    scanList('lendPeople', ['updatedAt', 'createdAt']);
    scanList('lendEntries', ['updatedAt', 'createdAt', 'date', 'settledAt']);
    scanList('lendSettlementEvents', ['createdAt', 'date']);
    scanList('monthlyReflections', ['updatedAt']);
    scanList('categoryBudgets', ['updatedAt']);
    scanList('goalFunds', ['updatedAt', 'createdAt']);
    scanList('goalContributions', ['createdAt']);
    scanList('activityEvents', ['occurredAt']);
    scanList('appUsageDays', ['updatedAt']);

    return maxMs;
  }

  @override
  Future<void> runDailyBackupIfNeeded() async {
    try {
      final state = await loadState();
      if (!state.isConnected || !state.automaticDailyBackup) {
        return;
      }

      final now = DateTime.now();
      final last = state.lastBackupAt;
      if (last != null &&
          last.year == now.year &&
          last.month == now.month &&
          last.day == now.day) {
        return;
      }

      final account = await _authService.getSignedInAccount(silentOnly: true);
      if (account?.email == null) {
        return;
      }

      await _performBackup(interactiveIfNeeded: false);
    } catch (_) {
      return;
    }
  }

  Future<File> _metaFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, _metaFileName));
  }

  Future<_CloudSyncMeta> _readMeta() async {
    final file = await _metaFile();
    if (!await file.exists()) {
      final meta = _CloudSyncMeta(
        automaticDailyBackup: false,
        lastBackupAt: null,
        connectedEmail: null,
        deviceId: const Uuid().v4(),
      );
      await _writeMeta(meta);
      return meta;
    }

    try {
      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      final lastBackupAtMs = json['lastBackupAtMs'] as int?;
      final existingDeviceId = json['deviceId'] as String?;
      return _CloudSyncMeta(
        automaticDailyBackup: json['automaticDailyBackup'] as bool? ?? false,
        lastBackupAt: lastBackupAtMs == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(lastBackupAtMs),
        connectedEmail: json['connectedEmail'] as String?,
        deviceId: existingDeviceId ?? const Uuid().v4(),
      );
    } catch (_) {
      final meta = _CloudSyncMeta(
        automaticDailyBackup: false,
        lastBackupAt: null,
        connectedEmail: null,
        deviceId: const Uuid().v4(),
      );
      await _writeMeta(meta);
      return meta;
    }
  }

  Future<void> _writeMeta(_CloudSyncMeta meta) async {
    final file = await _metaFile();
    final payload = <String, dynamic>{
      'automaticDailyBackup': meta.automaticDailyBackup,
      'lastBackupAtMs': meta.lastBackupAt?.millisecondsSinceEpoch,
      'connectedEmail': meta.connectedEmail,
      'deviceId': meta.deviceId,
    };
    await file.writeAsString(jsonEncode(payload), flush: true);
  }
}

class _CloudSyncMeta {
  const _CloudSyncMeta({
    required this.automaticDailyBackup,
    required this.lastBackupAt,
    required this.connectedEmail,
    this.deviceId,
  });

  final bool automaticDailyBackup;
  final DateTime? lastBackupAt;
  final String? connectedEmail;
  final String? deviceId;
}

final cloudSyncRepositoryProvider = Provider<CloudSyncRepository>((ref) {
  return CloudSyncRepositoryImpl(ref);
});
