// lib/providers/counter_stock_type_det_provider.dart

import 'package:rs_dashboard/rs_dashboard.dart';
import '../models/counter_stock_type_det_model.dart';

class CounterStockTypeDetProvider extends BaseProvider {
  List<CounterStockTypeDetModel> _list     = [];
  bool                           _isLoaded = false;

  List<CounterStockTypeDetModel> get list      => List.unmodifiable(_list);
  bool                           get isLoaded  => _isLoaded;

  List<Map<String, dynamic>>     get tableData =>
      _list.map((e) => e.toTableRow()).toList();

  // ── LOAD ALL ───────────────────────────────────────────────────────────────
  Future<void> load() async {
    final result = await request<List<CounterStockTypeDetModel>>(
      showLoader: true,
      call:      () => api.get('/counterStockTypeDet'),
      onSuccess: (res) {
        final data = res.data as List;
        return data.map((e) => CounterStockTypeDetModel.fromJson(e)).toList();
      },
    );
    if (result != null) {
      _list     = result;
      _isLoaded = true;
      notifyListeners();
    }
  }

  // ── GET BY ID ──────────────────────────────────────────────────────────────
  Future<CounterStockTypeDetModel?> getById(int id) async {
    return await request<CounterStockTypeDetModel>(
      showLoader: true,
      call:      () => api.get('/counterStockTypeDet/$id'),
      onSuccess: (res) => CounterStockTypeDetModel.fromJson(res.data),
    );
  }

  // ── CREATE ─────────────────────────────────────────────────────────────────
  Future<bool> create(Map<String, dynamic> formValues) async {
    final model  = CounterStockTypeDetModel.fromFormValues(formValues);
    final result = await request<CounterStockTypeDetModel>(
      showLoader: true,
      call:      () => api.post('/counterStockTypeDet', data: model.toJson()),
      onSuccess: (res) => CounterStockTypeDetModel.fromJson(res.data),
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
    final model  = CounterStockTypeDetModel.fromFormValues(formValues);
    final result = await request<CounterStockTypeDetModel>(
      showLoader: true,
      call:      () => api.put('/counterStockTypeDet/$id', data: model.toJson()),
      onSuccess: (res) => CounterStockTypeDetModel.fromJson(res.data),
    );
    if (result != null) {
      final i = _list.indexWhere((e) => e.counterStockTypeDetID == id);
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
      call:      () => api.delete('/counterStockTypeDet/$id'),
      onSuccess: (_) => true,
    );
    if (result == true) {
      _list.removeWhere((e) => e.counterStockTypeDetID == id);
      notifyListeners();
      return true;
    }
    return false;
  }
}