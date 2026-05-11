import 'package:erp_data_table/erp_data_table/models/erp_column.dart';
import 'package:rs_dashboard/base/base_provider.dart';

class PairProvider extends BaseProvider {
  List<Map<String, dynamic>> _tableData = [];

  bool _isLoaded = false;
  bool _isLoading = false;

  String? _error;
  String? _activeReportCode;

  List<Map<String, dynamic>> get tableData => _tableData;

  bool get isLoaded => _isLoaded;

  bool get isLoading => _isLoading;

  String? get error => _error;

  String? get activeReportCode => _activeReportCode;

  /// 🔥 DIRECT STATIC COLUMNS
  final List<ErpColumnConfig> columns = [
    ErpColumnConfig(key: 'date', label: 'Date'),
    ErpColumnConfig(key: 'time', label: 'Time'),
    ErpColumnConfig(key: 'process', label: 'Process'),
    ErpColumnConfig(key: 'pro', label: 'Pro'),

    ErpColumnConfig(key: 'id', label: 'ID'),
    ErpColumnConfig(key: 'jno', label: 'Jno'),
    ErpColumnConfig(key: 'bCode', label: 'BCode'),

    ErpColumnConfig(key: 'totPkt', label: 'Tot Pkt'),
    ErpColumnConfig(key: 'clvClt', label: 'Clv Clt'),

    ErpColumnConfig(key: 'mfgCut', label: 'Mfg Cut'),
    ErpColumnConfig(key: 'pc', label: 'Pc'),

    ErpColumnConfig(key: 'wt', label: 'Wt'),
    ErpColumnConfig(key: 'dmWt', label: 'Dm Wt'),
    ErpColumnConfig(key: 'dmPer', label: 'Dm Per'),

    ErpColumnConfig(key: 'fromManager', label: 'From Manager', width: 160),
    ErpColumnConfig(key: 'toManager', label: 'To Manager', width: 160),

    ErpColumnConfig(key: 'department', label: 'Department', width: 160),
    ErpColumnConfig(key: 'deptProcess', label: 'Dept Process', width: 180),

    ErpColumnConfig(key: 'employee', label: 'Employee', width: 160),
    ErpColumnConfig(key: 'factory', label: 'Factory'),

    ErpColumnConfig(key: 'signer', label: 'Signer'),
    ErpColumnConfig(key: 'remarks', label: 'Remarks'),

    ErpColumnConfig(key: 'user', label: 'User'),

    ErpColumnConfig(key: 'mstId', label: 'Mst ID'),
    ErpColumnConfig(key: 'detId', label: 'Det Id'),

    ErpColumnConfig(key: 'ipAddress', label: 'IP Address'),
  ];

  Future<List<Map<String, dynamic>>> loadPairData({
    required Map<String, dynamic> filter,
  }) async {
    _isLoading = true;
    _error = null;

    notifyListeners();

    final result = await request<List<Map<String, dynamic>>>(
      call: () => api.get('/packetHistory', query: filter),

      onSuccess: (res) {
        final data = res.data;

        if (data == null || data['data'] == null) {
          return <Map<String, dynamic>>[];
        }

        return (data['data'] as List).cast<Map<String, dynamic>>();
      },
    );

    _tableData = result ?? [];

    _isLoaded = true;
    _isLoading = false;

    notifyListeners();

    return _tableData;
  }

  void clear() {
    _tableData = [];
    _isLoaded = false;
    notifyListeners();
  }
}
