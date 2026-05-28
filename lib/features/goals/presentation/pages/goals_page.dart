import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:spendly/core/theme/app_design_tokens.dart';
import 'package:spendly/core/theme/app_icons.dart';
import 'package:spendly/core/theme/app_typography.dart';
import 'package:spendly/core/utils/formatters.dart';
import 'package:spendly/core/widgets/app_confirm_dialog.dart';
import 'package:spendly/core/widgets/app_input_dialog.dart';
import 'package:spendly/core/widgets/noir_header.dart';
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
    if (emergency == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
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
      backgroundColor: Colors.black,
      appBar: NoirHeader(
        showLeading: true,
        leadingIcon: AppIcons.bell,
        onLeadingTap: () => context.push('/notifications'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.smPlus,
          AppSpacing.md,
          AppSpacing.smPlus,
          94,
        ),
        children: [
          Text('Emergency Funds', style: AppTypography.sectionTitle(context)),
          const SizedBox(height: 10),
          const Divider(color: AppColors.borderDark, height: 1),
          const SizedBox(height: 12),
          ...emergencyCards.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Dismissible(
                key: ValueKey('emergency-${entry.value.id}'),
                direction: DismissDirection.endToStart,
                confirmDismiss: (_) {
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
                background: const SizedBox.shrink(),
                secondaryBackground: Container(
                  alignment: Alignment.centerRight,
                  color: const Color(0xFF1A1A1A),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: const Icon(AppIcons.trash, color: Colors.white),
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
                    await actions.addToEmergencyFund(
                      amount,
                      fundId: entry.value.id,
                    );
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Insufficient saved amount.'),
                        ),
                      );
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
          Text('Your Goals', style: AppTypography.sectionTitle(context)),
          const SizedBox(height: 10),
          const Divider(color: AppColors.borderDark, height: 1),
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
                direction: DismissDirection.endToStart,
                confirmDismiss: (_) {
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
                background: const SizedBox.shrink(),
                secondaryBackground: Container(
                  alignment: Alignment.centerRight,
                  color: const Color(0xFF1A1A1A),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: const Icon(AppIcons.trash, color: Colors.white),
                ),
                child: _GoalCard(
                  goal: goal,
                  onQuickAdd: () async {
                    final amount = await _askAmount(
                      context,
                      title: 'Add funds to ${goal.title}',
                    );
                    if (amount == null) return;
                    await actions.addToGoal(goal.id, amount);
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Insufficient saved amount.'),
                        ),
                      );
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
        ],
      ),
    );
  }

  Future<void> _openCreateGoalSheet(
    BuildContext context,
    GoalsActions actions,
  ) async {
    final titleController = TextEditingController();
    final categoryController = TextEditingController();
    final targetController = TextEditingController();
    final savedController = TextEditingController(text: '0');
    final monthlyController = TextEditingController();
    DateTime targetDate = DateTime.now().add(const Duration(days: 120));

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.darkSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.md,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Goal',
                      style: AppTypography.sectionTitle(context),
                    ),
                    const SizedBox(height: 14),
                    _GoalTextField(
                      controller: titleController,
                      label: 'Goal name',
                    ),
                    const SizedBox(height: 10),
                    _GoalTextField(
                      controller: categoryController,
                      label: 'Category (optional)',
                    ),
                    const SizedBox(height: 10),
                    _GoalTextField(
                      controller: targetController,
                      label: 'Target amount',
                      numeric: true,
                    ),
                    const SizedBox(height: 10),
                    _GoalTextField(
                      controller: savedController,
                      label: 'Already saved',
                      numeric: true,
                    ),
                    const SizedBox(height: 10),
                    _GoalTextField(
                      controller: monthlyController,
                      label: 'Monthly contribution (optional)',
                      numeric: true,
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: targetDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 3650),
                          ),
                        );
                        if (picked != null) {
                          setModalState(() => targetDate = picked);
                        }
                      },
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          color: AppColors.darkSurface,
                          border: Border.all(color: AppColors.borderDark),
                        ),
                        child: Text(
                          'Target date: ${DateFormat('d MMM yyyy').format(targetDate)}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        onPressed: () async {
                          final title = titleController.text.trim();
                          final categoryInput = categoryController.text.trim();
                          final target =
                              double.tryParse(targetController.text.trim()) ??
                              0;
                          final saved =
                              double.tryParse(savedController.text.trim()) ?? 0;
                          final monthlyInput =
                              double.tryParse(monthlyController.text.trim()) ??
                              0;

                          if (title.isEmpty || target <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Goal name and target are required.',
                                ),
                              ),
                            );
                            return;
                          }

                          final normalizedSaved = saved
                              .clamp(0, target)
                              .toDouble();
                          final daysLeft = targetDate
                              .difference(DateTime.now())
                              .inDays;
                          final monthsLeft = (daysLeft / 30).ceil().clamp(
                            1,
                            9999,
                          );
                          final remaining = (target - normalizedSaved).clamp(
                            0.0,
                            double.infinity,
                          );
                          final monthly = monthlyInput > 0
                              ? monthlyInput
                              : remaining / monthsLeft;
                          final category = categoryInput.isEmpty
                              ? 'General'
                              : categoryInput;

                          await actions.addGoal(
                            title: title,
                            category: category,
                            targetAmount: target,
                            initialSaved: normalizedSaved,
                            targetDate: targetDate,
                            monthlyContribution: monthly,
                          );
                          if (!context.mounted) return;
                          Navigator.of(context).pop();
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        child: const Text('Create Goal'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    titleController.dispose();
    categoryController.dispose();
    targetController.dispose();
    savedController.dispose();
    monthlyController.dispose();
  }

  Future<void> _openCreateEmergencySheet(
    BuildContext context,
    GoalsActions actions,
  ) async {
    final titleController = TextEditingController(text: 'Emergency Fund');
    final targetController = TextEditingController();
    final savedController = TextEditingController(text: '0');
    final monthlyExpenseController = TextEditingController(text: '0');
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.darkSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Emergency Fund',
                style: AppTypography.sectionTitle(context),
              ),
              const SizedBox(height: 12),
              _GoalTextField(controller: titleController, label: 'Name'),
              const SizedBox(height: 10),
              _GoalTextField(
                controller: targetController,
                label: 'Target amount',
                numeric: true,
              ),
              const SizedBox(height: 10),
              _GoalTextField(
                controller: savedController,
                label: 'Current saved',
                numeric: true,
              ),
              const SizedBox(height: 10),
              _GoalTextField(
                controller: monthlyExpenseController,
                label: 'Monthly expense coverage base',
                numeric: true,
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: () async {
                    final title = titleController.text.trim();
                    final target =
                        double.tryParse(targetController.text.trim()) ?? 0;
                    final saved =
                        double.tryParse(savedController.text.trim()) ?? 0;
                    final expense =
                        double.tryParse(monthlyExpenseController.text.trim()) ??
                        0;
                    if (title.isEmpty || target <= 0) return;
                    await actions.addEmergencyFund(
                      title: title,
                      targetAmount: target,
                      initialSaved: saved,
                      monthlyExpense: expense,
                    );
                    if (!context.mounted) return;
                    Navigator.pop(context);
                  },
                  child: const Text('Create'),
                ),
              ),
            ],
          ),
        );
      },
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
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
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
                              const Divider(color: AppColors.borderDark),
                          itemBuilder: (_, index) {
                            final item = items[index];
                            return Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${Formatters.currency(item.amount)} - ${DateFormat('d MMM, HH:mm').format(item.createdAt)}',
                                    style: const TextStyle(color: Colors.white),
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
                                    color: Color(0xFFFFB3A8),
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
        color: const Color(0xFFE8E8E8),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PRIMARY LIQUIDITY / ${liquidityIndex.toString().padLeft(2, '0')}',
            style: const TextStyle(
              color: Colors.black54,
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
            style: const TextStyle(
              color: Colors.black,
              fontSize: 50,
              height: 0.9,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'CURRENT STATUS',
            style: TextStyle(
              color: Colors.black54,
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
                    child: Text(
                      Formatters.currency(emergency.currentAmount),
                      maxLines: 1,
                      style: const TextStyle(
                        color: Colors.black,
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
                    style: const TextStyle(
                      color: Colors.black87,
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
            backgroundColor: const Color(0xFFD2D2D2),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
            minHeight: 14,
            borderRadius: BorderRadius.zero,
          ),
          const SizedBox(height: 16),
          Text(
            'Coverage: ${emergency.monthsCovered.toStringAsFixed(1)} months | Updated ${DateFormat('d MMM, HH:mm').format(emergency.lastUpdated)}',
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Target: ${Formatters.currency(emergency.targetAmount)}',
            style: const TextStyle(
              color: Colors.black54,
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
                    icon: const Icon(AppIcons.plus, color: Colors.black),
                    label: const Text(
                      'Add Funds',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.black87),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onRemoveFunds,
                    icon: const Icon(Icons.remove, color: Colors.black),
                    label: const Text(
                      'Remove',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.black87),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
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
                  style: TextButton.styleFrom(foregroundColor: Colors.black),
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
        color: AppColors.darkSurface,
        border: Border.all(color: AppColors.borderDark),
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
          Text(
            Formatters.currency(totalSaved),
            style: AppTypography.amount(context, fontSize: 30),
          ),
          const SizedBox(height: 2),
          Text(
            'Target ${Formatters.currency(totalTarget)}',
            style: const TextStyle(color: Color(0xFFB0B0B0)),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: const Color(0xFF181818),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            borderRadius: BorderRadius.zero,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _tinyMetric('On Track', '$onTrackCount / $goalCount'),
              ),
              Expanded(
                child: _tinyMetric(
                  'Monthly Commit',
                  Formatters.currency(monthlyCommitment),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Aggregate performance = combined progress across all emergency funds and goals.',
            style: TextStyle(color: Color(0xFF8A8A8A), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _tinyMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8F8F8F),
            fontSize: 11,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
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
        color: AppColors.darkSurface,
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Row(
        children: [
          const Icon(AppIcons.calendar, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Nearest deadline: ${goal.title} in ${daysLeft <= 0 ? '0' : daysLeft} days',
              style: const TextStyle(
                color: Colors.white,
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
        color: AppColors.darkSurface,
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            goal.category.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF868686),
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
                    border: Border.all(color: AppColors.borderDark),
                  ),
                  child: const Icon(AppIcons.plus, color: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: onQuickRemove,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.borderDark),
                  ),
                  child: const Icon(Icons.remove, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                '${Formatters.currency(goal.savedAmount)} / ${Formatters.currency(goal.targetAmount)}',
                style: const TextStyle(
                  color: Color(0xFFD8D8D8),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '${(goal.progress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Color(0xFFBDBDBD),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: goal.progress,
            minHeight: 6,
            backgroundColor: const Color(0xFF181818),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            borderRadius: BorderRadius.zero,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                _formatTimeline(remainingDays),
                style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 12),
              ),
              const Spacer(),
              Text(
                'Need ${Formatters.currency(requiredPerMonth)}/mo',
                style: TextStyle(
                  color: requiredPerMonth <= goal.monthlyContribution
                      ? const Color(0xFF57F28F)
                      : const Color(0xFFFFB3A8),
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
          color: AppColors.darkSurface,
          border: Border.all(color: AppColors.borderDark),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: const [
            CustomPaint(painter: _DotGridPainter()),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(AppIcons.plus, size: 46, color: Color(0xFF5A5A5A)),
                  SizedBox(height: 12),
                  Text(
                    'CREATE GOAL',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Expand your financial infrastructure',
                    style: TextStyle(
                      color: Color(0xFF787878),
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
    );
  }
}

class _DotGridPainter extends CustomPainter {
  const _DotGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 16.0;
    const radius = 2.0;
    final paint = Paint()..color = const Color(0xFF1B1B1B);

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
  });

  final TextEditingController controller;
  final String label;
  final bool numeric;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: numeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFFB2B2B2)),
        filled: true,
        fillColor: AppColors.darkSurface,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.borderDark),
        ),
      ),
    );
  }
}
