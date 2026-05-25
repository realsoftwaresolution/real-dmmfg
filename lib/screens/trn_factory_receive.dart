import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:diam_mfg/models/factory_receive_mst_model.dart';
import 'package:diam_mfg/providers/charni_provider.dart';
import 'package:diam_mfg/providers/color_provider.dart';
import 'package:diam_mfg/providers/counter_manager_det_provider.dart';
import 'package:diam_mfg/providers/counter_provider.dart';
import 'package:diam_mfg/providers/cut_provider.dart';
import 'package:diam_mfg/providers/dept_provider.dart';
import 'package:diam_mfg/providers/dept_group_provider.dart';
import 'package:diam_mfg/providers/dept_process_provider.dart';
import 'package:diam_mfg/providers/employee_provider.dart';
import 'package:diam_mfg/providers/factory_receive_provider.dart';
import 'package:diam_mfg/providers/remarks_provider.dart';
import 'package:diam_mfg/providers/tensions_provider.dart';
import 'package:diam_mfg/utils/app_images.dart';
import 'package:diam_mfg/utils/constants.dart';
import 'package:diam_mfg/utils/delete_dialogue.dart';
import 'package:diam_mfg/utils/helper_functions.dart';
import 'package:diam_mfg/utils/msg_dialogue.dart';
import 'package:diam_mfg/utils/process_constants.dart';
import 'package:erp_data_table/erp_data_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rs_dashboard/rs_dashboard.dart';
import '../models/user_visibility_model.dart';
import '../providers/auth_provider.dart';
import '../providers/counter_display_det_provider.dart';
import '../providers/factory_provider.dart';
import '../providers/purity_provider.dart';
import '../providers/shape_provider.dart';
import '../providers/user_visibility_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  WIDGET
// ─────────────────────────────────────────────────────────────────────────────

class FactoryReceiveEntry extends StatefulWidget {
  const FactoryReceiveEntry({super.key});

  @override
  State<FactoryReceiveEntry> createState() => _TrnMakableEntryState();
}

// ─────────────────────────────────────────────────────────────────────────────
//  STATE
// ─────────────────────────────────────────────────────────────────────────────

class _TrnMakableEntryState extends State<FactoryReceiveEntry> {
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
  FactoryReceiveMstModel? _selectedMst;
  FactoryReceiveDetModel? _scannedDet;

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
  List<FactoryReceiveDetModel> _detRows = [];
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
        context.read<FactoryReceivedEntryProvider>().load(),
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
        context.read<FactoryProvider>().loadFactories(),
        context.read<CutProvider>().loadCuts(),
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
      'factoryRecDate': DateFormat('dd/MM/yyyy').format(now),
      'factoryIssMstID': '0',
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

  Future<void> _onBCodeScanned(String bCode, String fCode) async {
    final rows = await context
        .read<FactoryReceivedEntryProvider>()
        .fetchByBCode(bCode: bCode,fCode: fCode);

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

    set('orgPc', r.pc?.toString());
    set('orgWt', fThreeDecimal(r.wt));
    set('recWt', fThreeDecimal(r.issWt));
    set('recPc', r.issPc?.toString() ?? '0');
    set('issPc', r.issPc?.toString());
    set('issWt', fThreeDecimal(r.issWt));
    set('jno', r.jno?.toString());
    set('mfgCut', r.MfgCut?.toString());
    set('lotNo', r.pktNo?.toString());
    set('dmPer', r.dmPer?.toString());
    set('dmWt', r.dmWt?.toString());
    set('size', r.size?.toString());
    set('size', r.size?.toString());
    set('factoryIssDetID', r.factoryIssDetID?.toString());
    setState(() => _scannedDet = r);
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  CALCULATIONS
  // ─────────────────────────────────────────────────────────────────────────

  /// Loss WT = Iss WT − K WT,  Loss PC = Iss PC − K PC
  void _calcLoss() {
    final issWt = double.tryParse(_entryVals['issWt'] ?? '') ?? 0;
    final recWt = double.tryParse(_entryVals['recWt'] ?? '') ?? 0;
    final kWt   = double.tryParse(_entryVals['kWt'] ?? '') ?? 0;
    final brWt  = double.tryParse(_entryVals['brWt'] ?? '') ?? 0;

    final issPc = int.tryParse(_entryVals['issPc'] ?? '') ?? 0;
    final recPc = int.tryParse(_entryVals['recPc'] ?? '') ?? 0;
    final kPc   = int.tryParse(_entryVals['kPc'] ?? '') ?? 0;
    final brPc  = int.tryParse(_entryVals['brPc'] ?? '') ?? 0;

    // ✅ LOSS WT
    final lossWt = issWt - (recWt + kWt + brWt);

    // ✅ LOSS PC (FIXED)
    final lossPc = issPc - (recPc + kPc + brPc);

    // ❗ Prevent negative
    final double safeLossWt = lossWt < 0 ? 0.0 : lossWt;
    final safeLossPc = lossPc < 0 ? 0 : lossPc;

    _entryVals['lossWt'] = fThreeDecimal(safeLossWt);
    _entryVals['lossPc'] = '$safeLossPc';

    _erpFormKey.currentState?.updateFieldValue('lossWt', fThreeDecimal(safeLossWt));
    _erpFormKey.currentState?.updateFieldValue('lossPc', '$safeLossPc');
  }
  // ─────────────────────────────────────────────────────────────────────────
  //  ADD / EDIT ENTRY
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _addEntry() async {
    // 🔒 Scan required
    if (_scannedDet == null && (_entryVals['scanValue'] ?? '').isEmpty) {
      _erpFormKey.currentState?.focusField('scanValue');
      return;
    }

    // ─────────────────────────────
    // 🔢 PARSE VALUES
    // ─────────────────────────────
    final issWt = double.tryParse(_entryVals['issWt'] ?? '') ?? 0;

    final recPc = int.tryParse(_entryVals['recPc'] ?? '') ?? 0;
    final recWt = double.tryParse(_entryVals['recWt'] ?? '') ?? 0;

    final kPc   = int.tryParse(_entryVals['kPc'] ?? '') ?? 0;
    final kWt   = double.tryParse(_entryVals['kWt'] ?? '') ?? 0;

    final brPc  = int.tryParse(_entryVals['brPc'] ?? '') ?? 0;
    final brWt  = double.tryParse(_entryVals['brWt'] ?? '') ?? 0;

    final dmWt  = double.tryParse(_entryVals['dmWt'] ?? '') ?? 0;

    // ─────────────────────────────
    // ✅ VALIDATIONS
    // ─────────────────────────────
    if (recWt > issWt) {
      _showSnack('Rec WT cannot be greater than Iss WT');
      _erpFormKey.currentState?.focusField('recWt');
      return;
    }

    if (kWt > issWt) {
      _showSnack('K WT cannot be greater than Iss WT');
      _erpFormKey.currentState?.focusField('kWt');
      return;
    }

    if (brWt > issWt) {
      _showSnack('Br WT cannot be greater than Iss WT');
      _erpFormKey.currentState?.focusField('brWt');
      return;
    }

    if (dmWt > issWt) {
      _showSnack('DM WT cannot be greater than Iss WT');
      _erpFormKey.currentState?.focusField('dmWt');
      return;
    }

    final totalWt = recWt + kWt + brWt;
print(totalWt);
print(issWt);
    if (totalWt > issWt) {
      _showSnack('Total WT (Rec + K + Br) cannot exceed Iss WT');
      return;
    }

    // ─────────────────────────────
    // ✅ LOSS CALCULATION
    // ─────────────────────────────
    final issPc = int.tryParse(_entryVals['issPc'] ?? '') ?? 0;

    final lossWt = issWt - (recWt + kWt + brWt);
    final lossPc = issPc - (recPc + kPc + brPc);

    final safeLossWt = lossWt < 0 ? 0.0 : lossWt;
    final safeLossPc = lossPc < 0 ? 0 : lossPc;

    _entryVals['lossWt'] = fThreeDecimal(safeLossWt);
    _entryVals['lossPc'] = '$safeLossPc';

    _erpFormKey.currentState?.updateFieldValue('lossWt', fThreeDecimal(safeLossWt));
    _erpFormKey.currentState?.updateFieldValue('lossPc', '$safeLossPc');

    // ─────────────────────────────
    // 🟡 EDIT MODE → UPDATE API
    // ─────────────────────────────
    if (_isEditMode && _editingDetIndex != null) {
      final prov = context.read<FactoryReceivedEntryProvider>();

      final payload = {
        "FactoryRecMstID":
        int.tryParse(_formValues['factoryRecMstID'] ?? '0') ?? 0,

        "FactoryRecDetID":
        _detRows[_editingDetIndex!].FactoryRecDetID ?? 0,

        "BCode":
        int.tryParse(_entryVals['scanValue'] ?? '0') ?? 0,

        "RecPc": recPc,
        "RecWt": recWt,

        "KPc": kPc,
        "KWt": kWt ?? 0.000,

        "BrPc": brPc,
        "BrWt": brWt,

        "LossPc": safeLossPc,
        "LossWt": safeLossWt.toStringAsFixed(3),

        "PurityCode":
        int.tryParse(_entryVals['purity'] ?? '0') ?? 0,

        "CharniCode":
        int.tryParse(_entryVals['charni'] ?? '0') ?? 0,

        "ColorCode":
        int.tryParse(_entryVals['color'] ?? '0') ?? 0,

        "ShapeCode":
        int.tryParse(_entryVals['shape'] ?? '0') ?? 0,

        "CutCode":
        int.tryParse(_entryVals['cutCode'] ?? '0') ?? 0,

        "DmWt": dmWt,
        "DmPer":
        double.tryParse(_entryVals['dmPer'] ?? '0') ?? 0,

        "Size":
        double.tryParse(_entryVals['size'] ?? '0') ?? 0,
        'expectedProcess': ProcessConstants.factoryRec
      };

      final success = await prov.update(payload);
      if (!mounted) return;
      if (success) {
        final updatedRow = _buildEditedRow(
          srno: _detRows[_editingDetIndex!].srno,
          existing: _detRows[_editingDetIndex!],
          issPcStr: _entryVals['issPc'] ?? '',
          issWtStr: _entryVals['issWt'] ?? '',
          recPc: recPc,
          recWt: recWt,
        );

        setState(() {
          _detRows[_editingDetIndex!] = updatedRow;
          _editingDetIndex = null;
          _syncDetGrid();
        });

        _clearEntryFields();
        _showSnack("Updated successfully");
        context.read<FactoryReceivedEntryProvider>().load();
      }

      return;
    }

    // ─────────────────────────────
    // 🟢 ADD MODE → ADD LOCAL ROW
    // ─────────────────────────────
    final srno = _detRows.length + 1;

    final newRow = _buildNewRow(
      srno: srno,
      issPcStr: _entryVals['issPc'] ?? '',
      issWtStr: _entryVals['issWt'] ?? '',
      recPc: recPc,
      recWt: recWt,
    );

    setState(() {
      _detRows.add(newRow);
      _syncDetGrid();
      _lockMasterFields = true;
    });

    _clearEntryFields();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _erpFormKey.currentState?.focusField('scanValue');
    });

    // 🔒 lock master fields after first add
    _erpFormKey.currentState?.setFieldReadOnly('fromCrId', true);
    _erpFormKey.currentState?.setFieldReadOnly('toCrId', true);
    _erpFormKey.currentState?.setFieldReadOnly('deptProcessCode', true);
  }

  /// Build a detail row for an existing (edit) record.
  FactoryReceiveDetModel _buildEditedRow({
    required int? srno,
    required FactoryReceiveDetModel existing,
    required String issPcStr,
    required String issWtStr,
    required int recPc,
    required double recWt,
  }) {
    return FactoryReceiveDetModel(
      srno: srno,
      factoryRecMstID: existing.factoryRecMstID,
      factoryIssDetID: existing.factoryIssDetID,
      MfgCut: existing.MfgCut,
      size: existing.size,
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
      toCrId: int.tryParse(_formValues['polishChecker'] ?? ''),
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
      dmWt: double.tryParse(_entryVals['dmWt'] ?? ''),
      dmPer: double.tryParse(_entryVals['dmPer'] ?? ''),
      kPc: int.tryParse(_entryVals['kPc'] ?? ''),
      kWt: double.tryParse(_entryVals['kWt'] ?? ''),
      brPc: int.tryParse(_entryVals['brPc'] ?? ''),
      brWt: double.tryParse(_entryVals['brWt'] ?? ''),
      lossPc: int.tryParse(_entryVals['lossPc'] ?? ''),
      lossWt: double.tryParse(_entryVals['lossWt'] ?? ''),
      topsPc: int.tryParse(_entryVals['topsPc'] ?? ''),
      topsWt: double.tryParse(_entryVals['topsWt'] ?? ''),
      charniCode: existing.charniCode,
      tensionsCode: int.tryParse(_formValues['tensionsCode'] ?? ''),
      employeeCode: int.tryParse(_entryVals['employee'] ?? ''),
      signerCode: int.tryParse(_entryVals['signer'] ?? ''),
      remarksCode: int.tryParse(_entryVals['remarks'] ?? ''),
      dueDay: int.tryParse(_entryVals['dueDay'] ?? ''),
      diffDmWt: double.tryParse(_entryVals['diffDmWt'] ?? ''),
      recutEmp: double.tryParse(_entryVals['recutEmp'] ?? '0.000'),
      length: int.tryParse(_entryVals['length'] ?? '0'),
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
    );
  }

  /// Build a detail row for a new (add) record.
  FactoryReceiveDetModel _buildNewRow({
    required int? srno,
    required String issPcStr,
    required String issWtStr,
    required int recPc,
    required double recWt,
  }) {
    return FactoryReceiveDetModel(
      srno: srno,
      id: _scannedDet?.id,
      jno: _scannedDet?.jno,
      jnoRecPc: _scannedDet?.jnoRecPc,
      factoryIssDetID: int.tryParse(_entryVals['factoryIssDetID'] ?? ''),
      bCode: _scannedDet?.bCode ?? _entryVals['scanValue'],
      pktNo: _scannedDet?.pktNo,
      cutNo: _scannedDet?.cutNo,
      clvCut: _scannedDet?.clvCut,
      MfgCut: _scannedDet?.MfgCut,
      size: _scannedDet?.size,
      shapeCode: int.tryParse(_entryVals['shape'] ?? ''),
      purityCode: _scannedDet?.purityCode,
      colorCode: int.tryParse(_entryVals['color'] ?? ''),
      diam: _scannedDet?.diam,
      kachaRec: _scannedDet?.kachaRec ?? 'Y',
      fromDeptCode: _fromDeptCode,
      toDeptCode: _toDeptCodeVal,
      fromCrId: _fromCrId,
      toCrId: int.tryParse(_formValues['polishChecker'] ?? ''),
      deptProcessCode: int.tryParse(_formValues['deptProcessCode'] ?? ''),
      charniCode: int.tryParse(_entryVals['charni'] ?? ''),
      tensionsCode: int.tryParse(_formValues['tensionsCode'] ?? ''),
      pc: int.tryParse(_entryVals['orgPc'] ?? ''),
      wt: double.tryParse(_entryVals['orgWt'] ?? ''),
      issPc: int.tryParse(issPcStr),
      issWt: double.tryParse(issWtStr),
      recPc: recPc,
      recWt: recWt,
      totalPc: recPc,
      totalWt: recWt,
      dmWt: double.tryParse(_entryVals['dmWt'] ?? ''),
      dmPer: double.tryParse(_entryVals['dmPer'] ?? ''),
      kPc: int.tryParse(_entryVals['kPc'] ?? ''),
      kWt: double.tryParse(_entryVals['kWt'] ?? ''),
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
      entryType: 'I',
      formType: '',
      pktType: 'A',
      diffDmWt: double.tryParse(_entryVals['diffDmWt'] ?? '0.000'),
      plDmWt: double.tryParse(_entryVals['dmWt'] ?? '0.000'),
      plDmPer: double.tryParse(_entryVals['dmPer'] ?? '0.00'),
      recutEmp: double.tryParse(_entryVals['recutEmp'] ?? '0.000'),
      length: int.tryParse(_entryVals['length'] ?? '0'),
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
    set('kWt', fThreeDecimal(r.kWt));
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
    set('size', r.size?.toString());
    set('kPc', r.kPc.toString());
    set('kWt', fThreeDecimal(r.kWt));
    set('charni', r.charniCode.toString());
    set('scanValue', r.bCode.toString());
    set('jno', r.jno.toString());
    set('mfgCut', r.MfgCut.toString());
    set('lotNo', r.pktNo.toString());
    set('factoryRecMstID', r.factoryRecMstID.toString());
  }

  dynamic _deleteDetRow(int idx) async {
    dynamic success = false;
    if(_detRows[idx].FactoryRecDetID?.toString() != null && _detRows[idx].FactoryRecDetID != 0){
      final confirm = await ErpDeleteDialog.show(
        context: context,
        theme: _theme,
        title: 'Factory Issue',
        itemName: 'ID: ${_detRows[idx].FactoryRecDetID?.toString()}',
      );
      if (confirm != true || !mounted) return;

       success = await context.read<FactoryReceivedEntryProvider>().deleteRow(
        _detRows[idx].factoryRecMstID?.toString(),
        _detRows[idx].FactoryRecDetID?.toString(),
        _detRows[idx].bCode,
         _theme,
         context,
      );
      await ErpResultDialog.showDeleted(
        context: context,
        theme: _theme,
        itemName: '1 row(s) deleted successfully',
      );
    }
    if (mounted) {
      setState(() {
        _detRows.removeAt(idx);
        // Re-number srno
        _detRows = _detRows.asMap().entries.map((e) {
          final v = e.value;
          return FactoryReceiveDetModel(
            srno: e.key + 1,
            factoryRecMstID: v.factoryRecMstID,
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
          );
        }).toList();

        _syncDetGrid();
        if (_editingDetIndex == idx) _editingDetIndex = null;
      });
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  CLEAR ENTRY FIELDS
  // ─────────────────────────────────────────────────────────────────────────

  void _clearEntryFields() {
    const keys = [
      'factoryRecMstID',
      'orgPc',
      'orgWt',
      'issPc',
      'issWt',
      'recPc',
      'recWt',
      'kPc',
      'kWt',
      'brPc',
      'brWt',
      'lossPc',
      'lossWt',
      'dmWt',
      'dmPer',
      'size',
      'purity',
      'shape',
      'color',
      'charni',
      'cutCode',
      'scanValue',
      'jno',
      'mfgCut',
      'lotNo',
    ];
    for (final k in keys) {
      _entryVals.remove(k);
      _erpFormKey.currentState?.updateFieldValue(k, '');
    }
    _scannedDet = null;
    _isBCodePending = false;
    _entryVals['scanValue'] = '';
    _entryVals['factoryRecMstID'] = '0';
    Future.delayed(
      const Duration(milliseconds: 100),
          () => _erpFormKey.currentState?.focusField('scanValue'),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  SYNC DET GRID
  // ─────────────────────────────────────────────────────────────────────────

  void _syncDetGrid() {
    _activeDetColumns = [
      'srno',
      'jno',
      'qrCode',
      'bCode',
      'pktNo',
      'mfgCut',
      'orgPc',
      'orgWt',
      'issPc',
      'issWt',
      'recPc',
      'recWt',
      'kPc',
      'kWt',
      'brPc',
      'brWt',
      'lossPc',
      'lossWt',
      'diam',
      'length',
      'purityCode',
      'charniCode',
      'colorCode',
      'cutCode',
      'shapeCode',
      'dmWt',
      'dmPer',
      'per',
      'diffPer',
      'diffWt',
      'size',
    ];

    _detDisplay = _detRows.map((r) {
      return {
        'srno': r.srno ?? '',
        'jno': r.jno ?? '',
        'qrCode': r.qrCode ?? '',
        'bCode': r.bCode ?? '',
        'pktNo': r.pktNo ?? '',
        'mfgCut': r.MfgCut ?? '',

        'orgPc': r.pc ?? '',
        'orgWt': fThreeDecimal(r.wt),

        'issPc': r.issPc ?? '',
        'issWt': fThreeDecimal(r.issWt),

        'recPc': r.recPc ?? '',
        'recWt': fThreeDecimal(r.recWt),

        'kPc': r.kPc ?? '',
        'kWt': fThreeDecimal(r.kWt),

        'brPc': r.brPc ?? '',
        'brWt': fThreeDecimal(r.brWt),

        'lossPc': r.lossPc ?? '',
        'lossWt': fThreeDecimal(r.lossWt),

        'diam': r.diam ?? '',
        'length': r.length ?? '',

        'purityCode': _purityNameFor(r.purityCode),
        'charniCode': r.charniCode ?? '',
        'colorCode': r.colorCode ?? '',
        'cutCode': _cutNameFor(r.cutCode),
        'shapeCode': _shapeNameFor(r.shapeCode),

        'dmWt': fThreeDecimal(r.dmWt),
        'dmPer': r.dmPer ?? '',

        // 👇 Custom calculated (as per your image)
        'per': r.dmPer ?? '',
        'diffPer': r.diffDmWt ?? '',
        'diffWt': r.diffDmWt ?? '',

        'size': r.size ?? '',
        'factoryIssDetID': r.factoryIssDetID ?? '',
      };
    }).toList();

  }

  // ─────────────────────────────────────────────────────────────────────────
  //  ROW TAP (load existing record)
  // ─────────────────────────────────────────────────────────────────────────

  String _s(dynamic v, [String def = '']) => v?.toString() ?? def;

  String _date(dynamic v) {
    if (v == null) return '';
    try {
      if (v is String && v.contains('/')) return v; // already formatted
      final dt = DateTime.parse(v.toString());
      return DateFormat('dd/MM/yyyy').format(dt.toLocal());
    } catch (_) {
      return v.toString();
    }
  }

  Future<void> _onRowTap(Map<String, dynamic> row) async {
    final prov = context.read<FactoryReceivedEntryProvider>();
    final id = int.tryParse(row['id'].toString()) ?? 0;

    final details = await prov.loadDetails(id);
    if (!mounted) return;

    setState(() {
      _selectedRow = row;
      _isEditMode = true;
      _detRows = details;
      _editingDetIndex = null;
      _isAdding = false;
      _showTableOnMobile = false;

      // ✅ CLEAN FORM VALUES (ONLY REQUIRED FIELDS)
      _formValues = {
        'factoryRecMstID': _s(_detRows.first.factoryRecMstID, '0'),
        'factoryRecDate': _date(row['date']),
        'time': _s(row['time']),
        'factory': _s(row['factory']),
        'type': _s(row['type']),
        "polishChecker": _s(details.first.LastCrID ?? 0),
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

  Map<String, dynamic> _mapToApiDetail(FactoryReceiveDetModel r) {
    return {
      "Jno": r.jno,
      "FactoryIssDetID": r.factoryIssDetID ?? 0,

      "BCode": int.tryParse(r.bCode ?? '0') ?? 0,
      "PktNo": r.pktNo,
      "CutNo": r.cutNo,

      "MfgCut": r.MfgCut,

      "Pc": r.pc,
      "Wt": r.wt,

      "IssPc": r.issPc,
      "IssWt": r.issWt,

      "RecPc": r.recPc,
      "RecWt": r.recWt,

      "KPc": r.kPc ?? 0,
      "KWt": r.kWt ?? 0,

      "BrPc": r.brPc ?? 0,
      "BrWt": r.brWt ?? 0,

      "LossPc": r.lossPc ?? 0,
      "LossWt": r.lossWt?.toStringAsFixed(3) ?? 0,

      // ✅ ONLY send if valid
        "PurityCode": r.purityCode ?? 0,

        "CharniCode": r.charniCode ?? 0,

        "ColorCode": r.colorCode ?? 0,

      "ShapeCode": r.shapeCode ?? 0,
      "CutCode": r.cutCode ?? 0,

      "DmWt": r.dmWt ?? 0,
      "DmPer": r.dmPer ?? 0,

      "RecPer": 0.00,
      "DiffPer": 0.00,
      "DiffWt": 0.000,

      "Size": r.size,

      "RateID": r.rateID,
      "Rateon": r.rateon,
      "Rate": r.rate ?? 0,
      "Amount": r.amount,

      "CrID": _formValues['polishChecker'] ?? 0,
      "LastCrID": _formValues['polishChecker'] ?? 0,

      "Diam": r.diam ?? 0.00,
      "Length": r.length ?? 0.00,
      "QRCode": r.qrCode ?? '',

      "OrderMstID": r.orderMstID,
    };
  }

  Future<void> _onSave(Map<String, dynamic> values) async {
    if(_detRows.isNotEmpty){
      final prov = context.read<FactoryReceivedEntryProvider>();
      final payload = {
        "FactoryRecDate": toUtcIso(values['factoryRecDate']),   // already yyyy-MM-dd
        "FactoryCode": int.tryParse(values['factory'] ?? '0') ?? 0,
        "Sdate": DateTime.now().toUtc().toIso8601String(),
        "Stime": DateTime.now().toUtc().toIso8601String(),
        "EntryType": _formValues['type'] ?? '',
        "details": _detRows.map(_mapToApiDetail).toList(),
      };

      final success = await prov.create(payload);

      if (!mounted) return;
      if (success) {
        final wasEdit = _isEditMode;
        _resetForm();
        await ErpResultDialog.showSuccess(
          context: context,
          theme: _theme,
          title: wasEdit ? 'Updated' : 'Saved',
          message: wasEdit
              ? 'Factory Receive Entry Updated.'
              : 'Factory Receive Entry Saved.',
        );
        context.read<FactoryReceivedEntryProvider>().load();
      }
    }else {
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
    if (_formValues['factoryRecMstID'] == null) return;

    final confirm = await ErpDeleteDialog.show(
      context: context,
      theme: _theme,
      title: 'Factory Received',
      itemName: 'ID: ${_formValues['factoryRecMstID'].toString()}',
    );

    if (confirm != true || !mounted) return;

    final success = await context.read<FactoryReceivedEntryProvider>().delete(
      _formValues['factoryRecMstID'].toString(),
      _theme,
      context,
      _detRows.where((r) => r.bCode != null && r.bCode != '0')
          .map((r) => num.parse(r.bCode.toString()))
          .toList(),
    );

    if (success && mounted) {
      final id = _formValues['factoryRecMstID'].toString();
      _resetForm();
      await ErpResultDialog.showDeleted(
        context: context,
        theme: _theme,
        itemName: 'Factory Received $id',
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
    final colorProv = context.read<ColorProvider>();
    final purityProv = context.read<PurityProvider>();
    final shapeProv = context.read<ShapeProvider>();
    final cutProv = context.read<CutProvider>();
    final charniProv = context.read<CharniProvider>();
    final factoryProv = context.read<FactoryProvider>();
    final counterProv = context.read<CounterProvider>();

    // ── FROM dropdown ────────────────────────────────────────────────────────
    final fromItems = counterProv.list
        .where((c) {
      final grp = _deptGroupNameFor(c.deptGroupCode).toUpperCase();
      return grp.contains('CLEAVING');
    })
        .map((c) => ErpDropdownItem(
      label: '${c.crName ?? ''}  |  ${_deptNameFor(c.deptCode)}',
      value: c.crId?.toString() ?? '',
    ))
        .toList();

    // factoryDropdown
    final factoryItems = factoryProv.factories
        .where((e) => e.active == true)
        .toList();
    final factoryDropdown = factoryItems
        .map(
          (e) => ErpDropdownItem(
            label: e.factoryName ?? '',
            value: e.factoryCode?.toString() ?? '',
          ),
        )
        .toList();


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
    //CHARNi
    final charniItems = charniProv.list.where((e) => e.active == true).toList()
      ..sort((a, b) => (a.sortID ?? 0).compareTo(b.sortID ?? 0));
    final charniDropdown = charniItems
        .map(
          (e) => ErpDropdownItem(
            label: e.charniName ?? '',
            value: e.charniCode?.toString() ?? '',
          ),
        )
        .toList();

    /// Returns true if the field name exists in the merged DEPT visibility map.
    bool _isFieldVisible(String fieldName) {
      // final name = fieldName.toUpperCase();
      //
      // for (final f in [
      //   ..._fromDisplayFields,
      //   ..._toDisplayFields,
      // ]) {
      //
      //   if (f.entryType != 'MAKABLE') continue;
      //
      //   final n =
      //   (f.userVisibilityName ?? '')
      //       .trim()
      //       .toUpperCase();
      //
      //   if (n == name) {
      //     return true;
      //   }
      // }

      return true;
    }
    // ─────────────────────────────────────────────────────────────────────
    //  MASTER SECTION (sectionIndex 0)
    // ─────────────────────────────────────────────────────────────────────
    final List<List<ErpFieldConfig>> rows = [
      // Row 1 — date / time / ID
      [
        ErpFieldConfig(
          key: 'factoryRecDate',
          label: 'DATE',
          type: ErpFieldType.date,
          readOnly: true,
          sectionIndex: 0,
        ),
        ErpFieldConfig(
          key: 'factory',
          label: 'FACTORY',
          type: ErpFieldType.dropdown,
          dropdownItems: factoryDropdown,
          sectionIndex: 0,
          width: 350,
          required: true,
          readOnly: _isEditMode || _detRows.isNotEmpty
        ),
        ErpFieldConfig(
          key: 'polishChecker',
          label: 'POLISH CHECKER',
          type: ErpFieldType.dropdown,
          dropdownItems: fromItems,
          sectionIndex: 0,
          width: 350,
            readOnly: _isEditMode || _detRows.isNotEmpty
        ),
        ErpFieldConfig(
          key: 'factoryRecMstID',
          label: 'ID',
          type: ErpFieldType.number,
          readOnly: true,
          sectionIndex: 0,
        ),
      ],

      [
        ErpFieldConfig(
          key: 'scanValue',
          label: 'BCODE',
          type: ErpFieldType.text,
          sectionIndex: 1,
          width: 200,
        ),
        ErpFieldConfig(
          key: 'qrCode',
          label: 'QRCODE',
          type: ErpFieldType.text,
          readOnly: true,
          sectionIndex: 1,
          width: 200,
        ),
        ErpFieldConfig(
          key: 'jno',
          label: 'Jno',
          type: ErpFieldType.number,
          readOnly: true,
          sectionIndex: 1,
          width: 200,
        ),
        ErpFieldConfig(
          key: 'mfgCut',
          label: 'MFG CUT',
          type: ErpFieldType.number,
          readOnly: true,
          sectionIndex: 1,
          width: 200,
        ),
        ErpFieldConfig(
          key: 'lotNo',
          label: 'Lot No',
          type: ErpFieldType.number,
          readOnly: true,
          sectionIndex: 1,
          width: 200,
        ),
      ],
      [
        // ORG
        ErpFieldConfig(
          key: 'orgPc',
          label: 'ORG PC',
          type: ErpFieldType.number,
          readOnly: true,
          isEntryField: true,
          sectionIndex: 2,
          flex: 1,
        ),
        ErpFieldConfig(
          key: 'orgWt',
          label: 'ORG WT',
          type: ErpFieldType.amount,
          readOnly: true,
          isEntryField: true,
          sectionIndex: 2,
          flex: 1,
        ),

        // ISS
        ErpFieldConfig(
          key: 'issPc',
          label: 'ISS PC',
          type: ErpFieldType.number,
          readOnly: true,
          sectionIndex: 2,
          flex: 1,
        ),
        ErpFieldConfig(
          key: 'issWt',
          label: 'ISS WT',
          type: ErpFieldType.amount,
          readOnly: true,
          sectionIndex: 2,
          flex: 1,
        ),

        // REC
        if (_isFieldVisible('REC PC'))
        ErpFieldConfig(
          key: 'recPc',
          label: 'REC PC',
          type: ErpFieldType.number,
          sectionIndex: 2,
          flex: 1,
        ),
        if (_isFieldVisible('REC WT'))
        ErpFieldConfig(
          key: 'recWt',
          label: 'REC WT',
          type: ErpFieldType.amount,
          sectionIndex: 2,
          flex: 1,
        ),
        if (_isFieldVisible('K PC'))
        ErpFieldConfig(
          key: 'kPc',
          label: 'K PC',
          type: ErpFieldType.number,
          sectionIndex: 2,
          flex: 1,
        ),
        if (_isFieldVisible('K PC'))
        ErpFieldConfig(
          key: 'kWt',
          label: 'K WT',
          type: ErpFieldType.amount,
          sectionIndex: 2,
          flex: 1,
        ),
        if (_isFieldVisible('BR PC'))
        ErpFieldConfig(
          key: 'brPc',
          label: 'BR PC',
          type: ErpFieldType.number,
          sectionIndex: 2,
          flex: 1,
        ),
        ErpFieldConfig(
          key: 'brWt',
          label: 'BR WT',
          type: ErpFieldType.amount,
          sectionIndex: 2,
          readOnly: true,
          flex: 1,
        ),
        ErpFieldConfig(
          key: 'lossPc',
          label: 'LOSS PC',
          type: ErpFieldType.number,
          readOnly: true,
          sectionIndex: 2,
          flex: 1,
        ),
        ErpFieldConfig(
          key: 'lossWt',
          label: 'LOSS WT',
          type: ErpFieldType.amount,
          readOnly: true,
          sectionIndex: 2,
          flex: 1,
        ),
        // DM
        ErpFieldConfig(
          key: 'dmWt',
          label: 'DM WT',
          type: ErpFieldType.amount,
          sectionIndex: 2,
          readOnly: true,
          flex: 1,
        ),
        ErpFieldConfig(
          key: 'dmPer',
          label: 'DM PER',
          type: ErpFieldType.number,
          readOnly: true,
          sectionIndex: 2,
          flex: 1,
        ),

        ErpFieldConfig(
          key: 'size',
          label: 'SIZE',
          type: ErpFieldType.number,
          readOnly: true,
          sectionIndex: 2,
          flex: 1,
        ),
        if (_isFieldVisible('PURITY'))
        ErpFieldConfig(
          key: 'purity',
          label: 'PURITY',
          type: ErpFieldType.dropdown,
          dropdownItems: purityDropdown,
          sectionIndex: 2,
          flex: 1,
        ),
        if (_isFieldVisible('CHARNI'))
        ErpFieldConfig(
          key: 'charni',
          label: 'CHARNI',
          type: ErpFieldType.dropdown,
          dropdownItems: charniDropdown,
          sectionIndex: 2,
          flex: 1,
        ),
        if (_isFieldVisible('COLOR'))
        ErpFieldConfig(
          key: 'color',
          label: 'COLOR',
          type: ErpFieldType.dropdown,
          dropdownItems: colorDropdown,
          sectionIndex: 2,
          flex: 1,
        ),
        if (_isFieldVisible('CUT'))
        ErpFieldConfig(
          key: 'cutCode',
          label: 'CUT',
          type: ErpFieldType.dropdown,
          dropdownItems: cutDropdown,
          sectionIndex: 2,
          flex: 1,
        ),
        if (_isFieldVisible('SHAPE'))
        ErpFieldConfig(
          key: 'shape',
          label: 'SHAPE',
          type: ErpFieldType.dropdown,
          dropdownItems: shapeDropdown,
          showAddButton: true,
          sectionIndex: 2,
          flex: 1,
        ),
      ],
    ];

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

    ErpColumnConfig(key: 'id', label: 'ID', width: 100),

    ErpColumnConfig(
      key: 'date',
      label: 'Date',
      width: 120,
      isDate: true,
    ),

    ErpColumnConfig(key: 'time', label: 'Time', width: 120),

    ErpColumnConfig(key: 'factoryName', label: 'Factory', width: 180),

    ErpColumnConfig(
      key: 'totPkt',
      label: 'Tot Pkt',
      width: 100,
      align: ColumnAlign.right,
    ),

    ErpColumnConfig(
      key: 'pc',
      label: 'Pc',
      width: 90,
      align: ColumnAlign.right,
    ),

    ErpColumnConfig(
      key: 'wt',
      label: 'Wt',
      width: 110,
      align: ColumnAlign.right,
    ),

    ErpColumnConfig(
      key: 'issPc',
      label: 'Iss Pc',
      width: 100,
      align: ColumnAlign.right,
    ),

    ErpColumnConfig(
      key: 'issWt',
      label: 'Iss Wt',
      width: 110,
      align: ColumnAlign.right,
    ),

    ErpColumnConfig(
      key: 'recPc',
      label: 'Rec Pc',
      width: 100,
      align: ColumnAlign.right,
    ),

    ErpColumnConfig(
      key: 'recWt',
      label: 'Rec Wt',
      width: 110,
      align: ColumnAlign.right,
    ),

    ErpColumnConfig(
      key: 'kPc',
      label: 'K Pc',
      width: 90,
      align: ColumnAlign.right,
    ),

    ErpColumnConfig(
      key: 'kWt',
      label: 'K Wt',
      width: 100,
      align: ColumnAlign.right,
    ),

    ErpColumnConfig(
      key: 'brPc',
      label: 'Br Pc',
      width: 100,
      align: ColumnAlign.right,
    ),

    ErpColumnConfig(
      key: 'brWt',
      label: 'Br Wt',
      width: 110,
      align: ColumnAlign.right,
    ),

    ErpColumnConfig(
      key: 'lossPc',
      label: 'Loss Pc',
      width: 110,
      align: ColumnAlign.right,
    ),

    ErpColumnConfig(
      key: 'lossWt',
      label: 'Loss Wt',
      width: 120,
      align: ColumnAlign.right,
    ),

    ErpColumnConfig(
      key: 'dmWt',
      label: 'Dm Wt',
      width: 110,
      align: ColumnAlign.right,
    ),

    ErpColumnConfig(
      key: 'dmPer',
      label: 'Dm Per',
      width: 110,
      align: ColumnAlign.right,
    ),
  ];


  // ─────────────────────────────────────────────────────────────────────────
  //  COL LABEL
  // ─────────────────────────────────────────────────────────────────────────

  String _colLabel(String key) {
    const labels = {
      'srno': 'Sr No',
      'jno': 'Jno',
      'qrCode': 'QRCode',
      'bCode': 'BCode',
      'pktNo': 'Pkt No',
      'mfgCut': 'Mfg Cut',

      'orgPc': 'Org Pc',
      'orgWt': 'Org Wt',

      'issPc': 'Iss Pc',
      'issWt': 'Iss Wt',

      'recPc': 'Rec Pc',
      'recWt': 'Rec Wt',

      'kPc': 'K Pc',
      'kWt': 'K Wt',

      'brPc': 'Br Pc',
      'brWt': 'Br Wt',

      'lossPc': 'Loss Pc',
      'lossWt': 'Loss Wt',

      'diam': 'Diam',
      'length': 'Length',

      'purityCode': 'Purity',
      'charniCode': 'Charni',
      'colorCode': 'Color',
      'cutCode': 'Cut',
      'shapeCode': 'Shape',

      'dmWt': 'Dm Wt',
      'dmPer': 'Dm Per',

      'per': 'Per',
      'diffPer': 'Diff %',
      'diffWt': 'Diff Wt',

      'size': 'Size',
    };
    return labels[key] ?? key;
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Consumer<FactoryReceivedEntryProvider>(
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
      addButtonSections: const {2},
      logo: AppImages.logo,
      title: 'FACTORY RECEIVE ENTRY',
      tabBarBackgroundColor: const Color(0xfff2f0ef),
      tabBarSelectedColor: _theme.primaryGradient.first,
      tabBarSelectedTxtColor: Colors.white,
      rows: _buildFormRows(),
      initialValues: _formValues,
      isEditMode: _isEditMode,

      onEntryAdd: (sectionIndex) {
        if (sectionIndex != 2) return;
        _addEntry();
      },

      onFieldChanged: (key, value) {
        final val = value.toString();
        _formValues[key] = val;

        // always store in entryVals
        _entryVals[key] = val;

        switch (key) {

        // ─────────────────────────────
        // MASTER FIELDS
        // ─────────────────────────────
          case 'fromCrId':
            _onFromSelected(val);
            Future.delayed(
              const Duration(milliseconds: 50),
                  () => _erpFormKey.currentState?.focusField('toCrId'),
            );
            break;

          case 'toCrId':
            _onToSelected(val);
            Future.delayed(
              const Duration(milliseconds: 50),
                  () => _erpFormKey.currentState?.focusField('deptProcessCode'),
            );
            break;

          case 'deptProcessCode':
            _onProcessSelected(val);
            Future.delayed(
              const Duration(milliseconds: 100),
                  () => _erpFormKey.currentState?.focusField('scanValue'),
            );
            break;
          case 'factory':
            _formValues[key] = value.toString();

            final factoryProv = context.read<FactoryProvider>();

            final selectedFactory = factoryProv.factories.firstWhereOrNull(
                  (f) => f.factoryCode.toString() == value.toString(),
            );

            if (selectedFactory != null) {
              final type = selectedFactory.factoryType ?? '';

              _formValues['type'] = type;

              _erpFormKey.currentState?.updateFieldValue('type', type);
            }

            break;
        // ─────────────────────────────
        // SCAN FIELD
        // ─────────────────────────────
          case 'scanValue':
          // handled in onFieldSubmitted
            break;

        // ─────────────────────────────
        // DM VALIDATION
        // ─────────────────────────────
          case 'dmPer':
            final dmPerVal = double.tryParse(val) ?? 0;
            if (dmPerVal > 100) {
              _entryVals['dmPer'] = '100';
              _erpFormKey.currentState?.updateFieldValue('dmPer', '100');
            }
            break;

        // ─────────────────────────────
        // 🔥 MAIN CALC TRIGGERS (VERY IMPORTANT)
        // ─────────────────────────────
          case 'recWt':
          case 'kWt':
          case 'brWt':
          case 'recPc':
          case 'kpc':
          case 'brPc':

            _calcLoss(); // ✅ auto calc lossPc + lossWt

            break;

        // ─────────────────────────────
        // OPTIONAL: DM WT change → recalc %
        // ─────────────────────────────
          case 'dmWt':
            final recWt = double.tryParse(_entryVals['recWt'] ?? '') ?? 0;
            final dmWt  = double.tryParse(val) ?? 0;

            if (recWt > 0) {
              final per = (dmWt / recWt) * 100;
              _entryVals['dmPer'] = per.toStringAsFixed(2);
              _erpFormKey.currentState?.updateFieldValue(
                'dmPer',
                per.toStringAsFixed(2),
              );
            }
            break;

          case 'shape':

            if (key == 'shape') {
              // VALIDATION
              if (value == null || value.toString().isEmpty) {
                return;
              }

              // ADD ENTRY
              _addEntry();

              return;
            }


          default:
            break;
        }
      },
      onFieldSubmitted: (key, value) {
        if (key != 'scanValue') return;
        final scanVal = value.toString().trim();
        if (scanVal.isEmpty) return;

        // ✅ Duplicate check
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

        // 🚀 MAIN API CALL
        _isBCodePending = true;
        _onBCodeScanned(scanVal,_formValues['factory']!);
      },
      onExit: () => context.read<TabProvider>().closeCurrentTab(),
      onSave: _isEditMode ?null:_onSave,
      isShowSaveButton: !_isEditMode,
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
                  'srno': TextAlign.left,
                  'jno': TextAlign.left,
                  'qrCode': TextAlign.left,
                  'bCode': TextAlign.left,
                  'pktNo': TextAlign.left,
                  'mfgCut': TextAlign.left,
                  'purityCode': TextAlign.right,
                  'charniCode': TextAlign.right,
                  'colorCode': TextAlign.right,
                  'cutCode': TextAlign.right,
                  'shapeCode': TextAlign.right,

                  'orgPc': TextAlign.right,
                  'orgWt': TextAlign.right,

                  'issPc': TextAlign.right,
                  'issWt': TextAlign.right,

                  'recPc': TextAlign.right,
                  'recWt': TextAlign.right,

                  'kPc': TextAlign.right,
                  'kWt': TextAlign.right,

                  'brPc': TextAlign.right,
                  'brWt': TextAlign.right,

                  'lossPc': TextAlign.right,
                  'lossWt': TextAlign.right,

                  'dmWt': TextAlign.right,
                  'dmPer': TextAlign.right,

                  'per': TextAlign.right,
                  'diffPer': TextAlign.right,
                  'diffWt': TextAlign.right,

                  'size': TextAlign.right,
                  'diam': TextAlign.right,
                  'length': TextAlign.right,
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
    double sumD(double? Function(FactoryReceiveDetModel r) fn) =>
        _detRows.fold(0.0, (s, r) => s + (fn(r) ?? 0));

    int sumI(int? Function(FactoryReceiveDetModel r) fn) =>
        _detRows.fold(0, (s, r) => s + (fn(r) ?? 0));

    // 🔹 Totals
    final orgPc = sumI((r) => r.pc);
    final orgWt = sumD((r) => r.wt);

    final issPc = sumI((r) => r.issPc);
    final issWt = sumD((r) => r.issWt);

    final recPc = sumI((r) => r.recPc);
    final recWt = sumD((r) => r.recWt);

    final kPc = sumI((r) => r.kPc);
    final kWt = sumD((r) => r.kWt);

    final brPc = sumI((r) => r.brPc);
    final brWt = sumD((r) => r.brWt);

    final lossPc = sumI((r) => r.lossPc);
    final lossWt = sumD((r) => r.lossWt);

    final dmWt = sumD((r) => r.dmWt);

    final size = sumD((r) => r.size);

    // 🔹 Percentage Calculation (IMPORTANT)
    final baseWt = recWt > 0 ? recWt : issWt;

    final per = baseWt > 0 ? (dmWt / baseWt) * 100 : 0;

    final diffWt = sumD((r) => r.diffDmWt);
    final diffPer = baseWt > 0 ? (diffWt / baseWt) * 100 : 0;

    return {
      // 🔹 COUNT
      'srno': 'Tot: ${_detRows.length}',

      // 🔹 ORG
      'orgPc': '$orgPc',
      'orgWt': fThreeDecimal(orgWt),

      // 🔹 ISS
      'issPc': '$issPc',
      'issWt': fThreeDecimal(issWt),

      // 🔹 REC
      'recPc': '$recPc',
      'recWt': fThreeDecimal(recWt),

      // 🔹 K
      'kPc': '$kPc',
      'kWt': fThreeDecimal(kWt),

      // 🔹 BR
      'brPc': '$brPc',
      'brWt': fThreeDecimal(brWt),

      // 🔹 LOSS
      'lossPc': '$lossPc',
      'lossWt': fThreeDecimal(lossWt),

      // 🔹 DM
      'dmWt': fThreeDecimal(dmWt),
      'dmPer': per.toStringAsFixed(2),

      // 🔹 EXTRA (MATCH IMAGE)
      'per': per.toStringAsFixed(2),
      'diffPer': diffPer.toStringAsFixed(2),
      'diffWt': fThreeDecimal(diffWt),

      // 🔹 SIZE
      'size': fThreeDecimal(size),
    };
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  TABLE WIDGET
  // ─────────────────────────────────────────────────────────────────────────
  String _formatDate(String? value) {
    if (value == null || value.isEmpty) return '';

    try {
      final dt = DateTime.parse(value).toLocal();
      return DateFormat('dd/MM/yyyy').format(dt);
    } catch (_) {
      return value;
    }
  }
  Widget _buildTable(FactoryReceivedEntryProvider prov) {
    final data = prov.list.map((e) {
      return {
        'id': e.factoryRecMstID?.toString() ?? '',

        'date': _formatDate(e.factoryRecDate),
        'time': e.time ?? '',

        'factory': e.factoryCode ?? '',
        'factoryName': e.factoryName ?? '',
        'type': e.EntryType ?? '',

        'totPkt': (e.pkt ?? 0).toString(),

        'pc': (e.pc ?? 0).toString(),
        'wt': fThreeDecimal(e.wt ?? 0),

        'issPc': (e.issPc ?? 0).toString(),
        'issWt': fThreeDecimal(e.issWt ?? 0),

        'recPc': (e.recPc ?? 0).toString(),
        'recWt': fThreeDecimal(e.recWt ?? 0),

        'kPc': (e.kPc ?? 0).toString(),
        'kWt': fThreeDecimal(e.kWt ?? 0),

        'brPc': (e.brPc ?? 0).toString(),
        'brWt': fThreeDecimal(e.brWt ?? 0),

        'lossPc': (e.lossPc ?? 0).toString(),
        'lossWt': fThreeDecimal(e.lossWt ?? 0),

        'dmWt': fThreeDecimal(e.dmWt ?? 0),
        'dmPer': (e.dmPer ?? 0).toStringAsFixed(2),
      };
    }).toList();

    return ErpDataTable(
      isReportRow: false,
      token: token ?? '',
      url: '',
      title: 'FACTORY RECEIVE ENTRY LIST',
      columns: _tableColumns,
      data: data,
      showSearch: true,
      dateFilter: true,
      onClose: (){
        setState(() {
          _showTableOnMobile = false;
        });
      },
      selectedRow: _selectedRow,
      onRowTap: _onRowTap,
      emptyMessage: prov.isLoaded ? 'No entries found' : 'Loading...',
    );
  }
}
