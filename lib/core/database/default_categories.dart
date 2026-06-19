import 'package:spendly/core/constants/app_enums.dart';

class DefaultCategorySeed {
  const DefaultCategorySeed({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });

  final String id;
  final String name;
  final String icon;
  final String color;
  final TransactionType type;
}

const defaultCategories = <DefaultCategorySeed>[
  DefaultCategorySeed(
    id: 'cat_salary',
    name: 'Salary',
    icon: 'payments',
    color: '#00A86B',
    type: TransactionType.income,
  ),
  DefaultCategorySeed(
    id: 'cat_freelance',
    name: 'Freelance',
    icon: 'work',
    color: '#13B77A',
    type: TransactionType.income,
  ),
  DefaultCategorySeed(
    id: 'cat_food',
    name: 'Food',
    icon: 'restaurant',
    color: '#F97316',
    type: TransactionType.expense,
  ),
  DefaultCategorySeed(
    id: 'cat_transport',
    name: 'Transport',
    icon: 'directions_bus',
    color: '#3B82F6',
    type: TransactionType.expense,
  ),
  DefaultCategorySeed(
    id: 'cat_shopping',
    name: 'Shopping',
    icon: 'shopping_bag',
    color: '#A855F7',
    type: TransactionType.expense,
  ),
  DefaultCategorySeed(
    id: 'cat_bills',
    name: 'Bills',
    icon: 'receipt_long',
    color: '#EF4444',
    type: TransactionType.expense,
  ),
  DefaultCategorySeed(
    id: 'cat_health',
    name: 'Health',
    icon: 'health_and_safety',
    color: '#14B8A6',
    type: TransactionType.expense,
  ),
  // Investment
  DefaultCategorySeed(
    id: 'cat_stocks',
    name: 'Stocks',
    icon: 'trending_up',
    color: '#8B5CF6',
    type: TransactionType.investment,
  ),
  DefaultCategorySeed(
    id: 'cat_mutual_funds',
    name: 'Mutual Funds',
    icon: 'account_balance',
    color: '#7C3AED',
    type: TransactionType.investment,
  ),
  DefaultCategorySeed(
    id: 'cat_crypto',
    name: 'Crypto',
    icon: 'currency_bitcoin',
    color: '#F59E0B',
    type: TransactionType.investment,
  ),
  DefaultCategorySeed(
    id: 'cat_fixed_deposit',
    name: 'Fixed Deposit',
    icon: 'lock',
    color: '#06B6D4',
    type: TransactionType.investment,
  ),
  DefaultCategorySeed(
    id: 'cat_goal_transfer',
    name: 'Goal Transfer',
    icon: 'savings',
    color: '#A855F7',
    type: TransactionType.investment,
  ),
];
