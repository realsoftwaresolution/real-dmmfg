import '../utils/helper_functions.dart';

class StockTypeModel {
  final int? stockTypeMstID;
  final int? stockTypeCode;
  final String? stockTypeName;
  final int? sortID;
  final bool? active;

  StockTypeModel({
    this.stockTypeMstID,
    this.stockTypeCode,
    this.stockTypeName,
    this.sortID,
    this.active,
  });

  factory StockTypeModel.fromJson(Map<String, dynamic> json) {
    return StockTypeModel(
      stockTypeMstID: json['StockTypeMstID'],
      stockTypeCode:  json['StockTypeCode'],
      stockTypeName:  json['StockTypeName'],
      sortID:         json['SortID'],
      active:         json['Active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'StockTypeName': stockTypeName,
      'SortID':        sortID,
      'Active':        active,
    };
  }

  Map<String, dynamic> toTableRow() {
    return {
      'stockTypeCode': stockTypeCode?.toString() ?? '',
      'stockTypeName': stockTypeName             ?? '',
      'sortID':        sortID?.toString()        ?? '',
      'active':        active == true ? 'Yes' : 'No',
      '_raw':          this,
    };
  }

  static StockTypeModel fromFormValues(Map<String, dynamic> v) {
    return StockTypeModel(
      stockTypeCode: int.tryParse(v['stockTypeCode'] ?? ''),
      stockTypeName: v['stockTypeName'],
      sortID:        int.tryParse(v['sortID'] ?? ''),
      active:        parseBool(v['active']),
    );
  }
}