import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:spendly/core/constants/app_constants.dart';
import 'package:spendly/core/constants/app_enums.dart';
import 'package:spendly/core/theme/app_design_tokens.dart';
import 'package:spendly/core/theme/app_icons.dart';
import 'package:spendly/core/theme/app_typography.dart';
import 'package:spendly/core/widgets/noir_header.dart';
import 'package:spendly/features/categories/domain/entities/category_entity.dart';
import 'package:spendly/features/categories/presentation/providers/categories_provider.dart';
import 'package:spendly/features/transactions/presentation/providers/transactions_provider.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: AppConstants.currencySymbol,
    decimalDigits: 2,
  );

  late DateTime _displayMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayMonth = DateTime(now.year, now.month, 1);
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(allTransactionsProvider).valueOrNull ?? const [];
    final categories = ref.watch(allCategoriesProvider).valueOrNull ?? const [];
    final categoryById = {for (final c in categories) c.id: c};

    final expenseByDay = <int, double>{};
    for (final tx in all) {
      if (tx.type != TransactionType.expense) continue;
      if (tx.date.year != _displayMonth.year ||
          tx.date.month != _displayMonth.month) {
        continue;
      }
      expenseByDay[tx.date.day] = (expenseByDay[tx.date.day] ?? 0) + tx.amount;
    }

    final monthlyTotal = expenseByDay.values.fold<double>(
      0,
      (sum, value) => sum + value,
    );

    final selectedItems =
        all
            .where((tx) => tx.type == TransactionType.expense)
            .where((tx) => _isSameDay(tx.date, _selectedDate))
            .toList(growable: false)
          ..sort((a, b) => b.amount.compareTo(a.amount));

    final selectedTotal = selectedItems.fold<double>(
      0,
      (sum, tx) => sum + tx.amount,
    );
    final visibleDays = _buildVisibleDays(_displayMonth);

    return Scaffold(
      appBar: NoirHeader(
        showLeading: true,
        leadingIcon: AppIcons.chevronLeft,
        onLeadingTap: () => Navigator.of(context).maybePop(),
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
                  DateFormat('MMMM yyyy').format(_displayMonth),
                  style: AppTypography.sectionTitle(context),
                ),
              ),
              _MonthNav(
                onPrev: () => setState(
                  () => _displayMonth = DateTime(
                    _displayMonth.year,
                    _displayMonth.month - 1,
                    1,
                  ),
                ),
                onNext: () => setState(
                  () => _displayMonth = DateTime(
                    _displayMonth.year,
                    _displayMonth.month + 1,
                    1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          const Divider(color: AppColors.borderDark),
          const SizedBox(height: AppSpacing.smPlus),
          Text('TOTAL SPENDING', style: AppTypography.metadata(context)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _currency.format(monthlyTotal),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.mdPlus),
          _MonthGrid(
            visibleDays: visibleDays,
            displayMonth: _displayMonth,
            selectedDate: _selectedDate,
            expenseByDay: expenseByDay,
            onTapDay: (day) => setState(() => _selectedDate = day),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Text(
                  DateFormat('MMMM d').format(_selectedDate),
                  style: AppTypography.sectionTitle(context),
                ),
              ),
              Text(
                _currency.format(selectedTotal),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          const Divider(color: AppColors.borderDark),
          const SizedBox(height: 10),
          if (selectedItems.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text('No spending transactions on this date'),
            )
          else
            ...selectedItems.map(
              (tx) => _CalendarTransactionRow(
                title: tx.note?.trim().isNotEmpty == true
                    ? tx.note!.trim()
                    : (categoryById[tx.categoryId]?.name ?? tx.categoryId),
                subtitle: (categoryById[tx.categoryId]?.name ?? tx.categoryId)
                    .toUpperCase(),
                amount: tx.amount,
                icon: _iconFor(
                  categoryById[tx.categoryId]?.name ?? tx.categoryId,
                ),
                iconColor: _categoryIconColor(
                  categoryById[tx.categoryId],
                  tx.type,
                ),
              ),
            ),
        ],
      ),
    );
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
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
    return type == TransactionType.income
        ? AppColors.income
        : AppColors.expense;
  }

  static List<DateTime> _buildVisibleDays(DateTime month) {
    final firstOfMonth = DateTime(month.year, month.month, 1);
    final sundayBasedIndex = firstOfMonth.weekday % 7;
    final gridStart = firstOfMonth.subtract(Duration(days: sundayBasedIndex));
    return List.generate(35, (index) {
      final day = gridStart.add(Duration(days: index));
      return DateTime(day.year, day.month, day.day);
    });
  }
}

class _MonthNav extends StatelessWidget {
  const _MonthNav({required this.onPrev, required this.onNext});

  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onPrev,
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Icon(AppIcons.chevronLeft, size: 22),
            ),
          ),
          Container(
            width: 1,
            height: 44,
            color: Theme.of(context).dividerColor,
          ),
          InkWell(
            onTap: onNext,
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Icon(AppIcons.chevronRight, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.visibleDays,
    required this.displayMonth,
    required this.selectedDate,
    required this.expenseByDay,
    required this.onTapDay,
  });

  final List<DateTime> visibleDays;
  final DateTime displayMonth;
  final DateTime selectedDate;
  final Map<int, double> expenseByDay;
  final ValueChanged<DateTime> onTapDay;

  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: AppConstants.currencySymbol,
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    const weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    final now = DateTime.now();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Column(
        children: [
          Row(
            children: [
              for (final day in weekdays)
                Expanded(
                  child: Container(
                    height: 42,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(color: AppColors.borderDark),
                        bottom: BorderSide(color: AppColors.borderDark),
                      ),
                    ),
                    child: Text(
                      day,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
            ],
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: visibleDays.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.9,
            ),
            itemBuilder: (context, index) {
              final day = visibleDays[index];
              final isCurrentMonth =
                  day.month == displayMonth.month &&
                  day.year == displayMonth.year;
              final isSelected =
                  day.year == selectedDate.year &&
                  day.month == selectedDate.month &&
                  day.day == selectedDate.day;
              final isToday =
                  day.year == now.year &&
                  day.month == now.month &&
                  day.day == now.day;
              final double spend = isCurrentMonth
                  ? (expenseByDay[day.day] ?? 0.0)
                  : 0.0;

              return InkWell(
                onTap: () => onTapDay(day),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(6, 6, 6, 4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFE5E5E5)
                        : (isToday ? const Color(0xFF111111) : Colors.black),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFE5E5E5)
                          : (isToday
                                ? const Color(0xFFE0E0E0)
                                : AppColors.borderDark),
                      width: isToday && !isSelected ? 1.2 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${day.day}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.black
                              : (isCurrentMonth
                                    ? Colors.white
                                    : const Color(0xFF4A4A4A)),
                        ),
                      ),
                      const Spacer(),
                      if (spend > 0)
                        Text(
                          _shortCurrency(spend),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.black : Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _shortCurrency(double amount) {
    if (amount >= 100000) {
      return '${AppConstants.currencySymbol} ${(amount / 100000).toStringAsFixed(1)}L';
    }
    if (amount >= 1000) {
      return '${AppConstants.currencySymbol} ${(amount / 1000).toStringAsFixed(1)}k';
    }
    return _currency.format(amount);
  }
}

class _CalendarTransactionRow extends StatelessWidget {
  const _CalendarTransactionRow({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final String subtitle;
  final double amount;
  final IconData icon;
  final Color iconColor;

  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '${AppConstants.currencySymbol} ',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
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
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.rowTitle(context)),
                Text(subtitle, style: Theme.of(context).textTheme.labelMedium),
              ],
            ),
          ),
          Text(
            _currency.format(amount),
            style: AppTypography.amountStyle(iconColor),
          ),
        ],
      ),
    );
  }
}
