// lib/models/counter_process_model.dart

class CounterProcessModel {
  final int? counterProcessDetID;
  final int? crId;
  final int? deptCode;
  final int? deptProcessCode;

  CounterProcessModel({
    this.counterProcessDetID,
    this.crId,
    this.deptCode,
    this.deptProcessCode,
  });

  factory CounterProcessModel.fromJson(Map<String, dynamic> json) =>
      CounterProcessModel(
        counterProcessDetID: json['CounterProcessDetID'],
        crId:                json['CrId'],
        deptCode:            json['DeptCode'],
        deptProcessCode:     json['DeptProcessCode'],
      );

  Map<String, dynamic> toJson() => {
    'CrId':            crId,
    'DeptCode':        deptCode,
    'DeptProcessCode': deptProcessCode,
  };

  Map<String, dynamic> toTableRow() => {
    'counterProcessDetID': counterProcessDetID?.toString() ?? '',
    'crId':                crId?.toString()                ?? '',
    'deptCode':            deptCode?.toString()            ?? '',
    'deptProcessCode':     deptProcessCode?.toString()     ?? '',
    '_raw':                this,
  };

  static CounterProcessModel fromFormValues(Map<String, dynamic> v) =>
      CounterProcessModel(
        crId:            int.tryParse(v['crId']?.toString()            ?? ''),
        deptCode:        int.tryParse(v['deptCode']?.toString()        ?? ''),
        deptProcessCode: int.tryParse(v['deptProcessCode']?.toString() ?? ''),
      );
}