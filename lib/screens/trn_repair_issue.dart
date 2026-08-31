import 'package:collection/collection.dart';
import 'package:diam_mfg/models/factory_model.dart';
import 'package:diam_mfg/models/repair_issue_entry_model.dart';
import 'package:diam_mfg/providers/charni_provider.dart';
import 'package:diam_mfg/providers/company_provider.dart';
import 'package:diam_mfg/providers/counter_manager_det_provider.dart';
import 'package:diam_mfg/providers/counter_provider.dart';
import 'package:diam_mfg/providers/dept_provider.dart';
import 'package:diam_mfg/providers/dept_group_provider.dart';
import 'package:diam_mfg/providers/dept_process_provider.dart';
import 'package:diam_mfg/providers/employee_provider.dart';
import 'package:diam_mfg/providers/factory_provider.dart';
import 'package:diam_mfg/providers/remarks_provider.dart';
import 'package:diam_mfg/providers/tensions_provider.dart';
import 'package:diam_mfg/services/generateJobWorkPdf.dart';
import 'package:diam_mfg/utils/app_images.dart';
import 'package:diam_mfg/utils/constants.dart';
import 'package:diam_mfg/utils/delete_dialogue.dart';
import 'package:diam_mfg/utils/msg_dialogue.dart';
import 'package:erp_data_table/erp_data_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:rs_dashboard/rs_dashboard.dart';
import '../models/company_model.dart';
import '../models/user_visibility_model.dart';
import '../providers/auth_provider.dart';
import '../providers/counter_display_det_provider.dart';
import '../providers/repair_issue_entry_provider.dart';
import '../providers/purity_provider.dart';
import '../providers/shape_provider.dart';
import '../providers/user_visibility_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  WIDGET
// ─────────────────────────────────────────────────────────────────────────────

class TrnRepairIssueEntry extends StatefulWidget {
  const TrnRepairIssueEntry({super.key});

  @override
  State<TrnRepairIssueEntry> createState() => _TrnRepairIssueEntryState();
}

// ─────────────────────────────────────────────────────────────────────────────
//  STATE
// ─────────────────────────────────────────────────────────────────────────────

class _TrnRepairIssueEntryState extends State<TrnRepairIssueEntry> {
  // ── Theme ──────────────────────────────────────────────────────────────────
  final ErpThemeVariant _themeVariant = ErpThemeVariant.frost;

  ErpTheme get _theme => ErpTheme(_themeVariant);

  // ── Form ───────────────────────────────────────────────────────────────────
  final GlobalKey<ErpFormState> _erpFormKey = GlobalKey<ErpFormState>();
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
  String? _fromDeptName;
  int? _fromDeptCode;

  int? _toCrId;
  String? _toDeptName;
  int? _toDeptCodeVal;
  FactoryModel? _selectedFactory;

  // ── Detail rows ────────────────────────────────────────────────────────────
  List<RepairIssueDetModel> _detRows = [];
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

  String _purityNameFor(int? code, [String? fallback]) {
    if (code != null) {
      try {
        final match = context
            .read<PurityProvider>()
            .list
            .firstWhereOrNull((p) => p.purityCode == code);
        if (match?.purityName != null && match!.purityName!.isNotEmpty) {
          return match.purityName!;
        }
      } catch (_) {}
    }
    return fallback ?? '';
  }


  @override
  void initState() {
    super.initState();
    _resetForm();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.wait([
        context.read<RepairIssueEntryProvider>().load(),
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

  // ─────────────────────────────────────────────────────────────────────────
  //  DEFAULT FORM VALUES
  // ─────────────────────────────────────────────────────────────────────────

  void _setDefaultFormValues() {
    final now = DateTime.now();
    _formValues = {
      'date': DateFormat('dd/MM/yyyy').format(now),
      'jno': '0',
      'report': 'REPORT',
      'rePairIssue': 'FACTORY',
    };
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
    Future.delayed(const Duration(milliseconds: 150), () {
      if (!mounted) return;

      try {
        _erpFormKey.currentState?.focusField('scanValue');
      } catch (_) {}
    });
  }

  Future<void> _onBCodeScanned(String bCode) async {
    if (_isBCodePending) return;
    _isBCodePending = true;

    final rows = await context.read<RepairIssueEntryProvider>().fetchByBCode(
      bCode: bCode,
    );

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

    final newRow = RepairIssueDetModel(
      srno: _detRows.length + 1,
      bCode: r.bCode?.toString() ?? '',
      pktNo: r.pktNo ?? '',
      packetMstID: r.packetMstID ?? r.PacketMstID ?? r.spkDeptIssDetID,
      cutNo: r.cutNo ?? '',
      ArticalName: r.ArticalName,
      purityName: r.purityName,
      colorName: r.colorName,
      charniName: r.charniName,
      shapeName: r.shapeName,
      polishName: r.polishName,
      symmetryName: r.symmetryName,
      fluoName: r.fluoName,
      // ORIGINAL PACKET VALUES
      pc: r.pc ?? 0,
      wt: r.wt ?? 0,
      dmWt: r.dmWt ?? 0,
      dmPer: r.dmPer ?? 0,
      // LAST ENTRY RECEIVE / ISSUE VALUES
      issPc: r.issPc ?? r.recPc ?? r.pc ?? 0,
      issWt: r.issWt ?? r.recWt ?? r.wt ?? 0,
      purityCode: r.purityCode,
      colorCode: r.colorCode,
      charniCode: r.charniCode ?? 0,
      shapeCode: r.shapeCode ?? 0,
      cutCode: r.cutCode ?? 0,
      polishCode: r.polishCode ?? 0,
      symmetryCode: r.symmetryCode ?? 0,
      fluoCode: r.fluoCode ?? 0,
      length: r.length ?? 0,
      height: r.height ?? 0,
      diam: r.diam ?? 0,
      // ✅ GHAT WT (LossWt from scan API response)
      lossWt: r.lossWt ?? r.wt ?? 0,
      fromCrId: _fromCrId,
      toCrId: _toCrId,
      entryType: 'B',
      formType: 'REPAIR ISSUE',
      size: r.size ?? 0.00,
      rate: r.rate,
      rateID: r.rateID,
      rateon: r.rateon,
      amount: r.amount,
    );


    setState(() {
      _detRows.add(newRow);
      _syncDetGrid();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      try {
        _erpFormKey.currentState?.updateFieldValue(
          'scanValue',
          '',
        );

        _erpFormKey.currentState?.focusField(
          'scanValue',
        );
      } catch (_) {}
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  EDIT / DELETE DET ROW
  // ─────────────────────────────────────────────────────────────────────────

  dynamic _deleteDetRow(int idx) async {
    final actualIdx = _detRows.length - 1 - idx; // ← convert display→actual

    if (_isEditMode) {
      final confirm = await ErpDeleteDialog.show(
        context: context,
        theme: _theme,
        title: 'Repair Issue',
        itemName: 'ID: ${_detRows[actualIdx].spkDeptIssDetID?.toString()}',
      );
      if (confirm != true || !mounted) return;

      final mstId = _detRows[actualIdx].spkDeptIssMstID ?? int.tryParse(_formValues['repairIssMstID'] ?? _formValues['factoryIssMstID'] ?? '');

      final success = await context.read<RepairIssueEntryProvider>().deleteRow(
        mstId?.toString(),
        _detRows[actualIdx].spkDeptIssDetID?.toString(),
        _detRows[actualIdx].bCode,
          _detRows[actualIdx].NewIssMstID,
        _theme,
        context,
      );
      if (success && mounted) {
        setState(() {
          _detRows.removeAt(actualIdx);
          // Re-number srno
          _detRows = _detRows.asMap().entries.map((e) {
            final v = e.value;
            return RepairIssueDetModel(
              srno: e.key + 1,
              spkDeptIssMstID: v.spkDeptIssMstID,
              id: v.id,
              jno: v.jno,
              bCode: v.bCode,
              pktNo: v.pktNo,
              cutNo: v.cutNo,
              clvCut: v.clvCut,
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
              polishCode: v.polishCode,
              symmetryCode: v.symmetryCode,
              fluoCode: v.fluoCode,
              height: v.height,
              ratio: v.ratio,
              length: v.length,
              qrCode: v.qrCode,
              partName: v.partName,
              orderMstID: v.orderMstID,
              amountRs: v.amountRs,
              diffDmWt: v.diffDmWt,
              plDmWt: v.plDmWt,
              plDmPer: v.plDmPer,
              jnoRecPc: v.jnoRecPc,
              ArticalName: v.ArticalName,
              size: v.size,
              rate: v.rate,
              rateID: v.rateID,
              rateon: v.rateon,
              amount: v.amount,

            );
          }).toList();

          _syncDetGrid();
          if (_editingDetIndex == actualIdx) _editingDetIndex = null;
        });
        await ErpResultDialog.showDeleted(
          context: context,
          theme: _theme,
          itemName: '1 row(s) deleted successfully',
        );
      }
      if(_detRows.isEmpty) {
        _resetForm();
        context.read<RepairIssueEntryProvider>().load();
      }
    } else {
      setState(() {
        _detRows.removeAt(actualIdx);
        // Re-number srno
        _detRows = _detRows.asMap().entries.map((e) {
          final v = e.value;
          return RepairIssueDetModel(
            srno: e.key + 1,
            spkDeptIssMstID: v.spkDeptIssMstID,
            id: v.id,
            jno: v.jno,
            bCode: v.bCode,
            pktNo: v.pktNo,
            cutNo: v.cutNo,
            clvCut: v.clvCut,
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
            polishCode: v.polishCode,
            symmetryCode: v.symmetryCode,
            fluoCode: v.fluoCode,
            height: v.height,
            diam: v.diam,
            kachaRec: v.kachaRec,
            remarks: v.remarks,
            ratio: v.ratio,
            length: v.length,
            qrCode: v.qrCode,
            partName: v.partName,
            orderMstID: v.orderMstID,
            amountRs: v.amountRs,
            diffDmWt: v.diffDmWt,
            plDmWt: v.plDmWt,
            plDmPer: v.plDmPer,
            jnoRecPc: v.jnoRecPc,
            ArticalName: v.ArticalName,
            size: v.size,
            rate: v.rate,
            rateID: v.rateID,
            rateon: v.rateon,
            amount: v.amount,
          );
        }).toList();

        _syncDetGrid();
        if (_editingDetIndex == actualIdx) _editingDetIndex = null;
      });
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
      'purityCode',
      'charniCode',
      'colorCode',
      'dmWt',
      'dmPer',
      'size', // optional (if available)
      'diam',
      'length',
    ];

    _detDisplay = _detRows.reversed
        .map(
          (r) => {
            'srno': r.srno?.toString() ?? '',
            'cutNo': r.cutNo ?? '',
            'qrCode': '',
            'bCode': r.bCode ?? '',
            'pktNo': r.pktNo ?? '',
            'pc': (r.pc ?? 0).toString(),
            'wt': fThreeDecimal(r.wt ?? 0),
            'issPc': (r.issPc ?? r.pc ?? 0).toString(),
            'issWt': fThreeDecimal(r.issWt ?? r.wt ?? 0),
            'ghatWt': fThreeDecimal(r.lossWt ?? 0),
            'purityCode': _purityNameFor(r.purityCode, r.purityName),
            'charniCode': (r.charniName != null && r.charniName!.isNotEmpty)
                ? r.charniName!
                : (r.charniCode?.toString() ?? ''),
            'colorCode': (r.colorName != null && r.colorName!.isNotEmpty)
                ? r.colorName!
                : (r.colorCode?.toString() ?? ''),

            'dmWt': fThreeDecimal(r.dmWt ?? 0),
            'dmPer': (r.dmPer ?? 0).toStringAsFixed(2),
            'size': r.size ?? 0.0,
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
      return DateFormat('dd/MM/yyyy').format(dt.toLocal());
    } catch (_) {
      return v.toString();
    }
  }

  Future<void> _onRowTap(Map<String, dynamic> row) async {
    final prov = context.read<RepairIssueEntryProvider>();
    final id = int.tryParse((row['repairIssMstID'] ?? row['RepairIssMstID'] ?? row['factoryIssMstID'] ?? row['FactoryIssMstID']).toString()) ?? 0;

    final details = await prov.loadDetails(id);

    final factoryCode = (row['factoryCode'] ?? row['FactoryCode'])?.toString();

    if (factoryCode != null) {
      final factoryProv = context.read<FactoryProvider>();

      _selectedFactory = factoryProv.factories.firstWhereOrNull(
        (f) => f.factoryCode.toString() == factoryCode,
      );
    }

    if (!mounted) return;

    final dueDayVal = row['dueDay'] ?? row['DueDay'];
    final dueDateVal = row['dueDate'] ?? row['DueDate'];

    setState(() {
      _selectedRow = row;
      _isEditMode = true;
      _detRows = details;
      _editingDetIndex = null;
      _isAdding = false;
      _showTableOnMobile = false;

      _formValues = {
        'jno': _s(row['jno'] ?? row['Jno']),
        'repairIssMstID': _s(row['repairIssMstID'] ?? row['RepairIssMstID'] ?? row['factoryIssMstID'] ?? row['FactoryIssMstID'], '0'),
        'repairIssDetID': _s(row['repairIssDetID'] ?? row['RepairIssDetID'], '0'),
        'date': _date(row['date'] ?? row['repairIssDate'] ?? row['RepairIssDate']),
        'time': _s(row['time'] ?? row['Time']),

        'rePairIssue': _s(row['rePairIssue'] ?? row['RePairIssue'] ?? row['repairIssue'] ?? row['RepairIssue'], 'FACTORY'),
        'entry': _s(row['entry'] ?? row['selectType'] ?? row['SelectType']),
        'type': _s(row['type'] ?? row['factoryType'] ?? row['FactoryType'] ?? row['RepairType']),

        'dueDay': _s(dueDayVal),
        'dueDayCount': _date(dueDateVal),

        'factory': _s(row['factoryCode'] ?? row['FactoryCode']),
        // 'scanValue': _detRows.isNotEmpty ? _s(_detRows.first.bCode) : '',
        'report': 'REPORT',
      };
      _entryVals['report'] = 'REPORT';
      _syncDetGrid();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      try {
        _erpFormKey.currentState?.updateFieldValue(
          'rePairIssue',
          _formValues['rePairIssue'] ?? 'FACTORY',
        );
        if (dueDayVal != null) {
          _erpFormKey.currentState?.updateFieldValue('dueDay', _s(dueDayVal));
        }
        if (dueDateVal != null) {
          _erpFormKey.currentState?.updateFieldValue('dueDayCount', _date(dueDateVal));
        }
        _erpFormKey.currentState?.focusField('scanValue');
      } catch (_) {}
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  SAVE
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _onSave(Map<String, dynamic> values) async {
    final prov = context.read<RepairIssueEntryProvider>();
    final reversedDet = _detRows.toList();

    if (reversedDet.isNotEmpty) {
      final mstId = int.tryParse(_formValues['repairIssMstID']?.toString() ?? _formValues['factoryIssMstID']?.toString() ?? _selectedRow?['repairIssMstID']?.toString() ?? _selectedRow?['factoryIssMstID']?.toString() ?? '') ?? 0;

      final isFactory = (_formValues['rePairIssue'] ?? 'FACTORY') == 'FACTORY';

      // ✅ MASTER PAYLOAD
      final payload = {
        if (_isEditMode && mstId > 0) ...{
          "RepairIssMstID": mstId,
        },
        "RepairIssDate": toUtcIso(_formValues['date']),
        "SelectType": "SPK",
        "DueDay": int.tryParse(_formValues['dueDay'] ?? '0') ?? 0,
        "DueDate": toUtcIso(_formValues['dueDayCount']),
        "RePairIssue": _formValues['rePairIssue'] ?? 'FACTORY',
        "FactoryCode": isFactory ? (int.tryParse(_formValues['factory'] ?? '0') ?? 0) : 0,
        "FactoryType": isFactory ? (_formValues['type'] ?? '') : '',
        "EntryType": _formValues['entry'],

        // ✅ DETAILS
        "details": reversedDet.map((r) {
          return {
            "CutNo": r.cutNo ?? '',
            "BCode": int.tryParse(r.bCode ?? '0') ?? 0,
            "PacketMstID": r.PacketMstID ?? 0,
            "MfgCut": r.cutNo ?? '',

            "OrgPc": r.pc ?? 0,
            "OrgWt": r.wt ?? 0.000,

            "IssPc":  r.issPc ?? r.pc ?? 0,
            "IssWt":  r.issWt ?? r.wt ?? 0,

            "GhatWt": r.lossWt ?? 0.000,
            "ColorCode": r.colorCode?.toString() ?? '0',

            "DmWt": r.dmWt ?? 0.000,
            "DmPer": r.dmPer ?? 0,

            "RateID": r.rateID ?? 0,
            "Rateon": r.rateon,
            "Rate":  r.rate,
            "Amount": r.amount ?? 0.00,

            "Diam": r.diam ?? 0,

            "PktNo": r.pktNo,
            "QRCode": r.qrCode,
            "Pc": r.pc ?? 0,
            "Wt": r.wt ?? 0.000,
            "PurityCode": r.purityCode ?? 0,
            "CharniCode": r.charniCode ?? 0,
            "ShapeCode": r.shapeCode ?? 0,
            "CutCode": r.cutCode ?? 0,
            "Size": r.size ?? 0,
            "PolishCode": r.polishCode ?? 0,
            "SymmetryCode": r.symmetryCode ?? 0,
            "FluoCode": r.fluoCode ?? 0,
            "Length": r.length ?? 0,
            "Height": r.height ?? 0,

          };
        }).toList(),
      };

      bool success = false;
      if (_isEditMode && mstId > 0) {
        success = await prov.update(mstId, payload);
      } else {
        success = await prov.create(payload);
      }

      if (!mounted) return;
      if (success) {
        final wasEdit = _isEditMode;
        await ErpResultDialog.showSuccess(
          context: context,
          theme: _theme,
          title: wasEdit ? 'Updated' : 'Saved',
          message: wasEdit
              ? 'Repair Issue Entry updated.'
              : 'Repair Issue Entry saved.',
        );
        await context.read<RepairIssueEntryProvider>().load();
        _resetForm();
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
    final mstIdStr = _formValues['repairIssMstID'] ?? _formValues['factoryIssMstID'];
    if (mstIdStr == null || mstIdStr.isEmpty) return;
    final id = int.tryParse(mstIdStr);
    if (id == null || id == 0) return;

    final confirm = await ErpDeleteDialog.show(
      context: context,
      theme: _theme,
      title: 'Repair Issue',
      itemName: 'ID: $id',
    );
    if (confirm != true || !mounted) return;

    final success = await context.read<RepairIssueEntryProvider>().delete(
      id,
      _theme,
      context,
      _detRows
          .where((r) => r.bCode != null && r.bCode != '0')
          .map((r) => num.parse(r.bCode.toString()))
          .toList(),
        _detRows.first.NewIssMstID
    );

    if (success && mounted) {
      _resetForm();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  RESET
  // ─────────────────────────────────────────────────────────────────────────

  void _resetForm() {
    FocusManager.instance.primaryFocus?.unfocus();

    try {
      _erpFormKey.currentState?.resetForm();
    } catch (_) {}

    _entryVals.clear();

    setState(() {
      _isEditMode = false;
      _showTableOnMobile = false;
      _isAdding = false;

      _detRows = [];
      _detDisplay = [];

      _editingDetIndex = null;

      _fromCrId = null;
      _toCrId = null;

      _fromDeptName = null;
      _toDeptName = null;

      _fromDeptCode = null;
      _toDeptCodeVal = null;

      _toDisplayFields.clear();
      _fromDisplayFields.clear();

      _selectedFactory = null;

      _formValues.clear();
    });

    _setDefaultFormValues();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      try {
        _erpFormKey.currentState?.focusField('scanValue');
      } catch (_) {}
    });
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
    final factoryProv = context.read<FactoryProvider>();

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

    // ─────────────────────────────────────────────────────────────────────
    //  MASTER SECTION
    // ─────────────────────────────────────────────────────────────────────
    final List<List<ErpFieldConfig>> rows = [
      // Row 1 — entry / dueDay / dueDayCount / date / jno
      [
        ErpFieldConfig(
          key: 'rePairIssue',
          label: 'REPAIR ISSUE',
          type: ErpFieldType.dropdown,
          dropdownItems: [
            ErpDropdownItem(label: 'FACTORY', value: 'FACTORY'),
            ErpDropdownItem(label: 'CLEAVING', value: 'CLEAVING'),
          ],
          sectionIndex: 0,
          initialDropValue: true,
          initialBoolValue: true
        ),
        ErpFieldConfig(
          key: 'dueDay',
          label: 'DUE DAY',
          type: ErpFieldType.number,
          sectionIndex: 0,
        ),
        ErpFieldConfig(
          key: 'dueDayCount',
          label: 'DUE DATE',
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
        if(_formValues['rePairIssue'] == 'FACTORY')
        ErpFieldConfig(
          key: 'factory',
          label: 'FACTORY',
          type: ErpFieldType.dropdown,
          dropdownItems: factoryDropdown,
          sectionIndex: 0,
        ),
        if(_formValues['rePairIssue'] == 'FACTORY')
          ErpFieldConfig(
          key: 'type',
          label: 'FACTORY TYPE',
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
          sectionIndex: 1,
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
    ErpColumnConfig(key: 'jno', label: 'Jno', width: 70, required: true),
    ErpColumnConfig(key: 'date', label: 'DATE', width: 160, isDate: true),
    ErpColumnConfig(key: 'time', label: 'TIME', width: 140),
    ErpColumnConfig(key: 'entry', label: 'ENTRY', width: 180),
    ErpColumnConfig(key: 'dueDay', label: 'DUE DAY', width: 180),
    ErpColumnConfig(key: 'dueDate', label: 'DUE DATE', width: 160),
    ErpColumnConfig(key: 'factory', label: 'FACTORY', width: 160),
    ErpColumnConfig(key: 'type', label: 'FACTORY TYPE', width: 150),
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
    return Consumer<RepairIssueEntryProvider>(
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

  // CREATE PDF
  CompanyModel? _selectedCompany;

  Future<void> printJobWorkPdf() async {
    if (_detRows.isEmpty) return;

    final prov = context.read<RepairIssueEntryProvider>();
    final masterId =
        (_detRows.first.spkDeptIssMstID ?? prov.list.firstOrNull?.repairIssMstID ?? prov.list.firstOrNull?.factoryIssMstID ?? 0)
            .toInt();
    final summaryModel = await prov.loadSummaryReport(masterId);
    final companies = context.read<CompanyProvider>().companies;
    final selectedCompany = context.read<CompanyProvider>().selectedCompanyCode;
    final company = companies.firstWhereOrNull(
          (e) => e.companyCode.toString() == selectedCompany.toString(),
    );
    _selectedCompany = company;
    if (!mounted) return;

    if (summaryModel == null) {
      _showSnack('Failed to load summary data.');
      return;
    }
    // ── DETAIL REPORT ─────────────────────────────────────────
    if (_entryVals['report'] == 'REPORT') {
      final pdfData = JobWorkPdfModel(
        headerInfo: _selectedCompany,
        partyName: _selectedFactory?.factoryName ?? 'REPAIR',
        partyType: _selectedFactory?.factoryType ?? 'REPAIR ISSUE',
        jobNo: masterId.toString(),
        date: _formValues['date']?.toString() ?? '',
        items: _detRows.map((e) {
          return JobWorkItem(
            kapan: e.cutNo ?? '',
            bCode: e.bCode ?? '',
            pktNo: e.pktNo ?? '',
            type: e.ArticalName?.toString() ?? '',
            pcs: (e.issPc ?? 0).toString(),
            cts: (e.issWt ?? 0).toStringAsFixed(3),
          );
        }).toList(),
      );

      final pdf = await generateJobWorkPdf(pdfData);
      await Printing.layoutPdf(onLayout: (_) async => pdf);
    }
    // ── SUMMARY REPORT ─────────────────────────────────────
    else if (_entryVals['report'] == 'SUMMARY') {
      final dataRows = summaryModel.summary
          .where((r) => !r.isGrandTotal)
          .toList();

      final grandTotal = summaryModel.summary.firstWhereOrNull(
        (r) => r.isGrandTotal,
      );

      final grandTotalItem = grandTotal != null
          ? JobWorkItem(
              kapan: '',
              bCode: (grandTotal.totalPkt).toString(),
              pktNo: '',
              type: '',
              pcs: grandTotal.totalPc.toString(),
              cts: grandTotal.totalWt.toStringAsFixed(3),
            )
          : null;

      final summaryItems = dataRows.map((r) {
        return JobWorkItem(
          kapan: r.cutNo.isNotEmpty ? r.cutNo : (r.groupName ?? ''),
          bCode: (r.totalPkt > 0 ? r.totalPkt : (r.pkt ?? 0)).toString(),
          pktNo: r.size,
          type: r.articalName,
          pcs: (r.totalPc > 0 ? r.totalPc : (r.issPc ?? r.pc ?? 0)).toString(),
          size: r.size.toString(),
          cts: (r.totalWt > 0 ? r.totalWt : (r.issWt ?? r.wt ?? 0.0)).toStringAsFixed(3),
        );
      }).toList();

      final summaryPdfData = JobWorkPdfModel(
        headerInfo: _selectedCompany,
        partyName: _selectedFactory?.factoryName ?? 'REPAIR',
        partyType: _selectedFactory?.factoryType ?? 'REPAIR ISSUE',
        jobNo: masterId.toString(),
        date: _formValues['date']?.toString() ?? '',
        items: summaryItems,
      );

      final pdf = await generateJobWorkPdfSummary(
        summaryPdfData,
        showSize: true,
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
      title: 'REPAIR ISSUE ENTRY',
      tabBarBackgroundColor: const Color(0xfff2f0ef),
      tabBarSelectedColor: _theme.primaryGradient.first,
      tabBarSelectedTxtColor: Colors.white,
      rows: _buildFormRows(),
      initialValues: _formValues,
      isEditMode: _isEditMode,
      onFieldChanged: (key, value) {
        _formValues[key] = value.toString();
        switch (key) {
          case 'rePairIssue':
            final valStr = value.toString();
            _formValues['rePairIssue'] = valStr;
            _entryVals[key] = valStr;
            if (valStr != 'FACTORY') {
              _formValues['factory'] = '';
              _formValues['type'] = '';
              _selectedFactory = null;
              try {
                _erpFormKey.currentState?.updateFieldValue('factory', '');
                _erpFormKey.currentState?.updateFieldValue('type', '');
              } catch (_) {}
            }
            setState(() {});
            Future.delayed(
              const Duration(milliseconds: 50),
              () => _erpFormKey.currentState?.focusField('dueDay'),
            );
            break;

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
              _selectedFactory = selectedFactory;
              setState(() {});
              final type = selectedFactory.factoryType ?? '';

              _formValues['type'] = type;

              _erpFormKey.currentState?.updateFieldValue('type', type);
            }

            break;

          default:
            _entryVals[key] = value.toString();
        }
      },

      onFieldSubmitted: (key, value) async {
        if (key != 'scanValue') return;

        FocusManager.instance.primaryFocus?.unfocus();

        final scanVal = value.toString().trim();

        if (scanVal.isEmpty) {
          _focusScan();
          return;
        }

        await _onBCodeScanned(scanVal);
      },
      printOnPress: printJobWorkPdf,
      isShowPrintButton: true,
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
                title: 'REPAIR ISSUE DETAILS',
                theme: t,
                onDeleteRow: _deleteDetRow,
                editingIndex: _editingDetIndex != null
                    ? (_detRows.length - 1 - _editingDetIndex!)
                    : null,
                columnLabels: {
                  for (final c in _activeDetColumns) c: _colLabel(c),
                },
                columnWidths: const {'srno': 40},
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
    double sumDouble(double Function(RepairIssueDetModel) fn) =>
        _detRows.fold(0.0, (s, r) => s + fn(r));

    int sumInt(int Function(RepairIssueDetModel) fn) =>
        _detRows.fold(0, (s, r) => s + fn(r));

    final totPc = sumInt((r) => r.pc ?? 0);
    final totWt = sumDouble((r) => r.wt ?? 0);

    final totIssPc = sumInt((r) => r.issPc ?? 0);
    final totIssWt = sumDouble((r) => r.issWt ?? 0);

    final totGhatWt = sumDouble((r) => r.lossWt ?? 0);

    final totDmWt = sumDouble((r) => r.dmWt ?? 0);
    final totDmPer = sumDouble((r) => r.dmPer ?? 0);

    final baseWt = totWt > 0 ? totWt : totIssWt;


    final avgSize = _detRows.isNotEmpty
        ? sumDouble((r) => (r.size ?? 0)) / _detRows.length
        : 0;

    return {
      'srno': 'Tot...',
      'pc': '$totPc',
      'wt': fThreeDecimal(totWt),
      'issPc': '$totIssPc',
      'issWt': fThreeDecimal(totIssWt),
      'ghatWt': fThreeDecimal(totGhatWt),
      'dmWt': fThreeDecimal(totDmWt),
      'dmPer': f2TwoDecimal(totDmPer),
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

  Widget _buildTable(RepairIssueEntryProvider prov) {
    final data = prov.list.map((e) {
      return {
        'jno': e.jno,
        'repairIssMstID': e.repairIssMstID ?? e.factoryIssMstID,
        'factoryIssMstID': e.repairIssMstID ?? e.factoryIssMstID,
        'date': _formatDate(e.repairIssDate),
        'time': e.time ?? '',
        'entry': e.selectType ?? '',
        'dueDay': (e.dueDay ?? 0).toString(),
        'dueDate': _formatDate(e.dueDate),
        'factory': e.factoryName ?? '',
        'factoryCode': e.factoryCode ?? '',
        'type': e.factoryType ?? '',
        'totPkt': (e.pkt ?? 0).toString(),
        'pc': (e.pc ?? 0).toString(),
        'wt': fThreeDecimal(e.wt ?? 0),
        'issPc': (e.issPc ?? 0).toString(),
        'issWt': fThreeDecimal(e.issWt ?? 0),
        'dmWt': fThreeDecimal(e.dmWt ?? 0),
        'dmPer': (e.dmPer ?? 0).toStringAsFixed(2),
      };
    }).toList();

    return ErpDataTable(
      isReportRow: false,
      token: token ?? '',
      url: '',
      title: 'REPAIR ISSUE ENTRY LIST',
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
        ErpSearchFieldConfig(key: 'factory', label: 'REPAIR', width: 150),
      ],
      selectedRow: _selectedRow,
      onRowTap: _onRowTap,
      emptyMessage: prov.isLoaded ? 'No repair issue entries found' : 'Loading...',
    );
  }
}
