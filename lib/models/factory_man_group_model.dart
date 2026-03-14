import '../utils/helper_functions.dart';

class FactoryManGroupModel {
  final int? factoryManGroupMstID;
  final int? factoryManGroupCode;
  final String? factoryManGroupName;
  final int? companyCode;
  final int? sortID;
  final bool? active;

  FactoryManGroupModel({
    this.factoryManGroupMstID,
    this.factoryManGroupCode,
    this.factoryManGroupName,
    this.companyCode,
    this.sortID,
    this.active,
  });

  factory FactoryManGroupModel.fromJson(Map<String, dynamic> json) =>
      FactoryManGroupModel(
        factoryManGroupMstID: json['FactoryManGroupMstID'],
        factoryManGroupCode: json['FactoryManGroupCode'],
        factoryManGroupName: json['FactoryManGroupName'],
        companyCode: json['CompanyCode'],
        sortID: json['SortID'],
        active: json['Active'],
      );

  Map<String, dynamic> toJson() => {
    'FactoryManGroupCode': factoryManGroupCode,
    'FactoryManGroupName': factoryManGroupName,
    'CompanyCode': companyCode,
    'SortID': sortID,
    'Active': active,
  };

  Map<String, dynamic> toTableRow({String? companyName}) => {
    'factoryManGroupCode': factoryManGroupCode,
    'factoryManGroupName': factoryManGroupName ?? '',
    'companyCode': companyName ?? companyCode?.toString() ?? '',  // ← name show karega
    'sortID': sortID?.toString() ?? '',
    'active': active == true ? 'Yes' : 'No',
    '_raw': this,
  };

  static FactoryManGroupModel fromFormValues(Map<String, dynamic> v) =>
      FactoryManGroupModel(
        factoryManGroupCode: int.tryParse(v['factoryManGroupCode'] ?? ''),
        factoryManGroupName: v['factoryManGroupName'],
        companyCode: int.tryParse(v['companyCode'] ?? ''),
        sortID: int.tryParse(v['sortID'] ?? ''),
        // active: v['active'] == 'Y',
        active: parseBool(v['active']),

      );
}