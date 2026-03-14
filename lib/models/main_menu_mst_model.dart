// lib/models/main_menu_mst_model.dart

class MainMenuMstModel {
  final int?    mainMenuSrNo;
  final int?    mainMenuMstID;
  final String? mainMenuName;
  final int?    valid;

  MainMenuMstModel({
    this.mainMenuSrNo,
    this.mainMenuMstID,
    this.mainMenuName,
    this.valid,
  });

  factory MainMenuMstModel.fromJson(Map<String, dynamic> json) =>
      MainMenuMstModel(
        mainMenuSrNo:  json['MainMenuSrNo'],
        mainMenuMstID: json['MainMenuMstID'],
        mainMenuName:  json['MainMenuName'],
        valid:         json['Valid'],
      );

  Map<String, dynamic> toJson() => {
    'MainMenuName': mainMenuName,
    'Valid':        valid,
  };

  Map<String, dynamic> toTableRow() => {
    'mainMenuMstID': mainMenuMstID?.toString() ?? '',
    'mainMenuName':  mainMenuName              ?? '',
    'valid':         valid?.toString()         ?? '',
    '_raw':          this,
  };

  static MainMenuMstModel fromFormValues(Map<String, dynamic> v) =>
      MainMenuMstModel(
        mainMenuName: v['mainMenuName'],
        valid:        int.tryParse(v['valid']?.toString() ?? ''),
      );
}