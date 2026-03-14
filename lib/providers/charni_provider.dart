import 'package:rs_dashboard/rs_dashboard.dart';
import '../models/charni_model.dart';
import '../models/company_model.dart';

class CharniProvider extends BaseProvider {
  List<CharniModel> _list = [];
  bool _isLoaded = false;

  List<CharniModel> get list => _list;
  bool get isLoaded => _isLoaded;

  List<CompanyModel> _companies = [];

  void setCompanies(List<CompanyModel> companies) {
    _companies = companies;
    notifyListeners();
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
    final result = await request<List<CharniModel>>(
      showLoader: true,
      call: () => api.get('/charni'),
      onSuccess: (res) {
        final data = res.data as List;
        return data.map((e) => CharniModel.fromJson(e)).toList();
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
    final model = CharniModel.fromFormValues(formValues);

    final result = await request<CharniModel>(
      showLoader: true,
      call: () => api.post('/charni', data: model.toJson()),
      onSuccess: (res) => CharniModel.fromJson(res.data),
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
    final model = CharniModel.fromFormValues(formValues);

    final result = await request<CharniModel>(
      showLoader: true,
      call: () => api.put('/charni/$code', data: model.toJson()),
      onSuccess: (res) => CharniModel.fromJson(res.data),
    );

    if (result != null) {
      final index = _list.indexWhere((e) => e.charniCode == code);
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
      call: () => api.delete('/charni/$code'),
      onSuccess: (_) => true,
    );

    if (result == true) {
      _list.removeWhere((e) => e.charniCode == code);
      notifyListeners();
      return true;
    }
    return false;
  }
}