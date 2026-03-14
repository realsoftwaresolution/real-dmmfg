import '../utils/helper_functions.dart';

class JangadCharaniModel {
  final int? jangadCharniMstID;
  final int? jangadCharniCode;
  final String? jangadCharniName;
  final String? sflag;
  final String? sdate;
  final int? logID;
  final String? pcID;
  final int? ever;
  final int? companyCode;
  final int? sortID;
  final bool? active;

  JangadCharaniModel({
    this.jangadCharniMstID,
    this.jangadCharniCode,
    this.jangadCharniName,
    this.sflag,
    this.sdate,
    this.logID,
    this.pcID,
    this.ever,
    this.companyCode,
    this.sortID,
    this.active,
  });

  factory JangadCharaniModel.fromJson(Map<String, dynamic> json) {
    return JangadCharaniModel(
      jangadCharniMstID: json['JangadCharniMstID'],
      jangadCharniCode: json['JangadCharniCode'],
      jangadCharniName: json['JangadCharniName'],
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
      'JangadCharniCode': jangadCharniCode,
      'JangadCharniName': jangadCharniName,
      'CompanyCode': companyCode,
      'SortID': sortID,
      'Active': active,
    };
  }

  Map<String, dynamic> toTableRow({String? companyName}) {
    return {
      'jangadCharniCode': jangadCharniCode,
      'jangadCharniName': jangadCharniName ?? '',
      'companyCode': companyName??companyCode?.toString() ?? '',
      'sortID': sortID?.toString() ?? '',
      'active': active == true ? 'Yes' : 'No',
      '_raw': this,
    };
  }

  static JangadCharaniModel fromFormValues(Map<String, dynamic> v) {
    return JangadCharaniModel(
      jangadCharniCode: int.tryParse(v['jangadCharniCode'] ?? ''),
      jangadCharniName: v['jangadCharniName'],
      companyCode: int.tryParse(v['companyCode'] ?? ''),
      sortID: int.tryParse(v['sortID'] ?? ''),
      // active: v['active'] == 'Y',
      active: parseBool(v['active']),

    );
  }
}