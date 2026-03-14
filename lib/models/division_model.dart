import 'package:diam_mfg/utils/helper_functions.dart';

class DivisionModel {
  final int? divisionMstID;
  final int? divisionCode;
  final String? divisionName;
  final int? companyCode;
  final int? sortID;
  final bool? active;

  DivisionModel({
    this.divisionMstID,
    this.divisionCode,
    this.divisionName,
    this.companyCode,
    this.sortID,
    this.active,
  });

  factory DivisionModel.fromJson(Map<String, dynamic> json) => DivisionModel(
    divisionMstID: json['DivisionMstID'],
    divisionCode: json['DivisionCode'],
    divisionName: json['DivisionName'],
    companyCode: json['CompanyCode'],
    sortID: json['SortID'],
    active: json['Active'],
  );

  Map<String, dynamic> toJson() => {
    'DivisionCode': divisionCode,
    'DivisionName': divisionName,
    'CompanyCode': companyCode,
    'SortID': sortID,
    'Active': active,
  };

  Map<String, dynamic> toTableRow({String? companyName}) => {
    'divisionCode': divisionCode,
    'divisionName': divisionName ?? '',
    'companyCode': companyName ?? companyCode?.toString() ?? '',  // ← name show karega
    'sortID': sortID?.toString() ?? '',
    'active': active == true ? 'Yes' : 'No',
    '_raw': this,
  };

  static DivisionModel fromFormValues(Map<String, dynamic> v) => DivisionModel(
    divisionCode: int.tryParse(v['divisionCode'] ?? ''),
    divisionName: v['divisionName'],
    companyCode: int.tryParse(v['companyCode'] ?? ''),
    sortID: int.tryParse(v['sortID'] ?? ''),
    // active: v['active'] == 'Y',
    active: parseBool(v['active']),
  );
}