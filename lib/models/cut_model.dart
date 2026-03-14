import '../utils/helper_functions.dart';

class CutModel {
  final int? cutMstID;
  final int? cutCode;
  final String? cutName;
  final String? sflag;
  final String? sdate;
  final int? logID;
  final String? pcID;
  final int? ever;
  final int? companyCode;
  final int? sortID;
  final bool? active;

  CutModel({
    this.cutMstID,
    this.cutCode,
    this.cutName,
    this.sflag,
    this.sdate,
    this.logID,
    this.pcID,
    this.ever,
    this.companyCode,
    this.sortID,
    this.active,
  });

  factory CutModel.fromJson(Map<String, dynamic> json) => CutModel(
    cutMstID: json['CutMstID'],
    cutCode: json['CutCode'],
    cutName: json['CutName'],
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
    'CutCode': cutCode,
    'CutName': cutName,
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
    'cutCode': cutCode,
    'cutName': cutName ?? '',
    'companyCode': companyName ?? companyCode?.toString() ?? '',  // ← name show karega
    'sortID': sortID?.toString() ?? '',
    'active': active == true ? 'Yes' : 'No',
    '_raw': this,
  };

  static CutModel fromFormValues(Map<String, dynamic> v) => CutModel(
    cutCode: int.tryParse(v['cutCode'] ?? ''),
    cutName: v['cutName'],
    companyCode: int.tryParse(v['companyCode'] ?? ''),
    sortID: int.tryParse(v['sortID'] ?? ''),
    // active: v['active'] == 'Y',
    active: parseBool(v['active']),

  );
}