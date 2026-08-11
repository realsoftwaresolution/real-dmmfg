// lib/screens/trn_spk_dept_iss_entry.dart

import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:diam_mfg/models/company_model.dart';
import 'package:diam_mfg/providers/charni_provider.dart';
import 'package:diam_mfg/providers/company_provider.dart';
import 'package:diam_mfg/providers/counter_manager_det_provider.dart';
import 'package:diam_mfg/providers/counter_provider.dart';
import 'package:diam_mfg/providers/dept_provider.dart';
import 'package:diam_mfg/providers/dept_group_provider.dart';
import 'package:diam_mfg/providers/dept_process_provider.dart';
import 'package:diam_mfg/providers/employee_provider.dart';
import 'package:diam_mfg/providers/remarks_provider.dart';
import 'package:diam_mfg/providers/spk_dept_iss_provider.dart';
import 'package:diam_mfg/providers/tensions_provider.dart';
import 'package:diam_mfg/services/generateJobWorkPdf.dart';
import 'package:diam_mfg/utils/app_images.dart';
import 'package:diam_mfg/utils/delete_dialogue.dart';
import 'package:diam_mfg/utils/helper_functions.dart';
import 'package:diam_mfg/utils/msg_dialogue.dart';
import 'package:diam_mfg/utils/process_constants.dart';
import 'package:erp_data_table/erp_data_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
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

class TrnSpkDeptIssEntry extends StatefulWidget {
  const TrnSpkDeptIssEntry({super.key});

  @override
  State<TrnSpkDeptIssEntry> createState() => _TrnSpkDeptIssEntryState();
}

// ─────────────────────────────────────────────────────────────────────────────
//  STATE
// ─────────────────────────────────────────────────────────────────────────────

class _TrnSpkDeptIssEntryState extends State<TrnSpkDeptIssEntry> {
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
  String? _toDeptName;
  int? _toDeptCodeVal;
  String _autoRec = 'N';
  CompanyModel? _selectedCompany;

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
    _resetForm();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.wait([
        context.read<CounterProvider>().load(),
        context.read<CounterManagerDetProvider>().load(),
        context.read<DeptProvider>().load(),
        context.read<DeptGroupProvider>().load(),
        context.read<DeptProcessProvider>().load(),
        context.read<CounterDisplayDetProvider>().load(),
        context.read<UserVisibilityProvider>().load(),
        context.read<SpkDeptIssProvider>().load(),
        context.read<CharniProvider>().load(),
        context.read<TensionsProvider>().load(),
        context.read<EmployeeProvider>().loadEmployees(),
        context.read<RemarksProvider>().load(),
        context.read<ShapeProvider>().load(),
        context.read<PurityProvider>().load(),
        context.read<CompanyProvider>().loadCompanies(),
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

  @override
  void dispose() {
    _erpFormKey.currentState?.dispose();
    super.dispose();
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
      'report': 'REPORT',
    };

    /// DEFAULT REPORT
    _entryVals['report'] = 'REPORT';

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
    /// PREVENT MULTIPLE ENTER PRESS
    if (_isBCodePending) return;

    _isBCodePending = true;

    final rows = await context.read<SpkDeptIssProvider>().fetchByBCode(
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
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!mounted) return;
        _erpFormKey.currentState?.focusField('scanValue');
      });

      return;
    }

    final r = rows.first;

    void set(String k, String? v) {
      _entryVals[k] = v ?? '';
      _erpFormKey.currentState?.updateFieldValue(k, v ?? '');
    }

    final orgPc = r.pc ?? 0;
    final orgWt = r.wt ?? 0;

    final issPc = (r.issPc == null || r.issPc == 0) ? orgPc : r.issPc;
    final issWt = (r.issWt == null || r.issWt == 0) ? orgWt : r.issWt!;

    final recPc = (r.recPc == null || r.recPc == 0) ? orgPc : r.recPc;
    final recWt = (r.recWt == null || r.recWt == 0) ? issWt : r.recWt!;

    set('orgPc', orgPc.toString());
    set('orgWt', fThreeDecimal(orgWt));

    set('issPc', recPc.toString());
    set('issWt', fThreeDecimal(recWt));

    set('recpc', recPc.toString());
    set('recwt', fThreeDecimal(recWt));
    set('jnoRecPc', r.jnoRecPc?.toString());
    set('shapeCode', r.shapeCode?.toString());
    set('purityCode', r.purityCode?.toString());
    set('fluoCode', r.fluo?.toString());
    set('tensionsCode', r.tensionsCode?.toString());

    setState(() => _scannedDet = r);

    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      _erpFormKey.currentState?.focusField('recpc');
    });
  }

  // ─── 1. NEW: _onCutLotFetched ──────────────────────────────────────────────
  // Add this method right after _onBCodeScanned

  Future<void> _onCutLotFetched() async {
    if (_isBCodePending) return;

    final cutNo = (_entryVals['cutNo'] ?? '').trim();
    final cutFrom = (_entryVals['cutFrom'] ?? '').trim();
    final cutTo = (_entryVals['cutTo'] ?? '').trim();

    if (cutNo.isEmpty) {
      _showSnack('Please enter Cut No.');
      Future.delayed(const Duration(milliseconds: 50), () {
        if (!mounted) return;
        _erpFormKey.currentState?.focusField('cutNo');
      });
      return;
    }

    _isBCodePending = true;

    final rows = await context.read<SpkDeptIssProvider>().fetchByCutLot(
      cutNo: cutNo,
      lotFrom: cutFrom,
      lotTo: cutTo,
      fromCrId: _fromCrId!.toString(),
    );

    if (!mounted) return;
    _isBCodePending = false;

    if (rows.isEmpty) {
      ErpResultDialog.showError(
        context: context,
        theme: _theme,
        title: 'Cut Lot',
        message:
            'No packets found for Cut No "$cutNo"'
            '${cutFrom.isNotEmpty ? " (From: $cutFrom" : ''}'
            '${cutTo.isNotEmpty ? " To: $cutTo)" : (cutFrom.isNotEmpty ? ')' : '')}.',
      );
      return;
    }

    int added = 0;
    int skipped = 0;

    for (final r in rows) {
      final bCode = (r.bCode ?? '').toString().trim();

      // Skip duplicates silently, count them
      if (_detRows.any((e) => e.bCode.toString().trim() == bCode)) {
        skipped++;
        continue;
      }

      final orgPc = r.pc ?? 0;
      final orgWt = r.wt ?? 0.0;
      final issPc = (r.issPc == null || r.issPc == 0) ? orgPc : r.issPc!;
      final issWt = (r.issWt == null || r.issWt == 0.0) ? orgWt : r.issWt!;
      final recPc = (r.recPc == null || r.recPc == 0) ? issPc : r.recPc!;
      final recWt = (r.recWt == null || r.recWt == 0.0) ? issWt : r.recWt!;

      final srno = _detRows.length + 1;

      final newRow = SpkDeptIssDetModel(
        srno: srno,
        id: r.id,
        preSpkDeptIssID: r.preSpkDeptIssID,
        jno: r.jno,
        jnoRecPc: r.jnoRecPc,
        bCode: r.bCode,
        ArticalName: r.ArticalName,
        pktNo: r.pktNo,
        cutNo: r.cutNo,
        clvCut: r.clvCut,
        shapeCode: r.shapeCode,
        purityCode: r.purityCode,
        colorCode: r.colorCode,
        diam: r.diam,
        kachaRec: r.kachaRec ?? 'Y',
        fromDeptCode: _fromDeptCode,
        toDeptCode: _toDeptCodeVal,
        fromCrId: _fromCrId,
        toCrId: _toCrId,
        deptCode: _toDeptCodeVal,
        deptProcessCode: int.tryParse(_formValues['deptProcessCode'] ?? ''),
        charniCode: int.tryParse(_formValues['charniCode'] ?? ''),
        tensionsCode: int.tryParse(_formValues['tensionsCode'] ?? ''),
        pc: orgPc,
        wt: orgWt,
        issPc: issPc,
        issWt: issWt,
        recPc: recPc,
        recWt: recWt,
        totalPc: recPc,
        totalWt: recWt,
        dmWt: r.LastDmWt,
        dmPer: r.LastDmPer,
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
        entryType: 'B',
        formType: 'SPK',
        pktType: 'A',
        confRec: _autoRec,
        clvRec: 'S',
        confCrID: _toCrId,
      );

      _detRows.add(newRow);
      added++;
    }

    setState(() {
      _lockMasterFields = _detRows.isNotEmpty;
      _syncDetGrid();
    });

    _erpFormKey.currentState?.setFieldReadOnly('fromCrId', true);
    _erpFormKey.currentState?.setFieldReadOnly('toCrId', true);
    _erpFormKey.currentState?.setFieldReadOnly('deptProcessCode', true);

    if (added > 0 && skipped > 0) {
      _showSnack('Added $added packet(s). Skipped $skipped duplicate(s).');
    } else if (skipped > 0) {
      _showSnack('All $skipped packet(s) already added.');
    }
    // No snack when all clean — grid update is feedback enough.
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  CALCULATIONS
  // ─────────────────────────────────────────────────────────────────────────

  /// DM WT = (Rec WT > 0 ? Rec WT : Iss WT) × DM % / 100
  void _calcDmWt() {
    final recWt = double.tryParse(_entryVals['recwt'] ?? '') ?? 0;
    final issWt = double.tryParse(_entryVals['issWt'] ?? '') ?? 0;
    final base = recWt > 0 ? recWt : issWt;
    final dmPer = double.tryParse(_entryVals['dmper'] ?? '') ?? 0;
    final dmWt = base * dmPer / 100;
    _entryVals['dmwt'] = fThreeDecimal(dmWt);
    _erpFormKey.currentState?.updateFieldValue('dmwt', fThreeDecimal(dmWt));
  }

  /// Loss WT = Iss WT − K WT,  Loss PC = Iss PC − K PC
  void _calcLoss() {
    final issWt = double.tryParse(_entryVals['issWt'] ?? '') ?? 0;
    final recWt =
        double.tryParse(_entryVals['recwt'] ?? '') ?? 0; // 👈 ADD THIS
    final kWt = double.tryParse(_entryVals['kwt'] ?? '') ?? 0;
    final issPc = int.tryParse(_entryVals['issPc'] ?? '') ?? 0;
    final kPc = int.tryParse(_entryVals['kpc'] ?? '') ?? 0;

    // ✅ UPDATED FORMULA
    final lossWt = issWt - recWt - kWt;

    _entryVals['losswt'] = fThreeDecimal(lossWt);
    _entryVals['losspc'] = '${issPc - kPc}';

    _erpFormKey.currentState?.updateFieldValue('losswt', fThreeDecimal(lossWt));
    _erpFormKey.currentState?.updateFieldValue('losspc', '${issPc - kPc}');
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  ADD / EDIT ENTRY
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _addEntry() async {
    final scanBCode = (_scannedDet?.bCode ?? '').trim();

    /// DUPLICATE CHECK
    final alreadyExists = _detRows.any(
      (e) => e.bCode.toString().trim() == scanBCode && _editingDetIndex == null,
    );

    if (alreadyExists) {
      ErpResultDialog.showError(
        context: context,
        theme: _theme,
        title: 'Duplicate',
        message: 'This BCode already added.',
      );

      _erpFormKey.currentState?.updateFieldValue('scanValue', '');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _erpFormKey.currentState?.focusField('scanValue');
      });

      return;
    }
    final merged = _getMergedFields();

    final hasRecPc = merged.containsKey('REC PC');

    final hasRecWt = merged.containsKey('REC WT');

    final hasDmWt = merged.containsKey('DM WT');

    final hasDmPer = merged.containsKey('DM PER');

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
    final recPc = int.tryParse(_entryVals['recpc'] ?? '') ?? 0;
    final recWt = double.tryParse(_entryVals['recwt'] ?? '') ?? 0;
    final kPc = int.tryParse(_entryVals['kpc'] ?? '') ?? 0;
    final kWt = double.tryParse(_entryVals['kwt'] ?? '') ?? 0;

    final totalPc = recPc + kPc;
    final totalWt = recWt + kWt;
    final finalRecPc = hasRecPc || hasRecWt ? recPc : issPc;
    final finalRecWt = hasRecWt || hasRecPc ? recWt : issWt;
    final hasRecPair =
        merged.containsKey('REC PC') || merged.containsKey('REC WT');
    final hasKPair = merged.containsKey('K PC') || merged.containsKey('K WT');

    // Total PC / WT must not exceed issued
    if (hasRecPair || hasKPair) {
      if (totalPc > issPc && issPc > 0) {
        _showSnack(
          'Rec PC ($recPc) + K PC ($kPc) = $totalPc cannot exceed Iss PC ($issPc)',
        );
        return;
      }
      if (totalWt > issWt + 0.0005 && issWt > 0) {
        _showSnack(
          'Rec Wt (${fThreeDecimal(recWt)}) + K Wt (${fThreeDecimal(kWt)}) = ${fThreeDecimal(totalWt)} cannot exceed Iss Wt (${fThreeDecimal(issWt)})',
        );
        return;
      }
    }

    // Pair completeness — PC requires WT and vice-versa
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

    final issPcStr = _entryVals['issPc'] ?? '0';
    final issWtStr = _entryVals['issWt'] ?? '0.000';

    final finalDmWt = hasDmWt || hasDmPer
        ? double.tryParse(_entryVals['dmwt'] ?? '')
        : _scannedDet?.LastDmWt;

    final finalDmPer = hasDmPer || hasDmWt
        ? double.tryParse(_entryVals['dmper'] ?? '')
        : _scannedDet?.LastDmPer;

    final srno = _editingDetIndex != null
        ? _detRows[_editingDetIndex!].srno
        : _detRows.length + 1;

    final newRow = _editingDetIndex != null
        ? _buildEditedRow(
            srno: srno,
            existing: _detRows[_editingDetIndex!],
            issPcStr: issPcStr,
            issWtStr: issWtStr,
            recPc: finalRecPc,
            recWt: finalRecWt,
            dmWt: finalDmWt,
            dmPer: finalDmPer,
          )
        : _buildNewRow(
            srno: srno,
            issPcStr: issPcStr,
            issWtStr: issWtStr,
            recPc: finalRecPc,
            recWt: finalRecWt,
            dmWt: finalDmWt,
            dmPer: finalDmPer,
          );
    final prov = context.read<SpkDeptIssProvider>();
    final apiData = await prov.rateCallApi(newRow);
    print(jsonEncode(apiData));
    // ✅ UPDATE: Set rate fields from API response to a new variable
    SpkDeptIssDetModel updatedRow = newRow;
    if (apiData.isNotEmpty) {
      if (apiData.first.bCode == null) {
        return;
      }
      final responseRow = apiData.first;
      updatedRow = newRow.copyWith(
        rateID: responseRow.rateID.toString(),
        rateon: responseRow.rateon,
        rate: responseRow.rate,
        amount: responseRow.amount,
      );
    } else {
      return;
    }
    setState(() {
      if (_editingDetIndex != null) {
        _detRows[_editingDetIndex!] = updatedRow;
        _editingDetIndex = null;
      } else {
        _detRows.add(updatedRow);
      }
      _lockMasterFields = true;
      _syncDetGrid();
    });

    // Return focus to scan field
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _erpFormKey.currentState?.focusField('scanValue'),
    );

    _erpFormKey.currentState?.setFieldReadOnly('fromCrId', true);
    _erpFormKey.currentState?.setFieldReadOnly('toCrId', true);
    _erpFormKey.currentState?.setFieldReadOnly('deptProcessCode', true);
    _scannedDet = null;

    _entryVals['scanValue'] = '';

    _erpFormKey.currentState?.updateFieldValue('scanValue', '');
  }

  /// Build a detail row for an existing (edit) record.
  SpkDeptIssDetModel _buildEditedRow({
    required int? srno,
    required SpkDeptIssDetModel existing,
    required String issPcStr,
    required String issWtStr,
    required int recPc,
    required double recWt,
    required double? dmWt,
    required double? dmPer,
  }) {
    return SpkDeptIssDetModel(
      srno: srno,
      spkDeptIssMstID: existing.spkDeptIssMstID,
      // Preserved scan data
      id: existing.id,
      preSpkDeptIssID: existing.preSpkDeptIssID,
      jno: existing.jno,
      bCode: existing.bCode,
      pktNo: existing.pktNo,
      cutNo: existing.cutNo,
      ArticalName: existing.ArticalName,
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
      fromDeptCode: existing.fromDeptCode,
      toDeptCode: existing.toDeptCode,
      fromCrId: existing.fromCrId,
      toCrId: existing.toCrId,
      deptCode: existing.deptCode,
      deptProcessCode: int.tryParse(_formValues['deptProcessCode'] ?? ''),
      // User-entered fields
      pc: int.tryParse(_entryVals['orgPc'] ?? '') ?? existing.pc,
      wt: double.tryParse(_entryVals['orgWt'] ?? '') ?? existing.wt,
      issPc: int.tryParse(issPcStr),
      issWt: double.tryParse(issWtStr),
      recPc: recPc,
      recWt: recWt,
      totalPc: recPc,
      totalWt: recWt,
      dmWt: dmWt,
      dmPer: dmPer,
      kPc: int.tryParse(_entryVals['kpc'] ?? ''),
      kWt: double.tryParse(_entryVals['kwt'] ?? ''),
      brPc: int.tryParse(_entryVals['brpc'] ?? ''),
      brWt: double.tryParse(_entryVals['brwt'] ?? ''),
      lossPc: int.tryParse(_entryVals['losspc'] ?? ''),
      lossWt: double.tryParse(_entryVals['losswt'] ?? ''),
      topsPc: int.tryParse(_entryVals['topspc'] ?? ''),
      topsWt: double.tryParse(_entryVals['topswt'] ?? ''),
      charniCode: int.tryParse(_entryVals['charniCode'] ?? ''),
      tensionsCode: int.tryParse(_entryVals['tensionsCode'] ?? ''),
      employeeCode: int.tryParse(_entryVals['employee'] ?? ''),
      signerCode: int.tryParse(_entryVals['signer'] ?? ''),
      remarksCode: int.tryParse(_entryVals['remarks'] ?? ''),
      dueDay: int.tryParse(_entryVals['dueDay'] ?? ''),
      confRec: _autoRec,
      clvRec: 'S',
      confCrID: _toCrId,
      length: existing.length,
      height: existing.height,
      polishCode: existing.polishCode,
      fluo: existing.fluo,
      symmetryCode: existing.symmetryCode,
    );
  }

  /// Build a detail row for a new (add) record.
  SpkDeptIssDetModel _buildNewRow({
    required int? srno,
    required String issPcStr,
    required String issWtStr,
    required int recPc,
    required double recWt,
    required double? dmWt,
    required double? dmPer,
  }) {
    return SpkDeptIssDetModel(
      srno: srno,
      id: _scannedDet?.id,
      preSpkDeptIssID: _scannedDet?.preSpkDeptIssID,
      jno: _scannedDet?.jno,
      jnoRecPc: _scannedDet?.jnoRecPc,
      bCode: _scannedDet?.bCode ?? _entryVals['scanValue'],
      ArticalName: _scannedDet?.ArticalName,
      pktNo: _scannedDet?.pktNo,
      cutNo: _scannedDet?.cutNo,
      clvCut: _scannedDet?.clvCut,
      shapeCode: _scannedDet?.shapeCode,
      purityCode: _scannedDet?.purityCode,
      colorCode: _scannedDet?.colorCode,
      length: _scannedDet?.length,
      height: _scannedDet?.height,
      diam: _scannedDet?.diam,
      polishCode: _scannedDet?.polishCode,
      fluo: _scannedDet?.fluo,
      symmetryCode: _scannedDet?.symmetryCode,
      kachaRec: _scannedDet?.kachaRec ?? 'Y',
      fromDeptCode: _fromDeptCode,
      toDeptCode: _toDeptCodeVal,
      fromCrId: _fromCrId,
      toCrId: _toCrId,
      deptCode: _toDeptCodeVal,
      deptProcessCode: int.tryParse(_formValues['deptProcessCode'] ?? ''),
      charniCode: int.tryParse(_entryVals['charniCode'] ?? ''),
      tensionsCode: int.tryParse(_entryVals['tensionsCode'] ?? ''),
      pc: int.tryParse(_entryVals['orgPc'] ?? ''),
      wt: double.tryParse(_entryVals['orgWt'] ?? ''),
      issPc: int.tryParse(issPcStr),
      issWt: double.tryParse(issWtStr),
      recPc: recPc,
      recWt: recWt,
      totalPc: recPc,
      totalWt: recWt,
      dmWt: dmWt,
      dmPer: dmPer,
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
      entryType: 'B',
      formType: 'SPK',
      pktType: 'A',
      confRec: _autoRec,
      clvRec: 'S',
      confCrID: _toCrId,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  EDIT / DELETE DET ROW
  // ─────────────────────────────────────────────────────────────────────────

  void _editDetRow(int idx) {
    final actualIdx = _detRows.length - 1 - idx; // ← convert display→actual
    final r = _detRows[actualIdx];
    setState(() => _editingDetIndex = actualIdx); // ← use actualIdx

    void set(String k, String? v) {
      _entryVals[k] = v ?? '';
      _erpFormKey.currentState?.updateFieldValue(k, v ?? '');
    }

    set('orgPc', r.pc?.toString());
    set('orgWt', fThreeDecimal(r.wt));
    set('issPc', r.issPc?.toString());
    set('issWt', fThreeDecimal(r.issWt));
    set('recpc', r.recPc?.toString());
    set('recwt', fThreeDecimal(r.recWt));
    set('dmper', r.dmPer?.toStringAsFixed(2));
    set('dmwt', fThreeDecimal(r.dmWt));
    set('kpc', r.kPc?.toString());
    set('kwt', fThreeDecimal(r.kWt));
    set('brpc', r.brPc?.toString());
    set('brwt', fThreeDecimal(r.brWt));
    set('losspc', r.lossPc?.toString());
    set('losswt', fThreeDecimal(r.lossWt));
    set('topspc', r.topsPc?.toString());
    set('topswt', fThreeDecimal(r.topsWt));
    set('employee', r.employeeCode?.toString());
    set('signer', r.signerCode?.toString());
    set('remarks', r.remarksCode?.toString());
    set('dueDay', r.dueDay?.toString());
  }

  void _deleteDetRow(int idx) {
    final actualIdx = _detRows.length - 1 - idx; // ← convert display→actual
    setState(() {
      _detRows.removeAt(actualIdx);
      // Re-number srno
      _detRows = _detRows.asMap().entries.map((e) {
        final v = e.value;
        return SpkDeptIssDetModel(
          srno: e.key + 1,
          spkDeptIssMstID: v.spkDeptIssMstID,
          spkDeptIssDetID: v.spkDeptIssDetID,
          id: v.id,
          preSpkDeptIssID: v.preSpkDeptIssID,
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
          confRec: v.confRec,
        );
      }).toList();

      _syncDetGrid();
      if (_editingDetIndex == actualIdx) _editingDetIndex = null;
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  SYNC DET GRID
  // ─────────────────────────────────────────────────────────────────────────

  void _syncDetGrid() {
    final merged = _getMergedFields();

    // Build column list based on what fields are actually configured
    final cols = <String>[
      'srno',
      'bCode',
      'pktNo',
      'cutNo',
      'orgPc',
      'orgWt',
      'issPc',
      'issWt',
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

    _detDisplay = _detRows.reversed
        .map(
          (r) => {
            'srno': r.srno?.toString() ?? '',
            'bCode': r.bCode ?? '',
            'pktNo': r.pktNo ?? '',
            'cutNo': r.cutNo ?? '',
            'orgPc': r.pc?.toString() ?? '0',
            'orgWt': fThreeDecimal(r.wt),
            'issPc': r.issPc?.toString() ?? '0',
            'issWt': fThreeDecimal(r.issWt),
            'recPc': r.recPc?.toString() ?? '0',
            'recWt': fThreeDecimal(r.recWt),
            'dmPer': r.dmPer?.toStringAsFixed(2) ?? '',
            'dmWt': fThreeDecimal(r.dmWt),
            'kPc': r.kPc?.toString() ?? '',
            'kWt': fThreeDecimal(r.kWt),
            'brPc': r.brPc?.toString() ?? '0',
            'brWt': fThreeDecimal(r.brWt),
            'lossPc': r.lossPc?.toString() ?? '',
            'lossWt': fThreeDecimal(r.lossWt),
            'topsPc': r.topsPc?.toString() ?? '',
            'topsWt': fThreeDecimal(r.topsWt),
            'employee': _employeeNameFor(r.employeeCode),
            'signer': _signerNameFor(r.signerCode),
            'remarks': _remarksNameFor(r.remarksCode),
            'jnoRecPc': r.jnoRecPc?.toString() ?? '',
            'shapeCode': _shapeNameFor(r.shapeCode),
            'purityCode': _purityNameFor(r.purityCode),
          },
        )
        .toList();
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  ROW TAP (load existing record)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _onRowTap(Map<String, dynamic> row) async {
    final raw = row['_raw'] as SpkDeptIssMstModel;
    final prov = context.read<SpkDeptIssProvider>();
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
        'report': 'REPORT',
        if (lastDet?.charniCode != null)
          'charniCode': lastDet!.charniCode!.toString(),
        if (lastDet?.tensionsCode != null)
          'tensionsCode': lastDet!.tensionsCode!.toString(),
        if (_selectedRadioCode != null) 'scanType': _selectedRadioCode!,
      };
      _entryVals['report'] = 'REPORT';
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

  // CREATE PDF

  Future<void> printJobWorkPdf() async {
    final companies = context.read<CompanyProvider>().companies;
    final selectedCompany = context.read<CompanyProvider>().selectedCompanyCode;
    final company = companies.firstWhereOrNull(
      (e) => e.companyCode.toString() == selectedCompany.toString(),
    );
    _selectedCompany = company;
    setState(() {});
    if (_detRows.isEmpty) {
      return;
    }
    final prov = context.read<SpkDeptIssProvider>();
    final toCounter = context.read<CounterProvider>().list.firstWhereOrNull(
      (e) => e.crId.toString() == _formValues['toCrId'],
    );
    final pdfData = JobWorkPdfModel(
      headerInfo: _selectedCompany,
      partyName: toCounter?.crName ?? '',
      partyType: _toDeptName ?? '',

      jobNo:
          (_detRows.first.spkDeptIssMstID ??
                  prov.list.first.spkDeptIssMstID ??
                  0)
              .toString(),

      date: _formValues['spkDeptIssDate']?.toString() ?? '',
      CVDPartyCode: toCounter?.CVDPartyCode ?? '',
      NaturalPartyCode: toCounter?.NaturalPartyCode ?? '',
      items: _detRows.map((e) {
        return JobWorkItem(
          kapan: e.cutNo ?? '',

          bCode: e.bCode ?? '',
          pktNo: e.pktNo ?? '',

          type: e.ArticalName ?? '',

          pcs: (e.recPc ?? 0).toString(),

          cts: (e.recWt ?? 0).toStringAsFixed(3),
        );
      }).toList(),
    );

    /// DETAIL REPORT
    if (_entryVals['report'] == 'REPORT') {
      final pdf = await generateJobWorkPdf(pdfData);

      await Printing.layoutPdf(onLayout: (_) async => pdf);
    }
    /// SUMMARY REPORT
    else if (_entryVals['report'] == 'SUMMARY') {
      /// GROUP CUTNO WISE
      final Map<String, Map<String, dynamic>> grouped = {};

      for (final e in _detRows) {
        final cutNo = e.cutNo ?? '';

        if (!grouped.containsKey(cutNo)) {
          grouped[cutNo] = {
            'cutNo': cutNo,

            'articalName': e.ArticalName ?? '',

            'pktNos': <String>{},

            'pcs': 0,

            'wt': 0.0,
          };
        }

        /// PKTNO COUNT
        grouped[cutNo]!['pktNos'].add(e.pktNo?.toString() ?? '');

        /// PCS SUM
        grouped[cutNo]!['pcs'] += (e.recPc ?? 0);

        /// WT SUM
        grouped[cutNo]!['wt'] += (e.recWt ?? 0.0);
      }

      /// CONVERT SUMMARY ITEMS
      final summaryItems = grouped.values.map((g) {
        return JobWorkItem(
          kapan: g['cutNo'],

          /// PKT COUNT
          bCode: (g['pktNos'] as Set).length.toString(),

          type: g['articalName'],
          pktNo: '',

          pcs: g['pcs'].toString(),

          cts: (g['wt'] as double).toStringAsFixed(3),
        );
      }).toList();

      final summaryPdfData = JobWorkPdfModel(
        headerInfo: _selectedCompany,

        partyName: toCounter?.crName ?? '',

        partyType: _toDeptName ?? '',

        jobNo:
            (_detRows.first.spkDeptIssMstID ??
                    prov.list.first.spkDeptIssMstID ??
                    0)
                .toString(),

        date: _formValues['spkDeptIssDate']?.toString() ?? '',
        CVDPartyCode: toCounter?.CVDPartyCode ?? '',
        NaturalPartyCode: toCounter?.NaturalPartyCode ?? '',
        items: summaryItems,
      );

      final pdf = await generateJobWorkPdfSummary(summaryPdfData);

      await Printing.layoutPdf(onLayout: (_) async => pdf);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  SAVE
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _onSave(Map<String, dynamic> values) async {
    final prov = context.read<SpkDeptIssProvider>();

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
    if (_detRows.isNotEmpty) {
      final merged = Map<String, dynamic>.from(values)
        ..['Stime'] = DateFormat('hh:mm a').format(DateTime.now())
        ..['Sdate'] = DateFormat('yyyy-MM-dd').format(DateTime.now())
        ..['spkDeptIssDate'] = toIso(values['spkDeptIssDate']?.toString())
        ..['fromCrID'] = _fromCrId?.toString() ?? ''
        ..['toCrID'] = _toCrId?.toString() ?? ''
        ..['deptCode'] = toDeptCode?.toString() ?? '';
      final reversedDet = _detRows.toList();

      final success = _isEditMode && _selectedMst != null
          ? await prov.update(
              _selectedMst!.spkDeptIssMstID!,
              merged,
              reversedDet,
              bCodeArray: reversedDet
                  .where(
                    (r) => r.spkDeptIssDetID != null || r.spkDeptIssDetID != 0,
                  )
                  .map((r) => num.parse(r.bCode.toString()))
                  .toList(),
              expectedProcess: ProcessConstants.deptIssue,
              theme: _theme,
              context: context,
            )
          : await prov.create(merged, reversedDet);

      if (!mounted) return;
      if (success) {
        final wasEdit = _isEditMode;
        printJobWorkPdf();
        await ErpResultDialog.showSuccess(
          context: context,
          theme: _theme,
          title: wasEdit ? 'Updated' : 'Saved',
          message: wasEdit ? 'Dept Issue updated.' : 'Dept Issue saved.',
        );
        _resetForm();
        await context.read<SpkDeptIssProvider>().load();
      }
    } else {
      await ErpResultDialog.showError(
        context: context,
        theme: _theme,
        title: 'No Entries',
        message: 'Please add at least one entry.',
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

    final success = await context.read<SpkDeptIssProvider>().delete(
      _selectedMst!.spkDeptIssMstID!,
      bCodeArray: _detRows.map((r) => r.bCode).toList(),
      expectedProcess: ProcessConstants.deptIssue,
      theme: _theme,
      context: context,
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
    final charniProv = context.read<CharniProvider>();
    final tensProv = context.read<TensionsProvider>();

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
    // ── CHARNI dropdown ───────────────────────────────────────────────────
    final charniItems = charniProv.list
        .where((e) => e.active == true)
        .map(
          (e) => ErpDropdownItem(
            label: e.charniName ?? '',
            value: e.charniCode?.toString() ?? '',
          ),
        )
        .toList();

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
          type: ErpFieldType.time,
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
          label: 'DEPT',
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
          label: 'DEPT',
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
    ];

    // ─────────────────────────────────────────────────────────────────────
    //  CHARNI / TENSIONS SECTION (sectionIndex 2)
    // ─────────────────────────────────────────────────────────────────────
    if (_processSelected) {
      final charniTensRow = <ErpFieldConfig>[];
      if (merged.containsKey('CHARNI')) {
        charniTensRow.add(
          ErpFieldConfig(
            key: 'charniCode',
            label: 'CHARNI',
            type: ErpFieldType.dropdown,
            dropdownItems: charniItems,
            sectionIndex: 2,
            width: 200,
          ),
        );
      }
      if (merged.containsKey('TENSIONS')) {
        charniTensRow.add(
          ErpFieldConfig(
            key: 'tensionsCode',
            label: 'TENSION',
            type: ErpFieldType.dropdown,
            dropdownItems: tensDropdown,
            sectionIndex: 2,
            width: 200,
          ),
        );
      }
      if (charniTensRow.isNotEmpty) rows.add(charniTensRow);
    }

    // ─────────────────────────────────────────────────────────────────────
    //  ENTRY SECTION (sectionIndex 3)
    // ─────────────────────────────────────────────────────────────────────
    if (_processSelected) {
      // Use _getRadioFields so radio options appear even when only one of
      // _fromDisplayFields or _toDisplayFields contains these field names.
      final radioFieldsMap = _getRadioFields();

      final radioItems = radioFieldsMap.values
          .map(
            (f) => ErpRadioOption(
              label: f.userVisibilityName ?? '',
              value: f.userVisibilityCode.toString(),
            ),
          )
          .toList();

      // Resolve currently selected radio name from whichever list has it
      final selectedField = radioFieldsMap.values.firstWhereOrNull(
        (f) => f.userVisibilityCode.toString() == _selectedRadioCode.toString(),
      );

      final selectedName = (selectedField?.userVisibilityName ?? '')
          .toUpperCase();
      // Compute radio widget width based on option count
      final radioWidth = switch (radioItems.length) {
        <= 1 => 150.0,
        2 => 200.0,
        3 => 300.0,
        4 => 400.0,
        _ => 500.0,
      };

      // Radio + scan-value row
      if (radioItems.isNotEmpty) {
        rows.add([
          ErpFieldConfig(
            key: 'scanType',
            label: '',
            type: ErpFieldType.radio,
            radioItems: radioItems,
            isEntryField: true,
            sectionIndex: 3,
            width: radioWidth,
          ),
          ErpFieldConfig(
            key: 'scanValue',
            label: '',
            type: ErpFieldType.text,
            isEntryField: true,
            readOnly: selectedName == 'CUT LOT',
            sectionIndex: 3,
            width: 200,
          ),
          ErpFieldConfig(
            key: 'report',
            label: '',
            type: ErpFieldType.radio,
            radioDirection: Axis.horizontal,
            isRadioRow: true,
            radioItems: [
              ErpRadioOption(label: 'Details', value: 'REPORT'),
              ErpRadioOption(label: 'Summary', value: 'SUMMARY'),
            ],
            width: 250,
            sectionIndex: 3,
          ),
        ]);
      }

      // CUT LOT extra fields
      if (selectedName == 'CUT LOT') {
        rows.add([
          ErpFieldConfig(
            key: 'cutNo',
            label: 'CUT NO',
            type: ErpFieldType.text,
            isEntryField: true,
            sectionIndex: 3,
            width: 200,
          ),
          ErpFieldConfig(
            key: 'cutFrom',
            label: 'FROM',
            type: ErpFieldType.text,
            isEntryField: true,
            sectionIndex: 3,
            width: 200,
          ),
          ErpFieldConfig(
            key: 'cutTo',
            label: 'TO',
            type: ErpFieldType.text,
            isEntryField: true,
            sectionIndex: 3,
            width: 200,
          ),
        ]);
      }

      // Main entry fields (ORG / ISS / PC-WT pairs / extras) — all in one row
      final singleRow = <ErpFieldConfig>[];

      final pairs = [
        ['REC PC', 'REC WT'],
        ['K PC', 'K WT'],
        ['BR PC', 'BR WT'],
        ['TOPS PC', 'TOPS WT'],
        ['LOSS PC', 'LOSS WT'],
        ['DM PER', 'DM WT'],
      ];

      final hasAnyPair = pairs.any(
        (p) => merged.containsKey(p[0]) || merged.containsKey(p[1]),
      );

      // Fixed ORG / ISS fields (only when there are PC-WT pairs)
      if (hasAnyPair) {
        singleRow.addAll([
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
            type: ErpFieldType.wt,
            readOnly: true,
            isEntryField: true,
            sectionIndex: 3,
            flex: 1,
          ),
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
            type: ErpFieldType.wt,
            readOnly: true,
            isEntryField: true,
            showAddButton: true,
            sectionIndex: 3,
            flex: 1,
          ),
        ]);
      }

      // PC-WT pairs
      for (final pair in pairs) {
        if (merged.containsKey(pair[0]) || merged.containsKey(pair[1])) {
          singleRow.add(
            ErpFieldConfig(
              key: pair[0].replaceAll(' ', '').toLowerCase(),
              label: pair[0],
              type: ErpFieldType.text,
              readOnly: pair[0] == 'LOSS PC',
              isEntryField: true,
              sectionIndex: 3,
              flex: 1,
            ),
          );
          singleRow.add(
            ErpFieldConfig(
              key: pair[1].replaceAll(' ', '').toLowerCase(),
              label: pair[1],
              type: ErpFieldType.text,
              readOnly: pair[1] == 'DM WT' || pair[1] == 'LOSS WT',
              isEntryField: true,
              sectionIndex: 3,
              flex: 1,
            ),
          );
        }
      }

      // EMPLOYEE
      if (merged.containsKey('EMPLOYEE')) {
        singleRow.add(
          ErpFieldConfig(
            key: 'employee',
            label: 'EMPLOYEE',
            type: ErpFieldType.dropdown,
            dropdownItems: context
                .read<EmployeeProvider>()
                .list
                .map(
                  (e) => ErpDropdownItem(
                    label: e.employeeName ?? '',
                    value: e.employeeCode?.toString() ?? '',
                  ),
                )
                .toList(),
            isEntryField: true,
            sectionIndex: 3,
            flex: 2,
          ),
        );
      }

      // SIGNER
      if (merged.containsKey('SIGNER')) {
        final signerCounters = context.read<CounterProvider>().list.where(
          (c) => _deptNameFor(c.deptCode).toUpperCase() == 'SIGNER',
        );
        singleRow.add(
          ErpFieldConfig(
            key: 'signer',
            label: 'SIGNER',
            type: ErpFieldType.dropdown,
            isEntryField: true,
            dropdownItems: signerCounters
                .map(
                  (e) => ErpDropdownItem(
                    label: e.logInName ?? '',
                    value: e.crId?.toString() ?? '',
                  ),
                )
                .toList(),
            sectionIndex: 3,
            flex: 2,
          ),
        );
      }

      // REMARKS (filtered by selected process)
      if (merged.containsKey('REMARKS')) {
        final selectedProcess = int.tryParse(
          _formValues['deptProcessCode'] ?? '',
        );
        final remarksItems = context
            .read<RemarksProvider>()
            .list
            .where(
              (e) =>
                  e.active == true &&
                  (selectedProcess == null ||
                      e.deptProcessCode == selectedProcess),
            )
            .map(
              (e) => ErpDropdownItem(
                label: e.remarksName ?? '',
                value: e.remarksCode?.toString() ?? '',
              ),
            )
            .toList();
        singleRow.add(
          ErpFieldConfig(
            key: 'remarks',
            label: 'REMARKS',
            type: ErpFieldType.dropdown,
            isEntryField: true,
            dropdownItems: remarksItems,
            sectionIndex: 3,
            flex: 2,
          ),
        );
      }

      // DUE DAY
      if (merged.containsKey('DUE DAY')) {
        singleRow.add(
          ErpFieldConfig(
            key: 'dueDay',
            label: 'DUE DAY',
            type: ErpFieldType.text,
            isEntryField: true,
            showAddButton: true,
            sectionIndex: 3,
            flex: 1,
          ),
        );
      }

      if (singleRow.isNotEmpty) rows.add(singleRow);
    }

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
      width: 100,
      isDate: true,
    ),
    ErpColumnConfig(key: 'spkDeptIssTime', label: 'TIME', width: 100),
    ErpColumnConfig(key: 'fromName', label: 'FROM MGR', width: 140),
    ErpColumnConfig(key: 'fromDeptName', label: 'FROM DEPT', width: 140),
    ErpColumnConfig(key: 'toName', label: 'TO MGR', width: 140),
    ErpColumnConfig(key: 'toDeptName', label: 'TO DEPT', width: 140),
    ErpColumnConfig(key: 'processName', label: 'PROCESS', width: 140),
    ErpColumnConfig(key: 'deptName', label: 'DEPT', width: 140),
    ErpColumnConfig(key: 'jno', label: 'JNO', width: 80),
    ErpColumnConfig(key: 'totPkt', label: 'TOT PKT', width: 100),
    ErpColumnConfig(key: 'totalPc', label: 'TOT PC', width: 100),
    ErpColumnConfig(key: 'totalWt', label: 'TOT WT', width: 100),
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
    };
    return labels[key] ?? key;
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Consumer<SpkDeptIssProvider>(
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
      title: 'DEPT ISSUE ENTRY',
      tabBarBackgroundColor: const Color(0xfff2f0ef),
      tabBarSelectedColor: _theme.primaryGradient.first,
      tabBarSelectedTxtColor: Colors.white,
      rows: _buildFormRows(),
      initialValues: _formValues,
      isEditMode: _isEditMode,
      isShowPrintButton: true,
      printOnPress: printJobWorkPdf,
      onEntryAdd: (sectionIndex) {
        if (sectionIndex != 3) return;

        final selectedName = () {
          final f = _getRadioFields().values.firstWhereOrNull(
            (f) => f.userVisibilityCode.toString() == _selectedRadioCode,
          );
          return (f?.userVisibilityName ?? '').toUpperCase();
        }();

        // CUT LOT → batch fetch
        if (selectedName == 'CUT LOT') {
          if (_fromCrId == null) return;
          _onCutLotFetched();
          return;
        }

        // BCODE → single scan must precede add
        if (selectedName == 'BCODE' &&
            _scannedDet == null &&
            _editingDetIndex == null) {
          Future.delayed(const Duration(milliseconds: 50), () {
            if (!mounted) return;
            _erpFormKey.currentState?.focusField('scanValue');
          });
          return;
        }

        _addEntry();
      },
      onFieldChanged: (key, value) {
        _formValues[key] = value.toString();
        if (key == 'scanType') {
          setState(() {
            _selectedRadioCode = value.toString();
          });

          _rebuildForm();
        }
        switch (key) {
          case 'fromCrId':
            _onFromSelected(value.toString());
            Future.delayed(const Duration(milliseconds: 50), () {
              if (!mounted) return;
              _erpFormKey.currentState?.focusField('toCrId');
            });

          case 'toCrId':
            _onToSelected(value.toString());
            Future.delayed(const Duration(milliseconds: 50), () {
              if (!mounted) return;
              _erpFormKey.currentState?.focusField('deptProcessCode');
            });

          case 'deptProcessCode':
            _onProcessSelected(value.toString());
            Future.delayed(const Duration(milliseconds: 100), () {
              if (!mounted) return;
              _erpFormKey.currentState?.focusField('charniCode');
            });

          case 'scanValue':
            _entryVals[key] = value.toString();

          case 'dmper':
            final dmPerVal = double.tryParse(value.toString()) ?? 0;
            if (dmPerVal > 100) {
              _erpFormKey.currentState?.updateFieldValue('dmPer', '100');
              _entryVals['dmper'] = '100';
            } else {
              _entryVals[key] = value.toString();
            }
            _calcDmWt();

          case 'recWt':
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
        // ── scanValue submit ────────────────────────────────────────────────────
        if (key == 'scanValue') {
          final scanVal = value.toString().trim();
          if (scanVal.isEmpty) return;
          if (_selectedRadioCode == null || _fromCrId == null) return;

          final merged = _getMergedFields();
          if (merged.isEmpty) return;

          final selectedField = _getRadioFields().values.firstWhereOrNull(
            (f) => f.userVisibilityCode.toString() == _selectedRadioCode,
          );
          final selectedName = (selectedField?.userVisibilityName ?? '')
              .toUpperCase();

          if (selectedName == 'BCODE') {
            final isDuplicate = _detRows.any(
              (r) => r.bCode?.toString() == scanVal,
            );
            if (isDuplicate) {
              ErpResultDialog.showError(
                context: context,
                theme: _theme,
                title: 'Duplicate',
                message: 'This BCode already added.',
              );
              _erpFormKey.currentState?.updateFieldValue('scanValue', '');
              // scanValue duplicate error path:
              Future.delayed(const Duration(milliseconds: 50), () {
                if (!mounted) return;
                _erpFormKey.currentState?.focusField('scanValue');
              });
              return;
            }

            _onBCodeScanned(scanVal).then((_) {
              if (!mounted) return;
              if (_scannedDet != null && !_hasEntryFields()) {
                _addEntry();
                _erpFormKey.currentState?.updateFieldValue('scanValue', '');
                _entryVals['scanValue'] = '';
                _scannedDet = null;
                Future.delayed(const Duration(milliseconds: 50), () {
                  if (!mounted) return;
                  _erpFormKey.currentState?.focusField('scanValue');
                });
              }
            });
            return;
          }

          // Non-BCODE duplicate check (ID / JNO / QR CODE)
          if (_editingDetIndex == null) {
            final isDuplicate = _detRows.any(
              (r) =>
                  r.id?.toString() == scanVal || r.jno?.toString() == scanVal,
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
          return;
        }

        // ── cutNo / cutFrom / cutTo: Enter key advances focus ──────────────────
        if (key == 'cutNo') {
          Future.delayed(const Duration(milliseconds: 50), () {
            if (!mounted) return;
            _erpFormKey.currentState?.focusField('cutFrom');
          });
          return;
        }
        if (key == 'cutFrom') {
          Future.delayed(const Duration(milliseconds: 50), () {
            if (!mounted) return;
            _erpFormKey.currentState?.focusField('cutTo');
          });
          return;
        }
        // cutTo Enter = trigger the batch fetch directly
        if (key == 'cutTo') {
          if (_fromCrId != null) _onCutLotFetched();
          return;
        }
      },
      onExit: () => context.read<TabProvider>().closeCurrentTab(),
      onSave: _onSave,
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
                editingIndex: _editingDetIndex != null
                    ? (_detRows.length - 1 - _editingDetIndex!)
                    : null,
                columnLabels: {
                  for (final c in _activeDetColumns) c: _colLabel(c),
                },
                columnAlignments: const {
                  'srno': TextAlign.left,
                  'orgPc': TextAlign.left,
                  'orgWt': TextAlign.left,
                  'issPc': TextAlign.left,
                  'issWt': TextAlign.left,
                  'recPc': TextAlign.left,
                  'recWt': TextAlign.left,
                  'dmPer': TextAlign.left,
                  'dmWt': TextAlign.left,
                  'kPc': TextAlign.left,
                  'kWt': TextAlign.left,
                  'brPc': TextAlign.left,
                  'brWt': TextAlign.left,
                  'lossPc': TextAlign.left,
                  'lossWt': TextAlign.left,
                  'topsPc': TextAlign.left,
                  'topsWt': TextAlign.left,
                  'remarks': TextAlign.left,
                  'employee': TextAlign.left,
                  'signer': TextAlign.left,
                  'jnoRecPc': TextAlign.left,
                  'shapeCode': TextAlign.left,
                  'purityCode': TextAlign.left,
                  'bCode': TextAlign.left,
                  'pktNo': TextAlign.left,
                  'cutNo': TextAlign.left,
                  'cutFrom': TextAlign.left,
                  'cutTo': TextAlign.left,
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
      'orgPc': '${foldInt((r) => r.pc ?? 0)}',
      'orgWt': fThreeDecimal(fold((r) => r.wt ?? 0)),
      'issPc': '${foldInt((r) => r.issPc ?? 0)}',
      'issWt': fThreeDecimal(totIssWt),
      'recPc': '${foldInt((r) => r.recPc ?? 0)}',
      'recWt': fThreeDecimal(totRecWt),
      'dmPer': dmPerStr,
      'dmWt': fThreeDecimal(totDmWt),
      'kPc': '${foldInt((r) => r.kPc ?? 0)}',
      'kWt': fThreeDecimal(fold((r) => r.kWt ?? 0)),
      'brPc': '${foldInt((r) => r.brPc ?? 0)}',
      'brWt': fThreeDecimal(fold((r) => r.brWt ?? 0)),
      'lossPc': '${foldInt((r) => r.lossPc ?? 0)}',
      'lossWt': fThreeDecimal(fold((r) => r.lossWt ?? 0)),
      'topsPc': '${foldInt((r) => r.topsPc ?? 0)}',
      'topsWt': fThreeDecimal(fold((r) => r.topsWt ?? 0)),
    };
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  TABLE WIDGET
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildTable(SpkDeptIssProvider prov) {
    final counterProv = context.read<CounterProvider>();
    final procProv = context.read<DeptProcessProvider>();
    final data = prov.list.where((e) => e.formType == 'DEPTISS').map((e) {
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

      final row = e.toTableRow()
        ..['fromName'] = fromName
        ..['fromDeptName'] = fromDeptName
        ..['toName'] = toName
        ..['toDeptName'] = toDeptName
        ..['deptName'] = toDeptName
        ..['processName'] = processName
        ..['spkDeptIssTime'] = _formatTime(e.stime)
        ..['jno'] = e.jnoFirst?.toString() ?? ''
        ..['totPkt'] = e.totPkt?.toString() ?? '0'
        ..['totalPc'] = e.totalPc.toString() ?? '0'
        ..['totalWt'] = fThreeDecimal(e.totalWt ?? 0);

      return row;
    }).toList();

    return ErpDataTable(
      isReportRow: false,
      token: token ?? '',
      url: baseUrl,
      title: 'DEPT ISSUE LIST',
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

  bool _hasEntryFields() {
    final merged = _getMergedFields();

    final pairs = [
      ['REC PC', 'REC WT'],
      ['K PC', 'K WT'],
      ['BR PC', 'BR WT'],
      ['TOPS PC', 'TOPS WT'],
      ['LOSS PC', 'LOSS WT'],
      ['DM PER', 'DM WT'],
    ];

    final hasAnyPair = pairs.any(
      (p) => merged.containsKey(p[0]) || merged.containsKey(p[1]),
    );

    return hasAnyPair ||
        merged.containsKey('EMPLOYEE') ||
        merged.containsKey('SIGNER') ||
        merged.containsKey('REMARKS') ||
        merged.containsKey('DUE DAY');
  }
}
