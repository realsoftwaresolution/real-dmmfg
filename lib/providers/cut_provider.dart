import 'package:rs_dashboard/rs_dashboard.dart';
import '../models/company_model.dart';
import '../models/cut_model.dart';

class CutProvider extends BaseProvider {
  List<CutModel> _cuts = [];
  bool _isLoaded = false;

  List<CutModel> get cuts => _cuts;
  bool get isLoaded => _isLoaded;
  List<CompanyModel> _companies = [];

  void setCompanies(List<CompanyModel> companies) {
    _companies = companies;
    notifyListeners();
  }

  List<Map<String, dynamic>> get tableData =>
      _cuts.map((d) {
        // companyCode se companyName dhundho
        final company = _companies
            .where((c) => c.companyCode == d.companyCode)
            .firstOrNull;
        return d.toTableRow(companyName: company?.companyName);
      }).toList();
  // ── GET ALL ──────────────────────────────────────────────────────────────
  Future<void> loadCuts() async {
    final result = await request<List<CutModel>>(
      showLoader: true,
      call: () => api.get('/cut'),
      onSuccess: (res) {
        final list = res.data as List;
        return list.map((e) => CutModel.fromJson(e)).toList();
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
    final model = CutModel.fromFormValues(formValues);

    final result = await request<CutModel>(
      showLoader: true,
      call: () => api.post('/cut', data: model.toJson()),
      onSuccess: (res) => CutModel.fromJson(res.data),
    );

    if (result != null) {
      _cuts.insert(0, result);
      notifyListeners();
      return true;
    }

    return false;
  }

  // ── UPDATE ───────────────────────────────────────────────────────────────
  Future<bool> updateCut(int code, Map<String, dynamic> formValues) async {
    final model = CutModel.fromFormValues(formValues);

    final result = await request<CutModel>(
      showLoader: true,
      call: () => api.put('/cut/$code', data: model.toJson()),
      onSuccess: (res) => CutModel.fromJson(res.data),
    );

    if (result != null) {
      final idx = _cuts.indexWhere((c) => c.cutCode == code);
      if (idx != -1) _cuts[idx] = result;
      notifyListeners();
      return true;
    }

    return false;
  }

  // ── DELETE ───────────────────────────────────────────────────────────────
  Future<bool> deleteCut(int code) async {
    final result = await request<bool>(
      showLoader: true,
      call: () => api.delete('/cut/$code'),
      onSuccess: (_) => true,
    );

    if (result == true) {
      _cuts.removeWhere((c) => c.cutCode == code);
      notifyListeners();
      return true;
    }

    return false;
  }
}