import '../utils/helper_functions.dart';

class TensionTypeModel {
  final int? tensionTypeMstID;
  final int? tensionTypeCode;
  final String? tensionTypeName;
  final String? sflag;
  final String? sdate;
  final int? logID;
  final String? pcID;
  final int? ever;
  final int? companyCode;
  final int? sortID;
  final bool? active;

  TensionTypeModel({
    this.tensionTypeMstID,
    this.tensionTypeCode,
    this.tensionTypeName,
    this.sflag,
    this.sdate,
    this.logID,
    this.pcID,
    this.ever,
    this.companyCode,
    this.sortID,
    this.active,
  });

  factory TensionTypeModel.fromJson(Map<String, dynamic> json) {
    return TensionTypeModel(
      tensionTypeMstID: json['TensionTypeMstID'],
      tensionTypeCode:  json['TensionTypeCode'],
      tensionTypeName:  json['TensionTypeName'],
      sflag:            json['Sflag'],
      sdate:            json['Sdate']?.toString(),
      logID:            json['LogID'],
      pcID:             json['PcID'],
      ever:             json['Ever'],
      companyCode:      json['CompanyCode'],
      sortID:           json['SortID'],
      active:           json['Active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'TensionTypeCode': tensionTypeCode,
      'TensionTypeName': tensionTypeName,
      'CompanyCode':     companyCode,
      'SortID':          sortID,
      'Active':          active,
    };
  }

  Map<String, dynamic> toTableRow({String? companyName}) {
    return {
      'tensionTypeCode': tensionTypeCode?.toString() ?? '',
      'tensionTypeName': tensionTypeName ?? '',
      'companyCode':     companyName ?? companyCode?.toString() ?? '',
      'sortID':          sortID?.toString() ?? '',
      'active':          active == true ? 'Yes' : 'No',
      '_raw':            this,
    };
  }

  static TensionTypeModel fromFormValues(Map<String, dynamic> v) {
    return TensionTypeModel(
      tensionTypeCode: int.tryParse(v['tensionTypeCode'] ?? ''),
      tensionTypeName: v['tensionTypeName'],
      companyCode:     int.tryParse(v['companyCode'] ?? ''),
      sortID:          int.tryParse(v['sortID'] ?? ''),
      active:          parseBool(v['active']),
    );
  }
}