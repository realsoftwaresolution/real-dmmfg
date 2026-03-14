class PartyModel {
  final int? partyMstID;
  final int? partyCode;
  final String? partyName;
  final String? address;

  final String? phone1;
  final String? phone2;
  final String? phone3;

  final String? mob1;
  final String? mob2;
  final String? mob3;

  final String? email1;
  final String? email2;
  final String? email3;

  final String? gstNo;
  final String? cstNo;
  final String? tinNo;

  final String? state;
  final int? stateCode;

  final int? companyCode;
  final bool? active;
  final String? partyType;
  final String? panNo;

  final bool? mainCutCompulsory;

  PartyModel({
    this.partyMstID,
    this.partyCode,
    this.partyName,
    this.address,
    this.phone1,
    this.phone2,
    this.phone3,
    this.mob1,
    this.mob2,
    this.mob3,
    this.email1,
    this.email2,
    this.email3,
    this.gstNo,
    this.cstNo,
    this.tinNo,
    this.state,
    this.stateCode,
    this.companyCode,
    this.active,
    this.partyType,
    this.panNo,
    this.mainCutCompulsory,
  });

  factory PartyModel.fromJson(Map<String, dynamic> json) {
    return PartyModel(
      partyMstID: json['PartyMstID'],
      partyCode: json['PartyCode'],
      partyName: json['PartyName'],
      address: json['Address'],
      phone1: json['Phone1'],
      phone2: json['Phone2'],
      phone3: json['Phone3'],
      mob1: json['Mob1'],
      mob2: json['Mob2'],
      mob3: json['Mob3'],
      email1: json['Email1'],
      email2: json['Email2'],
      email3: json['Email3'],
      gstNo: json['GstNo'],
      cstNo: json['CstNo'],
      tinNo: json['TinNo'],
      state: json['State'],
      stateCode: json['StateCode'],
      companyCode: json['CompanyCode'],
      active: json['Active'],
      partyType: json['PartyType'],
      panNo: json['PANNo'],
      mainCutCompulsory: json['MainCutCompulsory'],
    );
  }

  Map<String, dynamic> toJson() => {
    'PartyCode': partyCode,
    'PartyName': partyName,
    'Address': address,
    'Phone1': phone1,
    'Phone2': phone2,
    'Phone3': phone3,
    'Mob1': mob1,
    'Mob2': mob2,
    'Mob3': mob3,
    'Email1': email1,
    'Email2': email2,
    'Email3': email3,
    'GstNo': gstNo,
    'CstNo': cstNo,
    'TinNo': tinNo,
    'State': state,
    'StateCode': stateCode,
    'CompanyCode': companyCode,
    'Active': active,
    'PartyType': partyType,
    'PANNo': panNo,
    'MainCutCompulsory': mainCutCompulsory,
  };

  Map<String, dynamic> toTableRow() => {
    'partyCode': partyCode,
    'partyName': partyName ?? '',
    'phone1': phone1 ?? '',
    'mob1': mob1 ?? '',
    'gstNo': gstNo ?? '',
    'panNo': panNo ?? '',
    'active': active == true ? 'Yes' : 'No',
    '_raw': this,
  };
}