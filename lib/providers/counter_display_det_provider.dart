// // lib/providers/counter_display_det_provider.dart
//
// import 'package:rs_dashboard/rs_dashboard.dart';
// import '../models/counter_display_det_model.dart';
//
// class CounterDisplayDetProvider extends BaseProvider {
//   List<CounterDisplayDetModel> _list     = [];
//   bool                         _isLoaded = false;
//
//   List<CounterDisplayDetModel> get list      => List.unmodifiable(_list);
//   bool                         get isLoaded  => _isLoaded;
//
//   List<Map<String, dynamic>>   get tableData =>
//       _list.map((e) => e.toTableRow()).toList();
//
//   // ── LOAD ALL ───────────────────────────────────────────────────────────────
//   Future<void> load() async {
//     final result = await request<List<CounterDisplayDetModel>>(
//       showLoader: true,
//       call:      () => api.get('/counterDisplayDet'),
//       onSuccess: (res) {
//         final data = res.data as List;
//         return data.map((e) => CounterDisplayDetModel.fromJson(e)).toList();
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
//   Future<CounterDisplayDetModel?> getById(int id) async {
//     return await request<CounterDisplayDetModel>(
//       showLoader: true,
//       call:      () => api.get('/counterDisplayDet/$id'),
//       onSuccess: (res) => CounterDisplayDetModel.fromJson(res.data),
//     );
//   }
//
//   // ── CREATE ─────────────────────────────────────────────────────────────────
//   Future<bool> create(Map<String, dynamic> formValues) async {
//     final model  = CounterDisplayDetModel.fromFormValues(formValues);
//     final result = await request<CounterDisplayDetModel>(
//       showLoader: true,
//       call:      () => api.post('/counterDisplayDet', data: model.toJson()),
//       onSuccess: (res) => CounterDisplayDetModel.fromJson(res.data),
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
//     final model  = CounterDisplayDetModel.fromFormValues(formValues);
//     final result = await request<CounterDisplayDetModel>(
//       showLoader: true,
//       call:      () => api.put('/counterDisplayDet/$id', data: model.toJson()),
//       onSuccess: (res) => CounterDisplayDetModel.fromJson(res.data),
//     );
//     if (result != null) {
//       final i = _list.indexWhere((e) => e.counterDisplayDetID == id);
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
//       call:      () => api.delete('/counterDisplayDet/$id'),
//       onSuccess: (_) => true,
//     );
//     if (result == true) {
//       _list.removeWhere((e) => e.counterDisplayDetID == id);
//       notifyListeners();
//       return true;
//     }
//     return false;
//   }
// }

// lib/providers/counter_display_det_provider.dart

import 'package:rs_dashboard/rs_dashboard.dart';
import '../models/counter_display_det_model.dart';

class CounterDisplayDetProvider extends BaseProvider {
  List<CounterDisplayDetModel> _list        = [];
  List<CounterDisplayDetModel> _counterList = [];
  bool                         _isLoaded    = false;

  List<CounterDisplayDetModel> get list        => List.unmodifiable(_list);
  List<CounterDisplayDetModel> get counterList => List.unmodifiable(_counterList);
  bool                         get isLoaded    => _isLoaded;

  List<Map<String, dynamic>>   get tableData =>
      _list.map((e) => e.toTableRow()).toList();

  List<Map<String, dynamic>>   get counterTableData =>
      _counterList.map((e) => e.toTableRow()).toList();

  // ── LOAD ALL ───────────────────────────────────────────────────────────────
  Future<void> load() async {
    final result = await request<List<CounterDisplayDetModel>>(
      showLoader: true,
      call:      () => api.get('/counterDisplayDet'),
      onSuccess: (res) {
        final data = res.data as List;
        return data.map((e) => CounterDisplayDetModel.fromJson(e)).toList();
      },
    );
    if (result != null) {
      _list     = result;
      _isLoaded = true;
      notifyListeners();
    }
  }

  // ── LOAD BY COUNTER (CrId) — local filter from _list ─────────────────────
  // Note: agar backend pe /counterDisplayDet/counter/:crId endpoint available
  // hoga tab API call karna, warna local filter se kaam chala sakte ho
  Future<void> loadByCounter(int crId) async {
    // Option 1: Agar puri list already loaded hai toh locally filter karo
    if (_isLoaded) {
      _counterList = _list.where((e) => e.crId == crId).toList();
      notifyListeners();
      return;
    }

    // Option 2: Puri list load karo pehle, phir filter karo
    final result = await request<List<CounterDisplayDetModel>>(
      showLoader: false,
      call:      () => api.get('/counterDisplayDet'),
      onSuccess: (res) {
        final data = res.data as List;
        return data.map((e) => CounterDisplayDetModel.fromJson(e)).toList();
      },
    );
    if (result != null) {
      _list        = result;
      _isLoaded    = true;
      _counterList = _list.where((e) => e.crId == crId).toList();
      notifyListeners();
    }
  }

  // ── GET BY ID ──────────────────────────────────────────────────────────────
  Future<CounterDisplayDetModel?> getById(int id) async {
    return await request<CounterDisplayDetModel>(
      showLoader: true,
      call:      () => api.get('/counterDisplayDet/$id'),
      onSuccess: (res) => CounterDisplayDetModel.fromJson(res.data),
    );
  }

  // ── CREATE ─────────────────────────────────────────────────────────────────
  Future<bool> create(Map<String, dynamic> formValues) async {
    final model  = CounterDisplayDetModel.fromFormValues(formValues);
    final result = await request<CounterDisplayDetModel>(
      showLoader: false,  // bulk save mein loader off rakho
      call:      () => api.post('/counterDisplayDet', data: model.toJson()),
      onSuccess: (res) => CounterDisplayDetModel.fromJson(res.data),
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

  // ── DELETE BY COUNTER (sabhi records ek counter ke) ───────────────────────
  // Save karne se pehle purane records delete karo
  Future<void> deleteByCounter(int crId) async {
    final toDelete = _list.where((e) => e.crId == crId).toList();
    for (final item in toDelete) {
      if (item.counterDisplayDetID != null) {
        await request<bool>(
          showLoader: false,
          call:      () => api.delete('/counterDisplayDet/${item.counterDisplayDetID}'),
          onSuccess: (_) => true,
        );
      }
    }
    _list.removeWhere((e) => e.crId == crId);
    _counterList.removeWhere((e) => e.crId == crId);
    notifyListeners();
  }

  // ── UPDATE ─────────────────────────────────────────────────────────────────
  Future<bool> update(int id, Map<String, dynamic> formValues) async {
    final model  = CounterDisplayDetModel.fromFormValues(formValues);
    final result = await request<CounterDisplayDetModel>(
      showLoader: true,
      call:      () => api.put('/counterDisplayDet/$id', data: model.toJson()),
      onSuccess: (res) => CounterDisplayDetModel.fromJson(res.data),
    );
    if (result != null) {
      final i = _list.indexWhere((e) => e.counterDisplayDetID == id);
      if (i != -1) _list[i] = result;
      final j = _counterList.indexWhere((e) => e.counterDisplayDetID == id);
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
      call:      () => api.delete('/counterDisplayDet/$id'),
      onSuccess: (_) => true,
    );
    if (result == true) {
      _list.removeWhere((e) => e.counterDisplayDetID == id);
      _counterList.removeWhere((e) => e.counterDisplayDetID == id);
      notifyListeners();
      return true;
    }
    return false;
  }
}