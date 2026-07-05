import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:spendly/core/utils/formatters.dart';
import 'package:spendly/features/insights/domain/entities/expense_slice.dart';
import 'package:spendly/features/insights/domain/entities/income_expense_bar.dart';
import 'package:spendly/features/insights/domain/entities/insight_point.dart';

class InsightsExportService {
  Future<Uint8List> exportPdf({
    required DateTime month,
    required bool isYearly,
    String? userName,
    required double income,
    required double expense,
    double prevExpense = 0,
    required double? changePercent,
    required List<ExpenseSlice> distribution,
    Map<String, double> paymentMode = const {},
    required double budget,
    required double projected,
    required List<InsightPoint> trend,
    required List<IncomeExpenseBar> yearlyBars,
    pw.Font? lucideFont,
    pw.Font? baseFont,
  }) async {
    final pdf = pw.Document();

    final periodLabel = isYearly
        ? 'Year ${month.year}'
        : DateFormat('MMMM yyyy').format(month);

    pw.TextStyle style({
      double? fontSize,
      pw.FontWeight? fontWeight,
      PdfColor? color,
      pw.Font? font,
    }) =>
        pw.TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          font: font ?? baseFont,
        );

    final titleStyle = style(
      fontSize: 24,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.black,
    );
    final subtitleStyle = style(
      fontSize: 14,
      color: PdfColors.grey600,
    );
    final sectionTitleStyle = style(
      fontSize: 16,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.black,
    );
    final bodyStyle = style(fontSize: 11, color: PdfColors.black);
    final valueStyle = style(
      fontSize: 14,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.black,
    );
    final headerCellStyle = style(
      fontSize: 10,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.white,
    );
    final cellStyle = style(fontSize: 10, color: PdfColors.black);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          _buildHeader(periodLabel, userName, titleStyle, subtitleStyle),
          pw.SizedBox(height: 24),
          _buildSummaryRow(income, expense, valueStyle, bodyStyle),
          pw.SizedBox(height: 24),
          _buildSectionTitle(
            isYearly ? 'Monthly Burn Rate' : 'Daily Burn Rate',
            sectionTitleStyle,
          ),
          pw.SizedBox(height: 8),
          _buildBurnRateSection(expense, projected, month, isYearly, valueStyle, bodyStyle),
          pw.SizedBox(height: 24),
          _buildSectionTitle('Category Breakdown', sectionTitleStyle),
          pw.SizedBox(height: 8),
          _buildCategoryTable(distribution, bodyStyle, headerCellStyle, cellStyle, valueStyle, lucideFont),
          pw.SizedBox(height: 24),
          _buildSectionTitle('Spending Trend', sectionTitleStyle),
          pw.SizedBox(height: 8),
          _buildTrendSnapshot(trend, isYearly, bodyStyle, valueStyle),
          if (paymentMode.isNotEmpty && paymentMode.values.any((v) => v > 0)) ...[
            pw.SizedBox(height: 24),
            _buildSectionTitle('Payment Method', sectionTitleStyle),
            pw.SizedBox(height: 8),
            _buildPaymentModeTable(paymentMode, bodyStyle, headerCellStyle, cellStyle),
          ],
          if (budget > 0) ...[
            pw.SizedBox(height: 24),
            _buildSectionTitle('Budget Overview', sectionTitleStyle),
            pw.SizedBox(height: 8),
            _buildBudgetSection(expense, budget, projected, bodyStyle, valueStyle),
          ],
          pw.SizedBox(height: 24),
          _buildSummaryText(income, expense, prevExpense, changePercent, budget, projected, bodyStyle),
          pw.SizedBox(height: 32),
          _buildFooter(bodyStyle),
        ],
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader(
    String periodLabel,
    String? userName,
    pw.TextStyle titleStyle,
    pw.TextStyle subtitleStyle,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Spendly', style: titleStyle.copyWith(fontSize: 28)),
                if (userName != null) ...[
                  pw.SizedBox(height: 2),
                  pw.Text(userName, style: subtitleStyle.copyWith(fontSize: 12)),
                ],
              ],
            ),
            pw.Text(
              'Analytics Report',
              style: subtitleStyle.copyWith(fontSize: 16, color: PdfColors.grey700),
            ),
          ],
        ),
        pw.Divider(thickness: 2, color: PdfColors.black),
        pw.SizedBox(height: 12),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Period: $periodLabel', style: subtitleStyle),
            pw.Text(
              'Generated: ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
              style: subtitleStyle,
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildSummaryRow(
    double income,
    double expense,
    pw.TextStyle valueStyle,
    pw.TextStyle bodyStyle,
  ) {
    final savingsRate =
        income <= 0 ? 0.0 : ((income - expense) / income * 100).clamp(0, 100);
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
      children: [
        _summaryCard('Income', Formatters.rawCurrency(income), valueStyle, bodyStyle),
        _summaryCard('Expense', Formatters.rawCurrency(expense), valueStyle, bodyStyle),
        _summaryCard(
          'Saved',
          '${savingsRate.toStringAsFixed(0)}%',
          valueStyle.copyWith(
            color: savingsRate >= 20
                ? PdfColors.green700
                : savingsRate > 0
                    ? PdfColors.orange700
                    : PdfColors.red700,
          ),
          bodyStyle,
        ),
      ],
    );
  }

  pw.Widget _summaryCard(
    String label,
    String value,
    pw.TextStyle valueStyle,
    pw.TextStyle bodyStyle,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        children: [
          pw.Text(label.toUpperCase(), style: bodyStyle.copyWith(fontSize: 9, color: PdfColors.grey600)),
          pw.SizedBox(height: 6),
          pw.Text(value, style: valueStyle),
        ],
      ),
    );
  }

  pw.Widget _buildSummaryText(
    double income,
    double expense,
    double prevExpense,
    double? changePercent,
    double budget,
    double projected,
    pw.TextStyle bodyStyle,
  ) {
    final parts = <String>[];

    if (expense > 0) {
      final change = changePercent ?? (prevExpense > 0
          ? ((expense - prevExpense) / prevExpense * 100)
          : null);
      if (change != null) {
        final dir = change >= 0 ? 'increased' : 'decreased';
        parts.add(
          'Spending $dir by ${change.abs().toStringAsFixed(1)}% '
          'compared to the previous period.',
        );
      }
    }

    if (income > 0) {
      final savingsRate = ((income - expense) / income * 100).clamp(0, 100);
      if (savingsRate > 0) {
        final adj = savingsRate >= 20
            ? 'strong'
            : savingsRate >= 10
                ? 'moderate'
                : 'modest';
        parts.add(
          'You saved $adj ${savingsRate.toStringAsFixed(0)}% of your income.',
        );
      } else if (expense > income) {
        parts.add('Expenses exceeded income this period.');
      }
    }

    if (budget > 0 && expense > 0) {
      final pct = (expense / budget * 100).clamp(0, 100);
      final remaining = budget - expense;
      if (remaining > 0) {
        parts.add(
          'You have used ${pct.toStringAsFixed(0)}% of your budget '
          '(${Formatters.rawCurrency(remaining)} remaining).',
        );
      } else {
        parts.add(
          'You exceeded your budget by '
          '${Formatters.rawCurrency(remaining.abs())}.',
        );
      }
    }

    if (expense <= 0) {
      parts.add('No spending recorded for this period.');
    }

    if (parts.isEmpty) return pw.SizedBox.shrink();

    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Summary', style: bodyStyle.copyWith(
            fontWeight: pw.FontWeight.bold,
            fontSize: 13,
          )),
          pw.SizedBox(height: 6),
          ...parts.map((p) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4),
            child: pw.Text('\u2022 $p', style: bodyStyle),
          )),
        ],
      ),
    );
  }

  pw.Widget _buildBurnRateSection(
    double expense,
    double projected,
    DateTime month,
    bool isYearly,
    pw.TextStyle valueStyle,
    pw.TextStyle bodyStyle,
  ) {
    final now = DateTime.now();
    final isCurrentYear = month.year == now.year;
    final isCurrentMonth = isCurrentYear && month.month == now.month;

    String avgLabel;
    double avgValue;
    String title;
    String projectedLabel;
    double displayProjected;

    if (isYearly) {
      final monthsElapsed = isCurrentYear ? now.month : 12;
      avgValue = monthsElapsed <= 0 ? 0.0 : expense / monthsElapsed;
      avgLabel = 'Avg / Month';
      title = 'Total Year';
      displayProjected = monthsElapsed <= 0 ? 0.0 : (expense / monthsElapsed) * 12;
      projectedLabel = 'Projected EoY';
    } else {
      final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
      final daysElapsed = isCurrentMonth ? now.day : daysInMonth;
      avgValue = daysElapsed <= 0 ? 0.0 : expense / daysElapsed;
      avgLabel = 'Avg / Day';
      title = 'Total Month';
      displayProjected = projected;
      projectedLabel = 'Projected';
    }

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
      children: [
        _summaryCard(title, Formatters.rawCurrency(expense), valueStyle, bodyStyle),
        _summaryCard(avgLabel, Formatters.rawCurrency(avgValue), valueStyle, bodyStyle),
        if (displayProjected > 0)
          _summaryCard(projectedLabel, Formatters.rawCurrency(displayProjected), valueStyle, bodyStyle),
      ],
    );
  }

  List<_AggregatedPoint> _aggregateTrend(
    List<InsightPoint> trend,
    bool isYearly,
  ) {
    if (trend.isEmpty) return const [];

    if (isYearly) {
      return [
        for (final point in trend)
          if (point.value > 0)
            _AggregatedPoint(
              label: DateFormat('MMM').format(point.date),
              value: point.value,
            ),
      ];
    }

    final month = trend.first.date;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final weekCount = ((daysInMonth - 1) ~/ 7) + 1;
    final totals = List<double>.filled(weekCount, 0);

    for (final point in trend) {
      final weekIndex = (point.date.day - 1) ~/ 7;
      if (weekIndex >= 0 && weekIndex < totals.length) {
        totals[weekIndex] += point.value;
      }
    }

    return [
      for (var i = 0; i < totals.length; i++)
        if (totals[i] > 0)
          _AggregatedPoint(
            label: 'w${i + 1}',
            value: totals[i],
          ),
    ];
  }

  pw.Widget _buildTrendSnapshot(
    List<InsightPoint> trend,
    bool isYearly,
    pw.TextStyle bodyStyle,
    pw.TextStyle valueStyle,
  ) {
    final aggregated = _aggregateTrend(trend, isYearly);
    if (aggregated.isEmpty) {
      return pw.Text('No trend data available.', style: bodyStyle);
    }

    final activeBuckets = aggregated.length;
    final peak = aggregated.fold<_AggregatedPoint>(
      aggregated.first,
      (a, b) => a.value >= b.value ? a : b,
    );
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
      children: [
        _snapshotTile(
          isYearly ? 'Active Months' : 'Active Weeks',
          activeBuckets.toString(),
          bodyStyle,
          valueStyle,
        ),
        _snapshotTile(
          'Peak ${isYearly ? 'Month' : 'Week'}',
          Formatters.rawCurrency(peak.value),
          bodyStyle,
          valueStyle,
        ),
      ],
    );
  }

  pw.Widget _snapshotTile(
    String label,
    String value,
    pw.TextStyle bodyStyle,
    pw.TextStyle valueStyle,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Column(
        children: [
          pw.Text(label.toUpperCase(), style: bodyStyle.copyWith(fontSize: 9, color: PdfColors.grey600)),
          pw.SizedBox(height: 4),
          pw.Text(value, style: valueStyle),
        ],
      ),
    );
  }

  pw.Widget _buildCategoryTable(
    List<ExpenseSlice> distribution,
    pw.TextStyle bodyStyle,
    pw.TextStyle headerCellStyle,
    pw.TextStyle cellStyle,
    pw.TextStyle valueStyle,
    pw.Font? lucideFont,
  ) {
    final sorted = [...distribution]..sort((a, b) => b.total.compareTo(a.total));
    final total = sorted.fold<double>(0, (s, e) => s + e.total);

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey800),
          children: [
            _tableCell('Category', headerCellStyle, pw.TextAlign.left),
            _tableCell('Amount', headerCellStyle, pw.TextAlign.right),
            _tableCell('%', headerCellStyle, pw.TextAlign.right),
          ],
        ),
        ...sorted.map(
          (slice) {
            final pct = total <= 0 ? 0.0 : (slice.total / total) * 100;
            return pw.TableRow(
              children: [
                _categoryCell(slice, cellStyle, lucideFont),
                _tableCell(
                  Formatters.rawCurrency(slice.total),
                  cellStyle.copyWith(fontWeight: pw.FontWeight.bold),
                  pw.TextAlign.right,
                ),
                _tableCell(
                  '${pct.toStringAsFixed(1)}%',
                  cellStyle,
                  pw.TextAlign.right,
                ),
              ],
            );
          },
        ),
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey100),
          children: [
            _tableCell(
              'Total',
              bodyStyle.copyWith(fontWeight: pw.FontWeight.bold),
              pw.TextAlign.left,
            ),
            _tableCell(
              Formatters.rawCurrency(total),
              valueStyle,
              pw.TextAlign.right,
            ),
            _tableCell('100%', valueStyle, pw.TextAlign.right),
          ],
        ),
      ],
    );
  }

  pw.Widget _categoryCell(
    ExpenseSlice slice,
    pw.TextStyle textStyle,
    pw.Font? lucideFont,
  ) {
    if (lucideFont == null) {
      return _tableCell(slice.category, textStyle, pw.TextAlign.left);
    }

    final iconChar = _iconForCategory(slice.category);
    final iconPdfColor = _parsePdfColor(slice.color);

    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Row(
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.only(right: 6),
            child: pw.Text(
              iconChar,
              style: pw.TextStyle(
                font: lucideFont,
                fontSize: 13,
                color: iconPdfColor,
              ),
            ),
          ),
          pw.Text(slice.category, style: textStyle),
        ],
      ),
    );
  }

  PdfColor _parsePdfColor(String hex) {
    try {
      final normalized = hex.replaceFirst('#', '');
      final value = int.parse(normalized, radix: 16);
      return PdfColor(
        ((value >> 16) & 0xFF) / 255.0,
        ((value >> 8) & 0xFF) / 255.0,
        (value & 0xFF) / 255.0,
      );
    } catch (_) {
      return PdfColors.black;
    }
  }

  String _iconForCategory(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('food') ||
        name.contains('dining') ||
        name.contains('restaurant')) {
      return String.fromCharCode(58102); // utensils
    }
    if (name.contains('transport') ||
        name.contains('uber') ||
        name.contains('taxi') ||
        name.contains('car') ||
        name.contains('bus')) {
      return String.fromCharCode(57813); // car
    }
    if (name.contains('shopping') ||
        name.contains('shop') ||
        name.contains('store') ||
        name.contains('bag') ||
        name.contains('grocery')) {
      return String.fromCharCode(57691); // shoppingBag
    }
    if (name.contains('bill') ||
        name.contains('utility') ||
        name.contains('electric') ||
        name.contains('receipt') ||
        name.contains('util')) {
      return String.fromCharCode(58323); // receipt
    }
    if (name.contains('health') ||
        name.contains('medical') ||
        name.contains('hospital')) {
      return String.fromCharCode(58222); // heartPulse
    }
    if (name.contains('gym') ||
        name.contains('workout') ||
        name.contains('fitness') ||
        name.contains('dumbbell')) {
      return String.fromCharCode(58273); // dumbbell
    }
    if (name.contains('travel') ||
        name.contains('flight') ||
        name.contains('air') ||
        name.contains('trip')) {
      return String.fromCharCode(57822); // plane
    }
    if (name.contains('salary') ||
        name.contains('income') ||
        name.contains('transfer') ||
        name.contains('freelance') ||
        name.contains('business') ||
        name.contains('work')) {
      return String.fromCharCode(58808); // handCoins
    }
    if (name.contains('rent') ||
        name.contains('home') ||
        name.contains('house')) {
      return String.fromCharCode(57589); // house
    }
    return String.fromCharCode(58323); // receipt fallback
  }

  pw.Widget _buildPaymentModeTable(
    Map<String, double> paymentMode,
    pw.TextStyle bodyStyle,
    pw.TextStyle headerCellStyle,
    pw.TextStyle cellStyle,
  ) {
    final items = [
      {'label': 'UPI', 'pct': paymentMode['upi'] ?? 0},
      {'label': 'Cash', 'pct': paymentMode['cash'] ?? 0},
      {'label': 'Card', 'pct': paymentMode['card'] ?? 0},
    ];

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey800),
          children: [
            _tableCell('Method', headerCellStyle, pw.TextAlign.left),
            _tableCell('Share', headerCellStyle, pw.TextAlign.right),
          ],
        ),
        ...items.map(
          (item) => pw.TableRow(
            children: [
              _tableCell(item['label'] as String, cellStyle, pw.TextAlign.left),
              _tableCell(
                '${(item['pct'] as double).toStringAsFixed(1)}%',
                cellStyle,
                pw.TextAlign.right,
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildBudgetSection(
    double expense,
    double budget,
    double projected,
    pw.TextStyle bodyStyle,
    pw.TextStyle valueStyle,
  ) {
    final pct = budget <= 0 ? 0.0 : (expense / budget) * 100;
    final remaining = budget - expense;
    final isOver = expense > budget;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Monthly Budget', style: bodyStyle.copyWith(fontWeight: pw.FontWeight.bold)),
            pw.Text(Formatters.rawCurrency(budget), style: valueStyle),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Used: ${pct.toStringAsFixed(1)}% (${Formatters.rawCurrency(expense)})',
          style: bodyStyle,
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          isOver
              ? 'Over budget by ${Formatters.rawCurrency(remaining.abs())}'
              : 'Remaining: ${Formatters.rawCurrency(remaining)}',
          style: bodyStyle.copyWith(
            color: isOver ? PdfColors.red700 : PdfColors.green700,
          ),
        ),
        if (projected > 0) ...[
          pw.SizedBox(height: 4),
          pw.Text(
            'Projected total: ${Formatters.rawCurrency(projected)}',
            style: bodyStyle,
          ),
        ],
      ],
    );
  }

  pw.Widget _buildFooter(pw.TextStyle bodyStyle) {
    return pw.Column(
      children: [
        pw.Divider(thickness: 1, color: PdfColors.grey300),
        pw.SizedBox(height: 8),
        pw.Text(
          'Generated by Spendly - Personal Finance Tracker',
          style: bodyStyle.copyWith(color: PdfColors.grey600, fontSize: 9),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }

  pw.Widget _buildSectionTitle(String title, pw.TextStyle style) {
    return pw.Text(title, style: style);
  }

  pw.Widget _tableCell(
    String text,
    pw.TextStyle style,
    pw.TextAlign align,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(text, style: style, textAlign: align),
    );
  }
}

class _AggregatedPoint {
  const _AggregatedPoint({required this.label, required this.value});
  final String label;
  final double value;
}
