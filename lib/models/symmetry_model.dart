import '../utils/helper_functions.dart';

class SymmetryModel {
  final int? symmetryMstID;
  final int? symmetryCode;
  final String? symmetryName;
  final String? sflag;
  final String? sdate;
  final int? logID;
  final String? pcID;
  final int? ever;
  final int? companyCode;
  final int? sortID;
  final bool? active;

  SymmetryModel({
    this.symmetryMstID,
    this.symmetryCode,
    this.symmetryName,
    this.sflag,
    this.sdate,
    this.logID,
    this.pcID,
    this.ever,
    this.companyCode,
    this.sortID,
    this.active,
  });

  factory SymmetryModel.fromJson(Map<String, dynamic> json) => SymmetryModel(
    symmetryMstID: json['SymmetryMstID'],
    symmetryCode: json['SymmetryCode'],
    symmetryName: json['SymmetryName'],
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
    'SymmetryCode': symmetryCode,
    'SymmetryName': symmetryName,
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
    'symmetryCode': symmetryCode,
    'symmetryName': symmetryName ?? '',
    'companyCode': companyName ?? companyCode?.toString() ?? '',  // ← name show karega
    'sortID': sortID?.toString() ?? '',
    'active': active == true ? 'Yes' : 'No',
    '_raw': this,
  };

  static SymmetryModel fromFormValues(Map<String, dynamic> v) => SymmetryModel(
    symmetryCode: int.tryParse(v['symmetryCode'] ?? ''),
    symmetryName: v['symmetryName'],
    companyCode: int.tryParse(v['companyCode'] ?? ''),
    sortID: int.tryParse(v['sortID'] ?? ''),
    // active: v['active'] == 'Y',
    active: parseBool(v['active']),

  );
}