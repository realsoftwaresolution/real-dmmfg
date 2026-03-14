// import 'package:rs_dashboard/rs_dashboard.dart';
//
// import '../models/menu_model.dart';
//
// class MenuProvider extends BaseProvider {
//   final ApiService api = ApiService();
//
//   List<RSMenuItem> _menus = [];
//
//   List<RSMenuItem> get menus => _menus;
//
// //load menu for sidebar screens
//
//   Future<void> loadMenus() async {
//     await request(call: () async {
//       final data = await api.get('/menu?projectName=REAL_DMMFG');
//       print('res----${data.data}');
//       return data;
//     }, onSuccess: (response) {
//       _menus=(response.data as List)
//           .map((e) => MenuModel.fromJson(e).toRSMenuItem())
//           .toList();
//     },);
//   }
// }
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

        // API → Model convert
        final List<MenuMstModel> list =
        (response.data as List)
            .map((e) => MenuMstModel.fromJson(e))
            .toList();

        // MASTER
        final masters = list
            .where((e) => e.mainMenuMstID == 0)
            .map((e) => e.toMenuItem())
            .toList();

        // TRANSACTION
        final transactions = list
            .where((e) => e.mainMenuMstID == 1)
            .map((e) => e.toMenuItem())
            .toList();

        _menus = [
          RSMenuItem(
            id: "1",
            title: "Dashboard",
            icon: "assets/images/1.png",
            route: "/1",
          ),

          RSMenuItem(
            id: "2",
            title: "Masters",
            icon: "assets/images/2.png",
            children: masters,
          ),

          RSMenuItem(
            id: "3",
            title: "Transaction",
            icon: "assets/images/3.png",
            children: transactions,
          ),
        ];
      },
    );
  }
}