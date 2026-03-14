// lib/models/counter_stock_type_det_model.dart

class CounterStockTypeDetModel {
  final int? counterStockTypeDetID;
  final int? stockTypeCode;
  final int? allowCrId;

  CounterStockTypeDetModel({
    this.counterStockTypeDetID,
    this.stockTypeCode,
    this.allowCrId,
  });

  factory CounterStockTypeDetModel.fromJson(Map<String, dynamic> json) =>
      CounterStockTypeDetModel(
        counterStockTypeDetID: json['CounterStockTypeDetID'],
        stockTypeCode:         json['StockTypeCode'],
        allowCrId:             json['AllowCrId'],
      );

  Map<String, dynamic> toJson() => {
    'StockTypeCode': stockTypeCode,
    'AllowCrId':     allowCrId,
  };

  Map<String, dynamic> toTableRow() => {
    'counterStockTypeDetID': counterStockTypeDetID?.toString() ?? '',
    'stockTypeCode':         stockTypeCode?.toString()         ?? '',
    'allowCrId':             allowCrId?.toString()             ?? '',
    '_raw':                  this,
  };

  static CounterStockTypeDetModel fromFormValues(Map<String, dynamic> v) =>
      CounterStockTypeDetModel(
        stockTypeCode: int.tryParse(v['stockTypeCode']?.toString() ?? ''),
        allowCrId:     int.tryParse(v['allowCrId']?.toString()     ?? ''),
      );
}