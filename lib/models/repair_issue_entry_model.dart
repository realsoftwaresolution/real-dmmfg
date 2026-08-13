class RepairIssueMstModel {
  final int? repairIssMstID;
  final int? factoryIssMstID;
  final dynamic jno;
  final String? repairIssDate;
  final String? time;

  final String? selectType;
  final int? dueDay;
  final String? dueDate;

  final int? factoryCode;
  final String? factoryName;
  final String? factoryType;

  final String? entryType;
  final String? rePairIssue;

  // Totals
  final int? pkt;
  final int? pc;
  final double? wt;
  final int? issPc;
  final double? issWt;
  final double? dmWt;
  final double? dmPer;

  const RepairIssueMstModel({
    this.repairIssMstID,
    this.factoryIssMstID,
    this.repairIssDate,
    this.jno,
    this.time,
    this.selectType,
    this.dueDay,
    this.dueDate,
    this.factoryCode,
    this.factoryName,
    this.factoryType,
    this.entryType,
    this.rePairIssue,
    this.pkt,
    this.pc,
    this.wt,
    this.issPc,
    this.issWt,
    this.dmWt,
    this.dmPer,
  });

  factory RepairIssueMstModel.fromJson(Map<String, dynamic> json) {
    int? parseDueDay(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    return RepairIssueMstModel(
      repairIssMstID: json['RepairIssMstID'] ?? json['FactoryIssMstID'] ?? json['repairIssMstID'],
      factoryIssMstID: json['FactoryIssMstID'] ?? json['RepairIssMstID'] ?? json['factoryIssMstID'],
      repairIssDate: json['RepairIssDate'] ?? json['FactoryIssDate'] ?? json['Date'] ?? json['date'] ?? json['repairIssDate'],
      time: json['Time'] ?? json['time'],
      selectType: json['SelectType'] ?? json['selectType'] ?? json['entry'] ?? json['EntryType'],
      dueDay: parseDueDay(json['DueDay'] ?? json['dueDay']),
      dueDate: json['DueDate'] ?? json['dueDate'],
      factoryCode: json['FactoryCode'] ?? json['factoryCode'],
      factoryName: json['FactoryName'] ?? json['factoryName'],
      factoryType: json['FactoryType'] ?? json['factoryType'] ?? json['type'] ?? json['RepairType'],
      entryType: json['EntryType'] ?? json['entryType'],
      rePairIssue: json['RePairIssue'] ?? json['rePairIssue'] ?? json['RepairIssue'] ?? json['repairIssue'],
      pkt: json['Pkt'] ?? json['pkt'],
      jno: json['Jno'] ?? json['jno'],
      pc: json['Pc'] ?? json['pc'],
      wt: (json['Wt'] ?? json['wt'] as num?)?.toDouble(),
      issPc: json['IssPc'] ?? json['issPc'],
      issWt: (json['IssWt'] ?? json['issWt'] as num?)?.toDouble(),
      dmWt: (json['DmWt'] ?? json['dmWt'] as num?)?.toDouble(),
      dmPer: (json['DmPer'] ?? json['dmPer'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'RepairIssMstID': repairIssMstID,
        'FactoryIssMstID': factoryIssMstID,
        'RepairIssDate': repairIssDate,
        'Time': time,
        'SelectType': selectType,
        'DueDay': dueDay,
        'DueDate': dueDate,
        'FactoryCode': factoryCode,
        'FactoryName': factoryName,
        'FactoryType': factoryType,
        'EntryType': entryType,
        'RePairIssue': rePairIssue,
        'Pkt': pkt,
        'Jno': jno,
        'Pc': pc,
        'Wt': wt,
        'IssPc': issPc,
        'IssWt': issWt,
        'DmWt': dmWt,
        'DmPer': dmPer,
      };

  Map<String, dynamic> toTableRow() {
    return {
      'repairIssMstID': repairIssMstID ?? factoryIssMstID,
      'factoryIssMstID': factoryIssMstID ?? repairIssMstID,
      'repairIssDate': repairIssDate ?? '-',
      'date': repairIssDate ?? '-',
      'time': time ?? '-',
      'factoryName': factoryName ?? '-',
      'factoryCode': factoryCode,
      'factoryType': factoryType,
      'type': factoryType,
      'selectType': selectType,
      'entry': selectType,
      'dueDay': dueDay != null ? dueDay.toString() : '0',
      'dueDate': dueDate ?? '',
      'jno': jno,
      'entryType': entryType ?? '-',
      'rePairIssue': rePairIssue ?? 'FACTORY',
      'RePairIssue': rePairIssue ?? 'FACTORY',
      'pkt': pkt ?? 0,
      'pc': pc ?? 0,
      'wt': wt != null ? wt!.toStringAsFixed(3) : '0.000',
      'issPc': issPc ?? 0,
      'issWt': issWt != null ? issWt!.toStringAsFixed(3) : '0.000',
      'dmWt': dmWt != null ? dmWt!.toStringAsFixed(3) : '0.000',
      'dmPer': dmPer != null ? dmPer!.toStringAsFixed(2) : '0.00',

      // Fallback PascalCase keys
      'RepairIssMstID': repairIssMstID ?? factoryIssMstID,
      'RepairIssDate': repairIssDate,
      'Time': time,
      'FactoryName': factoryName,
      'FactoryCode': factoryCode,
      'FactoryType': factoryType,
      'SelectType': selectType,
      'DueDay': dueDay,
      'DueDate': dueDate,
      'Jno': jno,
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  RepairIssueDetModel
// ─────────────────────────────────────────────────────────────────────────────
class RepairIssueDetModel {
  final int? spkDeptIssDetID;
  final int? spkDeptIssMstID;
  final int? packetMstID;
  final int? NewIssMstID;
  final int? srno;
  final int? id;
  final int? jno;
  final String? bCode;
  final String? pktNo;
  final int? fromDeptCode;
  final int? toDeptCode;
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
  final int? totalPc;
  final double? totalWt;
  final int? employeeCode;
  final int? signerCode;
  final int? remarksCode;
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
  final num? length;
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
  final int? charniCode;
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
  final List<Map<String, dynamic>>? sarinData;
  final dynamic ArticalName;
  final String? purityName;
  final String? colorName;
  final String? charniName;
  final String? shapeName;
  final String? polishName;
  final String? symmetryName;
  final String? fluoName;
  final int? polishCode;
  final int? symmetryCode;
  final int? fluoCode;
  final double? height;

  int? get PacketMstID => packetMstID;

  const RepairIssueDetModel({
    this.spkDeptIssDetID,
    this.spkDeptIssMstID,
    this.packetMstID,
    this.srno,
    this.id,
    this.jno,
    this.bCode,
    this.pktNo,
    this.cutNo,
    this.clvCut,
    this.length,
    this.height,
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
    this.polishCode,
    this.symmetryCode,
    this.fluoCode,
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
    this.ArticalName,
    this.purityName,
    this.colorName,
    this.charniName,
    this.shapeName,
    this.polishName,
    this.symmetryName,
    this.fluoName, this.NewIssMstID,
  });

  factory RepairIssueDetModel.fromJson(Map<String, dynamic> json) => RepairIssueDetModel(
        spkDeptIssDetID: json['SpkDeptIssDetID'] ?? json['spkDeptIssDetID'],
        spkDeptIssMstID: json['SpkDeptIssMstID'] ?? json['spkDeptIssMstID'],
    NewIssMstID: json['NewIssMstID'] ?? 0,
        packetMstID: json['PacketMstID'] ?? json['packetMstID'] ?? json['JobWorkRecDetID'] ?? json['SpkDeptIssDetID'] ?? json['PacketDetID'],
        srno: json['Srno'] ?? json['srno'],
        id: json['Id'] ?? json['id'] ?? json['JobWorkRecDetID'],
        jno: json['Jno'] ?? json['jno'],
        bCode: json['BCode']?.toString() ?? json['bCode']?.toString(),
        pktNo: json['PktNo']?.toString() ?? json['pktNo']?.toString(),
        cutNo: json['CutNo']?.toString() ?? json['cutNo']?.toString() ?? json['MfgCut']?.toString(),
        clvCut: json['ClvCut']?.toString() ?? json['clvCut']?.toString(),
        length: json['Length'] ?? json['length'],
        height: (json['Height'] as num?)?.toDouble() ?? (json['height'] as num?)?.toDouble(),
        fromDeptCode: json['FromDeptCode'],
        toDeptCode: json['ToDeptCode'],
        fromCrId: json['FromCrId'],
        toCrId: json['ToCrId'],
        deptProcessCode: json['DeptProcessCode'],
        pc: json['Pc'] ?? json['pc'],
        wt: (json['Wt'] as num?)?.toDouble() ?? (json['wt'] as num?)?.toDouble(),
        issPc: json['IssPc'] ?? json['issPc'] ?? json['RecPc'] ?? json['pc'],
        issWt: (json['IssWt'] as num?)?.toDouble() ?? (json['issWt'] as num?)?.toDouble() ?? (json['RecWt'] as num?)?.toDouble() ?? (json['Wt'] as num?)?.toDouble(),
        recPc: json['RecPc'] ?? json['recPc'],
        recWt: (json['RecWt'] as num?)?.toDouble() ?? (json['recWt'] as num?)?.toDouble(),
        dmWt: (json['DmWt'] as num?)?.toDouble() ?? (json['dmWt'] as num?)?.toDouble(),

        dmPer: (json['DmPer'] as num?)?.toDouble(),
        kPc: json['KPc'],
        kWt: (json['KWt'] as num?)?.toDouble(),
        brPc: json['BrPc'],
        brWt: (json['BrWt'] as num?)?.toDouble(),
        lossPc: json['LossPc'],
        lossWt: (json['LossWt'] as num?)?.toDouble(),
        lossPer: (json['LossPer'] as num?)?.toDouble(),
        topsPc: json['TopsPc'],
        topsWt: (json['TopsWt'] as num?)?.toDouble(),
        totalPc: json['TotalPc'],
        totalWt: (json['TotalWt'] as num?)?.toDouble(),
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
        confRec: json['ConfRec'],
        recDate: json['RecDate'],
        recTime: json['RecTime'],
        lastDetID: json['LastDetID'],
        entryType: json['EntryType'],
        kachaRec: json['KachaRec'],
        subPktCreate: json['SubPktCreate'],
        spkPlanningDetID: json['SpkPlanningDetID'],
        pktType: json['PktType'],
        formType: json['FormType'],
        clvRec: json['ClvRec'],
        size: (json['Size'] as num?)?.toDouble(),
        jnoRecPc: json['JnoRecPc'],
        partName: json['PartName'],
        shapeCode: json['ShapeCode'],
        cutCode: json['CutCode'],
        purityCode: json['PurityCode'],
        colorCode: json['ColorCode'],
        polishCode: json['PolishCode'] ?? json['polishCode'],
        symmetryCode: json['SymmetryCode'] ?? json['symmetryCode'],
        fluoCode: json['FluoCode'] ?? json['fluoCode'],
        diam: (json['Diam'] as num?)?.toDouble(),
        acuraecy: (json['Acuraecy'] as num?)?.toDouble(),
        amt: (json['Amt'] as num?)?.toDouble(),
        manualAuto: json['ManualAuto'],
        qrCode: json['QrCode'],
        checkerCrId: json['CheckerCrId'],
        signerCrId: json['SignerCrId'],
        plDmWt: (json['PlDmWt'] as num?)?.toDouble(),
        plDmPer: (json['PlDmPer'] as num?)?.toDouble(),
        diffDmWt: (json['DiffDmWt'] as num?)?.toDouble(),
        charniCode: json['CharniCode'],
        mackRoughWt: (json['MackRoughWt'] as num?)?.toDouble(),
        rateRs: (json['RateRs'] as num?)?.toDouble(),
        amountRs: (json['AmountRs'] as num?)?.toDouble(),
        rateID: json['RateID']?.toString(),
        rateon: json['Rateon']?.toString(),
        rate: (json['Rate'] as num?)?.toDouble(),
        amount: (json['Amount'] as num?)?.toDouble(),
        ratio: (json['Ratio'] as num?)?.toDouble(),
        pcName: json['PcName'],
        machineSrNo: json['MachineSrNo'],
        userName: json['UserName'],
        crHeightMM: (json['CrHeightMM'] as num?)?.toDouble(),
        crHeightPer: (json['CrHeightPer'] as num?)?.toDouble(),
        crAng: (json['CrAng'] as num?)?.toDouble(),
        totDepthMM: (json['TotDepthMM'] as num?)?.toDouble(),
        totDepthPer: (json['TotDepthPer'] as num?)?.toDouble(),
        pavDepthMM: (json['PavDepthMM'] as num?)?.toDouble(),
        pavDepthPer: (json['PavDepthPer'] as num?)?.toDouble(),
        pavAng: (json['PavAng'] as num?)?.toDouble(),
        gridleMM: (json['GridleMM'] as num?)?.toDouble(),
        gridlePer: (json['GridlePer'] as num?)?.toDouble(),
        tableMM: (json['TableMM'] as num?)?.toDouble(),
        tablePer: (json['TablePer'] as num?)?.toDouble(),
        tilt: json['Tilt'],
        stoneNo: json['StoneNo'],
        nukDeptCode: json['NukDeptCode'],
        nukRemarks: json['NukRemarks'],
        diffRgPc: json['DiffRgPc'],
        diffRgWt: (json['DiffRgWt'] as num?)?.toDouble(),
        diffPoWt: (json['DiffPoWt'] as num?)?.toDouble(),
        diffAmt: (json['DiffAmt'] as num?)?.toDouble(),
        remarks: json['Remarks'],
        oldDeptIssMstID: json['OldDeptIssMstID'],
        nukTopPc: json['NukTopPc'],
        nukTopWt: (json['NukTopWt'] as num?)?.toDouble(),
        nukAmt: (json['NukAmt'] as num?)?.toDouble(),
        oldShapeCode: json['OldShapeCode'],
        oldColorCode: json['OldColorCode'],
        oldPurityCode: json['OldPurityCode'],
        jobJno: json['JobJno'],
        jobBCode: json['JobBCode'],
        rRateID: json['RRateID']?.toString(),
        rRateon: json['RRateon']?.toString(),
        rRate: (json['RRate'] as num?)?.toDouble(),
        rAmount: (json['RAmount'] as num?)?.toDouble(),
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
        tableDiam: (json['TableDiam'] as num?)?.toDouble(),
        dmDiam: (json['DmDiam'] as num?)?.toDouble(),
        optRateOn: json['OptRateOn'],
        optRateID: json['OptRateID'],
        optRate: (json['OptRate'] as num?)?.toDouble(),
        optAmount: (json['OptAmount'] as num?)?.toDouble(),
        lsAmount: (json['LsAmount'] as num?)?.toDouble(),
        orderMstID: json['OrderMstID'],
        ArticalName: json['ArticalName'] ?? json['articalName'],
        purityName: json['PurityName']?.toString() ?? json['purityName']?.toString(),
        colorName: json['ColorName']?.toString() ?? json['colorName']?.toString(),
        charniName: json['CharniName']?.toString() ?? json['charniName']?.toString(),
        shapeName: json['ShapeName']?.toString() ?? json['shapeName']?.toString(),
        polishName: json['PolishName']?.toString() ?? json['polishName']?.toString(),
        symmetryName: json['SymmetryName']?.toString() ?? json['symmetryName']?.toString(),
        fluoName: json['FluoName']?.toString() ?? json['fluoName']?.toString(),
      );


  Map<String, dynamic> toJson() => {
        'SpkDeptIssDetID': spkDeptIssDetID,
        'SpkDeptIssMstID': spkDeptIssMstID,
        'PacketMstID': packetMstID,
        'NewIssMstID': NewIssMstID,
        'Srno': srno,
        'Id': id,
        'Jno': jno,
        'BCode': bCode,
        'PktNo': pktNo,
        'CutNo': cutNo,
        'ClvCut': clvCut,
        'Length': length,
        'Height': height,
        'FromDeptCode': fromDeptCode,
        'ToDeptCode': toDeptCode,
        'FromCrId': fromCrId,
        'ToCrId': toCrId,
        'DeptProcessCode': deptProcessCode,
        'Pc': pc,
        'Wt': wt,
        'IssPc': issPc,
        'IssWt': issWt,
        'RecPc': recPc,
        'RecWt': recWt,
        'DmWt': dmWt,
        'DmPer': dmPer,
        'KPc': kPc,
        'KWt': kWt,
        'BrPc': brPc,
        'BrWt': brWt,
        'LossPc': lossPc,
        'LossWt': lossWt,
        'LossPer': lossPer,
        'TopsPc': topsPc,
        'TopsWt': topsWt,
        'TotalPc': totalPc,
        'TotalWt': totalWt,
        'EmployeeCode': employeeCode,
        'SignerCode': signerCode,
        'RemarksCode': remarksCode,
        'DueDay': dueDay,
        'ConfDate': confDate,
        'ConfTime': confTime,
        'ConfLogID': confLogID,
        'ConfPcID': confPcID,
        'ConfEver': confEver,
        'ConfCrID': confCrID,
        'ConfRec': confRec,
        'RecDate': recDate,
        'RecTime': recTime,
        'LastDetID': lastDetID,
        'EntryType': entryType,
        'KachaRec': kachaRec,
        'SubPktCreate': subPktCreate,
        'SpkPlanningDetID': spkPlanningDetID,
        'PktType': pktType,
        'FormType': formType,
        'ClvRec': clvRec,
        'Size': size,
        'JnoRecPc': jnoRecPc,
        'PartName': partName,
        'ShapeCode': shapeCode,
        'CutCode': cutCode,
        'PurityCode': purityCode,
        'ColorCode': colorCode,
        'PolishCode': polishCode,
        'SymmetryCode': symmetryCode,
        'FluoCode': fluoCode,
        'Diam': diam,
        'Acuraecy': acuraecy,
        'Amt': amt,
        'ManualAuto': manualAuto,
        'QrCode': qrCode,
        'CheckerCrId': checkerCrId,
        'SignerCrId': signerCrId,
        'PlDmWt': plDmWt,
        'PlDmPer': plDmPer,
        'DiffDmWt': diffDmWt,
        'CharniCode': charniCode,
        'MackRoughWt': mackRoughWt,
        'RateRs': rateRs,
        'AmountRs': amountRs,
        'RateID': rateID,
        'Rateon': rateon,
        'Rate': rate,
        'Amount': amount,
        'Ratio': ratio,
        'PcName': pcName,
        'MachineSrNo': machineSrNo,
        'UserName': userName,
        'CrHeightMM': crHeightMM,
        'CrHeightPer': crHeightPer,
        'CrAng': crAng,
        'TotDepthMM': totDepthMM,
        'TotDepthPer': totDepthPer,
        'PavDepthMM': pavDepthMM,
        'PavDepthPer': pavDepthPer,
        'PavAng': pavAng,
        'GridleMM': gridleMM,
        'GridlePer': gridlePer,
        'TableMM': tableMM,
        'TablePer': tablePer,
        'Tilt': tilt,
        'StoneNo': stoneNo,
        'NukDeptCode': nukDeptCode,
        'NukRemarks': nukRemarks,
        'DiffRgPc': diffRgPc,
        'DiffRgWt': diffRgWt,
        'DiffPoWt': diffPoWt,
        'DiffAmt': diffAmt,
        'Remarks': remarks,
        'OldDeptIssMstID': oldDeptIssMstID,
        'NukTopPc': nukTopPc,
        'NukTopWt': nukTopWt,
        'NukAmt': nukAmt,
        'OldShapeCode': oldShapeCode,
        'OldColorCode': oldColorCode,
        'OldPurityCode': oldPurityCode,
        'JobJno': jobJno,
        'JobBCode': jobBCode,
        'RRateID': rRateID,
        'RRateon': rRateon,
        'RRate': rRate,
        'RAmount': rAmount,
        'FType': fType,
        'PktValid': pktValid,
        'InValidReason': inValidReason,
        'HighLightEntry': highLightEntry,
        'TensionsCode': tensionsCode,
        'PlanSignerCrID': planSignerCrID,
        'SarinOpt': sarinOpt,
        'SarinMachine': sarinMachine,
        'OptDate': optDate,
        'OptStartTime': optStartTime,
        'OptEndTime': optEndTime,
        'OptDiffTime': optDiffTime,
        'OptEmpCode': optEmpCode,
        'TableDiam': tableDiam,
        'DmDiam': dmDiam,
        'OptRateOn': optRateOn,
        'OptRateID': optRateID,
        'OptRate': optRate,
        'OptAmount': optAmount,
        'LsAmount': lsAmount,
        'OrderMstID': orderMstID,
        'sarinData': sarinData,
        'ArticalName': ArticalName,
      };

  Map<String, dynamic> toTableRow() => {
        'bCode': bCode ?? '',
        'pktNo': pktNo ?? '',
        'cutNo': cutNo ?? '',
        'clvCut': clvCut ?? '',
        'pc': pc ?? 0,
        'wt': wt != null ? wt!.toStringAsFixed(3) : '0.000',
        'issPc': issPc ?? 0,
        'issWt': issWt != null ? issWt!.toStringAsFixed(3) : '0.000',
        'recPc': recPc ?? 0,
        'recWt': recWt != null ? recWt!.toStringAsFixed(3) : '0.000',
        'remarks': remarks ?? '',
      };
}

// ─────────────────────────────────────────────────────────────────────────────
//  RepairIssueSummaryModel & SummaryRow
// ─────────────────────────────────────────────────────────────────────────────
class RepairIssueSummaryModel {
  final List<RepairIssueSummaryRow> summary;

  const RepairIssueSummaryModel({required this.summary});

  factory RepairIssueSummaryModel.fromJson(Map<String, dynamic> json) {
    final list = json['data'] as List? ?? json['summary'] as List? ?? [];
    return RepairIssueSummaryModel(
      summary: list
          .map((e) => RepairIssueSummaryRow.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class RepairIssueSummaryRow {
  final String? groupName;
  final int? pkt;
  final int? pc;
  final double? wt;
  final int? issPc;
  final double? issWt;
  final String cutNo;
  final String articalName;
  final int totalPkt;
  final String size;
  final int totalPc;
  final double totalWt;
  final bool isGrandTotal;

  const RepairIssueSummaryRow({
    this.groupName,
    this.pkt,
    this.pc,
    this.wt,
    this.issPc,
    this.issWt,
    this.cutNo = '',
    this.articalName = '',
    this.totalPkt = 0,
    this.size = '',
    this.totalPc = 0,
    this.totalWt = 0.0,
    this.isGrandTotal = false,
  });

  factory RepairIssueSummaryRow.fromJson(Map<String, dynamic> json) {
    return RepairIssueSummaryRow(
      groupName: json['GroupName']?.toString() ?? json['groupName']?.toString(),
      pkt: json['Pkt'] ?? json['pkt'],
      pc: json['Pc'] ?? json['pc'],
      wt: (json['Wt'] as num?)?.toDouble(),
      issPc: json['IssPc'] ?? json['issPc'],
      issWt: (json['IssWt'] as num?)?.toDouble(),
      cutNo: json['CutNo']?.toString() ?? json['cutNo']?.toString() ?? json['GroupName']?.toString() ?? '',
      articalName: json['ArticalName']?.toString() ?? json['articalName']?.toString() ?? '',
      totalPkt: json['TotalPkt'] ?? json['totalPkt'] ?? json['Pkt'] ?? json['pkt'] ?? 0,
      size: json['Size']?.toString() ?? json['size']?.toString() ?? '',
      totalPc: json['TotalPc'] ?? json['totalPc'] ?? json['IssPc'] ?? json['issPc'] ?? json['Pc'] ?? json['pc'] ?? 0,
      totalWt: (json['TotalWt'] ?? json['totalWt'] ?? json['IssWt'] ?? json['issWt'] ?? json['Wt'] ?? json['wt'] ?? 0) is double
          ? (json['TotalWt'] ?? json['totalWt'] ?? json['IssWt'] ?? json['issWt'] ?? json['Wt'] ?? json['wt'] ?? 0) as double
          : ((json['TotalWt'] ?? json['totalWt'] ?? json['IssWt'] ?? json['issWt'] ?? json['Wt'] ?? json['wt'] ?? 0) as num).toDouble(),
      isGrandTotal: json['IsGrandTotal'] == true || json['isGrandTotal'] == true,
    );
  }
}

