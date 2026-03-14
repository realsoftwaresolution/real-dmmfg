import '../utils/helper_functions.dart';

class CharniGroupModel {
  final int? charniGroupMstID;
  final int? charniGroupCode;
  final String? charniGroupName;
  final String? sflag;
  final String? sdate;
  final int? logID;
  final String? pcID;
  final int? ever;
  final int? companyCode;
  final int? sortID;
  final bool? active;

  CharniGroupModel({
    this.charniGroupMstID,
    this.charniGroupCode,
    this.charniGroupName,
    this.sflag,
    this.sdate,
    this.logID,
    this.pcID,
    this.ever,
    this.companyCode,
    this.sortID,
    this.active,
  });

  factory CharniGroupModel.fromJson(Map<String, dynamic> json) {
    return CharniGroupModel(
      charniGroupMstID: json['CharniGroupMstID'],
      charniGroupCode:  json['CharniGroupCode'],
      charniGroupName:  json['CharniGroupName'],
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
      'CharniGroupCode': charniGroupCode,
      'CharniGroupName': charniGroupName,
      'CompanyCode':     companyCode,
      'SortID':          sortID,
      'Active':          active,
    };
  }

  Map<String, dynamic> toTableRow({String? companyName}) {
    return {
      'charniGroupCode': charniGroupCode?.toString() ?? '',
      'charniGroupName': charniGroupName ?? '',
      'companyCode':     companyName ?? companyCode?.toString() ?? '',
      'sortID':          sortID?.toString() ?? '',
      'active':          active == true ? 'Yes' : 'No',
      '_raw':            this,
    };
  }

  static CharniGroupModel fromFormValues(Map<String, dynamic> v) {
    return CharniGroupModel(
      charniGroupCode: int.tryParse(v['charniGroupCode'] ?? ''),
      charniGroupName: v['charniGroupName'],
      companyCode:     int.tryParse(v['companyCode'] ?? ''),
      sortID:          int.tryParse(v['sortID'] ?? ''),
      active:          parseBool(v['active']),
    );
  }
}