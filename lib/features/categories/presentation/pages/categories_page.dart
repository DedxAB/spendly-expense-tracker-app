import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/core/constants/app_enums.dart';
import 'package:spendly/core/theme/app_design_tokens.dart';
import 'package:spendly/core/theme/app_icons.dart';
import 'package:spendly/core/widgets/app_confirm_dialog.dart';
import 'package:spendly/core/widgets/dialog_actions_row.dart';
import 'package:spendly/core/widgets/noir_header.dart';
import 'package:spendly/features/categories/data/repositories/categories_repository_impl.dart';
import 'package:spendly/features/categories/domain/entities/category_entity.dart';
import 'package:spendly/features/categories/presentation/providers/categories_provider.dart';
import 'package:uuid/uuid.dart';

class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  static IconData _iconForCategory(String name, TransactionType type) {
    return AppIcons.getIconForCategory(name, type);
  }

  Future<void> _showCategoryDialog(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    TransactionType type = TransactionType.expense;

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Add Category'),
            content: SizedBox(
              width: AppModalSizes.dialogContentWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _ModalFieldLabel('Category Name'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Food, Salary',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const _ModalFieldLabel('Category Type'),
                  const SizedBox(height: 6),
                  _CategoryTypeSegment(
                    selected: type,
                    onChanged: (value) => setState(() => type = value),
                  ),
                ],
              ),
            ),
            actions: [
              DialogActionsRow(
                cancelText: 'Cancel',
                confirmText: 'Save',
                onCancel: () => Navigator.pop(context),
                onConfirm: () async {
                  final name = nameController.text.trim();
                  if (name.isEmpty) return;
                  final now = DateTime.now();
                  final category = CategoryEntity(
                    id: const Uuid().v4(),
                    name: name,
                    icon: 'category',
                    color: '#00A88F',
                    type: type,
                    createdAt: now,
                    updatedAt: now,
                  );
                  await ref.read(categoriesRepositoryProvider).add(category);
                  if (context.mounted) Navigator.pop(context);
                },
              ),
            ],
          ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(allCategoriesProvider);
    final bg = context.background;
    final surface = context.surface;
    final border = context.border;
    final primary = context.textPrimary;
    final secondary = context.textSecondary;
    const destructive = Color(0xFFE35D5D);
    final destructiveBorder = context.border;

    return Scaffold(
      backgroundColor: bg,
      appBar: NoirHeader(
        showLeading: true,
        leadingIcon: Icons.arrow_back,
        onLeadingTap: () => Navigator.of(context).maybePop(),
        showProfileAction: false,
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: SizedBox(
          width: 178,
          height: 54,
          child: FloatingActionButton.extended(
            onPressed: () => _showCategoryDialog(context, ref),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.md)),
          icon: const Icon(AppIcons.plus, size: 18),
          label: const Text(
            'Add Category',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
      ),
      body: categories.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Text(
                'No categories available',
                style: TextStyle(color: secondary),
              ),
            );
          }
          final expenses =
              items.where((e) => e.type == TransactionType.expense).toList()
                ..sort((a, b) => a.name.compareTo(b.name));
          final incomes =
              items.where((e) => e.type == TransactionType.income).toList()
                ..sort((a, b) => a.name.compareTo(b.name));
          final investments =
              items.where((e) => e.type == TransactionType.investment).toList()
                ..sort((a, b) => a.name.compareTo(b.name));

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.smPlus,
              AppSpacing.mdPlus,
              AppSpacing.smPlus,
              96,
            ),
            itemCount: expenses.length + incomes.length + investments.length + 3,
            itemBuilder: (context, index) {
              final expenseHeaderIndex = 0;
              final expenseStart = 1;
              final incomeHeaderIndex = expenseStart + expenses.length;
              final incomeStart = incomeHeaderIndex + 1;
              final investmentHeaderIndex = incomeStart + incomes.length;
              final investmentStart = investmentHeaderIndex + 1;

              if (index == expenseHeaderIndex) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    'EXPENSE',
                    style: TextStyle(
                      color: secondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.3,
                    ),
                  ),
                );
              }
              if (index == incomeHeaderIndex) {
                return Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 10),
                  child: Text(
                    'INCOME',
                    style: TextStyle(
                      color: secondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.3,
                    ),
                  ),
                );
              }
              if (index == investmentHeaderIndex) {
                return Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 10),
                  child: Text(
                    'INVESTMENT',
                    style: TextStyle(
                      color: secondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.3,
                    ),
                  ),
                );
              }

              final category = index < incomeHeaderIndex
                  ? expenses[index - expenseStart]
                  : index < investmentHeaderIndex
                      ? incomes[index - incomeStart]
                      : investments[index - investmentStart];
              final icon = _iconForCategory(category.name, category.type);

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: surface,
                  border: Border.all(color: border),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  leading: Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: context.surfaceAlt,
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    child: Icon(
                      icon,
                      color: AppIcons.getColorForCategory(
                        category.name,
                        category.type,
                      ),
                      size: 20,
                    ),
                  ),
                  title: Text(
                    category.name,
                    style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    category.type.name.toUpperCase(),
                    style: TextStyle(
                      color: secondary,
                      fontSize: 11,
                      letterSpacing: 0.9,
                    ),
                  ),
                  trailing: InkWell(
                    onTap: () async {
                      final shouldDelete = await showAppDeleteConfirmDialog(
                        context,
                        title: 'Delete category?',
                        message: 'Delete "${category.name}" category?',
                      );
                      if (shouldDelete) {
                        await ref
                            .read(categoriesRepositoryProvider)
                            .softDelete(category.id);
                      }
                    },
                    child: Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: destructiveBorder),
                        color: const Color(0x221B0000),
                        borderRadius: BorderRadius.circular(AppRadii.md),
                      ),
                      child: const Icon(
                        AppIcons.trash,
                        color: destructive,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () =>
            Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(
            'Failed to load: $error',
            style: TextStyle(color: context.textPrimary),
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
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _CategoryTypeSegment extends StatelessWidget {
  const _CategoryTypeSegment({required this.selected, required this.onChanged});

  final TransactionType selected;
  final ValueChanged<TransactionType> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = const [
      (TransactionType.income, 'Income'),
      (TransactionType.expense, 'Expense'),
      (TransactionType.investment, 'Investment'),
    ];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: context.border),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.md),
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
                  color: isSelected ? context.textPrimary : context.surface,
                  border: Border(
                    right: BorderSide(
                      color: index == items.length - 1
                          ? Colors.transparent
                          : context.border,
                    ),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  item.$2,
                  style: TextStyle(
                    color: isSelected ? context.surface : context.textPrimary,
                    fontSize: 13,
                    letterSpacing: 0.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }),
        ),
      ),
    );
  }
}
