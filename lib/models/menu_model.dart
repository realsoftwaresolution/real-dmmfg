import 'package:rs_dashboard/rs_dashboard.dart';

class MenuModel {
  final String id;
  final String title;
  final String icon;
  final String route;
  final List<MenuModel> children;

  MenuModel({
    required this.id,
    required this.title,
    required this.icon,
    required this.route,
    required this.children,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      id: json['id'],
      title: json['title'],
      icon: json['icon'],
      route: json['route'],
      children: (json['children'] as List)
          .map((e) => MenuModel.fromJson(e))
          .toList(),
    );
  }

  /// Convert API Model → RSMenuItem
  RSMenuItem toRSMenuItem() {
    return RSMenuItem(
      id: id,
      title: title=='TrnFirm_RoughEntry'?'ROUGH ENTRY':title=='TrnFirm_RoughAssort'?'ROUGH ASSORT':title=='TrnFirm_CutCreate'?'CUT CREATE':title=='TrnFirm_PacketCreate'?'PACKET CREATE':title,
      icon: _mapIcon(icon),
      route: route,
      children: children.map((e) => e.toRSMenuItem()).toList(),
    );
  }

  /// Convert String Icon → Material Icon
  String _mapIcon(String name) {
    switch (name) {
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
        case '3.5':
        return 'assets/images/3.5.png';
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
        case '2.27':
        return 'assets/images/2.27.png';
      default:
        return 'assets/images/1_black.png';
    }
  }
  String _mapTitle(String name) {
    switch (name) {
      case '2':
        return 'assets/images/2_black.png';
        case '3':
        return 'assets/images/3.png';
        case 'TrnFirm_RoughEntry':
        return 'assets/images/3.1.png';
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
      default:
        return 'assets/images/1_black.png';
    }
  }

  String _mapIcon1(String name) {
    switch (name) {
      case '2':
        return 'assets/images/2.png';
        case '3':
        return 'assets/images/3.png';
      case '2.1':
        return 'assets/images/2.1.png';
      case '2.2':
        return 'assets/images/2.2.png';
      case '2.3':
        return 'assets/images/2.3.png';
      case '2.4':
        return 'assets/images/2.4.png';
      case '2.5':
        return 'assets/images/2.5.png';
      case '2.6':
        return 'assets/images/2.6.png';
      case '2.7':
        return 'assets/images/2.7.png';
      case '2.8':
        return 'assets/images/2.8.png';
      case '2.9':
        return 'assets/images/2.9.png';
      case '2.10':
        return 'assets/images/2.10.png';
      case '2.11':
        return 'assets/images/2.11.png';
      case '2.12':
        return 'assets/images/2.12.png';
      case '2.13':
        return 'assets/images/2.13.png';
      case '2.14':
        return 'assets/images/2.14.png';
      case '2.15':
        return 'assets/images/2.15.png';
      case '2.16':
        return 'assets/images/2.16.png';
      case '2.17':
        return 'assets/images/2.17.png';
      case '2.18':
        return 'assets/images/2.18.png';
      case '2.19':
        return 'assets/images/2.19.png';
      case '2.20':
        return 'assets/images/2.20.png';
      case '2.21':
        return 'assets/images/2.21.png';
      case '2.22':
        return 'assets/images/2.22.png';
      case '2.23':
        return 'assets/images/2.23.png';
      case '2.24':
        return 'assets/images/2.24.png';
      default:
        return 'assets/images/1.png';
    }
  }
}
