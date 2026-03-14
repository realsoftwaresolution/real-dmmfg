// lib/providers/counter_process_provider.dart

import 'package:rs_dashboard/rs_dashboard.dart';
import '../models/counter_process_model.dart';

class CounterProcessProvider extends BaseProvider {
  List<CounterProcessModel> _list          = [];
  List<CounterProcessModel> _counterList   = [];
  bool                      _isLoaded      = false;

  List<CounterProcessModel>  get list         => List.unmodifiable(_list);
  List<CounterProcessModel>  get counterList  => List.unmodifiable(_counterList);
  bool                       get isLoaded     => _isLoaded;

  List<Map<String, dynamic>> get tableData =>
      _list.map((e) => e.toTableRow()).toList();

  List<Map<String, dynamic>> get counterTableData =>
      _counterList.map((e) => e.toTableRow()).toList();

  // ── LOAD ALL ───────────────────────────────────────────────────────────────
  Future<void> load() async {
    final result = await request<List<CounterProcessModel>>(
      showLoader: true,
      call:      () => api.get('/counterProcess'),
      onSuccess: (res) {
        final data = res.data as List;
        return data.map((e) => CounterProcessModel.fromJson(e)).toList();
      },
    );
    if (result != null) {
      _list     = result;
      _isLoaded = true;
      notifyListeners();
    }
  }

  // ── LOAD BY COUNTER (CrId) ─────────────────────────────────────────────────
  Future<void> loadByCounter(int crId) async {
    final result = await request<List<CounterProcessModel>>(
      showLoader: true,
      call:      () => api.get('/counterProcess/counter/$crId'),
      onSuccess: (res) {
        final data = res.data as List;
        return data.map((e) => CounterProcessModel.fromJson(e)).toList();
      },
    );
    if (result != null) {
      _counterList = result;
      notifyListeners();
    }
  }

  // ── GET BY ID ──────────────────────────────────────────────────────────────
  Future<CounterProcessModel?> getById(int id) async {
    return await request<CounterProcessModel>(
      showLoader: true,
      call:      () => api.get('/counterProcess/$id'),
      onSuccess: (res) => CounterProcessModel.fromJson(res.data),
    );
  }

  // ── CREATE ─────────────────────────────────────────────────────────────────
  Future<bool> create(Map<String, dynamic> formValues) async {
    final model  = CounterProcessModel.fromFormValues(formValues);
    final result = await request<CounterProcessModel>(
      showLoader: true,
      call:      () => api.post('/counterProcess', data: model.toJson()),
      onSuccess: (res) => CounterProcessModel.fromJson(res.data),
    );
    if (result != null) {
      _list.insert(0, result);
      // agar same counter ka record hai toh counterList mein bhi add karo
      if (result.crId != null &&
          _counterList.isNotEmpty &&
          _counterList.first.crId == result.crId) {
        _counterList.insert(0, result);
      }
      notifyListeners();
      return true;
    }
    return false;
  }

  // ── UPDATE ─────────────────────────────────────────────────────────────────
  Future<bool> update(int id, Map<String, dynamic> formValues) async {
    final model  = CounterProcessModel.fromFormValues(formValues);
    final result = await request<CounterProcessModel>(
      showLoader: true,
      call:      () => api.put('/counterProcess/$id', data: model.toJson()),
      onSuccess: (res) => CounterProcessModel.fromJson(res.data),
    );
    if (result != null) {
      final i = _list.indexWhere((e) => e.counterProcessDetID == id);
      if (i != -1) _list[i] = result;
      final j = _counterList.indexWhere((e) => e.counterProcessDetID == id);
      if (j != -1) _counterList[j] = result;
      notifyListeners();
      return true;
    }
    return false;
  }

  // ── DELETE ─────────────────────────────────────────────────────────────────
  Future<bool> delete(int id) async {
    final result = await request<bool>(
      showLoader: true,
      call:      () => api.delete('/counterProcess/$id'),
      onSuccess: (_) => true,
    );
    if (result == true) {
      _list.removeWhere((e) => e.counterProcessDetID == id);
      _counterList.removeWhere((e) => e.counterProcessDetID == id);
      notifyListeners();
      return true;
    }
    return false;
  }
}