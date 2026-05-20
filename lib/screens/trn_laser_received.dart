import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:diam_mfg/models/laser_mst_model.dart';
import 'package:diam_mfg/providers/charni_provider.dart';
import 'package:diam_mfg/providers/counter_manager_det_provider.dart';
import 'package:diam_mfg/providers/counter_provider.dart';
import 'package:diam_mfg/providers/dept_provider.dart';
import 'package:diam_mfg/providers/dept_group_provider.dart';
import 'package:diam_mfg/providers/dept_process_provider.dart';
import 'package:diam_mfg/providers/employee_provider.dart';
import 'package:diam_mfg/providers/remarks_provider.dart';
import 'package:diam_mfg/providers/tensions_provider.dart';
import 'package:diam_mfg/providers/trn_laser_received_provider.dart';
import 'package:diam_mfg/utils/app_images.dart';
import 'package:diam_mfg/utils/constants.dart';
import 'package:diam_mfg/utils/delete_dialogue.dart';
import 'package:diam_mfg/utils/helper_functions.dart';
import 'package:diam_mfg/utils/msg_dialogue.dart';
import 'package:erp_data_table/erp_data_table.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rs_dashboard/rs_dashboard.dart';

import '../bootstrap.dart';
import '../models/user_visibility_model.dart';
import '../providers/auth_provider.dart';
import '../providers/counter_display_det_provider.dart';
import '../providers/purity_provider.dart';
import '../providers/shape_provider.dart';
import '../providers/user_visibility_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  WIDGET
// ─────────────────────────────────────────────────────────────────────────────

class TrnLaserReceivedEntry extends StatefulWidget {
  const TrnLaserReceivedEntry({super.key});

  @override
  State<TrnLaserReceivedEntry> createState() => _TrnLaserReceivedEntryState();
}

// ─────────────────────────────────────────────────────────────────────────────
//  STATE
// ─────────────────────────────────────────────────────────────────────────────

class _TrnLaserReceivedEntryState extends State<TrnLaserReceivedEntry> {
  // ── Theme ──────────────────────────────────────────────────────────────────
  final ErpThemeVariant _themeVariant = ErpThemeVariant.frost;

  ErpTheme get _theme => ErpTheme(_themeVariant);

  // ── Form ───────────────────────────────────────────────────────────────────
  GlobalKey<ErpFormState> _erpFormKey = GlobalKey<ErpFormState>();
  Map<String, String> _formValues = {};
  final Map<String, String> _entryVals = {};

  // ── Auth ───────────────────────────────────────────────────────────────────
  final String? token = AppStorage.getString('token');

  // ── Selection state ────────────────────────────────────────────────────────
  Map<String, dynamic>? _selectedRow;
  LaserMstModel? _selectedMst;
  LaserDetModel? _scannedDet;
  List<LaserDetModel> _laserApiRows = [];

  List<Map<String, dynamic>> _laserApiDisplay = [];

  // ── UI flags ───────────────────────────────────────────────────────────────
  bool _isEditMode = false;
  bool _isAdding = false;
  bool _showTableOnMobile = false;
  bool _processSelected = false;
  bool _lockMasterFields = false;
  bool _isBCodePending = false;

  // ── From / To counter ─────────────────────────────────────────────────────
  int? _fromCrId;
  String? _fromDeptName;
  int? _fromDeptCode;

  int? _toCrId;
  String? _toDeptName;
  int? _toDeptCodeVal;

  // ── Detail rows ────────────────────────────────────────────────────────────
  List<LaserDetModel> _detRows = [];
  List<Map<String, dynamic>> _detDisplay = [];
  List<String> _activeDetColumns = [];
  int? _editingDetIndex;

  // ── Display fields (from UserVisibility) ───────────────────────────────────
  List<UserVisibilityModel> _fromDisplayFields = [];
  List<UserVisibilityModel> _toDisplayFields = [];
  String? _selectedRadioCode;
  bool _isMackable = false;

  // ─────────────────────────────────────────────────────────────────────────
  //  PROVIDER SHORTCUTS
  // ─────────────────────────────────────────────────────────────────────────

  CounterDisplayDetProvider get _displayProv =>
      context.read<CounterDisplayDetProvider>();

  UserVisibilityProvider get _visProv => context.read<UserVisibilityProvider>();

  // ─────────────────────────────────────────────────────────────────────────
  //  LOOKUP HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  String _deptNameFor(int? deptCode) {
    if (deptCode == null) return '';
    try {
      return context
              .read<DeptProvider>()
              .list
              .firstWhere((d) => d.deptCode == deptCode)
              .deptName ??
          '';
    } catch (_) {
      return '';
    }
  }

  String _deptGroupNameFor(int? code) {
    if (code == null) return '';
    try {
      return context
              .read<DeptGroupProvider>()
              .list
              .firstWhere((d) => d.deptGroupCode == code)
              .deptGroupName ??
          '';
    } catch (_) {
      return '';
    }
  }

  String _shapeNameFor(int? code) {
    if (code == null) return '';
    try {
      return context
              .read<ShapeProvider>()
              .list
              .firstWhere((s) => s.shapeCode == code)
              .shapeName ??
          '';
    } catch (_) {
      return '';
    }
  }

  String _purityNameFor(int? code) {
    if (code == null) return '';
    try {
      return context
              .read<PurityProvider>()
              .list
              .firstWhere((p) => p.purityCode == code)
              .purityName ??
          '';
    } catch (_) {
      return '';
    }
  }

  String _employeeNameFor(int? code) {
    if (code == null) return '';
    try {
      return context
              .read<EmployeeProvider>()
              .list
              .firstWhere((e) => e.employeeCode == code)
              .employeeName ??
          '';
    } catch (_) {
      return '';
    }
  }

  String _signerNameFor(int? crId) {
    if (crId == null) return '';
    try {
      return context
              .read<CounterProvider>()
              .list
              .firstWhere((c) => c.crId == crId)
              .logInName ??
          '';
    } catch (_) {
      return '';
    }
  }

  String _remarksNameFor(int? code) {
    if (code == null) return '';
    try {
      return context
              .read<RemarksProvider>()
              .list
              .firstWhere((r) => r.remarksCode == code)
              .remarksName ??
          '';
    } catch (_) {
      return '';
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  MERGED FIELD HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  /// Returns DEPT-scoped entry fields (excluding CHARNI, TENSIONS, ALL),
  /// de-duped by name. TO-fields win over FROM-fields on name collision.
  Map<String, UserVisibilityModel> _getMergedFields() {
    const excluded = {'CHARNI', 'TENSIONS', 'ALL'};
    final merged = <String, UserVisibilityModel>{};

    for (final f in [..._fromDisplayFields, ..._toDisplayFields]) {
      if (f.entryType != 'DEPT') continue;
      final name = (f.userVisibilityName ?? '').toUpperCase();
      if (excluded.contains(name)) continue;
      merged[name] = f;
    }
    return merged;
  }

  /// Returns radio-option fields (BCODE, ID, JNO, CUT LOT, QR CODE) sourced
  /// from EITHER _fromDisplayFields OR _toDisplayFields — whichever has them.
  /// FROM-fields are checked first; TO-fields fill in anything missing.
  /// This means radio buttons appear as long as at least one list carries them,
  /// even if the other list is empty or doesn't have those field names.
  Map<String, UserVisibilityModel> _getRadioFields() {
    const radioNames = {'BCODE', 'ID', 'JNO', 'CUT LOT', 'QR CODE'};
    final result = <String, UserVisibilityModel>{};

    // FROM first — these are the "scan source" fields
    for (final f in _fromDisplayFields) {
      final name = (f.userVisibilityName ?? '').toUpperCase();
      if (radioNames.contains(name)) result[name] = f;
    }

    // TO fills in any radio names not already found in FROM
    for (final f in _toDisplayFields) {
      final name = (f.userVisibilityName ?? '').toUpperCase();
      if (radioNames.contains(name) && !result.containsKey(name)) {
        result[name] = f;
      }
    }

    return result;
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  INIT
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.wait([
        context.read<TrnLaserReceivedProvider>().load(),
        context.read<CounterProvider>().load(),
        context.read<CounterManagerDetProvider>().load(),
        context.read<DeptProvider>().load(),
        context.read<DeptGroupProvider>().load(),
        context.read<DeptProcessProvider>().load(),
        context.read<CharniProvider>().load(),
        context.read<TensionsProvider>().load(),
        context.read<CounterDisplayDetProvider>().load(),
        context.read<UserVisibilityProvider>().load(),
        context.read<EmployeeProvider>().loadEmployees(),
        context.read<RemarksProvider>().load(),
        context.read<ShapeProvider>().load(),
        context.read<PurityProvider>().load(),
      ]);
      if (!mounted) return;
      _setDefaultFormValues();

      // Auto-fill FROM from logged-in user
      final loggedUser = context.read<AuthProvider>().user;
      if (loggedUser?.crId != null) {
        _onFromSelected(loggedUser!.crId!.toString());
      }
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  DEFAULT FORM VALUES
  // ─────────────────────────────────────────────────────────────────────────

  void _setDefaultFormValues() {
    final now = DateTime.now();
    _formValues = {
      'spkDeptIssDate': DateFormat('dd/MM/yyyy').format(now),
      'spkDeptIssMstID': '0',
      'time': DateFormat('hh:mm a').format(now),
    };
    if (mounted) setState(() {});
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  LOAD DISPLAY FIELDS
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _loadFromDisplayFields(int crId) async {
    final counter = context.read<CounterProvider>().list.firstWhereOrNull(
      (c) => c.crId == crId,
    );
    if (counter == null || counter.counterMstID == null) return;

    await _displayProv.loadByCounter(counter.counterMstID!);
    if (!mounted) return;

    setState(() {
      _fromDisplayFields = _buildVisibilityList(
        rawList: _displayProv.counterList,
        counterType: 'FROM',
      );
    });
  }

  Future<void> _loadToDisplayFields(int crId) async {
    final counter = context.read<CounterProvider>().list.firstWhereOrNull(
      (c) => c.crId == crId,
    );
    if (counter == null || counter.counterMstID == null) return;

    await _displayProv.loadByCounter(counter.counterMstID!);
    if (!mounted) return;

    setState(() {
      _toDisplayFields = _buildVisibilityList(
        rawList: _displayProv.counterList,
        counterType: 'TO',
      );
    });
  }

  /// Shared logic for building a sorted, validated UserVisibilityModel list.
  List<UserVisibilityModel> _buildVisibilityList({
    required List<dynamic> rawList,
    required String counterType,
  }) {
    return rawList
        .where(
          (r) =>
              r.counterType == counterType &&
              r.userVisibilityCode != null &&
              _visProv.list.any(
                (v) => v.userVisibilityCode == r.userVisibilityCode,
              ),
        )
        .map(
          (r) => _visProv.list.firstWhereOrNull(
            (v) => v.userVisibilityCode == r.userVisibilityCode,
          ),
        )
        .where(
          (v) =>
              v != null &&
              v!.userVisibilityCode != null &&
              (v.userVisibilityName ?? '').isNotEmpty,
        )
        .cast<UserVisibilityModel>()
        .toList()
      ..sort((a, b) => (a.sortID ?? 0).compareTo(b.sortID ?? 0));
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  SELECTION HANDLERS
  // ─────────────────────────────────────────────────────────────────────────

  void _onFromSelected(String crIdStr) {
    final crId = int.tryParse(crIdStr);
    if (crId == null) return;

    try {
      final counter = context.read<CounterProvider>().list.firstWhere(
        (c) => c.crId == crId,
      );
      final deptName = _deptNameFor(counter.deptCode);

      setState(() {
        _fromCrId = crId;
        _fromDeptName = deptName;
        _fromDeptCode = counter.deptCode;
        _toCrId = null;
        _toDeptName = null;
        _formValues['fromCrId'] = crIdStr;
        _formValues['fromDept'] = deptName;
      });

      _erpFormKey.currentState?.updateFieldValue('fromDept', deptName);
      _erpFormKey.currentState?.updateFieldValue('toCrId', '');
      _erpFormKey.currentState?.updateFieldValue('toDept', '');
      _erpFormKey.currentState?.updateFieldValue('deptProcessCode', '');
      _erpFormKey.currentState?.updateFieldValue('deptName', '');

      _loadFromDisplayFields(crId);
    } catch (_) {}
  }

  void _onToSelected(String crIdStr) {
    final crId = int.tryParse(crIdStr);
    if (crId == null) return;

    try {
      final counter = context.read<CounterProvider>().list.firstWhere(
        (c) => c.crId == crId,
      );
      final deptName = _deptNameFor(counter.deptCode);

      setState(() {
        _toCrId = crId;
        _toDeptName = deptName;
        _toDeptCodeVal = counter.deptCode;
        _formValues['toCrId'] = crIdStr;
        _formValues['toDept'] = deptName;
      });

      _erpFormKey.currentState?.updateFieldValue('toDept', deptName);
      _erpFormKey.currentState?.updateFieldValue('deptName', deptName);
      _erpFormKey.currentState?.updateFieldValue('deptProcessCode', '');

      _loadToDisplayFields(crId);
    } catch (_) {}
  }

  Future<void> _onProcessSelected(String procCodeStr) async {
    _formValues['deptProcessCode'] = procCodeStr;

    if (procCodeStr.isEmpty || _toCrId == null) {
      setState(() => _processSelected = false);
      return;
    }

    await _loadToDisplayFields(_toCrId!);
    if (!mounted) return;

    // Ensure form-value maps have entries for all dynamic fields
    for (final f in _toDisplayFields) {
      if (f.userVisibilityCode == null) continue;
      _formValues['entry_${f.userVisibilityCode}'] ??= '';
      _formValues['to_${f.userVisibilityCode}'] ??= '';
    }
    for (final f in _fromDisplayFields) {
      if (f.userVisibilityCode == null) continue;
      _formValues['from_${f.userVisibilityCode}'] ??= '';
    }

    // Use _getRadioFields so radio options appear even if only one list has them
    final radioFields = _getRadioFields();
    final firstRadio = radioFields.values.firstOrNull;

    setState(() {
      // Process is considered selected if either list has fields to show
      _processSelected =
          _toDisplayFields.isNotEmpty || _fromDisplayFields.isNotEmpty;
      _isAdding = _processSelected;

      // Preserve master-field display values after rebuild
      _formValues['deptName'] = _toDeptName ?? '';
      _formValues['toDept'] = _toDeptName ?? '';
      _formValues['fromDept'] = _fromDeptName ?? '';
      _formValues['toCrId'] = _toCrId?.toString() ?? '';
      _formValues['fromCrId'] = _fromCrId?.toString() ?? '';

      if (firstRadio != null) {
        _selectedRadioCode = firstRadio.userVisibilityCode.toString();
        _formValues['scanType'] = _selectedRadioCode!;
      }
    });

    _rebuildForm();
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  BCODE SCAN
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _onBCodeScanned(String bCode) async {
    final rows = await context.read<TrnLaserReceivedProvider>().fetchByBCode(
      bCode: bCode,
      fromCrId: _fromCrId!.toString(),
    );
    if (!mounted) return;
    _isBCodePending = false;

    if (rows.isEmpty) {
      ErpResultDialog.showError(
        context: context,
        theme: _theme,
        title: 'BCode',
        message: 'BCode "$bCode" not found!',
      );
      _entryVals['scanValue'] = '';
      _erpFormKey.currentState?.updateFieldValue('scanValue', '');
      Future.delayed(
        const Duration(milliseconds: 100),
        () => _erpFormKey.currentState?.focusField('scanValue'),
      );
      return;
    }

    final r = rows.first;

    void set(String k, String? v) {
      _entryVals[k] = v ?? '';
      _erpFormKey.currentState?.updateFieldValue(k, v ?? '');
    }

    set('orgPc', r.pc?.toString());
    set('orgWt', fThreeDecimal(r.wt));
    set('issPc', r.issPc?.toString());
    set('issWt', fThreeDecimal(r.issWt));
    set('recPc', r.recPc?.toString());
    set('recWt', fThreeDecimal(r.recWt));
    set('dmWt', fThreeDecimal(r.dmWt));
    set('dmPer', fThreeDecimal(r.dmPer));
    set('jnoRecPc', r.jnoRecPc?.toString());
    set('shapeCode', r.shapeCode?.toString());
    set('purityCode', r.purityCode?.toString());

    setState(() => _scannedDet = r);

    Future.delayed(
      const Duration(milliseconds: 100),
      () => _erpFormKey.currentState?.focusField('recpc'),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  CALCULATIONS
  // ─────────────────────────────────────────────────────────────────────────

  /// DM WT = (Rec WT > 0 ? Rec WT : Iss WT) × DM % / 100
  void _calcDmWt() {
    final recWt = double.tryParse(_entryVals['recWt'] ?? '') ?? 0;
    final issWt = double.tryParse(_entryVals['issWt'] ?? '') ?? 0;
    final base = recWt > 0 ? recWt : issWt;
    final dmPer = double.tryParse(_entryVals['dmPer'] ?? '') ?? 0;
    final dmWt = base * dmPer / 100;
    _entryVals['dmWt'] = fThreeDecimal(dmWt);
    _erpFormKey.currentState?.updateFieldValue('dmWt', fThreeDecimal(dmWt));
  }

  void _calcLoss() {
    final issWt = double.tryParse(_entryVals['issWt'] ?? '') ?? 0;
    final recWt = double.tryParse(_entryVals['recWt'] ?? '') ?? 0;
    final topsWt = double.tryParse(_entryVals['topsWt'] ?? '') ?? 0;

    final lossWt = issWt - (recWt + topsWt);

    _entryVals['lossWt'] = fThreeDecimal(lossWt);
    _erpFormKey.currentState?.updateFieldValue('lossWt', fThreeDecimal(lossWt));
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  ADD / EDIT ENTRY
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _addEntry() async {
    // Resolve selected scan-type name from radio fields (either list)
    final selectedName = () {
      final f = _getRadioFields().values.firstWhereOrNull(
        (f) => f.userVisibilityCode.toString() == _selectedRadioCode,
      );
      return (f?.userVisibilityName ?? '').toUpperCase();
    }();

    // BCODE guard — must scan before adding
    if (selectedName == 'BCODE' && _editingDetIndex == null) {
      if (_scannedDet == null) {
        _isBCodePending = false;
        Future.delayed(
          const Duration(milliseconds: 50),
          () => _erpFormKey.currentState?.focusField('scanValue'),
        );
        return;
      }
    }
    final issPc = int.tryParse(_entryVals['issPc'] ?? '') ?? 0;
    final issWt = double.tryParse(_entryVals['issWt'] ?? '') ?? 0;
    final recPc = int.tryParse(_entryVals['recPc'] ?? '') ?? 0;
    final recWt = double.tryParse(_entryVals['recWt'] ?? '') ?? 0;
    final kPc = int.tryParse(_entryVals['kpc'] ?? '') ?? 0;
    final kWt = double.tryParse(_entryVals['kwt'] ?? '') ?? 0;

    final issPcStr = _entryVals['issPc'] ?? '';
    final issWtStr = _entryVals['issWt'] ?? '';
    final srno = _editingDetIndex != null
        ? _detRows[_editingDetIndex!].srno
        : _detRows.length + 1;

    final newRow = _editingDetIndex != null
        ? _buildEditedRow(
            srno: srno,
            existing: _detRows[_editingDetIndex!],
            issPcStr: issPcStr,
            issWtStr: issWtStr,
            recPc: recPc,
            recWt: recWt,
          )
        : _buildNewRow(
            srno: srno,
            issPcStr: issPcStr,
            issWtStr: issWtStr,
            recPc: recPc,
            recWt: recWt,
          );

    setState(() {
      if (_editingDetIndex != null) {
        _detRows[_editingDetIndex!] = newRow;
        _editingDetIndex = null;
      } else {
        _detRows.add(newRow);
      }
      _lockMasterFields = true;
      _syncDetGrid();
    });

    _entryVals.remove('recWt');
    _entryVals.remove('topsPc');
    _entryVals.remove('topsWt');
    _entryVals.remove('partName');
    _erpFormKey.currentState?.updateFieldValue('recWt', '');
    _erpFormKey.currentState?.updateFieldValue('topsPc', '');
    _erpFormKey.currentState?.updateFieldValue('topsWt', '');
    _erpFormKey.currentState?.updateFieldValue('partName', '');

    // Return focus to scan field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 50), () {
        _erpFormKey.currentState?.focusField('recWt');
      });
    });

    _erpFormKey.currentState?.setFieldReadOnly('fromCrId', true);
    _erpFormKey.currentState?.setFieldReadOnly('toCrId', true);
    _erpFormKey.currentState?.setFieldReadOnly('deptProcessCode', true);
    _erpFormKey.currentState?.setFieldReadOnly('topsPc', true);
    _erpFormKey.currentState?.setFieldReadOnly('topsWt', true);
  }

  /// Build a detail row for an existing (edit) record.
  LaserDetModel _buildEditedRow({
    required int? srno,
    required LaserDetModel existing,
    required String issPcStr,
    required String issWtStr,
    required int recPc,
    required double recWt,
  }) {
    final recWtVal = double.tryParse(_entryVals['recWt'] ?? '0') ?? 0;
    final topsWtVal = double.tryParse(_entryVals['topsWt'] ?? '0') ?? 0;

    // ✅ ONLY row-level calculation
    final issWtVal = double.tryParse(_entryVals['issWt'] ?? '0') ?? 0;
    final lossWtVal = issWtVal - (recWtVal + topsWtVal);
    final lossPerVal = issWtVal > 0 ? (lossWtVal / issWtVal) * 100 : 0.0;

    return LaserDetModel(
      srno: srno,
      spkDeptIssMstID: existing.spkDeptIssMstID,
      // Preserved scan data
      id: existing.id,
      jno: existing.jno,
      bCode: existing.bCode,
      pktNo: existing.pktNo,
      cutNo: existing.cutNo,
      clvCut: existing.clvCut,
      shapeCode: existing.shapeCode,
      purityCode: existing.purityCode,
      colorCode: existing.colorCode,
      diam: existing.diam,
      kachaRec: existing.kachaRec,
      qrCode: existing.qrCode,
      entryType: existing.entryType,
      formType: existing.formType,
      pktType: existing.pktType,
      fromDeptCode: _fromDeptCode,
      toDeptCode: _toDeptCodeVal,
      fromCrId: _fromCrId,
      toCrId: _toCrId,
      deptCode: _toDeptCodeVal,
      fType: _isMackable ? 'MAKABLE' : 'SUBPACKET',
      deptProcessCode: int.tryParse(_formValues['deptProcessCode'] ?? ''),
      // User-entered fields
      pc: recPc,
      wt: recWt,
      issPc: int.tryParse(issPcStr),
      issWt: double.tryParse(issWtStr),
      recPc: recPc,
      recWt: recWt,
      totalPc: recPc,
      totalWt: recWt,
      dmWt: double.tryParse(_entryVals['dmWt'] ?? '0'),
      dmPer: double.tryParse(_entryVals['dmPer'] ?? '0'),
      kPc: int.tryParse(_entryVals['kpc'] ?? ''),
      kWt: double.tryParse(_entryVals['kwt'] ?? ''),
      brPc: int.tryParse(_entryVals['brpc'] ?? ''),
      brWt: double.tryParse(_entryVals['brwt'] ?? ''),
      lossWt: lossWtVal,
      lossPer: lossPerVal,
      topsPc: int.tryParse(_entryVals['topsPc'] ?? ''),
      topsWt: double.tryParse(_entryVals['topsWt'] ?? ''),
      tensionsCode: int.tryParse(_formValues['tensionsCode'] ?? ''),
      employeeCode: int.tryParse(_entryVals['employee'] ?? ''),
      signerCode: int.tryParse(_entryVals['signer'] ?? ''),
      remarksCode: int.tryParse(_entryVals['remarks'] ?? ''),
      dueDay: int.tryParse(_entryVals['dueDay'] ?? ''),
      partName: int.tryParse(_entryVals['partName'] ?? '0'),
      confRec: 'Y',
      clvRec: 'N',
    );
  }

  /// Build a detail row for a new (add) record.
  LaserDetModel _buildNewRow({
    required int? srno,
    required String issPcStr,
    required String issWtStr,
    required int recPc,
    required double recWt,
  }) {
    final isFirstRow = srno == 1;

    final recWtVal = double.tryParse(_entryVals['recWt'] ?? '0') ?? 0;
    final topsWtVal = double.tryParse(_entryVals['topsWt'] ?? '0') ?? 0;

    // ✅ ONLY row-level calculation
    final issWtVal = double.tryParse(_entryVals['issWt'] ?? '0') ?? 0;

    final lossWtVal = issWtVal - (recWtVal + topsWtVal);

    final lossPerVal = issWtVal > 0 ? (lossWtVal / issWtVal) * 100 : 0.0;

    return LaserDetModel(
      srno: srno,
      id: _scannedDet?.id,
      jno: _scannedDet?.jno,
      jnoRecPc: _scannedDet?.jnoRecPc,
      bCode: isFirstRow ? (_scannedDet?.bCode ?? _entryVals['scanValue']) : '0',

      pktNo: isFirstRow ? _scannedDet?.pktNo : '',
      cutNo: _scannedDet?.cutNo,
      clvCut: _scannedDet?.clvCut,
      shapeCode: _scannedDet?.shapeCode,
      purityCode: _scannedDet?.purityCode,
      colorCode: _scannedDet?.colorCode,
      diam: _scannedDet?.diam,
      kachaRec: _scannedDet?.kachaRec ?? 'Y',
      fromDeptCode: _fromDeptCode,
      toDeptCode: _toDeptCodeVal,
      fromCrId: _fromCrId,
      toCrId: _toCrId,
      deptCode: _toDeptCodeVal,
      fType: _isMackable ? 'MAKABLE' : 'SUBPACKET',
      deptProcessCode: int.tryParse(_formValues['deptProcessCode'] ?? ''),
      tensionsCode: int.tryParse(_formValues['tensionsCode'] ?? ''),
      pc: recPc,
      wt: recWt,
      issPc: int.tryParse(issPcStr),
      issWt: double.tryParse(issWtStr),
      recPc: recPc,
      recWt: recWt,
      totalPc: recPc,
      totalWt: recWt,
      dmWt: double.tryParse(_entryVals['dmWt'] ?? '0'),
      dmPer: double.tryParse(_entryVals['dmPer'] ?? '0'),
      kPc: int.tryParse(_entryVals['kpc'] ?? ''),
      kWt: double.tryParse(_entryVals['kwt'] ?? ''),
      brPc: int.tryParse(_entryVals['brpc'] ?? ''),
      brWt: double.tryParse(_entryVals['brwt'] ?? ''),
      lossWt: isFirstRow ? lossWtVal : 0.000,
      lossPer: isFirstRow ? lossPerVal : 0.00,
      topsPc: int.tryParse(_entryVals['topsPc'] ?? ''),
      topsWt: double.tryParse(_entryVals['topsWt'] ?? ''),
      employeeCode: int.tryParse(_entryVals['employee'] ?? ''),
      signerCode: int.tryParse(_entryVals['signer'] ?? ''),
      remarksCode: int.tryParse(_entryVals['remark'] ?? ''),
      dueDay: int.tryParse(_entryVals['dueDay'] ?? ''),
      entryType: 'B',
      formType: 'LASER_RECEIVED',
      pktType: 'A',
      partName: int.tryParse(_entryVals['partName'] ?? '0'),
      confRec: 'Y',
      clvRec: 'N',
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  EDIT / DELETE DET ROW
  // ─────────────────────────────────────────────────────────────────────────

  void _editDetRow(int idx) {
    final r = _detRows[idx];
    setState(() => _editingDetIndex = idx);

    void set(String k, String? v) {
      _entryVals[k] = v ?? '';
      _erpFormKey.currentState?.updateFieldValue(k, v ?? '');
    }

    set('orgPc', r.pc?.toString());
    set('orgWt', fThreeDecimal(r.wt));
    set('issPc', r.issPc?.toString());
    set('issWt', fThreeDecimal(r.issWt));
    set('recPc', r.recPc?.toString());
    set('recWt', fThreeDecimal(r.recWt));
    set('dmPer', r.dmPer?.toStringAsFixed(2));
    set('dmWt', fThreeDecimal(r.dmWt));
    set('kpc', r.kPc?.toString());
    set('kwt', fThreeDecimal(r.kWt));
    set('brpc', r.brPc?.toString());
    set('brwt', fThreeDecimal(r.brWt));
    set('lossPc', r.lossPc?.toString());
    set('lossWt', fThreeDecimal(r.lossWt));
    set('topsPc', r.topsPc?.toString());
    set('topsWt', fThreeDecimal(r.topsWt));
    set('employee', r.employeeCode?.toString());
    set('signer', r.signerCode?.toString());
    set('remarks', r.remarksCode?.toString());
    set('dueDay', r.dueDay?.toString());
    set('partName', r.partName?.toString());
  }

  void _deleteDetRow(int idx) {
    setState(() {
      if (_detRows.isEmpty) return;

      // ✅ Correct types
      final double firstIssWt = _detRows.first.issWt ?? 0.0;
      final int firstIssPc = _detRows.first.issPc ?? 0;
      dynamic bCode = _detRows.first.bCode ?? 0;
      dynamic pktNo = _detRows.first.pktNo ?? 0;

      _detRows.removeAt(idx);

      if (_detRows.isEmpty) {
        _syncDetGrid();
        return;
      }

      _detRows = _detRows.asMap().entries.map((e) {
        final i = e.key;
        final v = e.value;

        final double issWt = (i == 0) ? firstIssWt : 0.0;
        final int issPc = (i == 0) ? firstIssPc : 0;

        final double recWt = v.recWt ?? 0;
        final double topsWt = v.topsWt ?? 0;

        final double lossWt = issWt - (recWt + topsWt);
        final double lossPer = issWt > 0 ? (lossWt / issWt) * 100 : 0.0;

        return LaserDetModel(
          srno: i + 1,
          spkDeptIssMstID: v.spkDeptIssMstID,
          id: v.id,
          jno: v.jno,

          bCode: i == 0 ? bCode : '0',
          pktNo: i == 0 ? pktNo : '',
          partName: v.partName,
          cutNo: v.cutNo,
          pc: v.pc,
          wt: v.wt,

          issPc: issPc,
          // ✅ int
          issWt: issWt,

          // ✅ double
          recPc: v.recPc,
          recWt: v.recWt,

          dmPer: v.dmPer,
          dmWt: v.dmWt,

          kPc: v.kPc,
          kWt: v.kWt,
          brPc: v.brPc,
          brWt: v.brWt,

          lossPc: v.lossPc,
          lossWt: lossWt,
          lossPer: lossPer,

          topsPc: v.topsPc,
          topsWt: v.topsWt,

          totalPc: v.totalPc,
          totalWt: v.totalWt,

          tensionsCode: v.tensionsCode,
          employeeCode: v.employeeCode,
          signerCode: v.signerCode,
          remarksCode: v.remarksCode,
          dueDay: v.dueDay,

          fromCrId: v.fromCrId,
          toCrId: v.toCrId,
          fromDeptCode: v.fromDeptCode,
          toDeptCode: v.toDeptCode,
          deptProcessCode: v.deptProcessCode,

          entryType: v.entryType,
          formType: v.formType,
          pktType: v.pktType,

          shapeCode: v.shapeCode,
          purityCode: v.purityCode,
          colorCode: v.colorCode,
          diam: v.diam,
          kachaRec: v.kachaRec,
        );
      }).toList();

      if (_editingDetIndex == idx) {
        _editingDetIndex = null;
      }

      _syncDetGrid();
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  CLEAR ENTRY FIELDS
  // ─────────────────────────────────────────────────────────────────────────

  void _clearEntryFields() {
    const fields = [
      'scanValue',

      'orgPc',
      'orgWt',

      'issPc',
      'issWt',

      'recPc',
      'recWt',

      'dmWt',
      'dmPer',

      'lossWt',

      'topsPc',
      'topsWt',

      'partName',
    ];

    for (final key in fields) {
      _entryVals[key] = '';

      _erpFormKey.currentState?.updateFieldValue(key, '');
    }

    _scannedDet = null;
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  SYNC DET GRID
  // ─────────────────────────────────────────────────────────────────────────

  void _syncDetGrid() {
    int? toDeptCode;
    if (_toCrId != null) {
      try {
        toDeptCode = context
            .read<CounterProvider>()
            .list
            .firstWhere((c) => c.crId == _toCrId)
            .deptCode;
      } catch (_) {}
    }
    _activeDetColumns = [
      'srno',
      'bCode',
      'pktNo',
      'cutNo',
      'recPc',
      'recWt',
      'mackRoughWt', // Plan RgWt
      'dmWt',
      'diffPoWt', // Plan PoWt
      'dmPer',
      'lossWt',
      'lossPer',
      'partName',
      'shapeCode',
      'oldShapeCode', // Plan Shape
      'purityCode',
      'oldPurityCode', // Plan Purity
      'colorCode',
      'oldColorCode', // Plan Color
      'diam',
      'acuraecy', // Accuracy (note: typo in model)
      'sarinOpt', // Sarin Operator
      'sarinMachine',
      'qrCode',
    ];
    double totalLossWt = _detRows.isNotEmpty
        ? (_detRows.first.issWt ?? 0) -
              (_detRows.fold(0.0, (s, r) => s + (r.recWt ?? 0)) +
                  _detRows.fold(0.0, (s, r) => s + (r.topsWt ?? 0)))
        : 0.0;

    double totalIssWt = _detRows.isNotEmpty ? (_detRows.first.issWt ?? 0) : 0.0;
    print(jsonEncode(_detRows.first));
    _detDisplay = _detRows.map((r) {
      final isFirst = r.srno == 1; // ← add this

      return {
        'SPKDeptIssMstID': r.spkDeptIssMstID,
        'srno': r.srno?.toString() ?? '',
        'bCode': r.bCode ?? '',
        'pktNo': r.pktNo ?? '',
        'cutNo': r.cutNo ?? '',
        'length': r.length ?? 0,
        'acuraecy': r.acuraecy ?? 0,
        "pc": r.pc,
        "wt": r.wt,
        "issPc": r.issPc,
        "issWt": r.issWt,
        "totalPc": r.totalPc,
        "totalWt": r.totalWt,
        "kWt": r.kWt,
        "brWt": r.brWt,
        "topsPc": r.topsPc,
        "topsWt": r.topsWt,
        'recPc': r.recPc?.toString() ?? '',
        'recWt': fThreeDecimal(r.recWt),
        'mackRoughWt': fThreeDecimal(r.mackRoughWt),
        'dmWt': fThreeDecimal(r.dmWt),
        'diffPoWt': fThreeDecimal(r.diffPoWt),
        'dmPer': r.dmPer?.toStringAsFixed(2) ?? '',
        'lossWt': isFirst ? fThreeDecimal(totalLossWt) : '0.000',
        'lossPer': isFirst
            ? (totalIssWt > 0 ? (totalLossWt / totalIssWt) * 100 : 0)
                  .toStringAsFixed(2)
            : '0.00',
        'partName': r.partName?.toString() ?? '',
        'shapeCode': r.shapeCode,
        'oldShapeCode': r.oldShapeCode ?? '0',
        'purityCode': r.purityCode,
        'oldPurityCode': r.oldPurityCode ?? '0',
        'colorCode': r.colorCode?.toString() ?? '',
        'oldColorCode': r.oldColorCode?.toString() ?? '0',
        'diam': r.diam?.toStringAsFixed(2) ?? '0',
        'sarinOpt': r.sarinOpt ?? '',
        'sarinMachine': r.sarinMachine ?? '',
        'qrCode': r.qrCode ?? '',
        'remarkCode': _entryVals['remark'] ?? '',
        'fType': _isMackable ? 'MAKABLE' : 'SUBPACKET',
        'FormType': 'LASERREC',
        'DeptCode': toDeptCode?.toString() ?? '',
        'DeptProcessCode': _formValues['deptProcessCode'] ?? '',
        'FromCrID': _fromCrId,
        'ToCrID': _toCrId,
        'confRec': 'Y',
        'clvRec': 'N',
      };
    }).toList();
  }

  void _syncLaserApiGrid() {
    _laserApiDisplay = _laserApiRows.map((r) {
      return Map<String, dynamic>.from(jsonDecode(jsonEncode(r)));
    }).toList();
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  ROW TAP (load existing record)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _onRowTap(Map<String, dynamic> row) async {
    final raw = row['_raw'] as LaserMstModel;
    final prov = context.read<TrnLaserReceivedProvider>();
    final details = await prov.loadDetails(raw.spkDeptIssMstID!);
    if (!mounted) return;

    if (raw.fromCrID != null) _onFromSelected(raw.fromCrID.toString());
    if (raw.toCrID != null) _onToSelected(raw.toCrID.toString());

    if (raw.deptProcessCode != null && _toCrId != null && _fromCrId != null) {
      await _loadToDisplayFields(_toCrId!);
      await _loadFromDisplayFields(_fromCrId!);
    }
    if (!mounted) return;

    // Set first radio option — use _getRadioFields so it works even if
    // only one of the two lists contains these field names
    final firstRadio = _getRadioFields().values.firstOrNull;
    if (firstRadio != null) {
      _selectedRadioCode = firstRadio.userVisibilityCode.toString();
    }

    setState(() {
      _selectedRow = row;
      _selectedMst = raw;
      _isEditMode = true;
      _laserApiRows = details;
      _syncLaserApiGrid();
      _editingDetIndex = null;
      _processSelected = raw.deptProcessCode != null;
      _isAdding = false;
      _showTableOnMobile = false;
      setState(() {
        _isMackable = details.first.fType.toString() == 'MACKABLE'
            ? true
            : false;
      });
      _formValues = {
        'spkDeptIssMstID': raw.spkDeptIssMstID?.toString() ?? '0',
        'spkDeptIssDate': toDisplayDate(raw.spkDeptIssDate),
        'time': _formatTime(raw.stime),
        'fromCrId': raw.fromCrID?.toString() ?? '',
        'fromDept': _fromDeptName ?? '',
        'toCrId': raw.toCrID?.toString() ?? '',
        'toDept': _toDeptName ?? '',
        'deptProcessCode': details.first.deptProcessCode.toString(),
        'deptName': _toDeptName ?? '',
        'remark': details.first.remarksCode.toString(),
        'mackable': details.first.fType.toString() == 'MACKABLE' ? 'Y' : 'N',
      };
      _entryVals['scanValue'] = details.first.bCode.toString();
      // _syncDetGrid();
    });

    _rebuildForm();
  }

  /// Format an ISO time string to "hh:mm a".
  String _formatTime(String? raw) {
    if (raw == null || raw.isEmpty) {
      return DateFormat('hh:mm a').format(DateTime.now());
    }
    try {
      return DateFormat('hh:mm a').format(DateTime.parse(raw));
    } catch (_) {
      return raw;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  DELETE
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _onDelete() async {
    if (_selectedMst?.spkDeptIssMstID == null) return;

    final confirm = await ErpDeleteDialog.show(
      context: context,
      theme: _theme,
      title: 'Laser Received',
      itemName: 'ID: ${_selectedMst!.spkDeptIssMstID}',
    );
    if (confirm != true || !mounted) return;

    final success = await context.read<TrnLaserReceivedProvider>().delete(
      _selectedMst!.spkDeptIssMstID!,
    );

    if (success && mounted) {
      final id = _selectedMst?.spkDeptIssMstID;
      _resetForm();
      await ErpResultDialog.showDeleted(
        context: context,
        theme: _theme,
        itemName: 'Laser Received $id',
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  RESET
  // ─────────────────────────────────────────────────────────────────────────

  void _resetForm() {
    _erpFormKey.currentState?.resetForm();
    _entryVals.clear();
    setState(() {
      _selectedRow = _selectedMst = null;
      _isEditMode = _showTableOnMobile = false;
      _isAdding = false;
      _detRows = [];
      _detDisplay = [];
      _editingDetIndex = null;
      _fromCrId = _toCrId = null;
      _fromDeptName = _toDeptName = null;
      _fromDeptCode = _toDeptCodeVal = null;
      _processSelected = false;
      _lockMasterFields = false;
      _scannedDet = null;
      _selectedRadioCode = null;
      _toDisplayFields.clear();
      _fromDisplayFields.clear();
      _erpFormKey = GlobalKey<ErpFormState>();
      _formValues.clear();
      _laserApiRows = [];

      _laserApiDisplay = [];
    });
    _setDefaultFormValues();
  }

  void _rebuildForm() {
    setState(() => _erpFormKey = GlobalKey<ErpFormState>());
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  SNACKBAR
  // ─────────────────────────────────────────────────────────────────────────

  void _showSnack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  // ─────────────────────────────────────────────────────────────────────────
  //  BUILD FORM ROWS
  // ─────────────────────────────────────────────────────────────────────────
  List<List<ErpFieldConfig>> _buildFormRows() {
    final counterProv = context.read<CounterProvider>();
    final mgDetProv = context.read<CounterManagerDetProvider>();
    final procProv = context.read<DeptProcessProvider>();
    final charniProv = context.read<CharniProvider>();
    final tensProv = context.read<TensionsProvider>();
    final remarkProv = context.read<RemarksProvider>();
    //CUT
    final remarkItems = remarkProv.list.where((e) => e.active == true).toList()
      ..sort((a, b) => (a.sortID ?? 0).compareTo(b.sortID ?? 0));
    final remarkDropdown = remarkItems
        .map(
          (e) => ErpDropdownItem(
            label: e.remarksName ?? '',
            value: e.remarksCode?.toString() ?? '',
          ),
        )
        .toList();
    final isFromSelected = _fromCrId != null;
    final isToSelected = _toCrId != null;

    // ── FROM dropdown ────────────────────────────────────────────────────────
    final fromItems = counterProv.list
        .where((c) {
          final grp = _deptGroupNameFor(c.deptGroupCode).toUpperCase();
          return grp.contains('CLEAVING') || grp.contains('CLV');
        })
        .map(
          (c) => ErpDropdownItem(
            label: '${c.crName ?? ''}  |  ${_deptNameFor(c.deptCode)}',
            value: c.crId?.toString() ?? '',
          ),
        )
        .toList();

    // ── TO dropdown — allowCrIds from CounterManagerDet ───────────────────
    final toItems = _fromCrId == null
        ? <ErpDropdownItem>[]
        : mgDetProv.list
              .where((m) => m.crId == _fromCrId && m.allowCrId != null)
              .map((m) => m.allowCrId!)
              .toSet()
              .map((allowId) {
                try {
                  final c = counterProv.list.firstWhere(
                    (c) => c.crId == allowId && c.active == true,
                  );

                  // OPTIONAL:
                  // avoid same FROM manager in TO
                  if (c.crId == _fromCrId) {
                    return null;
                  }

                  return ErpDropdownItem(
                    label: '${c.crName ?? ''} | ${_deptNameFor(c.deptCode)}',
                    value: c.crId?.toString() ?? '',
                  );
                } catch (_) {
                  return null;
                }
              })
              .whereType<ErpDropdownItem>()
              .toList();

    // ── PROCESS dropdown — intersection of FROM-issue ∩ TO-receive codes ──
    final processItems = (_fromCrId == null || _toCrId == null)
        ? <ErpDropdownItem>[]
        : () {
            final issueCodes = mgDetProv.list
                .where((m) => m.crId == _fromCrId && m.deptProcessCode != null)
                .map((m) => m.deptProcessCode!)
                .toSet();

            final recvCodes = mgDetProv.list
                .where(
                  (m) => m.allowCrId == _toCrId && m.deptProcessCode != null,
                )
                .map((m) => m.deptProcessCode!)
                .toSet();

            return issueCodes.intersection(recvCodes).map((code) {
              String label = '$code';
              try {
                label =
                    procProv.list
                        .firstWhere((p) => p.deptProcessCode == code)
                        .deptProcessName ??
                    '$code';
              } catch (_) {}
              return ErpDropdownItem(label: label, value: code.toString());
            }).toList();
          }();
    // ── TENSIONS dropdown ─────────────────────────────────────────────────
    final tensItems = tensProv.list.where((e) => e.active == true).toList()
      ..sort((a, b) => (a.sortID ?? 0).compareTo(b.sortID ?? 0));
    final tensDropdown = tensItems
        .map(
          (e) => ErpDropdownItem(
            label: e.tensionsName ?? '',
            value: e.tensionsCode?.toString() ?? '',
          ),
        )
        .toList();

    // ── Merged DEPT fields (deduped) ──────────────────────────────────────
    final Map<String, UserVisibilityModel> merged = {};
    for (final f in [..._fromDisplayFields, ..._toDisplayFields]) {
      final name = (f.userVisibilityName ?? '').toUpperCase();
      if (f.entryType != 'DEPT') continue;
      if (['ALL'].contains(name)) continue;
      merged[name] = f;
    }

    // ─────────────────────────────────────────────────────────────────────
    //  MASTER SECTION (sectionIndex 0)
    // ─────────────────────────────────────────────────────────────────────
    final List<List<ErpFieldConfig>> rows = [
      // Row 1 — date / time / ID
      [
        ErpFieldConfig(
          key: 'spkDeptIssDate',
          label: 'DATE',
          type: ErpFieldType.date,
          readOnly: true,
          sectionIndex: 0,
        ),
        ErpFieldConfig(
          key: 'time',
          label: 'TIME',
          type: ErpFieldType.text,
          readOnly: true,
          sectionIndex: 0,
        ),
        ErpFieldConfig(
          key: 'spkDeptIssMstID',
          label: 'ID',
          type: ErpFieldType.number,
          readOnly: true,
          sectionIndex: 0,
        ),
      ],
      // Row 2 — FROM / TO / PROCESS
      [
        ErpFieldConfig(
          key: 'fromCrId',
          label: 'FROM',
          type: ErpFieldType.dropdown,
          dropdownItems: fromItems,
          sectionIndex: 0,
          readOnly: _lockMasterFields || _isEditMode,
        ),
        ErpFieldConfig(
          key: 'fromDept',
          label: 'MANAGER',
          type: ErpFieldType.text,
          readOnly: true,
          sectionIndex: 0,
        ),
        ErpFieldConfig(
          key: 'toCrId',
          label: 'TO',
          type: ErpFieldType.dropdown,
          dropdownItems: toItems,
          readOnly: !isFromSelected || _lockMasterFields || _isEditMode,
          sectionIndex: 0,
        ),
        ErpFieldConfig(
          key: 'toDept',
          label: 'MANAGER',
          type: ErpFieldType.text,
          readOnly: true,
          sectionIndex: 0,
        ),
        ErpFieldConfig(
          key: 'deptProcessCode',
          label: 'PROCESS',
          type: ErpFieldType.dropdown,
          dropdownItems: processItems,
          readOnly: !isToSelected || _lockMasterFields || _isEditMode,
          sectionIndex: 0,
        ),
        ErpFieldConfig(
          key: 'deptName',
          label: 'DEPT',
          type: ErpFieldType.text,
          readOnly: true,
          sectionIndex: 0,
        ),
      ],
      [
        ErpFieldConfig(
          key: 'remark',
          label: 'REMARK',
          type: ErpFieldType.dropdown,
          dropdownItems: remarkDropdown,
          width: 250,
          sectionIndex: 3,
        ),
        ErpFieldConfig(
          key: 'mackable',
          label: _isMackable ? 'MACKABLE' : 'SUBPACKET',
          type: ErpFieldType.checkbox,
          width: 200,
          sectionIndex: 3,
        ),
        ErpFieldConfig(
          key: 'scanValue',
          label: 'BCODE',
          type: ErpFieldType.text,
          isEntryField: true,
          // readOnly: _detDisplay.isNotEmpty,
          sectionIndex: 3,
          width: 200,
        ),
      ],
    ];

    final isFirstRow = _detRows.isEmpty || _editingDetIndex == 0;
    // ─────────────────────────────────────────────────────────────────────
    //  ENTRY SECTION (sectionIndex 3)
    // ─────────────────────────────────────────────────────────────────────
    final singleRow = <ErpFieldConfig>[
      // ORG
      ErpFieldConfig(
        key: 'orgPc',
        label: 'ORG PC',
        type: ErpFieldType.number,
        readOnly: true,
        isEntryField: true,
        sectionIndex: 3,
        flex: 1,
      ),
      ErpFieldConfig(
        key: 'orgWt',
        label: 'ORG WT',
        type: ErpFieldType.amount,
        readOnly: true,
        isEntryField: true,
        sectionIndex: 3,
        flex: 1,
      ),

      // ISS
      ErpFieldConfig(
        key: 'issPc',
        label: 'ISS PC',
        type: ErpFieldType.number,
        readOnly: true,
        isEntryField: true,
        sectionIndex: 3,
        flex: 1,
      ),
      ErpFieldConfig(
        key: 'issWt',
        label: 'ISS WT',
        type: ErpFieldType.amount,
        readOnly: true,
        isEntryField: true,
        sectionIndex: 3,
        flex: 1,
      ),

      // REC
      ErpFieldConfig(
        key: 'recPc',
        label: 'REC PC',
        type: ErpFieldType.number,
        isEntryField: true,
        sectionIndex: 3,
        flex: 1,
      ),
      ErpFieldConfig(
        key: 'recWt',
        label: 'REC WT',
        type: ErpFieldType.text,
        isEntryField: true,
        sectionIndex: 3,
        flex: 1,
      ),

      // DM
      ErpFieldConfig(
        key: 'dmPer',
        label: 'DM PER',
        type: ErpFieldType.number,
        isEntryField: true,
        readOnly: true,
        sectionIndex: 3,
        flex: 1,
      ),
      ErpFieldConfig(
        key: 'dmWt',
        label: 'DM WT',
        type: ErpFieldType.amount,
        readOnly: true,
        isEntryField: true,
        sectionIndex: 3,
        flex: 1,
      ),

      // LOSS WT
      ErpFieldConfig(
        key: 'lossWt',
        label: 'LOSS WT',
        type: ErpFieldType.amount,
        readOnly: true,
        isEntryField: true,
        sectionIndex: 3,
        flex: 1,
      ),

      // TOPS PC
      ErpFieldConfig(
        key: 'topsPc',
        label: 'TOPS PC',
        type: ErpFieldType.number,
        isEntryField: true,
        sectionIndex: 3,
        readOnly: !isFirstRow,
        flex: 1,
      ),

      // TOPS WT
      ErpFieldConfig(
        key: 'topsWt',
        label: 'TOPS WT',
        type: ErpFieldType.amount,
        isEntryField: true,
        sectionIndex: 3,
        readOnly: !isFirstRow,
        flex: 1,
      ),

      // PART NAME
      ErpFieldConfig(
        key: 'partName',
        label: 'PART NAME',
        type: ErpFieldType.amount,
        isEntryField: true,
        showAddButton: true,
        sectionIndex: 3,
        flex: 1,
      ),
    ];

    rows.add(singleRow);

    return _sanitizeRows(rows);
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  SANITIZE ROWS (null-safety wrapper)
  // ─────────────────────────────────────────────────────────────────────────

  List<List<ErpFieldConfig>> _sanitizeRows(List<List<ErpFieldConfig>> rows) {
    return rows.map((section) {
      return section.whereType<ErpFieldConfig>().map((field) {
        final safeItems = (field.dropdownItems ?? [])
            .whereType<ErpDropdownItem>()
            .where((item) => item.value.isNotEmpty && item.label.isNotEmpty)
            .toList();

        if (safeItems.length == (field.dropdownItems?.length ?? 0)) {
          return field;
        }
        return ErpFieldConfig(
          key: field.key,
          label: field.label,
          type: field.type,
          flex: field.flex,
          readOnly: field.readOnly,
          required: field.required,
          sectionIndex: field.sectionIndex ?? 0,
          sectionTitle: field.sectionTitle,
          isEntryField: field.isEntryField,
          isEntryRequired: field.isEntryRequired,
          showAddButton: field.showAddButton,
          dropdownItems: safeItems,
        );
      }).toList();
    }).toList();
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  TABLE COLUMNS
  // ─────────────────────────────────────────────────────────────────────────

  List<ErpColumnConfig> get _tableColumns => [
    ErpColumnConfig(
      key: 'spkDeptIssMstID',
      label: 'ID',
      width: 70,
      required: true,
    ),
    ErpColumnConfig(
      key: 'spkDeptIssDate',
      label: 'DATE',
      width: 160,
      isDate: true,
    ),
    ErpColumnConfig(key: 'spkDeptIssTime', label: 'TIME', width: 140),
    ErpColumnConfig(key: 'fromName', label: 'FROM MGR', width: 180),
    ErpColumnConfig(key: 'fromDeptName', label: 'FROM DEPT', width: 180),
    ErpColumnConfig(key: 'toName', label: 'TO MGR', width: 160),
    ErpColumnConfig(key: 'toDeptName', label: 'TO DEPT', width: 160),
    ErpColumnConfig(key: 'processName', label: 'PROCESS', width: 150),
    ErpColumnConfig(key: 'deptName', label: 'DEPT', width: 140),
    ErpColumnConfig(
      key: 'jno',
      label: 'JNO',
      width: 140,
      align: ColumnAlign.right,
    ),
    ErpColumnConfig(
      key: 'totPkt',
      label: 'TOT PKT',
      width: 170,
      align: ColumnAlign.right,
    ),
    ErpColumnConfig(
      key: 'totalPc',
      label: 'TOT PC',
      width: 170,
      align: ColumnAlign.right,
    ),
    ErpColumnConfig(
      key: 'totalWt',
      label: 'TOT WT',
      width: 170,
      align: ColumnAlign.right,
    ),
  ];

  // ─────────────────────────────────────────────────────────────────────────
  //  COL LABEL
  // ─────────────────────────────────────────────────────────────────────────

  String _colLabel(String key) {
    const labels = {
      // left grid
      'srno': 'SR NO',
      'bCode': 'BCODE',
      'pktNo': 'PKT NO',
      'cutNo': 'CUT NO',
      'recPc': 'REC PC',
      'recWt': 'REC WT',
      'mackRoughWt': 'PLAN RGWT',
      'dmWt': 'DM WT',
      'diffPoWt': 'PLAN POWT',
      'dmPer': 'DM PER',
      'lossWt': 'LOSS WT',
      'lossPer': 'LOSS PER',
      'partName': 'PART NAME',
      'shapeCode': 'SHAPE',
      'oldShapeCode': 'PLAN SHAPE',
      'purityCode': 'PURITY',
      'oldPurityCode': 'PLAN PURITY',
      'colorCode': 'COLOR',
      'oldColorCode': 'PLAN COLOR',
      'diam': 'DIAM',
      'acuraecy': 'ACCURACY',
      'sarinOpt': 'SARIN OPERATOR',
      'sarinMachine': 'SARIN MACHINE',
      'qrCode': 'QRCODE',
      // right grid
      'rPartName': 'PART',
      'rColor': 'COLOR',
      'rPurity': 'PURITY',
      'rRgWt': 'RGWT',
      'rPoWt': 'POWT',
    };
    return labels[key] ?? key;
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Consumer<TrnLaserReceivedProvider>(
      builder: (ctx, prov, _) => Padding(
        padding: const EdgeInsets.all(8),
        child: Responsive.isMobile(context)
            ? (_showTableOnMobile ? _buildTable(prov) : _buildForm(context))
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!_showTableOnMobile)
                    Expanded(flex: 2, child: _buildForm(context)),
                  if (_showTableOnMobile)
                    Expanded(flex: 2, child: _buildTable(prov)),
                ],
              ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  FORM WIDGET
  // ─────────────────────────────────────────────────────────────────────────
  bool _validateEntry() {
    final recWt = double.tryParse(_entryVals['recWt'] ?? '');
    final recPc = int.tryParse(_entryVals['recPc'] ?? '');
    final topsWt = double.tryParse(_entryVals['topsWt'] ?? '0') ?? 0;

    if (recWt == null || recWt <= 0) {
      _showSnack('Enter valid RecWt');
      _erpFormKey.currentState?.focusField('recWt');
      return false;
    }

    if (recPc == null || recPc <= 0) {
      _showSnack('Enter valid RecPc');
      _erpFormKey.currentState?.focusField('recPc');
      return false;
    }

    if (topsWt < 0) {
      _showSnack('TopsWt cannot be negative');
      _erpFormKey.currentState?.focusField('topsWt');
      return false;
    }
    return true;
  }

  Widget _buildForm(BuildContext context) {
    return ErpForm(
      key: _erpFormKey,
      isShowSearch: true,
      autoStartAdding: _isAdding,
      addButtonSections: const {3},
      logo: AppImages.logo,
      isShowSaveButton: false,
      title: 'LASER RECEIVED ENTRY',
      tabBarBackgroundColor: const Color(0xfff2f0ef),
      tabBarSelectedColor: _theme.primaryGradient.first,
      tabBarSelectedTxtColor: Colors.white,
      rows: _buildFormRows(),
      initialValues: _formValues,
      isEditMode: _isEditMode,

      onEntryAdd: (sectionIndex) {
        if (sectionIndex != 3) return;
        if (!_validateEntry()) return; // ✅ ADD THIS
        _addEntry();
      },

      onFieldChanged: (key, value) async {
        _formValues[key] = value.toString();
        switch (key) {
          case 'fromCrId':
            _onFromSelected(value.toString());
            Future.delayed(
              const Duration(milliseconds: 50),
              () => _erpFormKey.currentState?.focusField('toCrId'),
            );

          case 'toCrId':
            _onToSelected(value.toString());
            Future.delayed(
              const Duration(milliseconds: 50),
              () => _erpFormKey.currentState?.focusField('deptProcessCode'),
            );

          case 'deptProcessCode':
            _onProcessSelected(value.toString());
            Future.delayed(
              const Duration(milliseconds: 100),
              () => _erpFormKey.currentState?.focusField('remark'),
            );
          case 'mackable':
            final isChecked = value == true || value.toString() == 'true';

            setState(() {
              _isMackable = isChecked;
            });

            _entryVals[key] = isChecked.toString();
            break;

          case 'scanValue':
            _entryVals[key] = value.toString();

          case 'dmper':
            final dmPerVal = double.tryParse(value.toString()) ?? 0;
            if (dmPerVal > 100) {
              _erpFormKey.currentState?.updateFieldValue('dmper', '100');
              _entryVals['dmper'] = '100';
            } else {
              _entryVals[key] = value.toString();
            }
            _calcDmWt();

          case 'recWt':
            _entryVals[key] = value.toString();
            if (value.toString() == '+') {
              if (_detRows.isNotEmpty) {
                print('_laserApiRows ${jsonEncode(_laserApiRows)}');
                final data = await context
                    .read<TrnLaserReceivedProvider>()
                    .laserSelectData(
                      bCode: _entryVals['scanValue'] ?? '',
                      fromCrId: _fromCrId!.toString(),
                      gridData: _detRows,
                      spkDeptIssDate: toIso(
                        _formValues['spkDeptIssDate']?.toString(),
                      ),
                      time: DateFormat('hh:mm a').format(DateTime.now()),
                      SPKDeptIssMstID: _laserApiRows.isNotEmpty
                          ? _laserApiRows.first.spkDeptIssMstID
                          : (_isEditMode ? _detRows.first.spkDeptIssMstID : 0),
                      isSame: _isEditMode ? false : _laserApiRows.isNotEmpty,
                    );
                if (data.isNotEmpty) {
                  setState(() {
                    _laserApiRows.clear();
                    _laserApiRows.addAll(data);
                    _syncLaserApiGrid();
                    _detDisplay.clear();
                    _detRows.clear();
                  });
                  final wasEdit = _isEditMode;
                  _clearEntryFields();

                  // await ErpResultDialog.showSuccess(
                  //   context: context,
                  //   theme: _theme,
                  //   title: wasEdit ? 'Updated' : 'Saved',
                  //   message: wasEdit
                  //       ? 'Laser Rec updated.'
                  //       : 'Laser Rec saved.',
                  // );

                  await context.read<TrnLaserReceivedProvider>().load();

                  Future.delayed(const Duration(milliseconds: 100), () {
                    _erpFormKey.currentState?.focusField('scanValue');
                  });
                }
              } else {
                await ErpResultDialog.showError(
                  context: context,
                  theme: _theme,
                  title: 'No Entries',
                  message: 'Please add at least one entry.',
                );
              }
            } else {
              _calcDmWt();
            }
            break;
          case 'kwt':
            _entryVals[key] = value.toString();
            _calcLoss();

          case 'kpc':
            _entryVals[key] = value.toString();
            _calcLoss();

          default:
            _entryVals[key] = value.toString();
        }
      },

      onFieldSubmitted: (key, value) {
        if (key == 'recWt') {
          final issWt = double.tryParse(_entryVals['issWt'] ?? '') ?? 0;

          final recWt = double.tryParse(value.toString()) ?? 0;

          if (recWt > issWt) {
            ErpResultDialog.showError(
              context: context,
              theme: _theme,
              title: 'Invalid Weight',
              message: 'RecWt cannot be greater than IssWt',
            ).then((_) {
              Future.delayed(const Duration(milliseconds: 100), () {
                _erpFormKey.currentState?.focusField('recWt');
              });
            });
            return;
          }
        }

        if (key != 'scanValue') return;

        final scanVal = value.toString().trim();
        if (scanVal.isEmpty) return;
        if (_selectedRadioCode == null || _fromCrId == null) return;

        final merged = _getMergedFields();
        if (merged.isEmpty) return;

        final selectedField = merged.values.firstWhereOrNull(
          (f) => f.userVisibilityCode.toString() == _selectedRadioCode,
        );
        final selectedName = (selectedField?.userVisibilityName ?? '')
            .toUpperCase();

        if (selectedName == 'BCODE') {
          // Duplicate check before scanning
          if (_editingDetIndex == null) {
            final isDuplicate = _detRows.any(
              (r) => r.bCode?.toString() == scanVal,
            );
            if (isDuplicate) {
              ErpResultDialog.showError(
                context: context,
                theme: _theme,
                title: 'Duplicate',
                message: 'This bCode already added.',
              );
              _erpFormKey.currentState?.updateFieldValue('scanValue', '');
              _entryVals['scanValue'] = '';
              Future.delayed(
                const Duration(milliseconds: 100),
                () => _erpFormKey.currentState?.focusField('scanValue'),
              );
              return;
            }
          }
          _isBCodePending = true;
          _onBCodeScanned(scanVal);
          return;
        }

        // Non-BCODE duplicate check
        if (_editingDetIndex == null) {
          final isDuplicate = _detRows.any(
            (r) => r.id?.toString() == scanVal || r.jno?.toString() == scanVal,
          );
          if (isDuplicate) {
            ErpResultDialog.showError(
              context: context,
              theme: _theme,
              title: 'Duplicate',
              message: 'This entry already added.',
            );
          }
        }
      },

      onExit: () => context.read<TabProvider>().closeCurrentTab(),
      onCancel: _resetForm,
      onDelete: _isEditMode ? _onDelete : null,
      onSearch: () => setState(() => _showTableOnMobile = true),

      detailBuilder: (ctx) {
        final t = ctx.erpTheme;

        const leftAlignments = <String, TextAlign>{
          'recPc': TextAlign.right,
          'recWt': TextAlign.right,
          'mackRoughWt': TextAlign.right,
          'dmWt': TextAlign.right,
          'diffPoWt': TextAlign.right,
          'dmPer': TextAlign.right,
          'lossWt': TextAlign.right,
          'lossPer': TextAlign.right,
          'diam': TextAlign.left,
          'acuraecy': TextAlign.right,
          'sarinOpt': TextAlign.right,
          'sarinMachine': TextAlign.right,
          'qrCode': TextAlign.right,
        };

        return Column(
          children: [
            /// CURRENT GRID
            SizedBox(
              height: 200,
              child: _detDisplay.isNotEmpty
                  ? SingleChildScrollView(
                      child: ErpEntryGrid(
                        data: _detDisplay,
                        columns: _activeDetColumns,
                        title: 'DETAILS',
                        showTitleBar: false,
                        theme: t,
                        editingIndex: _editingDetIndex,
                        columnLabels: {
                          for (final c in _activeDetColumns) c: _colLabel(c),
                        },
                        columnAlignments: leftAlignments,
                        footerTotCount: 'Tot: ${_detRows.length}',
                        footerTotals: _buildFooterTotals(),
                        onDeleteRow: _deleteDetRow,
                        onEditRow: _editDetRow,
                      ),
                    )
                  : Container(),
            ),

            /// SPACING
            if (_laserApiRows.isNotEmpty) const SizedBox(height: 30),

            /// API RESPONSE GRID
            if (_laserApiRows.isNotEmpty)
              SizedBox(
                height: 220,
                child: SingleChildScrollView(
                  child: ErpEntryGrid(
                    data: _laserApiDisplay,
                    columns: const [
                      'BCode',
                      'PktNo',
                      'CutNo',

                      'Pc',
                      'Wt',

                      'IssPc',
                      'IssWt',

                      'RecPc',
                      'RecWt',

                      'DmWt',
                      'DmPer',

                      'KPc',
                      'KWt',

                      'LossWt',
                      'LossPer',

                      'Remarks',

                      'PktType',

                      'PartName',

                      'ShapeCode',

                      'CutCode',

                      'PurityCode',

                      'ColorCode',

                      'Diam',

                      'Length',

                      'Acuraecy',

                      'Amt',

                      'PlanSignerCrID',

                      'SarinOpt',

                      'SarinMachine',
                    ],
                    title: '',
                    showTitleBar: true,
                    theme: t,
                    columnLabels: {
                      'BCode': 'BCODE',
                      'PktNo': 'PKT NO',
                      'CutNo': 'CUT NO',

                      'Pc': 'PC',
                      'Wt': 'WT',

                      'IssPc': 'ISS PC',
                      'IssWt': 'ISS WT',

                      'RecPc': 'REC PC',
                      'RecWt': 'REC WT',

                      'DmWt': 'DM WT',
                      'DmPer': 'DM %',

                      'KPc': 'K PC',
                      'KWt': 'K WT',

                      'LossWt': 'LOSS WT',
                      'LossPer': 'LOSS %',

                      'Remarks': 'REMARK',

                      'PktType': 'PKT TYPE',

                      'PartName': 'PART',

                      'ShapeCode': 'SHAPE',

                      'CutCode': 'CUT',

                      'PurityCode': 'PURITY',

                      'ColorCode': 'COLOR',

                      'Diam': 'DIAM',

                      'Length': 'LENGTH',

                      'Acuraecy': 'ACCURACY',

                      'Amt': 'AMOUNT',

                      'PlanSignerCrID': 'PLAN SIGNER',

                      'SarinOpt': 'SARIN OPT',

                      'SarinMachine': 'SARIN MACHINE',
                    },
                    footerTotCount: 'Tot: ${_laserApiRows.length}',
                    footerTotals: _buildLaserFooterTotals(),
                    onRowTap: (index, row) {
                      final mainBCode = row['MainBCode'];

                      if (mainBCode == null) return;

                      final matchedRows = _laserApiRows
                          .where((e) => e.MainBCode == mainBCode)
                          .toList();

                      if (matchedRows.isEmpty) return;

                      final first = matchedRows.first;

                      void set(String key, dynamic value) {
                        final val = value?.toString() ?? '';

                        _entryVals[key] = val;

                        _erpFormKey.currentState?.updateFieldValue(key, val);
                      }

                      setState(() {
                        _detRows = matchedRows.reversed.toList();

                        _scannedDet = first;

                        _editingDetIndex = null;

                        _syncDetGrid();
                      });

                      /// scan
                      set('scanValue', first.bCode);

                      /// org
                      set('orgPc', first.pc);
                      set('orgWt', fThreeDecimal(first.wt));

                      /// iss
                      set('issPc', first.issPc);
                      set('issWt', fThreeDecimal(first.issWt));

                      /// rec
                      set('recPc', first.recPc);

                      /// loss
                      set('lossWt', fThreeDecimal(first.lossWt));

                      // print(mainBCode);
                      // print(matchedRows.length);
                    },
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  /// Compute footer totals map for ErpEntryGrid.
  Map<String, String> _buildFooterTotals() {
    double fold(double Function(LaserDetModel) fn) =>
        _detRows.fold(0.0, (s, r) => s + fn(r));
    int foldInt(int Function(LaserDetModel) fn) =>
        _detRows.fold(0, (s, r) => s + fn(r));

    final totDmWt = fold((r) => r.dmWt ?? 0);
    final totRecWt = fold((r) => r.recWt ?? 0);
    final totIssWt = fold((r) => r.issWt ?? 0);
    final base = totRecWt > 0 ? totRecWt : totIssWt;
    final dmPerStr = base > 0
        ? (totDmWt / base * 100).toStringAsFixed(2)
        : '0.00';
    double totalRecWt = _detRows.fold(0.0, (s, r) => s + (r.recWt ?? 0));
    double totalTopsWt = _detRows.fold(0.0, (s, r) => s + (r.topsWt ?? 0));
    double firstIssWt = _detRows.isNotEmpty ? (_detRows.first.issWt ?? 0) : 0;

    return {
      'recPc': '${foldInt((r) => r.recPc ?? 0)}',
      'recWt': fThreeDecimal(totRecWt),
      'mackRoughWt': fThreeDecimal(fold((r) => r.mackRoughWt ?? 0)),
      'dmWt': fThreeDecimal(totDmWt),
      'diffPoWt': fThreeDecimal(fold((r) => r.diffPoWt ?? 0)),
      'dmPer': dmPerStr,
      'lossWt': fThreeDecimal(firstIssWt - (totalRecWt + totalTopsWt)),
    };
  }

  Map<String, String> _buildLaserFooterTotals() {
    double sumDouble(String key) {
      return _laserApiDisplay.fold<double>(0, (s, e) {
        final val = e[key];

        if (val == null) return s;

        return s + (double.tryParse(val.toString()) ?? 0);
      });
    }

    int sumInt(String key) {
      return _laserApiDisplay.fold<int>(0, (s, e) {
        final val = e[key];

        if (val == null) return s;

        return s + (int.tryParse(val.toString()) ?? 0);
      });
    }

    return {
      'Pc': sumInt('Pc').toString(),

      'Wt': fThreeDecimal(sumDouble('Wt')),

      'IssPc': sumInt('IssPc').toString(),

      'IssWt': fThreeDecimal(sumDouble('IssWt')),

      'RecPc': sumInt('RecPc').toString(),

      'RecWt': fThreeDecimal(sumDouble('RecWt')),

      'DmWt': fThreeDecimal(sumDouble('DmWt')),

      'DmPer': fThreeDecimal(sumDouble('DmPer')),

      'KPc': sumInt('KPc').toString(),

      'KWt': fThreeDecimal(sumDouble('KWt')),

      'LossWt': fThreeDecimal(sumDouble('LossWt')),

      'LossPer': fThreeDecimal(sumDouble('LossPer')),

      'Amt': fThreeDecimal(sumDouble('Amt')),
    };
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  TABLE WIDGET
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildTable(TrnLaserReceivedProvider prov) {
    final counterProv = context.read<CounterProvider>();
    final procProv = context.read<DeptProcessProvider>();

    final data = prov.list.where((e) => e.formType == 'LASERREC').map((e) {
      String fromName = '', toName = '', processName = '';
      String fromDeptName = '', toDeptName = '';

      try {
        final c = counterProv.list.firstWhere((c) => c.crId == e.fromCrID);
        fromName = c.crName ?? '';
        fromDeptName = _deptNameFor(c.deptCode);
      } catch (_) {}

      try {
        final c = counterProv.list.firstWhere((c) => c.crId == e.toCrID);
        toName = c.crName ?? '';
        toDeptName = _deptNameFor(c.deptCode);
      } catch (_) {}

      try {
        processName =
            procProv.list
                .firstWhere((p) => p.deptProcessCode == e.deptProcessCode)
                .deptProcessName ??
            '';
      } catch (_) {}

      final dets = prov.detMap[e.spkDeptIssMstID] ?? [];

      final row = e.toTableRow()
        ..['fromName'] = fromName
        ..['fromDeptName'] = fromDeptName
        ..['toName'] = toName
        ..['toDeptName'] = toDeptName
        ..['deptName'] = toDeptName
        ..['processName'] = processName
        ..['spkDeptIssTime'] = _formatTime(e.stime)
        ..['jno'] = dets.isNotEmpty ? (dets.first.jno?.toString() ?? '') : ''
        ..['totPkt'] = '${dets.length}'
        ..['totalPc'] = '${dets.fold<int>(0, (s, r) => s + (r.totalPc ?? 0))}'
        ..['totalWt'] = fThreeDecimal(
          dets.fold<double>(0.0, (s, r) => s + (r.totalWt ?? 0.0)),
        );

      return row;
    }).toList();

    return ErpDataTable(
      isReportRow: false,
      token: token ?? '',
      url: baseUrl,
      title: 'LASER RECEIVED LIST',
      columns: _tableColumns,
      data: data,
      showSearch: true,
      dateFilter: true,
      onClose: () {
        setState(() {
          _showTableOnMobile = false;
        });
      },
      searchFields: const [
        ErpSearchFieldConfig(key: 'fromName', label: 'FROM', width: 150),
        ErpSearchFieldConfig(key: 'toName', label: 'TO', width: 150),
      ],
      selectedRow: _selectedRow,
      onRowTap: _onRowTap,
      emptyMessage: prov.isLoaded ? 'No entries found' : 'Loading...',
    );
  }
}
