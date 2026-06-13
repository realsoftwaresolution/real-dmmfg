import 'package:diam_mfg/models/intent_model.dart';
import 'package:rs_dashboard/rs_dashboard.dart';
import '../models/company_model.dart';

class IntentProvider extends BaseProvider {
  List<IntentModel> _cuts = [];
  bool _isLoaded = false;

  List<IntentModel> get cuts => _cuts;
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
      _cuts.map((d) {
        // companyCode se companyName dhundho
        final company = _companies
            .where((c) => c.companyCode == d.companyCode)
            .firstOrNull;
        return d.toTableRow(company: company?.companyName);
      }).toList();
  // ── GET ALL ──────────────────────────────────────────────────────────────
  Future<void> loadIntents() async {
    final result = await request<List<IntentModel>>(
      showLoader: true,
      call: () => api.get('/fc-intent'),
      onSuccess: (res) {
        final list = res.data['data'] as List;
        return list.map((e) => IntentModel.fromJson(e)).toList();
      },
    );

    if (result != null) {
      _cuts = result;
      _isLoaded = true;
      notifyListeners();
    }
  }

  // ── CREATE ───────────────────────────────────────────────────────────────
  Future<bool> createIntent(Map<String, dynamic> formValues) async {
    formValues['companyCode'] = _selectedCompanyCode?.toString() ?? '';

    final model = IntentModel.fromFormValues(formValues);

    final result = await request<IntentModel>(
      showLoader: true,
      call: () => api.post('/fc-intent', data: model.toJson()),
      onSuccess: (res) => IntentModel.fromJson(res.data),
    );

    if (result != null) {
      loadIntents();
      return true;
    }

    return false;
  }

  // ── UPDATE ───────────────────────────────────────────────────────────────
  Future<bool> updateIntent(int code, Map<String, dynamic> formValues) async {
    formValues['companyCode'] = _selectedCompanyCode?.toString() ?? '';

    final model = IntentModel.fromFormValues(formValues);

    final result = await request<IntentModel>(
      showLoader: true,
      call: () => api.put('/fc-intent/$code', data: model.toJson()),
      onSuccess: (res) => IntentModel.fromJson(res.data),
    );

    if (result != null) {
      loadIntents();
      return true;
    }

    return false;
  }

  // ── DELETE ───────────────────────────────────────────────────────────────
  Future<bool> deleteIntent(int code) async {
    final result = await request<bool>(
      showLoader: true,
      call: () => api.delete('/fc-intent/$code'),
      onSuccess: (_) => true,
    );

    if (result == true) {
      loadIntents();
      return true;
    }

    return false;
  }
}