import 'package:diam_mfg/models/company_model.dart';
import 'package:diam_mfg/models/ls_party_wt_calc_entry_model.dart';
import 'package:rs_dashboard/rs_dashboard.dart';

import '../utils/constants.dart';

class MstLsPartyWtCalcEntryProvider extends BaseProvider {
  List<MstLsPartyWtCalcEntryModel> _list = [];
  bool _isLoaded = false;

  List<MstLsPartyWtCalcEntryModel> get list => _list;

  bool get isLoaded => _isLoaded;
  List<LsPartyRowModel> detailRows = [];

  List<CompanyModel> _companies = [];

  void setCompanies(List<CompanyModel> companies) {
    _companies = companies;
    notifyListeners();
  }

  int? _selectedCompanyCode;

  void setSelectedCompany(int? code) {
    _selectedCompanyCode = code;
  }

  List<Map<String, dynamic>> get tableData => _list.map((d) {
    return {
      'lsPartyWtCalcMstId': d.lsPartyWtCalcMstId?.toString() ?? '',

      'lsPartyWtCalcDate': d.lsPartyWtCalcDate == null
          ? ''
          : formatDisplayDate(d.lsPartyWtCalcDate!),

      'remarksName': d.remarksName ?? '',

      'remarkTOPS': d.remarkTOPS?.toString() ?? '',

      'calcType': d.calcType ?? '',

      'calcWt': d.calcWt?.toStringAsFixed(3) ?? '0.000',

      '_raw': d,
    };
  }).toList();

  // ───── LOAD ─────
  Future<void> load() async {
    final result = await request<List<MstLsPartyWtCalcEntryModel>>(
      showLoader: true,
      call: () => api.get('/lsPartyWtCal'),
      onSuccess: (res) {
        final data = res.data['data'] as List;
        return data.map((e) => MstLsPartyWtCalcEntryModel.fromJson(e)).toList();
      },
    );

    if (result != null) {
      _list = result;

      print('API COUNT = ${_list.length}');
      print(_list.first.toJson());

      _isLoaded = true;

      notifyListeners();
    }
  }

  Future<void> loadDetails(int id) async {
    final result = await request<List<dynamic>>(
      showLoader: true,

      call: () => api.get('/lsPartyWtCal/$id'),

      onSuccess: (res) => res.data['data'] as List,
    );

    if (result != null && result.isNotEmpty) {
      detailRows = result.map((e) {
        return LsPartyRowModel(
          srNo: e['Srno'] ?? 0,

          per: (e['CalcPer'] ?? 0).toDouble(),

          calcWt: (e['DetCalcWt'] ?? 0).toDouble(),

          piePer: (e['PiePer'] ?? 0).toDouble(),

          pieCalcWt: (e['PieCalcWt'] ?? 0).toDouble(),

          lsPer: (e['LSPer'] ?? 0).toDouble(),

          lsCalcWt: (e['LSCalcWt'] ?? 0).toDouble(),
        );
      }).toList();

      notifyListeners();
    }
  }

  // ───── CREATE ─────
  Future<bool> create(
    Map<String, dynamic> formValues,
    List<LsPartyRowModel> details,
  ) async {
    final payload = {
      'LsPartyWtCalcDate': DateTime.now().toUtc().toIso8601String(),

      'RemarksCode':
          int.tryParse(formValues['remarks']?.toString() ?? '0') ?? 0,

      'TOPS': details.length,

      'CalcWt': details.fold<double>(0, (sum, e) => sum + e.calcWt),

      'CalcType': 'P2',

      'CrId': 0,

      'CompanyCode': _selectedCompanyCode ?? 0,

      'details': details.map((e) {
        return {
          'Srno': e.srNo,

          'CalcPer': e.per,

          'CalcWt': e.calcWt,

          'PiePer': e.piePer,

          'PieCalcWt': e.pieCalcWt,

          'LSPer': e.lsPer,

          'LSCalcWt': e.lsCalcWt,
        };
      }).toList(),
    };

    final result = await request<MstLsPartyWtCalcEntryModel>(
      showLoader: true,

      call: () => api.post('/lsPartyWtCal', data: payload),

      onSuccess: (res) => MstLsPartyWtCalcEntryModel.fromJson(res.data),
    );

    if (result != null) {
      _list.insert(0, result);

      notifyListeners();

      return true;
    }

    return false;
  }

  // ───── UPDATE ─────
  Future<bool> update(
    int code,
    Map<String, dynamic> formValues,
    List<LsPartyRowModel> details,
  ) async {
    final payload = {
      'LsPartyWtCalcDate': DateTime.now().toUtc().toIso8601String(),

      'RemarksCode':
          int.tryParse(formValues['remarks']?.toString() ?? '0') ?? 0,

      'TOPS': details.length,

      'CalcWt': details.fold<double>(0, (sum, e) => sum + e.calcWt),
      'CalcType': 'P2',
      'CrId': 0,
      'CompanyCode': _selectedCompanyCode ?? 0,

      'details': details.map((e) {
        return {
          'Srno': e.srNo,

          'CalcPer': e.per,

          'CalcWt': e.calcWt,

          'PiePer': e.piePer,

          'PieCalcWt': e.pieCalcWt,

          'LSPer': e.lsPer,

          'LSCalcWt': e.lsCalcWt,
        };
      }).toList(),
    };

    final result = await request<MstLsPartyWtCalcEntryModel>(
      showLoader: true,

      call: () => api.put('/lsPartyWtCal/$code', data: payload),

      onSuccess: (res) => MstLsPartyWtCalcEntryModel.fromJson(res.data),
    );

    if (result != null) {
      final index = _list.indexWhere((e) => e.lsPartyWtCalcMstId == code);

      if (index != -1) {
        _list[index] = result;
      }

      notifyListeners();

      return true;
    }

    return false;
  }

  // ───── DELETE ─────
  Future<bool> delete(int code) async {
    final result = await request<bool>(
      showLoader: true,
      call: () => api.delete('/lsPartyWtCal/bulk-delete',data: {
        'ids': [code]
      }),
      onSuccess: (_) => true,
    );

    if (result == true) {
      _list.removeWhere((e) => e.lsPartyWtCalcMstId == code);
      notifyListeners();
      return true;
    }
    return false;
  }
}
