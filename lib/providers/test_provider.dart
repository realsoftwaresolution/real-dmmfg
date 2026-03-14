// lib/providers/test_provider.dart

import 'package:rs_dashboard/rs_dashboard.dart';
import '../models/test_model.dart';

class TestProvider extends BaseProvider {
  List<TestModel> _list     = [];
  bool            _isLoaded = false;

  List<TestModel>            get list      => List.unmodifiable(_list);
  bool                       get isLoaded  => _isLoaded;

  List<Map<String, dynamic>> get tableData =>
      _list.map((e) => e.toTableRow()).toList();

  // ── LOAD ALL ───────────────────────────────────────────────────────────────
  Future<void> load() async {
    final result = await request<List<TestModel>>(
      showLoader: true,
      call:      () => api.get('/test'),
      onSuccess: (res) {
        final data = res.data as List;
        return data.map((e) => TestModel.fromJson(e)).toList();
      },
    );
    if (result != null) {
      _list     = result;
      _isLoaded = true;
      notifyListeners();
    }
  }

  // ── GET BY ID ──────────────────────────────────────────────────────────────
  Future<TestModel?> getById(int code) async {
    return await request<TestModel>(
      showLoader: true,
      call:      () => api.get('/test/$code'),
      onSuccess: (res) => TestModel.fromJson(res.data),
    );
  }

  // ── CREATE ─────────────────────────────────────────────────────────────────
  Future<bool> create(Map<String, dynamic> formValues) async {
    final model  = TestModel.fromFormValues(formValues);
    final result = await request<TestModel>(
      showLoader: true,
      call:      () => api.post('/test', data: model.toJson()),
      onSuccess: (res) => TestModel.fromJson(res.data),
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
    final model  = TestModel.fromFormValues(formValues);
    final result = await request<TestModel>(
      showLoader: true,
      call:      () => api.put('/test/$code', data: model.toJson()),
      onSuccess: (res) => TestModel.fromJson(res.data),
    );
    if (result != null) {
      final i = _list.indexWhere((e) => e.testCode == code);
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
      call:      () => api.delete('/test/$code'),
      onSuccess: (_) => true,
    );
    if (result == true) {
      _list.removeWhere((e) => e.testCode == code);
      notifyListeners();
      return true;
    }
    return false;
  }
}