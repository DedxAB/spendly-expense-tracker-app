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
import 'package:spendly/core/widgets/app_header.dart';
import 'package:spendly/core/widgets/transaction_row.dart';
import 'package:spendly/features/categories/domain/entities/category_entity.dart';
import 'package:spendly/features/categories/presentation/providers/categories_provider.dart';
import 'package:spendly/features/home/presentation/providers/home_provider.dart';
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
      appBar: const AppHeader(mode: AppHeaderMode.home),
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
                  value: Formatters.currency(todaySpent),
                  note: todayComparison.label,
                  noteColor: todayComparison.color,
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
                      TransactionRow(
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
                        paymentMode: items[i].paymentMode,
                        cardType: items[i].cardType,
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
  });

  final String title;
  final IconData icon;
  final Color accent;
  final String value;
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
                  Text(
                    value,
                    style: AppTypography.amount(
                      context,
                      fontSize: 20,
                      color: context.textPrimary,
                    ).copyWith(letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    note,
                    style: TextStyle(
                      color: noteColor,
                      fontSize: 13,
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
                  Text(
                    value,
                    style: AppTypography.amount(
                      context,
                      fontSize: 20,
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
                icon: AppIcons.usersRound,
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
                  backgroundColor: greenBg,
                  borderColor: greenBorder,
                  iconBackgroundColor: greenIconBg,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniMetricCard(
                  title: 'You Owe',
                  value: Formatters.currency(toPay),
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
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: tint,
                    fontSize: 16,
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

class _EmptyTransactionsCard extends StatelessWidget {
  const _EmptyTransactionsCard();

  @override
  Widget build(BuildContext context) {
    return HomeSurfaceCard(
      borderRadius: AppRadii.card,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: SizedBox(
        height: 170,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: const _EmptyTransactionIllustration()),
            const SizedBox(height: 14),
            Text(
              'No transactions yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w600,
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

class _EmptyTransactionIllustration extends StatelessWidget {
  const _EmptyTransactionIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      height: 72,
      child: CustomPaint(
        painter: _ReceiptIllustrationPainter(
          borderColor: context.border.withValues(alpha: 0.5),
          surfaceColor: context.surface,
          surfaceAltColor: context.surfaceAlt,
          iconColor: context.textSecondary.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}

class _ReceiptIllustrationPainter extends CustomPainter {
  _ReceiptIllustrationPainter({
    required this.borderColor,
    required this.surfaceColor,
    required this.surfaceAltColor,
    required this.iconColor,
  });

  final Color borderColor;
  final Color surfaceColor;
  final Color surfaceAltColor;
  final Color iconColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(14, 18, 58, 42),
      const Radius.circular(10),
    );
    final paint = Paint()
      ..color = surfaceAltColor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rrect, paint);

    final paintBorder = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(rrect, paintBorder);

    final rrect2 = RRect.fromRectAndRadius(
      Rect.fromLTWH(18, 24, 58, 42),
      const Radius.circular(10),
    );
    final paint2 = Paint()
      ..color = surfaceColor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rrect2, paint2);

    canvas.drawRRect(rrect2, paintBorder);

    final paintLine = Paint()
      ..color = iconColor
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(30, 34, 34, 3),
        const Radius.circular(2),
      ),
      paintLine,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(30, 42, 22, 3),
        const Radius.circular(2),
      ),
      paintLine..color = iconColor,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(30, 50, 12, 3),
        const Radius.circular(2),
      ),
      paintLine..color = iconColor,
    );

    canvas.save();
    canvas.translate(8, 12);
    canvas.rotate(0.08);
    final rrect3 = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, 32, 22),
      const Radius.circular(6),
    );
    canvas.drawRRect(rrect3, paint..color = surfaceAltColor);
    canvas.drawRRect(rrect3, paintBorder);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ReceiptIllustrationPainter oldDelegate) =>
      oldDelegate.borderColor != borderColor ||
      oldDelegate.surfaceColor != surfaceColor ||
      oldDelegate.surfaceAltColor != surfaceAltColor ||
      oldDelegate.iconColor != iconColor;
}
