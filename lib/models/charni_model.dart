import '../utils/helper_functions.dart';

class CharniModel {
  final int? charniMstID;
  final int? charniCode;
  final String? charniName;
  final int? charniRptGroupCode;
  final String? sflag;
  final String? sdate;
  final int? logID;
  final String? pcID;
  final int? ever;
  final int? companyCode;
  final int? sortID;
  final bool? active;
  final double? fromSize;
  final double? toSize;
  final int? shapeCode;
  final bool? pg;
  final String? charniGroup;
  final int? deptCode;

  CharniModel({
    this.charniMstID,
    this.charniCode,
    this.charniName,
    this.charniRptGroupCode,
    this.sflag,
    this.sdate,
    this.logID,
    this.pcID,
    this.ever,
    this.companyCode,
    this.sortID,
    this.active,
    this.fromSize,
    this.toSize,
    this.shapeCode,
    this.pg,
    this.charniGroup,
    this.deptCode,
  });

  factory CharniModel.fromJson(Map<String, dynamic> json) {
    return CharniModel(
      charniMstID: json['CharniMstID'],
      charniCode: json['CharniCode'],
      charniName: json['CharniName'],
      charniRptGroupCode: json['CharniRptGroupCode'],
      sflag: json['Sflag'],
      sdate: json['Sdate']?.toString(),
      logID: json['LogID'],
      pcID: json['PcID'],
      ever: json['Ever'],
      companyCode: json['CompanyCode'],
      sortID: json['SortID'],
      active: json['Active'],
      fromSize: json['FromSize'] != null
          ? double.tryParse(json['FromSize'].toString())
          : null,
      toSize: json['ToSize'] != null
          ? double.tryParse(json['ToSize'].toString())
          : null,
      shapeCode: json['ShapeCode'],
      pg: json['PG'],
      charniGroup: json['CharniGroup'],
      deptCode: json['DeptCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CharniCode': charniCode,
      'CharniName': charniName,
      'CharniRptGroupCode': charniRptGroupCode,
      'CompanyCode': companyCode,
      'SortID': sortID,
      'Active': active,
      'FromSize': fromSize,
      'ToSize': toSize,
      'ShapeCode': shapeCode,
      'PG': pg,
      'CharniGroup': charniGroup,
      'DeptCode': deptCode,
    };
  }

  Map<String, dynamic> toTableRow({String? companyName}) {
    return {
      'charniCode': charniCode,
      'charniName': charniName ?? '',
      'charniGroup': charniGroup ?? '',
      'companyCode': companyName??companyCode?.toString() ?? '',
      'sortID': sortID?.toString() ?? '',
      'active': active == true ? 'Yes' : 'No',
      '_raw': this,
    };
  }

  static CharniModel fromFormValues(Map<String, dynamic> v) {
    return CharniModel(
      charniCode: int.tryParse(v['charniCode'] ?? ''),
      charniName: v['charniName'],
      charniRptGroupCode: int.tryParse(v['charniRptGroupCode'] ?? ''),
      companyCode: int.tryParse(v['companyCode'] ?? ''),
      sortID: int.tryParse(v['sortID'] ?? ''),
      // active: v['active'] == 'Y',

      fromSize: double.tryParse(v['fromSize'] ?? ''),
      toSize: double.tryParse(v['toSize'] ?? ''),
      shapeCode: int.tryParse(v['shapeCode'] ?? ''),
      active: parseBool(v['active']),       // ← FIX
      pg: parseBool(v['pg']),
      charniGroup: v['charniGroup'],
      deptCode: int.tryParse(v['deptCode'] ?? ''),
    );
  }
}