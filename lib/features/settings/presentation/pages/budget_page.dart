import 'package:flutter/material.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:spendly/core/constants/app_enums.dart';
import 'package:spendly/core/database/app_database.dart';
import 'package:spendly/core/database/database_providers.dart';
import 'package:spendly/core/theme/app_design_tokens.dart';
import 'package:spendly/core/theme/app_icons.dart';
import 'package:spendly/core/theme/app_typography.dart';
import 'package:spendly/core/utils/formatters.dart';
import 'package:spendly/core/utils/money.dart';
import 'package:spendly/core/widgets/app_modal_surface.dart';
import 'package:spendly/core/widgets/dialog_actions_row.dart';
import 'package:spendly/core/widgets/noir_header.dart';
import 'package:spendly/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:spendly/features/categories/presentation/providers/categories_provider.dart';
import 'package:spendly/features/settings/presentation/providers/settings_provider.dart';
import 'package:spendly/features/transactions/presentation/providers/transactions_provider.dart';

class BudgetPage extends ConsumerWidget {
  const BudgetPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsStreamProvider).valueOrNull;
    final budget = (settings?.monthlyBudget ?? 0).toDouble();
    final transactions =
        ref.watch(allTransactionsProvider).valueOrNull ?? const [];
    final categories = ref.watch(allCategoriesProvider).valueOrNull ?? const [];

    final now = DateTime.now();
    final monthlyItems = transactions
        .where(
          (t) =>
              t.type == TransactionType.expense &&
              t.date.year == now.year &&
              t.date.month == now.month,
        )
        .toList(growable: false);

    final monthlySpend = monthlyItems.fold<double>(
      0,
      (sum, t) => sum + t.amount,
    );
    final remaining = budget - monthlySpend;
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final leftDays = (daysInMonth - now.day + 1).clamp(1, 31);
    final safePerDay = remaining / leftDays;

    final byCategory = <String, double>{};
    for (final tx in monthlyItems) {
      byCategory[tx.categoryId] =
          (byCategory[tx.categoryId] ?? 0.0) + tx.amount;
    }

    final categoryCards = byCategory.entries.toList(growable: false)
      ..sort((a, b) => b.value.compareTo(a.value));
    final monthKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final categoryBudgetsAsync = ref.watch(
      _categoryBudgetsForMonthProvider(monthKey),
    );
    final budgetByCategory = {
      for (final b in categoryBudgetsAsync.valueOrNull ?? const [])
        b.categoryId: b.budgetAmount.toDouble(),
    };

    return Scaffold(
      appBar: NoirHeader(
        showLeading: true,
        leadingIcon: AppIcons.bell,
        onLeadingTap: () => context.push('/notifications'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.smPlus,
          AppSpacing.mdPlus,
          AppSpacing.smPlus,
          AppSpacing.md,
        ),
        children: [
          Text('Budget', style: AppTypography.screenTitle(context)),
          const SizedBox(height: 4),
          Text(
            '${DateFormat('MMMM').format(now)} Overview',
            style: const TextStyle(color: Color(0xFFC5C5C5)),
          ),
          const SizedBox(height: 10),
          const Divider(color: AppColors.borderDark),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderDark),
              color: const Color(0xFF0E0E0E),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Monthly Health', style: AppTypography.cardTitle(context)),
                const SizedBox(height: 6),
                const Text(
                  'TOTAL AVAILABLE VS USED',
                  style: TextStyle(
                    letterSpacing: 1.8,
                    fontSize: 11,
                    color: Color(0xFFAFAFAF),
                  ),
                ),
                const SizedBox(height: 10),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.white),
                    children: [
                      TextSpan(
                        text: Formatters.currency(monthlySpend),
                        style: AppTypography.amount(context),
                      ),
                      TextSpan(
                        text: ' / ${Formatters.currency(budget)}',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color(0xFFC8C8C8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: budget <= 0 ? 0 : (monthlySpend / budget).clamp(0, 1),
                  minHeight: 8,
                  color: Colors.white,
                  backgroundColor: const Color(0xFF2F2F2F),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '${(budget <= 0 ? 0 : ((monthlySpend / budget) * 100)).toStringAsFixed(0)}% Used',
                    ),
                    const Spacer(),
                    Text(
                      '${Formatters.currency(remaining.abs())} ${remaining >= 0 ? 'Remaining' : 'Over'}',
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(color: AppColors.borderDark),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Safe to Spend',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFB8B8B8),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${safePerDay >= 0 ? Formatters.currency(safePerDay) : '-${Formatters.currency(safePerDay.abs())}'} / day',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: safePerDay >= 0
                                  ? const Color(0xFF59F28F)
                                  : const Color(0xFFFFB3A8),
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF797979)),
                      ),
                      child: Text(
                        remaining >= 0 ? 'ON TRACK' : 'OVER BUDGET',
                        style: const TextStyle(
                          fontSize: 11,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Categories',
                  style: AppTypography.sectionTitle(context),
                ),
              ),
              OutlinedButton(
                onPressed: () => _openBudgetEditor(context, ref, budget),
                child: const Text('Edit budgets'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...categoryCards.map((entry) {
            final category = categories
                .where((c) => c.id == entry.key)
                .firstOrNull;
            final spend = entry.value;
            final allocated = (budgetByCategory[entry.key] ?? 0.0).toDouble();
            final ratio = allocated <= 0 ? 0.0 : spend / allocated;
            final over = ratio > 1;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _BudgetCategoryCard(
                name: category?.name ?? entry.key,
                icon: _iconFor(category?.name ?? entry.key),
                spend: spend,
                allocated: allocated,
                ratio: ratio,
                overBudget: over,
              ),
            );
          }),
        ],
      ),
    );
  }

  static IconData _iconFor(String text) {
    return AppIcons.getIconForCategory(text);
  }

  Future<void> _openBudgetEditor(
    BuildContext context,
    WidgetRef ref,
    double currentBudget,
  ) async {
    final now = DateTime.now();
    final monthKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final budgetController = TextEditingController(
      text: currentBudget > 0 ? currentBudget.toStringAsFixed(2) : '',
    );
    final categories = ref.read(allCategoriesProvider).valueOrNull ?? const [];
    final expenseCategories = categories
        .where((c) => c.type == TransactionType.expense)
        .toList(growable: false);
    final existingCategoryBudgets = await ref
        .read(appDatabaseProvider)
        .getCategoryBudgetsForMonth(monthKey);
    final categoryBudgetControllers = {
      for (final c in expenseCategories)
        c.id: TextEditingController(
          text:
              (existingCategoryBudgets
                          .where((b) => b.categoryId == c.id)
                          .firstOrNull
                          ?.budgetAmount ??
                      0) >
                  0
              ? (existingCategoryBudgets
                            .where((b) => b.categoryId == c.id)
                            .firstOrNull
                            ?.budgetAmount ??
                        0)
                    .toStringAsFixed(2)
              : '',
        ),
    };
    if (!context.mounted) return;

    StateSetter? sheetSetState;
    void rebuildSheet() {
      if (sheetSetState != null) {
        sheetSetState!(() {});
      }
    }

    budgetController.addListener(rebuildSheet);
    for (final controller in categoryBudgetControllers.values) {
      controller.addListener(rebuildSheet);
    }

    final sheetFuture = showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => AppModalSurface(
        child: Padding(
          padding: EdgeInsets.zero,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.sm,
              AppSpacing.xs,
              AppSpacing.sm,
              MediaQuery.of(sheetContext).viewInsets.bottom + AppSpacing.sm,
            ),
            child: StatefulBuilder(
              builder: (context, setState) {
                sheetSetState = setState;

                final monthlyBudgetValue =
                    Money.tryParse(budgetController.text.trim()) ?? 0.0;
                double totalCategoryBudget = 0.0;
                for (final c in expenseCategories) {
                  final val =
                      Money.tryParse(
                        categoryBudgetControllers[c.id]!.text.trim(),
                      ) ??
                      0.0;
                  totalCategoryBudget += val;
                }

                final isOverAllocated =
                    totalCategoryBudget > monthlyBudgetValue;

                return Column(
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
                    Text(
                      'Edit Budget',
                      style: AppTypography.sectionTitle(context),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const _ModalFieldLabel('Monthly Budget'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: budgetController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(hintText: 'e.g. 25000'),
                    ),
                    const SizedBox(height: AppSpacing.smPlus),
                    Text(
                      'Category Budgets',
                      style: AppTypography.cardTitle(context),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ...expenseCategories.map((c) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ModalFieldLabel(c.name),
                            const SizedBox(height: 6),
                            TextField(
                              controller: categoryBudgetControllers[c.id],
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: const InputDecoration(hintText: '0'),
                            ),
                          ],
                        ),
                      );
                    }),
                    if (isOverAllocated) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Total category budgets (${Formatters.currency(totalCategoryBudget)}) cannot exceed monthly budget (${Formatters.currency(monthlyBudgetValue)}).',
                        style: const TextStyle(
                          color: Color(0xFFFFB3A8),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xs),
                    DialogActionsRow(
                      cancelText: 'Close',
                      confirmText: 'Save',
                      onCancel: () => Navigator.pop(sheetContext),
                      onConfirm: isOverAllocated
                          ? null
                          : () async {
                              final next = Money.tryParse(
                                budgetController.text.trim(),
                              );
                              if (next == null || next < 0) return;
                              await ref
                                  .read(settingsRepositoryProvider)
                                  .setBudget(next);
                              final db = ref.read(appDatabaseProvider);
                              for (final c in expenseCategories) {
                                final parsed = Money.tryParse(
                                  categoryBudgetControllers[c.id]!.text.trim(),
                                );
                                final value = parsed == null || parsed < 0
                                    ? 0.0
                                    : Money.normalize(parsed);
                                await db.upsertCategoryBudget(
                                  CategoryBudgetsCompanion.insert(
                                    monthKey: monthKey,
                                    categoryId: c.id,
                                    budgetAmount: value,
                                    budgetAmountPaise: Value(
                                      Money.toPaise(value),
                                    ),
                                    updatedAt:
                                        DateTime.now().millisecondsSinceEpoch,
                                  ),
                                );
                              }
                              if (sheetContext.mounted) {
                                Navigator.pop(sheetContext);
                              }
                            },
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          if (!context.mounted) return;
                          context.push('/categories');
                        },
                        child: const Text('Add / Manage Categories'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );

    sheetFuture.whenComplete(() {
      budgetController.removeListener(rebuildSheet);
      for (final controller in categoryBudgetControllers.values) {
        controller.removeListener(rebuildSheet);
      }
      budgetController.dispose();
      for (final controller in categoryBudgetControllers.values) {
        controller.dispose();
      }
    });
  }
}

class _ModalFieldLabel extends StatelessWidget {
  const _ModalFieldLabel(this.label);

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

final _categoryBudgetsForMonthProvider =
    StreamProvider.family<List<CategoryBudget>, String>((ref, monthKey) {
      return ref
          .read(appDatabaseProvider)
          .watchCategoryBudgetsForMonth(monthKey);
    });

class _BudgetCategoryCard extends StatelessWidget {
  const _BudgetCategoryCard({
    required this.name,
    required this.icon,
    required this.spend,
    required this.allocated,
    required this.ratio,
    required this.overBudget,
  });

  final String name;
  final IconData icon;
  final double spend;
  final double allocated;
  final double ratio;
  final bool overBudget;

  @override
  Widget build(BuildContext context) {
    final remaining = allocated - spend;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0E0E0E),
        border: Border.all(
          color: overBudget ? const Color(0xFFFFB3A8) : AppColors.borderDark,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: AppTypography.sectionTitle(context).copyWith(
                    color: overBudget ? const Color(0xFFFFB3A8) : Colors.white,
                  ),
                ),
              ),
              if (overBudget)
                const Text(
                  'OVER BUDGET',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.2,
                    color: Color(0xFFFFB3A8),
                  ),
                ),
              const SizedBox(width: 8),
              Icon(
                icon,
                size: 17,
                color: overBudget ? const Color(0xFFFFB3A8) : Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '${Formatters.currency(spend)} / ${Formatters.currency(allocated)}',
            style: TextStyle(
              color: overBudget
                  ? const Color(0xFFFFB3A8)
                  : const Color(0xFFE1E1E1),
            ),
          ),
          const SizedBox(height: 18),
          LinearProgressIndicator(
            value: ratio.clamp(0, 1.6),
            minHeight: 4,
            color: overBudget ? const Color(0xFFFFB3A8) : Colors.white,
            backgroundColor: const Color(0xFF2F2F2F),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text('${(ratio * 100).toStringAsFixed(0)}%'),
              const Spacer(),
              Text(
                '${remaining >= 0 ? Formatters.currency(remaining) : '-${Formatters.currency(remaining.abs())}'} ${remaining >= 0 ? 'Left' : 'Over'}',
                style: TextStyle(
                  color: overBudget
                      ? const Color(0xFFFFB3A8)
                      : const Color(0xFFD0D0D0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
