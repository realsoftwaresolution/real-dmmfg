import 'dart:convert';
import 'dart:typed_data';
import 'package:diam_mfg/utils/ReportRegistry.dart';
import 'package:diam_mfg/utils/msg_dialogue.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:rs_dashboard/base/base_provider.dart';

import '../bootstrap.dart';
import 'package:rs_dashboard/rs_dashboard.dart';

class ReportProvider extends BaseProvider {
  List<Map<String, dynamic>> _tableData = [];
  Uint8List? _pdfBytes; // 🔥 ADD
  bool _isLoaded = false;
  bool _isLoading = false;
  String? _error;
  String? _activeReportCode;

  List<Map<String, dynamic>> get tableData => _tableData;

  Uint8List? get pdfBytes => _pdfBytes; // 🔥 ADD
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
    notifyListeners();

    // 🔥 PDF branch
    if (config.isPdf) {
      try {
        final dio = Dio();
        final String? token = AppStorage.getString('token');

        final response = await dio.get(
          '$baseUrl${config.endpoint}',
          queryParameters: _normalizeQueryParams(filter),
          options: Options(
            responseType: ResponseType.bytes,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/pdf',
              'Authorization': 'Bearer $token',
            },
          ),
        );

        if (response.statusCode == 200) {
          final data = response.data;
          _pdfBytes = Uint8List.fromList(List<int>.from(data));
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
      return [];
    }

    // Normal table branch
    final result = await request<List<Map<String, dynamic>>>(
      call: () => api.get(
        config.endpoint,
        query: _normalizeQueryParams(filter),
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
    _isLoaded = true;
    _isLoading = false;
    notifyListeners();
    return _tableData;
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
    _isLoaded = false;
    _activeReportCode = null;
    notifyListeners();
  }
}
