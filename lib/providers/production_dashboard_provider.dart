import 'package:rs_dashboard/rs_dashboard.dart';

class ProductionDashboardProvider extends BaseProvider {

  List<dynamic> _level1 = [];
  List<dynamic> _level2 = [];
  List<dynamic> _level3 = [];

  List<dynamic> get level1 => _level1;
  List<dynamic> get level2 => _level2;
  List<dynamic> get level3 => _level3;

  int? selectedDeptCode;
  int? selectedRoughMstID;

  Future<void> loadLevel1() async {

    final result = await request<List<dynamic>>(
      showLoader: true,
      call: () => api.post(
        '/reports/production-report',
      ),
      onSuccess: (res) {
        return res.data['data'];
      },
    );

    if (result != null) {
      _level1 = result;
      notifyListeners();
    }
  }

  Future<void> loadLevel2(int deptCode) async {

    selectedDeptCode = deptCode;

    final result = await request<List<dynamic>>(
      showLoader: true,
      call: () => api.post(
        '/reports/production-report',
        data: {
          "DeptCode": deptCode
        },
      ),
      onSuccess: (res) {
        return res.data['data'];
      },
    );

    if (result != null) {
      _level2 = result;
      _level3.clear();
      notifyListeners();
    }
  }

  Future<void> loadLevel3({
    required int deptCode,
    required int roughMstID,
  }) async {

    selectedDeptCode = deptCode;
    selectedRoughMstID = roughMstID;

    final result = await request<List<dynamic>>(
      showLoader: true,
      call: () => api.post(
        '/reports/production-report',
        data: {
          "DeptCode": deptCode,
          "RoughMstID": roughMstID,
        },
      ),
      onSuccess: (res) {
        return res.data['data'];
      },
    );

    if (result != null) {
      _level3 = result;
      notifyListeners();
    }
  }
}