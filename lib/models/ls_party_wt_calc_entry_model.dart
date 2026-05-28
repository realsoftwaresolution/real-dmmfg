import '../utils/helper_functions.dart';

class MstLsPartyWtCalcEntryModel {
  final int? purityGroupMstID;
  final int? purityGroupCode;
  final String? purityGroupName;
  final String? PurityTypeName;
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

  MstLsPartyWtCalcEntryModel({
    this.purityGroupMstID,
    this.purityGroupCode,
    this.purityGroupName,
    this.PurityTypeName,
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

  factory MstLsPartyWtCalcEntryModel.fromJson(Map<String, dynamic> json) {
    return MstLsPartyWtCalcEntryModel(
      purityGroupMstID: json['PurityGroupMstID'],
      purityGroupCode: json['PurityGroupCode'],
      purityGroupName: json['PurityGroupName'],
      purityTypeCode: json['PurityTypeCode'],
      PurityTypeName: json['PurityTypeName'],
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
      'PurityTypeName': PurityTypeName,
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
      'PurityTypeName': PurityTypeName?.toString() ?? '',
      'companyCode': companyName??companyCode?.toString() ?? '',
      'sortID': sortID?.toString() ?? '',
      'active': active == true ? 'Yes' : 'No',
      '_raw': this,
    };
  }
  static MstLsPartyWtCalcEntryModel fromFormValues(Map<String, dynamic> v) {
    return MstLsPartyWtCalcEntryModel(
      purityGroupCode: int.tryParse(v['purityGroupCode'] ?? ''),
      purityGroupName: v['purityGroupName'],
      PurityTypeName: v['PurityTypeName'],
      purityTypeCode: int.tryParse(v['purityTypeCode'] ?? ''),
      companyCode: int.tryParse(v['companyCode'] ?? ''),
      sortID: int.tryParse(v['sortID'] ?? ''),
      active: parseBool(v['active']),       // ← FIX
      delRights: parseYN(v['delRights']),   // ← FIX
    );
  }
}