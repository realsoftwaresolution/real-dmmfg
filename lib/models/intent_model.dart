import '../utils/helper_functions.dart';

class IntentModel {
  final int? fcIntentMstID;
  final int? fcIntentCode;
  final String? fcIntentName;
  final String? sflag;
  final String? sdate;
  final int? logID;
  final String? pcID;
  final String? companyName;
  final int? ever;
  final int? companyCode;
  final int? sortID;
  final bool? active;

  IntentModel({
    this.fcIntentMstID,
    this.fcIntentCode,
    this.fcIntentName,
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

  factory IntentModel.fromJson(Map<String, dynamic> json) => IntentModel(
    fcIntentMstID: json['FcIntentMstID'],
    fcIntentCode: json['FcIntentCode'],
    fcIntentName: json['FcIntentName'],
    sflag: json['Sflag'],
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
    'FcIntentCode': fcIntentCode,
    'FcIntentName': fcIntentName,
    'Sflag': sflag,
    'Sdate': sdate,
    'LogID': logID,
    'PcID': pcID,
    'Ever': ever,
    'CompanyCode': companyCode,
    'CompanyName': companyName,
    'SortID': sortID,
    'Active': active,
  };

  Map<String, dynamic> toTableRow({String? company}) => {
    'fcIntentCode': fcIntentCode,
    'fcIntentName': fcIntentName ?? '',
    'CompanyName': companyName ?? '',
    'companyCode': company ?? companyCode?.toString() ?? '',  // ← name show karega
    'sortID': sortID?.toString() ?? '',
    'active': active == true ? 'Yes' : 'No',
    '_raw': this,
  };

  static IntentModel fromFormValues(Map<String, dynamic> v) => IntentModel(
    fcIntentCode: int.tryParse(v['fcIntentCode'] ?? ''),
    fcIntentName: v['fcIntentName'],
    companyCode: int.tryParse(v['companyCode'] ?? ''),
    sortID: int.tryParse(v['sortID'] ?? ''),
    // active: v['active'] == 'Y',
    active: parseBool(v['active']),

  );
}