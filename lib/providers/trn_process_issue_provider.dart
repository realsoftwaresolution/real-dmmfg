import 'package:diam_mfg/models/factory_issue_entry_model.dart';
import 'package:diam_mfg/models/process_issue_model.dart';
import 'package:rs_dashboard/rs_dashboard.dart';

class ProcessIssueEntryProvider extends BaseProvider {
  List<ProcessIssueMstModel> _list = [];
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  List<ProcessIssueMstModel> get list => List.unmodifiable(_list);

  List<Map<String, dynamic>> get tableData =>
      _list.map((e) => e.toTableRow()).toList();

  // Provider mein ye map maintain karo
  // detMap declare karo (class level)
  Map<int, List<ProcessIssueDetModel>> detMap = {};

  // SIRF EK loadDetails rakho — dono merge karo:
  Future<List<ProcessIssueDetModel>> loadDetails(int mstID) async {
    final result = await request<List<ProcessIssueDetModel>>(
      call: () => api.get('/spkProcessIss/details/$mstID'),
      onSuccess: (res) {
        final json = res.data as Map<String, dynamic>;
        final data = json['data'] as List;

        return data
            .map(
              (e) => ProcessIssueDetModel.fromJson(e as Map<String, dynamic>),
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
  Future<dynamic> loadSummaryReport(int mstID) async {
    final result = await request<dynamic>(
      call: () => api.get('/spkProcessIss/details/$mstID?isSummary=true'),
      onSuccess: (res) {
        return res.data;
      },
    );
    return result;
  }

  // ── LOAD ALL ──────────────────────────────────────────────────────────────
  Future<void> load() async {
    final result = await request<List<ProcessIssueMstModel>>(
      call: () => api.get('/spkProcessIss'),
      onSuccess: (res) {
        final list = res.data['data'] as List;
        return list
            .map(
              (e) => ProcessIssueMstModel.fromJson(e as Map<String, dynamic>),
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

  Future<List<ProcessIssueDetModel>> fetchByBCode({
    required String bCode,
    int? toCrId,
  }) async {
    final queryParams = toCrId != null
        ? '?BCode=$bCode&ToCrID=$toCrId'
        : '?BCode=$bCode';
    final result = await request<List<ProcessIssueDetModel>>(
      showLoader: false,
      call: () => api.get('/spkProcessIss/barcode-data$queryParams'),
      onSuccess: (res) {
        final data = res.data['data'];
        final list = data is List ? data : [data];
        return list
            .map(
              (e) => ProcessIssueDetModel.fromJson(e as Map<String, dynamic>),
            )
            .toList();
      },
    );
    return result ?? [];
  }

  // ── CREATE ────────────────────────────────────────────────────────────────
  Future<bool> create(Map<String, dynamic> payload) async {
    final result = await request<ProcessIssueMstModel>(
      call: () => api.post(
        '/spkProcessIss',
        data: payload, // ✅ DIRECT PAYLOAD
      ),
      onSuccess: (res) => _parseMstResponse(res.data),
    );

    if (result != null) {
      load();
      return true;
    }
    return false;
  }

  Future<bool> insertInSameMst(Map<String, dynamic> payload, id) async {
    final result = await request<ProcessIssueMstModel>(
      call: () => api.post(
        '/spkProcessIss?id=$id',
        data: payload, // ✅ DIRECT PAYLOAD
      ),
      onSuccess: (res) => _parseMstResponse(res.data),
    );

    if (result != null) {
      load();
      return true;
    }
    return false;
  }

  // ── DELETE ────────────────────────────────────────────────────────────────
  Future<bool> delete(id) async {
    final result = await request<bool>(
      call: () => api.delete('/spkProcessIss/$id'),
      onSuccess: (_) => true,
    );
    if (result == true) {
      load();
      return true;
    }
    return false;
  }

  Future<bool> deleteRow(id) async {
    final result = await request<bool>(
      call: () => api.delete('/spkProcessIss/detail/$id'),
      onSuccess: (_) => true,
    );
    if (result == true) {
      notifyListeners();
      return true;
    }
    return false;
  }

  ProcessIssueMstModel _parseMstResponse(dynamic data) {
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
      return ProcessIssueMstModel.fromJson(mstJson);
    }
    throw Exception('Unexpected response format');
  }
}
