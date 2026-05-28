import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:spendly/core/constants/app_constants.dart';
import 'package:spendly/core/theme/app_design_tokens.dart';
import 'package:spendly/core/theme/app_icons.dart';
import 'package:spendly/core/theme/app_typography.dart';
import 'package:spendly/core/utils/formatters.dart';
import 'package:spendly/core/widgets/noir_header.dart';
import 'package:spendly/features/insights/domain/entities/expense_slice.dart';
import 'package:spendly/features/insights/domain/entities/insight_point.dart';
import 'package:spendly/features/insights/presentation/providers/insights_provider.dart';

class InsightsPage extends ConsumerWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(insightsSelectedMonthProvider);
    final incomeExpense =
        ref.watch(incomeVsExpenseProvider).valueOrNull ??
        const {'income': 0.0, 'expense': 0.0};
    final trend = ref.watch(dailyTrendProvider);
    final distribution = ref.watch(expenseDistributionProvider);
    final change = ref.watch(expenseChangePercentProvider).valueOrNull ?? 0.0;
    final isYearly =
        ref.watch(insightsViewModeProvider) == InsightsViewMode.yearly;

    final expense = (incomeExpense['expense'] ?? 0).toDouble();

    return Scaffold(
      appBar: NoirHeader(
        showLeading: true,
        leadingIcon: AppIcons.bell,
        onLeadingTap: () => context.push('/notifications'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.smPlus,
          AppSpacing.md,
          AppSpacing.smPlus,
          AppSpacing.md,
        ),
        children: [
          Text('Monthly Spending', style: AppTypography.screenTitle(context)),
          const SizedBox(height: AppSpacing.smPlus),
          Text(
            'A detailed review of your outbound\ncapital for the current period.\nIdentifying areas of excess and\nstructural inefficiencies.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 16,
              color: const Color(0xFFB5B5B5),
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderDark),
              color: const Color(0xFF0E0E0E),
              borderRadius: BorderRadius.circular(AppRadii.lg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TOTAL OUTFLOW',
                            style: AppTypography.metadata(context),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            Formatters.currency(expense),
                            style: AppTypography.amount(context, fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'VS LAST MONTH',
                          style: TextStyle(
                            letterSpacing: 1.6,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}%',
                          style: AppTypography.amount(
                            context,
                            fontSize: 18,
                            color: change >= 0
                                ? const Color(0xFFFFB3A8)
                                : const Color(0xFF8AF0A0),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.smPlus),
                const Divider(color: AppColors.borderDark),
                const SizedBox(height: 8),
                SizedBox(
                  height: 240,
                  child: trend.when(
                    data: (points) =>
                        _TrendChart(points: points, isYearly: isYearly),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, __) =>
                        const Center(child: Text('Trend unavailable')),
                  ),
                ),
                trend.when(
                  data: (points) => _TrendSnapshot(
                    points: points,
                    period: month,
                    isYearly: isYearly,
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderDark),
              color: const Color(0xFF0E0E0E),
              borderRadius: BorderRadius.circular(AppRadii.lg),
            ),
            child: distribution.when(
              data: (items) => _CategoryBreakdown(items: items),
              loading: () => const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => const Text('Category breakdown unavailable'),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.center,
            child: Text(
              DateFormat('MMMM yyyy').format(month),
              style: const TextStyle(color: Color(0xFF8A8A8A)),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendChart extends StatelessWidget {
  const _TrendChart({required this.points, required this.isYearly});

  final List<InsightPoint> points;
  final bool isYearly;

  @override
  Widget build(BuildContext context) {
    final chartPoints = _buildTrendChartPoints(points, isYearly);
    if (chartPoints.isEmpty) {
      return const Center(child: Text('No spending trend yet'));
    }

    final maxY = chartPoints.map((e) => e.value).fold<double>(0, math.max);
    final safeMaxY = maxY <= 0 ? 1.0 : maxY * 1.2;

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: math.max(0, chartPoints.length - 1).toDouble(),
        minY: 0,
        maxY: safeMaxY,
        gridData: FlGridData(
          show: true,
          horizontalInterval: safeMaxY / 5,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: Color(0xFF252525), strokeWidth: 0.8),
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(
          show: true,
          border: const Border(
            bottom: BorderSide(color: Colors.white),
            left: BorderSide(color: AppColors.borderDark),
          ),
        ),
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => const Color(0xFFF4F4F4),
            tooltipRoundedRadius: 8,
            tooltipPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            tooltipMargin: 12,
            maxContentWidth: 180,
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
              final index = spot.x.round();
              if (index < 0 || index >= chartPoints.length) return null;
              return _tooltipItem(chartPoints, index);
            }).toList(),
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: safeMaxY / 5,
              reservedSize: 54,
              getTitlesWidget: (value, _) => Text(
                _formatAxisAmount(value),
                style: const TextStyle(fontSize: 11, color: Color(0xFFA6A6A6)),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 28,
              getTitlesWidget: (value, _) {
                final i = value.round();
                if (i < 0 || i >= chartPoints.length || value != i) {
                  return const SizedBox.shrink();
                }
                return Text(
                  chartPoints[i].label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFFA6A6A6),
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < chartPoints.length; i++)
                FlSpot(i.toDouble(), chartPoints[i].value),
            ],
            isCurved: true,
            color: Colors.white,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (_, __, ___, ____) =>
                  FlDotCirclePainter(radius: 4.5, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  LineTooltipItem _tooltipItem(List<_TrendChartPoint> chartPoints, int index) {
    final point = chartPoints[index];
    final average = point.daysInPeriod <= 0
        ? 0.0
        : point.value / point.daysInPeriod;
    final comparison = _comparison(chartPoints, index);

    return LineTooltipItem(
      '${point.title}\n',
      const TextStyle(
        color: Colors.black,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
      textAlign: TextAlign.left,
      children: [
        TextSpan(
          text: '${Formatters.currency(point.value)} spent\n',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        TextSpan(
          text: '${point.periodLabel}\n',
          style: const TextStyle(
            color: Color(0xFF555555),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        TextSpan(
          text: '${Formatters.currency(average)} per day',
          style: const TextStyle(
            color: Color(0xFF555555),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (comparison != null)
          TextSpan(
            text: '\n${comparison.text}',
            style: TextStyle(
              color: comparison.color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  _TrendComparison? _comparison(List<_TrendChartPoint> chartPoints, int index) {
    if (index == 0) return null;

    final current = chartPoints[index].value;
    final previous = chartPoints[index - 1].value;
    final previousLabel = isYearly ? 'previous month' : 'previous week';
    if (previous <= 0 && current <= 0) {
      return _TrendComparison(
        text: 'same as $previousLabel',
        color: const Color(0xFF555555),
      );
    }
    if (previous <= 0) {
      return _TrendComparison(
        text: '\u25B2 from no spend in $previousLabel',
        color: const Color(0xFFFF6F61),
      );
    }

    final change = ((current - previous) / previous) * 100;
    if (change.abs() < 0.05) {
      return _TrendComparison(
        text: 'same as $previousLabel',
        color: const Color(0xFF555555),
      );
    }
    final direction = change > 0 ? '\u25B2' : '\u25BC';
    return _TrendComparison(
      text: '$direction ${change.abs().toStringAsFixed(0)}% vs $previousLabel',
      color: change > 0 ? const Color(0xFFFF6F61) : const Color(0xFF19C37D),
    );
  }

  String _formatAxisAmount(double value) {
    if (value <= 0) return '0';
    if (value < 1000) {
      return '${AppConstants.currencySymbol}${value.toStringAsFixed(0)}';
    }
    return '${AppConstants.currencySymbol}${(value / 1000).toStringAsFixed(1)}k';
  }
}

class _TrendSnapshot extends StatelessWidget {
  const _TrendSnapshot({
    required this.points,
    required this.period,
    required this.isYearly,
  });

  final List<InsightPoint> points;
  final DateTime period;
  final bool isYearly;

  @override
  Widget build(BuildContext context) {
    final chartPoints = _buildTrendChartPoints(points, isYearly);
    if (chartPoints.isEmpty) return const SizedBox.shrink();

    final total = chartPoints.fold<double>(0, (sum, e) => sum + e.value);
    final peak = chartPoints.reduce((a, b) => a.value >= b.value ? a : b);
    final averageBase = isYearly
        ? _elapsedMonthsInYear(period)
        : _elapsedDaysInMonth(period);
    final average = averageBase <= 0 ? 0.0 : total / averageBase;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.smPlus),
      child: Row(
        children: [
          Expanded(
            child: _SnapshotTile(
              label: isYearly ? 'ACTIVE MONTHS' : 'ACTIVE WEEKS',
              value: chartPoints.length.toString(),
              caption: isYearly ? 'with spend' : 'with spend',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _SnapshotTile(
              label: isYearly ? 'AVG / MONTH' : 'AVG / DAY',
              value: Formatters.currency(average),
              caption: isYearly ? 'this year' : 'this period',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _SnapshotTile(
              label: isYearly ? 'PEAK MONTH' : 'PEAK WEEK',
              value: Formatters.currency(peak.value),
              caption: peak.label,
            ),
          ),
        ],
      ),
    );
  }
}

class _SnapshotTile extends StatelessWidget {
  const _SnapshotTile({
    required this.label,
    required this.value,
    required this.caption,
  });

  final String label;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0E0E0E),
        border: Border.all(color: const Color(0xFF252525)),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF8F8F8F),
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const Spacer(),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFFB2B2B2), fontSize: 11),
          ),
        ],
      ),
    );
  }
}

List<_TrendChartPoint> _buildTrendChartPoints(
  List<InsightPoint> points,
  bool isYearly,
) {
  if (points.isEmpty) return const [];

  if (isYearly) {
    return [
      for (final point in points)
        if (point.value > 0)
          _TrendChartPoint(
            label: DateFormat('MMM').format(point.date),
            title: DateFormat('MMMM yyyy').format(point.date),
            periodLabel: 'Monthly spend',
            daysInPeriod: DateTime(
              point.date.year,
              point.date.month + 1,
              0,
            ).day,
            value: point.value,
          ),
    ];
  }

  final month = points.first.date;
  final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
  final weekCount = ((daysInMonth - 1) ~/ 7) + 1;
  final totals = List<double>.filled(weekCount, 0);

  for (final point in points) {
    final weekIndex = (point.date.day - 1) ~/ 7;
    if (weekIndex >= 0 && weekIndex < totals.length) {
      totals[weekIndex] += point.value;
    }
  }

  return [
    for (var i = 0; i < totals.length; i++)
      if (totals[i] > 0)
        _TrendChartPoint(
          label: 'w${i + 1}',
          title: 'Week ${i + 1}',
          periodLabel: _weekRangeLabel(month, i),
          daysInPeriod: _daysInWeekBucket(daysInMonth, i),
          value: totals[i],
        ),
  ];
}

String _weekRangeLabel(DateTime month, int weekIndex) {
  final startDay = (weekIndex * 7) + 1;
  final lastDayOfMonth = DateTime(month.year, month.month + 1, 0).day;
  final endDay = math.min(startDay + 6, lastDayOfMonth);
  final monthLabel = DateFormat('MMM').format(month);
  return '$startDay-$endDay $monthLabel';
}

int _daysInWeekBucket(int daysInMonth, int weekIndex) {
  final startDay = (weekIndex * 7) + 1;
  final endDay = math.min(startDay + 6, daysInMonth);
  return math.max(0, endDay - startDay + 1);
}

int _elapsedDaysInMonth(DateTime period) {
  final now = DateTime.now();
  final daysInMonth = DateTime(period.year, period.month + 1, 0).day;
  if (period.year == now.year && period.month == now.month) {
    return math.min(now.day, daysInMonth);
  }
  return daysInMonth;
}

int _elapsedMonthsInYear(DateTime period) {
  final now = DateTime.now();
  if (period.year == now.year) return now.month;
  return 12;
}

class _TrendChartPoint {
  const _TrendChartPoint({
    required this.label,
    required this.title,
    required this.periodLabel,
    required this.daysInPeriod,
    required this.value,
  });

  final String label;
  final String title;
  final String periodLabel;
  final int daysInPeriod;
  final double value;
}

class _TrendComparison {
  const _TrendComparison({required this.text, required this.color});

  final String text;
  final Color color;
}

class _CategoryBreakdown extends StatelessWidget {
  const _CategoryBreakdown({required this.items});

  final List<ExpenseSlice> items;

  @override
  Widget build(BuildContext context) {
    final total = items.fold<double>(0, (sum, e) => sum + e.total);
    final sorted = [...items]..sort((a, b) => b.total.compareTo(a.total));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Category Breakdown', style: AppTypography.sectionTitle(context)),
        const SizedBox(height: 10),
        const Divider(color: AppColors.borderDark),
        const SizedBox(height: 8),
        ...sorted.take(5).map((slice) {
          final pct = total <= 0 ? 0 : (slice.total / total) * 100;
          final isTop = sorted.first == slice;
          return Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        slice.category,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    Text(
                      '${pct.toStringAsFixed(0)}%',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (pct / 100).clamp(0, 1),
                  minHeight: 6,
                  color: isTop ? const Color(0xFFFFB3A8) : Colors.white,
                  backgroundColor: const Color(0xFF2B2B2B),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    Formatters.currency(slice.total),
                    style: TextStyle(
                      color: isTop
                          ? const Color(0xFFFFB3A8)
                          : const Color(0xFFCFCFCF),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
