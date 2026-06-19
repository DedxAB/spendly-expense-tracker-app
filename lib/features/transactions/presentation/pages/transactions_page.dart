import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:spendly/core/constants/app_enums.dart';
import 'package:spendly/core/theme/app_date_picker_theme.dart';
import 'package:spendly/core/theme/app_design_tokens.dart';
import 'package:spendly/core/theme/app_icons.dart';
import 'package:spendly/core/theme/app_typography.dart';
import 'package:spendly/core/utils/formatters.dart';
import 'package:spendly/core/widgets/app_confirm_dialog.dart';
import 'package:spendly/core/widgets/app_modal_surface.dart';
import 'package:spendly/core/widgets/noir_header.dart';
import 'package:spendly/core/widgets/swipe_actions_info_button.dart';
import 'package:spendly/features/categories/domain/entities/category_entity.dart';
import 'package:spendly/features/categories/presentation/providers/categories_provider.dart';
import 'package:spendly/features/transactions/domain/entities/transaction_entity.dart';
import 'package:spendly/features/transactions/presentation/pages/add_transaction_page.dart';
import 'package:spendly/features/transactions/presentation/providers/transactions_provider.dart';

class TransactionsPage extends ConsumerStatefulWidget {
  const TransactionsPage({super.key});

  @override
  ConsumerState<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends ConsumerState<TransactionsPage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(transactionFilterProvider).searchQuery,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _setSearchQuery(String query) {
    if (_searchController.text != query) {
      _searchController.value = TextEditingValue(
        text: query,
        selection: TextSelection.collapsed(offset: query.length),
      );
    }
    ref.read(transactionFilterProvider.notifier).setSearchQuery(query);
  }

  void _clearAllFilters() {
    _searchController.clear();
    ref.read(transactionFilterProvider.notifier).clearAll();
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(transactionFilterProvider);
    final filterController = ref.read(transactionFilterProvider.notifier);
    final transactions = ref.watch(filteredTransactionsProvider);
    final categories = ref.watch(allCategoriesProvider).valueOrNull ?? const [];
    final categoryById = {for (final c in categories) c.id: c};
    final activeCategoryName = filters.categoryId == null
        ? null
        : categoryById[filters.categoryId!]?.name;
    final hasActiveFilters =
        filters.searchQuery.trim().isNotEmpty ||
        filters.type != null ||
        filters.categoryId != null ||
        filters.paymentMode != null ||
        filters.minAmount != null ||
        filters.maxAmount != null ||
        filters.sortOption != TransactionSortOption.newestFirst ||
        filters.datePreset != TransactionDatePreset.allTime;

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
          Row(
            children: [
              Expanded(
                child: Text(
                  'Search Ledger',
                  style: AppTypography.screenTitle(context),
                ),
              ),
              const SwipeActionsInfoButton(
                tooltip: 'Transaction swipe help',
                title: 'Transaction swipe actions',
                message:
                    'Transactions support quick gestures so you can act without opening another screen.',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.smPlus),
          TextField(
            controller: _searchController,
            onChanged: _setSearchQuery,
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
                onPressed: () => _openFilters(context, filters),
                icon: const Icon(AppIcons.filter, size: 16),
                label: const Text('Filters'),
              ),
            ),
          ),
          if (hasActiveFilters) ...[
            const SizedBox(height: AppSpacing.sm),
            _ActiveFilterBar(
              filters: filters,
              onClearAll: _clearAllFilters,
              onClearSearch: filters.searchQuery.trim().isNotEmpty
                  ? () => _setSearchQuery('')
                  : null,
              onClearType: filters.type != null
                  ? () => filterController.setType(null)
                  : null,
              onClearPaymentMode: filters.paymentMode != null
                  ? () => ref
                        .read(transactionFilterProvider.notifier)
                        .applyAdvanced(
                          datePreset: filters.datePreset,
                          paymentMode: null,
                          minAmount: filters.minAmount,
                          maxAmount: filters.maxAmount,
                          sortOption: filters.sortOption,
                          customFrom: filters.customFrom,
                          customTo: filters.customTo,
                        )
                  : null,
              onClearCategory: filters.categoryId != null
                  ? () => filterController.setCategory(null)
                  : null,
              onClearAmounts:
                  filters.minAmount != null || filters.maxAmount != null
                  ? () => ref
                        .read(transactionFilterProvider.notifier)
                        .applyAdvanced(
                          datePreset: filters.datePreset,
                          paymentMode: filters.paymentMode,
                          minAmount: null,
                          maxAmount: null,
                          sortOption: filters.sortOption,
                          customFrom: filters.customFrom,
                          customTo: filters.customTo,
                        )
                  : null,
              onClearSort:
                  filters.sortOption != TransactionSortOption.newestFirst
                  ? () => ref
                        .read(transactionFilterProvider.notifier)
                        .applyAdvanced(
                          datePreset: filters.datePreset,
                          paymentMode: filters.paymentMode,
                          minAmount: filters.minAmount,
                          maxAmount: filters.maxAmount,
                          sortOption: TransactionSortOption.newestFirst,
                          customFrom: filters.customFrom,
                          customTo: filters.customTo,
                        )
                  : null,
              onClearDatePreset:
                  filters.datePreset != TransactionDatePreset.allTime
                  ? () => ref
                        .read(transactionFilterProvider.notifier)
                        .applyAdvanced(
                          datePreset: TransactionDatePreset.allTime,
                          paymentMode: filters.paymentMode,
                          minAmount: filters.minAmount,
                          maxAmount: filters.maxAmount,
                          sortOption: filters.sortOption,
                        )
                  : null,
              categoryName: activeCategoryName,
            ),
          ],
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

              double upiExpense = 0;
              double cardExpense = 0;
              double cashExpense = 0;
              double totalIncome = 0;
              for (final tx in items) {
                final amt = tx.amount;
                if (tx.paymentMode == PaymentMode.upi) {
                  if (tx.type == TransactionType.expense) {
                    upiExpense += amt;
                  } else {
                    totalIncome += amt;
                  }
                } else if (tx.paymentMode == PaymentMode.card) {
                  if (tx.type == TransactionType.expense) {
                    cardExpense += amt;
                  } else {
                    totalIncome += amt;
                  }
                } else if (tx.paymentMode == PaymentMode.cash) {
                  if (tx.type == TransactionType.expense) {
                    cashExpense += amt;
                  } else {
                    totalIncome += amt;
                  }
                }
              }

              final grouped = _groupByDate(items);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E0E0E),
                      border: Border.all(color: AppColors.borderDark),
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'INCOME',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          Formatters.currency(totalIncome),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF8AF0A0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _AccountBreakupCard(
                          name: 'UPI',
                          expense: upiExpense,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _AccountBreakupCard(
                          name: 'Card',
                          expense: cardExpense,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _AccountBreakupCard(
                          name: 'Cash',
                          expense: cashExpense,
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
                                color: const Color(0xFF11261B),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      AppIcons.edit,
                                      color: AppColors.income,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'EDIT',
                                      style: TextStyle(
                                        color: AppColors.income,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              secondaryBackground: Container(
                                alignment: Alignment.centerRight,
                                color: const Color(0xFF2A1313),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'DELETE',
                                      style: TextStyle(
                                        color: AppColors.expense,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(
                                      AppIcons.trash,
                                      color: AppColors.expense,
                                    ),
                                  ],
                                ),
                              ),
                              child: _HistoryRow(
                                title:
                                    categoryById[tx.categoryId]?.name ??
                                    tx.categoryId,
                                subtitle: tx.note?.trim() ?? '',
                                paymentModeLabel: transactionPaymentLabel(
                                  type: tx.type,
                                  paymentMode: tx.paymentMode,
                                  cardType: tx.cardType,
                                ),
                                amount: tx.amount,
                                type: tx.type,
                                icon: _iconFor(
                                  categoryById[tx.categoryId]?.name ??
                                      tx.categoryId,
                                ),
                                iconColor: _categoryIconColor(
                                  categoryById[tx.categoryId],
                                  tx.type,
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

  Future<void> _openFilters(
    BuildContext context,
    TransactionFilterState filters,
  ) async {
    final availableCategories =
        ref.read(allCategoriesProvider).valueOrNull ?? const [];
    var selectedDatePreset = filters.datePreset;
    var selectedType = filters.type;
    var selectedPaymentMode = filters.paymentMode;
    var selectedMinAmount = filters.minAmount;
    var selectedMaxAmount = filters.maxAmount;
    var selectedCategoryId = filters.categoryId;
    var selectedSortOption = filters.sortOption;
    DateTime? customFrom = filters.customFrom;
    DateTime? customTo = filters.customTo;
    final minAmountController = TextEditingController(
      text: filters.minAmount == null
          ? ''
          : _formatAmountInput(filters.minAmount!),
    );
    final maxAmountController = TextEditingController(
      text: filters.maxAmount == null
          ? ''
          : _formatAmountInput(filters.maxAmount!),
    );

    Future<DateTime?> pickDate(DateTime initialDate) {
      return showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(2000),
        lastDate: DateTime.now().add(const Duration(days: 3650)),
        builder: (context, child) {
          final base = Theme.of(context);
          return Theme(
            data: base.copyWith(
              colorScheme: const ColorScheme.dark(
                primary: Colors.white,
                onPrimary: Colors.black,
                surface: Color(0xFF0E0E0E),
                onSurface: Colors.white,
              ),
              dialogTheme: const DialogThemeData(
                backgroundColor: Color(0xFF0E0E0E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              datePickerTheme: AppDatePickerTheme.darkBoxy(),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
              ),
            ),
            child: child!,
          );
        },
      );
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return AppModalSurface(
          child: StatefulBuilder(
            builder: (context, setState) {
              void syncAmountState() {
                selectedMinAmount = _parseAmountInput(minAmountController.text);
                selectedMaxAmount = _parseAmountInput(maxAmountController.text);
              }

              Future<void> chooseFrom() async {
                final picked =
                    await pickDate(customFrom ?? DateTime.now()) ?? customFrom;
                if (picked == null) return;
                setState(() {
                  customFrom = DateTime(picked.year, picked.month, picked.day);
                  if (customTo != null && customTo!.isBefore(customFrom!)) {
                    customTo = customFrom;
                  }
                  selectedDatePreset = TransactionDatePreset.custom;
                });
              }

              Future<void> chooseTo() async {
                final picked =
                    await pickDate(customTo ?? customFrom ?? DateTime.now()) ??
                    customTo;
                if (picked == null) return;
                setState(() {
                  customTo = DateTime(picked.year, picked.month, picked.day);
                  if (customFrom != null && customFrom!.isAfter(customTo!)) {
                    customFrom = customTo;
                  }
                  selectedDatePreset = TransactionDatePreset.custom;
                });
              }

              void resetFilters() {
                setState(() {
                  selectedDatePreset = TransactionDatePreset.allTime;
                  selectedType = null;
                  selectedPaymentMode = null;
                  selectedCategoryId = null;
                  selectedMinAmount = null;
                  selectedMaxAmount = null;
                  selectedSortOption = TransactionSortOption.newestFirst;
                  customFrom = null;
                  customTo = null;
                  minAmountController.clear();
                  maxAmountController.clear();
                });
              }

              return Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.sm,
                  AppSpacing.xs,
                  AppSpacing.sm,
                  MediaQuery.of(sheetContext).viewInsets.bottom + AppSpacing.sm,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 64,
                        height: 4,
                        color: const Color(0xFF6A6A6A),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.smPlus),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Filters',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        TextButton(
                          onPressed: resetFilters,
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const _FilterSectionLabel('Date Range'),
                    const SizedBox(height: 8),
                    _FilterSegment(
                      selectedIndex: selectedDatePreset.index,
                      labels: const [
                        'All time',
                        'This month',
                        'Last month',
                        'This year',
                        'Custom',
                      ],
                      onChanged: (index) {
                        setState(() {
                          selectedDatePreset =
                              TransactionDatePreset.values[index];
                          if (selectedDatePreset !=
                              TransactionDatePreset.custom) {
                            customFrom = null;
                            customTo = null;
                          }
                        });
                      },
                    ),
                    if (selectedDatePreset == TransactionDatePreset.custom) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _DateRangeButton(
                              label: customFrom == null
                                  ? 'From'
                                  : DateFormat(
                                      'd MMM yyyy',
                                    ).format(customFrom!),
                              onTap: chooseFrom,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _DateRangeButton(
                              label: customTo == null
                                  ? 'To'
                                  : DateFormat('d MMM yyyy').format(customTo!),
                              onTap: chooseTo,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    const _FilterSectionLabel('Type'),
                    const SizedBox(height: 8),
                    _FilterSegment(
                      selectedIndex: selectedType == null
                          ? 0
                          : selectedType == 'income'
                          ? 1
                          : selectedType == 'expense'
                          ? 2
                          : 3,
                      labels: const ['All', 'Income', 'Expense', 'Investment'],
                      onChanged: (index) {
                        setState(() {
                          if (index == 0) {
                            selectedType = null;
                          } else if (index == 1) {
                            selectedType = 'income';
                          } else if (index == 2) {
                            selectedType = 'expense';
                          } else {
                            selectedType = 'investment';
                          }
                        });
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const _FilterSectionLabel('Payment Mode'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        _FilterChip(
                          label: 'All',
                          selected: selectedPaymentMode == null,
                          onTap: () =>
                              setState(() => selectedPaymentMode = null),
                        ),
                        ...PaymentMode.values.map(
                          (m) => _FilterChip(
                            label: m.label,
                            selected: selectedPaymentMode == m,
                            onTap: () => setState(() {
                              selectedPaymentMode = selectedPaymentMode == m
                                  ? null
                                  : m;
                            }),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const _FilterSectionLabel('Category'),
                    const SizedBox(height: 8),
                    if (availableCategories.isEmpty)
                      const Text(
                        'No categories available.',
                        style: TextStyle(
                          color: Color(0xFF8E8E8E),
                          fontSize: 12,
                        ),
                      )
                    else
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: [
                          _FilterChip(
                            label: 'All',
                            selected: selectedCategoryId == null,
                            onTap: () =>
                                setState(() => selectedCategoryId = null),
                          ),
                          ...availableCategories.map(
                            (category) => _FilterChip(
                              label: category.name,
                              selected: selectedCategoryId == category.id,
                              onTap: () => setState(() {
                                selectedCategoryId =
                                    selectedCategoryId == category.id
                                    ? null
                                    : category.id;
                              }),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: AppSpacing.sm),
                    const _FilterSectionLabel('Amount'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: minAmountController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.,]'),
                              ),
                            ],
                            onChanged: (_) => setState(syncAmountState),
                            decoration: const InputDecoration(
                              hintText: 'Min amount',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: maxAmountController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.,]'),
                              ),
                            ],
                            onChanged: (_) => setState(syncAmountState),
                            decoration: const InputDecoration(
                              hintText: 'Max amount',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const _FilterSectionLabel('Sort'),
                    const SizedBox(height: 8),
                    _FilterSegment(
                      selectedIndex: selectedSortOption.index,
                      labels: const ['Newest', 'Oldest', 'High', 'Low'],
                      onChanged: (index) {
                        setState(() {
                          selectedSortOption =
                              TransactionSortOption.values[index];
                        });
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(sheetContext),
                            child: const Text('Close'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              syncAmountState();
                              ref
                                  .read(transactionFilterProvider.notifier)
                                  .setCategory(selectedCategoryId);
                              ref
                                  .read(transactionFilterProvider.notifier)
                                  .applyAdvanced(
                                    datePreset: selectedDatePreset,
                                    paymentMode: selectedPaymentMode,
                                    minAmount: selectedMinAmount,
                                    maxAmount: selectedMaxAmount,
                                    sortOption: selectedSortOption,
                                    customFrom:
                                        selectedDatePreset ==
                                            TransactionDatePreset.custom
                                        ? customFrom
                                        : null,
                                    customTo:
                                        selectedDatePreset ==
                                            TransactionDatePreset.custom
                                        ? customTo
                                        : null,
                                  );
                              Navigator.pop(sheetContext);
                            },
                            child: const Text('Apply'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    minAmountController.dispose();
    maxAmountController.dispose();
  }
}

class _FilterSectionLabel extends StatelessWidget {
  const _FilterSectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFFB3B3B3),
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _FilterSegment extends StatelessWidget {
  const _FilterSegment({
    required this.selectedIndex,
    required this.labels,
    required this.onChanged,
  });

  final int selectedIndex;
  final List<String> labels;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF4A4A4A)),
      ),
      child: Row(
        children: List.generate(labels.length, (index) {
          final isSelected = selectedIndex == index;
          return Expanded(
            child: InkWell(
              onTap: () => onChanged(index),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.black,
                  border: Border(
                    right: BorderSide(
                      color: index == labels.length - 1
                          ? Colors.transparent
                          : const Color(0xFF4A4A4A),
                    ),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  labels[index],
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontSize: 12,
                    letterSpacing: 0.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.white : const Color(0xFF0E0E0E),
          border: Border.all(
            color: selected ? Colors.white : const Color(0xFF4A4A4A),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ActiveFilterBar extends StatelessWidget {
  const _ActiveFilterBar({
    required this.filters,
    required this.onClearAll,
    required this.onClearSearch,
    required this.onClearType,
    required this.onClearPaymentMode,
    required this.onClearCategory,
    required this.onClearAmounts,
    required this.onClearSort,
    required this.onClearDatePreset,
    required this.categoryName,
  });

  final TransactionFilterState filters;
  final VoidCallback onClearAll;
  final VoidCallback? onClearSearch;
  final VoidCallback? onClearType;
  final VoidCallback? onClearPaymentMode;
  final VoidCallback? onClearCategory;
  final VoidCallback? onClearAmounts;
  final VoidCallback? onClearSort;
  final VoidCallback? onClearDatePreset;
  final String? categoryName;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];

    if (filters.datePreset == TransactionDatePreset.custom &&
        filters.customFrom != null &&
        filters.customTo != null) {
      chips.add(
        _SummaryChip(
          label:
              'Date: ${DateFormat('d MMM').format(filters.customFrom!)} - ${DateFormat('d MMM').format(filters.customTo!)}',
          onRemove: onClearDatePreset,
        ),
      );
    } else if (filters.datePreset != TransactionDatePreset.allTime) {
      chips.add(
        _SummaryChip(
          label: _datePresetLabel(filters.datePreset),
          onRemove: onClearDatePreset,
        ),
      );
    }

    if (filters.searchQuery.trim().isNotEmpty) {
      chips.add(
        _SummaryChip(
          label: 'Search: ${filters.searchQuery.trim()}',
          onRemove: onClearSearch,
        ),
      );
    }

    if (filters.type != null) {
      chips.add(
        _SummaryChip(
          label: 'Type: ${_typeLabel(filters.type!)}',
          onRemove: onClearType,
        ),
      );
    }

    if (filters.paymentMode != null) {
      chips.add(
        _SummaryChip(
          label: 'Mode: ${filters.paymentMode!.label}',
          onRemove: onClearPaymentMode,
        ),
      );
    }

    if (filters.categoryId != null) {
      chips.add(
        _SummaryChip(
          label: 'Category: ${categoryName ?? 'Selected'}',
          onRemove: onClearCategory,
        ),
      );
    }

    if (filters.minAmount != null || filters.maxAmount != null) {
      chips.add(
        _SummaryChip(
          label: _amountLabel(filters.minAmount, filters.maxAmount),
          onRemove: onClearAmounts,
        ),
      );
    }

    if (filters.sortOption != TransactionSortOption.newestFirst) {
      chips.add(
        _SummaryChip(
          label: 'Sort: ${_sortLabel(filters.sortOption)}',
          onRemove: onClearSort,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0E0E0E),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'ACTIVE FILTERS',
                  style: TextStyle(
                    color: Color(0xFFBDBDBD),
                    fontSize: 11,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(
                onPressed: onClearAll,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 32),
                ),
                child: const Text('Clear all'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (chips.isEmpty)
            const Text(
              'No filters applied.',
              style: TextStyle(color: Color(0xFF8E8E8E), fontSize: 12),
            )
          else
            Wrap(spacing: 8, runSpacing: 8, children: chips),
        ],
      ),
    );
  }

  static String _datePresetLabel(TransactionDatePreset preset) {
    switch (preset) {
      case TransactionDatePreset.allTime:
        return 'All time';
      case TransactionDatePreset.thisMonth:
        return 'This month';
      case TransactionDatePreset.lastMonth:
        return 'Last month';
      case TransactionDatePreset.thisYear:
        return 'This year';
      case TransactionDatePreset.custom:
        return 'Custom range';
    }
  }

  static String _sortLabel(TransactionSortOption sortOption) {
    switch (sortOption) {
      case TransactionSortOption.newestFirst:
        return 'Newest';
      case TransactionSortOption.oldestFirst:
        return 'Oldest';
      case TransactionSortOption.highestAmount:
        return 'Highest';
      case TransactionSortOption.lowestAmount:
        return 'Lowest';
    }
  }

  static String _amountLabel(double? minAmount, double? maxAmount) {
    if (minAmount != null && maxAmount != null) {
      return 'Amount: ${Formatters.currency(minAmount)} - ${Formatters.currency(maxAmount)}';
    }
    if (minAmount != null) {
      return 'Amount: >= ${Formatters.currency(minAmount)}';
    }
    return 'Amount: <= ${Formatters.currency(maxAmount ?? 0)}';
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label, this.onRemove});

  final String label;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF4A4A4A)),
        color: const Color(0xFF141414),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (onRemove != null) ...[
            const SizedBox(width: 8),
            InkWell(
              onTap: onRemove,
              child: const Icon(
                Icons.close,
                size: 14,
                color: Color(0xFFB0B0B0),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DateRangeButton extends StatelessWidget {
  const _DateRangeButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: const Color(0xFF0E0E0E),
          border: Border.all(color: const Color(0xFF4A4A4A)),
        ),
        child: Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

String _formatAmountInput(double amount) {
  final text = amount.toStringAsFixed(2);
  return text.endsWith('.00') ? amount.toStringAsFixed(0) : text;
}

double? _parseAmountInput(String text) {
  final normalized = text.trim().replaceAll(',', '');
  if (normalized.isEmpty) return null;
  return double.tryParse(normalized);
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    required this.title,
    required this.subtitle,
    required this.paymentModeLabel,
    required this.amount,
    required this.type,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final String subtitle;
  final String paymentModeLabel;
  final double amount;
  final TransactionType type;
  final IconData icon;
  final Color iconColor;

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
            child: Icon(icon, color: iconColor, size: 20),
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
            _amountWithSign(amount, type),
            style: AppTypography.amount(
              context,
              fontSize: 16,
            ).copyWith(
              color: type == TransactionType.income
                  ? const Color(0xFF5DF393)
                  : type == TransactionType.investment
                      ? const Color(0xFF8B5CF6)
                      : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountBreakupCard extends StatelessWidget {
  const _AccountBreakupCard({required this.name, required this.expense});

  final String name;
  final double expense;

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
        ],
      ),
    );
  }
}

String _typeLabel(String type) {
  switch (type) {
    case 'income':
      return 'Income';
    case 'expense':
      return 'Expense';
    case 'investment':
      return 'Investment';
    default:
      return type;
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
