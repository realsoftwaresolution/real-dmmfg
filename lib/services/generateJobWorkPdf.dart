import 'dart:typed_data';

import 'package:diam_mfg/models/company_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// ─────────────────────────────────────────────
/// MODEL
/// ─────────────────────────────────────────────

class JobWorkPdfModel {
  final CompanyModel? conpanyInfo;

  final String partyName;
  final String partyType;

  final String jobNo;
  final String date;

  final List<JobWorkItem> items;

  const JobWorkPdfModel({
    required this.conpanyInfo,
    required this.partyName,
    required this.partyType,
    required this.jobNo,
    required this.date,
    required this.items,
  });
}

class JobWorkItem {
  final String kapan;
  final String type;
  final String pcs;
  final String cts;
  final String bCode;

  const JobWorkItem({
    required this.kapan,
    required this.type,
    required this.pcs,
    required this.cts,
    required this.bCode,
  });
}

/// ─────────────────────────────────────────────
/// MAIN PDF
/// ─────────────────────────────────────────────

Future<Uint8List> generateJobWorkPdf(JobWorkPdfModel data) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4.landscape,

      margin: const pw.EdgeInsets.all(20),

      build: (context) {
        return pw.Row(
          children: [
            /// LEFT COPY
            pw.Expanded(child: _buildSlip(data)),

            pw.SizedBox(width: 20),

            /// RIGHT COPY
            pw.Expanded(child: _buildSlip(data)),
          ],
        );
      },
    ),
  );

  return pdf.save();
}

/// ─────────────────────────────────────────────
/// SLIP
/// ─────────────────────────────────────────────

pw.Widget _buildSlip(JobWorkPdfModel data) {
  final totalPcs = data.items.fold<int>(
    0,
    (sum, e) => sum + (int.tryParse(e.pcs) ?? 0),
  );

  final totalCts = data.items.fold<double>(
    0.0,
    (sum, e) => sum + (double.tryParse(e.cts) ?? 0),
  );

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,

    children: [
      /// HEADER
      pw.Center(
        child: pw.Text(
          data.conpanyInfo?.companyName ?? '',

          style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
        ),
      ),

      pw.SizedBox(height: 4),

      pw.Center(
        child: pw.Text(
          data.conpanyInfo?.address ?? '',

          textAlign: pw.TextAlign.center,

          style: const pw.TextStyle(fontSize: 9),
        ),
      ),

      pw.Divider(height: 10),

      /// PARTY SECTION
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,

        crossAxisAlignment: pw.CrossAxisAlignment.start,

        children: [
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

              pw.Text(data.partyName, style: pw.TextStyle(fontSize: 9)),

              pw.Text(data.partyType, style: pw.TextStyle(fontSize: 9)),
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
                      'Job Work Out',

                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ),

                _jobRow(data.jobNo, 10),

                _jobRow(data.date, 9),
              ],
            ),
          ),
        ],
      ),

      pw.SizedBox(height: 10),

      /// TABLE
      pw.Table(
        border: pw.TableBorder.all(width: 0.5),

        columnWidths: {
          0: const pw.FixedColumnWidth(35),
          1: const pw.FlexColumnWidth(),
          2: const pw.FixedColumnWidth(60),
          3: const pw.FixedColumnWidth(40),
          4: const pw.FixedColumnWidth(50),
          5: const pw.FixedColumnWidth(55),
          6: const pw.FixedColumnWidth(70),
        },

        children: [
          /// HEADER
          pw.TableRow(
            decoration: const pw.BoxDecoration(color: PdfColors.blue300),

            children: [
              _tableHeader('Sr'),
              _tableHeader('KAPAN'),
              _tableHeader('BCODE'),
              _tableHeader('TYPE'),
              _tableHeader('PCS'),
              _tableHeader('CTS'),
            ],
          ),

          /// DYNAMIC ROWS
          ...data.items.asMap().entries.map((e) {
            final index = e.key;
            final item = e.value;

            return _tableRow(
              '${index + 1}',
              item.kapan,
              item.bCode,
              item.type,
              item.pcs,
              item.cts,
            );
          }),

          /// TOTAL ROW
          pw.TableRow(
            children: [
              pw.SizedBox(),
              pw.SizedBox(),
              pw.SizedBox(),

              _tableBold(totalPcs.toString()),

              _tableBold(totalCts.toStringAsFixed(3)),

              pw.SizedBox(),
              pw.SizedBox(),
            ],
          ),
        ],
      ),

      pw.Spacer(),

      /// SIGNATURE
      pw.Row(
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
      ),
    ],
  );
}

/// ─────────────────────────────────────────────
/// HELPERS
/// ─────────────────────────────────────────────

pw.Widget _jobRow(String text, fontSize) {
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

      cell(type),

      cell(pcs),

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
