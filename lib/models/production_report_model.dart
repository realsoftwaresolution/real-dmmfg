class ProductionReportModel {
  final int? deptCode;
  final String? deptName;
  final int? deptProcessCode;
  final String? processName;
  final String? managerName;
  final double totalPc;
  final double totalWt;

  final String? kapanNo;
  final int? roughMstID;

  final String? bCode;
  final String? cutNo;

  ProductionReportModel({
    this.deptCode,
    this.deptName,
    this.deptProcessCode,
    this.processName,
    this.managerName,
    this.totalPc = 0,
    this.totalWt = 0,
    this.kapanNo,
    this.roughMstID,
    this.bCode,
    this.cutNo,
  });

  factory ProductionReportModel.fromJson(Map<String, dynamic> json) {
    return ProductionReportModel(
      deptCode: json['DeptCode'],
      deptName: json['DeptName'],
      deptProcessCode: json['DeptProcessCode'],
      processName: json['ProcessName'],
      managerName: json['ManagerName'],
      totalPc: (json['TotalPc'] ?? 0).toDouble(),
      totalWt: (json['TotalWt'] ?? 0).toDouble(),
      kapanNo: json['KapanNo'],
      roughMstID: json['RoughMstID'],
      bCode: json['BCode'],
      cutNo: json['CutNo'],
    );
  }
}