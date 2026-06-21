import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/features/cloud_sync/data/repositories/cloud_sync_repository_impl.dart';
import 'package:spendly/features/cloud_sync/domain/entities/cloud_sync_state.dart';
import 'package:spendly/features/cloud_sync/domain/entities/drive_backup_info.dart';
import 'package:spendly/features/cloud_sync/domain/entities/google_profile_entity.dart';
import 'package:spendly/features/user/data/repositories/user_profile_repository_impl.dart';
import 'package:spendly/features/user/presentation/providers/user_profile_provider.dart';

final cloudSyncControllerProvider =
    AsyncNotifierProvider<CloudSyncController, CloudSyncState>(
      CloudSyncController.new,
    );

class CloudSyncController extends AsyncNotifier<CloudSyncState> {
  @override
  Future<CloudSyncState> build() async {
    return ref.read(cloudSyncRepositoryProvider).loadState();
  }

  Future<void> refresh() async {
    final repository = ref.read(cloudSyncRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(repository.loadState);
  }

  Future<void> connectAccount() async {
    final repository = ref.read(cloudSyncRepositoryProvider);
    final current = state.valueOrNull ?? await repository.loadState();
    state = AsyncData(current.copyWith(isProcessing: true));
    try {
      final updated = await repository.connectAccount();
      final googleProfile = await repository.fetchGoogleProfile();
      if (googleProfile != null) {
        final currentProfile = ref.read(userProfileProvider).valueOrNull;
        await ref
            .read(userProfileRepositoryProvider)
            .updateProfile(
              name: (googleProfile.displayName ?? '').trim().isNotEmpty
                  ? googleProfile.displayName!.trim()
                  : (currentProfile?.name ?? 'User'),
              imageUrl: googleProfile.photoUrl ?? currentProfile?.imageUrl,
              email: googleProfile.email,
              phone: currentProfile?.phone,
              onboardingCompleted: currentProfile?.onboardingCompleted,
            );
      }
      state = AsyncData(updated.copyWith(isProcessing: false));
    } catch (_) {
      state = AsyncData(current.copyWith(isProcessing: false));
      rethrow;
    }
  }

  Future<DriveBackupInfo?> getBackupInfo() async {
    final repository = ref.read(cloudSyncRepositoryProvider);
    return repository.getBackupInfo();
  }

  Future<String?> getDeviceId() async {
    final repository = ref.read(cloudSyncRepositoryProvider);
    return repository.getDeviceId();
  }

  Future<GoogleProfileEntity?> fetchGoogleProfile() async {
    return ref.read(cloudSyncRepositoryProvider).fetchGoogleProfile();
  }

  Future<void> disconnectAccount() async {
    final repository = ref.read(cloudSyncRepositoryProvider);
    final current = state.valueOrNull ?? await repository.loadState();
    state = AsyncData(current.copyWith(isProcessing: true));
    try {
      final updated = await repository.disconnectAccount();
      state = AsyncData(updated.copyWith(isProcessing: false));
    } catch (_) {
      state = AsyncData(current.copyWith(isProcessing: false));
      rethrow;
    }
  }

  Future<void> setAutomaticDailyBackup(bool enabled) async {
    final repository = ref.read(cloudSyncRepositoryProvider);
    final current = state.valueOrNull ?? await repository.loadState();
    state = AsyncData(current.copyWith(isProcessing: true));
    try {
      final updated = await repository.setAutomaticDailyBackup(enabled);
      state = AsyncData(updated.copyWith(isProcessing: false));
    } catch (_) {
      state = AsyncData(current.copyWith(isProcessing: false));
      rethrow;
    }
  }

  Future<void> backupNow() async {
    final repository = ref.read(cloudSyncRepositoryProvider);
    final current = state.valueOrNull ?? await repository.loadState();
    state = AsyncData(current.copyWith(isProcessing: true));
    try {
      final updated = await repository.backupNow();
      state = AsyncData(updated.copyWith(isProcessing: false));
    } catch (_) {
      state = AsyncData(current.copyWith(isProcessing: false));
      rethrow;
    }
  }

  Future<void> restoreFromDrive() async {
    final repository = ref.read(cloudSyncRepositoryProvider);
    final current = state.valueOrNull ?? await repository.loadState();
    state = AsyncData(current.copyWith(isProcessing: true));
    try {
      await repository.restoreFromDrive();
      final refreshed = await repository.loadState();
      state = AsyncData(refreshed.copyWith(isProcessing: false));
    } catch (_) {
      state = AsyncData(current.copyWith(isProcessing: false));
      rethrow;
    }
  }
}
