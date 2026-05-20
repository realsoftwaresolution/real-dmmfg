import '../utils/constants.dart';

class LaserMstModel {
  final int? spkDeptIssMstID;
  final String? spkDeptIssDate;
  final int? fromCrID;
  final int? toCrID;
  final int? deptProcessCode;
  final int? deptCode;
  final String? sflag;
  final String? sdate;
  final String? stime;
  final int? logID;
  final String? pcID;
  final int? ever;
  final String? entryType;
  final String? repairing;
  final String? formType;
  final String? proType;
  final String? formType1;
  final int? nukCrId;
  final String? planType;

  final List<LaserDetModel> details;

  // ── totals from DB ─────────────────────────────────────────────────────────
  final double? totalWtDb;
  final int? totalPcDb;

  // Fields mein add karo (existing fields ke baad):
  final int? totPkt;
  final String? users;
  final int? jnoFirst;
  final int? bCode;

  // Replace karo:
  double get totalWt =>
      totalWtDb ?? details.fold(0.0, (s, d) => s + (d.totalWt ?? 0));

  int get totalPc =>
      totalPcDb ?? details.fold(0, (s, d) => s + (d.totalPc ?? 0));

  const LaserMstModel({
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

  factory LaserMstModel.fromJson(Map<String, dynamic> json) => LaserMstModel(
    spkDeptIssMstID: json['SPKDeptIssMstID'],
    spkDeptIssDate: _dateOnly(json['SPKDeptIssDate']),
    fromCrID: json['FromCrID'],
    toCrID: json['ToCrID'],
    deptProcessCode: json['DeptProcessCode'],
    deptCode: json['DeptCode'],
    sflag: json['Sflag'],
    sdate: _dateOnly(json['Sdate']),
    stime: json['Stime'],
    logID: json['LogID'],
    pcID: json['PcID'],
    ever: json['Ever'],
    entryType: json['EntryType'],
    repairing: json['Repairing'],
    formType: json['FormType'],
    proType: json['ProType'],
    formType1: json['FormType1'],
    nukCrId: json['NukCrId'],
    planType: json['PlanType'],
    bCode: json['BCode'],
    totPkt: json['TotPkt'] != null ? (json['TotPkt'] as num).toInt() : null,
    users: json['Users']?.toString(),
    jnoFirst: json['Jno'] != null ? (json['Jno'] as num).toInt() : null,
    totalWtDb: json['TotalWt'] != null
        ? double.tryParse(json['TotalWt'].toString())
        : null,
    totalPcDb: json['TotalPc'] != null
        ? (json['TotalPc'] as num).toInt()
        : null,
    details: (json['details'] as List? ?? [])
        .map((e) => LaserDetModel.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'SPKDeptIssDate': spkDeptIssDate ?? '',
    'FromCrID': fromCrID ?? 0,
    'ToCrID': toCrID ?? 0,
    'DeptProcessCode': deptProcessCode ?? 0,
    'DeptCode': deptCode ?? 0,
    'Sflag': sflag ?? '',
    'Sdate': sdate ?? '',
    'Stime': stime ?? '',
    'Ever': ever ?? 0,
    'EntryType': entryType ?? '',
    'Repairing': repairing ?? '',
    'FormType': formType ?? '',
    'ProType': proType ?? '',
    'FormType1': formType1 ?? '',
    'NukCrId': nukCrId ?? 0,
    'PlanType': planType ?? '',
    'BCode': bCode ?? 0,
  };

  static String? _dateOnly(dynamic v) {
    if (v == null) return null;
    final s = v.toString();
    return s.length >= 10 ? s.substring(0, 10) : s;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  LaserDetModel
// ─────────────────────────────────────────────────────────────────────────────
class LaserDetModel {
  final int? spkDeptIssDetID;
  final int? spkDeptIssMstID;
  final int? srno;
  final int? id;
  final int? jno;
  final String? bCode;
  final String? MainBCode;
  final String? pktNo;
  final int? fromDeptCode; // ← ADD
  final int? toDeptCode;
  final int? deptCode;
  final int? length;
  final String? cutNo;
  final String? clvCut;
  final int? pc;
  final double? wt;
  final int? issPc;
  final double? issWt;
  final int? recPc;
  final double? recWt;
  final double? dmWt;
  final double? dmPer;
  final int? kPc;
  final double? kWt;
  final int? brPc;
  final double? brWt;
  final int? lossPc;
  final double? lossWt;
  final double? lossPer;
  final int? topsPc;
  final double? topsWt;
  final int? totalPc; // NOT NULL in DB
  final double? totalWt;
  final int? employeeCode; // FK → Mst_Employee
  final int? signerCode;
  final int? remarksCode; // FK → Mst_Remarks
  final int? dueDay;
  final String? confDate;
  final String? confTime;
  final int? confLogID;
  final String? confPcID;
  final int? confEver;
  final int? confCrID;
  final String? confRec;
  final String? recDate;
  final String? recTime;
  final int? lastDetID;
  final String? entryType;
  final String? kachaRec;
  final bool? subPktCreate;
  final int? spkPlanningDetID;
  final String? pktType;
  final String? formType;
  final String? clvRec;
  final double? size;
  final int? jnoRecPc;
  final int? partName;
  final int? shapeCode;
  final int? cutCode;
  final int? purityCode;
  final int? colorCode;
  final double? diam;
  final double? acuraecy;
  final double? amt;
  final bool? manualAuto;
  final String? qrCode;
  final int? checkerCrId;
  final int? signerCrId;
  final double? plDmWt;
  final double? plDmPer;
  final double? diffDmWt;
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
  final int? tilt;
  final String? stoneNo;
  final int? nukDeptCode;
  final String? nukRemarks;
  final int? diffRgPc;
  final double? diffRgWt;
  final double? diffPoWt;
  final double? diffAmt;
  final String? remarks;
  final int? oldDeptIssMstID;
  final int? nukTopPc;
  final double? nukTopWt;
  final double? nukAmt;
  final int? oldShapeCode;
  final int? oldColorCode;
  final int? oldPurityCode;
  final int? jobJno;
  final int? jobBCode;
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
  final bool? highLightEntry;
  final int? tensionsCode;
  final int? planSignerCrID;
  final String? sarinOpt;
  final String? sarinMachine;
  final String? optDate;
  final String? optStartTime;
  final String? optEndTime;
  final String? optDiffTime;
  final int? optEmpCode;
  final double? tableDiam;
  final double? dmDiam;
  final String? optRateOn;
  final String? optRateID;
  final double? optRate;
  final double? optAmount;
  final double? lsAmount;
  final int? orderMstID;

  const LaserDetModel({
    this.spkDeptIssDetID,
    this.spkDeptIssMstID,
    this.srno,
    this.id,
    this.jno,
    this.bCode,
    this.MainBCode,
    this.pktNo,
    this.cutNo,
    this.length,
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
    this.deptCode,
  });

  factory LaserDetModel.fromJson(Map<String, dynamic> json) => LaserDetModel(
    spkDeptIssDetID: json['SPKDeptIssDetID'],
    spkDeptIssMstID: json['SPKDeptIssMstID'],
    srno: json['Srno'],
    id: json['ID'],
    fromDeptCode: json['FromDeptCode'],
    toDeptCode: json['ToDeptCode'],
    deptCode: json['DeptCode'],
    jno: json['Jno'],
    bCode: json['BCode']?.toString(),
    MainBCode: json['MainBCode']?.toString(),
    pktNo: json['PktNo'],
    cutNo: json['CutNo'],
    length: json['Length'],
    clvCut: json['ClvCut'],
    fromCrId: json['FromCrID'],
    toCrId: json['ToCrID'],
    deptProcessCode: json['DeptProcessCode'],
    pc: json['Pc'],
    wt: _d(json['Wt']),
    issPc: json['IssPc'] ?? 0,
    issWt: _d(json['IssWt']),
    recPc: json['RecPc'] ?? 0,
    recWt: _d(json['RecWt']),
    dmWt: _d(json['DmWt']),
    dmPer: _d(json['DmPer']),
    kPc: json['KPc'],
    kWt: _d(json['KWt']),
    brPc: json['BrPc'],
    brWt: _d(json['BrWt']),
    lossPc: json['LossPc'],
    lossWt: _d(json['LossWt']),
    lossPer: _d(json['LossPer']),
    topsPc: json['TopsPc'],
    topsWt: _d(json['TopsWt']),
    totalPc: json['TotalPc'],
    totalWt: _d(json['TotalWt']),
    employeeCode: json['EmployeeCode'],
    signerCode: json['SignerCode'],
    remarksCode: json['RemarksCode'],
    dueDay: json['DueDay'],
    confDate: json['ConfDate'],
    confTime: json['ConfTime'],
    confLogID: json['ConfLogID'],
    confPcID: json['ConfPcID'],
    confEver: json['ConfEver'],
    confCrID: json['ConfCrID'],
    confRec: json['ConfRec'] ?? 'Y',
    recDate: json['RecDate'],
    recTime: json['RecTime'],
    lastDetID: json['LastDetID'],
    entryType: json['EntryType'],
    kachaRec: json['KachaRec'],
    subPktCreate: json['SubPktCreate'],
    spkPlanningDetID: json['SPKPlanningDetID'],
    pktType: json['PktType'],
    formType: json['FormType'],
    clvRec: json['CLVRec'],
    size: _d(json['Size']),
    jnoRecPc: json['JnoRecPc'],
    partName: json['PartName'],
    shapeCode: json['ShapeCode'],
    cutCode: json['CutCode'],
    purityCode: json['PurityCode'],
    colorCode: json['ColorCode'],
    diam: _d(json['Diam']),
    acuraecy: _d(json['Acuraecy']),
    amt: _d(json['Amt']),
    manualAuto: json['ManualAuto'],
    qrCode: json['QrCode'],
    checkerCrId: json['CheckerCrId'],
    signerCrId: json['SignerCrId'],
    plDmWt: _d(json['PlDmWt']),
    plDmPer: _d(json['PlDmPer']),
    diffDmWt: _d(json['DiffDmWt']),
    mackRoughWt: _d(json['MackRoughWt']),
    rateRs: _d(json['RateRs']),
    amountRs: _d(json['AmountRs']),
    rateID: json['RateID'],
    rateon: json['Rateon'],
    rate: _d(json['Rate']),
    amount: _d(json['Amount']),
    ratio: _d(json['Ratio']),
    pcName: json['PcName'],
    machineSrNo: json['MachineSrNo'],
    userName: json['UserName'],
    crHeightMM: _d(json['CrHeightMM']),
    crHeightPer: _d(json['CrHeightPer']),
    crAng: _d(json['CrAng']),
    totDepthMM: _d(json['TotDepthMM']),
    totDepthPer: _d(json['TotDepthPer']),
    pavDepthMM: _d(json['PavDepthMM']),
    pavDepthPer: _d(json['PavDepthPer']),
    pavAng: _d(json['PavAng']),
    gridleMM: _d(json['GridleMM']),
    gridlePer: _d(json['GridlePer']),
    tableMM: _d(json['TableMM']),
    tablePer: _d(json['TablePer']),
    tilt: json['Tilt'],
    stoneNo: json['StoneNo'],
    nukDeptCode: json['NukDeptCode'],
    nukRemarks: json['NukRemarks'],
    diffRgPc: json['DiffRgPc'],
    diffRgWt: _d(json['DiffRgWt']),
    diffPoWt: _d(json['DiffPoWt']),
    diffAmt: _d(json['DiffAmt']),
    remarks: json['Remarks'],
    oldDeptIssMstID: json['OldDeptIssMstID'],
    nukTopPc: json['NukTopPc'],
    nukTopWt: _d(json['NukTopWt']),
    nukAmt: _d(json['NukAmt']),
    oldShapeCode: json['OldShapeCode'],
    oldColorCode: json['OldColorCode'],
    oldPurityCode: json['OldPurityCode'],
    jobJno: json['JobJno'],
    jobBCode: json['JobBCode'],
    rRateID: json['RRateID'],
    rRateon: json['RRateon'],
    rRate: _d(json['RRate']),
    rAmount: _d(json['RAmount']),
    fType: json['FType'],
    pktValid: json['PktValid'],
    inValidReason: json['InValidReason'],
    highLightEntry: json['HighLightEntry'],
    tensionsCode: json['TensionsCode'],
    planSignerCrID: json['PlanSignerCrID'],
    sarinOpt: json['SarinOpt'],
    sarinMachine: json['SarinMachine'],
    optDate: json['OptDate'],
    optStartTime: json['OptStartTime'],
    optEndTime: json['OptEndTime'],
    optDiffTime: json['OptDiffTime'],
    optEmpCode: json['OptEmpCode'],
    tableDiam: _d(json['TableDiam']),
    dmDiam: _d(json['DmDiam']),
    optRateOn: json['OptRateOn'],
    optRateID: json['OptRateID'],
    optRate: _d(json['OptRate']),
    optAmount: _d(json['OptAmount']),
    lsAmount: _d(json['LsAmount']),
    orderMstID: json['OrderMstID'],
  );

  Map<String, dynamic> toJson() => {
    'SPKDeptIssMstID': spkDeptIssMstID ?? 0,
    'Srno': srno ?? 0,
    'ID': id ?? 0,
    'Jno': jno ?? 0,

    'BCode': bCode ?? '',
    'MainBCode': MainBCode ?? '',
    'PktNo': pktNo ?? '',
    'CutNo': cutNo ?? '',
    'Length': length ?? 0,
    'ClvCut': clvCut ?? '',

    'Pc': pc ?? 0,
    'Wt': wt ?? 0,

    'IssPc': issPc ?? 0,
    'IssWt': issWt ?? 0,

    'RecPc': recPc ?? 0,
    'RecWt': recWt ?? 0,

    'FromDeptCode': fromDeptCode ?? 0,
    'ToDeptCode': toDeptCode ?? 0,
    'DeptCode': deptCode ?? 0,

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
    "Height": 0,
    "PolishCode": 0,
    "SymmetryCode": 0,
    "FluoCode": 0,
  };

  static double? _d(dynamic v) {
    if (v == null) return 0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString());
  }
}

extension SpkDeptIssMstExt on LaserMstModel {
  Map<String, dynamic> toTableRow() => {
    'spkDeptIssMstID': spkDeptIssMstID,
    'spkDeptIssDate': spkDeptIssDate ?? '',
    'fromCrID': fromCrID?.toString() ?? '',
    'toCrID': toCrID?.toString() ?? '',
    'deptProcessCode': deptProcessCode?.toString() ?? '',
    'entryType': entryType ?? '',
    'totalPc': totalPc.toString(),
    'totalWt': fThreeDecimal(totalWt),
    'totPkt': (totPkt ?? 0).toString(), // ← ADD
    'jno': jnoFirst?.toString() ?? '', // ← ADD
    'users': users ?? '', // ← ADD
    'spkDeptIssTime': stime ?? '', // ← ADD
    '_raw': this,
  };
}
