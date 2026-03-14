// lib/providers/counter_operator_det_provider.dart

import 'package:rs_dashboard/rs_dashboard.dart';
import '../models/counter_operator_det_model.dart';

class CounterOperatorDetProvider extends BaseProvider {
  List<CounterOperatorDetModel> _list     = [];
  bool                          _isLoaded = false;

  List<CounterOperatorDetModel> get list      => List.unmodifiable(_list);
  bool                          get isLoaded  => _isLoaded;

  List<Map<String, dynamic>>    get tableData =>
      _list.map((e) => e.toTableRow()).toList();

  // ── LOAD ALL ───────────────────────────────────────────────────────────────
  Future<void> load() async {
    final result = await request<List<CounterOperatorDetModel>>(
      showLoader: true,
      call:      () => api.get('/counterOperatorDet'),
      onSuccess: (res) {
        final data = res.data as List;
        return data.map((e) => CounterOperatorDetModel.fromJson(e)).toList();
      },
    );
    if (result != null) {
      _list     = result;
      _isLoaded = true;
      notifyListeners();
    }
  }

  // ── GET BY ID ──────────────────────────────────────────────────────────────
  Future<CounterOperatorDetModel?> getById(int id) async {
    return await request<CounterOperatorDetModel>(
      showLoader: true,
      call:      () => api.get('/counterOperatorDet/$id'),
      onSuccess: (res) => CounterOperatorDetModel.fromJson(res.data),
    );
  }

  // ── CREATE ─────────────────────────────────────────────────────────────────
  Future<bool> create(Map<String, dynamic> formValues) async {
    final model  = CounterOperatorDetModel.fromFormValues(formValues);
    final result = await request<CounterOperatorDetModel>(
      showLoader: true,
      call:      () => api.post('/counterOperatorDet', data: model.toJson()),
      onSuccess: (res) => CounterOperatorDetModel.fromJson(res.data),
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
    final model  = CounterOperatorDetModel.fromFormValues(formValues);
    final result = await request<CounterOperatorDetModel>(
      showLoader: true,
      call:      () => api.put('/counterOperatorDet/$id', data: model.toJson()),
      onSuccess: (res) => CounterOperatorDetModel.fromJson(res.data),
    );
    if (result != null) {
      final i = _list.indexWhere((e) => e.counterOperatorDetID == id);
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
      call:      () => api.delete('/counterOperatorDet/$id'),
      onSuccess: (_) => true,
    );
    if (result == true) {
      _list.removeWhere((e) => e.counterOperatorDetID == id);
      notifyListeners();
      return true;
    }
    return false;
  }
}