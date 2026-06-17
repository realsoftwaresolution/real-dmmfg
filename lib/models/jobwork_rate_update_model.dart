class JobWorkRateUpdateModel {
  int? jobWorkRecDetID;
  int? jobWorkRecMstID;

  int? jno;
  String? cutNo;
  String? mfgCut;
  int? srno;

  int? bCode;
  String? pktNo;
  int? pairNo;

  int? pc;
  double? wt;

  int? issPc;
  double? issWt;

  int? recPc;
  double? recWt;

  int? kPc;
  double? kWt;

  int? brPc;
  double? brWt;

  int? lossPc;
  double? lossWt;

  int? purityCode;
  int? charniCode;
  int? colorCode;
  int? shapeCode;
  int? cutCode;

  double? dmWt;
  double? dmPer;
  double? size;

  double? recPer;
  double? diffPer;
  double? diffWt;

  String? jobRec;

  String? rateID;
  String? rateon;
  double? rate;
  double? amount;
  double? amountRs;

  int? polishCheckerRecMstID;
  int? orderMstID;
  int? markerMstID;

  int? fromCrID;
  int? lastCrID;
  int? crID;

  double? diam;

  double? length;
  double? height;

  int? polishCode;
  int? symmetryCode;
  int? fluoCode;
  int? tensionsCode;

  String? qrCode;
  String? topSide;

  int? fcIntentCode;
  int? fcOverCode;
  int? fColorCode1;
  int? fColorCode2;

  String? ha;

  int? partyMstID;
  int? deptCode;
  int? deptProcessCode;
  int? articalCode;

  String? status;

  JobWorkRateUpdateModel();

  factory JobWorkRateUpdateModel.fromJson(Map<String, dynamic> json) {
    return JobWorkRateUpdateModel()
      ..jobWorkRecDetID = json['JobWorkRecDetID']
      ..jobWorkRecMstID = json['JobWorkRecMstID']
      ..jno = json['Jno']
      ..cutNo = json['CutNo']
      ..mfgCut = json['MfgCut']
      ..srno = json['Srno']
      ..bCode = json['BCode']
      ..pktNo = json['PktNo']
      ..pairNo = json['PairNo']
      ..pc = json['Pc']
      ..wt = (json['Wt'] as num?)?.toDouble()
      ..issPc = json['IssPc']
      ..issWt = (json['IssWt'] as num?)?.toDouble()
      ..recPc = json['RecPc']
      ..recWt = (json['RecWt'] as num?)?.toDouble()
      ..kPc = json['KPc']
      ..kWt = (json['KWt'] as num?)?.toDouble()
      ..brPc = json['BrPc']
      ..brWt = (json['BrWt'] as num?)?.toDouble()
      ..lossPc = json['LossPc']
      ..lossWt = (json['LossWt'] as num?)?.toDouble()
      ..purityCode = json['PurityCode']
      ..charniCode = json['CharniCode']
      ..colorCode = json['ColorCode']
      ..shapeCode = json['ShapeCode']
      ..cutCode = json['CutCode']
      ..dmWt = (json['DmWt'] as num?)?.toDouble()
      ..dmPer = (json['DmPer'] as num?)?.toDouble()
      ..size = (json['Size'] as num?)?.toDouble()
      ..recPer = (json['RecPer'] as num?)?.toDouble()
      ..diffPer = (json['DiffPer'] as num?)?.toDouble()
      ..diffWt = (json['DiffWt'] as num?)?.toDouble()
      ..jobRec = json['JobRec']
      ..rateID = json['RateID']?.toString()
      ..rateon = json['Rateon']
      ..rate = (json['Rate'] as num?)?.toDouble()
      ..amount = (json['Amount'] as num?)?.toDouble()
      ..amountRs = (json['AmountRs'] as num?)?.toDouble()
      ..polishCheckerRecMstID = json['PolishCheckerRecMstID']
      ..orderMstID = json['OrderMstID']
      ..markerMstID = json['MarkerMstID']
      ..fromCrID = json['FromCrID']
      ..lastCrID = json['LastCrID']
      ..crID = json['CrID']
      ..diam = (json['Diam'] as num?)?.toDouble()
      ..length = (json['Length'] as num?)?.toDouble()
      ..height = (json['Height'] as num?)?.toDouble()
      ..polishCode = json['PolishCode']
      ..symmetryCode = json['SymmetryCode']
      ..fluoCode = json['FluoCode']
      ..tensionsCode = json['TensionsCode']
      ..qrCode = json['QRCode']
      ..topSide = json['TopSide']
      ..fcIntentCode = json['FcIntentCode']
      ..fcOverCode = json['FcOverCode']
      ..fColorCode1 = json['FColorCode1']
      ..fColorCode2 = json['FColorCode2']
      ..ha = json['HA']
      ..partyMstID = json['PartyMstID']
      ..deptCode = json['DeptCode']
      ..deptProcessCode = json['DeptProcessCode']
      ..articalCode = json['ArticalCode']
      ..status = json['Status'];
  }

  Map<String, dynamic> toJson() => {
    'JobWorkRecDetID': jobWorkRecDetID,
    'JobWorkRecMstID': jobWorkRecMstID,
    'Jno': jno,
    'CutNo': cutNo,
    'MfgCut': mfgCut,
    'Srno': srno,
    'BCode': bCode,
    'PktNo': pktNo,
    'PairNo': pairNo,
    'Pc': pc,
    'Wt': wt,
    'IssPc': issPc,
    'IssWt': issWt,
    'RecPc': recPc,
    'RecWt': recWt,
    'KPc': kPc,
    'KWt': kWt,
    'BrPc': brPc,
    'BrWt': brWt,
    'LossPc': lossPc,
    'LossWt': lossWt,
    'PurityCode': purityCode,
    'CharniCode': charniCode,
    'ColorCode': colorCode,
    'ShapeCode': shapeCode,
    'CutCode': cutCode,
    'DmWt': dmWt,
    'DmPer': dmPer,
    'Size': size,
    'RecPer': recPer,
    'DiffPer': diffPer,
    'DiffWt': diffWt,
    'JobRec': jobRec,
    'RateID': rateID,
    'Rateon': rateon,
    'Rate': rate,
    'Amount': amount,
    'AmountRs': amountRs,
    'PolishCheckerRecMstID': polishCheckerRecMstID,
    'OrderMstID': orderMstID,
    'MarkerMstID': markerMstID,
    'FromCrID': fromCrID,
    'LastCrID': lastCrID,
    'CrID': crID,
    'Diam': diam,
    'Length': length,
    'Height': height,
    'PolishCode': polishCode,
    'SymmetryCode': symmetryCode,
    'FluoCode': fluoCode,
    'TensionsCode': tensionsCode,
    'QRCode': qrCode,
    'TopSide': topSide,
    'FcIntentCode': fcIntentCode,
    'FcOverCode': fcOverCode,
    'FColorCode1': fColorCode1,
    'FColorCode2': fColorCode2,
    'HA': ha,
    'PartyMstID': partyMstID,
    'DeptCode': deptCode,
    'DeptProcessCode': deptProcessCode,
    'ArticalCode': articalCode,
    'Status': status,
  };
}