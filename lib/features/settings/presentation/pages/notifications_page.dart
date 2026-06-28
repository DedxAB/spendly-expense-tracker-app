import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spendly/core/theme/app_design_tokens.dart';
import 'package:spendly/core/theme/app_typography.dart';
import 'package:spendly/core/utils/formatters.dart';
import 'package:spendly/core/widgets/noir_header.dart';
import 'package:spendly/features/home/presentation/providers/home_provider.dart';
import 'package:spendly/features/settings/presentation/providers/settings_provider.dart';
import 'package:spendly/features/transactions/presentation/providers/transactions_provider.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(dashboardSummaryProvider).valueOrNull;
    final recent =
        ref.watch(recentTransactionsProvider).valueOrNull ?? const [];
    final settings = ref.watch(settingsStreamProvider).valueOrNull;

    return Scaffold(
      backgroundColor: context.background,
      appBar: NoirHeader(
        title: 'Notifications',
        showLeading: true,
        leadingIcon: Icons.arrow_back,
        onLeadingTap: () => Navigator.of(context).maybePop(),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.smPlus,
          AppSpacing.mdPlus,
          AppSpacing.smPlus,
          AppSpacing.md,
        ),
        children: [
          Text('Notifications', style: AppTypography.screenTitle(context)),
          const SizedBox(height: 8),
          Text(
            'Recent alerts and notification status.',
            style: TextStyle(color: context.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 18),
          Divider(color: context.border),

          // Budget exceeded alert
          if (summary != null && summary.remainingBudget < 0)
            _NoticeTile(
              title: 'Budget exceeded',
              message:
                  'You are over budget by ${Formatters.currency(summary.remainingBudget.abs())} this month.',
              color: const Color(0xFFF55C5C),
            ),

          // Latest transaction
          if (recent.isNotEmpty)
            _NoticeTile(
              title: 'Latest transaction',
              message:
                  '${recent.first.type.name == 'income' ? 'Income' : 'Expense'} of ${Formatters.currency(recent.first.amount)} added.',
              color: const Color(0xFF3DD07B),
            ),

          // Notification status
          _NoticeTile(
            title: 'Push notifications',
            message: _buildStatusSummary(settings),
            color: context.textSecondary,
          ),

          const SizedBox(height: 18),
          Text(
            'Notification categories',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          _StatusRow(
            label: 'Budget alerts',
            enabled: settings?.budgetAlertsEnabled ?? false,
          ),
          _StatusRow(
            label: 'Daily reminder',
            enabled: settings?.dailyReminderEnabled ?? false,
            detail: settings?.dailyReminderEnabled == true
                ? 'at ${_formatTime(settings!.dailyReminderTime)}'
                : null,
          ),
          _StatusRow(
            label: 'Recurring bill reminders',
            enabled: settings?.recurringBillRemindersEnabled ?? false,
          ),
          _StatusRow(
            label: 'Lend/borrow due reminders',
            enabled: settings?.lendDueRemindersEnabled ?? false,
          ),
          _StatusRow(
            label: 'Goal target reminders',
            enabled: settings?.goalRemindersEnabled ?? false,
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton(
              onPressed: () => context.push('/settings'),
              style: OutlinedButton.styleFrom(
                foregroundColor: context.textPrimary,
                side: BorderSide(color: context.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
              ),
              child: const Text('Open Notification Settings'),
            ),
          ),
        ],
      ),
    );
  }

  String _buildStatusSummary(dynamic settings) {
    final parts = <String>[];
    if (settings?.budgetAlertsEnabled == true) parts.add('Budget alerts');
    if (settings?.dailyReminderEnabled == true) parts.add('Daily reminder');
    if (settings?.recurringBillRemindersEnabled == true) parts.add('Recurring bills');
    if (settings?.lendDueRemindersEnabled == true) parts.add('Lend/borrow');
    if (settings?.goalRemindersEnabled == true) parts.add('Goals');
    if (parts.isEmpty) return 'All notification categories are OFF';
    return 'ON: ${parts.join(', ')}';
  }

  String _formatTime(int minutesSinceMidnight) {
    final h = minutesSinceMidnight ~/ 60;
    final m = minutesSinceMidnight % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.label,
    required this.enabled,
    this.detail,
  });

  final String label;
  final bool enabled;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            enabled ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: enabled ? const Color(0xFF3DD07B) : context.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: context.textPrimary,
              ),
            ),
          ),
          if (detail != null)
            Text(
              detail!,
              style: TextStyle(
                fontSize: 12,
                color: context.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}

class _NoticeTile extends StatelessWidget {
  const _NoticeTile({
    required this.title,
    required this.message,
    required this.color,
  });

  final String title;
  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: context.surface,
        border: Border.all(color: context.border),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppRadii.md - 1),
                  bottomLeft: Radius.circular(AppRadii.md - 1),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 13,
                        color: context.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
