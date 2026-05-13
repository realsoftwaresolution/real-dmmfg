import '../utils/helper_functions.dart';

class PolishModel {
  final int? polishMstID;
  final int? polishCode;
  final String? polishName;
  final String? sflag;
  final String? sdate;
  final int? logID;
  final String? pcID;
  final int? ever;
  final int? companyCode;
  final int? sortID;
  final bool? active;

  PolishModel({
    this.polishMstID,
    this.polishCode,
    this.polishName,
    this.sflag,
    this.sdate,
    this.logID,
    this.pcID,
    this.ever,
    this.companyCode,
    this.sortID,
    this.active,
  });

  factory PolishModel.fromJson(Map<String, dynamic> json) => PolishModel(
    polishMstID: json['PolishMstID'],
    polishCode: json['PolishCode'],
    polishName: json['PolishName'],
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
    'PolishCode': polishCode,
    'PolishName': polishName,
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
    'polishCode': polishCode,
    'polishName': polishName ?? '',
    'companyCode': companyName ?? companyCode?.toString() ?? '',  // ← name show karega
    'sortID': sortID?.toString() ?? '',
    'active': active == true ? 'Yes' : 'No',
    '_raw': this,
  };

  static PolishModel fromFormValues(Map<String, dynamic> v) => PolishModel(
    polishCode: int.tryParse(v['polishCode'] ?? ''),
    polishName: v['polishName'],
    companyCode: int.tryParse(v['companyCode'] ?? ''),
    sortID: int.tryParse(v['sortID'] ?? ''),
    active: parseBool(v['active']),

  );
}