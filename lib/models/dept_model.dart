import 'package:diam_mfg/utils/helper_functions.dart';

class DeptModel {
  final int? deptMstID;
  final int? deptCode;
  final String? deptName;
  final int? deptGroupCode;
  final String? sflag;
  final String? sdate;
  final int? logID;
  final String? pcID;
  final int? ever;
  final int? companyCode;
  final int? sortID;
  final bool? active;
  final String? delRights;
  final bool? clvActive;
  final String? jnoCreate;
  final String? displayStock;
  final String? displayWt;
  final String? rateCalc;
  final String? cutwiseIss;
  final String? kbMinus;
  final bool? diaPcMinus;
  final String? rptDisp;
  final String? checker;
  final String? topsLock;
  final String? managerRate;
  final String? rateOnJanCharni;
  final String? rateOnCutMan;
  final String? rateSizeOn;
  final String? issToTblMan;
  final String? dashboardRpt;
  final String? mackCheck;
  final String? rateOnRgType;
  final String? rateOnTension;
  final String? wtLossCheckWith;
  final String? wtLossCheckWithRemarks;
  final String? rateOnLSPie;
  final String? salaryDeptName;
  final String? checkCharniSize;

  DeptModel({
    this.deptMstID,
    this.deptCode,
    this.deptName,
    this.deptGroupCode,
    this.sflag,
    this.sdate,
    this.logID,
    this.pcID,
    this.ever,
    this.companyCode,
    this.sortID,
    this.active,
    this.delRights,
    this.clvActive,
    this.jnoCreate,
    this.displayStock,
    this.displayWt,
    this.rateCalc,
    this.cutwiseIss,
    this.kbMinus,
    this.diaPcMinus,
    this.rptDisp,
    this.checker,
    this.topsLock,
    this.managerRate,
    this.rateOnJanCharni,
    this.rateOnCutMan,
    this.rateSizeOn,
    this.issToTblMan,
    this.dashboardRpt,
    this.mackCheck,
    this.rateOnRgType,
    this.rateOnTension,
    this.wtLossCheckWith,
    this.wtLossCheckWithRemarks,
    this.rateOnLSPie,
    this.salaryDeptName,
    this.checkCharniSize,
  });

  factory DeptModel.fromJson(Map<String, dynamic> json) {
    return DeptModel(
      deptMstID: json['DeptMstID'],
      deptCode: json['DeptCode'],
      deptName: json['DeptName'],
      deptGroupCode: json['DeptGroupCode'],
      sflag: json['Sflag'],
      sdate: json['Sdate']?.toString(),
      logID: json['LogID'],
      pcID: json['PcID'],
      ever: json['Ever'],
      companyCode: json['CompanyCode'],
      sortID: json['SortID'],
      active: json['Active'],
      delRights: json['DelRights'],
      clvActive: json['ClvActive'],
      jnoCreate: json['JnoCreate'],
      displayStock: json['DisplayStock'],
      displayWt: json['DisplayWt'],
      rateCalc: json['RateCalc'],
      cutwiseIss: json['CutwiseIss'],
      kbMinus: json['KBMinus'],
      diaPcMinus: json['DiaPcMinus'],
      rptDisp: json['RptDisp'],
      checker: json['Checker'],
      topsLock: json['TopsLock'],
      managerRate: json['ManagerRate'],
      rateOnJanCharni: json['RateOnJanCharni'],
      rateOnCutMan: json['RateOnCutMan'],
      rateSizeOn: json['RateSizeOn'],
      issToTblMan: json['IssToTblMan'],
      dashboardRpt: json['DashboardRpt'],
      mackCheck: json['MackCheck'],
      rateOnRgType: json['RateOnRgType'],
      rateOnTension: json['RateOnTension'],
      wtLossCheckWith: json['WtLossCheckWith'],
      wtLossCheckWithRemarks: json['WtLossCheckWithRemarks'],
      rateOnLSPie: json['RateOnLSPie'],
      salaryDeptName: json['SalaryDeptName'],
      checkCharniSize: json['CheckCharniSize'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'DeptCode': deptCode,
      'DeptName': deptName,
      'DeptGroupCode': deptGroupCode,
      'CompanyCode': companyCode,
      'SortID': sortID,
      'Active': active,
      'DelRights': delRights,
      'ClvActive': clvActive,
      'JnoCreate': jnoCreate,
      'DisplayStock': displayStock,
      'DisplayWt': displayWt,
      'RateCalc': rateCalc,
      'CutwiseIss': cutwiseIss,
      'KBMinus': kbMinus,
      'DiaPcMinus': diaPcMinus,
      'RptDisp': rptDisp,
      'Checker': checker,
      'TopsLock': topsLock,
      'ManagerRate': managerRate,
      'RateOnJanCharni': rateOnJanCharni,
      'RateOnCutMan': rateOnCutMan,
      'RateSizeOn': rateSizeOn,
      'IssToTblMan': issToTblMan,
      'DashboardRpt': dashboardRpt,
      'MackCheck': mackCheck,
      'RateOnRgType': rateOnRgType,
      'RateOnTension': rateOnTension,
      'WtLossCheckWith': wtLossCheckWith,
      'WtLossCheckWithRemarks': wtLossCheckWithRemarks,
      'RateOnLSPie': rateOnLSPie,
      'SalaryDeptName': salaryDeptName,
      'CheckCharniSize': checkCharniSize,
    };
  }

  Map<String, dynamic> toTableRow({String? companyName}) {
    return {
      'deptCode': deptCode,
      'deptName': deptName ?? '',
      'deptGroupCode': deptGroupCode?.toString() ?? '',
      'companyCode': companyName??companyCode?.toString() ?? '',
      'sortID': sortID?.toString() ?? '',
      'active': active == true ? 'Yes' : 'No',
      '_raw': this,
    };
  }

  static DeptModel fromFormValues(Map<String, dynamic> v) {
    return DeptModel(
      deptCode: int.tryParse(v['deptCode'] ?? ''),
      deptName: v['deptName'],
      deptGroupCode: int.tryParse(v['deptGroupCode'] ?? ''),
      companyCode: int.tryParse(v['companyCode'] ?? ''),
      sortID: int.tryParse(v['sortID'] ?? ''),
      active: parseBool(v['active']),
      // active: v['active'] == 'Y',
      delRights: parseYN(v['delRights']),
      // delRights: v['delRights'] ?? 'Y',
      clvActive: parseBool(v['clvActive']),
      // clvActive: v['clvActive'] == 'Y',
      jnoCreate: parseYN(v['jnoCreate']),
      // jnoCreate: v['jnoCreate'] ?? 'N',
      displayStock: v['displayStock'] ?? '',
      displayWt: v['displayWt'] ?? '',
      rateCalc: parseYN(v['rateCalc']),
      // rateCalc: v['rateCalc'] ?? 'N',
      cutwiseIss: parseYN(v['cutwiseIss']),
      // cutwiseIss: v['cutwiseIss'] ?? 'N',
      kbMinus: parseYN(v['kbMinus']),
      // kbMinus: v['kbMinus'] ?? 'N',
      diaPcMinus: parseBool(v['diaPcMinus']),
      // diaPcMinus: v['diaPcMinus'] == 'Y',
      rptDisp: v['rptDisp'] ?? '',
      // checker: v['checker'] ?? 'N',
      // topsLock: v['topsLock'] ?? 'N', 
      checker:  parseYN(v['checker']),
      topsLock: parseYN(v['topsLock']),
      managerRate: parseYN(v['managerRate']),
      // managerRate: v['managerRate'] ?? 'N',
      rateOnJanCharni: parseYN(v['rateOnJanCharni']),
      rateOnCutMan: parseYN(v['rateOnCutMan']),
      rateSizeOn: v['rateSizeOn'] ?? 'ISSWT',
      issToTblMan: parseYN(v['issToTblMan']),
      // issToTblMan: v['issToTblMan'] ?? 'N',
      dashboardRpt: v['dashboardRpt'] ?? 'CLEAVING',
      // mackCheck: v['mackCheck'] ?? 'N',
      mackCheck: parseYN(v['mackCheck']),
      rateOnRgType: parseYN(v['rateOnRgType']),
      rateOnTension: parseYN(v['rateOnTension']),
      wtLossCheckWith: v['wtLossCheckWith'] ?? 'ISSWT',
      // wtLossCheckWithRemarks: v['wtLossCheckWithRemarks'] ?? 'N',
      wtLossCheckWithRemarks: parseYN(v['wtLossCheckWithRemarks']),
      rateOnLSPie: parseYN(v['rateOnLSPie']),
      salaryDeptName: v['salaryDeptName'],
      checkCharniSize: v['checkCharniSize'] ?? 'ISSWT',
    );
  }
}