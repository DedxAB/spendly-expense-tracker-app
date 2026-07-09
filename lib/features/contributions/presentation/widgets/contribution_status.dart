import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/core/theme/app_design_tokens.dart';
import 'package:spendly/core/widgets/app_modal_surface.dart';
import 'package:spendly/core/utils/formatters.dart';
import 'package:spendly/features/contributions/domain/entities/contribution_entity.dart';
import 'package:spendly/features/contributions/presentation/providers/contributions_provider.dart';
import 'package:spendly/features/contributions/presentation/services/contribution_export_service.dart';
import 'package:spendly/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:spendly/features/user/presentation/providers/user_profile_provider.dart';

class ContributionStatusChip extends ConsumerWidget {
  const ContributionStatusChip({super.key, required this.expenseId});

  final String expenseId;

  void _openSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AppModalSurface(
        child: ContributorSettleSheet(expenseId: expenseId),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contributionsAsync = ref.watch(contributionStreamProvider(expenseId));

    return contributionsAsync.when(
      data: (contributions) {
        if (contributions.isEmpty) return const SizedBox.shrink();
        final settled = contributions.where((c) => c.isSettled).length;
        final allSettled = settled == contributions.length;
        return GestureDetector(
          onTap: () => _openSheet(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: allSettled
                          ? AppColors.homeAccentGreen.withValues(alpha: 0.1)
                          : AppColors.homeAccentPurple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          allSettled ? Icons.check_circle : Icons.people,
                          size: 10,
                          color: allSettled
                              ? AppColors.homeAccentGreen
                              : AppColors.homeAccentPurple,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          allSettled ? 'All paid' : '$settled/${contributions.length} paid',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: allSettled
                                ? AppColors.homeAccentGreen
                                : AppColors.homeAccentPurple,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right,
                    size: 12,
                    color: context.textSecondary.withValues(alpha: 0.4),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class ContributorSettleSheet extends ConsumerWidget {
  const ContributorSettleSheet({super.key, required this.expenseId});

  final String expenseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contributionsAsync = ref.watch(contributionStreamProvider(expenseId));
    final transactionsAsync = ref.watch(allTransactionsProvider);
    final userName = ref.watch(userProfileProvider).valueOrNull?.name;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: contributionsAsync.when(
          data: (contributions) {
            if (contributions.isEmpty) {
              return const SizedBox(
                height: 200,
                child: Center(child: Text('No contributors')),
              );
            }

            final settled = contributions.where((c) => c.isSettled).length;
            final total = contributions.fold<double>(0, (s, c) => s + c.amount);
            final settledAmt = contributions
                .where((c) => c.isSettled)
                .fold<double>(0, (s, c) => s + c.amount);

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                    color: context.textSecondary.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Contributors',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: context.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$settled of ${contributions.length} paid · ${Formatters.currency(total)} total',
                              style: TextStyle(
                                fontSize: 12,
                                color: context.textSecondary.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      transactionsAsync.when(
                        data: (txs) {
                          final expense = txs.where((t) => t.id == expenseId).firstOrNull;
                          if (expense == null) return const SizedBox.shrink();
                          return GestureDetector(
                            onTap: () async {
                              try {
                                await saveAndShareContributionInvoice(
                                  expense: expense,
                                  contributions: contributions,
                                  userName: userName,
                                );
                              } catch (_) {}
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                              decoration: BoxDecoration(
                                color: AppColors.homeAccentPurple.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.download, size: 13, color: AppColors.homeAccentPurple),
                                  const SizedBox(width: 4),
                                  Text(
                                    'PDF',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.homeAccentPurple,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
                if (settledAmt > 0 && settledAmt < total)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, size: 12, color: AppColors.homeAccentGreen),
                        const SizedBox(width: 4),
                        Text(
                          '${Formatters.currency(settledAmt)} collected',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.homeAccentGreen,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.45,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: contributions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (_, i) {
                      final c = contributions[i];
                      return _ContributorTile(contribution: c);
                    },
                  ),
                ),
              ],
            );
          },
          loading: () => const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => SizedBox(
            height: 200,
            child: Center(child: Text('$e')),
          ),
        ),
      ),
    );
  }
}

class _ContributorTile extends ConsumerWidget {
  const _ContributorTile({required this.contribution});
  final ContributionEntity contribution;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: contribution.isSettled
            ? AppColors.homeAccentGreen.withValues(alpha: 0.06)
            : context.textPrimary.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: contribution.isSettled
                  ? AppColors.homeAccentGreen.withValues(alpha: 0.15)
                  : context.textPrimary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              contribution.isSettled ? Icons.check_circle : Icons.person_outline,
              size: 18,
              color: contribution.isSettled
                  ? AppColors.homeAccentGreen
                  : context.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contribution.personName,
                  style: TextStyle(
                    color: context.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  contribution.isSettled
                      ? 'Paid ${contribution.settledAt != null ? Formatters.date(contribution.settledAt!) : ''}'
                      : Formatters.currency(contribution.amount),
                  style: TextStyle(
                    color: contribution.isSettled
                        ? AppColors.homeAccentGreen.withValues(alpha: 0.8)
                        : context.textSecondary.withValues(alpha: 0.7),
                    fontSize: 12,
                    fontWeight: contribution.isSettled ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          if (!contribution.isSettled)
            Text(
              Formatters.currency(contribution.amount),
              style: TextStyle(
                color: context.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              final actions = ref.read(contributionActionsProvider);
              if (contribution.isSettled) {
                actions.unsettle(contribution.id);
              } else {
                actions.settle(contribution.id);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: contribution.isSettled
                    ? context.textPrimary.withValues(alpha: 0.06)
                    : AppColors.homeAccentGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                contribution.isSettled ? 'Unsettle' : 'Settle',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: contribution.isSettled
                      ? context.textSecondary
                      : AppColors.homeAccentGreen,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
