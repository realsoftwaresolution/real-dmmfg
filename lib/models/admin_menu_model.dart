class AdminMenuModel {
  final int menuSRNO;
  final String menuName;
  final int menuMstID;
  final int mainMenuMstID;
  final int valid;
  final String formName;
  final String routeCode;
  final int sortID;
  final String dashBoard;
  final List<int>? menuImageBuffer; // raw buffer bytes from API

  AdminMenuModel({
    required this.menuSRNO,
    required this.menuName,
    required this.menuMstID,
    required this.mainMenuMstID,
    required this.valid,
    required this.formName,
    required this.sortID,
    required this.dashBoard,
    this.menuImageBuffer,
    required this.routeCode,
  });

  factory AdminMenuModel.fromJson(Map<String, dynamic> json) {
    List<int>? imageBuffer;
    final img = json['MenuImage'];
    if (img != null && img is Map && img['data'] != null) {
      imageBuffer = List<int>.from(img['data']);
    }

    return AdminMenuModel(
      menuSRNO: json['MenuSRNO'] ?? 0,
      menuName: json['MenuName'] ?? '',
      menuMstID: json['MenuMstID'] ?? 0,
      mainMenuMstID: json['MainMenuMstID'] ?? 0,
      valid: json['Valid'] ?? 1,
      formName: json['FormName'] ?? '',
      sortID: json['SortID'] ?? 1,
      dashBoard: json['DashBoard'] ?? 'CLICK',
      routeCode: (json['RouteCode'] ?? '').toString().trim(), // ✅ FIX
      menuImageBuffer: imageBuffer,
    );
  }

  /// Decode buffer to string (e.g. "2.16" — icon code reference)
  String get menuImageCode {
    if (menuImageBuffer == null || menuImageBuffer!.isEmpty) return '';
    return String.fromCharCodes(menuImageBuffer!);
  }
}

class MainMenuGroup {
  final int id;
  final String name;
  MainMenuGroup({required this.id, required this.name});
}

final List<MainMenuGroup> mainMenuGroups = [
  MainMenuGroup(id: 0, name: 'Master'),
  MainMenuGroup(id: 1, name: 'Transaction'),
  MainMenuGroup(id: 2, name: 'Reports'),
  MainMenuGroup(id: 3, name: 'Utility'),
];