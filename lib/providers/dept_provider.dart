import 'package:rs_dashboard/rs_dashboard.dart';
import '../models/company_model.dart';
import '../models/dept_model.dart';

class DeptProvider extends BaseProvider {
  List<DeptModel> _list = [];
  bool _isLoaded = false;

  List<DeptModel> get list => _list;
  bool get isLoaded => _isLoaded;


  List<CompanyModel> _companies = [];

  void setCompanies(List<CompanyModel> companies) {
    _companies = companies;
    notifyListeners();
  }
  int? _selectedCompanyCode;

  void setSelectedCompany(int? code) {
    _selectedCompanyCode = code;
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
    final result = await request<List<DeptModel>>(
      showLoader: true,
      call: () => api.get('/dept'),
      onSuccess: (res) {
        final data = res.data as List;
        return data.map((e) => DeptModel.fromJson(e)).toList();
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
    formValues['companyCode'] = _selectedCompanyCode?.toString() ?? '';

    final model = DeptModel.fromFormValues(formValues);

    final result = await request<DeptModel>(
      showLoader: true,
      call: () => api.post('/dept', data: model.toJson()),
      onSuccess: (res) => DeptModel.fromJson(res.data),
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
    formValues['companyCode'] = _selectedCompanyCode?.toString() ?? '';

    final model = DeptModel.fromFormValues(formValues);

    final result = await request<DeptModel>(
      showLoader: true,
      call: () => api.put('/dept/$code', data: model.toJson()),
      onSuccess: (res) => DeptModel.fromJson(res.data),
    );

    if (result != null) {
      final index = _list.indexWhere((e) => e.deptCode == code);
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
      call: () => api.delete('/dept/$code'),
      onSuccess: (_) => true,
    );

    if (result == true) {
      _list.removeWhere((e) => e.deptCode == code);
      notifyListeners();
      return true;
    }
    return false;
  }
}