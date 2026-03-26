// lib/models/counter_display_det_model.dart

class CounterDisplayDetModel {
  final int?    counterDisplayDetID;
  final int?    crId;
  final int?    userVisibilityCode;
  final String? counterType;

  CounterDisplayDetModel({
    this.counterDisplayDetID,
    this.crId,
    this.userVisibilityCode,
    this.counterType,
  });

  factory CounterDisplayDetModel.fromJson(Map<String, dynamic> json) =>
      CounterDisplayDetModel(
        counterDisplayDetID: json['CounterDisplayDetID'],
        crId: json['CrId'] ?? json['crId'] ?? json['CRID'],
        userVisibilityCode:  json['UserVisibilityCode'],
        counterType:         json['CounterType'],
      );

  Map<String, dynamic> toJson() => {
    'CrId':               crId,
    'UserVisibilityCode': userVisibilityCode,
    'CounterType':        counterType,
  };

  Map<String, dynamic> toTableRow() => {
    'counterDisplayDetID': counterDisplayDetID?.toString() ?? '',
    'crId':                crId?.toString()                ?? '',
    'userVisibilityCode':  userVisibilityCode?.toString()  ?? '',
    'counterType':         counterType                     ?? '',
    '_raw':                this,
  };

  static CounterDisplayDetModel fromFormValues(Map<String, dynamic> v) =>
      CounterDisplayDetModel(
        crId:               int.tryParse(v['crId']?.toString()               ?? ''),
        userVisibilityCode: int.tryParse(v['userVisibilityCode']?.toString() ?? ''),
        counterType:        v['counterType'],
      );
}