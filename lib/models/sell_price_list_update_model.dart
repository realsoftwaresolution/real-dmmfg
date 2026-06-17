class SellPriceListUpdateModel {
  int? factoryRecDetID;
  int? factoryRecMstID;

  String? cutNo;

  int? shapeCode;
  int? colorCode;
  int? purityCode;

  double? recWt;

  String? groupType;

  int? articalCode;

  double? sellRate;
  double? sellAmount;
  String? sellCode;

  SellPriceListUpdateModel();

  factory SellPriceListUpdateModel.fromJson(Map<String, dynamic> json) {
    return SellPriceListUpdateModel()
      ..factoryRecDetID = json['FactoryRecDetID']
      ..factoryRecMstID = json['FactoryRecMstID']
      ..cutNo = json['CutNo']
      ..shapeCode = json['ShapeCode']
      ..colorCode = json['ColorCode']
      ..purityCode = json['PurityCode']
      ..recWt = (json['RecWt'] as num?)?.toDouble()
      ..groupType = json['GroupType']
      ..articalCode = json['ArticalCode']
      ..sellRate = (json['SellRate'] as num?)?.toDouble()
      ..sellAmount = (json['SellAmount'] as num?)?.toDouble()
      ..sellCode = json['SellCode'];
  }

  Map<String, dynamic> toJson() => {
    'FactoryRecDetID': factoryRecDetID,
    'FactoryRecMstID': factoryRecMstID,
    'CutNo': cutNo,
    'ShapeCode': shapeCode,
    'ColorCode': colorCode,
    'PurityCode': purityCode,
    'RecWt': recWt,
    'GroupType': groupType,
    'ArticalCode': articalCode,
    'SellRate': sellRate,
    'SellAmount': sellAmount,
    'SellCode': sellCode,
  };
}