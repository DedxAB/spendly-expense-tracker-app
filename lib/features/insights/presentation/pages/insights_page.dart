import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:spendly/core/constants/app_constants.dart';
import 'package:spendly/core/theme/app_design_tokens.dart';
import 'package:spendly/core/theme/app_icons.dart';
import 'package:spendly/core/widgets/app_toast.dart';
import 'package:spendly/core/theme/app_typography.dart';
import 'package:spendly/core/utils/formatters.dart';
import 'package:spendly/core/widgets/amount_mask.dart';
import 'package:spendly/core/widgets/app_header.dart';
import 'package:spendly/features/insights/domain/entities/expense_slice.dart';
import 'package:spendly/features/insights/domain/entities/insight_point.dart';
import 'package:spendly/features/insights/presentation/providers/insights_provider.dart';
import 'package:spendly/features/insights/presentation/services/insights_export_service.dart';
import 'package:spendly/features/user/presentation/providers/user_profile_provider.dart';

const _kInsightGreen = Color(0xFF38D97A);
const _kInsightAmber = Color(0xFFF5B83D);
const _kInsightRed = Color(0xFFFF5C6C);
const _kInsightPurple = Color(0xFF8B5CF6);
const _kInsightSoftRed = Color(0xFFFF8A7A);
const _kInsightGreenTint = Color(0xFF0F2A1C);
const _kInsightAmberTint = Color(0xFF2A200D);
const _kInsightRedTint = Color(0xFF2A1313);
const _kInsightGreenLight = Color(0xFF0E9C58);
const _kInsightAmberLight = Color(0xFFA87409);
const _kInsightRedLight = Color(0xFFE03550);
const _kInsightPurpleLight = Color(0xFF7157D8);
const _kInsightSoftRedLight = Color(0xFFEF6459);
const _kInsightGreenTintLight = Color(0xFFE7F7EE);
const _kInsightAmberTintLight = Color(0xFFFBF3E1);
const _kInsightRedTintLight = Color(0xFFFDE7EA);

bool _isDark(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;

Color _trackColor(BuildContext context) =>
    _isDark(context) ? const Color(0xFF1C1E20) : const Color(0xFFEDEDEF);

Color _green(BuildContext context) =>
    _isDark(context) ? _kInsightGreen : _kInsightGreenLight;

Color _amber(BuildContext context) =>
    _isDark(context) ? _kInsightAmber : _kInsightAmberLight;

Color _red(BuildContext context) =>
    _isDark(context) ? _kInsightRed : _kInsightRedLight;

Color _purple(BuildContext context) =>
    _isDark(context) ? _kInsightPurple : _kInsightPurpleLight;

Color _softRed(BuildContext context) =>
    _isDark(context) ? _kInsightSoftRed : _kInsightSoftRedLight;

Color _greenTint(BuildContext context) =>
    _isDark(context) ? _kInsightGreenTint : _kInsightGreenTintLight;

Color _amberTint(BuildContext context) =>
    _isDark(context) ? _kInsightAmberTint : _kInsightAmberTintLight;

Color _redTint(BuildContext context) =>
    _isDark(context) ? _kInsightRedTint : _kInsightRedTintLight;

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
    final prevIncomeExpense = ref
        .watch(previousIncomeVsExpenseProvider)
        .valueOrNull;
    final distributionAsync = ref.watch(expenseDistributionProvider);
    final prevDistributionAsync = ref.watch(
      previousExpenseDistributionProvider,
    );
    final trend = ref.watch(dailyTrendProvider);
    final change = ref.watch(expenseChangePercentProvider).valueOrNull ?? 0.0;
    final projected = ref.watch(projectedExpenseProvider).valueOrNull ?? 0.0;
    final monthlyBudget = ref.watch(monthlyBudgetProvider);

    final income = (incomeExpense['income'] ?? 0).toDouble();
    final expense = (incomeExpense['expense'] ?? 0).toDouble();
    final prevExpense = ((prevIncomeExpense?['expense'] ?? 0).toDouble());

    return Scaffold(
      appBar: AppHeader(
        mode: AppHeaderMode.back,
        title: 'Analytics',
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
          _PeriodNavigator(month: month, isYearly: isYearly),
          const SizedBox(height: AppSpacing.smPlus),
          _OverviewCard(
            income: income,
            expense: expense,
            budget: monthlyBudget,
            projected: projected,
            change: change,
            month: month,
            isYearly: isYearly,
          ),
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
              border: Border.all(color: context.border),
              color: context.surface,
              borderRadius: BorderRadius.circular(AppRadii.card),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Trend', style: AppTypography.sectionTitle(context)),
                    const Spacer(),
                    trend.when(
                      data: (points) =>
                          _TrendArrow(points: points, isYearly: isYearly),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  height: 200,
                  child: trend.when(
                    data: (points) => _TrendChart(
                      points: points,
                      isYearly: isYearly,
                      budget: monthlyBudget,
                    ),
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
  try {
    final month = ref.read(insightsSelectedMonthProvider);
    final isYearly =
        ref.read(insightsViewModeProvider) == InsightsViewMode.yearly;
    final incomeExpense =
        ref.read(incomeVsExpenseProvider).valueOrNull ??
        const {'income': 0.0, 'expense': 0.0};
    final distribution =
        ref.read(expenseDistributionProvider).valueOrNull ?? const [];
    final change = ref.read(expenseChangePercentProvider).valueOrNull;
    final budget = ref.read(monthlyBudgetProvider);
    final projected = ref.read(projectedExpenseProvider).valueOrNull ?? 0.0;
    final trend = ref.read(dailyTrendProvider).valueOrNull ?? const [];
    final yearlyBars =
        ref.read(yearlyIncomeVsExpenseProvider).valueOrNull ?? const [];

    final userProfile = ref.read(userProfileProvider).valueOrNull;
    final userName = userProfile != null && userProfile.name.trim().isNotEmpty
        ? userProfile.name.trim()
        : null;

    final service = InsightsExportService();

    final lucideData = await rootBundle.load('assets/fonts/lucide/Lucide.ttf');
    final lucideFont = pw.Font.ttf(lucideData);

    final baseFontData = await rootBundle.load(
      'assets/fonts/general_sans/GeneralSans-Regular.ttf',
    );
    final baseFont = pw.Font.ttf(baseFontData);

    final incomeVal = (incomeExpense['income'] ?? 0).toDouble();
    final expenseVal = (incomeExpense['expense'] ?? 0).toDouble();
    final prevExpenseVal =
        (ref.read(previousIncomeVsExpenseProvider).valueOrNull?['expense'] ??
                0.0)
            .toDouble();

    final pdfBytes = await service.exportPdf(
      month: month,
      isYearly: isYearly,
      userName: userName,
      income: incomeVal,
      expense: expenseVal,
      prevExpense: prevExpenseVal,
      changePercent: change,
      distribution: distribution,
      paymentMode: const {},
      budget: budget,
      projected: projected,
      trend: trend,
      yearlyBars: yearlyBars,
      lucideFont: lucideFont,
      baseFont: baseFont,
    );

    final tempDir = await getTemporaryDirectory();
    final fileName =
        'Spendly_Report_${DateFormat('yyyy-MM').format(month)}.pdf';
    final tempFile = File('${tempDir.path}/$fileName');
    await tempFile.writeAsBytes(pdfBytes);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(tempFile.path, mimeType: 'application/pdf')],
        subject: 'Spendly Report',
        text:
            'Spendly Analytics Report - ${DateFormat('MMMM yyyy').format(month)}',
      ),
    );
  } catch (e) {
    if (context.mounted) {
      showAppToast(context, 'Export failed', style: AppToastStyle.error);
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
      ref
          .read(insightsSelectedMonthProvider.notifier)
          .update(
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
      ref
          .read(insightsViewModeProvider.notifier)
          .update(
            (mode) => mode == InsightsViewMode.monthly
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
          ref.read(insightsSelectedMonthProvider.notifier).state = DateTime(
            year,
            1,
            1,
          );
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
          ref.read(insightsSelectedMonthProvider.notifier).state = DateTime(
            picked.year,
            picked.month,
            1,
          );
        }
      }
    }

    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(AppIcons.chevronLeft, color: context.textSecondary),
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
                  style: TextStyle(
                    color: context.textPrimary,
                    fontSize: AppFontSizes.heading,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(AppIcons.chevronRight, color: context.textSecondary),
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
              border: Border.all(color: context.border),
              borderRadius: BorderRadius.circular(AppRadii.lg),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? context.textPrimary : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? context.surface : context.textSecondary,
          fontSize: AppFontSizes.label,
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
      backgroundColor: context.surface,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: context.border),
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: SizedBox(
        height: 400,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Select Year',
                style: AppTypography.sectionTitle(context),
              ),
            ),
            Divider(color: context.border, height: 1),
            Expanded(
              child: ListView.separated(
                itemCount: years.length,
                separatorBuilder: (_, __) =>
                    Divider(color: context.border, height: 1),
                itemBuilder: (_, i) {
                  final year = years[i];
                  final sel = year == selectedYear;
                  return ListTile(
                    title: Text(
                      year.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: sel
                            ? context.textPrimary
                            : context.textSecondary,
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

// ── Overview Card ─────────────────────────────────────────────

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.income,
    required this.expense,
    required this.budget,
    required this.projected,
    required this.change,
    required this.month,
    required this.isYearly,
  });

  final double income;
  final double expense;
  final double budget;
  final double projected;
  final double change;
  final DateTime month;
  final bool isYearly;

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark(context);
    final gradientColors = isDark
        ? const [Color(0xFF12131A), Color(0xFF0E0F16), Color(0xFF131022)]
        : const [Color(0xFFFBFAFF), Color(0xFFF5F1FF), Color(0xFFFDF5F4)];
    final now = DateTime.now();
    final isCurrentMonth = month.year == now.year && month.month == now.month;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final daysElapsed = isCurrentMonth ? now.day : daysInMonth;
    final monthsElapsed =
        isYearly ? (month.year == now.year ? now.month : 12) : 1;

    final rateValue = isYearly
        ? (monthsElapsed <= 0 ? 0.0 : expense / monthsElapsed)
        : (daysElapsed <= 0 ? 0.0 : expense / daysElapsed);
    final rateLabel = isYearly ? '/ month' : '/ day';

    final hasIncome = income > 0;
    final savings = income - expense;
    final ratio = hasIncome ? (savings / income) * 100 : 0.0;
    final isOverspent = hasIncome && savings < 0;
    final savedColor = !hasIncome
        ? context.textSecondary
        : isOverspent
            ? _red(context)
            : ratio >= 20
                ? _green(context)
                : _amber(context);
    final savedTint = !hasIncome
        ? context.surfaceAlt
        : isOverspent
            ? _redTint(context)
            : ratio >= 20
                ? _greenTint(context)
                : _amberTint(context);
    final savedLabel = !hasIncome
        ? 'SAVED \u2014'
        : isOverspent
            ? 'OVERSPENT \u00B7 ${Formatters.currency(savings.abs())}'
            : 'SAVED ${Formatters.currency(savings)} \u00B7 '
                  '${ratio.toStringAsFixed(0)}%';

    final hasBudget = budget > 0;
    final comparedExpense =
        isYearly && monthsElapsed > 0 ? expense / monthsElapsed : expense;
    final usage = hasBudget ? (comparedExpense / budget).clamp(0.0, 1.0) : 0.0;
    final remaining = budget - comparedExpense;
    final isOverBudget = comparedExpense > budget;

    final projectedTotal = isYearly
        ? (monthsElapsed <= 0 ? 0.0 : (expense / monthsElapsed) * 12)
        : projected;
    final projectionBudget = isYearly ? budget * 12 : budget;
    final willExceed =
        hasBudget && projectedTotal > projectionBudget;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        border: Border.all(color: context.border),
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -46,
            top: -46,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _purple(context).withValues(alpha: isDark ? 0.20 : 0.12),
                    _purple(context).withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isYearly
                            ? 'OVERVIEW \u00B7 ${month.year}'
                            : 'OVERVIEW \u00B7 ${DateFormat('MMMM').format(month).toUpperCase()}',
                        style: TextStyle(
                          letterSpacing: 1.8,
                          fontSize: AppFontSizes.small,
                          fontWeight: FontWeight.w700,
                          color: context.textSecondary,
                        ),
                      ),
                    ),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: savedTint,
                            borderRadius: BorderRadius.circular(AppRadii.pill),
                          ),
                          child: Text(
                            savedLabel,
                            style: TextStyle(
                              color: savedColor,
                              fontSize: AppFontSizes.small,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: AmountView(
                          expense,
                          style: TextStyle(
                            color: context.textPrimary,
                            fontSize: AppFontSizes.largeDisplay,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.8,
                            height: 1,
                          ),
                          maskColor: context.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'spent',
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: AppFontSizes.heading,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _MiniStatChip(
                        label: 'Income',
                        child: AmountView(
                          income,
                          style: TextStyle(
                            color: context.textPrimary,
                            fontSize: AppFontSizes.bodyLarge,
                            fontWeight: FontWeight.w700,
                          ),
                          maskColor: context.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MiniStatChip(
                        label: 'Burn rate',
                        child: Text(
                          '${AppConstants.currencySymbol}'
                          '${_formatCompact(rateValue)} $rateLabel',
                          style: TextStyle(
                            color: context.textPrimary,
                            fontSize: AppFontSizes.bodyLarge,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (change != 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        change > 0
                            ? AppIcons.trendingUp
                            : AppIcons.trendingDown,
                        size: 12,
                        color: change > 0 ? _red(context) : _green(context),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${change > 0 ? '+' : ''}'
                        '${change.toStringAsFixed(1)}% '
                        'vs last ${isYearly ? 'year' : 'month'}',
                        style: TextStyle(
                          color: change > 0 ? _red(context) : _green(context),
                          fontSize: AppFontSizes.small,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
                if (hasBudget) ...[
                  const SizedBox(height: 14),
                  Divider(color: context.border),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        isYearly ? 'Budget (avg / mo)' : 'Budget',
                        style: TextStyle(
                          color: context.textSecondary,
                          fontSize: AppFontSizes.label,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        isOverBudget
                            ? '${Formatters.currency(remaining.abs())} over'
                            : '${Formatters.currency(remaining)} left',
                        style: TextStyle(
                          color: isOverBudget
                              ? _red(context)
                              : _green(context),
                          fontSize: AppFontSizes.label,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _GradientBar(
                    value: usage,
                    colors: isOverBudget
                        ? [_softRed(context), _red(context)]
                        : usage >= 0.8
                            ? [_amber(context), _red(context)]
                            : [_purple(context), _green(context)],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${(usage * 100).toStringAsFixed(0)}% used',
                        style: TextStyle(
                          color: context.textSecondary,
                          fontSize: AppFontSizes.small,
                        ),
                      ),
                      const Spacer(),
                      if (projectedTotal > 0)
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              isYearly
                                  ? 'Projected EoY '
                                        '${Formatters.currency(projectedTotal)}'
                                  : 'Projected '
                                        '${Formatters.currency(projectedTotal)}',
                              style: TextStyle(
                                color: context.textSecondary,
                                fontSize: AppFontSizes.small,
                              ),
                            ),
                            if (willExceed)
                              Text(
                                'exceed by '
                                '${Formatters.currency(projectedTotal - projectionBudget)}',
                                style: TextStyle(
                                  color: _red(context),
                                  fontSize: AppFontSizes.small,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ],
                if (projectedTotal > 0 && !hasBudget) ...[
                  const SizedBox(height: 14),
                  Divider(color: context.border),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        isYearly
                            ? 'Projected EoY '
                                  '${Formatters.currency(projectedTotal)}'
                            : 'Projected '
                                  '${Formatters.currency(projectedTotal)}',
                        style: TextStyle(
                          color: context.textSecondary,
                          fontSize: AppFontSizes.small,
                        ),
                      ),
                      const Spacer(),
                      if (willExceed)
                        Text(
                          'exceed by '
                          '${Formatters.currency(projectedTotal - projectionBudget)}',
                          style: TextStyle(
                            color: _red(context),
                            fontSize: AppFontSizes.small,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCompact(double value) {
    if (value < 1000) return value.toStringAsFixed(0);
    return '${(value / 1000).toStringAsFixed(1)}k';
  }
}

class _MiniStatChip extends StatelessWidget {
  const _MiniStatChip({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _isDark(context) ? const Color(0xFF17181B) : context.surfaceAlt,
        border: Border.all(
          color: _isDark(context) ? const Color(0xFF1B1D20) : context.border,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: context.textSecondary.withValues(alpha: 0.6),
              fontSize: AppFontSizes.caption,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: child,
          ),
        ],
      ),
    );
  }
}

class _GradientBar extends StatelessWidget {
  const _GradientBar({required this.value, required this.colors});

  final double value;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    final progress = value.clamp(0.0, 1.0).toDouble();
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: SizedBox(
        height: 8,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: _trackColor(context)),
            if (progress > 0)
              FractionallySizedBox(
                widthFactor: progress,
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: colors,
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
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
    final sorted = [...distribution]
      ..sort((a, b) => b.total.compareTo(a.total));
    final prevByCategory = <String, double>{};
    for (final p in previous) {
      prevByCategory[p.category] = (prevByCategory[p.category] ?? 0) + p.total;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(color: context.border),
        color: context.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spending by Category',
            style: AppTypography.sectionTitle(context),
          ),
          const SizedBox(height: 12),
          Divider(color: context.border, height: 1),
          const SizedBox(height: 4),
          ...sorted.take(6).map((slice) {
            final prevAmount = prevByCategory[slice.category] ?? 0.0;
            final delta = prevAmount > 0
                ? ((slice.total - prevAmount) / prevAmount) * 100
                : null;
            final sliceColor = Formatters.parseHexColor(
              slice.color,
              fallback: context.textPrimary,
            );

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: sliceColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      AppIcons.getIconForCategory(slice.category),
                      color: sliceColor,
                      size: 17,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      slice.category,
                      style: TextStyle(
                        fontSize: AppFontSizes.bodyLarge,
                        color: context.textSecondary,
                      ),
                    ),
                  ),
                  if (delta != null && delta.abs() > 1)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: delta > 0
                            ? _red(context).withValues(alpha: 0.15)
                            : _green(context).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                      ),
                      child: Text(
                        '${delta > 0 ? '+' : ''}${delta.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: AppFontSizes.small,
                          fontWeight: FontWeight.w700,
                          color: delta > 0 ? _red(context) : _green(context),
                        ),
                      ),
                    ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 80,
                    child: AmountView(
                      slice.total,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: AppFontSizes.bodyLarge,
                        fontWeight: FontWeight.w600,
                        color: context.textPrimary,
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
              style: TextStyle(
                color: context.textSecondary,
                fontSize: AppFontSizes.label,
              ),
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
        border: Border.all(color: context.border),
        color: context.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
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
        icon: Icon(AppIcons.download, size: 18, color: _purple(context)),
        label: Text(
          'Download PDF Report',
          style: TextStyle(
            color: context.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: context.border),
          backgroundColor: context.surface,
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
        'Spending is $dir ${change.abs().toStringAsFixed(1)}% vs last month.',
      );
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
        border: Border.all(color: context.border),
        color: context.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                AppIcons.history,
                color: _purple(context),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                "What's Changed",
                style: AppTypography.sectionTitle(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...insights.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '\u2022',
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: AppFontSizes.bodyLarge,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      line,
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: AppFontSizes.bodyLarge,
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
  const _TrendChart({
    required this.points,
    required this.isYearly,
    this.budget = 0,
  });

  final List<InsightPoint> points;
  final bool isYearly;
  final double budget;

  @override
  Widget build(BuildContext context) {
    final chartPoints = _buildTrendChartPoints(points, isYearly);
    if (chartPoints.isEmpty) {
      return const Center(child: Text('No spending trend yet'));
    }

    final maxY = chartPoints.map((e) => e.value).fold<double>(0, math.max);
    final budgetPerPeriod = isYearly ? budget : (budget / 4);
    final overallMax = [
      maxY,
      if (budgetPerPeriod > 0) budgetPerPeriod,
    ].fold<double>(0, math.max);
    final safeMaxY = overallMax <= 0 ? 1.0 : overallMax * 1.2;

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
              FlLine(color: context.border, strokeWidth: 0.8),
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: context.textPrimary),
            left: BorderSide(color: context.border),
          ),
        ),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            if (budgetPerPeriod > 0)
              HorizontalLine(
                y: budgetPerPeriod,
                color: _amber(context),
                strokeWidth: 1.5,
                dashArray: [6, 4],
                label: HorizontalLineLabel(
                  show: true,
                  alignment: Alignment.topRight,
                  style: TextStyle(
                    color: _amber(context),
                    fontSize: AppFontSizes.caption,
                    fontWeight: FontWeight.w600,
                  ),
                  labelResolver: (_) => 'Budget',
                ),
              ),
          ],
        ),
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) =>
                Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF2A2A2A)
                : const Color(0xFFF4F4F4),
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
              return _tooltipItem(context, chartPoints, index);
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
                style: TextStyle(
                  fontSize: AppFontSizes.small,
                  color: context.textSecondary,
                ),
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
                  style: TextStyle(
                    fontSize: AppFontSizes.small,
                    color: context.textSecondary,
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
            color: context.textPrimary,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                final isMax =
                    index < chartPoints.length &&
                    chartPoints[index].value == maxY;
                return FlDotCirclePainter(
                  radius: isMax ? 5 : 3.5,
                  color: context.textPrimary,
                  strokeWidth: isMax ? 2 : 0,
                  strokeColor: context.border,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: context.textPrimary.withValues(alpha: 0.06),
              cutOffY: 0,
              applyCutOffY: true,
            ),
          ),
        ],
      ),
    );
  }

  LineTooltipItem _tooltipItem(
    BuildContext context,
    List<_TrendChartPoint> chartPoints,
    int index,
  ) {
    final point = chartPoints[index];
    final average = point.daysInPeriod <= 0
        ? 0.0
        : point.value / point.daysInPeriod;
    final comparison = _comparison(context, chartPoints, index);

    return LineTooltipItem(
      '${point.title}\n',
      TextStyle(
        color: context.textPrimary,
        fontSize: AppFontSizes.label,
        fontWeight: FontWeight.w700,
      ),
      textAlign: TextAlign.left,
      children: [
        TextSpan(
          text: '${Formatters.currency(point.value)} spent\n',
          style: TextStyle(
            color: context.textPrimary,
            fontSize: AppFontSizes.body,
            fontWeight: FontWeight.w800,
          ),
        ),
        TextSpan(
          text: '${point.periodLabel}\n',
          style: TextStyle(
            color: context.textSecondary,
            fontSize: AppFontSizes.small,
            fontWeight: FontWeight.w600,
          ),
        ),
        TextSpan(
          text: '${Formatters.currency(average)} per day',
          style: TextStyle(
            color: context.textSecondary,
            fontSize: AppFontSizes.small,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (comparison != null)
          TextSpan(
            text: '\n${comparison.text}',
            style: TextStyle(
              color: comparison.color,
              fontSize: AppFontSizes.small,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  _TrendComparison? _comparison(
    BuildContext context,
    List<_TrendChartPoint> chartPoints,
    int index,
  ) {
    if (index == 0) return null;

    final current = chartPoints[index].value;
    final previous = chartPoints[index - 1].value;
    final previousLabel = isYearly ? 'previous month' : 'previous week';
    if (previous <= 0 && current <= 0) {
      return _TrendComparison(
        text: 'same as $previousLabel',
        color: context.textSecondary,
      );
    }
    if (previous <= 0) {
      return _TrendComparison(
        text: '\u25B2 from no spend in $previousLabel',
        color: _red(context),
      );
    }

    final chg = ((current - previous) / previous) * 100;
    if (chg.abs() < 0.05) {
      return _TrendComparison(
        text: 'same as $previousLabel',
        color: context.textSecondary,
      );
    }
    final direction = chg > 0 ? '\u25B2' : '\u25BC';
    return _TrendComparison(
      text: '$direction ${chg.abs().toStringAsFixed(0)}% vs $previousLabel',
      color: chg > 0 ? _red(context) : _green(context),
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

class _TrendArrow extends StatelessWidget {
  const _TrendArrow({required this.points, required this.isYearly});

  final List<InsightPoint> points;
  final bool isYearly;

  @override
  Widget build(BuildContext context) {
    final chartPoints = _buildTrendChartPoints(points, isYearly);
    if (chartPoints.length < 2) return const SizedBox.shrink();

    final first = chartPoints.first.value;
    final last = chartPoints.last.value;
    final diff = last - first;

    if (diff.abs() < 0.01) return const SizedBox.shrink();

    final isUp = diff > 0;
    final pct = first > 0 ? (diff / first * 100).abs() : 100;
    final periodLabel = isYearly ? 'first month' : 'first week';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isUp ? AppIcons.trendingUp : AppIcons.trendingDown,
          size: 16,
          color: isUp ? _red(context) : _green(context),
        ),
        const SizedBox(width: 4),
        Text(
          '${isUp ? '+' : ''}${pct.toStringAsFixed(0)}% from $periodLabel start',
          style: TextStyle(
            fontSize: AppFontSizes.label,
            fontWeight: FontWeight.w600,
            color: isUp ? _red(context) : _green(context),
          ),
        ),
      ],
    );
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

    final peak = chartPoints.reduce((a, b) => a.value >= b.value ? a : b);

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
      constraints: const BoxConstraints(minHeight: 76),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: context.surface,
        border: Border.all(color: context.border),
        borderRadius: BorderRadius.circular(AppRadii.premiumCard),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: context.textSecondary,
              fontSize: AppFontSizes.caption,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: context.textPrimary,
              fontSize: AppFontSizes.body,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: context.textSecondary,
              fontSize: AppFontSizes.small,
            ),
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
