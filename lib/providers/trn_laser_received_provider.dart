import 'package:diam_mfg/models/laser_mst_model.dart';
import 'package:diam_mfg/utils/msg_dialogue.dart';
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
    expectedProcess,
    bCodeArray,
    theme,
    context,
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
          'EntryType': 'B',
          'SPKDeptIssDate': spkDeptIssDate,
          'bCodeArray': bCodeArray, 'expectedProcess': expectedProcess,
            'isSame': isSame,
        },
      ),
      onSuccess: (res) {
        final responseData = res.data['data'];
        if (res.data['success'] == false) {
          ErpResultDialog.showError(
            context: context,
            theme: theme,
            message: res.data['message'],
          );
          return res.data;
        }
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

// ── BULK DELETE ───────────────────────────────────────────────────────────
  Future<bool> delete({
    required int spkDeptIssMstID,
    required List<dynamic> bCodeArray,
    required List<dynamic> deleteBCodeArray,
    expectedProcess,
    theme,
    context,
  }) async {
    final body = {
      "spkDeptIssMstID": spkDeptIssMstID,
      "bCodeArray": bCodeArray,
      "deleteBCodeArray": deleteBCodeArray,
      'expectedProcess': expectedProcess,
    };

    final result = await request<bool>(
      call: () => api.post(
        '/spkDeptIss/bulk-clear',
        data: body,
      ),
      onSuccess: (res) {
        final data = res.data;
        print(data);
        if (data['success'] == false) {
          ErpResultDialog.showError(
            context: context,
            theme: theme,
            message: data['message'],
          );
          return false;
        }
        return true;
      },
    );

    if (result == true) {
      notifyListeners();
      return true;
    }

    return false;
  }

// ── SINGLE DELETE ────────────────────────────────────────────────────────
  Future<bool> singleDelete({
    required int spkDeptIssMstID,
    required dynamic bCode,
    expectedProcess,
    theme,
    context,
  }) async {
    final body = {
      "spkDeptIssMstID": spkDeptIssMstID,
      "bCode": bCode,
      'expectedProcess': expectedProcess,
    };

    final result = await request<bool>(
      call: () => api.post(
        '/spkDeptIss/single-clear',
        data: body,
      ),
      onSuccess: (res) {
        final data = res.data;
        print(data);
        if (data['success'] == false) {
          ErpResultDialog.showError(
            context: context,
            theme: theme,
            message: data['message'],
          );
          return false;
        }
        return true;
      },
    );

    if (result == true) {
      notifyListeners();
      return true;
    }

    return false;
  }
}
