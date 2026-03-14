// lib/models/counter_report_det_model.dart

class CounterReportDetModel {
  final int? counterReportDetID;
  final int? crID;
  final int? reportCode;
  final int? testCode;

  CounterReportDetModel({
    this.counterReportDetID,
    this.crID,
    this.reportCode,
    this.testCode,
  });

  factory CounterReportDetModel.fromJson(Map<String, dynamic> json) =>
      CounterReportDetModel(
        counterReportDetID: json['CounterReportDetID'],
        crID:               json['CrID'],
        reportCode:         json['ReportCode'],
        testCode:           json['TestCode'],
      );

  Map<String, dynamic> toJson() => {
    'CrID':       crID,
    'ReportCode': reportCode,
    'TestCode':   testCode,
  };

  Map<String, dynamic> toTableRow() => {
    'counterReportDetID': counterReportDetID?.toString() ?? '',
    'crID':               crID?.toString()               ?? '',
    'reportCode':         reportCode?.toString()         ?? '',
    'testCode':           testCode?.toString()           ?? '',
    '_raw':               this,
  };

  static CounterReportDetModel fromFormValues(Map<String, dynamic> v) =>
      CounterReportDetModel(
        crID:       int.tryParse(v['crID']?.toString()       ?? ''),
        reportCode: int.tryParse(v['reportCode']?.toString() ?? ''),
        testCode:   int.tryParse(v['testCode']?.toString()   ?? ''),
      );
}