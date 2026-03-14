// lib/models/counter_manager_det_model.dart

class CounterManagerDetModel {
  final int? counterManagerDetID;
  final int? crId;
  final int? allowCrId;
  final int? deptProcessCode;
  final int? deptCode;

  CounterManagerDetModel({
    this.counterManagerDetID,
    this.crId,
    this.allowCrId,
    this.deptProcessCode,
    this.deptCode,
  });

  factory CounterManagerDetModel.fromJson(Map<String, dynamic> json) =>
      CounterManagerDetModel(
        counterManagerDetID: json['CounterManagerDetID'],
        crId:                json['CrId'],
        allowCrId:           json['AllowCrId'],
        deptProcessCode:     json['DeptProcessCode'],
        deptCode:            json['DeptCode'],
      );

  Map<String, dynamic> toJson() => {
    'CrId':            crId,
    'AllowCrId':       allowCrId,
    'DeptProcessCode': deptProcessCode,
    'DeptCode':        deptCode,
  };

  Map<String, dynamic> toTableRow() => {
    'counterManagerDetID': counterManagerDetID?.toString() ?? '',
    'crId':                crId?.toString()                ?? '',
    'allowCrId':           allowCrId?.toString()           ?? '',
    'deptProcessCode':     deptProcessCode?.toString()     ?? '',
    'deptCode':            deptCode?.toString()            ?? '',
    '_raw':                this,
  };

  static CounterManagerDetModel fromFormValues(Map<String, dynamic> v) =>
      CounterManagerDetModel(
        crId:            int.tryParse(v['crId']?.toString()            ?? ''),
        allowCrId:       int.tryParse(v['allowCrId']?.toString()       ?? ''),
        deptProcessCode: int.tryParse(v['deptProcessCode']?.toString() ?? ''),
        deptCode:        int.tryParse(v['deptCode']?.toString()        ?? ''),
      );
}