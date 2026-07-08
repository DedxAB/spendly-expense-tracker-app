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
import 'package:spendly/core/widgets/app_confirm_dialog.dart';
import 'package:spendly/core/widgets/app_modal_surface.dart';
import 'package:spendly/core/widgets/app_header.dart';
import 'package:spendly/core/widgets/transaction_row.dart';
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
  late final ScrollController _scrollController;
  static const _pageSize = 30;
  int _visibleCount = _pageSize;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      _loadMore();
    }
  }

  void _loadMore() {
    setState(() {
      _visibleCount += _pageSize;
    });
  }

  void _resetPagination() {
    setState(() {
      _visibleCount = _pageSize;
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  Widget _buildTransactionGroups(
    Map<String, List<TransactionEntity>> grouped,
    int totalCount,
    Map<String, CategoryEntity> categoryById,
  ) {
    final entries = grouped.entries.toList();
    int shown = 0;
    final visible = <MapEntry<String, List<TransactionEntity>>>[];
    for (final entry in entries) {
      if (shown >= _visibleCount) break;
      visible.add(entry);
      shown += entry.value.length;
    }

    return Column(
      children: [
        ...visible.map((entry) => Padding(
          padding: EdgeInsets.only(top: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.key, style: AppTypography.sectionTitle(context)),
              SizedBox(height: AppSpacing.smPlus),
              Divider(color: context.border),
              ...entry.value.asMap().entries.map((item) {
                final tx = item.value;
                final isLast = item.key == entry.value.length - 1;
                return Dismissible(
                  key: ValueKey(tx.id),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      await showAddExpenseSheet(context, existing: tx);
                      return false;
                    }
                    return showAppDeleteConfirmDialog(
                      context,
                      title: 'Delete transaction?',
                      message: 'This transaction will be removed.',
                    );
                  },
                  onDismissed: (_) {
                    ref.read(transactionActionsProvider).softDelete(tx.id);
                  },
                  background: Container(
                    alignment: Alignment.centerLeft,
                    color: const Color(0xFF11261B),
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(AppIcons.edit, color: AppColors.income),
                        SizedBox(width: AppSpacing.xs),
                        Text('EDIT', style: TextStyle(
                          color: AppColors.income,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        )),
                      ],
                    ),
                  ),
                  secondaryBackground: Container(
                    alignment: Alignment.centerRight,
                    color: const Color(0xFF2A1313),
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('DELETE', style: TextStyle(
                          color: AppColors.expense,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        )),
                        SizedBox(width: AppSpacing.xs),
                        Icon(AppIcons.trash, color: AppColors.expense),
                      ],
                    ),
                  ),
                  child: TransactionRow(
                    title: tx.note?.trim().isNotEmpty == true
                        ? tx.note!.trim()
                        : (categoryById[tx.categoryId]?.name ?? tx.categoryId),
                    subtitle: categoryById[tx.categoryId]?.name ?? tx.categoryId,
                    amount: tx.amount,
                    type: tx.type,
                    isLast: isLast,
                    dateLabel: _dateLabel(tx),
                    icon: _iconFor(categoryById[tx.categoryId]?.name ?? tx.categoryId),
                    iconColor: _categoryIconColor(categoryById[tx.categoryId], tx.type),
                    paymentMode: tx.paymentMode,
                    cardType: tx.cardType,
                  ),

                );
              }),
            ],
          ),
        )),
        if (shown < totalCount)
          Padding(
            padding: EdgeInsets.only(top: AppSpacing.sm),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _loadMore,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: context.border),
                  backgroundColor: context.surface,
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                  ),
                ),
                child: Text(
                  'Show more (${totalCount - shown} left)',
                  style: TextStyle(color: context.textSecondary),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(transactionFilterProvider);
    final transactions = ref.watch(filteredTransactionsProvider);
    final categories = ref.watch(allCategoriesProvider).valueOrNull ?? const [];
    final categoryById = {for (final c in categories) c.id: c};

    ref.listen(transactionFilterProvider, (previous, next) {
      if (previous != null && previous != next) _resetPagination();
    });

    return Scaffold(
      appBar: AppHeader(
        mode: AppHeaderMode.calendar,
        title: 'Transactions',
        onLeadingTap: () => context.push('/calendar'),
      ),
      body: ListView(
        controller: _scrollController,
        padding: EdgeInsets.fromLTRB(
          AppSpacing.smPlus,
          AppSpacing.smPlus,
          AppSpacing.smPlus,
          AppSpacing.md,
        ),
        children: [
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _buildFilterChips(filters, categories),
            ),
          ),
          SizedBox(height: AppSpacing.smPlus),
          transactions.when(
            data: (items) {
              if (items.isEmpty) {
                return Padding(
                  padding: EdgeInsets.only(top: AppSpacing.xl),
                  child: const Text('No transactions found'),
                );
              }

              final grouped = _groupByDate(items);
              return _buildTransactionGroups(grouped, items.length, categoryById);
            },
            loading: () => Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: const Center(child: CircularProgressIndicator()),
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

  List<Widget> _buildFilterChips(
    TransactionFilterState filters,
    List<CategoryEntity> categories,
  ) {
    final categoryById = {for (final c in categories) c.id: c.name};
    return [
      _buildChip('Filter', Icons.keyboard_arrow_down, true, () => _openFilters(context, filters)),
      _buildChip('Date', null, true, () => _openFilters(context, filters, _FilterTab.date),
          subtitle: _datePresetLabel(filters.datePreset)),
      _buildChip('Type', null, filters.type != null, () => _openFilters(context, filters, _FilterTab.type),
          subtitle: filters.type != null ? _typeLabel(filters.type!) : 'All'),
      _buildChip('Payment', null, filters.paymentMode != null, () => _openFilters(context, filters, _FilterTab.payment),
          subtitle: filters.paymentMode?.label ?? 'All'),
      _buildChip('Category', null, filters.categoryId != null, () => _openFilters(context, filters, _FilterTab.category),
          subtitle: filters.categoryId != null
              ? (categoryById[filters.categoryId] ?? 'Selected')
              : 'All'),
      _buildChip('Amount', null, filters.minAmount != null || filters.maxAmount != null,
          () => _openFilters(context, filters, _FilterTab.amount),
          subtitle: filters.minAmount != null || filters.maxAmount != null ? 'Set' : 'All'),
      _buildChip('Sort', null, filters.sortOption != TransactionSortOption.newestFirst,
          () => _openFilters(context, filters, _FilterTab.sort),
          subtitle: _sortLabel(filters.sortOption)),
    ];
  }

  Widget _buildChip(String label, IconData? icon, bool active, VoidCallback onTap, {String? subtitle}) {
    return Padding(
      padding: EdgeInsets.only(right: AppSpacing.sm),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 36,
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.smPlus),
          decoration: BoxDecoration(
            color: active ? context.textPrimary : context.surfaceAlt,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(color: active ? context.textPrimary : context.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: active ? context.surface : context.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (subtitle != null) ...[
                SizedBox(width: 4),
                Text(
                  ': $subtitle',
                  style: TextStyle(
                    color: active ? context.surface.withValues(alpha: 0.7) : context.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
              if (icon != null) ...[
                SizedBox(width: 2),
                Icon(icon, size: 16, color: active ? context.surface : context.textPrimary),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openFilters(
    BuildContext context,
    TransactionFilterState filters, [
    _FilterTab? initialTab,
  ]) async {
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
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(2000),
        lastDate: DateTime.now().add(const Duration(days: 3650)),
        builder: (context, child) {
          final base = Theme.of(context);
          return Theme(
            data: base.copyWith(
              colorScheme: isDark
                  ? const ColorScheme.dark(
                      primary: Colors.white,
                      onPrimary: Colors.black,
                      surface: Color(0xFF0E0E0E),
                      onSurface: Colors.white,
                    )
                  : const ColorScheme.light(
                      primary: Color(0xFF111111),
                      onPrimary: Colors.white,
                      surface: Color(0xFFFFFFFF),
                      onSurface: Color(0xFF111111),
                    ),
              dialogTheme: DialogThemeData(
                backgroundColor: isDark ? const Color(0xFF0E0E0E) : const Color(0xFFFFFFFF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
              ),
              datePickerTheme: isDark ? AppDatePickerTheme.darkBoxy() : AppDatePickerTheme.lightBoxy(),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: isDark ? Colors.white : const Color(0xFF111111),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.md),
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
        var activeTab = initialTab ?? _FilterTab.date;
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
                activeTab = _FilterTab.date;
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

              const sidebarLabels = [
                'Date',
                'Type',
                'Payment',
                'Category',
                'Amount',
                'Sort',
              ];
              const sidebarTabs = [
                _FilterTab.date,
                _FilterTab.type,
                _FilterTab.payment,
                _FilterTab.category,
                _FilterTab.amount,
                _FilterTab.sort,
              ];

              return Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.sm,
                  MediaQuery.of(sheetContext).viewInsets.bottom + AppSpacing.sm,
                ),
                child: SizedBox(
                  height: 420,
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            SizedBox(
                              width: 96,
                              child: ListView(
                                padding: EdgeInsets.zero,
                                children: List.generate(sidebarLabels.length, (index) {
                                  final isSelected = sidebarTabs[index] == activeTab;
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: AppSpacing.xxs),
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () => setState(() => activeTab = sidebarTabs[index]),
                                      child: Container(
                                        height: 42,
                                        padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                                        decoration: BoxDecoration(
                                          color: isSelected ? context.textPrimary : Colors.transparent,
                                          borderRadius: BorderRadius.circular(AppRadii.md),
                                        ),
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          sidebarLabels[index],
                                          style: TextStyle(
                                            color: isSelected ? context.surface : context.textPrimary,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                            SizedBox(width: AppSpacing.smPlus),
                            Container(width: 1, color: context.border),
                            SizedBox(width: AppSpacing.smPlus),
                            Expanded(
                              child: SingleChildScrollView(
                                child: _buildFilterPanel(
                                  context: context,
                                  tab: activeTab,
                                  selectedDatePreset: selectedDatePreset,
                                  customFrom: customFrom,
                                  customTo: customTo,
                                  selectedType: selectedType,
                                  selectedPaymentMode: selectedPaymentMode,
                                  selectedCategoryId: selectedCategoryId,
                                  selectedMinAmount: selectedMinAmount,
                                  selectedMaxAmount: selectedMaxAmount,
                                  selectedSortOption: selectedSortOption,
                                  availableCategories: availableCategories,
                                  minAmountController: minAmountController,
                                  maxAmountController: maxAmountController,
                                  onChooseFrom: chooseFrom,
                                  onChooseTo: chooseTo,
                                  onSetDatePreset: (p) {
                                    setState(() {
                                      selectedDatePreset = p;
                                      if (p != TransactionDatePreset.custom) {
                                        customFrom = null;
                                        customTo = null;
                                      }
                                    });
                                  },
                                  onSetType: (t) =>
                                      setState(() => selectedType = t),
                                  onSetPaymentMode: (p) =>
                                      setState(() => selectedPaymentMode = p),
                                  onSetCategoryId: (id) =>
                                      setState(() => selectedCategoryId = id),
                                  onSyncAmount: syncAmountState,
                                  onSetSort: (s) =>
                                      setState(() => selectedSortOption = s),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: AppSpacing.md),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: resetFilters,
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(52),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppRadii.md),
                                  ),
                                ),
                                child: const Text('Reset'),
                              ),
                            ),
                            SizedBox(width: AppSpacing.sm),
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
                      ),
                    ],
                  ),
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

enum _FilterTab { date, type, payment, category, amount, sort }

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

String _datePresetLabel(TransactionDatePreset preset) {
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

String _sortLabel(TransactionSortOption sortOption) {
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

class _DateRangeButton extends StatelessWidget {
  const _DateRangeButton({required this.label, required this.onTap, this.selected = false});

  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 38,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.smPlus),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: selected ? context.textPrimary : context.surface,
          border: Border.all(color: selected ? context.textPrimary : context.border),
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? context.surface : context.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (selected)
              Icon(Icons.check, size: 16, color: context.surface),
          ],
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

String _dateLabel(dynamic tx) {
  return DateFormat('h:mm a').format(tx.date as DateTime);
}

Widget _buildFilterPanel({
  required BuildContext context,
  required _FilterTab tab,
  required TransactionDatePreset selectedDatePreset,
  required DateTime? customFrom,
  required DateTime? customTo,
  required String? selectedType,
  required PaymentMode? selectedPaymentMode,
  required String? selectedCategoryId,
  required double? selectedMinAmount,
  required double? selectedMaxAmount,
  required TransactionSortOption selectedSortOption,
  required List<CategoryEntity> availableCategories,
  required TextEditingController minAmountController,
  required TextEditingController maxAmountController,
  required VoidCallback onChooseFrom,
  required VoidCallback onChooseTo,
  required ValueChanged<TransactionDatePreset> onSetDatePreset,
  required ValueChanged<String?> onSetType,
  required ValueChanged<PaymentMode?> onSetPaymentMode,
  required ValueChanged<String?> onSetCategoryId,
  required VoidCallback onSyncAmount,
  required ValueChanged<TransactionSortOption> onSetSort,
}) {
  switch (tab) {
    case _FilterTab.date:
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...TransactionDatePreset.values.map(
            (preset) => Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.sm),
              child: _DateRangeButton(
                label: _datePresetLabel(preset),
                selected: selectedDatePreset == preset,
                onTap: () => onSetDatePreset(preset),
              ),
            ),
          ),
          if (selectedDatePreset == TransactionDatePreset.custom) ...[
            SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _DateRangeButton(
                    label: customFrom != null
                        ? DateFormat('MMM d, yyyy').format(customFrom)
                        : 'From',
                    selected: customFrom != null,
                    onTap: onChooseFrom,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _DateRangeButton(
                    label: customTo != null
                        ? DateFormat('MMM d, yyyy').format(customTo)
                        : 'To',
                    selected: customTo != null,
                    onTap: onChooseTo,
                  ),
                ),
              ],
            ),
          ],
        ],
      );
    case _FilterTab.type:
      return Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          for (final t in TransactionType.values)
            _FilterSelectionChip(
              label: t.value,
              selected: selectedType == t.value,
              onTap: () => onSetType(selectedType == t.value ? null : t.value),
            ),
        ],
      );
    case _FilterTab.payment:
      return Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          for (final m in PaymentMode.values)
            _FilterSelectionChip(
              label: m.label,
              selected: selectedPaymentMode == m,
              onTap: () =>
                  onSetPaymentMode(selectedPaymentMode == m ? null : m),
            ),
        ],
      );
    case _FilterTab.category:
      return Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          for (final c in availableCategories)
            _FilterSelectionChip(
              label: c.name,
              selected: selectedCategoryId == c.id,
              onTap: () =>
                  onSetCategoryId(selectedCategoryId == c.id ? null : c.id),
            ),
        ],
      );
    case _FilterTab.amount:
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: minAmountController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                  ],
                  onChanged: (_) => onSyncAmount(),
                  decoration: InputDecoration(
                    hintText: 'Min',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.sm,
                    ),
                    isDense: true,
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextField(
                  controller: maxAmountController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                  ],
                  onChanged: (_) => onSyncAmount(),
                  decoration: InputDecoration(
                    hintText: 'Max',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.sm,
                    ),
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    case _FilterTab.sort:
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final s in TransactionSortOption.values)
            Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.sm),
              child: _DateRangeButton(
                label: _sortLabel(s),
                selected: selectedSortOption == s,
                onTap: () => onSetSort(s),
              ),
            ),
        ],
      );
  }
}

class _FilterSelectionChip extends StatelessWidget {
  const _FilterSelectionChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.smPlus,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: selected ? context.textPrimary : context.surface,
          border: Border.all(
            color: selected ? context.textPrimary : context.border,
          ),
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        child: Text(
          label[0].toUpperCase() + label.substring(1),
          style: TextStyle(
            color: selected ? context.surface : context.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
