import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spendly/core/widgets/app_confirm_dialog.dart';
import 'package:spendly/core/theme/app_design_tokens.dart';
import 'package:spendly/core/theme/app_icons.dart';
import 'package:spendly/core/theme/app_typography.dart';
import 'package:spendly/core/widgets/amount_mask.dart';
import 'package:spendly/core/widgets/app_header.dart';
import 'package:spendly/core/widgets/app_input_dialog.dart';
import 'package:spendly/core/widgets/swipe_actions_info_button.dart';
import 'package:spendly/features/lend/domain/repositories/lend_repository.dart';
import 'package:spendly/features/lend/data/repositories/lend_repository_impl.dart';
import 'package:spendly/features/lend/presentation/providers/lend_provider.dart';

class LendPage extends ConsumerWidget {
  const LendPage({super.key});

  Future<void> _editPerson(
    BuildContext context,
    LendRepository repository, {
    required String personId,
    required String personName,
  }) async {
    final renamed = await showAppTextInputDialog(
      context,
      title: 'Edit Person',
      hintText: 'Person name',
      confirmText: 'Save',
      textCapitalization: TextCapitalization.words,
      initialValue: personName,
    );
    if (renamed == null || renamed.trim().isEmpty) return;
    await repository.renamePerson(personId: personId, name: renamed.trim());
  }

  Future<void> _showAddPersonDialog(
    BuildContext context,
    LendRepository repository,
  ) async {
    final name = await showAppTextInputDialog(
      context,
      title: 'Add Person',
      hintText: 'Person name',
      confirmText: 'Add',
      textCapitalization: TextCapitalization.words,
      requiredLabel: 'Name',
    );
    if (name == null) return;
    await repository.addPerson(name.trim());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(lendOverviewProvider);

    return Scaffold(
      backgroundColor: context.background,
      appBar: AppHeader(
        mode: AppHeaderMode.back,
        title: 'Lend',
        onLeadingTap: () => Navigator.of(context).maybePop(),
      ),
      body: overview.when(
        data: (data) {
          return ListView(
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
                      'Lend & Borrow',
                      style: AppTypography.screenTitle(context),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const SwipeActionsInfoButton(
                    tooltip: 'Lend and borrow swipe help',
                    title: 'Lend & Borrow actions',
                    message:
                        'People can be swiped to edit or delete from the list.',
                  ),
                ],
              ),
              const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: context.surface,
                    border: Border.all(color: context.border),
                    borderRadius: BorderRadius.circular(AppRadii.card),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Overview', style: AppTypography.cardTitle(context)),
                      const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryMetric(
                            label: 'You Will Receive',
                            amountValue: data.totalToReceive,
                            isReceive: true,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _SummaryMetric(
                            label: 'You Owe',
                            amountValue: data.totalToPay,
                            isReceive: false,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('People', style: AppTypography.sectionTitle(context)),
              const SizedBox(height: AppSpacing.xs),
              if (data.peopleBalances.isEmpty)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: context.surface,
                    border: Border.all(color: context.border),
                    borderRadius: BorderRadius.circular(AppRadii.card),
                  ),
                  child: const Text(
                    'No people added yet. Tap + to add your first person.',
                  ),
                ),
              ...data.peopleBalances.map((item) {
                final isPositive = item.netBalance >= 0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Dismissible(
                    key: ValueKey(item.person.id),
                    direction: DismissDirection.horizontal,
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.startToEnd) {
                        final repo = ref.read(lendRepositoryProvider);
                        await _editPerson(
                          context,
                          repo,
                          personId: item.person.id,
                          personName: item.person.name,
                        );
                        return false;
                      }
                      return showAppDeleteConfirmDialog(
                        context,
                        title: 'Delete person?',
                        message:
                            'Delete ${item.person.name} and all related lend/borrow entries?',
                      );
                    },
                    onDismissed: (_) {
                      final repo = ref.read(lendRepositoryProvider);
                      repo.deletePerson(item.person.id);
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'DELETE',
                            style: TextStyle(
                              color: AppIcons.getColorForIcon(AppIcons.trash),
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            AppIcons.trash,
                            color: AppIcons.getColorForIcon(AppIcons.trash),
                          ),
                        ],
                      ),
                    ),
                    child: InkWell(
                      onTap: () => context.push('/lend/${item.person.id}'),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: context.surface,
                          border: Border.all(color: context.border),
                          borderRadius: BorderRadius.circular(AppRadii.premiumCard),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: context.surfaceAlt,
                                borderRadius: BorderRadius.circular(
                                  AppRadii.md,
                                ),
                              ),
                              child: Icon(
                                AppIcons.usersRound,
                                color: AppIcons.getColorForIcon(
                                  AppIcons.usersRound,
                                ),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.person.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: AppFontSizes.title,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${item.activeEntryCount} active entries',
                  style: TextStyle(
                    color: context.textSecondary,
                    fontSize: AppFontSizes.label,
                  ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  item.netBalance >= 0 ? '+' : '-',
                                  style: TextStyle(
                                    color: isPositive
                                        ? AppColors.income
                                        : AppColors.expense,
                                    fontWeight: FontWeight.w800,
                                    fontSize: AppFontSizes.title,
                                  ),
                                ),
                                AmountView(
                                  item.netBalance.abs(),
                                  style: TextStyle(
                                    color: isPositive
                                        ? AppColors.income
                                        : AppColors.expense,
                                    fontWeight: FontWeight.w800,
                                    fontSize: AppFontSizes.title,
                                  ),
                                  maskColor: isPositive
                                      ? AppColors.income
                                      : AppColors.expense,
                                  maskWidth: 5,
                                  maskHeight: 16,
                                  maskSpacing: 2,
                                  maskRadius: 0,
                                ),
                              ],
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              AppIcons.chevronRight,
                              size: 20,
                              color: context.textSecondary,
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
        error: (error, _) => Center(child: Text('Failed to load: $error')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final repo = ref.read(lendRepositoryProvider);
          _showAddPersonDialog(context, repo);
        },
        icon: Icon(
          AppIcons.userRoundPlus,
          color: AppIcons.getColorForIcon(AppIcons.userRoundPlus),
        ),
        label: const Text('Add person'),
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.amountValue,
    required this.isReceive,
  });

  final String label;
  final double amountValue;
  final bool isReceive;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tint = isReceive ? AppColors.homeAccentGreen : AppColors.homeAccentRed;

    final bg = isDark
        ? (isReceive
            ? const Color(0xFF121C14)
            : const Color(0xFF1A1314))
        : tint.withValues(alpha: 0.06);
    final border = isDark
        ? (isReceive
            ? const Color(0xFF1B3420)
            : const Color(0xFF352224))
        : tint.withValues(alpha: 0.15);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: bg,
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: context.textPrimary,
              fontSize: AppFontSizes.small,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          AmountView(
            amountValue,
            style: TextStyle(
              color: tint,
              fontWeight: FontWeight.w800,
              fontSize: AppFontSizes.heading,
            ),
            maskColor: tint,
            maskWidth: 6,
            maskHeight: 18,
            maskSpacing: 3,
            maskRadius: 0,
          ),
        ],
      ),
    );
  }
}
