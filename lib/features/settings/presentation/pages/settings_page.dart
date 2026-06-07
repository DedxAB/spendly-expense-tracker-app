import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:spendly/core/theme/app_design_tokens.dart';
import 'package:spendly/core/theme/app_icons.dart';
import 'package:spendly/core/theme/app_typography.dart';
import 'package:spendly/core/widgets/app_confirm_dialog.dart';
import 'package:spendly/core/widgets/app_modal_surface.dart';
import 'package:spendly/core/widgets/dialog_actions_row.dart';
import 'package:spendly/core/widgets/noir_header.dart';
import 'package:spendly/features/activity/data/repositories/activity_repository_impl.dart';
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
    const bg = Color(0xFF0E0E0E);
    const divider = Color(0xFF2A2A2A);
    const primary = Colors.white;
    const secondary = Color(0xFFBBBBBB);
    const muted = Color(0xFF8F8F8F);

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
      appBar: NoirHeader(
        showLeading: true,
        leadingIcon: Icons.arrow_back,
        onLeadingTap: () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            context.go('/home');
          }
        },
        showProfileAction: false,
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
              _ProfilePhoto(
                imageUrl: imageUrl,
                backgroundColor: const Color(0xFF323A44),
                iconColor: const Color(0xFFD9DEE3),
              ),
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
          const _SectionLabel('PREFERENCES', color: secondary),
          const Divider(color: divider, height: 26),
          _ProfileRow(
            icon: AppIcons.user,
            title: 'Account',
            onTap: () => _editAccount(context, ref),
            textColor: primary,
            iconColor: muted,
            dividerColor: divider,
          ),
          _ProfileRow(
            icon: AppIcons.notifications,
            title: 'Notifications',
            onTap: () => context.push('/notifications'),
            textColor: primary,
            iconColor: muted,
            dividerColor: divider,
          ),
          _ProfileRow(
            icon: AppIcons.categories,
            title: 'Categories',
            onTap: () => context.push('/categories'),
            textColor: primary,
            iconColor: muted,
            dividerColor: divider,
          ),
          _ProfileRow(
            icon: AppIcons.money,
            title: 'Lend & Borrow',
            subtitle: 'Track people and settlements',
            onTap: () => context.go('/lend'),
            textColor: primary,
            subtitleColor: muted,
            iconColor: muted,
            dividerColor: divider,
          ),
          _ProfileRow(
            icon: AppIcons.repeat,
            title: 'Recurring',
            subtitle: 'Automate repeating expenses',
            onTap: () => context.push('/recurring'),
            textColor: primary,
            subtitleColor: muted,
            iconColor: muted,
            dividerColor: divider,
          ),
          _ProfileRow(
            icon: AppIcons.history,
            title: 'Activity & Screen Time',
            subtitle: 'Audit logs and app usage',
            onTap: () => context.push('/activity'),
            textColor: primary,
            subtitleColor: muted,
            iconColor: muted,
            dividerColor: divider,
          ),
          const SizedBox(height: 24),
          const _SectionLabel('PRIVACY & LOCKS', color: secondary),
          const Divider(color: divider, height: 26),
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
            iconColor: muted,
            dividerColor: divider,
          ),
          _ProfileRow(
            icon: AppIcons.upload,
            title: 'Import Data',
            subtitle: 'Restore from a Spendly JSON backup',
            onTap: () => _openImport(context, ref),
            textColor: primary,
            subtitleColor: muted,
            iconColor: muted,
            dividerColor: divider,
          ),
          _ProfileRow(
            icon: AppIcons.trash,
            title: 'Erase All Data',
            subtitle: 'Reset app to a clean start',
            onTap: () => _eraseAllData(context, ref),
            textColor: primary,
            subtitleColor: muted,
            iconColor: const Color(0xFFFF8D8D),
            dividerColor: divider,
          ),
          const SizedBox(height: 24),
          const _SectionLabel('DATA & SYSTEM', color: secondary),
          const Divider(color: divider, height: 26),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              border: Border.all(color: divider),
              color: const Color(0xFF0E0E0E),
              borderRadius: BorderRadius.circular(AppRadii.lg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cloud Sync',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  cloudSync?.isConnected == true
                      ? 'Connected: ${cloudSync?.connectedEmail ?? '-'}'
                      : 'Not connected',
                  style: const TextStyle(color: muted, fontSize: 12),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  cloudSync?.lastBackupAt == null
                      ? 'Last backup: never'
                      : 'Last backup: ${DateFormat('dd MMM, hh:mm a').format(cloudSync!.lastBackupAt!)}',
                  style: const TextStyle(color: muted, fontSize: 12),
                ),
                const SizedBox(height: AppSpacing.smPlus),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Automatic daily backup',
                    style: TextStyle(fontSize: 14),
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
                      onPressed: cloudSync?.isConnected == true
                          ? () async {
                              await _runCloudAction(
                                context,
                                () => ref
                                    .read(cloudSyncControllerProvider.notifier)
                                    .restoreFromDrive(),
                                successMessage:
                                    'Restore completed successfully.',
                                failureMessage:
                                    'Restore failed. Please try again.',
                              );
                            }
                          : null,
                      child: const Text('Restore'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Budget alerts',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Show in-app budget warning notifications',
              style: TextStyle(fontSize: 12),
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
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Daily reminder',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Receive a push reminder every day',
              style: TextStyle(fontSize: 12),
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
          const SizedBox(height: 26),
          SizedBox(
            height: 56,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: bg,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
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
          const Center(
            child: Text(
              'Version 1.1.2',
              style: TextStyle(color: muted, fontSize: 14),
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
                    color: const Color(0xFF6A6A6A),
                  ),
                ),
                const SizedBox(height: AppSpacing.smPlus),
                Text('Account', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                const Text(
                  'Update your primary profile details.',
                  style: TextStyle(color: Color(0xFF9B9B9B), fontSize: 12),
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
      builder: (dialogContext) => Theme(
        data: Theme.of(dialogContext).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Colors.white,
            onPrimary: Colors.black,
            surface: Color(0xFF0E0E0E),
            onSurface: Colors.white,
          ),
          dialogTheme: const DialogThemeData(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            backgroundColor: Color(0xFF0E0E0E),
          ),
        ),
        child: AlertDialog(
          title: const Text('Export JSON'),
          content: SizedBox(
            width: AppModalSizes.dialogContentWidth,
            child: SingleChildScrollView(child: SelectableText(payload)),
          ),
          actions: [
            DialogActionsRow(
              cancelText: 'Close',
              confirmText: 'Copy',
              onCancel: () => Navigator.pop(dialogContext),
              onConfirm: () {
                Clipboard.setData(ClipboardData(text: payload));
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('JSON copied to clipboard')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openImport(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => Theme(
        data: Theme.of(dialogContext).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Colors.white,
            onPrimary: Colors.black,
            surface: Color(0xFF0E0E0E),
            onSurface: Colors.white,
          ),
          dialogTheme: const DialogThemeData(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            backgroundColor: Color(0xFF0E0E0E),
          ),
        ),
        child: AlertDialog(
          title: const Text('Import JSON'),
          content: SizedBox(
            width: AppModalSizes.dialogContentWidth,
            child: TextField(
              controller: controller,
              maxLines: 14,
              decoration: const InputDecoration(
                hintText: 'Paste your exported JSON here',
              ),
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
                await ref.read(settingsRepositoryProvider).importJson(raw);
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Import completed')),
                );
              },
            ),
          ],
        ),
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
    required this.backgroundColor,
    required this.iconColor,
  });

  final String? imageUrl;
  final Color backgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      color: backgroundColor,
      child: imageUrl != null
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Icon(Icons.account_box, size: 44, color: iconColor),
            )
          : Icon(Icons.account_box, size: 44, color: iconColor),
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
      padding: const EdgeInsets.symmetric(vertical: 14),
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
                  : const Color(0xFF0E0E0E),
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(
                color: enabled
                    ? const Color(0xFF2F6F46)
                    : const Color(0xFF2A2A2A),
              ),
            ),
            child: Icon(
              AppIcons.shield,
              color: enabled
                  ? const Color(0xFF57F28F)
                  : const Color(0xFF8F8F8F),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
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
                  style: TextStyle(color: Color(0xFF8F8F8F), fontSize: 12),
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
        color: const Color(0xFF0E0E0E),
        border: Border.all(color: const Color(0xFF303030)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(AppIcons.receipt, size: 14, color: Color(0xFFD7D7D7)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFE7E7E7),
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
        color: const Color(0xFF0E0E0E),
        border: Border.all(color: const Color(0xFF292929)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(AppIcons.history, size: 14, color: Color(0xFFBDBDBD)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFD4D4D4),
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
          style: const TextStyle(
            color: Color(0xFFB3B3B3),
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
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color textColor;
  final Color iconColor;
  final Color dividerColor;
  final Color? subtitleColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: dividerColor)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Icon(
                icon,
                color: iconColor == const Color(0xFFFF8D8D)
                    ? iconColor
                    : Colors.white,
                size: 20,
              ),
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
