import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PairLabelPdfService {
  /// Helper to convert a string to Title Case (e.g. "TAPER" -> "Taper")
  static String _toTitleCase(String str) {
    if (str.isEmpty) return '';
    return str.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Helper to check if group type represents a pair
  static bool _isPairGroup(dynamic val) {
    if (val == null) return false;
    final str = val.toString().trim().toLowerCase();
    return str.contains('pair');
  }

  /// Helper to check if PairNo is valid
  static bool _hasValidPairNo(dynamic val) {
    if (val == null) return false;
    final str = val.toString().trim();
    return str.isNotEmpty && str != '-' && str != '--' && str != '0';
  }

  /// Helper to extract normalized shape string in lowercase
  static String _extractShape(Map<String, dynamic> s) {
    return (s['Shape'] ??
            s['shape'] ??
            s['ShapeName'] ??
            s['shapeName'] ??
            s['raw']?['Shape'] ??
            s['raw']?['shape'] ??
            '')
        .toString()
        .trim()
        .toLowerCase();
  }

  /// Helper to extract base packet number, e.g. "79-1" -> "79", "79-A" -> "79", "79/1" -> "79"
  static String _extractPacketBase(String pkt) {
    final clean = pkt.trim();
    if (clean.isEmpty) return '';
    // Strip trailing delimiter and suffix, e.g. "79-1" -> "79", "79-A" -> "79", "DA-8-1" -> "DA-8", "79/1" -> "79"
    final stripped = clean.replaceAll(RegExp(r'[-_/.]([0-9]+|[A-Za-z]+)$'), '');
    if (stripped.isNotEmpty && stripped != clean) return stripped;
    // Strip trailing letter suffix if attached directly to digits, e.g. "79A" -> "79"
    final strippedLetters = clean.replaceAll(RegExp(r'(?<=\d)[A-Za-z]+$'), '');
    if (strippedLetters.isNotEmpty && strippedLetters != clean) return strippedLetters;
    return clean;
  }

  /// Format packet number with cutNo prefix, e.g. CutNo: "DC", PktNo: "79-1" -> "DC-79-1"
  static String _formatPktWithCutNo(
    Map<String, dynamic> s, {
    Map<String, dynamic>? parentRow,
    String? fallbackCutNo,
  }) {
    final pktNo = (s['PktNo'] ??
            s['pktNo'] ??
            s['packetNo'] ??
            s['PacketNo'] ??
            '')
        .toString()
        .trim();

    if (pktNo.isEmpty || pktNo == '-') return '';

    var rawCutNo = (s['CutNo'] ??
            s['cutNo'] ??
            s['raw']?['CutNo'] ??
            s['raw']?['cutNo'] ??
            '')
        .toString()
        .trim();

    if ((rawCutNo.isEmpty ||
            rawCutNo == '-' ||
            rawCutNo == '--' ||
            rawCutNo == 'null' ||
            rawCutNo == '0') &&
        parentRow != null) {
      rawCutNo = (parentRow['CutNo'] ??
              parentRow['cutNo'] ??
              parentRow['raw']?['CutNo'] ??
              parentRow['raw']?['cutNo'] ??
              '')
          .toString()
          .trim();
    }

    if ((rawCutNo.isEmpty ||
            rawCutNo == '-' ||
            rawCutNo == '--' ||
            rawCutNo == 'null' ||
            rawCutNo == '0') &&
        fallbackCutNo != null &&
        fallbackCutNo.isNotEmpty &&
        fallbackCutNo != '-' &&
        fallbackCutNo != '--') {
      rawCutNo = fallbackCutNo.trim();
    }

    if (rawCutNo.isEmpty ||
        rawCutNo == '-' ||
        rawCutNo == '--' ||
        rawCutNo == 'null' ||
        rawCutNo == '0') {
      return pktNo;
    }

    // Clean any trailing separator from cutNo, e.g. "DC-" -> "DC"
    final cleanCutNo = rawCutNo.replaceAll(RegExp(r'[-_/\\]+$'), '').trim();
    if (cleanCutNo.isEmpty) return pktNo;

    // Check if pktNo already starts with cutNo (case-insensitive)
    final lowerPkt = pktNo.toLowerCase();
    final lowerCut = cleanCutNo.toLowerCase();

    if (lowerPkt == lowerCut) {
      return cleanCutNo;
    }

    if (lowerPkt.startsWith('$lowerCut-') ||
        lowerPkt.startsWith('$lowerCut/') ||
        lowerPkt.startsWith(lowerCut) ||
        lowerPkt.startsWith('$lowerCut.')) {
      return pktNo;
    }

    if (lowerPkt.startsWith(lowerCut)) {
      return pktNo;
    }

    return '$cleanCutNo-$pktNo';
  }

  /// Generate PDF bytes for the selected records.
  /// Each selected row produces one label print.
  /// If `GroupType == Pair`, it displays the pair's total weight, all packet numbers,
  /// and all pair stones' measurements (MM) on each print.
  /// If `GroupType != Pair`, it displays a single diamond label (Shape 1 - wt, pktNo, MM).
  static Future<Uint8List> generatePdf({
    required List<Map<String, dynamic>> selectedRows,
    List<Map<String, dynamic>>? allReportRows,
    String? kapanNo,
  }) async {
    final pdf = pw.Document();
    final fontBold = pw.Font.helveticaBold();
    final allRows = allReportRows ?? selectedRows;

    // ── Sort selected rows: Shape-wise first, then GroupType == 'Pair' wise, then Packet/Cut ──
    final sortedRows = List<Map<String, dynamic>>.from(selectedRows);
    sortedRows.sort((a, b) {
      final shapeA = _extractShape(a);
      final shapeB = _extractShape(b);
      final sComp = shapeA.compareTo(shapeB);
      if (sComp != 0) return sComp;

      final isPairA = _isPairGroup(a['GroupType'] ?? a['groupType'] ?? a['category']);
      final isPairB = _isPairGroup(b['GroupType'] ?? b['groupType'] ?? b['category']);
      if (isPairA != isPairB) {
        return isPairA ? -1 : 1; // Pair group first
      }

      final pA = (a['PktNo'] ?? a['pktNo'] ?? '').toString();
      final pB = (b['PktNo'] ?? b['pktNo'] ?? '').toString();
      return pA.compareTo(pB);
    });

    for (final row in sortedRows) {
      final groupTypeRaw = (row['GroupType'] ?? row['groupType'] ?? row['category'] ?? '').toString();
      final isPairGroup = _isPairGroup(groupTypeRaw);
      final curShape = _extractShape(row);
      final pNo = (row['PairNo'] ?? row['pairNo'] ?? '').toString().trim();
      final hasPairNo = _hasValidPairNo(pNo);

      List<Map<String, dynamic>> pairStones = [];

      // Only search for pair partners if this stone belongs to GroupType == Pair!
      if (isPairGroup) {
        // 1. Try lookup by PairNo (bidirectional match with other stone's PairNo or formatted packet)
        if (hasPairNo) {
          final curPktFormatted = _formatPktWithCutNo(row, fallbackCutNo: kapanNo).toLowerCase();
          final curPkt = (row['PktNo'] ?? row['pktNo'] ?? '').toString().trim().toLowerCase();
          final pNoLower = pNo.toLowerCase();

          pairStones = allRows.where((r) {
            // Must also belong to GroupType == Pair and have identical Shape!
            if (!_isPairGroup(r['GroupType'] ?? r['groupType'] ?? r['category'])) return false;
            if (_extractShape(r) != curShape) return false;

            final otherPNo = (r['PairNo'] ?? r['pairNo'] ?? '').toString().trim().toLowerCase();
            final otherPkt = (r['PktNo'] ?? r['pktNo'] ?? '').toString().trim().toLowerCase();
            final otherPktFormatted = _formatPktWithCutNo(r, fallbackCutNo: kapanNo).toLowerCase();

            // Bidirectional check:
            if (otherPNo.isNotEmpty && otherPNo == pNoLower) return true;
            if (pNoLower == otherPkt || pNoLower == otherPktFormatted || (otherPkt.isNotEmpty && pNoLower.endsWith(otherPkt))) return true;
            if (otherPNo.isNotEmpty && (otherPNo == curPkt || otherPNo == curPktFormatted || (curPkt.isNotEmpty && otherPNo.endsWith(curPkt)))) return true;

            return false;
          }).toList();
        }

        // 2. Fallback: Lookup by base packet number (e.g. "79" and "79-1")
        if (pairStones.length <= 1) {
          final curPkt = (row['PktNo'] ?? row['pktNo'] ?? row['packetNo'] ?? row['PacketNo'] ?? '').toString().trim();
          final curBase = _extractPacketBase(curPkt);
          if (curBase.isNotEmpty) {
            final candidates = allRows.where((r) {
              if (!_isPairGroup(r['GroupType'] ?? r['groupType'] ?? r['category'])) return false;
              if (_extractShape(r) != curShape) return false;

              final otherPkt = (r['PktNo'] ?? r['pktNo'] ?? r['packetNo'] ?? r['PacketNo'] ?? '').toString().trim();
              if (otherPkt.isEmpty) return false;
              final otherBase = _extractPacketBase(otherPkt);
              return (otherBase == curBase) || (otherPkt == curBase) || (otherBase == curPkt);
            }).toList();

            if (candidates.length > 1) {
              pairStones = candidates;
            }
          }
        }
      }

      // Ensure current row is always included in pairStones
      if (!pairStones.any((s) => identical(s, row) || (s['PktNo'] ?? s['pktNo']) == (row['PktNo'] ?? row['pktNo']))) {
        pairStones.insert(0, row);
      }

      // Deduplicate stones if any
      final seenIds = <String>{};
      pairStones = pairStones.where((s) {
        final id = (s['DetID'] ?? s['detID'] ?? s['Id'] ?? s['PktNo'] ?? s['pktNo'] ?? '').toString();
        return id.isEmpty || seenIds.add(id);
      }).toList();

      final isPair = isPairGroup && pairStones.length > 1;

      String line1;
      String line2;
      List<String> stoneLines = [];

      if (isPair && pairStones.length > 1) {
        // Sort pair stones consistently by PktNo so both prints have identical order
        pairStones.sort((a, b) {
          final aPkt = (a['PktNo'] ?? a['pktNo'] ?? a['packetNo'] ?? a['PacketNo'] ?? '').toString();
          final bPkt = (b['PktNo'] ?? b['pktNo'] ?? b['packetNo'] ?? b['PacketNo'] ?? '').toString();
          return aPkt.compareTo(bPkt);
        });

        final rawShape = (row['Shape'] ??
                row['shape'] ??
                pairStones.first['Shape'] ??
                pairStones.first['shape'] ??
                row['ShapeName'] ??
                row['shapeName'] ??
                '')
            .toString()
            .trim();
        final shape = _toTitleCase(rawShape);

        final stoneCount = pairStones.length;
        double totalWt = 0.0;
        for (final s in pairStones) {
          totalWt += _extractWeight(s);
        }
        String wtStr = totalWt.toStringAsFixed(3);
        if (wtStr.endsWith('0')) {
          wtStr = totalWt.toStringAsFixed(2);
        }

        line1 = [
          if (shape.isNotEmpty) shape,
          '$stoneCount - $wtStr',
        ].join(' ');

        final pktNos = pairStones
            .map((s) => _formatPktWithCutNo(
                  s,
                  parentRow: row,
                  fallbackCutNo: kapanNo,
                ))
            .where((p) => p.isNotEmpty && p != '-')
            .toSet()
            .toList();
        line2 = pktNos.join(' / ');

        stoneLines = pairStones.map((s) => _buildStoneDetailLine(s)).toList();
      } else {
        // Single diamond label
        final rawShape = (row['Shape'] ??
                row['shape'] ??
                row['ShapeName'] ??
                row['shapeName'] ??
                '')
            .toString()
            .trim();
        final shape = _toTitleCase(rawShape);

        final wt = _extractWeight(row);
        String wtStr = wt.toStringAsFixed(3);
        if (wtStr.endsWith('0')) {
          wtStr = wt.toStringAsFixed(2);
        }

        line1 = [
          if (shape.isNotEmpty) shape,
          '1 - $wtStr',
        ].join(' ');

        line2 = _formatPktWithCutNo(
          row,
          fallbackCutNo: kapanNo,
        );

        stoneLines = [_buildStoneDetailLine(row)];
      }

      pdf.addPage(
        pw.Page(
          pageFormat: const PdfPageFormat(60, 25, marginAll: 0),
          build: (pw.Context context) {
            return pw.Container(
              width: 60,
              height: 25,
              padding: const pw.EdgeInsets.only(top: 1.5, left: 1, right: 1, bottom: 0.5),
              alignment: pw.Alignment.topCenter,
              child: pw.FittedBox(
                fit: pw.BoxFit.scaleDown,
                alignment: pw.Alignment.topCenter,
                child: pw.Column(
                  mainAxisSize: pw.MainAxisSize.min,
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.FittedBox(
                      fit: pw.BoxFit.scaleDown,
                      child: pw.Text(
                        line1,
                        maxLines: 1,
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 6,
                          fontWeight: pw.FontWeight.bold,
                          lineSpacing: 0,
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 1.0),
                    pw.FittedBox(
                      fit: pw.BoxFit.scaleDown,
                      child: pw.Text(
                        line2,
                        maxLines: 1,
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 4,
                          fontWeight: pw.FontWeight.bold,
                          lineSpacing: 0,
                        ),
                      ),
                    ),
                    for (final stLine in stoneLines) ...[
                      pw.SizedBox(height: 1.0),
                      pw.FittedBox(
                        fit: pw.BoxFit.scaleDown,
                        child: pw.Text(
                          stLine,
                          maxLines: 1,
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            font: fontBold,
                            fontSize: 4,
                            fontWeight: pw.FontWeight.bold,
                            lineSpacing: 0,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      );
    }

    return pdf.save();
  }

  /// Direct method to generate and show/print the PDF via Printing.layoutPdf
  static Future<void> printPairLabels({
    required BuildContext context,
    required List<Map<String, dynamic>> selectedRows,
    List<Map<String, dynamic>>? allReportRows,
    String? kapanNo,
  }) async {
    try {
      if (selectedRows.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No records selected to print')),
        );
        return;
      }

      final pdfBytes = await generatePdf(
        selectedRows: selectedRows,
        allReportRows: allReportRows,
        kapanNo: kapanNo,
      );

      final fileName = (kapanNo != null && kapanNo.isNotEmpty && kapanNo != '--')
          ? 'DiamondLabels_$kapanNo.pdf'
          : 'DiamondLabels.pdf';

      await Printing.layoutPdf(
        name: fileName,
        onLayout: (PdfPageFormat format) async => pdfBytes,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  /// Extract weight (prefers RecWt, then Wt, then Weight, then IssWt)
  static double _extractWeight(Map<String, dynamic> s) {
    final recVal = double.tryParse((s['RecWt'] ?? s['recWt'] ?? '').toString());
    if (recVal != null && recVal > 0) return recVal;

    final wtVal = double.tryParse(
      (s['Wt'] ?? s['wt'] ?? s['weight'] ?? s['Weight'] ?? '').toString(),
    );
    if (wtVal != null && wtVal > 0) return wtVal;

    final issVal = double.tryParse((s['IssWt'] ?? s['issWt'] ?? '').toString());
    if (issVal != null && issVal > 0) return issVal;

    return 0.0;
  }

  /// Build stone detail line: "G VS1 6.05x3.70x2.40"
  static String _buildStoneDetailLine(Map<String, dynamic> s) {
    final color = (s['Color'] ??
            s['color'] ??
            s['ColorName'] ??
            s['colorName'] ??
            '')
        .toString()
        .trim();

    final clarity = (s['Clarity'] ??
            s['clarity'] ??
            s['Purity'] ??
            s['purity'] ??
            s['PurityName'] ??
            s['purityName'] ??
            '')
        .toString()
        .trim();

    final lenRaw = (s['Length'] ?? s['length'] ?? '').toString().trim();
    final diaRaw = (s['Dia'] ?? s['dia'] ?? '').toString().trim();
    final hgtRaw = (s['Height'] ?? s['height'] ?? '').toString().trim();

    String formatDim(dynamic val) {
      if (val == null) return '';
      final str = val.toString().trim();
      if (str.isEmpty || str == '-' || str == '--') return '';
      final d = double.tryParse(str);
      if (d != null) return d.toStringAsFixed(2);
      return str;
    }

    final lenStr = formatDim(s['Length'] ?? s['length']);
    final diaStr = formatDim(s['Dia'] ?? s['dia']);
    final hgtStr = formatDim(s['Height'] ?? s['height']);

    String dimStr = '';
    if (lenStr.isNotEmpty && diaStr.isNotEmpty && hgtStr.isNotEmpty) {
      dimStr = '${lenStr}x${diaStr}x${hgtStr}';
    } else if (s['mm'] != null && s['mm'].toString().isNotEmpty && s['mm'] != '-') {
      final rawMm = s['mm'].toString().trim();
      if (!rawMm.contains('-') || RegExp(r'^\d').hasMatch(rawMm)) {
        dimStr = rawMm.replaceAll(' ', '').replaceAll('-', 'x');
      }
    }

    final parts = <String>[];
    if (color.isNotEmpty && color != '-') parts.add(color);
    if (clarity.isNotEmpty && clarity != '-') parts.add(clarity);
    if (dimStr.isNotEmpty && dimStr != '-') parts.add(dimStr);

    return parts.join(' ');
  }
}
