import '../utils/helper_functions.dart';

class DeptGroupModel {
  final int? deptGroupMstID;
  final int? deptGroupCode;
  final String? deptGroupName;
  final String? sflag;
  final String? sdate;
  final int? logID;
  final String? pcID;
  final int? ever;
  final int? companyCode;
  final int? sortID;
  final bool? active;

  DeptGroupModel({
    this.deptGroupMstID,
    this.deptGroupCode,
    this.deptGroupName,
    this.sflag,
    this.sdate,
    this.logID,
    this.pcID,
    this.ever,
    this.companyCode,
    this.sortID,
    this.active,
  });

  factory DeptGroupModel.fromJson(Map<String, dynamic> json) {
    return DeptGroupModel(
      deptGroupMstID: json['DeptGroupMstID'],
      deptGroupCode: json['DeptGroupCode'],
      deptGroupName: json['DeptGroupName'],
      sflag: json['Sflag'],
      sdate: json['Sdate']?.toString(),
      logID: json['LogID'],
      pcID: json['PcID'],
      ever: json['Ever'],
      companyCode: json['CompanyCode'],
      sortID: json['SortID'],
      active: json['Active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'DeptGroupCode': deptGroupCode,
      'DeptGroupName': deptGroupName,
      'CompanyCode': companyCode,
      'SortID': sortID,
      'Active': active,
    };
  }

  Map<String, dynamic> toTableRow({String? companyName}) {
    return {
      'deptGroupCode': deptGroupCode,
      'deptGroupName': deptGroupName ?? '',
      'companyCode': companyName??companyCode?.toString() ?? '',
      'sortID': sortID?.toString() ?? '',
      'active': active == true ? 'Yes' : 'No',
      '_raw': this,
    };
  }

  static DeptGroupModel fromFormValues(Map<String, dynamic> v) {
    return DeptGroupModel(
      deptGroupCode: int.tryParse(v['deptGroupCode'] ?? ''),
      deptGroupName: v['deptGroupName'],
      companyCode: int.tryParse(v['companyCode'] ?? ''),
      sortID: int.tryParse(v['sortID'] ?? ''),
      // active: v['active'] == 'Y',
      active: parseBool(v['active']),

    );
  }
}