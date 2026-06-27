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
import 'package:spendly/features/categories/presentation/providers/categories_provider.dart';
import 'package:spendly/features/home/presentation/widgets/home_header.dart';
import 'package:spendly/features/home/presentation/providers/home_provider.dart';
import 'package:spendly/features/home/presentation/widgets/spendly_black_card.dart';
import 'package:spendly/features/lend/presentation/providers/lend_provider.dart';
import 'package:spendly/features/recurring/presentation/providers/recurring_provider.dart';
import 'package:spendly/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:spendly/features/settings/presentation/providers/settings_provider.dart';
import 'package:spendly/features/categories/domain/entities/category_entity.dart';
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
    final recurringRules =
        ref.watch(recurringRulesProvider).valueOrNull ?? const [];
    final activeRecurring = recurringRules.where((r) => r.isActive).toList()
      ..sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
    final nearestRecurring = activeRecurring.isEmpty
        ? null
        : activeRecurring.first;
    final categories = ref.watch(allCategoriesProvider).valueOrNull ?? const [];
    final categoryById = {for (final c in categories) c.id: c};

    return Scaffold(
      appBar: const HomeHeader(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddExpenseSheet(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
        child: const Icon(AppIcons.plus, size: 28),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.smPlus,
          AppSpacing.md,
          AppSpacing.smPlus,
          96,
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
              height: 260,
              child: Center(
                child: SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            error: (e, _) => Text('Failed to load: $e'),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  title: "TODAY'S SPEND",
                  amount: Formatters.currency(todaySpent),
                  note: todayComparison.label,
                  noteColor: todayComparison.color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatTile(
                  title: 'REMAINING',
                  amount: Formatters.currency(
                      summary.valueOrNull?.remainingBudget ?? 0),
                  note: () {
                    final data = summary.valueOrNull;
                    if (data == null) return '';
                    return 'of ${Formatters.currency(data.remainingBudget + data.monthlyExpense)} limit';
                  }(),
                  active: true,
                  noteColor: const Color(0xFF3DD07B),
                ),
              ),
            ],
          ),
          () {
            final data = summary.valueOrNull;
            if (data == null || data.monthlyInvestment <= 0) return const SizedBox(height: 28);
            final income = data.monthlyIncome > 0 ? data.monthlyIncome : 1;
            final pct = (data.monthlyInvestment / income * 100).toStringAsFixed(0);
            return Column(
              children: [
                const SizedBox(height: 16),
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(
                      color: context.surface,
                      border: Border.all(color: context.border),
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'INVESTED',
                        style: AppTypography.metadata(context).copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        Formatters.currency(data.monthlyInvestment),
                        style: const TextStyle(
                          color: Color(0xFF8B5CF6),
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.4)),
                            borderRadius: BorderRadius.circular(AppRadii.sm),
                          ),
                          child: Text(
                            '$pct% of income',
                          style: const TextStyle(
                            color: Color(0xFF8B5CF6),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
              ],
            );
          }(),
          lendOverview.when(
            data: (lend) => _LendQuickCard(
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
              if (activeRecurring.isNotEmpty) ...[
            const SizedBox(height: 12),
            InkWell(
              onTap: () => context.push('/recurring'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: context.surface,
                  border: Border.all(color: context.border),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: Row(
                  children: [
                    Icon(
                      AppIcons.repeat,
                      size: 16,
                      color: AppIcons.getColorForIcon(AppIcons.repeat, brightness: Theme.of(context).brightness),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _recurringSummaryText(
                          activeRecurring.length,
                          nearestRecurring,
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          color: context.textSecondary,
                        ),
                      ),
                    ),
                    const Icon(AppIcons.chevronRight, size: 16),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Recent Transactions',
                  style: AppTypography.sectionTitle(context),
                ),
              ),
              TextButton(
                onPressed: () => context.push('/transactions'),
                child: const Text('View all'),
              ),
            ],
          ),
          Divider(height: 28, color: context.border),
          recent.when(
            data: (items) {
              if (items.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text('No transactions yet'),
                );
              }
              return Column(
                children: items
                    .map(
                      (tx) => _TransactionRow(
                        title:
                            categoryById[tx.categoryId]?.name ?? tx.categoryId,
                        subtitle: _subtitle(tx),
                        amount: tx.amount,
                        type: tx.type,
                        icon: _iconFor(
                          categoryById[tx.categoryId]?.name ?? tx.categoryId,
                        ),
                        iconColor: _categoryIconColor(
                          categoryById[tx.categoryId],
                          tx.type,
                        ),
                      ),
                    )
                    .toList(growable: false),
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

  static String _subtitle(dynamic tx) {
    final now = DateTime.now();
    final d = tx.date as DateTime;
    if (d.year == now.year && d.month == now.month && d.day == now.day) {
      return 'Today, ${DateFormat('h:mm a').format(d)}';
    }
    return Formatters.date(d);
  }

  static String _recurringSummaryText(int activeCount, dynamic nearest) {
    if (nearest == null) {
      return '$activeCount active recurring transactions';
    }
    final due = Formatters.date(nearest.nextDueDate);
    return '$activeCount recurring transactions • Next: ${nearest.title} on $due';
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

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.title,
    required this.amount,
    required this.note,
    this.active = false,
    this.noteColor = const Color(0xFFA3A3A3),
  });

  final String title;
  final String amount;
  final String note;
  final bool active;
  final Color noteColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 208,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.surface,
        border: Border.all(color: context.border),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (active)
            Divider(height: 0, thickness: 2, color: context.textPrimary),
          if (active) const SizedBox(height: 10),
          Text(
            title,
            style: AppTypography.metadata(context).copyWith(height: 1.25),
          ),
          const Spacer(),
          Text(amount, style: AppTypography.amount(context, fontSize: 18)),
          const SizedBox(height: 8),
          Text(
            note,
            style: TextStyle(color: noteColor, fontSize: 13, height: 1.3),
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
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final String subtitle;
  final double amount;
  final TransactionType type;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.border)),
      ),
      child: Row(
        children: [
            Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: context.surfaceAlt,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.rowTitle(context)),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: context.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _amountWithSign(amount, type),
            style: AppTypography.amount(
              context,
              fontSize: 20,
              color: type == TransactionType.income
                  ? const Color(0xFF3DD07B)
                  : type == TransactionType.investment
                      ? const Color(0xFF8B5CF6)
                      : context.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _LendQuickCard extends StatelessWidget {
  const _LendQuickCard({
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
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.surface,
          border: Border.all(color: context.border),
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  AppIcons.money,
                  size: 16,
                  color: AppIcons.getColorForIcon(AppIcons.money, brightness: Theme.of(context).brightness),
                ),
                const SizedBox(width: 8),
                Text(
                  'LEND & BORROW',
                  style: AppTypography.metadata(
                    context,
                  ).copyWith(color: context.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _LendMetric(
                    label: 'You Receive',
                    value: Formatters.currency(toReceive),
                    valueColor: const Color(0xFF3DD07B),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _LendMetric(
                    label: 'You Owe',
                    value: Formatters.currency(toPay),
                    valueColor: const Color(0xFFF55C5C),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '$openPeople active people - Tap to open',
              style: TextStyle(color: context.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _LendMetric extends StatelessWidget {
  const _LendMetric({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          border: Border.all(color: context.border),
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 11, color: context.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.amount(
              context,
              fontSize: 16,
              color: valueColor,
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
