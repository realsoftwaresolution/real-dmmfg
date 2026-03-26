import 'package:rs_dashboard/rs_dashboard.dart';
import '../models/company_model.dart';
import '../models/division_model.dart';

class DivisionProvider extends BaseProvider {
  List<DivisionModel> _divisions = [];
  bool _isLoaded = false;

  List<DivisionModel> get divisions => _divisions;
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
      _divisions.map((d) {
        // companyCode se companyName dhundho
        final company = _companies
            .where((c) => c.companyCode == d.companyCode)
            .firstOrNull;
        return d.toTableRow(companyName: company?.companyName);
      }).toList();

  // ── GET ALL ──────────────────────────────────────────────────────────────
  Future<void> loadDivisions() async {
    final result = await request<List<DivisionModel>>(
      showLoader: true,
      call: () => api.get('/division'),
      onSuccess: (res) {
        final list = res.data as List;
        return list.map((e) => DivisionModel.fromJson(e)).toList();
      },
    );

    if (result != null) {
      _divisions = result;
      _isLoaded = true;
      notifyListeners();
    }
  }

  // ── CREATE ───────────────────────────────────────────────────────────────
  Future<bool> createDivision(Map<String, dynamic> formValues) async {
    formValues['companyCode'] = _selectedCompanyCode?.toString() ?? '';

    final model = DivisionModel.fromFormValues(formValues);

    final result = await request<DivisionModel>(
      showLoader: true,
      call: () => api.post('/division', data: model.toJson()),
      onSuccess: (res) => DivisionModel.fromJson(res.data),
    );

    if (result != null) {
      _divisions.insert(0, result);
      notifyListeners();
      return true;
    }

    return false;
  }

  // ── UPDATE ───────────────────────────────────────────────────────────────
  Future<bool> updateDivision(int code, Map<String, dynamic> formValues) async {
    formValues['companyCode'] = _selectedCompanyCode?.toString() ?? '';

    final model = DivisionModel.fromFormValues(formValues);

    final result = await request<DivisionModel>(
      showLoader: true,
      call: () => api.put('/division/$code', data: model.toJson()),
      onSuccess: (res) => DivisionModel.fromJson(res.data),
    );

    if (result != null) {
      final idx = _divisions.indexWhere((d) => d.divisionCode == code);
      if (idx != -1) _divisions[idx] = result;
      notifyListeners();
      return true;
    }

    return false;
  }

  // ── DELETE ───────────────────────────────────────────────────────────────
  Future<bool> deleteDivision(int code) async {
    final result = await request<bool>(
      showLoader: true,
      call: () => api.delete('/division/$code'),
      onSuccess: (_) => true,
    );

    if (result == true) {
      _divisions.removeWhere((d) => d.divisionCode == code);
      notifyListeners();
      return true;
    }

    return false;
  }
}