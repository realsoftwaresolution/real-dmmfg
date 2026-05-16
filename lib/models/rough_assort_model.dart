// lib/models/rough_assort_model.dart

class RoughAssortModel {
  final int? roughAssortMstID;
  final String? roughAssortDate;
  final String? remarks;
  final String? sflag;
  final String? sdate;
  final int? logID;
  final String? pcID;
  final int? ever;
  final int? jno;
  final String? kapanNo;

  final List<RoughAssortDetModel> details;

  RoughAssortModel({
    this.roughAssortMstID,
    this.roughAssortDate,
    this.remarks,
    this.sflag,
    this.sdate,
    this.logID,
    this.pcID,
    this.ever,
    this.jno,
    this.kapanNo,
    this.details = const [],
  });

  factory RoughAssortModel.fromJson(Map<String, dynamic> json) =>
      RoughAssortModel(
        roughAssortMstID: json['RoughAssortMstID'],
        roughAssortDate: json['RoughAssortDate'],
        remarks: json['Remarks'],
        sflag: json['Sflag'],
        sdate: json['Sdate'],
        logID: json['LogID'],
        pcID: json['PcID'],
        ever: json['Ever'],
        jno: json['Jno'],
        kapanNo: json['KapanNo'],
        details: (json['details'] as List? ?? [])
            .map((e) => RoughAssortDetModel.fromJson(e))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
    'RoughAssortDate': roughAssortDate ?? '',
    'Remarks': remarks ?? '',
    'Sflag': sflag ?? '',
    'Ever': ever ?? 1,
    'Jno': jno ?? 0,
    'KapanNo': kapanNo ?? '',
  };
}

// ─────────────────────────────────────────────────────────────────────────────
//  Detail Model
// ─────────────────────────────────────────────────────────────────────────────
class RoughAssortDetModel {
  final int? roughAssortDetID;
  final int? roughAssortMstID;
  final int? srno;
  final int? purityCode;
  final int? pc;
  final double? wt;
  final double? rateDollar;
  final double? amtDollar;
  final int? purityGroupCode;
  final double? per;
  final double? exRate;
  final double? rateRs;
  final double? amtRs;
  final double? labRateD;
  final double? labAmtD;
  final double? labRateRs;
  final double? labAmtRs;
  final double? totRateD;
  final double? totAmtD;
  final double? totRateRs;
  final double? totAmtRs;

  RoughAssortDetModel({
    this.roughAssortDetID,
    this.roughAssortMstID,
    this.srno,
    this.purityCode,
    this.pc,
    this.wt,
    this.rateDollar,
    this.amtDollar,
    this.purityGroupCode,
    this.per,
    this.exRate,
    this.rateRs,
    this.amtRs,
    this.labRateD,
    this.labAmtD,
    this.labRateRs,
    this.labAmtRs,
    this.totRateD,
    this.totAmtD,
    this.totRateRs,
    this.totAmtRs,
  });

  factory RoughAssortDetModel.fromJson(Map<String, dynamic> json) =>
      RoughAssortDetModel(
        roughAssortDetID: json['RoughAssortDetID'],
        roughAssortMstID: json['RoughAssortMstID'],
        srno: json['Srno'],
        purityCode: json['PurityCode'],
        pc: json['Pc'],
        wt: _d(json['Wt']),
        rateDollar: _d(json['RateDollar']),
        amtDollar: _d(json['AmtDollar']),
        purityGroupCode: json['PurityGroupCode'],
        per: _d(json['Per']),
        exRate: _d(json['ExRate']),
        rateRs: _d(json['RateRs']),
        amtRs: _d(json['AmtRs']),
        labRateD: _d(json['LabRateD']),
        labAmtD: _d(json['LabAmtD']),
        labRateRs: _d(json['LabRateRs']),
        labAmtRs: _d(json['LabAmtRs']),
        totRateD: _d(json['TotRateD']),
        totAmtD: _d(json['TotAmtD']),
        totRateRs: _d(json['TotRateRs']),
        totAmtRs: _d(json['TotAmtRs']),
      );

  Map<String, dynamic> toJson() => {
    'RoughAssortMstID': roughAssortMstID ?? 0,

    'Srno': srno ?? 0,

    'PurityCode': purityCode ?? 0,

    'Pc': pc ?? 0,

    'Wt': wt ?? 0,

    'RateDollar': rateDollar ?? 0,

    'AmtDollar': amtDollar ?? 0,

    'PurityGroupCode': purityGroupCode ?? 0,

    'Per': per ?? 0,

    'ExRate': exRate ?? 0,

    'RateRs': rateRs ?? 0,

    'AmtRs': amtRs ?? 0,

    'LabRateD': labRateD ?? 0,

    'LabAmtD': labAmtD ?? 0,

    'LabRateRs': labRateRs ?? 0,

    'LabAmtRs': labAmtRs ?? 0,

    'TotRateD': totRateD ?? 0,

    'TotAmtD': totAmtD ?? 0,

    'TotRateRs': totRateRs ?? 0,

    'TotAmtRs': totAmtRs ?? 0,
  };

  static double? _d(dynamic v) {
    if (v == null) return 0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString());
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  toTableRow extension  (ErpDataTable ke liye)
// ─────────────────────────────────────────────────────────────────────────────
extension RoughAssortModelExt on RoughAssortModel {
  Map<String, dynamic> toTableRow() => {
    'roughAssortMstID': roughAssortMstID,
    'roughAssortDate': roughAssortDate ?? '',
    'jno': jno?.toString() ?? '',
    'kapanNo': kapanNo ?? '',
    'remarks': remarks ?? '',
    'pcID': pcID ?? '',
    'ever': ever?.toString() ?? '',
    '_raw': this,
  };
}
