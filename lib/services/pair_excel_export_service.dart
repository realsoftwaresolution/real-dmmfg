import 'dart:typed_data';
import 'package:excel/excel.dart' hide TextSpan;
import 'package:flutter/material.dart' hide Border, BorderStyle;
import 'file_saver/file_saver.dart';

class PairExcelExportService {
  /// Exact 22 columns matching user image
  static const List<String> columns = [
    'TYPE',
    'REFNO',
    'COLOR',
    'CLARITY',
    'FLO',
    'SHAPE',
    'PCS',
    'CARAT',
    'RATE',
    'TOTAL',
    'LAB',
    'LENGTH',
    'WIDTH',
    'DEPTH',
    'TOP',
    'PAIR_NO',
    'CUT',
    'POLISH',
    'SYMMETRY',
    'CUT_TYPE',
    'REPORT_NO',
    'PCATEGORY_NAME',
  ];

  static String _toTitleCase(String str) {
    if (str.isEmpty) return '';
    return str.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  static String _extractPacketBase(String pkt) {
    final clean = pkt.trim();
    if (clean.isEmpty) return '';
    final stripped = clean.replaceAll(RegExp(r'[-_/.]([0-9]+|[A-Za-z]+)$'), '');
    if (stripped.isNotEmpty && stripped != clean) return stripped;
    final strippedLetters = clean.replaceAll(RegExp(r'(?<=\d)[A-Za-z]+$'), '');
    if (strippedLetters.isNotEmpty && strippedLetters != clean) return strippedLetters;
    return clean;
  }

  static bool _isPairGroup(dynamic val) {
    if (val == null) return false;
    final str = val.toString().trim().toLowerCase();
    return str.contains('pair');
  }

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

  static String _resolvePartnerPktNo(
    Map<String, dynamic> row,
    List<Map<String, dynamic>> allRows,
  ) {
    final groupTypeRaw = (row['GroupType'] ?? row['groupType'] ?? row['category'] ?? '').toString();
    if (!_isPairGroup(groupTypeRaw)) {
      return '';
    }

    final curShape = _extractShape(row);
    final curPkt = (row['PktNo'] ?? row['pktNo'] ?? row['packetNo'] ?? row['PacketNo'] ?? '').toString().trim();
    final rawPair = (row['PairNo'] ?? row['pairNo'] ?? row['raw']?['PairNo'] ?? row['raw']?['pairNo'] ?? '').toString().trim();
    final hasValidPair = rawPair.isNotEmpty && rawPair != '-' && rawPair != '--' && rawPair != '0' && rawPair != 'null';

    // 1. Check by PairNo in allRows
    if (hasValidPair) {
      for (final other in allRows) {
        if (!_isPairGroup(other['GroupType'] ?? other['groupType'] ?? other['category'])) continue;
        if (_extractShape(other) != curShape) continue;

        final otherPkt = (other['PktNo'] ?? other['pktNo'] ?? other['packetNo'] ?? other['PacketNo'] ?? '').toString().trim();
        if (otherPkt.isEmpty || otherPkt == curPkt) continue;
        final otherPair = (other['PairNo'] ?? other['pairNo'] ?? other['raw']?['PairNo'] ?? other['raw']?['pairNo'] ?? '').toString().trim();
        if (otherPair == rawPair || otherPair == curPkt || otherPkt == rawPair) {
          return otherPkt;
        }
      }
    }

    // 2. Check by base packet prefix match
    final curBase = _extractPacketBase(curPkt);
    if (curBase.isNotEmpty) {
      for (final other in allRows) {
        if (!_isPairGroup(other['GroupType'] ?? other['groupType'] ?? other['category'])) continue;
        if (_extractShape(other) != curShape) continue;

        final otherPkt = (other['PktNo'] ?? other['pktNo'] ?? other['packetNo'] ?? other['PacketNo'] ?? '').toString().trim();
        if (otherPkt.isEmpty || otherPkt == curPkt) continue;
        final otherBase = _extractPacketBase(otherPkt);
        if (otherBase == curBase || otherPkt == curBase || otherBase == curPkt) {
          return otherPkt;
        }
      }
    }

    // 3. Fallback: if rawPair itself looks like a packet code
    if (hasValidPair && (rawPair.contains('-') || rawPair.contains('/') || rawPair.contains('_') || RegExp(r'[A-Za-z]').hasMatch(rawPair))) {
      return rawPair;
    }

    return '';
  }

  static Future<String?> exportPairExcel({
    required BuildContext context,
    required List<Map<String, dynamic>> selectedRows,
    required List<Map<String, dynamic>> allReportRows,
    String? fileName,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];

    // Border definitions (thin black border around all cells as shown in screenshot)
    final blackBorder = Border(
      borderStyle: BorderStyle.Thin,
      borderColorHex: ExcelColor.fromHexString('#000000'),
    );

    // Header styling: Medium Blue background (#5B9BD5), Bold text, size 10, center aligned
    final headerStyle = CellStyle(
      bold: true,
      fontSize: 10,
      fontColorHex: ExcelColor.fromHexString('#000000'),
      backgroundColorHex: ExcelColor.fromHexString('#5B9BD5'),
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      leftBorder: blackBorder,
      rightBorder: blackBorder,
      topBorder: blackBorder,
      bottomBorder: blackBorder,
    );

    // Row 0: Headers
    const int headerRowIdx = 0;
    for (int colIdx = 0; colIdx < columns.length; colIdx++) {
      final colName = columns[colIdx];
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: colIdx, rowIndex: headerRowIdx),
      );
      cell.value = TextCellValue(colName);
      cell.cellStyle = headerStyle;
    }
    sheet.setRowHeight(headerRowIdx, 26.0);

    // Data Rows
    final num2Format = NumFormat.custom(formatCode: '0.00');
    final intFormat = NumFormat.standard_0;

    // ── Sort rows: Shape-wise first, then GroupType == 'Pair' wise, then Packet/Cut ──
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

    for (int rIdx = 0; rIdx < sortedRows.length; rIdx++) {
      final row = sortedRows[rIdx];
      final sheetRowIdx = rIdx + 1;

      // Extract values
      final groupTypeRaw = (row['GroupType'] ?? row['groupType'] ?? row['category'] ?? '').toString().trim();
      final typeVal = groupTypeRaw.isEmpty || groupTypeRaw == '-' ? 'MATCHING PAIR' : groupTypeRaw.toUpperCase();

      final pktNoVal = (row['PktNo'] ?? row['pktNo'] ?? row['packetNo'] ?? row['PacketNo'] ?? '').toString().trim();
      final cutNoVal = (row['cutNo'] ?? row['cutNo'] ?? row['cutNo'] ?? row['cutNo'] ?? '').toString().trim();
      final refNoVal = cutNoVal.isNotEmpty ? '$cutNoVal-$pktNoVal' : pktNoVal;
      final colorVal = (row['Color'] ?? row['color'] ?? '').toString().trim().toUpperCase();

      final clarityVal = (row['Clarity'] ?? row['clarity'] ?? row['purity'] ?? row['Purity'] ?? '').toString().trim().toUpperCase();

      final flouRaw = (row['Flou'] ?? row['flou'] ?? row['fluo'] ?? row['Fluo'] ?? '').toString().trim();
      final flouVal = flouRaw.isEmpty || flouRaw == '-' || flouRaw.toUpperCase() == 'NONE' || flouRaw.toUpperCase() == 'NON'
          ? 'NONE'
          : flouRaw.toUpperCase();

      final shapeRaw = (row['Shape'] ?? row['shape'] ?? '').toString().trim();
      final shapeVal = _toTitleCase(shapeRaw);

      final pcsVal = int.tryParse('${row['Pc'] ?? row['pc'] ?? row['pcs'] ?? 1}') ?? 1;

      final caratVal = double.tryParse('${row['RecWt'] ?? row['recWt'] ?? row['Wt'] ?? row['wt'] ?? 0.0}') ?? 0.0;

      final rateVal = double.tryParse('${row['SellPrice'] ?? row['sellPrice'] ?? row['Rate'] ?? row['rate'] ?? 0.0}') ?? 0.0;

      var totalVal = double.tryParse('${row['SellAmount'] ?? row['sellAmount'] ?? row['totalPrice'] ?? ''}');
      if (totalVal == null || totalVal == 0.0) {
        totalVal = caratVal * rateVal;
      }

      final certRaw = (row['Certificate'] ?? row['certificate'] ?? '').toString().trim();
      final labVal = certRaw.isEmpty || certRaw == '-' ? 'NON' : certRaw.toUpperCase();

      final lengthVal = double.tryParse('${row['Length'] ?? row['length'] ?? 0.0}') ?? 0.0;
      final widthVal = double.tryParse('${row['Dia'] ?? row['dia'] ?? row['Width'] ?? row['width'] ?? 0.0}') ?? 0.0;
      final depthVal = double.tryParse('${row['Height'] ?? row['height'] ?? row['Depth'] ?? row['depth'] ?? 0.0}') ?? 0.0;
      final topVal = double.tryParse('${row['TopSide'] ?? row['topSide'] ?? row['topsSide'] ?? row['TopsSide'] ?? 0.0}') ?? 0.0;

      final pairNoVal = _resolvePartnerPktNo(row, allReportRows);

      final cutVal = (row['Cut'] ?? row['cut'] ?? '').toString().trim().toUpperCase();
      final polishVal = (row['Polish'] ?? row['polish'] ?? '').toString().trim().toUpperCase();
      final symmVal = (row['Symmetry'] ?? row['symmetry'] ?? '').toString().trim().toUpperCase();

      final cutTypeRaw = (row['CutType'] ?? row['cutType'] ?? row['Cut'] ?? row['cut'] ?? '').toString().trim();
      final cutTypeVal = cutTypeRaw.toUpperCase();

      final certiNoRaw = (row['CertiNo'] ?? row['certiNo'] ?? row['certificateNo'] ?? row['CertificateNo'] ?? row['ReportNo'] ?? '').toString().trim();
      final reportNoVal = (certiNoRaw == '-' || certiNoRaw == '0' || certiNoRaw == 'null') ? '' : certiNoRaw;

      final pCatRaw = (row['ArticalName'] ?? row['articalName'] ?? row['ArticalName'] ?? '').toString().trim();
      final pCatVal = pCatRaw.isEmpty || pCatRaw == '-' ? '-' : pCatRaw.toUpperCase();

      for (int cIdx = 0; cIdx < columns.length; cIdx++) {
        final colName = columns[cIdx];
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: cIdx, rowIndex: sheetRowIdx),
        );

        HorizontalAlign align = HorizontalAlign.Left;
        NumFormat numFormat = NumFormat.standard_0;

        switch (colName) {
          case 'TYPE':
            cell.value = TextCellValue(typeVal);
            align = HorizontalAlign.Left;
            break;
          case 'REFNO':
            cell.value = TextCellValue(refNoVal);
            align = HorizontalAlign.Left;
            break;
          case 'COLOR':
            cell.value = TextCellValue(colorVal);
            align = HorizontalAlign.Center;
            break;
          case 'CLARITY':
            cell.value = TextCellValue(clarityVal);
            align = HorizontalAlign.Center;
            break;
          case 'FLO':
            cell.value = TextCellValue(flouVal);
            align = HorizontalAlign.Center;
            break;
          case 'SHAPE':
            cell.value = TextCellValue(shapeVal);
            align = HorizontalAlign.Left;
            break;
          case 'PCS':
            cell.value = IntCellValue(pcsVal);
            align = HorizontalAlign.Right;
            numFormat = intFormat;
            break;
          case 'CARAT':
            cell.value = DoubleCellValue(double.parse(caratVal.toStringAsFixed(2)));
            align = HorizontalAlign.Right;
            numFormat = num2Format;
            break;
          case 'RATE':
            cell.value = DoubleCellValue(double.parse(rateVal.toStringAsFixed(2)));
            align = HorizontalAlign.Right;
            numFormat = num2Format;
            break;
          case 'TOTAL':
            cell.value = DoubleCellValue(double.parse(totalVal.toStringAsFixed(2)));
            align = HorizontalAlign.Right;
            numFormat = num2Format;
            break;
          case 'LAB':
            cell.value = TextCellValue(labVal);
            align = HorizontalAlign.Center;
            break;
          case 'LENGTH':
            cell.value = DoubleCellValue(double.parse(lengthVal.toStringAsFixed(2)));
            align = HorizontalAlign.Right;
            numFormat = num2Format;
            break;
          case 'WIDTH':
            cell.value = DoubleCellValue(double.parse(widthVal.toStringAsFixed(2)));
            align = HorizontalAlign.Right;
            numFormat = num2Format;
            break;
          case 'DEPTH':
            cell.value = DoubleCellValue(double.parse(depthVal.toStringAsFixed(2)));
            align = HorizontalAlign.Right;
            numFormat = num2Format;
            break;
          case 'TOP':
            cell.value = DoubleCellValue(double.parse(topVal.toStringAsFixed(2)));
            align = HorizontalAlign.Right;
            numFormat = num2Format;
            break;
          case 'PAIR_NO':
            cell.value = TextCellValue(pairNoVal);
            align = HorizontalAlign.Left;
            break;
          case 'CUT':
            cell.value = TextCellValue(cutVal);
            align = HorizontalAlign.Left;
            break;
          case 'POLISH':
            cell.value = TextCellValue(polishVal);
            align = HorizontalAlign.Center;
            break;
          case 'SYMMETRY':
            cell.value = TextCellValue(symmVal);
            align = HorizontalAlign.Center;
            break;
          case 'CUT_TYPE':
            cell.value = TextCellValue(cutTypeVal);
            align = HorizontalAlign.Left;
            break;
          case 'REPORT_NO':
            cell.value = TextCellValue(reportNoVal);
            align = HorizontalAlign.Left;
            break;
          case 'PCATEGORY_NAME':
            cell.value = TextCellValue(pCatVal);
            align = HorizontalAlign.Left;
            break;
        }

        cell.cellStyle = CellStyle(
          fontSize: 10,
          fontColorHex: ExcelColor.fromHexString('#000000'),
          backgroundColorHex: ExcelColor.fromHexString('#FFFFFF'),
          horizontalAlign: align,
          verticalAlign: VerticalAlign.Center,
          numberFormat: numFormat,
          leftBorder: blackBorder,
          rightBorder: blackBorder,
          topBorder: blackBorder,
          bottomBorder: blackBorder,
        );
      }
      sheet.setRowHeight(sheetRowIdx, 20.0);
    }

    // Set Column Widths based on content and minimum bounds
    final minWidths = <String, double>{
      'TYPE': 18.0,
      'REFNO': 14.0,
      'COLOR': 10.0,
      'CLARITY': 12.0,
      'FLO': 10.0,
      'SHAPE': 14.0,
      'PCS': 8.0,
      'CARAT': 11.0,
      'RATE': 12.0,
      'TOTAL': 12.0,
      'LAB': 9.0,
      'LENGTH': 11.0,
      'WIDTH': 11.0,
      'DEPTH': 11.0,
      'TOP': 10.0,
      'PAIR_NO': 14.0,
      'CUT': 13.0,
      'POLISH': 11.0,
      'SYMMETRY': 13.0,
      'CUT_TYPE': 13.0,
      'REPORT_NO': 14.0,
      'PCATEGORY_NAME': 18.0,
    };

    for (int colIdx = 0; colIdx < columns.length; colIdx++) {
      final colName = columns[colIdx];
      sheet.setColumnWidth(colIdx, minWidths[colName] ?? 12.0);
    }

    // Save and download file
    final now = DateTime.now();
    final defaultFileName = fileName ?? 'PAIR_DATA_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}.xlsx';

    final bytes = Uint8List.fromList(excel.encode()!);
    final savedPath = await saveBinaryFile(
      bytes: bytes,
      fileName: defaultFileName,
      mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Excel exported successfully: $defaultFileName'),
          backgroundColor: Colors.green.shade700,
        ),
      );
    }

    return savedPath;
  }
}
