import 'package:diam_mfg/models/repair_receive_mst_model.dart';
import 'package:diam_mfg/utils/msg_dialogue.dart';
import 'package:diam_mfg/utils/process_constants.dart';
import 'package:rs_dashboard/rs_dashboard.dart';

class RepairReceivedEntryProvider extends BaseProvider {
  List<RepairReceiveMstModel> _list = [];
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  List<RepairReceiveMstModel> get list => List.unmodifiable(_list);

  List<Map<String, dynamic>> get tableData =>
      _list.map((e) => e.toTableRow()).toList();

  // Provider mein ye map maintain karo
  // detMap declare karo (class level)
  Map<int, List<RepairReceiveDetModel>> detMap = {};

  // SIRF EK loadDetails rakho — dono merge karo:
  Future<List<RepairReceiveDetModel>> loadDetails(int mstID) async {
    final result = await request<List<RepairReceiveDetModel>>(
      call: () => api.get('/repairRec/$mstID'),
      onSuccess: (res) {
        final json = res.data as Map<String, dynamic>;
        final data = json['data'] as List;
        return data
            .map(
              (e) => RepairReceiveDetModel.fromJson(e as Map<String, dynamic>),
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
    final result = await request<List<RepairReceiveMstModel>>(
      call: () => api.get('/repairRec'),
      onSuccess: (res) {
        final list = res.data['data'] as List;
        return list
            .map(
              (e) => RepairReceiveMstModel.fromJson(e as Map<String, dynamic>),
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
  Future<List<RepairReceiveDetModel>> fetchByBCode({
    required String fCode,
    required String bCode,
  }) async {
    final result = await request<List<RepairReceiveDetModel>>(
      showLoader: false,
      call: () => api.get('/repairRec/scan-bcode/$fCode/$bCode'),
      onSuccess: (res) {
        final data = res.data['data'];
        final list = data is List ? data : [data];
        print('step---2');
        return list
            .map(
              (e) => RepairReceiveDetModel.fromJson(e as Map<String, dynamic>),
            )
            .toList();
      },
    );
    return result ?? [];
  }

  // ── CREATE ────────────────────────────────────────────────────────────────
  Future<bool> create(Map<String, dynamic> payload, theme,
      context,) async {
    final result = await request<RepairReceiveMstModel>(
      call: () => api.post('/repairRec', data: payload),
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
  Future<List<RepairReceiveDetModel>> rateCallApi(String factoryCode, dynamic payload) async {
    // Ensure payload is a Map (models usually provide toJson())
    final detail = payload is RepairReceiveDetModel
        ? payload.toJson()
        : (payload is Map<String, dynamic> ? payload : payload);

    // Add factoryCode into the detail map
    detail['FactoryCode'] = factoryCode;


    final result = await request<List<RepairReceiveDetModel>>(
      call: () => api.post(
        '/factoryRec/rate-calculate',
        data: [detail],
      ),
      onSuccess: (res) {
        final data = res.data['data'];
        final list = data is List ? data : [data];
        return list
            .map((e) => RepairReceiveDetModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
    return result ?? [];
  }
  Future<List<RepairReceiveDetModel>> saleRateCallApi(dynamic payload) async {
    final result = await request<List<RepairReceiveDetModel>>(
      call: () => api.post(
        '/factoryRec/sell-rate-calculate',
        data: [payload],
      ),
      onSuccess: (res) {
        final data = res.data['data'];
        final list = data is List ? data : [data];
        return list
            .map((e) => RepairReceiveDetModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
    return result ?? [];
  }

  // ── UPDATE ────────────────────────────────────────────────────────────────
  Future<bool> update(Map<String, dynamic> values, theme,
  context,) async {
    final result = await request<RepairReceiveMstModel>(
      call: () => api.put('/repairRec', data: values),
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

  Future<bool> delete(id, theme, context, bCodeArray,newMstId) async {
    final result = await request<bool>(
      call: () => api.delete(
        '/repairRec/all/$id/$newMstId',

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
      newMstId,
    theme,
    context,
  ) async {
    final result = await request<bool>(
      call: () => api.delete(
        '/repairRec/$factoryIssMstID/$bCode/$newMstId',

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

  RepairReceiveMstModel _parseMstResponse(dynamic data) {
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
      return RepairReceiveMstModel.fromJson(mstJson);
    }
    throw Exception('Unexpected response format');
  }
}
