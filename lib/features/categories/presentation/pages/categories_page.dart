import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/core/constants/app_enums.dart';
import 'package:spendly/core/theme/app_design_tokens.dart';
import 'package:spendly/core/theme/app_icons.dart';
import 'package:spendly/core/widgets/app_confirm_dialog.dart';
import 'package:spendly/core/widgets/dialog_actions_row.dart';
import 'package:spendly/core/widgets/app_header.dart';
import 'package:spendly/features/categories/data/repositories/categories_repository_impl.dart';
import 'package:spendly/features/categories/domain/entities/category_entity.dart';
import 'package:spendly/features/categories/presentation/providers/categories_provider.dart';
import 'package:uuid/uuid.dart';

const _kCatRed = Color(0xFFFF5C6C);
const _kCatRedLight = Color(0xFFE03550);
const _kCatPurple = Color(0xFF8B5CF6);
const _kCatPurpleLight = Color(0xFF7157D8);

bool _isDark(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;

Color _red(BuildContext context) =>
    _isDark(context) ? _kCatRed : _kCatRedLight;

Color _purple(BuildContext context) =>
    _isDark(context) ? _kCatPurple : _kCatPurpleLight;

String _hexColorString(Color color) {
  final rgb =
      color.toARGB32() & 0xFFFFFF;
  return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}

class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  static IconData _iconForCategory(String name, TransactionType type) {
    return AppIcons.getIconForCategory(name, type);
  }

  Future<void> _showCategoryDialog(
    BuildContext context,
    WidgetRef ref, {
    CategoryEntity? existing,
  }) async {
    final nameController = TextEditingController(text: existing?.name);
    TransactionType type = existing?.type ?? TransactionType.expense;

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(existing == null ? 'Add Category' : 'Edit Category'),
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
                  autofocus: existing == null,
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
              confirmText: existing == null ? 'Save' : 'Update',
              onCancel: () => Navigator.pop(context),
              onConfirm: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                final now = DateTime.now();
                final repo = ref.read(categoriesRepositoryProvider);
                if (existing == null) {
                  final category = CategoryEntity(
                    id: const Uuid().v4(),
                    name: name,
                    icon: 'category',
                    color: _hexColorString(
                      AppIcons.getColorForCategory(
                        name,
                        type,
                        Brightness.dark,
                      ),
                    ),
                    type: type,
                    createdAt: now,
                    updatedAt: now,
                  );
                  await repo.add(category);
                } else {
                  await repo.update(
                    existing.copyWith(
                      name: name,
                      type: type,
                      updatedAt: now,
                    ),
                  );
                }
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

    return Scaffold(
      backgroundColor: context.background,
      appBar: AppHeader(
        mode: AppHeaderMode.back,
        title: 'Categories',
        onLeadingTap: () => Navigator.of(context).maybePop(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(context, ref),
        backgroundColor: context.textPrimary,
        foregroundColor: context.background,
        elevation: 0,
        shape: const CircleBorder(),
        child: const Icon(AppIcons.plus, size: 36),
      ),
      body: categories.when(
        data: (items) {
          if (items.isEmpty) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.smPlus,
                AppSpacing.md,
                AppSpacing.smPlus,
                96,
              ),
              child: _InlineEmpty(
                icon: AppIcons.categories,
                message: 'No categories yet. Create one to organise '
                    'your transactions.',
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

          final sections = <Widget>[
            if (expenses.isNotEmpty) ...[
              const _SectionLabel('EXPENSE'),
              ...expenses.map((c) => _buildRow(context, ref, c)),
            ],
            if (incomes.isNotEmpty) ...[
              const _SectionLabel('INCOME'),
              ...incomes.map((c) => _buildRow(context, ref, c)),
            ],
            if (investments.isNotEmpty) ...[
              const _SectionLabel('INVESTMENT'),
              ...investments.map((c) => _buildRow(context, ref, c)),
            ],
          ];

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.smPlus,
              AppSpacing.mdPlus,
              AppSpacing.smPlus,
              96,
            ),
            itemCount: sections.length,
            itemBuilder: (context, index) => sections[index],
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(
            'Failed to load: $error',
            style: TextStyle(color: context.textPrimary),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(
    BuildContext context,
    WidgetRef ref,
    CategoryEntity category,
  ) {
    final icon = _iconForCategory(category.name, category.type);
    final iconColor = AppIcons.getColorForCategory(
      category.name,
      category.type,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: context.surface,
        border: Border.all(color: context.border),
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 2,
        ),
        leading: Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          category.name,
          style: TextStyle(
            color: context.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        onTap: () => _showCategoryDialog(context, ref, existing: category),
        trailing: IconButton(
          onPressed: () async {
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
          icon: Icon(AppIcons.trash, color: _red(context), size: 20),
          tooltip: 'Delete',
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 10),
      child: Text(
        label,
        style: TextStyle(
          color: context.textSecondary,
          fontSize: AppFontSizes.label,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.3,
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

class _CategoryTypeSegment extends StatelessWidget {
  const _CategoryTypeSegment({required this.selected, required this.onChanged});

  final TransactionType selected;
  final ValueChanged<TransactionType> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<TransactionType>(
        showSelectedIcon: false,
        segments: const [
          ButtonSegment(
            value: TransactionType.expense,
            label: Text('Expense'),
          ),
          ButtonSegment(
            value: TransactionType.income,
            label: Text('Income'),
          ),
          ButtonSegment(
            value: TransactionType.investment,
            label: Text('Investment'),
          ),
        ],
        selected: {selected},
        onSelectionChanged: (value) => onChanged(value.first),
        style: SegmentedButton.styleFrom(
          foregroundColor: context.textSecondary,
          selectedForegroundColor: Theme.of(context).colorScheme.onPrimary,
          backgroundColor: context.surface,
          selectedBackgroundColor: Theme.of(context).colorScheme.primary,
          side: BorderSide(color: context.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
        ),
      ),
    );
  }
}
