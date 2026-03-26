import 'package:rs_dashboard/rs_dashboard.dart';

import '../models/party_model.dart';

class PartyProvider extends BaseProvider {
  List<PartyModel> _parties = [];
  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;
  List<PartyModel> get list => _parties;

  List<Map<String, dynamic>> get tableData =>
      _parties.map((e) => e.toTableRow()).toList();
  int? _selectedCompanyCode;

  void setSelectedCompany(int? code) {
    _selectedCompanyCode = code;
  }
  Future<void> loadParties() async {
    final result = await request<List<PartyModel>>(
      call: () => api.get('/party'),
      onSuccess: (res) {
        final list = res.data as List;
        return list.map((e) => PartyModel.fromJson(e)).toList();
      },
    );

    if (result != null) {
      _parties = result;
      _isLoaded  = true;

      notifyListeners();
    }
  }
  Future<bool> createParty(Map<String, dynamic> values) async {
    values['companyCode'] = _selectedCompanyCode?.toString() ?? '';

    final model = PartyModel(
      partyCode: int.tryParse(values['partyCode'] ?? ''),
      partyName: values['partyName'],
      address: values['address'],
      phone1: values['phone1'],
      phone2: values['phone2'],
      phone3: values['phone3'],
      mob1: values['mob1'],
      mob2: values['mob2'],
      mob3: values['mob3'],
      email1: values['email1'],
      email2: values['email2'],
      email3: values['email3'],
      gstNo: values['gstNo'],
      cstNo: values['cstNo'],
      tinNo: values['tinNo'],
      state: values['state'],
      stateCode: int.tryParse(values['stateCode'] ?? ''),
      companyCode: int.tryParse(values['companyCode'] ?? ''),
      active: values['active'] == 'true',
      partyType: values['partyType'],
      panNo: values['panNo'],
      mainCutCompulsory: values['mainCutCompulsory'] == 'true',
    );

    final result = await request<PartyModel>(
      call: () => api.post('/party', data: model.toJson()),
      onSuccess: (res) => PartyModel.fromJson(res.data),
    );

    if (result != null) {
      _parties.insert(0, result);
      notifyListeners();
      return true;
    }
    return false;
  }
  // Future<bool> createParty(Map<String, dynamic> values) async {
  //   final model = PartyModel.fromJson(values);
  //
  //   final result = await request<PartyModel>(
  //     call: () => api.post('/party', data: model.toJson()),
  //     onSuccess: (res) => PartyModel.fromJson(res.data),
  //   );
  //
  //   if (result != null) {
  //     _parties.insert(0, result);
  //     notifyListeners();
  //     return true;
  //   }
  //   return false;
  // }

  // Future<bool> updateParty(int code, Map<String, dynamic> values) async {
  //   final model = PartyModel.fromJson(values);
  //
  //   final result = await request<PartyModel>(
  //     call: () => api.put('/party/$code', data: model.toJson()),
  //     onSuccess: (res) => PartyModel.fromJson(res.data),
  //   );
  //
  //   if (result != null) {
  //     final i = _parties.indexWhere((e) => e.partyCode == code);
  //     if (i != -1) _parties[i] = result;
  //     notifyListeners();
  //     return true;
  //   }
  //   return false;
  // }
  Future<bool> updateParty(int code, Map<String, dynamic> values) async {
    values['companyCode'] = _selectedCompanyCode?.toString() ?? '';

    // ← fromJson ki jagah createParty jaisa manual mapping karo
    final model = PartyModel(
      partyCode: code,
      partyName: values['partyName'],
      address: values['address'],
      phone1: values['phone1'],
      phone2: values['phone2'],
      phone3: values['phone3'],
      mob1: values['mob1'],
      mob2: values['mob2'],
      mob3: values['mob3'],
      email1: values['email1'],
      email2: values['email2'],
      email3: values['email3'],
      gstNo: values['gstNo'],
      cstNo: values['cstNo'],
      tinNo: values['tinNo'],
      state: values['state'],
      stateCode: int.tryParse(values['stateCode'] ?? ''),
      companyCode: int.tryParse(values['companyCode'] ?? ''),
      active: values['active'] == '1' || values['active'] == 'true',
      partyType: values['partyType'],
      panNo: values['panNo'],
      mainCutCompulsory: values['mainCutCompulsory'] == '1' || values['mainCutCompulsory'] == 'true',
    );

    final result = await request<PartyModel>(
      call: () => api.put('/party/$code', data: model.toJson()),
      onSuccess: (res) => PartyModel.fromJson(res.data),
    );

    if (result != null) {
      final i = _parties.indexWhere((e) => e.partyCode == code);
      if (i != -1) _parties[i] = result;
      notifyListeners();
      return true;
    }
    return false;
  }
  Future<bool> deleteParty(int code) async {
    final result = await request<bool>(
      call: () => api.delete('/party/$code'),
      onSuccess: (_) => true,
    );

    if (result == true) {
      _parties.removeWhere((e) => e.partyCode == code);
      notifyListeners();
      return true;
    }
    return false;
  }
}