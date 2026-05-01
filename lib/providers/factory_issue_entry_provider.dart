import 'package:diam_mfg/models/factory_issue_entry_model.dart';
import 'package:rs_dashboard/rs_dashboard.dart';

class FactoryIssueEntryProvider extends BaseProvider {
  List<FactoryIssueMstModel> _list     = [];
  bool                     _isLoaded = false;

  bool                         get isLoaded => _isLoaded;
  List<FactoryIssueMstModel>     get list     => List.unmodifiable(_list);
  List<Map<String, dynamic>>   get tableData =>
      _list.map((e) => e.toTableRow()).toList();
// Provider mein ye map maintain karo
// detMap declare karo (class level)
  Map<int, List<FactoryIssueDetModel>> detMap = {};

// SIRF EK loadDetails rakho — dono merge karo:
  Future<List<FactoryIssueDetModel>> loadDetails(int mstID) async {
    final result = await request<List<FactoryIssueDetModel>>(
      call: () => api.get('/factoryIss/$mstID'),
      onSuccess: (res) {
        final json = res.data as Map<String, dynamic>;
        final data = json['data'] as List;

        return data
            .map((e) => FactoryIssueDetModel.fromJson(
          e as Map<String, dynamic>,
        ))
            .toList();
      },
    );

    final dets = result ?? [];

    detMap[mstID] = dets;
    notifyListeners();

    return dets;
  }

  // ── LOAD ALL ──────────────────────────────────────────────────────────────
  Future<void> load() async {
    final result = await request<List<FactoryIssueMstModel>>(
      call: () => api.get('/factoryIss?page=1&limit=2000'),
      onSuccess: (res) {
        final list = res.data['data'] as List;
        return list
            .map((e) => FactoryIssueMstModel.fromJson(e as Map<String, dynamic>))
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
  Future<List<FactoryIssueDetModel>> fetchByBCode({
    required String bCode
  }) async {
    final result = await request<List<FactoryIssueDetModel>>(
      showLoader: false,
      call: () => api.get(
        '/factoryIss/scan-bcode/$bCode',
      ),
      onSuccess: (res) {
        final data = res.data['data'];
        final list = data is List ? data : [data];
        return list
            .map((e) => FactoryIssueDetModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
    return result ?? [];
  }
  // ── CREATE ────────────────────────────────────────────────────────────────
  Future<bool> create(Map<String, dynamic> payload) async {
    final result = await request<FactoryIssueMstModel>(
      call: () => api.post(
        '/factoryIss',
        data: payload, // ✅ DIRECT PAYLOAD
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
      int                        id,
      Map<String, dynamic>       payload,
      ) async {
    final result = await request<FactoryIssueMstModel>(
      call: () => api.put('/factoryIss/$id', data: payload),
      onSuccess: (res) => _parseMstResponse(res.data),
    );
    if (result != null) {
      final i = _list.indexWhere((e) => e.factoryIssMstID == id);
      if (i != -1) _list[i] = result;
      notifyListeners();
      return true;
    }
    return false;
  }

  // ── DELETE ────────────────────────────────────────────────────────────────
  Future<bool> delete( id) async {
    final result = await request<bool>(
      call: () => api.delete('/factoryIss/all/$id'),
      onSuccess: (_) => true,
    );
    if (result == true) {
      _list.removeWhere((e) => e.factoryIssMstID == id);
      notifyListeners();
      return true;
    }
    return false;
  }
  Future<bool> deleteRow( factoryIssMstID, factoryIssDetID, bCode) async {
    final result = await request<bool>(
      call: () => api.delete('/factoryIss/$factoryIssMstID/$factoryIssDetID/$bCode'),
      onSuccess: (_) => true,
    );
    if (result == true) {
      notifyListeners();
      return true;
    }
    return false;
  }
  FactoryIssueMstModel _parseMstResponse(dynamic data) {
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
      return FactoryIssueMstModel.fromJson(mstJson);
    }
    throw Exception('Unexpected response format');
  }
  // ── BUILD MODEL from form values ──────────────────────────────────────────
  FactoryIssueMstModel _buildModel(Map<String, dynamic> v) {
    int toI(dynamic x) => int.tryParse(x?.toString() ?? '0') ?? 0;

    return FactoryIssueMstModel(
      factoryIssDate: v['FactoryIssDate'],
      time: v['Time'],

      selectType: v['SelectType'],
      dueDay: toI(v['DueDay']),
      dueDate: v['DueDate'],

      factoryCode: toI(v['FactoryCode']),
      factoryName: v['FactoryName'],   // optional
      factoryType: v['FactoryType'],

      entryType: v['EntryType'],
      jno: v['Jno'],

      // totals (optional)
      pkt: toI(v['Pkt']),
      pc: toI(v['Pc']),
      wt: (v['Wt'] as num?)?.toDouble(),

      issPc: toI(v['IssPc']),
      issWt: (v['IssWt'] as num?)?.toDouble(),

      dmWt: (v['DmWt'] as num?)?.toDouble(),
      dmPer: (v['DmPer'] as num?)?.toDouble(),
    );
  }
}