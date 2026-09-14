import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:diam_mfg/models/process_issue_model.dart';
import 'package:diam_mfg/providers/charni_provider.dart';
import 'package:diam_mfg/providers/counter_manager_det_provider.dart';
import 'package:diam_mfg/providers/counter_provider.dart';
import 'package:diam_mfg/providers/dept_provider.dart';
import 'package:diam_mfg/providers/dept_group_provider.dart';
import 'package:diam_mfg/providers/dept_process_provider.dart';
import 'package:diam_mfg/providers/employee_provider.dart';
import 'package:diam_mfg/providers/factory_provider.dart';
import 'package:diam_mfg/providers/remarks_provider.dart';
import 'package:diam_mfg/providers/tensions_provider.dart';
import 'package:diam_mfg/providers/trn_process_issue_provider.dart';
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
import '../providers/shape_provider.dart';
import 'package:diam_mfg/models/company_model.dart';
import 'package:diam_mfg/providers/company_provider.dart';
import 'package:diam_mfg/services/generateJobWorkPdf.dart';
import 'package:printing/printing.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  WIDGET
// ─────────────────────────────────────────────────────────────────────────────

class TrnProcessIssueEntry extends StatefulWidget {
  const TrnProcessIssueEntry({super.key});

  @override
  State<TrnProcessIssueEntry> createState() => _TrnProcessIssueEntryState();
}

// ─────────────────────────────────────────────────────────────────────────────
//  STATE
// ─────────────────────────────────────────────────────────────────────────────

class _TrnProcessIssueEntryState extends State<TrnProcessIssueEntry> {
  // ── Theme ──────────────────────────────────────────────────────────────────
  final ErpThemeVariant _themeVariant = ErpThemeVariant.frost;

  ErpTheme get _theme => ErpTheme(_themeVariant);

  // ── Form ───────────────────────────────────────────────────────────────────
  GlobalKey<ErpFormState> _erpFormKey = GlobalKey<ErpFormState>();
  Map<String, String> _formValues = {
    'date': DateFormat('dd/MM/yy').format(DateTime.now()),
    'jno': '0',
    'report': 'REPORT',
  };
  final Map<String, String> _entryVals = {
    'report': 'REPORT',
  };

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
  List<ProcessIssueDetModel> _detRows = [];
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
    _setDefaultFormValues();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.wait([
        context.read<ProcessIssueEntryProvider>().load(),
        context.read<CounterProvider>().load(),
        context.read<CounterManagerDetProvider>().load(),
        context.read<DeptProvider>().load(),
        context.read<DeptGroupProvider>().load(),
        context.read<DeptProcessProvider>().load(),
        context.read<EmployeeProvider>().loadEmployees(),
        context.read<CompanyProvider>().loadCompanies(),
        context.read<ShapeProvider>().load(),
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
    final dateStr = DateFormat('dd/MM/yy').format(now);
    _formValues['date'] = dateStr;
    _formValues['jno'] = '0';
    _formValues['report'] = 'REPORT';
    _entryVals['report'] = 'REPORT';
    _erpFormKey.currentState?.updateFieldValue('date', dateStr);
    _erpFormKey.currentState?.updateFieldValue('jno', '0');
    _erpFormKey.currentState?.updateFieldValue('report', 'REPORT');
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

    final rows = await context.read<ProcessIssueEntryProvider>().fetchByBCode(
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

    final newRow = ProcessIssueDetModel(
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
      formType: 'PROCESS ISSUE',
      remarks: r.remarks,
      topsPc: r.topsPc,
      qrCode: r.qrCode,
      charniCode: r.charniCode,
      shapeCode: r.shapeCode,
      cutCode: r.cutCode,
      size: r.size,
      length: r.length,
      articalCode: r.articalCode,
      articalName: r.articalName,
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
      success = await context.read<ProcessIssueEntryProvider>().deleteRow(
        (row.spkProcessIssMstID)?.toString(),
      );
    }

    if (success && mounted) {
      setState(() {
        _detRows.removeAt(idx);
        // Re-number srno
        _detRows = _detRows.asMap().entries.map((e) {
          final v = e.value;
          return ProcessIssueDetModel(
            srno: e.key + 1,
            spkDeptIssMstID: v.spkDeptIssMstID,
            spkDeptIssDetID: v.spkDeptIssDetID,
            spkProcessIssMstID: v.spkProcessIssMstID,
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
            articalCode: v.articalCode,
            articalName: v.articalName,
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
            'articalName': r.articalName ?? '',
            'articalCode': r.articalCode?.toString() ?? '',

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
      return DateFormat('dd/MM/yy').format(dt.toLocal());
    } catch (_) {
      return v.toString();
    }
  }

  Future<void> _onRowTap(Map<String, dynamic> row) async {
    final prov = context.read<ProcessIssueEntryProvider>();
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
        'id': _s(row['spkProcessIssMstID'], '0'),
        'spkProcessIssMstID': _s(row['spkProcessIssMstID'], '0'),
        'sPKProcessIssDetID': _s(row['SPKProcessIssDetID'], '0'),
        'date': _date(row['date']),
        'manager': _s(row['manager']),
        'deptProcessCode': _s(row['deptProcessCode']),
        'deptName': _s(row['deptCode']),
        'employee': _s(row['employeeCode']),
        'time': _s(row['time']),
        'report': _formValues['report'] ?? _entryVals['report'] ?? 'REPORT',
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
    final prov = context.read<ProcessIssueEntryProvider>();
    // ✅ MASTER PAYLOAD
    final payload = {
      "SPKProcessIssDate": toUtcIso(_formValues['date']),
      "CrID": int.tryParse(_formValues['manager'] ?? '0') ?? 0,
      "DeptProcessCode":
          int.tryParse(_formValues['deptProcessCode'] ?? '0') ?? 0,
      "DeptCode": int.tryParse(_formValues['deptName'] ?? '0') ?? 0,
      "EmployeeCode": int.tryParse(_formValues['employee'] ?? '0') ?? 0,
      "EntryType": 'B',
      "MachineCode": 0,
      "details": _detRows.map((r) {
        return {
          "Jno": r.jno ?? 0,
          // "ID": r.id ?? 0,
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
          "EmployeeCode":
              r.employeeCode ??
              int.tryParse(_formValues['employee'] ?? '0') ??
              0,
          "QRCode": r.qrCode ?? '',
          if (r.articalCode != null) "ArticalCode": r.articalCode,
          if (r.articalName != null) "ArticalName": r.articalName,
        };
      }).toList(),
    };

    // 🔍 DEBUG (VERY IMPORTANT)
    final mstId = int.tryParse(_formValues['spkProcessIssMstID'] ?? '0') ?? 0;

    bool success;
    if (_isEditMode && mstId > 0) {
      final newRows = _detRows.where((e) {
        final belongsToThisMst =
            e.spkProcessIssMstID != null && e.spkProcessIssMstID != 0;
        final hasDetId = e.id != null && e.id != 0; // SPKProcessRecDetID
        // a row is "new" only if it's NOT already tied to this master
        // AND doesn't already have a SPKProcessRecDetID
        return !belongsToThisMst && !hasDetId;
      }).toList();
      print(jsonEncode(newRows));
      if (newRows.isEmpty) return;
      final editPayload = {
        "SPKProcessIssDate": toUtcIso(_formValues['date']),
        "CrID": int.tryParse(_formValues['manager'] ?? '0') ?? 0,
        "DeptProcessCode": newRows.first.deptProcessCode ?? 0,
        "DeptCode": newRows.first.deptCode ?? 0,
        "EmployeeCode": newRows.first.employeeCode ?? 0,
        "EntryType": 'B',
        "MachineCode": 0,
        "details": newRows.map((r) {
          return {
            // "ID": r.id ?? 0,
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
            if (r.articalCode != null) "ArticalCode": r.articalCode,
            if (r.articalName != null) "ArticalName": r.articalName,
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
    if (_formValues['spkProcessIssMstID'] == null) return;

    final confirm = await ErpDeleteDialog.show(
      context: context,
      theme: _theme,
      title: 'Process Issue',
      itemName: 'ID: ${_formValues['spkProcessIssMstID'].toString()}',
    );
    if (confirm != true || !mounted) return;

    final success = await context.read<ProcessIssueEntryProvider>().delete(
      _formValues['spkProcessIssMstID'].toString(),
    );

    if (success && mounted) {
      final id = _formValues['spkProcessIssMstID'].toString();
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
    _entryVals['report'] = 'REPORT';
    setState(() {
      _isEditMode = _showTableOnMobile = false;
      _isAdding = false;
      _detRows = [];
      _detDisplay = [];
      _editingDetIndex = null;
      _fromCrId = _toCrId = null;
      _erpFormKey = GlobalKey<ErpFormState>();
      _formValues.clear();
      _formValues['date'] = DateFormat('dd/MM/yy').format(DateTime.now());
      _formValues['jno'] = '0';
      _formValues['report'] = 'REPORT';
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

      final formatted = DateFormat('dd/MM/yy').format(dueDate);

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
          key: 'date',
          label: 'DATE',
          type: ErpFieldType.date,
          readOnly: true,
          skipFocus: true,
          sectionIndex: 0,
          width: 130,
        ),
        ErpFieldConfig(
          key: 'time',
          label: 'TIME',
          skipFocus: true,
          type: ErpFieldType.time,
          readOnly: true,
          sectionIndex: 0,
          width: 110,
        ),
        ErpFieldConfig(
          key: 'id',
          label: 'ID',
          type: ErpFieldType.number,
          readOnly: true,
          skipFocus: true,
          sectionIndex: 0,
          width: 110,
        ),
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
                  label: '${e.crName ?? ''}  |  ${_deptNameFor(e.deptCode)}',
                  value: e.crId?.toString() ?? '',
                ),
              )
              .toList(),
        ),
        ErpFieldConfig(
          key: 'deptProcessCode',
          label: 'PROCESS',
          required: true,
          type: ErpFieldType.dropdown,
          readOnly: _detRows.isNotEmpty || _isEditMode,
          sectionIndex: 0,
          dropdownItems: processItems,
        ),
        ErpFieldConfig(
          key: 'employee',
          label: 'EMPLOYEE',
          type: ErpFieldType.dropdown,
          dropdownItems: employeeDropdown,
          readOnly: _detRows.isNotEmpty || _isEditMode,
          sectionIndex: 0,
        ),
        ErpFieldConfig(
          key: 'deptName',
          label: 'DEPT',
          type: ErpFieldType.dropdown,
          dropdownItems: deptDropdown,
          sectionIndex: 0,
          readOnly: true,
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
        ErpFieldConfig(
          key: 'report',
          label: '',
          type: ErpFieldType.radio,
          radioDirection: Axis.horizontal,
          isRadioRow: true,
          skipFocus: true,
          radioItems: [
            ErpRadioOption(label: 'Details', value: 'REPORT'),
            ErpRadioOption(label: 'Summary', value: 'SUMMARY'),
          ],
          width: 250,
          sectionIndex: 2,
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
      'articalName': 'ARTICLE',
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
    return Consumer<ProcessIssueEntryProvider>(
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
  //  PRINT JOB WORK PDF
  // ─────────────────────────────────────────────────────────────────────────

  CompanyModel? _selectedCompany;

  Future<void> printJobWorkPdf() async {
    final companies = context.read<CompanyProvider>().companies;
    final selectedCompany = context.read<CompanyProvider>().selectedCompanyCode;
    final company = companies.firstWhereOrNull(
          (e) => e.companyCode.toString() == selectedCompany.toString(),
    ) ?? companies.firstOrNull;
    _selectedCompany = company;

    if (_detRows.isEmpty) {
      _showSnack('No detail rows to print.');
      return;
    }

    final prov = context.read<ProcessIssueEntryProvider>();
    final counterProv = context.read<CounterProvider>();
    final deptProcessProv = context.read<DeptProcessProvider>();
    final shapeProv = context.read<ShapeProvider>();

    // ── 1. Party / Manager resolution ────────────────────────────────────────
    final partyId = _toCrId ??
        int.tryParse(_formValues['manager'] ?? '') ??
        _detRows.firstOrNull?.toCrId ??
        int.tryParse(_selectedRow?['CrID']?.toString() ??
            _selectedRow?['crID']?.toString() ??
            '');

    final partyCounter = partyId != null
        ? counterProv.list.firstWhereOrNull((e) => e.crId == partyId)
        : null;

    final partyName = partyCounter?.crName ??
        _selectedRow?['Manager']?.toString() ??
        _selectedRow?['manager']?.toString() ??
        _formValues['manager'] ??
        '';

    final cvdPartyCode = partyCounter?.CVDPartyCode?.toString() ?? '';
    final naturalPartyCode = partyCounter?.NaturalPartyCode?.toString() ?? '';

    // ── 2. Dept & Process resolution ─────────────────────────────────────────
    final deptCode = partyCounter?.deptCode ??
        _detRows.firstOrNull?.deptCode ??
        int.tryParse(_formValues['deptName'] ?? '');
    final deptName = _deptNameFor(deptCode).isNotEmpty
        ? _deptNameFor(deptCode)
        : (_selectedRow?['Department']?.toString() ?? _formValues['deptName'] ?? '');

    final processCode = int.tryParse(_formValues['deptProcessCode'] ?? '') ??
        _detRows.firstOrNull?.deptProcessCode ??
        int.tryParse(_selectedRow?['DeptProcessCode']?.toString() ??
            _selectedRow?['deptProcessCode']?.toString() ??
            '');

    String processName = '';
    if (processCode != null) {
      processName = deptProcessProv.list
              .firstWhereOrNull((e) => e.deptProcessCode == processCode)
              ?.deptProcessName ??
          '';
    }
    if (processName.isEmpty) {
      processName = _selectedRow?['Process']?.toString() ??
          _selectedRow?['process']?.toString() ??
          '';
    }

    final partyType = [deptName, processName]
        .where((s) => s.trim().isNotEmpty)
        .join(' - ');

    // ── 3. Master ID & Job No ────────────────────────────────────────────────
    final masterId = int.tryParse(_formValues['id'] ??
            _formValues['spkProcessIssMstID'] ??
            '') ??
        _detRows.firstOrNull?.spkProcessIssMstID ??
        int.tryParse(_selectedRow?['SPKProcessIssMstID']?.toString() ??
            _selectedRow?['spkProcessIssMstID']?.toString() ??
            _selectedRow?['id']?.toString() ??
            _selectedRow?['ID']?.toString() ??
            '') ??
        prov.list.firstOrNull?.SPKProcessIssMstID ??
        0;

    final jno = _detRows.firstOrNull?.jno ??
        int.tryParse(_formValues['jno'] ?? '') ??
        int.tryParse(_selectedRow?['Jno']?.toString() ??
            _selectedRow?['jno']?.toString() ??
            '') ??
        (masterId != 0 ? masterId : null);

    final jobNo = (jno != null && jno != 0) ? jno.toString() : masterId.toString();

    // ── 4. Date ──────────────────────────────────────────────────────────────
    final rawDate = _formValues['date'] ??
        _selectedRow?['Date']?.toString() ??
        _selectedRow?['date']?.toString() ??
        '';
    final dateStr = rawDate.isNotEmpty
        ? _date(rawDate)
        : DateFormat('dd/MM/yy').format(DateTime.now());

    // ── 5. Detail Items mapping ──────────────────────────────────────────────
    final detailItems = _detRows.map((e) {
      final kapan = (e.cutNo != null && e.cutNo!.isNotEmpty)
          ? e.cutNo!
          : (e.clvCut ?? '');
      final bCode = (e.bCode != null && e.bCode != '0') ? e.bCode! : '';
      final pktNo = e.pktNo ?? '';
      final shape = shapeProv.list
              .firstWhereOrNull((s) => s.shapeCode == e.shapeCode)
              ?.shapeName ??
          '';
      final artical = (e.articalName != null && e.articalName!.isNotEmpty)
          ? e.articalName!
          : (shape.isNotEmpty ? shape : '');
      final pcs = (e.issPc != null && e.issPc! > 0
              ? e.issPc!
              : (e.pc != null && e.pc! > 0 ? e.pc! : (e.recPc ?? 0)))
          .toString();
      final cts = (e.issWt != null && e.issWt! > 0
              ? e.issWt!
              : (e.wt != null && e.wt! > 0 ? e.wt! : (e.recWt ?? 0.0)))
          .toStringAsFixed(3);
      final size = (e.size != null && e.size! > 0)
          ? e.size!.toStringAsFixed(2)
          : ((e.diam != null && e.diam! > 0) ? e.diam!.toStringAsFixed(2) : '');

      return JobWorkItem(
        kapan: kapan,
        bCode: bCode,
        pktNo: pktNo,
        type: artical,
        pcs: pcs,
        cts: cts,
        size: size,
      );
    }).toList();

    final pdfData = JobWorkPdfModel(
      headerInfo: _selectedCompany,
      partyName: partyName,
      partyType: partyType,
      jobNo: jobNo,
      date: dateStr,
      CVDPartyCode: cvdPartyCode,
      NaturalPartyCode: naturalPartyCode,
      items: detailItems,
    );

    final reportType = _formValues['report'] ?? _entryVals['report'] ?? 'REPORT';

    /// DETAIL REPORT
    if (reportType == 'REPORT') {
      final pdf = await generateJobWorkPdf(pdfData);
      await Printing.layoutPdf(onLayout: (_) async => pdf);
    }
    /// SUMMARY REPORT
    else if (reportType == 'SUMMARY') {
      List<JobWorkItem> summaryItems = [];
      JobWorkItem? grandTotalItem;

      if (masterId > 0) {
        try {
          final summaryRes = await prov.loadSummaryReport(masterId);
          if (!mounted) return;

          if (summaryRes != null && summaryRes is Map && summaryRes['data'] != null) {
            final summaryList = summaryRes['data']['summary'] as List? ?? summaryRes['data'] as List? ?? [];
            final dataRows = summaryList.where((r) => r['isGrandTotal'] != true && r['IsGrandTotal'] != true).toList();

            summaryItems = dataRows.map((r) {
              final cut = (r['CutNo'] ?? r['cutNo'] ?? r['MfgCut'] ?? r['mfgCut'] ?? '').toString();
              final matchedDets = _detRows.where((d) => d.cutNo == cut || d.clvCut == cut).toList();
              final pktCount = matchedDets.isNotEmpty ? matchedDets.length : (int.tryParse((r['TotalPkt'] ?? r['totalPkt'] ?? r['Pkt'] ?? r['pkt'] ?? '1').toString()) ?? 1);
              final articalName = (r['ArticalName'] ?? r['articalName'] ?? '').toString().isNotEmpty
                  ? (r['ArticalName'] ?? r['articalName']).toString()
                  : (matchedDets.firstWhereOrNull((e) => (e.articalName ?? '').isNotEmpty)?.articalName ??
                      shapeProv.list.firstWhereOrNull((s) => s.shapeCode == matchedDets.firstOrNull?.shapeCode)?.shapeName ??
                      (r['Shape'] ?? r['shape'] ?? '').toString());

              final pc = int.tryParse((r['TotalPc'] ?? r['totalPc'] ?? r['Pc'] ?? r['pc'] ?? r['IssPc'] ?? r['issPc'] ?? '0').toString()) ?? 0;
              final wt = double.tryParse((r['TotalWt'] ?? r['totalWt'] ?? r['Wt'] ?? r['wt'] ?? r['IssWt'] ?? r['issWt'] ?? '0').toString()) ?? 0.0;
              final sizeStr = (r['Size'] ?? r['size'] ?? '').toString();

              return JobWorkItem(
                kapan: cut,
                bCode: pktCount.toString(),
                pktNo: sizeStr,
                type: articalName,
                pcs: pc.toString(),
                size: sizeStr,
                cts: wt.toStringAsFixed(3),
              );
            }).toList();

            final grandTotal = summaryList.firstWhereOrNull((r) => r['isGrandTotal'] == true || r['IsGrandTotal'] == true);
            if (grandTotal != null) {
              grandTotalItem = JobWorkItem(
                kapan: '',
                bCode: (grandTotal['TotalPkt'] ?? grandTotal['totalPkt'] ?? _detRows.length).toString(),
                pktNo: '',
                type: '',
                pcs: (grandTotal['TotalPc'] ?? grandTotal['totalPc'] ?? 0).toString(),
                cts: (double.tryParse((grandTotal['TotalWt'] ?? grandTotal['totalWt'] ?? '0').toString()) ?? 0.0).toStringAsFixed(3),
              );
            }
          }
        } catch (_) {}
      }

      // Fallback if summaryItems is empty
      if (summaryItems.isEmpty) {
        final Map<String, List<ProcessIssueDetModel>> grouped = {};
        for (final r in _detRows) {
          final key = (r.cutNo != null && r.cutNo!.isNotEmpty)
              ? r.cutNo!
              : ((r.clvCut != null && r.clvCut!.isNotEmpty) ? r.clvCut! : 'OTHER');
          grouped.putIfAbsent(key, () => []).add(r);
        }

        int totalPcs = 0;
        double totalCts = 0.0;

        summaryItems = grouped.entries.map((entry) {
          final cut = entry.key;
          final rows = entry.value;
          final sumPc = rows.fold<int>(
            0,
            (s, e) => s + (e.issPc != null && e.issPc! > 0 ? e.issPc! : (e.pc != null && e.pc! > 0 ? e.pc! : (e.recPc ?? 0))),
          );
          final sumWt = rows.fold<double>(
            0.0,
            (s, e) => s + (e.issWt != null && e.issWt! > 0 ? e.issWt! : (e.wt != null && e.wt! > 0 ? e.wt! : (e.recWt ?? 0.0))),
          );
          totalPcs += sumPc;
          totalCts += sumWt;

          final articalName = rows.firstWhereOrNull((e) => (e.articalName ?? '').isNotEmpty)?.articalName ??
              shapeProv.list
                  .firstWhereOrNull((s) => s.shapeCode == rows.first.shapeCode)
                  ?.shapeName ??
              '';

          return JobWorkItem(
            kapan: cut,
            bCode: rows.length.toString(),
            pktNo: '',
            type: articalName,
            pcs: sumPc.toString(),
            cts: sumWt.toStringAsFixed(3),
          );
        }).toList();

        grandTotalItem = JobWorkItem(
          kapan: '',
          bCode: _detRows.length.toString(),
          pktNo: '',
          type: '',
          pcs: totalPcs.toString(),
          cts: totalCts.toStringAsFixed(3),
        );
      }

      final summaryPdfData = JobWorkPdfModel(
        headerInfo: _selectedCompany,
        partyName: partyName,
        partyType: partyType,
        jobNo: jobNo,
        date: dateStr,
        CVDPartyCode: cvdPartyCode,
        NaturalPartyCode: naturalPartyCode,
        items: summaryItems,
      );

      final pdf = await generateJobWorkPdfSummary(
        summaryPdfData,
        showSize: false,
        grandTotal: grandTotalItem,
      );
      await Printing.layoutPdf(onLayout: (_) async => pdf);
    }
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
      title: 'PROCESS ISSUE ENTRY',
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

          case 'report':
            final valStr = value.toString();
            _formValues['report'] = valStr;
            _entryVals['report'] = valStr;
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

      isShowPrintButton: true,
      printOnPress: printJobWorkPdf,

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
                title: 'ISSUE DETAILS',
                theme: t,
                onDeleteRow: _deleteDetRow,
                editingIndex: _editingDetIndex,
                columnLabels: {
                  for (final c in _activeDetColumns) c: _colLabel(c),
                },
                columnAlignments: const {
                  'srno': TextAlign.left,
                  'cutNo': TextAlign.left,
                  'qrCode': TextAlign.left,
                  'bCode': TextAlign.left,
                  'pktNo': TextAlign.left,
                  'articalName': TextAlign.left,
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
    double sumDouble(double Function(ProcessIssueDetModel) fn) =>
        _detRows.fold(0.0, (s, r) => s + fn(r));

    int sumInt(int Function(ProcessIssueDetModel) fn) =>
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
      return DateFormat('dd/MM/yy').format(dt);
    } catch (_) {
      return value;
    }
  }

  Widget _buildTable(ProcessIssueEntryProvider prov) {
    final data = prov.list.map((e) {
      return {
        'id': e.SPKProcessIssMstID,
        'date': _formatDate(e.date),
        'time': e.time ?? '',

        'manager': e.crID ?? '',
        'process': e.process ?? '',
        'department': e.department ?? '',
        'employee': e.employee ?? '',

        'machine': (e.machineCode ?? 0).toString(),

        'jno': e.jno?.toString() ?? '',
        'totPkt': (e.totPkt ?? 0).toString(),
        'pc': (e.pc ?? 0).toString(),

        'wt': fThreeDecimal(e.wt ?? 0),
        'issPc': (e.issPc ?? 0).toString(),
        'issWt': fThreeDecimal(e.issWt ?? 0),

        'dmWt': fThreeDecimal(e.dmWt ?? 0),
        'dmPer': (e.dmPer ?? 0).toStringAsFixed(2),

        // Helper fields
        'spkProcessIssMstID': e.SPKProcessIssMstID,
        'crID': e.crID ?? 0,
        'deptCode': e.deptCode ?? 0,
        'deptProcessCode': e.deptProcessCode ?? 0,
        'employeeCode': e.employeeCode ?? 0,
        'machineCode': e.machineCode ?? 0,
      };
    }).toList();

    return ErpDataTable(
      isReportRow: false,
      token: token ?? '',
      url: '',
      title: 'PROCESS ISSUE ENTRY LIST',
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
