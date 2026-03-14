// lib/models/report_type_model.dart

import '../utils/helper_functions.dart';

class ReportTypeModel {
  final int?    reportTypeMstID;
  final int?    reportTypeCode;
  final String? reportTypeName;
  final int?    sortID;
  final bool?   active;

  ReportTypeModel({
    this.reportTypeMstID,
    this.reportTypeCode,
    this.reportTypeName,
    this.sortID,
    this.active,
  });

  factory ReportTypeModel.fromJson(Map<String, dynamic> json) =>
      ReportTypeModel(
        reportTypeMstID: json['ReportTypeMstID'],
        reportTypeCode:  json['ReportTypeCode'],
        reportTypeName:  json['ReportTypeName'],
        sortID:          json['SortID'],
        active:          json['Active'] == true || json['Active'] == 1,
      );

  Map<String, dynamic> toJson() => {
    'ReportTypeName': reportTypeName,
    'SortID':         sortID,
    'Active':         active,
  };

  Map<String, dynamic> toTableRow() => {
    'reportTypeCode': reportTypeCode?.toString() ?? '',
    'reportTypeName': reportTypeName             ?? '',
    'sortID':         sortID?.toString()         ?? '',
    'active':         active == true ? 'Yes' : 'No',
    '_raw':           this,
  };

  static ReportTypeModel fromFormValues(Map<String, dynamic> v) =>
      ReportTypeModel(
        reportTypeName: v['reportTypeName'],
        sortID:         int.tryParse(v['sortID']?.toString() ?? ''),
        active:         parseBool(v['active']),
      );
}