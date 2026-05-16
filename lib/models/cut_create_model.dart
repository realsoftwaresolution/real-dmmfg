// lib/models/cut_create_model.dart

class CutCreateModel {
  final int?    cutCreateMstID;
  final String? cutCreateDate;
  final int?    jno;
  final String? kapanNo;
  final String? sflag;
  final String? sdate;
  final int?    logID;
  final String? pcID;
  final int?    ever;
  final int?    roughAssortDetID;
  final double? totalWtDb;  // ✅ DB se
  final int?    totalPcDb;
  final List<CutCreateDetModel> details;

  CutCreateModel({
    this.cutCreateMstID,
    this.cutCreateDate,
    this.jno,
    this.kapanNo,
    this.sflag,
    this.sdate,
    this.logID,
    this.pcID,
    this.ever,
    this.totalWtDb,
  this.totalPcDb,
    this.roughAssortDetID,
    this.details = const [],
  });
  double get totalWt => totalWtDb ?? details.fold(0.0, (s, d) => s + (d.wt ?? 0));
  int    get totalPc => totalPcDb ?? details.fold(0,   (s, d) => s + (d.pc ?? 0));
  factory CutCreateModel.fromJson(Map<String, dynamic> json) => CutCreateModel(
    cutCreateMstID:   json['CutCreateMstID'],
    // ✅ FIX 1: Date — "2026-03-12T00:00:00.000Z" ya "2026-03-12" dono handle karo
    cutCreateDate:    _parseDateOnly(json['CutCreateDate']),
    jno:              json['Jno'],
    kapanNo:          json['KapanNo'],
    sflag:            json['Sflag'],
    sdate:            json['Sdate'],
    logID:            json['LogID'],
    pcID:             json['PcID'],
    ever:             json['Ever'],
    totalWtDb: json['TotalWt'] != null
        ? double.tryParse(json['TotalWt'].toString())
        : null,
    totalPcDb: json['TotalPc'] != null
        ? (json['TotalPc'] as num).toInt()
        : null,
    roughAssortDetID: json['RoughAssortDetID'],
    details: (json['details'] as List? ?? [])
        .map((e) => CutCreateDetModel.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  // ── Date parser: always returns "YYYY-MM-DD" or null ──────────────────────
  // ✅ Total wt/pc of details — used for pending calculation in screen
  // double get totalWt => details.fold(0.0, (s, d) => s + (d.wt ?? 0));
  // int    get totalPc => details.fold(0,   (s, d) => s + (d.pc ?? 0));

  static String? _parseDateOnly(dynamic val) {
    if (val == null) return null;
    final s = val.toString();
    if (s.length >= 10) return s.substring(0, 10); // "YYYY-MM-DD"
    return s;
  }

  Map<String, dynamic> toJson() => {
    'CutCreateDate': cutCreateDate ?? '',
    'Jno': jno ?? 0,
    'KapanNo': kapanNo ?? '',
    'Sflag': sflag ?? '',
    'Ever': ever ?? 1,
    'RoughAssortDetID': roughAssortDetID ?? 0,
  };
}

// ─────────────────────────────────────────────────────────────────────────────
//  Detail Model
// ─────────────────────────────────────────────────────────────────────────────
class CutCreateDetModel {
  final int?    cutCreateDetID;
  final int?    cutCreateMstID;
  final int?    srno;
  final String? cutType;
  final String? kapanNo;
  final String? cutNo;
  final String? clvCut;
  final String? mfgCut;
  final int?    pc;
  final double? wt;
  final double? wtLoss;
  final double? out;
  final int?    colorCode;
  final int?    purityCode;
  final bool?   autoPktCreate;
  final String? finish;
  final int?    lastCrId;
  final String? finishDate;
  final String? cutRec;
  final String? clvFinish;
  final String? clvFinishDate;
  final int?    signer2Code;
  final int?    signer3Code;
  final double? labour;
  final double? comparisionCode;
  final double? rate;
  final int?    urgent;
  final String? purityType;
  final int?    poPc;
  final double? poWt;
  final double? avgRate;
  final double? avgAmt;
  final double? labRate;
  final double? labAmt;
  final double? totAmt;
  final double? totAvg;
  final double? diff;
  final double? pcDiff;
  final int?    roughAssortDetID;
  final int?    charniCode;
  final String? pmFinish;
  final String? pmFinishDate;
  final String? lsFinish;
  final String? lsFinishDate;

  CutCreateDetModel({
    this.cutCreateDetID,
    this.cutCreateMstID,
    this.srno,
    this.cutType,
    this.kapanNo,
    this.cutNo,
    this.clvCut,
    this.mfgCut,
    this.pc,
    this.wt,
    this.wtLoss,
    this.out,
    this.colorCode,
    this.purityCode,
    this.autoPktCreate,
    this.finish,
    this.lastCrId,
    this.finishDate,
    this.cutRec,
    this.clvFinish,
    this.clvFinishDate,
    this.signer2Code,
    this.signer3Code,
    this.labour,
    this.comparisionCode,
    this.rate,
    this.urgent,
    this.purityType,
    this.poPc,
    this.poWt,
    this.avgRate,
    this.avgAmt,
    this.labRate,
    this.labAmt,
    this.totAmt,
    this.totAvg,
    this.diff,
    this.pcDiff,
    this.roughAssortDetID,
    this.charniCode,
    this.pmFinish,
    this.pmFinishDate,
    this.lsFinish,
    this.lsFinishDate,
  });

  factory CutCreateDetModel.fromJson(Map<String, dynamic> json) =>
      CutCreateDetModel(
        cutCreateDetID:   json['CutCreateDetID'],
        cutCreateMstID:   json['CutCreateMstID'],
        srno:             json['Srno'],
        cutType:          json['CutType'],
        kapanNo:          json['KapanNo'],
        cutNo:            json['CutNo'],
        clvCut:           json['ClvCut'],
        mfgCut:           json['MfgCut'],
        pc:               json['Pc'],
        wt:               _d(json['Wt']),
        wtLoss:           _d(json['WtLoss']),
        out:              _d(json['Out']),
        colorCode:        json['ColorCode'],
        purityCode:       json['PurityCode'],
        autoPktCreate:    json['AutoPktCreate'],
        finish:           json['Finish'],
        lastCrId:         json['LastCrId'],
        finishDate:       json['FinishDate'],
        cutRec:           json['CutRec'],
        clvFinish:        json['ClvFinish'],
        clvFinishDate:    json['ClvFinishDate'],
        signer2Code:      json['Signer2Code'],
        signer3Code:      json['Signer3Code'],
        labour:           _d(json['Labour']),
        comparisionCode:  _d(json['ComparisionCode']),
        rate:             _d(json['Rate']),
        urgent:           json['Urgent'],
        purityType:       json['PurityType'],
        poPc:             json['PoPc'],
        poWt:             _d(json['PoWt']),
        avgRate:          _d(json['AvgRate']),
        avgAmt:           _d(json['AvgAmt']),
        labRate:          _d(json['LabRate']),
        labAmt:           _d(json['LabAmt']),
        totAmt:           _d(json['TotAmt']),
        totAvg:           _d(json['TotAvg']),
        diff:             _d(json['Diff']),
        pcDiff:           _d(json['PcDiff']),
        roughAssortDetID: json['RoughAssortDetID'],
        charniCode:       json['CharniCode'],
        pmFinish:         json['PMFinish'],
        pmFinishDate:     json['PMFinishDate'],
        lsFinish:         json['LSFinish'],
        lsFinishDate:     json['LSFinishDate'],
      );

  Map<String, dynamic> toJson() => {
    'CutCreateMstID': cutCreateMstID ?? 0,

    'Srno': srno ?? 0,

    'CutType': cutType ?? '',

    'KapanNo': kapanNo ?? '',

    'CutNo': cutNo ?? '',

    'ClvCut': clvCut ?? '',

    'MfgCut': mfgCut ?? '',

    'Pc': pc ?? 0,

    'Wt': wt ?? 0,

    'WtLoss': wtLoss ?? 0,

    'Out': out ?? 0,

    'ColorCode': colorCode ?? 0,

    'PurityCode': purityCode ?? 0,

    'CharniCode': charniCode ?? 0,

    'AutoPktCreate': autoPktCreate ?? false,

    'Finish': finish ?? '',

    'LastCrId': lastCrId ?? 0,

    'FinishDate': finishDate ?? '',

    'CutRec': cutRec ?? '',

    'ClvFinish': clvFinish ?? '',

    'ClvFinishDate': clvFinishDate ?? '',

    'Signer2Code': signer2Code ?? 0,

    'Signer3Code': signer3Code ?? 0,

    'Labour': labour ?? 0,

    'ComparisionCode': comparisionCode ?? 0,

    'Rate': rate ?? 0,

    'Urgent': urgent ?? 0,

    'PurityType': purityType ?? '',

    'PoPc': poPc ?? 0,

    'PoWt': poWt ?? 0,

    'AvgRate': avgRate ?? 0,

    'AvgAmt': avgAmt ?? 0,

    'LabRate': labRate ?? 0,

    'LabAmt': labAmt ?? 0,

    'TotAmt': totAmt ?? 0,

    'TotAvg': totAvg ?? 0,

    'Diff': diff ?? 0,

    'PcDiff': pcDiff ?? 0,

    'RoughAssortDetID': roughAssortDetID ?? 0,

    'PMFinish': pmFinish ?? '',

    'PMFinishDate': pmFinishDate ?? '',

    'LSFinish': lsFinish ?? '',

    'LSFinishDate': lsFinishDate ?? '',
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
extension CutCreateModelExt on CutCreateModel {
  Map<String, dynamic> toTableRow() => {
    'cutCreateMstID': cutCreateMstID,
    // ✅ FIX 1: "2026-03-12" → ErpDataTable isDate:true se "12/03/2026" dikhayega
    'cutCreateDate':  cutCreateDate ?? '',
    'jno':            jno?.toString() ?? '',
    'kapanNo':        kapanNo         ?? '',
    'totalWt':        totalWt.toStringAsFixed(2),  // ✅
    'totalPc':        totalPc.toString(),
    '_raw': this,
  };
}