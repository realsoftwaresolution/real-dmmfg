// lib/providers/clv_rate_provider.dart
import 'package:diam_mfg/models/department_rate_model.dart';
import 'package:rs_dashboard/rs_dashboard.dart';
import '../models/clv_rate_model.dart';
import '../models/company_model.dart';

class DepartmentRateProvider extends BaseProvider {
  List<DepartmentRateModel> _list = [];
  bool _isLoaded = false;

  List<DepartmentRateModel> get list => _list;
  bool get isLoaded => _isLoaded;

  List<Map<String, dynamic>>  get tableData =>
      _list.map((e) => e.toTableRow()).toList();

  // ── GET ALL ──────────────────────────────────────────────────────────────
  Future<void> loadClvRates() async {
    final result = await request<List<DepartmentRateModel>>(
      showLoader: true,
      call: () => api.get('/department-rates'),
      onSuccess: (res) {
        final list = res.data['data'] as List;
        return list.map((e) => DepartmentRateModel.fromJson(e)).toList();
      },
    );

    if (result != null) {
      _list = result;
      _isLoaded = true;
      notifyListeners();
    }
  }

  // ── CREATE ───────────────────────────────────────────────────────────────
  Future<bool> createClvRate(Map<String, dynamic> formValues) async {
    final result = await request(
      showLoader: true,
      call: () => api.post('/department-rates', data: formValues),
      onSuccess: (res) {
        if(res.data['success'] == true){
          return true;
        }
      },
    );
    print(result);
    if (result != null) {
      loadClvRates();
      return true;
    }
    return false;
  }

  // ── UPDATE ───────────────────────────────────────────────────────────────
  Future<bool> updateClvRate(int id, Map<String, dynamic> formValues) async {
    final result = await request(
      showLoader: true,
      call: () => api.put('/department-rates/$id', data: formValues),
      onSuccess: (res) {
        if(res.data['success'] == true){
          return true;
        }
      },
    );
    print(result);
    if (result != null) {
      loadClvRates();
      return true;
    }
    return false;
  }



  // ── DELETE ───────────────────────────────────────────────────────────────
  Future<bool> deleteClvRate(int id) async {
    final result = await request<bool>(
      showLoader: true,
      call: () => api.delete('/department-rates/$id'),
      onSuccess: (_) => true,
    );

    if (result == true) {
      _list.removeWhere((e) => (e.clvDeptRateMstID ?? 0) == id || (e.deptRateCode ?? 0) == id);
      notifyListeners();
      return true;
    }

    return false;
  }
}