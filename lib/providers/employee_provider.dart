import 'package:rs_dashboard/rs_dashboard.dart';
import '../models/employee_model.dart';

class EmployeeProvider extends BaseProvider {

  List<EmployeeModel> _employees = [];
  bool _isLoaded = false;

  List<EmployeeModel> get list => _employees;
  bool get isLoaded => _isLoaded;

  List<Map<String, dynamic>> get tableData =>
      _employees.map((e) => e.toTableRow()).toList();

  int? _selectedCompanyCode;

  void setSelectedCompany(int? code) {
    _selectedCompanyCode = code;
  }

  // LOAD
  Future<void> loadEmployees() async {
    final result = await request<List<EmployeeModel>>(
      call: () => api.get('/employees'),
      onSuccess: (res) {
        final list = res.data as List;
        return list.map((e) => EmployeeModel.fromJson(e)).toList();
      },
    );

    if (result != null) {
      _employees = result;
      _isLoaded = true;
      notifyListeners();
    }
  }

  // CREATE
  Future<bool> createEmployee(Map<String, dynamic> values) async {
    values['companyCode'] = _selectedCompanyCode?.toString() ?? '';

    final model = EmployeeModel(
      employeeCode: int.tryParse(values['employeeCode'] ?? ''),
      employeeName: values['employeeName'],
      aliasName: values['aliasName'],
      address: values['address'],

      phone1: values['phone1'],
      phone2: values['phone2'],
      phone3: values['phone3'],

      mob1: values['mob1'],
      mob2: values['mob2'],
      mob3: values['mob3'],

      email1: values['email1'],

      deptCode: int.tryParse(values['deptCode'] ?? ''),

      companyCode: int.tryParse(values['companyCode'] ?? ''),
      active: values['active'] == 'true',

      salaryType: values['salaryType'],
      salary: int.tryParse(values['salary'] ?? ''),

      designationCode: int.tryParse(values['designationCode'] ?? ''),
    );

    final result = await request<EmployeeModel>(
      call: () => api.post('/employees', data: model.toJson()),
      onSuccess: (res) => EmployeeModel.fromJson(res.data),
    );

    if (result != null) {
      _employees.insert(0, result);
      notifyListeners();
      return true;
    }
    return false;
  }

  // UPDATE
  Future<bool> updateEmployee(int code, Map<String, dynamic> values) async {
    values['companyCode'] = _selectedCompanyCode?.toString() ?? '';

    final model = EmployeeModel(
      employeeCode: code,
      employeeName: values['employeeName'],
      aliasName: values['aliasName'],
      address: values['address'],

      phone1: values['phone1'],
      phone2: values['phone2'],
      phone3: values['phone3'],

      mob1: values['mob1'],
      mob2: values['mob2'],
      mob3: values['mob3'],

      email1: values['email1'],

      deptCode: int.tryParse(values['deptCode'] ?? ''),

      companyCode: int.tryParse(values['companyCode'] ?? ''),
      active: values['active'] == '1' || values['active'] == 'true',

      salaryType: values['salaryType'],
      salary: int.tryParse(values['salary'] ?? ''),

      designationCode: int.tryParse(values['designationCode'] ?? ''),
    );

    final result = await request<EmployeeModel>(
      call: () => api.put('/employees/$code', data: model.toJson()),
      onSuccess: (res) => EmployeeModel.fromJson(res.data),
    );

    if (result != null) {
      final i = _employees.indexWhere((e) => e.employeeCode == code);
      if (i != -1) _employees[i] = result;
      notifyListeners();
      return true;
    }
    return false;
  }

  // DELETE
  Future<bool> deleteEmployee(int code) async {
    final result = await request<bool>(
      call: () => api.delete('/employees/$code'),
      onSuccess: (_) => true,
    );

    if (result == true) {
      _employees.removeWhere((e) => e.employeeCode == code);
      notifyListeners();
      return true;
    }
    return false;
  }
}