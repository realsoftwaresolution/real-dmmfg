import 'package:diam_mfg/utils/helper_functions.dart';

class FactoryModel {
  final int? factoryMstID;
  final int? factoryCode;

  final String? factoryName;
  final String? contactPerson;
  final String? address;

  final String? phone1;
  final String? phone2;
  final String? phone3;

  final String? mob1;
  final String? mob2;
  final String? mob3;

  final String? email1;

  final String? factoryType;
  final int? factoryManGroupCode;
  final int? divisionCode;

  final int? companyCode;
  final bool? active;
  final int? crId;
  final String? sflag;
  final String? sdate;
  final int? logID;
  final String? pcID;
  final int? ever;
  final String? rateOnShape; // Y/N
  final String? rateOnCut;   // Y/N
  final String? diamEntry;   // Y/N

  final String? gstNo;

  FactoryModel({
    this.factoryMstID,
    this.factoryCode,
    this.factoryName,
    this.contactPerson,
    this.address,
    this.phone1,
    this.phone2,
    this.phone3,
    this.mob1,
    this.mob2,
    this.mob3,
    this.email1,
    this.crId,
    this.sflag,
    this.sdate,
    this.logID,
    this.pcID,
    this.ever,
    this.factoryType,
    this.factoryManGroupCode,
    this.divisionCode,
    this.companyCode,
    this.active,
    this.rateOnShape,
    this.rateOnCut,
    this.diamEntry,
    this.gstNo,
  });

  factory FactoryModel.fromJson(Map<String, dynamic> json) =>
      FactoryModel(
        factoryMstID: json['FactoryMstID'],
        factoryCode: json['FactoryCode'],
        factoryName: json['FactoryName'],
        contactPerson: json['ContactPerson'],
        address: json['Address'],
        phone1: json['Phone1'],
        phone2: json['Phone2'],
        phone3: json['Phone3'],
        mob1: json['Mob1'],
        mob2: json['Mob2'],
        mob3: json['Mob3'],
        email1: json['Email1'],
        crId: json['CrId'],
        sflag: json['Sflag'],
        sdate: json['Sdate']?.toString(),
        logID: json['LogID'],
        pcID: json['PcID'],
        ever: json['Ever'],
        factoryType: json['FactoryType'],
        factoryManGroupCode: json['FactoryManGroupCode'],
        divisionCode: json['DivisionCode'],
        companyCode: json['CompanyCode'],
        active: json['Active'],
        rateOnShape: json['RateOnShape'],
        rateOnCut: json['RateOnCut'],
        diamEntry: json['DiamEntry'],
        gstNo: json['GstNo'],
      );

  Map<String, dynamic> toJson() => {
    'FactoryCode': factoryCode,
    'FactoryName': factoryName,
    'ContactPerson': contactPerson,
    'Address': address,
    'Phone1': phone1,
    'Phone2': phone2,
    'Phone3': phone3,

    'CrId': crId,
    'Sflag': sflag,
    'Sdate': sdate,
    'LogID': logID,
    'PcID': pcID,
    'Ever': ever,
    'Mob1': mob1,
    'Mob2': mob2,
    'Mob3': mob3,
    'Email1': email1,
    'FactoryType': factoryType,
    'FactoryManGroupCode': factoryManGroupCode,
    'DivisionCode': divisionCode,
    'CompanyCode': companyCode,
    'Active': active,
    'RateOnShape': rateOnShape,
    'RateOnCut': rateOnCut,
    'DiamEntry': diamEntry,
    'GstNo': gstNo,
  };
  Map<String, dynamic> toTableRow() => {
    'factoryCode': factoryCode,
    'factoryName': factoryName ?? '',
    'contactPerson': contactPerson ?? '',
    'phone1': phone1 ?? '',
    'mob1': mob1 ?? '',
    'email1': email1 ?? '',
    'gstNo': gstNo ?? '',
    'rateOnShape': rateOnShape == 'Y' ? 'Yes' : 'No',
    'rateOnCut': rateOnCut == 'Y' ? 'Yes' : 'No',
    'diamEntry': diamEntry == 'Y' ? 'Yes' : 'No',
    'active': active == true ? 'Yes' : 'No',
    '_raw': this,
  };
  /// 🔥 From ErpForm Values
  static FactoryModel fromFormValues(Map<String, dynamic> v) =>
      FactoryModel(
        factoryCode: int.tryParse(v['factoryCode'] ?? ''),
        factoryName: v['factoryName'],
        contactPerson: v['contactPerson'],
        address: v['address'],
        phone1: v['phone1'],
        phone2: v['phone2'],
        phone3: v['phone3'],
        mob1: v['mob1'],
        mob2: v['mob2'],
        mob3: v['mob3'],
        email1: v['email1'],
        factoryType: v['factoryType'],
        crId: int.tryParse(v['crId'] ?? ''),
        sflag: v['sflag'],
        sdate: v['sdate'],
        logID: int.tryParse(v['logID'] ?? ''),
        pcID: v['pcID'],
        ever: int.tryParse(v['ever'] ?? ''),
        factoryManGroupCode:
        int.tryParse(v['factoryManGroupCode'] ?? ''),
        divisionCode: int.tryParse(v['divisionCode'] ?? ''),
        companyCode: int.tryParse(v['companyCode'] ?? ''),
        active: parseBool(v['active']),
        // active: v['active'] == 'Yes',

        rateOnShape: parseYN(v['rateOnShape']),
        // rateOnShape: v['rateOnShape'] == 'Yes' ? 'Y' : 'N',
        rateOnCut: parseYN(v['rateOnCut']),
        // rateOnCut: v['rateOnCut'] == 'Yes' ? 'Y' : 'N',
        diamEntry: parseYN(v['diamEntry']),
        // diamEntry: v['diamEntry'] == 'Yes' ? 'Y' : 'N',
        gstNo: v['gstNo'],
      );
}