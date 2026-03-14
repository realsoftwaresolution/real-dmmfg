// lib/providers/counter_type_provider.dart

import 'package:rs_dashboard/rs_dashboard.dart';
import '../models/counter_type_model.dart';

class CounterTypeProvider extends BaseProvider {
  List<CounterTypeModel> _list     = [];
  bool                   _isLoaded = false;

  List<CounterTypeModel>     get list      => List.unmodifiable(_list);
  bool                       get isLoaded  => _isLoaded;
  List<Map<String, dynamic>> get tableData =>
      _list.map((e) => e.toTableRow()).toList();

  // ── LOAD ──────────────────────────────────────────────────────────────────
  Future<void> load() async {
    final result = await request<List<CounterTypeModel>>(
      showLoader: true,
      call: () => api.get('/counterType'),
      onSuccess: (res) {
        final data = res.data as List;
        return data.map((e) => CounterTypeModel.fromJson(e)).toList();
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
    final model  = CounterTypeModel.fromFormValues(formValues);
    final result = await request<CounterTypeModel>(
      showLoader: true,
      call:      () => api.post('/counterType', data: model.toJson()),
      onSuccess: (res) => CounterTypeModel.fromJson(res.data),
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
    final model  = CounterTypeModel.fromFormValues(formValues);
    final result = await request<CounterTypeModel>(
      showLoader: true,
      call:      () => api.put('/counterType/$code', data: model.toJson()),
      onSuccess: (res) => CounterTypeModel.fromJson(res.data),
    );
    if (result != null) {
      final i = _list.indexWhere((e) => e.counterTypeCode == code);
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
      call:      () => api.delete('/counterType/$code'),
      onSuccess: (_) => true,
    );
    if (result == true) {
      _list.removeWhere((e) => e.counterTypeCode == code);
      notifyListeners();
      return true;
    }
    return false;
  }
}