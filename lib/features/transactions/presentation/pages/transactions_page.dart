import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:spendly/core/constants/app_enums.dart';
import 'package:spendly/core/theme/app_design_tokens.dart';
import 'package:spendly/core/theme/app_icons.dart';
import 'package:spendly/core/theme/app_typography.dart';
import 'package:spendly/core/utils/formatters.dart';
import 'package:spendly/core/widgets/app_confirm_dialog.dart';
import 'package:spendly/core/widgets/app_modal_surface.dart';
import 'package:spendly/core/widgets/noir_header.dart';
import 'package:spendly/features/categories/presentation/providers/categories_provider.dart';
import 'package:spendly/features/transactions/domain/entities/transaction_entity.dart';
import 'package:spendly/features/transactions/presentation/pages/add_transaction_page.dart';
import 'package:spendly/features/transactions/presentation/providers/transactions_provider.dart';

class TransactionsPage extends ConsumerWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(transactionFilterProvider);
    final filterController = ref.read(transactionFilterProvider.notifier);
    final transactions = ref.watch(filteredTransactionsProvider);
    final categories = ref.watch(allCategoriesProvider).valueOrNull ?? const [];
    final categoryById = {for (final c in categories) c.id: c.name};

    return Scaffold(
      appBar: NoirHeader(
        showLeading: true,
        leadingIcon: AppIcons.calendar,
        onLeadingTap: () => context.push('/calendar'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.smPlus,
          AppSpacing.mdPlus,
          AppSpacing.smPlus,
          AppSpacing.md,
        ),
        children: [
          Text('Search Ledger', style: AppTypography.screenTitle(context)),
          const SizedBox(height: AppSpacing.smPlus),
          TextField(
            onChanged: filterController.setSearchQuery,
            style: const TextStyle(fontSize: 18),
            decoration: const InputDecoration(
              hintText: 'MERCHANT, CATEGORY, OR AMOUNT',
              prefixIcon: Icon(AppIcons.search),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 134,
              child: OutlinedButton.icon(
                onPressed: () => _openFilters(context, ref, filters),
                icon: const Icon(AppIcons.filter, size: 16),
                label: const Text('Filters'),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.mdPlus),
          const Divider(color: AppColors.borderDark),
          transactions.when(
            data: (items) {
              if (items.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Text('No transactions found'),
                );
              }

              double upiExpense = 0, upiIncome = 0;
              double cardExpense = 0, cardIncome = 0;
              double cashExpense = 0, cashIncome = 0;
              for (final tx in items) {
                final amt = tx.amount;
                if (tx.paymentMode == PaymentMode.upi) {
                  if (tx.type == TransactionType.expense) {
                    upiExpense += amt;
                  } else {
                    upiIncome += amt;
                  }
                } else if (tx.paymentMode == PaymentMode.card) {
                  if (tx.type == TransactionType.expense) {
                    cardExpense += amt;
                  } else {
                    cardIncome += amt;
                  }
                } else if (tx.paymentMode == PaymentMode.cash) {
                  if (tx.type == TransactionType.expense) {
                    cashExpense += amt;
                  } else {
                    cashIncome += amt;
                  }
                }
              }

              final grouped = _groupByDate(items);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _AccountBreakupCard(
                          name: 'UPI',
                          expense: upiExpense,
                          income: upiIncome,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _AccountBreakupCard(
                          name: 'Card',
                          expense: cardExpense,
                          income: cardIncome,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _AccountBreakupCard(
                          name: 'Cash',
                          expense: cashExpense,
                          income: cashIncome,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.borderDark),
                  ...grouped.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 26),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key,
                            style: AppTypography.sectionTitle(context),
                          ),
                          const SizedBox(height: 12),
                          const Divider(color: AppColors.borderDark),
                          ...entry.value.map(
                            (tx) => Dismissible(
                              key: ValueKey(tx.id),
                              confirmDismiss: (direction) async {
                                if (direction == DismissDirection.startToEnd) {
                                  await showAddExpenseSheet(
                                    context,
                                    existing: tx,
                                  );
                                  return false;
                                }
                                return showAppDeleteConfirmDialog(
                                  context,
                                  title: 'Delete transaction?',
                                  message: 'This transaction will be removed.',
                                );
                              },
                              onDismissed: (_) {
                                ref
                                    .read(transactionActionsProvider)
                                    .softDelete(tx.id);
                              },
                              background: Container(
                                alignment: Alignment.centerLeft,
                                color: const Color(0xFF1A1A1A),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: const Icon(AppIcons.edit),
                              ),
                              secondaryBackground: Container(
                                alignment: Alignment.centerRight,
                                color: const Color(0xFF1A1A1A),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: const Icon(AppIcons.trash),
                              ),
                              child: _HistoryRow(
                                title:
                                    categoryById[tx.categoryId] ??
                                    tx.categoryId,
                                subtitle: tx.note?.trim() ?? '',
                                paymentModeLabel: tx.paymentMode.label,
                                amount: tx.amount,
                                income: tx.type == TransactionType.income,
                                icon: _iconFor(
                                  categoryById[tx.categoryId] ?? tx.categoryId,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
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

  static Map<String, List<TransactionEntity>> _groupByDate(
    List<TransactionEntity> items,
  ) {
    final now = DateTime.now();
    final map = <String, List<TransactionEntity>>{};
    for (final tx in items) {
      final day = DateTime(tx.date.year, tx.date.month, tx.date.day);
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final key = day == today
          ? 'Today'
          : day == yesterday
          ? 'Yesterday'
          : DateFormat('MMMM d, yyyy').format(tx.date);
      map.putIfAbsent(key, () => []).add(tx);
    }
    return map;
  }

  static IconData _iconFor(String text) {
    return AppIcons.getIconForCategory(text);
  }

  Future<void> _openFilters(
    BuildContext context,
    WidgetRef ref,
    TransactionFilterState filters,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return AppModalSurface(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.sm,
              AppSpacing.xs,
              AppSpacing.sm,
              MediaQuery.of(sheetContext).viewInsets.bottom + AppSpacing.sm,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 64,
                    height: 4,
                    color: const Color(0xFF6A6A6A),
                  ),
                ),
                const SizedBox(height: AppSpacing.smPlus),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Filters',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Type',
                    style: TextStyle(
                      color: Color(0xFFB3B3B3),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: AppSpacing.xs,
                  children: [
                    ChoiceChip(
                      label: const Text('All'),
                      selected: filters.type == null,
                      onSelected: (_) => ref
                          .read(transactionFilterProvider.notifier)
                          .setType(null),
                    ),
                    ChoiceChip(
                      label: const Text('Income'),
                      selected: filters.type == 'income',
                      onSelected: (_) => ref
                          .read(transactionFilterProvider.notifier)
                          .setType('income'),
                    ),
                    ChoiceChip(
                      label: const Text('Expense'),
                      selected: filters.type == 'expense',
                      onSelected: (_) => ref
                          .read(transactionFilterProvider.notifier)
                          .setType('expense'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Payment Mode',
                    style: TextStyle(
                      color: Color(0xFFB3B3B3),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: AppSpacing.xs,
                  children: PaymentMode.values
                      .map(
                        (m) => ChoiceChip(
                          label: Text(m.label),
                          selected: filters.paymentMode == m,
                          onSelected: (_) => ref
                              .read(transactionFilterProvider.notifier)
                              .applyAdvanced(
                                paymentMode: filters.paymentMode == m
                                    ? null
                                    : m,
                                minAmount: filters.minAmount,
                                maxAmount: filters.maxAmount,
                                sortOption: filters.sortOption,
                                customFrom: filters.customFrom,
                                customTo: filters.customTo,
                              ),
                        ),
                      )
                      .toList(growable: false),
                ),
                const SizedBox(height: AppSpacing.smPlus),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    required this.title,
    required this.subtitle,
    required this.paymentModeLabel,
    required this.amount,
    required this.income,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String paymentModeLabel;
  final double amount;
  final bool income;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
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
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(title, style: AppTypography.rowTitle(context)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF333333)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        paymentModeLabel.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFA3A3A3),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  subtitle.isNotEmpty ? subtitle : 'No note',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: subtitle.isNotEmpty
                        ? const Color(0xFFB5B5B5)
                        : const Color(0xFF6B6B6B),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${income ? '+' : '-'}${Formatters.currency(amount)}',
            style: AppTypography.amount(
              context,
              fontSize: 16,
            ).copyWith(color: income ? const Color(0xFF5DF393) : Colors.white),
          ),
        ],
      ),
    );
  }
}

class _AccountBreakupCard extends StatelessWidget {
  const _AccountBreakupCard({
    required this.name,
    required this.expense,
    required this.income,
  });

  final String name;
  final double expense;
  final double income;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0E0E0E),
        border: Border.all(color: AppColors.borderDark),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '-${Formatters.currency(expense)}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFFB3A8),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '+${Formatters.currency(income)}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8AF0A0),
            ),
          ),
        ],
      ),
    );
  }
}
