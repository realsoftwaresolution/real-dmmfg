import '../utils/helper_functions.dart';

class FColorModel {
  final int? fColorMstID;
  final int? fColorCode;
  final String? fColorName;
  final String? sflag;
  final String? sdate;
  final String? type;
  final int? logID;
  final String? pcID;
  final String? companyName;
  final int? ever;
  final int? companyCode;
  final int? sortID;
  final bool? active;

  FColorModel({
    this.fColorMstID,
    this.fColorCode,
    this.fColorName,
    this.type,
    this.sflag,
    this.sdate,
    this.logID,
    this.pcID,
    this.ever,
    this.companyCode,
    this.companyName,
    this.sortID,
    this.active,
  });

  factory FColorModel.fromJson(Map<String, dynamic> json) => FColorModel(
    fColorMstID: json['FColorMstID'],
    fColorCode: json['FColorCode'],
    fColorName: json['FColorName'],
    sflag: json['Sflag'],
    type: json['Type'],
    sdate: json['Sdate']?.toString(),
    logID: json['LogID'],
    pcID: json['PcID'],
    ever: json['Ever'],
    companyCode: json['CompanyCode'],
    companyName: json['CompanyName'],
    sortID: json['SortID'],
    active: json['Active'],
  );

  Map<String, dynamic> toJson() => {
    'FColorCode': fColorCode,
    'FColorName': fColorName,
    'Sflag': sflag,
    'Sdate': sdate,
    'Type': type,
    'LogID': logID,
    'PcID': pcID,
    'Ever': ever,
    'CompanyCode': companyCode,
    'CompanyName': companyName,
    'SortID': sortID,
    'Active': active,
  };

  Map<String, dynamic> toTableRow({String? company}) => {
    'fColorCode': fColorCode,
    'fColorName': fColorName ?? '',
    'type': type   ?? '',
    'CompanyName': companyName ?? '',
    'companyCode': company ?? companyCode?.toString() ?? '',  // ← name show karega
    'sortID': sortID?.toString() ?? '',
    'active': active == true ? 'Yes' : 'No',
    '_raw': this,
  };

  static FColorModel fromFormValues(Map<String, dynamic> v) => FColorModel(
    fColorCode: int.tryParse(v['fColorCode'] ?? ''),
    fColorName: v['fColorName'],
    type: v['type'],
    companyCode: int.tryParse(v['companyCode'] ?? ''),
    sortID: int.tryParse(v['sortID'] ?? ''),
    active: parseBool(v['active']),
  );
}