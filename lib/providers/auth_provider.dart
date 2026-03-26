import 'package:diam_mfg/models/counter_model.dart';
import 'package:rs_dashboard/rs_dashboard.dart';

import '../models/auth_model.dart';


class AppStorageKeys {
  static const String authToken = 'auth_token';
  static const String userData = 'user_data';
  static const String isLoggedIn = 'is_logged_in';
  static const String selectedSplash = 'selected_splash'; // for demo
  static const String theme = 'app_theme';
}

class AuthProvider extends BaseProvider {

  CounterModel? _user;
  String? _token;
  bool _isAuthenticated = false;
  bool _isInitialized = false;
  CounterModel? get user => _user;
  bool get isLoggedIn => _token != null;
  bool get isAuthenticated => _isAuthenticated;
  bool get isInitialized => _isInitialized;
  /// ============================================================
  /// 🔥 APP START SESSION CHECK
  /// ============================================================
  ///


  Future<void> checkSession() async {

    await RSAuthSession.restore(); // restore token

    final token = RSAuthSession.token;
    if (token == null) {
      _finishInit();
      return;
    }

    /// Try to validate token with server
    final result = await request<CounterModel>(
      showLoader: false,
      call: () => api.get("/counter/me"), // create this API (or any protected API)
      onSuccess: (res) {
        return CounterModel.fromJson(res.data);
      },
    );

    if (result == null) {
      /// Token invalid → logout
      await RSAuthSession.logout();
      _finishInit();
      return;
    }

    _user = result;
    _isAuthenticated = true;

    _finishInit();
  }

  void _finishInit() {
    _isInitialized = true;
    notifyListeners();
  }
  /// -----------------------------
  /// LOGIN API CALL
  /// -----------------------------
  Future<bool> login({
    required String username,
    required String password,
  }) async {

    final result = await request<AuthResponse>(

      call: () => api.post(
        "/counter/login",
        data: {
          "CrName": username,
          "CrPass": password,
        },
      ),

      onSuccess: (response) {
        print('ress----${response.data}');

        return AuthResponse.fromJson(response.data);
      },
    );

    if (result == null) return false;

    _token = result.token;
    _user = CounterModel.fromJson(result.user);
    _isAuthenticated = true;

    /// Save Session
    await AppStorage.setString("token", _token!);
    await AppStorage.setObject("user", result.user);
    await RSAuthSession.setToken(_token??"");

    notifyListeners();
    return true;
  }

  /// -----------------------------
  /// RESTORE SESSION
  /// -----------------------------
  Future<void> restoreSession() async {
    final token = AppStorage.getString("token");
    final userJson = AppStorage.getObject("user");

    if (token != null && userJson != null) {
      _token = token;
      _user = CounterModel.fromJson(userJson);
      notifyListeners();
    }
  }

  /// -----------------------------
  /// LOGOUT
  /// -----------------------------
  Future<void> logout() async {
    _token = null;
    _user = null;
    await AppStorage.clear();
    _isAuthenticated = false;

    notifyListeners();
  }
}