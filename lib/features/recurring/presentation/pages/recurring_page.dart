import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/core/constants/app_constants.dart';
import 'package:spendly/core/constants/app_enums.dart';
import 'package:spendly/core/theme/app_design_tokens.dart';
import 'package:spendly/core/theme/app_icons.dart';
import 'package:spendly/core/theme/app_typography.dart';
import 'package:spendly/core/utils/formatters.dart';
import 'package:spendly/core/utils/money.dart';
import 'package:spendly/core/widgets/app_confirm_dialog.dart';
import 'package:spendly/core/widgets/dialog_actions_row.dart';
import 'package:spendly/core/widgets/noir_header.dart';
import 'package:spendly/core/widgets/swipe_actions_info_button.dart';
import 'package:spendly/features/categories/data/repositories/categories_repository_impl.dart';
import 'package:spendly/features/categories/domain/entities/category_entity.dart';
import 'package:spendly/features/recurring/data/repositories/recurring_repository_impl.dart';
import 'package:spendly/features/recurring/domain/entities/recurring_rule_entity.dart';
import 'package:spendly/features/recurring/presentation/providers/recurring_provider.dart';
import 'package:uuid/uuid.dart';

class RecurringPage extends ConsumerWidget {
  const RecurringPage({super.key});

  Future<void> _openAddDialog(
    BuildContext context,
    WidgetRef ref, {
    RecurringRuleEntity? existing,
  }) async {
    final titleController = TextEditingController(text: existing?.title ?? '');
    final amountController = TextEditingController(
      text: existing == null ? '' : existing.amount.toStringAsFixed(2),
    );
    final noteController = TextEditingController(text: existing?.note ?? '');

    final categories = await ref
        .read(categoriesRepositoryProvider)
        .watchByType(TransactionType.expense.value)
        .first;
    if (!context.mounted) return;

    if (categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please create an expense category first.'),
        ),
      );
      return;
    }

    CategoryEntity selectedCategory = categories.first;
    if (existing != null) {
      final match = categories.where((c) => c.id == existing.categoryId);
      if (match.isNotEmpty) selectedCategory = match.first;
    }
    PaymentMode selectedPaymentMode = existing?.paymentMode ?? PaymentMode.upi;
    RecurringFrequency selectedFrequency =
        existing?.frequency ?? RecurringFrequency.monthly;
    DateTime selectedStartDate = existing?.startDate ?? DateTime.now();

    await showDialog<void>(
      context: context,
      builder: (context) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Colors.white,
            onPrimary: Colors.black,
            surface: Color(0xFF0E0E0E),
            onSurface: Colors.white,
          ),
          dialogTheme: const DialogThemeData(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            backgroundColor: Color(0xFF0E0E0E),
          ),
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            final dropdownMenuColor =
                Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF16261E)
                : Colors.white;
            return AlertDialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: AppModalSizes.horizontalInset,
                vertical: AppModalSizes.verticalInset,
              ),
              title: Text(
                existing == null ? 'Add Recurring Expense' : 'Edit Recurring',
              ),
              content: SizedBox(
                width: AppModalSizes.dialogContentWidth,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _ModalFieldLabel('Title'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          hintText: 'e.g. Netflix, Rent',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const _ModalFieldLabel('Amount'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          prefixText: '${AppConstants.currencySymbol} ',
                          hintText: '0.00',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const _ModalFieldLabel('Category'),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<CategoryEntity>(
                        dropdownColor: dropdownMenuColor,
                        initialValue: selectedCategory,
                        decoration: const InputDecoration(),
                        items: categories
                            .map(
                              (c) => DropdownMenuItem(
                                value: c,
                                child: Text(c.name),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => selectedCategory = value);
                          }
                        },
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const _ModalFieldLabel('Frequency'),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<RecurringFrequency>(
                        dropdownColor: dropdownMenuColor,
                        initialValue: selectedFrequency,
                        decoration: const InputDecoration(),
                        items: const [
                          DropdownMenuItem(
                            value: RecurringFrequency.daily,
                            child: Text('Daily'),
                          ),
                          DropdownMenuItem(
                            value: RecurringFrequency.weekly,
                            child: Text('Weekly'),
                          ),
                          DropdownMenuItem(
                            value: RecurringFrequency.monthly,
                            child: Text('Monthly'),
                          ),
                          DropdownMenuItem(
                            value: RecurringFrequency.yearly,
                            child: Text('Yearly'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => selectedFrequency = value);
                          }
                        },
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const _ModalFieldLabel('Account'),
                      const SizedBox(height: 6),
                      _PaymentModeSegment(
                        selected: selectedPaymentMode,
                        onChanged: (value) {
                          setState(() => selectedPaymentMode = value);
                        },
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const _ModalFieldLabel('Note (optional)'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: noteController,
                        decoration: const InputDecoration(hintText: 'Add note'),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const _ModalFieldLabel('Start Date'),
                      const SizedBox(height: 4),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(Formatters.date(selectedStartDate)),
                        trailing: const Icon(AppIcons.calendar),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedStartDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now().add(
                              const Duration(days: 3650),
                            ),
                          );
                          if (picked != null) {
                            setState(() => selectedStartDate = picked);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                DialogActionsRow(
                  cancelText: 'Cancel',
                  confirmText: existing == null ? 'Save' : 'Update',
                  onCancel: () => Navigator.pop(context),
                  onConfirm: () async {
                    final title = titleController.text.trim();
                    final amount = Money.tryParse(amountController.text.trim());
                    if (title.isEmpty || amount == null || amount <= 0) return;

                    final now = DateTime.now();
                    final rule = RecurringRuleEntity(
                      id: existing?.id ?? const Uuid().v4(),
                      title: title,
                      type: TransactionType.expense,
                      amount: amount,
                      categoryId: selectedCategory.id,
                      paymentMode: selectedPaymentMode,
                      frequency: selectedFrequency,
                      note: noteController.text.trim().isEmpty
                          ? null
                          : noteController.text.trim(),
                      startDate: selectedStartDate,
                      nextDueDate: existing?.nextDueDate ?? selectedStartDate,
                      createdAt: existing?.createdAt ?? now,
                      updatedAt: now,
                      isActive: existing?.isActive ?? true,
                      isDeleted: existing?.isDeleted ?? false,
                    );

                    await ref
                        .read(recurringRepositoryProvider)
                        .addOrUpdate(rule);
                    await ref
                        .read(recurringRepositoryProvider)
                        .processDueRules();
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rules = ref.watch(recurringRulesProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: NoirHeader(
        showLeading: true,
        leadingIcon: AppIcons.chevronLeft,
        onLeadingTap: () => Navigator.of(context).maybePop(),
        showProfileAction: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddDialog(context, ref),
        icon: const Icon(AppIcons.repeat),
        label: const Text('Add Rule'),
      ),
      body: rules.when(
        data: (items) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.smPlus,
                  AppSpacing.md,
                  AppSpacing.smPlus,
                  AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Recurring Expenses',
                        style: AppTypography.screenTitle(context),
                      ),
                    ),
                    const SwipeActionsInfoButton(
                      tooltip: 'Recurring swipe help',
                      title: 'Recurring actions',
                      message:
                          'Recurring rules can be swiped to edit or delete.',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: items.isEmpty
                    ? const Center(child: Text('No recurring expenses yet.'))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.smPlus,
                          0,
                          AppSpacing.smPlus,
                          AppSpacing.md,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final dueToday =
                              DateTime(
                                item.nextDueDate.year,
                                item.nextDueDate.month,
                                item.nextDueDate.day,
                              ) ==
                              DateTime(
                                DateTime.now().year,
                                DateTime.now().month,
                                DateTime.now().day,
                              );
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            child: Dismissible(
                              key: ValueKey(item.id),
                              direction: DismissDirection.horizontal,
                              confirmDismiss: (direction) async {
                                if (direction == DismissDirection.startToEnd) {
                                  await _openAddDialog(
                                    context,
                                    ref,
                                    existing: item,
                                  );
                                  return false;
                                }
                                final shouldDelete =
                                    await showAppDeleteConfirmDialog(
                                      context,
                                      title: 'Delete recurring rule?',
                                      message: 'Delete "${item.title}"?',
                                    );
                                return shouldDelete;
                              },
                              onDismissed: (_) async {
                                await ref
                                    .read(recurringRepositoryProvider)
                                    .softDelete(item.id);
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
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0E0E0E),
                                  border: Border.all(
                                    color: AppColors.borderDark,
                                  ),
                                ),
                                padding: const EdgeInsets.all(AppSpacing.sm),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF1A1A1A),
                                            borderRadius: BorderRadius.circular(
                                              AppRadii.md,
                                            ),
                                          ),
                                          child: Icon(
                                            AppIcons.repeat,
                                            size: 20,
                                            color: item.isActive
                                                ? AppIcons.getColorForIcon(
                                                    AppIcons.repeat,
                                                  )
                                                : const Color(0xFF8F8F8F),
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.sm),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.title,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${item.frequency.value} | Next: ${Formatters.date(item.nextDueDate)}',
                                                style: const TextStyle(
                                                  color: Color(0xFFB8B8B8),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.sm),
                                        Text(
                                          Formatters.currency(item.amount),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    Row(
                                      children: [
                                        if (dueToday)
                                          const Padding(
                                            padding: EdgeInsets.only(right: 10),
                                            child: Text(
                                              'DUE',
                                              style: TextStyle(
                                                color: Color(0xFFFFB3A8),
                                                fontSize: 10,
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: 1,
                                              ),
                                            ),
                                          ),
                                        const Text(
                                          'Active',
                                          style: TextStyle(
                                            color: Color(0xFF9A9A9A),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Switch(
                                          value: item.isActive,
                                          onChanged: (value) async {
                                            await ref
                                                .read(
                                                  recurringRepositoryProvider,
                                                )
                                                .setActive(item.id, value);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Failed to load: $error')),
      ),
    );
  }
}

class _PaymentModeSegment extends StatelessWidget {
  const _PaymentModeSegment({required this.selected, required this.onChanged});

  final PaymentMode selected;
  final ValueChanged<PaymentMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = const [
      (PaymentMode.upi, 'UPI'),
      (PaymentMode.card, 'Card'),
      (PaymentMode.cash, 'Cash'),
    ];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF4A4A4A)),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isSelected = selected == item.$1;
          return Expanded(
            child: InkWell(
              onTap: () => onChanged(item.$1),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.black,
                  border: Border(
                    right: BorderSide(
                      color: index == items.length - 1
                          ? Colors.transparent
                          : const Color(0xFF4A4A4A),
                    ),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  item.$2,
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontSize: 13,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w700,
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
