import 'package:diam_mfg/models/job_work_rec_model.dart';
import 'package:diam_mfg/utils/msg_dialogue.dart';
import 'package:diam_mfg/utils/process_constants.dart';
import 'package:rs_dashboard/rs_dashboard.dart';

class JobWorkRecEntryProvider extends BaseProvider {
  List<JobWorkRecMstModel> _list = [];
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  List<JobWorkRecMstModel> get list => List.unmodifiable(_list); 

  // Detail Map cache
  Map<int, List<JobWorkRecDetModel>> detMap = {};

  // ── LOAD DETAILS ───────────────────────────────────────────────────────────
  Future<List<JobWorkRecDetModel>> loadDetails(int mstID) async {
    final result = await request<List<JobWorkRecDetModel>>(
      call: () => api.get('/jobWorkRec/$mstID'),
      onSuccess: (res) {
        final json = res.data as Map<String, dynamic>;
        final data = json['data']['details'] as List;

        return data
            .map(
              (e) => JobWorkRecDetModel.fromJson(e as Map<String, dynamic>),
        )
            .toList();
      },
    );

    final dets = result ?? [];
    detMap[mstID] = dets;
    notifyListeners();

    return dets;
  }

  // ── LOAD SUMMARY REPORT ────────────────────────────────────────────────────
  Future<JobWorkRecSummaryModel?> loadSummaryReport(int mstID) async {
    final result = await request<JobWorkRecSummaryModel>(
      call: () => api.get('/jobWorkRec/$mstID?isSummary=true'),
      onSuccess: (res) {
        final json = res.data as Map<String, dynamic>;
        return JobWorkRecSummaryModel.fromJson(json);
      },
    );
    return result;
  }

  // ── LOAD ALL ───────────────────────────────────────────────────────────────
  Future<void> load() async {
    final result = await request<List<JobWorkRecMstModel>>(
      call: () => api.get('/jobWorkRec'),
      onSuccess: (res) {
        final list = res.data['data'] as List;
        return list
            .map(
              (e) => JobWorkRecMstModel.fromJson(e as Map<String, dynamic>),
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

  // ── FETCH BY BCODE ─────────────────────────────────────────────────────────
  Future<List<JobWorkRecDetModel>> fetchByBCode({
    required String bCode,
    required  partyMst,
    required  deptProcessCode,
  }) async {
    final result = await request<List<JobWorkRecDetModel>>(
      showLoader: false,
      call: () => api.get('/jobWorkRec/scan-bcode/$partyMst/$bCode'),
      onSuccess: (res) {
        final data = res.data['data'];
        final list = data is List ? data : [data];
        return list
            .map(
              (e) => JobWorkRecDetModel.fromJson(e as Map<String, dynamic>),
        )
            .toList();
      },
    );
    return result ?? [];
  }

  // ── CREATE ─────────────────────────────────────────────────────────────────
  Future<bool> create(Map<String, dynamic> payload) async {
    final result = await request<JobWorkRecMstModel>(
      call: () => api.post(
        '/jobWorkRec',
        data: payload, // ✅ Direct payload matching API structure
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
  Future<bool> update(Map<String, dynamic> values, theme,
      context,) async {
    final result = await request<JobWorkRecMstModel>(
      call: () => api.put('/jobWorkRec/update', data: values),
      onSuccess: (res) {
        final data = res.data;
        print(data);
        if (data['success'] == false) {
          ErpResultDialog.showError(
            context: context,
            theme: theme,
            message: data['message'],
          );
          return data;
        }
        return _parseMstResponse(data);
      },
    );
    if (result != null) {
      notifyListeners();
      return true;
    }
    return false;
  }
  // ── DELETE ROW ─────────────────────────────────────────────────────────────
  Future<bool> deleteRow(
      int mstID,
      int detID,
      int bCode, {
        required dynamic theme,
        required dynamic context,
      }) async {
    final result = await request<bool>(
      call: () => api.delete(
        '/jobWorkRec/$mstID/$detID/$bCode',
        data: {
          'expectedProcess': ProcessConstants.jobWorkRec,
        },
      ),
      onSuccess: (res) {
        final data = res.data;
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
      detMap.remove(mstID);
      notifyListeners();
      return true;
    }
    return false;
  }

  // ── DELETE MASTER ──────────────────────────────────────────────────────────
  Future<bool> delete(
      int mstID, {
        required dynamic theme,
        required dynamic context,
        bCodeArray
      }) async {
    final result = await request<bool>(
      call: () => api.delete(
        '/jobworkIss/all/$mstID',
        data: {
          'expectedProcess': ProcessConstants.jobWorkRec,
          'bCodeArray': bCodeArray,
        },
      ),
      onSuccess: (res) {
        final data = res.data;
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
      _list.removeWhere((e) => e.jobWorkRecMstID == mstID);
      detMap.remove(mstID);
      notifyListeners();
      return true;
    }
    return false;
  }

  // ── PARSE RESPONSE ─────────────────────────────────────────────────────────
  JobWorkRecMstModel _parseMstResponse(dynamic data) {
    if (data is Map) {
      Map<String, dynamic> mstJson;
      if (data.containsKey('mst')) {
        mstJson = Map<String, dynamic>.from(data['mst'] as Map);
        final rawDet = data['details'] as List? ?? [];

        // Calculate totals from details
        mstJson['TotalPc'] = rawDet.fold<int>(
          0,
              (s, d) => s + ((d['Pc'] ?? 0) as num).toInt(),
        );
        mstJson['TotalWt'] = rawDet.fold<double>(
          0.0,
              (s, d) => s + ((d['Wt'] ?? 0) as num).toDouble(),
        );
        mstJson['TotalPairNo'] = rawDet.fold<int>(
          0,
              (s, d) => s + ((d['PairNo'] ?? 0) as num).toInt(),
        );
      } else {
        mstJson = Map<String, dynamic>.from(data);
      }
      return JobWorkRecMstModel.fromJson(mstJson);
    }
    throw Exception('Unexpected response format');
  }
}