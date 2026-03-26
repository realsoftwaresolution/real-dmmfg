import 'package:rs_dashboard/rs_dashboard.dart';
import '../models/designation_model.dart';

class DesignationProvider extends BaseProvider {

  List<DesignationModel> _list = [];
  bool _isLoaded = false;

  List<DesignationModel> get list => _list;
  bool get isLoaded => _isLoaded;

  List<Map<String, dynamic>> get tableData =>
      _list.map((e) => e.toTableRow()).toList();

  // LOAD
  Future<void> load() async {
    final result = await request<List<DesignationModel>>(
      call: () => api.get('/designation'),
      onSuccess: (res) {
        final list = res.data as List;
        return list.map((e) => DesignationModel.fromJson(e)).toList();
      },
    );

    if (result != null) {
      _list = result;
      _isLoaded = true;
      notifyListeners();
    }
  }

  // CREATE
  Future<bool> create(Map<String, dynamic> values) async {

    final model = DesignationModel(
      designationName: values['designationName'],
      sortID: int.tryParse(values['sortID'] ?? ''),
      active: values['active'] == 'true',
    );

    final result = await request<DesignationModel>(
      call: () => api.post('/designation', data: model.toJson()),
      onSuccess: (res) => DesignationModel.fromJson(res.data),
    );

    if (result != null) {
      _list.insert(0, result);
      notifyListeners();
      return true;
    }
    return false;
  }

  // UPDATE
  Future<bool> update(int code, Map<String, dynamic> values) async {

    final model = DesignationModel(
      designationCode: code,
      designationName: values['designationName'],
      sortID: int.tryParse(values['sortID'] ?? ''),
      active: values['active'] == '1' || values['active'] == 'true',
    );

    final result = await request<DesignationModel>(
      call: () => api.put('/designation/$code', data: model.toJson()),
      onSuccess: (res) => DesignationModel.fromJson(res.data),
    );

    if (result != null) {
      final i = _list.indexWhere((e) => e.designationCode == code);
      if (i != -1) _list[i] = result;
      notifyListeners();
      return true;
    }
    return false;
  }

  // DELETE
  Future<bool> delete(int code) async {
    final result = await request<bool>(
      call: () => api.delete('/designation/$code'),
      onSuccess: (_) => true,
    );

    if (result == true) {
      _list.removeWhere((e) => e.designationCode == code);
      notifyListeners();
      return true;
    }
    return false;
  }
}