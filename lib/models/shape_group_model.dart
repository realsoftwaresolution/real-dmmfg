import '../utils/helper_functions.dart';

class ShapeGroupModel {
  final int? shapeGroupMstID;
  final int? shapeGroupCode;
  final String? shapeGroupName;
  final String? sflag;
  final String? sdate;
  final int? logID;
  final String? pcID;
  final int? ever;
  final int? companyCode;
  final int? sortID;
  final bool? active;

  ShapeGroupModel({
    this.shapeGroupMstID,
    this.shapeGroupCode,
    this.shapeGroupName,
    this.sflag,
    this.sdate,
    this.logID,
    this.pcID,
    this.ever,
    this.companyCode,
    this.sortID,
    this.active,
  });

  factory ShapeGroupModel.fromJson(Map<String, dynamic> json) {
    return ShapeGroupModel(
      shapeGroupMstID: json['ShapeGroupMstID'],
      shapeGroupCode: json['ShapeGroupCode'],
      shapeGroupName: json['ShapeGroupName'],
      sflag: json['Sflag'],
      sdate: json['Sdate']?.toString(),
      logID: json['LogID'],
      pcID: json['PcID'],
      ever: json['Ever'],
      companyCode: json['CompanyCode'],
      sortID: json['SortID'],
      active: json['Active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ShapeGroupCode': shapeGroupCode,
      'ShapeGroupName': shapeGroupName,
      'CompanyCode': companyCode,
      'SortID': sortID,
      'Active': active,
    };
  }

  Map<String, dynamic> toTableRow({String? companyName}) {
    return {
      'shapeGroupCode': shapeGroupCode,
      'shapeGroupName': shapeGroupName ?? '',
      'companyCode': companyName??companyCode?.toString() ?? '',
      'sortID': sortID?.toString() ?? '',
      'active': active == true ? 'Yes' : 'No',
      '_raw': this,
    };
  }

  static ShapeGroupModel fromFormValues(Map<String, dynamic> v) {
    return ShapeGroupModel(
      shapeGroupCode: int.tryParse(v['shapeGroupCode'] ?? ''),
      shapeGroupName: v['shapeGroupName'],
      companyCode: int.tryParse(v['companyCode'] ?? ''),
      sortID: int.tryParse(v['sortID'] ?? ''),
      // active: v['active'] == 'Y',
      active: parseBool(v['active']),       // ← FIX

    );
  }
}