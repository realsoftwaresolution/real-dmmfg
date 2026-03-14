import '../utils/helper_functions.dart';

class PurityGroupModel {
  final int? purityGroupMstID;
  final int? purityGroupCode;
  final String? purityGroupName;
  final int? purityTypeCode;
  final String? sflag;
  final String? sdate;
  final int? logID;
  final String? pcID;
  final int? ever;
  final int? companyCode;
  final int? sortID;
  final bool? active;
  final String? delRights;

  PurityGroupModel({
    this.purityGroupMstID,
    this.purityGroupCode,
    this.purityGroupName,
    this.purityTypeCode,
    this.sflag,
    this.sdate,
    this.logID,
    this.pcID,
    this.ever,
    this.companyCode,
    this.sortID,
    this.active,
    this.delRights,
  });

  factory PurityGroupModel.fromJson(Map<String, dynamic> json) {
    return PurityGroupModel(
      purityGroupMstID: json['PurityGroupMstID'],
      purityGroupCode: json['PurityGroupCode'],
      purityGroupName: json['PurityGroupName'],
      purityTypeCode: json['PurityTypeCode'],
      sflag: json['Sflag'],
      sdate: json['Sdate']?.toString(),
      logID: json['LogID'],
      pcID: json['PcID'],
      ever: json['Ever'],
      companyCode: json['CompanyCode'],
      sortID: json['SortID'],
      active: json['Active'],
      // active: json['Active'] == '1' || json['Active'] == true,
      delRights: json['DelRights'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'PurityGroupCode': purityGroupCode,
      'PurityGroupName': purityGroupName,
      'PurityTypeCode': purityTypeCode,
      'CompanyCode': companyCode,
      'SortID': sortID,
      'Active': active,
      'DelRights': delRights,
    };
  }

  Map<String, dynamic> toTableRow({String? companyName}) {
    return {
      'purityGroupCode': purityGroupCode,
      'purityGroupName': purityGroupName ?? '',
      'purityTypeCode': purityTypeCode?.toString() ?? '',
      'companyCode': companyName??companyCode?.toString() ?? '',
      'sortID': sortID?.toString() ?? '',
      'active': active == true ? 'Yes' : 'No',
      '_raw': this,
    };
  }
  static PurityGroupModel fromFormValues(Map<String, dynamic> v) {
    return PurityGroupModel(
      purityGroupCode: int.tryParse(v['purityGroupCode'] ?? ''),
      purityGroupName: v['purityGroupName'],
      purityTypeCode: int.tryParse(v['purityTypeCode'] ?? ''),
      companyCode: int.tryParse(v['companyCode'] ?? ''),
      sortID: int.tryParse(v['sortID'] ?? ''),
      active: parseBool(v['active']),       // ← FIX
      delRights: parseYN(v['delRights']),   // ← FIX
    );
  }
  // static PurityGroupModel fromFormValues(Map<String, dynamic> v) {
  //   return PurityGroupModel(
  //     purityGroupCode: int.tryParse(v['purityGroupCode'] ?? ''),
  //     purityGroupName: v['purityGroupName'],
  //     purityTypeCode: int.tryParse(v['purityTypeCode'] ?? ''),
  //     companyCode: int.tryParse(v['companyCode'] ?? ''),
  //     sortID: int.tryParse(v['sortID'] ?? ''),
  //     active: v['active'] == '1' || v['active'] == 'true' || v['active'] == true,
  //     delRights: v['delRights'] ?? 'Y',
  //   );
  // }

}