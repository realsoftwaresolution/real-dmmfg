import 'package:diam_mfg/models/polish_model.dart';
import 'package:rs_dashboard/rs_dashboard.dart';
import '../models/company_model.dart';

class PolishProvider extends BaseProvider {
  List<PolishModel> _polishs = [];
  bool _isLoaded = false;

  List<PolishModel> get polishs => _polishs;

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

  List<Map<String, dynamic>> get tableData => _polishs.map((d) {
    // companyCode se companyName dhundho
    final company = _companies
        .where((c) => c.companyCode == d.companyCode)
        .firstOrNull;
    return d.toTableRow(companyName: company?.companyName);
  }).toList();

  // ── GET ALL ──────────────────────────────────────────────────────────────
  Future<void> loadPolish() async {
    final result = await request<List<PolishModel>>(
      showLoader: true,
      call: () => api.get('/polish'),
      onSuccess: (res) {
        final list = res.data['data'] as List;
        return list.map((e) => PolishModel.fromJson(e)).toList();
      },
    );

    if (result != null) {
      _polishs = result;
      _isLoaded = true;
      notifyListeners();
    }
  }

  // ── CREATE ───────────────────────────────────────────────────────────────
  Future<bool> createPolish(Map<String, dynamic> formValues) async {
    formValues['companyCode'] = _selectedCompanyCode?.toString() ?? '';

    final model = PolishModel.fromFormValues(formValues);
    print(model.toJson());
    final result = await request<PolishModel>(
      showLoader: true,
      call: () => api.post('/polish', data: model.toJson()),
      onSuccess: (res) => PolishModel.fromJson(res.data['data']),
    );

    if (result != null) {
      _polishs.insert(0, result);
      notifyListeners();
      return true;
    }

    return false;
  }

  // ── UPDATE ───────────────────────────────────────────────────────────────
  Future<bool> updatePolish(int code, Map<String, dynamic> formValues) async {
    formValues['companyCode'] = _selectedCompanyCode?.toString() ?? '';
    final model = PolishModel.fromFormValues(formValues);
    final result = await request<PolishModel>(
      showLoader: true,
      call: () => api.put('/polish/$code', data: model.toJson()),
      onSuccess: (res) => PolishModel.fromJson(res.data['data']),
    );

    if (result != null) {
      final idx = _polishs.indexWhere((c) => c.polishCode == code);
      if (idx != -1) _polishs[idx] = result;
      notifyListeners();
      return true;
    }

    return false;
  }

  // ── DELETE ───────────────────────────────────────────────────────────────
  Future<bool> deletePolish(int code) async {
    final result = await request<bool>(
      showLoader: true,
      call: () => api.delete('/polish/$code'),
      onSuccess: (_) => true,
    );

    if (result == true) {
      _polishs.removeWhere((c) => c.polishCode == code);
      notifyListeners();
      return true;
    }

    return false;
  }
}
