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
  });

  factory SellPriceModel.fromJson(Map<String, dynamic> json) {
    return SellPriceModel(
      sellPriceListMstID: json['SellPriceListMstID'] as int?,
      sellCode: json['SellCode'] as String?,
      articalCode: json['ArticalCode'] as int?,
      articalName: json['ArticalName'] as String?,
      shapeCode: json['ShapeCode'] as int?,
      shapeName: json['ShapeName'] as String?,
      length: _toDouble(json['Length']),
      width: _toDouble(json['Width']),
      height: _toDouble(json['Height']),
      rate: _toDouble(json['Rate']),
      sdate: json['Sdate'] != null
          ? DateTime.tryParse(json['Sdate'].toString())
          : null,
      companyCode: json['CompanyCode'] as int?,
      companyName: json['CompanyName'] as String?,
      sortID: json['SortID'] as int?,
      active: json['Active'] == 1 || json['Active'] == true,
      colorCodes: (json['colorCodes'] as List<dynamic>? ?? [])
          .map((e) => int.tryParse(e.toString()) ?? 0)
          .toList(),
      colors: json['colors'] as String?,
      purityCodes: (json['purityCodes'] as List<dynamic>? ?? [])
          .map((e) => int.tryParse(e.toString()) ?? 0)
          .toList(),
      purities: json['purities'] as String?,
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

  /// Maps this model to a row for ErpDataTable.
  /// Keys here MUST match the `key` values used in
  /// MstSellPrice._tableColumns.
  Map<String, dynamic> toTableRow() {
    return {
      'sellCode': sellCode ?? '',
      'articalName': articalName ?? '',
      'shapeName': shapeName ?? '',
      'length': _fmtNum(length),
      'width': _fmtNum(width),
      'height': _fmtNum(height),
      'rate': _fmtNum(rate),
      'companyName': companyName ?? '',
      'colors': colors ?? '',
      'purities': purities ?? '',
      'sortID': sortID?.toString() ?? '',
      'active': active == true ? 'Yes' : 'No',
      'sdate': _fmtDate(sdate),
      '_raw': this,
    };
  }
}