import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:spendly/core/utils/formatters.dart';
import 'package:spendly/features/insights/domain/entities/expense_slice.dart';
import 'package:spendly/features/insights/domain/entities/income_expense_bar.dart';
import 'package:spendly/features/insights/domain/entities/insight_point.dart';

class InsightsExportService {
  Future<void> exportPdf({
    required DateTime month,
    required bool isYearly,
    required double income,
    required double expense,
    required double? changePercent,
    required List<ExpenseSlice> distribution,
    Map<String, double> paymentMode = const {},
    required double budget,
    required double projected,
    required List<InsightPoint> trend,
    required List<IncomeExpenseBar> yearlyBars,
  }) async {
    final pdf = pw.Document();

    final periodLabel = isYearly
        ? 'Year ${month.year}'
        : DateFormat('MMMM yyyy').format(month);

    final titleStyle = pw.TextStyle(
      fontSize: 24,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.black,
    );
    final subtitleStyle = pw.TextStyle(
      fontSize: 14,
      color: PdfColors.grey600,
    );
    final sectionTitleStyle = pw.TextStyle(
      fontSize: 16,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.black,
    );
    final bodyStyle = pw.TextStyle(fontSize: 11, color: PdfColors.black);
    final valueStyle = pw.TextStyle(
      fontSize: 14,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.black,
    );
    final headerCellStyle = pw.TextStyle(
      fontSize: 10,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.white,
    );
    final cellStyle = pw.TextStyle(fontSize: 10, color: PdfColors.black);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          _buildHeader(periodLabel, month, isYearly, titleStyle, subtitleStyle),
          pw.SizedBox(height: 24),
          _buildSummaryRow(income, expense, valueStyle, bodyStyle),
          pw.SizedBox(height: 24),
          _buildSectionTitle('Daily Burn Rate', sectionTitleStyle),
          pw.SizedBox(height: 8),
          _buildBurnRateSection(expense, projected, valueStyle, bodyStyle),
          pw.SizedBox(height: 24),
          _buildSectionTitle('Category Breakdown', sectionTitleStyle),
          pw.SizedBox(height: 8),
          _buildCategoryTable(distribution, bodyStyle, headerCellStyle, cellStyle, valueStyle),
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
          _buildChangePercent(changePercent, bodyStyle),
          pw.SizedBox(height: 32),
          _buildFooter(bodyStyle),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final fileName = 'Spendly_Report_${DateFormat('yyyy-MM').format(month)}.pdf';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        subject: 'Spendly Report - $periodLabel',
        text: 'Spendly Analytics Report for $periodLabel',
      ),
    );
  }

  pw.Widget _buildHeader(
    String periodLabel,
    DateTime month,
    bool isYearly,
    pw.TextStyle titleStyle,
    pw.TextStyle subtitleStyle,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Spendly', style: titleStyle.copyWith(fontSize: 28)),
        pw.SizedBox(height: 4),
        pw.Text(
          'Analytics Report',
          style: subtitleStyle.copyWith(fontSize: 18, color: PdfColors.grey700),
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

  pw.Widget _buildBurnRateSection(
    double expense,
    double projected,
    pw.TextStyle valueStyle,
    pw.TextStyle bodyStyle,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Total spent: ${Formatters.rawCurrency(expense)}', style: bodyStyle),
        pw.SizedBox(height: 4),
        if (projected > 0)
          pw.Text(
            'Projected month end: ${Formatters.rawCurrency(projected)}',
            style: bodyStyle,
          ),
      ],
    );
  }

  pw.Widget _buildTrendSnapshot(
    List<InsightPoint> trend,
    bool isYearly,
    pw.TextStyle bodyStyle,
    pw.TextStyle valueStyle,
  ) {
    if (trend.isEmpty) {
      return pw.Text('No trend data available.', style: bodyStyle);
    }

    final activeBuckets = trend.where((p) => p.value > 0).length;
    final total = trend.fold<double>(0, (s, e) => s + e.value);
    final peak = trend.fold<InsightPoint>(
      trend.first,
      (a, b) => a.value >= b.value ? a : b,
    );
    final avgBase = isYearly ? DateTime.now().month : DateTime(
      trend.first.date.year,
      trend.first.date.month + 1,
      0,
    ).day;
    final avg = avgBase <= 0 ? 0.0 : total / avgBase;

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
          isYearly ? 'Avg / Month' : 'Avg / Day',
          Formatters.rawCurrency(avg),
          bodyStyle,
          valueStyle,
        ),
        _snapshotTile(
          isYearly ? 'Peak Month' : 'Peak Week',
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
                _tableCell(slice.category, cellStyle, pw.TextAlign.left),
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

  pw.Widget _buildChangePercent(double? changePercent, pw.TextStyle bodyStyle) {
    if (changePercent == null) return pw.SizedBox.shrink();
    final direction = changePercent >= 0 ? 'increased' : 'decreased';
    return pw.Text(
      'Spending $direction by ${changePercent.abs().toStringAsFixed(1)}% '
      'compared to the previous period.',
      style: bodyStyle.copyWith(
        color: changePercent >= 0 ? PdfColors.red700 : PdfColors.green700,
        fontWeight: pw.FontWeight.bold,
      ),
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
