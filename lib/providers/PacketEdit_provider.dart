import 'package:erp_data_table/erp_data_table/models/erp_column.dart';
import 'package:rs_dashboard/base/base_provider.dart';

import '../utils/constants.dart';

class PacketEditProvider extends BaseProvider {
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
    ErpColumnConfig(key: 'Process', label: 'Process', width: 180),
    ErpColumnConfig(key: 'Pro', label: 'Pro', width: 180),
    ErpColumnConfig(key: 'GhatWt', label: 'Ghat Wt'),
    ErpColumnConfig(key: 'Pc', label: 'Pc'),
    ErpColumnConfig(key: 'Wt', label: 'Wt'),
    ErpColumnConfig(key: 'IssPc', label: 'Iss Pc'),
    ErpColumnConfig(key: 'IssWt', label: 'Iss Wt'),
    ErpColumnConfig(key: 'RecPc', label: 'Rec Pc'),
    ErpColumnConfig(key: 'RecWt', label: 'Rec Wt'),
    ErpColumnConfig(key: 'DmWt', label: 'Dm Wt'),
    ErpColumnConfig(key: 'DmPer', label: 'Dm Per'),
    ErpColumnConfig(key: 'TopsPc', label: 'Tops Pc'),
    ErpColumnConfig(key: 'TopsWt', label: 'Tops Wt'),
    ErpColumnConfig(key: 'KPc', label: 'KPc'),
    ErpColumnConfig(key: 'KWt', label: 'KWt'),
    ErpColumnConfig(key: 'BrPc', label: 'Br Pc'),
    ErpColumnConfig(key: 'BrWt', label: 'Br Wt'),
    ErpColumnConfig(key: 'LossPc', label: 'Loss Pc'),
    ErpColumnConfig(key: 'LossWt', label: 'Loss Wt'),
    ErpColumnConfig(key: 'LossPer', label: 'Loss Per',width: 160),
    ErpColumnConfig(key: 'CrossPc', label: 'Cross Pc',width: 160),
    ErpColumnConfig(key: 'PelPc', label: 'Pel Pc'),
    ErpColumnConfig(key: 'RepPc', label: 'Rep Pc'),
    ErpColumnConfig(key: 'SarinMistake', label: 'Sarin Mistake', width: 180),
    ErpColumnConfig(key: 'LsLossWt', label: 'Ls Loss Wt', width: 160),
    ErpColumnConfig(key: 'SubPktWt', label: 'Sub Pkt Wt', width: 160),
    ErpColumnConfig(key: 'TotalPc', label: 'Total Pc'),
    ErpColumnConfig(key: 'TotalWt', label: 'Total Wt',width: 160),
    ErpColumnConfig(key: 'MstID', label: 'Mst ID'),
    ErpColumnConfig(key: 'DetID', label: 'Det ID'),
    ErpColumnConfig(key: 'FromMan', label: 'From Man', width: 180),
    ErpColumnConfig(key: 'ToMan', label: 'To Man', width: 180),
    ErpColumnConfig(key: 'Dept', label: 'Dept', width: 140),
    ErpColumnConfig(key: 'DeptProcess', label: 'Dept Process', width: 180),
    ErpColumnConfig(key: 'Employee', label: 'Employee', width: 160),
  ];

  String _d(dynamic value) {
    return double.tryParse(value.toString())?.toStringAsFixed(3) ?? '0.000';
  }

  List<Map<String, dynamic>> mapRows(List<Map<String, dynamic>> raw) {
    return raw.map((e) {
      return {
        'Process': e['Process'] ?? '-',
        'Pro': e['Pro'] ?? '-',
        'GhatWt': _d(e['GhatWt']),
        'Pc': e['Pc'] ?? 0,
        'Wt': _d(e['Wt']),
        'IssPc': e['IssPc'] ?? 0,
        'IssWt': _d(e['IssWt']),
        'RecPc': e['RecPc'] ?? 0,
        'RecWt': _d(e['RecWt']),
        'DmWt': _d(e['DmWt']),
        'DmPer': _d(e['DmPer']),
        'TopsPc': e['TopsPc'] ?? 0,
        'TopsWt': _d(e['TopsWt']),
        'KPc': e['KPc'] ?? 0,
        'KWt': _d(e['KWt']),
        'BrPc': e['BrPc'] ?? 0,
        'BrWt': _d(e['BrWt']),
        'LossPc': e['LossPc'] ?? 0,
        'LossWt': _d(e['LossWt']),
        'LossPer': _d(e['LossPer']),
        'CrossPc': e['CrossPc'] ?? 0,
        'PelPc': e['PelPc'] ?? 0,
        'RepPc': e['RepPc'] ?? 0,
        'SarinMistake': _d(e['SarinMistake']),
        'LsLossWt': _d(e['LsLossWt']),
        'SubPktWt': _d(e['SubPktWt']),
        'TotalPc': e['TotalPc'] ?? 0,
        'TotalWt': _d(e['TotalWt']),
        'MstID': e['MstID'] ?? 0,
        'DetID': e['DetID'] ?? 0,
        'FromMan': e['FromMan'] ?? '-',
        'ToMan': e['ToMan'] ?? '-',
        'Dept': e['Dept'] ?? '-',
        'DeptProcess': e['DeptProcess'] ?? '-',
        'Employee': e['Employee'] ?? '-',
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> loadPacketEditList({
    required Map<String, dynamic> filter,
  }) async {
    _isLoading = true;
    _error = null;

    notifyListeners();

    final result = await request<List<Map<String, dynamic>>>(
      call: () => api.get('/packet-history/delete-history'),

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
