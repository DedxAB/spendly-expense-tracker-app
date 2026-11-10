import 'dart:math' show pi;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spendly/core/constants/app_enums.dart';
import 'package:spendly/core/theme/app_design_tokens.dart';
import 'package:spendly/features/transactions/domain/entities/transaction_entity.dart';
import 'package:spendly/core/theme/app_icons.dart';
import 'package:spendly/core/theme/app_typography.dart';
import 'package:spendly/core/utils/amount_visibility.dart';
import 'package:spendly/core/utils/formatters.dart';
import 'package:spendly/core/widgets/amount_mask.dart';
import 'package:spendly/core/widgets/app_header.dart';
import 'package:spendly/core/widgets/app_modal_surface.dart';
import 'package:spendly/core/widgets/empty_transaction_illustration.dart';
import 'package:spendly/core/widgets/transaction_row.dart';
import 'package:spendly/features/categories/presentation/providers/categories_provider.dart';
import 'package:spendly/features/home/presentation/providers/home_provider.dart';
import 'package:spendly/features/home/presentation/widgets/home_surface_card.dart';
import 'package:spendly/features/recurring/presentation/providers/recurring_provider.dart';
import 'package:spendly/features/home/presentation/widgets/spendly_black_card.dart';
import 'package:spendly/features/lend/presentation/providers/lend_provider.dart';
import 'package:spendly/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:spendly/features/settings/presentation/providers/settings_provider.dart';
import 'package:spendly/features/transactions/presentation/pages/add_transaction_page.dart';
import 'package:spendly/features/transactions/presentation/providers/transactions_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(dashboardSummaryProvider);
    final todaySpent = ref.watch(todaySpentProvider).valueOrNull ?? 0;
    final yesterdaySpent = ref.watch(yesterdaySpentProvider).valueOrNull ?? 0;
    final todayComparison = _todayComparison(todaySpent, yesterdaySpent);
    final daily = ref.watch(currentMonthDailyIncomeExpenseProvider);
    final dailyExpense = daily.valueOrNull?.expense ?? const <double>[];
    final recent = ref.watch(recentTransactionsProvider);
    final lendOverview = ref.watch(lendOverviewProvider);
    final recurringRules = ref.watch(recurringRulesProvider);
    final settings = ref.watch(settingsStreamProvider).valueOrNull;
    final showAmounts = settings?.showAmountsEnabled ?? true;
    final categories = ref.watch(allCategoriesProvider).valueOrNull ?? const [];
    final categoryById = {for (final c in categories) c.id: c};

    return Scaffold(
      backgroundColor: context.background,
      appBar: const AppHeader(mode: AppHeaderMode.home),
      floatingActionButton: GestureDetector(
        onLongPress: () {
          HapticFeedback.mediumImpact();
          _showQuickAddSheet(context);
        },
        child: FloatingActionButton(
          onPressed: () {
            HapticFeedback.selectionClick();
            showAddExpenseSheet(context);
          },
          tooltip: 'Add expense · long-press for type',
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
          foregroundColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.black
              : Colors.white,
          elevation: 0,
          shape: const CircleBorder(),
          child: const Icon(AppIcons.plus, size: 36),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.smPlus,
          AppSpacing.sm,
          AppSpacing.smPlus,
          28,
        ),
        children: [
          summary.when(
            data: (data) => SpendlyBlackCard(
              balance: data.availableToSpend,
              goalAllocation: data.monthlyGoalAllocation,
              dailyExpense: dailyExpense,
              showValues: showAmounts,
              onToggleValues: () async {
                HapticFeedback.selectionClick();
                final nextValue = !showAmounts;
                AmountVisibilityController.setVisible(nextValue);
                await ref
                    .read(settingsRepositoryProvider)
                    .setShowAmountsEnabled(nextValue);
              },
              onTap: () => context.push('/transactions'),
            ),
            loading: () => const SizedBox(
              height: 166,
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            error: (e, _) => SizedBox(
              height: 166,
              child: Center(child: Text('Failed to load: $e')),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: "TODAY'S SPEND",
                  amount: todaySpent,
                  note: todayComparison.label,
                  noteColor: todayComparison.color,
                  noteIcon: todayComparison.icon,
                  onTap: () => context.push('/transactions'),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _RemainingCard(
                  title: 'REMAINING',
                  amount: summary.valueOrNull?.remainingBudget ?? 0,
                  limit: (summary.valueOrNull?.remainingBudget ?? 0) +
                      (summary.valueOrNull?.monthlyExpense ?? 0),
                  showValues: showAmounts,
                  onTap: () => context.push('/budget'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          summary.when(
            data: (data) {
              if (data.monthlyInvestment <= 0) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _InvestmentCard(
                  amount: data.monthlyInvestment,
                  income: data.monthlyIncome,
                  onTap: () => context.push('/goals'),
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          lendOverview.when(
            data: (lend) {
              final openPeople = lend.peopleBalances
                  .where((p) => p.activeEntryCount > 0)
                  .length;
              if (lend.totalToReceive <= 0 && lend.totalToPay <= 0 && openPeople == 0) {
                return const SizedBox.shrink();
              }
              return _LendBorrowCard(
                toReceive: lend.totalToReceive,
                toPay: lend.totalToPay,
                openPeople: openPeople,
                onTap: () => context.push('/lend'),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 18),
          recurringRules.when(
            data: (rules) {
              final active = rules.where((r) => r.isActive).toList();
              if (active.isEmpty) return const SizedBox.shrink();
              final total = active.fold<double>(
                0, (sum, r) => sum + r.monthlyAmount);
              final nextRule = active.reduce(
                (a, b) => a.nextDueDate.isBefore(b.nextDueDate) ? a : b);
              return Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: _RecurringBanner(
                  count: active.length,
                  total: total,
                  nextTitle: nextRule.title,
                  nextDueDate: nextRule.nextDueDate,
                  onTap: () => context.push('/recurring'),
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          _SectionHeader(
            title: 'Recent Transactions',
            onTap: () => context.push('/transactions'),
          ),
          const SizedBox(height: 14),
          recent.when(
            data: (items) {
              if (items.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: EmptyTransactionIllustration(message: 'Your recent transactions will appear here'),
                );
              }
              return HomeSurfaceCard(
                borderRadius: AppRadii.lg,
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Column(
                  children: [
                    for (var i = 0; i < items.length; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: TransactionRow.fromEntity(
                          tx: items[i],
                          categoryById: categoryById,
                          dateLabel: _dateLabel(items[i]),
                          isLast: i == items.length - 1,
                          compact: true,
                        ),
                      ),
                  ],
                ),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text('Failed to load: $e'),
          ),
        ],
      ),
    );
  }

  static String _dateLabel(TransactionEntity tx) =>
      Formatters.transactionDateLabel(tx);

  static _SpendComparison _todayComparison(double today, double yesterday) {
    if (today <= 0 && yesterday <= 0) {
      return const _SpendComparison(
        label: 'No spend today',
        color: Color(0xFFA3A3A3),
        icon: Icons.remove,
      );
    }
    if (today <= 0) {
      return const _SpendComparison(
        label: 'No spend today',
        color: Color(0xFF3DD07B),
        icon: Icons.remove,
      );
    }
    if (yesterday <= 0) {
      return const _SpendComparison(
        label: 'No spend yesterday',
        color: Color(0xFFF55C5C),
        icon: Icons.arrow_upward,
      );
    }

    final change = ((today - yesterday) / yesterday) * 100;
    if (change.abs() < 0.05) {
      return const _SpendComparison(
        label: 'Same as yesterday',
        color: Color(0xFFA3A3A3),
        icon: Icons.remove,
      );
    }

    final isHigher = change > 0;
    return _SpendComparison(
      label:
          '${isHigher ? '+' : '-'}${change.abs().toStringAsFixed(0)}% vs yesterday',
      color: isHigher ? const Color(0xFFF55C5C) : const Color(0xFF3DD07B),
      icon: isHigher ? Icons.arrow_upward : Icons.arrow_downward,
    );
  }
}

class _SpendComparison {
  const _SpendComparison({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTypography.sectionTitle(context).copyWith(
              fontSize: AppFontSizes.heading,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
        ),
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('View all', style: TextStyle(fontSize: AppFontSizes.body)),
              SizedBox(width: 4),
              Icon(AppIcons.chevronRight, size: 16),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.amount,
    required this.note,
    required this.noteColor,
    required this.noteIcon,
    this.onTap,
  });

  final String title;
  final double amount;
  final String note;
  final Color noteColor;
  final IconData noteIcon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return HomeSurfaceCard(
      borderRadius: 26,
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: SizedBox(
        // 136px total card height, minus the 16px top/bottom padding.
        height: 104,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 30,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.3,
                      ),
                    ),
                  ),
                  Icon(noteIcon, size: 15, color: noteColor),
                ],
              ),
            ),
            const SizedBox(height: 15),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: AmountView(
                amount,
                style: TextStyle(
                  color: context.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                  height: 1,
                ),
                maskColor: context.textPrimary,
              ),
            ),
            const Spacer(),
            Text(
              note,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: noteColor,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RemainingCard extends StatelessWidget {
  const _RemainingCard({
    required this.title,
    required this.amount,
    required this.limit,
    required this.showValues,
    this.onTap,
  });

  final String title;
  final double amount;
  final double limit;
  final bool showValues;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasBudget = limit > 0;
    final isOver = hasBudget && amount < 0;
    final percent = hasBudget
        ? (amount / limit * 100).clamp(0, 100).round()
        : 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ringAccent = isOver
        ? context.homeAccentRed
        : isDark
            ? const Color(0xFFB18CFF)
            : AppColors.homeAccentPurple;

    final noteText = Text(
      !hasBudget
          ? 'Tap to set monthly budget'
          : isOver
              ? 'over by ${showValues ? Formatters.currency(amount.abs()) : '◆ ◆ ◆'}'
              : 'of ${showValues ? Formatters.currency(limit) : '◆ ◆ ◆'} limit',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: isOver ? context.homeAccentRed : context.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
    );

    return HomeSurfaceCard(
      borderRadius: 26,
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: SizedBox(
        // 136px total card height, minus the 16px top/bottom padding.
        height: 104,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 30,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.3,
                      ),
                    ),
                  ),
                  if (hasBudget)
                    _RingBadge(
                      value: percent,
                      accent: ringAccent,
                      isOver: isOver,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: hasBudget
                  ? AmountView(
                      amount,
                      style: TextStyle(
                        color: isOver
                            ? context.homeAccentRed
                            : context.textPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.6,
                        height: 1,
                      ),
                      maskColor: isOver
                          ? context.homeAccentRed
                          : context.textPrimary,
                    )
                  : Text(
                      '\u2014',
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.6,
                        height: 1,
                      ),
                    ),
            ),
            const Spacer(),
            noteText,
          ],
        ),
      ),
    );
  }
}

class _RingBadge extends StatelessWidget {
  const _RingBadge({
    required this.value,
    required this.accent,
    required this.isOver,
  });

  final int value;
  final Color accent;
  final bool isOver;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 30,
      child: CustomPaint(
        painter: _RingBadgePainter(
          progress: isOver ? 1 : value.clamp(0, 100) / 100,
          accent: accent,
          trackColor: context.border,
        ),
        child: Center(
          child: Text(
            isOver ? '!' : '$value%',
            style: TextStyle(
              color: accent,
              fontSize: isOver ? 9 : 7.6,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _RingBadgePainter extends CustomPainter {
  const _RingBadgePainter({
    required this.progress,
    required this.accent,
    required this.trackColor,
  });

  final double progress;
  final Color accent;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 - 3;
    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = trackColor;
    final valuePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = accent;

    canvas.drawCircle(center, radius, basePaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      progress.clamp(0, 1) * 2 * pi,
      false,
      valuePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingBadgePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.accent != accent ||
        oldDelegate.trackColor != trackColor;
  }
}

class _LendBorrowCard extends StatelessWidget {
  const _LendBorrowCard({
    required this.toReceive,
    required this.toPay,
    required this.openPeople,
    required this.onTap,
  });

  final double toReceive;
  final double toPay;
  final int openPeople;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return HomeSurfaceCard(
      onTap: onTap,
      borderRadius: AppRadii.lg,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 18,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'LEND & BORROW',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.3,
                    ),
                  ),
                ),
                Text(
                  '$openPeople ${openPeople == 1 ? 'person' : 'people'}',
                  style: TextStyle(
                    color: context.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 3),
                Icon(
                  AppIcons.chevronRight,
                  size: 14,
                  color: context.textSecondary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _LendAmount(
                    label: 'TO RECEIVE',
                    amount: toReceive,
                    dotColor: context.homeAccentGreen,
                    muted: toReceive <= 0,
                  ),
                ),
                Container(
                  width: 1,
                  margin: const EdgeInsets.only(right: 16),
                  color: context.border,
                ),
                Expanded(
                  child: _LendAmount(
                    label: 'YOU OWE',
                    amount: toPay,
                    dotColor: context.homeAccentRed,
                    muted: toPay <= 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LendAmount extends StatelessWidget {
  const _LendAmount({
    required this.label,
    required this.amount,
    required this.dotColor,
    required this.muted,
  });

  final String label;
  final double amount;
  final Color dotColor;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final amountColor = muted
        ? context.textSecondary.withValues(alpha: 0.5)
        : context.textPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: context.textSecondary,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: AmountView(
            amount,
            style: TextStyle(
              color: amountColor,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              height: 1,
            ),
            maskColor: amountColor,
          ),
        ),
      ],
    );
  }
}

class _SectionIconChip extends StatelessWidget {
  const _SectionIconChip({required this.icon, required this.tint});

  final IconData icon;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: tint, size: 20),
    );
  }
}

class _RecurringBanner extends StatelessWidget {
  const _RecurringBanner({
    required this.count,
    required this.total,
    required this.nextTitle,
    required this.nextDueDate,
    required this.onTap,
  });

  final int count;
  final double total;
  final String nextTitle;
  final DateTime nextDueDate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return HomeSurfaceCard(
      onTap: onTap,
      borderRadius: AppRadii.lg,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          _SectionIconChip(
            icon: AppIcons.repeat,
            tint: context.homeAccentPurple,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count == 1 ? '1 recurring txn' : '$count recurring txns',
                  style: TextStyle(
                    color: context.textPrimary,
                    fontSize: AppFontSizes.bodyLarge,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Next: $nextTitle on ${Formatters.date(nextDueDate)}',
                        style: TextStyle(
                          color: context.textSecondary,
                          fontSize: AppFontSizes.label,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              AmountView(
                total,
                style: TextStyle(
                  color: context.textPrimary,
                  fontSize: AppFontSizes.bodyLarge,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
                maskColor: context.textPrimary,
              ),
              Text(
                '/ month',
                style: TextStyle(
                  color: context.textSecondary,
                  fontSize: AppFontSizes.small,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Icon(
            AppIcons.chevronRight,
            size: 16,
            color: context.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _InvestmentCard extends StatelessWidget {
  const _InvestmentCard({
    required this.amount,
    required this.income,
    this.onTap,
  });

  final double amount;
  final double income;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final pct = income > 0 ? (amount / income * 100) : 0.0;
    final pctDisplay = '${pct.round()}% of income';
    final overIncome = pct > 100;

    return HomeSurfaceCard(
      onTap: onTap,
      borderRadius: AppRadii.lg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  AppIcons.trendingUp,
                  color: Color(0xFF8B5CF6),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  'INVESTMENT',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.textPrimary,
                    fontSize: AppFontSizes.body,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  overIncome ? '>100% of income' : pctDisplay,
                  style: const TextStyle(
                    color: Color(0xFF8B5CF6),
                    fontSize: AppFontSizes.small,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AmountView(
            amount,
            style: TextStyle(
              color: context.textPrimary,
              fontSize: AppFontSizes.display,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
            maskColor: context.textPrimary,
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: income > 0 ? (amount / income).clamp(0, 1) : 0,
              backgroundColor: context.border.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF8B5CF6),
              ),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _showQuickAddSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: false,
    backgroundColor: Colors.transparent,
    builder: (_) => const _QuickAddSheet(),
  );
}

class _QuickAddSheet extends StatelessWidget {
  const _QuickAddSheet();

  @override
  Widget build(BuildContext context) {
    final options = [
      (
        type: TransactionType.expense,
        label: 'Expense',
        icon: AppIcons.receipt,
        tint: AppColors.expense,
      ),
      (
        type: TransactionType.income,
        label: 'Income',
        icon: AppIcons.money,
        tint: AppColors.income,
      ),
      (
        type: TransactionType.investment,
        label: 'Investment',
        icon: AppIcons.trendingUp,
        tint: AppColors.homeAccentPurple,
      ),
    ];

    return AppModalSurface(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 76,
                height: 5,
                decoration: BoxDecoration(
                  color: context.textSecondary,
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Add Transaction',
              style: AppTypography.sectionTitle(context),
            ),
            const SizedBox(height: 14),
            for (final option in options) ...[
              _QuickAddOption(
                type: option.type,
                label: option.label,
                icon: option.icon,
                tint: option.tint,
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _QuickAddOption extends StatelessWidget {
  const _QuickAddOption({
    required this.type,
    required this.label,
    required this.icon,
    required this.tint,
  });

  final TransactionType type;
  final String label;
  final IconData icon;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.of(context).pop();
        showAddExpenseSheet(context, initialType: type);
      },
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: tint, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: context.textPrimary,
                fontSize: AppFontSizes.bodyLarge,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Icon(
            AppIcons.chevronRight,
            size: 18,
            color: context.textSecondary,
          ),
        ],
      ),
    );
  }
}
