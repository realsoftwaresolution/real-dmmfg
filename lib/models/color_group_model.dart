import '../utils/helper_functions.dart';

class ColorGroupModel {
  final int? colorGroupMstID;
  final int? colorGroupCode;
  final String? colorGroupName;
  final String? sflag;
  final String? sdate;
  final int? logID;
  final String? pcID;
  final int? ever;
  final int? companyCode;
  final int? sortID;
  final bool? active;

  ColorGroupModel({
    this.colorGroupMstID,
    this.colorGroupCode,
    this.colorGroupName,
    this.sflag,
    this.sdate,
    this.logID,
    this.pcID,
    this.ever,
    this.companyCode,
    this.sortID,
    this.active,
  });

  factory ColorGroupModel.fromJson(Map<String, dynamic> json) {
    return ColorGroupModel(
      colorGroupMstID: json['ColorGroupMstID'],
      colorGroupCode:  json['ColorGroupCode'],
      colorGroupName:  json['ColorGroupName'],
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
      'ColorGroupCode': colorGroupCode,
      'ColorGroupName': colorGroupName,
      'CompanyCode':    companyCode,
      'SortID':         sortID,
      'Active':         active,
    };
  }

  Map<String, dynamic> toTableRow({String? companyName}) {
    return {
      'colorGroupCode': colorGroupCode?.toString() ?? '',
      'colorGroupName': colorGroupName ?? '',
      'companyCode':    companyName ?? companyCode?.toString() ?? '',
      'sortID':         sortID?.toString() ?? '',
      'active':         active == true ? 'Yes' : 'No',
      '_raw':           this,
    };
  }

  static ColorGroupModel fromFormValues(Map<String, dynamic> v) {
    return ColorGroupModel(
      colorGroupCode: int.tryParse(v['colorGroupCode'] ?? ''),
      colorGroupName: v['colorGroupName'],
      companyCode:    int.tryParse(v['companyCode'] ?? ''),
      sortID:         int.tryParse(v['sortID'] ?? ''),
      active:         parseBool(v['active']),
    );
  }
}