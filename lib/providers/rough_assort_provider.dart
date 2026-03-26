// lib/providers/rough_assort_provider.dart

import 'package:rs_dashboard/rs_dashboard.dart';
import '../models/rough_assort_model.dart';

class RoughAssortProvider extends BaseProvider {
  List<RoughAssortModel> _list = [];
  bool _isLoaded = false;

  bool                        get isLoaded  => _isLoaded;
  List<RoughAssortModel>      get list      => List.unmodifiable(_list);
  List<Map<String, dynamic>>  get tableData =>
      _list.map((e) => e.toTableRow()).toList();

  Set<String> usedKapanNos({int? excludeMstID}) {
    return list
        .where((e) => e.roughAssortMstID != excludeMstID)
        .map((e) => e.kapanNo ?? '')
        .where((k) => k.isNotEmpty)
        .toSet();
  }
// ── GET TOTAL WT FOR A KAPAN (all saved records except current edit) ────────
  Future<double> getUsedWtForKapan(
      String kapanNo, {
        int? excludeMstID,
      }) async {
    // Sirf us kapan ke records filter karo
    final records = list.where((e) =>
    e.kapanNo == kapanNo &&
        e.roughAssortMstID != excludeMstID,
    ).toList();

    if (records.isEmpty) return 0.0;

    double totalUsed = 0.0;

    for (final record in records) {
      // Har record ki details load karo
      final details = await loadDetails(record.roughAssortMstID!);
      final wt = details.fold(0.0, (s, d) => s + (d.wt ?? 0));
      totalUsed += wt;
    }

    return totalUsed;
  }
// Ek kapan ki already saved wt (excluding current edit)
  double usedWtForKapan(String kapanNo, {int? excludeMstID}) {
    // Details seedha nahi hain master mein — isliye 0 return karo
    // Actual wt _detRows se aayega screen mein
    return 0.0;
  }
  // ── LOAD ALL ────────────────────────────────────────────────────────────────
  Future<void> load() async {
    final result = await request<List<RoughAssortModel>>(
      call: () => api.get('/roughAssort'),
      onSuccess: (res) {
        final list = res.data as List;
        return list.map((e) => RoughAssortModel.fromJson(e)).toList();
      },
    );
    if (result != null) {
      _list     = result;
      _isLoaded = true;
      notifyListeners();
    }
  }

  // ── CREATE ──────────────────────────────────────────────────────────────────
  Future<bool> create(
      Map<String, dynamic>      values,
      List<RoughAssortDetModel> details,
      ) async {
    final model = _buildModel(values);
    final result = await request<RoughAssortModel>(
      call: () => api.post('/roughAssort', data: {
        ...model.toJson(),
        'details': details.map((e) => e.toJson()).toList(),
      }),
      onSuccess: (res) => RoughAssortModel.fromJson(res.data),
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
      int                       id,
      Map<String, dynamic>      values,
      List<RoughAssortDetModel> details,
      ) async {
    final model = _buildModel(values);
    final result = await request<RoughAssortModel>(
      call: () => api.put('/roughAssort/$id', data: {
        ...model.toJson(),
        'details': details.map((e) => e.toJson()).toList(),
      }),
      onSuccess: (res) => RoughAssortModel.fromJson(res.data),
    );
    if (result != null) {
      final i = _list.indexWhere((e) => e.roughAssortMstID == id);
      if (i != -1) _list[i] = result;
      notifyListeners();
      return true;
    }
    return false;
  }

  // ── DELETE ──────────────────────────────────────────────────────────────────
  Future<bool> delete(int id) async {
    final result = await request<bool>(
      call: () => api.delete('/roughAssort/$id'),
      onSuccess: (_) => true,
    );
    if (result == true) {
      _list.removeWhere((e) => e.roughAssortMstID == id);
      notifyListeners();
      return true;
    }
    return false;
  }

  // ── LOAD DETAILS (by master ID) ─────────────────────────────────────────────
  /// API: GET /roughAssort/:id  → { mst: {...}, det: [...] }
  Future<List<RoughAssortDetModel>> loadDetails(int mstID) async {
    final result = await request<List<RoughAssortDetModel>>(
      call: () => api.get('/roughAssort/$mstID'),
      onSuccess: (res) {
        // API response: { mst: {}, det: [] }
        final det = res.data['det'] as List? ?? [];
        return det.map((e) => RoughAssortDetModel.fromJson(e)).toList();
      },
    );
    return result ?? [];
  }

  // ── BUILD MODEL from form values ─────────────────────────────────────────────
  RoughAssortModel _buildModel(Map<String, dynamic> v) {
    int?    toI(String? s) => s == null || s.isEmpty ? null : int.tryParse(s);

    return RoughAssortModel(
      roughAssortDate: v['roughAssortDate'],
      remarks:         v['remarks'],
      sflag:           v['sflag'],
      logID:           toI(v['logID']),
      pcID:            v['pcID'],
      ever:            toI(v['ever']),
      jno:             toI(v['jno']),
      kapanNo:         v['kapanNo'],
    );
  }
}