import '../utils/helper_functions.dart';

class PurityTypeModel {
  final int? purityTypeMstID;
  final int? purityTypeCode;
  final String? purityTypeName;
  final String? sflag;
  final String? sdate;
  final int? logID;
  final String? pcID;
  final int? ever;
  final int? companyCode;
  final int? sortID;
  final bool? active;

  PurityTypeModel({
    this.purityTypeMstID,
    this.purityTypeCode,
    this.purityTypeName,
    this.sflag,
    this.sdate,
    this.logID,
    this.pcID,
    this.ever,
    this.companyCode,
    this.sortID,
    this.active,
  });

  factory PurityTypeModel.fromJson(Map<String, dynamic> json) {
    return PurityTypeModel(
      purityTypeMstID: json['PurityTypeMstID'],
      purityTypeCode:  json['PurityTypeCode'],
      purityTypeName:  json['PurityTypeName'],
      sflag:           json['Sflag'],
      sdate:           json['Sdate']?.toString(),
      logID:           json['LogID'],
      pcID:            json['PcID'],
      ever:            json['Ever'],
      companyCode:     json['CompanyCode'],
      sortID:          json['SortID'],
      active:          json['Active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'PurityTypeCode': purityTypeCode,
      'PurityTypeName': purityTypeName,
      'CompanyCode':    companyCode,
      'SortID':         sortID,
      'Active':         active,
    };
  }

  Map<String, dynamic> toTableRow({String? companyName}) {
    return {
      'purityTypeCode': purityTypeCode?.toString() ?? '',
      'purityTypeName': purityTypeName ?? '',
      'companyCode':    companyName ?? companyCode?.toString() ?? '',
      'sortID':         sortID?.toString() ?? '',
      'active':         active == true ? 'Yes' : 'No',
      '_raw':           this,
    };
  }

  static PurityTypeModel fromFormValues(Map<String, dynamic> v) {
    return PurityTypeModel(
      purityTypeCode: int.tryParse(v['purityTypeCode'] ?? ''),
      purityTypeName: v['purityTypeName'],
      companyCode:    int.tryParse(v['companyCode'] ?? ''),
      sortID:         int.tryParse(v['sortID'] ?? ''),
      active:         parseBool(v['active']),
    );
  }
}