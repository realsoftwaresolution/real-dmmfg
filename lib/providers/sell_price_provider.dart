import 'package:diam_mfg/models/sell_price_model.dart';
import 'package:rs_dashboard/rs_dashboard.dart';


class SellPriceProvider extends BaseProvider {
  List<SellPriceModel> _list = [];
  bool _isLoaded = false;

  List<SellPriceModel> get list => _list;
  bool get isLoaded => _isLoaded;

  List<Map<String, dynamic>>  get tableData =>
      _list.map((e) => e.toTableRow()).toList();

  // ── GET ALL ──────────────────────────────────────────────────────────────
  Future<void> loadSellPrice() async {
    final result = await request<List<SellPriceModel>>(
      showLoader: true,
      call: () => api.get('/sell-price-list'),
      onSuccess: (res) {
        final list = res.data['data'] as List;
        return list.map((e) => SellPriceModel.fromJson(e)).toList();
      },
    );

    if (result != null) {
      _list = result;
      _isLoaded = true;
      notifyListeners();
    }
  }

  // ── CREATE ───────────────────────────────────────────────────────────────
  Future<bool> createSellPrice(Map<String, dynamic> formValues) async {
    final result = await request(
      showLoader: true,
      call: () => api.post('/sell-price-list', data: formValues),
      onSuccess: (res) {
        if(res.data['success'] == true){
          return true;
        }
      },
    );
    print(result);
    if (result != null) {
      loadSellPrice();
      return true;
    }
    return false;
  }

  // ── UPDATE ───────────────────────────────────────────────────────────────
  Future<bool> updateSellPrice(int id, Map<String, dynamic> formValues) async {
    final result = await request(
      showLoader: true,
      call: () => api.put('/sell-price-list/$id', data: formValues),
      onSuccess: (res) {
        if(res.data['success'] == true){
          return true;
        }
      },
    );
    print(result);
    if (result != null) {
      loadSellPrice();
      return true;
    }
    return false;
  }



  // ── DELETE ───────────────────────────────────────────────────────────────
  Future<bool> deleteSellPrice(int id) async {
    final result = await request<bool>(
      showLoader: true,
      call: () => api.delete('/sell-price-list/$id'),
      onSuccess: (_) => true,
    );

    if (result == true) {
      _list.removeWhere((e) => (e.sellPriceListMstID ?? 0) == id || (e.sellCode ?? 0) == id);
      notifyListeners();
      return true;
    }

    return false;
  }
}