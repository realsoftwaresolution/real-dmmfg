
import 'package:diam_mfg/models/planning_received_model.dart';
import 'package:rs_dashboard/rs_dashboard.dart';


class TrnPlanningReceivedProvider extends BaseProvider {
  List<PlanningReceivedMstModel> _list     = [];
  bool                     _isLoaded = false;

  bool                         get isLoaded => _isLoaded;
  List<PlanningReceivedMstModel>     get list     => List.unmodifiable(_list);
  List<Map<String, dynamic>>   get tableData =>
      _list.map((e) => e.toTableRow()).toList();
// Provider mein ye map maintain karo
// detMap declare karo (class level)
  Map<int, List<PlanningReceivedDetModel>> detMap = {};

  void clearForReset() {
    _scannedDetList.clear();   // clear barcode scan data
    detMap.clear();            // clear details map (important)
    notifyListeners();
  }

// SIRF EK loadDetails rakho — dono merge karo:
  Future<List<PlanningReceivedDetModel>> loadDetails(int mstID) async {
    final result = await request<List<PlanningReceivedDetModel>>(
      call: () => api.get('/spkDeptIss/$mstID'),
      onSuccess: (res) {
        final data   = res.data;
        final rawDet = (data is Map ? data['det'] : data) as List? ?? [];
        return rawDet
            .map((e) => PlanningReceivedDetModel.fromJson(e as Map<String, dynamic>))
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
    final result = await request<List<PlanningReceivedMstModel>>(
      call: () => api.get('/spkDeptIss'),
      onSuccess: (res) {
        final list = res.data as List;
        return list
            .map((e) => PlanningReceivedMstModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
    if (result != null) {
      _list     = result;
      _isLoaded = true;
      notifyListeners();
    }
  }

  // Store scanned det rows (which carry sarinData)
  List<PlanningReceivedDetModel> _scannedDetList = [];
  List<PlanningReceivedDetModel> get scannedDetList => _scannedDetList;
  List<PlanningReceivedDetModel> _planningDetList = [];
  List<PlanningReceivedDetModel> get planningDetList => _planningDetList;

  void clearScannedDetList() {
    _scannedDetList = [];
    notifyListeners();
  }

  Future<List<PlanningReceivedDetModel>> fetchByBCode({
    required String bCode,
    required String fromCrId,
  }) async {
    final result = await request<List<PlanningReceivedDetModel>>(
      showLoader: false,
      call: () => api.get(
        '/spkDeptIss/scan-bcode',
        query: {
          'bCode': bCode,
          'lastCrId': fromCrId.toString(),
          'screenName': 'PLANNING_RECEIVED',
        },
      ),
      onSuccess: (res) {
        final data = res.data['data'];
        final list = data is List ? data : [data];
        final parsed = list
            .map((e) => PlanningReceivedDetModel.fromJson(e as Map<String, dynamic>))
            .toList();
        for (var item in parsed) {
          if(parsed[0].sarinData!.isNotEmpty) {
            final index = _scannedDetList.indexWhere(
                    (e) => e.bCode.toString() == item.bCode.toString());
            if (index == -1) {
              _scannedDetList.insert(0,item);
            } else {
              _scannedDetList[index] = item; // update existing
            }
          }
        }
        notifyListeners();

        return parsed;
      },
    );
    return result ?? [];
  }

  Future<List<PlanningReceivedDetModel>> fetchByBCodePlanningList({
    required String bCode,
    required String fromCrId,
  }) async {

    final result = await request<List<PlanningReceivedDetModel>>(
      showLoader: false,

      call: () => api.get(
        '/spkDeptIss/scan-bcode-wise-planning-list',
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

        final List<dynamic> list =
        responseData is List
            ? responseData
            : [responseData];

        final parsed = list.map((e) {

          return PlanningReceivedDetModel.fromJson(
            Map<String, dynamic>.from(e),
          );

        }).toList();

        _planningDetList = parsed;

        notifyListeners();

        return parsed;
      },
    );

    return result ?? [];
  }

  // ── CREATE ────────────────────────────────────────────────────────────────
  Future<bool> create(
      Map<String, dynamic>       values,
      List<PlanningReceivedDetModel>   details,
      ) async {
    final model  = _buildModel(values);
    final result = await request<PlanningReceivedMstModel>(
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
      List<PlanningReceivedDetModel>   details,
      ) async {
    final model  = _buildModel(values);
    final result = await request<PlanningReceivedMstModel>(
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
  
  PlanningReceivedMstModel _parseMstResponse(dynamic data) {
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
      return PlanningReceivedMstModel.fromJson(mstJson);
    }
    throw Exception('Unexpected response format');
  }
  // ── BUILD MODEL from form values ──────────────────────────────────────────
  PlanningReceivedMstModel _buildModel(Map<String, dynamic> v) {
    int? toI(String? s) => s == null || s.isEmpty ? null : int.tryParse(s);

    return PlanningReceivedMstModel(
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
      entryType:       v['entryType'] ?? 'B',
      repairing:       v['repairing'] ?? 'N',
      formType:        v['formType'] ?? 'PLANNING RECEIVED',
      proType:         v['proType'] ?? 'SPK',
      formType1:       v['formType1'],
      nukCrId:         toI(v['nukCrId']?.toString()),
      planType:        v['planType'],
    );
  }
}