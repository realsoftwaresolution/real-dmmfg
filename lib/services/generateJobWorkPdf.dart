import 'dart:convert';
import 'dart:typed_data';
import 'package:diam_mfg/models/company_model.dart';
import 'package:diam_mfg/models/factory_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// ─────────────────────────────────────────────
/// MODEL
/// ─────────────────────────────────────────────

class JobWorkPdfModel {
  final dynamic headerInfo;
  final String partyName;
  final String partyType;

  final dynamic jobNo;
  final dynamic NaturalPartyCode;
  final dynamic CVDPartyCode;
  final String date;

  final List<JobWorkItem> items;

  const JobWorkPdfModel({
    required this.headerInfo,
    required this.partyName,
    required this.partyType,
    required this.jobNo,
    required this.date,
    this.CVDPartyCode,
    this.NaturalPartyCode,
    required this.items,
  });
}

class JobWorkItem {
  final String kapan;
  final String type;
  final String pcs;
  final String cts;
  final String bCode;
  final String pktNo;
  final String size;

  const JobWorkItem({
    required this.kapan,
    required this.type,
    required this.pcs,
    required this.cts,
    required this.bCode,
    required this.pktNo,
     this.size = '',
  });
}

/// ─────────────────────────────────────────────
/// DETAIL PDF
/// ─────────────────────────────────────────────

Future<Uint8List> generateJobWorkPdf(JobWorkPdfModel data) async {
  final pdf = pw.Document();

  const rowsPerPage = 15;

  final chunks = <List<JobWorkItem>>[];

  for (int i = 0; i < data.items.length; i += rowsPerPage) {
    chunks.add(
      data.items.sublist(
        i,
        i + rowsPerPage > data.items.length
            ? data.items.length
            : i + rowsPerPage,
      ),
    );
  }

  for (final chunk in chunks) {
    final pageData = JobWorkPdfModel(
      headerInfo: data.headerInfo,
      partyName: data.partyName,
      partyType: data.partyType,
      jobNo: data.jobNo,
      date: data.date,
      NaturalPartyCode: data.NaturalPartyCode,
      CVDPartyCode: data.CVDPartyCode,
      items: chunk,
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(20),

        build: (context) {
          return pw.Row(
            children: [
              /// ORIGINAL
              pw.Expanded(child: _buildSlip(pageData, 'Original')),

              pw.SizedBox(width: 20),

              /// DUPLICATE
              pw.Expanded(child: _buildSlip(pageData, 'Duplicate')),
            ],
          );
        },
      ),
    );
  }

  return pdf.save();
}

/// ─────────────────────────────────────────────
/// SUMMARY PDF
/// ─────────────────────────────────────────────

Future<Uint8List> generateJobWorkPdfSummary(JobWorkPdfModel data, {bool showSize = false,JobWorkItem? grandTotal}) async {
  final pdf = pw.Document();

  const rowsPerPage = 25;

  final chunks = <List<JobWorkItem>>[];

  for (int i = 0; i < data.items.length; i += rowsPerPage) {
    chunks.add(
      data.items.sublist(
        i,
        i + rowsPerPage > data.items.length
            ? data.items.length
            : i + rowsPerPage,
      ),
    );
  }

  for (final chunk in chunks) {
    final pageData = JobWorkPdfModel(
      headerInfo: data.headerInfo,
      partyName: data.partyName,
      partyType: data.partyType,
      jobNo: data.jobNo,
      date: data.date,
      NaturalPartyCode: data.NaturalPartyCode,
      CVDPartyCode: data.CVDPartyCode,
      items: chunk,
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(20),

        build: (context) {
          return pw.Row(
            children: [
              pw.Expanded(child: _buildSummarySlip(pageData, 'Original', showSize,grandTotal)),

              pw.SizedBox(width: 20),

              pw.Expanded(child: _buildSummarySlip(pageData, 'Duplicate',showSize,grandTotal)),
            ],
          );
        },
      ),
    );
  }

  return pdf.save();
}

/// ─────────────────────────────────────────────
/// DETAIL SLIP
/// ─────────────────────────────────────────────

pw.Widget _buildSlip(JobWorkPdfModel data, text) {
  final totalPcs = data.items.fold<int>(
    0,
    (sum, e) => sum + (int.tryParse(e.pcs) ?? 0),
  );

  final totalCts = data.items.fold<double>(
    0.0,
    (sum, e) => sum + (double.tryParse(e.cts) ?? 0),
  );

  return pw.Container(
    padding: const pw.EdgeInsets.all(10),

    decoration: pw.BoxDecoration(
      border: pw.Border.all(width: 1, color: PdfColors.black),
    ),

    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisSize: pw.MainAxisSize.min,

      children: [
        pw.Align(
          alignment: pw.Alignment.topRight,
          child: pw.Text(
            text,

            textAlign: pw.TextAlign.right,

            style: pw.TextStyle(
              color: PdfColors.black,
              fontWeight: pw.FontWeight.normal,
              fontSize: 8,
            ),
          ),
        ),

        /// HEADER
        _buildHeader(data),

        pw.SizedBox(height: 10),

        /// TABLE
        pw.Table(
          border: pw.TableBorder.all(width: 0.5),

          columnWidths: {
            0: const pw.FixedColumnWidth(25),
            1: const pw.FlexColumnWidth(60),
            2: const pw.FixedColumnWidth(60),
            3: const pw.FixedColumnWidth(60),
            4: const pw.FixedColumnWidth(60),
            5: const pw.FixedColumnWidth(50),
            6: const pw.FixedColumnWidth(55),
          },

          children: [
            /// HEADER
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.blue300),

              children: [
                _tableHeader('Sr'),
                _tableHeader('CUT NO'),
                _tableHeader('BCODE'),
                _tableHeader('PKT NO'),
                _tableHeader('ARTICAL'),
                _tableHeader('PCS'),
                _tableHeader('WT'),
              ],
            ),

            /// ROWS
            ...data.items.asMap().entries.map((e) {
              final index = e.key;
              final item = e.value;

              return _tableRow(
                '${index + 1}',
                item.kapan,
                item.bCode,
                item.pktNo,
                item.type,
                item.pcs,
                item.cts,
              );
            }),

            /// TOTAL
            pw.TableRow(
              children: [
                pw.SizedBox(),
                pw.SizedBox(),
                pw.SizedBox(),
                pw.SizedBox(),
                pw.SizedBox(),

                _tableBold(totalPcs.toString()),

                _tableBold(totalCts.toStringAsFixed(3)),
              ],
            ),
          ],
        ),

        pw.Spacer(),

        _buildSignature(),
      ],
    ),
  );
}

/// ─────────────────────────────────────────────
/// SUMMARY SLIP
/// ─────────────────────────────────────────────

pw.Widget _buildSummarySlip(JobWorkPdfModel data, text, bool showSize,JobWorkItem? grandTotal) {
  final totalPcs = grandTotal != null
      ? (int.tryParse(grandTotal.pcs) ?? 0)
      : data.items.fold<int>(0, (sum, e) => sum + (int.tryParse(e.pcs) ?? 0));

  final totalCts = grandTotal != null
      ? (double.tryParse(grandTotal.cts) ?? 0.0)
      : data.items.fold<double>(0.0, (sum, e) => sum + (double.tryParse(e.cts) ?? 0));

  return pw.Container(
    padding: const pw.EdgeInsets.all(10),

    decoration: pw.BoxDecoration(
      border: pw.Border.all(width: 1, color: PdfColors.black),
    ),

    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Align(
          alignment: pw.Alignment.topRight,
          child: pw.Text(
            text,

            textAlign: pw.TextAlign.right,

            style: pw.TextStyle(
              color: PdfColors.black,
              fontWeight: pw.FontWeight.normal,
              fontSize: 8,
            ),
          ),
        ),

        /// HEADER
        _buildHeader(data, title: 'Job Work Summary'),

        pw.SizedBox(height: 20),

        /// SUMMARY TABLE
        pw.Table(
          border: pw.TableBorder.all(width: 0.5),

          columnWidths: {
            0: const pw.FixedColumnWidth(30),   // SR
            1: const pw.FlexColumnWidth(80),    // CUT NO
            2: const pw.FixedColumnWidth(60),   // ARTICAL
            if (showSize) 3: const pw.FixedColumnWidth(60), // SIZE (conditional)
            (showSize ? 4 : 3): const pw.FixedColumnWidth(40), // PKT
            (showSize ? 5 : 4): const pw.FixedColumnWidth(40), // PCS
            (showSize ? 6 : 5): const pw.FixedColumnWidth(60), // WT
          },

          children: [
            /// HEADER
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.blue300),

              children: [
                _tableHeader('SR'),

                _tableHeader('CUT NO'),
                _tableHeader('ARTICAL'),
                if (showSize) _tableHeader('SIZE'),

                _tableHeader('PKT'),

                _tableHeader('PCS'),

                _tableHeader('WT'),
              ],
            ),

            /// DYNAMIC ROWS
            ...data.items.asMap().entries.map((e) {
              final index = e.key;
              final item = e.value;

              return pw.TableRow(
                children: [
                  /// SR
                  _summaryCell('${index + 1}'),

                  /// CUT NO
                  _summaryCell(item.kapan, align: pw.TextAlign.center),
                  _summaryCell(item.type, align: pw.TextAlign.center),
                  if (showSize) _summaryCell(item.size, align: pw.TextAlign.center),

                  /// PKT COUNT
                  _summaryCell(item.bCode, align: pw.TextAlign.center),

                  /// PCS
                  _summaryCell(item.pcs, align: pw.TextAlign.right),

                  /// WT
                  _summaryCell(item.cts, align: pw.TextAlign.right),
                ],
              );
            }).toList(),

            /// TOTAL ROW
            pw.TableRow(
              children: [
                _tableBold(''),

                _tableBold('TOTAL'),

                _tableBold(''),
                if (showSize) _tableBold(''),
                _tableBold(''),

                _tableBold(totalPcs.toString()),

                _tableBold(totalCts.toStringAsFixed(3)),
              ],
            ),
          ],
        ),

        pw.Spacer(),

        _buildSignature(),
      ],
    ),
  );
}

pw.Widget _summaryCell(
  String text, {
  pw.TextAlign align = pw.TextAlign.center,
}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(4),

    child: pw.Text(
      text,

      textAlign: align,

      style: const pw.TextStyle(fontSize: 9),
    ),
  );
}

/// ─────────────────────────────────────────────
/// COMMON HEADER
/// ─────────────────────────────────────────────

pw.Widget _buildHeader(JobWorkPdfModel data, {String title = 'Job Work Out'}) {
  // ✅ FIX: read fields directly instead of casting to Map
  String companyName = '';
  String address = '';
  String gstNo = '';

  final info = data.headerInfo;

  if (info is CompanyModel) {
    // ✅ CompanyModel fields
    companyName = info.companyName ?? '';
    address = info.address ?? '';
    gstNo = info.gstNo ?? '';
  } else if (info is FactoryModel) {
    // ✅ FactoryModel fields
    companyName = info.factoryName ?? '';
    address = info.address ?? '';
    gstNo = info.gstNo ?? '';
  } else if (info is Map<String, dynamic>) {
    // ✅ Raw map fallback
    companyName =
        (info['companyName'] ??
                info['CompanyName'] ??
                info['factoryName'] ??
                info['FactoryName'] ??
                '')
            .toString();
    address = (info['address'] ?? info['Address'] ?? '').toString();
    gstNo = (info['gstNo'] ?? info['GstNo'] ?? '').toString();
  }

  final article = data.items.isNotEmpty
      ? data.items.first.type.toUpperCase()
      : '';
  String partyCode = '';

  if (article.contains('NATURAL')) {
    partyCode = data.NaturalPartyCode?.toString() ?? '';
  } else if (article.contains('CVD')) {
    partyCode = data.CVDPartyCode?.toString() ?? '';
  }
  return pw.Column(
    children: [
      pw.Center(
        child: pw.Text(
          companyName,
          style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
        ),
      ),
      pw.SizedBox(height: 4),
      pw.Center(
        child: pw.Text(
          '$address\nGSTIN: $gstNo',
          textAlign: pw.TextAlign.center,
          style: const pw.TextStyle(fontSize: 9),
        ),
      ),

      pw.Divider(height: 10),

      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,

        crossAxisAlignment: pw.CrossAxisAlignment.start,

        children: [
          /// PARTY
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,

            children: [
              pw.Text(
                'TO,',

                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                ),
              ),

              pw.SizedBox(height: 4),

              pw.Row(
                children: [
                  pw.Text(
                    data.partyName,
                    style: const pw.TextStyle(fontSize: 9),
                  ),

                  if (partyCode.isNotEmpty)
                    pw.Text(
                      ' [$partyCode]',
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                ],
              ),

              pw.Text(data.partyType, style: const pw.TextStyle(fontSize: 9)),
            ],
          ),

          /// JOB BOX
          pw.Container(
            width: 140,

            decoration: pw.BoxDecoration(border: pw.Border.all()),

            child: pw.Column(
              children: [
                pw.Container(
                  width: double.infinity,

                  color: PdfColors.blue300,

                  padding: const pw.EdgeInsets.all(5),

                  child: pw.Center(
                    child: pw.Text(
                      title,

                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ),

                _jobRow(data.jobNo.toString(), 10),

                _jobRow(data.date, 9),
              ],
            ),
          ),
        ],
      ),
    ],
  );
}

/// ─────────────────────────────────────────────
/// SIGNATURE
/// ─────────────────────────────────────────────

pw.Widget _buildSignature() {
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,

    children: [
      pw.Text(
        "Receiver's Signature",

        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      ),

      pw.Text(
        "Authorized Signatory",

        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      ),
    ],
  );
}

/// ─────────────────────────────────────────────
/// HELPERS
/// ─────────────────────────────────────────────

pw.Widget _jobRow(String text, double fontSize) {
  return pw.Container(
    width: double.infinity,

    padding: const pw.EdgeInsets.all(4),

    decoration: const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide())),

    child: pw.Text(text, style: pw.TextStyle(fontSize: fontSize)),
  );
}

pw.Widget _tableHeader(String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(4),

    child: pw.Text(
      text,

      textAlign: pw.TextAlign.center,

      style: pw.TextStyle(
        color: PdfColors.white,
        fontWeight: pw.FontWeight.bold,
        fontSize: 10,
      ),
    ),
  );
}

pw.TableRow _tableRow(
  String sr,
  String kapan,
  String bCode,
  String pktNo,
  String type,
  String pcs,
  String cts,
) {
  pw.Widget cell(String t, {pw.TextAlign align = pw.TextAlign.center}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),

      child: pw.Text(
        t,

        textAlign: align,

        style: const pw.TextStyle(fontSize: 9),
      ),
    );
  }

  return pw.TableRow(
    children: [
      cell(sr),

      cell(kapan, align: pw.TextAlign.left),

      cell(bCode, align: pw.TextAlign.center),
      cell(pktNo, align: pw.TextAlign.center),

      cell(type),

      cell(pcs, align: pw.TextAlign.right),

      cell(cts, align: pw.TextAlign.right),
    ],
  );
}

pw.Widget _tableBold(String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(4),

    child: pw.Text(
      text,

      textAlign: pw.TextAlign.right,

      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
    ),
  );
}
