import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:spendly/core/theme/app_design_tokens.dart';
import 'package:spendly/core/theme/app_icons.dart';
import 'package:spendly/core/theme/app_typography.dart';
import 'package:spendly/core/utils/amount_visibility.dart';
import 'package:spendly/core/utils/formatters.dart';
import 'package:spendly/core/widgets/amount_mask.dart';
import 'package:spendly/core/widgets/app_header.dart';
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddExpenseSheet(context),
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
              balance: data.currentBalance,
              showValues: showAmounts,
              onToggleValues: () async {
                final nextValue = !showAmounts;
                AmountVisibilityController.setVisible(nextValue);
                await ref
                    .read(settingsRepositoryProvider)
                    .setShowAmountsEnabled(nextValue);
              },
              onTap: () => context.push('/transactions'),
            ),
            loading: () => const SizedBox(
              height: 190,
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            error: (e, _) => SizedBox(
              height: 190,
              child: Center(child: Text('Failed to load: $e')),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: "TODAY'S SPEND",
                  icon: AppIcons.analytics,
                  accent: context.homeAccentGreen,
                  amount: todaySpent,
                  note: todayComparison.label,
                  noteColor: todayComparison.color,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _RemainingCard(
                  title: 'REMAINING',
                  accent: context.homeAccentPurple,
                  amount: summary.valueOrNull?.remainingBudget ?? 0,
                  note: () {
                    final data = summary.valueOrNull;
                    if (data == null) return '';
                    return 'of ${Formatters.currency(data.remainingBudget + data.monthlyExpense)} limit';
                  }(),
                  percent: () {
                    final data = summary.valueOrNull;
                    if (data == null) return 0;
                    final budget = data.remainingBudget + data.monthlyExpense;
                    if (budget <= 0) return 0;
                    return (data.remainingBudget / budget * 100)
                        .clamp(0, 100)
                        .round();
                  }(),
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
                0, (sum, r) => sum + r.amount);
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
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (var i = 0; i < items.length; i++)
                      TransactionRow.fromEntity(
                        tx: items[i],
                        categoryById: categoryById,
                        dateLabel: _dateLabel(items[i]),
                        isLast: i == items.length - 1,
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

  static String _dateLabel(dynamic tx) {
    final now = DateTime.now();
    final d = tx.date as DateTime;
    if (d.year == now.year && d.month == now.month && d.day == now.day) {
      return 'Today, ${DateFormat('h:mm a').format(d)}';
    }
    return Formatters.date(d);
  }

  static _SpendComparison _todayComparison(double today, double yesterday) {
    if (today <= 0 && yesterday <= 0) {
      return const _SpendComparison(
        label: 'No spend today',
        color: Color(0xFFA3A3A3),
      );
    }
    if (today <= 0) {
      return const _SpendComparison(
        label: 'No spend today',
        color: Color(0xFF3DD07B),
      );
    }
    if (yesterday <= 0) {
      return const _SpendComparison(
        label: 'No spend yesterday',
        color: Color(0xFFF55C5C),
      );
    }

    final change = ((today - yesterday) / yesterday) * 100;
    if (change.abs() < 0.05) {
      return const _SpendComparison(
        label: 'Same as yesterday',
        color: Color(0xFFA3A3A3),
      );
    }

    final isHigher = change > 0;
    return _SpendComparison(
      label:
          '${isHigher ? '+' : '-'}${change.abs().toStringAsFixed(0)}% vs yesterday',
      color: isHigher ? const Color(0xFFF55C5C) : const Color(0xFF3DD07B),
    );
  }
}

class _SpendComparison {
  const _SpendComparison({required this.label, required this.color});

  final String label;
  final Color color;
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
    required this.icon,
    required this.accent,
    required this.amount,
    required this.note,
    required this.noteColor,
  });

  final String title;
  final IconData icon;
  final Color accent;
  final double amount;
  final String note;
  final Color noteColor;

  @override
  Widget build(BuildContext context) {
    return HomeSurfaceCard(
      borderRadius: AppRadii.card,
      topAccent: accent,
      child: SizedBox(
        height: 170,
        child: Stack(
          children: [
            Positioned(
              right: -15,
              bottom: -20,
              child: IgnorePointer(
                child: Icon(
                  Icons.wallet_outlined,
                  size: 100,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF2C2C2E)
                      : const Color(0xFFE0E0E3),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TitleChip(icon: icon, title: title, tint: accent),
                  const Spacer(),
                  AmountView(
                    amount,
                    style: AppTypography.amount(
                      context,
                      fontSize: AppFontSizes.largeHeading,
                      color: context.textPrimary,
                    ).copyWith(letterSpacing: -0.5),
                    maskColor: context.textPrimary,
                    maskWidth: 7,
                    maskHeight: 20,
                    maskSpacing: 3,
                    maskRadius: 0,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    note,
                    style: TextStyle(
                      color: noteColor,
                      fontSize: AppFontSizes.body,
                      height: 1.2,
                    ),
                  ),
                ],
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
    required this.accent,
    required this.amount,
    required this.note,
    required this.percent,
  });

  final String title;
  final Color accent;
  final double amount;
  final String note;
  final int percent;

  @override
  Widget build(BuildContext context) {
    return HomeSurfaceCard(
      borderRadius: AppRadii.card,
      topAccent: accent,
      child: SizedBox(
        height: 170,
        child: Stack(
          children: [
            Positioned(
              right: -15,
              bottom: -20,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.35,
                  child: SizedBox(
                    width: 90,
                    height: 90,
                    child: _RingIndicator(value: percent, accent: accent),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _TitleChip(
                    icon: AppIcons.budget,
                    title: 'REMAINING',
                    tint: AppColors.homeAccentPurple,
                  ),
                  const Spacer(),
                  AmountView(
                    amount,
                    style: AppTypography.amount(
                      context,
                      fontSize: AppFontSizes.largeHeading,
                      color: context.textPrimary,
                    ).copyWith(letterSpacing: -0.5),
                    maskColor: context.textPrimary,
                    maskWidth: 7,
                    maskHeight: 20,
                    maskSpacing: 3,
                    maskRadius: 0,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    note,
                    style: TextStyle(
                      color: context.homeAccentGreen,
                      fontSize: AppFontSizes.body,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TitleChip extends StatelessWidget {
  const _TitleChip({
    required this.icon,
    required this.title,
    required this.tint,
  });

  final IconData icon;
  final String title;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: tint.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: tint, size: 18),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: context.textPrimary,
              fontSize: AppFontSizes.label,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.1,
            ),
          ),
        ),
      ],
    );
  }
}

class _RingIndicator extends StatelessWidget {
  const _RingIndicator({required this.value, required this.accent});

  final int value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 90,
      child: CustomPaint(
        painter: _RingPainter(
          value: value,
          accent: accent,
          trackColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF2C2C2E)
              : const Color(0xFFE0E0E3),
        ),
        child: Center(
          child: Text(
            '$value%',
            style: TextStyle(
              color: accent,
              fontSize: AppFontSizes.bodyLarge,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.value,
    required this.accent,
    required this.trackColor,
  });

  final int value;
  final Color accent;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - 10) / 2;
    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..color = trackColor;

    final valuePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..color = accent;

    canvas.drawCircle(center, radius, basePaint);
    final sweep = (value.clamp(0, 100) / 100) * 2 * 3.1415926535897932;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5707963267948966,
      sweep,
      false,
      valuePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.value != value ||
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final greenBg = isDark
        ? const Color(0xFF121C14)
        : AppColors.homeAccentGreen.withValues(alpha: 0.06);
    final greenBorder = isDark
        ? const Color(0xFF1B3420)
        : AppColors.homeAccentGreen.withValues(alpha: 0.15);
    final greenIconBg = isDark
        ? const Color(0xFF17311F)
        : AppColors.homeAccentGreen.withValues(alpha: 0.12);

    final redBg = isDark
        ? const Color(0xFF1A1314)
        : AppColors.homeAccentRed.withValues(alpha: 0.06);
    final redBorder = isDark
        ? const Color(0xFF352224)
        : AppColors.homeAccentRed.withValues(alpha: 0.15);
    final redIconBg = isDark
        ? const Color(0xFF332122)
        : AppColors.homeAccentRed.withValues(alpha: 0.12);

    return HomeSurfaceCard(
      onTap: onTap,
      borderRadius: AppRadii.card,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _SectionIconChip(
                icon: AppIcons.money,
                tint: context.homeAccentGreen,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  'LEND & BORROW',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.textPrimary,
                    fontSize: AppFontSizes.subhead,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'View all',
                style: TextStyle(color: context.textSecondary, fontSize: AppFontSizes.body),
              ),
              const SizedBox(width: 4),
              Icon(
                AppIcons.chevronRight,
                size: 16,
                color: context.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MiniMetricCard(
                  title: 'You Will Receive',
                  amount: toReceive,
                  tint: AppColors.homeAccentGreen,
                  icon: AppIcons.download,
                  backgroundColor: greenBg,
                  borderColor: greenBorder,
                  iconBackgroundColor: greenIconBg,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniMetricCard(
                  title: 'You Owe',
                  amount: toPay,
                  tint: AppColors.homeAccentRed,
                  icon: AppIcons.upload,
                  backgroundColor: redBg,
                  borderColor: redBorder,
                  iconBackgroundColor: redIconBg,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: context.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: context.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: context.border.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Icon(
                    AppIcons.usersRound,
                    color: context.homeAccentGreen,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$openPeople active people',
          style: TextStyle(
            color: context.textPrimary,
            fontSize: AppFontSizes.label,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'Tap to open',
                        style: TextStyle(
                          color: context.textSecondary,
                          fontSize: AppFontSizes.label,
                        ),
                      ),
                    ],
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

class _MiniMetricCard extends StatelessWidget {
  const _MiniMetricCard({
    required this.title,
    required this.amount,
    required this.tint,
    required this.icon,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconBackgroundColor,
  });

  final String title;
  final double amount;
  final Color tint;
  final IconData icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconBackgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
              width: 36,
              height: 36,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: tint, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: context.textPrimary,
                    fontSize: AppFontSizes.small,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                AmountView(
                  amount,
                  style: TextStyle(
                    color: tint,
                    fontSize: AppFontSizes.title,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                  maskColor: tint,
                  maskWidth: 6,
                  maskHeight: 16,
                  maskSpacing: 3,
                  maskRadius: 0,
                ),
              ],
            ),
          ),
        ],
      ),
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
  });

  final double amount;
  final double income;

  @override
  Widget build(BuildContext context) {
    final pct = income > 0 ? (amount / income * 100) : 0.0;
    final pctDisplay = '${pct.round()}% of income';

    return HomeSurfaceCard(
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
                  pctDisplay,
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
            maskWidth: 8,
            maskHeight: 22,
            maskSpacing: 4,
            maskRadius: 0,
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
