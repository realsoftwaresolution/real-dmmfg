import 'package:rs_dashboard/rs_dashboard.dart';
import '../models/stock_type_model.dart';

class StockTypeProvider extends BaseProvider {
  List<StockTypeModel> _list     = [];
  bool                 _isLoaded = false;

  List<StockTypeModel> get list     => _list;
  bool                 get isLoaded => _isLoaded;

  List<Map<String, dynamic>> get tableData =>
      _list.map((d) => d.toTableRow()).toList();

  // ───── LOAD ─────
  Future<void> load() async {
    final result = await request<List<StockTypeModel>>(
      showLoader: true,
      call: () => api.get('/stock-type'),
      onSuccess: (res) {
        final data = res.data as List;
        return data.map((e) => StockTypeModel.fromJson(e)).toList();
      },
    );

    if (result != null) {
      _list     = result;
      _isLoaded = true;
      notifyListeners();
    }
  }

  // ───── CREATE ─────
  Future<bool> create(Map<String, dynamic> formValues) async {
    final model = StockTypeModel.fromFormValues(formValues);

    final result = await request<StockTypeModel>(
      showLoader: true,
      call: () => api.post('/stock-type', data: model.toJson()),
      onSuccess: (res) => StockTypeModel.fromJson(res.data),
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
    final model = StockTypeModel.fromFormValues(formValues);

    final result = await request<StockTypeModel>(
      showLoader: true,
      call: () => api.put('/stock-type/$code', data: model.toJson()),
      onSuccess: (res) => StockTypeModel.fromJson(res.data),
    );

    if (result != null) {
      final index = _list.indexWhere((e) => e.stockTypeCode == code);
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
      call: () => api.delete('/stock-type/$code'),
      onSuccess: (_) => true,
    );

    if (result == true) {
      _list.removeWhere((e) => e.stockTypeCode == code);
      notifyListeners();
      return true;
    }
    return false;
  }
}