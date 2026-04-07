import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:diam_mfg/providers/charni_provider.dart';
import 'package:diam_mfg/providers/counter_manager_det_provider.dart';
import 'package:diam_mfg/providers/counter_provider.dart';
import 'package:diam_mfg/providers/dept_provider.dart';
import 'package:diam_mfg/providers/dept_group_provider.dart';
import 'package:diam_mfg/providers/dept_process_provider.dart';
import 'package:diam_mfg/providers/employee_provider.dart';
import 'package:diam_mfg/providers/remarks_provider.dart';
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
import '../providers/trn_planning_received_provider.dart';
import '../providers/user_visibility_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  HELPERS
// ─────────────────────────────────────────────────────────────────────────────

String _f3(double? v) => v == null ? '0.000' : v.toStringAsFixed(3);

// ─────────────────────────────────────────────────────────────────────────────
//  WIDGET
// ─────────────────────────────────────────────────────────────────────────────

class TrnPlanningReceivedEntry extends StatefulWidget {
  const TrnPlanningReceivedEntry({super.key});

  @override
  State<TrnPlanningReceivedEntry> createState() =>
      _TrnPlanningReceivedEntryState();
}

// ─────────────────────────────────────────────────────────────────────────────
//  STATE
// ─────────────────────────────────────────────────────────────────────────────

class _TrnPlanningReceivedEntryState
    extends State<TrnPlanningReceivedEntry> {
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
  String? _highlightedBCode; // ← tracks which bCode to highlight in barcode table
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

  // ─────────────────────────────────────────────────────────────────────────
  //  PROVIDER SHORTCUTS
  // ─────────────────────────────────────────────────────────────────────────

  CounterDisplayDetProvider get _displayProv =>
      context.read<CounterDisplayDetProvider>();

  UserVisibilityProvider get _visProv =>
      context.read<UserVisibilityProvider>();

  // ─────────────────────────────────────────────────────────────────────────
  //  LOOKUP HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  String _deptNameFor(int? deptCode) {
    if (deptCode == null) return '';
    try {
      return context.read<DeptProvider>().list
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
      return context.read<DeptGroupProvider>().list
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
      return context.read<ShapeProvider>().list
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
      return context.read<PurityProvider>().list
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
      return context.read<EmployeeProvider>().list
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
      return context.read<CounterProvider>().list
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
      return context.read<RemarksProvider>().list
          .firstWhere((r) => r.remarksCode == code)
          .remarksName ??
          '';
    } catch (_) {
      return '';
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  MERGED FIELD HELPER
  // ─────────────────────────────────────────────────────────────────────────

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

  // ─────────────────────────────────────────────────────────────────────────
  //  INIT
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.wait([
        context.read<TrnPlanningReceivedProvider>().load(),
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
    final counter = context.read<CounterProvider>().list
        .firstWhereOrNull((c) => c.crId == crId);
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
    final counter = context.read<CounterProvider>().list
        .firstWhereOrNull((c) => c.crId == crId);
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

  List<UserVisibilityModel> _buildVisibilityList({
    required List<dynamic> rawList,
    required String counterType,
  }) {
    return rawList
        .where((r) =>
    r.counterType == counterType &&
        r.userVisibilityCode != null &&
        _visProv.list
            .any((v) => v.userVisibilityCode == r.userVisibilityCode))
        .map((r) => _visProv.list.firstWhereOrNull(
            (v) => v.userVisibilityCode == r.userVisibilityCode))
        .where((v) =>
    v != null &&
        v!.userVisibilityCode != null &&
        (v.userVisibilityName ?? '').isNotEmpty)
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
      final counter = context
          .read<CounterProvider>()
          .list
          .firstWhere((c) => c.crId == crId);
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
      final counter = context
          .read<CounterProvider>()
          .list
          .firstWhere((c) => c.crId == crId);
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
      _processSelected =
          _toDisplayFields.isNotEmpty || _fromDisplayFields.isNotEmpty;
      _isAdding = _processSelected;

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
    final rows = await context
        .read<TrnPlanningReceivedProvider>()
        .fetchByBCode(
      bCode: bCode,
      fromCrId: _fromCrId!.toString(),
    );

    if (!mounted) return;
    _isBCodePending = false;

    if (rows.isEmpty) {
      _showSnack('BCode "$bCode" not found!');
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
    set('orgWt', _f3(r.wt));
    set('issPc', r.issPc?.toString());
    set('issWt', _f3(r.issWt));
    set('jnoRecPc', r.jnoRecPc?.toString());
    set('shapeCode', r.shapeCode?.toString());
    set('purityCode', r.purityCode?.toString());

    setState(() => _scannedDet = r);
    // ── Now also update the BarCode table with sarinData from scanned row ──
    if (r.sarinData != null && r.sarinData!.isNotEmpty) {
      // sarinData is already on the model; _buildTableByBarCodeData
      // reads from prov.list which uses e.sarinData — so just rebuild
      setState(() {});
    }

    Future.delayed(
      const Duration(milliseconds: 100),
          () => _erpFormKey.currentState?.focusField('recpc'),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  CALCULATIONS
  // ─────────────────────────────────────────────────────────────────────────

  void _calcDmWt() {
    final recWt = double.tryParse(_entryVals['recwt'] ?? '') ?? 0;
    final issWt = double.tryParse(_entryVals['issWt'] ?? '') ?? 0;
    final base = recWt > 0 ? recWt : issWt;
    final dmPer = double.tryParse(_entryVals['dmper'] ?? '') ?? 0;
    final dmWt = base * dmPer / 100;
    _entryVals['dmwt'] = _f3(dmWt);
    _erpFormKey.currentState?.updateFieldValue('dmwt', _f3(dmWt));
  }

  void _calcLoss() {
    final issWt = double.tryParse(_entryVals['issWt'] ?? '') ?? 0;
    final recWt = double.tryParse(_entryVals['recwt'] ?? '') ?? 0;
    final kWt = double.tryParse(_entryVals['kwt'] ?? '') ?? 0;
    final issPc = int.tryParse(_entryVals['issPc'] ?? '') ?? 0;
    final kPc = int.tryParse(_entryVals['kpc'] ?? '') ?? 0;
    final lossWt = issWt - recWt - kWt;
    _entryVals['losswt'] = _f3(lossWt);
    _entryVals['losspc'] = '${issPc - kPc}';
    _erpFormKey.currentState?.updateFieldValue('losswt', _f3(lossWt));
    _erpFormKey.currentState?.updateFieldValue('losspc', '${issPc - kPc}');
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  ADD / EDIT ENTRY
  // ─────────────────────────────────────────────────────────────────────────

  void _addEntry() {
    final merged = _getMergedFields();

    // BCODE guard — must scan before adding
    if (_scannedDet == null && _editingDetIndex == null) {
      _isBCodePending = false;
      Future.delayed(
        const Duration(milliseconds: 50),
            () => _erpFormKey.currentState?.focusField('scanValue'),
      );
      return;
    }

    final issPc = int.tryParse(_entryVals['issPc'] ?? '') ?? 0;
    final issWt = double.tryParse(_entryVals['issWt'] ?? '') ?? 0;
    final recPc = int.tryParse(_entryVals['recpc'] ?? '') ?? 0;
    final recWt = double.tryParse(_entryVals['recwt'] ?? '') ?? 0;
    final kPc = int.tryParse(_entryVals['kpc'] ?? '') ?? 0;
    final kWt = double.tryParse(_entryVals['kwt'] ?? '') ?? 0;

    final totalPc = recPc + kPc;
    final totalWt = recWt + kWt;

    final hasRecPair =
        merged.containsKey('REC PC') || merged.containsKey('REC WT');
    final hasKPair =
        merged.containsKey('K PC') || merged.containsKey('K WT');

    if (hasRecPair || hasKPair) {
      if (totalPc > issPc && issPc > 0) {
        _showSnack(
            'Rec PC ($recPc) + K PC ($kPc) = $totalPc cannot exceed Iss PC ($issPc)');
        return;
      }
      if (totalWt > issWt + 0.0005 && issWt > 0) {
        _showSnack(
            'Rec Wt (${_f3(recWt)}) + K Wt (${_f3(kWt)}) = ${_f3(totalWt)} cannot exceed Iss Wt (${_f3(issWt)})');
        return;
      }
    }

    if (hasRecPair) {
      final recPcStr = _entryVals['recpc'] ?? '';
      final recWtStr = _entryVals['recwt'] ?? '';
      if (recPcStr.isNotEmpty && recWtStr.isEmpty) {
        _showSnack('Rec WT required when Rec PC entered!');
        _erpFormKey.currentState?.focusField('recwt');
        return;
      }
      if (recWtStr.isNotEmpty && recPcStr.isEmpty) {
        _showSnack('Rec PC required when Rec WT entered!');
        _erpFormKey.currentState?.focusField('recpc');
        return;
      }
    }

    if (hasKPair) {
      final kPcStr = _entryVals['kpc'] ?? '';
      final kWtStr = _entryVals['kwt'] ?? '';
      if (kPcStr.isNotEmpty && kWtStr.isEmpty) {
        _showSnack('K WT required when K PC entered!');
        _erpFormKey.currentState?.focusField('kwt');
        return;
      }
      if (kWtStr.isNotEmpty && kPcStr.isEmpty) {
        _showSnack('K PC required when K WT entered!');
        _erpFormKey.currentState?.focusField('kpc');
        return;
      }
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
      _lockMasterFields = true;
      _syncDetGrid();
    });

    _clearEntryFields();

    WidgetsBinding.instance.addPostFrameCallback(
            (_) => _erpFormKey.currentState?.focusField('scanValue'));

    _erpFormKey.currentState?.setFieldReadOnly('fromCrId', true);
    _erpFormKey.currentState?.setFieldReadOnly('toCrId', true);
    _erpFormKey.currentState?.setFieldReadOnly('deptProcessCode', true);
  }

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
      deptProcessCode: int.tryParse(_formValues['deptProcessCode'] ?? ''),
      pc: int.tryParse(_entryVals['orgPc'] ?? '') ?? existing.pc,
      wt: double.tryParse(_entryVals['orgWt'] ?? '') ?? existing.wt,
      issPc: int.tryParse(issPcStr),
      issWt: double.tryParse(issWtStr),
      recPc: recPc,
      recWt: recWt,
      totalPc: recPc,
      totalWt: recWt,
      dmWt: double.tryParse(_entryVals['dmwt'] ?? ''),
      dmPer: double.tryParse(_entryVals['dmper'] ?? ''),
      kPc: int.tryParse(_entryVals['kpc'] ?? ''),
      kWt: double.tryParse(_entryVals['kwt'] ?? ''),
      brPc: int.tryParse(_entryVals['brpc'] ?? ''),
      brWt: double.tryParse(_entryVals['brwt'] ?? ''),
      lossPc: int.tryParse(_entryVals['losspc'] ?? ''),
      lossWt: double.tryParse(_entryVals['losswt'] ?? ''),
      topsPc: int.tryParse(_entryVals['topspc'] ?? ''),
      topsWt: double.tryParse(_entryVals['topswt'] ?? ''),
      charniCode: int.tryParse(_formValues['charniCode'] ?? ''),
      tensionsCode: int.tryParse(_formValues['tensionsCode'] ?? ''),
      employeeCode: int.tryParse(_entryVals['employee'] ?? ''),
      signerCode: int.tryParse(_entryVals['signer'] ?? ''),
      remarksCode: int.tryParse(_entryVals['remarks'] ?? ''),
      dueDay: int.tryParse(_entryVals['dueDay'] ?? ''),
    );
  }

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
      shapeCode: _scannedDet?.shapeCode,
      purityCode: _scannedDet?.purityCode,
      colorCode: _scannedDet?.colorCode,
      diam: _scannedDet?.diam,
      kachaRec: _scannedDet?.kachaRec ?? 'Y',
      fromDeptCode: _fromDeptCode,
      toDeptCode: _toDeptCodeVal,
      fromCrId: _fromCrId,
      toCrId: _toCrId,
      deptProcessCode: int.tryParse(_formValues['deptProcessCode'] ?? ''),
      charniCode: int.tryParse(_formValues['charniCode'] ?? ''),
      tensionsCode: int.tryParse(_formValues['tensionsCode'] ?? ''),
      pc: int.tryParse(_entryVals['orgPc'] ?? ''),
      wt: double.tryParse(_entryVals['orgWt'] ?? ''),
      issPc: int.tryParse(issPcStr),
      issWt: double.tryParse(issWtStr),
      recPc: recPc,
      recWt: recWt,
      totalPc: recPc,
      totalWt: recWt,
      dmWt: double.tryParse(_entryVals['dmwt'] ?? ''),
      dmPer: double.tryParse(_entryVals['dmper'] ?? ''),
      kPc: int.tryParse(_entryVals['kpc'] ?? ''),
      kWt: double.tryParse(_entryVals['kwt'] ?? ''),
      brPc: int.tryParse(_entryVals['brpc'] ?? ''),
      brWt: double.tryParse(_entryVals['brwt'] ?? ''),
      lossPc: int.tryParse(_entryVals['losspc'] ?? ''),
      lossWt: double.tryParse(_entryVals['losswt'] ?? ''),
      topsPc: int.tryParse(_entryVals['topspc'] ?? ''),
      topsWt: double.tryParse(_entryVals['topswt'] ?? ''),
      employeeCode: int.tryParse(_entryVals['employee'] ?? ''),
      signerCode: int.tryParse(_entryVals['signer'] ?? ''),
      remarksCode: int.tryParse(_entryVals['remarks'] ?? ''),
      dueDay: int.tryParse(_entryVals['dueDay'] ?? ''),
      entryType: 'I',
      formType: 'SPK',
      pktType: 'A',
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
    set('orgWt', _f3(r.wt));
    set('issPc', r.issPc?.toString());
    set('issWt', _f3(r.issWt));
    set('recpc', r.recPc?.toString());
    set('recwt', _f3(r.recWt));
    set('dmper', r.dmPer?.toStringAsFixed(2));
    set('dmwt', _f3(r.dmWt));
    set('kpc', r.kPc?.toString());
    set('kwt', _f3(r.kWt));
    set('brpc', r.brPc?.toString());
    set('brwt', _f3(r.brWt));
    set('losspc', r.lossPc?.toString());
    set('losswt', _f3(r.lossWt));
    set('topspc', r.topsPc?.toString());
    set('topswt', _f3(r.topsWt));
    set('employee', r.employeeCode?.toString());
    set('signer', r.signerCode?.toString());
    set('remarks', r.remarksCode?.toString());
    set('dueDay', r.dueDay?.toString());
  }

  void _deleteDetRow(int idx) {
    setState(() {
      _detRows.removeAt(idx);
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
          purityCode: v.purityCode,
          colorCode: v.colorCode,
          diam: v.diam,
          kachaRec: v.kachaRec,
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
      'orgPc', 'orgWt', 'issPc', 'issWt',
      'recpc', 'recwt',
      'dmwt', 'dmper',
      'kpc', 'kwt',
      'brpc', 'brwt',
      'losspc', 'losswt',
      'topspc', 'topswt',
      'employee', 'signer', 'remarks', 'dueDay',
      'scanValue',
    ];
    for (final k in keys) {
      _entryVals.remove(k);
      _erpFormKey.currentState?.updateFieldValue(k, '');
    }
    _scannedDet = null;
    _isBCodePending = false;
    _entryVals['scanValue'] = '';
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  SYNC DET GRID
  // ─────────────────────────────────────────────────────────────────────────

  void _syncDetGrid() {
    final merged = _getMergedFields();

    final cols = <String>[
      'srno', 'bCode', 'pktNo', 'cutNo', 'orgPc', 'orgWt', 'issPc', 'issWt'
    ];

    void addIfPresent(String key1, String key2, List<String> colKeys) {
      if (merged.containsKey(key1) || merged.containsKey(key2)) {
        cols.addAll(colKeys);
      }
    }

    addIfPresent('REC PC', 'REC WT', ['recPc', 'recWt']);
    addIfPresent('DM PER', 'DM WT', ['dmPer', 'dmWt']);
    addIfPresent('K PC', 'K WT', ['kPc', 'kWt']);
    addIfPresent('BR PC', 'BR WT', ['brPc', 'brWt']);
    addIfPresent('LOSS PC', 'LOSS WT', ['lossPc', 'lossWt']);
    addIfPresent('TOPS PC', 'TOPS WT', ['topsPc', 'topsWt']);

    if (merged.containsKey('REMARKS')) cols.add('remarks');
    if (merged.containsKey('EMPLOYEE')) cols.add('employee');
    if (merged.containsKey('SIGNER')) cols.add('signer');

    cols.addAll(['jnoRecPc', 'shapeCode', 'purityCode']);
    _activeDetColumns = cols;

    _detDisplay = _detRows.map((r) => {
      'srno': r.srno?.toString() ?? '',
      'bCode': r.bCode ?? '',
      'pktNo': r.pktNo ?? '',
      'cutNo': r.cutNo ?? '',
      'orgPc': r.pc?.toString() ?? '',
      'orgWt': _f3(r.wt),
      'issPc': r.issPc?.toString() ?? '',
      'issWt': _f3(r.issWt),
      'recPc': r.recPc?.toString() ?? '',
      'recWt': _f3(r.recWt),
      'dmPer': r.dmPer?.toStringAsFixed(2) ?? '',
      'dmWt': _f3(r.dmWt),
      'kPc': r.kPc?.toString() ?? '',
      'kWt': _f3(r.kWt),
      'brPc': r.brPc?.toString() ?? '',
      'brWt': _f3(r.brWt),
      'lossPc': r.lossPc?.toString() ?? '',
      'lossWt': _f3(r.lossWt),
      'topsPc': r.topsPc?.toString() ?? '',
      'topsWt': _f3(r.topsWt),
      'employee': _employeeNameFor(r.employeeCode),
      'signer': _signerNameFor(r.signerCode),
      'remarks': _remarksNameFor(r.remarksCode),
      'jnoRecPc': r.jnoRecPc?.toString() ?? '',
      'shapeCode': _shapeNameFor(r.shapeCode),
      'purityCode': _purityNameFor(r.purityCode),
    }).toList();
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  DET TABLE COLUMNS
  // ─────────────────────────────────────────────────────────────────────────

  List<ErpColumnConfig> get _detTableColumns => [
    ErpColumnConfig(key: 'srno', label: 'SR NO', width: 70),
    ErpColumnConfig(key: 'bCode', label: 'BCODE', width: 130),
    ErpColumnConfig(key: 'pktNo', label: 'PKT NO', width: 100),
    ErpColumnConfig(key: 'cutNo', label: 'CUT NO', width: 100),
    ErpColumnConfig(
        key: 'orgPc', label: 'ORG PC', width: 90,
        align: ColumnAlign.right),
    ErpColumnConfig(
        key: 'orgWt', label: 'ORG WT', width: 100,
        align: ColumnAlign.right),
    ErpColumnConfig(
        key: 'issPc', label: 'ISS PC', width: 90,
        align: ColumnAlign.right),
    ErpColumnConfig(
        key: 'issWt', label: 'ISS WT', width: 100,
        align: ColumnAlign.right),
    ErpColumnConfig(
        key: 'recPc', label: 'REC PC', width: 90,
        align: ColumnAlign.right),
    ErpColumnConfig(
        key: 'recWt', label: 'REC WT', width: 100,
        align: ColumnAlign.right),
    ErpColumnConfig(
        key: 'dmPer', label: 'DM PER', width: 90,
        align: ColumnAlign.right),
    ErpColumnConfig(
        key: 'dmWt', label: 'DM WT', width: 100,
        align: ColumnAlign.right),
    ErpColumnConfig(
        key: 'kPc', label: 'K PC', width: 80,
        align: ColumnAlign.right),
    ErpColumnConfig(
        key: 'kWt', label: 'K WT', width: 90,
        align: ColumnAlign.right),
    ErpColumnConfig(
        key: 'brPc', label: 'BR PC', width: 80,
        align: ColumnAlign.right),
    ErpColumnConfig(
        key: 'brWt', label: 'BR WT', width: 90,
        align: ColumnAlign.right),
    ErpColumnConfig(
        key: 'lossPc', label: 'LOSS PC', width: 90,
        align: ColumnAlign.right),
    ErpColumnConfig(
        key: 'lossWt', label: 'LOSS WT', width: 100,
        align: ColumnAlign.right),
    ErpColumnConfig(
        key: 'topsPc', label: 'TOPS PC', width: 90,
        align: ColumnAlign.right),
    ErpColumnConfig(
        key: 'topsWt', label: 'TOPS WT', width: 100,
        align: ColumnAlign.right),
    ErpColumnConfig(key: 'remarks', label: 'REMARKS', width: 120),
    ErpColumnConfig(key: 'employee', label: 'EMPLOYEE', width: 130),
    ErpColumnConfig(key: 'signer', label: 'SIGNER', width: 120),
    ErpColumnConfig(
        key: 'jnoRecPc', label: 'JNO REC PC', width: 110,
        align: ColumnAlign.right),
    ErpColumnConfig(key: 'shapeCode', label: 'SHAPE', width: 100),
    ErpColumnConfig(key: 'purityCode', label: 'PURITY', width: 100),
  ];

  // ─────────────────────────────────────────────────────────────────────────
  //  ROW TAP
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _onRowTap(Map<String, dynamic> row) async {
    final raw = row['_raw'] as SpkDeptIssMstModel;
    final prov = context.read<TrnPlanningReceivedProvider>();
    final details = await prov.loadDetails(raw.spkDeptIssMstID!);
    if (!mounted) return;

    if (raw.fromCrID != null) _onFromSelected(raw.fromCrID.toString());
    if (raw.toCrID != null) _onToSelected(raw.toCrID.toString());

    if (raw.deptProcessCode != null && _toCrId != null && _fromCrId != null) {
      await _loadToDisplayFields(_toCrId!);
      await _loadFromDisplayFields(_fromCrId!);
    }
    if (!mounted) return;

    final lastDet = details.isNotEmpty ? details.last : null;

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
        if (lastDet?.charniCode != null)
          'charniCode': lastDet!.charniCode!.toString(),
        if (lastDet?.tensionsCode != null)
          'tensionsCode': lastDet!.tensionsCode!.toString(),
      };

      _syncDetGrid();
    });

    _rebuildForm();
  }

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
    final prov = context.read<TrnPlanningReceivedProvider>();

    String toIso(String? v) {
      if (v == null || v.isEmpty) return '';
      try {
        return DateFormat('yyyy-MM-dd')
            .format(DateFormat('dd/MM/yyyy').parse(v));
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
        ? await prov.update(
        _selectedMst!.spkDeptIssMstID!, merged, _detRows)
        : await prov.create(merged, _detRows);

    if (!mounted) return;
    if (success) {
      final wasEdit = _isEditMode;
      _resetForm();
      await ErpResultDialog.showSuccess(
        context: context,
        theme: _theme,
        title: wasEdit ? 'Updated' : 'Saved',
        message:
        wasEdit ? 'Dept Issue updated.' : 'Dept Issue saved.',
      );
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

    final success = await context
        .read<TrnPlanningReceivedProvider>()
        .delete(_selectedMst!.spkDeptIssMstID!);

    if (success && mounted) {
      final id = _selectedMst?.spkDeptIssMstID;
      _resetForm();
      await ErpResultDialog.showDeleted(
          context: context,
          theme: _theme,
          itemName: 'Dept Issue $id');
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

  void _showSnack(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg)));

  // ─────────────────────────────────────────────────────────────────────────
  //  BUILD FORM ROWS
  // ─────────────────────────────────────────────────────────────────────────

  List<List<ErpFieldConfig>> _buildFormRows() {
    final counterProv = context.read<CounterProvider>();
    final mgDetProv = context.read<CounterManagerDetProvider>();
    final procProv = context.read<DeptProcessProvider>();
    final charniProv = context.read<CharniProvider>();
    final tensProv = context.read<TensionsProvider>();

    final isFromSelected = _fromCrId != null;
    final isToSelected = _toCrId != null;

    final fromItems = counterProv.list
        .where((c) {
      final grp = _deptGroupNameFor(c.deptGroupCode).toUpperCase();
      return grp.contains('CLEAVING') || grp.contains('CLV');
    })
        .map((c) => ErpDropdownItem(
      label: '${c.crName ?? ''}  |  ${_deptNameFor(c.deptCode)}',
      value: c.crId?.toString() ?? '',
    ))
        .toList();

    final toItems = _fromCrId == null
        ? <ErpDropdownItem>[]
        : mgDetProv.list
        .where((m) => m.crId == _fromCrId && m.allowCrId != null)
        .map((m) => m.allowCrId!)
        .toSet()
        .map((allowId) {
      try {
        final c =
        counterProv.list.firstWhere((c) => c.crId == allowId);
        return ErpDropdownItem(
          label:
          '${c.crName ?? ''}  |  ${_deptNameFor(c.deptCode)}',
          value: c.crId?.toString() ?? '',
        );
      } catch (_) {
        return ErpDropdownItem(
            label: 'ID:$allowId', value: '$allowId');
      }
    }).toList();

    final processItems = (_fromCrId == null || _toCrId == null)
        ? <ErpDropdownItem>[]
        : () {
      final issueCodes = mgDetProv.list
          .where((m) =>
      m.crId == _fromCrId && m.deptProcessCode != null)
          .map((m) => m.deptProcessCode!)
          .toSet();
      final recvCodes = mgDetProv.list
          .where((m) =>
      m.allowCrId == _toCrId && m.deptProcessCode != null)
          .map((m) => m.deptProcessCode!)
          .toSet();
      return issueCodes.intersection(recvCodes).map((code) {
        String label = '$code';
        try {
          label = procProv.list
              .firstWhere((p) => p.deptProcessCode == code)
              .deptProcessName ??
              '$code';
        } catch (_) {}
        return ErpDropdownItem(
            label: label, value: code.toString());
      }).toList();
    }();

    final charniItems = charniProv.list
        .where((e) => e.active == true)
        .map((e) => ErpDropdownItem(
      label: e.charniName ?? '',
      value: e.charniCode?.toString() ?? '',
    ))
        .toList();

    final tensItems = tensProv.list.where((e) => e.active == true).toList()
      ..sort((a, b) => (a.sortID ?? 0).compareTo(b.sortID ?? 0));
    final tensDropdown = tensItems
        .map((e) => ErpDropdownItem(
      label: e.tensionsName ?? '',
      value: e.tensionsCode?.toString() ?? '',
    ))
        .toList();

    final Map<String, UserVisibilityModel> merged = {};
    for (final f in [..._fromDisplayFields, ..._toDisplayFields]) {
      final name = (f.userVisibilityName ?? '').toUpperCase();
      if (f.entryType != 'DEPT') continue;
      if (['ALL'].contains(name)) continue;
      merged[name] = f;
    }

    // ── MASTER SECTION ────────────────────────────────────────────────────
    final List<List<ErpFieldConfig>> rows = [
      [
        ErpFieldConfig(
            key: 'spkDeptIssDate',
            label: 'DATE',
            type: ErpFieldType.date,
            readOnly: true,
            sectionIndex: 0),
        ErpFieldConfig(
            key: 'time',
            label: 'TIME',
            type: ErpFieldType.text,
            readOnly: true,
            sectionIndex: 0),
        ErpFieldConfig(
            key: 'spkDeptIssMstID',
            label: 'ID',
            type: ErpFieldType.number,
            readOnly: true,
            sectionIndex: 0),
      ],
      [
        ErpFieldConfig(
            key: 'fromCrId',
            label: 'FROM',
            type: ErpFieldType.dropdown,
            dropdownItems: fromItems,
            sectionIndex: 0,
            readOnly: _lockMasterFields || _isEditMode),
        ErpFieldConfig(
            key: 'fromDept',
            label: 'MANAGER',
            type: ErpFieldType.text,
            readOnly: true,
            sectionIndex: 0),
        ErpFieldConfig(
            key: 'toCrId',
            label: 'TO',
            type: ErpFieldType.dropdown,
            dropdownItems: toItems,
            readOnly:
            !isFromSelected || _lockMasterFields || _isEditMode,
            sectionIndex: 0),
        ErpFieldConfig(
            key: 'toDept',
            label: 'MANAGER',
            type: ErpFieldType.text,
            readOnly: true,
            sectionIndex: 0),
        ErpFieldConfig(
            key: 'deptProcessCode',
            label: 'PROCESS',
            type: ErpFieldType.dropdown,
            dropdownItems: processItems,
            readOnly:
            !isToSelected || _lockMasterFields || _isEditMode,
            sectionIndex: 0),
        ErpFieldConfig(
            key: 'deptName',
            label: 'DEPT',
            type: ErpFieldType.text,
            readOnly: true,
            sectionIndex: 0),
      ],
      [
        ErpFieldConfig(
            key: 'scanValue',
            label: 'BCODE',
            type: ErpFieldType.text,
            isEntryField: true,
            readOnly: false,
            sectionIndex: 3,
            width: 200),
      ]
    ];
    return _sanitizeRows(rows);
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  SANITIZE ROWS
  // ─────────────────────────────────────────────────────────────────────────

  List<List<ErpFieldConfig>> _sanitizeRows(List<List<ErpFieldConfig>> rows) {
    return rows.map((section) {
      return section.whereType<ErpFieldConfig>().map((field) {
        final safeItems = (field.dropdownItems ?? [])
            .whereType<ErpDropdownItem>()
            .where(
                (item) => item.value.isNotEmpty && item.label.isNotEmpty)
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
  //  TABLE COLUMNS (master list)
  // ─────────────────────────────────────────────────────────────────────────

  List<ErpColumnConfig> get _tableColumns => [
    ErpColumnConfig(
        key: 'spkDeptIssMstID', label: 'ID', width: 70, required: true),
    ErpColumnConfig(
        key: 'spkDeptIssDate', label: 'DATE', width: 160, isDate: true),
    ErpColumnConfig(key: 'spkDeptIssTime', label: 'TIME', width: 140),
    ErpColumnConfig(key: 'fromName', label: 'FROM MGR', width: 180),
    ErpColumnConfig(key: 'fromDeptName', label: 'FROM DEPT', width: 180),
    ErpColumnConfig(key: 'toName', label: 'TO MGR', width: 160),
    ErpColumnConfig(key: 'toDeptName', label: 'TO DEPT', width: 160),
    ErpColumnConfig(key: 'processName', label: 'PROCESS', width: 150),
    ErpColumnConfig(key: 'deptName', label: 'DEPT', width: 140),
    ErpColumnConfig(
        key: 'jno', label: 'JNO', width: 140, align: ColumnAlign.right),
    ErpColumnConfig(
        key: 'totPkt',
        label: 'TOT PKT',
        width: 170,
        align: ColumnAlign.right),
    ErpColumnConfig(
        key: 'totalPc',
        label: 'TOT PC',
        width: 170,
        align: ColumnAlign.right),
    ErpColumnConfig(
        key: 'totalWt',
        label: 'TOT WT',
        width: 170,
        align: ColumnAlign.right),
  ];

  List<ErpColumnConfig> get _tableColumnsByBarCode => [
    ErpColumnConfig(label: 'Sarin ID',     key: 'sarinPolID'),
    ErpColumnConfig(label: 'Stone ID',     key: 'stoneID'),
    ErpColumnConfig(label: 'Polish Wt',    key: 'polishWT'),
    ErpColumnConfig(label: 'Polish %',     key: 'polishPer'),
    ErpColumnConfig(label: 'Shape',        key: 'shape'),
    ErpColumnConfig(label: 'Cut',          key: 'cut'),
    ErpColumnConfig(label: 'Color',        key: 'color'),
    ErpColumnConfig(label: 'Clarity',      key: 'clarity'),
    ErpColumnConfig(label: 'Total Wt',     key: 'tWT'),
    ErpColumnConfig(label: 'Rate',         key: 'rate'),
    ErpColumnConfig(label: 'Amt',          key: 'amt'),
    ErpColumnConfig(label: 'Lot Code',     key: 'lotCode'),
    ErpColumnConfig(label: 'Kapan No',     key: 'kapanNo'),
    ErpColumnConfig(label: 'Sr Num',       key: 'srNum'),
    ErpColumnConfig(label: 'Crown Height', key: 'crownHeight'),
    ErpColumnConfig(label: 'Operator',     key: 'operatorName'),
    ErpColumnConfig(label: 'THmm',         key: 'tHmm'),
    ErpColumnConfig(label: 'Disc',         key: 'disc'),
    ErpColumnConfig(label: 'Rec',          key: 'rec'),
  ];


  // ─────────────────────────────────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Consumer<TrnPlanningReceivedProvider>(
      builder: (ctx, prov, _) => Padding(
        padding: const EdgeInsets.all(8),
        child: Responsive.isMobile(context)
            ? (_showTableOnMobile
            ? _buildTable(prov)
            : _buildForm(context,prov))
            : Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_showTableOnMobile)
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Flexible( // 👈 instead of plain widget
                      flex: 1,
                      child: _buildForm(context, prov),
                    ),

                    Flexible(
                      flex: 2,
                      child: Row(
                        children: [
                          Expanded(child: _buildTableDefaultData(prov)),
                          SizedBox(width: 15),
                          Expanded(child: _buildTableByBarCodeData(prov)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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

  Widget _buildForm(BuildContext context,prov) {
    return ErpForm(
      key: _erpFormKey,
      isShowSearch: true,
      autoStartAdding: _isAdding,
      addButtonSections: const {3},
      logo: AppImages.logo,
      title: 'PLANNING RECEIVED ENTRY',
      tabBarBackgroundColor: const Color(0xfff2f0ef),
      tabBarSelectedColor: _theme.primaryGradient.first,
      tabBarSelectedTxtColor: Colors.white,
      rows: _buildFormRows(),
      initialValues: _formValues,
      isEditMode: _isEditMode,

      onEntryAdd: (sectionIndex) {
        if (sectionIndex != 3) return;
        if (_scannedDet == null && _editingDetIndex == null) {
          Future.delayed(
            const Duration(milliseconds: 50),
                () => _erpFormKey.currentState?.focusField('scanValue'),
          );
          return;
        }
        // _addEntry();
      },

      onFieldChanged: (key, value) {
        _formValues[key] = value.toString();

        switch (key) {
          case 'fromCrId':
            _onFromSelected(value.toString());
            Future.delayed(
                const Duration(milliseconds: 50),
                    () =>
                    _erpFormKey.currentState?.focusField('toCrId'));

          case 'toCrId':
            _onToSelected(value.toString());
            Future.delayed(
                const Duration(milliseconds: 50),
                    () => _erpFormKey.currentState
                    ?.focusField('deptProcessCode'));

          case 'deptProcessCode':
            _onProcessSelected(value.toString());
            Future.delayed(
                const Duration(milliseconds: 100),
                    () =>
                    _erpFormKey.currentState?.focusField('scanValue'));

          case 'scanValue':
            _entryVals[key] = value.toString();

          case 'dmper':
            final dmPerVal = double.tryParse(value.toString()) ?? 0;
            if (dmPerVal > 100) {
              _erpFormKey.currentState
                  ?.updateFieldValue('dmper', '100');
              _entryVals['dmper'] = '100';
            } else {
              _entryVals[key] = value.toString();
            }
            _calcDmWt();

          case 'recwt':
            _entryVals[key] = value.toString();
            _calcDmWt();

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
        if (key != 'scanValue') return;

        final scanVal = value.toString().trim();
        if (scanVal.isEmpty) return;
        if (_fromCrId == null) return;

        // Duplicate check
        if (_editingDetIndex == null) {
          final isDuplicate =
          _detRows.any((r) => r.bCode?.toString() == scanVal);
          if (isDuplicate) {
            ErpResultDialog.showError(
              context: context,
              theme: _theme,
              title: 'Duplicate',
              message: 'This bCode already added.',
            );
            _erpFormKey.currentState
                ?.updateFieldValue('scanValue', '');
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
      },

      onExit: () => context.read<TabProvider>().closeCurrentTab(),
      onSave: _onSave,
      onCancel: _resetForm,
      onDelete: _isEditMode ? _onDelete : null,
      onSearch: () => setState(() => _showTableOnMobile = true),

    );
  }

  /// Footer totals for detail grid.
  Map<String, String> _buildFooterTotals() {
    double fold(double Function(SpkDeptIssDetModel) fn) =>
        _detRows.fold(0.0, (s, r) => s + fn(r));
    int foldInt(int Function(SpkDeptIssDetModel) fn) =>
        _detRows.fold(0, (s, r) => s + fn(r));

    final totDmWt = fold((r) => r.dmWt ?? 0);
    final totRecWt = fold((r) => r.recWt ?? 0);
    final totIssWt = fold((r) => r.issWt ?? 0);
    final base = totRecWt > 0 ? totRecWt : totIssWt;
    final dmPerStr =
    base > 0 ? (totDmWt / base * 100).toStringAsFixed(2) : '0.00';

    return {
      'orgPc': '${foldInt((r) => r.pc ?? 0)}',
      'orgWt': _f3(fold((r) => r.wt ?? 0)),
      'issPc': '${foldInt((r) => r.issPc ?? 0)}',
      'issWt': _f3(totIssWt),
      'recPc': '${foldInt((r) => r.recPc ?? 0)}',
      'recWt': _f3(totRecWt),
      'dmPer': dmPerStr,
      'dmWt': _f3(totDmWt),
      'kPc': '${foldInt((r) => r.kPc ?? 0)}',
      'kWt': _f3(fold((r) => r.kWt ?? 0)),
      'brPc': '${foldInt((r) => r.brPc ?? 0)}',
      'brWt': _f3(fold((r) => r.brWt ?? 0)),
      'lossPc': '${foldInt((r) => r.lossPc ?? 0)}',
      'lossWt': _f3(fold((r) => r.lossWt ?? 0)),
      'topsPc': '${foldInt((r) => r.topsPc ?? 0)}',
      'topsWt': _f3(fold((r) => r.topsWt ?? 0)),
    };
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  MASTER TABLE WIDGET
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildTable(TrnPlanningReceivedProvider prov) {
    final counterProv = context.read<CounterProvider>();
    final procProv = context.read<DeptProcessProvider>();

    final data = prov.list.map((e) {
      String fromName = '', toName = '', processName = '';
      String fromDeptName = '', toDeptName = '';

      try {
        final c =
        counterProv.list.firstWhere((c) => c.crId == e.fromCrID);
        fromName = c.crName ?? '';
        fromDeptName = _deptNameFor(c.deptCode);
      } catch (_) {}

      try {
        final c =
        counterProv.list.firstWhere((c) => c.crId == e.toCrID);
        toName = c.crName ?? '';
        toDeptName = _deptNameFor(c.deptCode);
      } catch (_) {}

      try {
        processName = procProv.list
            .firstWhere((p) => p.deptProcessCode == e.deptProcessCode)
            .deptProcessName ??
            '';
      } catch (_) {}

      final dets = prov.detMap[e.spkDeptIssMstID] ?? [];

      return e.toTableRow()
        ..['fromName'] = fromName
        ..['fromDeptName'] = fromDeptName
        ..['toName'] = toName
        ..['toDeptName'] = toDeptName
        ..['deptName'] = toDeptName
        ..['processName'] = processName
        ..['spkDeptIssTime'] = _formatTime(e.stime)
        ..['jno'] =
        dets.isNotEmpty ? (dets.first.jno?.toString() ?? '') : ''
        ..['totPkt'] = '${dets.length}'
        ..['totalPc'] =
            '${dets.fold<int>(0, (s, r) => s + (r.totalPc ?? 0))}'
        ..['totalWt'] = _f3(
            dets.fold<double>(0.0, (s, r) => s + (r.totalWt ?? 0.0)));
    }).toList();

    return ErpDataTable(
      isReportRow: false,
      token: token ?? '',
      url: baseUrl,
      title: 'PLANNING RECEIVED LIST',
      columns: _tableColumns,
      data: data,
      showSearch: true,
      dateFilter: true,
      searchFields: const [
        ErpSearchFieldConfig(key: 'fromName', label: 'FROM', width: 150),
        ErpSearchFieldConfig(key: 'toName', label: 'TO', width: 150),
      ],
      selectedRow: _selectedRow,
      onRowTap: _onRowTap,
      emptyMessage: prov.isLoaded ? 'No entries found' : 'Loading...',
    );
  }
  Widget _buildTableDefaultData(TrnPlanningReceivedProvider prov) {
    final counterProv = context.read<CounterProvider>();
    final procProv = context.read<DeptProcessProvider>();

    final data = prov.list.map((e) {
      String fromName = '', toName = '', processName = '';
      String fromDeptName = '', toDeptName = '';

      try {
        final c =
        counterProv.list.firstWhere((c) => c.crId == e.fromCrID);
        fromName = c.crName ?? '';
        fromDeptName = _deptNameFor(c.deptCode);
      } catch (_) {}

      try {
        final c =
        counterProv.list.firstWhere((c) => c.crId == e.toCrID);
        toName = c.crName ?? '';
        toDeptName = _deptNameFor(c.deptCode);
      } catch (_) {}

      try {
        processName = procProv.list
            .firstWhere((p) => p.deptProcessCode == e.deptProcessCode)
            .deptProcessName ??
            '';
      } catch (_) {}

      final dets = prov.detMap[e.spkDeptIssMstID] ?? [];

      return e.toTableRow()
        ..['fromName'] = fromName
        ..['fromDeptName'] = fromDeptName
        ..['toName'] = toName
        ..['toDeptName'] = toDeptName
        ..['deptName'] = toDeptName
        ..['processName'] = processName
        ..['spkDeptIssTime'] = _formatTime(e.stime)
        ..['jno'] =
        dets.isNotEmpty ? (dets.first.jno?.toString() ?? '') : ''
        ..['totPkt'] = '${dets.length}'
        ..['totalPc'] =
            '${dets.fold<int>(0, (s, r) => s + (r.totalPc ?? 0))}'
        ..['totalWt'] = _f3(
            dets.fold<double>(0.0, (s, r) => s + (r.totalWt ?? 0.0)))
      ..['bCode'] = e.bCode?.toString() ?? ''; // ← ADD THIS

    }).toList();

    Future<void> _onRowTap(Map<String, dynamic> row) async {
      final raw = row['_raw'] as SpkDeptIssMstModel;
      print('raw.bCode?.toString() ${raw.bCode?.toString()}');
      setState(() {
        _selectedRow = row;
        _highlightedBCode = raw.bCode?.toString(); // ← directly from _raw
      });
    }

    return ErpDataTable(
      isReportRow: false,
      token: token ?? '',
      url: baseUrl,
      title: 'PLANNING RECEIVED LIST',
      columns: _tableColumns,
      data: data,
      showHeader: false,
      showSearch: false,
      selectedRow: _selectedRow,
      onRowTap: (val) => _onRowTap(val),
      emptyMessage: prov.isLoaded ? 'No entries found' : 'Loading...',
    );
  }
  Widget _buildTableByBarCodeData(TrnPlanningReceivedProvider prov) {
    final List<Map<String, dynamic>> data = [];
    // sarinData lives on SpkDeptIssDetModel from the scan response
    if(prov.scannedDetList.isNotEmpty){
      for (final det in prov.scannedDetList) {
        final sarinList = det.sarinData ?? [];

        if (sarinList.isEmpty) {
          data.add(_buildDetSarinRow(det: det, sarin: null));
        } else {
          for (final sarin in sarinList) {
            data.add(_buildDetSarinRow(det: det, sarin: sarin));
          }
        }
      }
    }
    return ErpDataTable(
      isReportRow: false,
      token: token ?? '',
      url: baseUrl,
      title: 'SARIN DATA',
      columns: _tableColumnsByBarCode,
      data: data,
      showHeader: false,
      showSearch: false,
      selectedRow: _selectedRow,
      isAllowHighlight: true,       // ← enable highlight
      highlightKey: 'bCode',        // ← match by bCode field
      highlightValue: _highlightedBCode,  // ← NEW param
      onRowTap: (val) => {},
      emptyMessage: prov.isLoaded ? 'No entries found' : 'Loading...',
    );
  }

  Map<String, dynamic> _buildDetSarinRow({
    required SpkDeptIssDetModel det,
    required Map<String, dynamic>? sarin,
  }) {
    return {
      // ── Sarin fields ────────────────────────────────────────────────────
      'sarinPolID':    sarin?['SarinPolID']?.toString() ?? '',
      'stoneID':       sarin?['StoneID']?.toString() ?? '',
      'polishWT':      sarin?['PolishWT']?.toString() ?? '',
      'polishPer':     sarin?['PolishPer']?.toString() ?? '',
      'shape':         sarin?['SHAPE']?.toString() ?? '',
      'cut':           sarin?['CUT']?.toString() ?? '',
      'color':         sarin?['Color']?.toString() ?? '',
      'clarity':       sarin?['Clarity']?.toString() ?? '',
      'tWT':           sarin?['TWT']?.toString() ?? '',
      'rate':          sarin?['Rate']?.toString() ?? '',
      'amt':           sarin?['AMT']?.toString() ?? '',
      'lotCode':       sarin?['LotCode']?.toString() ?? '',
      'kapanNo':       sarin?['KapanNo']?.toString() ?? '',
      'srNum':         (sarin?['SrNum'] ?? '').toString().trim(),
      'crownHeight':   (sarin?['CrownHeight'] ?? '').toString().trim(),
      'operatorName':  sarin?['operatorName']?.toString() ?? '',
      'tHmm':          sarin?['THmm']?.toString() ?? '',
      'disc':          sarin?['DISC']?.toString() ?? '',
      'rec':           sarin?['Rec']?.toString() ?? '',
      'bCode':           sarin?['BCode']?.toString() ?? '',
    };
  }
}