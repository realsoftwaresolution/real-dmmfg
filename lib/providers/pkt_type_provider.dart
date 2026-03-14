import 'package:rs_dashboard/rs_dashboard.dart';
import '../models/pkt_type_model.dart';

class PktTypeProvider extends BaseProvider {
  List<PktTypeModel> _list = [];
  bool _isLoaded = false;

  List<PktTypeModel> get list     => _list;
  bool               get isLoaded => _isLoaded;

  List<Map<String, dynamic>> get tableData =>
      _list.map((e) => e.toTableRow()).toList();

  // ───── LOAD ─────
  Future<void> load() async {
    final result = await request<List<PktTypeModel>>(
      showLoader: true,
      call: () => api.get('/pktType'),
      onSuccess: (res) {
        final data = res.data as List;
        return data.map((e) => PktTypeModel.fromJson(e)).toList();
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
    final model = PktTypeModel.fromFormValues(formValues);

    final result = await request<PktTypeModel>(
      showLoader: true,
      call: () => api.post('/pktType', data: model.toJson()),
      onSuccess: (res) => PktTypeModel.fromJson(res.data),
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
    final model = PktTypeModel.fromFormValues(formValues);

    final result = await request<PktTypeModel>(
      showLoader: true,
      call: () => api.put('/pktType/$code', data: model.toJson()),
      onSuccess: (res) => PktTypeModel.fromJson(res.data),
    );

    if (result != null) {
      final index = _list.indexWhere((e) => e.pktTypeCode == code);
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
      call: () => api.delete('/pktType/$code'),
      onSuccess: (_) => true,
    );

    if (result == true) {
      _list.removeWhere((e) => e.pktTypeCode == code);
      notifyListeners();
      return true;
    }
    return false;
  }
}