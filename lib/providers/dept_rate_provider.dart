// lib/providers/dept_rate_provider.dart
import 'package:rs_dashboard/rs_dashboard.dart';
import '../models/dept_rate_model.dart';

class DeptRateProvider extends BaseProvider {
  List<DeptRateModel> _list = [];
  bool _isLoaded = false;

  List<DeptRateModel> get list => _list;
  bool get isLoaded => _isLoaded;

  List<Map<String, dynamic>> get tableData =>
      _list.map((e) => e.toTableRow()).toList();

  // ── GET ALL ──────────────────────────────────────────────────────────────
  Future<void> loadDeptRates() async {
    final result = await request<List<DeptRateModel>>(
      showLoader: true,
      call: () => api.get('/deptRate'),
      onSuccess: (res) {
        final list = res.data['data'] as List;
        return list.map((e) => DeptRateModel.fromJson(e)).toList();
      },
    );

    if (result != null) {
      _list = result;
      _isLoaded = true;
      notifyListeners();
    }
  }

  // ── CREATE ───────────────────────────────────────────────────────────────
  Future<bool> createDeptRate(Map<String, dynamic> formValues) async {
    final result = await request(
      showLoader: true,
      call: () => api.post('/deptRate', data: formValues),
      onSuccess: (res) {
        if (res.data['success'] == true) {
          return true;
        }
      },
    );
    if (result != null) {
      loadDeptRates();
      return true;
    }
    return false;
  }

  // ── UPDATE ───────────────────────────────────────────────────────────────
  Future<bool> updateDeptRate(int id, Map<String, dynamic> formValues) async {
    final result = await request(
      showLoader: true,
      call: () => api.put('/deptRate/$id', data: formValues),
      onSuccess: (res) {
        if (res.data['success'] == true) {
          return true;
        }
      },
    );
    if (result != null) {
      loadDeptRates();
      return true;
    }
    return false;
  }

  // ── DELETE ───────────────────────────────────────────────────────────────
  Future<bool> deleteDeptRate(int id) async {
    final result = await request<bool>(
      showLoader: true,
      call: () => api.delete('/deptRate/bulk-delete', data: {
        'ids': [id]
      }),
      onSuccess: (_) => true,
    );

    if (result == true) {
      _list.removeWhere((e) =>
      (e.clvDeptRateMstID ?? 0) == id ||
          (e.deptRateCode ?? '') == id.toString());
      notifyListeners();
      return true;
    }

    return false;
  }
}