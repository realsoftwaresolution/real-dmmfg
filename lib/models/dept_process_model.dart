import '../utils/helper_functions.dart';

class DeptProcessModel {
  final int? deptProcessMstID;
  final int? deptProcessCode;
  final String? deptProcessName;
  final int? deptCode;
  final String? sflag;
  final String? sdate;
  final int? logID;
  final String? pcID;
  final int? ever;
  final int? companyCode;
  final int? sortID;
  final bool? active;
  final String? delRights;
  final int? tops;
  final bool? machineActive;
  final bool? remarksSelect;
  final String? multiTimeIss;
  final bool? jnoRecPc;
  final bool? jnoKPc;
  final bool? jnoLastPc;
  final bool? lsMarkPc;
  final String? proDirectIss;
  final bool? diaPcMinus;
  final bool? jnoExtraPc;
  final String? remarksRate;
  final String? displayRatePc;
  final String? planCheck;
  final String? displayRemarks;
  final String? multiTimeDeptIss;
  final String? makableCheck;
  final String? remarksDisplay;
  final String? procCalcWt;
  final String? planPcAsRatePc;
  final String? rateOnShape;
  final String? stockType;
  final String? getSarinOptData;
  final int? stockTypeCode;
  final String? countInCostingProduction;
  final String? checkerPlanCheck;

  DeptProcessModel({
    this.deptProcessMstID,
    this.deptProcessCode,
    this.deptProcessName,
    this.deptCode,
    this.sflag,
    this.sdate,
    this.logID,
    this.pcID,
    this.ever,
    this.companyCode,
    this.sortID,
    this.active,
    this.delRights,
    this.tops,
    this.machineActive,
    this.remarksSelect,
    this.multiTimeIss,
    this.jnoRecPc,
    this.jnoKPc,
    this.jnoLastPc,
    this.lsMarkPc,
    this.proDirectIss,
    this.diaPcMinus,
    this.jnoExtraPc,
    this.remarksRate,
    this.displayRatePc,
    this.planCheck,
    this.displayRemarks,
    this.multiTimeDeptIss,
    this.makableCheck,
    this.remarksDisplay,
    this.procCalcWt,
    this.planPcAsRatePc,
    this.rateOnShape,
    this.stockType,
    this.getSarinOptData,
    this.stockTypeCode,
    this.countInCostingProduction,
    this.checkerPlanCheck,
  });

  factory DeptProcessModel.fromJson(Map<String, dynamic> json) {
    return DeptProcessModel(
      deptProcessMstID: json['DeptProcessMstID'],
      deptProcessCode: json['DeptProcessCode'],
      deptProcessName: json['DeptProcessName'],
      deptCode: json['DeptCode'],
      sflag: json['Sflag'],
      sdate: json['Sdate']?.toString(),
      logID: json['LogID'],
      pcID: json['PcID'],
      ever: json['Ever'],
      companyCode: json['CompanyCode'],
      sortID: json['SortID'],
      active: json['Active'],
      delRights: json['DelRights'],
      tops: json['Tops'],
      machineActive: json['MachineActive'],
      remarksSelect: json['RemarksSelect'],
      multiTimeIss: json['MultiTimeIss'],
      jnoRecPc: json['JnoRecPc'],
      jnoKPc: json['JnoKPc'],
      jnoLastPc: json['JnoLastPc'],
      lsMarkPc: json['LsMarkPc'],
      proDirectIss: json['PRODIRECTISS'],
      diaPcMinus: json['DiaPcMinus'],
      jnoExtraPc: json['JnoExtraPc'],
      remarksRate: json['RemarksRate'],
      displayRatePc: json['DisplayRatePc'],
      planCheck: json['PlanCheck'],
      displayRemarks: json['DisplayRemarks'],
      multiTimeDeptIss: json['MultiTimeDeptIss'],
      makableCheck: json['MakableCheck'],
      remarksDisplay: json['RemarksDisplay'],
      procCalcWt: json['ProcCalcWt'],
      planPcAsRatePc: json['PlanPcAsRatePc'],
      rateOnShape: json['RateOnShape'],
      stockType: json['StockType'],
      getSarinOptData: json['GetSarinOptData'],
      stockTypeCode: json['StockTypeCode'],
      countInCostingProduction: json['CountInCostingProduction'],
      checkerPlanCheck: json['CheckerPlanCheck'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'DeptProcessCode': deptProcessCode,
      'DeptProcessName': deptProcessName,
      'DeptCode': deptCode,
      'CompanyCode': companyCode,
      'SortID': sortID,
      'Active': active,
      'DelRights': delRights,
      'Tops': tops,
      'MachineActive': machineActive,
      'RemarksSelect': remarksSelect,
      'MultiTimeIss': multiTimeIss,
      'JnoRecPc': jnoRecPc,
      'JnoKPc': jnoKPc,
      'JnoLastPc': jnoLastPc,
      'LsMarkPc': lsMarkPc,
      'PRODIRECTISS': proDirectIss,
      'DiaPcMinus': diaPcMinus,
      'JnoExtraPc': jnoExtraPc,
      'RemarksRate': remarksRate,
      'DisplayRatePc': displayRatePc,
      'PlanCheck': planCheck,
      'DisplayRemarks': displayRemarks,
      'MultiTimeDeptIss': multiTimeDeptIss,
      'MakableCheck': makableCheck,
      'RemarksDisplay': remarksDisplay,
      'ProcCalcWt': procCalcWt,
      'PlanPcAsRatePc': planPcAsRatePc,
      'RateOnShape': rateOnShape,
      'StockType': stockType,
      'GetSarinOptData': getSarinOptData,
      'StockTypeCode': stockTypeCode,
      'CountInCostingProduction': countInCostingProduction,
      'CheckerPlanCheck': checkerPlanCheck,
    };
  }

  Map<String, dynamic> toTableRow({String? companyName}) {
    return {
      'deptProcessCode': deptProcessCode,
      'deptProcessName': deptProcessName ?? '',
      'deptCode': deptCode?.toString() ?? '',
      'companyCode':companyName?? companyCode?.toString() ?? '',
      'sortID': sortID?.toString() ?? '',
      'active': active == true ? 'Yes' : 'No',
      '_raw': this,
    };
  }

  static DeptProcessModel fromFormValues(Map<String, dynamic> v) {
    // return DeptProcessModel(
    //   deptProcessCode: int.tryParse(v['deptProcessCode'] ?? ''),
    //   deptProcessName: v['deptProcessName'],
    //   deptCode: int.tryParse(v['deptCode'] ?? ''),
    //   companyCode: int.tryParse(v['companyCode'] ?? ''),
    //   sortID: int.tryParse(v['sortID'] ?? ''),
    //   active: v['active'] == 'Y',
    //   delRights: v['delRights'] ?? 'Y',
    //   tops: int.tryParse(v['tops'] ?? '0') ?? 0,
    //   machineActive: v['machineActive'] == 'Y',
    //   remarksSelect: v['remarksSelect'] == 'Y',
    //   multiTimeIss: v['multiTimeIss'] ?? 'N',
    //   jnoRecPc: v['jnoRecPc'] == 'Y',
    //   jnoKPc: v['jnoKPc'] == 'Y',
    //   jnoLastPc: v['jnoLastPc'] == 'Y',
    //   lsMarkPc: v['lsMarkPc'] == 'Y',
    //   proDirectIss: v['proDirectIss'] ?? 'Y',
    //   diaPcMinus: v['diaPcMinus'] == 'Y',
    //   jnoExtraPc: v['jnoExtraPc'] == 'Y',
    //   remarksRate: v['remarksRate'] ?? 'N',
    //   displayRatePc: v['displayRatePc'] ?? 'N',
    //   planCheck: v['planCheck'] ?? 'N',
    //   displayRemarks: v['displayRemarks'] ?? 'N',
    //   multiTimeDeptIss: v['multiTimeDeptIss'] ?? 'N',
    //   makableCheck: v['makableCheck'] ?? 'N',
    //   remarksDisplay: v['remarksDisplay'] ?? 'N',
    //   procCalcWt: v['procCalcWt'] ?? 'N',
    //   planPcAsRatePc: v['planPcAsRatePc'],
    //   rateOnShape: v['rateOnShape'],
    //   stockType: v['stockType'],
    //   getSarinOptData: v['getSarinOptData'],
    //   stockTypeCode: int.tryParse(v['stockTypeCode'] ?? ''),
    //   countInCostingProduction: v['countInCostingProduction'] ?? 'N',
    //   checkerPlanCheck: v['checkerPlanCheck'] ?? 'N',
    // );

    return DeptProcessModel(
      deptProcessCode: int.tryParse(v['deptProcessCode'] ?? ''),
      deptProcessName: v['deptProcessName'],

      deptCode: int.tryParse(v['deptCode'] ?? ''),
      companyCode: int.tryParse(v['companyCode'] ?? ''),
      sortID: int.tryParse(v['sortID'] ?? ''),

      active: parseBool(v['active']),
      delRights: parseYN(v['delRights']),

      tops: int.tryParse(v['tops'] ?? '0') ?? 0,

      machineActive: parseBool(v['machineActive']),
      remarksSelect: parseBool(v['remarksSelect']),

      multiTimeIss: parseYN(v['multiTimeIss']),
      multiTimeDeptIss: parseYN(v['multiTimeDeptIss']),

      jnoRecPc: parseBool(v['jnoRecPc']),
      jnoKPc: parseBool(v['jnoKPc']),
      jnoLastPc: parseBool(v['jnoLastPc']),
      jnoExtraPc: parseBool(v['jnoExtraPc']),
      lsMarkPc: parseBool(v['lsMarkPc']),
      diaPcMinus: parseBool(v['diaPcMinus']),

      proDirectIss: parseYN(v['proDirectIss']),
      remarksRate: parseYN(v['remarksRate']),
      displayRatePc: parseYN(v['displayRatePc']),
      planCheck: parseYN(v['planCheck']),
      displayRemarks: parseYN(v['displayRemarks']),
      makableCheck: parseYN(v['makableCheck']),
      remarksDisplay: parseYN(v['remarksDisplay']),
      procCalcWt: parseYN(v['procCalcWt']),

      planPcAsRatePc: v['planPcAsRatePc'],
      rateOnShape: v['rateOnShape'],
      stockType: v['stockType'],
      getSarinOptData: v['getSarinOptData'],

      stockTypeCode: int.tryParse(v['stockTypeCode'] ?? ''),

      countInCostingProduction: parseYN(v['countInCostingProduction']),
      checkerPlanCheck: parseYN(v['checkerPlanCheck']),
    );
  }
}