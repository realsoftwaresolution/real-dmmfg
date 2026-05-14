import 'package:erp_data_table/erp_data_table/models/erp_column.dart';
import 'package:rs_dashboard/base/base_provider.dart';

import '../utils/constants.dart';

class PacketDeleteProvider extends BaseProvider {
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
    ErpColumnConfig(key: 'Process', label: 'Process', width: 180),
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
    ErpColumnConfig(key: 'Employee', label: 'Employee', width: 160),
    ErpColumnConfig(key: 'Factory', label: 'Factory'),
    ErpColumnConfig(key: 'Signer', label: 'Signer'),
    ErpColumnConfig(key: 'Remarks', label: 'Remarks', width: 160),
    ErpColumnConfig(key: 'UserName', label: 'User'),
    ErpColumnConfig(key: 'MstID', label: 'Mst ID'),
    ErpColumnConfig(key: 'DetId', label: 'Det Id'),
  ];

  List<Map<String, dynamic>> mapRows(List<Map<String, dynamic>> raw) {
    return raw.map((e) {
      final date = DateTime.tryParse(e['Date']?.toString() ?? '');
      return {
        'Date': formatDate(date),
        'Time': e['Time'] ?? '',
        'Process': e['Process'] ?? '-',
        'ID': e['ID'] ?? 0,
        'Jno': e['Jno'] ?? 0,
        'BCode': e['BCode'] ?? 0,
        'PktNo': e['PktNo'] ?? '',
        'CutNo': e['CutNo'] ?? '',
        'ClvCut': e['ClvCut'] ?? '-',
        'MfgCut': e['MfgCut'] ?? '-',
        'LastPc': e['LastPc'] ?? 0,
        'LastWt':
            double.tryParse(e['LastWt'].toString())?.toStringAsFixed(3) ??
            '0.000',
        'LastDmWt':
            double.tryParse(e['LastDmWt'].toString())?.toStringAsFixed(3) ??
            '0.000',
        'LastDmPer':
            double.tryParse(e['LastDmPer'].toString())?.toStringAsFixed(3) ??
            '0.000',
        'FromMan': e['FromMan'] ?? '-',
        'ToMan': e['ToMan'] ?? '-',
        'Dept': e['Dept'] ?? '-',
        'Employee':
            (e['Employee'] == null || e['Employee'].toString().trim().isEmpty)
            ? '-'
            : e['Employee'],
        'Factory':
            (e['Factory'] == null || e['Factory'].toString().trim().isEmpty)
            ? '-'
            : e['Factory'],
        'Signer': (e['Signer'] == null || e['Signer'].toString().trim().isEmpty)
            ? '-'
            : e['Signer'],
        'Remarks':
            (e['Remarks'] == null || e['Remarks'].toString().trim().isEmpty)
            ? '-'
            : e['Remarks'],
        'UserName': e['UserName'] ?? '-',
        'MstID': e['MstID'] ?? 0,
        'DetId': e['DetId'] ?? 0,
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> loadPacketDeleteList({
    required Map<String, dynamic> filter,
  }) async {
    _isLoading = true;
    _error = null;

    notifyListeners();

    final result = await request<List<Map<String, dynamic>>>(
      call: () => api.get('/packet-history/delete-history/${filter['bCode']}'),

      onSuccess: (res) {
        final data = res.data;

        if (data == null || data['data'] == null) {
          return <Map<String, dynamic>>[];
        }

        return (data['data'] as List).cast<Map<String, dynamic>>();
      },
    );
    final rawList = result ?? [];
    _tableData = mapRows(rawList);
    _isLoaded = true;
    _isLoading = false;
    notifyListeners();
    return _tableData;
  }

  Future<List<Map<String, dynamic>>> deleteBulkPktApi({selectedRows}) async {
    _isLoading = true;
    _error = null;

    notifyListeners();

    final result = await request<List<Map<String, dynamic>>>(
      call: () => api.post('/packet-history/bulk-delete', data: selectedRows),

      onSuccess: (res) {
        final data = res.data;

        if (data == null || data['data'] == null) {
          return <Map<String, dynamic>>[];
        }

        return (data['data'] as List).cast<Map<String, dynamic>>();
      },
    );
    _isLoaded = true;
    _isLoading = false;
    notifyListeners();
    return [];
  }

  void clear() {
    _tableData = [];
    _isLoaded = false;
    notifyListeners();
  }
}
