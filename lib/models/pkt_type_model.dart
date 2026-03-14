import '../utils/helper_functions.dart';

class PktTypeModel {
  final int? pktTypeMstID;
  final int? pktTypeCode;
  final String? pktTypeName;
  final int? sortID;
  final bool? active;

  PktTypeModel({
    this.pktTypeMstID,
    this.pktTypeCode,
    this.pktTypeName,
    this.sortID,
    this.active,
  });

  factory PktTypeModel.fromJson(Map<String, dynamic> json) {
    return PktTypeModel(
      pktTypeMstID: json['PktTypeMstID'],
      pktTypeCode:  json['PktTypeCode'],
      pktTypeName:  json['PktTypeName'],
      sortID:       json['SortID'],
      active:       json['Active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'PktTypeName': pktTypeName,
      'SortID':      sortID,
      'Active':      active,
    };
  }

  Map<String, dynamic> toTableRow() {
    return {
      'pktTypeCode': pktTypeCode?.toString() ?? '',
      'pktTypeName': pktTypeName ?? '',
      'sortID':      sortID?.toString() ?? '',
      'active':      active == true ? 'Yes' : 'No',
      '_raw':        this,
    };
  }

  static PktTypeModel fromFormValues(Map<String, dynamic> v) {
    return PktTypeModel(
      pktTypeCode: int.tryParse(v['pktTypeCode'] ?? ''),
      pktTypeName: v['pktTypeName'],
      sortID:      int.tryParse(v['sortID'] ?? ''),
      active:      parseBool(v['active']),
    );
  }
}