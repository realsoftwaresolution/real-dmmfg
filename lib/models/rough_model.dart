class RoughModel {
  final int? roughMstID;
  final String? roughDate;
  final int? jno;
  final String? kapanNo;
  final String? site;
  final int? partyCode;
  final int? roughTypeCode;
  final int? articalCode;
  final int? jangadCharniCode;
  final double? rgExpPer;
  final double? rgExpAmt;
  final double? poExpPer;
  final double? poExpAmt;
  final double? rgSize;
  final double? rgSizeAmt;
  final double? poSize;
  final double? poSizeAmt;
  final double? lsPer;
  final double? lsAmt;
  final String? mainCutNo;
  final int? dueDay;
  final String? dueDate;
  final String? remarks;
  final double? totWt;
  final String? inv;
  final double? exRate;
  final double? rateDollar;
  final double? amtDollar;
  final double? rateRs;
  final double? amtRs;
  final List<RoughDetModel> details;
  final List<RoughProcessDaysModel> processDays;
  final int? totPcDb;


  RoughModel({
    this.roughMstID,
    this.roughDate,
    this.jno,
    this.totPcDb,

    this.kapanNo,
    this.site,
    this.partyCode,
    this.roughTypeCode,
    this.articalCode,
    this.jangadCharniCode,
    this.rgExpPer,
    this.rgExpAmt,
    this.poExpPer,
    this.poExpAmt,
    this.rgSize,
    this.rgSizeAmt,
    this.poSize,
    this.poSizeAmt,
    this.lsPer,
    this.lsAmt,
    this.mainCutNo,
    this.dueDay,
    this.dueDate,
    this.remarks,
    this.totWt,
    this.inv,
    this.exRate,
    this.rateDollar,
    this.amtDollar,
    this.rateRs,
    this.amtRs,
    this.details = const [],
    this.processDays = const [],
  });
  int get totPc => totPcDb ?? details.fold(0, (s, r) => s + (r.pc ?? 0));

  factory RoughModel.fromJson(Map<String, dynamic> json) => RoughModel(
    roughMstID: json['RoughMstID'],
    roughDate: json['RoughDate'],
    jno: json['Jno'],
    kapanNo: json['KapanNo'],
    site: json['Site'],
    partyCode: json['PartyCode'],
    roughTypeCode: json['RoughTypeCode'],
    articalCode: json['ArticalCode'],
    jangadCharniCode: json['JangadCharniCode'],
    rgExpPer: _toDouble(json['RgExpPer']),
    rgExpAmt: _toDouble(json['RgExpAmt']),
    poExpPer: _toDouble(json['PoExpPer']),
    poExpAmt: _toDouble(json['PoExpAmt']),
    rgSize: _toDouble(json['RgSize']),
    rgSizeAmt: _toDouble(json['RgSizeAmt']),
    poSize: _toDouble(json['PoSize']),
    poSizeAmt: _toDouble(json['PoSizeAmt']),
    lsPer: _toDouble(json['LsPer']),
    lsAmt: _toDouble(json['LsAmt']),
    mainCutNo: json['MainCutNo'],
    dueDay: json['DueDay'],
    dueDate: json['DueDate'],
    remarks: json['Remarks'],
    totWt: _toDouble(json['TotWt']),
    inv: json['Inv'],
    exRate: _toDouble(json['ExRate']),
    rateDollar: _toDouble(json['RateDollar']),
    amtDollar: _toDouble(json['AmtDollar']),
    rateRs: _toDouble(json['RateRs']),
    amtRs: _toDouble(json['AmtRs']),
    totPcDb: json['TotPc'] != null ? (json['TotPc'] as num).toInt() : null,

  );

  Map<String, dynamic> toJson() => {
    'RoughDate': roughDate,
    'Jno': jno,
    'KapanNo': kapanNo,
    'Site': site,
    'PartyCode': partyCode,
    'RoughTypeCode': roughTypeCode,
    'ArticalCode': articalCode,
    'JangadCharniCode': jangadCharniCode,
    'RgExpPer': rgExpPer,
    'RgExpAmt': rgExpAmt,
    'PoExpPer': poExpPer,
    'PoExpAmt': poExpAmt,
    'RgSize': rgSize,
    'RgSizeAmt': rgSizeAmt,
    'PoSize': poSize,
    'PoSizeAmt': poSizeAmt,
    'LsPer': lsPer,
    'LsAmt': lsAmt,
    'MainCutNo': mainCutNo,
    'DueDay': dueDay,
    'DueDate': dueDate,
    'Remarks': remarks,
    'TotWt': totWt,
    'Inv': inv,
    'ExRate': exRate,
    'RateDollar': rateDollar,
    'AmtDollar': amtDollar,
    'RateRs': rateRs,
    'AmtRs': amtRs,
  };

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString());
  }
}

class RoughDetModel {
  final int? roughDetID;
  final int? roughMstID;
  final int? srno;
  final int? charniCode;
  final String? charniName;
  final int? pc;
  final double? wt;
  final double? per;

  RoughDetModel({
    this.roughDetID,
    this.roughMstID,
    this.srno,
    this.charniCode,
    this.charniName,
    this.pc,
    this.wt,
    this.per,
  });

  factory RoughDetModel.fromJson(Map<String, dynamic> json) => RoughDetModel(
    roughDetID: json['RoughDetID'],
    roughMstID: json['RoughMstID'],
    srno: json['Srno'],
    charniCode: json['CharniCode'],
    charniName: json['CharniName'],
    pc: json['Pc'],
    wt: _toDouble(json['Wt']),
    per: _toDouble(json['Per']),
  );

  Map<String, dynamic> toJson() => {
    'RoughMstID': roughMstID,
    'Srno': srno,
    'CharniCode': charniCode,
    'Pc': pc,
    'Wt': wt,
    'Per': per,
  };

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString());
  }
}

class RoughProcessDaysModel {
  final int? roughEntryProcessDaysDetID;
  final int? roughMstID;
  final int? srno;
  final int? stockTypeCode;
  final String? stockTypeName;
  final double? days;

  RoughProcessDaysModel({
    this.roughEntryProcessDaysDetID,
    this.roughMstID,
    this.srno,
    this.stockTypeCode,
    this.stockTypeName,
    this.days,
  });

  factory RoughProcessDaysModel.fromJson(Map<String, dynamic> json) =>
      RoughProcessDaysModel(
        roughEntryProcessDaysDetID: json['RoughEntryProcessDaysDetID'],
        roughMstID: json['RoughMstID'],
        srno: json['Srno'],
        stockTypeCode: json['StockTypeCode'],
        stockTypeName: json['StockTypeName'],
        days: _toDouble(json['Days']),
      );

  Map<String, dynamic> toJson() => {
    'RoughMstID': roughMstID,
    'Srno': srno,
    'StockTypeCode': stockTypeCode,
    'Days': days,
  };

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString());
  }
}
