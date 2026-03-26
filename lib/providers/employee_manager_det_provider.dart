import 'package:rs_dashboard/rs_dashboard.dart';
import '../models/employee_manager_det_model.dart';

class EmployeeManagerDetProvider extends BaseProvider {
  List<EmployeeManagerDetModel> _list = [];
  bool _isLoaded = false;

  List<EmployeeManagerDetModel> get list => _list;
  bool get isLoaded => _isLoaded;

  // 🔹 Mapping (Dropdown / Name show karne ke liye)
  Map<int, String> _employeeMap = {};
  Map<int, String> _crMap = {};
  Map<int, String> _processMap = {};
  Map<int, String> _deptMap = {};

  void setEmployees(Map<int, String> data) {
    _employeeMap = data;
    notifyListeners();
  }

  void setCr(Map<int, String> data) {
    _crMap = data;
    notifyListeners();
  }

  void setProcesses(Map<int, String> data) {
    _processMap = data;
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
          crName: _crMap[d.crId],
          processName: _processMap[d.deptProcessCode],
          deptName: _deptMap[d.deptCode],
        );
      }).toList();

  // ───── LOAD ─────
  Future<void> load() async {
    final result = await request<List<EmployeeManagerDetModel>>(
      showLoader: true,
      call: () => api.get('/employeeManagerDet'),
      onSuccess: (res) {
        final data = res.data as List;
        return data.map((e) => EmployeeManagerDetModel.fromJson(e)).toList();
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
    final model = EmployeeManagerDetModel.fromFormValues(formValues);

    final result = await request<EmployeeManagerDetModel>(
      showLoader: true,
      call: () => api.post('/employeeManagerDet', data: model.toJson()),
      onSuccess: (res) => EmployeeManagerDetModel.fromJson(res.data),
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
    final model = EmployeeManagerDetModel.fromFormValues(formValues);

    final result = await request<EmployeeManagerDetModel>(
      showLoader: true,
      call: () => api.put('/employeeManagerDet/$id', data: model.toJson()),
      onSuccess: (res) => EmployeeManagerDetModel.fromJson(res.data),
    );

    if (result != null) {
      final index = _list.indexWhere(
              (e) => e.employeeManagerDetID == id);

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
      call: () => api.delete('/employeeManagerDet/$id'),
      onSuccess: (_) => true,
    );

    if (result == true) {
      _list.removeWhere((e) => e.employeeManagerDetID == id);
      notifyListeners();
      return true;
    }
    return false;
  }
}