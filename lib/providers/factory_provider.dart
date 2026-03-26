import 'package:rs_dashboard/rs_dashboard.dart';
import '../models/factory_model.dart';

/// ═══════════════════════════════════════════════════════════════════════════
///  FACTORY PROVIDER  — extends BaseProvider (same pattern as CompanyProvider)
/// ═══════════════════════════════════════════════════════════════════════════
class FactoryProvider extends BaseProvider {

  List<FactoryModel> _factories = [];
  bool _isLoaded = false;

  List<FactoryModel> get factories => _factories;
  bool get isLoaded => _isLoaded;

  /// For ErpDataTable
  List<Map<String, dynamic>> get tableData =>
      _factories.map((f) => f.toTableRow()).toList();
  int? _selectedCompanyCode;

  void setSelectedCompany(int? code) {
    _selectedCompanyCode = code;
  }
  // ── GET ALL ──────────────────────────────────────────────────────────────
  Future<void> loadFactories() async {
    final result = await request<List<FactoryModel>>(
      showLoader: true,
      call: () => api.get('/factory'),
      onSuccess: (res) {
        final list = res.data as List;
        return list.map((e) => FactoryModel.fromJson(e)).toList();
      },
    );

    if (result != null) {
      _factories = result;
      _isLoaded = true;
      notifyListeners();
    }
  }

  // ── CREATE ───────────────────────────────────────────────────────────────
  Future<bool> createFactory(Map<String, dynamic> formValues) async {
    formValues['companyCode'] = _selectedCompanyCode?.toString() ?? '';

    final model = FactoryModel.fromFormValues(formValues);

    final result = await request<FactoryModel>(
      showLoader: true,
      call: () => api.post('/factory', data: model.toJson()),
      onSuccess: (res) => FactoryModel.fromJson(res.data),
    );

    if (result != null) {
      _factories.insert(0, result);
      notifyListeners();
      return true;
    }

    return false;
  }

  // ── UPDATE ───────────────────────────────────────────────────────────────
  Future<bool> updateFactory(
      int factoryCode,
      Map<String, dynamic> formValues,
      ) async {
    formValues['companyCode'] = _selectedCompanyCode?.toString() ?? '';

    final model = FactoryModel.fromFormValues(formValues);

    final result = await request<FactoryModel>(
      showLoader: true,
      call: () => api.put('/factory/$factoryCode', data: model.toJson()),
      onSuccess: (res) => FactoryModel.fromJson(res.data),
    );

    if (result != null) {
      final idx = _factories.indexWhere(
            (f) => f.factoryCode == factoryCode,
      );

      if (idx != -1) {
        _factories[idx] = result;
      }

      notifyListeners();
      return true;
    }

    return false;
  }

  // ── DELETE ───────────────────────────────────────────────────────────────
  Future<bool> deleteFactory(int factoryCode) async {

    final result = await request<bool>(
      showLoader: true,
      call: () => api.delete('/factory/$factoryCode'),
      onSuccess: (_) => true,
    );

    if (result == true) {
      _factories.removeWhere(
            (f) => f.factoryCode == factoryCode,
      );

      notifyListeners();
      return true;
    }

    return false;
  }
}