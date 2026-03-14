import 'package:diam_mfg/utils/helper_functions.dart';

class RoughTypeModel {
  final int? roughTypeMstID;
  final int? roughTypeCode;
  final String? roughTypeName;
  final String? sflag;
  final String? sdate;
  final int? logID;
  final String? pcID;
  final int? ever;
  final int? companyCode;
  final int? sortID;
  final bool? active;

  RoughTypeModel({
    this.roughTypeMstID,
    this.roughTypeCode,
    this.roughTypeName,
    this.sflag,
    this.sdate,
    this.logID,
    this.pcID,
    this.ever,
    this.companyCode,
    this.sortID,
    this.active,
  });

  factory RoughTypeModel.fromJson(Map<String, dynamic> json) => RoughTypeModel(
    roughTypeMstID: json['RoughTypeMstID'],
    roughTypeCode: json['RoughTypeCode'],
    roughTypeName: json['RoughTypeName'],
    sflag: json['Sflag'],
    sdate: json['Sdate']?.toString(),
    logID: json['LogID'],
    pcID: json['PcID'],
    ever: json['Ever'],
    companyCode: json['CompanyCode'],
    sortID: json['SortID'],
    active: json['Active'],
  );

  Map<String, dynamic> toJson() => {
    'RoughTypeCode': roughTypeCode,
    'RoughTypeName': roughTypeName,
    'Sflag': sflag,
    'Sdate': sdate,
    'LogID': logID,
    'PcID': pcID,
    'Ever': ever,
    'CompanyCode': companyCode,
    'SortID': sortID,
    'Active': active,
  };

  Map<String, dynamic> toTableRow({String? companyName}) => {
    'roughTypeCode': roughTypeCode,
    'roughTypeName': roughTypeName ?? '',
    'companyCode': companyName??companyCode?.toString() ?? '',
    'sortID': sortID?.toString() ?? '',
    'active': active == true ? 'Yes' : 'No',
    '_raw': this,
  };

  static RoughTypeModel fromFormValues(Map<String, dynamic> v) => RoughTypeModel(
    roughTypeCode: int.tryParse(v['roughTypeCode'] ?? ''),
    roughTypeName: v['roughTypeName'],
    companyCode: int.tryParse(v['companyCode'] ?? ''),
    sortID: int.tryParse(v['sortID'] ?? ''),
    active: parseBool(v['active']),
  );
}