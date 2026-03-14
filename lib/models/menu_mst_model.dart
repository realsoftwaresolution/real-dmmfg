// lib/models/menu_mst_model.dart

import 'package:rs_dashboard/rs_dashboard.dart';

class MenuMstModel {
  final int?    menuSRNO;
  final int?    menuMstID;
  final String? menuName;
  final int?    mainMenuMstID;
  final int?    valid;
  final String? formName;
  final String? menuImage; // BLOB — API se base64 string ya null aayega
  final int?    mainGroupMstID;
  final int?    imageSize;
  final int?    sortID;
  final String? dashBoard;
  final String? shortCutKey;

  MenuMstModel({
    this.menuSRNO,
    this.menuMstID,
    this.menuName,
    this.mainMenuMstID,
    this.valid,
    this.formName,
    this.menuImage,
    this.mainGroupMstID,
    this.imageSize,
    this.sortID,
    this.dashBoard,
    this.shortCutKey,
  });

  factory MenuMstModel.fromJson(Map<String, dynamic> json) => MenuMstModel(
    menuSRNO:       json['MenuSRNO'],
    menuMstID:      json['MenuMstID'],
    menuName:       json['MenuName'],
    mainMenuMstID:  json['MainMenuMstID'],
    valid:          json['Valid'],
    formName:       json['FormName'],
    menuImage:      json['MenuImage']?.toString(),
    mainGroupMstID: json['MainGroupMstID'],
    imageSize:      json['ImageSize'],
    sortID:         json['SortID'],
    dashBoard:      json['DashBoard'],
    shortCutKey:    json['ShortCutKey'],
  );

  Map<String, dynamic> toJson() => {
    'MenuName':       menuName,
    'MainMenuMstID':  mainMenuMstID,
    'Valid':          valid,
    'FormName':       formName,
    'MenuImage':      menuImage,
    'MainGroupMstID': mainGroupMstID,
    'ImageSize':      imageSize,
    'SortID':         sortID,
    'DashBoard':      dashBoard,
    'ShortCutKey':    shortCutKey,
  };

  Map<String, dynamic> toTableRow() => {
    'menuMstID':      menuMstID?.toString()      ?? '',
    'menuName':       menuName                   ?? '',
    'mainMenuMstID':  mainMenuMstID?.toString()  ?? '',
    'formName':       formName                   ?? '',
    'sortID':         sortID?.toString()         ?? '',
    'valid':          valid?.toString()          ?? '',
    '_raw':           this,
  };

  static MenuMstModel fromFormValues(Map<String, dynamic> v) => MenuMstModel(
    menuName:       v['menuName'],
    mainMenuMstID:  int.tryParse(v['mainMenuMstID']?.toString()  ?? ''),
    valid:          int.tryParse(v['valid']?.toString()          ?? ''),
    formName:       v['formName'],
    menuImage:      v['menuImage']?.toString(),
    mainGroupMstID: int.tryParse(v['mainGroupMstID']?.toString() ?? ''),
    imageSize:      int.tryParse(v['imageSize']?.toString()      ?? ''),
    sortID:         int.tryParse(v['sortID']?.toString()         ?? ''),
    dashBoard:      v['dashBoard'],
    shortCutKey:    v['shortCutKey'],
  );
  RSMenuItem toMenuItem() {
    print("menuImage: $menuImage -> routeCode: $routeCode");
    return RSMenuItem(
      id: menuSRNO.toString(),
      title: menuName ?? '',
      icon: iconPath,
      route: "/$routeCode",
    );
  }
  String get routeCode {
    if (menuImage == null) return '';

    try {
      final value = menuImage.toString();

      // Buffer format → {type: Buffer, data: [50,46,52]}
      if (value.contains('data')) {
        final start = value.indexOf('[');
        final end = value.indexOf(']');
        final numbers = value.substring(start + 1, end).split(',');

        final bytes = numbers.map((e) => int.parse(e.trim())).toList();

        return String.fromCharCodes(bytes);
      }

      return value;
    } catch (e) {
      return '';
    }
  }
  String get iconPath {
    switch (routeCode) {
      case '2':
        return 'assets/images/2_black.png';
      case '3':
        return 'assets/images/3.png';
      case '3.1':
        return 'assets/images/3.1.png';
      case '3.2':
        return 'assets/images/3.2.png';
      case '3.3':
        return 'assets/images/3.3.png';
      case '3.4':
        return 'assets/images/3.4.png';
      case '2.1':
        return 'assets/images/2.1_black.png';
      case '2.2':
        return 'assets/images/2.2_black.png';
      case '2.3':
        return 'assets/images/2.3_black.png';
      case '2.4':
        return 'assets/images/2.4_black.png';
      case '2.5':
        return 'assets/images/2.5_black.png';
      case '2.6':
        return 'assets/images/2.6_black.png';
      case '2.7':
        return 'assets/images/2.7_black.png';
      case '2.8':
        return 'assets/images/2.8_black.png';
      case '2.9':
        return 'assets/images/2.9_black.png';
      case '2.10':
        return 'assets/images/2.10_black.png';
      case '2.11':
        return 'assets/images/2.11_black.png';
      case '2.12':
        return 'assets/images/2.12_black.png';
      case '2.13':
        return 'assets/images/2.13_black.png';
      case '2.14':
        return 'assets/images/2.14_black.png';
      case '2.15':
        return 'assets/images/2.15_black.png';
      case '2.16':
        return 'assets/images/2.16_black.png';
      case '2.17':
        return 'assets/images/2.17_black.png';
      case '2.18':
        return 'assets/images/2.18_black.png';
      case '2.19':
        return 'assets/images/2.19_black.png';
      case '2.20':
        return 'assets/images/2.20_black.png';
      case '2.21':
        return 'assets/images/2.21_black.png';
      case '2.22':
        return 'assets/images/2.22_black.png';
      case '2.23':
        return 'assets/images/2.23_black.png';
      case '2.24':
        return 'assets/images/2.24_black.png';
      case '2.25':
        return 'assets/images/2.25_black.png';
      case '2.26':
        return 'assets/images/2.26.png';
      default:
        return 'assets/images/1_black.png';
    }
  }

}