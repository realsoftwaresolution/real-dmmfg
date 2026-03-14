// lib/models/counter_model.dart

import '../utils/helper_functions.dart';

class CounterModel {
  final int?    counterMstID;
  final int?    crId;
  final String? logInName;
  final String? crName;
  final String? crPass;
  final String? userGrp;
  final int?    counterTypeCode;
  final int?    deptGroupCode;
  final int?    deptCode;
  final String? crEdit;
  final String? crDel;
  final String? autoRec;
  final String? empIssRec;
  final String? empRecWt;
  final String? laserPlanRec;
  final String? polishOut;
  final String? kachaIss;
  final String? manType;
  final int?    manPktDayLimit;
  final int?    manPktHourLimit;
  final String? empType;
  final int?    empPktDayLimit;
  final int?    empPktHourLimit;
  final int?    stockLimit;
  final int?    target;
  final DateTime? fromTime;
  final DateTime? toTime;
  final String? sflag;
  final DateTime? sDate;
  final int?    logID;
  final String? pcID;
  final int?    ever;
  final int?    companyCode;
  final int?    sortID;
  final bool?   active;
  final int?    divisionCode;
  final String? contactPerson;
  final String? address;
  final String? phone1;
  final String? phone2;
  final String? phone3;
  final String? mob1;
  final String? mob2;
  final String? mob3;
  final String? email1;
  final String? clvPartyType;
  final String? jnoCreate;
  final String? cutUrgent;
  final String? hastak;
  final String? cutUrgentValid;
  final int?    teamCode;
  final String? planRgWt;
  final int?    empPktLimit;
  final String? rptDisp;
  final int?    mfgDeptCode;
  final String? manRecWt;
  final String? manDmWt;
  final String? poPerValid;
  final String? makPlanCompalsary;
  final String? lsIssWithoutPlan;
  final String? issInValidPkt;
  final String? replanningWithoutNuksani;
  final String? makableEntry;
  final String? signerCheckerRec;
  final String? multiTimeDeptIss;
  final String? getTableRussianData;
  final int?    editDeleteTime;
  final String? editDeleteTimeExpire;
  final String? orderFinish;
  final bool?   viewAllDeptOrder;

  CounterModel({
    this.counterMstID,
    this.crId,
    this.logInName,
    this.crName,
    this.crPass,
    this.userGrp,
    this.counterTypeCode,
    this.deptGroupCode,
    this.deptCode,
    this.crEdit,
    this.crDel,
    this.autoRec,
    this.empIssRec,
    this.empRecWt,
    this.laserPlanRec,
    this.polishOut,
    this.kachaIss,
    this.manType,
    this.manPktDayLimit,
    this.manPktHourLimit,
    this.empType,
    this.empPktDayLimit,
    this.empPktHourLimit,
    this.stockLimit,
    this.target,
    this.fromTime,
    this.toTime,
    this.sflag,
    this.sDate,
    this.logID,
    this.pcID,
    this.ever,
    this.companyCode,
    this.sortID,
    this.active,
    this.divisionCode,
    this.contactPerson,
    this.address,
    this.phone1,
    this.phone2,
    this.phone3,
    this.mob1,
    this.mob2,
    this.mob3,
    this.email1,
    this.clvPartyType,
    this.jnoCreate,
    this.cutUrgent,
    this.hastak,
    this.cutUrgentValid,
    this.teamCode,
    this.planRgWt,
    this.empPktLimit,
    this.rptDisp,
    this.mfgDeptCode,
    this.manRecWt,
    this.manDmWt,
    this.poPerValid,
    this.makPlanCompalsary,
    this.lsIssWithoutPlan,
    this.issInValidPkt,
    this.replanningWithoutNuksani,
    this.makableEntry,
    this.signerCheckerRec,
    this.multiTimeDeptIss,
    this.getTableRussianData,
    this.editDeleteTime,
    this.editDeleteTimeExpire,
    this.orderFinish,
    this.viewAllDeptOrder,
  });

  factory CounterModel.fromJson(Map<String, dynamic> json) => CounterModel(
    counterMstID:              json['CounterMstID'],
    crId:                      json['CrId'],
    logInName:                 json['LogInName'],
    crName:                    json['CrName'],
    crPass:                    json['CrPass'],
    userGrp:                   json['UserGrp'],
    counterTypeCode:           json['CounterTypeCode'],
    deptGroupCode:             json['DeptGroupCode'],
    deptCode:                  json['DeptCode'],
    crEdit:                    json['CrEdit'],
    crDel:                     json['CrDel'],
    autoRec:                   json['AutoRec'],
    empIssRec:                 json['EmpIssRec'],
    empRecWt:                  json['EmpRecWt'],
    laserPlanRec:              json['LaserPlanRec'],
    polishOut:                 json['PolishOut'],
    kachaIss:                  json['KachaIss'],
    manType:                   json['ManType'],
    manPktDayLimit:            json['ManPktDayLimit'],
    manPktHourLimit:           json['ManPktHourLimit'],
    empType:                   json['EmpType'],
    empPktDayLimit:            json['EmpPktDayLimit'],
    empPktHourLimit:           json['EmpPktHourLimit'],
    stockLimit:                json['StockLimit'],
    target:                    json['Target'],
    fromTime:   json['FromTime']  != null ? DateTime.tryParse(json['FromTime'])  : null,
    toTime:     json['ToTime']    != null ? DateTime.tryParse(json['ToTime'])    : null,
    sflag:                     json['Sflag'],
    sDate:      json['SDate']     != null ? DateTime.tryParse(json['SDate'])     : null,
    logID:                     json['LogID'],
    pcID:                      json['PcID'],
    ever:                      json['Ever'],
    companyCode:               json['CompanyCode'],
    sortID:                    json['SortID'],
    active:                    json['Active'] == true || json['Active'] == 1,
    divisionCode:              json['DivisionCode'],
    contactPerson:             json['ContactPerson'],
    address:                   json['Address'],
    phone1:                    json['Phone1'],
    phone2:                    json['Phone2'],
    phone3:                    json['Phone3'],
    mob1:                      json['Mob1'],
    mob2:                      json['Mob2'],
    mob3:                      json['Mob3'],
    email1:                    json['Email1'],
    clvPartyType:              json['CLVPartyType'],
    jnoCreate:                 json['JnoCreate'],
    cutUrgent:                 json['CutUrgent'],
    hastak:                    json['Hastak'],
    cutUrgentValid:            json['CutUrgentValid'],
    teamCode:                  json['TeamCode'],
    planRgWt:                  json['PlanRgWt'],
    empPktLimit:               json['EmpPktLimit'],
    rptDisp:                   json['RptDisp'],
    mfgDeptCode:               json['MFGDeptCode'],
    manRecWt:                  json['ManRecWt'],
    manDmWt:                   json['ManDmWt'],
    poPerValid:                json['PoPerValid'],
    makPlanCompalsary:         json['MakPlanCompalsary'],
    lsIssWithoutPlan:          json['LsIssWithoutPlan'],
    issInValidPkt:             json['IssInValidPkt'],
    replanningWithoutNuksani:  json['ReplanningWithoutNuksani'],
    makableEntry:              json['MakableEntry'],
    signerCheckerRec:          json['SignerCheckerRec'],
    multiTimeDeptIss:          json['MultiTimeDeptIss'],
    getTableRussianData:       json['GetTableRussianData'],
    editDeleteTime:            json['EditDeleteTime'],
    editDeleteTimeExpire:      json['EditDeleteTimeExpire'],
    orderFinish:               json['OrderFinish'],
    viewAllDeptOrder:          json['ViewAllDeptOrder'] == true || json['ViewAllDeptOrder'] == 1,
  );

  Map<String, dynamic> toJson() => {
    'LogInName':                logInName,
    'CrName':                   crName,
    'CrPass':                   crPass,
    'UserGrp':                  userGrp,
    'CounterTypeCode':          counterTypeCode,
    'DeptGroupCode':            deptGroupCode,
    'DeptCode':                 deptCode,
    'CrEdit':                   crEdit,
    'CrDel':                    crDel,
    'AutoRec':                  autoRec,
    'EmpIssRec':                empIssRec,
    'EmpRecWt':                 empRecWt,
    'LaserPlanRec':             laserPlanRec,
    'PolishOut':                polishOut,
    'KachaIss':                 kachaIss,
    'ManType':                  manType,
    'ManPktDayLimit':           manPktDayLimit,
    'ManPktHourLimit':          manPktHourLimit,
    'EmpType':                  empType,
    'EmpPktDayLimit':           empPktDayLimit,
    'EmpPktHourLimit':          empPktHourLimit,
    'StockLimit':               stockLimit,
    'Target':                   target,
    'FromTime':                 fromTime?.toIso8601String(),
    'ToTime':                   toTime?.toIso8601String(),
    'Sflag':                    sflag,
    'SDate':                    sDate?.toIso8601String(),
    'LogID':                    logID,
    'PcID':                     pcID,
    'Ever':                     ever,
    'CompanyCode':              companyCode,
    'SortID':                   sortID,
    'Active':                   active,
    'DivisionCode':             divisionCode,
    'ContactPerson':            contactPerson,
    'Address':                  address,
    'Phone1':                   phone1,
    'Phone2':                   phone2,
    'Phone3':                   phone3,
    'Mob1':                     mob1,
    'Mob2':                     mob2,
    'Mob3':                     mob3,
    'Email1':                   email1,
    'CLVPartyType':             clvPartyType,
    'JnoCreate':                jnoCreate,
    'CutUrgent':                cutUrgent,
    'Hastak':                   hastak,
    'CutUrgentValid':           cutUrgentValid,
    'TeamCode':                 teamCode,
    'PlanRgWt':                 planRgWt,
    'EmpPktLimit':              empPktLimit,
    'RptDisp':                  rptDisp,
    'MFGDeptCode':              mfgDeptCode,
    'ManRecWt':                 manRecWt,
    'ManDmWt':                  manDmWt,
    'PoPerValid':               poPerValid,
    'MakPlanCompalsary':        makPlanCompalsary,
    'LsIssWithoutPlan':         lsIssWithoutPlan,
    'IssInValidPkt':            issInValidPkt,
    'ReplanningWithoutNuksani': replanningWithoutNuksani,
    'MakableEntry':             makableEntry,
    'SignerCheckerRec':         signerCheckerRec,
    'MultiTimeDeptIss':         multiTimeDeptIss,
    'GetTableRussianData':      getTableRussianData,
    'EditDeleteTime':           editDeleteTime,
    'EditDeleteTimeExpire':     editDeleteTimeExpire,
    'OrderFinish':              orderFinish,
    'ViewAllDeptOrder':         viewAllDeptOrder,
  };

  Map<String, dynamic> toTableRow() => {
    'crId':          crId?.toString()  ?? '',
    'crName':        crName            ?? '',
    'logInName':     logInName         ?? '',
    'userGrp':       userGrp           ?? '',
    'deptCode':      deptCode?.toString() ?? '',
    'active':        active == true ? 'Yes' : 'No',
    '_raw':          this,
  };

  static CounterModel fromFormValues(Map<String, dynamic> v) => CounterModel(
    logInName:                 v['logInName'],
    crName:                    v['crName'],
    crPass:                    v['crPass'],
    userGrp:                   v['userGrp'],
    counterTypeCode:           int.tryParse(v['counterTypeCode']?.toString() ?? ''),
    deptGroupCode:             int.tryParse(v['deptGroupCode']?.toString()   ?? ''),
    deptCode:                  int.tryParse(v['deptCode']?.toString()        ?? ''),
    crEdit:                    v['crEdit'],
    crDel:                     v['crDel'],
    autoRec:                   v['autoRec'],
    empIssRec:                 v['empIssRec'],
    empRecWt:                  v['empRecWt'],
    laserPlanRec:              v['laserPlanRec'],
    polishOut:                 v['polishOut'],
    kachaIss:                  v['kachaIss'],
    manType:                   v['manType'],
    manPktDayLimit:            int.tryParse(v['manPktDayLimit']?.toString()  ?? ''),
    manPktHourLimit:           int.tryParse(v['manPktHourLimit']?.toString() ?? ''),
    empType:                   v['empType'],
    empPktDayLimit:            int.tryParse(v['empPktDayLimit']?.toString()  ?? ''),
    empPktHourLimit:           int.tryParse(v['empPktHourLimit']?.toString() ?? ''),
    stockLimit:                int.tryParse(v['stockLimit']?.toString()      ?? ''),
    target:                    int.tryParse(v['target']?.toString()          ?? ''),
    fromTime:   v['fromTime']  != null ? DateTime.tryParse(v['fromTime'])  : null,
    toTime:     v['toTime']    != null ? DateTime.tryParse(v['toTime'])    : null,
    sflag:                     v['sflag'],
    logID:                     int.tryParse(v['logID']?.toString()           ?? ''),
    pcID:                      v['pcID'],
    ever:                      int.tryParse(v['ever']?.toString()            ?? ''),
    companyCode:               int.tryParse(v['companyCode']?.toString()     ?? ''),
    sortID:                    int.tryParse(v['sortID']?.toString()          ?? ''),
    active:                    parseBool(v['active']),
    divisionCode:              int.tryParse(v['divisionCode']?.toString()    ?? ''),
    contactPerson:             v['contactPerson'],
    address:                   v['address'],
    phone1:                    v['phone1'],
    phone2:                    v['phone2'],
    phone3:                    v['phone3'],
    mob1:                      v['mob1'],
    mob2:                      v['mob2'],
    mob3:                      v['mob3'],
    email1:                    v['email1'],
    clvPartyType:              v['clvPartyType'],
    jnoCreate:                 v['jnoCreate'],
    cutUrgent:                 v['cutUrgent'],
    hastak:                    v['hastak'],
    cutUrgentValid:            v['cutUrgentValid'],
    teamCode:                  int.tryParse(v['teamCode']?.toString()        ?? ''),
    planRgWt:                  v['planRgWt'],
    empPktLimit:               int.tryParse(v['empPktLimit']?.toString()     ?? ''),
    rptDisp:                   v['rptDisp'],
    mfgDeptCode:               int.tryParse(v['mfgDeptCode']?.toString()     ?? ''),
    manRecWt:                  v['manRecWt'],
    manDmWt:                   v['manDmWt'],
    poPerValid:                v['poPerValid'],
    makPlanCompalsary:         v['makPlanCompalsary'],
    lsIssWithoutPlan:          v['lsIssWithoutPlan'],
    issInValidPkt:             v['issInValidPkt'],
    replanningWithoutNuksani:  v['replanningWithoutNuksani'],
    makableEntry:              v['makableEntry'],
    signerCheckerRec:          v['signerCheckerRec'],
    multiTimeDeptIss:          v['multiTimeDeptIss'],
    getTableRussianData:       v['getTableRussianData'],
    editDeleteTime:            int.tryParse(v['editDeleteTime']?.toString()  ?? ''),
    editDeleteTimeExpire:      v['editDeleteTimeExpire'],
    orderFinish:               v['orderFinish'],
    viewAllDeptOrder:          parseBool(v['viewAllDeptOrder']),
  );
}