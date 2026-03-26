// // lib/providers/counter_det_provider.dart
//
// import 'package:rs_dashboard/rs_dashboard.dart';
// import '../models/counter_det_model.dart';
//
// class CounterDetProvider extends BaseProvider {
//   List<CounterDetModel> _list        = [];
//   List<CounterDetModel> _counterList = [];
//   bool                  _isLoaded    = false;
//
//   List<CounterDetModel>      get list             => List.unmodifiable(_list);
//   List<CounterDetModel>      get counterList       => List.unmodifiable(_counterList);
//   bool                       get isLoaded          => _isLoaded;
//
//   List<Map<String, dynamic>> get tableData         =>
//       _list.map((e) => e.toTableRow()).toList();
//
//   List<Map<String, dynamic>> get counterTableData  =>
//       _counterList.map((e) => e.toTableRow()).toList();
//
//   // ── LOAD ALL ───────────────────────────────────────────────────────────────
//   Future<void> load() async {
//     final result = await request<List<CounterDetModel>>(
//       showLoader: true,
//       call:      () => api.get('/counterDet'),
//       onSuccess: (res) {
//         final data = res.data as List;
//         return data.map((e) => CounterDetModel.fromJson(e)).toList();
//       },
//     );
//     if (result != null) {
//       _list     = result;
//       _isLoaded = true;
//       notifyListeners();
//     }
//   }
//
//   // ── LOAD BY COUNTER (CrId) ─────────────────────────────────────────────────
//   Future<void> loadByCounter(int crId) async {
//     final result = await request<List<CounterDetModel>>(
//       showLoader: true,
//       call:      () => api.get('/counterDet/counter/$crId'),
//       onSuccess: (res) {
//         final data = res.data as List;
//         return data.map((e) => CounterDetModel.fromJson(e)).toList();
//       },
//     );
//     if (result != null) {
//       _counterList = result;
//       notifyListeners();
//     }
//   }
//
//   // ── GET BY ID ──────────────────────────────────────────────────────────────
//   Future<CounterDetModel?> getById(int id) async {
//     return await request<CounterDetModel>(
//       showLoader: true,
//       call:      () => api.get('/counterDet/$id'),
//       onSuccess: (res) => CounterDetModel.fromJson(res.data),
//     );
//   }
//
//   // ── CREATE ─────────────────────────────────────────────────────────────────
//   Future<bool> create(Map<String, dynamic> formValues) async {
//     final model  = CounterDetModel.fromFormValues(formValues);
//     final result = await request<CounterDetModel>(
//       showLoader: true,
//       call:      () => api.post('/counterDet', data: model.toJson()),
//       onSuccess: (res) => CounterDetModel.fromJson(res.data),
//     );
//     if (result != null) {
//       _list.insert(0, result);
//       if (result.crId != null &&
//           _counterList.isNotEmpty &&
//           _counterList.first.crId == result.crId) {
//         _counterList.insert(0, result);
//       }
//       notifyListeners();
//       return true;
//     }
//     return false;
//   }
//
//   // ── UPDATE ─────────────────────────────────────────────────────────────────
//   Future<bool> update(int id, Map<String, dynamic> formValues) async {
//     final model  = CounterDetModel.fromFormValues(formValues);
//     final result = await request<CounterDetModel>(
//       showLoader: true,
//       call:      () => api.put('/counterDet/$id', data: model.toJson()),
//       onSuccess: (res) => CounterDetModel.fromJson(res.data),
//     );
//     if (result != null) {
//       final i = _list.indexWhere((e) => e.counterDetID == id);
//       if (i != -1) _list[i] = result;
//       final j = _counterList.indexWhere((e) => e.counterDetID == id);
//       if (j != -1) _counterList[j] = result;
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
//       call:      () => api.delete('/counterDet/$id'),
//       onSuccess: (_) => true,
//     );
//     if (result == true) {
//       _list.removeWhere((e) => e.counterDetID == id);
//       _counterList.removeWhere((e) => e.counterDetID == id);
//       notifyListeners();
//       return true;
//     }
//     return false;
//   }
// }
// lib/providers/counter_det_provider.dart

import 'package:rs_dashboard/rs_dashboard.dart';
import '../models/counter_det_model.dart';

class CounterDetProvider extends BaseProvider {
  List<CounterDetModel> _list        = [];
  List<CounterDetModel> _counterList = [];
  bool                  _isLoaded    = false;

  List<CounterDetModel>      get list             => List.unmodifiable(_list);
  List<CounterDetModel>      get counterList       => List.unmodifiable(_counterList);
  bool                       get isLoaded          => _isLoaded;

  List<Map<String, dynamic>> get tableData         =>
      _list.map((e) => e.toTableRow()).toList();

  List<Map<String, dynamic>> get counterTableData  =>
      _counterList.map((e) => e.toTableRow()).toList();

  // ── LOAD ALL ───────────────────────────────────────────────────────────────
  Future<void> load() async {
    final result = await request<List<CounterDetModel>>(
      showLoader: true,
      call:      () => api.get('/counterDet'),
      onSuccess: (res) {
        final data = res.data as List;
        return data.map((e) => CounterDetModel.fromJson(e)).toList();
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
    final result = await request<List<CounterDetModel>>(
      showLoader: true,
      call:      () => api.get('/counterDet/counter/$crId'),
      onSuccess: (res) {
        final data = res.data as List;
        return data.map((e) => CounterDetModel.fromJson(e)).toList();
      },
    );
    if (result != null) {
      _counterList = result;
      notifyListeners();
    }
  }

  // ── DELETE BY CrId ─────────────────────────────────────────────────────────
  Future<void> deleteByCrId(int crId) async {
    final toDelete = _counterList
        .where((e) => e.counterDetID != null)
        .toList();
    for (final item in toDelete) {
      await request<bool>(
        showLoader: false,
        call:      () => api.delete('/counterDet/${item.counterDetID}'),
        onSuccess: (_) => true,
      );
    }
    _list.removeWhere((e) => e.crId == crId);
    _counterList.removeWhere((e) => e.crId == crId);
    notifyListeners();
  }

  // ── GET BY ID ──────────────────────────────────────────────────────────────
  Future<CounterDetModel?> getById(int id) async {
    return await request<CounterDetModel>(
      showLoader: true,
      call:      () => api.get('/counterDet/$id'),
      onSuccess: (res) => CounterDetModel.fromJson(res.data),
    );
  }

  // ── CREATE ─────────────────────────────────────────────────────────────────
  Future<bool> create(Map<String, dynamic> formValues) async {
    final model  = CounterDetModel.fromFormValues(formValues);
    final result = await request<CounterDetModel>(
      showLoader: true,
      call:      () => api.post('/counterDet', data: model.toJson()),
      onSuccess: (res) => CounterDetModel.fromJson(res.data),
    );
    if (result != null) {
      _list.insert(0, result);
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
    final model  = CounterDetModel.fromFormValues(formValues);
    final result = await request<CounterDetModel>(
      showLoader: true,
      call:      () => api.put('/counterDet/$id', data: model.toJson()),
      onSuccess: (res) => CounterDetModel.fromJson(res.data),
    );
    if (result != null) {
      final i = _list.indexWhere((e) => e.counterDetID == id);
      if (i != -1) _list[i] = result;
      final j = _counterList.indexWhere((e) => e.counterDetID == id);
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
      call:      () => api.delete('/counterDet/$id'),
      onSuccess: (_) => true,
    );
    if (result == true) {
      _list.removeWhere((e) => e.counterDetID == id);
      _counterList.removeWhere((e) => e.counterDetID == id);
      notifyListeners();
      return true;
    }
    return false;
  }
}