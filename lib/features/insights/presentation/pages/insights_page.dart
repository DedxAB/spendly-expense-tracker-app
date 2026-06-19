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
import 'package:spendly/features/insights/domain/entities/expense_slice.dart';
import 'package:spendly/features/insights/domain/entities/insight_point.dart';
import 'package:spendly/features/insights/presentation/providers/insights_provider.dart';
import 'package:spendly/features/user/presentation/providers/user_profile_provider.dart';
import 'package:spendly/features/insights/presentation/services/insights_export_service.dart';

class InsightsPage extends ConsumerWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(insightsSelectedMonthProvider);
    final isYearly =
        ref.watch(insightsViewModeProvider) == InsightsViewMode.yearly;
    final incomeExpense =
        ref.watch(incomeVsExpenseProvider).valueOrNull ??
        const {'income': 0.0, 'expense': 0.0};
    final prevIncomeExpense =
        ref.watch(previousIncomeVsExpenseProvider).valueOrNull;
    final distributionAsync = ref.watch(expenseDistributionProvider);
    final prevDistributionAsync = ref.watch(previousExpenseDistributionProvider);
    final trend = ref.watch(dailyTrendProvider);
    final change = ref.watch(expenseChangePercentProvider).valueOrNull ?? 0.0;
    final projected = ref.watch(projectedExpenseProvider).valueOrNull ?? 0.0;
    final monthlyBudget = ref.watch(monthlyBudgetProvider);

    final income = (incomeExpense['income'] ?? 0).toDouble();
    final expense = (incomeExpense['expense'] ?? 0).toDouble();
    final prevExpense =
        ((prevIncomeExpense?['expense'] ?? 0).toDouble());

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        centerTitle: true,
        title: Text(
          'Spendly',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.9,
          ),
        ),
        leading: IconButton(
          icon: Icon(AppIcons.bell, size: 22, color: const Color(0xFFFFC857)),
          onPressed: () => context.push('/notifications'),
        ),
        leadingWidth: 56,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () => context.push('/settings'),
              borderRadius: BorderRadius.zero,
              child: Consumer(builder: (context, ref, _) {
                final profile = ref.watch(userProfileProvider).valueOrNull;
                final imageUrl = (profile?.imageUrl?.trim().isNotEmpty ?? false)
                    ? profile!.imageUrl!.trim()
                    : null;
                return Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    border: Border.all(color: AppColors.borderDark),
                  ),
                  child: imageUrl == null
                      ? const Icon(Icons.person, size: 18, color: Color(0xFFABABAB))
                      : Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.person, size: 18, color: Color(0xFFABABAB)),
                        ),
                );
              }),
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: AppColors.borderDark),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.smPlus,
          AppSpacing.md,
          AppSpacing.smPlus,
          AppSpacing.md,
        ),
        children: [
          _PeriodNavigator(month: month, isYearly: isYearly),
          const SizedBox(height: AppSpacing.smPlus),
          _BurnRateCard(
            expense: expense,
            projected: projected,
            budget: monthlyBudget,
            month: month,
            isYearly: isYearly,
          ),
          const SizedBox(height: AppSpacing.md),
          _SummaryStrip(income: income, expense: expense, prevExpense: prevExpense),
          const SizedBox(height: AppSpacing.md),
          distributionAsync.when(
            data: (distribution) => prevDistributionAsync.when(
              data: (prevDistribution) => _CategoryWatch(
                distribution: distribution,
                previous: prevDistribution,
                totalExpense: expense,
              ),
              loading: () => const _CategoryWatchSkeleton(),
              error: (_, __) => _CategoryWatch(
                distribution: distribution,
                previous: const [],
                totalExpense: expense,
              ),
            ),
            loading: () => const _CategoryWatchSkeleton(),
            error: (_, __) => const SizedBox.shrink(),
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
                Text('Trend', style: AppTypography.sectionTitle(context)),
                const SizedBox(height: AppSpacing.smPlus),
                SizedBox(
                  height: 200,
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
          _WhatsChanged(
            change: change,
            expense: expense,
            prevExpense: prevExpense,
            budget: monthlyBudget,
            projected: projected,
          ),
          const SizedBox(height: AppSpacing.lg),
          _ExportButton(onPressed: () => _exportPdf(context, ref)),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

Future<void> _exportPdf(BuildContext context, WidgetRef ref) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(
      child: SizedBox(
        width: 48,
        height: 48,
        child: CircularProgressIndicator(strokeWidth: 3),
      ),
    ),
  );

  final month = ref.read(insightsSelectedMonthProvider);
  final isYearly = ref.read(insightsViewModeProvider) == InsightsViewMode.yearly;
  final incomeExpense = ref.read(incomeVsExpenseProvider).valueOrNull ??
      const {'income': 0.0, 'expense': 0.0};
  final distribution =
      ref.read(expenseDistributionProvider).valueOrNull ?? const [];
  final change = ref.read(expenseChangePercentProvider).valueOrNull;
  final budget = ref.read(monthlyBudgetProvider);
  final projected = ref.read(projectedExpenseProvider).valueOrNull ?? 0.0;
  final trend =
      ref.read(dailyTrendProvider).valueOrNull ?? const [];
  final yearlyBars =
      ref.read(yearlyIncomeVsExpenseProvider).valueOrNull ?? const [];

  final service = InsightsExportService();
  try {
    await service.exportPdf(
      month: month,
      isYearly: isYearly,
      income: (incomeExpense['income'] ?? 0).toDouble(),
      expense: (incomeExpense['expense'] ?? 0).toDouble(),
      changePercent: change,
      distribution: distribution,
      paymentMode: const {},
      budget: budget,
      projected: projected,
      trend: trend,
      yearlyBars: yearlyBars,
    );
    if (context.mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF exported')),
      );
    }
  } catch (e) {
    if (context.mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }
}

// ── Period Navigator ──────────────────────────────────────────

class _PeriodNavigator extends ConsumerWidget {
  const _PeriodNavigator({required this.month, required this.isYearly});

  final DateTime month;
  final bool isYearly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void previous() {
      ref.read(insightsSelectedMonthProvider.notifier).update(
        (m) => isYearly
            ? DateTime(m.year - 1, 1, 1)
            : DateTime(m.year, m.month - 1, 1),
      );
    }

    void next() {
      ref.read(insightsSelectedMonthProvider.notifier).update((m) {
        final next = isYearly
            ? DateTime(m.year + 1, 1, 1)
            : DateTime(m.year, m.month + 1, 1);
        final now = DateTime.now();
        final limit = DateTime(now.year, now.month, 1);
        return next.isAfter(limit) ? limit : next;
      });
    }

    void toggleView() {
      ref.read(insightsViewModeProvider.notifier).update(
        (mode) =>
            mode == InsightsViewMode.monthly
                ? InsightsViewMode.yearly
                : InsightsViewMode.monthly,
      );
    }

    void pickPeriod() async {
      final now = DateTime.now();
      if (isYearly) {
        final year = await showDialog<int>(
          context: context,
          builder: (ctx) => _YearPickerDialog(selectedYear: month.year),
        );
        if (year != null) {
          ref.read(insightsSelectedMonthProvider.notifier).state =
              DateTime(year, 1, 1);
        }
      } else {
        final picked = await showDatePicker(
          context: context,
          initialDate: month,
          firstDate: DateTime(2020),
          lastDate: now,
          initialDatePickerMode: DatePickerMode.year,
        );
        if (picked != null) {
          ref.read(insightsSelectedMonthProvider.notifier).state =
              DateTime(picked.year, picked.month, 1);
        }
      }
    }

    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(AppIcons.chevronLeft, color: Color(0xFFD0D0D0)),
              onPressed: previous,
            ),
            Expanded(
              child: GestureDetector(
                onTap: pickPeriod,
                child: Text(
                  isYearly
                      ? month.year.toString()
                      : DateFormat('MMMM yyyy').format(month),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(AppIcons.chevronRight, color: Color(0xFFD0D0D0)),
              onPressed: next,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        GestureDetector(
          onTap: toggleView,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderDark),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ViewModeChip(label: 'Monthly', isSelected: !isYearly),
                const SizedBox(width: 8),
                _ViewModeChip(label: 'Yearly', isSelected: isYearly),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ViewModeChip extends StatelessWidget {
  const _ViewModeChip({required this.label, required this.isSelected});
  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.black : const Color(0xFF8A8A8A),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _YearPickerDialog extends StatelessWidget {
  const _YearPickerDialog({required this.selectedYear});
  final int selectedYear;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now().year;
    final years = List.generate(now - 2019, (i) => now - i);
    return Dialog(
      backgroundColor: const Color(0xFF0E0E0E),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.borderDark),
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: SizedBox(
        height: 400,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Select Year', style: AppTypography.sectionTitle(context)),
            ),
            const Divider(color: AppColors.borderDark, height: 1),
            Expanded(
              child: ListView.separated(
                itemCount: years.length,
                separatorBuilder: (_, __) =>
                    const Divider(color: AppColors.borderDark, height: 1),
                itemBuilder: (_, i) {
                  final year = years[i];
                  final sel = year == selectedYear;
                  return ListTile(
                    title: Text(
                      year.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: sel ? Colors.white : const Color(0xFF8A8A8A),
                        fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                    onTap: () => context.pop(year),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Daily Burn Rate ───────────────────────────────────────────

class _BurnRateCard extends StatelessWidget {
  const _BurnRateCard({
    required this.expense,
    required this.projected,
    required this.budget,
    required this.month,
    required this.isYearly,
  });

  final double expense;
  final double projected;
  final double budget;
  final DateTime month;
  final bool isYearly;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysInPeriod = isYearly
        ? DateTime(month.year + 1, 1, 1).difference(DateTime(month.year, 1, 1)).inDays
        : DateTime(month.year, month.month + 1, 0).day;
    final daysElapsed = isYearly
        ? (month.year == now.year
            ? now.difference(DateTime(month.year, 1, 1)).inDays + 1
            : daysInPeriod)
        : (month.year == now.year && month.month == now.month
            ? now.day
            : daysInPeriod);
    final dailyAvg = daysElapsed <= 0 ? 0.0 : expense / daysElapsed;

    return Container(
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
              const Icon(Icons.speed, color: Color(0xFFFFC857), size: 18),
              const SizedBox(width: 8),
              Text('Daily Burn Rate', style: AppTypography.sectionTitle(context)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${AppConstants.currencySymbol}${_formatCompact(dailyAvg)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  '/ day',
                  style: TextStyle(color: Color(0xFF8A8A8A), fontSize: 14),
                ),
              ),
              const Spacer(),
              if (projected > 0)
                Text(
                  'On track ${Formatters.currency(projected)}',
                  style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 12),
                ),
            ],
          ),
          if (budget > 0) ...[
            const SizedBox(height: 14),
            _BudgetBar(expense: expense, budget: budget, projected: projected),
          ],
        ],
      ),
    );
  }

  String _formatCompact(double value) {
    if (value < 1000) return value.toStringAsFixed(0);
    return '${(value / 1000).toStringAsFixed(1)}k';
  }
}

class _BudgetBar extends StatelessWidget {
  const _BudgetBar({required this.expense, required this.budget, required this.projected});

  final double expense;
  final double budget;
  final double projected;

  @override
  Widget build(BuildContext context) {
    final pct = budget <= 0 ? 0.0 : (expense / budget).clamp(0.0, 1.0);
    final remaining = budget - expense;
    final isOver = expense > budget;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 8,
            color: isOver ? const Color(0xFFFF7A7A) : const Color(0xFF5BE39A),
            backgroundColor: const Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(pct * 100).toStringAsFixed(0)}% of budget',
              style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 12),
            ),
            Text(
              isOver
                  ? '${Formatters.currency(remaining.abs())} over'
                  : '${Formatters.currency(remaining)} left',
              style: TextStyle(
                color: isOver ? const Color(0xFFFF7A7A) : const Color(0xFF5BE39A),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        if (projected > budget && projected > 0) ...[
          const SizedBox(height: 4),
          Text(
            'Projected to exceed by ${Formatters.currency(projected - budget)}',
            style: const TextStyle(color: Color(0xFFFF7A7A), fontSize: 11),
          ),
        ],
      ],
    );
  }
}

// ── Summary Strip ─────────────────────────────────────────────

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({
    required this.income,
    required this.expense,
    required this.prevExpense,
  });

  final double income;
  final double expense;
  final double prevExpense;

  @override
  Widget build(BuildContext context) {
    final savingsRate =
        income <= 0 ? 0.0 : ((income - expense) / income * 100).clamp(0, 100);
    final changeText = prevExpense > 0
        ? '${expense > prevExpense ? '+' : ''}${((expense - prevExpense) / prevExpense * 100).toStringAsFixed(1)}% vs last'
        : null;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderDark),
        color: const Color(0xFF0E0E0E),
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              label: 'Income',
              value: Formatters.currency(income),
              color: const Color(0xFF5BE39A),
            ),
          ),
          _VertDivider(),
          Expanded(
            child: _StatItem(
              label: 'Expense',
              value: Formatters.currency(expense),
              color: const Color(0xFFFF7A7A),
              subtitle: changeText,
            ),
          ),
          _VertDivider(),
          Expanded(
            child: _StatItem(
              label: 'Saved',
              value: '${savingsRate.toStringAsFixed(0)}%',
              color: savingsRate >= 20
                  ? const Color(0xFF5BE39A)
                  : savingsRate > 0
                      ? const Color(0xFFFFC857)
                      : const Color(0xFFFF7A7A),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
    this.subtitle,
  });

  final String label;
  final String value;
  final Color color;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8A8A8A),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: const TextStyle(color: Color(0xFF6A6A6A), fontSize: 10),
          ),
        ],
      ],
    );
  }
}

class _VertDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 48,
      color: AppColors.borderDark,
    );
  }
}

// ── Category Watch ────────────────────────────────────────────

class _CategoryWatch extends StatelessWidget {
  const _CategoryWatch({
    required this.distribution,
    required this.previous,
    required this.totalExpense,
  });

  final List<ExpenseSlice> distribution;
  final List<ExpenseSlice> previous;
  final double totalExpense;

  @override
  Widget build(BuildContext context) {
    final sorted = [...distribution]..sort((a, b) => b.total.compareTo(a.total));
    final prevByCategory = <String, double>{};
    for (final p in previous) {
      prevByCategory[p.category] = (prevByCategory[p.category] ?? 0) + p.total;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderDark),
        color: const Color(0xFF0E0E0E),
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Spending by Category', style: AppTypography.sectionTitle(context)),
          const SizedBox(height: 12),
          const Divider(color: AppColors.borderDark, height: 1),
          const SizedBox(height: 4),
          ...sorted.take(6).map((slice) {
            final prevAmount = prevByCategory[slice.category] ?? 0.0;
            final delta = prevAmount > 0
                ? ((slice.total - prevAmount) / prevAmount) * 100
                : null;
            final sliceColor = Formatters.parseHexColor(
              slice.color,
              fallback: Colors.white,
            );

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    color: sliceColor,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      slice.category,
                      style: const TextStyle(fontSize: 14, color: Color(0xFFCFCFCF)),
                    ),
                  ),
                  if (delta != null && delta.abs() > 1)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: delta > 0
                            ? const Color(0xFFFF7A7A).withValues(alpha: 0.15)
                            : const Color(0xFF5BE39A).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${delta > 0 ? '+' : ''}${delta.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: delta > 0
                              ? const Color(0xFFFF7A7A)
                              : const Color(0xFF5BE39A),
                        ),
                      ),
                    ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 80,
                    child: Text(
                      Formatters.currency(slice.total),
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 4),
          Center(
            child: Text(
              '${Formatters.currency(totalExpense)} total across ${sorted.length} categories',
              style: const TextStyle(color: Color(0xFF6A6A6A), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryWatchSkeleton extends StatelessWidget {
  const _CategoryWatchSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderDark),
        color: const Color(0xFF0E0E0E),
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

// ── What's Changed ────────────────────────────────────────────

class _ExportButton extends StatelessWidget {
  const _ExportButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(AppIcons.download, size: 18, color: Color(0xFFFFC857)),
        label: Text(
          'Export PDF Report',
          style: TextStyle(
            color: AppColors.darkTextPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.borderDark),
          backgroundColor: const Color(0xFF0E0E0E),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.lg),
          ),
        ),
      ),
    );
  }
}

class _WhatsChanged extends StatelessWidget {
  const _WhatsChanged({
    required this.change,
    required this.expense,
    required this.prevExpense,
    required this.budget,
    required this.projected,
  });

  final double change;
  final double expense;
  final double prevExpense;
  final double budget;
  final double projected;

  @override
  Widget build(BuildContext context) {
    final insights = <String>[];

    if (change != 0) {
      final dir = change > 0 ? 'up' : 'down';
      insights.add(
        'Spending is $dir ${change.abs().toStringAsFixed(1)}% vs last ${
          change != 0 ? 'month' : 'period'
        }.',
      );
    }

    if (budget > 0 && expense > 0) {
      final pct = (expense / budget * 100).toStringAsFixed(0);
      final remaining = budget - expense;
      if (remaining > 0) {
        insights.add(
          'You have used $pct% of your budget '
          '(${Formatters.currency(remaining)} remaining).',
        );
      } else {
        insights.add(
          'You have exceeded your budget by '
          '${Formatters.currency(remaining.abs())} ($pct% used).',
        );
      }
    }

    if (projected > 0 && budget > 0 && projected > budget) {
      insights.add(
        'At this rate you will exceed your budget by '
        '${Formatters.currency(projected - budget)}.',
      );
    }

    if (expense > 0 && prevExpense <= 0 && insights.isEmpty) {
      insights.add('First month of tracked spending for this period.');
    }

    if (expense <= 0) {
      insights.add('No spending recorded for this period.');
    }

    if (insights.isEmpty) return const SizedBox.shrink();

    return Container(
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
              const Icon(Icons.change_circle_outlined, color: Color(0xFF8EA0FF), size: 18),
              const SizedBox(width: 8),
              Text("What's Changed", style: AppTypography.sectionTitle(context)),
            ],
          ),
          const SizedBox(height: 12),
          ...insights.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '\u2022',
                    style: TextStyle(color: Color(0xFF8A8A8A), fontSize: 14),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      line,
                      style: const TextStyle(
                        color: Color(0xFFCFCFCF),
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

// ── Trend Chart ───────────────────────────────────────────────

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
          horizontalInterval: safeMaxY / 4,
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
              interval: safeMaxY / 4,
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

    final chg = ((current - previous) / previous) * 100;
    if (chg.abs() < 0.05) {
      return _TrendComparison(
        text: 'same as $previousLabel',
        color: const Color(0xFF555555),
      );
    }
    final direction = chg > 0 ? '\u25B2' : '\u25BC';
    return _TrendComparison(
      text: '$direction ${chg.abs().toStringAsFixed(0)}% vs $previousLabel',
      color: chg > 0 ? const Color(0xFFFF6F61) : const Color(0xFF19C37D),
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
              caption: 'with spend',
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
      height: 76,
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

// ── Helpers ───────────────────────────────────────────────────

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

// ── Data Classes ──────────────────────────────────────────────

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
