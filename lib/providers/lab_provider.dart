import 'package:diam_mfg/models/lab_model.dart';
import 'package:rs_dashboard/rs_dashboard.dart';
import '../models/company_model.dart';
import '../models/cut_model.dart';

class LabProvider extends BaseProvider {
  List<LabModel> _cuts = [];
  bool _isLoaded = false;

  List<LabModel> get cuts => _cuts;
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
  Future<void> loadCuts() async {
    final result = await request<List<LabModel>>(
      showLoader: true,
      call: () => api.get('/lab'),
      onSuccess: (res) {
        final list = res.data['data'] as List;
        return list.map((e) => LabModel.fromJson(e)).toList();
      },
    );

    if (result != null) {
      _cuts = result;
      _isLoaded = true;
      notifyListeners();
    }
  }

  // ── CREATE ───────────────────────────────────────────────────────────────
  Future<bool> createCut(Map<String, dynamic> formValues) async {
    formValues['companyCode'] = _selectedCompanyCode?.toString() ?? '';

    final model = LabModel.fromFormValues(formValues);

    final result = await request<LabModel>(
      showLoader: true,
      call: () => api.post('/lab', data: model.toJson()),
      onSuccess: (res) => LabModel.fromJson(res.data),
    );

    if (result != null) {
      loadCuts();
      return true;
    }

    return false;
  }

  // ── UPDATE ───────────────────────────────────────────────────────────────
  Future<bool> updateCut(int code, Map<String, dynamic> formValues) async {
    formValues['companyCode'] = _selectedCompanyCode?.toString() ?? '';

    final model = LabModel.fromFormValues(formValues);

    final result = await request<LabModel>(
      showLoader: true,
      call: () => api.put('/lab/$code', data: model.toJson()),
      onSuccess: (res) => LabModel.fromJson(res.data),
    );

    if (result != null) {
      loadCuts();
      return true;
    }

    return false;
  }

  // ── DELETE ───────────────────────────────────────────────────────────────
  Future<bool> deleteCut(int code) async {
    final result = await request<bool>(
      showLoader: true,
      call: () => api.delete('/lab/$code'),
      onSuccess: (_) => true,
    );

    if (result == true) {
      loadCuts();
      return true;
    }

    return false;
  }
}