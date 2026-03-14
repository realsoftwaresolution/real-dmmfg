import '../utils/helper_functions.dart';

class FluoModel {
  final int? fluoMstID;
  final int? fluoCode;
  final String? fluoName;
  final String? sflag;
  final String? sdate;
  final int? logID;
  final String? pcID;
  final int? ever;
  final int? companyCode;
  final int? sortID;
  final bool? active;

  FluoModel({
    this.fluoMstID,
    this.fluoCode,
    this.fluoName,
    this.sflag,
    this.sdate,
    this.logID,
    this.pcID,
    this.ever,
    this.companyCode,
    this.sortID,
    this.active,
  });

  factory FluoModel.fromJson(Map<String, dynamic> json) {
    return FluoModel(
      fluoMstID: json['FluoMstID'],
      fluoCode: json['FluoCode'],
      fluoName: json['FluoName'],
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
      'FluoCode': fluoCode,
      'FluoName': fluoName,
      'CompanyCode': companyCode,
      'SortID': sortID,
      'Active': active,
    };
  }

  Map<String, dynamic> toTableRow({String? companyName}) {
    return {
      'fluoCode': fluoCode,
      'fluoName': fluoName ?? '',
      'companyCode':companyName?? companyCode?.toString() ?? '',
      'sortID': sortID?.toString() ?? '',
      'active': active == true ? 'Yes' : 'No',
      '_raw': this,
    };
  }

  static FluoModel fromFormValues(Map<String, dynamic> v) {
    return FluoModel(
      fluoCode: int.tryParse(v['fluoCode'] ?? ''),
      fluoName: v['fluoName'],
      companyCode: int.tryParse(v['companyCode'] ?? ''),
      sortID: int.tryParse(v['sortID'] ?? ''),
      active: parseBool(v['active']),
      // active: v['active'] == 'Y',
    );
  }
}