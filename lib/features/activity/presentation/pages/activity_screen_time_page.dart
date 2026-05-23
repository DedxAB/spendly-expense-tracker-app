import 'dart:math' as math;

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
    final usage = ref.watch(recentUsageDaysProvider);
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
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
        ),
        children: [
          Text(
            'Activity & Screen Time',
            style: AppTypography.screenTitle(context),
          ),
          const SizedBox(height: 6),
          const Text(
            'Audit logs and app usage for your recent Spendly activity.',
            style: TextStyle(color: Color(0xFFB5B5B5), fontSize: 14),
          ),
          const SizedBox(height: AppSpacing.md),
          usage.when(
            data: (items) => _ScreenTimeCard(days: _normalizedUsage(items)),
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
                return const Padding(
                  padding: EdgeInsets.only(top: 24),
                  child: Text(
                    'No recent activity yet',
                    style: TextStyle(color: Color(0xFF8F8F8F)),
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

  List<AppUsageDayEntry> _normalizedUsage(List<AppUsageDayEntry> source) {
    final byKey = {for (final item in source) item.dateKey: item};
    final now = DateTime.now();
    return [
      for (var offset = 3; offset >= 0; offset--)
        byKey[_dateKey(now.subtract(Duration(days: offset)))] ??
            AppUsageDayEntry(
              dateKey: _dateKey(now.subtract(Duration(days: offset))),
              totalSeconds: 0,
              updatedAt: now,
            ),
    ];
  }

  String _dateKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}

class _ScreenTimeCard extends StatelessWidget {
  const _ScreenTimeCard({required this.days});

  final List<AppUsageDayEntry> days;

  @override
  Widget build(BuildContext context) {
    final today = days.isEmpty ? 0 : days.last.totalSeconds;
    final lifetime = days.fold<int>(0, (sum, day) => sum + day.totalSeconds);
    final maxSeconds = days.fold<int>(1, (max, day) {
      return math.max(max, day.totalSeconds);
    });

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0B0B),
        border: Border.all(color: AppColors.borderDark),
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
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'LIVE',
                  style: TextStyle(
                    color: Color(0xFF57F28F),
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
                  label: "TODAY'S TOTAL",
                  value: _formatDuration(today),
                  caption: 'Active session running',
                ),
              ),
              const SizedBox(width: AppSpacing.smPlus),
              Expanded(
                child: _ScreenTimeMetricCard(
                  label: 'LIFETIME USAGE',
                  value: _formatDuration(lifetime),
                  caption: 'All-time logged hours',
                  valueColor: const Color(0xFF8EA0FF),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.smPlus),
          Container(
            height: 104,
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
            decoration: BoxDecoration(
              color: const Color(0xFF090909),
              border: Border.all(color: const Color(0xFF252525)),
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < days.length; i++)
                  Expanded(
                    child: _UsageBar(
                      seconds: days[i].totalSeconds,
                      maxSeconds: maxSeconds,
                      label: i == days.length - 1
                          ? 'TODAY'
                          : i == days.length - 2
                          ? 'YESTERDAY'
                          : '${days.length - 1 - i}D AGO',
                      active: i == days.length - 1,
                    ),
                  ),
              ],
            ),
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
}

class _ScreenTimeMetricCard extends StatelessWidget {
  const _ScreenTimeMetricCard({
    required this.label,
    required this.value,
    required this.caption,
    this.valueColor = Colors.white,
  });

  final String label;
  final String value;
  final String caption;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 118,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF090909),
        border: Border.all(color: const Color(0xFF252525)),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF9D9D9D),
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
              color: valueColor,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            caption.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF9D9D9D), fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _UsageBar extends StatelessWidget {
  const _UsageBar({
    required this.seconds,
    required this.maxSeconds,
    required this.label,
    required this.active,
  });

  final int seconds;
  final int maxSeconds;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final height = seconds <= 0 ? 8.0 : 16 + ((seconds / maxSeconds) * 54);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: 13,
          height: height,
          decoration: BoxDecoration(
            color: active ? Colors.white : const Color(0xFF3B3B3B),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF9D9D9D),
            fontSize: 9,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
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
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderDark)),
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: const Color(0xFF4A4A4A)),
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  event.description,
                  style: const TextStyle(
                    color: Color(0xFFBDBDBD),
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
            style: const TextStyle(
              color: Color(0xFF777777),
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
