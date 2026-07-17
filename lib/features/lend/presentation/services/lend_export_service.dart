import 'dart:io';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:spendly/core/constants/app_enums.dart';
import 'package:spendly/core/theme/app_design_tokens.dart';
import 'package:spendly/core/utils/formatters.dart';
import 'package:spendly/features/lend/domain/entities/lend_entry_entity.dart';
import 'package:spendly/features/lend/domain/entities/lend_settlement_event_entity.dart';

Future<void> saveAndShareLendHistory({
  required String personName,
  required List<LendEntryEntity> entries,
  required List<LendSettlementEventEntity> settlementEvents,
  required double totalLent,
  required double totalBorrowed,
  required double net,
}) async {
  try {
    final fontData = await rootBundle.load(
      'assets/fonts/general_sans/GeneralSans-Regular.ttf',
    );
    final baseFont = pw.Font.ttf(fontData);

    final pdfBytes = await _generateLendPdf(
      personName: personName,
      entries: entries,
      settlementEvents: settlementEvents,
      totalLent: totalLent,
      totalBorrowed: totalBorrowed,
      net: net,
      baseFont: baseFont,
    );

    final tempDir = await getTemporaryDirectory();
    final fileName =
        'Spendly_${personName.replaceAll(' ', '_')}_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.pdf';
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(pdfBytes);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/pdf')],
        subject: 'Lend/borrow history - $personName',
        text: 'Lending history with $personName',
      ),
    );
  } catch (_) {}
}

Future<Uint8List> _generateLendPdf({
  required String personName,
  required List<LendEntryEntity> entries,
  required List<LendSettlementEventEntity> settlementEvents,
  required double totalLent,
  required double totalBorrowed,
  required double net,
  required pw.Font baseFont,
}) async {
  final pdf = pw.Document();

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

  final activeEntries = entries
      .where((e) => !e.isDeleted && (e.amount - e.settledAmount) > 0)
      .toList(growable: false);
  final settledEntries = entries
      .where((e) => !e.isDeleted && (e.amount - e.settledAmount) <= 0)
      .toList(growable: false);

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (context) => [
        _buildHeader(personName, titleStyle, subtitleStyle),
        pw.SizedBox(height: 24),
        _buildSummaryCard(totalLent, totalBorrowed, net, valueStyle, bodyStyle),
        pw.SizedBox(height: 24),
        if (activeEntries.isNotEmpty) ...[
          _buildSectionTitle('Active Entries (${activeEntries.length})', sectionTitleStyle),
          pw.SizedBox(height: 8),
          _buildEntriesTable(activeEntries, settlementEvents, false, bodyStyle, headerCellStyle, cellStyle, valueStyle),
          pw.SizedBox(height: 24),
        ],
        if (settledEntries.isNotEmpty) ...[
          _buildSectionTitle('Settled Entries (${settledEntries.length})', sectionTitleStyle),
          pw.SizedBox(height: 8),
          _buildEntriesTable(settledEntries, settlementEvents, true, bodyStyle, headerCellStyle, cellStyle, valueStyle),
          pw.SizedBox(height: 24),
        ],
        _buildFooter(bodyStyle),
      ],
    ),
  );

  return pdf.save();
}

pw.Widget _buildHeader(
  String personName,
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
              pw.Text(personName, style: subtitleStyle.copyWith(fontSize: AppFontSizes.title, color: PdfColors.grey700)),
            ],
          ),
          pw.Text(
            'Lending History',
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

pw.Widget _buildSummaryCard(
  double totalLent,
  double totalBorrowed,
  double net,
  pw.TextStyle valueStyle,
  pw.TextStyle bodyStyle,
) {
  final netColor = net >= 0 ? PdfColors.green700 : PdfColors.red700;
  return pw.Container(
    padding: const pw.EdgeInsets.all(14),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.grey300),
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
    ),
    child: pw.Column(
      children: [
        _summaryRow('Total Lent', Formatters.rawCurrency(totalLent), bodyStyle, valueStyle,
            color: PdfColors.green700),
        pw.SizedBox(height: 8),
        _summaryRow('Total Borrowed', Formatters.rawCurrency(totalBorrowed), bodyStyle, valueStyle,
            color: PdfColors.red700),
        pw.SizedBox(height: 8),
        pw.Divider(thickness: 1, color: PdfColors.grey300),
        pw.SizedBox(height: 8),
        _summaryRow('Net Balance', Formatters.rawCurrency(net.abs()), bodyStyle, valueStyle,
            color: netColor),
      ],
    ),
  );
}

pw.Widget _buildSectionTitle(String title, pw.TextStyle style) {
  return pw.Text(title, style: style);
}

pw.Widget _buildEntriesTable(
  List<LendEntryEntity> entries,
  List<LendSettlementEventEntity> allEvents,
  bool isSettledSection,
  pw.TextStyle bodyStyle,
  pw.TextStyle headerCellStyle,
  pw.TextStyle cellStyle,
  pw.TextStyle valueStyle,
) {
  return pw.Table(
    border: pw.TableBorder.all(color: PdfColors.grey300),
    columnWidths: {
      0: const pw.FlexColumnWidth(0.4),
      1: const pw.FlexColumnWidth(1.2),
      2: const pw.FlexColumnWidth(1.5),
      3: const pw.FlexColumnWidth(1),
      4: const pw.FlexColumnWidth(1.5),
    },
    children: [
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.grey800),
        children: ['#', 'Type', 'Amount', 'Date', 'Note']
            .map((h) => _tableCell(h, headerCellStyle, pw.TextAlign.left))
            .toList(),
      ),
      ...entries.asMap().entries.map((entry) {
        final i = entry.key;
        final e = entry.value;
        final isLent = e.type == LendEntryType.lent;
        final typeColor = isLent ? PdfColors.green700 : PdfColors.red700;
        final entryEvents = allEvents
            .where((ev) => ev.entryId == e.id && !ev.isDeleted)
            .toList(growable: false);
        final settlementNote = entryEvents.isEmpty
            ? ''
            : 'Settlements: ${entryEvents.map((ev) => Formatters.rawCurrency(ev.amount)).join(', ')}';
        return pw.TableRow(
          children: [
            _tableCell('${i + 1}', cellStyle, pw.TextAlign.center),
            _tableCell(
              isLent ? 'Lent' : 'Borrowed',
              cellStyle.copyWith(color: typeColor, fontWeight: pw.FontWeight.bold),
              pw.TextAlign.left,
            ),
            _tableCell(Formatters.rawCurrency(e.amount), cellStyle.copyWith(fontWeight: pw.FontWeight.bold), pw.TextAlign.right),
            _tableCell(DateFormat('dd MMM yy').format(e.date), cellStyle, pw.TextAlign.left),
            _tableCell(
              '${e.note ?? ''}${settlementNote.isNotEmpty ? '\n$settlementNote' : ''}',
              cellStyle.copyWith(fontSize: AppFontSizes.caption - 2),
              pw.TextAlign.left,
            ),
          ],
        );
      }),
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
    padding: const pw.EdgeInsets.all(6),
    child: pw.Text(text, style: style, textAlign: align),
  );
}

pw.Widget _summaryRow(
  String label,
  String value,
  pw.TextStyle bodyStyle,
  pw.TextStyle valueStyle, {
  PdfColor? color,
}) {
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Text(label, style: bodyStyle),
      pw.Text(value, style: valueStyle.copyWith(color: color ?? valueStyle.color)),
    ],
  );
}
