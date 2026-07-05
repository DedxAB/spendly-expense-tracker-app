import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:spendly/core/constants/app_enums.dart';
import 'package:spendly/core/theme/app_button_styles.dart';
import 'package:spendly/core/theme/app_design_tokens.dart';
import 'package:spendly/core/theme/app_icons.dart';
import 'package:spendly/core/theme/app_typography.dart';
import 'package:spendly/core/widgets/app_confirm_dialog.dart';
import 'package:spendly/core/widgets/app_modal_surface.dart';
import 'package:spendly/core/widgets/dialog_actions_row.dart';
import 'package:spendly/core/widgets/app_header.dart';
import 'package:spendly/features/activity/data/repositories/activity_repository_impl.dart';
import 'package:spendly/features/cloud_sync/domain/entities/drive_backup_info.dart';
import 'package:spendly/features/cloud_sync/presentation/providers/cloud_sync_provider.dart';
import 'package:spendly/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:spendly/features/settings/presentation/providers/settings_provider.dart';
import 'package:spendly/features/transactions/domain/entities/transaction_entity.dart';
import 'package:spendly/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:spendly/features/user/data/repositories/user_profile_repository_impl.dart';
import 'package:spendly/features/user/presentation/providers/user_profile_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  Future<void> _performGuardedLogout(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final cloudController = ref.read(cloudSyncControllerProvider.notifier);
    final cloud = ref.read(cloudSyncControllerProvider).valueOrNull;

    var shouldContinue = true;
    var backupDone = false;

    if (cloud?.isConnected == true) {
      while (!backupDone && shouldContinue) {
        try {
          await cloudController.backupNow();
          backupDone = true;
        } catch (_) {
          if (!context.mounted) return;
          final decision = await showDialog<int>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: const Text('Backup failed'),
              content: const SizedBox(
                width: AppModalSizes.dialogContentWidth,
                child: Text(
                  'Could not create latest backup before logout. What do you want to do?',
                ),
              ),
              actions: [
                DialogActionsRow(
                  cancelText: 'Cancel',
                  confirmText: 'Retry backup',
                  onCancel: () => Navigator.pop(dialogContext, 0),
                  onConfirm: () => Navigator.pop(dialogContext, 1),
                ),
                const SizedBox(height: AppSpacing.xs),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext, 2),
                    child: const Text('Logout anyway'),
                  ),
                ),
              ],
            ),
          );
          if (decision == 1) {
            continue;
          }
          if (decision == 2) {
            shouldContinue = true;
            break;
          }
          shouldContinue = false;
        }
      }
    }

    if (!shouldContinue) return;

    try {
      final latestCloud = ref.read(cloudSyncControllerProvider).valueOrNull;
      if (latestCloud?.isConnected == true) {
        await cloudController.disconnectAccount();
      }
      await ref.read(settingsRepositoryProvider).clearAllData();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Logged out. Local data cleared. Google backup preserved.',
          ),
        ),
      );
      context.go('/splash');
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logout failed. Please try again.')),
      );
    }
  }

  Future<bool> _restoreFromDrive(BuildContext context, WidgetRef ref) async {
    final cloudController = ref.read(cloudSyncControllerProvider.notifier);
    final cloud = ref.read(cloudSyncControllerProvider).valueOrNull;

    DriveBackupInfo? backupInfo;
    try {
      backupInfo = await cloudController.getBackupInfo();
    } catch (_) {
      if (!context.mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not fetch backup info. Please try again.'),
        ),
      );
      return false;
    }

    if (backupInfo == null) {
      if (!context.mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No backup found in Google Drive.'),
        ),
      );
      return false;
    }

    final lastLocalBackup = cloud?.lastBackupAt;
    final backupDate = backupInfo.exportedAt;
    final localDeviceId = await cloudController.getDeviceId();
    final isDifferentDevice = localDeviceId != null &&
        backupInfo.sourceDeviceId != null &&
        backupInfo.sourceDeviceId != localDeviceId;

    if (!context.mounted) return false;

    final shouldRestore = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (dialogContext) {
        final rootNav = Navigator.of(dialogContext, rootNavigator: true);
        final theme = Theme.of(dialogContext);
        final surfaceColor = theme.colorScheme.surface;
        final infoColor = const Color(0xFF5B7FBF);

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: surfaceColor,
          surfaceTintColor: Colors.transparent,
          titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          title: const Text('Restore from Google Drive?'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                _RestoreInfoRow(
                  label: 'Backup created on',
                  value: DateFormat('dd MMM yyyy, hh:mm a').format(backupDate),
                  icon: Icons.cloud_download_outlined,
                ),
                const SizedBox(height: 8),
                _RestoreInfoRow(
                  label: 'Your last backup',
                  value: lastLocalBackup != null
                      ? DateFormat('dd MMM yyyy, hh:mm a')
                          .format(lastLocalBackup)
                      : 'Never',
                  icon: Icons.history,
                ),
                if (isDifferentDevice) ...[
                  const SizedBox(height: 8),
                  _RestoreInfoRow(
                    label: 'Source device',
                    value: 'Different device',
                    icon: Icons.devices_other,
                  ),
                ],
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2F6F46).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF2F6F46).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.shield_outlined,
                          color: const Color(0xFF2F6F46), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'A local snapshot of your current data is saved '
                          'before restoring. Your Drive backup will not be '
                          'overwritten.',
                          style: TextStyle(
                            color: const Color(0xFF2F6F46),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: infoColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: infoColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline,
                          color: infoColor, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Current local data will be replaced with '
                          'the Drive backup contents.',
                          style: TextStyle(
                            color: infoColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            DialogActionsRow(
              cancelText: 'Cancel',
              confirmText: 'Restore',
              onCancel: () => rootNav.pop(false),
              onConfirm: () => rootNav.pop(true),
            ),
          ],
        );
      },
    );

    if (shouldRestore != true) return false;

    try {
      await cloudController.restoreFromDrive();
      await cloudController.refresh();
      if (!context.mounted) return true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Restore completed successfully.'),
        ),
      );
      return true;
    } catch (_) {
      if (!context.mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Restore failed. Please try again.'),
        ),
      );
      return false;
    }
  }

  Future<void> _runCloudAction(
    BuildContext context,
    Future<void> Function() action, {
    required String successMessage,
    required String failureMessage,
  }) async {
    try {
      await action();
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMessage)));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failureMessage)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bg = context.background;
    final divider = context.border;
    final primary = context.textPrimary;
    final secondary = context.textSecondary;
    final muted = context.textSecondary;
    final brightness = Theme.of(context).brightness;

    final profile = ref.watch(userProfileProvider).valueOrNull;
    final settings = ref.watch(settingsStreamProvider).valueOrNull;
    final transactions = ref.watch(allTransactionsProvider);
    final budgetAlerts = settings?.budgetAlertsEnabled ?? true;
    final dailyReminder = settings?.dailyReminderEnabled ?? false;
    final privacyLock = settings?.privacyLockEnabled ?? false;
    final cloudSync = ref.watch(cloudSyncControllerProvider).valueOrNull;

    final name = (profile?.name.trim().isNotEmpty ?? false)
        ? profile!.name.trim()
        : 'User';
    final imageUrl = (profile?.imageUrl?.trim().isNotEmpty ?? false)
        ? profile!.imageUrl!.trim()
        : null;
    final transactionItems = transactions.valueOrNull;
    final firstTransactionDate = _firstTransactionDate(transactionItems);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppHeader(
        mode: AppHeaderMode.back,
        title: 'Settings',
        onLeadingTap: () => Navigator.of(context).maybePop(),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.smPlus,
          AppSpacing.md,
          AppSpacing.smPlus,
          AppSpacing.md,
        ),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _ProfilePhoto(imageUrl: imageUrl),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(color: primary, height: 1.1),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _TransactionCountPill(count: transactionItems?.length),
                        _TrackingSincePill(date: firstTransactionDate),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _SectionLabel('PREFERENCES', color: secondary),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: context.surface,
              border: Border.all(color: divider),
              borderRadius: BorderRadius.circular(AppRadii.card),
            ),
            child: Column(
              children: [
                _ProfileRow(
                  icon: AppIcons.user,
                  title: 'Account',
                  onTap: () => _editAccount(context, ref),
                  textColor: primary,
                  iconColor: AppIcons.getColorForIcon(
                    AppIcons.user,
                    label: 'Account',
                    brightness: brightness,
                  ),
                  dividerColor: divider,
                ),
                _ProfileRow(
                  icon: AppIcons.notifications,
                  title: 'Notifications',
                  onTap: () => context.push('/notifications'),
                  textColor: primary,
                  iconColor: AppIcons.getColorForIcon(
                    AppIcons.notifications,
                    label: 'Notifications',
                    brightness: brightness,
                  ),
                  dividerColor: divider,
                ),
                _ThemeToggleTile(
                  currentMode: settings?.themeMode ?? AppThemeMode.system,
                  onChanged: (mode) {
                    ref.read(settingsRepositoryProvider).setThemeMode(mode);
                  },
                  dividerColor: divider,
                ),
                _ProfileRow(
                  icon: AppIcons.categories,
                  title: 'Categories',
                  onTap: () => context.push('/categories'),
                  textColor: primary,
                  iconColor: AppIcons.getColorForIcon(
                    AppIcons.categories,
                    label: 'Categories',
                    brightness: brightness,
                  ),
                  dividerColor: divider,
                ),
                _ProfileRow(
                  icon: AppIcons.money,
                  title: 'Lend & Borrow',
                  subtitle: 'Track people and settlements',
                  onTap: () => context.push('/lend'),
                  textColor: primary,
                  subtitleColor: muted,
                  iconColor: AppIcons.getColorForIcon(
                    AppIcons.money,
                    label: 'Lend & Borrow',
                    brightness: brightness,
                  ),
                  dividerColor: divider,
                ),
                _ProfileRow(
                  icon: AppIcons.repeat,
                  title: 'Recurring',
                  subtitle: 'Automate repeating expenses',
                  onTap: () => context.push('/recurring'),
                  textColor: primary,
                  subtitleColor: muted,
                  iconColor: AppIcons.getColorForIcon(
                    AppIcons.repeat,
                    label: 'Recurring',
                    brightness: brightness,
                  ),
                  dividerColor: divider,
                ),
                _ProfileRow(
                  icon: AppIcons.history,
                  title: 'Activity & Screen Time',
                  subtitle: 'Audit logs and app usage',
                  onTap: () => context.push('/activity'),
                  textColor: primary,
                  subtitleColor: muted,
                  iconColor: AppIcons.getColorForIcon(
                    AppIcons.history,
                    label: 'Activity & Screen Time',
                    brightness: brightness,
                  ),
                  dividerColor: divider,
                  isLast: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionLabel('PRIVACY & LOCKS', color: secondary),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: context.surface,
              border: Border.all(color: divider),
              borderRadius: BorderRadius.circular(AppRadii.card),
            ),
            child: Column(
              children: [
                _PrivacyShieldTile(
                  enabled: privacyLock,
                  onChanged: (value) => _setPrivacyLock(context, ref, value),
                  dividerColor: divider,
                ),
                _ProfileRow(
                  icon: AppIcons.download,
                  title: 'Export JSON',
                  subtitle: 'Create a portable backup file',
                  onTap: () => _openExport(context, ref),
                  textColor: primary,
                  subtitleColor: muted,
                  iconColor: AppIcons.getColorForIcon(
                    AppIcons.download,
                    label: 'Export JSON',
                    brightness: brightness,
                  ),
                  dividerColor: divider,
                ),
                _ProfileRow(
                  icon: AppIcons.upload,
                  title: 'Import Data',
                  subtitle: 'Restore from a Spendly JSON backup',
                  onTap: () => _openImport(context, ref),
                  textColor: primary,
                  subtitleColor: muted,
                  iconColor: AppIcons.getColorForIcon(
                    AppIcons.upload,
                    label: 'Import Data',
                    brightness: brightness,
                  ),
                  dividerColor: divider,
                ),
                _ProfileRow(
                  icon: AppIcons.trash,
                  title: 'Erase All Data',
                  subtitle: 'Reset app to a clean start',
                  onTap: () => _eraseAllData(context, ref),
                  textColor: primary,
                  subtitleColor: muted,
                  iconColor: AppIcons.getColorForIcon(
                    AppIcons.trash,
                    label: 'Erase All Data',
                    brightness: brightness,
                  ),
                  dividerColor: divider,
                  isLast: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionLabel('DATA & SYSTEM', color: secondary),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              border: Border.all(color: divider),
              color: context.surface,
              borderRadius: BorderRadius.circular(AppRadii.card),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cloud Sync',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: primary),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  cloudSync?.isConnected == true
                      ? 'Connected: ${cloudSync?.connectedEmail ?? '-'}'
                      : 'Not connected',
                  style: TextStyle(color: muted, fontSize: 12),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  cloudSync?.lastBackupAt == null
                      ? 'Last backup: never'
                      : 'Last backup: ${DateFormat('dd MMM, hh:mm a').format(cloudSync!.lastBackupAt!)}',
                  style: TextStyle(color: muted, fontSize: 12),
                ),
                const SizedBox(height: AppSpacing.smPlus),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Automatic daily backup',
                    style: TextStyle(fontSize: 14, color: primary),
                  ),
                  value: cloudSync?.automaticDailyBackup ?? false,
                  onChanged: cloudSync?.isConnected == true
                      ? (value) async {
                          await ref
                              .read(cloudSyncControllerProvider.notifier)
                              .setAutomaticDailyBackup(value);
                        }
                      : null,
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton(
                      onPressed: cloudSync?.isProcessing == true
                          ? null
                          : () async {
                              await _runCloudAction(
                                context,
                                () => cloudSync?.isConnected == true
                                    ? ref
                                          .read(
                                            cloudSyncControllerProvider
                                                .notifier,
                                          )
                                          .disconnectAccount()
                                    : ref
                                          .read(
                                            cloudSyncControllerProvider
                                                .notifier,
                                          )
                                          .connectAccount(),
                                successMessage: cloudSync?.isConnected == true
                                    ? 'Google account disconnected.'
                                    : 'Google account connected.',
                                failureMessage: cloudSync?.isConnected == true
                                    ? 'Disconnect failed. Please try again.'
                                    : 'Connect failed. Please try again.',
                              );
                            },
                      child: Text(
                        cloudSync?.isConnected == true
                            ? 'Disconnect'
                            : 'Connect',
                      ),
                    ),
                    OutlinedButton(
                      onPressed: cloudSync?.isConnected == true
                          ? () async {
                              await _runCloudAction(
                                context,
                                () => ref
                                    .read(cloudSyncControllerProvider.notifier)
                                    .backupNow(),
                                successMessage:
                                    'Backup completed successfully.',
                                failureMessage:
                                    'Backup failed. Please try again.',
                              );
                            }
                          : null,
                      child: const Text('Backup now'),
                    ),
                    OutlinedButton(
                      onPressed: cloudSync?.isConnected == true &&
                              cloudSync?.isProcessing != true
                          ? () async {
                              await _restoreFromDrive(context, ref);
                            }
                          : null,
                      child: const Text('Restore'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: context.surface,
              border: Border.all(color: divider),
              borderRadius: BorderRadius.circular(AppRadii.card),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  title: Text(
                    'Budget alerts',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: primary),
                  ),
                  subtitle: Text(
                    'Show in-app budget warning notifications',
                    style: TextStyle(fontSize: 12, color: muted),
                  ),
                  value: budgetAlerts,
                  onChanged: (value) async {
                    await ref
                        .read(settingsRepositoryProvider)
                        .setNotificationPreferences(
                          budgetAlertsEnabled: value,
                          dailyReminderEnabled: dailyReminder,
                        );
                  },
                ),
                Divider(height: 1, color: divider, indent: 16, endIndent: 16),
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  title: Text(
                    'Daily reminder',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: primary),
                  ),
                  subtitle: Text(
                    'Receive a push reminder every day',
                    style: TextStyle(fontSize: 12, color: muted),
                  ),
                  value: dailyReminder,
                  onChanged: (value) async {
                    await ref
                        .read(settingsRepositoryProvider)
                        .setNotificationPreferences(
                          budgetAlertsEnabled: budgetAlerts,
                          dailyReminderEnabled: value,
                        );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          SizedBox(
            height: 56,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: bg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
              ),
              onPressed: () async {
                await _performGuardedLogout(context, ref);
              },
              child: const Text(
                'Logout',
                style: TextStyle(
                  fontSize: 18,
                  letterSpacing: 0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 26),
          Center(
            child: TextButton(
              onPressed: () async {
                await launchUrl(
                  Uri.parse('https://dedxab.vercel.app/spendly/privacy-policy'),
                  mode: LaunchMode.inAppBrowserView,
                );
              },
              child: const Text(
                'Privacy Policy',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
          Center(
            child: FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                final info = snapshot.data;
                if (info == null) return const SizedBox.shrink();
                return Text(
                  'Version ${info.version}',
                  style: TextStyle(color: muted, fontSize: 14),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static DateTime? _firstTransactionDate(
    List<TransactionEntity>? transactions,
  ) {
    if (transactions == null || transactions.isEmpty) return null;

    DateTime? earliest;
    for (final tx in transactions) {
      final date = tx.date;
      if (earliest == null || date.isBefore(earliest)) {
        earliest = date;
      }
    }
    return earliest;
  }

  Future<void> _setPrivacyLock(
    BuildContext context,
    WidgetRef ref,
    bool enabled,
  ) async {
    try {
      final auth = LocalAuthentication();
      final isSupported = await auth.isDeviceSupported();
      if (!context.mounted) return;
      if (!isSupported) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Device lock is not available on this device.'),
          ),
        );
        return;
      }

      final didAuthenticate = await auth.authenticate(
        localizedReason: enabled
            ? 'Verify it is you to enable Privacy Shield.'
            : 'Verify it is you to disable Privacy Shield.',
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
      if (!context.mounted || !didAuthenticate) {
        return;
      }

      await ref.read(settingsRepositoryProvider).setPrivacyLockEnabled(enabled);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            enabled ? 'Privacy Shield enabled.' : 'Privacy Shield disabled.',
          ),
        ),
      );
    } on LocalAuthException {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not verify biometrics. Check device settings.'),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Privacy Shield update failed.')),
      );
    }
  }

  Future<void> _editAccount(BuildContext context, WidgetRef ref) async {
    final profile = ref.read(userProfileProvider).valueOrNull;
    final name = TextEditingController(text: profile?.name ?? '');
    final image = TextEditingController(text: profile?.imageUrl ?? '');
    final email = TextEditingController(text: profile?.email ?? '');
    final phone = TextEditingController(text: profile?.phone ?? '');

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (_) => AppModalSurface(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.sm,
            AppSpacing.xs,
            AppSpacing.sm,
            MediaQuery.of(context).viewInsets.bottom + AppSpacing.sm,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 64,
                    height: 4,
                    color: context.border,
                  ),
                ),
                const SizedBox(height: AppSpacing.smPlus),
                Text('Account', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                  Text(
                    'Update your primary profile details.',
                    style: TextStyle(color: context.textSecondary, fontSize: 12),
                  ),
                const SizedBox(height: AppSpacing.smPlus),
                _SheetLabeledField(
                  label: 'Name',
                  hintText: 'Enter your display name',
                  controller: name,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: AppSpacing.sm),
                _SheetLabeledField(
                  label: 'Profile Photo URL',
                  hintText: 'https://...',
                  controller: image,
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: AppSpacing.sm),
                _SheetLabeledField(
                  label: 'Email',
                  hintText: 'name@example.com',
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: AppSpacing.sm),
                _SheetLabeledField(
                  label: 'Phone',
                  hintText: '+91...',
                  controller: phone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: AppSpacing.md),
                DialogActionsRow(
                  cancelText: 'Cancel',
                  confirmText: 'Save',
                  onCancel: () => Navigator.pop(context),
                  onConfirm: () async {
                    await ref
                        .read(userProfileRepositoryProvider)
                        .updateProfile(
                          name: name.text.trim(),
                          imageUrl: image.text.trim(),
                          email: email.text.trim(),
                          phone: phone.text.trim(),
                        );
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openExport(BuildContext context, WidgetRef ref) async {
    final payload = await ref.read(settingsRepositoryProvider).exportJson();
    await ref
        .read(activityRepositoryProvider)
        .recordEvent(
          kind: 'privacy',
          title: 'Exported JSON',
          description: 'A local JSON backup was generated.',
        );
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Export JSON'),
        content: SizedBox(
          width: AppModalSizes.dialogContentWidth,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 300),
            child: SingleChildScrollView(child: SelectableText(payload)),
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: AppButtonStyles.danger(context).copyWith(
                    minimumSize: WidgetStatePropertyAll(const Size(0, 48)),
                    padding: WidgetStatePropertyAll(EdgeInsets.zero),
                  ),
                  child: const Text('Close'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: () async {
                    if (!dialogContext.mounted) return;
                    Navigator.pop(dialogContext);
                    final tempDir = await getTemporaryDirectory();
                    final timestamp = DateTime.now();
                    final fileName =
                        'spendly_backup_'
                        '${timestamp.year}-'
                        '${timestamp.month.toString().padLeft(2, '0')}-'
                        '${timestamp.day.toString().padLeft(2, '0')}.json';
                    final tempFile = File('${tempDir.path}/$fileName');
                    await tempFile.writeAsString(payload, flush: true);
                    await SharePlus.instance.share(
                      ShareParams(
                        files: [XFile(tempFile.path, mimeType: 'application/json')],
                        subject: 'Spendly Backup',
                        text: 'Spendly data backup - $fileName',
                      ),
                    );
                  },
                  style: AppButtonStyles.primary(context).copyWith(
                    minimumSize: WidgetStatePropertyAll(const Size(0, 48)),
                    padding: WidgetStatePropertyAll(EdgeInsets.zero),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.save_alt, size: 18),
                      SizedBox(width: 4),
                      Text('Save'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: payload));
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('JSON copied to clipboard'),
                      ),
                    );
                  },
                  style: AppButtonStyles.primary(context).copyWith(
                    minimumSize: WidgetStatePropertyAll(const Size(0, 48)),
                    padding: WidgetStatePropertyAll(EdgeInsets.zero),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.copy, size: 18),
                      SizedBox(width: 4),
                      Text('Copy'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openImport(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Import JSON'),
        content: SizedBox(
          width: AppModalSizes.dialogContentWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.folder_open, size: 18),
                  onPressed: () async {
                    final result = await FilePicker.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['json'],
                      withData: true,
                    );
                    if (result == null || result.files.isEmpty) return;
                    final bytes = result.files.first.bytes;
                    if (bytes == null) return;
                    controller.text = utf8.decode(bytes);
                    if (!dialogContext.mounted) return;
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  label: const Text('Choose JSON file'),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'or paste below',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: TextField(
                  controller: controller,
                  maxLines: null,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    hintText: 'Paste your exported JSON here',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                    contentPadding: EdgeInsets.all(12),
                  ),
                  style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          DialogActionsRow(
            cancelText: 'Cancel',
            confirmText: 'Import',
            onCancel: () => Navigator.pop(dialogContext),
            onConfirm: () async {
              final raw = controller.text.trim();
              if (raw.isEmpty) return;
              try {
                await ref.read(settingsRepositoryProvider).importJson(raw);
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Import completed')),
                );
              } catch (e) {
                if (!dialogContext.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Import failed: $e')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _eraseAllData(BuildContext context, WidgetRef ref) async {
    final cloud = ref.read(cloudSyncControllerProvider).valueOrNull;
    final shouldErase = await showAppDeleteConfirmDialog(
      context,
      title: 'Erase all data?',
      message: cloud?.isConnected == true
          ? 'This will permanently remove local transactions, categories, recurring rules, lend/borrow records, and profile details. Google will be disconnected from this app, but your existing Drive backup will not be deleted.'
          : 'This will permanently remove all transactions, categories, recurring rules, and lend/borrow records.',
      confirmText: 'Erase',
    );
    if (!shouldErase) return;
    try {
      if (cloud?.isConnected == true) {
        await ref
            .read(cloudSyncControllerProvider.notifier)
            .disconnectAccount();
      }
      await ref.read(settingsRepositoryProvider).clearAllData();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            cloud?.isConnected == true
                ? 'All data erased. Google account disconnected.'
                : 'All data erased.',
          ),
        ),
      );
      context.go('/splash');
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erase failed. Please try again.')),
      );
    }
  }
}

class _ProfilePhoto extends StatelessWidget {
  const _ProfilePhoto({
    required this.imageUrl,
  });

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const _ProfilePhotoGradient(),
            )
          : const _ProfilePhotoGradient(),
    );
  }
}

class _ProfilePhotoGradient extends StatelessWidget {
  const _ProfilePhotoGradient();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFFF59E0B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(AppIcons.user, size: 44, color: context.background),
    );
  }
}

class _PrivacyShieldTile extends StatelessWidget {
  const _PrivacyShieldTile({
    required this.enabled,
    required this.onChanged,
    required this.dividerColor,
  });

  final bool enabled;
  final ValueChanged<bool> onChanged;
  final Color dividerColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: dividerColor)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: enabled
                  ? const Color(0xFF142119)
                  : const Color(0xFF3DD07B).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(
                color: enabled
                    ? const Color(0xFF2F6F46)
                    : context.border,
              ),
            ),
            child: Icon(
              AppIcons.shield,
              color: enabled
                  ? Colors.white
                  : AppIcons.getColorForIcon(AppIcons.shield, brightness: Theme.of(context).brightness),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Privacy Shield',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 4),
                Text(
                  'Require fingerprint, face, or device PIN for app access',
                  style: TextStyle(color: context.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(value: enabled, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _ThemeToggleTile extends StatelessWidget {
  const _ThemeToggleTile({
    required this.currentMode,
    required this.onChanged,
    required this.dividerColor,
  });

  final AppThemeMode currentMode;
  final ValueChanged<AppThemeMode> onChanged;
  final Color dividerColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: dividerColor)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE8B830).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: const Icon(Icons.brightness_6, color: Color(0xFFE8B830), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Theme',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 4),
                Text(
                  'Switch between light and dark mode',
                  style: TextStyle(color: context.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: context.border),
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.md),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _seg(context, 'Sys', currentMode == AppThemeMode.system, true, () => onChanged(AppThemeMode.system)),
                  _seg(context, 'Light', currentMode == AppThemeMode.light, true, () => onChanged(AppThemeMode.light)),
                  _seg(context, 'Dark', currentMode == AppThemeMode.dark, false, () => onChanged(AppThemeMode.dark)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _seg(BuildContext ctx, String label, bool selected, bool showRightBorder, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? ctx.textPrimary : ctx.surface,
          border: Border(
            right: BorderSide(color: showRightBorder ? ctx.border : Colors.transparent),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: selected ? ctx.surface : ctx.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _TransactionCountPill extends StatelessWidget {
  const _TransactionCountPill({required this.count});

  final int? count;

  @override
  Widget build(BuildContext context) {
    final label = count == null
        ? '...'
        : '${NumberFormat.compact().format(count)} ${count == 1 ? 'txn' : 'txns'}';

    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: context.surface,
        border: Border.all(color: context.border),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            AppIcons.receipt,
            size: 14,
            color: AppIcons.getColorForIcon(AppIcons.receipt, brightness: Theme.of(context).brightness),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackingSincePill extends StatelessWidget {
  const _TrackingSincePill({required this.date});

  final DateTime? date;

  @override
  Widget build(BuildContext context) {
    final label = date == null
        ? 'Start tracking'
        : 'Tracking since ${DateFormat('MMM yyyy').format(date!)}';

    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: context.surface,
        border: Border.all(color: context.border),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            AppIcons.history,
            size: 14,
            color: AppIcons.getColorForIcon(AppIcons.history, brightness: Theme.of(context).brightness),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetLabeledField extends StatelessWidget {
  const _SheetLabeledField({
    required this.label,
    required this.controller,
    this.hintText,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
  });

  final String label;
  final String? hintText;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: context.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          decoration: InputDecoration(hintText: hintText),
        ),
      ],
    );
  }
}

class _RestoreInfoRow extends StatelessWidget {
  const _RestoreInfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: context.textSecondary),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: context.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                color: context.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, {required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: 14,
        letterSpacing: 1.4,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.icon,
    required this.title,
    required this.onTap,
    required this.textColor,
    required this.iconColor,
    required this.dividerColor,
    this.subtitle,
    this.subtitleColor,
    this.isLast = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color textColor;
  final Color iconColor;
  final Color dividerColor;
  final Color? subtitleColor;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(bottom: BorderSide(color: dividerColor)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.sectionTitle(
                      context,
                    ).copyWith(color: textColor, fontSize: 18),
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        subtitle!,
                        style: TextStyle(
                          color: subtitleColor ?? iconColor,
                          fontSize: 13,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Icon(AppIcons.chevronRight, color: iconColor, size: 22),
          ],
        ),
      ),
    );
  }
}
