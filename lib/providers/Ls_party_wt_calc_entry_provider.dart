import 'package:diam_mfg/models/ls_party_wt_calc_entry_model.dart';
import 'package:rs_dashboard/rs_dashboard.dart';
import '../models/company_model.dart';

class MstLsPartyWtCalcEntryProvider extends BaseProvider {
  List<MstLsPartyWtCalcEntryModel> _list = [];
  bool _isLoaded = false;

  List<MstLsPartyWtCalcEntryModel> get list => _list;
  bool get isLoaded => _isLoaded;

  List<CompanyModel> _companies = [];

  void setCompanies(List<CompanyModel> companies) {
    _companies = companies;
    notifyListeners();
  }
  int? _selectedCompanyCode;

  void setSelectedCompany(int? code) {
    _selectedCompanyCode = code;
  }
  List<Map<String, dynamic>> get tableData =>
      _list.map((d) {

        final company = _companies
            .where((c) => c.companyCode == d.companyCode)
            .firstOrNull;
        return d.toTableRow(companyName: company?.companyName);
      }).toList();

  // ───── LOAD ─────
  Future<void> load() async {
    final result = await request<List<MstLsPartyWtCalcEntryModel>>(
      showLoader: true,
      call: () => api.get('/purity-group'),
      onSuccess: (res) {
        final data = res.data as List;
        return data.map((e) => MstLsPartyWtCalcEntryModel.fromJson(e)).toList();
      },
    );

    if (result != null) {
      _list = result;
      _isLoaded = true;
      notifyListeners();
    }
  }

  // ───── CREATE ─────
  Future<bool> create(Map<String, dynamic> formValues) async {
    formValues['companyCode'] = _selectedCompanyCode?.toString() ?? '';

    final model = MstLsPartyWtCalcEntryModel.fromFormValues(formValues);

    final result = await request<MstLsPartyWtCalcEntryModel>(
      showLoader: true,
      call: () => api.post('/purity-group', data: model.toJson()),
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
  Future<bool> update(int code, Map<String, dynamic> formValues) async {
    formValues['companyCode'] = _selectedCompanyCode?.toString() ?? '';

    final model = MstLsPartyWtCalcEntryModel.fromFormValues(formValues);

    final result = await request<MstLsPartyWtCalcEntryModel>(
      showLoader: true,
      call: () => api.put('/purity-group/$code', data: model.toJson()),
      onSuccess: (res) => MstLsPartyWtCalcEntryModel.fromJson(res.data),
    );

    if (result != null) {
      final index = _list.indexWhere((e) => e.purityGroupCode == code);
      if (index != -1) _list[index] = result;
      notifyListeners();
      return true;
    }
    return false;
  }

  // ───── DELETE ─────
  Future<bool> delete(int code) async {
    final result = await request<bool>(
      showLoader: true,
      call: () => api.delete('/purity-group/$code'),
      onSuccess: (_) => true,
    );

    if (result == true) {
      _list.removeWhere((e) => e.purityGroupCode == code);
      notifyListeners();
      return true;
    }
    return false;
  }
}


class LsPartyRowModel {

  int srNo;

  double per;

  double calcWt;

  double piePer;

  double pieCalcWt;

  double lsPer;

  double lsCalcWt;

  LsPartyRowModel({

    required this.srNo,

    this.per = 0,

    this.calcWt = 0,

    this.piePer = 0,

    this.pieCalcWt = 0,

    this.lsPer = 0,

    this.lsCalcWt = 0,
  });
}