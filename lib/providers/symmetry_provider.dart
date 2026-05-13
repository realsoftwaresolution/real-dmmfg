import 'package:diam_mfg/models/symmetry_model.dart';
import 'package:rs_dashboard/rs_dashboard.dart';
import '../models/company_model.dart';

class SymmetryProvider extends BaseProvider {
  List<SymmetryModel> _symmetrys = [];
  bool _isLoaded = false;

  List<SymmetryModel> get symmetrys => _symmetrys;

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

  List<Map<String, dynamic>> get tableData => _symmetrys.map((d) {
    // companyCode se companyName dhundho
    final company = _companies
        .where((c) => c.companyCode == d.companyCode)
        .firstOrNull;
    return d.toTableRow(companyName: company?.companyName);
  }).toList();

  // ── GET ALL ──────────────────────────────────────────────────────────────
  Future<void> loadSymmetry() async {
    final result = await request<List<SymmetryModel>>(
      showLoader: true,
      call: () => api.get('/symmetry'),
      onSuccess: (res) {
        final list = res.data['data'] as List;
        return list.map((e) => SymmetryModel.fromJson(e)).toList();
      },
    );

    if (result != null) {
      _symmetrys = result;
      _isLoaded = true;
      notifyListeners();
    }
  }

  // ── CREATE ───────────────────────────────────────────────────────────────
  Future<bool> createSymmetry(Map<String, dynamic> formValues) async {
    formValues['companyCode'] = _selectedCompanyCode?.toString() ?? '';

    final model = SymmetryModel.fromFormValues(formValues);

    final result = await request<SymmetryModel>(
      showLoader: true,
      call: () => api.post('/symmetry', data: model.toJson()),
      onSuccess: (res) => SymmetryModel.fromJson(res.data['data']),
    );

    if (result != null) {
      _symmetrys.insert(0, result);
      notifyListeners();
      return true;
    }

    return false;
  }

  // ── UPDATE ───────────────────────────────────────────────────────────────
  Future<bool> updateSymmetry(int code, Map<String, dynamic> formValues) async {
    formValues['companyCode'] = _selectedCompanyCode?.toString() ?? '';

    final model = SymmetryModel.fromFormValues(formValues);

    final result = await request<SymmetryModel>(
      showLoader: true,
      call: () => api.put('/symmetry/$code', data: model.toJson()),
      onSuccess: (res) => SymmetryModel.fromJson(res.data['data']),
    );

    if (result != null) {
      final idx = _symmetrys.indexWhere((c) => c.symmetryCode == code);
      if (idx != -1) _symmetrys[idx] = result;
      notifyListeners();
      return true;
    }

    return false;
  }

  // ── DELETE ───────────────────────────────────────────────────────────────
  Future<bool> deleteSymmetry(int code) async {
    final result = await request<bool>(
      showLoader: true,
      call: () => api.delete('/symmetry/$code'),
      onSuccess: (_) => true,
    );

    if (result == true) {
      _symmetrys.removeWhere((c) => c.symmetryCode == code);
      notifyListeners();
      return true;
    }

    return false;
  }
}
