import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:spendly/core/constants/app_enums.dart';
import 'package:spendly/core/widgets/app_confirm_dialog.dart';
import 'package:spendly/core/theme/app_design_tokens.dart';
import 'package:spendly/core/theme/app_typography.dart';
import 'package:spendly/core/utils/formatters.dart';
import 'package:spendly/core/utils/money.dart';
import 'package:spendly/core/widgets/dialog_actions_row.dart';
import 'package:spendly/core/widgets/glass_card.dart';
import 'package:spendly/core/widgets/noir_header.dart';
import 'package:spendly/features/lend/data/repositories/lend_repository_impl.dart';
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

  Widget _buildSettlementHistoryRow(List<dynamic> entryEvents) {
    if (entryEvents.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: entryEvents
            .map((event) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF303030)),
                  color: const Color(0xFF0E0E0E),
                  borderRadius: BorderRadius.zero,
                ),
                child: Text(
                  '${_settledDateFmt.format(event.date)} ${Formatters.currency(event.amount)}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE0E0E0),
                  ),
                ),
              );
            })
            .toList(growable: false),
      ),
    );
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
            datePickerTheme: DatePickerThemeData(
              backgroundColor: const Color(0xFF0E0E0E),
              surfaceTintColor: Colors.transparent,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              headerBackgroundColor: const Color(0xFF0E0E0E),
              headerForegroundColor: Colors.white,
              dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) return Colors.white;
                return Colors.transparent;
              }),
              dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) return Colors.black;
                return Colors.white;
              }),
              dayOverlayColor: const WidgetStatePropertyAll(Colors.transparent),
              dayStyle: const TextStyle(fontWeight: FontWeight.w600),
              todayForegroundColor: const WidgetStatePropertyAll(Colors.white),
              todayBorder: const BorderSide(color: Color(0xFF4A4A4A)),
              todayBackgroundColor: const WidgetStatePropertyAll(
                Colors.transparent,
              ),
              yearForegroundColor: const WidgetStatePropertyAll(Colors.white),
              rangeSelectionBackgroundColor: const Color(0xFF1E1E1E),
              dividerColor: const Color(0xFF2A2A2A),
              dayShape: const WidgetStatePropertyAll(
                RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              yearShape: const WidgetStatePropertyAll(
                RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
            ),
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
        child: AlertDialog(
          title: const Text('Settle Amount'),
          content: SizedBox(
            width: AppModalSizes.dialogContentWidth,
            child: StatefulBuilder(
              builder: (context, setState) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _ModalFieldLabel('Amount'),
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
          ),
          actions: [
            DialogActionsRow(
              cancelText: 'Cancel',
              confirmText: 'Settle',
              onCancel: () => Navigator.pop(context),
              onConfirm: () async {
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
    );
  }

  Future<void> _showAddEntryDialog(BuildContext context, WidgetRef ref) async {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    var selectedType = LendEntryType.lent;
    var selectedDate = DateTime.now();

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
                if (states.contains(WidgetState.selected)) return Colors.black;
                return Colors.white;
              }),
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) return Colors.white;
                return Colors.black;
              }),
            ),
          ),
        ),
        child: StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text(
              'Add Entry',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
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
                    const _ModalFieldLabel('Amount'),
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
                                datePickerTheme: DatePickerThemeData(
                                  backgroundColor: const Color(0xFF0E0E0E),
                                  surfaceTintColor: Colors.transparent,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                  ),
                                  headerBackgroundColor: const Color(
                                    0xFF0E0E0E,
                                  ),
                                  headerForegroundColor: Colors.white,
                                  dayBackgroundColor:
                                      WidgetStateProperty.resolveWith((states) {
                                        if (states.contains(
                                          WidgetState.selected,
                                        )) {
                                          return Colors.white;
                                        }
                                        return Colors.transparent;
                                      }),
                                  dayForegroundColor:
                                      WidgetStateProperty.resolveWith((states) {
                                        if (states.contains(
                                          WidgetState.selected,
                                        )) {
                                          return Colors.black;
                                        }
                                        return Colors.white;
                                      }),
                                  dayOverlayColor: const WidgetStatePropertyAll(
                                    Colors.transparent,
                                  ),
                                  dayStyle: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  todayForegroundColor:
                                      const WidgetStatePropertyAll(
                                        Colors.white,
                                      ),
                                  todayBorder: const BorderSide(
                                    color: Color(0xFF4A4A4A),
                                  ),
                                  todayBackgroundColor:
                                      const WidgetStatePropertyAll(
                                        Colors.transparent,
                                      ),
                                  yearForegroundColor:
                                      const WidgetStatePropertyAll(
                                        Colors.white,
                                      ),
                                  rangeSelectionBackgroundColor: const Color(
                                    0xFF1E1E1E,
                                  ),
                                  dividerColor: const Color(0xFF2A2A2A),
                                  dayShape: const WidgetStatePropertyAll(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero,
                                    ),
                                  ),
                                  yearShape: const WidgetStatePropertyAll(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero,
                                    ),
                                  ),
                                ),
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
                confirmText: 'Save',
                onCancel: () => Navigator.pop(context),
                onConfirm: () async {
                  final amount = Money.tryParse(amountController.text.trim());
                  if (amount == null || amount <= 0) return;
                  await ref
                      .read(lendRepositoryProvider)
                      .addEntry(
                        personId: personId,
                        type: selectedType,
                        amount: amount,
                        date: selectedDate,
                        note: noteController.text.trim(),
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
                  icon: const Icon(Icons.delete_outline),
                ),
            ],
          ),
          const SizedBox(height: 10),
          GlassCard(
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
          Text('History', style: AppTypography.sectionTitle(context)),
          const SizedBox(height: AppSpacing.xs),
          entriesAsync.when(
            data: (entries) {
              if (entries.isEmpty) {
                return const GlassCard(
                  child: Text('No entries yet. Add your first entry.'),
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
                      child: GlassCard(
                        padding: EdgeInsets.zero,
                        child: ListTile(
                          title: Text(
                            '${isLent ? 'Lent' : 'Borrowed'} ${Formatters.currency(entry.amount)}',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${Formatters.date(entry.date)} - Remaining ${Formatters.currency(remaining)}',
                              ),
                              if (entry.note != null && entry.note!.isNotEmpty)
                                Text(
                                  entry.note!,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              if (entryEvents.isNotEmpty)
                                Text(
                                  'Settlements (${entryEvents.length})',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFBDBDBD),
                                  ),
                                ),
                              _buildSettlementHistoryRow(entryEvents),
                            ],
                          ),
                          trailing: SizedBox(
                            width: 84,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
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
                      child: GlassCard(
                        padding: EdgeInsets.zero,
                        child: ListTile(
                          title: Text(
                            '${isLent ? 'Lent' : 'Borrowed'} ${Formatters.currency(entry.amount)}',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(Formatters.date(entry.date)),
                              if (entry.note != null && entry.note!.isNotEmpty)
                                Text(
                                  entry.note!,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              if (entryEvents.isNotEmpty)
                                Text(
                                  'Settlements (${entryEvents.length})',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFBDBDBD),
                                  ),
                                ),
                              _buildSettlementHistoryRow(entryEvents),
                            ],
                          ),
                          trailing: SizedBox(
                            width: 120,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: entry.isSettled
                                        ? Colors.white.withValues(alpha: 0.18)
                                        : color.withValues(alpha: 0.16),
                                    borderRadius: BorderRadius.zero,
                                  ),
                                  child: Text(
                                    entry.settledAt == null
                                        ? 'Settled'
                                        : 'Settled ${_settledDateFmt.format(entry.settledAt!)}',
                                    style: TextStyle(
                                      color: entry.isSettled ? null : color,
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
                                  child: const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(Icons.undo, size: 16),
                                  ),
                                ),
                              ],
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: person == null
            ? null
            : () => _showAddEntryDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add entry'),
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
