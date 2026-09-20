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
import 'package:spendly/core/widgets/amount_mask.dart';
import 'package:spendly/core/utils/money.dart';
import 'package:spendly/core/widgets/app_modal_surface.dart';
import 'package:spendly/core/widgets/dialog_actions_row.dart';
import 'package:spendly/core/widgets/app_header.dart';
import 'package:spendly/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:spendly/features/categories/presentation/providers/categories_provider.dart';
import 'package:spendly/features/categories/domain/entities/category_entity.dart';
import 'package:spendly/features/settings/presentation/providers/settings_provider.dart';
import 'package:spendly/features/transactions/presentation/providers/transactions_provider.dart';

const _kBudgetGreen = Color(0xFF38D97A);
const _kBudgetAmber = Color(0xFFF5B83D);
const _kBudgetRed = Color(0xFFFF5C6C);
const _kBudgetPurple = Color(0xFF8B5CF6);
const _kBudgetSoftRed = Color(0xFFFF8A7A);
const _kBudgetGreenTint = Color(0xFF0F2A1C);
const _kBudgetRedTint = Color(0xFF2A1313);
const _kBudgetGreenLight = Color(0xFF0E9C58);
const _kBudgetAmberLight = Color(0xFFA87409);
const _kBudgetRedLight = Color(0xFFE03550);
const _kBudgetPurpleLight = Color(0xFF7157D8);
const _kBudgetSoftRedLight = Color(0xFFEF6459);
const _kBudgetGreenTintLight = Color(0xFFE7F7EE);
const _kBudgetRedTintLight = Color(0xFFFDE7EA);

bool _isDark(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;

Color _budgetTrackColor(BuildContext context) =>
    _isDark(context) ? const Color(0xFF1C1E20) : const Color(0xFFEDEDEF);

Color _green(BuildContext context) =>
    _isDark(context) ? _kBudgetGreen : _kBudgetGreenLight;

Color _amber(BuildContext context) =>
    _isDark(context) ? _kBudgetAmber : _kBudgetAmberLight;

Color _red(BuildContext context) =>
    _isDark(context) ? _kBudgetRed : _kBudgetRedLight;

Color _purple(BuildContext context) =>
    _isDark(context) ? _kBudgetPurple : _kBudgetPurpleLight;

Color _softRed(BuildContext context) =>
    _isDark(context) ? _kBudgetSoftRed : _kBudgetSoftRedLight;

Color _greenTint(BuildContext context) =>
    _isDark(context) ? _kBudgetGreenTint : _kBudgetGreenTintLight;

Color _redTint(BuildContext context) =>
    _isDark(context) ? _kBudgetRedTint : _kBudgetRedTintLight;

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
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final leftDays = (daysInMonth - now.day + 1).clamp(1, 31);

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
      appBar: AppHeader(
        mode: AppHeaderMode.back,
        title: 'Budget',
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
          if (budget > 0)
            _BudgetSummaryCard(
              monthLabel: DateFormat('MMMM').format(now).toUpperCase(),
              monthlySpend: monthlySpend,
              budget: budget,
              leftDays: leftDays,
            )
          else
            _NoBudgetCard(
              onSet: () => _openBudgetEditor(context, ref, budget),
            ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const Expanded(child: _SectionHeader(label: 'Categories')),
              const SizedBox(width: 12),
              _GhostEditButton(
                onTap: () => _openBudgetEditor(context, ref, budget),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.smPlus),
          if (categoryCards.isEmpty)
            const _InlineEmpty(
              icon: AppIcons.budget,
              message: 'No category spending this month',
            )
          else
            ...categoryCards.map((entry) {
              final category = categories
                  .where((c) => c.id == entry.key)
                  .firstOrNull;
              final spend = entry.value;
              final allocated = (budgetByCategory[entry.key] ?? 0.0).toDouble();
              final ratio = allocated <= 0 ? 0.0 : spend / allocated;
              final over = ratio > 1;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
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
    final categories = ref.read(allCategoriesProvider).valueOrNull ?? const [];
    final expenseCategories = categories
        .where((c) => c.type == TransactionType.expense)
        .toList(growable: false);
    final existingCategoryBudgets = await ref
        .read(appDatabaseProvider)
        .getCategoryBudgetsForMonth(monthKey);
    if (!context.mounted) return;

    final sheetFuture = showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _BudgetEditorSheet(
        monthKey: monthKey,
        currentBudget: currentBudget,
        expenseCategories: expenseCategories,
        existingCategoryBudgets: existingCategoryBudgets,
        onManageCategories: () {
          if (context.mounted) {
            context.push('/categories');
          }
        },
      ),
    );

    await sheetFuture;
  }
}

class _BudgetEditorSheet extends ConsumerStatefulWidget {
  const _BudgetEditorSheet({
    required this.monthKey,
    required this.currentBudget,
    required this.expenseCategories,
    required this.existingCategoryBudgets,
    required this.onManageCategories,
  });

  final String monthKey;
  final double currentBudget;
  final List<CategoryEntity> expenseCategories;
  final List<CategoryBudget> existingCategoryBudgets;
  final VoidCallback onManageCategories;

  @override
  ConsumerState<_BudgetEditorSheet> createState() => _BudgetEditorSheetState();
}

class _BudgetEditorSheetState extends ConsumerState<_BudgetEditorSheet> {
  late final TextEditingController _budgetController;
  late final Map<String, TextEditingController> _categoryBudgetControllers;

  @override
  void initState() {
    super.initState();
    _budgetController = TextEditingController(
      text: widget.currentBudget > 0
          ? widget.currentBudget.toStringAsFixed(2)
          : '',
    );
    _categoryBudgetControllers = {
      for (final c in widget.expenseCategories)
        c.id: TextEditingController(
          text:
              (widget.existingCategoryBudgets
                          .where((b) => b.categoryId == c.id)
                          .firstOrNull
                          ?.budgetAmount ??
                      0) >
                  0
              ? (widget.existingCategoryBudgets
                            .where((b) => b.categoryId == c.id)
                            .firstOrNull
                            ?.budgetAmount ??
                        0)
                    .toStringAsFixed(2)
              : '',
        ),
    };
  }

  @override
  void dispose() {
    _budgetController.dispose();
    for (final controller in _categoryBudgetControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save(BuildContext context) async {
    final next = Money.tryParse(_budgetController.text.trim());
    if (next == null || next < 0) return;
    await ref.read(settingsRepositoryProvider).setBudget(next);
    final db = ref.read(appDatabaseProvider);
    for (final c in widget.expenseCategories) {
      final parsed = Money.tryParse(
        _categoryBudgetControllers[c.id]!.text.trim(),
      );
      final value = parsed == null || parsed < 0
          ? 0.0
          : Money.normalize(parsed);
      await db.upsertCategoryBudget(
        CategoryBudgetsCompanion.insert(
          monthKey: widget.monthKey,
          categoryId: c.id,
          budgetAmount: value,
          budgetAmountPaise: Value(Money.toPaise(value)),
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    }
    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final monthlyBudgetValue =
        Money.tryParse(_budgetController.text.trim()) ?? 0.0;
    double totalCategoryBudget = 0.0;
    for (final c in widget.expenseCategories) {
      final val =
          Money.tryParse(_categoryBudgetControllers[c.id]!.text.trim()) ?? 0.0;
      totalCategoryBudget += val;
    }
    final isOverAllocated = totalCategoryBudget > monthlyBudgetValue;

    return AppModalSurface(
      child: Padding(
        padding: EdgeInsets.zero,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.sm,
            AppSpacing.xs,
            AppSpacing.sm,
            MediaQuery.of(context).viewInsets.bottom + AppSpacing.sm,
          ),
          child: SingleChildScrollView(
            child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 64,
                  height: 4,
                  color: context.border,
                ),
              ),
              const SizedBox(height: AppSpacing.smPlus),
              Row(
                children: [
                  Expanded(
                    child: Text('Edit Budget', style: AppTypography.sectionTitle(context)),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(AppIcons.close, color: context.textPrimary, size: 28),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              const _ModalFieldLabel('Monthly Budget'),
              const SizedBox(height: 6),
              TextField(
                controller: _budgetController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(hintText: 'e.g. 25000'),
              ),
              const SizedBox(height: AppSpacing.smPlus),
              Text('Category Budgets', style: AppTypography.cardTitle(context)),
              const SizedBox(height: AppSpacing.sm),
              ...widget.expenseCategories.map((c) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ModalFieldLabel(c.name),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _categoryBudgetControllers[c.id],
                        keyboardType: const TextInputType.numberWithOptions(
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
                  style: TextStyle(
                    color: _red(context),
                    fontSize: AppFontSizes.label,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xs),
              DialogActionsRow(
                cancelText: 'Close',
                confirmText: 'Save',
                onCancel: () => Navigator.pop(context),
                onConfirm: isOverAllocated ? null : () => _save(context),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onManageCategories();
                  },
                  child: const Text('Add / Manage Categories'),
                ),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}

class _ModalFieldLabel extends StatelessWidget {
  const _ModalFieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: context.textSecondary,
        fontSize: AppFontSizes.label,
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

class _BudgetSummaryCard extends StatelessWidget {
  const _BudgetSummaryCard({
    required this.monthLabel,
    required this.monthlySpend,
    required this.budget,
    required this.leftDays,
  });

  final String monthLabel;
  final double monthlySpend;
  final double budget;
  final int leftDays;

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark(context);
    final gradientColors = isDark
        ? const [Color(0xFF12131A), Color(0xFF0E0F16), Color(0xFF131022)]
        : const [Color(0xFFFBFAFF), Color(0xFFF5F1FF), Color(0xFFFDF5F4)];
    final remaining = budget - monthlySpend;
    final safePerDay = remaining / leftDays;
    final onTrack = remaining >= 0;
    final usage = (monthlySpend / budget).clamp(0.0, 1.0);
    final percent = monthlySpend / budget;
    final statusColor = onTrack ? _green(context) : _red(context);
    final statusTint = onTrack ? _greenTint(context) : _redTint(context);
    final statusLabel = onTrack ? 'ON TRACK' : 'OVER BUDGET';

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        border: Border.all(color: context.border),
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -46,
            top: -46,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _purple(context).withValues(alpha: isDark ? 0.20 : 0.12),
                    _purple(context).withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'MONTHLY BUDGET \u00B7 $monthLabel',
                        style: TextStyle(
                          letterSpacing: 1.8,
                          fontSize: AppFontSizes.small,
                          fontWeight: FontWeight.w700,
                          color: context.textSecondary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusTint,
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: AppFontSizes.small,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: AmountView(
                          monthlySpend,
                          style: TextStyle(
                            color: context.textPrimary,
                            fontSize: AppFontSizes.largeDisplay,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.8,
                            height: 1,
                          ),
                          maskColor: context.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '/ ${Formatters.currency(budget)}',
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: AppFontSizes.heading,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _BudgetBar(
                  value: usage,
                  colors: onTrack
                      ? [_purple(context), _green(context)]
                      : [_softRed(context), _red(context)],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '${percent.toStringAsFixed(0)}% Used',
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: AppFontSizes.label,
                      ),
                    ),
                    const Spacer(),
                    Flexible(
                      child: Text(
                        '${Formatters.currency(remaining.abs())} ${onTrack ? 'Remaining' : 'Over'}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: AppFontSizes.label,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(color: context.border),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Safe to Spend',
                            style: TextStyle(
                              fontSize: AppFontSizes.label,
                              color: context.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(
                                safePerDay < 0 ? '-' : '',
                                style: TextStyle(
                                  fontSize: AppFontSizes.heading,
                                  fontWeight: FontWeight.w700,
                                  color: statusColor,
                                  height: 1,
                                ),
                              ),
                              AmountView(
                                safePerDay.abs(),
                                style: TextStyle(
                                  fontSize: AppFontSizes.heading,
                                  fontWeight: FontWeight.w700,
                                  color: statusColor,
                                  height: 1,
                                ),
                                maskColor: statusColor,
                              ),
                              Text(
                                ' / day',
                                style: TextStyle(
                                  fontSize: AppFontSizes.heading,
                                  fontWeight: FontWeight.w700,
                                  color: statusColor,
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Days left',
                          style: TextStyle(
                            fontSize: AppFontSizes.caption,
                            color: context.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$leftDays',
                          style: TextStyle(
                            fontSize: AppFontSizes.heading,
                            fontWeight: FontWeight.w700,
                            color: context.textPrimary,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NoBudgetCard extends StatelessWidget {
  const _NoBudgetCard({required this.onSet});

  final VoidCallback onSet;

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark(context);
    final gradientColors = isDark
        ? const [Color(0xFF12131A), Color(0xFF0E0F16), Color(0xFF131022)]
        : const [Color(0xFFFBFAFF), Color(0xFFF5F1FF), Color(0xFFFDF5F4)];
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        border: Border.all(color: context.border),
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -46,
            top: -46,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _purple(context).withValues(alpha: isDark ? 0.20 : 0.12),
                    _purple(context).withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MONTHLY BUDGET',
                  style: TextStyle(
                    letterSpacing: 1.8,
                    fontSize: AppFontSizes.small,
                    fontWeight: FontWeight.w700,
                    color: context.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Set a budget to catch overspending',
                  style: TextStyle(
                    color: context.textPrimary,
                    fontSize: AppFontSizes.largeHeading,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'A clear monthly limit keeps spending in check and reveals '
                  'exactly how much headroom you have left.',
                  style: TextStyle(
                    color: context.textSecondary,
                    fontSize: AppFontSizes.body,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                _PrimaryPill(
                  label: 'Set budget',
                  icon: AppIcons.edit,
                  onTap: onSet,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryPill extends StatelessWidget {
  const _PrimaryPill({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: context.textPrimary,
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: context.background),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: context.background,
                fontSize: AppFontSizes.bodyLarge,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetBar extends StatelessWidget {
  const _BudgetBar({required this.value, required this.colors});

  final double value;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    final progress = value.clamp(0.0, 1.0).toDouble();
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: SizedBox(
        height: 8,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: _budgetTrackColor(context)),
            if (progress > 0)
              FractionallySizedBox(
                widthFactor: progress,
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: colors,
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: context.textSecondary.withValues(alpha: 0.7),
            fontSize: AppFontSizes.small,
            letterSpacing: 2.4,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 1,
            color: context.border.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

class _GhostEditButton extends StatelessWidget {
  const _GhostEditButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            color: context.textPrimary.withValues(alpha: 0.28),
          ),
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(AppIcons.edit, size: 15, color: context.textPrimary),
            const SizedBox(width: 6),
            Text(
              'Edit',
              style: TextStyle(
                color: context.textPrimary,
                fontSize: AppFontSizes.bodyLarge,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineEmpty extends StatelessWidget {
  const _InlineEmpty({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: context.surface,
        border: Border.all(color: context.border),
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _purple(context).withValues(alpha: 0.16),
                  _purple(context).withValues(alpha: 0),
                ],
              ),
            ),
            child: Icon(icon, color: _purple(context), size: 26),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.textSecondary,
              fontSize: AppFontSizes.body,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

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
    final hasLimit = allocated > 0;
    final remaining = allocated - spend;
    final iconColor = AppIcons.getColorForIcon(icon, label: name);
    final statusColor = !hasLimit
        ? context.textSecondary
        : (overBudget ? _red(context) : _green(context));
    final statusTint = !hasLimit
        ? context.surfaceAlt
        : (overBudget ? _redTint(context) : _greenTint(context));
    final statusLabel = !hasLimit
        ? 'NO LIMIT'
        : (overBudget ? 'OVER' : 'ON TRACK');
    final barColors = overBudget
        ? [_softRed(context), _red(context)]
        : (ratio >= 0.8)
            ? [_amber(context), _red(context)]
            : [_purple(context), _green(context)];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surface,
        border: Border.all(
          color: overBudget
              ? _red(context).withValues(
                  alpha: _isDark(context) ? 0.5 : 0.55,
                )
              : context.border,
        ),
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.textPrimary,
                        fontSize: AppFontSizes.title,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusTint,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: AppFontSizes.small,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              AmountView(
                spend,
                style: TextStyle(
                  color: overBudget ? _red(context) : context.textPrimary,
                  fontSize: AppFontSizes.heading,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
                maskColor: overBudget ? _red(context) : context.textPrimary,
              ),
              const SizedBox(width: 4),
              Text(
                '/',
                style: TextStyle(
                  color: context.textSecondary,
                  fontSize: AppFontSizes.body,
                  fontWeight: FontWeight.w600,
                  height: 1,
                ),
              ),
              const SizedBox(width: 4),
              AmountView(
                allocated,
                style: TextStyle(
                  color: context.textSecondary,
                  fontSize: AppFontSizes.body,
                  fontWeight: FontWeight.w600,
                  height: 1,
                ),
                maskColor: context.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _BudgetBar(
            value: hasLimit ? ratio.clamp(0.0, 1.0) : 0.0,
            colors: barColors,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                hasLimit ? '${(ratio * 100).toStringAsFixed(0)}% used' : 'No cap',
                style: TextStyle(
                  color: context.textSecondary,
                  fontSize: AppFontSizes.label,
                ),
              ),
              const Spacer(),
              if (hasLimit)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AmountView(
                      remaining.abs(),
                      style: TextStyle(
                        color: overBudget
                            ? _red(context)
                            : context.textSecondary,
                        fontSize: AppFontSizes.label,
                        fontWeight: FontWeight.w700,
                      ),
                      maskColor: overBudget
                          ? _red(context)
                          : context.textSecondary,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      remaining >= 0 ? 'Left' : 'Over',
                      style: TextStyle(
                        color: overBudget
                            ? _red(context)
                            : context.textSecondary,
                        fontSize: AppFontSizes.label,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                )
              else
                AmountView(
                  spend,
                  style: TextStyle(
                    color: context.textSecondary,
                    fontSize: AppFontSizes.label,
                    fontWeight: FontWeight.w700,
                  ),
                  maskColor: context.textSecondary,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
