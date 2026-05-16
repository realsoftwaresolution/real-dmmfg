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

    'SPKDeptIssMstID': spkDeptIssMstID ?? 0,
    'PacketMstID': PacketMstID ?? 0,

    'Srno': srno ?? 0,
    'ID': id ?? 0,
    'Jno': jno ?? 0,

    'BCode': bCode ?? '',
    'PktNo': pktNo ?? '',
    'CutNo': cutNo ?? '',
    'ClvCut': clvCut ?? '',

    'Pc': pc ?? 0,
    'Wt': wt ?? 0,

    'IssPc': issPc ?? 0,
    'IssWt': issWt ?? 0,

    'Length': length ?? 0,

    'RecPc': recPc ?? 0,
    'RecWt': recWt ?? 0,

    'sarinData': sarinData ?? [],

    'FromDeptCode': fromDeptCode ?? 0,
    'ToDeptCode': toDeptCode ?? 0,

    'TotalPc': totalPc ?? 0,
    'TotalWt': totalWt ?? 0,

    'EntryType': entryType ?? '',

    'FromCrID': fromCrId ?? 0,
    'ToCrID': toCrId ?? 0,

    'DeptProcessCode': deptProcessCode ?? 0,

    'EmployeeCode': employeeCode ?? 0,
    'RemarksCode': remarksCode ?? 0,

    'DmWt': dmWt ?? 0,
    'DmPer': dmPer ?? 0,

    'KPc': kPc ?? 0,
    'KWt': kWt ?? 0,

    'BrPc': brPc ?? 0,
    'BrWt': brWt ?? 0,

    'LossPc': lossPc ?? 0,
    'LossWt': lossWt ?? 0,
    'LossPer': lossPer ?? 0,

    'TopsPc': topsPc ?? 0,
    'TopsWt': topsWt ?? 0,

    'SignerCode': signerCode ?? 0,

    'DueDay': dueDay ?? 0,

    'ConfDate': confDate ?? '',
    'ConfTime': confTime ?? '',

    'ConfLogID': confLogID ?? 0,
    'ConfPcID': confPcID ?? '',

    'ConfEver': confEver ?? 0,
    'ConfCrID': confCrID ?? 0,

    'ConfRec': confRec ?? '',

    'RecDate': recDate ?? '',
    'RecTime': recTime ?? '',

    'LastDetID': lastDetID ?? 0,

    'KachaRec': kachaRec ?? '',

    'SubPktCreate': subPktCreate ?? false,

    'SPKPlanningDetID': spkPlanningDetID ?? 0,

    'PktType': pktType ?? '',
    'FormType': formType ?? '',
    'CLVRec': clvRec ?? '',

    'Size': size ?? 0,

    'JnoRecPc': jnoRecPc ?? 0,

    'PartName': partName ?? 0,
    'ShapeCode': shapeCode ?? 0,
    'CutCode': cutCode ?? 0,
    'PurityCode': purityCode ?? 0,
    'ColorCode': colorCode ?? 0,

    'Diam': diam ?? 0,

    'Acuraecy': acuraecy ?? 0,

    'Amt': amt ?? 0,

    'ManualAuto': manualAuto ?? false,

    'QrCode': qrCode ?? '',

    'CheckerCrId': checkerCrId ?? 0,
    'SignerCrId': signerCrId ?? 0,

    'PlDmWt': plDmWt ?? 0,
    'PlDmPer': plDmPer ?? 0,

    'DiffDmWt': diffDmWt ?? 0,

    'CharniCode': charniCode ?? 0,

    'MackRoughWt': mackRoughWt ?? 0,

    'RateRs': rateRs ?? 0,
    'AmountRs': amountRs ?? 0,

    'RateID': rateID ?? '',
    'Rateon': rateon ?? '',

    'Rate': rate ?? 0,
    'Amount': amount ?? 0,
    'Ratio': ratio ?? 0,

    'PcName': pcName ?? '',
    'MachineSrNo': machineSrNo ?? '',
    'UserName': userName ?? '',

    'CrHeightMM': crHeightMM ?? 0,
    'CrHeightPer': crHeightPer ?? 0,
    'CrAng': crAng ?? 0,

    'TotDepthMM': totDepthMM ?? 0,
    'TotDepthPer': totDepthPer ?? 0,

    'PavDepthMM': pavDepthMM ?? 0,
    'PavDepthPer': pavDepthPer ?? 0,
    'PavAng': pavAng ?? 0,

    'GridleMM': gridleMM ?? 0,
    'GridlePer': gridlePer ?? 0,

    'TableMM': tableMM ?? 0,
    'TablePer': tablePer ?? 0,

    'Tilt': tilt ?? 0,

    'StoneNo': stoneNo ?? '',

    'NukDeptCode': nukDeptCode ?? 0,
    'NukRemarks': nukRemarks ?? '',

    'DiffRgPc': diffRgPc ?? 0,
    'DiffRgWt': diffRgWt ?? 0,
    'DiffPoWt': diffPoWt ?? 0,
    'DiffAmt': diffAmt ?? 0,

    'Remarks': remarks ?? '',

    'OldDeptIssMstID': oldDeptIssMstID ?? 0,

    'NukTopPc': nukTopPc ?? 0,
    'NukTopWt': nukTopWt ?? 0,
    'NukAmt': nukAmt ?? 0,

    'OldShapeCode': oldShapeCode ?? 0,
    'OldColorCode': oldColorCode ?? 0,
    'OldPurityCode': oldPurityCode ?? 0,

    'JobJno': jobJno ?? 0,
    'JobBCode': jobBCode ?? 0,

    'RRateID': rRateID ?? '',
    'RRateon': rRateon ?? '',

    'RRate': rRate ?? 0,
    'RAmount': rAmount ?? 0,

    'FType': fType ?? '',

    'PktValid': pktValid ?? '',

    'InValidReason': inValidReason ?? '',

    'HighLightEntry': highLightEntry ?? false,

    'TensionsCode': tensionsCode ?? 0,

    'PlanSignerCrID': planSignerCrID ?? 0,

    'SarinOpt': sarinOpt ?? '',
    'SarinMachine': sarinMachine ?? '',

    'OptDate': optDate ?? '',
    'OptStartTime': optStartTime ?? '',
    'OptEndTime': optEndTime ?? '',
    'OptDiffTime': optDiffTime ?? '',

    'OptEmpCode': optEmpCode ?? 0,

    'TableDiam': tableDiam ?? 0,
    'DmDiam': dmDiam ?? 0,

    'OptRateOn': optRateOn ?? '',
    'OptRateID': optRateID ?? '',

    'OptRate': optRate ?? 0,
    'OptAmount': optAmount ?? 0,

    'LsAmount': lsAmount ?? 0,

    'OrderMstID': orderMstID ?? 0,

    'PlanPurity': planPurity ?? '',
    'RecutEmp': recutEmp ?? '',
    'PlanShape': planShape ?? '',
  };

  static double? _d(dynamic v) {
    if (v == null) return 0;
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