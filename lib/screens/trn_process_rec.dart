import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:diam_mfg/models/process_Rec_model.dart';
import 'package:diam_mfg/providers/counter_manager_det_provider.dart';
import 'package:diam_mfg/providers/counter_provider.dart';
import 'package:diam_mfg/providers/dept_provider.dart';
import 'package:diam_mfg/providers/dept_group_provider.dart';
import 'package:diam_mfg/providers/dept_process_provider.dart';
import 'package:diam_mfg/providers/employee_provider.dart';
import 'package:diam_mfg/providers/factory_provider.dart';
import 'package:diam_mfg/providers/trn_process_rec_provider.dart';
import 'package:diam_mfg/utils/app_images.dart';
import 'package:diam_mfg/utils/constants.dart';
import 'package:diam_mfg/utils/delete_dialogue.dart';
import 'package:diam_mfg/utils/msg_dialogue.dart';
import 'package:erp_data_table/erp_data_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rs_dashboard/rs_dashboard.dart';
import '../providers/auth_provider.dart';
import '../providers/purity_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  WIDGET
// ─────────────────────────────────────────────────────────────────────────────

class TrnProcessRecEntry extends StatefulWidget {
  const TrnProcessRecEntry({super.key});

  @override
  State<TrnProcessRecEntry> createState() => _TrnProcessRecEntryState();
}

// ─────────────────────────────────────────────────────────────────────────────
//  STATE
// ─────────────────────────────────────────────────────────────────────────────

class _TrnProcessRecEntryState extends State<TrnProcessRecEntry> {
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
  bool _isBCodePending = false;

  // ── From / To counter ─────────────────────────────────────────────────────
  int? _fromCrId;

  int? _toCrId;

  // ── Detail rows ────────────────────────────────────────────────────────────
  List<ProcessRecDetModel> _detRows = [];
  List<Map<String, dynamic>> _detDisplay = [];
  List<String> _activeDetColumns = [];
  int? _editingDetIndex;

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
        context.read<ProcessRecEntryProvider>().load(),
        context.read<CounterProvider>().load(),
        context.read<CounterManagerDetProvider>().load(),
        context.read<DeptProvider>().load(),
        context.read<DeptGroupProvider>().load(),
        context.read<DeptProcessProvider>().load(),
        context.read<EmployeeProvider>().loadEmployees(),
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
    _formValues = {'date': DateFormat('dd/MM/yyyy').format(now), 'jno': '0'};
    if (mounted) setState(() {});
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  LOAD DISPLAY FIELDS
  // ─────────────────────────────────────────────────────────────────────────

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
        _formValues['fromCrId'] = crIdStr;
        _formValues['fromDept'] = deptName;
      });

      _erpFormKey.currentState?.updateFieldValue('fromDept', deptName);
      _erpFormKey.currentState?.updateFieldValue('toCrId', '');
      _erpFormKey.currentState?.updateFieldValue('toDept', '');
      _erpFormKey.currentState?.updateFieldValue('deptProcessCode', '');
      _erpFormKey.currentState?.updateFieldValue('deptName', '');
    } catch (_) {}
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  BCODE SCAN
  // ─────────────────────────────────────────────────────────────────────────
  void _focusScan() {
    _erpFormKey.currentState?.focusField('scanValue');
  }

  Future<void> _onBCodeScanned(String bCode) async {
    if (_toCrId == null) {
      _showSnack('Please select a manager first!');
      _erpFormKey.currentState?.updateFieldValue('scanValue', '');
      _focusScan();
      return;
    }

    final cleanedBCode = bCode.trim();

    // Check duplicate in grid before API call
    final exists = _detRows.any((e) => e.bCode?.toString() == cleanedBCode);

    if (exists) {
      _showSnack('BCode already exists!');
      _erpFormKey.currentState?.updateFieldValue('scanValue', '');
      _focusScan();
      return;
    }

    if (_isBCodePending) return;
    _isBCodePending = true;

    final rows = await context.read<ProcessRecEntryProvider>().fetchByBCode(
      bCode: cleanedBCode,
      toCrId: _toCrId,
    );

    if (!mounted) return;

    _isBCodePending = false;

    if (rows.isEmpty) {
      _showSnack('BCode "$cleanedBCode" not found!');
      _focusScan();
      return;
    }

    final r = rows.first;

    final newRow = ProcessRecDetModel(
      srno: _detRows.length + 1,
      id: r.id,
      jno: r.jno,
      spkDeptIssDetID: r.spkDeptIssDetID,
      spkDeptIssMstID: r.spkDeptIssMstID,

      bCode: r.bCode?.toString() ?? '',
      pktNo: r.pktNo ?? '',
      PacketMstID: r.PacketMstID,
      cutNo: r.cutNo ?? '',
      clvCut: r.clvCut ?? '',
      pc: r.pc ?? 0,
      wt: r.wt ?? 0,

      issPc: r.issPc ?? r.pc ?? 0,
      issWt: r.issWt ?? r.wt ?? 0,

      dmWt: r.dmWt ?? 0,
      dmPer: r.dmPer ?? 0,

      purityCode: r.purityCode,
      colorCode: r.colorCode,
      diam: r.diam ?? 0,

      // ✅ IMPORTANT (for GHAT WT)
      lossWt: r.lossWt ?? r.wt ?? 0,

      fromCrId: _fromCrId,
      toCrId: _toCrId,

      entryType: r.entryType ?? 'I',
      formType: 'PROCESS REC',
      remarks: r.remarks,
      topsPc: r.topsPc,
      qrCode: r.qrCode,
      charniCode: r.charniCode,
      shapeCode: r.shapeCode,
      cutCode: r.cutCode,
      size: r.size,
      length: r.length,
      repairing: r.repairing,
      employeeCode: r.employeeCode,
      deptCode: r.deptCode,
      deptProcessCode: r.deptProcessCode,
      tensionsCode: r.tensionsCode,
      signerCode: r.signerCode,
      remarksCode: r.remarksCode,
      dueDay: r.dueDay,
    );
    _detRows.add(newRow);
    _syncDetGrid();

    setState(() {}); // ✅ FORCE UI REFRESH

    // clear + refocus
    _erpFormKey.currentState?.updateFieldValue('scanValue', '');
    Future.delayed(const Duration(milliseconds: 50), _focusScan);
  }

  // ─────────────────────────────────────────────────────────────────────────
  //    DELETE DET ROW
  // ─────────────────────────────────────────────────────────────────────────
  dynamic _deleteDetRow(int idx) async {
    final row = _detRows[idx];
    final isSavedRecord = _isEditMode && (row.id != null && row.id != 0);

    final confirm = await ErpDeleteDialog.show(
      context: context,
      theme: _theme,
      title: 'Process Issue',
      itemName: isSavedRecord ? 'ID: ${row.id}' : 'BCode: ${row.bCode}',
    );
    if (confirm != true || !mounted) return;

    bool success = true;
    if (isSavedRecord) {
      success = await context.read<ProcessRecEntryProvider>().deleteRow(
        (row.spkProcessRecMstID)?.toString(),
      );
    }

    if (success && mounted) {
      setState(() {
        _detRows.removeAt(idx);
        // Re-number srno
        _detRows = _detRows.asMap().entries.map((e) {
          final v = e.value;
          return ProcessRecDetModel(
            srno: e.key + 1,
            spkDeptIssMstID: v.spkDeptIssMstID,
            spkDeptIssDetID: v.spkDeptIssDetID,
            spkProcessRecMstID: v.spkProcessRecMstID,
            PacketMstID: v.PacketMstID,
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
      'cutNo', // Mfg Cut
      'qrCode',
      'bCode',
      'pktNo',
      'pc',
      'wt',
      'issPc',
      'issWt',
      'ghatWt', // custom (lossWt or calculated)
      'dmWt',
      'dmPer',
      'size', // optional (if available)
      'diam',
      'length',
    ];

    _detDisplay = _detRows
        .map(
          (r) => {
            'srno': r.srno?.toString() ?? '',

            'cutNo': r.cutNo ?? '',

            'qrCode': r.qrCode ?? '',

            'bCode': r.bCode ?? '',
            'pktNo': r.pktNo ?? '',

            'pc': (r.pc ?? 0).toString(),
            'wt': fThreeDecimal(r.wt ?? 0),

            'issPc': (r.issPc ?? r.pc ?? 0).toString(),
            'issWt': fThreeDecimal(r.issWt ?? r.wt ?? 0),

            'ghatWt': fThreeDecimal(r.lossWt ?? 0),

            'purityCode': _purityNameFor(r.purityCode),

            'charniCode': r.charniCode?.toString() ?? '',

            'colorCode': r.colorCode?.toString() ?? '',

            'dmWt': fThreeDecimal(r.dmWt ?? 0),
            'dmPer': (r.dmPer ?? 0).toStringAsFixed(2),

            'size': r.size != null ? r.size.toString() : '',

            'diam': (r.diam ?? 0).toString(),
            'length': (r.length ?? 0).toString(),
            'shapeCode': r.shapeCode?.toString() ?? '',
            'cutCode': r.cutCode?.toString() ?? '',
            'tensionsCode': r.tensionsCode?.toString() ?? '',
            'signerCode': r.signerCode?.toString() ?? '',
            'remarksCode': r.remarksCode?.toString() ?? '',
            'dueDay': r.dueDay?.toString() ?? '',
            'topsPc': (r.topsPc ?? 0).toString(),
            'topsWt': fThreeDecimal(r.topsWt ?? 0),
            'totalPc': (r.totalPc ?? 0).toString(),
            'totalWt': fThreeDecimal(r.totalWt ?? 0),
            'repairing': r.repairing ?? 'N',
            'employeeCode': r.employeeCode?.toString() ?? '',
            'deptCode': r.deptCode?.toString() ?? '',
            'deptProcessCode': r.deptProcessCode?.toString() ?? '',
            'remarks': r.remarks ?? '',
          },
        )
        .toList();
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
    final prov = context.read<ProcessRecEntryProvider>();
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
      // ✅ SINGLE SOURCE OF TRUTH
      _formValues = {
        'jno': _s(row['jno']),
        'id': _s(row['spkProcessRecMstID'], '0'),
        'spkProcessRecMstID': _s(row['spkProcessRecMstID'], '0'),
        'sPKProcessRecDetID': _s(row['SPKProcessRecDetID'], '0'),
        'date': _date(row['date']),
        'manager': _s(row['crID']),
        'deptProcessCode': _s(row['deptProcessCode']),
        'deptName': _s(row['deptCode']),
        'employee': _s(row['employeeCode']),
        'time': _s(row['time']),
      };
      _toCrId = row['crID'];
      _syncDetGrid();
    });

    _rebuildForm();
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  SAVE
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _onSave(Map<String, dynamic> values) async {
    final prov = context.read<ProcessRecEntryProvider>();
    // ✅ MASTER PAYLOAD
    final payload = {
      "SPKProcessRecDate": toUtcIso(_formValues['date']),
      "CrID": int.tryParse(_formValues['manager'] ?? '0') ?? 0,
      "DeptProcessCode": _detRows.first.deptProcessCode ?? 0,
      "DeptCode": _detRows.first.deptCode ?? 0,
      "EmployeeCode": _detRows.first.employeeCode ?? 0,
      "EntryType": 'B',
      "MachineCode": 0,
      "details": _detRows.map((r) {
        return {
          "Jno": r.jno ?? 0,
          "BCode": int.tryParse(r.bCode ?? '0') ?? 0,
          "PktNo": r.pktNo ?? '',
          "CutNo": r.cutNo ?? '',
          "ClvCut": r.clvCut ?? '',
          "Pc": r.pc ?? 0,
          "Wt": r.wt ?? 0.0,
          "IssPc": r.issPc ?? r.pc ?? 0,
          "IssWt": r.issWt ?? r.wt ?? 0.0,
          "DmWt": r.dmWt ?? 0.0,
          "DmPer": r.dmPer ?? 0.0,
          "Repairing": r.repairing ?? 'N',
          "SPKDeptIssMstID": r.spkDeptIssMstID ?? 0,
          "SPKDeptIssDetID": r.spkDeptIssDetID ?? 0,
          "PacketDetID": r.PacketMstID ?? 0,
          "EntryType": r.entryType ?? 'P',
          "TopsPc": r.topsPc ?? 0,
          "QRCode": r.qrCode ?? '',
        };
      }).toList(),
    };

    // 🔍 DEBUG (VERY IMPORTANT)
    final mstId = int.tryParse(_formValues['spkProcessRecMstID'] ?? '0') ?? 0;

    bool success;

    if (_isEditMode && mstId > 0) {
      final newRows = _detRows.where((e) {
        final belongsToThisMst =
            e.spkProcessRecMstID != null && e.spkProcessRecMstID != 0;
        final hasDetId = e.id != null && e.id != 0; // SPKProcessRecDetID
        // a row is "new" only if it's NOT already tied to this master
        // AND doesn't already have a SPKProcessRecDetID
        return !belongsToThisMst && !hasDetId;
      }).toList();
      if (newRows.isEmpty) return;
      final editPayload = {
        "SPKProcessRecDate": toUtcIso(_formValues['date']),
        "CrID": int.tryParse(_formValues['manager'] ?? '0') ?? 0,
        "DeptProcessCode": newRows.first.deptProcessCode ?? 0,
        "DeptCode": newRows.first.deptCode ?? 0,
        "EmployeeCode": newRows.first.employeeCode ?? 0,
        "EntryType": 'B',
        "MachineCode": 0,
        "details": newRows.map((r) {
          return {
            "Jno": r.jno ?? 0,
            "BCode": int.tryParse(r.bCode ?? '0') ?? 0,
            "PktNo": r.pktNo ?? '',
            "CutNo": r.cutNo ?? '',
            "ClvCut": r.clvCut ?? '',
            "Pc": r.pc ?? 0,
            "Wt": r.wt ?? 0.0,
            "IssPc": r.issPc ?? 0,
            "IssWt": r.issWt ?? 0.0,
            "DmWt": r.dmWt ?? 0.0,
            "DmPer": r.dmPer ?? 0.0,
            "Repairing": r.repairing ?? 'N',
            "SPKDeptIssMstID": r.spkDeptIssMstID ?? 0,
            "SPKDeptIssDetID": r.spkDeptIssDetID ?? 0,
            "PacketDetID": r.PacketMstID ?? 0,
            "EntryType": r.entryType ?? 'P',
            "TopsPc": r.topsPc ?? 0,
            "QRCode": r.qrCode ?? '',
          };
        }).toList(),
      };

      success = await prov.insertInSameMst(editPayload, mstId);
    } else {
      success = await prov.create(payload);
    }

    if (!mounted) return;
    if (success) {
      final wasEdit = _isEditMode;
      _resetForm();
      await ErpResultDialog.showSuccess(
        context: context,
        theme: _theme,
        title: wasEdit ? 'Updated' : 'Saved',
        message: wasEdit
            ? 'Process Issue Entry updated.'
            : 'Process Issue Entry saved.',
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  DELETE
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _onDelete() async {
    if (_formValues['spkProcessRecMstID'] == null) return;

    final confirm = await ErpDeleteDialog.show(
      context: context,
      theme: _theme,
      title: 'Process Issue',
      itemName: 'ID: ${_formValues['spkProcessRecMstID'].toString()}',
    );
    if (confirm != true || !mounted) return;

    final success = await context.read<ProcessRecEntryProvider>().delete(
      _formValues['spkProcessRecMstID'].toString(),
    );

    if (success && mounted) {
      final id = _formValues['spkProcessRecMstID'].toString();
      _resetForm();
      await ErpResultDialog.showDeleted(
        context: context,
        theme: _theme,
        itemName: 'Process Issue $id',
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
      _isEditMode = _showTableOnMobile = false;
      _isAdding = false;
      _detRows = [];
      _detDisplay = [];
      _editingDetIndex = null;
      _fromCrId = _toCrId = null;
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

      _erpFormKey.currentState?.updateFieldValue('dueDayCount', formatted);
    } else {
      _formValues['dueDayCount'] = '';
      _erpFormKey.currentState?.updateFieldValue('dueDayCount', '');
    }
  }

  List<List<ErpFieldConfig>> _buildFormRows() {
    final deptProcessProvider = context.read<DeptProcessProvider>();
    final deptProv = context.read<DeptProvider>();
    final employeeProv = context.read<EmployeeProvider>();
    final counterProvider = context.read<CounterProvider>();

    final processItems = deptProcessProvider.list
        .where((p) => p.active == true)
        .map(
          (e) => ErpDropdownItem(
            label: e.deptProcessName ?? '',
            value: e.deptProcessCode?.toString() ?? '',
          ),
        )
        .toList();

    // ── deptItems dropdown ─────────────────────────────────────────────────
    final deptItems = deptProv.list.where((e) => e.active == true).toList()
      ..sort((a, b) => (a.sortID ?? 0).compareTo(b.sortID ?? 0));
    final deptDropdown = deptItems
        .map(
          (e) => ErpDropdownItem(
            label: e.deptName ?? '',
            value: e.deptCode?.toString() ?? '',
          ),
        )
        .toList();

    // ── deptItems dropdown ─────────────────────────────────────────────────
    final employeeItems = employeeProv.list
        .where((e) => e.active == true)
        .toList();
    final employeeDropdown = employeeItems
        .map(
          (e) => ErpDropdownItem(
            label: e.employeeName ?? '',
            value: e.employeeCode?.toString() ?? '',
          ),
        )
        .toList();

    // ─────────────────────────────────────────────────────────────────────
    //  MASTER SECTION (sectionIndex 0)
    // ─────────────────────────────────────────────────────────────────────
    final List<List<ErpFieldConfig>> rows = [
      [
        ErpFieldConfig(
          key: 'manager',
          label: 'MANAGER',
          type: ErpFieldType.dropdown,
          sectionIndex: 0,
          required: true,
          readOnly: _detRows.isNotEmpty || _isEditMode,
          dropdownItems: counterProvider.list
              .where((e) => e.active == true)
              .map(
                (e) => ErpDropdownItem(
                  label: e.crName ?? '',
                  value: e.crId?.toString() ?? '',
                ),
              )
              .toList(),
        ),
        ErpFieldConfig(
          key: 'date',
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
          key: 'id',
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
    ErpColumnConfig(key: 'id', label: 'ID', width: 120),
    ErpColumnConfig(key: 'date', label: 'DATE', width: 160, isDate: true),
    ErpColumnConfig(key: 'time', label: 'TIME', width: 160),
    ErpColumnConfig(key: 'manager', label: 'MANAGER', width: 160),
    ErpColumnConfig(key: 'process', label: 'PROCESS', width: 160),
    ErpColumnConfig(key: 'department', label: 'DEPARTMENT', width: 160),
    ErpColumnConfig(key: 'employee', label: 'EMPLOYEE', width: 160),
    ErpColumnConfig(key: 'machine', label: 'MACHINE', width: 160),
    ErpColumnConfig(key: 'jno', label: 'Jno', width: 160),
    ErpColumnConfig(key: 'totPkt', label: 'TOT PKT', width: 160),
    ErpColumnConfig(key: 'pc', label: 'PC', width: 140),
    ErpColumnConfig(key: 'wt', label: 'WT', width: 140),
    ErpColumnConfig(key: 'issPc', label: 'ISS PC', width: 160),
    ErpColumnConfig(key: 'issWt', label: 'ISS WT', width: 160),
    ErpColumnConfig(key: 'dmWt', label: 'DM WT', width: 160),
    ErpColumnConfig(key: 'dmPer', label: 'DM PER', width: 160),
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
    return Consumer<ProcessRecEntryProvider>(
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
      title: 'PROCESS REC ENTRY',
      tabBarBackgroundColor: const Color(0xfff2f0ef),
      tabBarSelectedColor: _theme.primaryGradient.first,
      tabBarSelectedTxtColor: Colors.white,
      rows: _buildFormRows(),
      initialValues: _formValues,
      isEditMode: _isEditMode,
      onFieldChanged: (key, value) {
        _formValues[key] = value.toString();
        switch (key) {
          case 'entry':
            _entryVals[key] = value.toString();
            Future.delayed(
              const Duration(milliseconds: 50),
              () => _erpFormKey.currentState?.focusField('dueDay'),
            );
            break;

          case 'dueDay':
            _formValues[key] = value.toString();
            _calcDueDate();
            break;

          case 'manager':
            final val = value.toString();
            final id = int.tryParse(val);
            setState(() {
              _toCrId = id;
            });
            break;

          case 'employee':
            final employeeProv = context.read<EmployeeProvider>();
            final selectedEmployee = employeeProv.list.firstWhereOrNull(
              (e) => e.employeeCode.toString() == value.toString(),
            );
            if (selectedEmployee != null && selectedEmployee.deptCode != null) {
              final deptVal = selectedEmployee.deptCode.toString();
              _formValues['deptName'] = deptVal;
              _erpFormKey.currentState?.updateFieldValue('deptName', deptVal);
            }
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
                title: 'REC DETAILS',
                theme: t,
                onDeleteRow: _deleteDetRow,
                editingIndex: _editingDetIndex,
                columnLabels: {
                  for (final c in _activeDetColumns) c: _colLabel(c),
                },
                columnWidths: {for (final c in _activeDetColumns) c: 90},
                columnAlignments: const {
                  'srno': TextAlign.left,
                  'cutNo': TextAlign.left,
                  'qrCode': TextAlign.left,
                  'bCode': TextAlign.left,
                  'pktNo': TextAlign.left,
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
    double sumDouble(double Function(ProcessRecDetModel) fn) =>
        _detRows.fold(0.0, (s, r) => s + fn(r));

    int sumInt(int Function(ProcessRecDetModel) fn) =>
        _detRows.fold(0, (s, r) => s + fn(r));

    final totPc = sumInt((r) => r.pc ?? 0);
    final totWt = sumDouble((r) => r.wt ?? 0);

    final totIssPc = sumInt((r) => r.issPc ?? 0);
    final totIssWt = sumDouble((r) => r.issWt ?? 0);

    final totGhatWt = sumDouble((r) => r.lossWt ?? 0); // 👈 GHAT WT

    final totDmWt = sumDouble((r) => r.dmWt ?? 0);

    final baseWt = totWt > 0 ? totWt : totIssWt;

    final dmPer = baseWt > 0 ? (totDmWt / baseWt * 100) : 0;

    final avgSize = _detRows.isNotEmpty
        ? sumDouble((r) => (r.diam ?? 0)) / _detRows.length
        : 0;

    return {
      'srno': 'Tot...',
      'pc': '$totPc',
      'wt': fThreeDecimal(totWt),
      'issPc': '$totIssPc',
      'issWt': fThreeDecimal(totIssWt),
      'ghatWt': fThreeDecimal(totGhatWt),
      'dmWt': fThreeDecimal(totDmWt),
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

  Widget _buildTable(ProcessRecEntryProvider prov) {
    final data = prov.list.map((e) {
      return {
        'id': e.id,
        'date': _formatDate(e.date),
        'time': e.time ?? '',

        'jno': e.jno?.toString() ?? '',
        'totPkt': (e.totPkt ?? 0).toString(),
        'pc': (e.pc ?? 0).toString(),

        'wt': fThreeDecimal(e.wt ?? 0),
        'issPc': (e.issPc ?? 0).toString(),
        'issWt': fThreeDecimal(e.issWt ?? 0),

        'dmWt': fThreeDecimal(e.dmWt ?? 0),
        'dmPer': (e.dmPer ?? 0).toStringAsFixed(2),

        // Helper fields
        'spkProcessRecMstID': e.id,
        'crID': e.crID ?? 0,
        'deptCode': e.deptCode ?? 0,
        'deptProcessCode': e.deptProcessCode ?? 0,
        'employeeCode': e.employeeCode ?? 0,
        'employee': e.employeeName ?? 0,
        'process': e.deptProcessName ?? 0,
        'department': e.deptName ?? 0,
        'manager': e.manager ?? 0,
      };
    }).toList();

    return ErpDataTable(
      isReportRow: false,
      token: token ?? '',
      url: '',
      title: 'PROCESS REC ENTRY LIST',
      columns: _tableColumns,
      data: data,
      showSearch: true,
      dateFilter: true,
      onClose: () {
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
