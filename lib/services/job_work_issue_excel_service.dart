import 'dart:typed_data';
import 'package:excel/excel.dart' hide TextSpan;
import '../models/job_work_issue_model.dart';
import 'file_saver/file_saver.dart';

class JobWorkIssueExcelService {
  static Future<String?> exportDetails({
    required String masterId,
    required String date,
    required String partyName,
    required String processName,
    required List<JobWorkIssueDetModel> rows,
    required List<String> columns,
    required Map<String, String> columnLabels,
    required String fileName,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];

    // ── Common Borders ───────────────────────────────────────────────────────
    final cellBorder = Border(
      borderStyle: BorderStyle.Thin,
      borderColorHex: ExcelColor.fromHexString('#CBD5E1'),
    );

    final headerBorder = Border(
      borderStyle: BorderStyle.Thin,
      borderColorHex: ExcelColor.fromHexString('#475569'),
    );

    final totalTopBorder = Border(
      borderStyle: BorderStyle.Thin,
      borderColorHex: ExcelColor.fromHexString('#93C5FD'),
    );

    final totalBottomBorder = Border(
      borderStyle: BorderStyle.Double,
      borderColorHex: ExcelColor.fromHexString('#1E40AF'),
    );

    int rowIdx = 0;

    // ── 1. Title Banner ──────────────────────────────────────────────────────
    final titleCell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIdx),
    );
    titleCell.value = TextCellValue('JOB WORK ISSUE DETAILS');
    titleCell.cellStyle = CellStyle(
      bold: true,
      fontSize: 13,
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      backgroundColorHex: ExcelColor.fromHexString('#107C41'), // Excel Green
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    // Merge title across columns
    if (columns.isNotEmpty) {
      sheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIdx),
        CellIndex.indexByColumnRow(columnIndex: columns.length - 1, rowIndex: rowIdx),
      );
    }
    sheet.setRowHeight(rowIdx, 32);
    rowIdx++;

    // ── 2. Meta Info Banner ──────────────────────────────────────────────────
    final metaInfo = <String>[];
    if (masterId.isNotEmpty && masterId != '0') {
      metaInfo.add('Issue ID: #$masterId');
    }
    if (date.isNotEmpty) {
      metaInfo.add('Date: $date');
    }
    if (partyName.isNotEmpty) {
      metaInfo.add('Party: $partyName');
    }
    if (processName.isNotEmpty) {
      metaInfo.add('Process: $processName');
    }
    metaInfo.add('Total Records: ${rows.length}');

    final metaCell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIdx),
    );
    metaCell.value = TextCellValue(metaInfo.join('   |   '));
    metaCell.cellStyle = CellStyle(
      italic: true,
      fontSize: 10,
      fontColorHex: ExcelColor.fromHexString('#334155'),
      backgroundColorHex: ExcelColor.fromHexString('#F1F5F9'),
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      leftBorder: cellBorder,
      rightBorder: cellBorder,
      topBorder: cellBorder,
      bottomBorder: cellBorder,
    );
    if (columns.isNotEmpty) {
      sheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIdx),
        CellIndex.indexByColumnRow(columnIndex: columns.length - 1, rowIndex: rowIdx),
      );
    }
    sheet.setRowHeight(rowIdx, 24);
    rowIdx++;

    // Empty separator row
    sheet.setRowHeight(rowIdx, 12);
    rowIdx++;

    // ── 3. Column Headers ─────────────────────────────────────────────────────
    final headerRowIdx = rowIdx;
    for (int colIdx = 0; colIdx < columns.length; colIdx++) {
      final colKey = columns[colIdx];
      final label = columnLabels[colKey] ?? colKey.toUpperCase();
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: colIdx, rowIndex: headerRowIdx),
      );
      cell.value = TextCellValue(label);
      cell.cellStyle = CellStyle(
        bold: true,
        fontSize: 10,
        fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
        backgroundColorHex: ExcelColor.fromHexString('#1E293B'),
        horizontalAlign: _isNumericCol(colKey)
            ? HorizontalAlign.Right
            : (_isCenterCol(colKey) ? HorizontalAlign.Center : HorizontalAlign.Left),
        verticalAlign: VerticalAlign.Center,
        leftBorder: headerBorder,
        rightBorder: headerBorder,
        topBorder: headerBorder,
        bottomBorder: headerBorder,
      );
    }
    sheet.setRowHeight(headerRowIdx, 26);
    rowIdx++;

    // ── 4. Data Rows ──────────────────────────────────────────────────────────
    final sortedRows = List<JobWorkIssueDetModel>.from(rows)
      ..sort((a, b) => (a.srno ?? 0).compareTo(b.srno ?? 0));

    for (int i = 0; i < sortedRows.length; i++) {
      final r = sortedRows[i];
      final isEven = i % 2 == 0;
      final rowBgColor = isEven
          ? ExcelColor.fromHexString('#FFFFFF')
          : ExcelColor.fromHexString('#F8FAFC');

      for (int colIdx = 0; colIdx < columns.length; colIdx++) {
        final colKey = columns[colIdx];
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: colIdx, rowIndex: rowIdx),
        );

        _populateCellValue(cell, colKey, r);

        final numFmt = _isThreeDecimalCol(colKey)
            ? NumFormat.custom(formatCode: '0.000')
            : (_isTwoDecimalCol(colKey)
                ? NumFormat.custom(formatCode: '0.00')
                : NumFormat.standard_0);

        cell.cellStyle = CellStyle(
          fontSize: 10,
          fontColorHex: ExcelColor.fromHexString('#1E293B'),
          backgroundColorHex: rowBgColor,
          numberFormat: numFmt,
          horizontalAlign: _isNumericCol(colKey)
              ? HorizontalAlign.Right
              : (_isCenterCol(colKey) ? HorizontalAlign.Center : HorizontalAlign.Left),
          verticalAlign: VerticalAlign.Center,
          leftBorder: cellBorder,
          rightBorder: cellBorder,
          topBorder: cellBorder,
          bottomBorder: cellBorder,
        );
      }
      sheet.setRowHeight(rowIdx, 22);
      rowIdx++;
    }

    // ── 5. Totals Row ─────────────────────────────────────────────────────────
    final totalRowIdx = rowIdx;
    final totPc = sortedRows.fold(0, (s, r) => s + r.pc);
    final totWt = sortedRows.fold(0.0, (s, r) => s + r.wt);
    final totIssPc = sortedRows.fold(0, (s, r) => s + r.issPc);
    final totIssWt = sortedRows.fold(0.0, (s, r) => s + r.issWt);
    final totRecPc = sortedRows.fold(0, (s, r) => s + (r.recPc ?? 0));
    final totRecWt = sortedRows.fold(0.0, (s, r) => s + (r.recWt ?? 0.0));
    final totDmWt = sortedRows.fold(0.0, (s, r) => s + r.dmWt);
    final totDmPer = sortedRows.fold(0.0, (s, r) => s + r.dmPer);

    for (int colIdx = 0; colIdx < columns.length; colIdx++) {
      final colKey = columns[colIdx];
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: colIdx, rowIndex: totalRowIdx),
      );

      switch (colKey) {
        case 'srno':
          cell.value = TextCellValue('Total (${sortedRows.length})');
          break;
        case 'pc':
          cell.value = IntCellValue(totPc);
          break;
        case 'wt':
          cell.value = DoubleCellValue(double.parse(totWt.toStringAsFixed(3)));
          break;
        case 'issPc':
          cell.value = IntCellValue(totIssPc);
          break;
        case 'issWt':
          cell.value = DoubleCellValue(double.parse(totIssWt.toStringAsFixed(3)));
          break;
        case 'recPc':
          cell.value = IntCellValue(totRecPc);
          break;
        case 'recWt':
          cell.value = DoubleCellValue(double.parse(totRecWt.toStringAsFixed(3)));
          break;
        case 'dmWt':
          cell.value = DoubleCellValue(double.parse(totDmWt.toStringAsFixed(3)));
          break;
        case 'dmPer':
          cell.value = DoubleCellValue(double.parse(totDmPer.toStringAsFixed(2)));
          break;
        default:
          cell.value = TextCellValue('');
          break;
      }

      final numFmt = _isThreeDecimalCol(colKey)
          ? NumFormat.custom(formatCode: '0.000')
          : (_isTwoDecimalCol(colKey)
              ? NumFormat.custom(formatCode: '0.00')
              : NumFormat.standard_0);

      cell.cellStyle = CellStyle(
        bold: true,
        fontSize: 10,
        fontColorHex: ExcelColor.fromHexString('#1E40AF'),
        backgroundColorHex: ExcelColor.fromHexString('#EFF6FF'),
        numberFormat: numFmt,
        horizontalAlign: _isNumericCol(colKey)
            ? HorizontalAlign.Right
            : (_isCenterCol(colKey) ? HorizontalAlign.Center : HorizontalAlign.Left),
        verticalAlign: VerticalAlign.Center,
        leftBorder: cellBorder,
        rightBorder: cellBorder,
        topBorder: totalTopBorder,
        bottomBorder: totalBottomBorder,
      );
    }
    sheet.setRowHeight(totalRowIdx, 24);

    // ── 6. Explicit Column Widths (Calculated per column, No AutoFit bug) ─────
    for (int colIdx = 0; colIdx < columns.length; colIdx++) {
      final colKey = columns[colIdx];
      final label = columnLabels[colKey] ?? colKey.toUpperCase();
      final width = _calcColWidth(colKey, label, sortedRows);
      sheet.setColumnWidth(colIdx, width);
    }

    // ── 7. Save / Download ────────────────────────────────────────────────────
    final bytes = Uint8List.fromList(excel.encode()!);
    final savedPath = await saveBinaryFile(
      bytes: bytes,
      fileName: fileName,
      mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    );
    return savedPath;
  }

  static double _calcColWidth(
    String colKey,
    String label,
    List<JobWorkIssueDetModel> rows,
  ) {
    int maxLen = label.length;
    for (final r in rows) {
      final str = _getColString(colKey, r);
      if (str.length > maxLen) {
        maxLen = str.length;
      }
    }

    // Minimum baseline width map
    final minMap = <String, double>{
      'srno': 11.0,
      'mfgCut': 14.0,
      'qrCode': 16.0,
      'bCode': 12.0,
      'pktNo': 12.0,
      'pairNo': 12.0,
      'pc': 9.0,
      'wt': 12.0,
      'issPc': 10.0,
      'issWt': 12.0,
      'recPc': 10.0,
      'recWt': 12.0,
      'purityCode': 13.0,
      'charniCode': 12.0,
      'colorCode': 12.0,
      'shapeCode': 14.0,
      'size': 10.0,
      'cutCode': 16.0,
      'length': 10.0,
      'diam': 10.0,
      'height': 10.0,
      'polishCode': 14.0,
      'topSide': 12.0,
      'symmetryCode': 14.0,
      'fluoCode': 12.0,
      'dmWt': 12.0,
      'dmPer': 10.0,
    };

    // SR NO should remain clean and compact
    if (colKey == 'srno') {
      return 11.0;
    }

    final minW = minMap[colKey] ?? 12.0;
    final calculated = (maxLen + 4).toDouble();
    return calculated > minW ? calculated : minW;
  }

  static String _getColString(String colKey, JobWorkIssueDetModel r) {
    switch (colKey) {
      case 'srno':
        return '${r.srno ?? 0}';
      case 'mfgCut':
        return r.mfgCut.isNotEmpty ? r.mfgCut : r.cutNo;
      case 'qrCode':
        return r.qrCode ?? '';
      case 'bCode':
        return r.bCode != 0 ? '${r.bCode}' : '';
      case 'pktNo':
        return r.pktNo;
      case 'pairNo':
        return r.pairNo?.toString() ?? '';
      case 'pc':
        return '${r.pc}';
      case 'wt':
        return r.wt.toStringAsFixed(3);
      case 'issPc':
        return '${r.issPc}';
      case 'issWt':
        return r.issWt.toStringAsFixed(3);
      case 'recPc':
        return '${r.recPc ?? 0}';
      case 'recWt':
        return (r.recWt ?? 0.0).toStringAsFixed(3);
      case 'purityCode':
        return r.purityName ?? r.purity ?? '';
      case 'charniCode':
        return r.charniName ?? r.charni ?? '';
      case 'colorCode':
        return r.colorName ?? r.color ?? '';
      case 'shapeCode':
        return r.shapeName ?? r.shape ?? '';
      case 'size':
        return r.size.toStringAsFixed(3);
      case 'cutCode':
        return r.cutName ?? r.cut ?? '';
      case 'length':
        return r.length.toStringAsFixed(2);
      case 'diam':
        return r.diam.toStringAsFixed(2);
      case 'height':
        return (r.height ?? 0.0).toStringAsFixed(2);
      case 'polishCode':
        return r.polishName ?? r.polish ?? '';
        case 'topSide':
        return r.topSide ?? '';
      case 'symmetryCode':
        return r.symmetryName ?? r.symmetry ?? '';
      case 'fluoCode':
        return r.fluoName ?? r.fluo ?? '';
      case 'dmWt':
        return r.dmWt.toStringAsFixed(3);
      case 'dmPer':
        return r.dmPer.toStringAsFixed(2);
      default:
        return '';
    }
  }

  static bool _isThreeDecimalCol(String col) {
    return const {'wt', 'issWt', 'recWt', 'size', 'dmWt'}.contains(col);
  }

  static bool _isTwoDecimalCol(String col) {
    return const {'length', 'diam', 'height', 'dmPer'}.contains(col);
  }

  static bool _isNumericCol(String col) {
    return const {
      'pc',
      'wt',
      'issPc',
      'issWt',
      'recPc',
      'recWt',
      'size',
      'length',
      'diam',
      'height',
      'dmWt',
      'dmPer',
    }.contains(col);
  }

  static bool _isCenterCol(String col) {
    return const {
      'srno',
      'bCode',
      'pktNo',
      'pairNo',
      'qrCode',
      'purityCode',
      'charniCode',
      'colorCode',
      'shapeCode',
      'cutCode',
      'topSide',
      'polishCode',
      'symmetryCode',
      'fluoCode',
    }.contains(col);
  }

  static void _populateCellValue(Data cell, String colKey, JobWorkIssueDetModel r) {
    switch (colKey) {
      case 'srno':
        cell.value = IntCellValue(r.srno ?? 0);
        break;
      case 'mfgCut':
        cell.value = TextCellValue(r.mfgCut.isNotEmpty ? r.mfgCut : r.cutNo);
        break;
      case 'qrCode':
        cell.value = TextCellValue(r.qrCode ?? '');
        break;
      case 'bCode':
        cell.value = (r.bCode != 0) ? IntCellValue(r.bCode) : TextCellValue('');
        break;
      case 'pktNo':
        cell.value = TextCellValue(r.pktNo);
        break;
      case 'pairNo':
        cell.value = TextCellValue(r.pairNo?.toString() ?? '');
        break;
      case 'pc':
        cell.value = IntCellValue(r.pc);
        break;
      case 'wt':
        cell.value = DoubleCellValue(double.parse(r.wt.toStringAsFixed(3)));
        break;
      case 'issPc':
        cell.value = IntCellValue(r.issPc);
        break;
      case 'issWt':
        cell.value = DoubleCellValue(double.parse(r.issWt.toStringAsFixed(3)));
        break;
      case 'recPc':
        cell.value = IntCellValue(r.recPc ?? 0);
        break;
      case 'recWt':
        cell.value = DoubleCellValue(double.parse((r.recWt ?? 0.0).toStringAsFixed(3)));
        break;
      case 'purityCode':
        cell.value = TextCellValue(r.purityName ?? r.purity ?? '');
        break;
      case 'charniCode':
        cell.value = TextCellValue(r.charniName ?? r.charni ?? '');
        break;
      case 'colorCode':
        cell.value = TextCellValue(r.colorName ?? r.color ?? '');
        break;
      case 'shapeCode':
        cell.value = TextCellValue(r.shapeName ?? r.shape ?? '');
        break;
      case 'size':
        cell.value = DoubleCellValue(double.parse(r.size.toStringAsFixed(3)));
        break;
      case 'cutCode':
        cell.value = TextCellValue(r.cutName ?? r.cut ?? '');
        break;
      case 'length':
        cell.value = DoubleCellValue(double.parse(r.length.toStringAsFixed(2)));
        break;
      case 'diam':
        cell.value = DoubleCellValue(double.parse(r.diam.toStringAsFixed(2)));
        break;
      case 'height':
        cell.value = DoubleCellValue(double.parse((r.height ?? 0.0).toStringAsFixed(2)));
        break;
      case 'topSide':
        cell.value = TextCellValue(r.topSide ?? '');
        break;
      case 'polishCode':
        cell.value = TextCellValue(r.polishName ?? r.polish ?? '');
        break;
      case 'symmetryCode':
        cell.value = TextCellValue(r.symmetryName ?? r.symmetry ?? '');
        break;
      case 'fluoCode':
        cell.value = TextCellValue(r.fluoName ?? r.fluo ?? '');
        break;
      case 'dmWt':
        cell.value = DoubleCellValue(double.parse(r.dmWt.toStringAsFixed(3)));
        break;
      case 'dmPer':
        cell.value = DoubleCellValue(double.parse(r.dmPer.toStringAsFixed(2)));
        break;
      default:
        cell.value = TextCellValue('');
        break;
    }
  }
}
