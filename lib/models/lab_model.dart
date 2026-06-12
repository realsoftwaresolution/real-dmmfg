import '../utils/helper_functions.dart';

class LabModel {
  final int? labMstID;
  final int? certificateCode;
  final String? certificateName;
  final String? sflag;
  final String? sdate;
  final int? logID;
  final String? pcID;
  final String? companyName;
  final int? ever;
  final int? companyCode;
  final int? sortID;
  final bool? active;

  LabModel({
    this.labMstID,
    this.certificateCode,
    this.certificateName,
    this.sflag,
    this.sdate,
    this.logID,
    this.pcID,
    this.ever,
    this.companyCode,
    this.companyName,
    this.sortID,
    this.active,
  });

  factory LabModel.fromJson(Map<String, dynamic> json) => LabModel(
    labMstID: json['LabMstID'],
    certificateCode: json['CertificateCode'],
    certificateName: json['CertificateName'],
    sflag: json['Sflag'],
    sdate: json['Sdate']?.toString(),
    logID: json['LogID'],
    pcID: json['PcID'],
    ever: json['Ever'],
    companyCode: json['CompanyCode'],
    companyName: json['CompanyName'],
    sortID: json['SortID'],
    active: json['Active'],
  );

  Map<String, dynamic> toJson() => {
    'CertificateCode': certificateCode,
    'CertificateName': certificateName,
    'Sflag': sflag,
    'Sdate': sdate,
    'LogID': logID,
    'PcID': pcID,
    'Ever': ever,
    'CompanyCode': companyCode,
    'CompanyName': companyName,
    'SortID': sortID,
    'Active': active,
  };

  Map<String, dynamic> toTableRow({String? company}) => {
    'certificateCode': certificateCode,
    'certificateName': certificateName ?? '',
    'CompanyName': companyName ?? '',
    'companyCode': company ?? companyCode?.toString() ?? '',  // ← name show karega
    'sortID': sortID?.toString() ?? '',
    'active': active == true ? 'Yes' : 'No',
    '_raw': this,
  };

  static LabModel fromFormValues(Map<String, dynamic> v) => LabModel(
    certificateCode: int.tryParse(v['certificateCode'] ?? ''),
    certificateName: v['certificateName'],
    companyCode: int.tryParse(v['companyCode'] ?? ''),
    sortID: int.tryParse(v['sortID'] ?? ''),
    // active: v['active'] == 'Y',
    active: parseBool(v['active']),

  );
}