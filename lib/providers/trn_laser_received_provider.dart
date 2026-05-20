import 'package:diam_mfg/models/laser_mst_model.dart';
import 'package:flutter/foundation.dart';
import 'package:rs_dashboard/rs_dashboard.dart';

class TrnLaserReceivedProvider extends BaseProvider {
  List<LaserMstModel> _list = [];
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  List<LaserMstModel> get list => List.unmodifiable(_list);

  List<Map<String, dynamic>> get tableData =>
      _list.map((e) => e.toTableRow()).toList();

  // Provider mein ye map maintain karo
  // detMap declare karo (class level)
  Map<int, List<LaserDetModel>> detMap = {};

  void clearForReset() {
    detMap.clear(); // clear details map (important)
    _list.clear(); // clear details map (important)
    notifyListeners();
  }

  // SIRF EK loadDetails rakho — dono merge karo:
  Future<List<LaserDetModel>> loadDetails(int mstID) async {
    final result = await request<List<LaserDetModel>>(
      call: () => api.get('/spkDeptIss/$mstID'),
      onSuccess: (res) {
        final data = res.data;
        final rawDet = (data is Map ? data['det'] : data) as List? ?? [];
        return rawDet
            .map((e) => LaserDetModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
    final dets = result ?? [];
    detMap[mstID] = dets; // ← detMap update
    notifyListeners();
    return dets;
  }

  // ── LOAD ALL ──────────────────────────────────────────────────────────────
  Future<void> load() async {
    final result = await request<List<LaserMstModel>>(
      call: () => api.get('/spkDeptIss'),
      onSuccess: (res) {
        final list = res.data as List;
        return list
            .map((e) => LaserMstModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
    if (result != null) {
      _list = result;
      _isLoaded = true;
      notifyListeners();
    }
  }

  void clearScannedDetList() {
    notifyListeners();
  }

  Future<List<LaserDetModel>> fetchByBCode({
    required String bCode,
    required String fromCrId,
  }) async {
    final result = await request<List<LaserDetModel>>(
      showLoader: false,
      call: () => api.get(
        '/spkDeptIss/scan-bcode',
        query: {
          'bCode': bCode,
          'lastCrId': fromCrId.toString(),
          'screenName': 'LASER_RECEIVED',
        },
      ),
      onSuccess: (res) {
        final data = res.data['data'];
        final list = data is List ? data : [data];
        final parsed = list
            .map((e) => LaserDetModel.fromJson(e as Map<String, dynamic>))
            .toList();
        notifyListeners();
        return parsed;
      },
    );
    return result ?? [];
  }

  Future<List<LaserDetModel>> laserSelectData({
    required String bCode,
    required String fromCrId,
    required dynamic gridData,
    required dynamic time,
    required dynamic spkDeptIssDate,
    required dynamic SPKDeptIssMstID,
    required dynamic isSame,
  }) async {
    final result = await request<List<LaserDetModel>>(
      showLoader: false,
      call: () => api.post(
        '/spkDeptIss/laser-data-list-select',
        data: {
          'SPKDeptIssMstID': SPKDeptIssMstID == 0 ? 0 : SPKDeptIssMstID,
          'bCode': bCode,
          'lastCrId': fromCrId.toString(),
          'screenName': 'LASER_RECEIVED',
          'gridData': gridData,
          'FormType': 'LASERREC',
          if(isSame)
          'isSame': isSame,
        },
      ),
      onSuccess: (res) {
        final responseData = res.data['data'];

        if (responseData == null) {
          return <LaserDetModel>[];
        }

        return (responseData as List)
            .map((e) => LaserDetModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      },
    );

    notifyListeners();

    return result ?? [];
  }

  // ── CREATE ────────────────────────────────────────────────────────────────
  Future<bool> create(
    Map<String, dynamic> values,
    List<LaserDetModel> details,
  ) async {
    final model = _buildModel(values);
    final result = await request<LaserMstModel>(
      call: () => api.post(
        '/spkDeptIss',
        data: {
          ...model.toJson(),
          'details': details.map((e) => e.toJson()).toList(),
        },
      ),
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
    int id,
    Map<String, dynamic> values,
    List<LaserDetModel> details,
  ) async {
    final model = _buildModel(values);
    final result = await request<LaserMstModel>(
      call: () => api.put(
        '/spkDeptIss/$id',
        data: {
          ...model.toJson(),
          'details': details.map((e) => e.toJson()).toList(),
        },
      ),
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
  // Future<List<LaserDetModel>> loadDetails(int mstID) async {
  //   final result = await request<List<LaserDetModel>>(
  //     call: () => api.get('/spkDeptIss/$mstID'),
  //     onSuccess: (res) {
  //       final data   = res.data;
  //       final rawDet = (data is Map ? data['det'] : data) as List? ?? [];
  //       return rawDet
  //           .map((e) => LaserDetModel.fromJson(e as Map<String, dynamic>))
  //           .toList();
  //     },
  //   );
  //   return result ?? [];
  // }

  // ── PARSE { mst, det } response ───────────────────────────────────────────
  // LaserMstModel _parseMstResponse(dynamic data) {
  //   if (data is Map) {
  //     if (data.containsKey('mst')) {
  //       final mst    = Map<String, dynamic>.from(data['mst'] as Map);
  //       final rawDet = data['det'] as List? ?? [];
  //       mst['details'] = rawDet;
  //       return LaserMstModel.fromJson(mst);
  //     }
  //     return LaserMstModel.fromJson(Map<String, dynamic>.from(data));
  //   }
  //   throw Exception('Unexpected response format');
  // }
  LaserMstModel _parseMstResponse(dynamic data) {
    if (data is Map) {
      Map<String, dynamic> mstJson;
      if (data.containsKey('mst')) {
        mstJson = Map<String, dynamic>.from(data['mst'] as Map);
        final rawDet = data['det'] as List? ?? [];
        mstJson['details'] = rawDet;
        // Det se totals calculate karo (create/update ke baad)
        mstJson['TotPkt'] = rawDet.length;
        mstJson['TotalPc'] = rawDet.fold<int>(
          0,
          (s, d) => s + ((d['TotalPc'] ?? 0) as num).toInt(),
        );
        mstJson['TotalWt'] = rawDet.fold<double>(
          0.0,
          (s, d) => s + ((d['TotalWt'] ?? 0) as num).toDouble(),
        );
        mstJson['Jno'] = rawDet.isNotEmpty ? rawDet.first['Jno'] : null;
      } else {
        mstJson = Map<String, dynamic>.from(data);
      }
      return LaserMstModel.fromJson(mstJson);
    }
    throw Exception('Unexpected response format');
  }

  // ── BUILD MODEL from form values ──────────────────────────────────────────
  LaserMstModel _buildModel(Map<String, dynamic> v) {
    int? toI(String? s) => s == null || s.isEmpty ? null : int.tryParse(s);

    return LaserMstModel(
      spkDeptIssDate: v['spkDeptIssDate'],
      fromCrID: toI(v['fromCrID']?.toString()),
      toCrID: toI(v['toCrID']?.toString()),
      deptProcessCode: toI(v['deptProcessCode']?.toString()),
      deptCode: toI(v['deptCode']?.toString()),
      sflag: v['sflag'],
      stime: v['Stime'],
      // ← ADD
      sdate: v['Sdate'],
      // ← ADD
      logID: toI(v['logID']?.toString()),
      pcID: v['pcID'],
      ever: toI(v['ever']?.toString()),
      entryType: v['entryType'] ?? 'B',
      repairing: v['repairing'] ?? 'N',
      formType: v['formType'] ?? 'LASERREC',
      proType: v['proType'] ?? 'SPK',
      formType1: v['formType1'],
      nukCrId: toI(v['nukCrId']?.toString()),
      planType: v['planType'],
    );
  }
}
