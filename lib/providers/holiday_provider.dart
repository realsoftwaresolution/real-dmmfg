import 'package:rs_dashboard/rs_dashboard.dart';
import '../models/company_model.dart';
import '../models/holiday_model.dart';

class HolidayProvider extends BaseProvider {
  List<HolidayModel> _list = [];
  bool _isLoaded = false;

  List<HolidayModel> get list => _list;
  bool get isLoaded => _isLoaded;


  List<CompanyModel> _companies = [];

  void setCompanies(List<CompanyModel> companies) {
    _companies = companies;
    notifyListeners();
  }

  List<Map<String, dynamic>> get tableData =>
      _list.map((d) {
        // companyCode se companyName dhundho
        final company = _companies
            .where((c) => c.companyCode == d.companyCode)
            .firstOrNull;
        return d.toTableRow(companyName: company?.companyName);
      }).toList();

  // ───── LOAD ─────
  Future<void> load() async {
    final result = await request<List<HolidayModel>>(
      showLoader: true,
      call: () => api.get('/holiday'),
      onSuccess: (res) {
        final data = res.data as List;
        return data.map((e) => HolidayModel.fromJson(e)).toList();
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
    final model = HolidayModel.fromFormValues(formValues);

    final result = await request<HolidayModel>(
      showLoader: true,
      call: () => api.post('/holiday', data: model.toJson()),
      onSuccess: (res) => HolidayModel.fromJson(res.data),
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
    final model = HolidayModel.fromFormValues(formValues);

    final result = await request<HolidayModel>(
      showLoader: true,
      call: () => api.put('/holiday/$code', data: model.toJson()),
      onSuccess: (res) => HolidayModel.fromJson(res.data),
    );

    if (result != null) {
      final index = _list.indexWhere((e) => e.holidayCode == code);
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
      call: () => api.delete('/holiday/$code'),
      onSuccess: (_) => true,
    );

    if (result == true) {
      _list.removeWhere((e) => e.holidayCode == code);
      notifyListeners();
      return true;
    }
    return false;
  }
}