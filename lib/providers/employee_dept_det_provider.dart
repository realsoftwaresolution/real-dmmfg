import 'package:rs_dashboard/rs_dashboard.dart';
import '../models/employee_dept_det_model.dart';

class EmployeeDeptDetProvider extends BaseProvider {
  List<EmployeeDeptDetModel> _list = [];
  bool _isLoaded = false;

  List<EmployeeDeptDetModel> get list => _list;
  bool get isLoaded => _isLoaded;

  // (Optional dropdown mapping ke liye)
  Map<int, String> _employeeMap = {};
  Map<int, String> _deptMap = {};

  void setEmployees(Map<int, String> data) {
    _employeeMap = data;
    notifyListeners();
  }

  void setDepts(Map<int, String> data) {
    _deptMap = data;
    notifyListeners();
  }

  // 🔹 TABLE DATA
  List<Map<String, dynamic>> get tableData =>
      _list.map((d) {
        return d.toTableRow(
          employeeName: _employeeMap[d.employeeCode],
          deptName: _deptMap[d.deptCode],
        );
      }).toList();

  // ───── LOAD ─────
  Future<void> load() async {
    final result = await request<List<EmployeeDeptDetModel>>(
      showLoader: true,
      call: () => api.get('/employeeDeptDet'),
      onSuccess: (res) {
        final data = res.data as List;
        return data.map((e) => EmployeeDeptDetModel.fromJson(e)).toList();
      },
    );

    if (result != null) {
      _list = result;
      _isLoaded = true;
      notifyListeners();
    }
  }

  // ───── CREATE ─────
  Future<bool> create(Map<String, dynamic> formValues) async {
    final model = EmployeeDeptDetModel.fromFormValues(formValues);

    final result = await request<EmployeeDeptDetModel>(
      showLoader: true,
      call: () => api.post('/employeeDeptDet', data: model.toJson()),
      onSuccess: (res) => EmployeeDeptDetModel.fromJson(res.data),
    );

    if (result != null) {
      _list.insert(0, result);
      notifyListeners();
      return true;
    }
    return false;
  }

  // ───── UPDATE ─────
  Future<bool> update(int id, Map<String, dynamic> formValues) async {
    final model = EmployeeDeptDetModel.fromFormValues(formValues);

    final result = await request<EmployeeDeptDetModel>(
      showLoader: true,
      call: () => api.put('/employeeDeptDet/$id', data: model.toJson()),
      onSuccess: (res) => EmployeeDeptDetModel.fromJson(res.data),
    );

    if (result != null) {
      final index = _list.indexWhere(
              (e) => e.employeeDeptDetID == id);

      if (index != -1) _list[index] = result;

      notifyListeners();
      return true;
    }
    return false;
  }

  // ───── DELETE ─────
  Future<bool> delete(int id) async {
    final result = await request<bool>(
      showLoader: true,
      call: () => api.delete('/employeeDeptDet/$id'),
      onSuccess: (_) => true,
    );

    if (result == true) {
      _list.removeWhere((e) => e.employeeDeptDetID == id);
      notifyListeners();
      return true;
    }
    return false;
  }
}