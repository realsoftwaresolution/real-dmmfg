import '../utils/helper_functions.dart';

class PurityModel {
  final int? purityMstID;
  final int? purityCode;
  final String? purityName;
  final int? purityGroupCode;
  final int? purityRptGroupCode;
  final String? sflag;
  final String? sdate;
  final int? logID;
  final String? pcID;
  final int? ever;
  final int? companyCode;
  final int? sortID;
  final bool? active;
  final double? labourRate;
  final bool? pg;
  final String? purityGraddingGroup;
  final String? reportGroup;

  PurityModel({
    this.purityMstID,
    this.purityCode,
    this.purityName,
    this.purityGroupCode,
    this.purityRptGroupCode,
    this.sflag,
    this.sdate,
    this.logID,
    this.pcID,
    this.ever,
    this.companyCode,
    this.sortID,
    this.active,
    this.labourRate,
    this.pg,
    this.purityGraddingGroup,
    this.reportGroup,
  });

  factory PurityModel.fromJson(Map<String, dynamic> json) {
    return PurityModel(
      purityMstID: json['PurityMstID'],
      purityCode: json['PurityCode'],
      purityName: json['PurityName'],
      purityGroupCode: json['PurityGroupCode'],
      purityRptGroupCode: json['PurityRptGroupCode'],
      sflag: json['Sflag'],
      sdate: json['Sdate']?.toString(),
      logID: json['LogID'],
      pcID: json['PcID'],
      ever: json['Ever'],
      companyCode: json['CompanyCode'],
      sortID: json['SortID'],
      active: json['Active'],
      labourRate: json['LabourRate'] != null
          ? double.tryParse(json['LabourRate'].toString())
          : null,
      pg: json['PG'],
      purityGraddingGroup: json['PurityGraddingGroup'],
      reportGroup: json['ReportGroup'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'PurityCode': purityCode,
      'PurityName': purityName,
      'PurityGroupCode': purityGroupCode,
      'PurityRptGroupCode': purityRptGroupCode,
      'CompanyCode': companyCode,
      'SortID': sortID,
      'Active': active,
      'LabourRate': labourRate,
      'PG': pg,
      'PurityGraddingGroup': purityGraddingGroup,
      'ReportGroup': reportGroup,
    };
  }

  Map<String, dynamic> toTableRow({String? companyName}) {
    return {
      'purityCode': purityCode,
      'purityName': purityName ?? '',
      'purityGroupCode': purityGroupCode?.toString() ?? '',
      'purityRptGroupCode': purityRptGroupCode?.toString() ?? '',
      'labourRate': labourRate?.toStringAsFixed(2) ?? '',
      'companyCode': companyName??companyCode?.toString() ?? '',
      'sortID': sortID?.toString() ?? '',
      'active': active == true ? 'Yes' : 'No',
      '_raw': this,
    };
  }

  static PurityModel fromFormValues(Map<String, dynamic> v) {
    return PurityModel(
      purityCode: int.tryParse(v['purityCode'] ?? ''),
      purityName: v['purityName'],
      purityGroupCode: int.tryParse(v['purityGroupCode'] ?? ''),
      purityRptGroupCode: int.tryParse(v['purityRptGroupCode'] ?? ''),
      companyCode: int.tryParse(v['companyCode'] ?? ''),
      sortID: int.tryParse(v['sortID'] ?? ''),
      active: parseBool(v['active']),
      labourRate: double.tryParse(v['labourRate'] ?? ''),
      pg: parseBool(v['pg']),
      // pg: v['pg'] == 'Y',
      purityGraddingGroup: v['purityGraddingGroup'],
      reportGroup: v['reportGroup'],
    );
  }
}