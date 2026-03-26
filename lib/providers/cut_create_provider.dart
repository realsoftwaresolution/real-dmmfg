// // lib/providers/cut_create_provider.dart
//
// import 'package:rs_dashboard/rs_dashboard.dart';
// import '../models/cut_create_model.dart';
//
// class CutCreateProvider extends BaseProvider {
//   List<CutCreateModel> _list     = [];
//   bool                 _isLoaded = false;
//
//   bool                        get isLoaded  => _isLoaded;
//   List<CutCreateModel>        get list      => List.unmodifiable(_list);
//   List<Map<String, dynamic>>  get tableData =>
//       _list.map((e) => e.toTableRow()).toList();
//
//   // ── LOAD ALL ────────────────────────────────────────────────────────────────
//   Future<void> load() async {
//     final result = await request<List<CutCreateModel>>(
//       call: () => api.get('/cutCreate'),
//       onSuccess: (res) {
//         final list = res.data as List;
//         return list.map((e) => CutCreateModel.fromJson(e)).toList();
//       },
//     );
//     if (result != null) {
//       _list     = result;
//       _isLoaded = true;
//       notifyListeners();
//     }
//   }
//
//   // ── CREATE ──────────────────────────────────────────────────────────────────
//   Future<bool> create(
//       Map<String, dynamic>    values,
//       List<CutCreateDetModel> details,
//       ) async {
//     final model  = _buildModel(values);
//     final result = await request<CutCreateModel>(
//       call: () => api.post('/cutCreate', data: {
//         ...model.toJson(),
//         'details': details.map((e) => e.toJson()).toList(),
//       }),
//       onSuccess: (res) => CutCreateModel.fromJson(res.data),
//     );
//     if (result != null) {
//       _list.insert(0, result);
//       notifyListeners();
//       return true;
//     }
//     return false;
//   }
//
//   // ── UPDATE ──────────────────────────────────────────────────────────────────
//   Future<bool> update(
//       int                     id,
//       Map<String, dynamic>    values,
//       List<CutCreateDetModel> details,
//       ) async {
//     final model  = _buildModel(values);
//     final result = await request<CutCreateModel>(
//       call: () => api.put('/cutCreate/$id', data: {
//         ...model.toJson(),
//         'details': details.map((e) => e.toJson()).toList(),
//       }),
//       onSuccess: (res) => CutCreateModel.fromJson(res.data),
//     );
//     if (result != null) {
//       final i = _list.indexWhere((e) => e.cutCreateMstID == id);
//       if (i != -1) _list[i] = result;
//       notifyListeners();
//       return true;
//     }
//     return false;
//   }
//
//   // ── DELETE ──────────────────────────────────────────────────────────────────
//   Future<bool> delete(int id) async {
//     final result = await request<bool>(
//       call: () => api.delete('/cutCreate/$id'),
//       onSuccess: (_) => true,
//     );
//     if (result == true) {
//       _list.removeWhere((e) => e.cutCreateMstID == id);
//       notifyListeners();
//       return true;
//     }
//     return false;
//   }
//
//   // ── LOAD DETAILS (by master ID) ──────────────────────────────────────────────
//   /// API: GET /cutCreate/:id  → { mst: {...}, det: [...] }
//   Future<List<CutCreateDetModel>> loadDetails(int mstID) async {
//     final result = await request<List<CutCreateDetModel>>(
//       call: () => api.get('/cutCreate/$mstID'),
//       onSuccess: (res) {
//         final det = res.data['det'] as List? ?? [];
//         return det.map((e) => CutCreateDetModel.fromJson(e)).toList();
//       },
//     );
//     return result ?? [];
//   }
//
//   // ── BUILD MODEL from form values ─────────────────────────────────────────────
//   CutCreateModel _buildModel(Map<String, dynamic> v) {
//     int? toI(String? s) => s == null || s.isEmpty ? null : int.tryParse(s);
//
//     return CutCreateModel(
//       cutCreateDate:    v['cutCreateDate'],
//       jno:              toI(v['jno']),
//       kapanNo:          v['kapanNo'],
//       sflag:            v['sflag'],
//       logID:            toI(v['logID']),
//       pcID:             v['pcID'],
//       ever:             toI(v['ever']),
//       roughAssortDetID: toI(v['roughAssortDetID']),
//     );
//   }
// }
// lib/providers/cut_create_provider.dart
// lib/providers/cut_create_provider.dart

import 'package:rs_dashboard/rs_dashboard.dart';
import '../models/cut_create_model.dart';

class CutCreateProvider extends BaseProvider {
  List<CutCreateModel> _list     = [];
  bool                 _isLoaded = false;

  bool                        get isLoaded  => _isLoaded;
  List<CutCreateModel>        get list      => List.unmodifiable(_list);
  List<Map<String, dynamic>>  get tableData =>
      _list.map((e) => e.toTableRow()).toList();

  // ── LOAD ALL (masters only — fast, for table display) ───────────────────────
  Future<void> load() async {
    final result = await request<List<CutCreateModel>>(
      call: () => api.get('/cutCreate'),
      onSuccess: (res) {
        final list = res.data as List;
        return list
            .map((e) => CutCreateModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
    if (result != null) {
      _list     = result;
      _isLoaded = true;
      notifyListeners();
      // Auto-load all details in background so SPK filter works
      _loadAllDetails();
    }
  }
  Future<int> getNextJno() async {
    final result = await request<int>(
      showLoader: false,
      call: () => api.get('/cutCreate/next-jno'),
      onSuccess: (res) => (res.data as num).toInt(),
    );
    return result ?? 1;
  }

// ── KAPAN DUPLICATE CHECK ─────────────────────────────────────────────────
  bool isKapanDuplicate(String kapanNo, {int? excludeMstID}) {
    return list.any((cc) =>
    cc.kapanNo == kapanNo &&
        cc.cutCreateMstID != excludeMstID
    );
  }
  // ── LOAD ALL DETAILS in background ──────────────────────────────────────────
  // Har master ki details load karo — SPK pending wt filter ke liye zaroori
  Future<void> _loadAllDetails() async {
    bool anyUpdated = false;
    for (int i = 0; i < _list.length; i++) {
      final mst = _list[i];
      if (mst.cutCreateMstID == null) continue;
      if (mst.details.isNotEmpty) continue; // already loaded

      try {
        final result = await request<List<CutCreateDetModel>>(
          call: () => api.get('/cutCreate/${mst.cutCreateMstID}'),
          onSuccess: (res) {
            final data   = res.data;
            print(data);
            final rawDet = (data is Map ? data['det'] : data) as List? ?? [];
            return rawDet
                .map((e) => CutCreateDetModel.fromJson(e as Map<String, dynamic>))
                .toList();
          },
        );
        if (result != null) {
          _list[i] = CutCreateModel(
            cutCreateMstID:  mst.cutCreateMstID,
            cutCreateDate:   mst.cutCreateDate,
            jno:             mst.jno,
            kapanNo:         mst.kapanNo,
            sflag:           mst.sflag,
            sdate:           mst.sdate,
            logID:           mst.logID,
            pcID:            mst.pcID,
            ever:            mst.ever,
            roughAssortDetID: mst.roughAssortDetID,
            details:         result,
          );
          anyUpdated = true;
        }
      } catch (_) {
        // skip failed records, continue with others
      }
    }
    if (anyUpdated) notifyListeners();
  }

  // ── CREATE ──────────────────────────────────────────────────────────────────
  // API returns { mst: {...}, det: [...] }
  Future<bool> create(
      Map<String, dynamic>    values,
      List<CutCreateDetModel> details,
      ) async {
    final model  = _buildModel(values);
    final result = await request<CutCreateModel>(
      call: () => api.post('/cutCreate', data: {
        ...model.toJson(),
        'details': details.map((e) => e.toJson()).toList(),
      }),
      onSuccess: (res) => _parseMstResponse(res.data),
    );
    if (result != null) {
      _list.insert(0, result);
      notifyListeners();
      return true;
    }
    return false;
  }

  // ── UPDATE ──────────────────────────────────────────────────────────────────
  Future<bool> update(
      int                     id,
      Map<String, dynamic>    values,
      List<CutCreateDetModel> details,
      ) async {
    final model  = _buildModel(values);
    final result = await request<CutCreateModel>(
      call: () => api.put('/cutCreate/$id', data: {
        ...model.toJson(),
        'details': details.map((e) => e.toJson()).toList(),
      }),
      onSuccess: (res) => _parseMstResponse(res.data),
    );
    if (result != null) {
      final i = _list.indexWhere((e) => e.cutCreateMstID == id);
      if (i != -1) _list[i] = result;
      notifyListeners();
      return true;
    }
    return false;
  }

  // ── DELETE ──────────────────────────────────────────────────────────────────
  Future<bool> delete(int id) async {
    final result = await request<bool>(
      call: () => api.delete('/cutCreate/$id'),
      onSuccess: (_) => true,
    );
    if (result == true) {
      _list.removeWhere((e) => e.cutCreateMstID == id);
      notifyListeners();
      return true;
    }
    return false;
  }

  // ── LOAD DETAILS (by master ID) ──────────────────────────────────────────────
  /// API: GET /cutCreate/:id  → { mst: {...}, det: [...] }
  /// Details load karke _list mein bhi merge karta hai taaki
  /// SPK dropdown filter kaam kare.
  Future<List<CutCreateDetModel>> loadDetails(int mstID) async {
    final result = await request<List<CutCreateDetModel>>(
      call: () => api.get('/cutCreate/$mstID'),
      onSuccess: (res) {
        final data = res.data;
        final rawDet = (data is Map ? data['det'] : data) as List? ?? [];
        return rawDet
            .map((e) => CutCreateDetModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
    final dets = result ?? [];

    // _list mein merge karo taaki dropdown filter mein dikh sake
    final i = _list.indexWhere((e) => e.cutCreateMstID == mstID);
    if (i != -1 && dets.isNotEmpty) {
      final mst = _list[i];
      _list[i] = CutCreateModel(
        cutCreateMstID:   mst.cutCreateMstID,
        cutCreateDate:    mst.cutCreateDate,
        jno:              mst.jno,
        kapanNo:          mst.kapanNo,
        sflag:            mst.sflag,
        sdate:            mst.sdate,
        logID:            mst.logID,
        pcID:             mst.pcID,
        ever:             mst.ever,
        roughAssortDetID: mst.roughAssortDetID,
        details:          dets,
      );
      notifyListeners();
    }

    return dets;
  }

  // ── PARSE { mst, det } response ─────────────────────────────────────────────
  CutCreateModel _parseMstResponse(dynamic data) {
    if (data is Map) {
      // { mst: {}, det: [] } format
      if (data.containsKey('mst')) {
        final mst = Map<String, dynamic>.from(data['mst'] as Map);
        final rawDet = (data['det'] as List? ?? []);
        final det = rawDet
            .map((e) => CutCreateDetModel.fromJson(e as Map<String, dynamic>))
            .toList();
        // Pass det as list of maps for fromJson
        mst['details'] = rawDet; // raw maps, not objects
        return CutCreateModel.fromJson(mst);
      }
      // Plain mst object
      return CutCreateModel.fromJson(Map<String, dynamic>.from(data));
    }
    throw Exception('Unexpected response format');
  }

  // ── BUILD MODEL from form values ─────────────────────────────────────────────
  CutCreateModel _buildModel(Map<String, dynamic> v) {
    int? toI(String? s) => s == null || s.isEmpty ? null : int.tryParse(s);

    return CutCreateModel(
      cutCreateDate:    v['cutCreateDate'],
      jno:              toI(v['jno']),
      kapanNo:          v['kapanNo'],
      sflag:            v['sflag'],
      logID:            toI(v['logID']),
      pcID:             v['pcID'],
      ever:             toI(v['ever']),
      roughAssortDetID: toI(v['roughAssortDetID']),
    );
  }
}
// import 'package:rs_dashboard/rs_dashboard.dart';
// import '../models/cut_create_model.dart';
//
// class CutCreateProvider extends BaseProvider {
//   List<CutCreateModel> _list     = [];
//   bool                 _isLoaded = false;
//
//   bool                        get isLoaded  => _isLoaded;
//   List<CutCreateModel>        get list      => List.unmodifiable(_list);
//   List<Map<String, dynamic>>  get tableData =>
//       _list.map((e) => e.toTableRow()).toList();
//
//   // ── LOAD ALL ────────────────────────────────────────────────────────────────
//   Future<void> load() async {
//     final result = await request<List<CutCreateModel>>(
//       call: () => api.get('/cutCreate'),
//       onSuccess: (res) {
//         final list = res.data as List;
//         return list
//             .map((e) => CutCreateModel.fromJson(e as Map<String, dynamic>))
//             .toList();
//       },
//     );
//     if (result != null) {
//       _list     = result;
//       _isLoaded = true;
//       notifyListeners();
//     }
//   }
//
//   // ── CREATE ──────────────────────────────────────────────────────────────────
//   // API returns { mst: {...}, det: [...] }
//   Future<bool> create(
//       Map<String, dynamic>    values,
//       List<CutCreateDetModel> details,
//       ) async {
//     final model  = _buildModel(values);
//     final result = await request<CutCreateModel>(
//       call: () => api.post('/cutCreate', data: {
//         ...model.toJson(),
//         'details': details.map((e) => e.toJson()).toList(),
//       }),
//       onSuccess: (res) => _parseMstResponse(res.data),
//     );
//     if (result != null) {
//       _list.insert(0, result);
//       notifyListeners();
//       return true;
//     }
//     return false;
//   }
//
//   // ── UPDATE ──────────────────────────────────────────────────────────────────
//   Future<bool> update(
//       int                     id,
//       Map<String, dynamic>    values,
//       List<CutCreateDetModel> details,
//       ) async {
//     final model  = _buildModel(values);
//     final result = await request<CutCreateModel>(
//       call: () => api.put('/cutCreate/$id', data: {
//         ...model.toJson(),
//         'details': details.map((e) => e.toJson()).toList(),
//       }),
//       onSuccess: (res) => _parseMstResponse(res.data),
//     );
//     if (result != null) {
//       final i = _list.indexWhere((e) => e.cutCreateMstID == id);
//       if (i != -1) _list[i] = result;
//       notifyListeners();
//       return true;
//     }
//     return false;
//   }
//
//   // ── DELETE ──────────────────────────────────────────────────────────────────
//   Future<bool> delete(int id) async {
//     final result = await request<bool>(
//       call: () => api.delete('/cutCreate/$id'),
//       onSuccess: (_) => true,
//     );
//     if (result == true) {
//       _list.removeWhere((e) => e.cutCreateMstID == id);
//       notifyListeners();
//       return true;
//     }
//     return false;
//   }
//
//   // ── LOAD DETAILS (by master ID) ──────────────────────────────────────────────
//   /// API: GET /cutCreate/:id  → { mst: {...}, det: [...] }
//   Future<List<CutCreateDetModel>> loadDetails(int mstID) async {
//     final result = await request<List<CutCreateDetModel>>(
//       call: () => api.get('/cutCreate/$mstID'),
//       onSuccess: (res) {
//         final data = res.data;
//         // API returns { mst: {}, det: [] }
//         final rawDet = (data is Map ? data['det'] : data) as List? ?? [];
//         return rawDet
//             .map((e) => CutCreateDetModel.fromJson(e as Map<String, dynamic>))
//             .toList();
//       },
//     );
//     return result ?? [];
//   }
//
//   // ── PARSE { mst, det } response ─────────────────────────────────────────────
//   CutCreateModel _parseMstResponse(dynamic data) {
//     if (data is Map) {
//       // { mst: {}, det: [] } format
//       if (data.containsKey('mst')) {
//         final mst = Map<String, dynamic>.from(data['mst'] as Map);
//         final rawDet = (data['det'] as List? ?? []);
//         final det = rawDet
//             .map((e) => CutCreateDetModel.fromJson(e as Map<String, dynamic>))
//             .toList();
//         // Pass det as list of maps for fromJson
//         mst['details'] = rawDet; // raw maps, not objects
//         return CutCreateModel.fromJson(mst);
//       }
//       // Plain mst object
//       return CutCreateModel.fromJson(Map<String, dynamic>.from(data));
//     }
//     throw Exception('Unexpected response format');
//   }
//
//   // ── BUILD MODEL from form values ─────────────────────────────────────────────
//   CutCreateModel _buildModel(Map<String, dynamic> v) {
//     int? toI(String? s) => s == null || s.isEmpty ? null : int.tryParse(s);
//
//     return CutCreateModel(
//       cutCreateDate:    v['cutCreateDate'],
//       jno:              toI(v['jno']),
//       kapanNo:          v['kapanNo'],
//       sflag:            v['sflag'],
//       logID:            toI(v['logID']),
//       pcID:             v['pcID'],
//       ever:             toI(v['ever']),
//       roughAssortDetID: toI(v['roughAssortDetID']),
//     );
//   }
// }