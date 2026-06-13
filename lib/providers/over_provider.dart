import 'package:diam_mfg/models/intent_model.dart';
import 'package:diam_mfg/models/over_model.dart';
import 'package:rs_dashboard/rs_dashboard.dart';
import '../models/company_model.dart';

class OverProvider extends BaseProvider {
  List<OverModel> _cuts = [];
  bool _isLoaded = false;

  List<OverModel> get cuts => _cuts;
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
  Future<void> loadOvers() async {
    final result = await request<List<OverModel>>(
      showLoader: true,
      call: () => api.get('/fc-over'),
      onSuccess: (res) {
        final list = res.data['data'] as List;
        return list.map((e) => OverModel.fromJson(e)).toList();
      },
    );

    if (result != null) {
      _cuts = result;
      _isLoaded = true;
      notifyListeners();
    }
  }

  // ── CREATE ───────────────────────────────────────────────────────────────
  Future<bool> createOver(Map<String, dynamic> formValues) async {
    formValues['companyCode'] = _selectedCompanyCode?.toString() ?? '';

    final model = OverModel.fromFormValues(formValues);

    final result = await request<OverModel>(
      showLoader: true,
      call: () => api.post('/fc-over', data: model.toJson()),
      onSuccess: (res) => OverModel.fromJson(res.data),
    );

    if (result != null) {
      loadOvers();
      return true;
    }

    return false;
  }

  // ── UPDATE ───────────────────────────────────────────────────────────────
  Future<bool> updateOver(int code, Map<String, dynamic> formValues) async {
    formValues['companyCode'] = _selectedCompanyCode?.toString() ?? '';

    final model = OverModel.fromFormValues(formValues);

    final result = await request<OverModel>(
      showLoader: true,
      call: () => api.put('/fc-over/$code', data: model.toJson()),
      onSuccess: (res) => OverModel.fromJson(res.data),
    );

    if (result != null) {
      loadOvers();
      return true;
    }

    return false;
  }

  // ── DELETE ───────────────────────────────────────────────────────────────
  Future<bool> deleteOver(int code) async {
    final result = await request<bool>(
      showLoader: true,
      call: () => api.delete('/fc-over/$code'),
      onSuccess: (_) => true,
    );

    if (result == true) {
      loadOvers();
      return true;
    }

    return false;
  }
}