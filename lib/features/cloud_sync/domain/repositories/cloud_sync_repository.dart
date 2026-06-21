import 'package:spendly/features/cloud_sync/domain/entities/cloud_sync_state.dart';
import 'package:spendly/features/cloud_sync/domain/entities/drive_backup_info.dart';
import 'package:spendly/features/cloud_sync/domain/entities/google_profile_entity.dart';

abstract class CloudSyncRepository {
  Future<CloudSyncState> loadState();

  Future<CloudSyncState> connectAccount();

  Future<CloudSyncState> disconnectAccount();

  Future<GoogleProfileEntity?> fetchGoogleProfile();

  Future<CloudSyncState> setAutomaticDailyBackup(bool enabled);

  Future<CloudSyncState> backupNow();

  Future<DriveBackupInfo?> getBackupInfo();

  Future<String?> getDeviceId();

  Future<void> restoreFromDrive();

  Future<void> runDailyBackupIfNeeded();
}
