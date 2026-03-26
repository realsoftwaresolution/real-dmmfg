import 'package:rs_dashboard/rs_dashboard.dart';
import '../models/company_model.dart';
import '../models/shape_model.dart';

class ShapeProvider extends BaseProvider {
  List<ShapeModel> _list = [];
  bool _isLoaded = false;

  List<ShapeModel> get list => _list;
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
    final result = await request<List<ShapeModel>>(
      showLoader: true,
      call: () => api.get('/shape'),
      onSuccess: (res) {
        final data = res.data as List;
        return data.map((e) => ShapeModel.fromJson(e)).toList();
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

    final model = ShapeModel.fromFormValues(formValues);

    final result = await request<ShapeModel>(
      showLoader: true,
      call: () => api.post('/shape', data: model.toJson()),
      onSuccess: (res) => ShapeModel.fromJson(res.data),
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

    final model = ShapeModel.fromFormValues(formValues);

    final result = await request<ShapeModel>(
      showLoader: true,
      call: () => api.put('/shape/$code', data: model.toJson()),
      onSuccess: (res) => ShapeModel.fromJson(res.data),
    );

    if (result != null) {
      final index = _list.indexWhere((e) => e.shapeCode == code);
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
      call: () => api.delete('/shape/$code'),
      onSuccess: (_) => true,
    );

    if (result == true) {
      _list.removeWhere((e) => e.shapeCode == code);
      notifyListeners();
      return true;
    }
    return false;
  }
}