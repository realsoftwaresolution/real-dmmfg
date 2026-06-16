import 'package:diam_mfg/models/factory_receive_mst_model.dart';
import 'package:diam_mfg/utils/msg_dialogue.dart';
import 'package:diam_mfg/utils/process_constants.dart';
import 'package:rs_dashboard/rs_dashboard.dart';

class FactoryReceivedEntryProvider extends BaseProvider {
  List<FactoryReceiveMstModel> _list = [];
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  List<FactoryReceiveMstModel> get list => List.unmodifiable(_list);

  List<Map<String, dynamic>> get tableData =>
      _list.map((e) => e.toTableRow()).toList();

  // Provider mein ye map maintain karo
  // detMap declare karo (class level)
  Map<int, List<FactoryReceiveDetModel>> detMap = {};

  // SIRF EK loadDetails rakho — dono merge karo:
  Future<List<FactoryReceiveDetModel>> loadDetails(int mstID) async {
    final result = await request<List<FactoryReceiveDetModel>>(
      call: () => api.get('/factoryRec/$mstID'),
      onSuccess: (res) {
        final json = res.data as Map<String, dynamic>;
        final data = json['data'] as List;
        return data
            .map(
              (e) => FactoryReceiveDetModel.fromJson(e as Map<String, dynamic>),
            )
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
    final result = await request<List<FactoryReceiveMstModel>>(
      call: () => api.get('/factoryRec'),
      onSuccess: (res) {
        final list = res.data['data'] as List;
        return list
            .map(
              (e) => FactoryReceiveMstModel.fromJson(e as Map<String, dynamic>),
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

  // BCode scan → PacketDet rows fetch
  Future<List<FactoryReceiveDetModel>> fetchByBCode({
    required String fCode,
    required String bCode,
  }) async {
    final result = await request<List<FactoryReceiveDetModel>>(
      showLoader: false,
      call: () => api.get('/factoryRec/scan-bcode/$fCode/$bCode'),
      onSuccess: (res) {
        final data = res.data['data'];
        final list = data is List ? data : [data];
        return list
            .map(
              (e) => FactoryReceiveDetModel.fromJson(e as Map<String, dynamic>),
            )
            .toList();
      },
    );
    return result ?? [];
  }

  // ── CREATE ────────────────────────────────────────────────────────────────
  Future<bool> create(Map<String, dynamic> payload, theme,
      context,) async {
    final result = await request<FactoryReceiveMstModel>(
      call: () => api.post('/factoryRec', data: payload),
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
      _list.insert(0, result);
      notifyListeners();
      return true;
    }
    return false;
  }

  // Send factoryCode first, then the detail payload as a map.
  Future<List<FactoryReceiveDetModel>> rateCallApi(String factoryCode, dynamic payload) async {
    // Ensure payload is a Map (models usually provide toJson())
    final detail = payload is FactoryReceiveDetModel
        ? payload.toJson()
        : (payload is Map<String, dynamic> ? payload : payload);

    // Add factoryCode into the detail map
    detail['FactoryCode'] = factoryCode;


    final result = await request<List<FactoryReceiveDetModel>>(
      call: () => api.post(
        '/factoryRec/rate-calculate',
        data: [detail],
      ),
      onSuccess: (res) {
        final data = res.data['data'];
        final list = data is List ? data : [data];
        return list
            .map((e) => FactoryReceiveDetModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
    return result ?? [];
  }
  Future<List<FactoryReceiveDetModel>> saleRateCallApi(dynamic payload) async {
    final result = await request<List<FactoryReceiveDetModel>>(
      call: () => api.post(
        '/factoryRec/sell-rate-calculate',
        data: [payload],
      ),
      onSuccess: (res) {
        final data = res.data['data'];
        final list = data is List ? data : [data];
        return list
            .map((e) => FactoryReceiveDetModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
    return result ?? [];
  }

  // ── UPDATE ────────────────────────────────────────────────────────────────
  Future<bool> update(Map<String, dynamic> values, theme,
  context,) async {
    final result = await request<FactoryReceiveMstModel>(
      call: () => api.put('/factoryRec', data: values),
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

  // ── DELETE ────────────────────────────────────────────────────────────────

  Future<bool> delete(id, theme, context, bCodeArray) async {
    final result = await request<bool>(
      call: () => api.delete(
        '/factoryRec/all/$id',
        data: {
          'expectedProcess': ProcessConstants.factoryRec,
          'bCodeArray': bCodeArray,
        },
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
      final mstId = int.tryParse(id.toString()) ?? 0;

      _list.removeWhere((e) => e.factoryRecMstID == mstId);

      detMap.remove(mstId);

      notifyListeners();

      return true;
    }
    return false;
  }

  Future<bool> deleteRow(
    factoryIssMstID,
    factoryIssDetID,
    bCode,
    theme,
    context,
  ) async {
    final result = await request<bool>(
      call: () => api.delete(
        '/factoryRec/$factoryIssMstID/$factoryIssDetID/$bCode',
        data: {'expectedProcess': ProcessConstants.factoryRec},
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

  FactoryReceiveMstModel _parseMstResponse(dynamic data) {
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
      return FactoryReceiveMstModel.fromJson(mstJson);
    }
    throw Exception('Unexpected response format');
  }
}
