// lib/models/dept_rate_model.dart
class DeptRateModel {
  final int? clvDeptRateMstID;
  final String? deptRateCode;
  final int? crId;
  final int? deptCode;
  final String? deptName;
  final int? deptProcessCode;
  final String? deptProcessName;
  final int? rateID;
  final String? rateon;
  final String? sizeon;
  final double? fromWt;
  final double? toWt;
  final double? rate;
  final String? sflag;
  final DateTime? sdate;
  final int? logID;
  final String? pcID;
  final String? companyCode;
  final String? companyName;
  final int? sortID;
  final int? active;
  final List<int>? shapes;
  final List<int>? cuts;
  final List<int>? articles;

  DeptRateModel({
    this.clvDeptRateMstID,
    this.deptRateCode,
    this.crId,
    this.deptCode,
    this.deptName,
    this.deptProcessCode,
    this.deptProcessName,
    this.rateID,
    this.rateon,
    this.sizeon,
    this.fromWt,
    this.toWt,
    this.rate,
    this.sflag,
    this.sdate,
    this.logID,
    this.pcID,
    this.companyCode,
    this.companyName,
    this.sortID,
    this.active,
    this.shapes,
    this.cuts,
    this.articles,
  });

  factory DeptRateModel.fromJson(Map<String, dynamic> json) {
    return DeptRateModel(
      clvDeptRateMstID: json['ClvDeptRateMstID'],
      deptRateCode: json['DeptRateCode'],
      crId: json['CrId'],
      deptCode: json['DeptCode'],
      deptName: json['DeptName'],
      deptProcessCode: json['DeptProcessCode'],
      deptProcessName: json['DeptProcessName'],
      rateID: json['RateID'],
      rateon: json['Rateon'],
      sizeon: json['Sizeon'],
      fromWt: parseDouble(json['FromWt']),
      toWt: parseDouble(json['ToWt']),
      rate: parseDouble(json['Rate']),
      sflag: json['Sflag'],
      sdate: json['Sdate'] != null ? DateTime.parse(json['Sdate']) : null,
      logID: json['LogID'],
      pcID: json['PcID'],
      companyCode: json['CompanyCode'],
      companyName: json['CompanyName'],
      sortID: json['SortID'],
      active: json['Active'],
      shapes: json['shapes'] != null ? List<int>.from(json['shapes']) : [],
      cuts: json['cuts'] != null ? List<int>.from(json['cuts']) : [],
      articles: json['articles'] != null ? List<int>.from(json['articles']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ClvDeptRateMstID': clvDeptRateMstID,
      'DeptRateCode': deptRateCode,
      'CrId': crId,
      'DeptCode': deptCode,
      'DeptName': deptName,
      'DeptProcessCode': deptProcessCode,
      'DeptProcessName': deptProcessName,
      'RateID': rateID,
      'Rateon': rateon,
      'Sizeon': sizeon,
      'FromWt': fromWt,
      'ToWt': toWt,
      'Rate': rate,
      'Sflag': sflag,
      'Sdate': sdate?.toIso8601String(),
      'LogID': logID,
      'PcID': pcID,
      'CompanyCode': companyCode,
      'CompanyName': companyName,
      'SortID': sortID,
      'Active': active,
      'shapes': shapes,
      'cuts': cuts,
      'articles': articles,
    };
  }

  Map<String, dynamic> toTableRow() {
    return {
      '_raw': this,
      'deptRateCode': deptRateCode ?? '',
      'deptName': deptName ?? '',
      'deptProcessName': deptProcessName ?? '',
      'rateID': rateID?.toString() ?? '',
      'rateon': rateon ?? '',
      'sizeon': sizeon ?? '',
      'fromWt': fromWt != null ? fromWt!.toStringAsFixed(3) : '',
      'toWt': toWt != null ? toWt!.toStringAsFixed(3) : '',
      'rate': rate != null ? rate!.toStringAsFixed(2) : '',
      'sortID': sortID?.toString() ?? '',
      'active': active == 1 ? '✓' : '',
      'companyName': companyName ?? '',
      'crId': crId?.toString() ?? '',
    };
  }
}

double? parseDouble(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is String) {
    try {
      return double.parse(v);
    } catch (_) {
      return null;
    }
  }
  return null;
}