import 'dart:convert';
import 'dart:typed_data';
import 'package:diam_mfg/utils/ReportRegistry.dart';
import 'package:diam_mfg/utils/msg_dialogue.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:rs_dashboard/base/base_provider.dart';

import '../bootstrap.dart';
import 'package:rs_dashboard/rs_dashboard.dart';

import '../models/ReportConfig.dart';

class ReportProvider extends BaseProvider {
  List<Map<String, dynamic>> _tableData = [];
  Uint8List? _pdfBytes; // 🔥 ADD
  Map<String, dynamic> _jsonResponse = {}; // 👈 Stores the JSON response
  bool _isLoaded = false;
  bool _isLoading = false;
  String? _error;
  String? _activeReportCode;

  List<Map<String, dynamic>> get tableData => _tableData;

  Uint8List? get pdfBytes => _pdfBytes; // 🔥 ADD
  Map<String, dynamic> get jsonResponse => _jsonResponse;
  Map<String, dynamic> get responseMap => _jsonResponse;
  dynamic get rawData => _jsonResponse['data'];
  bool get isLoaded => _isLoaded;

  bool get isLoading => _isLoading;

  String? get error => _error;

  String? get activeReportCode => _activeReportCode;

  Future<List<Map<String, dynamic>>> loadReport({
    required String reportTypeCode,
    required Map<String, dynamic> filter,
    required ErpTheme theme,
    required BuildContext context,
  }) async {
    final config = ReportRegistry.of(reportTypeCode);
    if (config == null) {
      _error = 'Unknown report type: $reportTypeCode';
      notifyListeners();
      return [];
    }

    _isLoading = true;
    _activeReportCode = reportTypeCode;
    _error = null;
    _pdfBytes = null; // 🔥 reset pdf bytes
    _tableData = []; // 🔥 reset table
    _jsonResponse = {}; // 🔥 reset json response
    notifyListeners();

    final queryParams = config.queryBuilder?.call(filter) ?? filter;
    // print('queryParams $queryParams');
    // 🔥 PDF branch
    if (config.isPdf) {
      try {
        final dio = Dio();
        final String? token = AppStorage.getString('token');

        final response = await dio.get(
          '$baseUrl${config.endpoint}',
          queryParameters: _normalizeQueryParams(queryParams),
          options: Options(
            responseType: ResponseType.bytes,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/pdf, application/json, */*',
              'Authorization': 'Bearer $token',
            },
          ),
        );

        if (response.statusCode == 200) {
          final data = response.data;
          if (data is List<int>) {
            // Check if bytes are a raw PDF (starts with "%PDF")
            final isRawPdf = data.length >= 4 &&
                data[0] == 0x25 && // '%'
                data[1] == 0x50 && // 'P'
                data[2] == 0x44 && // 'D'
                data[3] == 0x46; // 'F'

            if (isRawPdf) {
              _pdfBytes = Uint8List.fromList(data);
              _jsonResponse = {};
              _tableData = [];
            } else {
              final responseString = utf8.decode(data);
              final dynamic decoded = jsonDecode(responseString);
              _handleJsonResponse(decoded, config);
            }
          } else if (data is Map<String, dynamic>) {
            _handleJsonResponse(data, config);
          } else if (data is String) {
            final dynamic decoded = jsonDecode(data);
            _handleJsonResponse(decoded, config);
          }
        } else {
          _error = 'Failed to load PDF: ${response.statusCode}';
          _pdfBytes = null;
        }
      } on DioException catch (e) {
        try {
          print('Status: ${e.response?.statusCode}');

          final data = e.response?.data;

          if (data is Uint8List) {
            // Convert bytes to JSON string
            final responseString = utf8.decode(data);

            print('Response JSON: $responseString');

            final json = jsonDecode(responseString);

            _error = json['message']?.toString() ??
                'Failed to load PDF';

            print('API Message: $_error');
            ErpResultDialog.showError(
              context: context,
              theme: theme,
              title: 'Validation Error',
              message: _error ?? 'Something went wrong.',
            );
          } else if (data is Map) {
            _error = data['message']?.toString() ?? 'Failed to load PDF';
            ErpResultDialog.showError(
              context: context,
              theme: theme,
              title: 'Validation Error',
              message: _error ?? 'Something went wrong.',
            );
          } else {
            _error = e.message ?? 'Failed to load PDF';

            print('Unexpected Response: $data');
          }
        } catch (ex) {
          print('Parse Error: $ex');

          _error = e.message ?? 'Failed to load PDF';
        }

        _pdfBytes = null;
      }

      _isLoaded = true;
      _isLoading = false;
      notifyListeners();
      return _tableData;
    }

    // Normal table branch
    final result = await request<List<Map<String, dynamic>>>(
      call: () => api.get(
        config.endpoint,
        query: _normalizeQueryParams(queryParams),
      ),
      onSuccess: (res) {
        final data = res.data;
        if (data is Map<String, dynamic>) {
          _jsonResponse = data;
        }
        if (data == null || data['data'] == null) {
          return <Map<String, dynamic>>[];
        }
        return (data['data'] as List).cast<Map<String, dynamic>>();
      },
    );

    final rawList = result ?? [];
    _tableData = config.mapper(rawList);
    _isLoaded = true;
    _isLoading = false;
    notifyListeners();
    return _tableData;
  }

  void _handleJsonResponse(dynamic decoded, ReportConfig config) {
    if (decoded is Map<String, dynamic>) {
      _jsonResponse = decoded;

      // Extract and decode PDF from pdfBase64
      final pdfBase64 = decoded['pdfBase64']?.toString();
      if (pdfBase64 != null && pdfBase64.isNotEmpty) {
        final cleanBase64 =
            pdfBase64.contains(',') ? pdfBase64.split(',').last : pdfBase64;
        try {
          _pdfBytes = Uint8List.fromList(base64Decode(cleanBase64.trim()));
        } catch (e) {
          print('Error decoding pdfBase64: $e');
        }
      }

      // Map/flatten data into _tableData
      final rawData = decoded['data'];
      if (rawData is List) {
        final list = rawData
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        final mapped = config.mapper(list);
        if (mapped.isNotEmpty) {
          _tableData = mapped;
        } else {
          _tableData = _flattenSellPriceData(rawData);
        }
      }
    } else if (decoded is List) {
      _jsonResponse = {'data': decoded};
      _tableData = _flattenSellPriceData(decoded);
    }
  }

  List<Map<String, dynamic>> _flattenSellPriceData(List<dynamic> list) {
    final result = <Map<String, dynamic>>[];
    for (final item in list) {
      if (item is! Map) continue;
      final layoutName = item['layoutname']?.toString() ?? '';
      final shapes = item['shapes'] as List? ?? [];
      if (shapes.isEmpty) {
        result.add(Map<String, dynamic>.from(item));
        continue;
      }
      for (final shapeItem in shapes) {
        if (shapeItem is! Map) continue;
        final shapeName = shapeItem['ShapeName']?.toString() ?? '';
        final sizes = shapeItem['sizes'] as List? ?? [];
        if (sizes.isEmpty) {
          result.add({
            'layoutname': layoutName,
            'ShapeName': shapeName,
            ...Map<String, dynamic>.from(shapeItem),
          });
          continue;
        }
        for (final sizeItem in sizes) {
          if (sizeItem is Map) {
            result.add({
              'layoutname': layoutName,
              'ShapeName': shapeName,
              ...Map<String, dynamic>.from(sizeItem),
            });
          }
        }
      }
    }
    return result;
  }

  void updateRow(int index, Map<String, dynamic> row) {
    if (index >= 0 && index < _tableData.length) {
      _tableData[index] = Map<String, dynamic>.from(row);
      notifyListeners();
    }
  }

  void addRow(Map<String, dynamic> row) {
    _tableData.add(Map<String, dynamic>.from(row));
    notifyListeners();
  }

  void setTableData(List<Map<String, dynamic>> newData) {
    _tableData = List<Map<String, dynamic>>.from(newData);
    notifyListeners();
  }

  Map<String, dynamic> _normalizeQueryParams(
      Map<String, dynamic> filter,
      ) {
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

  void clear() {
    _tableData = [];
    _pdfBytes = null; // 🔥 ADD
    _jsonResponse = {};
    _isLoaded = false;
    _activeReportCode = null;
    notifyListeners();
  }
}
