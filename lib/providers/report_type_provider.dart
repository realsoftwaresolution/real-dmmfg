// lib/providers/report_type_provider.dart

import 'package:rs_dashboard/rs_dashboard.dart';
import '../models/report_type_model.dart';

class ReportTypeProvider extends BaseProvider {
  List<ReportTypeModel> _list     = [];
  bool                  _isLoaded = false;

  List<ReportTypeModel>      get list      => List.unmodifiable(_list);
  bool                       get isLoaded  => _isLoaded;

  List<Map<String, dynamic>> get tableData =>
      _list.map((e) => e.toTableRow()).toList();

  // ── LOAD ALL ───────────────────────────────────────────────────────────────
  Future<void> load() async {
    final result = await request<List<ReportTypeModel>>(
      showLoader: true,
      call:      () => api.get('/reportType'),
      onSuccess: (res) {
        final data = res.data as List;
        return data.map((e) => ReportTypeModel.fromJson(e)).toList();
      },
    );
    if (result != null) {
      _list     = result;
      _isLoaded = true;
      notifyListeners();
    }
  }

  // ── GET BY ID ──────────────────────────────────────────────────────────────
  Future<ReportTypeModel?> getById(int reportTypeCode) async {
    return await request<ReportTypeModel>(
      showLoader: true,
      call:      () => api.get('/reportType/$reportTypeCode'),
      onSuccess: (res) => ReportTypeModel.fromJson(res.data),
    );
  }

  // ── CREATE ─────────────────────────────────────────────────────────────────
  Future<bool> create(Map<String, dynamic> formValues) async {
    final model  = ReportTypeModel.fromFormValues(formValues);
    final result = await request<ReportTypeModel>(
      showLoader: true,
      call:      () => api.post('/reportType', data: model.toJson()),
      onSuccess: (res) => ReportTypeModel.fromJson(res.data),
    );
    if (result != null) {
      _list.insert(0, result);
      notifyListeners();
      return true;
    }
    return false;
  }

  // ── UPDATE ─────────────────────────────────────────────────────────────────
  Future<bool> update(int reportTypeCode, Map<String, dynamic> formValues) async {
    final model  = ReportTypeModel.fromFormValues(formValues);
    final result = await request<ReportTypeModel>(
      showLoader: true,
      call:      () => api.put('/reportType/$reportTypeCode', data: model.toJson()),
      onSuccess: (res) => ReportTypeModel.fromJson(res.data),
    );
    if (result != null) {
      final i = _list.indexWhere((e) => e.reportTypeCode == reportTypeCode);
      if (i != -1) _list[i] = result;
      notifyListeners();
      return true;
    }
    return false;
  }

  // ── DELETE ─────────────────────────────────────────────────────────────────
  Future<bool> delete(int reportTypeCode) async {
    final result = await request<bool>(
      showLoader: true,
      call:      () => api.delete('/reportType/$reportTypeCode'),
      onSuccess: (_) => true,
    );
    if (result == true) {
      _list.removeWhere((e) => e.reportTypeCode == reportTypeCode);
      notifyListeners();
      return true;
    }
    return false;
  }
}