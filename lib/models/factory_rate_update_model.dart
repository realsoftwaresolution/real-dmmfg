class FactoryRateUpdateModel {
  int? factoryRecDetID;
  int? factoryRecMstID;
  int? srno;
  int? jno;

  String? cutNo;
  String? mfgCut;

  int? bCode;
  String? pktNo;

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

  double? dmWt;
  double? dmPer;
  double? size;

  double? recPer;
  double? diffPer;
  double? diffWt;

  int? factoryJamaDetID;

  String? factRec;

  String? rateID;
  String? rateon;
  double? rate;
  double? amount;

  int? cutCode;
  double? amountRs;

  String? checkerRec;

  int? fromCrID;
  int? lastCrID;
  int? polishCheckerRecMstID;
  int? crID;

  int? factoryIssDetID;

  double? diam;

  String? qrCode;

  int? orderMstID;

  double? length;
  double? height;

  int? polishCode;
  int? symmetryCode;
  int? fluoCode;

  int? pairNo;
  int? tensionsCode;

  String? topSide;

  int? markerMstID;

  int? fcIntentCode;
  int? fcOverCode;
  int? fColorCode1;
  int? fColorCode2;

  String? ha;
  String? groupType;

  double? sellRate;
  double? sellAmount;
  String? sellCode;

  FactoryRateUpdateModel();

  factory FactoryRateUpdateModel.fromJson(Map<String, dynamic> json) {
    return FactoryRateUpdateModel()
      ..factoryRecDetID = json['FactoryRecDetID']
      ..factoryRecMstID = json['FactoryRecMstID']
      ..srno = json['Srno']
      ..jno = json['Jno']
      ..cutNo = json['CutNo']
      ..mfgCut = json['MfgCut']
      ..bCode = json['BCode']
      ..pktNo = json['PktNo']
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
      ..dmWt = (json['DmWt'] as num?)?.toDouble()
      ..dmPer = (json['DmPer'] as num?)?.toDouble()
      ..size = (json['Size'] as num?)?.toDouble()
      ..recPer = (json['RecPer'] as num?)?.toDouble()
      ..diffPer = (json['DiffPer'] as num?)?.toDouble()
      ..diffWt = (json['DiffWt'] as num?)?.toDouble()
      ..factoryJamaDetID = json['FactoryJamaDetID']
      ..factRec = json['FactRec']
      ..rateID = json['RateID']?.toString()
      ..rateon = json['Rateon']
      ..rate = (json['Rate'] as num?)?.toDouble()
      ..amount = (json['Amount'] as num?)?.toDouble()
      ..cutCode = json['CutCode']
      ..amountRs = (json['AmountRs'] as num?)?.toDouble()
      ..checkerRec = json['CheckerRec']
      ..fromCrID = json['FromCrID']
      ..lastCrID = json['LastCrID']
      ..polishCheckerRecMstID = json['PolishCheckerRecMstID']
      ..crID = json['CrID']
      ..factoryIssDetID = json['FactoryIssDetID']
      ..diam = (json['Diam'] as num?)?.toDouble()
      ..qrCode = json['QRCode']
      ..orderMstID = json['OrderMstID']
      ..length = (json['Length'] as num?)?.toDouble()
      ..height = (json['Height'] as num?)?.toDouble()
      ..polishCode = json['PolishCode']
      ..symmetryCode = json['SymmetryCode']
      ..fluoCode = json['FluoCode']
      ..pairNo = json['PairNo']
      ..tensionsCode = json['TensionsCode']
      ..topSide = json['TopSide']
      ..markerMstID = json['MarkerMstID']
      ..fcIntentCode = json['FcIntentCode']
      ..fcOverCode = json['FcOverCode']
      ..fColorCode1 = json['FColorCode1']
      ..fColorCode2 = json['FColorCode2']
      ..ha = json['HA']
      ..groupType = json['GroupType']
      ..sellRate = (json['SellRate'] as num?)?.toDouble()
      ..sellAmount = (json['SellAmount'] as num?)?.toDouble()
      ..sellCode = json['SellCode'];
  }

  Map<String, dynamic> toJson() => {
    'FactoryRecDetID': factoryRecDetID,
    'FactoryRecMstID': factoryRecMstID,
    'Srno': srno,
    'Jno': jno,
    'CutNo': cutNo,
    'MfgCut': mfgCut,
    'BCode': bCode,
    'PktNo': pktNo,
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
    'DmWt': dmWt,
    'DmPer': dmPer,
    'Size': size,
    'RecPer': recPer,
    'DiffPer': diffPer,
    'DiffWt': diffWt,
    'FactoryJamaDetID': factoryJamaDetID,
    'FactRec': factRec,
    'RateID': rateID,
    'Rateon': rateon,
    'Rate': rate,
    'Amount': amount,
    'CutCode': cutCode,
    'AmountRs': amountRs,
    'CheckerRec': checkerRec,
    'FromCrID': fromCrID,
    'LastCrID': lastCrID,
    'PolishCheckerRecMstID': polishCheckerRecMstID,
    'CrID': crID,
    'FactoryIssDetID': factoryIssDetID,
    'Diam': diam,
    'QRCode': qrCode,
    'OrderMstID': orderMstID,
    'Length': length,
    'Height': height,
    'PolishCode': polishCode,
    'SymmetryCode': symmetryCode,
    'FluoCode': fluoCode,
    'PairNo': pairNo,
    'TensionsCode': tensionsCode,
    'TopSide': topSide,
    'MarkerMstID': markerMstID,
    'FcIntentCode': fcIntentCode,
    'FcOverCode': fcOverCode,
    'FColorCode1': fColorCode1,
    'FColorCode2': fColorCode2,
    'HA': ha,
    'GroupType': groupType,
    'SellRate': sellRate,
    'SellAmount': sellAmount,
    'SellCode': sellCode,
  };
}