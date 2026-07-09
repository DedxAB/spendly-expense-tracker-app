import 'package:flutter/material.dart';
import 'package:spendly/core/constants/app_enums.dart';
import 'package:spendly/core/theme/app_design_tokens.dart';
import 'package:spendly/core/theme/app_icons.dart';
import 'package:spendly/core/theme/app_typography.dart';
import 'package:spendly/core/utils/formatters.dart';
import 'package:spendly/core/widgets/amount_mask.dart';
import 'package:spendly/features/categories/domain/entities/category_entity.dart';
import 'package:spendly/features/transactions/domain/entities/transaction_entity.dart';

IconData _categoryIcon(String categoryName) {
  return AppIcons.getIconForCategory(categoryName);
}

Color _categoryIconColor(CategoryEntity? category, TransactionType type) {
  if (category != null) {
    return AppIcons.getColorForCategory(category.name, type);
  }
  return switch (type) {
    TransactionType.income => AppColors.income,
    TransactionType.investment => const Color(0xFF8B5CF6),
    TransactionType.expense => AppColors.expense,
  };
}

String _transactionTitle(TransactionEntity tx, Map<String, CategoryEntity> categoryById) {
  return tx.note?.trim().isNotEmpty == true
      ? tx.note!.trim()
      : (categoryById[tx.categoryId]?.name ?? tx.categoryId);
}

String _transactionSubtitle(TransactionEntity tx, Map<String, CategoryEntity> categoryById) {
  return categoryById[tx.categoryId]?.name ?? tx.categoryId;
}

class TransactionRow extends StatelessWidget {
  const TransactionRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.type,
    required this.isLast,
    required this.dateLabel,
    required this.icon,
    required this.iconColor,
    this.paymentMode,
    this.cardType,
    this.recoveredAmount,
  });

  final double? recoveredAmount;

  factory TransactionRow.fromEntity({
    required TransactionEntity tx,
    required Map<String, CategoryEntity> categoryById,
    required String dateLabel,
    required bool isLast,
    Key? key,
  }) {
    return TransactionRow(
      key: key,
      title: _transactionTitle(tx, categoryById),
      subtitle: _transactionSubtitle(tx, categoryById),
      amount: tx.amount,
      type: tx.type,
      isLast: isLast,
      dateLabel: dateLabel,
      icon: _categoryIcon(categoryById[tx.categoryId]?.name ?? tx.categoryId),
      iconColor: _categoryIconColor(categoryById[tx.categoryId], tx.type),
      paymentMode: tx.paymentMode,
      cardType: tx.cardType,
      recoveredAmount: tx.type == TransactionType.expense ? tx.recoveredAmount : null,
    );
  }

  final String title;
  final String subtitle;
  final double amount;
  final TransactionType type;
  final bool isLast;
  final String dateLabel;
  final IconData icon;
  final Color iconColor;
  final PaymentMode? paymentMode;
  final CardType? cardType;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : BorderSide(color: context.border.withValues(alpha: 0.6)),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: context.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: context.border.withValues(alpha: 0.6)),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.textPrimary,
                    fontSize: AppFontSizes.bodyLarge,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        subtitle,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.textSecondary,
                          fontSize: AppFontSizes.label,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    _TagChip(
                      label: typeLabel(type),
                      tint: categoryTint(type),
                    ),
                    if (paymentMode != null) ...[
                      const SizedBox(width: 4),
                      _TagChip(
                        label: transactionPaymentLabel(
                          type: type,
                          paymentMode: paymentMode!,
                          cardType: cardType,
                        ),
                        tint: paymentModeTint(paymentMode!),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _AmountWithSign(
                amount: amount,
                type: type,
                textColor: type == TransactionType.income
                    ? context.homeAccentGreen
                    : type == TransactionType.investment
                    ? AppColors.homeAccentPurple
                    : context.textPrimary,
              ),
              if (recoveredAmount != null && recoveredAmount! > 0) ...[
                const SizedBox(height: 2),
                Text(
                  '${Formatters.currency(recoveredAmount!)} recovered',
                  style: TextStyle(
                    color: AppColors.homeAccentGreen,
                    fontSize: AppFontSizes.caption,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                dateLabel,
                style: TextStyle(color: context.textSecondary, fontSize: AppFontSizes.small),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label, required this.tint});

  final String label;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: tint.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: tint,
          fontSize: AppFontSizes.caption,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

String typeLabel(TransactionType type) {
  return switch (type) {
    TransactionType.income => 'Income',
    TransactionType.investment => 'Asset',
    TransactionType.expense => 'Expense',
  };
}

Color categoryTint(TransactionType type) {
  return switch (type) {
    TransactionType.income => AppColors.homeAccentGreen,
    TransactionType.investment => AppColors.homeAccentPurple,
    TransactionType.expense => AppColors.homeAccentRed,
  };
}

String amountWithSign(double amount, TransactionType type) {
  if (type == TransactionType.income) {
    return '+${Formatters.currency(amount)}';
  }
  if (type == TransactionType.investment && amount < 0) {
    return '+${Formatters.currency(amount.abs())}';
  }
  return '-${Formatters.currency(amount.abs())}';
}

class _AmountWithSign extends StatelessWidget {
  const _AmountWithSign({
    required this.amount,
    required this.type,
    required this.textColor,
  });

  final double amount;
  final TransactionType type;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final isPositive = type == TransactionType.income ||
        (type == TransactionType.investment && amount < 0);
    final sign = isPositive ? '+' : '-';
    final absAmount = amount.abs();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          sign,
          style: TextStyle(
            color: textColor,
            fontSize: AppFontSizes.subhead,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 1),
        AmountView(
          absAmount,
          style: AppTypography.amount(context, fontSize: AppFontSizes.subhead).copyWith(
            color: textColor,
          ),
          maskColor: textColor,
          maskWidth: 5,
          maskHeight: 15,
          maskSpacing: 2,
          maskRadius: 0,
        ),
      ],
    );
  }
}

Color paymentModeTint(PaymentMode mode) {
  return switch (mode) {
    PaymentMode.cash => AppColors.homeAccentGreen,
    PaymentMode.upi => const Color(0xFF4A7AD4),
    PaymentMode.card => AppColors.homeAccentPurple,
  };
}
