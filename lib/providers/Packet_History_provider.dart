import 'package:erp_data_table/erp_data_table/models/erp_column.dart';
import 'package:rs_dashboard/base/base_provider.dart';

class PacketHistoryProvider extends BaseProvider {
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
    ErpColumnConfig(key: 'Date', label: 'Date'),
    ErpColumnConfig(key: 'Time', label: 'Time'),

    ErpColumnConfig(key: 'LastProcess', label: 'Last Process', width: 180),
    ErpColumnConfig(key: 'Pro', label: 'Pro'),

    ErpColumnConfig(key: 'ID', label: 'ID'),
    ErpColumnConfig(key: 'Jno', label: 'Jno'),

    ErpColumnConfig(key: 'BCode', label: 'BCode'),

    ErpColumnConfig(key: 'PktNo', label: 'Pkt No'),
    ErpColumnConfig(key: 'CutNo', label: 'Cut No'),

    ErpColumnConfig(key: 'ClvCut', label: 'Clv Cut'),
    ErpColumnConfig(key: 'MfgCut', label: 'Mfg Cut'),

    ErpColumnConfig(key: 'LastPc', label: 'Pc'),
    ErpColumnConfig(key: 'LastWt', label: 'Wt'),

    ErpColumnConfig(key: 'LastDmWt', label: 'Dm Wt'),
    ErpColumnConfig(key: 'LastDmPer', label: 'Dm %'),

    ErpColumnConfig(key: 'FromMan', label: 'From Manager', width: 180),

    ErpColumnConfig(key: 'ToMan', label: 'To Manager', width: 180),

    ErpColumnConfig(key: 'Dept', label: 'Department', width: 180),

    ErpColumnConfig(key: 'Process', label: 'Dept Process', width: 180),

    ErpColumnConfig(key: 'Employee', label: 'Employee', width: 160),

    ErpColumnConfig(key: 'Factory', label: 'Factory'),

    ErpColumnConfig(key: 'Signer', label: 'Signer'),

    ErpColumnConfig(key: 'Remarks', label: 'Remarks', width: 160),

    ErpColumnConfig(key: 'UserName', label: 'User'),

    ErpColumnConfig(key: 'MstID', label: 'Mst ID'),

    ErpColumnConfig(key: 'DetId', label: 'Det Id'),

    ErpColumnConfig(key: 'PcID', label: 'PC ID'),
  ];

  Future<List<Map<String, dynamic>>> loadPacketHistory({
    required Map<String, dynamic> filter,
  }) async {
    _isLoading = true;
    _error = null;

    notifyListeners();

    final result = await request<List<Map<String, dynamic>>>(
      call: () => api.get('/packet-history/${filter['bcode']}'),

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
