import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:spendly/features/cloud_sync/data/services/cloud_sync_exceptions.dart';
import 'package:spendly/features/cloud_sync/data/services/google_auth_service.dart';
import 'package:spendly/features/cloud_sync/domain/entities/drive_backup_info.dart';

class DriveService {
  DriveService(this._authService);

  static const backupFileName = 'spendly_backup.json';
  final GoogleAuthService _authService;

  Future<void> backupToDrive(
    Map<String, dynamic> data, {
    required bool interactiveIfNeeded,
  }) async {
    try {
      final payload = jsonEncode(data);
      final bytes = utf8.encode(payload);
      final media = drive.Media(Stream<List<int>>.value(bytes), bytes.length);

      await _withDriveApi(
        interactiveIfNeeded: interactiveIfNeeded,
        action: (api) async {
          final existing = await _findBackupFile(api);
          if (existing?.id != null) {
            await api.files.update(
              drive.File(
                name: backupFileName,
                modifiedTime: DateTime.now(),
                mimeType: 'application/json',
              ),
              existing!.id!,
              uploadMedia: media,
            );
            return;
          }

          await api.files.create(
            drive.File(
              name: backupFileName,
              parents: const <String>['appDataFolder'],
              mimeType: 'application/json',
            ),
            uploadMedia: media,
          );
        },
      );
    } on CloudSyncException {
      rethrow;
    } on SocketException catch (e) {
      throw CloudSyncNetworkException(
        'Network error while backing up to Drive.',
        cause: e,
      );
    } on TimeoutException catch (e) {
      throw CloudSyncNetworkException(
        'Request timed out while backing up to Drive.',
        cause: e,
      );
    } catch (e) {
      throw CloudSyncDriveException(
        'Drive API failed during backup.',
        cause: e,
      );
    }
  }

  Future<Map<String, dynamic>> restoreFromDrive({
    required bool interactiveIfNeeded,
  }) async {
    try {
      return await _withDriveApi<Map<String, dynamic>>(
        interactiveIfNeeded: interactiveIfNeeded,
        action: (api) async {
          final existing = await _findBackupFile(api);
          if (existing?.id == null) {
            throw const CloudSyncBackupNotFoundException(
              'Backup file not found in Google Drive AppData folder.',
            );
          }

          final media = await api.files.get(
            existing!.id!,
            downloadOptions: drive.DownloadOptions.fullMedia,
          );
          if (media is! drive.Media) {
            throw const CloudSyncCorruptedBackupException(
              'Backup payload is corrupted or unreadable.',
            );
          }

          final chunks = await media.stream.toList();
          final bytes = chunks.expand((chunk) => chunk).toList();
          final payload = utf8.decode(bytes);
          final decoded = jsonDecode(payload);
          if (decoded is! Map<String, dynamic>) {
            throw const CloudSyncCorruptedBackupException(
              'Backup payload has an invalid JSON structure.',
            );
          }
          return decoded;
        },
      );
    } on CloudSyncException {
      rethrow;
    } on FormatException catch (e) {
      throw CloudSyncCorruptedBackupException(
        'Backup JSON is corrupted.',
        cause: e,
      );
    } on SocketException catch (e) {
      throw CloudSyncNetworkException(
        'Network error while restoring from Drive.',
        cause: e,
      );
    } on TimeoutException catch (e) {
      throw CloudSyncNetworkException(
        'Request timed out while restoring from Drive.',
        cause: e,
      );
    } catch (e) {
      throw CloudSyncDriveException(
        'Drive API failed during restore.',
        cause: e,
      );
    }
  }

  Future<(DriveBackupInfo, Map<String, dynamic>)?> fetchBackup({
    required bool interactiveIfNeeded,
  }) async {
    try {
      return await _withDriveApi<(DriveBackupInfo, Map<String, dynamic>)?>(
        interactiveIfNeeded: interactiveIfNeeded,
        action: (api) async {
          final existing = await _findBackupFile(api);
          if (existing?.id == null) {
            return null;
          }

          final media = await api.files.get(
            existing!.id!,
            downloadOptions: drive.DownloadOptions.fullMedia,
          );
          if (media is! drive.Media) {
            throw const CloudSyncCorruptedBackupException(
              'Backup payload is corrupted or unreadable.',
            );
          }

          final chunks = await media.stream.toList();
          final bytes = chunks.expand((chunk) => chunk).toList();
          final payload = utf8.decode(bytes);
          final decoded = jsonDecode(payload);
          if (decoded is! Map<String, dynamic>) {
            throw const CloudSyncCorruptedBackupException(
              'Backup payload has an invalid JSON structure.',
            );
          }

          final exportedAtStr = decoded['exportedAt'] as String?;
          final exportedAt = exportedAtStr != null
              ? DateTime.tryParse(exportedAtStr) ?? DateTime.now()
              : existing.modifiedTime ?? DateTime.now();
          final sourceDeviceId = decoded['deviceId'] as String?;

          final info = DriveBackupInfo(
            exportedAt: exportedAt,
            sourceDeviceId: sourceDeviceId,
            modifiedTime: existing.modifiedTime,
            fileSize: int.tryParse(existing.size ?? ''),
          );
          return (info, decoded);
        },
      );
    } on CloudSyncException {
      rethrow;
    } on FormatException catch (e) {
      throw CloudSyncCorruptedBackupException(
        'Backup JSON is corrupted.',
        cause: e,
      );
    } on SocketException catch (e) {
      throw CloudSyncNetworkException(
        'Network error while fetching backup info.',
        cause: e,
      );
    } on TimeoutException catch (e) {
      throw CloudSyncNetworkException(
        'Request timed out while fetching backup info.',
        cause: e,
      );
    } catch (e) {
      throw CloudSyncDriveException(
        'Drive API failed while fetching backup info.',
        cause: e,
      );
    }
  }

  Future<drive.File?> _findBackupFile(drive.DriveApi api) async {
    final result = await api.files.list(
      q: "name = '$backupFileName' and trashed = false",
      spaces: 'appDataFolder',
      $fields: 'files(id,name,modifiedTime,size)',
      pageSize: 1,
    );
    if (result.files?.isEmpty ?? true) {
      return null;
    }
    return result.files!.first;
  }

  Future<T> _withDriveApi<T>({
    required bool interactiveIfNeeded,
    required Future<T> Function(drive.DriveApi api) action,
  }) async {
    final client = await _authService.authenticatedClient(
      interactiveIfNeeded: interactiveIfNeeded,
    );
    final api = drive.DriveApi(client);
    try {
      return await action(api);
    } finally {
      client.close();
    }
  }
}

final driveServiceProvider = Provider<DriveService>((ref) {
  final authService = ref.read(googleAuthServiceProvider);
  return DriveService(authService);
});
