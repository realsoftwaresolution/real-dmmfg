import 'package:rs_dashboard/rs_dashboard.dart';
import '../models/company_model.dart';
import '../models/rough_type_model.dart';

class RoughTypeProvider extends BaseProvider {
  List<RoughTypeModel> _roughTypes = [];
  bool _isLoaded = false;

  List<RoughTypeModel> get roughTypes => _roughTypes;
  bool get isLoaded => _isLoaded;

  List<CompanyModel> _companies = [];

  void setCompanies(List<CompanyModel> companies) {
    _companies = companies;
    notifyListeners();
  }

  List<Map<String, dynamic>> get tableData =>
      _roughTypes.map((d) {
        // companyCode se companyName dhundho
        final company = _companies
            .where((c) => c.companyCode == d.companyCode)
            .firstOrNull;
        return d.toTableRow(companyName: company?.companyName);
      }).toList();


  // ── GET ALL ──────────────────────────────────────────────────────────────
  Future<void> loadRoughTypes() async {
    final result = await request<List<RoughTypeModel>>(
      showLoader: true,
      call: () => api.get('/rough-type'),
      onSuccess: (res) {
        final list = res.data as List;
        return list.map((e) => RoughTypeModel.fromJson(e)).toList();
      },
    );

    if (result != null) {
      _roughTypes = result;
      _isLoaded = true;
      notifyListeners();
    }
  }

  // ── CREATE ───────────────────────────────────────────────────────────────
  Future<bool> createRoughType(Map<String, dynamic> formValues) async {
    final model = RoughTypeModel.fromFormValues(formValues);

    final result = await request<RoughTypeModel>(
      showLoader: true,
      call: () => api.post('/rough-type', data: model.toJson()),
      onSuccess: (res) => RoughTypeModel.fromJson(res.data),
    );

    if (result != null) {
      _roughTypes.insert(0, result);
      notifyListeners();
      return true;
    }

    return false;
  }

  // ── UPDATE ───────────────────────────────────────────────────────────────
  Future<bool> updateRoughType(int code, Map<String, dynamic> formValues) async {
    final model = RoughTypeModel.fromFormValues(formValues);

    final result = await request<RoughTypeModel>(
      showLoader: true,
      call: () => api.put('/rough-type/$code', data: model.toJson()),
      onSuccess: (res) => RoughTypeModel.fromJson(res.data),
    );

    if (result != null) {
      final idx = _roughTypes.indexWhere((r) => r.roughTypeCode == code);
      if (idx != -1) _roughTypes[idx] = result;
      notifyListeners();
      return true;
    }

    return false;
  }

  // ── DELETE ───────────────────────────────────────────────────────────────
  Future<bool> deleteRoughType(int code) async {
    final result = await request<bool>(
      showLoader: true,
      call: () => api.delete('/rough-type/$code'),
      onSuccess: (_) => true,
    );

    if (result == true) {
      _roughTypes.removeWhere((r) => r.roughTypeCode == code);
      notifyListeners();
      return true;
    }

    return false;
  }
}