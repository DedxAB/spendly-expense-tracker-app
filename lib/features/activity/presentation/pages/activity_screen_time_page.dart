import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:spendly/core/theme/app_design_tokens.dart';
import 'package:spendly/core/theme/app_icons.dart';
import 'package:spendly/core/theme/app_typography.dart';
import 'package:spendly/core/widgets/noir_header.dart';
import 'package:spendly/features/activity/data/repositories/activity_repository_impl.dart';

class ActivityScreenTimePage extends ConsumerWidget {
  const ActivityScreenTimePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usage = ref.watch(allUsageDaysProvider);
    final events = ref.watch(recentActivityEventsProvider);

    return Scaffold(
      appBar: NoirHeader(
        showLeading: true,
        leadingIcon: AppIcons.chevronLeft,
        onLeadingTap: () => context.pop(),
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
          Text(
            'Activity & Screen Time',
            style: AppTypography.screenTitle(context),
          ),
          const SizedBox(height: 6),
          Text(
            'Audit logs and app usage for your recent Spendly activity.',
            style: TextStyle(color: context.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: AppSpacing.md),
          usage.when(
            data: (items) => _ScreenTimeCard(days: items),
            loading: () => const SizedBox(
              height: 160,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => const Text('Screen time unavailable'),
          ),
          const SizedBox(height: AppSpacing.mdPlus),
          Text(
            'Diagnostic Audit Trail',
            style: AppTypography.sectionTitle(context),
          ),
          const SizedBox(height: AppSpacing.sm),
          events.when(
            data: (items) {
              if (items.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Text(
                    'No recent activity yet',
                    style: TextStyle(color: context.textSecondary),
                  ),
                );
              }
              return Column(
                children: [
                  for (final event in items) _ActivityEventRow(event: event),
                ],
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.only(top: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => const Text('Activity trail unavailable'),
          ),
        ],
      ),
    );
  }
}

class _ScreenTimeCard extends StatelessWidget {
  const _ScreenTimeCard({required this.days});

  final List<AppUsageDayEntry> days;

  @override
  Widget build(BuildContext context) {
    final todayKey = _dateKey(DateTime.now());
    final today = days.fold<int>(
      0,
      (sum, day) => day.dateKey == todayKey ? day.totalSeconds : sum,
    );
    final lifetime = days.fold<int>(0, (sum, day) => sum + day.totalSeconds);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.surface,
        border: Border.all(color: context.border),
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Screen Time Log',
                style: AppTypography.sectionTitle(context),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0E2B1B),
                  border: Border.all(color: const Color(0xFF166E3C)),
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: const Text(
                  'LIVE',
                  style: TextStyle(
                    color: Color(0xFF3DD07B),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _ScreenTimeMetricCard(
                  label: 'TODAY',
                  value: _formatDuration(today),
                  caption: 'Usage recorded today',
                ),
              ),
              const SizedBox(width: AppSpacing.smPlus),
              Expanded(
                child: _ScreenTimeMetricCard(
                  label: 'ALL TIME',
                  value: _formatDuration(lifetime),
                  caption: 'All-time app usage',
                  valueColor: const Color(0xFF8EA0FF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    if (hours > 0) return '${hours}h ${minutes}m';
    if (minutes > 0) return '${minutes}m';
    return '${seconds}s';
  }

  String _dateKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}

class _ScreenTimeMetricCard extends StatelessWidget {
  const _ScreenTimeMetricCard({
    required this.label,
    required this.value,
    required this.caption,
    this.valueColor,
  });

  final String label;
  final String value;
  final String caption;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 118,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surfaceAlt,
        border: Border.all(color: context.border),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: context.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const Spacer(),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: valueColor ?? context.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            caption.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: context.textSecondary, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _ActivityEventRow extends StatelessWidget {
  const _ActivityEventRow({required this.event});

  final ActivityEventEntry event;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 4),
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: context.textPrimary,
                borderRadius: BorderRadius.circular(AppRadii.pill),
                border: Border.all(color: context.border),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title.toUpperCase(),
                  style: TextStyle(
                    color: context.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  event.description,
                  style: TextStyle(
                    color: context.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _timeLabel(event.occurredAt),
            textAlign: TextAlign.right,
            style: TextStyle(
              color: context.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _timeLabel(DateTime at) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(at.year, at.month, at.day);
    final prefix = eventDay == today
        ? 'TODAY'
        : eventDay == today.subtract(const Duration(days: 1))
        ? 'YDAY'
        : DateFormat('MMM d').format(at).toUpperCase();
    return '$prefix\n${DateFormat('h:mm a').format(at)}';
  }
}
