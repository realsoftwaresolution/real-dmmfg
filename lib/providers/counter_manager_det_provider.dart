// // lib/providers/counter_manager_det_provider.dart
//
// import 'package:rs_dashboard/rs_dashboard.dart';
// import '../models/counter_manager_det_model.dart';
//
// class CounterManagerDetProvider extends BaseProvider {
//   List<CounterManagerDetModel> _list     = [];
//   bool                         _isLoaded = false;
//
//   List<CounterManagerDetModel> get list      => List.unmodifiable(_list);
//   bool                         get isLoaded  => _isLoaded;
//
//   List<Map<String, dynamic>>   get tableData =>
//       _list.map((e) => e.toTableRow()).toList();
//
//   // ── LOAD ALL ───────────────────────────────────────────────────────────────
//   Future<void> load() async {
//     final result = await request<List<CounterManagerDetModel>>(
//       showLoader: true,
//       call:      () => api.get('/counterManagerDet'),
//       onSuccess: (res) {
//         final data = res.data as List;
//         return data.map((e) => CounterManagerDetModel.fromJson(e)).toList();
//       },
//     );
//     if (result != null) {
//       _list     = result;
//       _isLoaded = true;
//       notifyListeners();
//     }
//   }
//
//   // ── GET BY ID ──────────────────────────────────────────────────────────────
//   Future<CounterManagerDetModel?> getById(int id) async {
//     return await request<CounterManagerDetModel>(
//       showLoader: true,
//       call:      () => api.get('/counterManagerDet/$id'),
//       onSuccess: (res) => CounterManagerDetModel.fromJson(res.data),
//     );
//   }
//
//   // ── CREATE ─────────────────────────────────────────────────────────────────
//   Future<bool> create(Map<String, dynamic> formValues) async {
//     final model  = CounterManagerDetModel.fromFormValues(formValues);
//     final result = await request<CounterManagerDetModel>(
//       showLoader: true,
//       call:      () => api.post('/counterManagerDet', data: model.toJson()),
//       onSuccess: (res) => CounterManagerDetModel.fromJson(res.data),
//     );
//     if (result != null) {
//       _list.insert(0, result);
//       notifyListeners();
//       return true;
//     }
//     return false;
//   }
//
//   // ── UPDATE ─────────────────────────────────────────────────────────────────
//   Future<bool> update(int id, Map<String, dynamic> formValues) async {
//     final model  = CounterManagerDetModel.fromFormValues(formValues);
//     final result = await request<CounterManagerDetModel>(
//       showLoader: true,
//       call:      () => api.put('/counterManagerDet/$id', data: model.toJson()),
//       onSuccess: (res) => CounterManagerDetModel.fromJson(res.data),
//     );
//     if (result != null) {
//       final i = _list.indexWhere((e) => e.counterManagerDetID == id);
//       if (i != -1) _list[i] = result;
//       notifyListeners();
//       return true;
//     }
//     return false;
//   }
//
//   // ── DELETE ─────────────────────────────────────────────────────────────────
//   Future<bool> delete(int id) async {
//     final result = await request<bool>(
//       showLoader: true,
//       call:      () => api.delete('/counterManagerDet/$id'),
//       onSuccess: (_) => true,
//     );
//     if (result == true) {
//       _list.removeWhere((e) => e.counterManagerDetID == id);
//       notifyListeners();
//       return true;
//     }
//     return false;
//   }
// }
// lib/providers/counter_manager_det_provider.dart

import 'package:rs_dashboard/rs_dashboard.dart';
import '../models/counter_manager_det_model.dart';

class CounterManagerDetProvider extends BaseProvider {
  List<CounterManagerDetModel> _list     = [];
  bool                         _isLoaded = false;

  List<CounterManagerDetModel> get list      => List.unmodifiable(_list);
  bool                         get isLoaded  => _isLoaded;

  List<Map<String, dynamic>>   get tableData =>
      _list.map((e) => e.toTableRow()).toList();

  // ── LOAD ALL ───────────────────────────────────────────────────────────────
  Future<void> load() async {
    final result = await request<List<CounterManagerDetModel>>(
      showLoader: true,
      call:      () => api.get('/counterManagerDet'),
      onSuccess: (res) {
        final data = res.data as List;
        return data.map((e) => CounterManagerDetModel.fromJson(e)).toList();
      },
    );
    if (result != null) {
      _list     = result;
      _isLoaded = true;
      notifyListeners();
    }
  }

  // ── LOAD BY CrId ───────────────────────────────────────────────────────────
  Future<void> loadByCrId(int crId) async {
    final result = await request<List<CounterManagerDetModel>>(
      showLoader: false,
      call:      () => api.get('/counterManagerDet?crId=$crId'),
      onSuccess: (res) {
        final data = res.data as List;
        print('datamanager-----$data');

        return data.map((e) => CounterManagerDetModel.fromJson(e)).toList();
      },
    );
    if (result != null) {
      _list = result;
      notifyListeners();
    }
  }

  // ── DELETE BY CrId ─────────────────────────────────────────────────────────
  Future<void> deleteByCrId(int crId) async {
    final toDelete = _list
        .where((e) => e.crId == crId && e.counterManagerDetID != null)
        .toList();
    for (final item in toDelete) {
      await request<bool>(
        showLoader: false,
        call:      () => api.delete('/counterManagerDet/${item.counterManagerDetID}'),
        onSuccess: (_) => true,
      );
    }
    _list.removeWhere((e) => e.crId == crId);
    notifyListeners();
  }

  // ── GET BY ID ──────────────────────────────────────────────────────────────
  Future<CounterManagerDetModel?> getById(int id) async {
    return await request<CounterManagerDetModel>(
      showLoader: true,
      call:      () => api.get('/counterManagerDet/$id'),
      onSuccess: (res) => CounterManagerDetModel.fromJson(res.data),
    );
  }

  // ── CREATE ─────────────────────────────────────────────────────────────────
  Future<bool> create(Map<String, dynamic> formValues) async {
    final model  = CounterManagerDetModel.fromFormValues(formValues);
    final result = await request<CounterManagerDetModel>(
      showLoader: false,
      call:      () => api.post('/counterManagerDet', data: model.toJson()),
      onSuccess: (res) => CounterManagerDetModel.fromJson(res.data),
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
    final model  = CounterManagerDetModel.fromFormValues(formValues);
    final result = await request<CounterManagerDetModel>(
      showLoader: true,
      call:      () => api.put('/counterManagerDet/$id', data: model.toJson()),
      onSuccess: (res) => CounterManagerDetModel.fromJson(res.data),
    );
    if (result != null) {
      final i = _list.indexWhere((e) => e.counterManagerDetID == id);
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
      call:      () => api.delete('/counterManagerDet/$id'),
      onSuccess: (_) => true,
    );
    if (result == true) {
      _list.removeWhere((e) => e.counterManagerDetID == id);
      notifyListeners();
      return true;
    }
    return false;
  }
}