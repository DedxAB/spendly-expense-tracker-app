import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_summary.freezed.dart';

@freezed
class DashboardSummary with _$DashboardSummary {
  const factory DashboardSummary({
    required double currentBalance,
    required double monthlyIncome,
    required double monthlyExpense,
    required double monthlyInvestment,
    required double remainingBudget,
  }) = _DashboardSummary;
}
