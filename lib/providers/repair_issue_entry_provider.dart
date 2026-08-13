import 'package:diam_mfg/utils/process_constants.dart';
import 'package:flutter/material.dart';
import 'package:diam_mfg/models/repair_issue_entry_model.dart';
import 'package:diam_mfg/utils/msg_dialogue.dart';
import 'package:rs_dashboard/rs_dashboard.dart';

class RepairIssueEntryProvider extends BaseProvider {
  List<RepairIssueMstModel> _list = [];
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  List<RepairIssueMstModel> get list => List.unmodifiable(_list);

  List<Map<String, dynamic>> get tableData =>
      _list.map((e) => e.toTableRow()).toList();

  Map<int, List<RepairIssueDetModel>> detMap = {};

  Future<List<RepairIssueDetModel>> loadDetails(int mstID) async {
    final result = await request<List<RepairIssueDetModel>>(
      call: () => api.get('/repairIss/$mstID'),
      onSuccess: (res) {
        final json = res.data as Map<String, dynamic>;
        final data = json['data'] as List;

        return data
            .map(
              (e) => RepairIssueDetModel.fromJson(e as Map<String, dynamic>),
            )
            .toList();
      },
    );

    final dets = result ?? [];
    detMap[mstID] = dets;
    notifyListeners();

    return dets;
  }

  Future<RepairIssueSummaryModel?> loadSummaryReport(int mstID) async {
    final result = await request<RepairIssueSummaryModel>(
      call: () => api.get('/repairIss/$mstID?isSummary=true'),
      onSuccess: (res) {
        final json = res.data as Map<String, dynamic>;
        return RepairIssueSummaryModel.fromJson(json);
      },
    );
    return result;
  }

  // ── LOAD ALL ──────────────────────────────────────────────────────────────
  Future<void> load() async {
    final result = await request<List<RepairIssueMstModel>>(
      call: () => api.get('/repairIss'),
      onSuccess: (res) {
        final list = res.data['data']['data'] as List;
        return list
            .map(
              (e) => RepairIssueMstModel.fromJson(e as Map<String, dynamic>),
            )
            .toList();
      },
    );
    if (result != null) {
      _list = result;
      _isLoaded = true;
      notifyListeners();
    }
  }

  Future<List<RepairIssueDetModel>> fetchByBCode({
    required String bCode,
  }) async {
    final result = await request<List<RepairIssueDetModel>>(
      showLoader: false,
      call: () => api.get('/repairIss/scan-bcode/$bCode'),
      onSuccess: (res) {
        final rawData = res.data['data'];
        dynamic target = rawData;
        if (rawData is Map<String, dynamic> && rawData.containsKey('details')) {
          target = rawData['details'];
        }
        final list = target is List ? target : (target != null ? [target] : []);
        return list
            .whereType<Map<String, dynamic>>()
            .map(
              (e) => RepairIssueDetModel.fromJson(e),
            )
            .toList();
      },
    );
    return result ?? [];
  }


  // ── CREATE ────────────────────────────────────────────────────────────────
  Future<bool> create(Map<String, dynamic> payload) async {
    final result = await request<RepairIssueMstModel>(
      call: () => api.post(
        '/repairIss',
        data: payload,
      ),
      onSuccess: (res) => _parseMstResponse(res.data),
    );

    if (result != null) {
      _list.insert(0, result);
      notifyListeners();
      return true;
    }
    return false;
  }

  // ── DELETE ────────────────────────────────────────────────────────────────
  Future<bool> delete(int id, ErpTheme theme, BuildContext context, List<dynamic> bCodeArray,newMstId) async {
    final result = await request<bool>(
      call: () => api.delete(
        '/repairIss/all/$id/$newMstId',
        data: {
          'expectedProcess': ProcessConstants.factoryIss,
          'bCodeArray': bCodeArray,
        },
      ),
      onSuccess: (res) {
        if (res.data != null && res.data['success'] == true) {
          _list.removeWhere((e) => (e.repairIssMstID ?? e.factoryIssMstID) == id);
          detMap.remove(id);
          notifyListeners();
          ErpResultDialog.showSuccess(
            context: context,
            theme: theme,
            title: 'Success',
            message: res.data['message']?.toString() ?? 'Deleted successfully.',
          );
          return true;
        } else {
          ErpResultDialog.showError(
            context: context,
            theme: theme,
            title: 'Error',
            message: res.data?['message']?.toString() ?? 'Delete failed.',
          );
          return false;
        }
      },
    );
    return result ?? false;
  }

  // ── UPDATE ────────────────────────────────────────────────────────────────
  Future<bool> update(int id, Map<String, dynamic> payload) async {
    final result = await request<RepairIssueMstModel>(
      call: () => api.put(
        '/repairIss/$id',
        data: payload,
      ),
      onSuccess: (res) => _parseMstResponse(res.data),
    );

    if (result != null) {
      final index = _list.indexWhere((e) => (e.repairIssMstID ?? e.factoryIssMstID) == id);
      if (index != -1) {
        _list[index] = result;
      } else {
        _list.insert(0, result);
      }
      detMap.remove(id);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> deleteRow(
    dynamic repairIssMstID,
    dynamic repairIssDetID,
    dynamic bCode,
    dynamic newMstId,
    ErpTheme theme,
    BuildContext context,
  ) async {
    final result = await request<bool>(
      call: () => api.delete(
        '/repairIss/$repairIssMstID/$bCode/$newMstId',
        data: {'expectedProcess': ProcessConstants.factoryIss},
      ),
      onSuccess: (res) {
        final data = res.data;
        if (data != null && data['success'] == false) {
          ErpResultDialog.showError(
            context: context,
            theme: theme,
            message: data['message']?.toString() ?? 'Delete failed.',
          );
          return false;
        }
        return true;
      },
    );
    if (result == true) {
      notifyListeners();
      return true;
    }
    return false;
  }

  RepairIssueMstModel _parseMstResponse(dynamic data) {
    if (data is Map<String, dynamic>) {
      final mstJson = data['data'] ?? data;
      if (mstJson is Map<String, dynamic>) {
        return RepairIssueMstModel.fromJson(mstJson);
      }
    }
    return RepairIssueMstModel.fromJson(data as Map<String, dynamic>);
  }
}

