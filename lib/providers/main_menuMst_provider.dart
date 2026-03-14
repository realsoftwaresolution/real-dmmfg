// lib/providers/main_menu_mst_provider.dart

import 'package:rs_dashboard/rs_dashboard.dart';
import '../models/main_menu_mst_model.dart';

class MainMenuMstProvider extends BaseProvider {
  List<MainMenuMstModel> _list     = [];
  bool                   _isLoaded = false;

  List<MainMenuMstModel>     get list      => List.unmodifiable(_list);
  bool                       get isLoaded  => _isLoaded;

  List<Map<String, dynamic>> get tableData =>
      _list.map((e) => e.toTableRow()).toList();

  // ── LOAD ALL ───────────────────────────────────────────────────────────────
  Future<void> load() async {
    final result = await request<List<MainMenuMstModel>>(
      showLoader: true,
      call:      () => api.get('/mainMenuMst'),
      onSuccess: (res) {
        final data = res.data as List;
        return data.map((e) => MainMenuMstModel.fromJson(e)).toList();
      },
    );
    if (result != null) {
      _list     = result;
      _isLoaded = true;
      notifyListeners();
    }
  }

  // ── GET BY ID ──────────────────────────────────────────────────────────────
  Future<MainMenuMstModel?> getById(int mainMenuMstID) async {
    return await request<MainMenuMstModel>(
      showLoader: true,
      call:      () => api.get('/mainMenuMst/$mainMenuMstID'),
      onSuccess: (res) => MainMenuMstModel.fromJson(res.data),
    );
  }

  // ── CREATE ─────────────────────────────────────────────────────────────────
  Future<bool> create(Map<String, dynamic> formValues) async {
    final model  = MainMenuMstModel.fromFormValues(formValues);
    final result = await request<MainMenuMstModel>(
      showLoader: true,
      call:      () => api.post('/mainMenuMst', data: model.toJson()),
      onSuccess: (res) => MainMenuMstModel.fromJson(res.data),
    );
    if (result != null) {
      _list.insert(0, result);
      notifyListeners();
      return true;
    }
    return false;
  }

  // ── UPDATE ─────────────────────────────────────────────────────────────────
  Future<bool> update(int mainMenuMstID, Map<String, dynamic> formValues) async {
    final model  = MainMenuMstModel.fromFormValues(formValues);
    final result = await request<MainMenuMstModel>(
      showLoader: true,
      call:      () => api.put('/mainMenuMst/$mainMenuMstID', data: model.toJson()),
      onSuccess: (res) => MainMenuMstModel.fromJson(res.data),
    );
    if (result != null) {
      final i = _list.indexWhere((e) => e.mainMenuMstID == mainMenuMstID);
      if (i != -1) _list[i] = result;
      notifyListeners();
      return true;
    }
    return false;
  }

  // ── DELETE ─────────────────────────────────────────────────────────────────
  Future<bool> delete(int mainMenuMstID) async {
    final result = await request<bool>(
      showLoader: true,
      call:      () => api.delete('/mainMenuMst/$mainMenuMstID'),
      onSuccess: (_) => true,
    );
    if (result == true) {
      _list.removeWhere((e) => e.mainMenuMstID == mainMenuMstID);
      notifyListeners();
      return true;
    }
    return false;
  }
}