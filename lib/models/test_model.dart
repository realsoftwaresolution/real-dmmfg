// lib/models/test_model.dart

import '../utils/helper_functions.dart';

class TestModel {
  final int?    testMstID;
  final int?    testCode;
  final String? testName;
  final int?    formNo;
  final int?    sortID;
  final bool?   active;

  TestModel({
    this.testMstID,
    this.testCode,
    this.testName,
    this.formNo,
    this.sortID,
    this.active,
  });

  factory TestModel.fromJson(Map<String, dynamic> json) => TestModel(
    testMstID: json['TestMstID'],
    testCode:  json['TestCode'],
    testName:  json['TestName'],
    formNo:    json['FormNo'],
    sortID:    json['SortID'],
    active:    json['Active'] == true || json['Active'] == 1,
  );

  Map<String, dynamic> toJson() => {
    'TestName': testName,
    'FormNo':   formNo,
    'SortID':   sortID,
    'Active':   active,
  };

  Map<String, dynamic> toTableRow() => {
    'testCode': testCode?.toString() ?? '',
    'testName': testName             ?? '',
    'formNo':   formNo?.toString()   ?? '',
    'sortID':   sortID?.toString()   ?? '',
    'active':   active == true ? 'Yes' : 'No',
    '_raw':     this,
  };

  static TestModel fromFormValues(Map<String, dynamic> v) => TestModel(
    testName: v['testName'],
    formNo:   int.tryParse(v['formNo']?.toString() ?? ''),
    sortID:   int.tryParse(v['sortID']?.toString() ?? ''),
    active:   parseBool(v['active']),
  );
}