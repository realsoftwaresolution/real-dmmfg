import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:diam_mfg/models/factory_issue_entry_model.dart';
import 'package:diam_mfg/providers/charni_provider.dart';
import 'package:diam_mfg/providers/counter_manager_det_provider.dart';
import 'package:diam_mfg/providers/counter_provider.dart';
import 'package:diam_mfg/providers/cut_provider.dart';
import 'package:diam_mfg/providers/dept_provider.dart';
import 'package:diam_mfg/providers/dept_group_provider.dart';
import 'package:diam_mfg/providers/dept_process_provider.dart';
import 'package:diam_mfg/providers/employee_provider.dart';
import 'package:diam_mfg/providers/factory_provider.dart';
import 'package:diam_mfg/providers/remarks_provider.dart';
import 'package:diam_mfg/providers/tensions_provider.dart';
import 'package:diam_mfg/utils/app_images.dart';
import 'package:diam_mfg/utils/constants.dart';
import 'package:diam_mfg/utils/delete_dialogue.dart';
import 'package:diam_mfg/utils/msg_dialogue.dart';
import 'package:erp_data_table/erp_data_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rs_dashboard/rs_dashboard.dart';
import '../models/user_visibility_model.dart';
import '../providers/auth_provider.dart';
import '../providers/counter_display_det_provider.dart';
import '../providers/factory_issue_entry_provider.dart';
import '../providers/purity_provider.dart';
import '../providers/shape_provider.dart';
import '../providers/user_visibility_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  HELPERS
// ─────────────────────────────────────────────────────────────────────────────

String _f3(double? v) => v == null ? '0.000' : v.toStringAsFixed(3);

// ─────────────────────────────────────────────────────────────────────────────
//  WIDGET
// ─────────────────────────────────────────────────────────────────────────────

class TrnFactoryIssueEntry extends StatefulWidget {
  const TrnFactoryIssueEntry({super.key});

  @override
  State<TrnFactoryIssueEntry> createState() => _TrnFactoryIssueEntryState();
}

// ─────────────────────────────────────────────────────────────────────────────
//  STATE
// ─────────────────────────────────────────────────────────────────────────────

class _TrnFactoryIssueEntryState extends State<TrnFactoryIssueEntry> {
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
  List<FactoryIssueDetModel> _detRows = [];
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.wait([
        context.read<FactoryIssueEntryProvider>().load(),
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
        context.read<FactoryProvider>().loadFactories(),
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
      'date': DateFormat('dd/MM/yyyy').format(now),
      'jno': '0',
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

    if (_fromDisplayFields.isNotEmpty) {
      debugPrint('FROM → ${_fromDisplayFields.first.userVisibilityName}');
    }
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

    if (_toDisplayFields.isNotEmpty) {
      debugPrint('TO → ${_toDisplayFields.first.userVisibilityName}');
    }
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

  // ─────────────────────────────────────────────────────────────────────────
  //  BCODE SCAN
  // ─────────────────────────────────────────────────────────────────────────
  void _focusScan() {
    _erpFormKey.currentState?.focusField('scanValue');
  }

  Future<void> _onBCodeScanned(String bCode) async {
    if (_isBCodePending) return;
    _isBCodePending = true;

    final rows = await context
        .read<FactoryIssueEntryProvider>()
        .fetchByBCode(bCode: bCode);

    if (!mounted) return;

    _isBCodePending = false;

    if (rows.isEmpty) {
      _showSnack('BCode "$bCode" not found!');
      _focusScan();
      return;
    }

    final r = rows.first;

    // ✅ Duplicate check
    final exists = _detRows.any(
          (e) => e.bCode?.toString() == r.bCode?.toString(),
    );

    if (exists) {
      _showSnack('BCode already exists!');
      _focusScan();
      return;
    }

    final newRow = FactoryIssueDetModel(
      srno: _detRows.length + 1,

      bCode: r.bCode?.toString() ?? '',
      pktNo: r.pktNo ?? '',
      PacketMstID:r.PacketMstID,
      cutNo: r.cutNo ?? '',
      pc: r.pc ?? 0,
      wt: r.wt ?? 0,

      issPc: r.pc ?? 0,
      issWt: r.wt ?? 0,

      dmWt: r.dmWt ?? 0,
      dmPer: r.dmPer ?? 0,

      purityCode: r.purityCode,
      colorCode: r.colorCode,
      diam: r.diam ?? 0,

      // ✅ IMPORTANT (for GHAT WT)
      lossWt: r.wt ?? 0,

      fromCrId: _fromCrId,
      toCrId: _toCrId,

      entryType: 'I',
      formType: 'FACTORY ISSUE',
    );
print(jsonEncode(newRow));
    _detRows.add(newRow);
    _syncDetGrid();

    setState(() {}); // ✅ FORCE UI REFRESH

    // clear + refocus
    _erpFormKey.currentState?.updateFieldValue('scanValue', '');
    Future.delayed(const Duration(milliseconds: 50), _focusScan);
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
    set('scanValue', r.bCode);
  }

  dynamic _deleteDetRow(int idx) async {
    final confirm = await ErpDeleteDialog.show(
      context: context,
      theme: _theme,
      title: 'Factory Issue',
      itemName: 'ID: ${_detRows[idx].spkDeptIssDetID?.toString()}',
    );
    if (confirm != true || !mounted) return;

    final success = await context.read<FactoryIssueEntryProvider>().deleteRow(
      _detRows[idx].spkDeptIssMstID?.toString(),
      _detRows[idx].spkDeptIssDetID?.toString(),
      _detRows[idx].bCode,
    );

    if (success && mounted) {
      setState(() {
        _detRows.removeAt(idx);
        // Re-number srno
        _detRows = _detRows.asMap().entries.map((e) {
          final v = e.value;
          return FactoryIssueDetModel(
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
          );
        }).toList();

        _syncDetGrid();
        if (_editingDetIndex == idx) _editingDetIndex = null;
      });
      await ErpResultDialog.showDeleted(
        context: context,
        theme: _theme,
        itemName: '1 row(s) deleted successfully',
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  SYNC DET GRID
  // ─────────────────────────────────────────────────────────────────────────

  void _syncDetGrid() {
    _activeDetColumns = [
      'srno',
      'cutNo',        // Mfg Cut
      'qrCode',
      'bCode',
      'pktNo',
      'pc',
      'wt',
      'issPc',
      'issWt',
      'ghatWt',       // custom (lossWt or calculated)
      'purityCode',
      'charniCode',
      'colorCode',
      'dmWt',
      'dmPer',
      'size',         // optional (if available)
      'diam',
      'length',
    ];

    _detDisplay = _detRows.map((r) => {
      'srno': r.srno?.toString() ?? '',

      'cutNo': r.cutNo ?? '',

      'qrCode': '',

      'bCode': r.bCode ?? '',
      'pktNo': r.pktNo ?? '',

      'pc': (r.pc ?? 0).toString(),
      'wt': _f3(r.wt ?? 0),

      'issPc': (r.issPc ?? r.pc ?? 0).toString(),
      'issWt': _f3(r.issWt ?? r.wt ?? 0),

      'ghatWt': _f3(r.lossWt ?? 0),

      'purityCode': _purityNameFor(r.purityCode),

      'charniCode': r.charniCode?.toString() ?? '',

      'colorCode': r.colorCode?.toString() ?? '',

      'dmWt': _f3(r.dmWt ?? 0),
      'dmPer': (r.dmPer ?? 0).toStringAsFixed(2),

      'size': '',

      'diam': (r.diam ?? 0).toString(),
      'length': (r.length ?? 0).toString(),
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
    print(row);

    final prov = context.read<FactoryIssueEntryProvider>();
    final id = int.tryParse(row['factoryIssMstID'].toString()) ?? 0;

    final details = await prov.loadDetails(id);
    if (!mounted) return;

    setState(() {
      _selectedRow = row;
      _isEditMode = true;
      _detRows = details;
      _editingDetIndex = null;
      _isAdding = false;
      _showTableOnMobile = false;
print(jsonEncode(_detRows));
      // ✅ SINGLE SOURCE OF TRUTH
      _formValues = {
        'jno': _s(row['jno']),
        'factoryIssMstID': _s(row['factoryIssMstID'], '0'),
        'factoryIssDetID': _s(row['factoryIssDetID'], '0'),
        'scanValue': _s(row['BCode'], '0'),

        'date': _date(row['date']),
        'time': _s(row['time']),

        'entry': _s(row['entry']),
        'type': _s(row['type']),

        'dueDay': _s(row['dueDay']),
        'dueDayCount': _date(row['dueDate']),

        'factory': _s(row['factoryCode']),
      };

      _syncDetGrid();
    });

    _rebuildForm();
  }
  // ─────────────────────────────────────────────────────────────────────────
  //  SAVE
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _onSave(Map<String, dynamic> values) async {
    final prov = context.read<FactoryIssueEntryProvider>();
    // ✅ MASTER PAYLOAD
    final payload = {
      "FactoryIssDate": toUtcIso(_formValues['date']),
      "SelectType": "SPK",
      "DueDay": int.tryParse(_formValues['dueDay'] ?? '0') ?? 0,
      "DueDate": toUtcIso(_formValues['dueDayCount']),
      "FactoryCode": int.tryParse(_formValues['factory'] ?? '0') ?? 0,
      "FactoryType": _formValues['type'] ?? '',
      "EntryType": _formValues['entry'],
      "Sflag": "A",
      "Sdate": DateTime.now().toUtc().toIso8601String(),
      "LogID": 1,
      "PcID": "PC-01",
      "Ever": 1,

      // ✅ DETAILS
      "details": _detRows.map((r) {
        return {
          "CutNo": r.cutNo ?? '',
          "BCode": int.tryParse(r.bCode ?? '0') ?? 0,
          "PacketMstID": r.PacketMstID ?? 0,
          "MfgCut": r.cutNo ?? '',

          "OrgPc": r.pc ?? 0,
          "OrgWt": r.wt ?? 0,

          "IssPc": r.issPc ?? r.pc ?? 0,
          "IssWt": r.issWt ?? r.wt ?? 0,

          "GhatWt": r.lossWt ?? 0,
          "ColorCode": r.colorCode?.toString() ?? '0',

          "DmWt": r.dmWt ?? 0,
          "DmPer": r.dmPer ?? 0,

          "RateID": "R1",
          "Rateon": "WT",
          "Rate": 0,
          "Amount": 0,

          "Diam": r.diam ?? 0,
        };
      }).toList(),
    };

    // 🔍 DEBUG (VERY IMPORTANT)
    print("FINAL PAYLOAD: $payload");
    bool success = await prov.create(payload);
    if (!mounted) return;
    if (success) {
      final wasEdit = _isEditMode;
      _resetForm();
      await ErpResultDialog.showSuccess(
        context: context, theme: _theme,
        title:   wasEdit ? 'Updated' : 'Saved',
        message: wasEdit ? 'Factory Issue Entry updated.' : 'Factory Issue Entry saved.',
      );
    }
  }
  // ─────────────────────────────────────────────────────────────────────────
  //  DELETE
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _onDelete() async {
    if (_formValues['factoryIssMstID'] == null) return;

    final confirm = await ErpDeleteDialog.show(
      context: context,
      theme: _theme,
      title: 'Factory Issue',
      itemName: 'ID: ${_formValues['factoryIssMstID'].toString()}',
    );
    if (confirm != true || !mounted) return;

    final success = await context.read<FactoryIssueEntryProvider>().delete(
      _formValues['factoryIssMstID'].toString(),
    );

    if (success && mounted) {
      final id = _formValues['factoryIssMstID'].toString();
      _resetForm();
      await ErpResultDialog.showDeleted(
        context: context,
        theme: _theme,
        itemName: 'Factory Issue $id',
      );
    }
  }

  Future<void> _onDeleteRow() async {


  }

  // ─────────────────────────────────────────────────────────────────────────
  //  RESET
  // ─────────────────────────────────────────────────────────────────────────

  void _resetForm() {
    _erpFormKey.currentState?.resetForm();
    _entryVals.clear();
    setState(() {
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
  void _calcDueDate() {
    final dueDay = int.tryParse(_formValues['dueDay'] ?? '') ?? 0;

    if (dueDay > 0) {
      final today = DateTime.now();
      final dueDate = today.add(Duration(days: dueDay));

      final formatted = DateFormat('dd/MM/yyyy').format(dueDate);

      _formValues['dueDayCount'] = formatted;

      _erpFormKey.currentState?.updateFieldValue(
        'dueDayCount',
        formatted,
      );
    } else {
      _formValues['dueDayCount'] = '';
      _erpFormKey.currentState?.updateFieldValue('dueDayCount', '');
    }
  }
  List<List<ErpFieldConfig>> _buildFormRows() {
    final factoryProv = context.read<FactoryProvider>();

    // factoryDropdown
    final factoryItems = factoryProv.factories.where((e) => e.active == true).toList();
    final factoryDropdown = factoryItems
        .map(
          (e) => ErpDropdownItem(
        label: e.factoryName ?? '',
        value: e.factoryCode?.toString() ?? '',
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
          key: 'entry',
          label: 'ENTRY',
          type: ErpFieldType.dropdown,
          dropdownItems:  [
        ErpDropdownItem(label: 'SPK', value: 'SPK'),
        ErpDropdownItem(label: 'GENERAL', value: 'GENERAL'),
      ],
          sectionIndex: 0,
        ),
        ErpFieldConfig(
          key: 'dueDay',
          label: 'DUE DAY',
          type: ErpFieldType.number,
          sectionIndex: 0,
        ),
        ErpFieldConfig(
          key: 'dueDayCount',
          label: '',
          type: ErpFieldType.date,
          sectionIndex: 0,
          readOnly: true,
        ),
        ErpFieldConfig(
          key: 'date',
          label: 'DATE',
          type: ErpFieldType.date,
          readOnly: true,
          sectionIndex: 0,
        ),
        ErpFieldConfig(
          key: 'jno',
          label: 'JNO',
          type: ErpFieldType.number,
          readOnly: true,
          sectionIndex: 0,
        ),
      ],

      [
        ErpFieldConfig(
          key: 'factory',
          label: 'FACTORY',
          type: ErpFieldType.dropdown,
          dropdownItems: factoryDropdown,
          sectionIndex: 1,
          width: 500
        ),
        ErpFieldConfig(
          key: 'type',
          label: 'FACTORY TYPE',
          type: ErpFieldType.text,
          readOnly: true,
          sectionIndex: 1,
          width: 250
        ),
      ],

      [
        ErpFieldConfig(
          key: 'scanValue',
          label: 'BCODE',
          type: ErpFieldType.text,
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
      key: 'jno',
      label: 'Jno',
      width: 70,
      required: true,
    ),
    ErpColumnConfig(
      key: 'date',
      label: 'DATE',
      width: 160,
      isDate: true,
    ),
    ErpColumnConfig(key: 'time', label: 'TIME', width: 140),
    ErpColumnConfig(key: 'entry', label: 'ENTRY', width: 180),
    ErpColumnConfig(key: 'dueDay', label: 'DUE DAY', width: 180),
    ErpColumnConfig(key: 'dueDate', label: 'DUE DATE', width: 160),
    ErpColumnConfig(key: 'factory', label: 'FACTORY', width: 160),
    ErpColumnConfig(key: 'type', label: 'FACT TYPE', width: 150),
    ErpColumnConfig(key: 'totPkt', label: 'TOT PKT', width: 140),
    ErpColumnConfig(
      key: 'pc',
      label: 'PC',
      width: 140,
      align: ColumnAlign.right,
    ),
    ErpColumnConfig(
      key: 'wt',
      label: 'WT',
      width: 170,
      align: ColumnAlign.right,
    ),
    ErpColumnConfig(
      key: 'issPc',
      label: 'ISS PC',
      width: 170,
      align: ColumnAlign.right,
    ),
    ErpColumnConfig(
      key: 'issWt',
      label: 'ISS WT',
      width: 170,
      align: ColumnAlign.right,
    ),
    ErpColumnConfig(
      key: 'dmWt',
      label: 'DM WT',
      width: 170,
      align: ColumnAlign.right,
    ),
    ErpColumnConfig(
      key: 'dmPer',
      label: 'DM PER',
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
      'cutNo': 'MFG CUT',
      'qrCode': 'QRCODE',
      'bCode': 'BCODE',
      'pktNo': 'PKT NO',
      'pc': 'PC',
      'wt': 'WT',
      'issPc': 'ISS PC',
      'issWt': 'ISS WT',
      'ghatWt': 'GHAT WT',
      'purityCode': 'PURITY',
      'charniCode': 'CHARNI',
      'colorCode': 'COLOR',
      'dmWt': 'DM WT',
      'dmPer': 'DM PER',
      'size': 'SIZE',
      'diam': 'DIAM',
      'length': 'LENGTH',
    };
    return labels[key] ?? key;
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Consumer<FactoryIssueEntryProvider>(
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
      title: 'FACTORY ISSUE ENTRY',
      tabBarBackgroundColor: const Color(0xfff2f0ef),
      tabBarSelectedColor: _theme.primaryGradient.first,
      tabBarSelectedTxtColor: Colors.white,
      rows: _buildFormRows(),
      initialValues: _formValues,
      isEditMode: _isEditMode,
      onFieldChanged: (key, value) {
        _formValues[key] = value.toString();
        debugPrint('onFieldChanged: $key');

        switch (key) {
          case 'entry':
            _entryVals[key] = value.toString();
            Future.delayed(
              const Duration(milliseconds: 50),
                  () => _erpFormKey.currentState?.focusField('dueDay'),
            );

          case 'dueDay':
            _formValues[key] = value.toString();
            _calcDueDate();
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

          default:
            _entryVals[key] = value.toString();
        }
      },

      onFieldSubmitted: (key, value) {
        if (key != 'scanValue') return;

        final scanVal = value.toString().trim();
        if (scanVal.isEmpty) return;

        _onBCodeScanned(scanVal);
      },

      onExit: () => context.read<TabProvider>().closeCurrentTab(),
      onSave: _onSave,
      isShowSaveButton: !_isEditMode,
      onCancel: _resetForm,
      onDelete: _isEditMode ? _onDelete : null,
      onSearch: () => setState(() => _showTableOnMobile = true),

      detailBuilder: (ctx) {
        final t = ctx.erpTheme;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_detRows.isNotEmpty)
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
                  'pc': TextAlign.right,
                  'wt': TextAlign.right,
                  'issPc': TextAlign.right,
                  'issWt': TextAlign.right,
                  'ghatWt': TextAlign.right,
                  'dmWt': TextAlign.right,
                  'dmPer': TextAlign.right,
                  'diam': TextAlign.right,
                  'length': TextAlign.right,
                  'size': TextAlign.right,
                  'purityCode': TextAlign.right,
                  'colorCode': TextAlign.right,
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
    double sumDouble(double Function(FactoryIssueDetModel) fn) =>
        _detRows.fold(0.0, (s, r) => s + fn(r));

    int sumInt(int Function(FactoryIssueDetModel) fn) =>
        _detRows.fold(0, (s, r) => s + fn(r));

    final totPc = sumInt((r) => r.pc ?? 0);
    final totWt = sumDouble((r) => r.wt ?? 0);

    final totIssPc = sumInt((r) => r.issPc ?? 0);
    final totIssWt = sumDouble((r) => r.issWt ?? 0);

    final totGhatWt = sumDouble((r) => r.lossWt ?? 0); // 👈 GHAT WT

    final totDmWt = sumDouble((r) => r.dmWt ?? 0);

    final baseWt = totWt > 0 ? totWt : totIssWt;

    final dmPer = baseWt > 0
        ? (totDmWt / baseWt * 100)
        : 0;

    final avgSize = _detRows.isNotEmpty
        ? sumDouble((r) => (r.diam ?? 0)) / _detRows.length
        : 0;

    return {
      'srno': 'Tot...',
      'pc': '$totPc',
      'wt': _f3(totWt),
      'issPc': '$totIssPc',
      'issWt': _f3(totIssWt),
      'ghatWt': _f3(totGhatWt),
      'dmWt': _f3(totDmWt),
      'dmPer': dmPer.toStringAsFixed(2),
      'size': avgSize.toStringAsFixed(2),
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
  Widget _buildTable(FactoryIssueEntryProvider prov) {
    final data = prov.list.map((e) {
      return {
        // ✅ JNO (if not available keep empty)
        'jno': e.jno,
        'factoryIssMstID': e.factoryIssMstID,

        // ✅ DATE (convert ISO → UI format)
        'date': _formatDate(e.factoryIssDate),

        // ✅ TIME
        'time': e.time ?? '',

        // ✅ ENTRY
        'entry': e.selectType ?? '',

        // ✅ DUE DAY
        'dueDay': (e.dueDay ?? 0).toString(),

        // ✅ DUE DATE
        'dueDate': _formatDate(e.dueDate),

        // ✅ FACTORY
        'factory': e.factoryName ?? '',
        'factoryCode': e.factoryCode ?? '',

        // ✅ FACT TYPE
        'type': e.factoryType ?? '',

        // ✅ TOTAL PKT
        'totPkt': (e.pkt ?? 0).toString(),

        // ✅ PC
        'pc': (e.pc ?? 0).toString(),

        // ✅ WT
        'wt': _f3(e.wt ?? 0),

        // ✅ ISS PC
        'issPc': (e.issPc ?? 0).toString(),

        // ✅ ISS WT
        'issWt': _f3(e.issWt ?? 0),

        // ✅ DM WT
        'dmWt': _f3(e.dmWt ?? 0),

        // ✅ DM PER
        'dmPer': (e.dmPer ?? 0).toStringAsFixed(2),
      };
    }).toList();

    return ErpDataTable(
      isReportRow: false,
      token: token ?? '',
      url: '',
      title: 'FACTORY ISSUE ENTRY LIST',
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
}
