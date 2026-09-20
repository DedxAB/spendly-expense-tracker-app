import 'dart:math' as math;

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
import 'package:spendly/core/widgets/app_header.dart';
import 'package:spendly/core/widgets/dialog_actions_row.dart';
import 'package:spendly/core/widgets/swipe_actions_info_button.dart';
import 'package:spendly/core/widgets/swipe_hint_coach.dart';
import 'package:spendly/features/goals/presentation/providers/goals_provider.dart';

enum _GoalStatus { onTrack, behind, atRisk }

enum _MoreAction { withdraw, history }

const _kGoalGreen = Color(0xFF38D97A);
const _kGoalAmber = Color(0xFFF5B83D);
const _kGoalRed = Color(0xFFFF5C6C);
const _kGoalPurple = Color(0xFF8B5CF6);
const _kGoalOrange = Color(0xFFF59E0B);
const _kGoalSoftRed = Color(0xFFFF8A7A);
const _kGoalGreenTint = Color(0xFF0F2A1C);
const _kGoalAmberTint = Color(0xFF2A200D);
const _kGoalRedTint = Color(0xFF2A1313);
const _kGoalPurpleTint = Color(0xFF1E1433);

const _kGoalGreenLight = Color(0xFF0E9C58);
const _kGoalAmberLight = Color(0xFFA87409);
const _kGoalRedLight = Color(0xFFE03550);
const _kGoalPurpleLight = Color(0xFF7157D8);
const _kGoalOrangeLight = Color(0xFFE2870A);
const _kGoalSoftRedLight = Color(0xFFEF6459);
const _kGoalGreenTintLight = Color(0xFFE7F7EE);
const _kGoalAmberTintLight = Color(0xFFFBF3E1);
const _kGoalRedTintLight = Color(0xFFFDE7EA);
const _kGoalPurpleTintLight = Color(0xFFEFEBFF);

bool _isDark(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;

Color _goalTrackColor(BuildContext context) =>
    _isDark(context) ? const Color(0xFF1C1E20) : const Color(0xFFEDEDEF);

Color _green(BuildContext context) =>
    _isDark(context) ? _kGoalGreen : _kGoalGreenLight;

Color _amber(BuildContext context) =>
    _isDark(context) ? _kGoalAmber : _kGoalAmberLight;

Color _red(BuildContext context) =>
    _isDark(context) ? _kGoalRed : _kGoalRedLight;

Color _purple(BuildContext context) =>
    _isDark(context) ? _kGoalPurple : _kGoalPurpleLight;

Color _orange(BuildContext context) =>
    _isDark(context) ? _kGoalOrange : _kGoalOrangeLight;

Color _softRed(BuildContext context) =>
    _isDark(context) ? _kGoalSoftRed : _kGoalSoftRedLight;

Color _greenTint(BuildContext context) =>
    _isDark(context) ? _kGoalGreenTint : _kGoalGreenTintLight;

Color _amberTint(BuildContext context) =>
    _isDark(context) ? _kGoalAmberTint : _kGoalAmberTintLight;

Color _redTint(BuildContext context) =>
    _isDark(context) ? _kGoalRedTint : _kGoalRedTintLight;

Color _purpleTint(BuildContext context) =>
    _isDark(context) ? _kGoalPurpleTint : _kGoalPurpleTintLight;

double _monthsLeft(DateTime target) {
  final days = target.difference(DateTime.now()).inDays;
  return (days / 30).ceil().clamp(1, 9999).toDouble();
}

double _requiredPerMonth(GoalItem goal) =>
    goal.remaining / _monthsLeft(goal.targetDate);

GoalItem _asGoal(EmergencyFund fund) {
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

_GoalStatus _statusOf(GoalItem goal) {
  if (goal.remaining <= 0) return _GoalStatus.onTrack;
  if (_requiredPerMonth(goal) <= goal.monthlyContribution) {
    return _GoalStatus.onTrack;
  }
  if (goal.targetDate.difference(DateTime.now()).inDays <= 30) {
    return _GoalStatus.atRisk;
  }
  return _GoalStatus.behind;
}

String _statusLabel(_GoalStatus status) => switch (status) {
  _GoalStatus.onTrack => 'On track',
  _GoalStatus.behind => 'Behind',
  _GoalStatus.atRisk => 'At risk',
};

Color _statusColor(BuildContext context, _GoalStatus status) => switch (status) {
  _GoalStatus.onTrack => _green(context),
  _GoalStatus.behind => _amber(context),
  _GoalStatus.atRisk => _red(context),
};

Color _statusTint(BuildContext context, _GoalStatus status) => switch (status) {
  _GoalStatus.onTrack => _greenTint(context),
  _GoalStatus.behind => _amberTint(context),
  _GoalStatus.atRisk => _redTint(context),
};

List<Color> _statusBarColors(BuildContext context, _GoalStatus status) =>
    switch (status) {
      _GoalStatus.onTrack => [_purple(context), _green(context)],
      _GoalStatus.behind => [_amber(context), _orange(context)],
      _GoalStatus.atRisk => [_softRed(context), _red(context)],
    };

String _formatTimeline(int days) {
  if (days <= 0) return 'Due today';
  if (days == 1) return '1 day';
  if (days <= 30) return '$days days';
  final months = days / 30;
  if (months < 12) {
    return months < 2
        ? '1 month'
        : '${months.toStringAsFixed(1)} months';
  }
  final years = days / 365;
  return years < 2 ? '1 year' : '${years.toStringAsFixed(1)} years';
}

IconData _goalIcon(GoalItem goal) =>
    AppIcons.getIconForCategory(goal.category);

Color _goalIconColor(GoalItem goal) =>
    AppIcons.getColorForIcon(_goalIcon(goal), label: goal.category);

class GoalsPage extends ConsumerStatefulWidget {
  const GoalsPage({super.key});

  @override
  ConsumerState<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends ConsumerState<GoalsPage> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
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
    final state = GoalsState(emergencyFunds: emergencyFunds, goals: goals);
    final onTrackCount =
        goals
                .where((goal) => _statusOf(goal) == _GoalStatus.onTrack)
                .length +
            emergencyFunds
                .where(
                  (fund) => fund.currentAmount >= fund.targetAmount,
                )
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
      floatingActionButton: hasAnyGoalData
          ? _GoalsFab(
              onCreate: _tabIndex == 0
                  ? () => _openCreateSheet(context, actions)
                  : () => _openCreateEmergencySheet(context, actions),
            )
          : null,
      body: !hasAnyGoalData
          ? _EmptyState(onCreate: () => _openCreateSheet(context, actions))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.smPlus,
                    AppSpacing.xs,
                    AppSpacing.smPlus,
                    AppSpacing.smPlus,
                  ),
                  child: _GoalsTabs(
                    goalsCount: goals.length,
                    emergencyCount: emergencyFunds.length,
                    index: _tabIndex,
                    onChanged: (index) => setState(() => _tabIndex = index),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.smPlus,
                      0,
                      AppSpacing.smPlus,
                      120,
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppSpacing.sm,
                        ),
                        child: _SummaryHeader(
                          totalSaved: state.totalSaved,
                          totalTarget: state.totalTarget,
                          progress: state.totalProgress,
                          fundCount: emergencyFunds.length + goals.length,
                          monthlyCommitment: state.monthlyGoalCommitment,
                          onTrackCount: onTrackCount,
                        ),
                      ),
                      if (_tabIndex == 0) ...[
                        if (urgentGoal != null) ...[
                          _UrgencyBanner(goal: urgentGoal),
                          const SizedBox(height: 16),
                        ],
                        const _SectionHeader(
                          label: 'Your goals',
                          trailing: SwipeActionsInfoButton(
                            tooltip: 'Goals swipe help',
                            title: 'Goal actions',
                            message:
                                'Goals can be swiped to edit or delete.',
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (goals.isEmpty)
                          const _InlineEmpty(
                            icon: AppIcons.goals,
                            message: 'No goals yet. Tap + to start saving for '
                                'something you love.',
                          )
                        else
                          ...goals.asMap().entries.map(
                            (goalEntry) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Dismissible(
                                key: ValueKey(
                                  'goal-${goalEntry.value.id}',
                                ),
                                direction: DismissDirection.horizontal,
                                confirmDismiss: (direction) async {
                                  if (direction ==
                                      DismissDirection.startToEnd) {
                                    await _openEditGoalSheet(
                                      context,
                                      actions,
                                      goalEntry.value,
                                    );
                                    return false;
                                  }
                                  return _confirmDelete(
                                    context,
                                    title: 'Delete goal?',
                                    message:
                                        'This will remove "${goalEntry.value.title}" and all its contribution history.',
                                  );
                                },
                                onDismissed: (_) async {
                                  await actions.deleteGoal(goalEntry.value.id);
                                },
                                background: Container(
                                  alignment: Alignment.centerLeft,
                                  color: _greenTint(context),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Icon(
                                    AppIcons.edit,
                                    color: _green(context),
                                  ),
                                ),
                                secondaryBackground: Container(
                                  alignment: Alignment.centerRight,
                                  color: _redTint(context),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Icon(
                                    AppIcons.trash,
                                    color: _red(context),
                                  ),
                                ),
                                child: SwipeHintCoach(
                                  enabled: goalEntry.key == 0,
                                  child: _GoalCard(
                                    goal: goalEntry.value,
                                    onAdd: () =>
                                        _addFunds(context, actions, goalEntry.value),
                                    onMore: () =>
                                        _showGoalMore(context, actions, goalEntry.value),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ] else ...[
                        const _SectionHeader(
                          label: 'Emergency fund',
                          trailing: SwipeActionsInfoButton(
                            tooltip: 'Emergency fund swipe help',
                            title: 'Emergency fund actions',
                            message:
                                'Emergency funds can be swiped to edit or delete.',
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (emergencyFunds.isEmpty)
                          const _InlineEmpty(
                            icon: AppIcons.shield,
                            message: 'Build a safety net \u2014 an emergency fund '
                                'covers up to 6 months of expenses when you '
                                'need it most.',
                          )
                        else
                          ...emergencyFunds.asMap().entries.map(
                            (entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Dismissible(
                                key: ValueKey('emergency-${entry.value.id}'),
                                direction: DismissDirection.horizontal,
                                confirmDismiss: (direction) async {
                                  if (direction ==
                                      DismissDirection.startToEnd) {
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
                                  color: _greenTint(context),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Icon(
                                    AppIcons.edit,
                                    color: _green(context),
                                  ),
                                ),
                                secondaryBackground: Container(
                                  alignment: Alignment.centerRight,
                                  color: _redTint(context),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Icon(
                                    AppIcons.trash,
                                    color: _red(context),
                                  ),
                                ),
                                child: SwipeHintCoach(
                                  enabled: entry.key == 0,
                                  child: _EmergencyFundCard(
                                    fund: entry.value,
                                    liquidityIndex: entry.key + 1,
                                    onAdd: () => _addEmergencyFunds(
                                      context,
                                      actions,
                                      entry.value,
                                    ),
                                    onMore: () => _showEmergencyMore(
                                      context,
                                      actions,
                                      entry.value,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
    );
  }

  Future<void> _openCreateSheet(
    BuildContext context,
    GoalsActions actions,
  ) async {
    final isEmergency = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: context.surface,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      builder: (ctx) => _CreateSheet(
        onSelect: (isEmergency) => Navigator.of(ctx).pop(isEmergency),
      ),
    );
    if (isEmergency == null) return;
    if (!context.mounted) return;
    if (isEmergency) {
      await _openCreateEmergencySheet(context, actions);
    } else {
      await _openCreateGoalSheet(context, actions);
    }
  }

  Future<void> _addFunds(
    BuildContext context,
    GoalsActions actions,
    GoalItem goal,
  ) async {
    final result = await _askAmountWithNote(
      context,
      title: 'Add funds to ${goal.title}',
    );
    if (result == null) return;
    if (!context.mounted) return;
    final added = await actions.addToGoal(
      goal.id,
      result.amount,
      note: result.note,
    );
if (!context.mounted) return;
    if (added < result.amount) {
      showAppToast(
        context,
added > 0
            ? "Target nearly reached! Added \u20B9${added.toInt()} only."
            : 'Goal target already reached.',
      );
    }
    HapticFeedback.selectionClick();
  }

  Future<void> _addEmergencyFunds(
    BuildContext context,
    GoalsActions actions,
    EmergencyFund fund,
  ) async {
    final result = await _askAmountWithNote(
      context,
      title: 'Add to emergency fund',
      confirmText: 'Add',
    );
    if (result == null) return;
    if (!context.mounted) return;
    final added = await actions.addToEmergencyFund(
      result.amount,
      fundId: fund.id,
      note: result.note,
);
    if (!context.mounted) return;
    if (added < result.amount) {
      showAppToast(
        context,
        added > 0
            ? "Target nearly reached! Added \u20B9${added.toInt()} only."
            : 'Emergency fund target already reached.',
      );
    }
    HapticFeedback.selectionClick();
  }

  Future<void> _withdrawFromGoal(
    BuildContext context,
    GoalsActions actions,
    GoalItem goal,
  ) async {
    final result = await _askAmountWithNote(
      context,
      title: 'Withdraw from ${goal.title}',
      confirmText: 'Remove',
    );
    if (result == null) return;
    if (!context.mounted) return;
    final ok = await actions.removeFromGoal(
      goal.id,
      result.amount,
      note: result.note,
    );
    if (!context.mounted) return;
    if (!ok) {
      showAppToast(context, 'Insufficient saved amount.');
      return;
    }
    HapticFeedback.selectionClick();
  }

  Future<void> _withdrawFromEmergency(
    BuildContext context,
    GoalsActions actions,
    EmergencyFund fund,
  ) async {
    final result = await _askAmountWithNote(
      context,
      title: 'Withdraw from emergency fund',
      confirmText: 'Remove',
    );
    if (result == null) return;
    if (!context.mounted) return;
    final ok = await actions.removeFromEmergencyFund(
      fund.id,
      result.amount,
      note: result.note,
    );
    if (!context.mounted) return;
    if (!ok) {
      showAppToast(context, 'Insufficient saved amount.');
      return;
    }
    HapticFeedback.selectionClick();
  }

  Future<void> _showGoalMore(
    BuildContext context,
    GoalsActions actions,
    GoalItem goal,
  ) async {
    final action = await showModalBottomSheet<_MoreAction>(
      context: context,
      backgroundColor: context.surface,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      builder: (ctx) => _MoreSheet(
        title: goal.title,
        onSelect: (action) => Navigator.of(ctx).pop(action),
      ),
    );
    if (action == null) return;
    if (!context.mounted) return;
    switch (action) {
      case _MoreAction.withdraw:
        await _withdrawFromGoal(context, actions, goal);
      case _MoreAction.history:
        await _openContributionHistory(context, ref, goal);
    }
  }

  Future<void> _showEmergencyMore(
    BuildContext context,
    GoalsActions actions,
    EmergencyFund fund,
  ) async {
    final action = await showModalBottomSheet<_MoreAction>(
      context: context,
      backgroundColor: context.surface,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      builder: (ctx) => _MoreSheet(
        title: fund.title,
        onSelect: (action) => Navigator.of(ctx).pop(action),
      ),
    );
    if (action == null) return;
    if (!context.mounted) return;
    switch (action) {
      case _MoreAction.withdraw:
        await _withdrawFromEmergency(context, actions, fund);
      case _MoreAction.history:
        await _openContributionHistory(context, ref, _asGoal(fund));
    }
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

  static Future<({double amount, String? note})?> _askAmountWithNote(
    BuildContext context, {
    required String title,
    String confirmText = 'Add',
  }) async {
    return showDialog<({double amount, String? note})>(
      context: context,
      useRootNavigator: true,
      builder: (dialogContext) => _AmountWithNoteDialog(
        title: title,
        confirmText: confirmText,
      ),
    );
  }

  static Future<bool> _confirmDelete(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    return showAppDeleteConfirmDialog(context, title: title, message: message);
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
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${Formatters.currency(item.amount)} - ${DateFormat('d MMM, HH:mm').format(item.createdAt)}',
                                        style: TextStyle(color: context.textPrimary),
                                      ),
                                      if (item.note != null && item.note!.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 2),
                                          child: Text(
                                            item.note!,
                                            style: TextStyle(
                                              color: context.textSecondary,
                                              fontSize: AppFontSizes.small,
                                            ),
                                          ),
                                        ),
                                    ],
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
                                  icon: Icon(
                                    AppIcons.trash,
                                    color: _red(context),
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
            Row(
              children: [
                Expanded(
                  child: Text(widget.titleText, style: AppTypography.sectionTitle(context)),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(AppIcons.close, color: context.textPrimary, size: 28),
                ),
              ],
            ),
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
                  style: TextStyle(color: Colors.red, fontSize: AppFontSizes.label),
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
                  style: TextStyle(color: Colors.red, fontSize: AppFontSizes.label),
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
      child: SingleChildScrollView(
        child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Row(
              children: [
                Expanded(
                  child: Text(widget.titleText, style: AppTypography.sectionTitle(context)),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(AppIcons.close, color: context.textPrimary, size: 28),
                ),
              ],
            ),
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
                style: TextStyle(color: Colors.red, fontSize: AppFontSizes.label),
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
                style: TextStyle(color: Colors.red, fontSize: AppFontSizes.label),
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

class _GoalButton extends StatelessWidget {
  const _GoalButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.primary = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final fg = primary ? context.background : context.textPrimary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: Container(
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: primary ? context.textPrimary : Colors.transparent,
          border: Border.all(
            color: primary
                ? Colors.transparent
                : context.textPrimary.withValues(alpha: 0.28),
          ),
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: fg,
                fontSize: AppFontSizes.bodyLarge,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final _GoalStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _statusTint(context, status),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        _statusLabel(status),
        style: TextStyle(
          color: _statusColor(context, status),
          fontSize: AppFontSizes.small,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _GradientBar extends StatelessWidget {
  const _GradientBar({required this.value, required this.colors});

  final double value;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    final progress = value.clamp(0.0, 1.0).toDouble();
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: SizedBox(
        height: 8,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: _goalTrackColor(context)),
            if (progress > 0)
              FractionallySizedBox(
                widthFactor: progress,
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: colors,
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmergencyFundCard extends StatelessWidget {
  const _EmergencyFundCard({
    required this.fund,
    required this.liquidityIndex,
    required this.onAdd,
    required this.onMore,
  });

  final EmergencyFund fund;
  final int liquidityIndex;
  final VoidCallback onAdd;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final progress = fund.progress;
    final monthsCovered = fund.monthsCovered;
    final title = fund.title.trim().isEmpty
        ? 'Emergency Fund'
        : fund.title.trim();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surface,
        border: Border.all(color: context.border),
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: _greenTint(context),
                  border: Border.all(
                    color: _green(context).withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(AppIcons.shield, color: _green(context), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.textPrimary,
                        fontSize: AppFontSizes.title,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'LIQUIDITY FUND / ${liquidityIndex.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: context.textSecondary.withValues(alpha: 0.6),
                        fontSize: AppFontSizes.small,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${monthsCovered.toStringAsFixed(1)} mo',
                    style: TextStyle(
                      color: _green(context),
                      fontSize: AppFontSizes.heading,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'COVERAGE',
                    style: TextStyle(
                      color: context.textSecondary.withValues(alpha: 0.6),
                      fontSize: AppFontSizes.caption,
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: AmountView(
                    fund.currentAmount,
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: AppFontSizes.largeDisplay,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                      height: 1,
                    ),
                    maskColor: context.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '/ ${Formatters.currency(fund.targetAmount)}',
                style: TextStyle(
                  color: context.textSecondary,
                  fontSize: AppFontSizes.body,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _GradientBar(
            value: progress,
            colors: [_green(context), _purple(context)],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${(progress * 100).toStringAsFixed(0)}% funded',
                style: TextStyle(
                  color: context.textSecondary,
                  fontSize: AppFontSizes.label,
                ),
              ),
              const Spacer(),
              Text(
                '${Formatters.currency(fund.currentAmount)} of target',
                style: TextStyle(
                  color: context.textSecondary.withValues(alpha: 0.6),
                  fontSize: AppFontSizes.small,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _GoalButton(
                  label: 'Add',
                  icon: AppIcons.plus,
                  onTap: onAdd,
                  primary: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _GoalButton(
                  label: 'More',
                  icon: Icons.more_horiz,
                  onTap: onMore,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({
    required this.totalSaved,
    required this.totalTarget,
    required this.progress,
    required this.fundCount,
    required this.monthlyCommitment,
    required this.onTrackCount,
  });

  final double totalSaved;
  final double totalTarget;
  final double progress;
  final int fundCount;
  final double monthlyCommitment;
  final int onTrackCount;

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark(context);
    final gradientColors = isDark
        ? const [Color(0xFF12131A), Color(0xFF0E0F16), Color(0xFF131022)]
        : const [Color(0xFFFBFAFF), Color(0xFFF5F1FF), Color(0xFFFDF5F4)];
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        border: Border.all(color: context.border),
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -46,
            top: -46,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _purple(context).withValues(alpha: isDark ? 0.20 : 0.12),
                    _purple(context).withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                _ProgressRing(
                  value: progress,
                  size: 94,
                  strokeWidth: 7,
                  colors: [_purple(context), _green(context)],
                  label: 'OF TARGET',
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TOTAL SAVED',
                        style: TextStyle(
                          color: context.textSecondary.withValues(alpha: 0.7),
                          fontSize: AppFontSizes.small,
                          letterSpacing: 1.4,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AmountView(
                        totalSaved,
                        style: TextStyle(
                          color: context.textPrimary,
                          fontSize: AppFontSizes.largeDisplay,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1,
                          height: 1,
                        ),
                        maskColor: context.textPrimary,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'of ${Formatters.currency(totalTarget)} across '
                        '$fundCount ${fundCount == 1 ? 'fund' : 'funds'}',
                        style: TextStyle(
                          color: context.textSecondary,
                          fontSize: AppFontSizes.label,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _SummaryMetric(
                            label: 'On track',
                            value: '$onTrackCount / $fundCount',
                          ),
                          const SizedBox(width: 8),
                          _SummaryMetric(
                            label: 'Monthly',
                            value: Formatters.currency(monthlyCommitment),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _isDark(context) ? const Color(0xFF17181B) : context.surfaceAlt,
        border: Border.all(
          color: _isDark(context)
              ? const Color(0xFF1B1D20)
              : context.border,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: context.textSecondary.withValues(alpha: 0.6),
              fontSize: AppFontSizes.caption,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: context.textPrimary,
              fontSize: AppFontSizes.bodyLarge,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({
    required this.value,
    required this.size,
    required this.strokeWidth,
    required this.colors,
    required this.label,
  });

  final double value;
  final double size;
  final double strokeWidth;
  final List<Color> colors;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GradientRingPainter(
          progress: value,
          strokeWidth: strokeWidth,
          trackColor: _goalTrackColor(context),
          colors: colors,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(value * 100).round()}%',
                style: TextStyle(
                  color: context.textPrimary,
                  fontSize: AppFontSizes.heading,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: context.textSecondary.withValues(alpha: 0.7),
                  fontSize: AppFontSizes.caption,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradientRingPainter extends CustomPainter {
  const _GradientRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.trackColor,
    required this.colors,
  });

  final double progress;
  final double strokeWidth;
  final Color trackColor;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (size.shortestSide - strokeWidth) / 2;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = trackColor,
    );
    final sweep = progress.clamp(0.0, 1.0).toDouble() * 2 * math.pi;
    final drawnSweep = sweep == 0 ? 0.001 : sweep;
    final shader = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: -math.pi / 2 + drawnSweep,
      colors: colors,
    ).createShader(rect);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      drawnSweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth
        ..shader = shader,
    );
  }

  @override
  bool shouldRepaint(covariant _GradientRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.colors != colors ||
        oldDelegate.trackColor != trackColor;
  }
}

class _UrgencyBanner extends StatelessWidget {
  const _UrgencyBanner({required this.goal});

  final GoalItem goal;

  @override
  Widget build(BuildContext context) {
    final daysLeft = goal.targetDate.difference(DateTime.now()).inDays;
    final icon = _goalIcon(goal);
    final requiredPerMonth = _requiredPerMonth(goal);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _purpleTint(context),
        border: Border.all(color: _purple(context).withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(AppRadii.premiumCard),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _purple(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: context.background, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nearest deadline \u00B7 ${goal.title}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.textPrimary,
                    fontSize: AppFontSizes.body,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_formatTimeline(daysLeft)} \u00B7 '
                  '${(goal.progress * 100).toStringAsFixed(0)}% funded \u00B7 '
                  'need ${Formatters.currency(requiredPerMonth)}/mo',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.textSecondary,
                    fontSize: AppFontSizes.small,
                  ),
                ),
              ],
            ),
          ),
        ],
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0x334B2FD6),
                    Color(0x003B82F6),
                    Color(0x00000000),
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  AppIcons.goals,
                  size: 54,
                  color: _purple(context),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'No goals yet',
              style: TextStyle(
                color: context.textPrimary,
                fontSize: AppFontSizes.largeHeading,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Set a target, start saving monthly \u2014 we'll keep you on track "
              'with progress and deadlines.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.textSecondary,
                fontSize: AppFontSizes.body,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: 220,
              child: _GoalButton(
                label: 'Create your first fund',
                icon: AppIcons.plus,
                onTap: onCreate,
                primary: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.goal,
    required this.onAdd,
    required this.onMore,
  });

  final GoalItem goal;
  final VoidCallback onAdd;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final status = _statusOf(goal);
    final remainingDays = goal.targetDate.difference(DateTime.now()).inDays;
    final requiredPerMonth = _requiredPerMonth(goal);
    final icon = _goalIcon(goal);
    final iconColor = _goalIconColor(goal);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surface,
        border: Border.all(color: context.border),
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title.toUpperCase(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.textPrimary,
                        fontSize: AppFontSizes.title,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      goal.category.toUpperCase(),
                      style: TextStyle(
                        color: context.textSecondary.withValues(alpha: 0.6),
                        fontSize: AppFontSizes.caption,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusPill(status: status),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: AmountView(
                    goal.savedAmount,
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: AppFontSizes.largeDisplay,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                      height: 1,
                    ),
                    maskColor: context.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '/ ${Formatters.currency(goal.targetAmount)}',
                style: TextStyle(
                  color: context.textSecondary,
                  fontSize: AppFontSizes.body,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _GradientBar(
            value: goal.progress,
            colors: _statusBarColors(context, status),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                _formatTimeline(remainingDays),
                style: TextStyle(
                  color: context.textSecondary,
                  fontSize: AppFontSizes.label,
                ),
              ),
              const Spacer(),
              Text(
                'Need ${Formatters.currency(requiredPerMonth)}/mo',
                style: TextStyle(
                  color: _statusColor(context, status),
                  fontSize: AppFontSizes.label,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _GoalButton(
                  label: 'Add',
                  icon: AppIcons.plus,
                  onTap: onAdd,
                  primary: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _GoalButton(
                  label: 'More',
                  icon: Icons.more_horiz,
                  onTap: onMore,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, this.trailing});

  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: context.textSecondary.withValues(alpha: 0.7),
            fontSize: AppFontSizes.small,
            letterSpacing: 2.4,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 1,
            color: context.border.withValues(alpha: 0.6),
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          trailing!,
        ],
      ],
    );
  }
}

class _GoalsTabs extends StatelessWidget {
  const _GoalsTabs({
    required this.goalsCount,
    required this.emergencyCount,
    required this.index,
    required this.onChanged,
  });

  final int goalsCount;
  final int emergencyCount;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.surface,
        border: Border.all(color: context.border),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        children: [
          Expanded(
            child: _GoalsTabItem(
              label: 'Goals',
              icon: AppIcons.goals,
              count: goalsCount,
              selected: index == 0,
              onTap: () => onChanged(0),
            ),
          ),
          Expanded(
            child: _GoalsTabItem(
              label: 'Emergency',
              icon: AppIcons.shield,
              count: emergencyCount,
              selected: index == 1,
              onTap: () => onChanged(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalsTabItem extends StatelessWidget {
  const _GoalsTabItem({
    required this.label,
    required this.icon,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? context.background : context.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.pill - 4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? context.textPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.pill - 4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: fg,
                fontSize: AppFontSizes.body,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 5),
              Text(
                '$count',
                style: TextStyle(
                  color: fg.withValues(alpha: 0.55),
                  fontSize: AppFontSizes.label,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GoalsFab extends StatelessWidget {
  const _GoalsFab({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onCreate,
      backgroundColor: context.textPrimary,
      foregroundColor: context.background,
      elevation: 0,
      shape: const CircleBorder(),
      child: const Icon(AppIcons.plus, size: 36),
    );
  }
}

class _CreateSheet extends StatelessWidget {
  const _CreateSheet({required this.onSelect});

  final ValueChanged<bool> onSelect;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: context.border,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Create fund',
              style: TextStyle(
                color: context.textPrimary,
                fontSize: AppFontSizes.heading,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Pick what you want to build next.',
              style: TextStyle(
                color: context.textSecondary,
                fontSize: AppFontSizes.body,
              ),
            ),
            const SizedBox(height: 16),
            _CreateOptionTile(
              icon: AppIcons.goals,
              color: _purple(context),
              tint: _purpleTint(context),
              title: 'Savings goal',
              subtitle: 'A target amount with a deadline, e.g. a trip or a gadget.',
              onTap: () => onSelect(false),
            ),
            const SizedBox(height: 10),
            _CreateOptionTile(
              icon: AppIcons.shield,
              color: _green(context),
              tint: _greenTint(context),
              title: 'Emergency fund',
              subtitle: 'Months of coverage for a rainy day.',
              onTap: () => onSelect(true),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateOptionTile extends StatelessWidget {
  const _CreateOptionTile({
    required this.icon,
    required this.color,
    required this.tint,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final Color tint;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.surface,
          border: Border.all(color: context.border),
          borderRadius: BorderRadius.circular(AppRadii.card),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: tint,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: color, size: 21),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: AppFontSizes.bodyLarge,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: AppFontSizes.label,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Icon(AppIcons.chevronRight, color: context.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _MoreSheet extends StatelessWidget {
  const _MoreSheet({required this.title, required this.onSelect});

  final String title;
  final ValueChanged<_MoreAction> onSelect;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: context.border,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: context.textPrimary,
                fontSize: AppFontSizes.heading,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            _MoreTile(
              icon: AppIcons.money,
              label: 'Withdraw',
              color: _red(context),
              tint: _redTint(context),
              onTap: () => onSelect(_MoreAction.withdraw),
            ),
            _MoreTile(
              icon: AppIcons.history,
              label: 'History',
              color: _purple(context),
              tint: _purpleTint(context),
              onTap: () => onSelect(_MoreAction.history),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoreTile extends StatelessWidget {
  const _MoreTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.tint,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: context.surface,
            border: Border.all(color: context.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: tint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: context.textPrimary,
                  fontSize: AppFontSizes.body,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
              style: TextStyle(color: context.textSecondary, fontSize: AppFontSizes.label),
            ),
            if (required)
              Text(' *', style: TextStyle(color: _red(context))),
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

class _AmountWithNoteDialog extends StatefulWidget {
  const _AmountWithNoteDialog({
    required this.title,
    required this.confirmText,
  });

  final String title;
  final String confirmText;

  @override
  State<_AmountWithNoteDialog> createState() => _AmountWithNoteDialogState();
}

class _AmountWithNoteDialogState extends State<_AmountWithNoteDialog> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  var _formAttempted = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      titlePadding: const EdgeInsets.fromLTRB(
        AppSpacing.sm, AppSpacing.sm, AppSpacing.sm, AppSpacing.xs,
      ),
      contentPadding: const EdgeInsets.fromLTRB(
        AppSpacing.sm, 0, AppSpacing.sm, AppSpacing.sm,
      ),
      actionsPadding: const EdgeInsets.fromLTRB(
        AppSpacing.sm, 0, AppSpacing.sm, AppSpacing.sm,
      ),
      title: Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
      content: SizedBox(
        width: AppModalSizes.dialogContentWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Amount'),
            ),
            if (_formAttempted && _amountController.text.trim().isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'Amount is required',
                  style: TextStyle(color: Colors.red, fontSize: AppFontSizes.label),
                ),
              ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                hintText: 'Reason (optional)',
              ),
            ),
          ],
        ),
      ),
      actions: [
        DialogActionsRow(
          cancelText: 'Cancel',
          confirmText: widget.confirmText,
          onCancel: () => Navigator.of(context, rootNavigator: true).pop(null),
          onConfirm: () {
            setState(() => _formAttempted = true);
            final rawAmount = _amountController.text.trim();
            final amount = double.tryParse(rawAmount);
            if (amount == null || amount <= 0) return;
            final trimmed = _noteController.text.trim();
            Navigator.of(context, rootNavigator: true).pop((
              amount: amount,
              note: trimmed.isEmpty ? null : trimmed,
            ));
          },
        ),
      ],
    );
  }
}

