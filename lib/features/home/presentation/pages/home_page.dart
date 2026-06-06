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
import 'package:spendly/core/widgets/noir_header.dart';
import 'package:spendly/features/categories/presentation/providers/categories_provider.dart';
import 'package:spendly/features/home/presentation/providers/home_provider.dart';
import 'package:spendly/features/home/presentation/widgets/spendly_black_card.dart';
import 'package:spendly/features/lend/presentation/providers/lend_provider.dart';
import 'package:spendly/features/recurring/presentation/providers/recurring_provider.dart';
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
    final recurringRules =
        ref.watch(recurringRulesProvider).valueOrNull ?? const [];
    final activeRecurring = recurringRules.where((r) => r.isActive).toList()
      ..sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
    final nearestRecurring = activeRecurring.isEmpty
        ? null
        : activeRecurring.first;
    final categories = ref.watch(allCategoriesProvider).valueOrNull ?? const [];
    final categoryById = {for (final c in categories) c.id: c.name};

    return Scaffold(
      appBar: NoirHeader(
        showLeading: true,
        leadingIcon: AppIcons.bell,
        onLeadingTap: () => context.push('/notifications'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddExpenseSheet(context),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
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
                child: summary.when(
                  data: (data) => _StatTile(
                    title: 'REMAINING',
                    amount: Formatters.currency(data.remainingBudget),
                    note:
                        'of ${Formatters.currency(data.remainingBudget + data.monthlyExpense)} limit',
                    active: true,
                    noteColor: const Color(0xFF57F28F),
                  ),
                  loading: () => const _StatTile(
                    title: 'REMAINING',
                    amount: '...',
                    note: '',
                    active: true,
                  ),
                  error: (_, __) => const _StatTile(
                    title: 'REMAINING',
                    amount: '--',
                    note: '',
                    active: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
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
                  color: const Color(0xFF0E0E0E),
                  border: Border.all(color: const Color(0xFF242424)),
                ),
                child: Row(
                  children: [
                    const Icon(AppIcons.repeat, size: 16, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _recurringSummaryText(
                          activeRecurring.length,
                          nearestRecurring,
                        ),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFB2B2B2),
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
          const Divider(height: 28, color: AppColors.borderDark),
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
                        title: categoryById[tx.categoryId] ?? tx.categoryId,
                        subtitle: _subtitle(tx),
                        amount: tx.amount,
                        isIncome: tx.type == TransactionType.income,
                        icon: _iconFor(
                          categoryById[tx.categoryId] ?? tx.categoryId,
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
        color: Color(0xFF57F28F),
      );
    }
    if (yesterday <= 0) {
      return const _SpendComparison(
        label: 'No spend yesterday',
        color: Color(0xFFFF6B6B),
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
      color: isHigher ? const Color(0xFFFF6B6B) : const Color(0xFF57F28F),
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
        color: const Color(0xFF0E0E0E),
        border: Border.all(color: const Color(0xFF242424)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (active)
            const Divider(height: 0, thickness: 2, color: Colors.white),
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
    required this.isIncome,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final double amount;
  final bool isIncome;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderDark)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Icon(icon, size: 20, color: Colors.white),
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
                  style: const TextStyle(
                    color: Color(0xFFB2B2B2),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'}${Formatters.currency(amount)}',
            style: AppTypography.amount(
              context,
              fontSize: 20,
              color: isIncome ? const Color(0xFF57F28F) : Colors.white,
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
          color: const Color(0xFF0E0E0E),
          border: Border.all(color: const Color(0xFF242424)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(AppIcons.money, size: 16, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'LEND & BORROW',
                  style: AppTypography.metadata(
                    context,
                  ).copyWith(color: const Color(0xFFBDBDBD)),
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
                    valueColor: const Color(0xFF57F28F),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _LendMetric(
                    label: 'You Owe',
                    value: Formatters.currency(toPay),
                    valueColor: const Color(0xFFFF6B6B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '$openPeople active people - Tap to open',
              style: const TextStyle(color: Color(0xFFB2B2B2), fontSize: 12),
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
        border: Border.all(color: const Color(0xFF2B2B2B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFFA3A3A3)),
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
