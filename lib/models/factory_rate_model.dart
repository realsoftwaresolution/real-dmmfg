// lib/models/factory_rate_model.dart

class FactoryRateModel {
  final int factRateMstID;
  final String factRateCode;
  final String factoryCode;
  final String factoryName;
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

  // Lists & comma-separated strings
  final List<int> shapeCodes;
  final String shapes;
  final List<int> cutCodes;
  final String cuts;
  final List<int> articalCodes; // API uses "articalCodes"
  final String articles;

  final List<int> polishCodes;
  final String polish;
  final List<int> symmetryCodes;
  final String symmetry;
  final List<int> certificateCodes;
  final String certificate;

  const FactoryRateModel({
    required this.factRateMstID,
    required this.factRateCode,
    required this.factoryCode,
    required this.factoryName,
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
    required this.shapeCodes,
    required this.shapes,
    required this.cutCodes,
    required this.cuts,
    required this.articalCodes,
    required this.articles,
    required this.polishCodes,
    required this.polish,
    required this.symmetryCodes,
    required this.symmetry,
    required this.certificateCodes,
    required this.certificate,
  });

  factory FactoryRateModel.fromJson(Map<String, dynamic> json) {
    // helper to try multiple key names for compatibility with older payloads
    T _get<T>(Map<String, dynamic> map, List<String> keys, T fallback) {
      for (final k in keys) {
        if (map.containsKey(k) && map[k] != null) {
          return map[k] as T;
        }
      }
      return fallback;
    }

    List<int> _listInt(Map<String, dynamic> map, List<String> keys) {
      for (final k in keys) {
        final v = map[k];
        if (v is List) {
          return v.map((e) => _toInt(e)).toList();
        }
      }
      return <int>[];
    }

    return FactoryRateModel(
      factRateMstID: _toInt(_get<dynamic>(json, ['FactRateMstID', 'ClvDeptRateMstID', 'FactRateMstId'], 0)),
      factRateCode: (_get<dynamic>(json, ['FactRateCode', 'DeptRateCode', 'FactRateCode'], '')).toString(),
      factoryCode: (_get<dynamic>(json, ['FactoryCode'], '')).toString(),
      factoryName: (_get<dynamic>(json, ['FactoryName'], '')).toString(),
      rateID: (_get<dynamic>(json, ['RateID'], '')).toString(),
      rateon: (_get<dynamic>(json, ['Rateon'], '')).toString(),
      sizeon: (_get<dynamic>(json, ['Sizeon'], '')).toString(),
      fromWt: _toDouble(_get<dynamic>(json, ['FromWt'], 0.0)),
      toWt: _toDouble(_get<dynamic>(json, ['ToWt'], 0.0)),
      rate: _toDouble(_get<dynamic>(json, ['Rate'], 0.0)),
      sflag: (_get<dynamic>(json, ['Sflag'], '')).toString(),
      sdate: json['Sdate'] == null ? null : DateTime.tryParse(json['Sdate'].toString()),
      logID: _toInt(_get<dynamic>(json, ['LogID'], 0)),
      pcID: (_get<dynamic>(json, ['PcID'], '')).toString(),
      companyCode: (_get<dynamic>(json, ['CompanyCode'], '')).toString(),
      companyName: (_get<dynamic>(json, ['CompanyName'], null))?.toString(),
      sortID: _toInt(_get<dynamic>(json, ['SortID'], 0)),
      active: _toInt(_get<dynamic>(json, ['Active'], 0)),

      // arrays & strings (support multiple key spellings)
      shapeCodes: _listInt(json, ['shapeCodes', 'shapeCode', 'shape_ids']),
      shapes: (_get<dynamic>(json, ['shapes'], '')).toString(),

      cutCodes: _listInt(json, ['cutCodes', 'cutCode', 'cut_ids']),
      cuts: (_get<dynamic>(json, ['cuts'], '')).toString(),

      articalCodes: _listInt(json, ['articalCodes', 'articleCodes', 'article_codes']),
      articles: (_get<dynamic>(json, ['articles'], '')).toString(),

      polishCodes: _listInt(json, ['polishCodes', 'polish_codes']),
      polish: (_get<dynamic>(json, ['polish'], '')).toString(),

      symmetryCodes: _listInt(json, ['symmetryCodes', 'symmetry_codes']),
      symmetry: (_get<dynamic>(json, ['symmetry'], '')).toString(),

      certificateCodes: _listInt(json, ['certificateCodes', 'certificate_codes']),
      certificate: (_get<dynamic>(json, ['certificate'], '')).toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'FactRateMstID': factRateMstID,
    'FactRateCode': factRateCode,
    'FactoryCode': factoryCode,
    'FactoryName': factoryName,
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
    'shapeCodes': shapeCodes,
    'shapes': shapes,
    'cutCodes': cutCodes,
    'cuts': cuts,
    'articalCodes': articalCodes,
    'articles': articles,
    'polishCodes': polishCodes,
    'polish': polish,
    'symmetryCodes': symmetryCodes,
    'symmetry': symmetry,
    'certificateCodes': certificateCodes,
    'certificate': certificate,
  };

  FactoryRateModel copyWith({
    int? factRateMstID,
    String? factRateCode,
    String? factoryCode,
    String? factoryName,
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
    List<int>? shapeCodes,
    String? shapes,
    List<int>? cutCodes,
    String? cuts,
    List<int>? articalCodes,
    String? articles,
    List<int>? polishCodes,
    String? polish,
    List<int>? symmetryCodes,
    String? symmetry,
    List<int>? certificateCodes,
    String? certificate,
  }) {
    return FactoryRateModel(
      factRateMstID: factRateMstID ?? this.factRateMstID,
      factRateCode: factRateCode ?? this.factRateCode,
      factoryCode: factoryCode ?? this.factoryCode,
      factoryName: factoryName ?? this.factoryName,
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
      shapeCodes: shapeCodes ?? this.shapeCodes,
      shapes: shapes ?? this.shapes,
      cutCodes: cutCodes ?? this.cutCodes,
      cuts: cuts ?? this.cuts,
      articalCodes: articalCodes ?? this.articalCodes,
      articles: articles ?? this.articles,
      polishCodes: polishCodes ?? this.polishCodes,
      polish: polish ?? this.polish,
      symmetryCodes: symmetryCodes ?? this.symmetryCodes,
      symmetry: symmetry ?? this.symmetry,
      certificateCodes: certificateCodes ?? this.certificateCodes,
      certificate: certificate ?? this.certificate,
    );
  }

  Map<String, dynamic> toTableRow() => {
    '_raw': this,
    'factRateMstID': factRateMstID,
    'factRateCode': factRateCode,
    'factoryName': factoryName,
    'rateID': rateID,
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
    'articalCodes': articalCodes,
    'cutCodes': cutCodes,
    'shapeCodes': shapeCodes,
    'polish': polish,
    'symmetry': symmetry,
    'certificate': certificate,
  };

  // parse list helper
  static List<FactoryRateModel> listFromJsonList(List<dynamic>? list) {
    if (list == null) return [];
    return list.map((e) => FactoryRateModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  String toString() {
    return 'FactoryRateModel(factRateMstID: $factRateMstID, factoryName: $factoryName, rate: $rate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FactoryRateModel &&
        other.factRateMstID == factRateMstID &&
        other.factRateCode == factRateCode &&
        other.rateID == rateID;
  }

  @override
  int get hashCode => Object.hash(factRateMstID, factRateCode, rateID);

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