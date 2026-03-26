// lib/providers/packet_provider.dart

import 'package:rs_dashboard/rs_dashboard.dart';
import '../models/packet_model.dart';

class PacketProvider extends BaseProvider {
  List<PacketMstModel> _list     = [];
  bool                 _isLoaded = false;

  bool                       get isLoaded  => _isLoaded;
  List<PacketMstModel>       get list      => List.unmodifiable(_list);
  List<Map<String, dynamic>> get tableData =>
      _list.map((e) => e.toTableRow()).toList();

  // ── LOAD ALL ──────────────────────────────────────────────────────────────
  Future<void> load() async {
    final result = await request<List<PacketMstModel>>(
      call: () => api.get('/packetCreate'),
      onSuccess: (res) {
        final list = res.data as List;
        return list
            .map((e) => PacketMstModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
    if (result != null) {
      _list     = result;
      _isLoaded = true;
      notifyListeners();
    }
  }
// PacketProvider mein method add karo:
  Future<int> getNextLotNo(String cutNo) async {
    final result = await request<int>(
      showLoader: false,
      call: () => api.get('/packetCreate/next-lot-no/$cutNo'),
      onSuccess: (res) => (res.data as num).toInt(),
    );
    return result ?? 1;
  }
  // ── CREATE ────────────────────────────────────────────────────────────────
  // API returns { mst: {}, det: [] }
  Future<bool> create(
      Map<String, dynamic>  values,
      List<PacketDetModel>  details,
      ) async {
    final model  = _buildModel(values);
    final result = await request<PacketMstModel>(
      call: () => api.post('/packetCreate', data: {
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
      int                   id,
      Map<String, dynamic>  values,
      List<PacketDetModel>  details,
      ) async {
    final model  = _buildModel(values);
    final result = await request<PacketMstModel>(
      call: () => api.put('/packetCreate/$id', data: {
        ...model.toJson(),
        'details': details.map((e) => e.toJson()).toList(),
      }),
      onSuccess: (res) => _parseMstResponse(res.data),
    );
    if (result != null) {
      final i = _list.indexWhere((e) => e.packetMstID == id);
      if (i != -1) _list[i] = result;
      notifyListeners();
      return true;
    }
    return false;
  }

  // ── DELETE ────────────────────────────────────────────────────────────────
  Future<bool> delete(int id) async {
    final result = await request<bool>(
      call: () => api.delete('/packetCreate/$id'),
      onSuccess: (_) => true,
    );
    if (result == true) {
      _list.removeWhere((e) => e.packetMstID == id);
      notifyListeners();
      return true;
    }
    return false;
  }

  // ── LOAD DETAILS ──────────────────────────────────────────────────────────
  // API: GET /packet/:id → { mst: {}, det: [] }
  Future<List<PacketDetModel>> loadDetails(int mstID) async {
    final result = await request<List<PacketDetModel>>(
      call: () => api.get('/packetCreate/$mstID'),
      onSuccess: (res) {
        final data   = res.data;
        final rawDet = (data is Map ? data['det'] : data) as List? ?? [];
        return rawDet
            .map((e) => PacketDetModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
    return result ?? [];
  }

  // ── PARSE { mst, det } response ───────────────────────────────────────────
  PacketMstModel _parseMstResponse(dynamic data) {
    if (data is Map) {
      if (data.containsKey('mst')) {
        final mst    = Map<String, dynamic>.from(data['mst'] as Map);
        final rawDet = data['det'] as List? ?? [];
        mst['details'] = rawDet; // raw maps for fromJson
        return PacketMstModel.fromJson(mst);
      }
      return PacketMstModel.fromJson(Map<String, dynamic>.from(data));
    }
    throw Exception('Unexpected response format');
  }

  // ── BUILD MODEL from form values ──────────────────────────────────────────
  PacketMstModel _buildModel(Map<String, dynamic> v) {
    int? toI(String? s) => s == null || s.isEmpty ? null : int.tryParse(s);

    return PacketMstModel(
      packetDate: v['packetDate'],
      cutNo:      v['cutNo'],
      clvCut:     v['clvCut'],
      sflag:      v['sflag'],
      sdate:      v['sdate'],
      logID:      toI(v['logID']),
      pcID:       v['pcID'],
      ever:       toI(v['ever']),
      packetRec:  v['packetRec'],
      entryType:  v['entryType'],
      slType:     v['slType'],
    );
  }
}