import 'dart:convert';

import 'package:diam_mfg/models/planning_received_model.dart';
import 'package:diam_mfg/utils/msg_dialogue.dart';
import 'package:flutter/material.dart';
import 'package:rs_dashboard/rs_dashboard.dart';

class TrnPlanningReceivedProvider extends BaseProvider {
  List<PlanningReceivedMstModel> _list = [];
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  List<PlanningReceivedMstModel> get list => List.unmodifiable(_list);

  List<Map<String, dynamic>> get tableData =>
      _list.map((e) => e.toTableRow()).toList();

  // Provider mein ye map maintain karo
  // detMap declare karo (class level)
  Map<int, List<PlanningReceivedDetModel>> detMap = {};

  void clearForReset() {
    // TABLE 1
    _planningDetList.clear();

    // TABLE 2
    _scannedDetList.clear();

    // TEMP LISTS
    _tempPlanningDetList.clear();

    _tempScannedDetList.clear();

    // MASTER DETAIL CACHE
    detMap.clear();

    notifyListeners();
  }

  // SIRF EK loadDetails rakho — dono merge karo:
  Future<List<PlanningReceivedDetModel>> loadDetails(int mstID) async {
    final result = await request<List<PlanningReceivedDetModel>>(
      call: () => api.get('/spkDeptIss/$mstID'),

      onSuccess: (res) {
        final responseData = res.data['det'];
        if (responseData == null) {
          _planningDetList = [];
          detMap[mstID] = [];
          notifyListeners();
          return <PlanningReceivedDetModel>[];
        }

        final List<dynamic> list = responseData is List
            ? responseData
            : [responseData];

        final parsed = list.map((e) {
          return PlanningReceivedDetModel.fromJson(
            Map<String, dynamic>.from(e),
          );
        }).toList();

        // TABLE DATA
        _planningDetList = parsed;

        // MASTER DETAIL MAP
        detMap[mstID] = parsed;

        notifyListeners();

        return parsed;
      },
    );

    return result ?? [];
  }

  Future<List<PlanningReceivedDetModel>> loadSarinDataDetails(int mstID) async {
    final result = await request<List<PlanningReceivedDetModel>>(
      call: () => api.get('/spkPlanning/planning-details/$mstID'),

      onSuccess: (res) {
        final responseData = res.data['data'];

        print('responseData $responseData');

        if (responseData == null) {
          _scannedDetList = [];

          notifyListeners();

          return <PlanningReceivedDetModel>[];
        }

        final List<dynamic> list = responseData is List
            ? responseData
            : [responseData];

        // GROUP BY BCODE
        final Map<String, List<Map<String, dynamic>>> grouped = {};

        for (final item in list) {
          final map = Map<String, dynamic>.from(item);

          final bcode = map['BCode'].toString();

          grouped.putIfAbsent(bcode, () => []);

          grouped[bcode]!.add({
            // CONVERT TO SARIN FORMAT
            'SarinPolID': map['SPKPlanningDetID'],

            'StoneID': map['PktNo'],

            'PolishWT': map['PoWt'],

            'PolishPer': map['PoPer'],

            'SHAPE': map['ShapeName'],

            'CUT': map['CutName'],

            'Color': map['ColorName'],

            'Clarity': map['PurityName'],

            'TWT': map['RgWt'],

            'Rate': map['Rate'],

            'AMT': map['Amt'],

            'LotCode': map['PktNo'],

            'KapanNo': map['CutNo'],

            'SrNum': map['PktNo'],

            'CrownHeight': map['HeightPer'],

            'operatorName': map['OptName'],

            'THmm': map['Height'],

            'DISC': map['Disc'],

            'Rec': map['NetAmt'],

            'BCode': map['BCode'],
          });
        }

        final parsed = grouped.entries.map((entry) {
          final first = entry.value.first;

          return PlanningReceivedDetModel(
            bCode: entry.key,

            sarinData: entry.value,

            pktNo: first['StoneID']?.toString(),

            cutNo: first['KapanNo']?.toString(),
          );
        }).toList();

        _scannedDetList = parsed;

        notifyListeners();

        return parsed;
      },
    );

    return result ?? [];
  }

  // ── LOAD ALL ──────────────────────────────────────────────────────────────
  Future<void> load() async {
    final result = await request<List<PlanningReceivedMstModel>>(
      call: () => api.get('/spkDeptIss'),
      onSuccess: (res) {
        final list = res.data as List;
        return list
            .map(
              (e) =>
                  PlanningReceivedMstModel.fromJson(e as Map<String, dynamic>),
            )
            .toList();
      },
    );
    if (result != null) {
      _list = result;
      _isLoaded = true;
      notifyListeners();
    }
  }

  // Store scanned det rows (which carry sarinData)
  List<PlanningReceivedDetModel> _scannedDetList = [];

  List<PlanningReceivedDetModel> get scannedDetList => _scannedDetList;
  List<PlanningReceivedDetModel> _planningDetList = [];

  List<PlanningReceivedDetModel> get planningDetList => _planningDetList;

  List<PlanningReceivedDetModel> _tempPlanningDetList = [];

  List<PlanningReceivedDetModel> _tempScannedDetList = [];

  void clearScannedDetList() {
    _scannedDetList = [];
    notifyListeners();
  }

  void clearTempScanData() {
    _tempPlanningDetList = [];

    _tempScannedDetList = [];
  }

  void commitTempScanData() {
    _planningDetList.addAll(_tempPlanningDetList);

    _scannedDetList.addAll(_tempScannedDetList);

    notifyListeners();
  }

  Future<List<PlanningReceivedDetModel>> fetchByBCodePlanningList({
    required String bCode,
    required String fromCrId,
  }) async {
    final result = await request<List<PlanningReceivedDetModel>>(
      showLoader: false,

      call: () => api.get(
        '/spkDeptIss/scan-bcode',
        query: {
          'bCode': bCode,
          'lastCrId': fromCrId,
          'screenName': 'PLANNING_RECEIVED',
        },
      ),

      onSuccess: (res) {
        final responseData = res.data['data'];
        if (responseData == null) {
          _planningDetList = [];
          notifyListeners();
          return <PlanningReceivedDetModel>[];
        }

        final List<dynamic> list = responseData is List
            ? responseData
            : [responseData];

        final parsed = list.map((e) {
          return PlanningReceivedDetModel.fromJson(
            Map<String, dynamic>.from(e),
          );
        }).toList();

        _tempPlanningDetList = parsed;
        return parsed;
      },
    );

    return result ?? [];
  }

  // ── Theme ──────────────────────────────────────────────────────────────────
  final ErpThemeVariant _themeVariant = ErpThemeVariant.frost;

  ErpTheme get _theme => ErpTheme(_themeVariant);

  // ─────────────────────────────────────────────
  // fetchByBCode
  // ─────────────────────────────────────────────
  Future<List<PlanningReceivedDetModel>> fetchByBCode({
    required String bCode,
    required String fromCrId,
    required BuildContext context,
  }) async {

    final result = await request<List<PlanningReceivedDetModel>>(

      call: () => api.get(
        '/spkDeptIss/scan-bcode',
        query: {
          'bCode': bCode,
          'lastCrId': fromCrId.toString(),
          'screenName': 'SARIN_PLANNING_RECEIVED',
        },
      ),

      onSuccess: (res) {

        final data = res.data;

        print('fetchByBCode data => $data');
print('ashdajkdasdhak ${data['data']['success']}');
        /// API ERROR
        if (data['data']['success'] == false) {

          final errors =
              (data['data']['errors'] as List?)
                  ?.join('\n') ??
                  'Sarin data not found';

          ErpResultDialog.showError(
            context: context,
            theme: _theme,
            message: errors,
            title: 'Error',
          );

          return <PlanningReceivedDetModel>[];
        }

        /// NORMAL DATA
        final responseData = data['data'];

        if (responseData == null ||
            responseData is! List) {

          return <PlanningReceivedDetModel>[];
        }

        final List<dynamic> list = responseData;

        final parsed = list.map((e) {

          return PlanningReceivedDetModel.fromJson(
            Map<String, dynamic>.from(e),
          );

        }).toList();

        _tempScannedDetList = parsed;

        return parsed;
      },
    );

    return result ?? [];
  }

  // ── CREATE ────────────────────────────────────────────────────────────────
  Future<bool> savePlanningDetails(
    Map<String, dynamic> values,
    List<PlanningReceivedDetModel> details,
    List<SpkPlanningSaveModel> scannedDetList,
  ) async {
    final model = _buildModel(values);
    // ✅ Convert model → map and remove BCode
    final modelMap = Map<String, dynamic>.from(model.toJson())
      ..remove('DeptCode')
      ..remove('DeptCode')
      ..remove('DeptProcessCode')
      ..remove('ToCrID')
      ..remove('FromCrID');
    // 🔥 REMOVE HERE
    final result = await request<PlanningReceivedMstModel>(
      call: () => api.post(
        '/spkPlanning/save-planning-details',
        data: {
          'spk': {
            ...modelMap, // ✅ cleaned
            'details': details.map((e) {
              final map = Map<String, dynamic>.from(e.toJson())
                ..remove('LastDmWt')
                ..remove('LastDmPer');

              return map;
            }).toList(),
          },
          'planning': scannedDetList.map((e) => e.toJson()).toList(),
        },
      ),
      onSuccess: (res) => _parseMstResponse(res.data),
    );
    if (result != null) {
      notifyListeners();
      return true;
    }
    return false;
  }

  // ── DELETE ────────────────────────────────────────────────────────────────
  Future<bool> delete({required int spkDeptIssMstId, bcode}) async {
    final result = await request<bool>(
      call: () => api.post(
        '/spkPlanning/planning/single-delete',
        data: {'bcode': bcode, 'spkDeptIssMstId': spkDeptIssMstId},
      ),
      onSuccess: (_) => true,
    );
    if (result == true) {
      _list.removeWhere((e) => e.spkDeptIssMstID == spkDeptIssMstId);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> deleteBulk(data) async {
    final result = await request<bool>(
      call: () =>
          api.post('/spkPlanning/planning/bulk-delete', data: {'items': data}),
      onSuccess: (_) => true,
    );
    if (result == true) {
      _list.clear();
      notifyListeners();
      return true;
    }
    return false;
  }

  PlanningReceivedMstModel _parseMstResponse(dynamic data) {
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
      return PlanningReceivedMstModel.fromJson(mstJson);
    }
    throw Exception('Unexpected response format');
  }

  // ── BUILD MODEL from form values ──────────────────────────────────────────
  PlanningReceivedMstModel _buildModel(Map<String, dynamic> v) {
    int? toI(String? s) => s == null || s.isEmpty ? null : int.tryParse(s);

    return PlanningReceivedMstModel(
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
      formType: v['formType'] ?? 'PLANNINGREC',
      //d det spk
      proType: v['proType'] ?? 'SPK',
      formType1: v['formType1'],
      nukCrId: toI(v['nukCrId']?.toString()),
      planType: v['planType'],
    );
  }
}
