import 'package:diam_mfg/utils/helper_functions.dart';

class TensionsModel {
  final int? tensionsMstID;
  final int? tensionsCode;
  final String? tensionsName;
  final String? sflag;
  final String? sdate;
  final int? logID;
  final String? pcID;
  final int? ever;
  final int? companyCode;
  final int? sortID;
  final bool? active;
  final String? tensionType;

  TensionsModel({
    this.tensionsMstID,
    this.tensionsCode,
    this.tensionsName,
    this.sflag,
    this.sdate,
    this.logID,
    this.pcID,
    this.ever,
    this.companyCode,
    this.sortID,
    this.active,
    this.tensionType,
  });

  factory TensionsModel.fromJson(Map<String, dynamic> json) {
    return TensionsModel(
      tensionsMstID: json['TensionsMstID'],
      tensionsCode: json['TensionsCode'],
      tensionsName: json['TensionsName'],
      sflag: json['Sflag'],
      sdate: json['Sdate']?.toString(),
      logID: json['LogID'],
      pcID: json['PcID'],
      ever: json['Ever'],
      companyCode: json['CompanyCode'],
      sortID: json['SortID'],
      active: json['Active'],
      tensionType: json['TensionType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'TensionsCode': tensionsCode,
      'TensionsName': tensionsName,
      'CompanyCode': companyCode,
      'SortID': sortID,
      'Active': active,
      'TensionType': tensionType,
    };
  }

  Map<String, dynamic> toTableRow({String? companyName}) {
    return {
      'tensionsCode': tensionsCode,
      'tensionsName': tensionsName ?? '',
      'tensionType': tensionType ?? '',
      'companyCode':companyName?? companyCode?.toString() ?? '',
      'sortID': sortID?.toString() ?? '',
      'active': active == true ? 'Yes' : 'No',
      '_raw': this,
    };
  }

  static TensionsModel fromFormValues(Map<String, dynamic> v) {
    return TensionsModel(
      tensionsCode: int.tryParse(v['tensionsCode'] ?? ''),
      tensionsName: v['tensionsName'],
      companyCode: int.tryParse(v['companyCode'] ?? ''),
      sortID: int.tryParse(v['sortID'] ?? ''),
      active: parseBool(v['active']),
      tensionType: v['tensionType'],
    );
  }
}