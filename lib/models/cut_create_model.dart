// // lib/models/cut_create_model.dart
//
// class CutCreateModel {
//   final int?    cutCreateMstID;
//   final String? cutCreateDate;
//   final int?    jno;
//   final String? kapanNo;
//   final String? sflag;
//   final String? sdate;
//   final int?    logID;
//   final String? pcID;
//   final int?    ever;
//   final int?    roughAssortDetID;
//
//   final List<CutCreateDetModel> details;
//
//   CutCreateModel({
//     this.cutCreateMstID,
//     this.cutCreateDate,
//     this.jno,
//     this.kapanNo,
//     this.sflag,
//     this.sdate,
//     this.logID,
//     this.pcID,
//     this.ever,
//     this.roughAssortDetID,
//     this.details = const [],
//   });
//
//   factory CutCreateModel.fromJson(Map<String, dynamic> json) => CutCreateModel(
//     cutCreateMstID:   json['CutCreateMstID'],
//     cutCreateDate:    json['CutCreateDate'],
//     jno:              json['Jno'],
//     kapanNo:          json['KapanNo'],
//     sflag:            json['Sflag'],
//     sdate:            json['Sdate'],
//     logID:            json['LogID'],
//     pcID:             json['PcID'],
//     ever:             json['Ever'],
//     roughAssortDetID: json['RoughAssortDetID'],
//     details: (json['details'] as List? ?? [])
//         .map((e) => CutCreateDetModel.fromJson(e))
//         .toList(),
//   );
//
//   Map<String, dynamic> toJson() => {
//     'CutCreateDate':    cutCreateDate,
//     'Jno':              jno,
//     'KapanNo':          kapanNo,
//     'Sflag':            sflag,
//     'Sdate':            sdate,
//     'LogID':            logID,
//     'PcID':             pcID,
//     'Ever':             ever,
//     'RoughAssortDetID': roughAssortDetID,
//   };
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// //  Detail Model
// // ─────────────────────────────────────────────────────────────────────────────
// class CutCreateDetModel {
//   final int?    cutCreateDetID;
//   final int?    cutCreateMstID;
//   final int?    srno;
//   final String? cutType;
//   final String? kapanNo;
//   final String? cutNo;
//   final String? clvCut;
//   final String? mfgCut;
//   final int?    pc;
//   final double? wt;
//   final double? wtLoss;
//   final double? out;
//   final int?    colorCode;
//   final int?    purityCode;
//   final bool?   autoPktCreate;
//   final String? finish;
//   final int?    lastCrId;
//   final String? finishDate;
//   final String? cutRec;
//   final String? clvFinish;
//   final String? clvFinishDate;
//   final int?    signer2Code;
//   final int?    signer3Code;
//   final double? labour;
//   final double? comparisionCode;
//   final double? rate;
//   final int?    urgent;
//   final String? purityType;
//   final int?    poPc;
//   final double? poWt;
//   final double? avgRate;
//   final double? avgAmt;
//   final double? labRate;
//   final double? labAmt;
//   final double? totAmt;
//   final double? totAvg;
//   final double? diff;
//   final double? pcDiff;
//   final int?    roughAssortDetID;
//   final int?    charniCode;
//   final String? pmFinish;
//   final String? pmFinishDate;
//   final String? lsFinish;
//   final String? lsFinishDate;
//
//   CutCreateDetModel({
//     this.cutCreateDetID,
//     this.cutCreateMstID,
//     this.srno,
//     this.cutType,
//     this.kapanNo,
//     this.cutNo,
//     this.clvCut,
//     this.mfgCut,
//     this.pc,
//     this.wt,
//     this.wtLoss,
//     this.out,
//     this.colorCode,
//     this.purityCode,
//     this.autoPktCreate,
//     this.finish,
//     this.lastCrId,
//     this.finishDate,
//     this.cutRec,
//     this.clvFinish,
//     this.clvFinishDate,
//     this.signer2Code,
//     this.signer3Code,
//     this.labour,
//     this.comparisionCode,
//     this.rate,
//     this.urgent,
//     this.purityType,
//     this.poPc,
//     this.poWt,
//     this.avgRate,
//     this.avgAmt,
//     this.labRate,
//     this.labAmt,
//     this.totAmt,
//     this.totAvg,
//     this.diff,
//     this.pcDiff,
//     this.roughAssortDetID,
//     this.charniCode,
//     this.pmFinish,
//     this.pmFinishDate,
//     this.lsFinish,
//     this.lsFinishDate,
//   });
//
//   factory CutCreateDetModel.fromJson(Map<String, dynamic> json) =>
//       CutCreateDetModel(
//         cutCreateDetID:   json['CutCreateDetID'],
//         cutCreateMstID:   json['CutCreateMstID'],
//         srno:             json['Srno'],
//         cutType:          json['CutType'],
//         kapanNo:          json['KapanNo'],
//         cutNo:            json['CutNo'],
//         clvCut:           json['ClvCut'],
//         mfgCut:           json['MfgCut'],
//         pc:               json['Pc'],
//         wt:               _d(json['Wt']),
//         wtLoss:           _d(json['WtLoss']),
//         out:              _d(json['Out']),
//         colorCode:        json['ColorCode'],
//         purityCode:       json['PurityCode'],
//         autoPktCreate:    json['AutoPktCreate'],
//         finish:           json['Finish'],
//         lastCrId:         json['LastCrId'],
//         finishDate:       json['FinishDate'],
//         cutRec:           json['CutRec'],
//         clvFinish:        json['ClvFinish'],
//         clvFinishDate:    json['ClvFinishDate'],
//         signer2Code:      json['Signer2Code'],
//         signer3Code:      json['Signer3Code'],
//         labour:           _d(json['Labour']),
//         comparisionCode:  _d(json['ComparisionCode']),
//         rate:             _d(json['Rate']),
//         urgent:           json['Urgent'],
//         purityType:       json['PurityType'],
//         poPc:             json['PoPc'],
//         poWt:             _d(json['PoWt']),
//         avgRate:          _d(json['AvgRate']),
//         avgAmt:           _d(json['AvgAmt']),
//         labRate:          _d(json['LabRate']),
//         labAmt:           _d(json['LabAmt']),
//         totAmt:           _d(json['TotAmt']),
//         totAvg:           _d(json['TotAvg']),
//         diff:             _d(json['Diff']),
//         pcDiff:           _d(json['PcDiff']),
//         roughAssortDetID: json['RoughAssortDetID'],
//         charniCode:       json['CharniCode'],
//         pmFinish:         json['PMFinish'],
//         pmFinishDate:     json['PMFinishDate'],
//         lsFinish:         json['LSFinish'],
//         lsFinishDate:     json['LSFinishDate'],
//       );
//
//   Map<String, dynamic> toJson() => {
//     'CutCreateMstID':   cutCreateMstID,
//     'Srno':             srno,
//     'CutType':          cutType,
//     'KapanNo':          kapanNo,
//     'CutNo':            cutNo,
//     'ClvCut':           clvCut,
//     'MfgCut':           mfgCut,
//     'Pc':               pc,
//     'Wt':               wt,
//     'WtLoss':           wtLoss,
//     'Out':              out,
//     'ColorCode':        colorCode,
//     'PurityCode':       purityCode,
//     'AutoPktCreate':    autoPktCreate,
//     'Finish':           finish,
//     'LastCrId':         lastCrId,
//     'FinishDate':       finishDate,
//     'CutRec':           cutRec,
//     'ClvFinish':        clvFinish,
//     'ClvFinishDate':    clvFinishDate,
//     'Signer2Code':      signer2Code,
//     'Signer3Code':      signer3Code,
//     'Labour':           labour,
//     'ComparisionCode':  comparisionCode,
//     'Rate':             rate,
//     'Urgent':           urgent,
//     'PurityType':       purityType,
//     'PoPc':             poPc,
//     'PoWt':             poWt,
//     'AvgRate':          avgRate,
//     'AvgAmt':           avgAmt,
//     'LabRate':          labRate,
//     'LabAmt':           labAmt,
//     'TotAmt':           totAmt,
//     'TotAvg':           totAvg,
//     'Diff':             diff,
//     'PcDiff':           pcDiff,
//     'RoughAssortDetID': roughAssortDetID,
//     'CharniCode':       charniCode,
//     'PMFinish':         pmFinish,
//     'PMFinishDate':     pmFinishDate,
//     'LSFinish':         lsFinish,
//     'LSFinishDate':     lsFinishDate,
//   };
//
//   static double? _d(dynamic v) {
//     if (v == null) return null;
//     if (v is double) return v;
//     if (v is int) return v.toDouble();
//     return double.tryParse(v.toString());
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// //  toTableRow extension  (ErpDataTable ke liye)
// // ─────────────────────────────────────────────────────────────────────────────
// extension CutCreateModelExt on CutCreateModel {
//   Map<String, dynamic> toTableRow() => {
//     'cutCreateMstID': cutCreateMstID,
//     'cutCreateDate':  cutCreateDate  ?? '',
//     'jno':            jno?.toString() ?? '',
//     'kapanNo':        kapanNo         ?? '',
//     'pcID':           pcID            ?? '',
//     'ever':           ever?.toString() ?? '',
//     '_raw': this,
//   };
// }
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
    'CutCreateDate':    cutCreateDate,
    'Jno':              jno,
    'KapanNo':          kapanNo,
    'Sflag':            sflag,
    'Sdate':            sdate,
    'LogID':            logID,
    'PcID':             pcID,
    'Ever':             ever,
    'RoughAssortDetID': roughAssortDetID,
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
    'CutCreateMstID':   cutCreateMstID,
    'Srno':             srno,
    'CutType':          cutType,
    'KapanNo':          kapanNo,
    'CutNo':            cutNo,
    if(clvCut != null)'ClvCut':           clvCut,
    if(mfgCut != null)'MfgCut':           mfgCut,
    'Pc':               pc,
    'Wt':               wt,
    if(wtLoss != null)'WtLoss':           wtLoss,
    if(out != null)'Out':              out,
    'ColorCode':  (colorCode  == null || colorCode  == 0) ? null : colorCode,
    'PurityCode': (purityCode == null || purityCode == 0) ? null : purityCode,
    'CharniCode': (charniCode == null || charniCode == 0) ? null : charniCode,
    if(autoPktCreate != null)'AutoPktCreate':    autoPktCreate,
    if(finish != null)'Finish':           finish,
    if(lastCrId != null)'LastCrId':         lastCrId,
    if(finishDate != null)'FinishDate':       finishDate,
    if(cutRec != null)'CutRec':           cutRec,
    if(clvFinish != null)'ClvFinish':        clvFinish,
    if(clvFinishDate != null)'ClvFinishDate':    clvFinishDate,
    if(signer2Code != null)'Signer2Code':      signer2Code,
    if(signer3Code != null)'Signer3Code':      signer3Code,
    if(labour != null)'Labour':           labour,
    'ComparisionCode':  comparisionCode,
    if(rate != null)'Rate':             rate,
    if(urgent != null)'Urgent':           urgent,
    if(purityType != null)'PurityType':       purityType,
    if(poPc != null)'PoPc':             poPc,
    if(poWt != null)'PoWt':             poWt,
    if(avgRate != null)'AvgRate':          avgRate,
    if(avgAmt != null)'AvgAmt':           avgAmt,
    if(labRate != null)'LabRate':          labRate,
    if(labAmt != null)'LabAmt':           labAmt,
    if(totAmt != null)'TotAmt':           totAmt,
    if(totAvg != null)'TotAvg':           totAvg,
    if(diff != null)'Diff':             diff,
    if(pcDiff != null)'PcDiff':           pcDiff,
    if(roughAssortDetID != null)'RoughAssortDetID': roughAssortDetID,
    if(pmFinish != null)'PMFinish':         pmFinish,
    if(pmFinishDate != null)'PMFinishDate':     pmFinishDate,
    if(lsFinish != null)'LSFinish':         lsFinish,
    if(lsFinishDate != null)'LSFinishDate':     lsFinishDate,
  };

  static double? _d(dynamic v) {
    if (v == null) return null;
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