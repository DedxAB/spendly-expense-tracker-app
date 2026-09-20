import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:spendly/core/constants/app_enums.dart';
import 'package:spendly/core/widgets/app_confirm_dialog.dart';
import 'package:spendly/core/widgets/app_toast.dart';
import 'package:spendly/core/theme/app_icons.dart';
import 'package:spendly/core/theme/app_design_tokens.dart';
import 'package:spendly/core/theme/app_typography.dart';
import 'package:spendly/core/utils/formatters.dart';
import 'package:spendly/core/utils/money.dart';
import 'package:spendly/core/widgets/amount_mask.dart';
import 'package:spendly/core/widgets/dialog_actions_row.dart';
import 'package:spendly/core/widgets/app_header.dart';
import 'package:spendly/core/widgets/swipe_actions_info_button.dart';
import 'package:spendly/core/widgets/swipe_hint_coach.dart';
import 'package:spendly/features/lend/domain/repositories/lend_repository.dart';
import 'package:spendly/features/lend/data/repositories/lend_repository_impl.dart';
import 'package:spendly/features/lend/domain/entities/lend_entry_entity.dart';
import 'package:spendly/features/lend/domain/entities/lend_settlement_event_entity.dart';
import 'package:spendly/features/lend/presentation/services/lend_export_service.dart';
import 'package:spendly/features/lend/presentation/providers/lend_provider.dart';

const _kLendGreen = Color(0xFF38D97A);
const _kLendRed = Color(0xFFFF5C6C);
const _kLendPurple = Color(0xFF8B5CF6);
const _kLendGreenTint = Color(0xFF0F2A1C);
const _kLendRedTint = Color(0xFF2A1313);
const _kLendGreenLight = Color(0xFF0E9C58);
const _kLendRedLight = Color(0xFFE03550);
const _kLendPurpleLight = Color(0xFF7157D8);
const _kLendGreenTintLight = Color(0xFFE7F7EE);
const _kLendRedTintLight = Color(0xFFFDE7EA);

bool _isDark(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;

Color _green(BuildContext context) =>
    _isDark(context) ? _kLendGreen : _kLendGreenLight;

Color _red(BuildContext context) =>
    _isDark(context) ? _kLendRed : _kLendRedLight;

Color _purple(BuildContext context) =>
    _isDark(context) ? _kLendPurple : _kLendPurpleLight;

Color _greenTint(BuildContext context) =>
    _isDark(context) ? _kLendGreenTint : _kLendGreenTintLight;

Color _redTint(BuildContext context) =>
    _isDark(context) ? _kLendRedTint : _kLendRedTintLight;

class LendPersonDetailPage extends ConsumerWidget {
  const LendPersonDetailPage({super.key, required this.personId});

  final String personId;
  static final DateFormat _settledDateFmt = DateFormat('dd MMM');

  Future<void> _confirmDeletePerson(
    BuildContext context,
    LendRepository repository, {
    required String personName,
  }) async {
    final shouldDelete = await showAppDeleteConfirmDialog(
      context,
      title: 'Delete person?',
      message: 'Delete $personName and all related lend/borrow entries?',
    );
    if (!shouldDelete) return;
    await repository.deletePerson(personId);
    if (context.mounted) {
      context.go('/lend');
    }
  }

  Future<void> _exportPdf(
    BuildContext context,
    WidgetRef ref,
    String personName,
    List<LendEntryEntity> entries,
    List<LendSettlementEventEntity> settlementEvents,
  ) async {
    final active = entries
        .where((e) => !e.isDeleted && (e.amount - e.settledAmount) > 0)
        .toList(growable: false);
    final totalLent = active
        .where((e) => e.type == LendEntryType.lent)
        .fold<double>(0, (sum, e) => sum + (e.amount - e.settledAmount).clamp(0, e.amount));
    final totalBorrowed = active
        .where((e) => e.type == LendEntryType.borrowed)
        .fold<double>(0, (sum, e) => sum + (e.amount - e.settledAmount).clamp(0, e.amount));
    final net = totalLent - totalBorrowed;

    try {
      await saveAndShareLendHistory(
        personName: personName,
        entries: entries,
        settlementEvents: settlementEvents,
        totalLent: totalLent,
        totalBorrowed: totalBorrowed,
        net: net,
      );
    } catch (_) {
      if (context.mounted) {
        showAppToast(context, 'Export failed', style: AppToastStyle.error);
      }
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
      builder: (context, child) => child!,
    );
  }

  Future<void> _showSettleDialog(
    BuildContext context,
    LendRepository repository, {
    required String entryId,
    required double remainingAmount,
  }) async {
    final amountController = TextEditingController(
      text: remainingAmount.toStringAsFixed(2),
    );
    var selectedDate = DateTime.now();
    var formAttempted = false;

    final settleResult = await showDialog<_SettleDialogResult>(
      context: context,
      builder: (_) => StatefulBuilder(
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
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Amount is required',
                        style: TextStyle(
                          color: _red(context),
                          fontSize: AppFontSizes.label,
                        ),
                      ),
                    ),
                  if (formAttempted &&
                      (Money.tryParse(amountController.text.trim()) ??
                              0) >
                          remainingAmount)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Amount cannot exceed the remaining '
                        '${Formatters.currency(remainingAmount)}',
                        style: TextStyle(
                          color: _red(context),
                          fontSize: AppFontSizes.label,
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.sm),
                  const _ModalFieldLabel('Settlement Date'),
                  const SizedBox(height: 4),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(Formatters.date(selectedDate)),
                    trailing: const Icon(AppIcons.calendar),
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
                onConfirm: () {
                  final amount = Money.tryParse(amountController.text.trim());
                  if (amount == null ||
                      amount <= 0 ||
                      amount > remainingAmount) {
                    formAttempted = true;
                    setState(() {});
                    return;
                  }
                  Navigator.pop(
                    context,
                    _SettleDialogResult(
                      amount: amount,
                      date: selectedDate,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
    );

    if (settleResult != null) {
      await repository.applySettlement(
        entryId: entryId,
        amount: settleResult.amount,
        settledAt: settleResult.date,
      );
    }
  }

  Future<void> _showEntryDialog(
    BuildContext context,
    LendRepository repository, {
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
      final result = await showDialog<_EntryDialogResult>(
        context: context,
        builder: (_) => StatefulBuilder(
            builder: (context, setState) => AlertDialog(
              title: Text(
                isEditing ? 'Edit Entry' : 'Add Entry',
                style: const TextStyle(
                  fontSize: AppFontSizes.largeHeading,
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
                      SizedBox(
                        width: AppModalSizes.dialogContentWidth,
                        child: SegmentedButton<LendEntryType>(
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
                          style: SegmentedButton.styleFrom(
                            foregroundColor: context.textSecondary,
                            selectedForegroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            backgroundColor: context.surface,
                            selectedBackgroundColor:
                                Theme.of(context).colorScheme.primary,
                            side: BorderSide(color: context.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadii.md),
                            ),
                          ),
                        ),
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
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Amount is required',
                            style: TextStyle(
                              color: _red(context),
                              fontSize: AppFontSizes.label,
                            ),
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
                        trailing: const Icon(AppIcons.calendar),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now().add(
                              const Duration(days: 3650),
                            ),
                            builder: (context, child) => child!,
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
                  onConfirm: () {
                    final amount = Money.tryParse(amountController.text.trim());
                    if (amount == null || amount <= 0) {
                      formAttempted = true;
                      setState(() {});
                      return;
                    }
                    Navigator.pop(
                      context,
                      _EntryDialogResult(
                        amount: amount,
                        note: noteController.text.trim(),
                        date: selectedDate,
                        type: selectedType,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
      );

      if (result != null) {
        if (isEditing) {
          await repository.updateEntry(
            entryId: existing.id,
            personId: personId,
            type: result.type,
            amount: result.amount,
            date: result.date,
            note: result.note,
          );
        } else {
          await repository.addEntry(
            personId: personId,
            type: result.type,
            amount: result.amount,
            date: result.date,
            note: result.note,
          );
        }
      }
    } finally {
      amountController.dispose();
      noteController.dispose();
    }
  }

  Future<bool> _deleteEntry(
    BuildContext context,
    LendRepository repository, {
    required String entryId,
    required String title,
  }) async {
    final shouldDelete = await showAppDeleteConfirmDialog(
      context,
      title: 'Delete entry?',
      message: 'Delete this $title entry and its settlements?',
    );
    if (!shouldDelete) return false;
    await repository.deleteEntry(entryId);
    return true;
  }

  Future<bool> _unsettleEntry(
    BuildContext context,
    LendRepository repository, {
    required String entryId,
  }) async {
    final shouldUnsettle = await showAppDeleteConfirmDialog(
      context,
      title: 'Unsettle entry?',
      message:
          'Mark this entry as active again and remove its settlement?',
      confirmText: 'Unsettle',
    );
    if (!shouldUnsettle) return false;
    await repository.clearSettlement(entryId);
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
    final totalLent = activeEntries
        .where((e) => e.type == LendEntryType.lent)
        .fold<double>(0, (sum, e) => sum + (e.amount - e.settledAmount).clamp(0, e.amount));
    final totalBorrowed = activeEntries
        .where((e) => e.type == LendEntryType.borrowed)
        .fold<double>(0, (sum, e) => sum + (e.amount - e.settledAmount).clamp(0, e.amount));

    return Scaffold(
      backgroundColor: context.background,
      appBar: AppHeader(
        mode: AppHeaderMode.back,
        onLeadingTap: () => Navigator.of(context).maybePop(),
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
              if (person != null) ...[
                IconButton(
                  tooltip: 'Export PDF',
                  onPressed: () => _exportPdf(context, ref, person.name, entriesAsync.valueOrNull ?? const [], settlementEvents),
                  icon: const Icon(AppIcons.download),
                ),
                IconButton(
                  tooltip: 'Delete person',
                  onPressed: () {
                    final repo = ref.read(lendRepositoryProvider);
                    _confirmDeletePerson(
                      context,
                      repo,
                      personName: person.name,
                    );
                  },
                  icon: Icon(AppIcons.trash, color: _red(context)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          _SummaryCard(
            totalLent: totalLent,
            totalBorrowed: totalBorrowed,
            net: net,
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
                return const _InlineEmpty(
                  icon: AppIcons.history,
                  message: 'No entries yet. Tap + to add a lend or borrow entry.',
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _greenTint(context),
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                      ),
child: Text(
                          'ACTIVE  \u00B7  ${active.length} pending',
                          style: TextStyle(
                            fontSize: AppFontSizes.caption,
                            letterSpacing: 0.8,
                            color: _green(context),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  ...active.indexed.map((entry) {
                    final index = entry.$1;
                    final entryData = entry.$2;
                    final isLent = entryData.type == LendEntryType.lent;
                    final color = isLent ? _green(context) : _red(context);
                    final remaining = (entryData.amount - entryData.settledAmount)
                        .clamp(0, entryData.amount)
                        .toDouble();
                    final entryEvents = settlementEvents
                        .where(
                          (event) =>
                              event.entryId == entryData.id &&
                              !event.isDeleted,
                        )
                        .toList(growable: false);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Dismissible(
                        key: ValueKey('lend-entry-${entryData.id}'),
                        direction: DismissDirection.horizontal,
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.startToEnd) {
                            final repo = ref.read(lendRepositoryProvider);
                            await _showEntryDialog(
                              context,
                              repo,
                              existing: entryData,
                            );
                            return false;
                          }
                          final repo = ref.read(lendRepositoryProvider);
                          return _deleteEntry(
                            context,
                            repo,
                            entryId: entryData.id,
                            title: isLent ? 'lent' : 'borrowed',
                          );
                        },
                        background: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          color: _greenTint(context),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(AppIcons.edit, color: _green(context)),
                              SizedBox(width: 8),
                              Text(
                                'EDIT',
                                style: TextStyle(
                                  color: _green(context),
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
                          color: _redTint(context),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'DELETE',
                                style: TextStyle(
                                  color: _red(context),
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(AppIcons.trash, color: _red(context)),
                            ],
                          ),
                        ),
                        child: SwipeHintCoach(
                          enabled: index == 0,
                          child: _EntryCard(
                          title: isLent ? 'Lent' : 'Borrowed',
                          amount: entryData.amount,
                          amountColor: color,
                          dateLabel: Formatters.date(entryData.date),
                          note: entryData.note,
                          eventChips: _buildEventChips(context, entryEvents),
                          leadingIcon: isLent
                              ? AppIcons.download
                              : AppIcons.upload,
                          leadingIconColor: color,
                          remainingAmount: remaining,
                          trailing: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {
                              final repo = ref.read(lendRepositoryProvider);
                              _showSettleDialog(
                                context,
                                repo,
                                entryId: entryData.id,
                                remainingAmount: remaining,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(AppIcons.plus, size: 13, color: color),
                                  const SizedBox(width: 3),
                                  Text(
                                    'Settle',
                                    style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.w700,
                                      fontSize: AppFontSizes.label,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        ),
                      ),
                    );
                  }),
                  if (settled.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      'SETTLED  \u00B7  ${settled.length} entries',
                      style: TextStyle(
                        fontSize: AppFontSizes.caption,
                        letterSpacing: 0.8,
                        color: context.textSecondary.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  ...settled.asMap().entries.map((entry) {
                    final index = entry.key;
                    final entryData = entry.value;
                    final isLent = entryData.type == LendEntryType.lent;
                    final color = isLent ? _green(context) : _red(context);
                    final entryEvents = settlementEvents
                        .where(
                          (event) =>
                              event.entryId == entryData.id && !event.isDeleted,
                        )
                        .toList(growable: false);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Dismissible(
                        key: ValueKey('lend-entry-${entryData.id}'),
                        direction: DismissDirection.horizontal,
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.startToEnd) {
                            final repo = ref.read(lendRepositoryProvider);
                            await _showEntryDialog(
                              context,
                              repo,
                              existing: entryData,
                            );
                            return false;
                          }
                          final repo = ref.read(lendRepositoryProvider);
                          return _deleteEntry(
                            context,
                            repo,
                            entryId: entryData.id,
                            title: isLent ? 'lent' : 'borrowed',
                          );
                        },
                        background: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          color: _greenTint(context),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(AppIcons.edit, color: _green(context)),
                              SizedBox(width: 8),
                              Text(
                                'EDIT',
                                style: TextStyle(
                                  color: _green(context),
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
                          color: _redTint(context),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'DELETE',
                                style: TextStyle(
                                  color: _red(context),
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(AppIcons.trash, color: _red(context)),
                            ],
                          ),
                        ),
                        child: SwipeHintCoach(
                          enabled: index == 0 && active.isEmpty,
                          child: _EntryCard(
                            title: isLent ? 'Lent' : 'Borrowed',
                            amount: entryData.amount,
                            amountColor: color,
                            dateLabel: Formatters.date(entryData.date),
                            note: entryData.note,
                            eventChips: _buildEventChips(context, entryEvents),
                            leadingIcon: isLent
                                ? AppIcons.download
                                : AppIcons.upload,
                            leadingIconColor: color,
                            isSettled: true,
                            settledLabel: entryData.settledAt == null
                                ? 'Settled'
                                : 'Settled ${_settledDateFmt.format(entryData.settledAt!)}',
                            trailing: IconButton(
                              style: IconButton.styleFrom(
                                backgroundColor: context.textPrimary.withValues(alpha: 0.06),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                minimumSize: const Size(32, 32),
                                padding: EdgeInsets.zero,
                              ),
                              icon: Icon(AppIcons.undo, size: 15, color: context.textSecondary),
                              onPressed: () {
                                final repo = ref.read(lendRepositoryProvider);
                                _unsettleEntry(
                                  context,
                                  repo,
                                  entryId: entryData.id,
                                );
                              },
                            ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: person == null
            ? null
            : () {
                final repo = ref.read(lendRepositoryProvider);
                _showEntryDialog(context, repo);
              },
        backgroundColor: context.textPrimary,
        foregroundColor: context.background,
        elevation: 0,
        shape: const CircleBorder(),
        child: const Icon(AppIcons.plus, size: 36),
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
        style: TextStyle(
          color: context.textSecondary,
          fontSize: AppFontSizes.label,
          fontWeight: FontWeight.w600,
        ),
        children: required_
            ? [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: _red(context)),
                ),
              ]
            : null,
      ),
    );
  }
}

class _EntryDialogResult {
  const _EntryDialogResult({
    required this.amount,
    required this.note,
    required this.date,
    required this.type,
  });

  final double amount;
  final String note;
  final DateTime date;
  final LendEntryType type;
}

class _SettleDialogResult {
  const _SettleDialogResult({required this.amount, required this.date});

  final double amount;
  final DateTime date;
}

List<Widget> _buildEventChips(BuildContext context, List<dynamic> entryEvents) {
  if (entryEvents.isEmpty) return const [];
  return entryEvents
      .map(
        (event) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: context.textPrimary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '${DateFormat('dd MMM').format(event.date)} ${Formatters.currency(event.amount)}',
            style: TextStyle(
              fontSize: AppFontSizes.caption,
              fontWeight: FontWeight.w600,
              color: context.textSecondary.withValues(alpha: 0.8),
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
    this.isSettled = false,
    this.settledLabel,
    this.remainingAmount,
    this.eventChips = const [],
  });

  final String title;
  final double amount;
  final Color amountColor;
  final String dateLabel;
  final String? note;
  final IconData leadingIcon;
  final Color leadingIconColor;
  final Widget trailing;
  final bool isSettled;
  final String? settledLabel;
  final double? remainingAmount;
  final List<Widget> eventChips;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surface,
        border: Border.all(color: context.border),
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MiniBadge(icon: leadingIcon, color: amountColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: context.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: AppFontSizes.subhead,
                            ),
                          ),
                          Expanded(
                            child: AmountView(
                              amount,
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                color: amountColor,
                                fontWeight: FontWeight.w800,
                                fontSize: AppFontSizes.heading,
                              ),
                              maskColor: amountColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(AppIcons.calendar, size: 11, color: context.textSecondary.withValues(alpha: 0.6)),
                          const SizedBox(width: 4),
                          Text(
                            dateLabel,
                            style: TextStyle(
                              color: context.textSecondary.withValues(alpha: 0.7),
                              fontSize: AppFontSizes.small,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (note != null && note!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  const SizedBox(width: 52),
                  Expanded(
                    child: Text(
                      note!,
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: AppFontSizes.label,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (eventChips.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  const SizedBox(width: 52),
                  Expanded(
                    child: Wrap(spacing: 6, runSpacing: 4, children: eventChips),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 4),
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 14),
            color: context.border.withValues(alpha: 0.25),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 6, 8),
            child: Row(
              children: [
                if (remainingAmount != null && !isSettled) ...[
                  Text(
                    'Remaining',
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: AppFontSizes.label,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 6),
                  AmountView(
                    remainingAmount!,
                    style: TextStyle(
                      color: amountColor,
                      fontWeight: FontWeight.w800,
                      fontSize: AppFontSizes.subhead,
                    ),
                    maskColor: amountColor,
                  ),
                  const Spacer(),
                ],
                if (isSettled && settledLabel != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.textPrimary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(AppIcons.checkCircle, size: 12, color: context.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          settledLabel!,
                          style: TextStyle(
                            color: context.textSecondary,
                            fontSize: AppFontSizes.caption,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                ],
                SizedBox(
                  height: 32,
                  child: trailing,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.totalLent,
    required this.totalBorrowed,
    required this.net,
  });

  final double totalLent;
  final double totalBorrowed;
  final double net;

  @override
  Widget build(BuildContext context) {
    final green = _green(context);
    final red = _red(context);
    final netColor = net >= 0 ? green : red;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.surface,
        border: Border.all(color: context.border),
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _MiniBadge(icon: AppIcons.download, color: green),
              const SizedBox(width: 10),
              Text('You Lent',
                style: TextStyle(
                  color: context.textSecondary,
                  fontSize: AppFontSizes.small,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  Formatters.currency(totalLent),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: green,
                    fontWeight: FontWeight.w700,
                    fontSize: AppFontSizes.title,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _MiniBadge(icon: AppIcons.upload, color: red),
              const SizedBox(width: 10),
              Text('You Borrowed',
                style: TextStyle(
                  color: context.textSecondary,
                  fontSize: AppFontSizes.small,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  Formatters.currency(totalBorrowed),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: red,
                    fontWeight: FontWeight.w700,
                    fontSize: AppFontSizes.title,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: context.border.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Net Balance',
                style: TextStyle(
                  color: context.textSecondary,
                  fontSize: AppFontSizes.label,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                net >= 0 ? AppIcons.trendingUp : AppIcons.trendingDown,
                size: 16,
                color: netColor,
              ),
              Expanded(
                child: Text(
                  Formatters.currency(net.abs()),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: netColor,
                    fontWeight: FontWeight.w800,
                    fontSize: AppFontSizes.heading,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({required this.icon, required this.color});
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 18, color: color),
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
