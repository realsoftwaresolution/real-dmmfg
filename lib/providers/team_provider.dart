// lib/providers/team_provider.dart

import 'package:rs_dashboard/rs_dashboard.dart';
import '../models/company_model.dart';
import '../models/team_model.dart';

class TeamProvider extends BaseProvider {
  List<TeamModel> _list     = [];
  bool            _isLoaded = false;

  List<TeamModel>            get list     => List.unmodifiable(_list);
  bool                       get isLoaded => _isLoaded;

  // ── Company lookup (inject from CompanyProvider) ──────────────────────────
  List<CompanyModel> _companies = [];

  void setCompanies(List<CompanyModel> companies) {
    _companies = companies;
    notifyListeners();
  }

  List<Map<String, dynamic>> get tableData => _list.map((d) {
    final company = _companies
        .where((c) => c.companyCode == d.companyCode)
        .firstOrNull;
    return d.toTableRow(companyName: company?.companyName);
  }).toList();

  // ── LOAD ───────────────────────────────────────────────────────────────────
  Future<void> load() async {
    final result = await request<List<TeamModel>>(
      showLoader: true,
      call:      () => api.get('/team'),
      onSuccess: (res) {
        final data = res.data as List;
        return data.map((e) => TeamModel.fromJson(e)).toList();
      },
    );
    if (result != null) {
      _list     = result;
      _isLoaded = true;
      notifyListeners();
    }
  }

  // ── CREATE ─────────────────────────────────────────────────────────────────
  Future<bool> create(Map<String, dynamic> formValues) async {
    final model  = TeamModel.fromFormValues(formValues);
    final result = await request<TeamModel>(
      showLoader: true,
      call:      () => api.post('/team', data: model.toJson()),
      onSuccess: (res) => TeamModel.fromJson(res.data),
    );
    if (result != null) {
      _list.insert(0, result);
      notifyListeners();
      return true;
    }
    return false;
  }

  // ── UPDATE ─────────────────────────────────────────────────────────────────
  Future<bool> update(int code, Map<String, dynamic> formValues) async {
    final model  = TeamModel.fromFormValues(formValues);
    final result = await request<TeamModel>(
      showLoader: true,
      call:      () => api.put('/team/$code', data: model.toJson()),
      onSuccess: (res) => TeamModel.fromJson(res.data),
    );
    if (result != null) {
      final i = _list.indexWhere((e) => e.teamCode == code);
      if (i != -1) _list[i] = result;
      notifyListeners();
      return true;
    }
    return false;
  }

  // ── DELETE ─────────────────────────────────────────────────────────────────
  Future<bool> delete(int code) async {
    final result = await request<bool>(
      showLoader: true,
      call:      () => api.delete('/team/$code'),
      onSuccess: (_) => true,
    );
    if (result == true) {
      _list.removeWhere((e) => e.teamCode == code);
      notifyListeners();
      return true;
    }
    return false;
  }
}