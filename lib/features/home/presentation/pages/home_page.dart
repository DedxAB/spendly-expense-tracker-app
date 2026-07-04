import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:spendly/core/constants/app_enums.dart';
import 'package:spendly/core/theme/app_design_tokens.dart';
import 'package:spendly/core/theme/app_icons.dart';
import 'package:spendly/core/theme/app_typography.dart';
import 'package:spendly/core/utils/amount_visibility.dart';
import 'package:spendly/core/utils/formatters.dart';
import 'package:spendly/features/categories/domain/entities/category_entity.dart';
import 'package:spendly/features/categories/presentation/providers/categories_provider.dart';
import 'package:spendly/features/home/presentation/providers/home_provider.dart';
import 'package:spendly/features/home/presentation/widgets/home_header.dart';
import 'package:spendly/features/home/presentation/widgets/home_surface_card.dart';
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
    final dailyGraph = ref.watch(currentMonthDailyIncomeExpenseProvider).valueOrNull ?? (income: <double>[], expense: <double>[]);
    final todaySpent = ref.watch(todaySpentProvider).valueOrNull ?? 0;
    final yesterdaySpent = ref.watch(yesterdaySpentProvider).valueOrNull ?? 0;
    final todayComparison = _todayComparison(todaySpent, yesterdaySpent);
    final recent = ref.watch(recentTransactionsProvider);
    final lendOverview = ref.watch(lendOverviewProvider);
    final settings = ref.watch(settingsStreamProvider).valueOrNull;
    final showAmounts = settings?.showAmountsEnabled ?? true;
    final categories = ref.watch(allCategoriesProvider).valueOrNull ?? const [];
    final categoryById = {for (final c in categories) c.id: c};

    return Scaffold(
      backgroundColor: context.background,
      appBar: const HomeHeader(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddExpenseSheet(context),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        shape: const CircleBorder(),
        child: const Icon(AppIcons.plus, size: 36),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.sm,
          28,
        ),
        children: [
          summary.when(
            data: (data) => SpendlyBlackCard(
              balance: data.currentBalance,
              showValues: showAmounts,
              dailyIncome: dailyGraph.income,
              dailyExpense: dailyGraph.expense,
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
                  value: Formatters.currency(todaySpent),
                  note: todayComparison.label,
                  noteColor: todayComparison.color,
                  trailing: const _SpendBagSketch(),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _RemainingCard(
                  title: 'REMAINING',
                  accent: context.homeAccentPurple,
                  value: Formatters.currency(
                    summary.valueOrNull?.remainingBudget ?? 0,
                  ),
                  note: () {
                    final data = summary.valueOrNull;
                    if (data == null) return '';
                    return 'of ${Formatters.currency(data.remainingBudget + data.monthlyExpense)} limit';
                  }(),
                  percent: () {
                    final data = summary.valueOrNull;
                    if (data == null || data.monthlyIncome <= 0) {
                      return 0;
                    }
                    return (data.monthlyExpense / data.monthlyIncome * 100)
                        .clamp(0, 100)
                        .round();
                  }(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          lendOverview.when(
            data: (lend) => _LendBorrowCard(
              toReceive: lend.totalToReceive,
              toPay: lend.totalToPay,
              openPeople: lend.peopleBalances
                  .where((p) => p.activeEntryCount > 0)
                  .length,
              onTap: () => context.push('/lend'),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 18),
          _SectionHeader(
            title: 'Recent Transactions',
            onTap: () => context.push('/transactions'),
          ),
          const SizedBox(height: 14),
          recent.when(
            data: (items) {
              if (items.isEmpty) {
                return const _EmptyTransactionsCard();
              }
              return HomeSurfaceCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (var i = 0; i < items.length; i++)
                      _TransactionRow(
                        title: items[i].note?.trim().isNotEmpty == true
                            ? items[i].note!.trim()
                            : (categoryById[items[i].categoryId]?.name ??
                                  items[i].categoryId),
                        subtitle:
                            categoryById[items[i].categoryId]?.name ??
                            items[i].categoryId,
                        amount: items[i].amount,
                        type: items[i].type,
                        isLast: i == items.length - 1,
                        dateLabel: _dateLabel(items[i]),
                        icon: _iconFor(
                          categoryById[items[i].categoryId]?.name ??
                              items[i].categoryId,
                        ),
                        iconColor: _categoryIconColor(
                          categoryById[items[i].categoryId],
                          items[i].type,
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

  static IconData _iconFor(String text) {
    return AppIcons.getIconForCategory(text);
  }

  static Color _categoryIconColor(
    CategoryEntity? category,
    TransactionType type,
  ) {
    if (category != null) {
      return AppIcons.getColorForCategory(category.name, type);
    }
    switch (type) {
      case TransactionType.income:
        return AppColors.income;
      case TransactionType.investment:
        return const Color(0xFF8B5CF6);
      case TransactionType.expense:
        return AppColors.expense;
    }
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
              fontSize: 18,
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
              Text('View all', style: TextStyle(fontSize: 13)),
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
    required this.value,
    required this.note,
    required this.noteColor,
    required this.trailing,
  });

  final String title;
  final IconData icon;
  final Color accent;
  final String value;
  final String note;
  final Color noteColor;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return HomeSurfaceCard(
      borderRadius: AppRadii.card,
      topAccent: accent,
      padding: const EdgeInsets.all(14),
      child: SizedBox(
        height: 170,
        child: Stack(
          children: [
            Positioned(
              right: 0,
              bottom: 0,
              child: Opacity(opacity: 0.25, child: trailing),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TitleChip(icon: icon, title: title, tint: accent),
                const Spacer(),
                Text(
                  value,
                  style: AppTypography.amount(
                    context,
                    fontSize: 26,
                    color: context.textPrimary,
                  ).copyWith(letterSpacing: -0.5),
                ),
                const SizedBox(height: 6),
                Text(
                  note,
                  style: TextStyle(color: noteColor, fontSize: 13, height: 1.2),
                ),
              ],
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
    required this.value,
    required this.note,
    required this.percent,
  });

  final String title;
  final Color accent;
  final String value;
  final String note;
  final int percent;

  @override
  Widget build(BuildContext context) {
    return HomeSurfaceCard(
      borderRadius: AppRadii.card,
      topAccent: accent,
      padding: const EdgeInsets.all(14),
      child: SizedBox(
        height: 170,
        child: Stack(
          children: [
            Positioned(
              top: 52,
              left: 0,
              right: 0,
              child: Center(child: _RingIndicator(value: percent, accent: accent)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _TitleChip(
                  icon: AppIcons.budget,
                  title: 'REMAINING',
                  tint: AppColors.homeAccentPurple,
                ),
                const Spacer(),
                Text(
                  value,
                  style: AppTypography.amount(
                    context,
                    fontSize: 26,
                    color: context.textPrimary,
                  ).copyWith(letterSpacing: -0.5),
                ),
                const SizedBox(height: 6),
                Text(
                  note,
                  style: TextStyle(
                    color: context.homeAccentGreen,
                    fontSize: 13,
                    height: 1.2,
                  ),
                ),
              ],
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
        Text(
          title,
          style: TextStyle(
            color: context.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
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
      width: 66,
      height: 66,
      child: CustomPaint(
        painter: _RingPainter(
          value: value,
          accent: accent,
          trackColor: context.border.withValues(alpha: 0.6),
        ),
        child: Center(
          child: Text(
            '$value%',
            style: TextStyle(
              color: accent,
              fontSize: 14,
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
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..color = trackColor;

    final valuePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
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
                icon: AppIcons.personAdd,
                tint: context.homeAccentGreen,
              ),
              const SizedBox(width: 10),
              Text(
                'LEND & BORROW',
                style: TextStyle(
                  color: context.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
              const Spacer(),
              Text(
                'View all',
                style: TextStyle(color: context.textSecondary, fontSize: 13),
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
                  title: 'You Receive',
                  value: Formatters.currency(toReceive),
                  tint: AppColors.homeAccentGreen,
                  icon: AppIcons.download,
                  backgroundColor: const Color(0xFF121C14),
                  borderColor: const Color(0xFF1B3420),
                  iconBackgroundColor: const Color(0xFF17311F),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniMetricCard(
                  title: 'You Owe',
                  value: Formatters.currency(toPay),
                  tint: AppColors.homeAccentRed,
                  icon: AppIcons.upload,
                  backgroundColor: const Color(0xFF1A1314),
                  borderColor: const Color(0xFF352224),
                  iconBackgroundColor: const Color(0xFF332122),
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
                    AppIcons.personAdd,
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
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'Tap to open',
                        style: TextStyle(
                          color: context.textSecondary,
                          fontSize: 12,
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
    required this.value,
    required this.tint,
    required this.icon,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconBackgroundColor,
  });

  final String title;
  final String value;
  final Color tint;
  final IconData icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconBackgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
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
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: tint,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
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

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.type,
    required this.isLast,
    required this.dateLabel,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final String subtitle;
  final double amount;
  final TransactionType type;
  final bool isLast;
  final String dateLabel;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : BorderSide(color: context.border.withValues(alpha: 0.6)),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: context.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: context.border.withValues(alpha: 0.6)),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        subtitle,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    _TagChip(
                      label: _typeLabel(type),
                      tint: _categoryTint(type),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _amountWithSign(amount, type),
                style: AppTypography.amount(
                  context,
                  fontSize: 15,
                  color: type == TransactionType.income
                      ? context.homeAccentGreen
                      : type == TransactionType.investment
                      ? AppColors.homeAccentPurple
                      : context.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dateLabel,
                style: TextStyle(color: context.textSecondary, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label, required this.tint});

  final String label;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: tint.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: tint,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EmptyTransactionsCard extends StatelessWidget {
  const _EmptyTransactionsCard();

  @override
  Widget build(BuildContext context) {
    return HomeSurfaceCard(
      borderRadius: AppRadii.card,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      child: SizedBox(
        height: 160,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const _EmptyTransactionSketch(),
            const SizedBox(height: 12),
            Text(
              'No transactions yet',
              style: TextStyle(
                color: context.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your recent transactions will appear here',
              textAlign: TextAlign.center,
              style: TextStyle(color: context.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

String _typeLabel(TransactionType type) {
  return switch (type) {
    TransactionType.income => 'Income',
    TransactionType.investment => 'Asset',
    TransactionType.expense => 'Expense',
  };
}

Color _categoryTint(TransactionType type) {
  return switch (type) {
    TransactionType.income => AppColors.homeAccentGreen,
    TransactionType.investment => AppColors.homeAccentPurple,
    TransactionType.expense => AppColors.homeAccentRed,
  };
}

class _EmptyTransactionSketch extends StatelessWidget {
  const _EmptyTransactionSketch();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 76,
      child: Stack(
        children: [
          Positioned(
            left: 12,
            top: 18,
            child: Container(
              width: 78,
              height: 56,
              decoration: BoxDecoration(
                color: context.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: context.border.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
          Positioned(
            left: 22,
            top: 8,
            child: Container(
              width: 66,
              height: 64,
              decoration: BoxDecoration(
                color: context.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: context.border.withValues(alpha: 0.6),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: context.textSecondary.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 6,
                      width: 28,
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: context.textSecondary.withValues(alpha: 0.24),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 6,
                      width: 18,
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: context.textSecondary.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            child: Transform.rotate(
              angle: -0.45,
              child: Container(
                width: 14,
                height: 3,
                color: context.textSecondary.withValues(alpha: 0.35),
              ),
            ),
          ),
          Positioned(
            right: 8,
            top: 12,
            child: Transform.rotate(
              angle: 0.45,
              child: Container(
                width: 14,
                height: 3,
                color: context.textSecondary.withValues(alpha: 0.35),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpendBagSketch extends StatelessWidget {
  const _SpendBagSketch();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 70,
      child: Stack(
        children: [
          Positioned(
            right: 12,
            bottom: 14,
            child: Container(
              width: 74,
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: context.border.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
          Positioned(
            right: 24,
            bottom: 34,
            child: Transform.rotate(
              angle: -0.28,
              child: Container(
                width: 42,
                height: 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: context.border.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 36,
            bottom: 28,
            child: Container(
              width: 28,
              height: 2,
              color: context.border.withValues(alpha: 0.6),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: context.surface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: context.border.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _amountWithSign(double amount, TransactionType type) {
  if (type == TransactionType.income) {
    return '+${Formatters.currency(amount)}';
  }
  if (type == TransactionType.investment && amount < 0) {
    return '+${Formatters.currency(amount.abs())}';
  }
  return '-${Formatters.currency(amount.abs())}';
}
