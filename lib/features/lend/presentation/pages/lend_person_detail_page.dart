import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:spendly/core/constants/app_enums.dart';
import 'package:spendly/core/widgets/app_confirm_dialog.dart';
import 'package:spendly/core/theme/app_icons.dart';
import 'package:spendly/core/theme/app_date_picker_theme.dart';
import 'package:spendly/core/theme/app_design_tokens.dart';
import 'package:spendly/core/theme/app_typography.dart';
import 'package:spendly/core/utils/formatters.dart';
import 'package:spendly/core/utils/money.dart';
import 'package:spendly/core/widgets/dialog_actions_row.dart';
import 'package:spendly/core/widgets/noir_header.dart';
import 'package:spendly/core/widgets/swipe_actions_info_button.dart';
import 'package:spendly/features/lend/data/repositories/lend_repository_impl.dart';
import 'package:spendly/features/lend/domain/entities/lend_entry_entity.dart';
import 'package:spendly/features/lend/presentation/providers/lend_provider.dart';

class LendPersonDetailPage extends ConsumerWidget {
  const LendPersonDetailPage({super.key, required this.personId});

  final String personId;
  static final DateFormat _settledDateFmt = DateFormat('dd MMM');

  Future<void> _confirmDeletePerson(
    BuildContext context,
    WidgetRef ref, {
    required String personName,
  }) async {
    final shouldDelete = await showAppDeleteConfirmDialog(
      context,
      title: 'Delete person?',
      message: 'Delete $personName and all related lend/borrow entries?',
    );
    if (!shouldDelete) return;
    await ref.read(lendRepositoryProvider).deletePerson(personId);
    if (context.mounted) {
      context.go('/lend');
    }
  }

  Future<DateTime?> _pickSettlementDate(
    BuildContext context,
    DateTime initialDate,
  ) async {
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      builder: (context, child) {
        final base = Theme.of(context);
        return Theme(
          data: base.copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.white,
              onPrimary: Colors.black,
              surface: Color(0xFF0E0E0E),
              onSurface: Colors.white,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Color(0xFF0E0E0E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            datePickerTheme: AppDatePickerTheme.darkBoxy(),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
  }

  Future<void> _showSettleDialog(
    BuildContext context,
    WidgetRef ref, {
    required String entryId,
    required double remainingAmount,
  }) async {
    final amountController = TextEditingController(
      text: remainingAmount.toStringAsFixed(2),
    );
    var selectedDate = DateTime.now();
    var formAttempted = false;

    await showDialog<void>(
      context: context,
      builder: (_) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Colors.white,
            onPrimary: Colors.black,
            surface: Color(0xFF0E0E0E),
            onSurface: Colors.white,
          ),
          inputDecorationTheme: const InputDecorationTheme(
            filled: false,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: Color(0xFF2E2E2E)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: Color(0xFF2E2E2E)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: Color(0xFFE0E0E0)),
            ),
          ),
          dialogTheme: const DialogThemeData(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            backgroundColor: Color(0xFF0E0E0E),
          ),
        ),
        child: StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Settle Amount'),
            content: SizedBox(
              width: AppModalSizes.dialogContentWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _ModalFieldLabel('Amount', required_: true),
                  const SizedBox(height: 6),
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      helperText:
                          'Remaining ${Formatters.currency(remainingAmount)}',
                    ),
                  ),
                  if (formAttempted && amountController.text.trim().isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        'Amount is required',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.sm),
                  const _ModalFieldLabel('Settlement Date'),
                  const SizedBox(height: 4),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(Formatters.date(selectedDate)),
                    trailing: const Icon(Icons.calendar_month),
                    onTap: () async {
                      final picked = await _pickSettlementDate(
                        context,
                        selectedDate,
                      );
                      if (picked != null) {
                        setState(() => selectedDate = picked);
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              DialogActionsRow(
                cancelText: 'Cancel',
                confirmText: 'Settle',
                onCancel: () => Navigator.pop(context),
                onConfirm: () async {
                  formAttempted = true;
                  setState(() {});
                  final amount = Money.tryParse(amountController.text.trim());
                  if (amount == null || amount <= 0) return;
                  await ref
                      .read(lendRepositoryProvider)
                      .applySettlement(
                        entryId: entryId,
                        amount: amount,
                        settledAt: selectedDate,
                      );
                  if (context.mounted) Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showEntryDialog(
    BuildContext context,
    WidgetRef ref, {
    LendEntryEntity? existing,
  }) async {
    final amountController = TextEditingController(
      text: existing == null ? '' : existing.amount.toStringAsFixed(2),
    );
    final noteController = TextEditingController(text: existing?.note ?? '');
    var selectedType = existing?.type ?? LendEntryType.lent;
    var selectedDate = existing?.date ?? DateTime.now();
    final isEditing = existing != null;
    var formAttempted = false;

    try {
      await showDialog<void>(
        context: context,
        builder: (_) => Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.white,
              onPrimary: Colors.black,
              surface: Color(0xFF0E0E0E),
              onSurface: Colors.white,
            ),
            inputDecorationTheme: const InputDecorationTheme(
              filled: false,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: Color(0xFF2E2E2E)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: Color(0xFF2E2E2E)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: Color(0xFFBDBDBD)),
              ),
            ),
            dialogTheme: const DialogThemeData(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              backgroundColor: Color(0xFF0E0E0E),
            ),
            segmentedButtonTheme: SegmentedButtonThemeData(
              style: ButtonStyle(
                side: const WidgetStatePropertyAll(
                  BorderSide(color: Color(0xFF4A4A4A)),
                ),
                shape: const WidgetStatePropertyAll(
                  RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
                foregroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return Colors.black;
                  }
                  return Colors.white;
                }),
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return Colors.white;
                  }
                  return Colors.black;
                }),
              ),
            ),
          ),
          child: StatefulBuilder(
            builder: (context, setState) => AlertDialog(
              title: Text(
                isEditing ? 'Edit Entry' : 'Add Entry',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              content: SizedBox(
                width: AppModalSizes.dialogContentWidth,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _ModalFieldLabel('Entry Type'),
                      const SizedBox(height: 6),
                      SegmentedButton<LendEntryType>(
                        showSelectedIcon: false,
                        segments: const [
                          ButtonSegment(
                            value: LendEntryType.lent,
                            label: Text('Lent'),
                          ),
                          ButtonSegment(
                            value: LendEntryType.borrowed,
                            label: Text('Borrowed'),
                          ),
                        ],
                        selected: {selectedType},
                        onSelectionChanged: (value) {
                          setState(() => selectedType = value.first);
                        },
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const _ModalFieldLabel('Amount', required_: true),
                      const SizedBox(height: 6),
                      TextField(
                        controller: amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          prefixText: '\u20B9 ',
                          hintText: '0.00',
                        ),
                      ),
                      if (formAttempted && amountController.text.trim().isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text(
                            'Amount is required',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      const SizedBox(height: AppSpacing.sm),
                      const _ModalFieldLabel('Note (optional)'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: noteController,
                        decoration: const InputDecoration(hintText: 'Add note'),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const _ModalFieldLabel('Date'),
                      const SizedBox(height: 4),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(Formatters.date(selectedDate)),
                        trailing: const Icon(Icons.calendar_month),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now().add(
                              const Duration(days: 3650),
                            ),
                            builder: (context, child) {
                              final base = Theme.of(context);
                              return Theme(
                                data: base.copyWith(
                                  colorScheme: const ColorScheme.dark(
                                    primary: Colors.white,
                                    onPrimary: Colors.black,
                                    surface: Color(0xFF0E0E0E),
                                    onSurface: Colors.white,
                                  ),
                                  dialogTheme: const DialogThemeData(
                                    backgroundColor: Color(0xFF0E0E0E),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero,
                                    ),
                                  ),
                                  datePickerTheme:
                                      AppDatePickerTheme.darkBoxy(),
                                  textButtonTheme: TextButtonThemeData(
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.zero,
                                      ),
                                    ),
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            setState(() => selectedDate = picked);
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
                  confirmText: isEditing ? 'Save' : 'Add',
                  onCancel: () => Navigator.pop(context),
                  onConfirm: () async {
                    formAttempted = true;
                    setState(() {});
                    final amount = Money.tryParse(amountController.text.trim());
                    if (amount == null || amount <= 0) return;
                    final repository = ref.read(lendRepositoryProvider);
                    if (isEditing) {
                      await repository.updateEntry(
                        entryId: existing.id,
                        personId: personId,
                        type: selectedType,
                        amount: amount,
                        date: selectedDate,
                        note: noteController.text.trim(),
                      );
                    } else {
                      await repository.addEntry(
                        personId: personId,
                        type: selectedType,
                        amount: amount,
                        date: selectedDate,
                        note: noteController.text.trim(),
                      );
                    }
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      );
    } finally {
      amountController.dispose();
      noteController.dispose();
    }
  }

  Future<bool> _deleteEntry(
    BuildContext context,
    WidgetRef ref, {
    required String entryId,
    required String title,
  }) async {
    final shouldDelete = await showAppDeleteConfirmDialog(
      context,
      title: 'Delete entry?',
      message: 'Delete this $title entry and its settlements?',
    );
    if (!shouldDelete) return false;
    await ref.read(lendRepositoryProvider).deleteEntry(entryId);
    return true;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final people = ref.watch(lendPeopleProvider).valueOrNull ?? const [];
    final personMatches = people.where((p) => p.id == personId);
    final person = personMatches.isEmpty ? null : personMatches.first;
    final entriesAsync = ref.watch(lendEntriesByPersonProvider(personId));
    final settlementEvents =
        ref.watch(lendSettlementEventsByPersonProvider(personId)).valueOrNull ??
        const [];

    final activeEntries =
        entriesAsync.valueOrNull
            ?.where((e) => !e.isDeleted && (e.amount - e.settledAmount) > 0)
            .toList(growable: false) ??
        const [];
    final net = activeEntries.fold<double>(0, (sum, e) {
      final remaining = (e.amount - e.settledAmount)
          .clamp(0, e.amount)
          .toDouble();
      if (e.type == LendEntryType.lent) return sum + remaining;
      return sum - remaining;
    });

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: NoirHeader(
        showLeading: true,
        leadingIcon: Icons.arrow_back,
        onLeadingTap: () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            context.go('/lend');
          }
        },
        showProfileAction: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.smPlus,
          AppSpacing.md,
          AppSpacing.smPlus,
          AppSpacing.md,
        ),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  person?.name ?? 'Person',
                  style: AppTypography.screenTitle(context),
                ),
              ),
              if (person != null)
                IconButton(
                  tooltip: 'Delete person',
                  onPressed: () => _confirmDeletePerson(
                    context,
                    ref,
                    personName: person.name,
                  ),
                  icon: Icon(
                    AppIcons.trash,
                    color: AppIcons.getColorForIcon(AppIcons.trash),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: const Color(0xFF0E0E0E),
              border: Border.all(color: AppColors.borderDark),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  person?.name ?? 'Unknown',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Net Balance',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFB0B0B0),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  Formatters.currency(net.abs()),
                  style: AppTypography.amount(
                    context,
                    fontSize: 20,
                    color: net >= 0 ? AppColors.income : AppColors.expense,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Text(
                  'History',
                  style: AppTypography.sectionTitle(context),
                ),
              ),
              const SwipeActionsInfoButton(
                tooltip: 'History swipe help',
                title: 'Entry actions',
                message: 'History entries can be swiped to edit or delete.',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          entriesAsync.when(
            data: (entries) {
              if (entries.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0E0E0E),
                    border: Border.all(color: AppColors.borderDark),
                  ),
                  child: const Text('No entries yet. Add your first entry.'),
                );
              }
              final active = entries
                  .where(
                    (e) => !e.isDeleted && (e.amount - e.settledAmount) > 0,
                  )
                  .toList(growable: false);
              final settled = entries
                  .where(
                    (e) => !e.isDeleted && (e.amount - e.settledAmount) <= 0,
                  )
                  .toList(growable: false);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (active.isNotEmpty) ...[
                    const Text(
                      'ACTIVE',
                      style: TextStyle(
                        fontSize: 12,
                        letterSpacing: 1.2,
                        color: Color(0xFFB0B0B0),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  ...active.map((entry) {
                    final isLent = entry.type == LendEntryType.lent;
                    final color = isLent ? AppColors.income : AppColors.expense;
                    final remaining = (entry.amount - entry.settledAmount)
                        .clamp(0, entry.amount)
                        .toDouble();
                    final isPartial = entry.settledAmount > 0 && remaining > 0;
                    final entryEvents = settlementEvents
                        .where(
                          (event) =>
                              event.entryId == entry.id && !event.isDeleted,
                        )
                        .toList(growable: false);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Dismissible(
                        key: ValueKey('lend-entry-${entry.id}'),
                        direction: DismissDirection.horizontal,
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.startToEnd) {
                            await _showEntryDialog(
                              context,
                              ref,
                              existing: entry,
                            );
                            return false;
                          }
                          return _deleteEntry(
                            context,
                            ref,
                            entryId: entry.id,
                            title: isLent ? 'lent' : 'borrowed',
                          );
                        },
                        background: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          color: const Color(0xFF11261B),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(AppIcons.edit, color: AppColors.income),
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
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          color: const Color(0xFF2A1313),
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
                              Icon(AppIcons.trash, color: AppColors.expense),
                            ],
                          ),
                        ),
                        child: _EntryCard(
                          title: isLent ? 'Lent' : 'Borrowed',
                          amount: entry.amount,
                          amountColor: color,
                          dateLabel:
                              '${Formatters.date(entry.date)}  Remaining ${Formatters.currency(remaining)}',
                          note: entry.note,
                          eventCount: entryEvents.isEmpty
                              ? null
                              : entryEvents.length,
                          eventChips: _buildEventChips(entryEvents),
                          leadingIcon: isLent
                              ? AppIcons.download
                              : AppIcons.upload,
                          leadingIconColor: color,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                borderRadius: BorderRadius.zero,
                                onTap: () async {
                                  await _showSettleDialog(
                                    context,
                                    ref,
                                    entryId: entry.id,
                                    remainingAmount: remaining,
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Icon(
                                    isPartial
                                        ? Icons.toll_outlined
                                        : Icons.add_circle_outline,
                                    size: 18,
                                    color: color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  if (settled.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    const Text(
                      'SETTLED',
                      style: TextStyle(
                        fontSize: 12,
                        letterSpacing: 1.2,
                        color: Color(0xFFB0B0B0),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  ...settled.map((entry) {
                    final isLent = entry.type == LendEntryType.lent;
                    final color = isLent ? AppColors.income : AppColors.expense;
                    final entryEvents = settlementEvents
                        .where(
                          (event) =>
                              event.entryId == entry.id && !event.isDeleted,
                        )
                        .toList(growable: false);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Dismissible(
                        key: ValueKey('lend-entry-${entry.id}'),
                        direction: DismissDirection.horizontal,
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.startToEnd) {
                            await _showEntryDialog(
                              context,
                              ref,
                              existing: entry,
                            );
                            return false;
                          }
                          return _deleteEntry(
                            context,
                            ref,
                            entryId: entry.id,
                            title: isLent ? 'lent' : 'borrowed',
                          );
                        },
                        background: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          color: const Color(0xFF11261B),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(AppIcons.edit, color: AppColors.income),
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
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          color: const Color(0xFF2A1313),
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
                              Icon(AppIcons.trash, color: AppColors.expense),
                            ],
                          ),
                        ),
                        child: _EntryCard(
                          title: isLent ? 'Lent' : 'Borrowed',
                          amount: entry.amount,
                          amountColor: color,
                          dateLabel: Formatters.date(entry.date),
                          note: entry.note,
                          eventCount: entryEvents.isEmpty
                              ? null
                              : entryEvents.length,
                          eventChips: _buildEventChips(entryEvents),
                          leadingIcon: isLent
                              ? AppIcons.download
                              : AppIcons.upload,
                          leadingIconColor: color,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: entry.isSettled
                                      ? Colors.white.withValues(alpha: 0.12)
                                      : color.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.zero,
                                ),
                                child: Text(
                                  entry.settledAt == null
                                      ? 'Settled'
                                      : 'Settled ${_settledDateFmt.format(entry.settledAt!)}',
                                  style: TextStyle(
                                    color: entry.isSettled
                                        ? Colors.white
                                        : color,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              InkWell(
                                borderRadius: BorderRadius.zero,
                                onTap: () async {
                                  await ref
                                      .read(lendRepositoryProvider)
                                      .clearSettlement(entry.id);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Icon(
                                    Icons.undo,
                                    size: 16,
                                    color: AppIcons.getColorForIcon(
                                      AppIcons.download,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text('Failed to load: $error'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: person == null ? null : () => _showEntryDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add entry'),
      ),
    );
  }
}

class _ModalFieldLabel extends StatelessWidget {
  const _ModalFieldLabel(this.label, {this.required_ = false});

  final String label;
  final bool required_;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: label,
        style: const TextStyle(
          color: Color(0xFFB3B3B3),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        children: required_
            ? const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
              ]
            : null,
      ),
    );
  }
}

List<Widget> _buildEventChips(List<dynamic> entryEvents) {
  if (entryEvents.isEmpty) return const [];
  return entryEvents
      .map(
        (event) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF303030)),
            color: const Color(0xFF0E0E0E),
            borderRadius: BorderRadius.zero,
          ),
          child: Text(
            '${DateFormat('dd MMM').format(event.date)} ${Formatters.currency(event.amount)}',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFFE0E0E0),
            ),
          ),
        ),
      )
      .toList(growable: false);
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({
    required this.title,
    required this.amount,
    required this.amountColor,
    required this.dateLabel,
    required this.leadingIcon,
    required this.leadingIconColor,
    required this.trailing,
    this.note,
    this.eventCount,
    this.eventChips = const [],
  });

  final String title;
  final double amount;
  final Color amountColor;
  final String dateLabel;
  final String? note;
  final int? eventCount;
  final List<Widget> eventChips;
  final IconData leadingIcon;
  final Color leadingIconColor;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: const Color(0xFF0E0E0E),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Icon(leadingIcon, size: 20, color: leadingIconColor),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      Formatters.currency(amount),
                      style: TextStyle(
                        color: amountColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  dateLabel,
                  style: const TextStyle(
                    color: Color(0xFFB5B5B5),
                    fontSize: 12,
                  ),
                ),
                if (note != null && note!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(note!, style: const TextStyle(fontSize: 12)),
                ],
                if (eventCount != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Settlements ($eventCount)',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFBDBDBD),
                    ),
                  ),
                ],
                if (eventChips.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(spacing: 6, runSpacing: 6, children: eventChips),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    );
  }
}
