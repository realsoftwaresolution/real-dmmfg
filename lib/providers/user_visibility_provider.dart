// lib/providers/user_visibility_provider.dart

import 'package:rs_dashboard/rs_dashboard.dart';
import '../models/user_visibility_model.dart';

class UserVisibilityProvider extends BaseProvider {
  List<UserVisibilityModel> _list      = [];
  List<UserVisibilityModel> _deptList  = [];
  bool                      _isLoaded  = false;

  List<UserVisibilityModel>  get list      => List.unmodifiable(_list);
  List<UserVisibilityModel>  get deptList  => List.unmodifiable(_deptList);
  bool                       get isLoaded  => _isLoaded;

  List<Map<String, dynamic>> get tableData =>
      _list.map((e) => e.toTableRow()).toList();

  List<Map<String, dynamic>> get deptTableData =>
      _deptList.map((e) => e.toTableRow()).toList();

  // ── LOAD ALL ───────────────────────────────────────────────────────────────
  Future<void> load() async {
    final result = await request<List<UserVisibilityModel>>(
      showLoader: true,
      call:      () => api.get('/userVisibility'),
      onSuccess: (res) {
        final data = res.data as List;
        return data.map((e) => UserVisibilityModel.fromJson(e)).toList();
      },
    );
    if (result != null) {
      _list     = result;
      _isLoaded = true;
      notifyListeners();
    }
  }

  // ── LOAD DEPT ONLY ─────────────────────────────────────────────────────────
  Future<void> loadDept() async {
    final result = await request<List<UserVisibilityModel>>(
      showLoader: true,
      call:      () => api.get('/userVisibility/dept'),
      onSuccess: (res) {
        final data = res.data as List;
        return data.map((e) => UserVisibilityModel.fromJson(e)).toList();
      },
    );
    if (result != null) {
      _deptList = result;
      notifyListeners();
    }
  }

  // ── CREATE ─────────────────────────────────────────────────────────────────
  Future<bool> create(Map<String, dynamic> formValues) async {
    final model  = UserVisibilityModel.fromFormValues(formValues);
    final result = await request<UserVisibilityModel>(
      showLoader: true,
      call:      () => api.post('/userVisibility', data: model.toJson()),
      onSuccess: (res) => UserVisibilityModel.fromJson(res.data),
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
    final model  = UserVisibilityModel.fromFormValues(formValues);
    final result = await request<UserVisibilityModel>(
      showLoader: true,
      call:      () => api.put('/userVisibility/$code', data: model.toJson()),
      onSuccess: (res) => UserVisibilityModel.fromJson(res.data),
    );
    if (result != null) {
      final i = _list.indexWhere((e) => e.userVisibilityCode == code);
      if (i != -1) _list[i] = result;
      // deptList bhi update karo agar wahan ho
      final j = _deptList.indexWhere((e) => e.userVisibilityCode == code);
      if (j != -1) _deptList[j] = result;
      notifyListeners();
      return true;
    }
    return false;
  }

  // ── DELETE ─────────────────────────────────────────────────────────────────
  Future<bool> delete(int code) async {
    final result = await request<bool>(
      showLoader: true,
      call:      () => api.delete('/userVisibility/$code'),
      onSuccess: (_) => true,
    );
    if (result == true) {
      _list.removeWhere((e) => e.userVisibilityCode == code);
      _deptList.removeWhere((e) => e.userVisibilityCode == code);
      notifyListeners();
      return true;
    }
    return false;
  }
}