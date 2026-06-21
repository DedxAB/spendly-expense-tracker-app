import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:spendly/core/theme/app_design_tokens.dart';
import 'package:spendly/core/theme/app_typography.dart';
import 'package:spendly/core/utils/formatters.dart';
import 'package:spendly/features/insights/domain/entities/expense_slice.dart';
import 'package:spendly/features/insights/domain/entities/insight_point.dart';
import 'package:spendly/features/insights/presentation/providers/insights_provider.dart';

class MonthlySummaryCard extends ConsumerWidget {
  const MonthlySummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(insightsSelectedMonthProvider);
    final isYearly =
        ref.watch(insightsViewModeProvider) == InsightsViewMode.yearly;
    final incomeExpense =
        ref.watch(incomeVsExpenseProvider).valueOrNull ??
        const {'income': 0.0, 'expense': 0.0};
    final change = ref.watch(expenseChangePercentProvider).valueOrNull;
    final distribution = ref.watch(expenseDistributionProvider).valueOrNull ?? const [];
    final paymentMode =
        ref.watch(paymentModeBreakdownProvider).valueOrNull ??
            {'upi': 0.0, 'cash': 0.0, 'card': 0.0};
    final monthlyBudget = ref.watch(monthlyBudgetProvider);
    final projected = ref.watch(projectedExpenseProvider).valueOrNull ?? 0.0;
    final trend = ref.watch(dailyTrendProvider).valueOrNull ?? const [];

    final income = (incomeExpense['income'] ?? 0).toDouble();

    final insights = _generateInsights(
      month: month,
      isYearly: isYearly,
      income: income,
      change: change,
      distribution: distribution,
      paymentMode: paymentMode,
      budget: monthlyBudget,
      projected: projected,
      trend: trend,
    );

    if (insights.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(color: context.border),
        color: context.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Color(0xFFFFC857), size: 18),
              const SizedBox(width: 8),
              Text(
                isYearly ? 'Year in Review' : 'Monthly Insights',
                style: AppTypography.sectionTitle(context),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.smPlus),
          ...insights.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '\u2022',
                    style: TextStyle(color: context.textSecondary, fontSize: 14),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      line,
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

List<String> _generateInsights({
  required DateTime month,
  required bool isYearly,
  required double income,
  required double? change,
  required List<ExpenseSlice> distribution,
  required Map<String, double> paymentMode,
  required double budget,
  required double projected,
  required List<InsightPoint> trend,
}) {
  final insights = <String>[];
  final totalExpense = distribution.fold<double>(0, (s, e) => s + e.total);
  if (totalExpense <= 0 && income <= 0) return insights;

  final periodLabel = isYearly
      ? '${month.year}'
      : DateFormat('MMMM yyyy').format(month);

  if (totalExpense > 0) {
    if (change != null) {
      final direction = change >= 0 ? 'up' : 'down';
      final pct = change.abs().toStringAsFixed(1);
      insights.add(
        'Spending in $periodLabel was $pct% $direction compared to the '
        '${isYearly ? 'last year' : 'previous month'}.',
      );
    } else {
      insights.add('This is the first ${isYearly ? 'year' : 'month'} '
          'of tracked spending for $periodLabel.');
    }
  }

  if (income > 0 && totalExpense > 0) {
    final savingsRate = ((income - totalExpense) / income * 100)
        .clamp(0, 100)
        .toStringAsFixed(0);
    if (income > totalExpense) {
      insights.add(
        'You saved $savingsRate% of your income this '
        '${isYearly ? 'year' : 'month'} \u2014 '
        '${Formatters.currency(income - totalExpense)} in total.',
      );
    } else {
      insights.add(
        'Expenses exceeded income by ${Formatters.currency(totalExpense - income)} '
        'this ${isYearly ? 'year' : 'month'}.',
      );
    }
  }

  if (distribution.isNotEmpty) {
    final top = distribution.first;
    final topPct = ((top.total / totalExpense) * 100).toStringAsFixed(0);
    insights.add(
      'Your biggest expense category was "${
        top.category
      }" at $topPct% of total spending (${Formatters.currency(top.total)}).',
    );
    if (distribution.length >= 3) {
      final top3 = distribution.take(3).fold<double>(0, (s, e) => s + e.total);
      final top3Pct = ((top3 / totalExpense) * 100).toStringAsFixed(0);
      insights.add(
        'Your top 3 categories accounted for $top3Pct% of all outflows.',
      );
    }
  }

  if (paymentMode.values.any((v) => v > 0)) {
    final primary = paymentMode.entries.reduce(
      (a, b) => a.value >= b.value ? a : b,
    );
    if (primary.value > 0) {
      insights.add(
        '${_paymentModeLabel(primary.key)} was your most used payment method '
        'at ${primary.value.toStringAsFixed(0)}% of transactions.',
      );
    }
  }

  if (budget > 0 && totalExpense > 0) {
    final budgetPct = (totalExpense / budget * 100).toStringAsFixed(0);
    if (totalExpense <= budget) {
      insights.add(
        'You used $budgetPct% of your monthly budget, leaving '
        '${Formatters.currency(budget - totalExpense)} unspent.',
      );
    } else {
      insights.add(
        'You exceeded your monthly budget by '
        '${Formatters.currency(totalExpense - budget)} ($budgetPct% usage).',
      );
    }
    if (projected > 0 && projected > budget) {
      insights.add(
        'At the current rate, you are projected to exceed your budget by '
        '${Formatters.currency(projected - budget)} by month end.',
      );
    }
  }

  if (trend.length >= 2) {
    final peak = trend.reduce((a, b) => a.value >= b.value ? a : b);
    if (peak.value > 0) {
      final peakLabel = isYearly
          ? DateFormat('MMMM').format(peak.date)
          : 'Week ${((peak.date.day - 1) ~/ 7) + 1}';
      insights.add(
        'Your peak spending ${
          isYearly ? 'month' : 'week'
        } was $peakLabel at ${Formatters.currency(peak.value)}.',
      );
    }
  }

  if (totalExpense > 0 && distribution.length >= 2) {
    final smallest = distribution.last;
    if (smallest.total > 0) {
      insights.add(
        'Your lowest spending category was "${smallest.category}" '
        '(${Formatters.currency(smallest.total)}).',
      );
    }
  }

  return insights;
}

String _paymentModeLabel(String key) {
  switch (key) {
    case 'upi':
      return 'UPI';
    case 'cash':
      return 'Cash';
    case 'card':
      return 'Card';
    default:
      return key;
  }
}
