// lib/providers/counter_shape_det_provider.dart

import 'package:rs_dashboard/rs_dashboard.dart';
import '../models/counter_shape_det_model.dart';

class CounterShapeDetProvider extends BaseProvider {
  List<CounterShapeDetModel> _list     = [];
  bool                       _isLoaded = false;

  List<CounterShapeDetModel> get list      => List.unmodifiable(_list);
  bool                       get isLoaded  => _isLoaded;

  List<Map<String, dynamic>> get tableData =>
      _list.map((e) => e.toTableRow()).toList();

  // ── LOAD ALL ───────────────────────────────────────────────────────────────
  Future<void> load() async {
    final result = await request<List<CounterShapeDetModel>>(
      showLoader: true,
      call:      () => api.get('/counterShapeDet'),
      onSuccess: (res) {
        final data = res.data as List;
        return data.map((e) => CounterShapeDetModel.fromJson(e)).toList();
      },
    );
    if (result != null) {
      _list     = result;
      _isLoaded = true;
      notifyListeners();
    }
  }

  // ── GET BY ID ──────────────────────────────────────────────────────────────
  Future<CounterShapeDetModel?> getById(int id) async {
    return await request<CounterShapeDetModel>(
      showLoader: true,
      call:      () => api.get('/counterShapeDet/$id'),
      onSuccess: (res) => CounterShapeDetModel.fromJson(res.data),
    );
  }

  // ── CREATE ─────────────────────────────────────────────────────────────────
  Future<bool> create(Map<String, dynamic> formValues) async {
    final model  = CounterShapeDetModel.fromFormValues(formValues);
    final result = await request<CounterShapeDetModel>(
      showLoader: true,
      call:      () => api.post('/counterShapeDet', data: model.toJson()),
      onSuccess: (res) => CounterShapeDetModel.fromJson(res.data),
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
    final model  = CounterShapeDetModel.fromFormValues(formValues);
    final result = await request<CounterShapeDetModel>(
      showLoader: true,
      call:      () => api.put('/counterShapeDet/$id', data: model.toJson()),
      onSuccess: (res) => CounterShapeDetModel.fromJson(res.data),
    );
    if (result != null) {
      final i = _list.indexWhere((e) => e.counterShapeDetID == id);
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
      call:      () => api.delete('/counterShapeDet/$id'),
      onSuccess: (_) => true,
    );
    if (result == true) {
      _list.removeWhere((e) => e.counterShapeDetID == id);
      notifyListeners();
      return true;
    }
    return false;
  }
}