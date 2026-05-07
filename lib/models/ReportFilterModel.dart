class ReportFilterModel {
  final String? type;
  final String? sel;

  final String? dateFrom;
  final String? dateTo;

  final String? timeFrom;
  final String? timeTo;

  final String? finish;

  final String? mainCut;
  final String? kno;
  final String? cutNo;

  final String? fromMan;
  final String? toMan;

  final String? remarks;
  final String? process;
  final String? dept;

  final String? purity;
  final String? color;
  final String? tension;
  final String? shape;

  final String? repairing;
  final String? shift;

  final String? lotNo;
  final String? pktType;

  ReportFilterModel({
    this.type,
    this.sel,
    this.dateFrom,
    this.dateTo,
    this.timeFrom,
    this.timeTo,
    this.finish,
    this.mainCut,
    this.kno,
    this.cutNo,
    this.fromMan,
    this.toMan,
    this.remarks,
    this.process,
    this.dept,
    this.purity,
    this.color,
    this.tension,
    this.shape,
    this.repairing,
    this.shift,
    this.lotNo,
    this.pktType,
  });

  Map<String, dynamic> toJson() => {
    "Type": type,
    "Sel": sel,
    "DateFrom": dateFrom,
    "DateTo": dateTo,
    "TimeFrom": timeFrom,
    "TimeTo": timeTo,
    "Finish": finish,
    "MainCut": mainCut,
    "Kno": kno,
    "CutNo": cutNo,
    "FromMan": fromMan,
    "ToMan": toMan,
    "Remarks": remarks,
    "Process": process,
    "Dept": dept,
    "Purity": purity,
    "Color": color,
    "Tension": tension,
    "Shape": shape,
    "Repairing": repairing,
    "Shift": shift,
    "LotNo": lotNo,
    "PktType": pktType,
  };
}