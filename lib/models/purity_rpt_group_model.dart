import 'package:diam_mfg/utils/helper_functions.dart';

class PurityRptGroupModel {
  final int? purityRptGroupMstID;
  final int? purityRptGroupCode;
  final String? purityRptGroupName;
  final String? sflag;
  final String? sdate;
  final int? logID;
  final String? pcID;
  final int? ever;
  final int? companyCode;
  final int? sortID;
  final bool? active;
  final double? rate;
  final double? per;

  PurityRptGroupModel({
    this.purityRptGroupMstID,
    this.purityRptGroupCode,
    this.purityRptGroupName,
    this.sflag,
    this.sdate,
    this.logID,
    this.pcID,
    this.ever,
    this.companyCode,
    this.sortID,
    this.active,
    this.rate,
    this.per,
  });

  factory PurityRptGroupModel.fromJson(Map<String, dynamic> json) {
    return PurityRptGroupModel(
      purityRptGroupMstID: json['PurityRptGroupMstID'],
      purityRptGroupCode: json['PurityRptGroupCode'],
      purityRptGroupName: json['PurityRptGroupName'],
      sflag: json['Sflag'],
      sdate: json['Sdate']?.toString(),
      logID: json['LogID'],
      pcID: json['PcID'],
      ever: json['Ever'],
      companyCode: json['CompanyCode'],
      sortID: json['SortID'],
      active: json['Active'],
      rate: json['Rate'] != null
          ? double.tryParse(json['Rate'].toString())
          : null,
      per: json['Per'] != null
          ? double.tryParse(json['Per'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'PurityRptGroupCode': purityRptGroupCode,
      'PurityRptGroupName': purityRptGroupName,
      'CompanyCode': companyCode,
      'SortID': sortID,
      'Active': active,
      'Rate': rate,
      'Per': per,
    };
  }

  Map<String, dynamic> toTableRow({String? companyName}) {
    return {
      'purityRptGroupCode': purityRptGroupCode,
      'purityRptGroupName': purityRptGroupName ?? '',
      'rate': rate?.toStringAsFixed(2) ?? '',
      'per': per?.toStringAsFixed(2) ?? '',
      'companyCode': companyName??companyCode?.toString() ?? '',
      'sortID': sortID?.toString() ?? '',
      'active': active == true ? 'Yes' : 'No',
      '_raw': this,
    };
  }

  static PurityRptGroupModel fromFormValues(Map<String, dynamic> v) {
    return PurityRptGroupModel(
      purityRptGroupCode: int.tryParse(v['purityRptGroupCode'] ?? ''),
      purityRptGroupName: v['purityRptGroupName'],
      companyCode: int.tryParse(v['companyCode'] ?? ''),
      sortID: int.tryParse(v['sortID'] ?? ''),
      active: parseBool(v['active']),
      rate: double.tryParse(v['rate'] ?? ''),
      per: double.tryParse(v['per'] ?? ''),
    );
  }
}