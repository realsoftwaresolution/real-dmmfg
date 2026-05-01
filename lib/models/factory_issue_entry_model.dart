class FactoryIssueMstModel {
  final int? factoryIssMstID;
  final dynamic jno;
  final String? factoryIssDate;
  final String? time;

  final String? selectType;
  final int? dueDay;
  final String? dueDate;

  final int? factoryCode;
  final String? factoryName;
  final String? factoryType;

  final String? entryType;

  // 🔹 Totals (direct from API)
  final int? pkt;
  final int? pc;
  final double? wt;
  final int? issPc;
  final double? issWt;
  final double? dmWt;
  final double? dmPer;

  const FactoryIssueMstModel({
    this.factoryIssMstID,
    this.factoryIssDate,
    this.jno,
    this.time,
    this.selectType,
    this.dueDay,
    this.dueDate,
    this.factoryCode,
    this.factoryName,
    this.factoryType,
    this.entryType,
    this.pkt,
    this.pc,
    this.wt,
    this.issPc,
    this.issWt,
    this.dmWt,
    this.dmPer,
  });

  factory FactoryIssueMstModel.fromJson(Map<String, dynamic> json) {
    return FactoryIssueMstModel(
      factoryIssMstID: json['FactoryIssMstID'],
      factoryIssDate: json['FactoryIssDate'],
      time: json['Time'],

      selectType: json['SelectType'],
      dueDay: json['DueDay'],
      dueDate: json['DueDate'],

      factoryCode: json['FactoryCode'],
      factoryName: json['FactoryName'],
      factoryType: json['FactoryType'],

      entryType: json['EntryType'],

      pkt: json['Pkt'],
      jno: json['Jno'],
      pc: json['Pc'],
      wt: (json['Wt'] as num?)?.toDouble(),

      issPc: json['IssPc'],
      issWt: (json['IssWt'] as num?)?.toDouble(),

      dmWt: (json['DmWt'] as num?)?.toDouble(),
      dmPer: (json['DmPer'] as num?)?.toDouble(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  FactoryIssueDetModel
// ─────────────────────────────────────────────────────────────────────────────
class FactoryIssueDetModel {
  final int?    spkDeptIssDetID;
  final int?    spkDeptIssMstID;
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

  const FactoryIssueDetModel({
    this.spkDeptIssDetID,
    this.spkDeptIssMstID,
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
    this.recutEmp,
  });

  factory FactoryIssueDetModel.fromJson(Map<String, dynamic> json) =>
      FactoryIssueDetModel(
        spkDeptIssDetID: json['FactoryIssDetID'],   // ✅ FIX
        spkDeptIssMstID: json['FactoryIssMstID'],   // ✅ FIX

        PacketMstID: json['PacketMstID'],
        srno: json['Srno'],
        jno: json['Jno'],

        bCode: json['BCode']?.toString(),
        pktNo: json['PktNo'],

        cutNo: json['CutNo'],

        pc: json['Pc'],
        wt: _d(json['Wt']),

        issPc: json['IssPc'],
        issWt: _d(json['IssWt']),

        lossWt: _d(json['GhatWt']),   // ✅ IMPORTANT FIX

        dmWt: _d(json['DmWt']),
        dmPer: _d(json['DmPer']),

        purityCode: json['PurityCode'],
        charniCode: json['CharniCode'],
        colorCode: json['ColorCode'],

        shapeCode: json['ShapeCode'],
        cutCode: json['CutCode'],

        size: _d(json['Size']),
        diam: _d(json['Diam']),
        length: json['Length'],
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

    if (planPurity       != null) 'PlanPurity':       planPurity,
    if (recutEmp       != null) 'RecutEmp':       recutEmp,
    if (planShape       != null) 'PlanShape':       planShape,
  };

  static double? _d(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString());
  }
}
extension FactoryIssMstExt on FactoryIssueMstModel {
  Map<String, dynamic> toTableRow() => {
    'jno': jno,

    'date': factoryIssDate ?? '',
    'time': time ?? '',

    'entry': selectType ?? '',
    'dueDay': (dueDay ?? 0).toString(),
    'dueDate': dueDate ?? '',

    'factory': factoryName ?? '',
    'type': factoryType ?? '',

    'totPkt': (pkt ?? 0).toString(),

    'pc': (pc ?? 0).toString(),
    'wt': (wt ?? 0).toStringAsFixed(3),

    'issPc': (issPc ?? 0).toString(),
    'issWt': (issWt ?? 0).toStringAsFixed(3),

    'dmWt': (dmWt ?? 0).toStringAsFixed(3),
    'dmPer': (dmPer ?? 0).toStringAsFixed(2),
  };
}