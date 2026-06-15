import '../utils/constants.dart';

class FactoryReceiveMstModel {
  final int? factoryRecMstID;
  final String? factoryRecDate;
  final String? time;

  final int? factoryCode;
  final dynamic EntryType;
  final String? factoryName;

  final int? pkt;
  final int? pc;
  final double? wt;

  final int? issPc;
  final double? issWt;

  final int? recPc;
  final double? recWt;

  final int? kPc;
  final double? kWt;

  final int? brPc;
  final double? brWt;

  final int? lossPc;
  final double? lossWt;

  final double? dmWt;
  final double? dmPer;

  const FactoryReceiveMstModel({
    this.EntryType,
    this.factoryRecMstID,
    this.factoryRecDate,
    this.time,
    this.factoryCode,
    this.factoryName,
    this.pkt,
    this.pc,
    this.wt,
    this.issPc,
    this.issWt,
    this.recPc,
    this.recWt,
    this.kPc,
    this.kWt,
    this.brPc,
    this.brWt,
    this.lossPc,
    this.lossWt,
    this.dmWt,
    this.dmPer,
  });

  factory FactoryReceiveMstModel.fromJson(Map<String, dynamic> json) {
    return FactoryReceiveMstModel(
      factoryRecMstID: json['FactoryRecMstID'],
      factoryRecDate: _dateOnly(json['FactoryRecDate']),
      time: json['Time']?.toString(),

      factoryCode: json['FactoryCode'],
      factoryName: json['FactoryName'],
      EntryType: json['EntryType'],

      pkt: json['Pkt'],
      pc: json['Pc'],
      wt: _toDouble(json['Wt']),

      issPc: json['IssPc'],
      issWt: _toDouble(json['IssWt']),

      recPc: json['RecPc'],
      recWt: _toDouble(json['RecWt']),

      kPc: json['KPc'],
      kWt: _toDouble(json['KWt']),

      brPc: json['BrPc'],
      brWt: _toDouble(json['BrWt']),

      lossPc: json['LossPc'],
      lossWt: _toDouble(json['LossWt']),

      dmWt: _toDouble(json['DmWt']),
      dmPer: _toDouble(json['DmPer']),
    );
  }

  // ❗ Not required for list API, but keep minimal
  Map<String, dynamic> toJson() => {
    "FactoryRecDate": factoryRecDate,
    "FactoryCode": factoryCode,
    "EntryType": EntryType,
  };

  // ───────── HELPERS ─────────
  static String? _dateOnly(dynamic v) {
    if (v == null) return null;
    final s = v.toString();
    return s.length >= 10 ? s.substring(0, 10) : s;
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return 0;
    return double.tryParse(v.toString());
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  FactoryReceiveDetModel
// ─────────────────────────────────────────────────────────────────────────────
class FactoryReceiveDetModel {
  final int? factoryIssDetID;
  final int?    factoryRecMstID;
  final int?    FactoryRecDetID;
  final int?    srno;
  final int?    id;
  final int?    jno;
  final dynamic   MfgCut;
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
  final dynamic CrID;
  final dynamic LastCrID;
  final dynamic pairNo;
  final int? polishCode;
  final int? symmetryCode;
  final int? fluo;
  final double? height;
  final String? topSide;
  final int? markerMstID;
  final int? fcIntentCode;
  final int? fcOverCode;
  final int? fColorCode1;
  final int? fColorCode2;
  final String? ha;

  const FactoryReceiveDetModel({
    this.pairNo,
    this.polishCode,
    this.symmetryCode,
    this.fluo,
    this.height,
    this.factoryIssDetID,
    this.factoryRecMstID,
    this.FactoryRecDetID,
    this.srno,
    this.MfgCut,
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
    this.LastCrID,
    this.CrID,
    this.markerMstID,
    this.fcIntentCode,
    this.fcOverCode,
    this.fColorCode1,
    this.fColorCode2,
    this.ha,
    this.topSide,
  });

  factory FactoryReceiveDetModel.fromJson(Map<String, dynamic> json) =>
      FactoryReceiveDetModel(
        factoryIssDetID: json['FactoryIssDetID'],
        factoryRecMstID:  json['FactoryRecMstID'] ?? 0,
        FactoryRecDetID:  json['FactoryRecDetID'],
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
        CrID:          json['CrID'],
        LastCrID:          json['LastCrID'],
        deptProcessCode: json['DeptProcessCode'],
        pc:               json['Pc'],
        wt:               _d(json['Wt']),
        issPc:            json['IssPc'],
        MfgCut:            json['MfgCut'],
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
        confRec:          json['ConfRec'] ?? 'Y',
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
        recutEmp:       json['RecutEmp'],
        planShape:       json['PlanShape'],
        planPurity:       json['PlanPurity'],
        pairNo: json['PairNo'],
        polishCode: json['PolishCode'],
        symmetryCode: json['SymmetryCode'],
        fluo: json['FluoCode'] ?? 0,
        height: _d(json['Height']),
        length:       json['Length'],
        markerMstID: json['MarkerMstID'],
        fcIntentCode: json['FcIntentCode'],
        fcOverCode: json['FcOverCode'],
        fColorCode1: json['FColorCode1'],
        fColorCode2: json['FColorCode2'],
        ha: json['HA']?.toString(),
        topSide: json['TopSide']?.toString(),
        sarinData: (json['sarinData'] as List?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() ?? [],
      );

  Map<String, dynamic> toJson() => {
    // ── Always send ───────────────────────────────────────────────────────────
    if (factoryIssDetID != null) 'FactoryIssDetID': factoryIssDetID,
    'FactoryRecMstID':  factoryRecMstID,
    'FactoryRecDetID':  FactoryRecDetID,
    'Srno':             srno,
    'ID':               id,
    'Jno':              jno,
    'BCode':            bCode,
    'PktNo':            pktNo,
    'CutNo':            cutNo,
    'LastCrID':            LastCrID,
    'CrID':            CrID,
    'ClvCut':           clvCut,
    'Pc':               pc,
    'Wt':               wt,
    'IssPc':            issPc,
    'IssWt':            issWt,
    'Length':            length,
    'RecPc':            recPc,
    'MfgCut':            MfgCut,
    'sarinData':            sarinData,
    if (pairNo != null) 'PairNo': pairNo,
    if (polishCode != null) 'PolishCode': polishCode,
    if (symmetryCode != null) 'SymmetryCode': symmetryCode,
    if (fluo != null) 'FluoCode': fluo,
    if (height != null) 'Height': height,
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
    if (markerMstID != null) 'MarkerMstID': markerMstID,
    if (fcIntentCode  != null) 'FcIntentCode':  fcIntentCode,
    if (fcOverCode    != null) 'FcOverCode':    fcOverCode,
    if (fColorCode1   != null) 'FColorCode1':   fColorCode1,
    if (fColorCode2   != null) 'FColorCode2':   fColorCode2,
    if (ha            != null) 'HA':             ha,
    if (topSide       != null) 'TopSide':        topSide,
  };


  FactoryReceiveDetModel copyWith({
    int? factoryIssDetID,
    int? factoryRecMstID,
    int? FactoryRecDetID,
    int? srno,
    int? id,
    int? jno,
    dynamic MfgCut,
    String? bCode,
    String? pktNo,
    int? fromDeptCode,
    int? toDeptCode,
    String? cutNo,
    String? clvCut,
    int? pc,
    double? wt,
    int? issPc,
    double? issWt,
    int? recPc,
    double? recWt,
    double? dmWt,
    double? dmPer,
    int? kPc,
    double? kWt,
    int? brPc,
    double? brWt,
    int? lossPc,
    double? lossWt,
    double? lossPer,
    int? topsPc,
    double? topsWt,
    int? totalPc,
    double? totalWt,
    int? employeeCode,
    int? signerCode,
    int? remarksCode,
    int? dueDay,
    String? confDate,
    String? confTime,
    int? confLogID,
    String? confPcID,
    int? confEver,
    int? confCrID,
    String? confRec,
    String? recDate,
    String? recTime,
    int? lastDetID,
    String? entryType,
    String? kachaRec,
    bool? subPktCreate,
    int? spkPlanningDetID,
    String? pktType,
    String? formType,
    String? clvRec,
    double? size,
    int? jnoRecPc,
    int? partName,
    int? shapeCode,
    int? cutCode,
    int? purityCode,
    int? colorCode,
    int? length,
    double? diam,
    double? acuraecy,
    double? amt,
    bool? manualAuto,
    String? qrCode,
    int? checkerCrId,
    int? signerCrId,
    double? plDmWt,
    double? plDmPer,
    double? diffDmWt,
    int? charniCode,
    double? mackRoughWt,
    double? rateRs,
    double? amountRs,
    String? rateID,
    String? rateon,
    double? rate,
    double? amount,
    double? ratio,
    String? pcName,
    String? machineSrNo,
    String? userName,
    double? crHeightMM,
    double? crHeightPer,
    double? crAng,
    double? totDepthMM,
    double? totDepthPer,
    double? pavDepthMM,
    double? pavDepthPer,
    double? pavAng,
    double? gridleMM,
    double? gridlePer,
    double? tableMM,
    double? tablePer,
    int? tilt,
    String? stoneNo,
    int? nukDeptCode,
    String? nukRemarks,
    int? diffRgPc,
    double? diffRgWt,
    double? diffPoWt,
    double? diffAmt,
    String? remarks,
    int? oldDeptIssMstID,
    int? nukTopPc,
    double? nukTopWt,
    double? nukAmt,
    int? oldShapeCode,
    int? oldColorCode,
    int? oldPurityCode,
    int? jobJno,
    int? jobBCode,
    String? rRateID,
    String? rRateon,
    double? rRate,
    double? rAmount,
    String? fType,
    String? pktValid,
    int? fromCrId,
    int? toCrId,
    int? deptProcessCode,
    String? inValidReason,
    bool? highLightEntry,
    int? tensionsCode,
    int? planSignerCrID,
    String? sarinOpt,
    String? sarinMachine,
    String? optDate,
    String? optStartTime,
    String? optEndTime,
    String? optDiffTime,
    int? optEmpCode,
    double? tableDiam,
    double? dmDiam,
    String? optRateOn,
    String? optRateID,
    double? optRate,
    double? optAmount,
    double? lsAmount,
    int? orderMstID,
    List<Map<String, dynamic>>? sarinData,
    dynamic recutEmp,
    dynamic planPurity,
    dynamic planShape,
    dynamic orderMstId,
    dynamic CrID,
    dynamic LastCrID,
    dynamic pairNo,
    int? polishCode,
    int? symmetryCode,
    int? fluo,
    double? height,
    String? topSide,
    int? markerMstID,
    int? fcIntentCode,
    int? fcOverCode,
    int? fColorCode1,
    int? fColorCode2,
    String? ha,
  }) =>
      FactoryReceiveDetModel(
        factoryIssDetID: factoryIssDetID ?? this.factoryIssDetID,
        factoryRecMstID: factoryRecMstID ?? this.factoryRecMstID,
        FactoryRecDetID: FactoryRecDetID ?? this.FactoryRecDetID,
        srno: srno ?? this.srno,
        id: id ?? this.id,
        jno: jno ?? this.jno,
        MfgCut: MfgCut ?? this.MfgCut,
        bCode: bCode ?? this.bCode,
        pktNo: pktNo ?? this.pktNo,
        fromDeptCode: fromDeptCode ?? this.fromDeptCode,
        toDeptCode: toDeptCode ?? this.toDeptCode,
        cutNo: cutNo ?? this.cutNo,
        clvCut: clvCut ?? this.clvCut,
        pc: pc ?? this.pc,
        wt: wt ?? this.wt,
        issPc: issPc ?? this.issPc,
        issWt: issWt ?? this.issWt,
        recPc: recPc ?? this.recPc,
        recWt: recWt ?? this.recWt,
        dmWt: dmWt ?? this.dmWt,
        dmPer: dmPer ?? this.dmPer,
        kPc: kPc ?? this.kPc,
        kWt: kWt ?? this.kWt,
        brPc: brPc ?? this.brPc,
        brWt: brWt ?? this.brWt,
        lossPc: lossPc ?? this.lossPc,
        lossWt: lossWt ?? this.lossWt,
        lossPer: lossPer ?? this.lossPer,
        topsPc: topsPc ?? this.topsPc,
        topsWt: topsWt ?? this.topsWt,
        totalPc: totalPc ?? this.totalPc,
        totalWt: totalWt ?? this.totalWt,
        employeeCode: employeeCode ?? this.employeeCode,
        signerCode: signerCode ?? this.signerCode,
        remarksCode: remarksCode ?? this.remarksCode,
        dueDay: dueDay ?? this.dueDay,
        confDate: confDate ?? this.confDate,
        confTime: confTime ?? this.confTime,
        confLogID: confLogID ?? this.confLogID,
        confPcID: confPcID ?? this.confPcID,
        confEver: confEver ?? this.confEver,
        confCrID: confCrID ?? this.confCrID,
        confRec: confRec ?? this.confRec,
        recDate: recDate ?? this.recDate,
        recTime: recTime ?? this.recTime,
        lastDetID: lastDetID ?? this.lastDetID,
        entryType: entryType ?? this.entryType,
        kachaRec: kachaRec ?? this.kachaRec,
        subPktCreate: subPktCreate ?? this.subPktCreate,
        spkPlanningDetID: spkPlanningDetID ?? this.spkPlanningDetID,
        pktType: pktType ?? this.pktType,
        formType: formType ?? this.formType,
        clvRec: clvRec ?? this.clvRec,
        size: size ?? this.size,
        jnoRecPc: jnoRecPc ?? this.jnoRecPc,
        partName: partName ?? this.partName,
        shapeCode: shapeCode ?? this.shapeCode,
        cutCode: cutCode ?? this.cutCode,
        purityCode: purityCode ?? this.purityCode,
        colorCode: colorCode ?? this.colorCode,
        length: length ?? this.length,
        diam: diam ?? this.diam,
        acuraecy: acuraecy ?? this.acuraecy,
        amt: amt ?? this.amt,
        manualAuto: manualAuto ?? this.manualAuto,
        qrCode: qrCode ?? this.qrCode,
        checkerCrId: checkerCrId ?? this.checkerCrId,
        signerCrId: signerCrId ?? this.signerCrId,
        plDmWt: plDmWt ?? this.plDmWt,
        plDmPer: plDmPer ?? this.plDmPer,
        diffDmWt: diffDmWt ?? this.diffDmWt,
        charniCode: charniCode ?? this.charniCode,
        mackRoughWt: mackRoughWt ?? this.mackRoughWt,
        rateRs: rateRs ?? this.rateRs,
        amountRs: amountRs ?? this.amountRs,
        rateID: rateID ?? this.rateID,
        rateon: rateon ?? this.rateon,
        rate: rate ?? this.rate,
        amount: amount ?? this.amount,
        ratio: ratio ?? this.ratio,
        pcName: pcName ?? this.pcName,
        machineSrNo: machineSrNo ?? this.machineSrNo,
        userName: userName ?? this.userName,
        crHeightMM: crHeightMM ?? this.crHeightMM,
        crHeightPer: crHeightPer ?? this.crHeightPer,
        crAng: crAng ?? this.crAng,
        totDepthMM: totDepthMM ?? this.totDepthMM,
        totDepthPer: totDepthPer ?? this.totDepthPer,
        pavDepthMM: pavDepthMM ?? this.pavDepthMM,
        pavDepthPer: pavDepthPer ?? this.pavDepthPer,
        pavAng: pavAng ?? this.pavAng,
        gridleMM: gridleMM ?? this.gridleMM,
        gridlePer: gridlePer ?? this.gridlePer,
        tableMM: tableMM ?? this.tableMM,
        tablePer: tablePer ?? this.tablePer,
        tilt: tilt ?? this.tilt,
        stoneNo: stoneNo ?? this.stoneNo,
        nukDeptCode: nukDeptCode ?? this.nukDeptCode,
        nukRemarks: nukRemarks ?? this.nukRemarks,
        diffRgPc: diffRgPc ?? this.diffRgPc,
        diffRgWt: diffRgWt ?? this.diffRgWt,
        diffPoWt: diffPoWt ?? this.diffPoWt,
        diffAmt: diffAmt ?? this.diffAmt,
        remarks: remarks ?? this.remarks,
        oldDeptIssMstID: oldDeptIssMstID ?? this.oldDeptIssMstID,
        nukTopPc: nukTopPc ?? this.nukTopPc,
        nukTopWt: nukTopWt ?? this.nukTopWt,
        nukAmt: nukAmt ?? this.nukAmt,
        oldShapeCode: oldShapeCode ?? this.oldShapeCode,
        oldColorCode: oldColorCode ?? this.oldColorCode,
        oldPurityCode: oldPurityCode ?? this.oldPurityCode,
        jobJno: jobJno ?? this.jobJno,
        jobBCode: jobBCode ?? this.jobBCode,
        rRateID: rRateID ?? this.rRateID,
        rRateon: rRateon ?? this.rRateon,
        rRate: rRate ?? this.rRate,
        rAmount: rAmount ?? this.rAmount,
        fType: fType ?? this.fType,
        pktValid: pktValid ?? this.pktValid,
        fromCrId: fromCrId ?? this.fromCrId,
        toCrId: toCrId ?? this.toCrId,
        deptProcessCode: deptProcessCode ?? this.deptProcessCode,
        inValidReason: inValidReason ?? this.inValidReason,
        highLightEntry: highLightEntry ?? this.highLightEntry,
        tensionsCode: tensionsCode ?? this.tensionsCode,
        planSignerCrID: planSignerCrID ?? this.planSignerCrID,
        sarinOpt: sarinOpt ?? this.sarinOpt,
        sarinMachine: sarinMachine ?? this.sarinMachine,
        optDate: optDate ?? this.optDate,
        optStartTime: optStartTime ?? this.optStartTime,
        optEndTime: optEndTime ?? this.optEndTime,
        optDiffTime: optDiffTime ?? this.optDiffTime,
        optEmpCode: optEmpCode ?? this.optEmpCode,
        tableDiam: tableDiam ?? this.tableDiam,
        dmDiam: dmDiam ?? this.dmDiam,
        optRateOn: optRateOn ?? this.optRateOn,
        optRateID: optRateID ?? this.optRateID,
        optRate: optRate ?? this.optRate,
        optAmount: optAmount ?? this.optAmount,
        lsAmount: lsAmount ?? this.lsAmount,
        orderMstID: orderMstID ?? this.orderMstID,
        sarinData: sarinData ?? this.sarinData,
        recutEmp: recutEmp ?? this.recutEmp,
        planPurity: planPurity ?? this.planPurity,
        planShape: planShape ?? this.planShape,
        orderMstId: orderMstId ?? this.orderMstId,
        CrID: CrID ?? this.CrID,
        LastCrID: LastCrID ?? this.LastCrID,
        pairNo: pairNo ?? this.pairNo,
        polishCode: polishCode ?? this.polishCode,
        symmetryCode: symmetryCode ?? this.symmetryCode,
        fluo: fluo ?? this.fluo,
        height: height ?? this.height,
        markerMstID: markerMstID ?? this.markerMstID,
        fcIntentCode: fcIntentCode ?? this.fcIntentCode,
        fcOverCode: fcOverCode ?? this.fcOverCode,
        fColorCode1: fColorCode1 ?? this.fColorCode1,
        fColorCode2: fColorCode2 ?? this.fColorCode2,
        ha: ha ?? this.ha,
        topSide: topSide ?? this.topSide,
      );

  static double? _d(dynamic v) {
    if (v == null) return 0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString());
  }
}



extension FactoryReceiveMstExt on FactoryReceiveMstModel {
  Map<String, dynamic> toTableRow() => {
    'id': factoryRecMstID?.toString() ?? '',

    'date': factoryRecDate ?? '',
    'time': time ?? '',

    'factory': factoryName ?? '',

    'totPkt': (pkt ?? 0).toString(),

    'pc': (pc ?? 0).toString(),
    'wt': fThreeDecimal(wt ?? 0),

    'issPc': (issPc ?? 0).toString(),
    'issWt': fThreeDecimal(issWt ?? 0),

    'recPc': (recPc ?? 0).toString(),
    'recWt': fThreeDecimal(recWt ?? 0),

    'kPc': (kPc ?? 0).toString(),
    'kWt': fThreeDecimal(kWt ?? 0),

    'brPc': (brPc ?? 0).toString(),
    'brWt': fThreeDecimal(brWt ?? 0),

    'lossPc': (lossPc ?? 0).toString(),
    'lossWt': fThreeDecimal(lossWt ?? 0),

    'dmWt': fThreeDecimal(dmWt ?? 0),
    'dmPer': (dmPer ?? 0).toStringAsFixed(2),

    // 🔥 keep raw for rowTap
    '_raw': this,
  };
}