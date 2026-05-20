import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:diam_mfg/models/planning_received_model.dart';
import 'package:diam_mfg/models/spkDeptIss_mst_model.dart';
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
import '../models/user_visibility_model.dart';
import '../providers/auth_provider.dart';
import '../providers/counter_display_det_provider.dart';
import '../providers/purity_provider.dart';
import '../providers/shape_provider.dart';
import '../providers/trn_planning_received_provider.dart';
import '../providers/user_visibility_provider.dart';
import '../utils/constants.dart';

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

class _TrnPlanningReceivedEntryState extends State<TrnPlanningReceivedEntry> {
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
  String?
  _highlightedBCode; // ← tracks which bCode to highlight in barcode table
  Map<String, dynamic>? _selectedRow;
  PlanningReceivedMstModel? _selectedMst;
  PlanningReceivedDetModel? _scannedDet;

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
  String? _filteredBCode; // ← add this with your other state variables
  String _autoRec = 'N';

  int? _toCrId;
  String? _toDeptName;
  int? _toDeptCodeVal;

  // ── Detail rows ────────────────────────────────────────────────────────────
  List<PlanningReceivedDetModel> _detRows = [];
  int? _editingDetIndex;

  // ── Display fields (from UserVisibility) ───────────────────────────────────
  List<UserVisibilityModel> _fromDisplayFields = [];
  List<UserVisibilityModel> _toDisplayFields = [];

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
        context.read<CounterDisplayDetProvider>().load(),
        context.read<UserVisibilityProvider>().load(),
      ]);
      if (!mounted) return;
      _resetForm();
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

  // ─────────────────────────────────────────────
  // _onBCodeScanned
  // ─────────────────────────────────────────────

  Future<void> _onBCodeScanned(String bCode) async {
    final prov = context.read<TrnPlanningReceivedProvider>();

    // CLEAR OLD TEMP DATA
    prov.clearTempScanData();

    final planningData = await prov.fetchByBCodePlanningList(
      bCode: bCode,

      fromCrId: _fromCrId!.toString(),
    );

    // ─────────────────────────────
    // SARIN API
    // ─────────────────────────────

    List<PlanningReceivedDetModel> sarinData = [];

    try {
      sarinData = await prov.fetchByBCode(
        bCode: bCode,

        fromCrId: _fromCrId!.toString(),
        context:context,
      );
    } catch (e) {
      if (!mounted) return;

      prov.clearTempScanData();


      _entryVals['scanValue'] = '';

      _erpFormKey.currentState?.updateFieldValue('scanValue', '');

      Future.delayed(
        const Duration(milliseconds: 100),

        () => _erpFormKey.currentState?.focusField('scanValue'),
      );

      return;
    }

    if (!mounted) return;

    _isBCodePending = false;

    // ─────────────────────────────
    // VALIDATION
    // ─────────────────────────────

    final hasPlanning = planningData.isNotEmpty;

    final hasSarin =
        sarinData.isNotEmpty &&
        sarinData.any((e) => e.sarinData != null && e.sarinData!.isNotEmpty);

    // ─────────────────────────────
    // ERROR
    // ─────────────────────────────

    if (!hasPlanning || !hasSarin) {
      prov.clearTempScanData();

      await ErpResultDialog.showError(
        context: context,

        theme: _theme,

        title: 'BCode',

        message: !hasPlanning
            ? 'Planning data not found!'
            : 'Sarin data not found!',
      );

      _entryVals['scanValue'] = '';

      _erpFormKey.currentState?.updateFieldValue('scanValue', '');

      Future.delayed(
        const Duration(milliseconds: 100),

        () => _erpFormKey.currentState?.focusField('scanValue'),
      );

      return;
    }

    // ─────────────────────────────
    // SUCCESS
    // ─────────────────────────────

    prov.commitTempScanData();

    setState(() {
      _highlightedBCode = bCode;
    });

    _entryVals['scanValue'] = '';

    _erpFormKey.currentState?.updateFieldValue('scanValue', '');

    Future.delayed(
      const Duration(milliseconds: 100),

      () => _erpFormKey.currentState?.focusField('scanValue'),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  ROW TAP
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _onRowTap(Map<String, dynamic> row) async {
    final raw = row['_raw'] as PlanningReceivedMstModel;
    final prov = context.read<TrnPlanningReceivedProvider>();
    await prov.loadDetails(raw.spkDeptIssMstID!);
    await prov.loadSarinDataDetails(raw.spkDeptIssMstID!);
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
      };
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

  //  DELETE
  Future<void> _onDelete() async {
    if (_selectedMst?.spkDeptIssMstID == null) {
      return;
    }

    final prov = context.read<TrnPlanningReceivedProvider>();

    // UNIQUE DELETE DATA
    final seen = <String>{};

    final data = prov.planningDetList
        .where((e) {
          print(jsonEncode(e));
          final key = '${e.bCode}_${e.spkDeptIssMstID}';

          if (seen.contains(key)) {
            return false;
          }

          seen.add(key);

          return true;
        })
        .map((e) {
          return {'bcode': e.bCode, 'spkDeptIssMstId': e.spkDeptIssMstID};
        })
        .toList();

    if (data.isEmpty) {
      await ErpResultDialog.showError(
        context: context,

        theme: _theme,

        title: 'Delete',

        message: 'No planning data found for delete.',
      );

      return;
    }

    final confirm = await ErpDeleteDialog.show(
      context: context,

      theme: _theme,

      title: 'Planning Delete',

      itemName: '${data.length} Planning Record(s)',
    );

    if (confirm != true || !mounted) {
      return;
    }

    final success = await prov.deleteBulk(data);

    if (!mounted) return;

    if (success) {
      final deletedCount = data.length;

      _resetForm();

      await ErpResultDialog.showDeleted(
        context: context,

        theme: _theme,

        itemName: '$deletedCount Planning Record(s)',
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  RESET
  // ─────────────────────────────────────────────────────────────────────────

  void _resetForm() {
    // _erpFormKey.currentState?.resetForm();
    _entryVals.clear();
    final prov = context.read<TrnPlanningReceivedProvider>();
    prov.clearForReset(); // 🔥 THIS LINE
    setState(() {
      _selectedRow = _selectedMst = null;
      _isEditMode = _showTableOnMobile = false;
      _isAdding = false;
      _detRows = [];
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
      _filteredBCode = null; // ← ADD THIS
      _highlightedBCode = null;
    });
    _setDefaultFormValues();
  }

  void _rebuildForm() {
    setState(() => _erpFormKey = GlobalKey<ErpFormState>());
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  BUILD FORM ROWS
  // ─────────────────────────────────────────────────────────────────────────

  List<List<ErpFieldConfig>> _buildFormRows() {
    final counterProv = context.read<CounterProvider>();
    final mgDetProv = context.read<CounterManagerDetProvider>();
    final procProv = context.read<DeptProcessProvider>();

    final isFromSelected = _fromCrId != null;
    final isToSelected = _toCrId != null;

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

    // ── MASTER SECTION ────────────────────────────────────────────────────
    final List<List<ErpFieldConfig>> rows = [
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
          key: 'scanValue',
          label: 'BCODE',
          type: ErpFieldType.text,
          isEntryField: true,
          readOnly: false,
          sectionIndex: 3,
          width: 200,
        ),
      ],
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
  //  TABLE COLUMNS (master list)
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

  List<ErpColumnConfig> get _tableColumnsByBarCode => [
    ErpColumnConfig(label: 'Sarin ID', key: 'sarinPolID'),
    ErpColumnConfig(label: 'BCode', key: 'bCode'),
    ErpColumnConfig(label: 'Stone ID', key: 'stoneID'),
    ErpColumnConfig(label: 'Polish Wt', key: 'polishWT'),
    ErpColumnConfig(label: 'Polish %', key: 'polishPer'),
    ErpColumnConfig(label: 'Shape', key: 'shape'),
    ErpColumnConfig(label: 'Cut', key: 'cut'),
    ErpColumnConfig(label: 'Color', key: 'color'),
    ErpColumnConfig(label: 'Clarity', key: 'clarity'),
    ErpColumnConfig(label: 'Total Wt', key: 'tWT'),
    ErpColumnConfig(label: 'Rate', key: 'rate'),
    ErpColumnConfig(label: 'Amt', key: 'amt'),
    ErpColumnConfig(label: 'Lot Code', key: 'lotCode'),
    ErpColumnConfig(label: 'Kapan No', key: 'kapanNo'),
    ErpColumnConfig(label: 'Sr Num', key: 'srNum'),
    ErpColumnConfig(label: 'Crown Height', key: 'crownHeight'),
    ErpColumnConfig(label: 'Operator', key: 'operatorName'),
    ErpColumnConfig(label: 'THmm', key: 'tHmm'),
    ErpColumnConfig(label: 'Disc', key: 'disc'),
    ErpColumnConfig(label: 'Rec', key: 'rec'),
  ];

  List<ErpColumnConfig> get _columnLabels => [
    ErpColumnConfig(label: 'Sr No', key: 'Srno'),
    ErpColumnConfig(label: 'BCode', key: 'BCode'),
    ErpColumnConfig(label: 'Pkt No', key: 'PktNo'),
    ErpColumnConfig(label: 'Cut No', key: 'CutNo'),
    ErpColumnConfig(label: 'Pc', key: 'Pc'),
    ErpColumnConfig(label: 'Wt', key: 'Wt'),
    ErpColumnConfig(label: 'Iss Pc', key: 'IssPc'),
    ErpColumnConfig(label: 'Iss Wt', key: 'IssWt'),
    ErpColumnConfig(label: 'Rec Pc', key: 'RecPc'),
    ErpColumnConfig(label: 'Rec Wt', key: 'RecWt'),
    ErpColumnConfig(label: 'Dm Wt', key: 'DmWt'),
    ErpColumnConfig(label: 'Dm Per', key: 'DmPer'),
    ErpColumnConfig(label: 'Employee', key: 'Employee', width: 160),
    ErpColumnConfig(label: 'Signer', key: 'Signer'),
    ErpColumnConfig(label: 'Checker Man', key: 'CheckerMan', width: 180),
    ErpColumnConfig(label: 'Signer Man', key: 'SignerMan', width: 180),
  ];

  // ─────────────────────────────────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    print(_isEditMode);
    return Consumer<TrnPlanningReceivedProvider>(
      builder: (ctx, prov, _) => Padding(
        padding: const EdgeInsets.all(8),
        child: Responsive.isMobile(context)
            ? (_showTableOnMobile
                  ? _buildTable(prov)
                  : _buildForm(context, prov))
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!_showTableOnMobile)
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          Flexible(
                            // 👈 instead of plain widget
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

  Widget _buildForm(BuildContext context, prov) {
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
              () => _erpFormKey.currentState?.focusField('scanValue'),
            );

          case 'scanValue':
            _entryVals[key] = value.toString();
          default:
            _entryVals[key] = value.toString();
        }
      },

      onFieldSubmitted: (key, value) async {
        if (key != 'scanValue') return;

        final scanVal = value.toString().trim();
        if (scanVal.isEmpty) return;
        if (_fromCrId == null) return;
        setState(() => _filteredBCode = scanVal);
        _isBCodePending = true;
        _onBCodeScanned(scanVal);
      },
      onExit: () => context.read<TabProvider>().closeCurrentTab(),
      onCancel: _resetForm,
      onSave: (val) async {
        final prov = context.read<TrnPlanningReceivedProvider>();

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
        final merged = Map<String, dynamic>.from(val)
          ..['Stime'] = DateFormat('hh:mm a').format(DateTime.now())
          ..['Sdate'] = DateFormat('yyyy-MM-dd').format(DateTime.now())
          ..['spkDeptIssDate'] = toIso(val['spkDeptIssDate']?.toString())
          ..['fromCrID'] = _fromCrId?.toString() ?? ''
          ..['toCrID'] = _toCrId?.toString() ?? ''
          ..['deptCode'] = toDeptCode?.toString() ?? '';

        final rows = prov.planningDetList.map((e) {
          return PlanningReceivedDetModel(
            jno: e.jno,
            jnoRecPc: e.jnoRecPc,
            bCode: e.bCode,
            pktNo: e.pktNo,
            cutNo: e.cutNo,
            clvCut: e.clvCut,
            shapeCode: e.shapeCode,
            purityCode: e.purityCode,
            colorCode: e.colorCode,
            diam: e.diam,
            kachaRec: e.kachaRec ?? 'Y',
            fromDeptCode: _fromDeptCode,
            toDeptCode: _toDeptCodeVal,
            fromCrId: _fromCrId,
            toCrId: _toCrId,
            deptCode: _toDeptCodeVal,
            deptProcessCode: int.tryParse(_formValues['deptProcessCode'] ?? ''),
            charniCode: int.tryParse(_formValues['charniCode'] ?? ''),
            tensionsCode: int.tryParse(_formValues['tensionsCode'] ?? ''),
            pc: e.pc,
            wt: e.wt,
            issPc: e.issPc,
            issWt: e.issWt,
            recPc: e.recPc,
            recWt: e.recWt,
            totalPc: e.recPc,
            totalWt: e.recWt,
            dmWt: e.dmWt,
            dmPer: e.dmPer,
            kPc: e.kPc,
            kWt: e.kWt,
            brPc: e.brPc,
            brWt: e.brWt,
            lossPc: e.lossPc,
            lossWt: e.lossWt,
            topsPc: e.topsPc,
            topsWt: e.topsWt,
            employeeCode: e.employeeCode,
            signerCode: e.signerCode,
            remarksCode: e.remarksCode,
            dueDay: e.dueDay,
            entryType: 'B',
            formType: 'SPK',
            pktType: 'A',
            confRec: _autoRec,
            clvRec: 'S',
            confCrID: _toCrId,
          );
        }).toList();

        final scannedDetList = prov.scannedDetList.expand((e) {
          final sarinList = e.sarinData ?? <Map<String, dynamic>>[];

          return sarinList.map((sarin) {
            return SpkPlanningSaveModel(
              spkDeptIssMstID: e.spkDeptIssMstID ?? 0,

              bCode: e.bCode ?? '',

              pktNo: int.tryParse(e.pktNo ?? '0') ?? 0,

              cutNo: e.cutNo ?? '',

              clvCut: e.clvCut ?? '',

              shapeCode: e.shapeCode ?? 0,

              cutCode: e.cutCode ?? 0,

              purityCode: e.purityCode ?? 0,

              colorCode: e.colorCode ?? 0,

              // SARIN RECORD
              rgWt: ((sarin['RoughWt'] ?? 0) as num).toDouble(),

              poWt: ((sarin['PolishWT'] ?? 0) as num).toDouble(),

              poPer: ((sarin['PolishPer'] ?? 0) as num).toDouble(),

              optName: sarin['operatorName']?.toString(),

              disc: ((sarin['DISC'] ?? 0) as num).toDouble(),

              rate: ((sarin['Rate'] ?? 0) as num).toDouble(),

              amt: ((sarin['AMT'] ?? 0) as num).toDouble(),

              netAmt: ((sarin['AMT'] ?? 0) as num).toDouble(),

              ratio: ((sarin['Ration'] ?? 0) as num).toDouble(),

              length: ((sarin['LENGTH'] ?? 0) as num).toDouble(),

              width: ((sarin['WIDTH'] ?? 0) as num).toDouble(),

              height: ((sarin['HEIGHT'] ?? 0) as num).toDouble(),

              heightPer: ((sarin['HEIGHTPER'] ?? 0) as num).toDouble(),

              tDepth: ((sarin['TABPER'] ?? 0) as num).toDouble(),

              // OTHER
              fluoCode: e.fluo ?? 0,

              rateRs: e.rateRs ?? 0,

              amountRs: e.amountRs ?? 0,

              partName: (e.partName ?? 0).toDouble(),

              topsPc: e.topsPc ?? 0,

              topsWt: e.topsWt ?? 0,

              piePc: e.brPc ?? 0,

              lsPc: e.lossPc ?? 0,

              remarks: e.remarks ?? '',
            );
          });
        }).toList();

       if(rows.isNotEmpty && scannedDetList.isNotEmpty){
         final success = await prov.savePlanningDetails(
           merged,
           rows,
           scannedDetList,
         );

         if (rows.isEmpty) {
           ErpResultDialog.showError(
             context: context,
             theme: _theme,
             title: 'Planning',
             message: 'No planning rows found',
           );

           return;
         }

         if (!mounted) return;

         if (success) {
           ErpResultDialog.showSuccess(
             context: context,
             theme: _theme,
             title: 'Planning',
             message: 'Planning saved successfully',
           );

           prov.clearScannedDetList();
         }

         await prov.load();
       }else {
         await ErpResultDialog.showError(
           context: context,
           theme: _theme,
           title: 'No Entries',
           message: 'Please add at least one entry.',
         );
       }
      },
      onDelete: _isEditMode ? _onDelete : null,
      onSearch: () => setState(() => _showTableOnMobile = true),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  MASTER TABLE WIDGET
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildTable(TrnPlanningReceivedProvider prov) {
    final counterProv = context.read<CounterProvider>();
    final procProv = context.read<DeptProcessProvider>();

    final data = prov.list.where((e) => e.formType == 'PLANNINGREC').map((e) {
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

      return e.toTableRow()
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

  Widget _buildTableDefaultData(TrnPlanningReceivedProvider prov) {
    final data = prov.planningDetList.asMap().entries.map((entry) {
      final index = entry.key;

      final r = entry.value;

      return {
        // AUTO SR NO
        'Srno': '${index + 1}',

        'BCode': r.bCode?.toString() ?? '',

        'PktNo': r.pktNo?.toString() ?? '',

        'CutNo': r.cutNo?.toString() ?? '',

        'Pc': r.pc?.toString() ?? '0',

        'Wt': fThreeDecimal(r.wt ?? 0),

        'IssPc': r.issPc ?? r.pc?.toString() ?? '0',

        'IssWt': fThreeDecimal(r.issWt ?? r.wt ?? 0),

        'RecPc': r.recPc ?? r.pc?.toString() ?? '0',

        'RecWt': fThreeDecimal(r.recWt ?? r.wt ?? 0),

        'DmWt': fThreeDecimal(r.dmWt ?? 0),

        'DmPer': (r.dmPer ?? 0).toStringAsFixed(2),

        'Employee': _employeeNameFor(r.employeeCode).isEmpty
            ? '-'
            : _employeeNameFor(r.employeeCode),

        'Signer': _signerNameFor(r.signerCode).isEmpty
            ? '-'
            : _signerNameFor(r.signerCode),

        'CheckerMan': '-',

        'SignerMan': '-',
      };
    }).toList();

    Future<void> _onRowTap(Map<String, dynamic> row) async {
      print(row);
      setState(() {
        _selectedRow = row;
        _highlightedBCode = row['BCode'];
      });
      final rowIndex = prov.planningDetList.indexWhere(
        (e) => e.bCode == row['BCode'],
      );
      await _showDeletePopup(context, rowIndex);
    }

    return ErpDataTable(
      isReportRow: false,
      token: token ?? '',
      url: baseUrl,
      title: 'PLANNING RECEIVED LIST',

      columns: _columnLabels,

      data: data,

      showHeader: false,
      showSearch: false,

      selectedRow: _selectedRow,

      onRowTap: (val) => _onRowTap(val),

      emptyMessage: prov.isLoaded ? 'No entries found' : 'Loading...',
    );
  }

  Future<void> _showDeletePopup(BuildContext context, int rowIndex) async {
    final isYes = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Delete Confirmation'),
          content: Text('Are You Sure You Want To Delete?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (isYes != true) return;

    /// API CALL
    final success = await context.read<TrnPlanningReceivedProvider>().delete(
      spkDeptIssMstId: _selectedMst!.spkDeptIssMstID!,
      bcode: _highlightedBCode,
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
    if (!mounted) return;
  }

  Widget _buildTableByBarCodeData(TrnPlanningReceivedProvider prov) {
    final List<Map<String, dynamic>> data = [];
    // sarinData lives on PlanningReceivedDetModel from the scan response
    if (prov.scannedDetList.isNotEmpty) {
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
      isAllowHighlight: true,
      // ← enable highlight
      highlightKey: 'bCode',
      // ← match by bCode field
      highlightValue: _highlightedBCode,
      // ← NEW param
      onRowTap: (val) => {},
      emptyMessage: prov.isLoaded
          ? 'Planning received data not found'
          : 'Loading...',
    );
  }

  Map<String, dynamic> _buildDetSarinRow({
    required PlanningReceivedDetModel det,
    required Map<String, dynamic>? sarin,
  }) {
    return {
      // ── Sarin fields ────────────────────────────────────────────────────
      'sarinPolID': sarin?['SarinPolID']?.toString() ?? '',
      'bCode': sarin?['BCode']?.toString() ?? '',
      'stoneID': sarin?['StoneID']?.toString() ?? '',
      'polishWT': sarin?['PolishWT']?.toString() ?? '',
      'polishPer': sarin?['PolishPer']?.toString() ?? '',
      'shape': sarin?['SHAPE']?.toString() ?? '',
      'cut': sarin?['CUT']?.toString() ?? '',
      'color': sarin?['Color']?.toString() ?? '',
      'clarity': sarin?['Clarity']?.toString() ?? '',
      'tWT': sarin?['TWT']?.toString() ?? '',
      'rate': sarin?['Rate']?.toString() ?? '',
      'amt': sarin?['AMT']?.toString() ?? '',
      'lotCode': sarin?['LotCode']?.toString() ?? '',
      'kapanNo': sarin?['KapanNo']?.toString() ?? '',
      'srNum': (sarin?['SrNum'] ?? '').toString().trim(),
      'crownHeight': (sarin?['CrownHeight'] ?? '').toString().trim(),
      'operatorName': sarin?['operatorName']?.toString() ?? '',
      'tHmm': sarin?['THmm']?.toString() ?? '',
      'disc': sarin?['DISC']?.toString() ?? '',
      'rec': sarin?['Rec']?.toString() ?? '',
    };
  }
}
