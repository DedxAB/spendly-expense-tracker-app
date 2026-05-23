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
      builder: (context) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Colors.white,
            onPrimary: Colors.black,
            surface: Color(0xFF0F0F0F),
            onSurface: Colors.white,
          ),
          dialogTheme: const DialogThemeData(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            backgroundColor: Color(0xFF0F0F0F),
          ),
        ),
        child: StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Add Category'),
            content: SizedBox(
              width: AppModalSizes.dialogContentWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<TransactionType>(
                    segments: const [
                      ButtonSegment(
                        value: TransactionType.income,
                        label: Text('Income'),
                      ),
                      ButtonSegment(
                        value: TransactionType.expense,
                        label: Text('Expense'),
                      ),
                    ],
                    selected: {type},
                    onSelectionChanged: (selection) =>
                        setState(() => type = selection.first),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(allCategoriesProvider);
    final bg = Colors.black;
    final surface = const Color(0xFF0F0F0F);
    final border = const Color(0xFF2E2E2E);
    final primary = Colors.white;
    final secondary = const Color(0xFFB0B0B0);
    const destructive = Color(0xFFE35D5D);
    const destructiveBorder = Color(0xFF5A2323);

    return Scaffold(
      backgroundColor: bg,
      appBar: NoirHeader(
        showLeading: true,
        leadingIcon: AppIcons.chevronLeft,
        onLeadingTap: () => Navigator.of(context).maybePop(),
        showProfileAction: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(context, ref),
        backgroundColor: primary,
        foregroundColor: Colors.black,
        child: const Icon(AppIcons.categories),
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

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.mdPlus,
              AppSpacing.md,
              96,
            ),
            itemCount: expenses.length + incomes.length + 2,
            itemBuilder: (context, index) {
              final expenseHeaderIndex = 0;
              final expenseStart = 1;
              final incomeHeaderIndex = expenseStart + expenses.length;
              final incomeStart = incomeHeaderIndex + 1;

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

              final category = index < incomeHeaderIndex
                  ? expenses[index - expenseStart]
                  : incomes[index - incomeStart];
              final icon = _iconForCategory(category.name, category.type);

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: surface,
                  border: Border.all(color: border),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  leading: Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: border),
                    ),
                    child: Icon(icon, color: primary, size: 20),
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
            const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (error, _) => Center(
          child: Text(
            'Failed to load: $error',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
