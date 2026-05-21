import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:diam_mfg/providers/charni_provider.dart';
import 'package:diam_mfg/providers/color_provider.dart';
import 'package:diam_mfg/providers/counter_manager_det_provider.dart';
import 'package:diam_mfg/providers/counter_provider.dart';
import 'package:diam_mfg/providers/cut_provider.dart';
import 'package:diam_mfg/providers/dept_provider.dart';
import 'package:diam_mfg/providers/dept_group_provider.dart';
import 'package:diam_mfg/providers/dept_process_provider.dart';
import 'package:diam_mfg/providers/employee_provider.dart';
import 'package:diam_mfg/providers/fluo_provider.dart';
import 'package:diam_mfg/providers/makable_entry_provider.dart';
import 'package:diam_mfg/providers/polish_provider.dart';
import 'package:diam_mfg/providers/remarks_provider.dart';
import 'package:diam_mfg/providers/symmetry_provider.dart';
import 'package:diam_mfg/providers/tensions_provider.dart';
import 'package:diam_mfg/utils/app_images.dart';
import 'package:diam_mfg/utils/delete_dialogue.dart';
import 'package:diam_mfg/utils/helper_functions.dart';
import 'package:diam_mfg/utils/msg_dialogue.dart';
import 'package:erp_data_table/erp_data_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rs_dashboard/rs_dashboard.dart';
import '../bootstrap.dart';
import '../models/spkDeptIss_mst_model.dart';
import '../models/user_visibility_model.dart';
import '../providers/auth_provider.dart';
import '../providers/counter_display_det_provider.dart';
import '../providers/purity_provider.dart';
import '../providers/shape_provider.dart';
import '../providers/user_visibility_provider.dart';
import '../utils/constants.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  WIDGET
// ─────────────────────────────────────────────────────────────────────────────

class TrnMakableEntry extends StatefulWidget {
  const TrnMakableEntry({super.key});

  @override
  State<TrnMakableEntry> createState() => _TrnMakableEntryState();
}

// ─────────────────────────────────────────────────────────────────────────────
//  STATE
// ─────────────────────────────────────────────────────────────────────────────

class _TrnMakableEntryState extends State<TrnMakableEntry> {
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
  SpkDeptIssMstModel? _selectedMst;
  SpkDeptIssDetModel? _scannedDet;

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
  String _autoRec = 'N';

  String? _toDeptName;
  int? _toDeptCodeVal;

  // ── Detail rows ────────────────────────────────────────────────────────────
  List<SpkDeptIssDetModel> _detRows = [];
  List<Map<String, dynamic>> _detDisplay = [];
  List<String> _activeDetColumns = [];
  int? _editingDetIndex;

  // ── Display fields (from UserVisibility) ───────────────────────────────────
  List<UserVisibilityModel> _fromDisplayFields = [];
  List<UserVisibilityModel> _toDisplayFields = [];
  String? _selectedRadioCode;

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

  String _cutNameFor(int? code) {
    if (code == null) return '';
    try {
      return context
              .read<CutProvider>()
              .cuts
              .firstWhere((s) => s.cutCode == code)
              .cutName ??
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.wait([
        context.read<MakableEntryProvider>().load(),
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
        context.read<ColorProvider>().load(),
        context.read<CutProvider>().loadCuts(),
        context.read<PolishProvider>().loadPolish(),
        context.read<SymmetryProvider>().loadSymmetry(),
        context.read<FluoProvider>().load(),
        context.read<TensionsProvider>().load(),
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
        // AUTO REC SET
        _autoRec = (counter.autoRec ?? 'N').toString();
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
    });

    _rebuildForm();
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  BCODE SCAN
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _onBCodeScanned(String bCode) async {
    final rows = await context.read<MakableEntryProvider>().fetchByBCode(
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
    } else {
      Future.delayed(
        const Duration(milliseconds: 100),
        () => _erpFormKey.currentState?.focusField('dmWt'),
      );
    }
    final r = rows.first;

    void set(String k, String? v) {
      _entryVals[k] = v ?? '';
      _erpFormKey.currentState?.updateFieldValue(k, v ?? '');
    }

    final orgPc = r.pc ?? 0;
    final orgWt = r.wt ?? 0;

    final issPc = (r.issPc == null || r.issPc == 0) ?orgPc : r.issPc;
    final issWt = (r.issWt == null || r.issWt == 0)
        ? orgWt
        : r.issWt!;

    final recPc = (r.recPc == null || r.recPc == 0) ? orgPc : r.recPc;
    final recWt = (r.recWt == null || r.recWt == 0)
        ? issWt
        : r.recWt!;

    set('issPc', issPc.toString());
    set('issWt', fThreeDecimal(issWt));

    set('recPc', recPc.toString());
    set('recWt', fThreeDecimal(recWt));
    set('jnoRecPc', r.jnoRecPc?.toString());
    set('shapeCode', r.shapeCode?.toString());
    set('purityCode', r.purityCode?.toString());
    set('diam', r.diam?.toString());
    set('length', r.length?.toString());
    set('height', r.height?.toString());
    setState(() => _scannedDet = r);




    setState(() => _scannedDet = r);
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

  // DM PER
  void _calcDmPer() {
    final recWt = double.tryParse(_entryVals['recWt'] ?? '') ?? 0;
    final dmWt = double.tryParse(_entryVals['dmWt'] ?? '') ?? 0;

    if (recWt > 0) {
      final dmPer = (dmWt * 100) / recWt;

      _entryVals['dmPer'] = dmPer.toStringAsFixed(2);

      _erpFormKey.currentState?.updateFieldValue(
        'dmPer',
        dmPer.toStringAsFixed(2),
      );
    } else {
      _entryVals['dmPer'] = '0';

      _erpFormKey.currentState?.updateFieldValue(
        'dmPer',
        '0',
      );
    }
  }

  /// Loss WT = Iss WT − K WT,  Loss PC = Iss PC − K PC
  void _calcLoss() {
    final issWt = double.tryParse(_entryVals['issWt'] ?? '') ?? 0;
    final recWt =
        double.tryParse(_entryVals['recWt'] ?? '') ?? 0; // 👈 ADD THIS
    final kWt = double.tryParse(_entryVals['kwt'] ?? '') ?? 0;
    final issPc = int.tryParse(_entryVals['issPc'] ?? '') ?? 0;
    final kPc = int.tryParse(_entryVals['kpc'] ?? '') ?? 0;

    // ✅ UPDATED FORMULA
    final lossWt = issWt - recWt - kWt;

    _entryVals['lossWt'] = fThreeDecimal(lossWt);
    _entryVals['lossPc'] = '${issPc - kPc}';

    _erpFormKey.currentState?.updateFieldValue('lossWt', fThreeDecimal(lossWt));
    _erpFormKey.currentState?.updateFieldValue('lossPc', '${issPc - kPc}');
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  ADD / EDIT ENTRY
  // ─────────────────────────────────────────────────────────────────────────

  void _addEntry() {
    if (_scannedDet == null) {
      _isBCodePending = false;
      Future.delayed(
        const Duration(milliseconds: 50),
        () => _erpFormKey.currentState?.focusField('scanValue'),
      );
      return;
    }

    final recPc = int.tryParse(_entryVals['recPc'] ?? '') ?? 0;
    final recWt = double.tryParse(_entryVals['recWt'] ?? '') ?? 0;
    final dmWt = double.tryParse(_entryVals['dmWt'] ?? '') ?? 0;
    if (_entryVals['dmWt'] == null) {
      _showSnack('DM WT cannot be empty!');
      _erpFormKey.currentState?.focusField('dmWt');
      return;
    }
    // ✅ VALIDATION: recWt must be >= dmWt
    if (recWt < dmWt) {
      _showSnack('Rec WT cannot be less than DM WT!');
      _erpFormKey.currentState?.focusField('recWt');
      return;
    }

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

      if (_editingDetIndex == null) {
        _clearEntryFields();
      } else {
        _editingDetIndex = null;

        _clearEntryFields();
      }

      _lockMasterFields = true;
      _syncDetGrid();
    });

    _erpFormKey.currentState?.setFieldReadOnly('fromCrId', true);
    _erpFormKey.currentState?.setFieldReadOnly('toCrId', true);
    _erpFormKey.currentState?.setFieldReadOnly('deptProcessCode', true);

    Future.delayed(
      const Duration(milliseconds: 50),
      () => _erpFormKey.currentState?.focusField('scanValue'),
    );
  }

  /// Build a detail row for an existing (edit) record.
  SpkDeptIssDetModel _buildEditedRow({
    required int? srno,
    required SpkDeptIssDetModel existing,
    required String issPcStr,
    required String issWtStr,
    required int recPc,
    required double recWt,
  }) {
    return SpkDeptIssDetModel(
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
      kachaRec: existing.kachaRec,
      qrCode: existing.qrCode,
      entryType: existing.entryType,
      fType: existing.fType,
      pktType: existing.pktType,
      fromDeptCode: _fromDeptCode,
      toDeptCode: _toDeptCodeVal,
      fromCrId: _fromCrId,
      toCrId: _toCrId,
      deptCode: _toDeptCodeVal,
      deptProcessCode: int.tryParse(_formValues['deptProcessCode'] ?? ''),
      // User-entered fields
      pc: existing.pc,
      wt: existing.wt,
      issPc: int.tryParse(issPcStr),
      issWt: double.tryParse(issWtStr),
      recPc: recPc,
      recWt: recWt,
      totalPc: recPc,
      totalWt: recWt,
      dmWt: double.tryParse(_entryVals['dmWt'] ?? ''),
      dmPer: existing.dmPer,
      kPc: int.tryParse(_entryVals['kpc'] ?? ''),
      kWt: double.tryParse(_entryVals['kwt'] ?? ''),
      brPc: int.tryParse(_entryVals['brPc'] ?? ''),
      brWt: double.tryParse(_entryVals['brWt'] ?? ''),
      lossPc: int.tryParse(_entryVals['lossPc'] ?? ''),
      lossWt: double.tryParse(_entryVals['lossWt'] ?? ''),
      topsPc: int.tryParse(_entryVals['topsPc'] ?? ''),
      topsWt: double.tryParse(_entryVals['topsWt'] ?? ''),
      charniCode: existing.charniCode,
      employeeCode: int.tryParse(_entryVals['employee'] ?? ''),
      signerCode: int.tryParse(_entryVals['signer'] ?? ''),
      remarksCode: int.tryParse(_entryVals['remarks'] ?? ''),
      dueDay: int.tryParse(_entryVals['dueDay'] ?? ''),
      diffDmWt: double.tryParse(_entryVals['diffDmWt'] ?? ''),
      recutEmp: double.tryParse(_entryVals['recutEmp'] ?? '0.000'),
      ratio: double.tryParse(_entryVals['ratio'] ?? ''),
      planShape: _entryVals['shape'] ?? '',
      planPurity: _entryVals['planPurity'] ?? '',
      partName: int.tryParse(_entryVals['partName'].toString()),
      orderMstID: int.tryParse(_entryVals['orderMstId'] ?? ''),
      amountRs: double.tryParse(_entryVals['amount'] ?? '0.000'),
      amount: double.tryParse(_entryVals['amount'] ?? '0.000'),
      remarks: _entryVals['remarks'] ?? '',
      cutCode: int.tryParse(_entryVals['cutCode'] ?? ''),
      plDmWt: double.tryParse(_entryVals['dmWt'] ?? '0.000'),
      plDmPer: double.tryParse(_entryVals['dmPer'] ?? '0.00'),
      fluo: _isFieldVisible('FLUO')
          ? int.tryParse(_formValues['fluo'] ?? '')
          : null,
      symmetryCode: _isFieldVisible('SYMMETRY')
          ? int.tryParse(_formValues['symmetryCode'] ?? '')
          : null,
      polishCode: _isFieldVisible('POLISH')
          ? int.tryParse(_formValues['polishCode'] ?? '')
          : null,
      tensionsCode: _isFieldVisible('TENSIONS')
          ? int.tryParse(_formValues['tensionCode'] ?? '')
          : null,
      length: _isFieldVisible('LENGTH')
          ? int.tryParse(_entryVals['length'].toString())
          : null,
      diam: _isFieldVisible('DIAM')
          ? double.tryParse(_entryVals['diam'].toString())
          : null,
      height: _isFieldVisible('HEIGHT')
          ? double.tryParse(_entryVals['height'].toString())
          : null,
      formType: 'SPK',
      confRec: _autoRec,
      clvRec: 'S',
      confCrID: _toCrId,
    );
  }

  /// Build a detail row for a new (add) record.
  SpkDeptIssDetModel _buildNewRow({
    required int? srno,
    required String issPcStr,
    required String issWtStr,
    required int recPc,
    required double recWt,
  }) {
    return SpkDeptIssDetModel(
      srno: srno,
      id: _scannedDet?.id,
      jno: _scannedDet?.jno,
      jnoRecPc: _scannedDet?.jnoRecPc,
      bCode: _scannedDet?.bCode ?? _entryVals['scanValue'],
      pktNo: _scannedDet?.pktNo,
      cutNo: _scannedDet?.cutNo,
      clvCut: _scannedDet?.clvCut,
      shapeCode: int.tryParse(_entryVals['shape'] ?? ''),
      purityCode: _scannedDet?.purityCode,
      colorCode: int.tryParse(_entryVals['color'] ?? ''),
      kachaRec: _scannedDet?.kachaRec ?? 'Y',
      fromDeptCode: _fromDeptCode,
      toDeptCode: _toDeptCodeVal,
      fromCrId: _fromCrId,
      toCrId: _toCrId,
      deptCode: _toDeptCodeVal,
      deptProcessCode: int.tryParse(_formValues['deptProcessCode'] ?? ''),
      charniCode: int.tryParse(_entryVals['charniCode'] ?? ''),
      pc: _scannedDet?.pc  ?? 0,
      wt: _scannedDet?.wt  ?? 0.000,
      issPc: int.tryParse(issPcStr),
      issWt: double.tryParse(issWtStr),
      recPc: recPc,
      recWt: recWt,
      totalPc: recPc,
      totalWt: recWt,
      dmWt: double.tryParse(_entryVals['dmWt'] ?? ''),
      dmPer: _scannedDet?.dmPer ?? 0,
      kPc: int.tryParse(_entryVals['kpc'] ?? ''),
      kWt: double.tryParse(_entryVals['kwt'] ?? ''),
      brPc: int.tryParse(_entryVals['brPc'] ?? ''),
      brWt: double.tryParse(_entryVals['brWt'] ?? ''),
      lossPc: int.tryParse(_entryVals['lossPc'] ?? ''),
      lossWt: double.tryParse(_entryVals['lossWt'] ?? ''),
      topsPc: int.tryParse(_entryVals['topsPc'] ?? ''),
      topsWt: double.tryParse(_entryVals['topsWt'] ?? ''),
      employeeCode: int.tryParse(_entryVals['employee'] ?? ''),
      signerCode: int.tryParse(_entryVals['signer'] ?? ''),
      remarksCode: int.tryParse(_entryVals['remarks'] ?? ''),
      dueDay: int.tryParse(_entryVals['dueDay'] ?? ''),
      entryType: 'B',
      fType: 'MAKABLE',
      pktType: 'A',
      diffDmWt: double.tryParse(_entryVals['diffDmWt'] ?? '0.000'),
      plDmWt: double.tryParse(_entryVals['dmWt'] ?? '0.000'),
      plDmPer: double.tryParse(_entryVals['dmPer'] ?? '0.00'),
      recutEmp: double.tryParse(_entryVals['recutEmp'] ?? '0.000'),
      ratio: double.tryParse(_entryVals['ratio'] ?? ''),
      planShape: _entryVals['shape'] ?? '',
      planPurity: _entryVals['planPurity'] ?? '',
      qrCode: _entryVals['qrCode'] ?? '',
      partName: int.tryParse(_entryVals['partName'].toString()),
      orderMstID: int.tryParse(_entryVals['orderMstId'] ?? ''),
      amountRs: double.tryParse(_entryVals['amount'] ?? '0.000'),
      amount: double.tryParse(_entryVals['amount'] ?? '0.000'),
      remarks: _entryVals['remarks'] ?? '',
      cutCode: int.tryParse(_entryVals['cutCode'] ?? ''),
      fluo: _isFieldVisible('FLUO')
          ? int.tryParse(_formValues['fluo'] ?? '')
          : null,
      symmetryCode: _isFieldVisible('SYMMETRY')
          ? int.tryParse(_formValues['symmetryCode'] ?? '')
          : null,
      polishCode: _isFieldVisible('POLISH')
          ? int.tryParse(_formValues['polishCode'] ?? '')
          : null,
      tensionsCode: _isFieldVisible('TENSIONS')
          ? int.tryParse(_formValues['tensionCode'] ?? '')
          : null,
      length: _isFieldVisible('LENGTH')
          ? int.tryParse(_entryVals['length'].toString())
          : null,
      diam: _isFieldVisible('DIAM')
          ? double.tryParse(_entryVals['diam'].toString())
          : null,
      height: _isFieldVisible('HEIGHT')
          ? double.tryParse(_entryVals['height'].toString())
          : null,
      formType: 'SPK',
      confRec: _autoRec,
      clvRec: 'S',
      confCrID: _toCrId,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  EDIT / DELETE DET ROW
  // ─────────────────────────────────────────────────────────────────────────

  void _editDetRow(int idx) {
    final r = _detRows[idx];
    setState(() {
      _editingDetIndex = idx;
      // IMPORTANT
      _scannedDet = r;
    });

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
    set('brPc', r.brPc?.toString());
    set('brWt', fThreeDecimal(r.brWt));
    set('lossPc', r.lossPc?.toString());
    set('lossWt', fThreeDecimal(r.lossWt));
    set('topsPc', r.topsPc?.toString());
    set('topsWt', fThreeDecimal(r.topsWt));
    set('employee', r.employeeCode?.toString());
    set('signer', r.signerCode?.toString());
    set('remarks', r.remarksCode?.toString());
    set('dueDay', r.dueDay?.toString());
    set('diffDmWt', r.diffDmWt?.toString());
    set('recutEmp', r.recutEmp?.toString());
    set('amount', r.amount?.toString());
    set('plDmWt', r.plDmWt?.toString());
    set('plDmPer', r.plDmPer?.toString());
    set('cutCode', r.cutCode?.toString());
    set('shape', r.shapeCode?.toString());
    set('purity', r.purityCode?.toString());
    set('color', r.colorCode?.toString());
    set('tensionCode', r.tensionsCode?.toString());
    set('fluo', r.fluo?.toString());
    set('symmetryCode', r.symmetryCode?.toString());
    set('polishCode', r.polishCode?.toString());
    set('length', r.length?.toString());
    set('diam', r.diam?.toString());
    set('height', r.height?.toString());
    set('scanValue', r.bCode?.toString());

    Future.delayed(
      const Duration(milliseconds: 100),

      () => _erpFormKey.currentState?.focusField('dmWt'),
    );
  }

  void _deleteDetRow(int idx) {
    setState(() {
      _detRows.removeAt(idx);
      // Re-number srno
      _detRows = _detRows.asMap().entries.map((e) {
        final v = e.value;
        return SpkDeptIssDetModel(
          srno: e.key + 1,
          spkDeptIssMstID: v.spkDeptIssMstID,
          id: v.id,
          jno: v.jno,
          bCode: v.bCode,
          pktNo: v.pktNo,
          cutNo: v.cutNo,
          pc: v.pc,
          wt: v.wt,
          issPc: v.issPc,
          issWt: v.issWt,
          recPc: v.recPc,
          recWt: v.recWt,
          dmPer: v.dmPer,
          dmWt: v.dmWt,
          kPc: v.kPc,
          kWt: v.kWt,
          brPc: v.brPc,
          brWt: v.brWt,
          lossPc: v.lossPc,
          lossWt: v.lossWt,
          topsPc: v.topsPc,
          topsWt: v.topsWt,
          totalPc: v.totalPc,
          totalWt: v.totalWt,
          charniCode: v.charniCode,
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
          cutCode: v.cutCode,
          purityCode: v.purityCode,
          colorCode: v.colorCode,
          diam: v.diam,
          kachaRec: v.kachaRec,
          remarks: v.remarks,
          ratio: v.ratio,
          length: v.length,
          planShape: v.planShape,
          planPurity: v.planPurity,
          qrCode: v.qrCode,
          partName: v.partName,
          orderMstID: v.orderMstID,
          amountRs: v.amountRs,
          diffDmWt: v.diffDmWt,
          recutEmp: v.recutEmp,
          plDmWt: v.plDmWt,
          plDmPer: v.plDmPer,
          clvCut: v.clvCut,
          jnoRecPc: v.jnoRecPc,
          height: v.height,
          fluo: v.fluo,
          symmetryCode: v.symmetryCode,
          polishCode: v.polishCode,
        );
      }).toList();

      _syncDetGrid();
      if (_editingDetIndex == idx) _editingDetIndex = null;
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  CLEAR ENTRY FIELDS
  // ─────────────────────────────────────────────────────────────────────────

  void _clearEntryFields() {
    const keys = [
      // SCAN
      'scanValue',

      // ORG
      'orgPc',
      'orgWt',

      // ISSUE
      'issPc',
      'issWt',

      // RECEIVE
      'recPc',
      'recWt',

      // DM
      'dmWt',
      'dmPer',

      // SHAPE / COLOR / PURITY
      'shape',
      'color',
      'purity',
      'cutCode',

      // OTHER
      'plDmWt',
      'diffDmWt',
      'recutEmp',
      'amount',

      // OPTIONAL
      'diam',
      'length',
      'height',

      'polishCode',
      'symmetryCode',
      'fluo',
      'tensionCode',
    ];

    for (final k in keys) {
      _entryVals.remove(k);
      _erpFormKey.currentState?.updateFieldValue(k, '');
    }
  }

  /// Returns true if the field name exists in the merged DEPT visibility map.
  bool _isFieldVisible(String fieldName) {
    // final name = fieldName.toUpperCase();
    // for (final f in [..._fromDisplayFields, ..._toDisplayFields]) {
    //   if (f.entryType != 'MAKABLE') continue;
    //   final n = (f.userVisibilityName ?? '').toUpperCase();
    //   if (n == name) return true;
    // }
    return true;
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  SYNC DET GRID
  // ─────────────────────────────────────────────────────────────────────────

  void _syncDetGrid() {
    _activeDetColumns = [
      'srno',
      'bCode',
      'pktNo',
      'cutNo',
      'issPc',
      'issWt',
      'recPc',
      'recWt',
      'dmWt',
      'dmPer',
      'plDmWt',
      'plDmPer',
      'diffDmWt',
      'recutEmp',
      'remarks',
      'ratio',
      'shapeCode',
      'cutCode',
      'planShape',
      'colorCode',
      'purityCode',
      'planPurity',
      'charniCode',
      'amount',
      'qrCode',
      'partName',
      'orderMstId',

      // Conditional columns
      if (_isFieldVisible('LENGTH')) 'length',
      if (_isFieldVisible('DIAM')) 'diam',
      // if (_isFieldVisible('HEIGHT')) 'height',
      // if (_isFieldVisible('FLUO')) 'fluo',
      // if (_isFieldVisible('TENSIONS')) 'tensionCode',
      // if (_isFieldVisible('SYMMETRY')) 'symmetryCode',
      // if (_isFieldVisible('POLISH')) 'polishCode',
    ];

    _detDisplay = _detRows
        .map(
          (r) => {
            'srno': r.srno?.toString() ?? '',
            'bCode': r.bCode ?? '',
            'pktNo': r.pktNo ?? '',
            'cutNo': r.cutNo ?? '',
            'issPc': r.issPc?.toString() ?? '0',
            'issWt': fThreeDecimal(r.issWt),
            'recPc': r.recPc?.toString() ?? '0',
            'recWt': fThreeDecimal(r.recWt),
            'dmWt': fThreeDecimal(r.dmWt),
            'dmPer': r.dmPer?.toStringAsFixed(2) ?? '',
            'diffDmWt': r.diffDmWt?.toStringAsFixed(3) ?? '',
            'recutEmp': r.recutEmp ?? '',
            'remarks': _remarksNameFor(r.remarksCode),
            'diam': r.diam?.toString() ?? '0.00',
            'length': r.length?.toString() ?? '0.00',
            'ratio': r.ratio?.toString() ?? '0.00',
            'shapeCode': _shapeNameFor(r.shapeCode),
            'cutCode': _cutNameFor(r.cutCode),
            'planShape': _shapeNameFor(r.shapeCode),
            'colorCode': r.colorCode?.toString() ?? '',
            'purityCode': _purityNameFor(r.purityCode),
            'planPurity': _purityNameFor(r.purityCode),
            'charniCode': r.charniCode?.toString() ?? '',
            'amount': r.amount?.toString() ?? '0.00',
            'qrCode': r.qrCode ?? '',
            'partName': r.partName ?? '',
            'orderMstId': r.orderMstID ?? '',
            'plDmPer': r.plDmPer ?? '0.00',
            'plDmWt': r.plDmWt?.toStringAsFixed(3) ?? '',
            'fluo': r.fluo ?? '',
            'tensionCode': r.tensionsCode ?? '',
            'symmetryCode': r.symmetryCode ?? '',
            'polishCode': r.polishCode ?? '',
          },
        )
        .toList();
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  ROW TAP (load existing record)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _onRowTap(Map<String, dynamic> row) async {
    final raw = row['_raw'] as SpkDeptIssMstModel;
    final prov = context.read<MakableEntryProvider>();
    final details = await prov.loadDetails(raw.spkDeptIssMstID!);
    if (!mounted) return;

    if (raw.fromCrID != null) _onFromSelected(raw.fromCrID.toString());
    if (raw.toCrID != null) _onToSelected(raw.toCrID.toString());

    if (raw.deptProcessCode != null && _toCrId != null && _fromCrId != null) {
      await _loadToDisplayFields(_toCrId!);
      await _loadFromDisplayFields(_fromCrId!);
    }
    if (!mounted) return;
    setState(() {
      _selectedRow = row;
      _selectedMst = raw;
      _isEditMode = true;
      _detRows = details;
      _editingDetIndex = null;
      _processSelected = raw.deptProcessCode != null;
      _isAdding = false;
      _showTableOnMobile = false;

      _formValues = {
        'spkDeptIssMstID': raw.spkDeptIssMstID?.toString() ?? '0',
        'spkDeptIssDate': toDisplayDate(raw.spkDeptIssDate),
        'time': _formatTime(raw.stime),
        'fromCrId': raw.fromCrID?.toString() ?? '',
        'fromDept': _fromDeptName ?? '',
        'toCrId': raw.toCrID?.toString() ?? '',
        'toDept': _toDeptName ?? '',
        'deptProcessCode': raw.deptProcessCode?.toString() ?? '',
        'deptName': _toDeptName ?? '',
        if (_selectedRadioCode != null) 'scanType': _selectedRadioCode!,
      };

      _syncDetGrid();
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
  //  SAVE
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _onSave(Map<String, dynamic> values) async {
    final prov = context.read<MakableEntryProvider>();

    String toIso(String? v) {
      if (v == null || v.isEmpty) return '';
      try {
        return DateFormat(
          'yyyy-MM-dd',
        ).format(DateFormat('dd/MM/yyyy').parse(v));
      } catch (_) {
        return v;
      }
    }

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

    final merged = Map<String, dynamic>.from(values)
      ..['Stime'] = DateFormat('hh:mm a').format(DateTime.now())
      ..['Sdate'] = DateFormat('yyyy-MM-dd').format(DateTime.now())
      ..['spkDeptIssDate'] = toIso(values['spkDeptIssDate']?.toString())
      ..['fromCrID'] = _fromCrId?.toString() ?? ''
      ..['toCrID'] = _toCrId?.toString() ?? ''
      ..['deptCode'] = toDeptCode?.toString() ?? '';

    final success = _isEditMode && _selectedMst != null
        ? await prov.update(_selectedMst!.spkDeptIssMstID!, merged, _detRows)
        : await prov.create(merged, _detRows);

    if (!mounted) return;
    if (success) {
      final wasEdit = _isEditMode;
      _resetForm();
      await ErpResultDialog.showSuccess(
        context: context,
        theme: _theme,
        title: wasEdit ? 'Updated' : 'Saved',
        message: wasEdit ? 'Makable Entry Updated.' : 'Makable Entry Saved.',
      );
      context.read<MakableEntryProvider>().load();
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
      title: 'Dept Issue',
      itemName: 'ID: ${_selectedMst!.spkDeptIssMstID}',
    );
    if (confirm != true || !mounted) return;

    final success = await context.read<MakableEntryProvider>().delete(
      _selectedMst!.spkDeptIssMstID!,
    );

    if (success && mounted) {
      final id = _selectedMst?.spkDeptIssMstID;
      _resetForm();
      await ErpResultDialog.showDeleted(
        context: context,
        theme: _theme,
        itemName: 'Dept Issue $id',
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
    final colorProv = context.read<ColorProvider>();
    final purityProv = context.read<PurityProvider>();
    final shapeProv = context.read<ShapeProvider>();
    final cutProv = context.read<CutProvider>();
    final remarkProv = context.read<RemarksProvider>();
    final polishProv = context.read<PolishProvider>();
    final symmetryProv = context.read<SymmetryProvider>();
    final fluoProv = context.read<FluoProvider>();
    final tensionProv = context.read<TensionsProvider>();

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

    //COLOR
    final colorItems = colorProv.list.where((e) => e.active == true).toList()
      ..sort((a, b) => (a.sortID ?? 0).compareTo(b.sortID ?? 0));
    final colorDropdown = colorItems
        .map(
          (e) => ErpDropdownItem(
            label: e.colorName ?? '',
            value: e.colorCode?.toString() ?? '',
          ),
        )
        .toList();

    //PURITY
    final purityItems = purityProv.list.where((e) => e.active == true).toList()
      ..sort((a, b) => (a.sortID ?? 0).compareTo(b.sortID ?? 0));
    final purityDropdown = purityItems
        .map(
          (e) => ErpDropdownItem(
            label: e.purityName ?? '',
            value: e.purityCode?.toString() ?? '',
          ),
        )
        .toList();

    //SHAPE
    final shapeItems = shapeProv.list.where((e) => e.active == true).toList()
      ..sort((a, b) => (a.sortID ?? 0).compareTo(b.sortID ?? 0));
    final shapeDropdown = shapeItems
        .map(
          (e) => ErpDropdownItem(
            label: e.shapeName ?? '',
            value: e.shapeCode?.toString() ?? '',
          ),
        )
        .toList();

    //CUT
    final cutItems = cutProv.cuts.where((e) => e.active == true).toList()
      ..sort((a, b) => (a.sortID ?? 0).compareTo(b.sortID ?? 0));
    final cutDropdown = cutItems
        .map(
          (e) => ErpDropdownItem(
            label: e.cutName ?? '',
            value: e.cutCode?.toString() ?? '',
          ),
        )
        .toList();

    //REMARKS
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

    //POLISH
    final polishItems =
        polishProv.polishs.where((e) => e.active == true).toList()
          ..sort((a, b) => (a.sortID ?? 0).compareTo(b.sortID ?? 0));
    final polishDropdown = polishItems
        .map(
          (e) => ErpDropdownItem(
            label: e.polishName ?? '',
            value: e.polishCode?.toString() ?? '',
          ),
        )
        .toList();
    //SYMMETRY
    final symmetryItems =
        symmetryProv.symmetrys.where((e) => e.active == true).toList()
          ..sort((a, b) => (a.sortID ?? 0).compareTo(b.sortID ?? 0));
    final symmetryDropdown = symmetryItems
        .map(
          (e) => ErpDropdownItem(
            label: e.symmetryName ?? '',
            value: e.symmetryCode?.toString() ?? '',
          ),
        )
        .toList();
    //FLUO
    final fluoItems = fluoProv.list.where((e) => e.active == true).toList()
      ..sort((a, b) => (a.sortID ?? 0).compareTo(b.sortID ?? 0));
    final fluoDropdown = fluoItems
        .map(
          (e) => ErpDropdownItem(
            label: e.fluoName ?? '',
            value: e.fluoCode?.toString() ?? '',
          ),
        )
        .toList();

    //TENSIONS
    final tensionItems =
        tensionProv.list.where((e) => e.active == true).toList()
          ..sort((a, b) => (a.sortID ?? 0).compareTo(b.sortID ?? 0));
    final tensionDropdown = tensionItems
        .map(
          (e) => ErpDropdownItem(
            label: e.tensionsName ?? '',
            value: e.tensionsCode?.toString() ?? '',
          ),
        )
        .toList();

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
          sectionIndex: 1,
          readOnly: _lockMasterFields || _isEditMode,
        ),
        ErpFieldConfig(
          key: 'fromDept',
          label: 'MANAGER',
          type: ErpFieldType.text,
          readOnly: true,
          sectionIndex: 1,
        ),
        ErpFieldConfig(
          key: 'toCrId',
          label: 'TO',
          type: ErpFieldType.dropdown,
          dropdownItems: toItems,
          readOnly: !isFromSelected || _lockMasterFields || _isEditMode,
          sectionIndex: 1,
        ),
        ErpFieldConfig(
          key: 'toDept',
          label: 'MANAGER',
          type: ErpFieldType.text,
          readOnly: true,
          sectionIndex: 1,
        ),
        ErpFieldConfig(
          key: 'deptProcessCode',
          label: 'PROCESS',
          type: ErpFieldType.dropdown,
          dropdownItems: processItems,
          readOnly: !isToSelected || _lockMasterFields || _isEditMode,
          sectionIndex: 1,
        ),
        ErpFieldConfig(
          key: 'deptName',
          label: 'DEPT',
          type: ErpFieldType.text,
          readOnly: true,
          sectionIndex: 1,
        ),
      ],

      [
        ErpFieldConfig(
          key: 'remarks',
          label: 'REMARK',
          type: ErpFieldType.dropdown,
          dropdownItems: remarkDropdown,
          width: 250,
          sectionIndex: 2,
        ),
        ErpFieldConfig(
          key: 'scanValue',
          label: 'BCODE',
          type: ErpFieldType.text,
          readOnly: _isEditMode,
          sectionIndex: 2,
          width: 200,
        ),
        ErpFieldConfig(
          key: 'qrCode',
          label: 'QRCODE',
          type: ErpFieldType.text,
          readOnly: true,
          sectionIndex: 2,
          width: 200,
        ),
      ],
    ];

    final singleRow = <ErpFieldConfig>[
      // ISS
      ErpFieldConfig(
        key: 'issPc',
        label: 'ISS PC',
        type: ErpFieldType.number,
        readOnly: true,
        sectionIndex: 3,
        flex: 1,
      ),
      ErpFieldConfig(
        key: 'issWt',
        label: 'ISS WT',
        type: ErpFieldType.amount,
        readOnly: true,
        sectionIndex: 3,
        flex: 1,
      ),

      // REC
      ErpFieldConfig(
        key: 'recPc',
        label: 'REC PC',
        type: ErpFieldType.number,
        readOnly: true,
        sectionIndex: 3,
        flex: 1,
      ),
      ErpFieldConfig(
        key: 'recWt',
        label: 'REC WT',
        type: ErpFieldType.text,
        readOnly: true,
        sectionIndex: 3,
        flex: 1,
      ),

      // DM
      ErpFieldConfig(
        key: 'dmWt',
        label: 'DM WT',
        type: ErpFieldType.amount,
        sectionIndex: 3,
        flex: 1,
      ),
      ErpFieldConfig(
        key: 'shape',
        label: 'SHAPE',
        type: ErpFieldType.dropdown,
        dropdownItems: shapeDropdown,
        sectionIndex: 3,
      ),
      ErpFieldConfig(
        key: 'color',
        label: 'COLOR',
        type: ErpFieldType.dropdown,
        dropdownItems: colorDropdown,
        sectionIndex: 3,
      ),
      ErpFieldConfig(
        key: 'purity',
        label: 'PURITY',
        type: ErpFieldType.dropdown,
        dropdownItems: purityDropdown,
        sectionIndex: 3,
      ),
      ErpFieldConfig(
        key: 'cutCode',
        label: 'CUT',
        type: ErpFieldType.dropdown,
        dropdownItems: cutDropdown,
        sectionIndex: 3,
      ),
      if (_isFieldVisible('POLISH'))
        ErpFieldConfig(
          key: 'polishCode',
          label: 'POLISH',
          type: ErpFieldType.dropdown,
          dropdownItems: polishDropdown,
          sectionIndex: 3,
        ),
      if (_isFieldVisible('SYMMETRY'))
        ErpFieldConfig(
          key: 'symmetryCode',
          label: 'SYMMETRY',
          type: ErpFieldType.dropdown,
          dropdownItems: symmetryDropdown,
          sectionIndex: 3,
        ),
      if (_isFieldVisible('FLUO'))
        ErpFieldConfig(
          key: 'fluo',
          label: 'FLUO',
          type: ErpFieldType.dropdown,
          dropdownItems: fluoDropdown,
          sectionIndex: 3,
        ),
      if (_isFieldVisible('TENSIONS'))
        ErpFieldConfig(
          key: 'tensionCode',
          label: 'TENSIONS',
          type: ErpFieldType.dropdown,
          dropdownItems: tensionDropdown,
          sectionIndex: 3,
        ),
      if (_isFieldVisible('LENGTH'))
        ErpFieldConfig(
          key: 'length',
          label: 'LENGTH',
          type: ErpFieldType.number,
          sectionIndex: 3,
          flex: 1,
        ),
      if (_isFieldVisible('DIAM'))
        ErpFieldConfig(
          key: 'diam',
          label: 'DIAM',
          type: ErpFieldType.amount,
          sectionIndex: 3,
          flex: 1,
        ),
      if (_isFieldVisible('HEIGHT'))
        ErpFieldConfig(
          key: 'height',
          label: 'HEIGHT',
          type: ErpFieldType.amount,
          sectionIndex: 3,
          flex: 1,
        ),
      ErpFieldConfig(
        key: 'dmPer',
        label: 'DM PER',
        type: ErpFieldType.number,
        readOnly: true,
        sectionIndex: 3,
        flex: 1,
      ),
      ErpFieldConfig(
        key: 'plDmWt',
        label: 'PL DM WT',
        type: ErpFieldType.amount,
        readOnly: true,
        sectionIndex: 3,
        flex: 1,
      ),
      ErpFieldConfig(
        key: 'diffDmWt',
        label: 'DIFF DM WT',
        type: ErpFieldType.amount,
        readOnly: true,
        sectionIndex: 3,
        flex: 1,
      ),
      ErpFieldConfig(
        key: 'recutEmp',
        label: 'RECUT EMP',
        type: ErpFieldType.amount,
        readOnly: true,
        sectionIndex: 3,
        flex: 1,
      ),
      ErpFieldConfig(
        key: 'amount',
        label: 'AMOUNT RS',
        type: ErpFieldType.amount,
        readOnly: true,
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
      'srno': 'SR NO',
      'bCode': 'BCODE',
      'pktNo': 'PKT NO',
      'cutNo': 'CUT NO',
      'orgPc': 'ORG PC',
      'orgWt': 'ORG WT',
      'issPc': 'ISS PC',
      'issWt': 'ISS WT',
      'recPc': 'REC PC',
      'recWt': 'REC WT',
      'dmWt': 'DM WT',
      'dmPer': 'DM PER',
      'kPc': 'K PC',
      'kWt': 'K WT',
      'brPc': 'BR PC',
      'brWt': 'BR WT',
      'lossPc': 'LOSS PC',
      'lossWt': 'LOSS WT',
      'topsPc': 'TOPS PC',
      'topsWt': 'TOPS WT',
      'remarks': 'REMARKS',
      'employee': 'EMPLOYEE',
      'signer': 'SIGNER',
      'jnoRecPc': 'JNO REC PC',
      'shapeCode': 'SHAPE',
      'purityCode': 'PURITY',
      'diam': 'DIAM',
      'length': 'LENGTH',
      'ratio': 'RATIO',
      'planShape': 'PLAN SHAPE',
      'planPurity': 'PLAN PURITY',
      'colorCode': 'COLOR',
      'cutCode': 'CUT',
      'charniCode': 'CHARNI',
      'amount': 'AMOUNT RS',
      'qrCode': 'QRCODE',
      'partName': 'PART NAME',
      'diffDmWt': 'DIFF DM WT',
      'recutEmp': 'RECUT EMP',
      'orderMstId': 'ORDER MST ID',
      'plDmWt': 'PL. DM WT',
      'plDmPer': 'PL. DM PER',
    };
    return labels[key] ?? key;
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Consumer<MakableEntryProvider>(
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

  Widget _buildForm(BuildContext context) {
    return ErpForm(
      key: _erpFormKey,
      isShowSearch: true,
      autoStartAdding: _isAdding,
      addButtonSections: const {3},
      logo: AppImages.logo,
      title: 'MAKABLE ENTRY',
      tabBarBackgroundColor: const Color(0xfff2f0ef),
      tabBarSelectedColor: _theme.primaryGradient.first,
      tabBarSelectedTxtColor: Colors.white,
      rows: _buildFormRows(),
      initialValues: _formValues,
      isEditMode: _isEditMode,

      onEntryAdd: (sectionIndex) {
        if (sectionIndex != 3) return;
        _addEntry();
      },

      onFieldChanged: (key, value) {
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
              () => _erpFormKey.currentState?.focusField('remarks'),
            );

          case 'remarks':
            _entryVals[key] = value.toString();
            Future.delayed(
              const Duration(milliseconds: 100),
              () => _erpFormKey.currentState?.focusField('scanValue'),
            );
          case 'scanValue':
            _entryVals[key] = value.toString();

          case 'dmPer':
            final dmPerVal = double.tryParse(value.toString()) ?? 0;
            if (dmPerVal > 100) {
              _erpFormKey.currentState?.updateFieldValue('dmPer', '100');
              _entryVals['dmPer'] = '100';
            } else {
              _entryVals[key] = value.toString();
            }
            _calcDmWt();

          case 'dmWt':
            _entryVals[key] = value.toString();
            _calcDmPer();
            break;

          case 'recWt':
            _entryVals[key] = value.toString();
            _calcDmPer(); // 👈 ADD THIS
            _calcDmWt(); // already exists
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

      onFieldSubmitted: (key, value) async {
        // ─────────────────────────────
        // HEIGHT SUBMIT
        // ─────────────────────────────

        if (key == 'height') {
          // VALIDATION
          final height = double.tryParse(value.toString()) ?? 0;

          if (height <= 0) {
            _showSnack('Height must be greater than 0');

            return;
          }

          // ADD ENTRY
          _addEntry();

          return;
        }

        // ─────────────────────────────
        // SCAN VALUE
        // ─────────────────────────────

        if (key != 'scanValue') return;

        final scanVal = value.toString().trim();

        if (scanVal.isEmpty) return;

        // DUPLICATE CHECK
        if (_editingDetIndex == null) {
          final isDuplicate = _detRows.any(
            (r) => r.bCode?.toString() == scanVal,
          );

          if (isDuplicate) {
            _showSnack('This BCode already added');

            _erpFormKey.currentState?.updateFieldValue('scanValue', '');

            _entryVals['scanValue'] = '';

            Future.delayed(
              const Duration(milliseconds: 100),

              () => _erpFormKey.currentState?.focusField('scanValue'),
            );

            return;
          }
        }

        // MAIN API CALL
        _isBCodePending = true;

        _onBCodeScanned(scanVal);
      },

      onExit: () => context.read<TabProvider>().closeCurrentTab(),
      onSave: _detRows.isNotEmpty ? _onSave : null,
      onCancel: _resetForm,
      onDelete: _isEditMode ? _onDelete : null,
      onSearch: () => setState(() => _showTableOnMobile = true),

      detailBuilder: (ctx) {
        final t = ctx.erpTheme;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_detDisplay.isNotEmpty)
              ErpEntryGrid(
                data: _detDisplay,
                columns: _activeDetColumns,
                title: 'ISSUE DETAILS',
                theme: t,
                onDeleteRow: _deleteDetRow,
                onEditRow: _editDetRow,
                editingIndex: _editingDetIndex,
                columnLabels: {
                  for (final c in _activeDetColumns) c: _colLabel(c),
                },
                columnAlignments: const {
                  'orgPc': TextAlign.right,
                  'orgWt': TextAlign.right,
                  'issPc': TextAlign.right,
                  'issWt': TextAlign.right,
                  'recPc': TextAlign.right,
                  'recWt': TextAlign.right,
                  'dmPer': TextAlign.right,
                  'dmWt': TextAlign.right,
                  'kPc': TextAlign.right,
                  'kWt': TextAlign.right,
                  'brPc': TextAlign.right,
                  'brWt': TextAlign.right,
                  'lossPc': TextAlign.right,
                  'lossWt': TextAlign.right,
                  'topsPc': TextAlign.right,
                  'topsWt': TextAlign.right,
                  'remarks': TextAlign.right,
                  'employee': TextAlign.right,
                  'signer': TextAlign.right,
                  'jnoRecPc': TextAlign.right,
                  'shapeCode': TextAlign.right,
                  'planShape': TextAlign.right,
                  'colorCode': TextAlign.right,
                  'purityCode': TextAlign.right,
                  'planPurity': TextAlign.right,
                  'diam': TextAlign.right,
                  'length': TextAlign.right,
                  'ratio': TextAlign.right,
                  'amount': TextAlign.right,
                  'diffDmWt': TextAlign.right,
                  'recutEmp': TextAlign.right,
                  'cutCode': TextAlign.right,
                  'qrCode': TextAlign.right,
                  'partName': TextAlign.right,
                  'orderMstId': TextAlign.right,
                  'plDmPer': TextAlign.right,
                  'plDmWt': TextAlign.right,
                  'charniCode': TextAlign.right,
                },
                footerTotCount: 'Tot: ${_detRows.length}',
                footerTotals: _buildFooterTotals(),
              ),
          ],
        );
      },
    );
  }

  /// Compute footer totals map for ErpEntryGrid.
  Map<String, String> _buildFooterTotals() {
    double fold(double Function(SpkDeptIssDetModel) fn) =>
        _detRows.fold(0.0, (s, r) => s + fn(r));
    int foldInt(int Function(SpkDeptIssDetModel) fn) =>
        _detRows.fold(0, (s, r) => s + fn(r));

    final totDmWt = fold((r) => r.dmWt ?? 0);
    final totRecWt = fold((r) => r.recWt ?? 0);
    final totIssWt = fold((r) => r.issWt ?? 0);
    final base = totRecWt > 0 ? totRecWt : totIssWt;
    final dmPerStr = base > 0
        ? (totDmWt / base * 100).toStringAsFixed(2)
        : '0.00';

    return {
      // 🔹 PCS / WT
      'orgPc': '${foldInt((r) => r.pc ?? 0)}',
      'orgWt': fThreeDecimal(fold((r) => r.wt ?? 0)),

      'issPc': '${foldInt((r) => r.issPc ?? 0)}',
      'issWt': fThreeDecimal(totIssWt),

      'recPc': '${foldInt((r) => r.recPc ?? 0)}',
      'recWt': fThreeDecimal(totRecWt),

      // 🔹 DM
      'dmPer': dmPerStr,
      'dmWt': fThreeDecimal(totDmWt),

      // 🔹 K
      'kPc': '${foldInt((r) => r.kPc ?? 0)}',
      'kWt': fThreeDecimal(fold((r) => r.kWt ?? 0)),

      // 🔹 BR
      'brPc': '${foldInt((r) => r.brPc ?? 0)}',
      'brWt': fThreeDecimal(fold((r) => r.brWt ?? 0)),

      // 🔹 LOSS
      'lossPc': '${foldInt((r) => r.lossPc ?? 0)}',
      'lossWt': fThreeDecimal(fold((r) => r.lossWt ?? 0)),

      // 🔹 TOPS
      'topsPc': '${foldInt((r) => r.topsPc ?? 0)}',
      'topsWt': fThreeDecimal(fold((r) => r.topsWt ?? 0)),
      'plDmWt': fThreeDecimal(fold((r) => r.plDmWt ?? 0)),
      'plDmPer': fThreeDecimal(fold((r) => r.plDmPer ?? 0)),
      'diffDmWt': fThreeDecimal(fold((r) => r.diffDmWt ?? 0)),

      // 🔹 NEW (IMPORTANT)
      'amount': fThreeDecimal(fold((r) => r.amount ?? 0)), // ✅ if exists
      // ❌ DO NOT add totals for:
      // diam, length, ratio, shape, color, purity etc.
    };
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  TABLE WIDGET
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildTable(MakableEntryProvider prov) {
    final counterProv = context.read<CounterProvider>();
    final procProv = context.read<DeptProcessProvider>();

    final data = prov.list.where((e) => e.formType == 'MAKABLE MANUAL').map((
      e,
    ) {
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
      title: 'MAKABLE ENTRY LIST',
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
