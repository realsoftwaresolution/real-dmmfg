// lib/models/counter_shape_det_model.dart

class CounterShapeDetModel {
  final int? counterShapeDetID;
  final int? shapeCode;
  final int? allowCrId;

  CounterShapeDetModel({
    this.counterShapeDetID,
    this.shapeCode,
    this.allowCrId,
  });

  factory CounterShapeDetModel.fromJson(Map<String, dynamic> json) =>
      CounterShapeDetModel(
        counterShapeDetID: json['CounterShapeDetID'],
        shapeCode:         json['ShapeCode'],
        allowCrId:         json['AllowCrId'],
      );

  Map<String, dynamic> toJson() => {
    'ShapeCode': shapeCode,
    'AllowCrId': allowCrId,
  };

  Map<String, dynamic> toTableRow() => {
    'counterShapeDetID': counterShapeDetID?.toString() ?? '',
    'shapeCode':         shapeCode?.toString()         ?? '',
    'allowCrId':         allowCrId?.toString()         ?? '',
    '_raw':              this,
  };

  static CounterShapeDetModel fromFormValues(Map<String, dynamic> v) =>
      CounterShapeDetModel(
        shapeCode: int.tryParse(v['shapeCode']?.toString() ?? ''),
        allowCrId: int.tryParse(v['allowCrId']?.toString() ?? ''),
      );
}