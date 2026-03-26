import 'package:rs_dashboard/rs_dashboard.dart';
import '../models/rough_model.dart';

class RoughProvider extends BaseProvider {
  List<RoughModel> _roughs = [];
  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;
  List<RoughModel> get roughs => _roughs;

  List<Map<String, dynamic>> get tableData =>
      _roughs.map((e) => e.toTableRow()).toList();
  final Map<int, int> _roughTotPc = {}; // roughMstID → totPc

  Future<void> loadRoughs() async {
    final result = await request<List<RoughModel>>(
      call: () => api.get('/rough'),
      onSuccess: (res) {
        final list = res.data as List;
        return list.map((e) => RoughModel.fromJson(e)).toList();
      },
    );
    if (result != null) {
      _roughs = result;
      _isLoaded = true;
      notifyListeners();
    }
  }
// ── GET NEXT JNO ─────────────────────────────────────────────────────────
  Future<int> getNextJno() async {
    final result = await request<int>(
      showLoader: false,
      call: () => api.get('/rough/next-jno'),
      onSuccess: (res) => (res.data as num).toInt(),
    );
    return result ?? 1;
  }

// ── KAPAN DUPLICATE CHECK ─────────────────────────────────────────────────
  bool isKapanDuplicate(String kapanNo, {int? excludeMstID}) {
    return roughs.any((cc) =>
    cc.kapanNo == kapanNo &&
        cc.roughMstID != excludeMstID
    );
  }
  Future<bool> createRough(
      Map<String, dynamic> values,
      List<RoughDetModel> details,
      List<RoughProcessDaysModel> processDays,
      ) async {
    final model = _buildModel(values);
    final result = await request<RoughModel>(
      call: () => api.post('/rough', data: {
        ...model.toJson(),
        'details': details.map((e) => e.toJson()).toList(),
        'processDays': processDays.map((e) => e.toJson()).toList(),
      }),
      onSuccess: (res) => RoughModel.fromJson(res.data),
    );
    if (result != null) {
      _roughs.insert(0, result);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> updateRough(
      int id,
      Map<String, dynamic> values,
      List<RoughDetModel> details,
      List<RoughProcessDaysModel> processDays,
      ) async {
    final model = _buildModel(values);
    final result = await request<RoughModel>(
      call: () => api.put('/rough/$id', data: {
        ...model.toJson(),
        'details': details.map((e) => e.toJson()).toList(),
        'processDays': processDays.map((e) => e.toJson()).toList(),
      }),
      onSuccess: (res) => RoughModel.fromJson(res.data),
    );
    if (result != null) {
      final i = _roughs.indexWhere((e) => e.roughMstID == id);
      if (i != -1) _roughs[i] = result;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> deleteRough(int id) async {
    final result = await request<bool>(
      call: () => api.delete('/rough/$id'),
      onSuccess: (_) => true,
    );
    if (result == true) {
      _roughs.removeWhere((e) => e.roughMstID == id);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<List<RoughDetModel>> loadDetails(int roughMstID) async {
    final result = await request<List<RoughDetModel>>(
      call: () => api.get('/roughDet/rough/$roughMstID'),
      onSuccess: (res) {
        final list = res.data as List;
        return list.map((e) => RoughDetModel.fromJson(e)).toList();
      },
    );
    if (result != null) {
      // ✅ totPc cache karo
      _roughTotPc[roughMstID] = result.fold(0, (s, r) => s + (r.pc ?? 0));
      notifyListeners();
    }
    return result ?? [];
  }
  int getTotPc(int? roughMstID) => _roughTotPc[roughMstID] ?? 0;

  Future<List<RoughProcessDaysModel>> loadProcessDays(int roughMstID) async {
    final result = await request<List<RoughProcessDaysModel>>(
      call: () => api.get('/roughEntryProcessDays/rough/$roughMstID'),
      onSuccess: (res) {
        final list = res.data as List;
        return list.map((e) => RoughProcessDaysModel.fromJson(e)).toList();
      },
    );
    return result ?? [];
  }

  RoughModel _buildModel(Map<String, dynamic> v) {
    double? toD(String? s) => s == null || s.isEmpty ? null : double.tryParse(s);
    int? toI(String? s) => s == null || s.isEmpty ? null : int.tryParse(s);

    return RoughModel(
      roughDate: v['roughDate'],
      jno: toI(v['jno']),
      kapanNo: v['kapanNo'],
      site: v['site'],
      partyCode: toI(v['partyCode']),
      roughTypeCode: toI(v['roughTypeCode']),
      articalCode: toI(v['articalCode']),
      jangadCharniCode: toI(v['jangadCharniCode']),
      rgExpPer: toD(v['rgExpPer']),
      poExpPer: toD(v['poExpPer']),
      rgSize: toD(v['rgSize']),
      poSize: toD(v['poSize']),
      lsPer: toD(v['lsPer']),
      mainCutNo: v['mainCutNo'],
      dueDay: toI(v['dueDay']),
      dueDate: v['dueDate'],
      remarks: v['remarks'],
      inv: v['inv'],
      exRate: toD(v['exRate']),
      rateDollar: toD(v['rateDollar']),
      amtDollar: toD(v['amtDollar']),
      rateRs: toD(v['rateRs']),
      amtRs: toD(v['amtRs']),
      totWt: toD(v['totWt']),

    );
  }
  List<Map<String, dynamic>> tableDataWithNames({
    required Map<String, String> partyNames,
    required Map<String, String> roughTypeNames,
    required Map<String, String> articleNames,
    required Map<String, String> jangadCharniNames,
  }) {
    return roughs.map((r) => {
      'roughMstID':       r.roughMstID,
      'roughDate':        r.roughDate        ?? '',
      'jno':              r.jno?.toString()  ?? '',
      'kapanNo':          r.kapanNo          ?? '',
      'site':             r.site             ?? '',
      'partyCode':        partyNames[r.partyCode?.toString()] ?? r.partyCode?.toString() ?? '',
      'roughTypeCode':    roughTypeNames[r.roughTypeCode?.toString()] ?? '',
      'articalCode':      articleNames[r.articalCode?.toString()] ?? '',
      'jangadCharniCode': jangadCharniNames[r.jangadCharniCode?.toString()] ?? '',
      'amtDollar':        r.amtDollar?.toStringAsFixed(2) ?? '',
      'amtRs':            r.amtRs?.toStringAsFixed(2)     ?? '',
      'totWt':            r.totWt?.toStringAsFixed(3)     ?? '',
      'totPc':            r.totPc.toString(),
      '_raw': r,
    }).toList();
  }
  // List<Map<String, dynamic>> tableDataWithNames({
  //   required Map<String, String> partyNames,
  //   required Map<String, String> roughTypeNames,
  //   required Map<String, String> articleNames,
  //   required Map<String, String> jangadCharniNames,
  // }) {
  //   return _roughs.map((e) {
  //
  //     final row = e.toTableRow();
  //
  //     return {
  //       ...row,
  //
  //       /// Replace codes with names
  //       'partyCode': partyNames[row['partyCode']] ?? row['partyCode'],
  //       'roughTypeCode': roughTypeNames[row['roughTypeCode']] ?? row['roughTypeCode'],
  //       'articalCode': articleNames[row['articalCode']] ?? row['articalCode'],
  //       'jangadCharniCode': jangadCharniNames[row['jangadCharniCode']] ?? row['jangadCharniCode'],
  //     };
  //
  //   }).toList();
  // }
}

extension RoughModelExt on RoughModel {
  Map<String, dynamic> toTableRow() => {
    // Main columns
    'roughMstID':       roughMstID,
    'roughDate':        roughDate                          ?? '',
    'jno':              jno?.toString()                    ?? '',
    'site':             site                               ?? '',
    'partyCode':        partyCode?.toString()              ?? '',
    'totWt':            totWt?.toStringAsFixed(2)          ?? '0.000',
    'amtDollar':        amtDollar?.toStringAsFixed(2)      ?? '0.00',
    'amtRs':            amtRs?.toStringAsFixed(2)          ?? '0.00',

    // Extra columns
    'kapanNo':          kapanNo                            ?? '',
    'inv':              inv                                ?? '',
    'roughTypeCode':    roughTypeCode?.toString()          ?? '',
    'articalCode':      articalCode?.toString()            ?? '',
    'jangadCharniCode': jangadCharniCode?.toString()       ?? '',
    'exRate':           exRate?.toStringAsFixed(2)         ?? '',
    'rateDollar':       rateDollar?.toStringAsFixed(2)     ?? '',
    'rateRs':           rateRs?.toStringAsFixed(2)         ?? '',
    'rgExpPer':         rgExpPer?.toStringAsFixed(2)       ?? '',
    'poExpPer':         poExpPer?.toStringAsFixed(2)       ?? '',
    'rgSize':           rgSize?.toStringAsFixed(2)         ?? '',
    'poSize':           poSize?.toStringAsFixed(2)         ?? '',
    'lsPer':            lsPer?.toStringAsFixed(2)          ?? '',
    'mainCutNo':        mainCutNo                          ?? '',
    'dueDay':           dueDay?.toString()                 ?? '',
    'dueDate':          dueDate                            ?? '',
    'remarks':          remarks                            ?? '',

    '_raw': this,
  };
}





























// extension RoughModelExt on RoughModel {
//   Map<String, dynamic> toTableRow() => {
//     'roughMstID': roughMstID,
//     'roughDate': roughDate ?? '',
//     'jno': jno?.toString() ?? '',
//     'site': site ?? '',
//     'partyCode': partyCode?.toString() ?? '',
//     'totWt': totWt?.toStringAsFixed(3) ?? '0.000',
//     'amtDollar': amtDollar?.toStringAsFixed(2) ?? '0.00',
//     'amtRs': amtRs?.toStringAsFixed(2) ?? '0.00',
//     '_raw': this,
//   };
// }