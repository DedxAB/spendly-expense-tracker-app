import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/core/constants/app_enums.dart';
import 'package:spendly/features/categories/presentation/providers/categories_provider.dart';
import 'package:spendly/features/transactions/data/repositories/transactions_repository_impl.dart';
import 'package:spendly/features/transactions/domain/entities/transaction_entity.dart';

enum TransactionDatePreset { allTime, thisMonth, lastMonth, thisYear, custom }

enum TransactionSortOption {
  newestFirst,
  oldestFirst,
  highestAmount,
  lowestAmount,
}

class DateInterval {
  const DateInterval({required this.start, required this.end});

  final DateTime start;
  final DateTime end;
}

class TransactionFilterState {
  const TransactionFilterState({
    required this.datePreset,
    required this.type,
    required this.categoryId,
    required this.paymentMode,
    required this.minAmount,
    required this.maxAmount,
    required this.searchQuery,
    required this.sortOption,
    this.customFrom,
    this.customTo,
  });

  factory TransactionFilterState.initial() {
    return const TransactionFilterState(
      datePreset: TransactionDatePreset.thisMonth,
      type: null,
      categoryId: null,
      paymentMode: null,
      minAmount: null,
      maxAmount: null,
      searchQuery: '',
      sortOption: TransactionSortOption.newestFirst,
      customFrom: null,
      customTo: null,
    );
  }

  final TransactionDatePreset datePreset;
  final String? type;
  final String? categoryId;
  final PaymentMode? paymentMode;
  final double? minAmount;
  final double? maxAmount;
  final String searchQuery;
  final TransactionSortOption sortOption;
  final DateTime? customFrom;
  final DateTime? customTo;

  TransactionFilterState copyWith({
    TransactionDatePreset? datePreset,
    String? type,
    bool clearType = false,
    String? categoryId,
    bool clearCategory = false,
    PaymentMode? paymentMode,
    bool clearPaymentMode = false,
    double? minAmount,
    bool clearMinAmount = false,
    double? maxAmount,
    bool clearMaxAmount = false,
    String? searchQuery,
    TransactionSortOption? sortOption,
    DateTime? customFrom,
    bool clearCustomFrom = false,
    DateTime? customTo,
    bool clearCustomTo = false,
  }) {
    return TransactionFilterState(
      datePreset: datePreset ?? this.datePreset,
      type: clearType ? null : (type ?? this.type),
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      paymentMode: clearPaymentMode ? null : (paymentMode ?? this.paymentMode),
      minAmount: clearMinAmount ? null : (minAmount ?? this.minAmount),
      maxAmount: clearMaxAmount ? null : (maxAmount ?? this.maxAmount),
      searchQuery: searchQuery ?? this.searchQuery,
      sortOption: sortOption ?? this.sortOption,
      customFrom: clearCustomFrom ? null : (customFrom ?? this.customFrom),
      customTo: clearCustomTo ? null : (customTo ?? this.customTo),
    );
  }

  DateInterval effectiveRange(DateTime now) {
    switch (datePreset) {
      case TransactionDatePreset.allTime:
        return DateInterval(
          start: DateTime(1900, 1, 1),
          end: DateTime(2100, 12, 31, 23, 59, 59),
        );
      case TransactionDatePreset.thisMonth:
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        return DateInterval(start: start, end: end);
      case TransactionDatePreset.lastMonth:
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        final start = DateTime(lastMonth.year, lastMonth.month, 1);
        final end = DateTime(
          lastMonth.year,
          lastMonth.month + 1,
          0,
          23,
          59,
          59,
        );
        return DateInterval(start: start, end: end);
      case TransactionDatePreset.thisYear:
        return DateInterval(
          start: DateTime(now.year, 1, 1),
          end: DateTime(now.year, 12, 31, 23, 59, 59),
        );
      case TransactionDatePreset.custom:
        final fallbackStart = DateTime(now.year, now.month, 1);
        final fallbackEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        final start = customFrom ?? fallbackStart;
        final end = customTo ?? fallbackEnd;
        return DateInterval(start: start, end: end);
    }
  }
}

class TransactionFilterController
    extends StateNotifier<TransactionFilterState> {
  TransactionFilterController() : super(TransactionFilterState.initial());

  void setDatePreset(TransactionDatePreset preset) {
    state = state.copyWith(datePreset: preset);
  }

  void setCustomRange(DateTime from, DateTime to) {
    final normalizedFrom = DateTime(from.year, from.month, from.day);
    final normalizedTo = DateTime(to.year, to.month, to.day, 23, 59, 59);
    state = state.copyWith(
      datePreset: TransactionDatePreset.custom,
      customFrom: normalizedFrom,
      customTo: normalizedTo,
    );
  }

  void clearCustomRange() {
    state = state.copyWith(
      datePreset: TransactionDatePreset.allTime,
      clearCustomFrom: true,
      clearCustomTo: true,
    );
  }

  void setType(String? type) {
    state = state.copyWith(type: type, clearType: type == null);
  }

  void setCategory(String? categoryId) {
    state = state.copyWith(
      categoryId: categoryId,
      clearCategory: categoryId == null,
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void applyAdvanced({
    TransactionDatePreset? datePreset,
    required PaymentMode? paymentMode,
    required double? minAmount,
    required double? maxAmount,
    required TransactionSortOption sortOption,
    DateTime? customFrom,
    DateTime? customTo,
  }) {
    state = state.copyWith(
      datePreset: datePreset ?? state.datePreset,
      paymentMode: paymentMode,
      clearPaymentMode: paymentMode == null,
      minAmount: minAmount,
      clearMinAmount: minAmount == null,
      maxAmount: maxAmount,
      clearMaxAmount: maxAmount == null,
      sortOption: sortOption,
      customFrom: customFrom,
      clearCustomFrom: customFrom == null,
      customTo: customTo,
      clearCustomTo: customTo == null,
    );
  }

  void clearAll() {
    state = TransactionFilterState.initial();
  }
}

final transactionFilterProvider =
    StateNotifierProvider<TransactionFilterController, TransactionFilterState>(
      (ref) => TransactionFilterController(),
    );

final allTransactionsProvider = StreamProvider<List<TransactionEntity>>((ref) {
  return ref.watch(transactionsRepositoryProvider).watchAll();
});

final filteredTransactionsProvider =
    Provider<AsyncValue<List<TransactionEntity>>>((ref) {
      final filters = ref.watch(transactionFilterProvider);
      final txAsync = ref.watch(allTransactionsProvider);
      final categories =
          ref.watch(allCategoriesProvider).valueOrNull ?? const [];
      final categoryById = {
        for (final c in categories) c.id: c.name.toLowerCase(),
      };

      return txAsync.whenData((source) {
        final range = filters.effectiveRange(DateTime.now());
        final query = filters.searchQuery.trim().toLowerCase();

        final filtered = source
            .where((tx) {
              if (tx.date.isBefore(range.start) || tx.date.isAfter(range.end)) {
                return false;
              }
              if (filters.type != null && tx.type.value != filters.type) {
                return false;
              }
              if (filters.categoryId != null &&
                  tx.categoryId != filters.categoryId) {
                return false;
              }
              if (filters.paymentMode != null &&
                  tx.paymentMode != filters.paymentMode) {
                return false;
              }
              if (filters.minAmount != null && tx.amount < filters.minAmount!) {
                return false;
              }
              if (filters.maxAmount != null && tx.amount > filters.maxAmount!) {
                return false;
              }

              if (query.isNotEmpty) {
                final note = (tx.note ?? '').toLowerCase();
                final categoryName = categoryById[tx.categoryId] ?? '';
                if (!note.contains(query) && !categoryName.contains(query)) {
                  return false;
                }
              }

              return true;
            })
            .toList(growable: false);

        filtered.sort((a, b) {
          switch (filters.sortOption) {
            case TransactionSortOption.newestFirst:
              return b.date.compareTo(a.date);
            case TransactionSortOption.oldestFirst:
              return a.date.compareTo(b.date);
            case TransactionSortOption.highestAmount:
              return b.amount.compareTo(a.amount);
            case TransactionSortOption.lowestAmount:
              return a.amount.compareTo(b.amount);
          }
        });

        return filtered;
      });
    });

final recentTransactionsProvider = StreamProvider((ref) {
  return ref.watch(transactionsRepositoryProvider).watchRecent(limit: 5);
});

final monthlyTotalsProvider = StreamProvider((ref) {
  final month = DateTime(DateTime.now().year, DateTime.now().month, 1);
  return ref.watch(transactionsRepositoryProvider).watchMonthlyTotals(month);
});

class TransactionActions {
  TransactionActions(this._ref);

  final Ref _ref;

  Future<void> save(TransactionEntity transaction) async {
    await _ref.read(transactionsRepositoryProvider).add(transaction);
  }

  Future<void> update(TransactionEntity transaction) async {
    await _ref.read(transactionsRepositoryProvider).update(transaction);
  }

  Future<void> softDelete(String id) async {
    await _ref.read(transactionsRepositoryProvider).softDelete(id);
  }

  Future<void> restore(String id) async {
    await _ref.read(transactionsRepositoryProvider).restore(id);
  }
}

final transactionActionsProvider = Provider(TransactionActions.new);
