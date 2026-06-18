import 'package:rs_dashboard/rs_dashboard.dart';

class ProductionDashboardProvider extends BaseProvider {

  List<dynamic> _level1 = [];
  List<dynamic> _level2 = [];
  List<dynamic> _level3 = [];

  List<dynamic> get level1 => _level1;
  List<dynamic> get level2 => _level2;
  List<dynamic> get level3 => _level3;

  int? selectedDeptCode;
  int? selectedRoughMstID;

  // ── FILTER STATES ──────────────────────────────────────────────────────────
  List<int> filterRoughMstIDs = [];
  List<int> filterArticleCodes = [];

  void setFilters({List<int>? roughMstIDs, List<int>? articleCodes}) {
    filterRoughMstIDs = roughMstIDs ?? [];
    filterArticleCodes = articleCodes ?? [];
    notifyListeners();
  }

  void resetFilters() {
    filterRoughMstIDs = [];
    filterArticleCodes = [];
    notifyListeners();
  }

  // ── DYNAMIC FETCH METHODS ──────────────────────────────────────────────────
  Future<List<dynamic>?> fetchLevel1() async {
    return await request<List<dynamic>>(
      showLoader: true,
      call: () => api.post(
        '/reports/production-report',
        data: {
          "RoughMstIDs": filterRoughMstIDs,
          "ArticleCodes": filterArticleCodes,
        },
      ),
      onSuccess: (res) {
        return (res.data['data'] as List<dynamic>?) ?? [];
      },
    );
  }

  Future<List<dynamic>?> fetchLevel2(int deptCode) async {
    return await request<List<dynamic>>(
      showLoader: true,
      call: () => api.post(
        '/reports/production-report',
        data: {
          "DeptCode": deptCode,
          "RoughMstIDs": filterRoughMstIDs,
          "ArticleCodes": filterArticleCodes,
        },
      ),
      onSuccess: (res) {
        return (res.data['data'] as List<dynamic>?) ?? [];
      },
    );
  }

  Future<List<dynamic>?> fetchLevel3({
    required int deptCode,
    required int roughMstID,
  }) async {
    return await request<List<dynamic>>(
      showLoader: true,
      call: () => api.post(
        '/reports/production-report',
        data: {
          "DeptCode": deptCode,
          "RoughMstID": roughMstID,
          "RoughMstIDs": filterRoughMstIDs,
          "ArticleCodes": filterArticleCodes,
        },
      ),
      onSuccess: (res) {
        return (res.data['data'] as List<dynamic>?) ?? [];
      },
    );
  }

  // ── POLISH STOCK FETCH METHODS ─────────────────────────────────────────────
  Future<List<dynamic>?> fetchPolishStockLevel1() async {
    return await request<List<dynamic>>(
      showLoader: true,
      call: () => api.post(
        '/reports/polish-stock-report',
        data: {
          "RoughMstIDs": filterRoughMstIDs,
          "ArticleCodes": filterArticleCodes,
        },
      ),
      onSuccess: (res) {
        return (res.data['data'] as List<dynamic>?) ?? [];
      },
    );
  }

  Future<List<dynamic>?> fetchPolishStockLevel2(int factoryCode) async {
    return await request<List<dynamic>>(
      showLoader: true,
      call: () => api.post(
        '/reports/polish-stock-report',
        data: {
          "FactoryCode": factoryCode,
          "RoughMstIDs": filterRoughMstIDs,
          "ArticleCodes": filterArticleCodes,
        },
      ),
      onSuccess: (res) {
        return (res.data['data'] as List<dynamic>?) ?? [];
      },
    );
  }

  Future<List<dynamic>?> fetchPolishStockLevel3({
    required int factoryCode,
    required int roughMstID,
  }) async {
    return await request<List<dynamic>>(
      showLoader: true,
      call: () => api.post(
        '/reports/polish-stock-report',
        data: {
          "FactoryCode": factoryCode,
          "RoughMstID": roughMstID,
          "RoughMstIDs": filterRoughMstIDs,
          "ArticleCodes": filterArticleCodes,
        },
      ),
      onSuccess: (res) {
        return (res.data['data'] as List<dynamic>?) ?? [];
      },
    );
  }

  Future<List<dynamic>?> fetchPairListReport() async {
    return await request<List<dynamic>>(
      showLoader: true,
      call: () => api.post(
        '/reports/pair-list-report',
        data: {
          "RoughMstIDs": filterRoughMstIDs,
          "ArticleCodes": filterArticleCodes,
        },
      ),
      onSuccess: (res) {
        return (res.data['data'] as List<dynamic>?) ?? [];
      },
    );
  }
}