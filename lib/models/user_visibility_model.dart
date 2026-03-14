// lib/models/user_visibility_model.dart

import '../utils/helper_functions.dart';

class UserVisibilityModel {
  final int?    userVisibilityMstID;
  final int?    userVisibilityCode;
  final String? userVisibilityName;
  final String? entryType;
  final int?    sortID;
  final bool?   active;
  final int?    entrySortID;
  final bool?   entryConfirm;

  UserVisibilityModel({
    this.userVisibilityMstID,
    this.userVisibilityCode,
    this.userVisibilityName,
    this.entryType,
    this.sortID,
    this.active,
    this.entrySortID,
    this.entryConfirm,
  });

  factory UserVisibilityModel.fromJson(Map<String, dynamic> json) =>
      UserVisibilityModel(
        userVisibilityMstID:  json['UserVisibilityMstID'],
        userVisibilityCode:   json['UserVisibilityCode'],
        userVisibilityName:   json['UserVisibilityName'],
        entryType:            json['EntryType'],
        sortID:               json['SortID'],
        active:               json['Active'] == true || json['Active'] == 1,
        entrySortID:          json['EntrySortID'],
        entryConfirm:         json['EntryConfirm'] == true || json['EntryConfirm'] == 1,
      );

  Map<String, dynamic> toJson() => {
    'UserVisibilityName': userVisibilityName,
    'EntryType':          entryType,
    'SortID':             sortID,
    'Active':             active,
    'EntrySortID':        entrySortID,
    'EntryConfirm':       entryConfirm,
  };

  Map<String, dynamic> toTableRow() => {
    'userVisibilityCode': userVisibilityCode?.toString() ?? '',
    'userVisibilityName': userVisibilityName             ?? '',
    'entryType':          entryType                      ?? '',
    'sortID':             sortID?.toString()             ?? '',
    'active':             active == true ? 'Yes' : 'No',
    '_raw':               this,
  };

  static UserVisibilityModel fromFormValues(Map<String, dynamic> v) =>
      UserVisibilityModel(
        userVisibilityName: v['userVisibilityName'],
        entryType:          v['entryType'],
        sortID:             int.tryParse(v['sortID']?.toString()      ?? ''),
        entrySortID:        int.tryParse(v['entrySortID']?.toString() ?? ''),
        active:             parseBool(v['active']),
        entryConfirm:       parseBool(v['entryConfirm']),
      );
}