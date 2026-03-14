// lib/models/report_mst_model.dart

import '../utils/helper_functions.dart';

class ReportMstModel {
  final int?    reportMstID;
  final int?    testCode;
  final int?    reportTypeCode;
  final int?    reportCode;
  final String? reportName;
  final String? reportHeading;
  final String? reportPath;
  final int?    sortID;
  final bool?   active;

  ReportMstModel({
    this.reportMstID,
    this.testCode,
    this.reportTypeCode,
    this.reportCode,
    this.reportName,
    this.reportHeading,
    this.reportPath,
    this.sortID,
    this.active,
  });

  factory ReportMstModel.fromJson(Map<String, dynamic> json) => ReportMstModel(
    reportMstID:    json['ReportMstID'],
    testCode:       json['TestCode'],
    reportTypeCode: json['ReportTypeCode'],
    reportCode:     json['ReportCode'],
    reportName:     json['ReportName'],
    reportHeading:  json['ReportHeading'],
    reportPath:     json['ReportPath'],
    sortID:         json['SortID'],
    active:         json['Active'] == true || json['Active'] == 1,
  );

  Map<String, dynamic> toJson() => {
    'TestCode':       testCode,
    'ReportTypeCode': reportTypeCode,
    'ReportName':     reportName,
    'ReportHeading':  reportHeading,
    'ReportPath':     reportPath,
    'SortID':         sortID,
    'Active':         active,
  };

  Map<String, dynamic> toTableRow() => {
    'reportMstID':    reportMstID?.toString()    ?? '',
    'reportCode':     reportCode?.toString()     ?? '',
    'reportName':     reportName                 ?? '',
    'reportTypeCode': reportTypeCode?.toString() ?? '',
    'testCode':       testCode?.toString()       ?? '',
    'sortID':         sortID?.toString()         ?? '',
    'active':         active == true ? 'Yes' : 'No',
    '_raw':           this,
  };

  static ReportMstModel fromFormValues(Map<String, dynamic> v) => ReportMstModel(
    testCode:       int.tryParse(v['testCode']?.toString()       ?? ''),
    reportTypeCode: int.tryParse(v['reportTypeCode']?.toString() ?? ''),
    reportName:     v['reportName'],
    reportHeading:  v['reportHeading'],
    reportPath:     v['reportPath'],
    sortID:         int.tryParse(v['sortID']?.toString()         ?? ''),
    active:         parseBool(v['active']),
  );
}