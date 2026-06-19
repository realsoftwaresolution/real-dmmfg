import '../utils/constants.dart';

class ProcessRecMstModel {
  final int? id;
  final String? date;
  final String? time;

  final String? manager;
  final int? crID;

  final dynamic jno;

  final int? totPkt;
  final int? pc;
  final double? wt;

  final int? issPc;
  final double? issWt;

  final int? recPc;
  final double? recWt;

  final double? calcWt;

  final int? kPc;
  final double? kWt;

  final int? brPc;
  final double? brWt;

  final int? lossPc;
  final double? lossWt;

  final double? dmWt;
  final double? dmPer;

  final int? employeeCode;
  final String? employeeName;

  final int? deptCode;
  final String? deptName;

  final int? deptProcessCode;
  final String? deptProcessName;

  const ProcessRecMstModel({
    this.id,
    this.date,
    this.time,
    this.manager,
    this.crID,
    this.jno,
    this.totPkt,
    this.pc,
    this.wt,
    this.issPc,
    this.issWt,
    this.recPc,
    this.recWt,
    this.calcWt,
    this.kPc,
    this.kWt,
    this.brPc,
    this.brWt,
    this.lossPc,
    this.lossWt,
    this.dmWt,
    this.dmPer,
    this.employeeCode,
    this.employeeName,
    this.deptCode,
    this.deptName,
    this.deptProcessCode,
    this.deptProcessName,
  });

  factory ProcessRecMstModel.fromJson(Map<String, dynamic> json) {
    int? toInt(dynamic value) =>
        value == null ? null : int.tryParse(value.toString());

    double? toDouble(dynamic value) =>
        value == null ? null : double.tryParse(value.toString());

    return ProcessRecMstModel(
      id: toInt(json['ID']),
      date: json['Date']?.toString(),
      time: json['Time']?.toString(),

      manager: json['Manager']?.toString(),
      crID: toInt(json['CrID']),

      jno: json['Jno'],

      totPkt: toInt(json['TotPkt']),
      pc: toInt(json['Pc']),
      wt: toDouble(json['Wt']),

      issPc: toInt(json['IssPc']),
      issWt: toDouble(json['IssWt']),

      recPc: toInt(json['RecPc']),
      recWt: toDouble(json['RecWt']),

      calcWt: toDouble(json['CalcWt']),

      kPc: toInt(json['KPc']),
      kWt: toDouble(json['KWt']),

      brPc: toInt(json['BrPc']),
      brWt: toDouble(json['BrWt']),

      lossPc: toInt(json['LossPc']),
      lossWt: toDouble(json['LossWt']),

      dmWt: toDouble(json['DmWt']),
      dmPer: toDouble(json['DmPer']),

      employeeCode: toInt(json['EmployeeCode']),
      employeeName: json['EmployeeName']?.toString(),

      deptCode: toInt(json['DeptCode']),
      deptName: json['DeptName']?.toString(),

      deptProcessCode: toInt(json['DeptProcessCode']),
      deptProcessName: json['DeptProcessName']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'Date': date,
      'Time': time,
      'Manager': manager,
      'CrID': crID,
      'Jno': jno,
      'TotPkt': totPkt,
      'Pc': pc,
      'Wt': wt,
      'IssPc': issPc,
      'IssWt': issWt,
      'RecPc': recPc,
      'RecWt': recWt,
      'CalcWt': calcWt,
      'KPc': kPc,
      'KWt': kWt,
      'BrPc': brPc,
      'BrWt': brWt,
      'LossPc': lossPc,
      'LossWt': lossWt,
      'DmWt': dmWt,
      'DmPer': dmPer,
      'EmployeeCode': employeeCode,
      'EmployeeName': employeeName,
      'DeptCode': deptCode,
      'DeptName': deptName,
      'DeptProcessCode': deptProcessCode,
      'DeptProcessName': deptProcessName,
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  ProcessRecueDetModel
// ─────────────────────────────────────────────────────────────────────────────
class ProcessRecDetModel {
  final int?    spkDeptIssDetID;
  final int?    spkDeptIssMstID;
  final int?    spkProcessRecMstID;
  final int?    PacketMstID;
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
  final String? repairing;
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
  final int?    length;
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
  final dynamic recutEmp;
  final dynamic planPurity;
  final dynamic planShape;
  final dynamic orderMstId;
  final int? deptCode;

  const ProcessRecDetModel({
    this.spkDeptIssDetID,
    this.spkDeptIssMstID,
    this.spkProcessRecMstID,
    this.PacketMstID,
    this.srno,
    this.id,
    this.jno,
    this.bCode,
    this.pktNo,
    this.cutNo,
    this.clvCut,
    this.length,
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
    this.repairing,
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
    this.orderMstId,
    this.planPurity,
    this.planShape,
    this.recutEmp, this.deptCode,
  });

  factory ProcessRecDetModel.fromJson(Map<String, dynamic> json) =>
      ProcessRecDetModel(
        spkDeptIssDetID: json['SPKDeptIssDetID'] ,
        spkDeptIssMstID: json['SPKDeptIssMstID'] ,
        spkProcessRecMstID: json['SPKProcessRecMstID'],

        id: json['SPKProcessRecDetID'] ?? json['ID'],
        PacketMstID: json['PacketMstID'] ?? json['PacketDetID'],
        srno: json['Srno'],
        jno: json['Jno'],

        bCode: json['BCode']?.toString(),
        pktNo: json['PktNo']?.toString(),

        cutNo: json['CutNo']?.toString(),
        clvCut: json['ClvCut']?.toString(),

        pc: json['Pc'],
        wt: _d(json['Wt']),

        issPc: json['IssPc'] ?? json['Pc'],
        issWt: _d(json['IssWt'] ?? json['Wt']),

        lossWt: _d(json['GhatWt'] ?? json['Wt']),

        dmWt: _d(json['DmWt']),
        dmPer: _d(json['DmPer']),

        purityCode: json['PurityCode'],
        deptCode: json['DeptCode'],
        charniCode: json['CharniCode'],
        colorCode: json['ColorCode'],

        shapeCode: json['ShapeCode'],
        cutCode: json['CutCode'],

        size: _d(json['Size']),
        diam: _d(json['Diam']),
        length: json['Length'],

        qrCode: json['QRCode']?.toString() ?? json['QrCode']?.toString(),
        entryType: json['EntryType']?.toString(),
        repairing: json['Repairing']?.toString()?.trim(),
        remarks: json['DeptRemark']?.toString() ?? json['Remarks']?.toString(),
        topsPc: json['TopsPc'],
        fromDeptCode: json['FromDeptCode'],
        toDeptCode: json['ToDeptCode'],
        fromCrId: json['FromCrID'],
        toCrId: json['ToCrID'] ?? json['CrID'],
        deptProcessCode: json['DeptProcessCode'],
        employeeCode: json['EmployeeCode'],
        signerCode: json['SignerCode'],
        remarksCode: json['RemarksCode'],
        dueDay: json['DueDay'],
        tensionsCode: json['TensionsCode'],
      );

  Map<String, dynamic> toJson() => {
    // ── Always send ───────────────────────────────────────────────────────────
    'SPKDeptIssMstID':  spkDeptIssMstID,
    'PacketMstID':  PacketMstID,
    'Srno':             srno,
    'ID':               id,
    'Jno':              jno,
    'BCode':            bCode,
    'PktNo':            pktNo,
    'CutNo':            cutNo,
    'ClvCut':           clvCut,
    'DeptCode':           deptCode,
    'Pc':               pc,
    'Wt':               wt,
    'IssPc':            issPc,
    'IssWt':            issWt,
    'Length':            length,
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
    'EmployeeCode': employeeCode,
    'RemarksCode':  remarksCode,

    // ── DEFAULT value fields — sirf tab bhejo jab value ho ───────────────────
     'DmWt':             dmWt,
     'DmPer':            dmPer,
     'KPc':              kPc,
     'KWt':              kWt,
     'BrPc':             brPc,
     'BrWt':             brWt,
     'LossPc':           lossPc,
     'LossWt':           lossWt,
     'LossPer':          lossPer,
     'TopsPc':           topsPc,
     'TopsWt':           topsWt,
     'SignerCode':       signerCode,
     'DueDay':           dueDay,
     'ConfDate':         confDate,
     'ConfTime':         confTime,
     'ConfLogID':        confLogID,
     'ConfPcID':         confPcID,
     'ConfEver':         confEver,
     'ConfCrID':         confCrID,
     'ConfRec':          confRec,
     'RecDate':          recDate,
     'RecTime':          recTime,
     'LastDetID':        lastDetID,
     'KachaRec':         kachaRec,
     'SubPktCreate':     subPktCreate,
     'SPKPlanningDetID': spkPlanningDetID,
     'PktType':          pktType,
     'FormType':         formType,
     'CLVRec':           clvRec,
     'Size':             size,
     'JnoRecPc':         jnoRecPc,
     'PartName':         partName,
     'ShapeCode':        shapeCode,
     'CutCode':          cutCode,
     'PurityCode':       purityCode,
     'ColorCode':        colorCode,
     'Diam':             diam,
     'Acuraecy':         acuraecy,
     'Amt':              amt,
     'ManualAuto':       manualAuto,
     'QrCode':           qrCode,
     'CheckerCrId':      checkerCrId,
     'SignerCrId':       signerCrId,
     'PlDmWt':           plDmWt,
     'PlDmPer':          plDmPer,
     'DiffDmWt':         diffDmWt,
     'CharniCode':       charniCode,
     'MackRoughWt':      mackRoughWt,
     'RateRs':           rateRs,
     'AmountRs':         amountRs,
     'RateID':           rateID,
     'Rateon':           rateon,
     'Rate':             rate,
     'Amount':           amount,
     'Ratio':            ratio,
     'PcName':           pcName,
     'MachineSrNo':      machineSrNo,
     'UserName':         userName,
     'CrHeightMM':       crHeightMM,
     'CrHeightPer':      crHeightPer,
     'CrAng':            crAng,
     'TotDepthMM':       totDepthMM,
     'TotDepthPer':      totDepthPer,
     'PavDepthMM':       pavDepthMM,
     'PavDepthPer':      pavDepthPer,
     'PavAng':           pavAng,
     'GridleMM':         gridleMM,
     'GridlePer':        gridlePer,
     'TableMM':          tableMM,
     'TablePer':         tablePer,
     'Tilt':             tilt,
     'StoneNo':          stoneNo,
     'NukDeptCode':      nukDeptCode,
     'NukRemarks':       nukRemarks,
     'DiffRgPc':         diffRgPc,
     'DiffRgWt':         diffRgWt,
     'DiffPoWt':         diffPoWt,
     'DiffAmt':          diffAmt,
     'Remarks':          remarks,
     'OldDeptIssMstID':  oldDeptIssMstID,
     'NukTopPc':         nukTopPc,
     'NukTopWt':         nukTopWt,
     'NukAmt':           nukAmt,
     'OldShapeCode':     oldShapeCode,
     'OldColorCode':     oldColorCode,
     'OldPurityCode':    oldPurityCode,
     'JobJno':           jobJno,
     'JobBCode':         jobBCode,
     'RRateID':          rRateID,
     'RRateon':          rRateon,
     'RRate':            rRate,
     'RAmount':          rAmount,
     'FType':            fType,
     'PktValid':         pktValid,
     'InValidReason':    inValidReason,
     'HighLightEntry':   highLightEntry,
     'TensionsCode':     tensionsCode,
     'PlanSignerCrID':   planSignerCrID,
     'SarinOpt':         sarinOpt,
     'SarinMachine':     sarinMachine,
     'OptDate':          optDate,
     'OptStartTime':     optStartTime,
     'OptEndTime':       optEndTime,
     'OptDiffTime':      optDiffTime,
     'OptEmpCode':       optEmpCode,
     'TableDiam':        tableDiam,
     'DmDiam':           dmDiam,
     'OptRateOn':        optRateOn,
     'OptRateID':        optRateID,
     'OptRate':          optRate,
     'OptAmount':        optAmount,
     'LsAmount':         lsAmount,
     'OrderMstID':       orderMstID,

     'PlanPurity':       planPurity,
     'RecutEmp':       recutEmp,
    'PlanShape':       planShape,
     'Repairing':       repairing,
     'SPKProcessRecMstID': spkProcessRecMstID,
  };

  static double? _d(dynamic v) {
    if (v == null) return 0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString());
  }
}
extension FactoryIssMstExt on ProcessRecMstModel {
  Map<String, dynamic> toTableRow() => {
    'jno': jno,

    'date': date ?? '',
    'time': time ?? '',


    'pc': (pc ?? 0).toString(),
    'wt': fThreeDecimal(wt ?? 0.000),

    'issPc': (issPc ?? 0).toString(),
    'issWt': fThreeDecimal(issWt ?? 0.000),

    'dmWt': fThreeDecimal(dmWt ?? 0.000),
    'dmPer': (dmPer ?? 0).toStringAsFixed(2),

    'manager': manager ?? '',
    'process': deptProcessCode ?? '',
    'department': deptCode ?? '',
    'employee': employeeCode ?? '',
  };
}