import 'package:diam_mfg/utils/ReportRegistry.dart';
import 'package:rs_dashboard/base/base_provider.dart';

class ReportProvider extends BaseProvider {
  List<Map<String, dynamic>> _tableData = [];
  bool _isLoaded = false;
  bool _isLoading = false;
  String? _error;
  String? _activeReportCode; // 🔥 tracks which report is active

  List<Map<String, dynamic>> get tableData => _tableData;

  bool get isLoaded => _isLoaded;

  bool get isLoading => _isLoading;

  String? get error => _error;

  String? get activeReportCode => _activeReportCode;

  /// 🔹 DYNAMIC API CALL — picks endpoint + mapper from registry
  Future<List<Map<String, dynamic>>> loadReport({
    required String reportTypeCode,
    required Map<String, dynamic> filter,
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
    notifyListeners();

    final result = await request<List<Map<String, dynamic>>>(
      call: () => api.get(config.endpoint, query: filter),
      onSuccess: (res) {
        final data = res.data;
        if (data == null || data['data'] == null) return <Map<String, dynamic>>[];
        return (data['data'] as List).cast<Map<String, dynamic>>();
      },
    );

    // Apply the mapper defined in the config
    final rawList = result ?? [];
    _tableData = config.mapper(rawList);
    _isLoaded = true;
    _isLoading = false;
    notifyListeners();

    return _tableData;
  }

  void clear() {
    _tableData = [];
    _isLoaded = false;
    _activeReportCode = null;
    notifyListeners();
  }
}
