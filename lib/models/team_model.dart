// lib/models/team_model.dart

import '../utils/helper_functions.dart';

class TeamModel {
  final int?    teamMstID;
  final int?    teamCode;
  final String? teamName;
  final String? sflag;
  final String? sdate;
  final int?    logID;
  final String? pcID;
  final int?    ever;
  final int?    companyCode;
  final int?    sortID;
  final bool?   active;

  TeamModel({
    this.teamMstID,
    this.teamCode,
    this.teamName,
    this.sflag,
    this.sdate,
    this.logID,
    this.pcID,
    this.ever,
    this.companyCode,
    this.sortID,
    this.active,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) => TeamModel(
    teamMstID:   json['TeamMstID'],
    teamCode:    json['TeamCode'],
    teamName:    json['TeamName'],
    sflag:       json['Sflag'],
    sdate:       json['Sdate']?.toString(),
    logID:       json['LogID'],
    pcID:        json['PcID'],
    ever:        json['Ever'],
    companyCode: json['CompanyCode'],
    sortID:      json['SortID'],
    active:      json['Active'] == true || json['Active'] == 1,
  );

  Map<String, dynamic> toJson() => {
    'TeamName':    teamName,
    'CompanyCode': companyCode,
    'SortID':      sortID,
    'Active':      active,
  };

  Map<String, dynamic> toTableRow({String? companyName}) => {
    'teamCode':    teamCode?.toString()  ?? '',
    'teamName':    teamName              ?? '',
    'companyCode': companyName           ?? companyCode?.toString() ?? '',
    'sortID':      sortID?.toString()    ?? '',
    'active':      active == true ? 'Yes' : 'No',
    '_raw':        this,
  };

  static TeamModel fromFormValues(Map<String, dynamic> v) => TeamModel(
    teamName:    v['teamName'],
    companyCode: int.tryParse(v['companyCode']?.toString() ?? ''),
    sortID:      int.tryParse(v['sortID']?.toString()      ?? ''),
    active:      parseBool(v['active']),
  );
}