import 'package:diam_mfg/utils/constants.dart';

class SellPriceModel {
  final int? sellPriceListMstID;
  final String? sellCode;

  final int? articalCode;
  final String? articalName;

  final int? shapeCode;
  final String? shapeName;

  final double? length;
  final double? width;
  final double? height;
  final double? rate;

  final DateTime? sdate;

  final int? companyCode;
  final String? companyName;

  final int? sortID;
  final bool? active;

  final List<int> colorCodes;
  final String? colors;

  final List<int> purityCodes;
  final String? purities;

  final String? layoutNameField;
  final String? mm;

  SellPriceModel({
    this.sellPriceListMstID,
    this.sellCode,
    this.articalCode,
    this.articalName,
    this.shapeCode,
    this.shapeName,
    this.length,
    this.width,
    this.height,
    this.rate,
    this.sdate,
    this.companyCode,
    this.companyName,
    this.sortID,
    this.active,
    this.colorCodes = const [],
    this.colors,
    this.purityCodes = const [],
    this.purities,
    this.layoutNameField,
    this.mm,
  });

  factory SellPriceModel.fromJson(Map<String, dynamic> json) {
    return SellPriceModel(
      sellPriceListMstID: (json['SellPriceListMstID'] ?? json['sellPriceListMstID'] ?? json['sellPriceListDetID'] ?? json['SellPriceListDetID']) as int?,
      sellCode: (json['SellCode'] ?? json['sellCode']) as String?,
      articalCode: (json['ArticalCode'] ?? json['articalCode']) as int?,
      articalName: (json['ArticalName'] ?? json['articalName']) as String?,
      shapeCode: (json['ShapeCode'] ?? json['shapeCode']) as int?,
      shapeName: (json['ShapeName'] ?? json['shapeName']) as String?,
      length: _toDouble(json['Length'] ?? json['length']),
      width: _toDouble(json['Width'] ?? json['width']),
      height: _toDouble(json['Height'] ?? json['height']),
      rate: _toDouble(json['Rate'] ?? json['rate']),
      sdate: json['Sdate'] != null || json['sdate'] != null
          ? DateTime.tryParse((json['Sdate'] ?? json['sdate']).toString())
          : null,
      companyCode: (json['CompanyCode'] ?? json['companyCode']) as int?,
      companyName: (json['CompanyName'] ?? json['companyName']) as String?,
      sortID: (json['SortID'] ?? json['sortID']) as int?,
      active: json['Active'] == 1 || json['Active'] == true || json['active'] == 1 || json['active'] == true,
      colorCodes: (json['colorCodes'] as List<dynamic>? ?? [])
          .map((e) => int.tryParse(e.toString()) ?? 0)
          .toList(),
      colors: (json['colors'] ?? json['Colors']) as String?,
      purityCodes: (json['purityCodes'] as List<dynamic>? ?? [])
          .map((e) => int.tryParse(e.toString()) ?? 0)
          .toList(),
      purities: (json['purities'] ?? json['Purities']) as String?,
      layoutNameField: (json['LayoutName'] ?? json['layoutname'] ?? json['layoutName']) as String?,
      mm: (json['MM'] ?? json['mm']) as String?,
    );
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  static String _fmtNum(double? v) {
    if (v == null) return '';
    return v.toStringAsFixed(2);
  }

  static String _fmtDate(DateTime? d) {
    if (d == null) return '';
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }

  String get layoutName {
    if (layoutNameField != null && layoutNameField!.isNotEmpty) {
      return layoutNameField!;
    }
    final art = articalName ?? '';
    final col = colors ?? '';
    final pur = purities ?? '';
    return '$art $col - $pur';
  }

  static String _formatMmToDecimal(String val) {
    if (val.isEmpty) return '';
    final parts = val.split('*');
    final formattedParts = <String>[];
    for (final part in parts) {
      final numValue = double.tryParse(part.trim()) ?? 0.0;
      formattedParts.add(numValue.toStringAsFixed(2));
    }
    return formattedParts.join('*');
  }

  /// Maps this model to a row for ErpDataTable.
  /// Keys here MUST match the `key` values used in
  /// MstSellPrice._tableColumns.
  Map<String, dynamic> toTableRow() {
    return {
      'sellCode': sellCode ?? '',
      'articalName': articalName ?? '',
      'shapeName': shapeName ?? '',
      'mm': _formatMmToDecimal(mm ?? (length != null && width != null && height != null ? '${_fmtNum(length)}*${_fmtNum(width)}*${_fmtNum(height)}' : '')),
      'length': _fmtNum(length),
      'width': _fmtNum(width),
      'height': _fmtNum(height),
      'rate': _fmtNum(rate),
      'companyName': companyName ?? '',
      'colors': colors ?? '',
      'purities': purities ?? '',
      'layoutName': layoutName,
      'sortID': sortID?.toString() ?? '',
      'active': active == true ? 'Yes' : 'No',
      'sdate': formatDisplayDate(sdate),
      '_raw': this,
    };
  }
}