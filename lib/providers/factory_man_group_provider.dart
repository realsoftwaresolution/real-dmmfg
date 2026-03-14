import 'package:rs_dashboard/rs_dashboard.dart';
import '../models/company_model.dart';
import '../models/factory_man_group_model.dart';

class FactoryManGroupProvider extends BaseProvider {
  List<FactoryManGroupModel> _groups = [];
  bool _isLoaded = false;

  List<FactoryManGroupModel> get groups => _groups;
  bool get isLoaded => _isLoaded;

  List<CompanyModel> _companies = [];

  void setCompanies(List<CompanyModel> companies) {
    _companies = companies;
    notifyListeners();
  }

  List<Map<String, dynamic>> get tableData =>
      groups.map((d) {
        // companyCode se companyName dhundho
        final company = _companies
            .where((c) => c.companyCode == d.companyCode)
            .firstOrNull;
        return d.toTableRow(companyName: company?.companyName);
      }).toList();

  // ── GET ALL ──────────────────────────────────────────────────────────────
  Future<void> loadGroups() async {
    final result = await request<List<FactoryManGroupModel>>(
      showLoader: true,
      call: () => api.get('/factory-man-group'),
      onSuccess: (res) {
        final list = res.data as List;
        return list.map((e) => FactoryManGroupModel.fromJson(e)).toList();
      },
    );

    if (result != null) {
      _groups = result;
      _isLoaded = true;
      notifyListeners();
    }
  }

  // ── CREATE ───────────────────────────────────────────────────────────────
  Future<bool> createGroup(Map<String, dynamic> formValues) async {
    final model = FactoryManGroupModel.fromFormValues(formValues);

    final result = await request<FactoryManGroupModel>(
      showLoader: true,
      call: () => api.post('/factory-man-group', data: model.toJson()),
      onSuccess: (res) => FactoryManGroupModel.fromJson(res.data),
    );

    if (result != null) {
      _groups.insert(0, result);
      notifyListeners();
      return true;
    }

    return false;
  }

  // ── UPDATE ───────────────────────────────────────────────────────────────
  Future<bool> updateGroup(
      int code,
      Map<String, dynamic> formValues,
      ) async {
    final model = FactoryManGroupModel.fromFormValues(formValues);

    final result = await request<FactoryManGroupModel>(
      showLoader: true,
      call: () => api.put('/factory-man-group/$code', data: model.toJson()),
      onSuccess: (res) => FactoryManGroupModel.fromJson(res.data),
    );

    if (result != null) {
      final idx = _groups.indexWhere((g) => g.factoryManGroupCode == code);
      if (idx != -1) _groups[idx] = result;
      notifyListeners();
      return true;
    }

    return false;
  }

  // ── DELETE ───────────────────────────────────────────────────────────────
  Future<bool> deleteGroup(int code) async {
    final result = await request<bool>(
      showLoader: true,
      call: () => api.delete('/factory-man-group/$code'),
      onSuccess: (_) => true,
    );

    if (result == true) {
      _groups.removeWhere((g) => g.factoryManGroupCode == code);
      notifyListeners();
      return true;
    }

    return false;
  }
}