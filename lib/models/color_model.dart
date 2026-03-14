import '../utils/helper_functions.dart';

class ColorModel {
  final int? colorMstID;
  final int? colorCode;
  final String? colorName;
  final int? colorRptGroupCode;
  final String? sflag;
  final String? sdate;
  final int? logID;
  final String? pcID;
  final int? ever;
  final int? companyCode;
  final int? sortID;
  final bool? active;
  final bool? pg;

  ColorModel({
    this.colorMstID,
    this.colorCode,
    this.colorName,
    this.colorRptGroupCode,
    this.sflag,
    this.sdate,
    this.logID,
    this.pcID,
    this.ever,
    this.companyCode,
    this.sortID,
    this.active,
    this.pg,
  });

  factory ColorModel.fromJson(Map<String, dynamic> json) {
    return ColorModel(
      colorMstID: json['ColorMstID'],
      colorCode: json['ColorCode'],
      colorName: json['ColorName'],
      colorRptGroupCode: json['ColorRptGroupCode'],
      sflag: json['Sflag'],
      sdate: json['Sdate']?.toString(),
      logID: json['LogID'],
      pcID: json['PcID'],
      ever: json['Ever'],
      companyCode: json['CompanyCode'],
      sortID: json['SortID'],
      active: json['Active'],
      pg: json['PG'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ColorCode': colorCode,
      'ColorName': colorName,
      'ColorRptGroupCode': colorRptGroupCode,
      'CompanyCode': companyCode,
      'SortID': sortID,
      'Active': active,
      'PG': pg,
    };
  }

  Map<String, dynamic> toTableRow({String? companyName}) {
    return {
      'colorCode': colorCode,
      'colorName': colorName ?? '',
      'colorRptGroupCode': colorRptGroupCode?.toString() ?? '',
      'companyCode': companyName??companyCode?.toString() ?? '',
      'sortID': sortID?.toString() ?? '',
      'active': active == true ? 'Yes' : 'No',
      '_raw': this,
    };
  }

  static ColorModel fromFormValues(Map<String, dynamic> v) {
    return ColorModel(
      colorCode: int.tryParse(v['colorCode'] ?? ''),
      colorName: v['colorName'],
      colorRptGroupCode: int.tryParse(v['colorRptGroupCode'] ?? ''),
      companyCode: int.tryParse(v['companyCode'] ?? ''),
      sortID: int.tryParse(v['sortID'] ?? ''),
      // active: v['active'] == 'Y',
      // pg: v['pg'] == 'Y',
      active: parseBool(v['active']),       // ← FIX
      pg: parseBool(v['pg']),
    );
  }
}