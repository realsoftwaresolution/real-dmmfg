// lib/providers/menu_mst_provider.dart

import 'package:rs_dashboard/rs_dashboard.dart';
import '../models/menu_mst_model.dart';

class MenuMstProvider extends BaseProvider {
  List<MenuMstModel> _list     = [];
  bool               _isLoaded = false;

  List<MenuMstModel>         get list      => List.unmodifiable(_list);
  bool                       get isLoaded  => _isLoaded;

  List<Map<String, dynamic>> get tableData =>
      _list.map((e) => e.toTableRow()).toList();

  // ── LOAD ALL ───────────────────────────────────────────────────────────────
  Future<void> load() async {
    final result = await request<List<MenuMstModel>>(
      showLoader: true,
      call:      () => api.get('/menuMst'),
      onSuccess: (res) {
        final data = res.data as List;
        return data.map((e) => MenuMstModel.fromJson(e)).toList();
      },
    );
    if (result != null) {
      _list     = result;
      _isLoaded = true;
      notifyListeners();
    }
  }

  // ── GET BY ID ──────────────────────────────────────────────────────────────
  Future<MenuMstModel?> getById(int menuMstID) async {
    return await request<MenuMstModel>(
      showLoader: true,
      call:      () => api.get('/menuMst/$menuMstID'),
      onSuccess: (res) => MenuMstModel.fromJson(res.data),
    );
  }

  // ── CREATE ─────────────────────────────────────────────────────────────────
  Future<bool> create(Map<String, dynamic> formValues) async {
    final model  = MenuMstModel.fromFormValues(formValues);
    final result = await request<MenuMstModel>(
      showLoader: true,
      call:      () => api.post('/menuMst', data: model.toJson()),
      onSuccess: (res) => MenuMstModel.fromJson(res.data),
    );
    if (result != null) {
      _list.insert(0, result);
      notifyListeners();
      return true;
    }
    return false;
  }

  // ── UPDATE ─────────────────────────────────────────────────────────────────
  Future<bool> update(int menuMstID, Map<String, dynamic> formValues) async {
    final model  = MenuMstModel.fromFormValues(formValues);
    final result = await request<MenuMstModel>(
      showLoader: true,
      call:      () => api.put('/menuMst/$menuMstID', data: model.toJson()),
      onSuccess: (res) => MenuMstModel.fromJson(res.data),
    );
    if (result != null) {
      final i = _list.indexWhere((e) => e.menuMstID == menuMstID);
      if (i != -1) _list[i] = result;
      notifyListeners();
      return true;
    }
    return false;
  }

  // ── DELETE ─────────────────────────────────────────────────────────────────
  Future<bool> delete(int menuMstID) async {
    final result = await request<bool>(
      showLoader: true,
      call:      () => api.delete('/menuMst/$menuMstID'),
      onSuccess: (_) => true,
    );
    if (result == true) {
      _list.removeWhere((e) => e.menuMstID == menuMstID);
      notifyListeners();
      return true;
    }
    return false;
  }
}