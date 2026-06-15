import 'package:diam_mfg/models/job_work_issue_model.dart';
import 'package:diam_mfg/utils/msg_dialogue.dart';
import 'package:diam_mfg/utils/process_constants.dart';
import 'package:rs_dashboard/rs_dashboard.dart';

class JobWorkIssueEntryProvider extends BaseProvider {
  List<JobWorkIssueMstModel> _list = [];
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  List<JobWorkIssueMstModel> get list => List.unmodifiable(_list);

  // Detail Map cache
  Map<int, List<JobWorkIssueDetModel>> detMap = {};

  // ── LOAD DETAILS ───────────────────────────────────────────────────────────
  Future<List<JobWorkIssueDetModel>> loadDetails(int mstID) async {
    final result = await request<List<JobWorkIssueDetModel>>(
      call: () => api.get('/jobWorkIss/$mstID'),
      onSuccess: (res) {
        final json = res.data as Map<String, dynamic>;
        final data = json['data']['details'] as List;

        return data
            .map(
              (e) => JobWorkIssueDetModel.fromJson(e as Map<String, dynamic>),
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
  Future<JobWorkIssueSummaryModel?> loadSummaryReport(int mstID) async {
    final result = await request<JobWorkIssueSummaryModel>(
      call: () => api.get('/jobWorkIss/$mstID?isSummary=true'),
      onSuccess: (res) {
        final json = res.data as Map<String, dynamic>;
        return JobWorkIssueSummaryModel.fromJson(json);
      },
    );
    return result;
  }

  // ── LOAD ALL ───────────────────────────────────────────────────────────────
  Future<void> load() async {
    final result = await request<List<JobWorkIssueMstModel>>(
      call: () => api.get('/jobWorkIss'),
      onSuccess: (res) {
        final list = res.data['data'] as List;
        return list
            .map(
              (e) => JobWorkIssueMstModel.fromJson(e as Map<String, dynamic>),
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
  Future<List<JobWorkIssueDetModel>> fetchByBCode({
    required String bCode,
  }) async {
    final result = await request<List<JobWorkIssueDetModel>>(
      showLoader: false,
      call: () => api.get('/jobWorkIss/scan-bcode/$bCode'),
      onSuccess: (res) {
        final data = res.data['data'];
        final list = data is List ? data : [data];
        return list
            .map(
              (e) => JobWorkIssueDetModel.fromJson(e as Map<String, dynamic>),
        )
            .toList();
      },
    );
    return result ?? [];
  }

  // ── CREATE ─────────────────────────────────────────────────────────────────
  Future<bool> create(Map<String, dynamic> payload) async {
    final result = await request<JobWorkIssueMstModel>(
      call: () => api.post(
        '/jobWorkIss',
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

  // ── UPDATE ─────────────────────────────────────────────────────────────────
  Future<bool> update(int mstID, Map<String, dynamic> payload) async {
    final result = await request<JobWorkIssueMstModel>(
      call: () => api.put(
        '/jobWorkIss/$mstID',
        data: payload,
      ),
      onSuccess: (res) => _parseMstResponse(res.data),
    );

    if (result != null) {
      final idx = _list.indexWhere((e) => e.jobWorkIssMstID == mstID);
      if (idx >= 0) {
        _list[idx] = result;
      }
      detMap.remove(mstID);
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
        '/jobWorkIss/$mstID/$detID/$bCode',
        data: {
          'expectedProcess': ProcessConstants.jobWorkIss,
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
          'expectedProcess': ProcessConstants.jobWorkIss,
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
      _list.removeWhere((e) => e.jobWorkIssMstID == mstID);
      detMap.remove(mstID);
      notifyListeners();
      return true;
    }
    return false;
  }

  // ── PARSE RESPONSE ─────────────────────────────────────────────────────────
  JobWorkIssueMstModel _parseMstResponse(dynamic data) {
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
      return JobWorkIssueMstModel.fromJson(mstJson);
    }
    throw Exception('Unexpected response format');
  }
}