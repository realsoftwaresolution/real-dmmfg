import '../utils/helper_functions.dart';

class PcModel {
  final int? pcMstID;
  final int? pcCode;
  final String? pcName;
  final String? pcIPAddress;
  final String? sflag;
  final String? sdate;
  final int? logID;
  final String? pcID;
  final int? ever;
  final int? companyCode;
  final int? sortID;
  final bool? active;

  PcModel({
    this.pcMstID,
    this.pcCode,
    this.pcName,
    this.pcIPAddress,
    this.sflag,
    this.sdate,
    this.logID,
    this.pcID,
    this.ever,
    this.companyCode,
    this.sortID,
    this.active,
  });

  factory PcModel.fromJson(Map<String, dynamic> json) {
    return PcModel(
      pcMstID: json['PcMstID'],
      pcCode: json['PcCode'],
      pcName: json['PcName'],
      pcIPAddress: json['PcIPAddress'],
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
      'PcCode': pcCode,
      'PcName': pcName,
      'PcIPAddress': pcIPAddress,
      'CompanyCode': companyCode,
      'SortID': sortID,
      'Active': active,
    };
  }

  Map<String, dynamic> toTableRow({String? companyName}) {
    return {
      'pcCode': pcCode,
      'pcName': pcName ?? '',
      'pcIPAddress': pcIPAddress ?? '',
      'companyCode':companyName?? companyCode?.toString() ?? '',
      'sortID': sortID?.toString() ?? '',
      'active': active == true ? 'Yes' : 'No',
      '_raw': this,
    };
  }

  static PcModel fromFormValues(Map<String, dynamic> v) {
    return PcModel(
      pcCode: int.tryParse(v['pcCode'] ?? ''),
      pcName: v['pcName'],
      pcIPAddress: v['pcIPAddress'],
      companyCode: int.tryParse(v['companyCode'] ?? ''),
      sortID: int.tryParse(v['sortID'] ?? ''),
      active: parseBool(v['active']),

      // active: v['active'] == 'Y',
    );
  }
}