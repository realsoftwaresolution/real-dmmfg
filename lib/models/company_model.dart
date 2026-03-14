
// ═══════════════════════════════════════════════════════════════════════════
//  COMPANY MODEL
// ═══════════════════════════════════════════════════════════════════════════

import '../utils/helper_functions.dart';

class CompanyModel {
  final int? companyMstID;
  final int? companyCode;
  final String? companyName;
  final String? contactPerson;
  final String? address;
  final String? phone;
  final String? webSite;
  final String? emailID;
  final String? state;
  final int? stateCode;
  final String? gstNo;
  final String? cstNo;
  final String? tinNo;
  final String? bankName;
  final String? branchName;
  final String? bankAddress;
  final String? ifscCode;
  final String? bankAcNo;
  final String? fromYear;
  final String? toYear;
  final bool? active;
  final String? panNo;

  CompanyModel({
    this.companyMstID,
    this.companyCode,
    this.companyName,
    this.contactPerson,
    this.address,
    this.phone,
    this.webSite,
    this.emailID,
    this.state,
    this.stateCode,
    this.gstNo,
    this.cstNo,
    this.tinNo,
    this.bankName,
    this.branchName,
    this.bankAddress,
    this.ifscCode,
    this.bankAcNo,
    this.fromYear,
    this.toYear,
    this.active,
    this.panNo,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) => CompanyModel(
    companyMstID:  json['CompanyMstID'],
    companyCode:   json['CompanyCode'],
    companyName:   json['CompanyName'],
    contactPerson: json['ContactPerson'],
    address:       json['Address'],
    phone:         json['Phone'],
    webSite:       json['WebSite'],
    emailID:       json['EmailID'],
    state:         json['State'],
    stateCode:     json['StateCode'],
    gstNo:         json['GstNo'],
    cstNo:         json['CstNo'],
    tinNo:         json['TinNo'],
    bankName:      json['BankName'],
    branchName:    json['BranchName'],
    bankAddress:   json['BankAddress'],
    ifscCode:      json['IFSCCode'],
    bankAcNo:      json['BankAcNo'],
    fromYear:      json['FromYear'],
    toYear:        json['ToYear'],
    active:        json['Active'],
    panNo:         json['PANNo'],
  );

  Map<String, dynamic> toJson() => {
    'CompanyCode':   companyCode,
    'CompanyName':   companyName,
    'ContactPerson': contactPerson,
    'Address':       address,
    'Phone':         phone,
    'WebSite':       webSite,
    'EmailID':       emailID,
    'State':         state,
    'StateCode':     stateCode,
    'GstNo':         gstNo,
    'CstNo':         cstNo,
    'TinNo':         tinNo,
    'BankName':      bankName,
    'BranchName':    branchName,
    'BankAddress':   bankAddress,
    'IFSCCode':      ifscCode,
    'BankAcNo':      bankAcNo,
    'FromYear': fromYear?.substring(0,10),
    'ToYear': toYear?.substring(0,10),
    // 'FromYear': formatDate(fromYear),
    // 'ToYear': formatDate(toYear),
    'Active':        active,
    'PANNo':         panNo,
  };

  // ── For ErpDataTable ─────────────────────────────────────────────────────
  Map<String, dynamic> toTableRow() => {
    'companyCode':   companyCode,
    'companyName':   companyName   ?? '',
    'contactPerson': contactPerson ?? '',
    'phone':         phone         ?? '',
    'emailID':       emailID       ?? '',
    'state':         state         ?? '',
    'gstNo':         gstNo         ?? '',
    'panNo':         panNo         ?? '',
    'bankName':      bankName      ?? '',
    'branchName':    branchName    ?? '',
    'ifscCode':      ifscCode      ?? '',
    'bankAcNo':      bankAcNo      ?? '',
    'fromYear':      fromYear      ?? '',
    'toYear':        toYear        ?? '',
    'active':        active == true ? 'Yes' : 'No',
    '_raw':          this,
  };

  // ── From form values (what ErpForm returns) ──────────────────────────────
  static CompanyModel fromFormValues(Map<String, dynamic> v) => CompanyModel(
    companyCode:   int.tryParse(v['companyCode']?.toString() ?? ''),
    companyName:   v['companyName'],
    contactPerson: v['contactPerson'],
    address:       v['address'],
    phone:         v['phone'],
    webSite:       v['webSite'],
    emailID:       v['emailID'],
    state:         v['state'],
    stateCode:     int.tryParse(v['stateCode']?.toString() ?? ''),
    gstNo:         v['gstNo'],
    cstNo:         v['cstNo'],
    tinNo:         v['tinNo'],
    bankName:      v['bankName'],
    branchName:    v['branchName'],
    bankAddress:   v['bankAddress'],
    ifscCode:      v['ifscCode'],
    bankAcNo:      v['bankAcNo'],
    fromYear:      v['fromYear'],
    toYear:        v['toYear'],
    active: parseBool(v['active']),
    // active:        v['active'] == 'Yes' || v['active'] == true,
    panNo:         v['panNo'],
  );
}