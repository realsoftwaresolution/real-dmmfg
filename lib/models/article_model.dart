import '../utils/helper_functions.dart';

class ArticleModel {
  final int? articalMstID;
  final int? articalCode;
  final String? articalName;
  final String? sflag;
  final String? sdate;
  final int? logID;
  final String? pcID;
  final int? ever;
  final int? companyCode;
  final int? sortID;
  final bool? active;

  ArticleModel({
    this.articalMstID,
    this.articalCode,
    this.articalName,
    this.sflag,
    this.sdate,
    this.logID,
    this.pcID,
    this.ever,
    this.companyCode,
    this.sortID,
    this.active,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      articalMstID: json['ArticalMstID'],
      articalCode: json['ArticalCode'],
      articalName: json['ArticalName'],
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
      'ArticalCode': articalCode,
      'ArticalName': articalName,
      'CompanyCode': companyCode,
      'SortID': sortID,
      'Active': active,
    };
  }

  Map<String, dynamic> toTableRow({String? companyName}) {
    return {
      'articalCode': articalCode,
      'articalName': articalName ?? '',
      'companyCode': companyName??companyCode?.toString() ?? '',
      'sortID': sortID?.toString() ?? '',
      'active': active == true ? 'Yes' : 'No',
      '_raw': this,
    };
  }

  static ArticleModel fromFormValues(Map<String, dynamic> v) {
    return ArticleModel(
      articalCode: int.tryParse(v['articalCode'] ?? ''),
      articalName: v['articalName'],
      companyCode: int.tryParse(v['companyCode'] ?? ''),
      sortID: int.tryParse(v['sortID'] ?? ''),
      // active: v['active'] == 'Y',
      active: parseBool(v['active']),       // ← FIX

    );
  }
}