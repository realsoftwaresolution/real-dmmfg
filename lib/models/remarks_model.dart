import 'package:diam_mfg/utils/helper_functions.dart';

class RemarksModel {
  final int? remarksMstID;
  final int? remarksCode;
  final String? remarksName;
  final int? deptCode;
  final int? deptProcessCode;
  final String? sflag;
  final String? sdate;
  final int? logID;
  final String? pcID;
  final int? ever;
  final int? companyCode;
  final int? sortID;
  final bool? active;
  final int? tops;

  RemarksModel({
    this.remarksMstID,
    this.remarksCode,
    this.remarksName,
    this.deptCode,
    this.deptProcessCode,
    this.sflag,
    this.sdate,
    this.logID,
    this.pcID,
    this.ever,
    this.companyCode,
    this.sortID,
    this.active,
    this.tops,
  });

  factory RemarksModel.fromJson(Map<String, dynamic> json) {
    return RemarksModel(
      remarksMstID: json['RemarksMstID'],
      remarksCode: json['RemarksCode'],
      remarksName: json['RemarksName'],
      deptCode: json['DeptCode'],
      deptProcessCode: json['DeptProcessCode'],
      sflag: json['Sflag'],
      sdate: json['Sdate']?.toString(),
      logID: json['LogID'],
      pcID: json['PcID'],
      ever: json['Ever'],
      companyCode: json['CompanyCode'],
      sortID: json['SortID'],
      active: json['Active'],
      tops: json['TOPS'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'RemarksCode': remarksCode,
      'RemarksName': remarksName,
      'DeptCode': deptCode,
      'DeptProcessCode': deptProcessCode,
      'CompanyCode': companyCode,
      'SortID': sortID,
      'Active': active,
      'TOPS': tops,
    };
  }

  Map<String, dynamic> toTableRow({String? companyName}) {
    return {
      'remarksCode': remarksCode,
      'remarksName': remarksName ?? '',
      'deptCode': deptCode?.toString() ?? '',
      'deptProcessCode': deptProcessCode?.toString() ?? '',
      'tops': tops?.toString() ?? '',
      'companyCode':companyName?? companyCode?.toString() ?? '',
      'sortID': sortID?.toString() ?? '',
      'active': active == true ? 'Yes' : 'No',
      '_raw': this,
    };
  }

  static RemarksModel fromFormValues(Map<String, dynamic> v) {
    return RemarksModel(
      remarksCode: int.tryParse(v['remarksCode'] ?? ''),
      remarksName: v['remarksName'],
      deptCode: int.tryParse(v['deptCode'] ?? ''),
      deptProcessCode: int.tryParse(v['deptProcessCode'] ?? ''),
      companyCode: int.tryParse(v['companyCode'] ?? ''),
      sortID: int.tryParse(v['sortID'] ?? ''),
      active: parseBool(v['active']),
      tops: int.tryParse(v['tops'] ?? ''),
    );
  }
}