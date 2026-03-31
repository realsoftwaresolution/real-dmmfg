// lib/providers/spk_dept_iss_provider.dart

import 'package:rs_dashboard/rs_dashboard.dart';

import '../models/spkDeptIss_mst_model.dart';

class SpkDeptIssProvider extends BaseProvider {
  List<SpkDeptIssMstModel> _list     = [];
  bool                     _isLoaded = false;

  bool                         get isLoaded => _isLoaded;
  List<SpkDeptIssMstModel>     get list     => List.unmodifiable(_list);
  List<Map<String, dynamic>>   get tableData =>
      _list.map((e) => e.toTableRow()).toList();
// Provider mein ye map maintain karo
// detMap declare karo (class level)
  Map<int, List<SpkDeptIssDetModel>> detMap = {};

// SIRF EK loadDetails rakho — dono merge karo:
  Future<List<SpkDeptIssDetModel>> loadDetails(int mstID) async {
    final result = await request<List<SpkDeptIssDetModel>>(
      call: () => api.get('/spkDeptIss/$mstID'),
      onSuccess: (res) {
        final data   = res.data;
        final rawDet = (data is Map ? data['det'] : data) as List? ?? [];
        return rawDet
            .map((e) => SpkDeptIssDetModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
    final dets = result ?? [];
    detMap[mstID] = dets;   // ← detMap update
    notifyListeners();
    return dets;
  }
  // ── LOAD ALL ──────────────────────────────────────────────────────────────
  Future<void> load() async {
    final result = await request<List<SpkDeptIssMstModel>>(
      call: () => api.get('/spkDeptIss'),
      onSuccess: (res) {
        final list = res.data as List;
        return list
            .map((e) => SpkDeptIssMstModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
    if (result != null) {
      _list     = result;
      _isLoaded = true;
      notifyListeners();
    }
  }
// BCode scan → PacketDet rows fetch
  Future<List<SpkDeptIssDetModel>> fetchByBCode({
    required String bCode,
    required String    fromCrId,
  }) async {
    final result = await request<List<SpkDeptIssDetModel>>(
      showLoader: false,
      call: () => api.get(
        '/spkDeptIss/scan-bcode',

        query: {
          'bCode':     bCode,
          'lastCrId':  fromCrId.toString(),
        },
      ),
      onSuccess: (res) {
        final data = res.data;
        final list = data is List ? data : [data];
        return list
            .map((e) => SpkDeptIssDetModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
      // onSuccess: (res) {
      //   final list = res.data as List? ?? [];
      //
      //   print('listttt----${list}');
      //
      //   return list
      //       .map((e) => SpkDeptIssDetModel.fromJson(e as Map<String, dynamic>))
      //       .toList();
      // },
    );
    return result ?? [];
  }
  // ── CREATE ────────────────────────────────────────────────────────────────
  Future<bool> create(
      Map<String, dynamic>       values,
      List<SpkDeptIssDetModel>   details,
      ) async {
    final model  = _buildModel(values);
    final result = await request<SpkDeptIssMstModel>(
      call: () => api.post('/spkDeptIss', data: {
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

  // ── UPDATE ────────────────────────────────────────────────────────────────
  Future<bool> update(
      int                        id,
      Map<String, dynamic>       values,
      List<SpkDeptIssDetModel>   details,
      ) async {
    final model  = _buildModel(values);
    final result = await request<SpkDeptIssMstModel>(
      call: () => api.put('/spkDeptIss/$id', data: {
        ...model.toJson(),
        'details': details.map((e) => e.toJson()).toList(),
      }),
      onSuccess: (res) => _parseMstResponse(res.data),
    );
    if (result != null) {
      final i = _list.indexWhere((e) => e.spkDeptIssMstID == id);
      if (i != -1) _list[i] = result;
      notifyListeners();
      return true;
    }
    return false;
  }

  // ── DELETE ────────────────────────────────────────────────────────────────
  Future<bool> delete(int id) async {
    final result = await request<bool>(
      call: () => api.delete('/spkDeptIss/$id'),
      onSuccess: (_) => true,
    );
    if (result == true) {
      _list.removeWhere((e) => e.spkDeptIssMstID == id);
      notifyListeners();
      return true;
    }
    return false;
  }

  // ── LOAD DETAILS ──────────────────────────────────────────────────────────
  // Future<List<SpkDeptIssDetModel>> loadDetails(int mstID) async {
  //   final result = await request<List<SpkDeptIssDetModel>>(
  //     call: () => api.get('/spkDeptIss/$mstID'),
  //     onSuccess: (res) {
  //       final data   = res.data;
  //       final rawDet = (data is Map ? data['det'] : data) as List? ?? [];
  //       return rawDet
  //           .map((e) => SpkDeptIssDetModel.fromJson(e as Map<String, dynamic>))
  //           .toList();
  //     },
  //   );
  //   return result ?? [];
  // }

  // ── PARSE { mst, det } response ───────────────────────────────────────────
  // SpkDeptIssMstModel _parseMstResponse(dynamic data) {
  //   if (data is Map) {
  //     if (data.containsKey('mst')) {
  //       final mst    = Map<String, dynamic>.from(data['mst'] as Map);
  //       final rawDet = data['det'] as List? ?? [];
  //       mst['details'] = rawDet;
  //       return SpkDeptIssMstModel.fromJson(mst);
  //     }
  //     return SpkDeptIssMstModel.fromJson(Map<String, dynamic>.from(data));
  //   }
  //   throw Exception('Unexpected response format');
  // }
  SpkDeptIssMstModel _parseMstResponse(dynamic data) {
    if (data is Map) {
      Map<String, dynamic> mstJson;
      if (data.containsKey('mst')) {
        mstJson = Map<String, dynamic>.from(data['mst'] as Map);
        final rawDet = data['det'] as List? ?? [];
        mstJson['details'] = rawDet;
        // Det se totals calculate karo (create/update ke baad)
        mstJson['TotPkt'] = rawDet.length;
        mstJson['TotalPc'] = rawDet.fold<int>(0, (s, d) =>
        s + ((d['TotalPc'] ?? 0) as num).toInt());
        mstJson['TotalWt'] = rawDet.fold<double>(0.0, (s, d) =>
        s + ((d['TotalWt'] ?? 0) as num).toDouble());
        mstJson['Jno'] = rawDet.isNotEmpty ? rawDet.first['Jno'] : null;
      } else {
        mstJson = Map<String, dynamic>.from(data);
      }
      return SpkDeptIssMstModel.fromJson(mstJson);
    }
    throw Exception('Unexpected response format');
  }
  // ── BUILD MODEL from form values ──────────────────────────────────────────
  SpkDeptIssMstModel _buildModel(Map<String, dynamic> v) {
    int? toI(String? s) => s == null || s.isEmpty ? null : int.tryParse(s);

    return SpkDeptIssMstModel(
      spkDeptIssDate:  v['spkDeptIssDate'],
      fromCrID:        toI(v['fromCrID']?.toString()),
      toCrID:          toI(v['toCrID']?.toString()),
      deptProcessCode: toI(v['deptProcessCode']?.toString()),
      deptCode:        toI(v['deptCode']?.toString()),
      sflag:           v['sflag'],
      stime:           v['Stime'],    // ← ADD
      sdate:           v['Sdate'],    // ← ADD
      logID:           toI(v['logID']?.toString()),
      pcID:            v['pcID'],
      ever:            toI(v['ever']?.toString()),
      entryType:       v['entryType'] ?? 'deptIss',
      repairing:       v['repairing'],
      formType:        v['formType'],
      proType:         v['proType'],
      formType1:       v['formType1'],
      nukCrId:         toI(v['nukCrId']?.toString()),
      planType:        v['planType'],
    );
  }
}