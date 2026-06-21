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
      appBar: NoirHeader(
        showLeading: true,
        leadingIcon: Icons.arrow_back,
        onLeadingTap: () => Navigator.of(context).maybePop(),
        showProfileAction: false,
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
            'Recent alerts and activity updates.',
            style: TextStyle(color: context.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 18),
          const Divider(),
          if (summary != null && summary.remainingBudget < 0)
            _NoticeTile(
              title: 'Budget exceeded',
              message:
                  'You are over budget by ${Formatters.currency(summary.remainingBudget.abs())} this month.',
              color: const Color(0xFFF55C5C),
            ),
          if (recent.isNotEmpty)
            _NoticeTile(
              title: 'Latest transaction',
              message:
                  '${recent.first.type.name == 'income' ? 'Income' : 'Expense'} of ${Formatters.currency(recent.first.amount)} added.',
              color: const Color(0xFF3DD07B),
            ),
          _NoticeTile(
            title: 'Push notifications',
            message:
                'Daily reminder: ${(settings?.dailyReminderEnabled ?? false) ? 'ON' : 'OFF'} | Budget alerts: ${(settings?.budgetAlertsEnabled ?? false) ? 'ON' : 'OFF'}',
            color: context.textSecondary,
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton(
              onPressed: () => context.push('/settings'),
              child: const Text('Open Notification Settings'),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: context.border),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: TextStyle(fontSize: 13, color: context.textSecondary),
          ),
        ],
      ),
    );
  }
}
