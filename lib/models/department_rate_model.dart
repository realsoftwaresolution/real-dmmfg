// lib/models/department_rate.dart

class DepartmentRateModel {
  final int clvDeptRateMstID;
  final String deptRateCode;
  final int crId;
  final int deptProcessCode;
  final String deptProcessName;
  final int deptCode;
  final String deptName;
  final dynamic rateID;
  final String rateon;
  final String sizeon;
  final double fromWt;
  final double toWt;
  final double rate;
  final String sflag;
  final DateTime? sdate;
  final int logID;
  final String pcID;
  final String companyCode;
  final String? companyName;
  final int sortID;
  final int active;
  final String shapes;
  final String cuts;
  final String articles;
  final List<int> shapesIds;
  final List<int> cutsIds;
  final List<int> articlesIds;

  const DepartmentRateModel({
    required this.clvDeptRateMstID,
    required this.deptRateCode,
    required this.crId,
    required this.deptProcessCode,
    required this.deptProcessName,
    required this.deptCode,
    required this.deptName,
    required this.rateID,
    required this.rateon,
    required this.sizeon,
    required this.fromWt,
    required this.toWt,
    required this.rate,
    required this.sflag,
    required this.sdate,
    required this.logID,
    required this.pcID,
    required this.companyCode,
    required this.companyName,
    required this.sortID,
    required this.active,
    required this.shapes,
    required this.cuts,
    required this.articles,
    required this.shapesIds,
    required this.cutsIds,
    required this.articlesIds,
  });

  factory DepartmentRateModel.fromJson(Map<String, dynamic> json) {
    return DepartmentRateModel(
      clvDeptRateMstID: _toInt(json['ClvDeptRateMstID']),
      deptRateCode: json['DeptRateCode']?.toString() ?? '',
      crId: _toInt(json['CrId']),
      deptProcessCode: _toInt(json['DeptProcessCode']),
      deptProcessName: json['DeptProcessName']?.toString() ?? '',
      deptCode: _toInt(json['DeptCode']),
      deptName: json['DeptName']?.toString() ?? '',
      rateID: json['RateID'] ?? '',
      rateon: json['Rateon']?.toString() ?? '',
      sizeon: json['Sizeon']?.toString() ?? '',
      fromWt: _toDouble(json['FromWt']),
      toWt: _toDouble(json['ToWt']),
      rate: _toDouble(json['Rate']),
      sflag: json['Sflag']?.toString() ?? '',
      sdate: json['Sdate'] == null
          ? null
          : DateTime.tryParse(json['Sdate'].toString()),
      logID: _toInt(json['LogID']),
      pcID: json['PcID']?.toString() ?? '',
      companyCode: json['CompanyCode']?.toString() ?? '',
      companyName: json['CompanyName']?.toString(),
      sortID: _toInt(json['SortID']),
      active: _toInt(json['Active']),
      shapes: json['shapes']?.toString() ?? '',
      cuts: json['cuts']?.toString() ?? '',
      articles: json['articles']?.toString() ?? '',

      shapesIds: (json['shapeCodes'] as List<dynamic>?)
          ?.map((e) => _toInt(e))
          .toList() ??
          [],

      cutsIds: (json['cutCodes'] as List<dynamic>?)
          ?.map((e) => _toInt(e))
          .toList() ??
          [],

      articlesIds: (json['articalCodes'] as List<dynamic>?)
          ?.map((e) => _toInt(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'ClvDeptRateMstID': clvDeptRateMstID,
    'DeptRateCode': deptRateCode,
    'CrId': crId,
    'DeptProcessCode': deptProcessCode,
    'DeptProcessName': deptProcessName,
    'DeptCode': deptCode,
    'DeptName': deptName,
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
    'articalCodes': articlesIds,
    'cutCodes': cutsIds,
    'shapeCodes': shapesIds,
  };

  DepartmentRateModel copyWith({
    int? clvDeptRateMstID,
    String? deptRateCode,
    int? crId,
    int? deptProcessCode,
    String? deptProcessName,
    int? deptCode,
    String? deptName,
    int? rateID,
    String? rateon,
    String? sizeon,
    double? fromWt,
    double? toWt,
    double? rate,
    String? sflag,
    DateTime? sdate,
    int? logID,
    String? pcID,
    String? companyCode,
    String? companyName,
    int? sortID,
    int? active,
    String? shapes,
    String? cuts,
    String? articles,
  }) {
    return DepartmentRateModel(
      clvDeptRateMstID: clvDeptRateMstID ?? this.clvDeptRateMstID,
      deptRateCode: deptRateCode ?? this.deptRateCode,
      crId: crId ?? this.crId,
      deptProcessCode: deptProcessCode ?? this.deptProcessCode,
      deptProcessName: deptProcessName ?? this.deptProcessName,
      deptCode: deptCode ?? this.deptCode,
      deptName: deptName ?? this.deptName,
      rateID: rateID ?? this.rateID,
      rateon: rateon ?? this.rateon,
      sizeon: sizeon ?? this.sizeon,
      fromWt: fromWt ?? this.fromWt,
      toWt: toWt ?? this.toWt,
      rate: rate ?? this.rate,
      sflag: sflag ?? this.sflag,
      sdate: sdate ?? this.sdate,
      logID: logID ?? this.logID,
      pcID: pcID ?? this.pcID,
      companyCode: companyCode ?? this.companyCode,
      companyName: companyName ?? this.companyName,
      sortID: sortID ?? this.sortID,
      active: active ?? this.active,
      shapes: shapes ?? this.shapes,
      cuts: cuts ?? this.cuts,
      articles: articles ?? this.articles,
      shapesIds: shapesIds ,
      cutsIds: cutsIds,
      articlesIds: articlesIds,
    );
  }

  // Add this method to the DepartmentRate class

  Map<String, dynamic> toTableRow() => {
    '_raw': this,          // ← add this line
    'clvDeptRateMstID': clvDeptRateMstID,
    'deptRateCode': deptRateCode,
    'deptProcessName': deptProcessName,
    'deptName': deptName,
    'rateon': rateon,
    'sizeon': sizeon,
    'fromWt': fromWt,
    'toWt': toWt,
    'rate': rate,
    'sflag': sflag,
    'sdate': sdate?.toIso8601String(),
    'companyName': companyName ?? 'N/A',
    'active': active,
    'shapes': shapes,
    'cuts': cuts,
    'articles': articles,
    'articalCodes': articlesIds,
    'cutCodes': cutsIds,
    'shapeCodes': shapesIds,
  };

  // Helper to parse a list from the "data" array
  static List<DepartmentRateModel> listFromJsonList(List<dynamic>? list) {
    if (list == null) return [];
    return list.map((e) => DepartmentRateModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  String toString() {
    return 'DepartmentRate(clvDeptRateMstID: $clvDeptRateMstID, deptName: $deptName, rate: $rate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DepartmentRateModel &&
        other.clvDeptRateMstID == clvDeptRateMstID &&
        other.deptRateCode == deptRateCode &&
        other.rateID == rateID;
  }

  @override
  int get hashCode => Object.hash(clvDeptRateMstID, deptRateCode, rateID);

  // ---- helpers to safely convert types ----
  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }
}