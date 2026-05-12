import 'dart:convert';

import 'package:rs_dashboard/rs_dashboard.dart';
import '../models/menu_mst_model.dart';

class MenuProvider extends BaseProvider {
  final ApiService api = ApiService();

  List<RSMenuItem> _menus = [];
  List<RSMenuItem> get menus => _menus;

  Future<void> loadMenus() async {
    await request(
      call: () async {
        final res = await api.get('/menuMst');
        return res;
      },
        onSuccess: (response) {
          dynamic permissions = AppStorage.getObject("user");

          // Decode if stored as String
          if (permissions is String) {
            permissions = jsonDecode(permissions);
          }

          final ua = permissions['ua'] ?? {};

          // Permission lists
          final List masterPermission =
          List<int>.from(ua['0'] ?? []);

          final List transactionPermission =
          List<int>.from(ua['1'] ?? []);

          final List reportPermission =
          List<int>.from(ua['2'] ?? []);
          final List utilityPermission =
          List<int>.from(ua['3'] ?? []);

          // API → Model convert
          final List<MenuMstModel> list =
          (response.data as List)
              .map((e) => MenuMstModel.fromJson(e))
              .toList();

          // ================= MASTER =================
          final masters = list
              .where((e) =>
          e.mainMenuMstID == 0 &&
              masterPermission.contains(e.menuMstID))
              .toList()
            ..sort((a, b) =>
                (a.menuSRNO ?? 0).compareTo(b.menuSRNO ?? 0));

          final masterItems =
          masters.map((e) => e.toMenuItem()).toList();

          // ================= TRANSACTION =================
          final transactions = list
              .where((e) =>
          e.mainMenuMstID == 1 &&
              transactionPermission.contains(e.menuMstID))
              .toList()
            ..sort((a, b) =>
                (a.menuSRNO ?? 0).compareTo(b.menuSRNO ?? 0));

          final transactionItems =
          transactions.map((e) => e.toMenuItem()).toList();

          // ================= REPORTS =================
          final reports = list
              .where((e) =>
          e.mainMenuMstID == 2 &&
              reportPermission.contains(e.menuMstID))
              .toList()
            ..sort((a, b) =>
                (a.menuSRNO ?? 0).compareTo(b.menuSRNO ?? 0));

          final reportItems =
          reports.map((e) => e.toMenuItem()).toList();


          // ================= UTILITY =================
          final utility = list
              .where((e) =>
          e.mainMenuMstID == 3 &&
              utilityPermission.contains(e.menuMstID))
              .toList()
            ..sort((a, b) =>
                (a.menuSRNO ?? 0).compareTo(b.menuSRNO ?? 0));

          final utilityItems =
          utility.map((e) => e.toMenuItem()).toList();


          // ================= FINAL MENU =================
          _menus = [
            RSMenuItem(
              id: "4",
              title: "Admin",
              icon: "assets/images/2.27.png",
              route: "/4",
            ),
            RSMenuItem(
              id: "1",
              title: "Dashboard",
              icon: "assets/images/1.png",
              route: "/1",
            ),
            if (masterItems.isNotEmpty)
              RSMenuItem(
                id: "2",
                title: "Masters",
                icon: "assets/images/2.png",
                children: masterItems,
              ),
            if (transactionItems.isNotEmpty)
              RSMenuItem(
                id: "3",
                title: "Transaction",
                icon: "assets/images/3.png",
                children: transactionItems,
              ),
            if (reportItems.isNotEmpty)
              RSMenuItem(
                id: "4",
                title: "Reports",
                icon: "assets/images/2.9.png",
                children: reportItems,
              ),
            if (utilityItems.isNotEmpty)
              RSMenuItem(
                id: "5",
                title: "Utility",
                icon: "assets/images/2.13.png",
                children: utilityItems,
              ),
          ];
        }
    );
  }
}