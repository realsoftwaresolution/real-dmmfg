// lib/models/clv_rate_model.dart
import '../utils/helper_functions.dart';

class ClvRateModel {
  final int? clvRateMstID;
  final int? clvRateCode;
  final int? crId;
  final int? deptCode;
  final int? deptProcessCode;
  final int? rateID;
  final String? rateOn;
  final String? rateSizeOn;
  final double? fromWt;
  final double? toWt;
  final double? rate;
  final double? repairRate;
  final double? pieRate;
  final double? lsRate;
  final double? bonus;
  final double? repairBonus;
  final double? ever;
  final int? sortID;
  final bool? active;
  final int? remarksCode;
  final int? shapeCode;
  final String? type;
  final int? companyCode;
  final String? companyName;
  final String? crName;
  final String? deptName;
  final String? deptProcessName;
  final String? shapeName;
  final String? remarksName;

  ClvRateModel({
    this.clvRateMstID,
    this.clvRateCode,
    this.crId,
    this.deptCode,
    this.deptProcessCode,
    this.rateID,
    this.rateOn,
    this.rateSizeOn,
    this.fromWt,
    this.toWt,
    this.rate,
    this.repairRate,
    this.pieRate,
    this.lsRate,
    this.bonus,
    this.repairBonus,
    this.ever,
    this.sortID,
    this.active,
    this.remarksCode,
    this.shapeCode,
    this.type,
    this.companyCode,
    this.companyName,
    this.crName,
    this.deptName,
    this.deptProcessName,
    this.shapeName,
    this.remarksName,
  });

  factory ClvRateModel.fromJson(Map<String, dynamic> json) {
    return ClvRateModel(
      clvRateMstID: json['ClvProcessRateMstID'],
      clvRateCode: json['ClvProcessRateCode'],
      crId: json['CrId'],
      deptCode: json['DeptCode'],
      deptProcessCode: json['DeptProcessCode'],
      rateID: json['RateID'],
      rateOn: json['Rateon'] ?? json['RateOn'],
      rateSizeOn: json['RateSizeOn'],
      fromWt: parseDouble(json['FromWt']),
      toWt: parseDouble(json['ToWt']),
      rate: parseDouble(json['Rate']),
      repairRate: parseDouble(json['RepairRate']),
      pieRate: parseDouble(json['PieRate']),
      lsRate: parseDouble(json['LSRate']),
      bonus: parseDouble(json['Bonus']),
      repairBonus: parseDouble(json['RepairBonus']),
      ever: parseDouble(json['Ever']),
      sortID: json['SortID'],
      active: json['Active'] == true,
      remarksCode: json['RemarksCode'],
      shapeCode: json['ShapeCode'],
      type: json['Type'],
      companyCode: json['CompanyCode'],
      companyName: json['CompanyName'],
      crName: json['CrName'],
      deptName: json['DeptName'],
      deptProcessName: json['DeptProcessName'],
      shapeName: json['ShapeName'],
      remarksName: json['RemarksName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ClvProcessRateMstID': clvRateMstID,
      'ClvProcessRateCode': clvRateCode,
      'CrId': crId,
      'DeptCode': deptCode,
      'DeptProcessCode': deptProcessCode,
      'RateID': rateID,
      'Rateon': rateOn,
      'RateSizeOn': rateSizeOn,
      'FromWt': fromWt,
      'ToWt': toWt,
      'Rate': rate,
      'RepairRate': repairRate,
      'PieRate': pieRate,
      'LSRate': lsRate,
      'Bonus': bonus,
      'RepairBonus': repairBonus,
      'Ever': ever,
      'SortID': sortID,
      'Active': active,
      'RemarksCode': remarksCode,
      'ShapeCode': shapeCode,
      'Type': type,
      'CompanyCode': companyCode,
    };
  }

  /// Convert to a map suited for ErpDataTable display. Keys should match columns used in the screen.
  Map<String, dynamic> toTableRow() {
    return {
      '_raw': this,
      'clvProcessRateMstID': clvRateMstID,
      'clvProcessRateCode': clvRateCode?.toString() ?? '',
      'companyName': companyName ?? '',
      'crName': crName ?? '',
      'deptName': deptName ?? '',
      'deptProcessName': deptProcessName ?? '',
      'shapeName': shapeName ?? '',
      'type': type ?? '',
      'rateOn': rateOn ?? '',
      'rateSizeOn': rateSizeOn.toString().trim() ?? '',
      'fromWt': fromWt != null ? fromWt!.toStringAsFixed(3) : '',
      'toWt': toWt != null ? toWt!.toStringAsFixed(3) : '',
      'rate': rate != null ? rate!.toStringAsFixed(2) : '',
      'repairRate': repairRate != null ? repairRate!.toStringAsFixed(2) : '',
      'pieRate': pieRate != null ? pieRate!.toStringAsFixed(2) : '',
      'lsRate': lsRate != null ? lsRate!.toStringAsFixed(2) : '',
      'bonus': bonus != null ? bonus!.toStringAsFixed(2) : '',
      'repairBonus': repairBonus != null ? repairBonus!.toStringAsFixed(2) : '',
      'ever': ever != null ? ever!.toStringAsFixed(2) : '',
      'sortID': sortID?.toString() ?? '',
      'active': active == true ? '✓' : '',
      'remarksName': remarksName ?? '',
    };
  }
}

double? parseDouble(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is String) {
    try {
      return double.parse(v);
    } catch (_) {
      return null;
    }
  }
  return null;
}