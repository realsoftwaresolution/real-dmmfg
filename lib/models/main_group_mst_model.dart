// lib/models/main_group_mst_model.dart

class MainGroupMstModel {
  final int?    mainGroupSrNo;
  final int?    mainGroupMstID;
  final String? mainGroupName;
  final int?    valid;
  final int?    mainMenuMstID;

  MainGroupMstModel({
    this.mainGroupSrNo,
    this.mainGroupMstID,
    this.mainGroupName,
    this.valid,
    this.mainMenuMstID,
  });

  factory MainGroupMstModel.fromJson(Map<String, dynamic> json) =>
      MainGroupMstModel(
        mainGroupSrNo:  json['MainGroupSrNo'],
        mainGroupMstID: json['MainGroupMstID'],
        mainGroupName:  json['MainGroupName'],
        valid:          json['Valid'],
        mainMenuMstID:  json['MainMenuMstID'],
      );

  Map<String, dynamic> toJson() => {
    'MainGroupName': mainGroupName,
    'Valid':         valid,
    'MainMenuMstID': mainMenuMstID,
  };

  Map<String, dynamic> toTableRow() => {
    'mainGroupMstID': mainGroupMstID?.toString() ?? '',
    'mainGroupName':  mainGroupName              ?? '',
    'mainMenuMstID':  mainMenuMstID?.toString()  ?? '',
    'valid':          valid?.toString()          ?? '',
    '_raw':           this,
  };

  static MainGroupMstModel fromFormValues(Map<String, dynamic> v) =>
      MainGroupMstModel(
        mainGroupName: v['mainGroupName'],
        valid:         int.tryParse(v['valid']?.toString()         ?? ''),
        mainMenuMstID: int.tryParse(v['mainMenuMstID']?.toString() ?? ''),
      );
}