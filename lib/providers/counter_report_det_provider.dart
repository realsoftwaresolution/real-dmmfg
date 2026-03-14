// lib/providers/counter_report_det_provider.dart

import 'package:rs_dashboard/rs_dashboard.dart';
import '../models/counter_report_det_model.dart';

class CounterReportDetProvider extends BaseProvider {
  List<CounterReportDetModel> _list     = [];
  bool                        _isLoaded = false;

  List<CounterReportDetModel> get list      => List.unmodifiable(_list);
  bool                        get isLoaded  => _isLoaded;

  List<Map<String, dynamic>>  get tableData =>
      _list.map((e) => e.toTableRow()).toList();

  // ── LOAD ALL ───────────────────────────────────────────────────────────────
  Future<void> load() async {
    final result = await request<List<CounterReportDetModel>>(
      showLoader: true,
      call:      () => api.get('/counterReportDet'),
      onSuccess: (res) {
        final data = res.data as List;
        return data.map((e) => CounterReportDetModel.fromJson(e)).toList();
      },
    );
    if (result != null) {
      _list     = result;
      _isLoaded = true;
      notifyListeners();
    }
  }

  // ── GET BY ID ──────────────────────────────────────────────────────────────
  Future<CounterReportDetModel?> getById(int id) async {
    return await request<CounterReportDetModel>(
      showLoader: true,
      call:      () => api.get('/counterReportDet/$id'),
      onSuccess: (res) => CounterReportDetModel.fromJson(res.data),
    );
  }

  // ── CREATE ─────────────────────────────────────────────────────────────────
  Future<bool> create(Map<String, dynamic> formValues) async {
    final model  = CounterReportDetModel.fromFormValues(formValues);
    final result = await request<CounterReportDetModel>(
      showLoader: true,
      call:      () => api.post('/counterReportDet', data: model.toJson()),
      onSuccess: (res) => CounterReportDetModel.fromJson(res.data),
    );
    if (result != null) {
      _list.insert(0, result);
      notifyListeners();
      return true;
    }
    return false;
  }

  // ── UPDATE ─────────────────────────────────────────────────────────────────
  Future<bool> update(int id, Map<String, dynamic> formValues) async {
    final model  = CounterReportDetModel.fromFormValues(formValues);
    final result = await request<CounterReportDetModel>(
      showLoader: true,
      call:      () => api.put('/counterReportDet/$id', data: model.toJson()),
      onSuccess: (res) => CounterReportDetModel.fromJson(res.data),
    );
    if (result != null) {
      final i = _list.indexWhere((e) => e.counterReportDetID == id);
      if (i != -1) _list[i] = result;
      notifyListeners();
      return true;
    }
    return false;
  }

  // ── DELETE ─────────────────────────────────────────────────────────────────
  Future<bool> delete(int id) async {
    final result = await request<bool>(
      showLoader: true,
      call:      () => api.delete('/counterReportDet/$id'),
      onSuccess: (_) => true,
    );
    if (result == true) {
      _list.removeWhere((e) => e.counterReportDetID == id);
      notifyListeners();
      return true;
    }
    return false;
  }
}