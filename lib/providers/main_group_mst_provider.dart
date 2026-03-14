// lib/providers/main_group_mst_provider.dart

import 'package:rs_dashboard/rs_dashboard.dart';
import '../models/main_group_mst_model.dart';

class MainGroupMstProvider extends BaseProvider {
  List<MainGroupMstModel> _list     = [];
  bool                    _isLoaded = false;

  List<MainGroupMstModel>    get list      => List.unmodifiable(_list);
  bool                       get isLoaded  => _isLoaded;

  List<Map<String, dynamic>> get tableData =>
      _list.map((e) => e.toTableRow()).toList();

  // ── LOAD ALL ───────────────────────────────────────────────────────────────
  Future<void> load() async {
    final result = await request<List<MainGroupMstModel>>(
      showLoader: true,
      call:      () => api.get('/mainGroup'),
      onSuccess: (res) {
        final data = res.data as List;
        return data.map((e) => MainGroupMstModel.fromJson(e)).toList();
      },
    );
    if (result != null) {
      _list     = result;
      _isLoaded = true;
      notifyListeners();
    }
  }

  // ── GET BY ID ──────────────────────────────────────────────────────────────
  Future<MainGroupMstModel?> getById(int mainGroupMstID) async {
    return await request<MainGroupMstModel>(
      showLoader: true,
      call:      () => api.get('/mainGroup/$mainGroupMstID'),
      onSuccess: (res) => MainGroupMstModel.fromJson(res.data),
    );
  }

  // ── CREATE ─────────────────────────────────────────────────────────────────
  Future<bool> create(Map<String, dynamic> formValues) async {
    final model  = MainGroupMstModel.fromFormValues(formValues);
    final result = await request<MainGroupMstModel>(
      showLoader: true,
      call:      () => api.post('/mainGroup', data: model.toJson()),
      onSuccess: (res) => MainGroupMstModel.fromJson(res.data),
    );
    if (result != null) {
      _list.insert(0, result);
      notifyListeners();
      return true;
    }
    return false;
  }

  // ── UPDATE ─────────────────────────────────────────────────────────────────
  Future<bool> update(int mainGroupMstID, Map<String, dynamic> formValues) async {
    final model  = MainGroupMstModel.fromFormValues(formValues);
    final result = await request<MainGroupMstModel>(
      showLoader: true,
      call:      () => api.put('/mainGroup/$mainGroupMstID', data: model.toJson()),
      onSuccess: (res) => MainGroupMstModel.fromJson(res.data),
    );
    if (result != null) {
      final i = _list.indexWhere((e) => e.mainGroupMstID == mainGroupMstID);
      if (i != -1) _list[i] = result;
      notifyListeners();
      return true;
    }
    return false;
  }

  // ── DELETE ─────────────────────────────────────────────────────────────────
  Future<bool> delete(int mainGroupMstID) async {
    final result = await request<bool>(
      showLoader: true,
      call:      () => api.delete('/mainGroup/$mainGroupMstID'),
      onSuccess: (_) => true,
    );
    if (result == true) {
      _list.removeWhere((e) => e.mainGroupMstID == mainGroupMstID);
      notifyListeners();
      return true;
    }
    return false;
  }
}