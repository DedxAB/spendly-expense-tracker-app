import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spendly/core/constants/app_constants.dart';
import 'package:spendly/core/constants/app_enums.dart';
import 'package:spendly/core/theme/app_date_picker_theme.dart';
import 'package:spendly/core/theme/app_design_tokens.dart';
import 'package:spendly/core/theme/app_icons.dart';
import 'package:spendly/core/theme/app_typography.dart';
import 'package:spendly/core/utils/money.dart';
import 'package:spendly/core/widgets/app_modal_surface.dart';
import 'package:spendly/features/categories/domain/entities/category_entity.dart';
import 'package:spendly/features/categories/presentation/providers/categories_provider.dart';
import 'package:spendly/features/transactions/domain/entities/transaction_entity.dart';
import 'package:spendly/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:uuid/uuid.dart';

Future<void> showAddExpenseSheet(
  BuildContext context, {
  TransactionEntity? existing,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: false,
    backgroundColor: Colors.transparent,
    builder: (_) => AddExpenseSheet(existing: existing),
  );
}

class AddTransactionPage extends StatelessWidget {
  const AddTransactionPage({super.key, this.existing, this.initialType});

  final TransactionEntity? existing;
  final TransactionType? initialType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const Expanded(child: SizedBox()),
            AddExpenseSheet(
              existing: existing,
              initialType: initialType,
              embedded: true,
            ),
          ],
        ),
      ),
    );
  }
}

class AddExpenseSheet extends ConsumerStatefulWidget {
  const AddExpenseSheet({
    super.key,
    this.existing,
    this.initialType,
    this.embedded = false,
  });

  final TransactionEntity? existing;
  final TransactionType? initialType;
  final bool embedded;

  @override
  ConsumerState<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends ConsumerState<AddExpenseSheet> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  late TransactionType _type;
  PaymentMode _account = PaymentMode.upi;
  CardType? _cardType;
  DateTime _date = DateTime.now();
  String? _selectedCategoryId;
  bool _formAttempted = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _type = existing.type;
      _account = existing.paymentMode;
      _cardType = existing.cardType;
      _date = existing.date;
      _selectedCategoryId = existing.categoryId;
      _amountController.text = existing.amount.toStringAsFixed(2);
      _noteController.text = existing.note ?? '';
    } else {
      _type = widget.initialType ?? TransactionType.expense;
      _cardType = _type != TransactionType.income ? CardType.debit : null;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save(List<CategoryEntity> categories) async {
    setState(() => _formAttempted = true);
    final amount = Money.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0 || _selectedCategoryId == null) {
      return;
    }

    final now = DateTime.now();

    final entity = TransactionEntity(
      id: widget.existing?.id ?? const Uuid().v4(),
      type: _type,
      amount: amount,
      categoryId: _selectedCategoryId!,
      paymentMode: _account,
      cardType: _type != TransactionType.income && _account == PaymentMode.card
          ? _cardType
          : null,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      date: _date,
      createdAt: widget.existing?.createdAt ?? now,
      updatedAt: now,
      recurringRuleId: widget.existing?.recurringRuleId,
      isRecurringInstance: widget.existing?.isRecurringInstance ?? false,
      isDeleted: false,
    );

    if (widget.existing == null) {
      await ref.read(transactionActionsProvider).save(entity);
    } else {
      await ref.read(transactionActionsProvider).update(entity);
    }

    HapticFeedback.selectionClick();

    if (!mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    final navigator = Navigator.of(context);

    if (!widget.embedded) {
      navigator.pop();
    } else {
      navigator.maybePop();
    }

    // Show feedback without reading inherited widgets from a deactivated context.
    messenger?.showSnackBar(
      SnackBar(
        content: Text(
          widget.existing == null ? 'Transaction added' : 'Transaction updated',
        ),
        action: widget.existing == null
            ? SnackBarAction(
                label: 'Undo',
                onPressed: () =>
                    ref.read(transactionActionsProvider).softDelete(entity.id),
              )
            : null,
      ),
    );
  }

  Future<void> _pickDate() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
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
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryByTypeProvider(_type.value));

    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: const TextScaler.linear(1)),
      child: AppModalSurface(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.mdPlus,
            AppSpacing.xs,
            AppSpacing.mdPlus,
            MediaQuery.of(context).viewInsets.bottom + 100,
          ),
          child: categoriesAsync.when(
            data: (categories) {
              if (categories.isNotEmpty && _selectedCategoryId == null) {
                _selectedCategoryId = categories.first.id;
              }

              return ListView(
                shrinkWrap: true,
                children: [
                  Center(
                    child: Container(
                      width: 76,
                      height: 5,
                      decoration: BoxDecoration(
                        color: context.textSecondary,
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.existing == null
                              ? 'Add Transaction'
                              : 'Edit Transaction',
                          style: AppTypography.sectionTitle(context),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: Icon(
                          AppIcons.close,
                          color: context.textPrimary,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const _SheetLabel('AMOUNT', required: true),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _amountController,
                    autofocus: widget.existing == null,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      prefixText: '${AppConstants.currencySymbol} ',
                      prefixStyle: TextStyle(
                        color: context.textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      hintStyle: TextStyle(
                        color: context.textSecondary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 13,
                      ),
                    ),
                  ),
                  if (_formAttempted && (Money.tryParse(_amountController.text.trim()) == null ||
                      Money.tryParse(_amountController.text.trim())! <= 0))
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text(
                        'Enter a valid amount',
                        style: TextStyle(color: Color(0xFFF55C5C), fontSize: 11),
                      ),
                    ),
                  const SizedBox(height: 14),
                  Divider(color: context.border, height: 1),
                  const SizedBox(height: 22),
                  const _SheetLabel('TYPE'),
                  const SizedBox(height: 12),
                  _TypeSegment(
                    selected: _type,
                    onChanged: (value) => setState(() {
                      _type = value;
                      _selectedCategoryId = null;
                      if (value == TransactionType.income) {
                        _cardType = null;
                      } else if (_account == PaymentMode.card &&
                          _cardType == null) {
                        _cardType = CardType.debit;
                      }
                    }),
                  ),
                  const SizedBox(height: 22),
                  const _SheetLabel('CATEGORY', required: true),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ...categories.map(
                          (c) => Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: _SheetChoiceChip(
                              label: c.name,
                              selected: _selectedCategoryId == c.id,
                              onTap: () =>
                                  setState(() => _selectedCategoryId = c.id),
                            ),
                          ),
                        ),
                        _SheetChoiceChip(
                          label: '+',
                          selected: false,
                          onTap: () => context.push('/categories'),
                          compact: true,
                        ),
                      ],
                    ),
                  ),
                  if (_formAttempted && _selectedCategoryId == null)
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text(
                        'Select a category',
                        style: TextStyle(color: Color(0xFFF55C5C), fontSize: 11),
                      ),
                    ),
                  const SizedBox(height: 22),
                  const _SheetLabel('PAYMENT MODE'),
                  const SizedBox(height: 12),
                  _AccountSegment(
                    selected: _account,
                    onChanged: (value) => setState(() {
                      _account = value;
                      if (value == PaymentMode.card &&
                          _type != TransactionType.income &&
                          _cardType == null) {
                        _cardType = CardType.debit;
                      }
                    }),
                  ),
                  if (_type != TransactionType.income &&
                      _account == PaymentMode.card) ...[
                    const SizedBox(height: 12),
                    const _SheetLabel('CARD TYPE'),
                    const SizedBox(height: 12),
                    _CardTypeSegment(
                      selected: _cardType,
                      onChanged: (value) => setState(() => _cardType = value),
                    ),
                  ],
                  const SizedBox(height: 22),
                  const _SheetLabel('DATE'),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: _pickDate,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        border: Border.all(color: context.border),
                        borderRadius: BorderRadius.circular(AppRadii.md),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              MaterialLocalizations.of(
                                context,
                              ).formatMediumDate(_date),
                              style: TextStyle(
                                color: context.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Icon(
                            AppIcons.calendar,
                            color: context.textSecondary,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const _SheetLabel('NOTE (OPTIONAL)'),
                  const SizedBox(height: 10),
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      border: Border.all(color: context.border),
                    ),
                    alignment: Alignment.center,
                    child: TextField(
                      controller: _noteController,
                      maxLines: 1,
                      style: TextStyle(color: context.textPrimary, fontSize: 16),
                      decoration: InputDecoration(
                        filled: false,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        hintText: 'What was this for?',
                        hintStyle: TextStyle(
                          color: context.textSecondary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        border: InputBorder.none,
                        isCollapsed: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 14),
                      ),
                    ),
                  ),
                  Divider(color: context.border, height: 1),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 54,
                    child: FilledButton(
                      onPressed: () => _save(categories),
                      child: Text(
                        widget.existing == null
                            ? _saveButtonLabel(_type)
                            : _updateButtonLabel(_type),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ),
                  if (widget.embedded) const SizedBox(height: 8),
                ],
              );
            },
            loading: () => const SizedBox(
              height: 180,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => SizedBox(
              height: 100,
              child: Center(child: Text('Failed to load categories: $error')),
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetLabel extends StatelessWidget {
  const _SheetLabel(this.text, {this.required = false});

  final String text;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          text,
          style: TextStyle(
            color: context.textSecondary,
            fontSize: 12,
            letterSpacing: 1.6,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (required)
          const Padding(
            padding: EdgeInsets.only(left: 4),
            child: Text(
              '*',
              style: TextStyle(
                color: Color(0xFFF55C5C),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}

class _SheetChoiceChip extends StatelessWidget {
  const _SheetChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.compact = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(
          minWidth: compact ? 52 : 110,
          minHeight: 48,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? context.textPrimary : context.surface,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(
            color: selected ? context.textPrimary : context.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? context.surface : context.textPrimary,
            fontSize: 13,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _AccountSegment extends StatelessWidget {
  const _AccountSegment({required this.selected, required this.onChanged});

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
        border: Border.all(color: context.border),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Row(
          children: List.generate(items.length, (index) {
          final item = items[index];
          return Expanded(
            child: InkWell(
              onTap: () => onChanged(item.$1),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: selected == item.$1 ? context.textPrimary : context.surface,
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
                    color: selected == item.$1 ? context.surface : context.textPrimary,
                    fontSize: 13,
                    letterSpacing: 0,
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

class _CardTypeSegment extends StatelessWidget {
  const _CardTypeSegment({required this.selected, required this.onChanged});

  final CardType? selected;
  final ValueChanged<CardType> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = const [
      (CardType.debit, 'Debit'),
      (CardType.credit, 'Credit'),
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
                    letterSpacing: 0,
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

class _TypeSegment extends StatelessWidget {
  const _TypeSegment({required this.selected, required this.onChanged});

  final TransactionType selected;
  final ValueChanged<TransactionType> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = const [
      (TransactionType.expense, 'Expense'),
      (TransactionType.income, 'Income'),
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
          return Expanded(
            child: InkWell(
              onTap: () => onChanged(item.$1),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: selected == item.$1 ? context.textPrimary : context.surface,
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
                    color: selected == item.$1 ? context.surface : context.textPrimary,
                    fontSize: 13,
                    letterSpacing: 0,
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

String _saveButtonLabel(TransactionType type) {
  switch (type) {
    case TransactionType.income:
      return 'Save income';
    case TransactionType.investment:
      return 'Save investment';
    case TransactionType.expense:
      return 'Save expense';
  }
}

String _updateButtonLabel(TransactionType type) {
  switch (type) {
    case TransactionType.income:
      return 'Update income';
    case TransactionType.investment:
      return 'Update investment';
    case TransactionType.expense:
      return 'Update expense';
  }
}
