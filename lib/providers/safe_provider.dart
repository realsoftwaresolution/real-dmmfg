import 'package:rs_dashboard/rs_dashboard.dart';
import '../models/safe_model.dart';
import '../models/company_model.dart';

class SafeProvider extends BaseProvider {
  List<SafeModel> _list = [];
  bool _isLoaded = false;

  List<SafeModel> get list => _list;
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
      _list.map((d) {
        final company = _companies
            .where((c) => c.companyCode == d.companyCode)
            .firstOrNull;
        return d.toTableRow(companyName: company?.companyName);
      }).toList();

  // ───── LOAD ─────
  Future<void> load() async {
    final result = await request<List<SafeModel>>(
      showLoader: true,
      call: () => api.get('/safe'),
      onSuccess: (res) {
        final data = res.data;
        List rawList = [];
        if (data is List) {
          rawList = data;
        } else if (data is Map && data['data'] is List) {
          rawList = data['data'] as List;
        }
        final list = rawList
            .whereType<Map>()
            .map((e) => SafeModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        list.sort((a, b) => (a.sortID ?? 0).compareTo(b.sortID ?? 0));
        return list;
      },
    );

    if (result != null) {
      _list = result;
      _isLoaded = true;
      notifyListeners();
    }
  }

  // ───── CREATE ─────
  Future<bool> create(Map<String, dynamic> formValues) async {
    formValues['companyCode'] = _selectedCompanyCode?.toString() ?? '';

    final model = SafeModel.fromFormValues(formValues);

    final result = await request<SafeModel>(
      showLoader: true,
      call: () => api.post('/safe', data: model.toJson()),
      onSuccess: (res) {
        final data = res.data is Map && res.data['data'] is Map ? res.data['data'] : res.data;
        if (data is Map) {
          return SafeModel.fromJson(Map<String, dynamic>.from(data));
        }
        return model;
      },
    );

    if (result != null) {
      _list.insert(0, result);
      notifyListeners();
      return true;
    }
    return false;
  }

  // ───── UPDATE ─────
  Future<bool> update(int code, Map<String, dynamic> formValues) async {
    formValues['companyCode'] = _selectedCompanyCode?.toString() ?? '';

    final model = SafeModel.fromFormValues(formValues);

    final result = await request<SafeModel>(
      showLoader: true,
      call: () => api.put('/safe/$code', data: model.toJson()),
      onSuccess: (res) {
        final data = res.data is Map && res.data['data'] is Map ? res.data['data'] : res.data;
        if (data is Map) {
          return SafeModel.fromJson(Map<String, dynamic>.from(data));
        }
        return model;
      },
    );

    if (result != null) {
      final index = _list.indexWhere((e) => e.safeCode == code);
      if (index != -1) _list[index] = result;
      notifyListeners();
      return true;
    }
    return false;
  }

  // ───── DELETE ─────
  Future<bool> delete(int code) async {
    final result = await request<bool>(
      showLoader: true,
      call: () => api.delete('/safe/$code'),
      onSuccess: (_) => true,
    );

    if (result == true) {
      _list.removeWhere((e) => e.safeCode == code);
      notifyListeners();
      return true;
    }
    return false;
  }
}
