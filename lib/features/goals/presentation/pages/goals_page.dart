import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:spendly/core/theme/app_design_tokens.dart';
import 'package:spendly/core/theme/app_icons.dart';
import 'package:spendly/core/theme/app_typography.dart';
import 'package:spendly/core/widgets/app_toast.dart';
import 'package:spendly/core/utils/formatters.dart';
import 'package:spendly/core/widgets/amount_mask.dart';
import 'package:spendly/core/widgets/app_confirm_dialog.dart';
import 'package:spendly/core/widgets/app_input_dialog.dart';
import 'package:spendly/core/widgets/app_header.dart';
import 'package:spendly/core/widgets/swipe_actions_info_button.dart';
import 'package:spendly/features/goals/presentation/providers/goals_provider.dart';

class GoalsPage extends ConsumerWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emergencyAsync = ref.watch(emergencyFundProvider);
    final emergencyFundsAsync = ref.watch(emergencyFundsProvider);
    final goalsAsync = ref.watch(goalsListProvider);
    final actions = ref.read(goalsActionsProvider);
    final emergency = emergencyAsync.valueOrNull;
    final emergencyFunds =
        emergencyFundsAsync.valueOrNull ?? const <EmergencyFund>[];
    final goals = goalsAsync.valueOrNull ?? const <GoalItem>[];
    final hasAnyGoalData = emergencyFunds.isNotEmpty || goals.isNotEmpty;
    if (emergency == null) {
      return Scaffold(
        backgroundColor: context.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final emergencyCards = emergencyFunds;
    final state = GoalsState(emergencyFund: emergency, goals: goals);
    final onTrackCount = goals
        .where((goal) => _requiredPerMonth(goal) <= goal.monthlyContribution)
        .length;
    final urgentGoal = goals.isEmpty
        ? null
        : goals.reduce((a, b) => a.targetDate.isBefore(b.targetDate) ? a : b);

    return Scaffold(
      backgroundColor: context.background,
      appBar: AppHeader(
        mode: AppHeaderMode.back,
        title: 'Goals',
        onLeadingTap: () => Navigator.of(context).maybePop(),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.smPlus,
          AppSpacing.md,
          AppSpacing.smPlus,
          94,
        ),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Emergency Funds',
                  style: AppTypography.sectionTitle(context),
                ),
              ),
              const SwipeActionsInfoButton(
                tooltip: 'Emergency fund swipe help',
                title: 'Emergency fund actions',
                message:
                    'Emergency fund cards can be swiped to edit or delete.',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(color: context.border, height: 1),
          const SizedBox(height: 12),
          ...emergencyCards.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Dismissible(
                key: ValueKey('emergency-${entry.value.id}'),
                direction: DismissDirection.horizontal,
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    await _openEditEmergencySheet(
                      context,
                      actions,
                      entry.value,
                    );
                    return false;
                  }
                  return _confirmDelete(
                    context,
                    title: 'Delete emergency fund?',
                    message:
                        'This will remove the selected emergency fund and its history.',
                  );
                },
                onDismissed: (_) async {
                  await actions.deleteGoal(entry.value.id);
                },
                background: Container(
                  alignment: Alignment.centerLeft,
                  color: context.surfaceAlt,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(AppIcons.edit, color: context.textPrimary),
                ),
                secondaryBackground: Container(
                  alignment: Alignment.centerRight,
                  color: context.surfaceAlt,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(AppIcons.trash, color: context.textPrimary),
                ),
                child: _EmergencyFundCard(
                  emergency: entry.value,
                  liquidityIndex: entry.key + 1,
                  onAddFunds: () async {
                    final amount = await _askAmount(
                      context,
                      title: 'Add to emergency fund',
                      confirmText: 'Add',
                    );
                    if (amount == null) return;
                    final added = await actions.addToEmergencyFund(
                      amount,
                      fundId: entry.value.id,
                    );
                    if (!context.mounted) return;
                    if (added < amount) {
                      showAppToast(
                        context,
                        added > 0
                            ? "Target nearly reached! Added ₹${added.toInt()} only."
                            : 'Emergency fund target already reached.',
                      );
                    }
                    HapticFeedback.selectionClick();
                  },
                  onRemoveFunds: () async {
                    final amount = await _askAmount(
                      context,
                      title: 'Withdraw from emergency fund',
                      confirmText: 'Remove',
                    );
                    if (amount == null) return;
                    final ok = await actions.removeFromEmergencyFund(
                      entry.value.id,
                      amount,
                    );
                    if (!context.mounted) return;
                    if (!ok) {
                      showAppToast(context, 'Insufficient saved amount.');
                      return;
                    }
                    HapticFeedback.selectionClick();
                  },
                  onHistory: () => _openContributionHistory(
                    context,
                    ref,
                    _asGoal(entry.value),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () => _openCreateEmergencySheet(context, actions),
              icon: const Icon(AppIcons.plus, size: 16),
              label: const Text('Add emergency fund'),
            ),
          ),
          if (hasAnyGoalData) ...[
            const SizedBox(height: 20),
            _AggregateInsightCard(
              totalSaved: state.totalSaved,
              totalTarget: state.totalTarget,
              progress: state.totalProgress,
              monthlyCommitment: state.monthlyGoalCommitment,
              onTrackCount: onTrackCount,
              goalCount: goals.length,
            ),
            const SizedBox(height: 22),
          ] else
            const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Your Goals',
                  style: AppTypography.sectionTitle(context),
                ),
              ),
              const SwipeActionsInfoButton(
                tooltip: 'Goals swipe help',
                title: 'Goal actions',
                message: 'Goal cards can be swiped to edit or delete.',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(color: context.border, height: 1),
          const SizedBox(height: 14),
          if (urgentGoal != null)
            _UrgencyStrip(goal: urgentGoal)
          else
            const SizedBox.shrink(),
          if (urgentGoal != null) const SizedBox(height: 12),
          ...goals.map(
            (goal) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Dismissible(
                key: ValueKey('goal-${goal.id}'),
                direction: DismissDirection.horizontal,
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    await _openEditGoalSheet(context, actions, goal);
                    return false;
                  }
                  return _confirmDelete(
                    context,
                    title: 'Delete goal?',
                    message:
                        'This will remove "${goal.title}" and all its contribution history.',
                  );
                },
                onDismissed: (_) async {
                  await actions.deleteGoal(goal.id);
                },
                background: Container(
                  alignment: Alignment.centerLeft,
                  color: context.surfaceAlt,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(AppIcons.edit, color: context.textPrimary),
                ),
                secondaryBackground: Container(
                  alignment: Alignment.centerRight,
                  color: context.surfaceAlt,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(AppIcons.trash, color: context.textPrimary),
                ),
                child: _GoalCard(
                  goal: goal,
                    onQuickAdd: () async {
                      final amount = await _askAmount(
                        context,
                        title: 'Add funds to ${goal.title}',
                      );
                      if (amount == null) return;
                      final added = await actions.addToGoal(goal.id, amount);
                      if (!context.mounted) return;
                      if (added < amount) {
                        showAppToast(
                          context,
                          added > 0
                              ? "Target nearly reached! Added ₹${added.toInt()} only."
                              : 'Goal target already reached.',
                        );
                      }
                      HapticFeedback.selectionClick();
                    },
                    onQuickRemove: () async {
                    final amount = await _askAmount(
                      context,
                      title: 'Withdraw from ${goal.title}',
                      confirmText: 'Remove',
                    );
                    if (amount == null) return;
                    final ok = await actions.removeFromGoal(goal.id, amount);
                    if (!context.mounted) return;
                    if (!ok) {
                      showAppToast(context, 'Insufficient saved amount.');
                      return;
                    }
                    HapticFeedback.selectionClick();
                  },
                  onHistory: () => _openContributionHistory(context, ref, goal),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _CreateGoalCard(
            onCreate: () => _openCreateGoalSheet(context, actions),
          ),
          () {
            final total = emergencyFunds.fold<double>(
              0, (sum, f) => sum + f.currentAmount,
            ) + goals.fold<double>(
              0, (sum, g) => sum + g.savedAmount,
            );
            if (total <= 0) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: context.surface,
                  border: Border.all(color: context.border),
                  borderRadius: BorderRadius.circular(AppRadii.card),
                ),
                child: Row(
                  children: [
                    Text(
                      'Total Invested',
                      style: AppTypography.metadata(context).copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    AmountView(
                      total,
                      style: const TextStyle(
                        color: Color(0xFF8B5CF6),
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }(),
        ],
      ),
    );
  }

  Future<void> _openCreateGoalSheet(
    BuildContext context,
    GoalsActions actions,
  ) async {
    final draft = await showModalBottomSheet<_GoalDraft>(
      context: context,
      backgroundColor: context.surface,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
      builder: (ctx) => const _CreateGoalSheet(),
    );

    if (draft == null) return;
    await actions.addGoal(
      title: draft.title,
      category: draft.category,
      targetAmount: draft.targetAmount,
      initialSaved: draft.initialSaved,
      targetDate: draft.targetDate,
      monthlyContribution: draft.monthlyContribution,
    );
  }

  Future<void> _openEditGoalSheet(
    BuildContext context,
    GoalsActions actions,
    GoalItem goal,
  ) async {
    final draft = await showModalBottomSheet<_GoalDraft>(
      context: context,
      backgroundColor: context.surface,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
      builder: (ctx) => _CreateGoalSheet(
        initialDraft: _GoalDraft(
          title: goal.title,
          category: goal.category,
          targetAmount: goal.targetAmount,
          initialSaved: goal.savedAmount,
          targetDate: goal.targetDate,
          monthlyContribution: goal.monthlyContribution,
        ),
        titleText: 'Edit Goal',
        submitText: 'Save Changes',
      ),
    );

    if (draft == null) return;
    await actions.updateGoal(
      goalId: goal.id,
      title: draft.title,
      category: draft.category,
      targetAmount: draft.targetAmount,
      savedAmount: draft.initialSaved,
      targetDate: draft.targetDate,
      monthlyContribution: draft.monthlyContribution,
    );
  }

  Future<void> _openCreateEmergencySheet(
    BuildContext context,
    GoalsActions actions,
  ) async {
    final draft = await showModalBottomSheet<_EmergencyFundDraft>(
      context: context,
      backgroundColor: context.surface,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
      builder: (ctx) => const _CreateEmergencyFundSheet(),
    );

    if (draft == null) return;
    await actions.addEmergencyFund(
      title: draft.title,
      targetAmount: draft.targetAmount,
      initialSaved: draft.initialSaved,
      monthlyExpense: draft.monthlyExpense,
    );
  }

  Future<void> _openEditEmergencySheet(
    BuildContext context,
    GoalsActions actions,
    EmergencyFund fund,
  ) async {
    final draft = await showModalBottomSheet<_EmergencyFundDraft>(
      context: context,
      backgroundColor: context.surface,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
      builder: (ctx) => _CreateEmergencyFundSheet(
        initialDraft: _EmergencyFundDraft(
          title: fund.title,
          targetAmount: fund.targetAmount,
          initialSaved: fund.currentAmount,
          monthlyExpense: fund.monthlyExpense,
        ),
        titleText: 'Edit Emergency Fund',
        submitText: 'Save Changes',
      ),
    );

    if (draft == null) return;
    await actions.updateEmergencyFund(
      fundId: fund.id,
      title: draft.title,
      targetAmount: draft.targetAmount,
      savedAmount: draft.initialSaved,
      monthlyExpense: draft.monthlyExpense,
    );
  }

  static double _requiredPerMonth(GoalItem goal) {
    final now = DateTime.now();
    final months = ((goal.targetDate.difference(now).inDays / 30).ceil()).clamp(
      1,
      9999,
    );
    return goal.remaining / months;
  }

  static Future<double?> _askAmount(
    BuildContext context, {
    required String title,
    String confirmText = 'Add',
  }) async {
    final value = await showAppTextInputDialog(
      context,
      title: title,
      hintText: 'Amount',
      confirmText: confirmText,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    );
    final amount = double.tryParse((value ?? '').trim());
    if (amount == null || amount <= 0) return null;
    return amount;
  }

  static Future<bool> _confirmDelete(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    return showAppDeleteConfirmDialog(context, title: title, message: message);
  }

  static GoalItem _asGoal(EmergencyFund fund) {
    return GoalItem(
      id: fund.id,
      title: fund.title,
      category: 'Emergency',
      targetAmount: fund.targetAmount,
      savedAmount: fund.currentAmount,
      targetDate: DateTime.now().add(const Duration(days: 365)),
      monthlyContribution: 0,
      recentDelta: 0,
    );
  }

  Future<void> _openContributionHistory(
    BuildContext context,
    WidgetRef ref,
    GoalItem goal,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
      builder: (ctx) {
        return Consumer(
          builder: (context, ref, _) {
            final historyAsync = ref.watch(goalContributionsProvider(goal.id));
            final actions = ref.read(goalsActionsProvider);
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${goal.title} History',
                    style: AppTypography.sectionTitle(context),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: historyAsync.when(
                      data: (items) {
                        if (items.isEmpty) {
                          return const Center(
                            child: Text('No contributions yet'),
                          );
                        }
                        return ListView.separated(
                          itemCount: items.length,
                          separatorBuilder: (_, __) =>
                              Divider(color: context.border),
                          itemBuilder: (_, index) {
                            final item = items[index];
                            return Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${Formatters.currency(item.amount)} - ${DateFormat('d MMM, HH:mm').format(item.createdAt)}',
                                    style: TextStyle(color: context.textPrimary),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    final confirmed = await _confirmDelete(
                                      context,
                                      title: 'Delete contribution?',
                                      message:
                                          'This contribution will be removed from ${goal.title}.',
                                    );
                                    if (!confirmed) return;
                                    await actions.deleteContribution(item.id);
                                  },
                                  icon: const Icon(
                                    AppIcons.trash,
                                    color: Color(0xFFFF8A7A),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text('$e')),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _GoalDraft {
  const _GoalDraft({
    required this.title,
    required this.category,
    required this.targetAmount,
    required this.initialSaved,
    required this.targetDate,
    required this.monthlyContribution,
  });

  final String title;
  final String category;
  final double targetAmount;
  final double initialSaved;
  final DateTime targetDate;
  final double monthlyContribution;
}

class _EmergencyFundDraft {
  const _EmergencyFundDraft({
    required this.title,
    required this.targetAmount,
    required this.initialSaved,
    required this.monthlyExpense,
  });

  final String title;
  final double targetAmount;
  final double initialSaved;
  final double monthlyExpense;
}

class _CreateGoalSheet extends StatefulWidget {
  const _CreateGoalSheet({
    this.initialDraft,
    this.titleText = 'Create Goal',
    this.submitText = 'Create Goal',
  });

  final _GoalDraft? initialDraft;
  final String titleText;
  final String submitText;

  @override
  State<_CreateGoalSheet> createState() => _CreateGoalSheetState();
}

class _CreateGoalSheetState extends State<_CreateGoalSheet> {
  bool _formAttempted = false;
  late final TextEditingController _titleController;
  late final TextEditingController _categoryController;
  late final TextEditingController _targetController;
  late final TextEditingController _savedController;
  late final TextEditingController _monthlyController;
  late DateTime _targetDate;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialDraft;
    _titleController = TextEditingController(text: initial?.title ?? '');
    _categoryController = TextEditingController(text: initial?.category ?? '');
    _targetController = TextEditingController(
      text: initial == null ? '' : _formatDecimal(initial.targetAmount),
    );
    _savedController = TextEditingController(
      text: _formatDecimal(initial?.initialSaved ?? 0),
    );
    _monthlyController = TextEditingController(
      text: initial == null ? '' : _formatDecimal(initial.monthlyContribution),
    );
    _targetDate =
        initial?.targetDate ?? DateTime.now().add(const Duration(days: 120));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _targetController.dispose();
    _savedController.dispose();
    _monthlyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.titleText, style: AppTypography.sectionTitle(context)),
            const SizedBox(height: 14),
            _GoalTextField(
              controller: _titleController,
              label: 'Goal name',
              required: true,
            ),
            if (_formAttempted && _titleController.text.trim().isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'Goal name is required',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            const SizedBox(height: 10),
            _GoalTextField(
              controller: _categoryController,
              label: 'Category (optional)',
            ),
            const SizedBox(height: 10),
            _GoalTextField(
              controller: _targetController,
              label: 'Target amount',
              numeric: true,
              required: true,
            ),
            if (_formAttempted && _targetController.text.trim().isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'Target amount is required',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            const SizedBox(height: 10),
            _GoalTextField(
              controller: _savedController,
              label: 'Already saved',
              numeric: true,
            ),
            const SizedBox(height: 10),
            _GoalTextField(
              controller: _monthlyController,
              label: 'Monthly contribution (optional)',
              numeric: true,
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _targetDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                );
                if (picked != null) {
                  setState(() => _targetDate = picked);
                }
              },
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: context.surface,
                  border: Border.all(color: context.border),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: Text(
                  'Target date: ${DateFormat('d MMM yyyy').format(_targetDate)}',
                  style: TextStyle(color: context.textPrimary),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _submit,
                child: Text(widget.submitText),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    setState(() => _formAttempted = true);

    final title = _titleController.text.trim();
    final categoryInput = _categoryController.text.trim();
    final target = double.tryParse(_targetController.text.trim()) ?? 0;
    final saved = double.tryParse(_savedController.text.trim()) ?? 0;
    final monthlyInput = double.tryParse(_monthlyController.text.trim()) ?? 0;

    if (title.isEmpty || target <= 0) return;

    final normalizedSaved = saved.clamp(0, target).toDouble();
    final daysLeft = _targetDate.difference(DateTime.now()).inDays;
    final monthsLeft = (daysLeft / 30).ceil().clamp(1, 9999);
    final remaining = (target - normalizedSaved).clamp(0.0, double.infinity);
    final monthly = monthlyInput > 0 ? monthlyInput : remaining / monthsLeft;
    final category = categoryInput.isEmpty ? 'General' : categoryInput;

    Navigator.of(context).pop(
      _GoalDraft(
        title: title,
        category: category,
        targetAmount: target,
        initialSaved: normalizedSaved,
        targetDate: _targetDate,
        monthlyContribution: monthly,
      ),
    );
  }
}

class _CreateEmergencyFundSheet extends StatefulWidget {
  const _CreateEmergencyFundSheet({
    this.initialDraft,
    this.titleText = 'Add Emergency Fund',
    this.submitText = 'Create',
  });

  final _EmergencyFundDraft? initialDraft;
  final String titleText;
  final String submitText;

  @override
  State<_CreateEmergencyFundSheet> createState() =>
      _CreateEmergencyFundSheetState();
}

class _CreateEmergencyFundSheetState extends State<_CreateEmergencyFundSheet> {
  bool _formAttempted = false;
  late final TextEditingController _titleController;
  late final TextEditingController _targetController;
  late final TextEditingController _savedController;
  late final TextEditingController _monthlyExpenseController;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialDraft;
    _titleController = TextEditingController(
      text: initial?.title ?? 'Emergency Fund',
    );
    _targetController = TextEditingController(
      text: initial == null ? '' : _formatDecimal(initial.targetAmount),
    );
    _savedController = TextEditingController(
      text: _formatDecimal(initial?.initialSaved ?? 0),
    );
    _monthlyExpenseController = TextEditingController(
      text: _formatDecimal(initial?.monthlyExpense ?? 0),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    _savedController.dispose();
    _monthlyExpenseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.titleText, style: AppTypography.sectionTitle(context)),
          const SizedBox(height: 12),
          _GoalTextField(
            controller: _titleController,
            label: 'Name',
            required: true,
          ),
          if (_formAttempted && _titleController.text.trim().isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'Goal name is required',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          const SizedBox(height: 10),
          _GoalTextField(
            controller: _targetController,
            label: 'Target amount',
            numeric: true,
            required: true,
          ),
          if (_formAttempted && _targetController.text.trim().isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'Target amount is required',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          const SizedBox(height: 10),
          _GoalTextField(
            controller: _savedController,
            label: 'Current saved',
            numeric: true,
          ),
          const SizedBox(height: 10),
          _GoalTextField(
            controller: _monthlyExpenseController,
            label: 'Monthly expense coverage base',
            numeric: true,
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: _submit,
              child: Text(widget.submitText),
            ),
          ),
        ],
      ),
    );
  }

  void _submit() {
    setState(() => _formAttempted = true);

    final title = _titleController.text.trim();
    final target = double.tryParse(_targetController.text.trim()) ?? 0;
    final saved = double.tryParse(_savedController.text.trim()) ?? 0;
    final expense = double.tryParse(_monthlyExpenseController.text.trim()) ?? 0;

    if (title.isEmpty || target <= 0) return;

    Navigator.of(context).pop(
      _EmergencyFundDraft(
        title: title,
        targetAmount: target,
        initialSaved: saved,
        monthlyExpense: expense,
      ),
    );
  }
}

String _formatDecimal(double value) {
  if (value == value.truncateToDouble()) {
    return value.toStringAsFixed(0);
  }
  return value.toStringAsFixed(2);
}

class _EmergencyFundCard extends StatelessWidget {
  const _EmergencyFundCard({
    required this.emergency,
    required this.liquidityIndex,
    required this.onAddFunds,
    required this.onRemoveFunds,
    this.onHistory,
  });

  final EmergencyFund emergency;
  final int liquidityIndex;
  final VoidCallback onAddFunds;
  final VoidCallback onRemoveFunds;
  final VoidCallback? onHistory;

  @override
  Widget build(BuildContext context) {
    final progress = emergency.progress;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.surface,
        border: Border.all(color: context.border),
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PRIMARY LIQUIDITY / ${liquidityIndex.toString().padLeft(2, '0')}',
            style: TextStyle(
              color: context.textPrimary.withValues(alpha: 0.54),
              fontSize: 11,
              letterSpacing: 4,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            emergency.title.trim().isEmpty ? 'EMERGENCY FUND' : emergency.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 50,
              height: 0.9,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'CURRENT STATUS',
            style: TextStyle(
              color: context.textPrimary.withValues(alpha: 0.54),
              fontSize: 11,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 52,
            child: Row(
              children: [
                Expanded(
                  child: FittedBox(
                    alignment: Alignment.centerLeft,
                    fit: BoxFit.scaleDown,
                    child: AmountView(
                      emergency.currentAmount,
                      maxLines: 1,
                      style: TextStyle(
                        color: context.textPrimary,
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${(progress * 100).toStringAsFixed(1)}%',
                    maxLines: 1,
                    style: TextStyle(
                      color: context.textPrimary.withValues(alpha: 0.87),
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: context.textSecondary,
            valueColor: AlwaysStoppedAnimation<Color>(context.textPrimary),
            minHeight: 14,
          ),
          const SizedBox(height: 16),
          Text(
            'Coverage: ${emergency.monthsCovered.toStringAsFixed(1)} months | Updated ${DateFormat('d MMM, HH:mm').format(emergency.lastUpdated)}',
            style: TextStyle(
              color: context.textPrimary.withValues(alpha: 0.87),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Target: ${Formatters.currency(emergency.targetAmount)}',
            style: TextStyle(
              color: context.textPrimary.withValues(alpha: 0.54),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onAddFunds,
                    icon: Icon(AppIcons.plus, color: context.textPrimary),
                    label: Text(
                      'Add Funds',
                      style: TextStyle(
                        color: context.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: context.textPrimary.withValues(alpha: 0.87)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.md),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onRemoveFunds,
                    icon: Icon(Icons.remove, color: context.textPrimary),
                    label: Text(
                      'Remove',
                      style: TextStyle(
                        color: context.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: context.textPrimary.withValues(alpha: 0.87)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.md),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (onHistory != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Spacer(),
                TextButton(
                  onPressed: onHistory,
                  style: TextButton.styleFrom(foregroundColor: context.textPrimary),
                  child: const Text('History'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _AggregateInsightCard extends StatelessWidget {
  const _AggregateInsightCard({
    required this.totalSaved,
    required this.totalTarget,
    required this.progress,
    required this.monthlyCommitment,
    required this.onTrackCount,
    required this.goalCount,
  });

  final double totalSaved;
  final double totalTarget;
  final double progress;
  final double monthlyCommitment;
  final int onTrackCount;
  final int goalCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.surface,
        border: Border.all(color: context.border),
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('AGGREGATE PERFORMANCE', style: AppTypography.metadata(context)),
          const SizedBox(height: 8),
          Text(
            'TOTAL SAVINGS PROGRESS',
            style: AppTypography.sectionTitle(context),
          ),
          const SizedBox(height: 10),
          AmountView(
            totalSaved,
            style: AppTypography.amount(context, fontSize: 30),
          ),
          const SizedBox(height: 2),
          Text(
            'Target ${Formatters.currency(totalTarget)}',
            style: TextStyle(color: context.textSecondary),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: context.surfaceAlt,
            valueColor: AlwaysStoppedAnimation<Color>(context.textPrimary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _tinyMetric(context, 'On Track', '$onTrackCount / $goalCount'),
              ),
              Expanded(
                child: _tinyMetric(
                  context,
                  'Monthly Commit',
                  Formatters.currency(monthlyCommitment),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Aggregate performance = combined progress across all emergency funds and goals.',
            style: TextStyle(color: context.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _tinyMetric(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: context.textSecondary,
            fontSize: 11,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: context.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _UrgencyStrip extends StatelessWidget {
  const _UrgencyStrip({required this.goal});

  final GoalItem goal;

  @override
  Widget build(BuildContext context) {
    final daysLeft = goal.targetDate.difference(DateTime.now()).inDays;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.surface,
        border: Border.all(color: context.border),
        borderRadius: BorderRadius.circular(AppRadii.premiumCard),
      ),
      child: Row(
        children: [
          Icon(AppIcons.calendar, color: context.textPrimary, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Nearest deadline: ${goal.title} in ${daysLeft <= 0 ? '0' : daysLeft} days',
              style: TextStyle(
                color: context.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.goal,
    required this.onQuickAdd,
    required this.onQuickRemove,
    required this.onHistory,
  });

  final GoalItem goal;
  final VoidCallback onQuickAdd;
  final VoidCallback onQuickRemove;
  final VoidCallback onHistory;

  @override
  Widget build(BuildContext context) {
    final requiredPerMonth = GoalsPage._requiredPerMonth(goal);
    final remainingDays = goal.targetDate.difference(DateTime.now()).inDays;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.surface,
        border: Border.all(color: context.border),
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            goal.category.toUpperCase(),
  style: TextStyle(
    color: context.textSecondary,
    letterSpacing: 3,
    fontSize: 10,
    fontWeight: FontWeight.w700,
  ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  goal.title.toUpperCase(),
                  style: AppTypography.sectionTitle(context),
                ),
              ),
                  InkWell(
                onTap: onQuickAdd,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    border: Border.all(color: context.border),
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: Icon(AppIcons.plus, color: context.textPrimary),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: onQuickRemove,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    border: Border.all(color: context.border),
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: Icon(Icons.remove, color: context.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                '${Formatters.currency(goal.savedAmount)} / ${Formatters.currency(goal.targetAmount)}',
style: TextStyle(
  color: context.textSecondary,
  fontWeight: FontWeight.w700,
),
              ),
              const Spacer(),
              Text(
                '${(goal.progress * 100).toStringAsFixed(0)}%',
    style: TextStyle(
      color: context.textSecondary,
      fontWeight: FontWeight.w700,
    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: goal.progress,
            minHeight: 6,
            backgroundColor: context.surfaceAlt,
            valueColor: AlwaysStoppedAnimation<Color>(context.textPrimary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                _formatTimeline(remainingDays),
                style: TextStyle(color: context.textSecondary, fontSize: 12),
              ),
              const Spacer(),
              Text(
                'Need ${Formatters.currency(requiredPerMonth)}/mo',
                style: TextStyle(
                  color: requiredPerMonth <= goal.monthlyContribution
                      ? const Color(0xFF3DD07B)
                      : const Color(0xFFFF8A7A),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onHistory,
            child: const Text('View contribution history'),
          ),
        ],
      ),
    );
  }

  static String _formatTimeline(int days) {
    if (days <= 30) return '$days days';
    if (days < 365) return '${(days / 30).toStringAsFixed(1)} months';
    return '${(days / 365).toStringAsFixed(1)} years';
  }
}

class _CreateGoalCard extends StatelessWidget {
  const _CreateGoalCard({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onCreate,
        child: Container(
          height: 220,
          decoration: BoxDecoration(
            color: context.surface,
            border: Border.all(color: context.border),
            borderRadius: BorderRadius.circular(AppRadii.card),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.card),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(painter: _DotGridPainter(color: context.border)),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(AppIcons.plus, size: 46, color: context.textSecondary),
                  const SizedBox(height: 12),
                  Text(
                    'CREATE GOAL',
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Expand your financial infrastructure',
                    style: TextStyle(
                      color: context.textSecondary,
                      letterSpacing: 2.2,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  const _DotGridPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 16.0;
    const radius = 2.0;
    final paint = Paint()..color = color;

    for (double y = spacing / 2; y < size.height; y += spacing) {
      for (double x = spacing / 2; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GoalTextField extends StatelessWidget {
  const _GoalTextField({
    required this.controller,
    required this.label,
    this.numeric = false,
    this.required = false,
  });

  final TextEditingController controller;
  final String label;
  final bool numeric;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(color: context.textSecondary, fontSize: 12),
            ),
            if (required)
              const Text(' *', style: TextStyle(color: Colors.red)),
          ],
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: numeric
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          style: TextStyle(color: context.textPrimary),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: context.surfaceAlt,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.md),
              borderSide: BorderSide(color: context.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.md),
              borderSide: BorderSide(color: context.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.md),
              borderSide: BorderSide(color: context.border),
            ),
          ),
        ),
      ],
    );
  }
}
