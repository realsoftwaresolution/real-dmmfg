import 'package:rs_dashboard/rs_dashboard.dart';
import '../models/company_model.dart';
import '../models/purity_rpt_group_model.dart';

class PurityRptGroupProvider extends BaseProvider {
  List<PurityRptGroupModel> _list = [];
  bool _isLoaded = false;

  List<PurityRptGroupModel> get list => _list;
  bool get isLoaded => _isLoaded;


  List<CompanyModel> _companies = [];

  void setCompanies(List<CompanyModel> companies) {
    _companies = companies;
    notifyListeners();
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
    final result = await request<List<PurityRptGroupModel>>(
      showLoader: true,
      call: () => api.get('/purity-rpt-group'),
      onSuccess: (res) {
        final data = res.data as List;
        return data.map((e) => PurityRptGroupModel.fromJson(e)).toList();
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
    final model = PurityRptGroupModel.fromFormValues(formValues);

    final result = await request<PurityRptGroupModel>(
      showLoader: true,
      call: () => api.post('/purity-rpt-group', data: model.toJson()),
      onSuccess: (res) => PurityRptGroupModel.fromJson(res.data),
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
    final model = PurityRptGroupModel.fromFormValues(formValues);

    final result = await request<PurityRptGroupModel>(
      showLoader: true,
      call: () => api.put('/purity-rpt-group/$code', data: model.toJson()),
      onSuccess: (res) => PurityRptGroupModel.fromJson(res.data),
    );

    if (result != null) {
      final index =
      _list.indexWhere((e) => e.purityRptGroupCode == code);
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
      call: () => api.delete('/purity-rpt-group/$code'),
      onSuccess: (_) => true,
    );

    if (result == true) {
      _list.removeWhere((e) => e.purityRptGroupCode == code);
      notifyListeners();
      return true;
    }
    return false;
  }
}