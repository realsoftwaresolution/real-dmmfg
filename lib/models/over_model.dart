import '../utils/helper_functions.dart';

class OverModel {
  final int? fcOverMstID;
  final int? fcOverCode;
  final String? fcOverName;
  final String? sflag;
  final String? sdate;
  final int? logID;
  final String? pcID;
  final String? companyName;
  final int? ever;
  final int? companyCode;
  final int? sortID;
  final bool? active;

  OverModel({
    this.fcOverMstID,
    this.fcOverCode,
    this.fcOverName,
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

  factory OverModel.fromJson(Map<String, dynamic> json) => OverModel(
    fcOverMstID: json['FcOverMstID'],
    fcOverCode: json['FcOverCode'],
    fcOverName: json['FcOverName'],
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
    'FcOverCode': fcOverCode,
    'FcOverName': fcOverName,
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
    'fcOverCode': fcOverCode,
    'fcOverName': fcOverName ?? '',
    'CompanyName': companyName ?? '',
    'companyCode': company ?? companyCode?.toString() ?? '',  // ← name show karega
    'sortID': sortID?.toString() ?? '',
    'active': active == true ? 'Yes' : 'No',
    '_raw': this,
  };

  static OverModel fromFormValues(Map<String, dynamic> v) => OverModel(
    fcOverCode: int.tryParse(v['fcOverCode'] ?? ''),
    fcOverName: v['fcOverName'],
    companyCode: int.tryParse(v['companyCode'] ?? ''),
    sortID: int.tryParse(v['sortID'] ?? ''),
    // active: v['active'] == 'Y',
    active: parseBool(v['active']),

  );
}