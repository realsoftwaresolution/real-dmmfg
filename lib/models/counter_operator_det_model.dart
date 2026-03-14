// lib/models/counter_operator_det_model.dart

class CounterOperatorDetModel {
  final int? counterOperatorDetID;
  final int? crId;
  final int? allowCrId;

  CounterOperatorDetModel({
    this.counterOperatorDetID,
    this.crId,
    this.allowCrId,
  });

  factory CounterOperatorDetModel.fromJson(Map<String, dynamic> json) =>
      CounterOperatorDetModel(
        counterOperatorDetID: json['CounterOperatorDetID'],
        crId:                 json['CrId'],
        allowCrId:            json['AllowCrId'],
      );

  Map<String, dynamic> toJson() => {
    'CrId':      crId,
    'AllowCrId': allowCrId,
  };

  Map<String, dynamic> toTableRow() => {
    'counterOperatorDetID': counterOperatorDetID?.toString() ?? '',
    'crId':                 crId?.toString()                 ?? '',
    'allowCrId':            allowCrId?.toString()            ?? '',
    '_raw':                 this,
  };

  static CounterOperatorDetModel fromFormValues(Map<String, dynamic> v) =>
      CounterOperatorDetModel(
        crId:      int.tryParse(v['crId']?.toString()      ?? ''),
        allowCrId: int.tryParse(v['allowCrId']?.toString() ?? ''),
      );
}