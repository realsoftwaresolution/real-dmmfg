import 'dart:convert';
import 'dart:typed_data';
import 'package:erp_data_table/erp_data_table.dart';
import 'package:intl/intl.dart';
import 'package:rs_dashboard/base/base_provider.dart';
import '../utils/ReportRegistry.dart';

class TrnSendToHoProvider extends BaseProvider {
  List<Map<String, dynamic>> _tableData = [];
  Uint8List? _pdfBytes;
  Map<String, dynamic> _jsonResponse = {};
  bool _isLoading = false;
  String? _error;
  String? _lastMessage;
  String? _selectedType;
  List<ErpColumnConfig> _columns = [];

  List<Map<String, dynamic>> get tableData => _tableData;
  Uint8List? get pdfBytes => _pdfBytes;
  Map<String, dynamic> get jsonResponse => _jsonResponse;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get lastMessage => _lastMessage;
  String? get selectedType => _selectedType;
  List<ErpColumnConfig> get columns => _columns;

  void setSelectedType(String? type) {
    _selectedType = type;
    notifyListeners();
  }

  void clear() {
    _tableData = [];
    _pdfBytes = null;
    _jsonResponse = {};
    _error = null;
    _lastMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> loadPairData({
    Map<String, dynamic>? filter,
  }) async {
    final config = ReportRegistry.of('PAIR_DATA');
    if (config == null) {
      _error = 'PAIR_DATA configuration not found in registry.';
      notifyListeners();
      return [];
    }

    _isLoading = true;
    _error = null;
    _pdfBytes = null;
    _jsonResponse = {};
    _columns = config.columns.map((c) => c.toErpColumn()).toList();
    _tableData = [];
    notifyListeners();

    try {
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final effectiveFilter = <String, dynamic>{
        'fromDate': todayStr,
        'toDate': todayStr,
        'sendToHo': 'N',
        ...?filter,
      };
      final queryParams = config.queryBuilder?.call(effectiveFilter) ?? effectiveFilter;
      final result = await request<List<Map<String, dynamic>>>(
        call: () => api.get(
          config.endpoint,
          query: _normalizeQueryParams(queryParams),
        ),
        onSuccess: (res) {
          final data = res.data;
          if (data == null || data['data'] == null) {
            return <Map<String, dynamic>>[];
          }
          return (data['data'] as List).cast<Map<String, dynamic>>();
        },
      );

      final rawList = result ?? [];
      _tableData = config.mapper(rawList);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return _tableData;
  }

  Future<List<Map<String, dynamic>>> loadLayoutData({
    Map<String, dynamic>? filter,
  }) async {
    final config = ReportRegistry.of('FACTORY_REC_SELL_PRICE');
    if (config == null) {
      _error = 'FACTORY_REC_SELL_PRICE configuration not found in registry.';
      notifyListeners();
      return [];
    }

    _isLoading = true;
    _error = null;
    _pdfBytes = null;
    _columns = config.columns.map((c) => c.toErpColumn()).toList();
    _tableData = [];
    _jsonResponse = {};
    notifyListeners();

    try {
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final effectiveFilter = <String, dynamic>{
        'fromDate': todayStr,
        'toDate': todayStr,
        'sendToHo': 'N',
        'format': 'both',
        ...?filter,
      };
      final queryParams =
          config.queryBuilder?.call(effectiveFilter) ?? effectiveFilter;
      final result = await request<List<Map<String, dynamic>>>(
        call: () => api.get(
          config.endpoint,
          query: _normalizeQueryParams(queryParams),
        ),
        onSuccess: (res) {
          final data = res.data;
          if (data is Map) {
            _jsonResponse = Map<String, dynamic>.from(data);
            final pdfBase64 = data['pdfBase64']?.toString();
            if (pdfBase64 != null && pdfBase64.isNotEmpty) {
              final cleanBase64 = pdfBase64.contains(',')
                  ? pdfBase64.split(',').last
                  : pdfBase64;
              try {
                _pdfBytes = Uint8List.fromList(base64Decode(cleanBase64.trim()));
              } catch (e) {
                print('Error decoding pdfBase64: $e');
              }
            }
          }
          if (data == null || (data is Map && data['data'] == null)) {
            return <Map<String, dynamic>>[];
          }
          final listData = data is Map ? data['data'] : null;
          if (listData is List) {
            return listData
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList();
          }
          return <Map<String, dynamic>>[];
        },
      );

      final rawList = result ?? [];
      _tableData = config.mapper(rawList);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return _tableData;
  }

  Map<String, dynamic> formatRowForSendToHo(Map<String, dynamic> row, {String sendToHo = 'Y'}) {
    final raw = (row['raw'] is Map ? Map<String, dynamic>.from(row['raw'] as Map) : null) ?? row;

    int toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      final str = v.toString().trim();
      return int.tryParse(str) ?? 0;
    }

    num toNum(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v;
      final str = v.toString().trim();
      return num.tryParse(str) ?? 0;
    }

    String? toNullableString(dynamic v) {
      if (v == null) return null;
      final s = v.toString().trim();
      if (s.isEmpty || s == '-' || s == '--' || s.toLowerCase() == 'null') {
        return null;
      }
      return s;
    }

    String toNonEmptyString(dynamic v, [String fallback = '']) {
      if (v == null) return fallback;
      final s = v.toString().trim();
      if (s == '-' || s == '--' || s.toLowerCase() == 'null') return fallback;
      return s;
    }

    List toList(dynamic v) {
      if (v == null) return [];
      if (v is List) return v;
      if (v is String) {
        final s = v.trim();
        if (s.isEmpty || s == '[]' || s == '-' || s == '--') return [];
        if (s.startsWith('[') && s.endsWith(']')) {
          try {
            final decoded = jsonDecode(s);
            if (decoded is List) return decoded;
          } catch (_) {}
        }
        return s.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }
      return [v];
    }

    return {
      "DetID": toInt(raw['DetID'] ?? raw['detID'] ?? row['DetID'] ?? row['Id']),
      "MstID": toInt(raw['MstID'] ?? raw['mstID'] ?? row['MstID']),
      "BCode": toInt(raw['BCode'] ?? raw['bCode'] ?? row['BCode']),
      "PktNo": toNonEmptyString(raw['PktNo'] ?? raw['pktNo'] ?? row['PktNo'] ?? row['packetNo']),
      "CutNo": toNonEmptyString(raw['CutNo'] ?? raw['cutNo'] ?? row['CutNo']),
      "Wt": toNum(raw['Wt'] ?? raw['wt'] ?? row['Wt'] ?? row['weight']),
      "IssWt": toNum(raw['IssWt'] ?? raw['issWt'] ?? row['IssWt']),
      "RecWt": toNum(raw['RecWt'] ?? raw['recWt'] ?? row['RecWt']),
      "ColorCode": toInt(raw['ColorCode'] ?? raw['colorCode'] ?? row['ColorCode']),
      "Color": toNonEmptyString(raw['Color'] ?? raw['color'] ?? row['Color']),
      "PurityCode": toInt(raw['PurityCode'] ?? raw['purityCode'] ?? row['PurityCode']),
      "Clarity": toNonEmptyString(raw['Clarity'] ?? raw['clarity'] ?? raw['purity'] ?? row['Clarity']),
      "CutCode": toInt(raw['CutCode'] ?? raw['cutCode'] ?? row['CutCode']),
      "Cut": toNullableString(raw['Cut'] ?? raw['cut'] ?? row['Cut']),
      "PolishCode": toInt(raw['PolishCode'] ?? raw['polishCode'] ?? row['PolishCode']),
      "Polish": toNullableString(raw['Polish'] ?? raw['polish'] ?? row['Polish']),
      "SymmetryCode": toInt(raw['SymmetryCode'] ?? raw['symmetryCode'] ?? row['SymmetryCode']),
      "Symmetry": toNullableString(raw['Symmetry'] ?? raw['symmetry'] ?? row['Symmetry']),
      "FluoCode": toInt(raw['FluoCode'] ?? raw['fluoCode'] ?? row['FluoCode']),
      "Flou": toNonEmptyString(raw['Flou'] ?? raw['flou'] ?? raw['florence'] ?? row['Flou']),
      "SellPrice": toNum(raw['SellPrice'] ?? raw['sellPrice'] ?? row['SellPrice']),
      "SellAmount": toNum(raw['SellAmount'] ?? raw['sellAmount'] ?? raw['totalPrice'] ?? row['SellAmount']),
      "Length": toNum(raw['Length'] ?? raw['length'] ?? row['Length']),
      "Dia": toNum(raw['Dia'] ?? raw['dia'] ?? row['Dia']),
      "Height": toNum(raw['Height'] ?? raw['height'] ?? row['Height']),
      "TopSide": toNullableString(raw['TopSide'] ?? raw['topSide'] ?? raw['topsSide'] ?? row['TopSide']),
      "GroupType": toNonEmptyString(raw['GroupType'] ?? raw['groupType'] ?? raw['category'] ?? row['GroupType'], 'Pair'),
      "Certificate": toNullableString(raw['Certificate'] ?? raw['certificate'] ?? row['Certificate']),
      "CertiNo": toNullableString(raw['CertiNo'] ?? raw['certiNo'] ?? row['certificateNo'] ?? row['CertiNo']),
      "PairNo": toNullableString(raw['PairNo'] ?? raw['pairNo'] ?? row['PairNo']),
      "ShapeCode": toInt(raw['ShapeCode'] ?? raw['shapeCode'] ?? row['ShapeCode']),
      "Shape": toNonEmptyString(raw['Shape'] ?? raw['shape'] ?? row['Shape']),
      "KapanNo": toNonEmptyString(raw['KapanNo'] ?? raw['kapanNo'] ?? row['KapanNo']),
      "ArticalCode": toInt(raw['ArticalCode'] ?? raw['articalCode'] ?? row['ArticalCode']),
      "ArticalName": toNonEmptyString(raw['ArticalName'] ?? raw['articalName'] ?? row['ArticalName']),
      "images": toList(raw['images'] ?? raw['Images'] ?? row['images']),
      "videos": toList(raw['videos'] ?? raw['Videos'] ?? row['videos']),
      "certificates": toList(raw['certificates'] ?? raw['Certificates'] ?? row['certificates']),
      "sendToHo": sendToHo,
    };
  }

  Future<bool> sendToHo({
    required List<Map<String, dynamic>> selectedRows,
  }) async {
    if (selectedRows.isEmpty) return false;

    _isLoading = true;
    _error = null;
    _lastMessage = null;
    notifyListeners();

    final groupedRows = <int, List<Map<String, dynamic>>>{};
    for (final row in selectedRows) {
      final formatted = formatRowForSendToHo(row);
      int mstId = formatted['MstID'] as int? ?? 0;
      if (mstId == 0) {
        final raw = (row['raw'] is Map ? Map<String, dynamic>.from(row['raw'] as Map) : null) ?? row;
        mstId = int.tryParse('${raw['FactoryRecMstID'] ?? raw['factoryRecMstID'] ?? raw['MstID'] ?? raw['mstID'] ?? row['FactoryRecMstID'] ?? 0}') ?? 0;
        formatted['MstID'] = mstId;
      }
      groupedRows.putIfAbsent(mstId, () => []).add(formatted);
    }

    try {
      bool allSuccess = true;
      for (final entry in groupedRows.entries) {
        final payload = {
          "sendToHo": "Y",
          "FactoryRecMstID": entry.key,
          "details": entry.value,
        };

        final result = await request<bool>(
          showLoader: true,
          call: () => api.post('/factoryRec/send-to-ho', data: payload),
          onSuccess: (res) {
            final data = res.data;
            if (data is Map) {
              if (data['success'] == false) {
                _error = data['message']?.toString() ?? 'Failed to send to HO';
                return false;
              }
              _lastMessage = data['message']?.toString() ?? _lastMessage;
            }
            return true;
          },
        );

        if (result != true) {
          allSuccess = false;
          break;
        }
      }
      return allSuccess;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Map<String, dynamic> _normalizeQueryParams(Map<String, dynamic> filter) {
    final params = <String, dynamic>{};
    filter.forEach((key, value) {
      if (value == null) return;
      if (value is List) {
        if (value.isNotEmpty) {
          params[key] = value.join(',');
        }
      } else {
        params[key] = value;
      }
    });
    return params;
  }
}
