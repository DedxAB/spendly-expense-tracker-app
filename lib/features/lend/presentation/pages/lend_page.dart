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
import 'package:spendly/core/widgets/swipe_hint_coach.dart';
import 'package:spendly/features/lend/domain/repositories/lend_repository.dart';
import 'package:spendly/features/lend/data/repositories/lend_repository_impl.dart';
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
              Row(
                children: [
                  Text('People', style: AppTypography.sectionTitle(context)),
                  const Spacer(),
                  const SwipeActionsInfoButton(
                    tooltip: 'Lend and borrow swipe help',
                    title: 'Lend & Borrow actions',
                    message:
                        'People can be swiped to edit or delete from the list.',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              if (data.peopleBalances.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: AppSpacing.xs),
                  child: _InlineEmpty(
                    icon: AppIcons.usersRound,
                    message: 'No people yet. Tap + to add your first person.',
                  ),
                ),
              ...data.peopleBalances.indexed.map((entry) {
                final index = entry.$1;
                final item = entry.$2;
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
                      color: _greenTint(context),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(AppIcons.edit, color: _green(context)),
                          const SizedBox(width: 8),
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
                          const SizedBox(width: 8),
                          Icon(
                            AppIcons.trash,
                            color: _red(context),
                          ),
                        ],
                      ),
                    ),
                    child: SwipeHintCoach(
                      enabled: index == 0,
                      child: InkWell(
                        onTap: () => context.push('/lend/${item.person.id}'),
                        child: Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: context.surface,
                          border: Border.all(color: context.border),
                          borderRadius: BorderRadius.circular(AppRadii.lg),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _purple(context).withValues(
                                  alpha: 0.14,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                AppIcons.usersRound,
                                color: _purple(context),
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
                                        ? _green(context)
                                        : _red(context),
                                    fontWeight: FontWeight.w800,
                                    fontSize: AppFontSizes.title,
                                  ),
                                ),
                                AmountView(
                                  item.netBalance.abs(),
                                  style: TextStyle(
                                    color: isPositive
                                        ? _green(context)
                                        : _red(context),
                                    fontWeight: FontWeight.w800,
                                    fontSize: AppFontSizes.title,
                                  ),
                                  maskColor: isPositive
                                      ? _green(context)
                                      : _red(context),
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
                  ),
                );
              }),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Failed to load: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final repo = ref.read(lendRepositoryProvider);
          _showAddPersonDialog(context, repo);
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
    final accent = isReceive ? _green(context) : _red(context);
    final tint = isReceive ? _greenTint(context) : _redTint(context);
    final borderColor = accent.withValues(
      alpha: _isDark(context) ? 0.45 : 0.4,
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        color: tint,
        border: Border.all(color: borderColor),
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
              color: accent,
              fontWeight: FontWeight.w800,
              fontSize: AppFontSizes.heading,
            ),
            maskColor: accent,
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
