import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spendly/core/widgets/app_confirm_dialog.dart';
import 'package:spendly/core/theme/app_design_tokens.dart';
import 'package:spendly/core/theme/app_icons.dart';
import 'package:spendly/core/theme/app_typography.dart';
import 'package:spendly/core/utils/formatters.dart';
import 'package:spendly/core/widgets/noir_header.dart';
import 'package:spendly/core/widgets/app_input_dialog.dart';
import 'package:spendly/core/widgets/swipe_actions_info_button.dart';
import 'package:spendly/features/lend/data/repositories/lend_repository_impl.dart';
import 'package:spendly/features/lend/presentation/providers/lend_provider.dart';

class LendPage extends ConsumerWidget {
  const LendPage({super.key});

  Future<void> _editPerson(
    BuildContext context,
    WidgetRef ref, {
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
    await ref
        .read(lendRepositoryProvider)
        .renamePerson(personId: personId, name: renamed.trim());
  }

  Future<void> _showAddPersonDialog(BuildContext context, WidgetRef ref) async {
    final name = await showAppTextInputDialog(
      context,
      title: 'Add Person',
      hintText: 'Person name',
      confirmText: 'Add',
      textCapitalization: TextCapitalization.words,
    );
    if (name == null || name.trim().isEmpty) return;
    await ref.read(lendRepositoryProvider).addPerson(name.trim());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(lendOverviewProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: NoirHeader(
        showLeading: true,
        leadingIcon: AppIcons.chevronLeft,
        onLeadingTap: () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            context.go('/settings');
          }
        },
        showProfileAction: false,
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
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => _showAddPersonDialog(context, ref),
                    icon: Icon(
                      AppIcons.personAdd,
                      size: 16,
                      color: AppIcons.getColorForIcon(AppIcons.personAdd),
                    ),
                    label: const Text('ADD'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: const Color(0xFF0E0E0E),
                  border: Border.all(color: AppColors.borderDark),
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
                            value: Formatters.currency(data.totalToReceive),
                            color: AppColors.income,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _SummaryMetric(
                            label: 'You Owe',
                            value: Formatters.currency(data.totalToPay),
                            color: AppColors.expense,
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
                    color: const Color(0xFF0E0E0E),
                    border: Border.all(color: AppColors.borderDark),
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
                        await _editPerson(
                          context,
                          ref,
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
                      ref
                          .read(lendRepositoryProvider)
                          .deletePerson(item.person.id);
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
                          color: const Color(0xFF0E0E0E),
                          border: Border.all(color: AppColors.borderDark),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1A1A),
                                borderRadius: BorderRadius.circular(
                                  AppRadii.md,
                                ),
                              ),
                              child: Icon(
                                isPositive
                                    ? AppIcons.download
                                    : AppIcons.upload,
                                color: AppIcons.getColorForIcon(
                                  isPositive
                                      ? AppIcons.download
                                      : AppIcons.upload,
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
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${item.activeEntryCount} active entries',
                                    style: const TextStyle(
                                      color: Color(0xFFB5B5B5),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              '${item.netBalance >= 0 ? '+' : '-'}${Formatters.currency(item.netBalance.abs())}',
                              style: TextStyle(
                                color: isPositive
                                    ? AppColors.income
                                    : AppColors.expense,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              AppIcons.chevronRight,
                              size: 20,
                              color: Color(0xFF8E8E8E),
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
        onPressed: () => _showAddPersonDialog(context, ref),
        icon: Icon(
          AppIcons.personAdd,
          color: AppIcons.getColorForIcon(AppIcons.personAdd),
        ),
        label: const Text('Add person'),
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.md),
        color: color.withValues(alpha: 0.16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
