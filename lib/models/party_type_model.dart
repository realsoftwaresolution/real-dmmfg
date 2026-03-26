import '../utils/helper_functions.dart';

class PartyTypeModel {
  final int? partyTypeID;
  final int? partyNameCode;
  final String? partyTypeName;
  final int? companyCode;
  final int? sortID;
  final bool? active;

  PartyTypeModel({
    this.partyTypeID,
    this.partyNameCode,
    this.partyTypeName,
    this.companyCode,
    this.sortID,
    this.active,
  });

  factory PartyTypeModel.fromJson(Map<String, dynamic> json) {
    return PartyTypeModel(
      partyTypeID: json['PartyTypeID'],
      partyNameCode: json['PartyNameCode'],
      partyTypeName: json['PartyTypeName'],
      companyCode: json['CompanyCode'],
      sortID: json['SortID'],
      active: json['Active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'PartyNameCode': partyNameCode,
      'PartyTypeName': partyTypeName,
      'CompanyCode': companyCode,
      'SortID': sortID,
      'Active': active,
    };
  }

  Map<String, dynamic> toTableRow({String? companyName}) {
    return {
      'partyNameCode': partyNameCode,
      'partyTypeName': partyTypeName ?? '',
      'companyCode': companyName ?? companyCode?.toString() ?? '',
      'sortID': sortID?.toString() ?? '',
      'active': active == true ? 'Yes' : 'No',
      '_raw': this,
    };
  }

  static PartyTypeModel fromFormValues(Map<String, dynamic> v) {
    return PartyTypeModel(
      partyNameCode: int.tryParse(v['partyNameCode'] ?? ''),
      partyTypeName: v['partyTypeName'],
      companyCode: int.tryParse(v['companyCode'] ?? ''),
      sortID: int.tryParse(v['sortID'] ?? ''),
      active: parseBool(v['active']),
    );
  }
}