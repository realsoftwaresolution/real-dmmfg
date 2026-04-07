// // lib/models/spk_dept_iss_model.dart
//
// class SpkDeptIssMstModel {
//   final int?    spkDeptIssMstID;
//   final String? spkDeptIssDate;
//   final int?    fromCrID;
//   final int?    toCrID;
//   final int?    deptProcessCode;
//   final int?    deptCode;
//   final String? sflag;
//   final String? sdate;
//   final String? stime;
//   final int?    logID;
//   final String? pcID;
//   final int?    ever;
//   final String? entryType;
//   final String? repairing;
//   final String? formType;
//   final String? proType;
//   final String? formType1;
//   final int?    nukCrId;
//   final String? planType;
//
//   final List<SpkDeptIssDetModel> details;
//
//   // ── totals from DB ─────────────────────────────────────────────────────────
//   final double? totalWtDb;
//   final int?    totalPcDb;
//
//   double get totalWt => totalWtDb ?? details.fold(0.0, (s, d) => s + (d.wt ?? 0));
//   int    get totalPc => totalPcDb ?? details.fold(0,   (s, d) => s + (d.pc ?? 0));
//
//   const SpkDeptIssMstModel({
//     this.spkDeptIssMstID,
//     this.spkDeptIssDate,
//     this.fromCrID,
//     this.toCrID,
//     this.deptProcessCode,
//     this.deptCode,
//     this.sflag,
//     this.sdate,
//     this.stime,
//     this.logID,
//     this.pcID,
//     this.ever,
//     this.entryType,
//     this.repairing,
//     this.formType,
//     this.proType,
//     this.formType1,
//     this.nukCrId,
//     this.planType,
//     this.details = const [],
//     this.totalWtDb,
//     this.totalPcDb,
//   });
//
//   factory SpkDeptIssMstModel.fromJson(Map<String, dynamic> json) =>
//       SpkDeptIssMstModel(
//         spkDeptIssMstID: json['SPKDeptIssMstID'],
//         spkDeptIssDate:  _dateOnly(json['SPKDeptIssDate']),
//         fromCrID:        json['FromCrID'],
//         toCrID:          json['ToCrID'],
//         deptProcessCode: json['DeptProcessCode'],
//         deptCode:        json['DeptCode'],
//         sflag:           json['Sflag'],
//         sdate:           _dateOnly(json['Sdate']),
//         stime:           json['Stime'],
//         logID:           json['LogID'],
//         pcID:            json['PcID'],
//         ever:            json['Ever'],
//         entryType:       json['EntryType'],
//         repairing:       json['Repairing'],
//         formType:        json['FormType'],
//         proType:         json['ProType'],
//         formType1:       json['FormType1'],
//         nukCrId:         json['NukCrId'],
//         planType:        json['PlanType'],
//         totalWtDb: json['TotalWt'] != null
//             ? double.tryParse(json['TotalWt'].toString())
//             : null,
//         totalPcDb: json['TotalPc'] != null
//             ? (json['TotalPc'] as num).toInt()
//             : null,
//         details: (json['details'] as List? ?? [])
//             .map((e) => SpkDeptIssDetModel.fromJson(e as Map<String, dynamic>))
//             .toList(),
//       );
//
//   Map<String, dynamic> toJson() => {
//     'SPKDeptIssDate':  spkDeptIssDate,
//     'FromCrID':        fromCrID,
//     'ToCrID':          toCrID,
//     'DeptProcessCode': deptProcessCode,
//     'DeptCode':        deptCode,
//     'Sflag':           sflag,
//     'Sdate':           sdate,
//     'Stime':           stime,
//     'LogID':           logID,
//     'PcID':            pcID,
//     'Ever':            ever,
//     'EntryType':       entryType,
//     'Repairing':       repairing,
//     'FormType':        formType,
//     'ProType':         proType,
//     'FormType1':       formType1,
//     'NukCrId':         nukCrId,
//     'PlanType':        planType,
//   };
//
//   static String? _dateOnly(dynamic v) {
//     if (v == null) return null;
//     final s = v.toString();
//     return s.length >= 10 ? s.substring(0, 10) : s;
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// //  SpkDeptIssDetModel
// // ─────────────────────────────────────────────────────────────────────────────
// class SpkDeptIssDetModel {
//   final int?    spkDeptIssDetID;
//   final int?    spkDeptIssMstID;
//   final int?    srno;
//   final int?    id;
//   final int?    jno;
//   final String? bCode;
//   final String? pktNo;
//   final String? cutNo;
//   final int?    pc;
//   final double? wt;
//   final int?    issPc;
//   final double? issWt;
//   final int?    recPc;
//   final double? recWt;
//   final double? totalPc;
//   final double? totalWt;
//   final int?    employeeCode;
//   final int?    remarksCode;
//   final String? entryType;
//   final double? size;
//   final int?    shapeCode;
//   final int?    cutCode;
//   final int?    purityCode;
//   final int?    colorCode;
//   final double? rate;
//   final double? amount;
//
//   const SpkDeptIssDetModel({
//     this.spkDeptIssDetID,
//     this.spkDeptIssMstID,
//     this.srno,
//     this.id,
//     this.jno,
//     this.bCode,
//     this.pktNo,
//     this.cutNo,
//     this.pc,
//     this.wt,
//     this.issPc,
//     this.issWt,
//     this.recPc,
//     this.recWt,
//     this.totalPc,
//     this.totalWt,
//     this.employeeCode,
//     this.remarksCode,
//     this.entryType,
//     this.size,
//     this.shapeCode,
//     this.cutCode,
//     this.purityCode,
//     this.colorCode,
//     this.rate,
//     this.amount,
//   });
//
//   factory SpkDeptIssDetModel.fromJson(Map<String, dynamic> json) =>
//       SpkDeptIssDetModel(
//         spkDeptIssDetID: json['SPKDeptIssDetID'],
//         spkDeptIssMstID: json['SPKDeptIssMstID'],
//         srno:            json['Srno'],
//         id:              json['ID'],
//         jno:             json['Jno'],
//         bCode:           json['BCode']?.toString(),
//         pktNo:           json['PktNo'],
//         cutNo:           json['CutNo'],
//         pc:              json['Pc'],
//         wt:              _d(json['Wt']),
//         issPc:           json['IssPc'],
//         issWt:           _d(json['IssWt']),
//         recPc:           json['RecPc'],
//         recWt:           _d(json['RecWt']),
//         totalPc:         _d(json['TotalPc']),
//         totalWt:         _d(json['TotalWt']),
//         employeeCode:    json['EmployeeCode'],
//         remarksCode:     json['RemarksCode'],
//         entryType:       json['EntryType'],
//         size:            _d(json['Size']),
//         shapeCode:       json['ShapeCode'],
//         cutCode:         json['CutCode'],
//         purityCode:      json['PurityCode'],
//         colorCode:       json['ColorCode'],
//         rate:            _d(json['Rate']),
//         amount:          _d(json['Amount']),
//       );
//
//   // Map<String, dynamic> toJson() => {
//   //   'SPKDeptIssMstID': spkDeptIssMstID,
//   //   'Srno':            srno,
//   //   'ID':              id,
//   //   'Jno':             jno,
//   //   'BCode':           bCode,
//   //   'PktNo':           pktNo,
//   //   'CutNo':           cutNo,
//   //   'Pc':              pc,
//   //   'Wt':              wt,
//   //   'IssPc':           issPc,
//   //   'IssWt':           issWt,
//   //   'RecPc':           recPc,
//   //   'RecWt':           recWt,
//   //   'EmployeeCode':    employeeCode,
//   //   'RemarksCode':     remarksCode,
//   //   'EntryType':       entryType,
//   //   'Size':            size,
//   //   'ShapeCode':       shapeCode,
//   //   'CutCode':         cutCode,
//   //   'PurityCode':      purityCode,
//   //   'ColorCode':       colorCode,
//   //   'Rate':            rate,
//   //   'Amount':          amount,
//   // };
//   Map<String, dynamic> toJson() => {
//     'SPKDeptIssMstID': spkDeptIssMstID,
//     'Srno':            srno,
//     'ID':              id,
//     'Jno':             jno,
//     'BCode':           bCode,
//     'PktNo':           pktNo,
//     'CutNo':           cutNo,
//     'Pc':              pc,
//     'Wt':              wt,
//     'IssPc':           issPc,
//     'IssWt':           issWt,
//     'RecPc':           recPc,
//     'RecWt':           recWt,
//     'EmployeeCode': (employeeCode == null || employeeCode == 0) ? null : employeeCode,
//     'RemarksCode':  (remarksCode  == null || remarksCode  == 0) ? null : remarksCode,
//     'EntryType':       entryType,
//     if (size       != null) 'Size':      size,
//     if (shapeCode  != null) 'ShapeCode': shapeCode,
//     if (cutCode    != null) 'CutCode':   cutCode,
//     if (purityCode != null) 'PurityCode': purityCode,
//     if (colorCode  != null) 'ColorCode':  colorCode,
//     if (rate       != null) 'Rate':       rate,
//     if (amount     != null) 'Amount':     amount,
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
// //  toTableRow extension
// // ─────────────────────────────────────────────────────────────────────────────
// extension SpkDeptIssMstExt on SpkDeptIssMstModel {
//   Map<String, dynamic> toTableRow() => {
//     'spkDeptIssMstID': spkDeptIssMstID,
//     'spkDeptIssDate':  spkDeptIssDate ?? '',
//     'fromCrID':        fromCrID?.toString() ?? '',
//     'toCrID':          toCrID?.toString() ?? '',
//     'deptProcessCode': deptProcessCode?.toString() ?? '',
//     'entryType':       entryType ?? '',
//     'totalPc':         totalPc.toString(),
//     'totalWt':         totalWt.toStringAsFixed(3),
//     '_raw': this,
//   };
// }

// lib/models/spk_dept_iss_model.dart

class SpkDeptIssMstModel {
  final int?    spkDeptIssMstID;
  final String? spkDeptIssDate;
  final int?    fromCrID;
  final int?    toCrID;
  final int?    deptProcessCode;
  final int?    deptCode;
  final String? sflag;
  final String? sdate;
  final String? stime;
  final int?    logID;
  final String? pcID;
  final int?    ever;
  final String? entryType;
  final String? repairing;
  final String? formType;
  final String? proType;
  final String? formType1;
  final int?    nukCrId;
  final String? planType;

  final List<SpkDeptIssDetModel> details;

  // ── totals from DB ─────────────────────────────────────────────────────────
  final double? totalWtDb;
  final int?    totalPcDb;
  // Fields mein add karo (existing fields ke baad):
  final int?    totPkt;
  final String? users;
  final int?    jnoFirst;
  final int?    bCode;

  // Replace karo:
  double get totalWt => totalWtDb ?? details.fold(0.0, (s, d) => s + (d.totalWt ?? 0));
  int    get totalPc => totalPcDb ?? details.fold(0,   (s, d) => s + (d.totalPc ?? 0));

  const SpkDeptIssMstModel({
    this.spkDeptIssMstID,
    this.spkDeptIssDate,
    this.fromCrID,
    this.toCrID,
    this.deptProcessCode,
    this.deptCode,
    this.sflag,
    this.sdate,
    this.totPkt,
    this.users,
    this.jnoFirst,
    this.stime,
    this.logID,
    this.pcID,
    this.ever,
    this.entryType,
    this.repairing,
    this.formType,
    this.proType,
    this.formType1,
    this.nukCrId,
    this.planType,
    this.details = const [],
    this.totalWtDb,
    this.totalPcDb,
    this.bCode,
  });

  factory SpkDeptIssMstModel.fromJson(Map<String, dynamic> json) =>
      SpkDeptIssMstModel(
        spkDeptIssMstID: json['SPKDeptIssMstID'],
        spkDeptIssDate:  _dateOnly(json['SPKDeptIssDate']),
        fromCrID:        json['FromCrID'],
        toCrID:          json['ToCrID'],
        deptProcessCode: json['DeptProcessCode'],
        deptCode:        json['DeptCode'],
        sflag:           json['Sflag'],
        sdate:           _dateOnly(json['Sdate']),
        stime:           json['Stime'],
        logID:           json['LogID'],
        pcID:            json['PcID'],
        ever:            json['Ever'],
        entryType:       json['EntryType'],
        repairing:       json['Repairing'],
        formType:        json['FormType'],
        proType:         json['ProType'],
        formType1:       json['FormType1'],
        nukCrId:         json['NukCrId'],
        planType:        json['PlanType'],
        bCode:        json['BCode'],
        totPkt:   json['TotPkt']  != null ? (json['TotPkt']  as num).toInt() : null,
        users:    json['Users']?.toString(),
        jnoFirst: json['Jno']     != null ? (json['Jno']     as num).toInt() : null,
        totalWtDb: json['TotalWt'] != null
            ? double.tryParse(json['TotalWt'].toString())
            : null,
        totalPcDb: json['TotalPc'] != null
            ? (json['TotalPc'] as num).toInt()
            : null,
        details: (json['details'] as List? ?? [])
            .map((e) => SpkDeptIssDetModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
    'SPKDeptIssDate':  spkDeptIssDate,
    'FromCrID':        fromCrID,
    'ToCrID':          toCrID,
    'DeptProcessCode': deptProcessCode,
    'DeptCode':        deptCode,
    'Sflag':           sflag,
    'Sdate':           sdate,
    'Stime':           stime,
    'LogID':           logID,
    'PcID':            pcID,
    'Ever':            ever,
    'EntryType':       entryType,
    'Repairing':       repairing,
    'FormType':        formType,
    'ProType':         proType,
    'FormType1':       formType1,
    'NukCrId':         nukCrId,
    'PlanType':        planType,
    'BCode':        bCode,
  };

  static String? _dateOnly(dynamic v) {
    if (v == null) return null;
    final s = v.toString();
    return s.length >= 10 ? s.substring(0, 10) : s;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SpkDeptIssDetModel
// ─────────────────────────────────────────────────────────────────────────────
class SpkDeptIssDetModel {
  final int?    spkDeptIssDetID;
  final int?    spkDeptIssMstID;
  final int?    srno;
  final int?    id;
  final int?    jno;
  final String? bCode;
  final String? pktNo;
  final int? fromDeptCode;  // ← ADD
  final int? toDeptCode;
  final String? cutNo;
  final String? clvCut;
  final int?    pc;
  final double? wt;
  final int?    issPc;
  final double? issWt;
  final int?    recPc;
  final double? recWt;
  final double? dmWt;
  final double? dmPer;
  final int?    kPc;
  final double? kWt;
  final int?    brPc;
  final double? brWt;
  final int?    lossPc;
  final double? lossWt;
  final double? lossPer;
  final int?    topsPc;
  final double? topsWt;
  final int?    totalPc;       // NOT NULL in DB
  final double? totalWt;
  final int?    employeeCode;  // FK → Mst_Employee
  final int?    signerCode;
  final int?    remarksCode;   // FK → Mst_Remarks
  final int?    dueDay;
  final String? confDate;
  final String? confTime;
  final int?    confLogID;
  final String? confPcID;
  final int?    confEver;
  final int?    confCrID;
  final String? confRec;
  final String? recDate;
  final String? recTime;
  final int?    lastDetID;
  final String? entryType;
  final String? kachaRec;
  final bool?   subPktCreate;
  final int?    spkPlanningDetID;
  final String? pktType;
  final String? formType;
  final String? clvRec;
  final double? size;
  final int?    jnoRecPc;
  final int?    partName;
  final int?    shapeCode;
  final int?    cutCode;
  final int?    purityCode;
  final int?    colorCode;
  final double? diam;
  final double? acuraecy;
  final double? amt;
  final bool?   manualAuto;
  final String? qrCode;
  final int?    checkerCrId;
  final int?    signerCrId;
  final double? plDmWt;
  final double? plDmPer;
  final double? diffDmWt;
  final int?    charniCode;
  final double? mackRoughWt;
  final double? rateRs;
  final double? amountRs;
  final String? rateID;
  final String? rateon;
  final double? rate;
  final double? amount;
  final double? ratio;
  final String? pcName;
  final String? machineSrNo;
  final String? userName;
  final double? crHeightMM;
  final double? crHeightPer;
  final double? crAng;
  final double? totDepthMM;
  final double? totDepthPer;
  final double? pavDepthMM;
  final double? pavDepthPer;
  final double? pavAng;
  final double? gridleMM;
  final double? gridlePer;
  final double? tableMM;
  final double? tablePer;
  final int?    tilt;
  final String? stoneNo;
  final int?    nukDeptCode;
  final String? nukRemarks;
  final int?    diffRgPc;
  final double? diffRgWt;
  final double? diffPoWt;
  final double? diffAmt;
  final String? remarks;
  final int?    oldDeptIssMstID;
  final int?    nukTopPc;
  final double? nukTopWt;
  final double? nukAmt;
  final int?    oldShapeCode;
  final int?    oldColorCode;
  final int?    oldPurityCode;
  final int?    jobJno;
  final int?    jobBCode;
  final String? rRateID;
  final String? rRateon;
  final double? rRate;
  final double? rAmount;
  final String? fType;
  final String? pktValid;
  final int? fromCrId;
  final int? toCrId;
  final int? deptProcessCode;
  final String? inValidReason;
  final bool?   highLightEntry;
  final int?    tensionsCode;
  final int?    planSignerCrID;
  final String? sarinOpt;
  final String? sarinMachine;
  final String? optDate;
  final String? optStartTime;
  final String? optEndTime;
  final String? optDiffTime;
  final int?    optEmpCode;
  final double? tableDiam;
  final double? dmDiam;
  final String? optRateOn;
  final String? optRateID;
  final double? optRate;
  final double? optAmount;
  final double? lsAmount;
  final int?    orderMstID;
  final List<Map<String, dynamic>>? sarinData;

  const SpkDeptIssDetModel({
    this.spkDeptIssDetID,
    this.spkDeptIssMstID,
    this.srno,
    this.id,
    this.jno,
    this.bCode,
    this.pktNo,
    this.cutNo,
    this.clvCut,
    this.fromDeptCode,
    this.toDeptCode,
    this.pc,
    this.fromCrId,
    this.toCrId,
    this.deptProcessCode,
    this.wt,
    this.issPc,
    this.issWt,
    this.recPc,
    this.recWt,
    this.dmWt,
    this.dmPer,
    this.kPc,
    this.kWt,
    this.brPc,
    this.brWt,
    this.lossPc,
    this.lossWt,
    this.lossPer,
    this.topsPc,
    this.topsWt,
    this.totalPc,
    this.totalWt,
    this.employeeCode,
    this.signerCode,
    this.remarksCode,
    this.dueDay,
    this.confDate,
    this.confTime,
    this.confLogID,
    this.confPcID,
    this.confEver,
    this.confCrID,
    this.confRec,
    this.recDate,
    this.recTime,
    this.lastDetID,
    this.entryType,
    this.kachaRec,
    this.subPktCreate,
    this.spkPlanningDetID,
    this.pktType,
    this.formType,
    this.clvRec,
    this.size,
    this.jnoRecPc,
    this.partName,
    this.shapeCode,
    this.cutCode,
    this.purityCode,
    this.colorCode,
    this.diam,
    this.acuraecy,
    this.amt,
    this.manualAuto,
    this.qrCode,
    this.checkerCrId,
    this.signerCrId,
    this.plDmWt,
    this.plDmPer,
    this.diffDmWt,
    this.charniCode,
    this.mackRoughWt,
    this.rateRs,
    this.amountRs,
    this.rateID,
    this.rateon,
    this.rate,
    this.amount,
    this.ratio,
    this.pcName,
    this.machineSrNo,
    this.userName,
    this.crHeightMM,
    this.crHeightPer,
    this.crAng,
    this.totDepthMM,
    this.totDepthPer,
    this.pavDepthMM,
    this.pavDepthPer,
    this.pavAng,
    this.gridleMM,
    this.gridlePer,
    this.tableMM,
    this.tablePer,
    this.tilt,
    this.stoneNo,
    this.nukDeptCode,
    this.nukRemarks,
    this.diffRgPc,
    this.diffRgWt,
    this.diffPoWt,
    this.diffAmt,
    this.remarks,
    this.oldDeptIssMstID,
    this.nukTopPc,
    this.nukTopWt,
    this.nukAmt,
    this.oldShapeCode,
    this.oldColorCode,
    this.oldPurityCode,
    this.jobJno,
    this.jobBCode,
    this.rRateID,
    this.rRateon,
    this.rRate,
    this.rAmount,
    this.fType,
    this.pktValid,
    this.inValidReason,
    this.highLightEntry,
    this.tensionsCode,
    this.planSignerCrID,
    this.sarinOpt,
    this.sarinMachine,
    this.optDate,
    this.optStartTime,
    this.optEndTime,
    this.optDiffTime,
    this.optEmpCode,
    this.tableDiam,
    this.dmDiam,
    this.optRateOn,
    this.optRateID,
    this.optRate,
    this.optAmount,
    this.lsAmount,
    this.orderMstID,
    this.sarinData,
  });

  factory SpkDeptIssDetModel.fromJson(Map<String, dynamic> json) =>
      SpkDeptIssDetModel(
        spkDeptIssDetID:  json['SPKDeptIssDetID'],
        spkDeptIssMstID:  json['SPKDeptIssMstID'],
        srno:             json['Srno'],
        id:               json['ID'],
        fromDeptCode: json['FromDeptCode'],
        toDeptCode:   json['ToDeptCode'],
        jno:              json['Jno'],
        bCode:            json['BCode']?.toString(),
        pktNo:            json['PktNo'],
        cutNo:            json['CutNo'],
        clvCut:           json['ClvCut'],
        fromCrId:        json['FromCrID'],
        toCrId:          json['ToCrID'],
        deptProcessCode: json['DeptProcessCode'],
        pc:               json['Pc'],
        wt:               _d(json['Wt']),
        issPc:            json['IssPc'],
        issWt:            _d(json['IssWt']),
        recPc:            json['RecPc'],
        recWt:            _d(json['RecWt']),
        dmWt:             _d(json['DmWt']),
        dmPer:            _d(json['DmPer']),
        kPc:              json['KPc'],
        kWt:              _d(json['KWt']),
        brPc:             json['BrPc'],
        brWt:             _d(json['BrWt']),
        lossPc:           json['LossPc'],
        lossWt:           _d(json['LossWt']),
        lossPer:          _d(json['LossPer']),
        topsPc:           json['TopsPc'],
        topsWt:           _d(json['TopsWt']),
        totalPc:          json['TotalPc'],
        totalWt:          _d(json['TotalWt']),
        employeeCode:     json['EmployeeCode'],
        signerCode:       json['SignerCode'],
        remarksCode:      json['RemarksCode'],
        dueDay:           json['DueDay'],
        confDate:         json['ConfDate'],
        confTime:         json['ConfTime'],
        confLogID:        json['ConfLogID'],
        confPcID:         json['ConfPcID'],
        confEver:         json['ConfEver'],
        confCrID:         json['ConfCrID'],
        confRec:          json['ConfRec'],
        recDate:          json['RecDate'],
        recTime:          json['RecTime'],
        lastDetID:        json['LastDetID'],
        entryType:        json['EntryType'],
        kachaRec:         json['KachaRec'],
        subPktCreate:     json['SubPktCreate'],
        spkPlanningDetID: json['SPKPlanningDetID'],
        pktType:          json['PktType'],
        formType:         json['FormType'],
        clvRec:           json['CLVRec'],
        size:             _d(json['Size']),
        jnoRecPc:         json['JnoRecPc'],
        partName:         json['PartName'],
        shapeCode:        json['ShapeCode'],
        cutCode:          json['CutCode'],
        purityCode:       json['PurityCode'],
        colorCode:        json['ColorCode'],
        diam:             _d(json['Diam']),
        acuraecy:         _d(json['Acuraecy']),
        amt:              _d(json['Amt']),
        manualAuto:       json['ManualAuto'],
        qrCode:           json['QrCode'],
        checkerCrId:      json['CheckerCrId'],
        signerCrId:       json['SignerCrId'],
        plDmWt:           _d(json['PlDmWt']),
        plDmPer:          _d(json['PlDmPer']),
        diffDmWt:         _d(json['DiffDmWt']),
        charniCode:       json['CharniCode'],
        mackRoughWt:      _d(json['MackRoughWt']),
        rateRs:           _d(json['RateRs']),
        amountRs:         _d(json['AmountRs']),
        rateID:           json['RateID'],
        rateon:           json['Rateon'],
        rate:             _d(json['Rate']),
        amount:           _d(json['Amount']),
        ratio:            _d(json['Ratio']),
        pcName:           json['PcName'],
        machineSrNo:      json['MachineSrNo'],
        userName:         json['UserName'],
        crHeightMM:       _d(json['CrHeightMM']),
        crHeightPer:      _d(json['CrHeightPer']),
        crAng:            _d(json['CrAng']),
        totDepthMM:       _d(json['TotDepthMM']),
        totDepthPer:      _d(json['TotDepthPer']),
        pavDepthMM:       _d(json['PavDepthMM']),
        pavDepthPer:      _d(json['PavDepthPer']),
        pavAng:           _d(json['PavAng']),
        gridleMM:         _d(json['GridleMM']),
        gridlePer:        _d(json['GridlePer']),
        tableMM:          _d(json['TableMM']),
        tablePer:         _d(json['TablePer']),
        tilt:             json['Tilt'],
        stoneNo:          json['StoneNo'],
        nukDeptCode:      json['NukDeptCode'],
        nukRemarks:       json['NukRemarks'],
        diffRgPc:         json['DiffRgPc'],
        diffRgWt:         _d(json['DiffRgWt']),
        diffPoWt:         _d(json['DiffPoWt']),
        diffAmt:          _d(json['DiffAmt']),
        remarks:          json['Remarks'],
        oldDeptIssMstID:  json['OldDeptIssMstID'],
        nukTopPc:         json['NukTopPc'],
        nukTopWt:         _d(json['NukTopWt']),
        nukAmt:           _d(json['NukAmt']),
        oldShapeCode:     json['OldShapeCode'],
        oldColorCode:     json['OldColorCode'],
        oldPurityCode:    json['OldPurityCode'],
        jobJno:           json['JobJno'],
        jobBCode:         json['JobBCode'],
        rRateID:          json['RRateID'],
        rRateon:          json['RRateon'],
        rRate:            _d(json['RRate']),
        rAmount:          _d(json['RAmount']),
        fType:            json['FType'],
        pktValid:         json['PktValid'],
        inValidReason:    json['InValidReason'],
        highLightEntry:   json['HighLightEntry'],
        tensionsCode:     json['TensionsCode'],
        planSignerCrID:   json['PlanSignerCrID'],
        sarinOpt:         json['SarinOpt'],
        sarinMachine:     json['SarinMachine'],
        optDate:          json['OptDate'],
        optStartTime:     json['OptStartTime'],
        optEndTime:       json['OptEndTime'],
        optDiffTime:      json['OptDiffTime'],
        optEmpCode:       json['OptEmpCode'],
        tableDiam:        _d(json['TableDiam']),
        dmDiam:           _d(json['DmDiam']),
        optRateOn:        json['OptRateOn'],
        optRateID:        json['OptRateID'],
        optRate:          _d(json['OptRate']),
        optAmount:        _d(json['OptAmount']),
        lsAmount:         _d(json['LsAmount']),
        orderMstID:       json['OrderMstID'],
        sarinData: (json['sarinData'] as List?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() ?? [],
      );

  Map<String, dynamic> toJson() => {
    // ── Always send ───────────────────────────────────────────────────────────
    'SPKDeptIssMstID':  spkDeptIssMstID,
    'Srno':             srno,
    'ID':               id,
    'Jno':              jno,
    'BCode':            bCode,
    'PktNo':            pktNo,
    'CutNo':            cutNo,
    'ClvCut':           clvCut,
    'Pc':               pc,
    'Wt':               wt,
    'IssPc':            issPc,
    'IssWt':            issWt,
    'RecPc':            recPc,
    'sarinData':            sarinData,
    if (fromDeptCode != null) 'FromDeptCode': fromDeptCode,
    if (toDeptCode   != null) 'ToDeptCode':   toDeptCode,
    'RecWt':            recWt,
    'TotalPc':          totalPc,
    'TotalWt':          totalWt,
    'EntryType':        entryType,
    if (fromCrId        != null) 'FromCrID':        fromCrId,
    if (toCrId          != null) 'ToCrID':          toCrId,
    if (deptProcessCode != null) 'DeptProcessCode': deptProcessCode,

    // ── FK fields — 0 ya null dono null bhejo ────────────────────────────────
    'EmployeeCode': (employeeCode == null || employeeCode == 0) ? null : employeeCode,
    'RemarksCode':  (remarksCode  == null || remarksCode  == 0) ? null : remarksCode,

    // ── DEFAULT value fields — sirf tab bhejo jab value ho ───────────────────
    if (dmWt             != null) 'DmWt':             dmWt,
    if (dmPer            != null) 'DmPer':            dmPer,
    if (kPc              != null) 'KPc':              kPc,
    if (kWt              != null) 'KWt':              kWt,
    if (brPc             != null) 'BrPc':             brPc,
    if (brWt             != null) 'BrWt':             brWt,
    if (lossPc           != null) 'LossPc':           lossPc,
    if (lossWt           != null) 'LossWt':           lossWt,
    if (lossPer          != null) 'LossPer':          lossPer,
    if (topsPc           != null) 'TopsPc':           topsPc,
    if (topsWt           != null) 'TopsWt':           topsWt,
    if (signerCode       != null) 'SignerCode':       signerCode,
    if (dueDay           != null) 'DueDay':           dueDay,
    if (confDate         != null) 'ConfDate':         confDate,
    if (confTime         != null) 'ConfTime':         confTime,
    if (confLogID        != null) 'ConfLogID':        confLogID,
    if (confPcID         != null) 'ConfPcID':         confPcID,
    if (confEver         != null) 'ConfEver':         confEver,
    if (confCrID         != null) 'ConfCrID':         confCrID,
    if (confRec          != null) 'ConfRec':          confRec,
    if (recDate          != null) 'RecDate':          recDate,
    if (recTime          != null) 'RecTime':          recTime,
    if (lastDetID        != null) 'LastDetID':        lastDetID,
    if (kachaRec         != null) 'KachaRec':         kachaRec,
    if (subPktCreate     != null) 'SubPktCreate':     subPktCreate,
    if (spkPlanningDetID != null) 'SPKPlanningDetID': spkPlanningDetID,
    if (pktType          != null) 'PktType':          pktType,
    if (formType         != null) 'FormType':         formType,
    if (clvRec           != null) 'CLVRec':           clvRec,
    if (size             != null) 'Size':             size,
    if (jnoRecPc         != null) 'JnoRecPc':         jnoRecPc,
    if (partName         != null) 'PartName':         partName,
    if (shapeCode        != null) 'ShapeCode':        shapeCode,
    if (cutCode          != null) 'CutCode':          cutCode,
    if (purityCode       != null) 'PurityCode':       purityCode,
    if (colorCode        != null) 'ColorCode':        colorCode,
    if (diam             != null) 'Diam':             diam,
    if (acuraecy         != null) 'Acuraecy':         acuraecy,
    if (amt              != null) 'Amt':              amt,
    if (manualAuto       != null) 'ManualAuto':       manualAuto,
    if (qrCode           != null) 'QrCode':           qrCode,
    if (checkerCrId      != null) 'CheckerCrId':      checkerCrId,
    if (signerCrId       != null) 'SignerCrId':       signerCrId,
    if (plDmWt           != null) 'PlDmWt':           plDmWt,
    if (plDmPer          != null) 'PlDmPer':          plDmPer,
    if (diffDmWt         != null) 'DiffDmWt':         diffDmWt,
    if (charniCode       != null) 'CharniCode':       charniCode,
    if (mackRoughWt      != null) 'MackRoughWt':      mackRoughWt,
    if (rateRs           != null) 'RateRs':           rateRs,
    if (amountRs         != null) 'AmountRs':         amountRs,
    if (rateID           != null) 'RateID':           rateID,
    if (rateon           != null) 'Rateon':           rateon,
    if (rate             != null) 'Rate':             rate,
    if (amount           != null) 'Amount':           amount,
    if (ratio            != null) 'Ratio':            ratio,
    if (pcName           != null) 'PcName':           pcName,
    if (machineSrNo      != null) 'MachineSrNo':      machineSrNo,
    if (userName         != null) 'UserName':         userName,
    if (crHeightMM       != null) 'CrHeightMM':       crHeightMM,
    if (crHeightPer      != null) 'CrHeightPer':      crHeightPer,
    if (crAng            != null) 'CrAng':            crAng,
    if (totDepthMM       != null) 'TotDepthMM':       totDepthMM,
    if (totDepthPer      != null) 'TotDepthPer':      totDepthPer,
    if (pavDepthMM       != null) 'PavDepthMM':       pavDepthMM,
    if (pavDepthPer      != null) 'PavDepthPer':      pavDepthPer,
    if (pavAng           != null) 'PavAng':           pavAng,
    if (gridleMM         != null) 'GridleMM':         gridleMM,
    if (gridlePer        != null) 'GridlePer':        gridlePer,
    if (tableMM          != null) 'TableMM':          tableMM,
    if (tablePer         != null) 'TablePer':         tablePer,
    if (tilt             != null) 'Tilt':             tilt,
    if (stoneNo          != null) 'StoneNo':          stoneNo,
    if (nukDeptCode      != null) 'NukDeptCode':      nukDeptCode,
    if (nukRemarks       != null) 'NukRemarks':       nukRemarks,
    if (diffRgPc         != null) 'DiffRgPc':         diffRgPc,
    if (diffRgWt         != null) 'DiffRgWt':         diffRgWt,
    if (diffPoWt         != null) 'DiffPoWt':         diffPoWt,
    if (diffAmt          != null) 'DiffAmt':          diffAmt,
    if (remarks          != null) 'Remarks':          remarks,
    if (oldDeptIssMstID  != null) 'OldDeptIssMstID':  oldDeptIssMstID,
    if (nukTopPc         != null) 'NukTopPc':         nukTopPc,
    if (nukTopWt         != null) 'NukTopWt':         nukTopWt,
    if (nukAmt           != null) 'NukAmt':           nukAmt,
    if (oldShapeCode     != null) 'OldShapeCode':     oldShapeCode,
    if (oldColorCode     != null) 'OldColorCode':     oldColorCode,
    if (oldPurityCode    != null) 'OldPurityCode':    oldPurityCode,
    if (jobJno           != null) 'JobJno':           jobJno,
    if (jobBCode         != null) 'JobBCode':         jobBCode,
    if (rRateID          != null) 'RRateID':          rRateID,
    if (rRateon          != null) 'RRateon':          rRateon,
    if (rRate            != null) 'RRate':            rRate,
    if (rAmount          != null) 'RAmount':          rAmount,
    if (fType            != null) 'FType':            fType,
    if (pktValid         != null) 'PktValid':         pktValid,
    if (inValidReason    != null) 'InValidReason':    inValidReason,
    if (highLightEntry   != null) 'HighLightEntry':   highLightEntry,
    if (tensionsCode     != null) 'TensionsCode':     tensionsCode,
    if (planSignerCrID   != null) 'PlanSignerCrID':   planSignerCrID,
    if (sarinOpt         != null) 'SarinOpt':         sarinOpt,
    if (sarinMachine     != null) 'SarinMachine':     sarinMachine,
    if (optDate          != null) 'OptDate':          optDate,
    if (optStartTime     != null) 'OptStartTime':     optStartTime,
    if (optEndTime       != null) 'OptEndTime':       optEndTime,
    if (optDiffTime      != null) 'OptDiffTime':      optDiffTime,
    if (optEmpCode       != null) 'OptEmpCode':       optEmpCode,
    if (tableDiam        != null) 'TableDiam':        tableDiam,
    if (dmDiam           != null) 'DmDiam':           dmDiam,
    if (optRateOn        != null) 'OptRateOn':        optRateOn,
    if (optRateID        != null) 'OptRateID':        optRateID,
    if (optRate          != null) 'OptRate':          optRate,
    if (optAmount        != null) 'OptAmount':        optAmount,
    if (lsAmount         != null) 'LsAmount':         lsAmount,
    if (orderMstID       != null) 'OrderMstID':       orderMstID,
  };

  static double? _d(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString());
  }
}
extension SpkDeptIssMstExt on SpkDeptIssMstModel {
  Map<String, dynamic> toTableRow() => {
    'spkDeptIssMstID': spkDeptIssMstID,
    'spkDeptIssDate':  spkDeptIssDate ?? '',
    'fromCrID':        fromCrID?.toString() ?? '',
    'toCrID':          toCrID?.toString() ?? '',
    'deptProcessCode': deptProcessCode?.toString() ?? '',
    'entryType':       entryType ?? '',
    'totalPc':         totalPc.toString(),
    'totalWt':         totalWt.toStringAsFixed(3),
    'totPkt':          (totPkt ?? 0).toString(),   // ← ADD
    'jno':             jnoFirst?.toString() ?? '',  // ← ADD
    'users':           users ?? '',                 // ← ADD
    'spkDeptIssTime':  stime ?? '',                 // ← ADD
    '_raw': this,
  };
}
// ─────────────────────────────────────────────────────────────────────────────
//  toTableRow extension
// ─────────────────────────────────────────────────────────────────────────────
// extension SpkDeptIssMstExt on SpkDeptIssMstModel {
//   Map<String, dynamic> toTableRow() => {
//     'spkDeptIssMstID': spkDeptIssMstID,
//     'spkDeptIssDate':  spkDeptIssDate ?? '',
//     'fromCrID':        fromCrID?.toString() ?? '',
//     'toCrID':          toCrID?.toString() ?? '',
//     'deptProcessCode': deptProcessCode?.toString() ?? '',
//     'entryType':       entryType ?? '',
//     'totalPc':         totalPc.toString(),
//     'totalWt':         totalWt.toStringAsFixed(3),
//     '_raw': this,
//   };
// }