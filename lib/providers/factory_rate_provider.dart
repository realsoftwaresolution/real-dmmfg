import 'package:diam_mfg/models/factory_rate_model.dart';
import 'package:rs_dashboard/rs_dashboard.dart';

class FactoryRateProvider extends BaseProvider {
  List<FactoryRateModel> _list = [];
  bool _isLoaded = false;

  List<FactoryRateModel> get list => _list;
  bool get isLoaded => _isLoaded;

  List<Map<String, dynamic>>  get tableData =>
      _list.map((e) => e.toTableRow()).toList();

  // ── GET ALL ──────────────────────────────────────────────────────────────
  Future<void> loadFactoryRates() async {
    final result = await request<List<FactoryRateModel>>(
      showLoader: true,
      call: () => api.get('/factory-rates'),
      onSuccess: (res) {
        final list = res.data['data'] as List;
        return list.map((e) => FactoryRateModel.fromJson(e)).toList();
      },
    );

    if (result != null) {
      _list = result;
      _isLoaded = true;
      notifyListeners();
    }
  }

  // ── CREATE ───────────────────────────────────────────────────────────────
  Future<bool> createFactoryRate(Map<String, dynamic> formValues) async {
    final result = await request(
      showLoader: true,
      call: () => api.post('/factory-rates', data: formValues),
      onSuccess: (res) {
        if(res.data['success'] == true){
          return true;
        }
      },
    );
    print(result);
    if (result != null) {
      loadFactoryRates();
      return true;
    }
    return false;
  }

  // ── UPDATE ───────────────────────────────────────────────────────────────
  Future<bool> updateFactoryRate(int id, Map<String, dynamic> formValues) async {
    final result = await request(
      showLoader: true,
      call: () => api.put('/factory-rates/$id', data: formValues),
      onSuccess: (res) {
        if(res.data['success'] == true){
          return true;
        }
      },
    );
    print(result);
    if (result != null) {
      loadFactoryRates();
      return true;
    }
    return false;
  }



  // ── DELETE ───────────────────────────────────────────────────────────────
  Future<bool> deleteFactoryRate(int id) async {
    final result = await request<bool>(
      showLoader: true,
      call: () => api.delete('/factory-rates/$id'),
      onSuccess: (_) => true,
    );

    if (result == true) {
      _list.removeWhere((e) => (e.factRateMstID ?? 0) == id || (e.factRateCode ?? 0) == id);
      notifyListeners();
      return true;
    }

    return false;
  }
}