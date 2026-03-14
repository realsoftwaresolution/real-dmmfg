import 'package:rs_dashboard/rs_dashboard.dart';
import '../models/company_model.dart';
import '../models/dept_process_model.dart';

class DeptProcessProvider extends BaseProvider {
  List<DeptProcessModel> _list = [];
  bool _isLoaded = false;

  List<DeptProcessModel> get list => _list;
  bool get isLoaded => _isLoaded;

  List<CompanyModel> _companies = [];

  void setCompanies(List<CompanyModel> companies) {
    _companies = companies;
    notifyListeners();
  }

  List<Map<String, dynamic>> get tableData =>
      _list.map((d) {

        final company = _companies
            .where((c) => c.companyCode == d.companyCode)
            .firstOrNull;
        return d.toTableRow(companyName: company?.companyName);
      }).toList();

  // ───── LOAD ─────
  Future<void> load() async {
    final result = await request<List<DeptProcessModel>>(
      showLoader: true,
      call: () => api.get('/dept-process'),
      onSuccess: (res) {
        final data = res.data as List;
        return data.map((e) => DeptProcessModel.fromJson(e)).toList();
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
    final model = DeptProcessModel.fromFormValues(formValues);

    final result = await request<DeptProcessModel>(
      showLoader: true,
      call: () => api.post('/dept-process', data: model.toJson()),
      onSuccess: (res) => DeptProcessModel.fromJson(res.data),
    );

    if (result != null) {
      _list.insert(0, result);
      notifyListeners();
      return true;
    }
    return false;
  }

  // ───── UPDATE ─────
  Future<bool> update(int code, Map<String, dynamic> formValues) async {
    final model = DeptProcessModel.fromFormValues(formValues);

    final result = await request<DeptProcessModel>(
      showLoader: true,
      call: () => api.put('/dept-process/$code', data: model.toJson()),
      onSuccess: (res) => DeptProcessModel.fromJson(res.data),
    );

    if (result != null) {
      final index = _list.indexWhere((e) => e.deptProcessCode == code);
      if (index != -1) _list[index] = result;
      notifyListeners();
      return true;
    }
    return false;
  }

  // ───── DELETE ─────
  Future<bool> delete(int code) async {
    final result = await request<bool>(
      showLoader: true,
      call: () => api.delete('/dept-process/$code'),
      onSuccess: (_) => true,
    );

    if (result == true) {
      _list.removeWhere((e) => e.deptProcessCode == code);
      notifyListeners();
      return true;
    }
    return false;
  }
}