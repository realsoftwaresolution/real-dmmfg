// lib/providers/company_provider.dart

import 'package:rs_dashboard/rs_dashboard.dart';

import '../models/company_model.dart';


// ═══════════════════════════════════════════════════════════════════════════
//  COMPANY PROVIDER  — extends BaseProvider (same as AuthProvider)
// ═══════════════════════════════════════════════════════════════════════════
class CompanyProvider extends BaseProvider {
  List<CompanyModel> _companies = [];
  bool _isLoaded = false;

  List<CompanyModel> get companies => _companies;
  bool get isLoaded => _isLoaded;

  List<Map<String, dynamic>> get tableData =>
      _companies.map((c) => c.toTableRow()).toList();
  int? _selectedCompanyCode;
  int? get selectedCompanyCode => _selectedCompanyCode;

  CompanyModel? get selectedCompany => _selectedCompanyCode == null
      ? null
      : _companies.firstWhere(
        (c) => c.companyCode == _selectedCompanyCode,
    orElse: () => _companies.first,
  );

  void selectCompany(int code) {
    _selectedCompanyCode = code;
    notifyListeners();
  }

  /// Call this on logout to reset selection
  void clearSelection() {
    _selectedCompanyCode = null;
    _companies = [];
    _isLoaded = false;
    notifyListeners();
  }
  // ── GET ALL ──────────────────────────────────────────────────────────────
  Future<void> loadCompanies() async {
    final result = await request<List<CompanyModel>>(
      showLoader: true,
      call: () => api.get('/company'),
      onSuccess: (res) {
        final list = res.data as List;
        return list.map((e) => CompanyModel.fromJson(e)).toList();
      },
    );

    if (result != null) {
      _companies = result;
      _isLoaded  = true;
      notifyListeners();
    }
  }

  // ── CREATE ───────────────────────────────────────────────────────────────
  Future<bool> createCompany(Map<String, dynamic> formValues) async {
    final model = CompanyModel.fromFormValues(formValues);

    final result = await request<CompanyModel>(
      showLoader: true,
      call: () => api.post('/company', data: model.toJson()),
      onSuccess: (res) => CompanyModel.fromJson(res.data),
    );

    if (result != null) {
      _companies.insert(0, result);
      notifyListeners();
      return true;
    }
    return false;
  }

  // ── UPDATE ───────────────────────────────────────────────────────────────
  Future<bool> updateCompany(int companyCode, Map<String, dynamic> formValues) async {
    final model = CompanyModel.fromFormValues(formValues);

    final result = await request<CompanyModel>(
      showLoader: true,
      call: () => api.put('/company/$companyCode', data: model.toJson()),
      onSuccess: (res) => CompanyModel.fromJson(res.data),
    );

    if (result != null) {
      final idx = _companies.indexWhere((c) => c.companyCode == companyCode);
      if (idx != -1) _companies[idx] = result;
      notifyListeners();
      return true;
    }
    return false;
  }

  // ── DELETE ───────────────────────────────────────────────────────────────
  Future<bool> deleteCompany(int companyCode) async {
    final result = await request<bool>(
      showLoader: true,
      call: () => api.delete('/company/$companyCode'),
      onSuccess: (_) => true,
    );

    if (result == true) {
      _companies.removeWhere((c) => c.companyCode == companyCode);
      notifyListeners();
      return true;
    }
    return false;
  }
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    loadCompanies();
  }
}