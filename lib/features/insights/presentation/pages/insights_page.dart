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

    final expense = (incomeExpense['expense'] ?? 0).toDouble();

    return Scaffold(
      appBar: NoirHeader(
        showLeading: true,
        leadingIcon: AppIcons.bell,
        onLeadingTap: () => context.push('/notifications'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
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
              color: const Color(0xFF0B0B0B),
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
                          'VS LAST\nMONTH',
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
                    data: (points) => _TrendChart(
                      points: points,
                      isYearly: ref.watch(insightsViewModeProvider) == InsightsViewMode.yearly,
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, __) =>
                        const Center(child: Text('Trend unavailable')),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderDark),
              color: const Color(0xFF0B0B0B),
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
    if (points.isEmpty) {
      return const Center(child: Text('No trend data'));
    }

    final maxY = points.map((e) => e.value).fold<double>(0, math.max);
    final safeMaxY = maxY <= 0 ? 1.0 : maxY * 1.2;

    return LineChart(
      LineChartData(
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
        lineTouchData: LineTouchData(enabled: true),
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
              reservedSize: 42,
              getTitlesWidget: (value, _) => Text(
                value == 0
                    ? '0'
                    : '${AppConstants.currencySymbol}${(value / 1000).toStringAsFixed(0)}k',
                style: const TextStyle(fontSize: 11, color: Color(0xFFA6A6A6)),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final i = value.toInt();
                if (i < 0 || i >= points.length) return const SizedBox.shrink();
                if (isYearly) {
                  if (i % 2 != 0) return const SizedBox.shrink();
                  return Text(
                    DateFormat('MMM').format(points[i].date),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFFA6A6A6),
                    ),
                  );
                } else {
                  if (i % 7 != 0) return const SizedBox.shrink();
                  return Text(
                    'W${i ~/ 7 + 1}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFFA6A6A6),
                    ),
                  );
                }
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < points.length; i++)
                FlSpot(i.toDouble(), points[i].value),
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
