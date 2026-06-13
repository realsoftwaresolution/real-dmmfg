import 'package:diam_mfg/models/fColor_model.dart';
import 'package:rs_dashboard/rs_dashboard.dart';
import '../models/company_model.dart';

class FColorProvider extends BaseProvider {
  List<FColorModel> _cuts = [];
  bool _isLoaded = false;

  List<FColorModel> get cuts => _cuts;
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
  Future<void> loadColors() async {
    final result = await request<List<FColorModel>>(
      showLoader: true,
      call: () => api.get('/fc-color'),
      onSuccess: (res) {
        final list = res.data['data'] as List;
        return list.map((e) => FColorModel.fromJson(e)).toList();
      },
    );

    if (result != null) {
      _cuts = result;
      _isLoaded = true;
      notifyListeners();
    }
  }

  // ── CREATE ───────────────────────────────────────────────────────────────
  Future<bool> createColor(Map<String, dynamic> formValues) async {
    formValues['companyCode'] = _selectedCompanyCode?.toString() ?? '';

    final model = FColorModel.fromFormValues(formValues);

    final result = await request<FColorModel>(
      showLoader: true,
      call: () => api.post('/fc-color', data: model.toJson()),
      onSuccess: (res) => FColorModel.fromJson(res.data),
    );

    if (result != null) {
      loadColors();
      return true;
    }

    return false;
  }

  // ── UPDATE ───────────────────────────────────────────────────────────────
  Future<bool> updateColor(int code, Map<String, dynamic> formValues) async {
    formValues['companyCode'] = _selectedCompanyCode?.toString() ?? '';

    final model = FColorModel.fromFormValues(formValues);

    final result = await request<FColorModel>(
      showLoader: true,
      call: () => api.put('/fc-color/$code', data: model.toJson()),
      onSuccess: (res) => FColorModel.fromJson(res.data),
    );

    if (result != null) {
      loadColors();
      return true;
    }

    return false;
  }

  // ── DELETE ───────────────────────────────────────────────────────────────
  Future<bool> deleteColor(int code) async {
    final result = await request<bool>(
      showLoader: true,
      call: () => api.delete('/fc-color/$code'),
      onSuccess: (_) => true,
    );

    if (result == true) {
      loadColors();
      return true;
    }

    return false;
  }
}