// // lib/providers/counter_provider.dart
//
// import 'package:rs_dashboard/rs_dashboard.dart';
// import '../models/counter_model.dart';
//
// class CounterProvider extends BaseProvider {
//   List<CounterModel> _list     = [];
//   bool               _isLoaded = false;
//
//   List<CounterModel>         get list      => List.unmodifiable(_list);
//   bool                       get isLoaded  => _isLoaded;
//
//   List<Map<String, dynamic>> get tableData =>
//       _list.map((e) => e.toTableRow()).toList();
//
//   // ── LOAD ALL ───────────────────────────────────────────────────────────────
//   Future<void> load() async {
//     final result = await request<List<CounterModel>>(
//       showLoader: true,
//       call:      () => api.get('/counter'),
//       onSuccess: (res) {
//         final data = res.data as List;
//         return data.map((e) => CounterModel.fromJson(e)).toList();
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
//   Future<CounterModel?> getById(int id) async {
//     return await request<CounterModel>(
//       showLoader: true,
//       call:      () => api.get('/counter/$id'),
//       onSuccess: (res) => CounterModel.fromJson(res.data),
//     );
//   }
//
//   // ── CREATE ─────────────────────────────────────────────────────────────────
//   Future<bool> create(Map<String, dynamic> formValues) async {
//     final model  = CounterModel.fromFormValues(formValues);
//     final result = await request<CounterModel>(
//       showLoader: true,
//       call:      () => api.post('/counter', data: model.toJson()),
//       onSuccess: (res) => CounterModel.fromJson(res.data),
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
//     final model  = CounterModel.fromFormValues(formValues);
//     final result = await request<CounterModel>(
//       showLoader: true,
//       call:      () => api.put('/counter/$id', data: model.toJson()),
//       onSuccess: (res) => CounterModel.fromJson(res.data),
//     );
//     if (result != null) {
//       final i = _list.indexWhere((e) => e.crId == id);
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
//       call:      () => api.delete('/counter/$id'),
//       onSuccess: (_) => true,
//     );
//     if (result == true) {
//       _list.removeWhere((e) => e.crId == id);
//       notifyListeners();
//       return true;
//     }
//     return false;
//   }
// }
// lib/providers/counter_provider.dart

import 'package:rs_dashboard/rs_dashboard.dart';
import '../models/counter_model.dart';

class CounterProvider extends BaseProvider {
  List<CounterModel> _list     = [];
  bool               _isLoaded = false;

  List<CounterModel>         get list      => List.unmodifiable(_list);
  bool                       get isLoaded  => _isLoaded;

  List<Map<String, dynamic>> get tableData =>
      _list.map((e) => e.toTableRow()).toList();

  // ── LOAD ALL ───────────────────────────────────────────────────────────────
  Future<void> load() async {
    final result = await request<List<CounterModel>>(
      showLoader: true,
      call:      () => api.get('/counter'),
      onSuccess: (res) {
        final data = res.data as List;
        return data.map((e) => CounterModel.fromJson(e)).toList();
      },
    );
    if (result != null) {
      _list     = result;
      _isLoaded = true;
      notifyListeners();
    }
  }

  // ── GET BY ID ──────────────────────────────────────────────────────────────
  Future<CounterModel?> getById(int id) async {
    return await request<CounterModel>(
      showLoader: true,
      call:      () => api.get('/counter/$id'),
      onSuccess: (res) => CounterModel.fromJson(res.data),
    );
  }

  // ── CREATE — returns bool (existing pattern) ───────────────────────────────
  Future<bool> create(Map<String, dynamic> formValues) async {
    final result = await createAndReturn(formValues);
    return result != null;
  }

  // ── CREATE AND RETURN — API response model return karta hai ────────────────
  // CounterMstID API response mein aata hai — CounterDisplayDet.CrId ke liye zaroori
  Future<CounterModel?> createAndReturn(Map<String, dynamic> formValues) async {
    final model  = CounterModel.fromFormValues(formValues);
    final result = await request<CounterModel>(
      showLoader: true,
      call:      () => api.post('/counter', data: model.toJson()),
      onSuccess: (res) => CounterModel.fromJson(res.data),
    );
    if (result != null) {
      _list.insert(0, result);
      notifyListeners();
    }
    return result;
  }

  // ── UPDATE — returns bool (existing pattern) ───────────────────────────────
  Future<bool> update(int id, Map<String, dynamic> formValues) async {
    final result = await updateAndReturn(id, formValues);
    return result != null;
  }

  // ── UPDATE AND RETURN — API response model return karta hai ───────────────
  // CounterMstID confirm karne ke liye
  Future<CounterModel?> updateAndReturn(int id, Map<String, dynamic> formValues) async {
    final model  = CounterModel.fromFormValues(formValues);
    final result = await request<CounterModel>(
      showLoader: true,
      call:      () => api.put('/counter/$id', data: model.toJson()),
      onSuccess: (res) => CounterModel.fromJson(res.data),
    );
    if (result != null) {
      final i = _list.indexWhere((e) => e.crId == id);
      if (i != -1) _list[i] = result;
      notifyListeners();
    }
    return result;
  }

  // ── DELETE ─────────────────────────────────────────────────────────────────
  Future<bool> delete(int id) async {
    final result = await request<bool>(
      showLoader: true,
      call:      () => api.delete('/counter/$id'),
      onSuccess: (_) => true,
    );
    if (result == true) {
      _list.removeWhere((e) => e.crId == id);
      notifyListeners();
      return true;
    }
    return false;
  }
}