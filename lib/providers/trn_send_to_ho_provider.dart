import 'dart:convert';
import 'dart:typed_data';
import 'package:erp_data_table/erp_data_table.dart';
import 'package:intl/intl.dart';
import 'package:rs_dashboard/base/base_provider.dart';
import '../utils/ReportRegistry.dart';

class TrnSendToHoProvider extends BaseProvider {
  List<Map<String, dynamic>> _tableData = [];
  List<Map<String, dynamic>> _searchMstList = [];
  Uint8List? _pdfBytes;
  Map<String, dynamic> _jsonResponse = {};
  bool _isLoading = false;
  String? _error;
  String? _lastMessage;
  String? _selectedType;
  List<ErpColumnConfig> _columns = [];

  List<Map<String, dynamic>> get tableData => _tableData;
  List<Map<String, dynamic>> get searchMstList => _searchMstList;
  Uint8List? get pdfBytes => _pdfBytes;
  Map<String, dynamic> get jsonResponse => _jsonResponse;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get lastMessage => _lastMessage;
  String? get selectedType => _selectedType;
  List<ErpColumnConfig> get columns => _columns;

  List<ErpColumnConfig> get searchMstColumns => [
    ErpColumnConfig(key: 'mstId', label: 'JNO', width: 90),
    ErpColumnConfig(key: 'date', label: 'DATE', width: 110),
    ErpColumnConfig(key: 'type', label: 'TYPE', width: 110),
    ErpColumnConfig(key: 'companyName', label: 'HO PARTY', width: 160),
    ErpColumnConfig(key: 'articalName', label: 'ARTICLE', width: 140),
    ErpColumnConfig(key: 'certificate', label: 'CERTIFICATE', width: 130),
    ErpColumnConfig(key: 'fromSafeDisplay', label: 'FROM SAFE', width: 120),
    ErpColumnConfig(key: 'toSafeDisplay', label: 'TO SAFE', width: 120),
    ErpColumnConfig(key: 'narration', label: 'NARRATION', width: 180),
    ErpColumnConfig(key: 'totalPkt', label: 'TOT PKT', width: 90),
    ErpColumnConfig(key: 'totalWt', label: 'TOT WT', width: 100),
  ];

  void setSelectedType(String? type) {
    _selectedType = type;
    notifyListeners();
  }

  void clear() {
    _tableData = [];
    _searchMstList = [];
    _pdfBytes = null;
    _jsonResponse = {};
    _error = null;
    _lastMessage = null;
    _isLoading = false;
    _selectedType = null;
    notifyListeners();
  }

  void removeRow(Map<String, dynamic> row) {
    final rowId = row['DetID'] ?? row['detId'] ?? row['PktNo'] ?? row['pktNo'] ?? row['BCode'] ?? row['bCode'];
    _tableData.removeWhere((e) {
      if (identical(e, row)) return true;
      final eId = e['DetID'] ?? e['detId'] ?? e['PktNo'] ?? e['pktNo'] ?? e['BCode'] ?? e['bCode'];
      if (rowId != null && eId != null && rowId.toString().isNotEmpty && eId.toString().isNotEmpty) {
        return rowId.toString() == eId.toString();
      }
      return e == row;
    });
    notifyListeners();
  }

  Future<bool> updateSendToHoStatus({
    required int detId,
    String sendToHo = "N",
  }) async {
    _error = null;

    try {
      final payload = {
        "DetID": detId,
        "sendToHo": sendToHo,
      };

      final result = await request<bool>(
        showLoader: false,
        call: () => api.put('/factoryRec/send-to-ho/status', data: payload),
        onSuccess: (res) {
          final data = res.data;
          if (data is Map && data['success'] == false) {
            _error = data['message']?.toString() ?? 'Failed to update status';
            return false;
          }
          if (data is Map && data['message'] != null) {
            _lastMessage = data['message'].toString();
          }
          return true;
        },
      );

      return result == true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> loadSearchMstRecords({
    Map<String, dynamic>? filter,
    bool showLoader = true,
  }) async {
    _error = null;

    try {
      final result = await request<List<Map<String, dynamic>>>(
        showLoader: false,
        call: () => api.get(
          '/factoryRec/send-to-ho',
          query: filter != null ? _normalizeQueryParams(filter) : null,
        ),
        onSuccess: (res) {
          final data = res.data;
          List rawList = [];
          if (data is Map && data['data'] is List) {
            rawList = data['data'] as List;
          } else if (data is List) {
            rawList = data;
          }
          return rawList.whereType<Map>().map((e) {
            final m = Map<String, dynamic>.from(e);

            final sendToHoMstId = m['SendToHoMstID'] ?? m['sendToHoMstID'] ?? m['MstID'] ?? m['mstId'] ?? m['Id'] ?? m['id'] ?? '';
            final factoryRecMstId = m['FactoryRecMstID'] ?? m['factoryRecMstID'] ?? '';

            String rawDate = (m['Date'] ?? m['SendToHoDate'] ?? m['date'] ?? '').toString();
            String formattedDate = rawDate;
            if (rawDate.isNotEmpty && rawDate.contains('T')) {
              formattedDate = rawDate.split('T').first;
            }

            final artCode = m['ArticalCode'] ?? m['articalCode'] ?? '';
            final artName = m['ArticalName'] ?? m['articalName'] ?? m['ArticleName'] ?? '';
            final compCode = m['CompanyCode'] ?? m['companyCode'] ?? '';
            final compName = m['CompanyName'] ?? m['companyName'] ?? m['HOParty'] ?? m['hoParty'] ?? '';
            final cert = m['Certificate'] ?? m['certificate'] ?? '';
            final rawFromSafe = (m['FromSafe'] ?? m['fromSafe'] ?? '').toString();
            final rawToSafe = (m['ToSafe'] ?? m['toSafe'] ?? '').toString();
            final fromSafeDisplay = (rawFromSafe == '1') ? 'MAIN' : rawFromSafe;
            final toSafeDisplay = (rawToSafe == '1') ? 'MAIN' : rawToSafe;
            final narration = m['Narration'] ?? m['narration'] ?? m['Naration'] ?? '';
            final totalPkt = m['TotalPkt'] ?? m['totalPkt'] ?? m['TotPkt'] ?? m['totPkt'] ?? (m['det'] is List ? (m['det'] as List).length : (m['details'] is List ? (m['details'] as List).length : ''));
            final totalWt = m['TotalWt'] ?? m['totalWt'] ?? m['TotWt'] ?? m['totWt'] ?? '';
            final rawType = (m['Type'] ?? m['type'] ?? '').toString().trim();
            String type = rawType;
            if (rawType.toUpperCase() == 'PAIR_DATA' || rawType.toLowerCase() == 'pair data') {
              type = 'Pair Data';
            } else if (rawType.toUpperCase() == 'LAYOUT' || rawType.toLowerCase() == 'layout') {
              type = 'Layout';
            }

            return {
              'mstId': sendToHoMstId,
              'MstID': sendToHoMstId,
              'SendToHoMstID': sendToHoMstId,
              'sendToHoMstID': sendToHoMstId,
              'FactoryRecMstID': factoryRecMstId,
              'factoryRecMstID': factoryRecMstId,
              'date': formattedDate,
              'Date': formattedDate,
              'SendToHoDate': formattedDate,
              'rawDate': rawDate,
              'type': type,
              'Type': type,
              'articalCode': artCode,
              'ArticalCode': artCode,
              'articalName': artName,
              'ArticalName': artName,
              'companyCode': compCode,
              'CompanyCode': compCode,
              'companyName': compName,
              'CompanyName': compName,
              'hoParty': compName,
              'HOParty': compName,
              'certificate': cert,
              'Certificate': cert,
              'certificateCode': cert,
              'fromSafe': rawFromSafe,
              'FromSafe': rawFromSafe,
              'fromSafeDisplay': fromSafeDisplay,
              'toSafe': rawToSafe,
              'ToSafe': rawToSafe,
              'toSafeDisplay': toSafeDisplay,
              'narration': narration,
              'Narration': narration,
              'naration': narration,
              'Naration': narration,
              'totalPkt': totalPkt,
              'TotalPkt': totalPkt,
              'totPkt': totalPkt,
              'TotPkt': totalPkt,
              'totalWt': totalWt,
              'TotalWt': totalWt,
              'totWt': totalWt,
              'TotWt': totalWt,
              '_raw': m,
            };
          }).toList();
        },
      );

      _searchMstList = result ?? [];
      return _searchMstList;
    } catch (e) {
      _error = e.toString();
      return [];
    } finally {
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> loadMstDetails(
    int mstId, {
    String? type,
    bool showLoader = true,
    bool notify = true,
  }) async {
    _error = null;
    if (showLoader) {
      _isLoading = true;
      if (notify) notifyListeners();
    }

    try {
      final result = await request<List<Map<String, dynamic>>>(
        showLoader: false,
        call: () => api.get('/factoryRec/send-to-ho/$mstId'),
        onSuccess: (res) {
          final data = res.data;
          List rawList = [];
          if (data is Map) {
            _jsonResponse = Map<String, dynamic>.from(data);
            if (data['data'] is List) {
              rawList = data['data'] as List;
            } else if (data['data'] is Map) {
              final inner = data['data'] as Map;
              if (inner['det'] is List) {
                rawList = inner['det'] as List;
              } else if (inner['details'] is List) {
                rawList = inner['details'] as List;
              } else if (inner['data'] is List) {
                rawList = inner['data'] as List;
              }
            } else if (data['det'] is List) {
              rawList = data['det'] as List;
            } else if (data['details'] is List) {
              rawList = data['details'] as List;
            }
          } else if (data is List) {
            rawList = data;
          }
          return rawList
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        },
      );

      final rawList = result ?? [];
      final resolvedType = (type ?? _selectedType ?? '').trim();
      final configKey = (resolvedType.toUpperCase() == 'LAYOUT')
          ? 'FACTORY_REC_SELL_PRICE'
          : 'PAIR_DATA';
      final config = ReportRegistry.of(configKey);
      if (config != null) {
        _columns = config.columns.map((c) => c.toErpColumn()).toList();
        _tableData = config.mapper(rawList);
      } else {
        _tableData = rawList;
      }
      _selectedType = (resolvedType.toUpperCase() == 'LAYOUT') ? 'Layout' : 'Pair Data';

      if (!_columns.any((c) => c.key.toLowerCase() == 'jno')) {
        _columns.insert(
          1,
          ErpColumnConfig(key: 'Jno', label: 'JNO', width: 110),
        );
      }
      if (!_columns.any((c) => c.key.toLowerCase() == 'articalname')) {
        _columns.add(
          ErpColumnConfig(key: 'ArticalName', label: 'ARTICAL NAME', width: 160),
        );
      }

      final mstArtName = _jsonResponse['ArticalName'] ??
          _jsonResponse['articalName'] ??
          _jsonResponse['data']?['ArticalName'] ??
          _jsonResponse['data']?['articalName'];
      final mstJno = (mstId > 0)
          ? '$mstId'
          : (_jsonResponse['SendToHoMstID'] ??
                  _jsonResponse['FactoryRecMstID'] ??
                  _jsonResponse['Jno'] ??
                  _jsonResponse['MstID'])
              ?.toString();

      for (final row in _tableData) {
        if (mstArtName != null && mstArtName.toString().isNotEmpty && mstArtName.toString() != '-') {
          if (row['ArticalName'] == null || row['ArticalName'] == '-' || row['ArticalName'] == '') {
            row['ArticalName'] = mstArtName.toString();
            row['articalName'] = mstArtName.toString();
          }
        }
        if (mstJno != null && mstJno.isNotEmpty && mstJno != '0') {
          if (row['Jno'] == null || row['Jno'] == '-' || row['Jno'] == '' || row['Jno'] == '0') {
            row['Jno'] = mstJno;
            row['jno'] = mstJno;
          }
        }
      }

      return _tableData;
    } catch (e) {
      _error = e.toString();
      return [];
    } finally {
      if (showLoader) {
        _isLoading = false;
      }
      if (notify) {
        notifyListeners();
      }
    }
  }

  Future<List<Map<String, dynamic>>> loadPairData({
    Map<String, dynamic>? filter,
    bool showLoader = false,
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
    if (!_columns.any((c) => c.key.toLowerCase() == 'jno')) {
      _columns.insert(
        1,
        ErpColumnConfig(key: 'Jno', label: 'JNO', width: 110),
      );
    }
    if (!_columns.any((c) => c.key.toLowerCase() == 'articalname')) {
      _columns.add(
        ErpColumnConfig(key: 'ArticalName', label: 'ARTICAL NAME', width: 160),
      );
    }
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
        showLoader: showLoader,
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
    bool showLoader = false,
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
    if (!_columns.any((c) => c.key.toLowerCase() == 'jno')) {
      _columns.insert(
        1,
        ErpColumnConfig(key: 'Jno', label: 'JNO', width: 110),
      );
    }
    if (!_columns.any((c) => c.key.toLowerCase() == 'articalname')) {
      _columns.add(
        ErpColumnConfig(key: 'ArticalName', label: 'ARTICAL NAME', width: 160),
      );
    }
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
        showLoader: showLoader,
        call: () => api.get(
          config.endpoint,
          query: _normalizeQueryParams(queryParams),
        ),
        onSuccess: (res) {
          final data = res.data;
          if (data is Map) {
            _jsonResponse = Map<String, dynamic>.from(data);
            final listData = data['data'];
            if (listData is List) {
              return listData
                  .whereType<Map>()
                  .map((e) => Map<String, dynamic>.from(e))
                  .toList();
            }
          } else if (data is List) {
            return data
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

    final int detId = toInt(raw['DetID'] ?? raw['detID'] ?? raw['FactoryRecDetID'] ?? raw['factoryRecDetID'] ?? row['DetID'] ?? row['Id']);
    final int mstId = toInt(raw['MstID'] ?? raw['mstID'] ?? raw['FactoryRecMstID'] ?? raw['factoryRecMstID'] ?? row['MstID'] ?? raw['Jno'] ?? raw['jno'] ?? row['Jno']);
    final int sendToHoDetId = toInt(raw['SendToHoDetID'] ?? raw['sendToHoDetID'] ?? row['SendToHoDetID'] ?? row['sendToHoDetID']);

    return {
      if (sendToHoDetId > 0) "SendToHoDetID": sendToHoDetId,
      "DetID": detId,
      "FactoryRecDetID": detId,
      "MstID": mstId,
      "FactoryRecMstID": mstId,
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
      "layoutname": toNullableString(raw['layoutname'] ?? raw['LayoutName'] ?? row['layoutname'] ?? row['LayoutName']),
      "LayoutName": toNullableString(raw['LayoutName'] ?? raw['layoutname'] ?? row['LayoutName'] ?? row['layoutname']),
      "sendToHo": sendToHo,
    };
  }

  Future<bool> sendToHo({
    required List<Map<String, dynamic>> selectedRows,
    Map<String, dynamic>? mstData,
  }) async {
    if (selectedRows.isEmpty) return false;

    _isLoading = true;
    _error = null;
    _lastMessage = null;
    notifyListeners();

    final List<Map<String, dynamic>> details = [];
    int factoryRecMstId = 0;

    for (final row in selectedRows) {
      final formatted = formatRowForSendToHo(row);
      int mstId = formatted['MstID'] as int? ?? 0;
      if (mstId == 0) {
        final raw = (row['raw'] is Map ? Map<String, dynamic>.from(row['raw'] as Map) : null) ?? row;
        mstId = int.tryParse('${raw['FactoryRecMstID'] ?? raw['factoryRecMstID'] ?? raw['MstID'] ?? raw['mstID'] ?? 0}') ?? 0;
        formatted['MstID'] = mstId;
        formatted['FactoryRecMstID'] = mstId;
      }
      if (factoryRecMstId == 0 && mstId != 0) {
        factoryRecMstId = mstId;
      }
      if (formatted['ArticalCode'] == 0 && mstData?['ArticalCode'] != null) {
        formatted['ArticalCode'] = mstData!['ArticalCode'];
      }
      if ((formatted['ArticalName'] == null || '${formatted['ArticalName']}'.isEmpty || '${formatted['ArticalName']}' == '-') &&
          mstData?['ArticalName'] != null) {
        formatted['ArticalName'] = mstData!['ArticalName'];
      }
      details.add(formatted);
    }

    if (factoryRecMstId == 0 && _jsonResponse['FactoryRecMstID'] != null) {
      factoryRecMstId = int.tryParse('${_jsonResponse['FactoryRecMstID']}') ?? 0;
    }
    if (factoryRecMstId == 0 && _jsonResponse['MstID'] != null) {
      factoryRecMstId = int.tryParse('${_jsonResponse['MstID']}') ?? 0;
    }

    try {
      final payload = {
        "sendToHo": "Y",
        "details": details,
        if (mstData != null) ...mstData,
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

      return result == true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateSendToHo({
    required int sendToHoMstId,
    required List<Map<String, dynamic>> selectedRows,
    Map<String, dynamic>? mstData,
  }) async {
    if (sendToHoMstId <= 0) return false;

    _isLoading = true;
    _error = null;
    _lastMessage = null;
    notifyListeners();

    final List<Map<String, dynamic>> details = [];
    int factoryRecMstId = 0;

    for (final row in selectedRows) {
      final formatted = formatRowForSendToHo(row);
      int mstId = formatted['MstID'] as int? ?? 0;
      if (mstId == 0) {
        final raw = (row['raw'] is Map ? Map<String, dynamic>.from(row['raw'] as Map) : null) ?? row;
        mstId = int.tryParse('${raw['FactoryRecMstID'] ?? raw['factoryRecMstID'] ?? raw['MstID'] ?? raw['mstID'] ?? 0}') ?? 0;
        formatted['MstID'] = mstId;
        formatted['FactoryRecMstID'] = mstId;
      }
      if (factoryRecMstId == 0 && mstId != 0) {
        factoryRecMstId = mstId;
      }
      if (formatted['ArticalCode'] == 0 && mstData?['ArticalCode'] != null) {
        formatted['ArticalCode'] = mstData!['ArticalCode'];
      }
      if ((formatted['ArticalName'] == null || '${formatted['ArticalName']}'.isEmpty || '${formatted['ArticalName']}' == '-') &&
          mstData?['ArticalName'] != null) {
        formatted['ArticalName'] = mstData!['ArticalName'];
      }
      details.add(formatted);
    }

    if (factoryRecMstId == 0 && _jsonResponse['FactoryRecMstID'] != null) {
      factoryRecMstId = int.tryParse('${_jsonResponse['FactoryRecMstID']}') ?? 0;
    }
    if (factoryRecMstId == 0 && _jsonResponse['MstID'] != null) {
      factoryRecMstId = int.tryParse('${_jsonResponse['MstID']}') ?? 0;
    }

    try {
      final payload = {
        "SendToHoMstID": sendToHoMstId,
        "sendToHo": "Y",
        "Sflag": "I",
        "Ever": 1,
        "details": details,
        if (mstData != null) ...mstData,
      };

      final result = await request<bool>(
        showLoader: true,
        call: () => api.put('/factoryRec/send-to-ho/$sendToHoMstId', data: payload),
        onSuccess: (res) {
          final data = res.data;
          if (data is Map) {
            if (data['success'] == false) {
              _error = data['message']?.toString() ?? 'Failed to update Send to HO';
              return false;
            }
            _lastMessage = data['message']?.toString() ?? _lastMessage;
          }
          return true;
        },
      );

      return result == true;
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
