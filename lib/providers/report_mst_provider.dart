// lib/providers/report_mst_provider.dart

import 'package:rs_dashboard/rs_dashboard.dart';
import '../models/report_mst_model.dart';

class ReportMstProvider extends BaseProvider {
  List<ReportMstModel> _list     = [];
  bool                 _isLoaded = false;

  List<ReportMstModel>       get list      => List.unmodifiable(_list);
  bool                       get isLoaded  => _isLoaded;

  List<Map<String, dynamic>> get tableData =>
      _list.map((e) => e.toTableRow()).toList();

  // ── LOAD ALL ───────────────────────────────────────────────────────────────
  Future<void> load() async {
    final result = await request<List<ReportMstModel>>(
      showLoader: true,
      call:      () => api.get('/report'),
      onSuccess: (res) {
        final data = res.data as List;
        return data.map((e) => ReportMstModel.fromJson(e)).toList();
      },
    );
    if (result != null) {
      _list     = result;
      _isLoaded = true;
      notifyListeners();
    }
  }

  // ── GET BY ID ──────────────────────────────────────────────────────────────
  Future<ReportMstModel?> getById(int reportMstID) async {
    return await request<ReportMstModel>(
      showLoader: true,
      call:      () => api.get('/report/$reportMstID'),
      onSuccess: (res) => ReportMstModel.fromJson(res.data),
    );
  }

  // ── CREATE ─────────────────────────────────────────────────────────────────
  Future<bool> create(Map<String, dynamic> formValues) async {
    final model  = ReportMstModel.fromFormValues(formValues);
    final result = await request<ReportMstModel>(
      showLoader: true,
      call:      () => api.post('/report', data: model.toJson()),
      onSuccess: (res) => ReportMstModel.fromJson(res.data),
    );
    if (result != null) {
      _list.insert(0, result);
      notifyListeners();
      return true;
    }
    return false;
  }

  // ── UPDATE ─────────────────────────────────────────────────────────────────
  Future<bool> update(int reportMstID, Map<String, dynamic> formValues) async {
    final model  = ReportMstModel.fromFormValues(formValues);
    final result = await request<ReportMstModel>(
      showLoader: true,
      call:      () => api.put('/report/$reportMstID', data: model.toJson()),
      onSuccess: (res) => ReportMstModel.fromJson(res.data),
    );
    if (result != null) {
      final i = _list.indexWhere((e) => e.reportMstID == reportMstID);
      if (i != -1) _list[i] = result;
      notifyListeners();
      return true;
    }
    return false;
  }

  // ── DELETE ─────────────────────────────────────────────────────────────────
  Future<bool> delete(int reportMstID) async {
    final result = await request<bool>(
      showLoader: true,
      call:      () => api.delete('/report/$reportMstID'),
      onSuccess: (_) => true,
    );
    if (result == true) {
      _list.removeWhere((e) => e.reportMstID == reportMstID);
      notifyListeners();
      return true;
    }
    return false;
  }
}