import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../bootstrap.dart';
import '../models/admin_menu_model.dart';

enum MenuLoadState { idle, loading, loaded, error }

class AdminMenuProvider extends ChangeNotifier {
  final AdminMenuApiService _apiService = AdminMenuApiService();
  final ImagePicker _picker = ImagePicker();

  // ── Load State ─────────────────────────────────────────
  MenuLoadState _loadState = MenuLoadState.idle;
  List<AdminMenuModel> _allMenus = [];
  String _errorMessage = '';
  bool _isSaving = false;

  // ── Form ───────────────────────────────────────────────
  final formKey = GlobalKey<FormState>();
  String _menuName = '';
  String _formName = '';
  int _sortID = 1;
  int _valid = 1;
  String _dashBoard = 'CLICK';
  MainMenuGroup? _selectedMainMenu;

  // ── Image ──────────────────────────────────────────────
  XFile? _pickedImageFile;       // picked file reference
  List<int>? _pickedImageBytes;  // raw bytes to send
  String? _pickedImageMime;      // image/png or image/jpeg
  bool _isPickingImage = false;

  // ── Getters ────────────────────────────────────────────
  MenuLoadState get loadState => _loadState;
  List<AdminMenuModel> get allMenus => _allMenus;
  String get errorMessage => _errorMessage;
  bool get isSaving => _isSaving;
  bool get isPickingImage => _isPickingImage;

  String get menuName => _menuName;
  String get formName => _formName;
  int get sortID => _sortID;
  int get valid => _valid;
  String get dashBoard => _dashBoard;
  MainMenuGroup? get selectedMainMenu => _selectedMainMenu;

  XFile? get pickedImageFile => _pickedImageFile;
  List<int>? get pickedImageBytes => _pickedImageBytes;
  bool get hasImage => _pickedImageFile != null;

  List<AdminMenuModel> get menusInSelectedGroup {
    if (_selectedMainMenu == null) return [];
    return _allMenus.where((m) => m.mainMenuMstID == _selectedMainMenu!.id).toList();
  }

  // ── Load menus ─────────────────────────────────────────
  Future<void> loadMenus() async {
    _loadState = MenuLoadState.loading;
    _errorMessage = '';
    notifyListeners();
    try {
      _allMenus = await _apiService.getAllMenus();
      _loadState = MenuLoadState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _loadState = MenuLoadState.error;
    }
    notifyListeners();
  }

  // ── Image Picking ──────────────────────────────────────
  Future<void> pickImage(ImageSource source) async {
    _isPickingImage = true;
    notifyListeners();

    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (file != null) {
        _pickedImageFile = file;
        _pickedImageBytes = await file.readAsBytes();
        // Determine MIME type from extension
        final ext = file.name.split('.').last.toLowerCase();
        _pickedImageMime = ext == 'png' ? 'image/png' : 'image/jpeg';
        if (_errorMessage == 'Please select a menu image.') _errorMessage = '';
      }
    } catch (e) {
      _errorMessage = 'Failed to pick image: $e';
    }

    _isPickingImage = false;
    notifyListeners();
  }

  void removeImage() {
    _pickedImageFile = null;
    _pickedImageBytes = null;
    _pickedImageMime = null;
    notifyListeners();
  }

  // ── Form Setters ───────────────────────────────────────
  void setMenuName(String v) { _menuName = v; notifyListeners(); }
  void setFormName(String v) { _formName = v; notifyListeners(); }
  void setSortID(int v) { _sortID = v; notifyListeners(); }
  void setValid(int v) { _valid = v; notifyListeners(); }
  void setDashBoard(String v) { _dashBoard = v; notifyListeners(); }
  void setSelectedMainMenu(MainMenuGroup? g) {
    _selectedMainMenu = g;
    notifyListeners();
  }

  String get generatedRouteCode {
    if (_selectedMainMenu == null) return '';

    final prefixMap = {
      0: '2',
      1: '3',
      2: '4',
      3: '5',
    };

    final prefix = prefixMap[_selectedMainMenu!.id] ?? '9';

    final groupMenus = _allMenus.where((m) {
      return m.mainMenuMstID == _selectedMainMenu!.id &&
          m.routeCode.startsWith('$prefix.');
    }).toList();

    final numbers = groupMenus.map((m) {
      final rc = m.routeCode.trim();
      if (rc.contains('.')) {
        final last = rc.split('.').last.trim();
        return int.tryParse(last) ?? 0;
      }
      return 0;
    }).toList();

    final max = numbers.isEmpty ? 0 : numbers.reduce((a, b) => a > b ? a : b);

    final next = (max + 1).toString().padLeft(2, '0');

    return '$prefix.$next';
  }


  int get _nextMenuMstID {
    final grouped = menusInSelectedGroup;
    if (grouped.isEmpty) return 1;
    return grouped.map((m) => m.menuMstID).reduce((a, b) => a > b ? a : b) + 1;
  }

  // ── Save ───────────────────────────────────────────────
  Future<bool> saveMenu() async {
    if (!formKey.currentState!.validate()) return false;
    if (_selectedMainMenu == null) return false;
    if (_pickedImageFile == null) {
      _errorMessage = 'Please select a menu image.';
      notifyListeners();
      return false;
    }
    formKey.currentState!.save();

    _isSaving = true;
    _errorMessage = '';
    notifyListeners();

    final fields = {
      'MenuName': _menuName,
      'MainMenuMstID': _selectedMainMenu!.id,
      'Valid': _valid,
      'FormName': _formName,
      'SortID': _sortID,
      'DashBoard': _dashBoard,
      'RouteCode': generatedRouteCode, // ✅ ADD THIS
    };

    try {
      final success = await _apiService.createMenu(
        fields: fields,
        imageBytes: _pickedImageBytes,
        imageName: _pickedImageFile?.name,
        mimeType: _pickedImageMime,
      );
      if (success) {
        await loadMenus();
        _resetForm();
      }
      _isSaving = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  void _resetForm() {
    _menuName = '';
    _formName = '';
    _sortID = 1;
    _valid = 1;
    _dashBoard = 'CLICK';
    _selectedMainMenu = null;
    _pickedImageFile = null;
    _pickedImageBytes = null;
    _pickedImageMime = null;
    formKey.currentState?.reset();
  }

  void resetForm() {
    _resetForm();
    notifyListeners();
  }
}

class AdminMenuApiService {
  late final Dio _dio;

  AdminMenuApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );
    _dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  }

  /// Fetch all menus
  Future<List<AdminMenuModel>> getAllMenus() async {
    try {
      final response = await _dio.get('/api/menuMst'); // <-- Replace endpoint
      final List data = response.data as List;
      return data
          .map((e) => AdminMenuModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Create a new menu with image as multipart/form-data
  ///
  /// [fields]      - text fields (MenuName, FormName, etc.)
  /// [imageBytes]  - raw bytes of the picked image file
  /// [imageName]   - original filename e.g. "icon.png"
  /// [mimeType]    - "image/png" or "image/jpeg"
  Future<bool> createMenu({
    required Map<String, dynamic> fields,
    List<int>? imageBytes,
    String? imageName,
    String? mimeType,
  }) async {
    try {
      final formData = FormData();

      // Add text fields
      fields.forEach((key, value) {
        formData.fields.add(MapEntry(key, value.toString()));
      });

      // Add image file if provided
      if (imageBytes != null && imageName != null) {
        formData.files.add(
          MapEntry(
            'MenuImage', // <-- key your API expects for the file
            MultipartFile.fromBytes(
              imageBytes,
              filename: imageName,
              contentType: DioMediaType.parse(mimeType ?? 'image/jpeg'),
            ),
          ),
        );
      }

      final response = await _dio.post(
        '/api/menuMst', // <-- Replace endpoint
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timed out. Please try again.';
      case DioExceptionType.badResponse:
        return 'Server error: ${e.response?.statusCode} - ${e.response?.statusMessage}';
      case DioExceptionType.connectionError:
        return 'No internet connection.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}