// lib/models/counter_det_model.dart

class CounterDetModel {
  final int? counterDetID;
  final int? crId;
  final int? mainMenuMstID;
  final int? menuMstID;

  CounterDetModel({
    this.counterDetID,
    this.crId,
    this.mainMenuMstID,
    this.menuMstID,
  });

  factory CounterDetModel.fromJson(Map<String, dynamic> json) =>
      CounterDetModel(
        counterDetID:  json['CounterDetID'],
        crId:          json['CrId'],
        mainMenuMstID: json['MainMenuMstID'],
        menuMstID:     json['MenuMstID'],
      );

  Map<String, dynamic> toJson() => {
    'CrId':          crId,
    'MainMenuMstID': mainMenuMstID,
    'MenuMstID':     menuMstID,
  };

  Map<String, dynamic> toTableRow() => {
    'counterDetID':  counterDetID?.toString()  ?? '',
    'crId':          crId?.toString()          ?? '',
    'mainMenuMstID': mainMenuMstID?.toString() ?? '',
    'menuMstID':     menuMstID?.toString()     ?? '',
    '_raw':          this,
  };

  static CounterDetModel fromFormValues(Map<String, dynamic> v) =>
      CounterDetModel(
        crId:          int.tryParse(v['crId']?.toString()          ?? ''),
        mainMenuMstID: int.tryParse(v['mainMenuMstID']?.toString() ?? ''),
        menuMstID:     int.tryParse(v['menuMstID']?.toString()     ?? ''),
      );
}