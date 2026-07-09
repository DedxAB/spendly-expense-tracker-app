import 'package:flutter/material.dart';
import 'package:spendly/core/theme/app_design_tokens.dart';
import 'package:spendly/core/theme/app_icons.dart';
import 'package:spendly/core/utils/formatters.dart';
import 'package:spendly/core/utils/money.dart';
import 'package:spendly/core/widgets/dialog_actions_row.dart';

class ContributorEditor extends StatelessWidget {
  const ContributorEditor({
    super.key,
    required this.contributors,
    required this.onChanged,
    required this.totalAmount,
    required this.includeSelf,
    required this.onIncludeSelfChanged,
    this.selfShare,
    required this.onSelfShareChanged,
  });

  final List<({String personName, double amount})> contributors;
  final ValueChanged<List<({String personName, double amount})>> onChanged;
  final double totalAmount;
  final bool includeSelf;
  final ValueChanged<bool> onIncludeSelfChanged;
  final double? selfShare;
  final ValueChanged<double> onSelfShareChanged;

  void _addPerson(BuildContext context) {
    final nameCtrl = TextEditingController();
    var attempted = false;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: const Text('Add Person'),
          content: SizedBox(
            width: AppModalSizes.dialogContentWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Person name',
                  ),
                ),
                if (attempted)
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Text(
                      'Enter a name',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: DialogActionsRow(
                cancelText: 'Cancel',
                confirmText: 'Add',
                onCancel: () => Navigator.pop(ctx),
                onConfirm: () {
                  final name = nameCtrl.text.trim();
                  if (name.isEmpty) {
                    attempted = true;
                    setDlgState(() {});
                    return;
                  }
                  Navigator.pop(ctx);
                  final updated = [
                    ...contributors,
                    (personName: name, amount: 0.0),
                  ];
                  _equalSplit(updated, totalAmount, includeSelf, onChanged);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _equalSplit(
    List<({String personName, double amount})> list,
    double total,
    bool includeSelf,
    ValueChanged<List<({String personName, double amount})>> onChanged,
  ) {
    if (list.isEmpty) return;
    final divisor = list.length + (includeSelf ? 1 : 0);
    if (divisor == 0) return;
    final share = total / divisor;
    onChanged(list.map((c) => (personName: c.personName, amount: share)).toList());
  }

  void _editSelfAmount(BuildContext context) {
    final current = selfShare ?? (totalAmount - contributors.fold<double>(0, (s, c) => s + c.amount));
    final ctrl = TextEditingController(text: current.toStringAsFixed(0));
    var attempted = false;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: const Text('Your share'),
          content: SizedBox(
            width: AppModalSizes.dialogContentWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: ctrl,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    hintText: 'Amount',
                    prefixText: '\u20B9 ',
                  ),
                ),
                if (attempted)
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Text(
                      'Enter a valid amount',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: DialogActionsRow(
                cancelText: 'Cancel',
                confirmText: 'Set',
                onCancel: () => Navigator.pop(ctx),
                onConfirm: () {
                  final amt = Money.tryParse(ctrl.text.trim());
                  if (amt == null || amt < 0) {
                    attempted = true;
                    setDlgState(() {});
                    return;
                  }
                  Navigator.pop(ctx);
                  onSelfShareChanged(amt);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editAmount(
    BuildContext context,
    int index,
    ({String personName, double amount}) current,
  ) {
    final ctrl = TextEditingController(text: current.amount.toStringAsFixed(0));
    var attempted = false;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: Text(current.personName),
          content: SizedBox(
            width: AppModalSizes.dialogContentWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: ctrl,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    hintText: 'Amount',
                    prefixText: '\u20B9 ',
                  ),
                ),
                if (attempted)
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Text(
                      'Enter a valid amount',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: DialogActionsRow(
                cancelText: 'Cancel',
                confirmText: 'Set',
                onCancel: () => Navigator.pop(ctx),
                onConfirm: () {
                  final amt = Money.tryParse(ctrl.text.trim());
                  if (amt == null || amt <= 0) {
                    attempted = true;
                    setDlgState(() {});
                    return;
                  }
                  Navigator.pop(ctx);
                  final updated = [...contributors];
                  updated[index] = (personName: current.personName, amount: amt);
                  onChanged(updated);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalShare = contributors.fold<double>(0, (sum, c) => sum + c.amount);
    final displaySelfShare = selfShare ?? (totalAmount - totalShare);
    final overage = totalShare + (includeSelf ? displaySelfShare : 0) > totalAmount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('SPLIT WITH', style: _labelStyle(context)),
            const Spacer(),
            GestureDetector(
              onTap: () => _addPerson(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.homeAccentPurple.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 12, color: AppColors.homeAccentPurple),
                    const SizedBox(width: 3),
                    Text(
                      'Add',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.homeAccentPurple,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (contributors.isEmpty)
          GestureDetector(
            onTap: () => _addPerson(context),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: context.border.withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_add_alt, size: 16, color: context.textSecondary.withValues(alpha: 0.6)),
                    const SizedBox(width: 6),
                    Text(
                      'Add people to split this expense',
                      style: TextStyle(
                        color: context.textSecondary.withValues(alpha: 0.6),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: context.surfaceAlt,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                  _PersonRow(
                    personName: 'You',
                    amount: displaySelfShare,
                    isSelf: true,
                    includeSelf: includeSelf,
                    index: -1,
                    onToggleSelf: () {
                      final newVal = !includeSelf;
                      onIncludeSelfChanged(newVal);
                      onSelfShareChanged(0);
                      _equalSplit(contributors, totalAmount, newVal, onChanged);
                    },
                    onTapAmount: includeSelf
                        ? () => _editSelfAmount(context)
                        : null,
                  ),
                ...contributors.asMap().entries.map((entry) {
                  final i = entry.key;
                  final c = entry.value;
                  return Column(
                    children: [
                      Divider(height: 1, color: context.border.withValues(alpha: 0.3), indent: 12, endIndent: 12),
                      _PersonRow(
                        personName: c.personName,
                        amount: c.amount,
                        isSelf: false,
                        includeSelf: false,
                        index: i,
                        onTapAmount: () => _editAmount(context, i, c),
                        onRemove: () {
                          final updated = [
                            ...contributors.sublist(0, i),
                            ...contributors.sublist(i + 1),
                          ];
                          if (updated.isEmpty) {
                            onChanged(updated);
                          } else {
                            _equalSplit(updated, totalAmount, includeSelf, onChanged);
                          }
                        },
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        if (overage) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, size: 12, color: const Color(0xFFF55C5C)),
              const SizedBox(width: 4),
              Text(
                'Shares exceed ${Formatters.currency(totalAmount)}',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFFF55C5C),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 6),
        Row(
          children: [
            const Spacer(),
            Text(
              'Total ${Formatters.currency(totalAmount)}',
              style: TextStyle(
                color: context.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PersonRow extends StatelessWidget {
  const _PersonRow({
    required this.personName,
    required this.amount,
    required this.isSelf,
    required this.includeSelf,
    required this.index,
    this.onTapAmount,
    this.onRemove,
    this.onToggleSelf,
  });

  final String personName;
  final double amount;
  final bool isSelf;
  final bool includeSelf;
  final int index;
  final VoidCallback? onTapAmount;
  final VoidCallback? onRemove;
  final VoidCallback? onToggleSelf;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: isSelf ? onToggleSelf : null,
            child: Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: isSelf
                    ? (includeSelf
                        ? AppColors.homeAccentGreen.withValues(alpha: 0.12)
                        : context.textPrimary.withValues(alpha: 0.06))
                    : AppColors.homeAccentPurple.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isSelf ? Icons.person : Icons.person_outline,
                size: 16,
                color: isSelf
                    ? (includeSelf ? AppColors.homeAccentGreen : context.textSecondary)
                    : AppColors.homeAccentPurple,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: isSelf ? onToggleSelf : null,
              child: Text(
                personName,
                style: TextStyle(
                  color: isSelf && !includeSelf
                      ? context.textSecondary.withValues(alpha: 0.5)
                      : context.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          if (isSelf && !includeSelf)
            GestureDetector(
              onTap: onToggleSelf,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  border: Border.all(color: context.border.withValues(alpha: 0.4)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Include me',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: context.textSecondary,
                  ),
                ),
              ),
            ),
          if (isSelf && includeSelf)
            GestureDetector(
              onTap: onTapAmount,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.homeAccentGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  Formatters.currency(amount),
                  style: TextStyle(
                    color: AppColors.homeAccentGreen,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          if (!isSelf) ...[
            GestureDetector(
              onTap: onTapAmount,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: context.textPrimary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  Formatters.currency(amount),
                  style: TextStyle(
                    color: context.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onRemove,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  AppIcons.close,
                  size: 16,
                  color: context.textSecondary.withValues(alpha: 0.5),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

TextStyle _labelStyle(BuildContext context) {
  return TextStyle(
    color: context.textSecondary,
    fontSize: AppFontSizes.small,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
  );
}
