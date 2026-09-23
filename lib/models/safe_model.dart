import '../utils/helper_functions.dart';

class SafeModel {
  final int? safeMstID;
  final int? safeCode;
  final String? safeName;
  final String? sflag;
  final String? sdate;
  final int? logID;
  final String? pcID;
  final int? ever;
  final int? companyCode;
  final int? sortID;
  final bool? active;

  SafeModel({
    this.safeMstID,
    this.safeCode,
    this.safeName,
    this.sflag,
    this.sdate,
    this.logID,
    this.pcID,
    this.ever,
    this.companyCode,
    this.sortID,
    this.active,
  });

  factory SafeModel.fromJson(Map<String, dynamic> json) {
    return SafeModel(
      safeMstID: json['SafeMstID'] ?? json['safeMstID'] ?? json['SafeMstId'],
      safeCode: json['SafeCode'] ?? json['safeCode'] ?? json['SafeId'] ?? json['safeId'],
      safeName: json['SafeName'] ?? json['safeName'],
      sflag: json['Sflag'] ?? json['sflag'],
      sdate: (json['Sdate'] ?? json['sdate'])?.toString(),
      logID: json['LogID'] ?? json['logID'],
      pcID: (json['PcID'] ?? json['pcID'])?.toString(),
      ever: json['Ever'] ?? json['ever'],
      companyCode: json['CompanyCode'] ?? json['companyCode'],
      sortID: json['SortID'] ?? json['sortID'],
      active: parseBool(json['Active'] ?? json['active']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (safeCode != null) 'SafeCode': safeCode,
      'SafeName': safeName,
      'CompanyCode': companyCode,
      'SortID': sortID,
      'Active': active,
    };
  }

  Map<String, dynamic> toTableRow({String? companyName}) {
    return {
      'safeCode': safeCode,
      'safeName': safeName ?? '',
      'companyCode': companyName ?? companyCode?.toString() ?? '',
      'sortID': sortID?.toString() ?? '',
      'active': active == true ? 'Yes' : 'No',
      '_raw': this,
    };
  }

  static SafeModel fromFormValues(Map<String, dynamic> v) {
    return SafeModel(
      safeCode: int.tryParse(v['safeCode']?.toString() ?? ''),
      safeName: v['safeName']?.toString(),
      companyCode: int.tryParse(v['companyCode']?.toString() ?? ''),
      sortID: int.tryParse(v['sortID']?.toString() ?? ''),
      active: parseBool(v['active']),
    );
  }
}
