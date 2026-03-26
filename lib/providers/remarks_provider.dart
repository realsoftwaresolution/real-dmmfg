import 'package:rs_dashboard/rs_dashboard.dart';
import '../models/company_model.dart';
import '../models/remarks_model.dart';

class RemarksProvider extends BaseProvider {
  List<RemarksModel> _list = [];
  bool _isLoaded = false;

  List<RemarksModel> get list => _list;
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
        // companyCode se companyName dhundho
        final company = _companies
            .where((c) => c.companyCode == d.companyCode)
            .firstOrNull;
        return d.toTableRow(companyName: company?.companyName);
      }).toList();

  // ───── LOAD ─────
  Future<void> load() async {
    final result = await request<List<RemarksModel>>(
      showLoader: true,
      call: () => api.get('/remarks'),
      onSuccess: (res) {
        final data = res.data as List;
        return data.map((e) => RemarksModel.fromJson(e)).toList();
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

    final model = RemarksModel.fromFormValues(formValues);

    final result = await request<RemarksModel>(
      showLoader: true,
      call: () => api.post('/remarks', data: model.toJson()),
      onSuccess: (res) => RemarksModel.fromJson(res.data),
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

    final model = RemarksModel.fromFormValues(formValues);

    final result = await request<RemarksModel>(
      showLoader: true,
      call: () => api.put('/remarks/$code', data: model.toJson()),
      onSuccess: (res) => RemarksModel.fromJson(res.data),
    );

    if (result != null) {
      final index = _list.indexWhere((e) => e.remarksCode == code);
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
      call: () => api.delete('/remarks/$code'),
      onSuccess: (_) => true,
    );

    if (result == true) {
      _list.removeWhere((e) => e.remarksCode == code);
      notifyListeners();
      return true;
    }
    return false;
  }
}