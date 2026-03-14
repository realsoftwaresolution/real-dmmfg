import 'package:diam_mfg/utils/helper_functions.dart';

class ShapeModel {
  final int? shapeMstID;
  final int? shapeCode;
  final String? shapeName;
  final int? shapeGroupCode;
  final String? sflag;
  final String? sdate;
  final int? logID;
  final String? pcID;
  final int? ever;
  final int? companyCode;
  final int? sortID;
  final bool? active;
  final String? rateOn;
  final String? rapCode;
  final bool? pg;

  ShapeModel({
    this.shapeMstID,
    this.shapeCode,
    this.shapeName,
    this.shapeGroupCode,
    this.sflag,
    this.sdate,
    this.logID,
    this.pcID,
    this.ever,
    this.companyCode,
    this.sortID,
    this.active,
    this.rateOn,
    this.rapCode,
    this.pg,
  });

  factory ShapeModel.fromJson(Map<String, dynamic> json) {
    return ShapeModel(
      shapeMstID: json['ShapeMstID'],
      shapeCode: json['ShapeCode'],
      shapeName: json['ShapeName'],
      shapeGroupCode: json['ShapeGroupCode'],
      sflag: json['Sflag'],
      sdate: json['Sdate']?.toString(),
      logID: json['LogID'],
      pcID: json['PcID'],
      ever: json['Ever'],
      companyCode: json['CompanyCode'],
      sortID: json['SortID'],
      active: json['Active'],
      rateOn: json['RateOn'],
      rapCode: json['RAPCODE'],
      pg: json['PG'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ShapeCode': shapeCode,
      'ShapeName': shapeName,
      'ShapeGroupCode': shapeGroupCode,
      'CompanyCode': companyCode,
      'SortID': sortID,
      'Active': active,
      'RateOn': rateOn,
      'RAPCODE': rapCode,
      'PG': pg,
    };
  }

  Map<String, dynamic> toTableRow({String? companyName}) {
    return {
      'shapeCode': shapeCode,
      'shapeName': shapeName ?? '',
      'shapeGroupCode': shapeGroupCode?.toString() ?? '',
      'rateOn': rateOn ?? '',
      'rapCode': rapCode ?? '',
      'companyCode': companyName??companyCode?.toString() ?? '',
      'sortID': sortID?.toString() ?? '',
      'active': active == true ? 'Yes' : 'No',
      '_raw': this,
    };
  }

  static ShapeModel fromFormValues(Map<String, dynamic> v) {
    return ShapeModel(
      shapeCode: int.tryParse(v['shapeCode'] ?? ''),
      shapeName: v['shapeName'],
      shapeGroupCode: int.tryParse(v['shapeGroupCode'] ?? ''),
      companyCode: int.tryParse(v['companyCode'] ?? ''),
      sortID: int.tryParse(v['sortID'] ?? ''),
      active: parseBool(v['active']),
      // active: v['active'] == 'Y',
      rateOn: v['rateOn'],
      rapCode: v['rapCode'],
      pg: parseBool(v['pg']),
      // pg: v['pg'] == 'Y',
    );
  }
}