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

  /// Natural comparison helper for sorting packets (e.g. "79" comes before "79-1", "2" before "2-1", "9" before "16")
  static int _comparePackets(Map<String, dynamic> a, Map<String, dynamic> b) {
    final pktA = (a['PktNo'] ?? a['pktNo'] ?? a['packetNo'] ?? a['PacketNo'] ?? '').toString().trim();
    final pktB = (b['PktNo'] ?? b['pktNo'] ?? b['packetNo'] ?? b['PacketNo'] ?? '').toString().trim();

    final baseA = _extractPacketBase(pktA);
    final baseB = _extractPacketBase(pktB);

    final numA = int.tryParse(baseA);
    final numB = int.tryParse(baseB);

    if (numA != null && numB != null && numA != numB) {
      return numA.compareTo(numB);
    }

    final baseComp = baseA.compareTo(baseB);
    if (baseComp != 0) return baseComp;

    if (pktA.length != pktB.length) {
      return pktA.length.compareTo(pktB.length);
    }

    return pktA.compareTo(pktB);
  }

  /// Format shape name cleanly (e.g. "TREPEZOID" -> "Trapezoid", "CADILACNEW" -> "Cadillac")
  static String _formatShapeName(String rawShape) {
    if (rawShape.isEmpty) return '';
    final lower = rawShape.trim().toLowerCase();
    if (lower == 'trepezoid' || lower == 'trapezoid') return 'Trapezoid';
    if (lower == 'cadilac' || lower == 'cadillac' || lower == 'cadilacnew' || lower == 'cadillacnew') return 'Cadillac';
    if (lower == 'tapper' || lower == 'taper') return 'Taper';
    if (lower == 'bulets' || lower == 'bullet' || lower == 'bullets' || lower == 'buletnew') return 'Bullets';
    if (lower == 'trillant' || lower == 'trilliant') return 'Trilliant';
    return _toTitleCase(rawShape.trim());
  }

  /// Check if two selected stones match as a pair (shape-wise, cutNo-wise, and pktNo/pairNo-wise)
  static bool _isPairMatch(
    Map<String, dynamic> stoneA,
    Map<String, dynamic> stoneB, {
    String? fallbackCutNo,
  }) {
    if (!_isPairGroup(stoneA['GroupType'] ?? stoneA['groupType'] ?? stoneA['category']) ||
        !_isPairGroup(stoneB['GroupType'] ?? stoneB['groupType'] ?? stoneB['category'])) {
      return false;
    }

    final shapeA = _extractShape(stoneA);
    final shapeB = _extractShape(stoneB);
    if (shapeA.isNotEmpty && shapeB.isNotEmpty && shapeA != shapeB) {
      return false;
    }

    final pktA = (stoneA['PktNo'] ?? stoneA['pktNo'] ?? stoneA['packetNo'] ?? stoneA['PacketNo'] ?? '').toString().trim();
    final pktB = (stoneB['PktNo'] ?? stoneB['pktNo'] ?? stoneB['packetNo'] ?? stoneB['PacketNo'] ?? '').toString().trim();

    final cutA = (stoneA['CutNo'] ?? stoneA['cutNo'] ?? stoneA['raw']?['CutNo'] ?? stoneA['raw']?['cutNo'] ?? '').toString().trim();
    final cutB = (stoneB['CutNo'] ?? stoneB['cutNo'] ?? stoneB['raw']?['CutNo'] ?? stoneB['raw']?['cutNo'] ?? '').toString().trim();

    final pairNoA = (stoneA['PairNo'] ?? stoneA['pairNo'] ?? '').toString().trim();
    final pairNoB = (stoneB['PairNo'] ?? stoneB['pairNo'] ?? '').toString().trim();

    final formattedA = _formatPktWithCutNo(stoneA, fallbackCutNo: fallbackCutNo).toLowerCase();
    final formattedB = _formatPktWithCutNo(stoneB, fallbackCutNo: fallbackCutNo).toLowerCase();

    // 1. Cross-reference PairNo match
    if (_hasValidPairNo(pairNoA)) {
      final pA = pairNoA.toLowerCase();
      if (pA == formattedB ||
          pA == '${cutB.toLowerCase()}-${pktB.toLowerCase()}' ||
          (pktB.isNotEmpty && pA == pktB.toLowerCase())) {
        return true;
      }
      if (_hasValidPairNo(pairNoB) && pA == pairNoB.toLowerCase()) {
        return true;
      }
    }

    if (_hasValidPairNo(pairNoB)) {
      final pB = pairNoB.toLowerCase();
      if (pB == formattedA ||
          pB == '${cutA.toLowerCase()}-${pktA.toLowerCase()}' ||
          (pktA.isNotEmpty && pB == pktA.toLowerCase())) {
        return true;
      }
    }

    // 2. Matching CutNo and Base Packet number (e.g. Cut "DC" with Pkt "79" and "79-1")
    if (cutA.isNotEmpty && cutB.isNotEmpty && cutA.toLowerCase() == cutB.toLowerCase()) {
      final baseA = _extractPacketBase(pktA).toLowerCase();
      final baseB = _extractPacketBase(pktB).toLowerCase();
      if (baseA.isNotEmpty && baseA == baseB) {
        return true;
      }
    }

    return false;
  }

  /// Helper to render a single label page in the PDF
  static void _addLabelPage({
    required pw.Document pdf,
    required pw.Font fontBold,
    required String line1,
    required String line2,
    required List<String> stoneLines,
  }) {
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

  /// Generate PDF bytes for the selected records.
  /// Grouped shape-wise, cutNo-wise, and pktNo-wise.
  /// When 2 selected rows of the same shape form a pair, they are combined and print 2 identical labels.
  /// If a single row is selected or no partner is in selected rows (e.g. Fancy or unpaired Pair), it prints 1 single label.
  static Future<Uint8List> generatePdf({
    required List<Map<String, dynamic>> selectedRows,
    List<Map<String, dynamic>>? allReportRows,
    String? kapanNo,
  }) async {
    final pdf = pw.Document();
    final fontBold = pw.Font.helveticaBold();

    // ── Group selected rows shape-wise (preserving order of appearance) ──
    final shapeGroups = <String, List<Map<String, dynamic>>>{};
    for (final row in selectedRows) {
      final shapeKey = _extractShape(row);
      shapeGroups.putIfAbsent(shapeKey, () => []).add(row);
    }

    for (final entry in shapeGroups.entries) {
      final stonesInShape = entry.value;
      final pairedIndices = <int>{};

      // Process stones within this shape group
      for (int i = 0; i < stonesInShape.length; i++) {
        if (pairedIndices.contains(i)) continue;
        final stoneA = stonesInShape[i];

        final isPairGroupA = _isPairGroup(
          stoneA['GroupType'] ?? stoneA['groupType'] ?? stoneA['category'],
        );

        if (isPairGroupA) {
          // Look for partner stone within the selected stones of this shape
          int partnerIdx = -1;
          for (int j = i + 1; j < stonesInShape.length; j++) {
            if (pairedIndices.contains(j)) continue;
            final stoneB = stonesInShape[j];
            if (_isPairMatch(stoneA, stoneB, fallbackCutNo: kapanNo)) {
              partnerIdx = j;
              break;
            }
          }

          if (partnerIdx != -1) {
            pairedIndices.add(i);
            pairedIndices.add(partnerIdx);

            final pairStones = [stoneA, stonesInShape[partnerIdx]];
            // Sort stones naturally so lower/base packet is first (e.g. DC-79 before DC-79-1)
            pairStones.sort((a, b) => _comparePackets(a, b));

            final rawShape = (pairStones.first['Shape'] ??
                    pairStones.first['shape'] ??
                    pairStones.first['ShapeName'] ??
                    pairStones.first['shapeName'] ??
                    entry.key)
                .toString();
            final shape = _formatShapeName(rawShape);

            final stoneCount = pairStones.length;
            double totalWt = 0.0;
            for (final s in pairStones) {
              totalWt += _extractWeight(s);
            }
            String wtStr = totalWt.toStringAsFixed(3);
            if (wtStr.endsWith('0')) {
              wtStr = totalWt.toStringAsFixed(2);
            }

            final line1 = [
              if (shape.isNotEmpty) shape,
              '$stoneCount - $wtStr',
            ].join(' ');

            final pktNos = pairStones
                .map((s) => _formatPktWithCutNo(
                      s,
                      parentRow: stoneA,
                      fallbackCutNo: kapanNo,
                    ))
                .where((p) => p.isNotEmpty && p != '-')
                .toSet()
                .toList();
            final line2 = pktNos.join(' / ');
            final stoneLines = pairStones.map((s) => _buildStoneDetailLine(s)).toList();

            // When 2 stones form a pair, generate 2 identical prints
            _addLabelPage(
              pdf: pdf,
              fontBold: fontBold,
              line1: line1,
              line2: line2,
              stoneLines: stoneLines,
            );
            _addLabelPage(
              pdf: pdf,
              fontBold: fontBold,
              line1: line1,
              line2: line2,
              stoneLines: stoneLines,
            );
            continue;
          }
        }

        // Single print for Fancy stones or Pair stones without partner in selected rows
        pairedIndices.add(i);

        final rawShape = (stoneA['Shape'] ??
                stoneA['shape'] ??
                stoneA['ShapeName'] ??
                stoneA['shapeName'] ??
                entry.key)
            .toString();
        final shape = _formatShapeName(rawShape);

        final wt = _extractWeight(stoneA);
        String wtStr = wt.toStringAsFixed(3);
        if (wtStr.endsWith('0')) {
          wtStr = wt.toStringAsFixed(2);
        }

        final line1 = [
          if (shape.isNotEmpty) shape,
          '1 - $wtStr',
        ].join(' ');

        final line2 = _formatPktWithCutNo(
          stoneA,
          fallbackCutNo: kapanNo,
        );

        final stoneLines = [_buildStoneDetailLine(stoneA)];

        _addLabelPage(
          pdf: pdf,
          fontBold: fontBold,
          line1: line1,
          line2: line2,
          stoneLines: stoneLines,
        );
      }
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
