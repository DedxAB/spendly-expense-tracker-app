import 'dart:io';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:spendly/core/theme/app_design_tokens.dart';
import 'package:spendly/core/utils/formatters.dart';
import 'package:spendly/features/contributions/domain/entities/contribution_entity.dart';
import 'package:spendly/features/transactions/domain/entities/transaction_entity.dart';

Future<Uint8List> generateContributionInvoice({
  required TransactionEntity expense,
  required List<ContributionEntity> contributions,
  required pw.Font baseFont,
  String? userName,
}) async {
  final pdf = pw.Document();

  final totalShare = contributions.fold<double>(0, (s, c) => s + c.amount);
  final selfAmount = expense.amount - totalShare;
  final showSelf = selfAmount > 0 && contributions.isNotEmpty;
  final settled = contributions.where((c) => c.isSettled).length;
  final settledAmount = contributions
      .where((c) => c.isSettled)
      .fold<double>(0, (s, c) => s + c.amount);
  final pendingAmount = totalShare - settledAmount;

  pw.TextStyle style({
    double? fontSize,
    pw.FontWeight? fontWeight,
    PdfColor? color,
  }) =>
      pw.TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        font: baseFont,
      );

  final titleStyle = style(
    fontSize: AppFontSizes.largeHeading,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.black,
  );
  final subtitleStyle = style(
    fontSize: AppFontSizes.bodyLarge,
    color: PdfColors.grey600,
  );
  final sectionTitleStyle = style(
    fontSize: AppFontSizes.title,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.black,
  );
  final bodyStyle = style(fontSize: AppFontSizes.small, color: PdfColors.black);
  final valueStyle = style(
    fontSize: AppFontSizes.bodyLarge,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.black,
  );
  final headerCellStyle = style(
    fontSize: AppFontSizes.caption,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.white,
  );
  final cellStyle = style(fontSize: AppFontSizes.caption, color: PdfColors.black);

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (context) => [
        _buildHeader(expense, userName, titleStyle, subtitleStyle),
        pw.SizedBox(height: 24),
        _buildExpenseSummaryCard(expense, valueStyle, bodyStyle),
        pw.SizedBox(height: 24),
        _buildSectionTitle(
          'Contributors ($settled/${contributions.length} paid)',
          sectionTitleStyle,
        ),
        pw.SizedBox(height: 8),
        _buildContributorTable(contributions, totalShare, showSelf, selfAmount, userName, bodyStyle, headerCellStyle, cellStyle, valueStyle),
        pw.SizedBox(height: 24),
        _buildSummaryBox(expense, totalShare, settledAmount, pendingAmount, showSelf, selfAmount, userName, bodyStyle, style),
        pw.SizedBox(height: 32),
        _buildFooter(bodyStyle),
      ],
    ),
  );

  return pdf.save();
}

pw.Widget _buildHeader(
  TransactionEntity expense,
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
              pw.Text('Spendly', style: titleStyle.copyWith(fontSize: AppFontSizes.largeDisplay)),
              pw.SizedBox(height: 2),
              pw.Text(userName ?? 'User', style: subtitleStyle.copyWith(fontSize: AppFontSizes.label)),
            ],
          ),
          pw.Text(
            'Expense Breakdown',
            style: subtitleStyle.copyWith(fontSize: AppFontSizes.title, color: PdfColors.grey700),
          ),
        ],
      ),
      pw.Divider(thickness: 2, color: PdfColors.black),
      pw.SizedBox(height: 12),
      pw.Text(
        'Generated: ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
        style: subtitleStyle,
      ),
    ],
  );
}

pw.Widget _buildExpenseSummaryCard(
  TransactionEntity expense,
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
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('TOTAL EXPENSE', style: bodyStyle.copyWith(fontSize: AppFontSizes.caption, color: PdfColors.grey600)),
            pw.Text(Formatters.rawCurrency(expense.amount), style: valueStyle),
          ],
        ),
        if (expense.note != null && expense.note!.isNotEmpty) ...[
          pw.SizedBox(height: 6),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('NOTE', style: bodyStyle.copyWith(fontSize: AppFontSizes.caption, color: PdfColors.grey600)),
              pw.Text(expense.note!, style: bodyStyle),
            ],
          ),
        ],
      ],
    ),
  );
}

pw.Widget _buildSectionTitle(String title, pw.TextStyle style) {
  return pw.Text(title, style: style);
}

pw.Widget _buildContributorTable(
  List<ContributionEntity> contributions,
  double totalShare,
  bool showSelf,
  double selfAmount,
  String? userName,
  pw.TextStyle bodyStyle,
  pw.TextStyle headerCellStyle,
  pw.TextStyle cellStyle,
  pw.TextStyle valueStyle,
) {
  return pw.Table(
    border: pw.TableBorder.all(color: PdfColors.grey300),
    columnWidths: {
      0: const pw.FlexColumnWidth(0.5),
      1: const pw.FlexColumnWidth(3),
      2: const pw.FlexColumnWidth(1.5),
      3: const pw.FlexColumnWidth(1),
    },
    children: [
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.grey800),
        children: ['#', 'Person', 'Amount', 'Status']
            .map((h) => _tableCell(h, headerCellStyle, pw.TextAlign.left))
            .toList(),
      ),
      if (showSelf)
        pw.TableRow(
          children: [
            _tableCell('', cellStyle, pw.TextAlign.center),
            _tableCell(userName ?? 'User', cellStyle.copyWith(fontWeight: pw.FontWeight.bold), pw.TextAlign.left),
            _tableCell(Formatters.rawCurrency(selfAmount), cellStyle.copyWith(fontWeight: pw.FontWeight.bold), pw.TextAlign.right),
            _tableCell('-', cellStyle, pw.TextAlign.center),
          ],
        ),
      ...contributions.asMap().entries.map((entry) {
        final i = entry.key;
        final c = entry.value;
        return pw.TableRow(
          children: [
            _tableCell('${i + 1}', cellStyle, pw.TextAlign.center),
            _tableCell(c.personName, cellStyle, pw.TextAlign.left),
            _tableCell(Formatters.rawCurrency(c.amount), cellStyle.copyWith(fontWeight: pw.FontWeight.bold), pw.TextAlign.right),
            _tableCell(
              c.isSettled ? 'Paid' : 'Pending',
              cellStyle.copyWith(
                fontWeight: pw.FontWeight.bold,
                color: c.isSettled ? PdfColors.green700 : PdfColors.red700,
              ),
              pw.TextAlign.center,
            ),
          ],
        );
      }),
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.grey100),
        children: [
          _tableCell('', cellStyle, pw.TextAlign.left),
          _tableCell('Total', bodyStyle.copyWith(fontWeight: pw.FontWeight.bold), pw.TextAlign.left),
          _tableCell(Formatters.rawCurrency(totalShare + (showSelf ? selfAmount : 0)), valueStyle, pw.TextAlign.right),
          _tableCell('', cellStyle, pw.TextAlign.left),
        ],
      ),
    ],
  );
}

pw.Widget _buildSummaryBox(
  TransactionEntity expense,
  double totalShare,
  double settledAmount,
  double pendingAmount,
  bool showSelf,
  double selfAmount,
  String? userName,
  pw.TextStyle bodyStyle,
  pw.TextStyle Function({double? fontSize, pw.FontWeight? fontWeight, PdfColor? color}) style,
) {
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
          fontSize: AppFontSizes.body,
        )),
        pw.SizedBox(height: 8),
        _summaryRow('Total Expense', Formatters.rawCurrency(expense.amount), bodyStyle, style),
        if (showSelf) ...[
          pw.SizedBox(height: 6),
          _summaryRow("${userName ?? 'User'}'s Share", Formatters.rawCurrency(selfAmount), bodyStyle, style),
        ],
        pw.SizedBox(height: 6),
        _summaryRow('Collected', Formatters.rawCurrency(settledAmount), bodyStyle, style,
            color: PdfColors.green700),
        pw.SizedBox(height: 6),
        _summaryRow('Pending', Formatters.rawCurrency(pendingAmount), bodyStyle, style,
            color: pendingAmount > 0 ? PdfColors.red700 : PdfColors.grey600),
      ],
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
        style: bodyStyle.copyWith(color: PdfColors.grey600, fontSize: AppFontSizes.caption),
        textAlign: pw.TextAlign.center,
      ),
    ],
  );
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

pw.Widget _summaryRow(
  String label,
  String value,
  pw.TextStyle bodyStyle,
  pw.TextStyle Function({double? fontSize, pw.FontWeight? fontWeight, PdfColor? color}) style, {
  PdfColor? color,
}) {
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Text(label, style: bodyStyle),
      pw.Text(value, style: style(fontWeight: pw.FontWeight.bold, color: color)),
    ],
  );
}

Future<void> saveAndShareContributionInvoice({
  required TransactionEntity expense,
  required List<ContributionEntity> contributions,
  String? userName,
}) async {
  try {
    final fontData = await rootBundle.load(
      'assets/fonts/general_sans/GeneralSans-Regular.ttf',
    );
    final baseFont = pw.Font.ttf(fontData);

    final pdfBytes = await generateContributionInvoice(
      expense: expense,
      contributions: contributions,
      baseFont: baseFont,
      userName: userName,
    );
    final tempDir = await getTemporaryDirectory();
    final fileName =
        'Spendly_Contribution_Report_${DateFormat('yyyy-MM-dd').format(expense.date)}.pdf';
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(pdfBytes);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/pdf')],
        subject: 'Expense Breakdown',
        text: 'Expense Breakdown - ${DateFormat('dd MMM yyyy').format(expense.date)}',
      ),
    );
  } catch (e) {
    // Silently handle
  }
}
