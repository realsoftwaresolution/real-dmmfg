// lib/models/counter_dept_det_model.dart

class CounterDeptDetModel {
  final int? counterDeptDetID;
  final int? crId;
  final int? deptCode;

  CounterDeptDetModel({
    this.counterDeptDetID,
    this.crId,
    this.deptCode,
  });

  factory CounterDeptDetModel.fromJson(Map<String, dynamic> json) =>
      CounterDeptDetModel(
        counterDeptDetID: json['CounterDeptDetID'],
        crId:             json['CrId'],
        deptCode:         json['DeptCode'],
      );

  Map<String, dynamic> toJson() => {
    'CrId':     crId,
    'DeptCode': deptCode,
  };

  Map<String, dynamic> toTableRow() => {
    'counterDeptDetID': counterDeptDetID?.toString() ?? '',
    'crId':             crId?.toString()             ?? '',
    'deptCode':         deptCode?.toString()         ?? '',
    '_raw':             this,
  };

  static CounterDeptDetModel fromFormValues(Map<String, dynamic> v) =>
      CounterDeptDetModel(
        crId:     int.tryParse(v['crId']?.toString()     ?? ''),
        deptCode: int.tryParse(v['deptCode']?.toString() ?? ''),
      );
}