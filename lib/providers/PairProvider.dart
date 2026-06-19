import 'package:erp_data_table/erp_data_table/models/erp_column.dart';
import 'package:rs_dashboard/base/base_provider.dart';

class PairProvider extends BaseProvider {
  // ── STATE ─────────────────────────────────────────────
  List<Map<String, dynamic>> _tableData = [];
  List<Map<String, dynamic>> _tableSearchListData = [];

  bool _isLoaded = false;
  bool _isLoading = false;

  String? _error;
  String? _activeReportCode;

  // ── GETTERS ───────────────────────────────────────────
  List<Map<String, dynamic>> get tableData => _tableData;

  List<Map<String, dynamic>> get tableSearchListData => _tableSearchListData;

  bool get isLoaded => _isLoaded;

  bool get isLoading => _isLoading;

  String? get error => _error;

  String? get activeReportCode => _activeReportCode;

  // ── COLUMNS ───────────────────────────────────────────
  final List<ErpColumnConfig> columns = [
    ErpColumnConfig(key: 'bCode', label: 'BCode'),

    ErpColumnConfig(key: 'cutNo', label: 'Cut No'),

    ErpColumnConfig(key: 'lotNo', label: 'Lot No'),

    ErpColumnConfig(key: 'shapeName', label: 'Shape', width: 140),

    ErpColumnConfig(key: 'cutName', label: 'Cut', width: 140),

    ErpColumnConfig(key: 'colorName', label: 'Color', width: 140),

    ErpColumnConfig(key: 'purityName', label: 'Purity', width: 140),

    ErpColumnConfig(key: 'diam', label: 'Diam'),

    ErpColumnConfig(key: 'length', label: 'Length'),

    ErpColumnConfig(key: 'height', label: 'Height'),

    ErpColumnConfig(key: 'deptName', label: 'Department', width: 180),

    ErpColumnConfig(key: 'deptProcessName', label: 'Dept Process', width: 180),

    ErpColumnConfig(key: 'wt', label: 'Wt'),

    ErpColumnConfig(key: 'factoryName', label: 'Factory', width: 140),

    ErpColumnConfig(key: 'manager', label: 'Manager', width: 180),
  ];

  // ── NUMBER FORMATTER ─────────────────────────────────
  String _f(dynamic value, int digit) {
    final numVal = num.tryParse(value?.toString() ?? '');

    return numVal?.toStringAsFixed(digit) ?? (digit == 3 ? '0.000' : '0.00');
  }

  // ── MAPPER ────────────────────────────────────────────
  List<Map<String, dynamic>> mapRows(List<Map<String, dynamic>> raw) {
    return raw
        .map((e) {
          return {
            'bCode': e['BCode'] ?? '',
            'PairMstID': e['PairMstID'] ?? '',
            'PairName': e['PairName'] ?? '',

            'cutNo': e['CutNo'] ?? '',

            'lotNo': e['LotNo'] ?? '',

            'shapeName': e['ShapeName'] ?? '',

            'cutName': e['CutName'] ?? '',

            'colorName': e['ColorName'] ?? '',

            'purityName': e['PurityName'] ?? '',

            'diam': _f(e['Diam'], 2),

            'length': _f(e['Length'], 2),

            'height': _f(e['Height'], 2),

            'deptName': e['DeptName'] ?? '-',

            'deptProcessName': e['DeptProcessName'] ?? '-',

            'wt': _f(e['Wt'], 3),

            'factoryName': e['FactoryName'] ?? '-',

            'manager': e['Manager'] ?? '-',

            // OPTIONAL EXTRA
            'shapeCode': e['ShapeCode'] ?? 0,

            'cutCode': e['CutCode'] ?? 0,

            'colorCode': e['ColorCode'] ?? 0,

            'purityCode': e['PurityCode'] ?? 0,

            'deptCode': e['DeptCode'] ?? 0,

            'deptProcessCode': e['DeptProcessCode'] ?? 0,

            'crID': e['CrID'] ?? 0,
          };
        })
        .toList(growable: false);
  }

  // ── LOAD DATA ────────────────────────────────────────
  Future<List<Map<String, dynamic>>> loadPairData({
    required Map<String, dynamic> filter,
    int? pairMstId,

  }) async {
    if (_isLoading) return _tableData;

    _isLoading = true;
    _error = null;

    try {
      final result = await request<List<Map<String, dynamic>>>(
        showLoader: false,

        call: () => api.post('/pair/list', data: filter),

        onSuccess: (res) {
          final data = res.data;

          if (data == null || data['data'] == null) {
            return <Map<String, dynamic>>[];
          }

          return (data['data'] as List).cast<Map<String, dynamic>>();
        },
      );

      final rawList = result ?? [];

      final filteredList = rawList.where((e) {
        final currentPairId =
            int.tryParse(
              e['PairMstID']?.toString() ?? '0',
            ) ??
                0;

        // ALWAYS SHOW UNPAIRED
        if (currentPairId == 0) {
          return true;
        }

        // ALSO SHOW SELECTED PAIR
        if (pairMstId != null &&
            currentPairId == pairMstId) {
          return true;
        }

        return false;
      }).toList();

      _tableData = mapRows(filteredList);

      _isLoaded = true;

      return _tableData;
    } catch (e) {
      _error = e.toString();

      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── LOAD SEARCH LIST DATA ────────────────────────────────────────
  Future<List<Map<String, dynamic>>> loadSearchListData() async {
    if (_isLoading) return _tableSearchListData;

    _isLoading = true;
    _error = null;

    try {
      final result = await request<List<Map<String, dynamic>>>(
        showLoader: false,

        call: () => api.get('/pair/saved-list'),

        onSuccess: (res) {
          final data = res.data;

          if (data == null || data['data'] == null) {
            return <Map<String, dynamic>>[];
          }

          return (data['data'] as List).cast<Map<String, dynamic>>();
        },
      );

      final rawList = result ?? [];

      _tableSearchListData = mapRows(rawList);

      _isLoaded = true;

      return _tableSearchListData;
    } catch (e) {
      _error = e.toString();

      return [];
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // ── SAVE PAIR ────────────────────────────────────────
  Future<bool> savePair({
    required String pairName,
    required List<int> bCodes,
  }) async {
    if (_isLoading) return false;

    _isLoading = true;
    _error = null;

    notifyListeners();

    try {
      final payload = {'pairName': pairName, 'bCodes': bCodes};

      final result = await request<bool>(
        showLoader: true,

        call: () => api.post('/pair/save', data: payload),

        onSuccess: (_) => true,
      );

      return result ?? false;
    } catch (e) {
      _error = e.toString();

      return false;
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // ── SAVE PAIR ────────────────────────────────────────
  Future<bool> updatePair({
    required String pairName,
    required int pairMstID,
    required List<int> bCodes,
  }) async {
    if (_isLoading) return false;

    _isLoading = true;
    _error = null;

    notifyListeners();

    try {
      final payload = {'pairName': pairName,'PairMstID': pairMstID, 'bCodes': bCodes};

      final result = await request<bool>(
        showLoader: true,

        call: () => api.put('/pair/update', data: payload),

        onSuccess: (_) => true,
      );

      return result ?? false;
    } catch (e) {
      _error = e.toString();

      return false;
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // ── CLEAR ────────────────────────────────────────────
  void clear() {
    _tableData = [];
    _isLoaded = false;
    _error = null;
    notifyListeners();
  }
}
