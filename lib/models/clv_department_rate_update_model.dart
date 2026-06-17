class ClvDepartmentRateUpdateModel {
  int? spkDeptIssDetID;
  int? spkDeptIssMstID;
  int? srno;
  int? id;
  int? jno;
  int? bCode;
  String? pktNo;
  String? cutNo;
  String? clvCut;
  int? pc;
  double? wt;
  int? issPc;
  double? issWt;
  int? recPc;
  double? recWt;
  double? dmWt;
  double? dmPer;
  int? kPc;
  double? kWt;
  int? brPc;
  double? brWt;
  int? lossPc;
  double? lossWt;
  double? lossPer;
  int? topsPc;
  double? topsWt;
  int? totalPc;
  double? totalWt;
  int? fromCrID;
  int? toCrID;
  int? deptProcessCode;
  int? deptCode;
  int? fromDeptCode;
  int? toDeptCode;
  int? employeeCode;
  int? signerCode;
  int? remarksCode;
  int? dueDay;
  DateTime? confDate;
  DateTime? confTime;
  int? confLogID;
  String? confPcID;
  int? confEver;
  int? confCrID;
  String? confRec;
  DateTime? recDate;
  DateTime? recTime;
  int? lastDetID;
  String? entryType;
  String? kachaRec;
  bool? subPktCreate;
  int? spkPlanningDetID;
  String? pktType;
  String? formType;
  String? clvRec;
  double? size;
  int? jnoRecPc;
  int? partName;
  int? shapeCode;
  int? cutCode;
  int? purityCode;
  int? colorCode;
  double? diam;
  double? acuraecy;
  double? amt;
  bool? manualAuto;
  String? qrCode;
  int? checkerCrId;
  int? signerCrId;
  double? plDmWt;
  double? plDmPer;
  double? diffDmWt;
  int? charniCode;
  double? mackRoughWt;
  double? rateRs;
  double? amountRs;
  String? rateID;
  String? rateon;
  double? rate;
  String? amount;
  double? ratio;
  String? pcName;
  String? machineSrNo;
  String? userName;
  double? crHeightMM;
  double? crHeightPer;
  double? crAng;
  double? totDepthMM;
  double? totDepthPer;
  double? pavDepthMM;
  double? pavDepthPer;
  double? pavAng;
  double? gridleMM;
  double? gridlePer;
  double? tableMM;
  double? tablePer;
  double? tilt;
  String? stoneNo;
  int? nukDeptCode;
  String? nukRemarks;
  int? diffRgPc;
  double? diffRgWt;
  double? diffPoWt;
  double? diffAmt;
  String? remarks;
  int? oldDeptIssMstID;
  int? nukTopPc;
  double? nukTopWt;
  double? nukAmt;
  int? oldShapeCode;
  int? oldColorCode;
  int? oldPurityCode;
  int? jobJno;
  int? jobBCode;
  String? rRateID;
  String? rRateon;
  double? rRate;
  double? rAmount;
  String? fType;
  String? pktValid;
  String? inValidReason;
  bool? highLightEntry;
  int? tensionsCode;
  int? planSignerCrID;
  String? sarinOpt;
  String? sarinMachine;
  DateTime? optDate;
  DateTime? optStartTime;
  DateTime? optEndTime;
  String? optDiffTime;
  int? optEmpCode;
  double? tableDiam;
  double? dmDiam;
  String? optRateOn;
  String? optRateID;
  double? optRate;
  double? optAmount;
  double? lsAmount;
  int? orderMstID;
  int? polishCode;
  int? symmetryCode;
  double? length;
  double? height;
  int? fluoCode;
  int? mainBCode;
  int? articalCode;

  ClvDepartmentRateUpdateModel();

  factory ClvDepartmentRateUpdateModel.fromJson(Map<String, dynamic> json) {
    final model = ClvDepartmentRateUpdateModel();

    model.spkDeptIssDetID = json['SPKDeptIssDetID'];
    model.spkDeptIssMstID = json['SPKDeptIssMstID'];
    model.srno = json['Srno'];
    model.id = json['ID'];
    model.jno = json['Jno'];
    model.bCode = json['BCode'];
    model.pktNo = json['PktNo'];
    model.cutNo = json['CutNo'];
    model.clvCut = json['ClvCut'];

    model.pc = json['Pc'];
    model.wt = (json['Wt'] as num?)?.toDouble();

    model.issPc = json['IssPc'];
    model.issWt = (json['IssWt'] as num?)?.toDouble();

    model.recPc = json['RecPc'];
    model.recWt = (json['RecWt'] as num?)?.toDouble();

    model.deptProcessCode = json['DeptProcessCode'];
    model.deptCode = json['DeptCode'];
    model.fromDeptCode = json['FromDeptCode'];
    model.toDeptCode = json['ToDeptCode'];

    model.confDate = json['ConfDate'] != null
        ? DateTime.tryParse(json['ConfDate'])
        : null;

    model.recDate = json['RecDate'] != null
        ? DateTime.tryParse(json['RecDate'])
        : null;

    model.rateID = json['RateID']?.toString();
    model.rateon = json['Rateon'];
    model.rate = (json['Rate'] as num?)?.toDouble();
    model.amount = json['Amount']?.toString();

    model.articalCode = json['ArticalCode'];

    return model;
  }

  Map<String, dynamic> toJson() => {
    'SPKDeptIssDetID': spkDeptIssDetID,
    'SPKDeptIssMstID': spkDeptIssMstID,
    'Srno': srno,
    'ID': id,
    'Jno': jno,
    'BCode': bCode,
    'PktNo': pktNo,
    'CutNo': cutNo,
    'ClvCut': clvCut,
    'Pc': pc,
    'Wt': wt,
    'IssPc': issPc,
    'IssWt': issWt,
    'RecPc': recPc,
    'RecWt': recWt,
    'DeptProcessCode': deptProcessCode,
    'DeptCode': deptCode,
    'FromDeptCode': fromDeptCode,
    'ToDeptCode': toDeptCode,
    'ConfDate': confDate?.toIso8601String(),
    'RecDate': recDate?.toIso8601String(),
    'RateID': rateID,
    'Rateon': rateon,
    'Rate': rate,
    'Amount': amount,
    'ArticalCode': articalCode,
  };
}