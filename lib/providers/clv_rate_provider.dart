// lib/providers/clv_rate_provider.dart
import 'package:rs_dashboard/rs_dashboard.dart';
import '../models/clv_rate_model.dart';
import '../models/company_model.dart';

class ClvRateProvider extends BaseProvider {
  List<ClvRateModel> _list = [];
  bool _isLoaded = false;

  List<ClvRateModel> get list => _list;
  bool get isLoaded => _isLoaded;

  List<Map<String, dynamic>>  get tableData =>
      _list.map((e) => e.toTableRow()).toList();

  // ── GET ALL ──────────────────────────────────────────────────────────────
  Future<void> loadClvRates() async {
    final result = await request<List<ClvRateModel>>(
      showLoader: true,
      call: () => api.get('/clvRate'),
      onSuccess: (res) {
        final list = res.data['data'] as List;
        return list.map((e) => ClvRateModel.fromJson(e)).toList();
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
      call: () => api.post('/clvRate', data: formValues),
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
      call: () => api.put('/clvRate/$id', data: formValues),
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
      call: () => api.delete('/clvRate/bulk-delete',data: {
        'ids':[id]
      }),
      onSuccess: (_) => true,
    );

    if (result == true) {
      _list.removeWhere((e) => (e.clvRateMstID ?? 0) == id || (e.clvRateCode ?? 0) == id);
      notifyListeners();
      return true;
    }

    return false;
  }
}