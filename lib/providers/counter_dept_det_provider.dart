// lib/providers/counter_dept_det_provider.dart

import 'package:rs_dashboard/rs_dashboard.dart';
import '../models/counter_dept_det_model.dart';

class CounterDeptDetProvider extends BaseProvider {
  List<CounterDeptDetModel> _list     = [];
  bool                      _isLoaded = false;

  List<CounterDeptDetModel>  get list      => List.unmodifiable(_list);
  bool                       get isLoaded  => _isLoaded;

  List<Map<String, dynamic>> get tableData =>
      _list.map((e) => e.toTableRow()).toList();

  // ── LOAD ALL ───────────────────────────────────────────────────────────────
  Future<void> load() async {
    final result = await request<List<CounterDeptDetModel>>(
      showLoader: true,
      call:      () => api.get('/counterDeptDet'),
      onSuccess: (res) {
        final data = res.data as List;
        return data.map((e) => CounterDeptDetModel.fromJson(e)).toList();
      },
    );
    if (result != null) {
      _list     = result;
      _isLoaded = true;
      notifyListeners();
    }
  }

  // ── GET BY ID ──────────────────────────────────────────────────────────────
  Future<CounterDeptDetModel?> getById(int id) async {
    return await request<CounterDeptDetModel>(
      showLoader: true,
      call:      () => api.get('/counterDeptDet/$id'),
      onSuccess: (res) => CounterDeptDetModel.fromJson(res.data),
    );
  }

  // ── CREATE ─────────────────────────────────────────────────────────────────
  Future<bool> create(Map<String, dynamic> formValues) async {
    final model  = CounterDeptDetModel.fromFormValues(formValues);
    final result = await request<CounterDeptDetModel>(
      showLoader: true,
      call:      () => api.post('/counterDeptDet', data: model.toJson()),
      onSuccess: (res) => CounterDeptDetModel.fromJson(res.data),
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
    final model  = CounterDeptDetModel.fromFormValues(formValues);
    final result = await request<CounterDeptDetModel>(
      showLoader: true,
      call:      () => api.put('/counterDeptDet/$id', data: model.toJson()),
      onSuccess: (res) => CounterDeptDetModel.fromJson(res.data),
    );
    if (result != null) {
      final i = _list.indexWhere((e) => e.counterDeptDetID == id);
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
      call:      () => api.delete('/counterDeptDet/$id'),
      onSuccess: (_) => true,
    );
    if (result == true) {
      _list.removeWhere((e) => e.counterDeptDetID == id);
      notifyListeners();
      return true;
    }
    return false;
  }
}