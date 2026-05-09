import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:diam_mfg/providers/counter_stock_type_det_provider.dart';
import 'package:diam_mfg/services/duplicate_check_service.dart';
import 'package:diam_mfg/services/duplicate_utils.dart';
import 'package:diam_mfg/utils/constants.dart';
import 'package:erp_data_table/erp_data_table.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rs_dashboard/rs_dashboard.dart';
import '../bootstrap.dart';
import '../models/counter_model.dart';
import '../models/counter_report_det_model.dart';
import '../models/user_visibility_model.dart';
import '../providers/counter_dept_det_provider.dart';
import '../providers/counter_provider.dart';
import '../providers/counter_display_det_provider.dart';
import '../providers/counter_det_provider.dart';
import '../providers/counter_process_provider.dart';
import '../providers/counter_report_det_provider.dart';
import '../providers/counter_shape_det_provider.dart';
import '../providers/dept_provider.dart';
import '../providers/main_menuMst_provider.dart';
import '../providers/report_mst_provider.dart';
import '../providers/report_type_provider.dart';
import '../providers/shape_provider.dart';
import '../providers/stock_type_provider.dart';
import '../providers/test_provider.dart';
import '../providers/user_visibility_provider.dart';
import '../providers/counter_type_provider.dart';
import '../providers/division_provider.dart';
import '../providers/dept_group_provider.dart';
import '../providers/team_provider.dart';
import '../providers/menu_mst_provider.dart';
import '../providers/dept_process_provider.dart';
import '../utils/app_images.dart';
import '../utils/delete_dialogue.dart';
import '../utils/msg_dialogue.dart';
import '../providers/counter_operator_det_provider.dart';
import '../providers/counter_manager_det_provider.dart';

class MstCounter extends StatefulWidget {
  const MstCounter({super.key});

  @override
  State<MstCounter> createState() => _MstCounterState();
}

class _MstCounterState extends State<MstCounter> {
  final ErpThemeVariant _themeVariant = ErpThemeVariant.frost;

  ErpTheme get _theme => ErpTheme(_themeVariant);
  Set<String> _selectedReportKeys = {};
  final GlobalKey<ErpFormState> _erpFormKey = GlobalKey<ErpFormState>();
  Map<String, dynamic>? _selectedRow;
  bool _isEditMode = false;
  bool _showSearch = false;
  bool _showTableOnMobile = false;
  Map<String, String> _formValues = {};
  Set<int> _selectedDeptIds = {};
  bool _isSaving = false;

  int? _savedCrId;
  int? _savedMstID;
  int? _savedDeptCode;

  int _currentTabIndex = 0;

  String? _selectedDeptGroupCode;
  String? _selectedDeptCode;
  String? _selectedManType;
  String? _selectedEmpType;

  Map<int, Set<int>> _managerIssueSelected = {};
  Set<int> _expandedIssueDepts = {};
  Set<int> _expandedIssueCounters = {};

  Map<int, Set<int>> _managerRecvSelected = {};
  Set<int> _expandedRecvDepts = {};
  Set<int> _expandedRecvCounters = {};

  Set<int> _fromSelected = {};
  Set<int> _toSelected = {};

  Set<int> _selectedProcessCodes = {};
  Set<int> _selectedShapeIds = {};
  Set<int> _selectedStockTypeIds = {};
  Set<int> _selectedOperatorIds = {};
  Set<int> _selectedManagerIds = {};
  Set<String> _selectedMenuIds = {};
  final Set<int> _collapsedMainMenus = {};

  final String? token = AppStorage.getString("token");

  List<ErpColumnConfig> get _tableColumns => [
    ErpColumnConfig(key: 'crId', label: 'CODE', width: 140),
    ErpColumnConfig(key: 'logInName', label: 'LOGIN', width: 130),
    ErpColumnConfig(key: 'crName', label: 'NAME', width: 180),
    ErpColumnConfig(key: 'userGrp', label: 'USER GRP', width: 160),
    ErpColumnConfig(key: 'sortID', label: 'SORT ID', width: 160),
    ErpColumnConfig(key: 'active', label: 'ACTIVE', width: 130),
    ErpColumnConfig(key: 'counterTypeName', label: 'TYPE', width: 130),
    ErpColumnConfig(key: 'divisionName', label: 'DIVISION', width: 160),
    ErpColumnConfig(key: 'deptGroupName', label: 'GROUP', width: 130),
    ErpColumnConfig(key: 'deptName', label: 'DEPARTMENT', width: 170),
    ErpColumnConfig(key: 'teamName', label: 'TEAM', width: 130),
    ErpColumnConfig(key: 'mfgDeptName', label: 'MFG DEPT', width: 160),
  ];

  List<ErpDropdownItem> get _ynItems => const [
    ErpDropdownItem(label: 'Y', value: 'Y'),
    ErpDropdownItem(label: 'N', value: 'N'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final providers = <String, Future<void>>{
        'CounterType': context.read<CounterTypeProvider>().load(),
        'Division': context.read<DivisionProvider>().loadDivisions(),
        'DeptGroup': context.read<DeptGroupProvider>().load(),
        'Dept': context.read<DeptProvider>().load(),
        'Team': context.read<TeamProvider>().load(),
        'UserVisibility': context.read<UserVisibilityProvider>().load(),
        'MainMenuMst': context.read<MainMenuMstProvider>().load(),
        'MenuMst': context.read<MenuMstProvider>().load(),
        'DeptProcess': context.read<DeptProcessProvider>().load(),
        'CounterOperatorDet': context.read<CounterOperatorDetProvider>().load(),
        'CounterManagerDet': context.read<CounterManagerDetProvider>().load(),
        'CounterDeptDet': context.read<CounterDeptDetProvider>().load(),
        'CounterShapeDet': context.read<CounterShapeDetProvider>().load(),
        'Shape': context.read<ShapeProvider>().load(),
        'CounterStockTypeDet': context
            .read<CounterStockTypeDetProvider>()
            .load(),
        'StockType': context.read<StockTypeProvider>().load(),
        'ReportType': context.read<ReportTypeProvider>().load(),
        'ReportMst': context.read<ReportMstProvider>().load(),
        'Test': context.read<TestProvider>().load(),
        'CounterReportDet': context.read<CounterReportDetProvider>().load(),
      };

      await Future.wait(
        providers.entries.map(
          (e) => e.value
              .then((_) => debugPrint('✅ ${e.key} loaded'))
              .catchError((err) => debugPrint('❌ ${e.key} FAILED: $err')),
        ),
      );

      if (!mounted) return;

      await context
          .read<CounterProvider>()
          .load()
          .then((_) {
            debugPrint('✅ Counter loaded');
            if (!mounted) return;

            final list = context.read<CounterProvider>().list;
            final maxSort = list.isEmpty
                ? 0
                : list
                      .map((c) => c.sortID ?? 0)
                      .reduce((a, b) => a > b ? a : b);
            setState(() {
              _formValues['sortID'] = (maxSort + 1).toString();
            });
          })
          .catchError((err) => debugPrint("❌ Counter FAILED: $err"));
    });
  }

  void _onRowTap(Map<String, dynamic> row) {
    final raw = row['_raw'] as CounterModel;
    setState(() {
      _selectedRow = row;
      _isEditMode = true;
      _showSearch = false;
      _selectedDeptGroupCode = raw.deptGroupCode?.toString();
      _selectedDeptCode = raw.deptCode?.toString();
      _selectedManType = raw.manType ?? 'Days';
      _selectedEmpType = raw.empType ?? 'Days';
      // _currentTabIndex = 0;
      _selectedOperatorIds = {};
      _selectedManagerIds = {};
      _selectedDeptIds = {};
      _savedCrId = raw.crId;
      _savedMstID = raw.counterMstID;
      _savedDeptCode = raw.deptCode;

      _formValues = {
        'counterTypeCode': raw.counterTypeCode?.toString() ?? '',
        'divisionCode': raw.divisionCode?.toString() ?? '',
        'deptGroupCode': raw.deptGroupCode?.toString() ?? '',
        'deptCode': raw.deptCode?.toString() ?? '',
        'teamCode': raw.teamCode?.toString() ?? '',
        'userGrp': raw.userGrp ?? '',
        'logInName': raw.logInName ?? '',
        'crPass': raw.crPass ?? '',
        'crName': raw.crName ?? '',
        'sortID': raw.sortID?.toString() ?? '',
        'active': raw.active == true ? 'true' : 'false',
        'mfgDeptCode': raw.mfgDeptCode?.toString() ?? '',
        'crEdit': raw.crEdit ?? 'Y',
        'crDel': raw.crDel ?? 'Y',
        'autoRec': raw.autoRec ?? 'Y',
        'empIssRec': raw.empIssRec ?? 'N',
        'empRecWt': raw.empRecWt ?? 'N',
        'laserPlanRec': raw.laserPlanRec ?? 'N',
        'polishOut': raw.polishOut ?? 'N',
        'stockLimit': raw.stockLimit?.toString() ?? '',
        'target': raw.target?.toString() ?? '',
        'kachaIss': raw.kachaIss ?? 'Y',
        'manType': raw.manType ?? 'Days',
        'manPktDayLimit': raw.manPktDayLimit?.toString() ?? '',
        'manPktHourLimit': raw.manPktHourLimit?.toString() ?? '',
        'empType': raw.empType ?? 'Days',
        'empPktDayLimit': raw.empPktDayLimit?.toString() ?? '',
        'empPktHourLimit': raw.empPktHourLimit?.toString() ?? '',
        'empPktLimit': raw.empPktLimit?.toString() ?? '',
      };
    });
    if (raw.counterMstID != null) _loadDisplaySettings(raw.counterMstID!);
    _loadMenuRights(raw.crId!);
    _loadProcessRights(raw.crId!);
    _loadOperatorRights(raw.crId!);
    _loadManagerRights(raw.crId!);
    _loadDeptRights(raw.crId!);
    _loadShapeRights(raw.crId!);
    _loadStockTypeRights(raw.crId!);
    _loadManagerIssueReceiveRights(raw.crId!);
    _loadReportRights(raw.crId!);
    if (Responsive.isMobile(context))
      setState(() => _showTableOnMobile = false);
  }

  Future<void> _loadDisplaySettings(int counterMstID) async {
    final dp = context.read<CounterDisplayDetProvider>();
    await dp.loadByCounter(counterMstID);
    final records = dp.counterList;
    setState(() {
      _fromSelected = records
          .where((r) => r.counterType == 'FROM' && r.userVisibilityCode != null)
          .map((r) => r.userVisibilityCode!)
          .toSet();
      _toSelected = records
          .where((r) => r.counterType == 'TO' && r.userVisibilityCode != null)
          .map((r) => r.userVisibilityCode!)
          .toSet();
    });
  }

  Future<void> _loadMenuRights(int crId) async {
    final dp = context.read<CounterDetProvider>();

    await dp.loadByCounter(crId);

    setState(() {
      _selectedMenuIds = dp.counterList
          .where((r) => r.mainMenuMstID != null && r.menuMstID != null)
          .map((r) => '${r.mainMenuMstID}_${r.menuMstID}')
          .toSet();
    });
  }

  Future<void> _loadReportRights(int crId) async {
    final dp = context.read<CounterReportDetProvider>();
    await dp.loadByCrId(crId);
    setState(() {
      _selectedReportKeys = dp.list
          .where((r) => r.testCode != null && r.reportCode != null)
          .map((r) => '${r.testCode}_${r.reportCode}')
          .toSet();
    });
  }

  Future<void> _loadProcessRights(int crId) async {
    final dp = context.read<CounterProcessProvider>();
    await dp.loadByCounter(crId);
    setState(() {
      _selectedProcessCodes = dp.counterList
          .where((r) => r.deptProcessCode != null)
          .map((r) => r.deptProcessCode!)
          .toSet();
    });
  }

  Future<void> _loadOperatorRights(int crId) async {
    final dp = context.read<CounterOperatorDetProvider>();
    await dp.loadByCrId(crId);
    setState(() {
      _selectedOperatorIds = dp.list
          .where((r) => r.crId != null)
          .map((r) => r.crId!)
          .toSet();
    });
  }

  Future<void> _loadManagerRights(int crId) async {
    final dp = context.read<CounterOperatorDetProvider>();
    await dp.loadByCrId(crId);
    setState(() {
      _selectedManagerIds = dp.list
          .where((r) => r.allowCrId != null)
          .map((r) => r.allowCrId!)
          .toSet();
    });
  }

  Future<void> _loadDeptRights(int crId) async {
    final dp = context.read<CounterDeptDetProvider>();
    await dp.loadByCrId(crId);
    setState(() {
      _selectedDeptIds = dp.list
          .where((r) => r.deptCode != null)
          .map((r) => r.deptCode!)
          .toSet();
    });
  }

  Future<void> _loadShapeRights(int crId) async {
    final dp = context.read<CounterShapeDetProvider>();
    await dp.loadByCrId(crId);
    setState(() {
      _selectedShapeIds = dp.list
          .where((r) => r.shapeCode != null)
          .map((r) => r.shapeCode!)
          .toSet();
    });
  }

  Future<void> _loadStockTypeRights(int crId) async {
    final dp = context.read<CounterStockTypeDetProvider>();
    await dp.loadByCrId(crId);
    setState(() {
      _selectedStockTypeIds = dp.list
          .where((r) => r.stockTypeCode != null)
          .map((r) => r.stockTypeCode!)
          .toSet();
    });
  }

  Future<void> _loadManagerIssueReceiveRights(int crId) async {
    final dp = context.read<CounterManagerDetProvider>();
    await dp.loadByCrId(crId);

    final Map<int, Set<int>> issueMap = {};
    final Map<int, Set<int>> recvMap = {};

    for (final r in dp.list) {
      // ✅ ISSUE
      if (r.crId == crId && r.allowCrId != null) {
        issueMap.putIfAbsent(r.allowCrId!, () => {});
        if (r.deptProcessCode != null) {
          issueMap[r.allowCrId!]!.add(r.deptProcessCode!);
        }
      }

      // ✅ RECEIVE (SEPARATE IF, NOT ELSE IF)
      if (r.allowCrId == crId && r.crId != null) {
        recvMap.putIfAbsent(r.crId!, () => {});
        if (r.deptProcessCode != null) {
          recvMap[r.crId!]!.add(r.deptProcessCode!);
        }
      }
    }

    print("ISSUE MAP => $issueMap");
    print("RECEIVE MAP => $recvMap");

    setState(() {
      _managerIssueSelected = issueMap;
      _managerRecvSelected = recvMap;
    });
  }

  Future<void> _onSave(Map<String, dynamic> values) async {
    final exists = await _checkDuplicate(
      fields: {'CrName': values['crName'].toString()},
    );
    if (exists) return;
    setState(() => _isSaving = true);

    // ── Tab 0: Counter Master + Display Settings ──────────────────────────────
    if (_currentTabIndex == 0) {
      final counterProvider = context.read<CounterProvider>();
      CounterModel? savedCounter;

      if (_isEditMode && _selectedRow != null) {
        final raw = _selectedRow!['_raw'] as CounterModel;
        savedCounter = await counterProvider.updateAndReturn(raw.crId!, values);
      } else {
        savedCounter = await counterProvider.createAndReturn(values);
      }

      if (savedCounter == null || !mounted) {
        setState(() => _isSaving = false);
        return;
      }

      final crId = savedCounter.crId!;
      final mstID = savedCounter.counterMstID;
      final wasEdit = _isEditMode;

      setState(() {
        _savedCrId = crId;
        _savedMstID = mstID;
        _savedDeptCode = savedCounter!.deptCode;
        _isEditMode = true;
        _selectedRow = {'_raw': savedCounter};
      });

      if (mstID != null) {
        final dp = context.read<CounterDisplayDetProvider>();
        await dp.deleteByCounter(mstID);
        for (final v in _fromSelected) {
          await dp.create({
            'crId': mstID.toString(),
            'userVisibilityCode': v.toString(),
            'counterType': 'FROM',
          });
        }
        for (final v in _toSelected) {
          await dp.create({
            'crId': mstID.toString(),
            'userVisibilityCode': v.toString(),
            'counterType': 'TO',
          });
        }
      }
      if (!mounted) return;
      setState(() => _isSaving = false); // ✅ dialog se PEHLE
      await ErpResultDialog.showSuccess(
        context: context,
        theme: _theme,
        title: wasEdit ? 'Updated' : 'Saved',
        message: 'Basic info saved.',
      );
      _resetForm();
      return;
    }

    // ── Baaki tabs ke liye _savedCrId zaruri ────────────────────────────────
    if (_savedCrId == null) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please save BASIC tab first.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final crId = _savedCrId!;
    final deptCode = _savedDeptCode;

    // ── Tab 1: Process Rights ───────────────────────────────────────────────
    if (_currentTabIndex == 1) {
      final processProvider = context.read<CounterProcessProvider>();
      final processList = context.read<DeptProcessProvider>().list;
      for (final r in List.of(processProvider.counterList)) {
        if (r.counterProcessDetID != null)
          await processProvider.delete(r.counterProcessDetID!);
      }
      print('_selectedProcessCodes ${_selectedProcessCodes}');

      for (final procCode in _selectedProcessCodes) {
        final proc = processList.firstWhereOrNull(
          (p) => p.deptProcessCode == procCode,
        );
        await processProvider.create({
          'crId': crId.toString(),
          'deptCode': (proc?.deptCode ?? 0).toString(),
          'deptProcessCode': procCode.toString(),
        });
      }
      if (!mounted) return;
      setState(() => _isSaving = false);
      await ErpResultDialog.showSuccess(
        context: context,
        theme: _theme,
        title: 'Saved',
        message: 'Process rights saved.',
      );
      _resetForm();
      return;
    }

    // ── Tab 2: Menu Rights ─────────────────────────────────────────────────
    if (_currentTabIndex == 2) {
      final detProvider = context.read<CounterDetProvider>();

      /// ── DELETE OLD RIGHTS ────────────────────

      for (final r in List.of(detProvider.counterList)) {
        if (r.counterDetID != null) {
          await detProvider.delete(r.counterDetID!);
        }
      }

      /// ── SAVE NEW RIGHTS ──────────────────────

      for (final uniqueKey in _selectedMenuIds) {
        final parts = uniqueKey.split('_');

        if (parts.length != 2) continue;

        final mainMenuId = int.tryParse(parts[0]);

        final menuId = int.tryParse(parts[1]);

        if (mainMenuId == null || menuId == null) {
          continue;
        }

        await detProvider.create({
          'crId': crId.toString(),

          'mainMenuMstID': mainMenuId.toString(),

          'menuMstID': menuId.toString(),
        });
      }

      if (!mounted) return;

      setState(() => _isSaving = false);

      await ErpResultDialog.showSuccess(
        context: context,

        theme: _theme,

        title: 'Saved',

        message: 'Menu rights saved.',
      );

      /// ── RELOAD RIGHTS ────────────────────────

      await _loadMenuRights(crId);
      _resetForm();
      return;
    }

    // ── Tab 3: Allow Manager Issue ─────────────────────────────────────────
    if (_currentTabIndex == 3) {
      final mgProvider = context.read<CounterManagerDetProvider>();
      await mgProvider.deleteByCrId(crId);
      final procP = context.read<DeptProcessProvider>();
      for (final entry in _managerIssueSelected.entries) {
        for (final procCode in entry.value) {
          final proc = procP.list.firstWhereOrNull(
            (p) => p.deptProcessCode == procCode,
          );
          await mgProvider.create({
            'crId': crId.toString(),
            'allowCrId': entry.key.toString(),
            'deptCode': (proc?.deptCode ?? 0).toString(),
            'deptProcessCode': procCode.toString(),
          });
        }
      }
      if (!mounted) return;
      setState(() => _isSaving = false);
      await ErpResultDialog.showSuccess(
        context: context,
        theme: _theme,
        title: 'Saved',
        message: 'Allow Manager Issue saved.',
      );
      _resetForm();
      return;
    }

    // ── Tab 4: Allow Manager Receive ───────────────────────────────────────
    if (_currentTabIndex == 4) {
      final mgProvider = context.read<CounterManagerDetProvider>();
      for (final entry in _managerRecvSelected.entries) {
        for (final procCode in entry.value) {
          await mgProvider.create({
            'crId': entry.key.toString(),
            'allowCrId': crId.toString(),
            'deptCode': deptCode?.toString() ?? '0',
            'deptProcessCode': procCode.toString(),
          });
        }
      }
      if (!mounted) return;
      setState(() => _isSaving = false);
      await ErpResultDialog.showSuccess(
        context: context,
        theme: _theme,
        title: 'Saved',
        message: 'Allow Manager Receive saved.',
      );
      _resetForm();
      return;
    }

    // ── Tab 5: Allow Operator ──────────────────────────────────────────────
    if (_currentTabIndex == 5) {
      final opProvider = context.read<CounterOperatorDetProvider>();
      await opProvider.deleteByCrId(crId);
      for (final allowId in _selectedOperatorIds) {
        await opProvider.create({
          'crId': allowId.toString(),
          'allowCrId': crId.toString(),
        });
      }
      if (!mounted) return;
      setState(() => _isSaving = false);
      await ErpResultDialog.showSuccess(
        context: context,
        theme: _theme,
        title: 'Saved',
        message: 'Allow Operator saved.',
      );
      _resetForm();
      return;
    }

    // ── Tab 6: Allow Manager ───────────────────────────────────────────────
    if (_currentTabIndex == 6) {
      final opProvider = context.read<CounterOperatorDetProvider>();
      await opProvider.deleteByCrId(crId);
      for (final allowId in _selectedManagerIds) {
        await opProvider.create({
          'crId': crId.toString(),
          'allowCrId': allowId.toString(),
        });
      }
      if (!mounted) return;
      setState(() => _isSaving = false);
      await ErpResultDialog.showSuccess(
        context: context,
        theme: _theme,
        title: 'Saved',
        message: 'Allow Manager saved.',
      );
      _resetForm();
      return;
    }

    // ── Tab 7: Allow Department ────────────────────────────────────────────
    if (_currentTabIndex == 7) {
      final deptDetProvider = context.read<CounterDeptDetProvider>();
      await deptDetProvider.deleteByCrId(crId);
      for (final dc in _selectedDeptIds) {
        await deptDetProvider.create({
          'crId': crId.toString(),
          'deptCode': dc.toString(),
        });
      }
      if (!mounted) return;
      setState(() => _isSaving = false);
      await ErpResultDialog.showSuccess(
        context: context,
        theme: _theme,
        title: 'Saved',
        message: 'Allow Department saved.',
      );
      _resetForm();
      return;
    }

    // ── Tab 8: Shape Lock ──────────────────────────────────────────────────
    if (_currentTabIndex == 8) {
      final shapeProvider = context.read<CounterShapeDetProvider>();
      await shapeProvider.deleteByCrId(crId);
      print('_selectedShapeIds ${_selectedShapeIds}');
      for (final shapeCode in _selectedShapeIds) {
        await shapeProvider.create({
          'allowCrId': crId.toString(),
          'shapeCode': shapeCode.toString(),
        });
      }
      if (!mounted) return;
      setState(() => _isSaving = false);
      await ErpResultDialog.showSuccess(
        context: context,
        theme: _theme,
        title: 'Saved',
        message: 'Shape Lock saved.',
      );
      _resetForm();
      return;
    }

    // ── Tab 9: Allow Stock Type ────────────────────────────────────────────
    if (_currentTabIndex == 9) {
      final stProvider = context.read<CounterStockTypeDetProvider>();
      await stProvider.deleteByCrId(crId);
      for (final code in _selectedStockTypeIds) {
        await stProvider.create({
          'allowCrId': crId.toString(),
          'stockTypeCode': code.toString(),
        });
      }
      if (!mounted) return;
      setState(() => _isSaving = false);
      await ErpResultDialog.showSuccess(
        context: context,
        theme: _theme,
        title: 'Saved',
        message: 'Allow Stock Type saved.',
      );
      _resetForm();
      return;
    }

    // ── Tab 10: Report Rights ──────────────────────────────────────────────
    if (_currentTabIndex == 10) {
      final repProvider = context.read<CounterReportDetProvider>();
      final reportList = context.read<ReportMstProvider>().list;
      await repProvider.deleteByCrId(crId);
      for (final key in _selectedReportKeys) {
        final parts = key.split('_');

        if (parts.length != 2) continue;

        final testCode = int.tryParse(parts[0]);

        final reportCode = int.tryParse(parts[1]);

        if (testCode == null || reportCode == null) {
          continue;
        }

        await repProvider.create(
          CounterReportDetModel(
            crID: crId,
            reportCode: reportCode,
            testCode: testCode,
          ).toJson(),
        );
      }
      if (!mounted) return;
      setState(() => _isSaving = false);
      await ErpResultDialog.showSuccess(
        context: context,
        theme: _theme,
        title: 'Saved',
        message: 'Report rights saved.',
      );
      _resetForm();
      return;
    }

    setState(() => _isSaving = false);
  }

  Future<void> _onDelete() async {
    setState(() => _isSaving = true);
    final raw = _selectedRow?['_raw'] as CounterModel?;
    if (raw?.crId == null) return;
    final confirm = await ErpDeleteDialog.show(
      context: context,
      theme: _theme,
      title: 'Counter',
      itemName: raw!.crName ?? '',
    );
    if (confirm != true || !mounted) return;
    final crId = raw.crId!;
    final mstID = raw.counterMstID;
    if (mstID != null) {
      await context.read<CounterDisplayDetProvider>().deleteByCounter(mstID);
    }
    await context.read<CounterDetProvider>().deleteByCrId(crId);
    await context.read<CounterProcessProvider>().deleteByCrId(crId);
    await context.read<CounterOperatorDetProvider>().deleteByCrId(crId);
    await context.read<CounterManagerDetProvider>().deleteByCrId(crId);
    await context.read<CounterDeptDetProvider>().deleteByCrId(crId);
    await context.read<CounterShapeDetProvider>().deleteByCrId(crId);
    await context.read<CounterStockTypeDetProvider>().deleteByCrId(crId);
    await context.read<CounterReportDetProvider>().deleteByCrId(crId);

    if (!mounted) return;
    final success = await context.read<CounterProvider>().delete(crId);
    if (success && mounted) {
      _resetForm();
      if (mounted) setState(() => _isSaving = false);
      setState(() {
        _formValues.clear();
      });
      await ErpResultDialog.showDeleted(
        context: context,
        theme: _theme,
        itemName: raw.crName ?? '',
      );
    }
  }

  Future<void> loadCounterData() async {
    await context.read<CounterProvider>().load();
  }

  Future<void> _resetForm() async {
    final list = context.read<CounterProvider>().list;

    final maxSort = list.isEmpty
        ? 0
        : list.map((c) => c.sortID ?? 0).reduce((a, b) => a > b ? a : b);

    final nextSort = (maxSort + 1).toString();

    setState(() {
      /// ── DO NOT CHANGE _formKey ─────────────
      /// REMOVE:
      /// _formKey = UniqueKey();

      _selectedRow = null;

      _isEditMode = false;

      _showSearch = false;

      _showTableOnMobile = false;

      _selectedDeptGroupCode = null;

      _selectedDeptCode = null;

      _selectedManType = null;

      _selectedEmpType = null;

      _savedCrId = null;

      _savedMstID = null;

      _savedDeptCode = null;

      _fromSelected.clear();

      _toSelected.clear();

      _selectedDeptIds.clear();

      _selectedStockTypeIds.clear();

      _selectedReportKeys.clear();

      _selectedMenuIds.clear();

      _selectedProcessCodes.clear();

      _selectedOperatorIds.clear();

      _selectedManagerIds.clear();

      _selectedShapeIds.clear();

      _managerIssueSelected.clear();

      _managerRecvSelected.clear();

      _expandedIssueDepts.clear();

      _expandedIssueCounters.clear();

      _expandedRecvDepts.clear();

      _expandedRecvCounters.clear();

      _collapsedMainMenus.clear();

      /// ── IMPORTANT ──────────────────────────
      /// CLEAR FORM VALUES DIRECTLY

      _formValues = {
        'counterTypeCode': '',

        'divisionCode': '',

        'deptGroupCode': '',

        'deptCode': '',

        'teamCode': '',

        'userGrp': '',

        'logInName': '',

        'crPass': '',

        'crName': '',

        'sortID': nextSort,

        'mfgDeptCode': '',

        'active': 'true',

        'crEdit': 'Y',

        'crDel': 'Y',

        'autoRec': 'Y',

        'empIssRec': 'N',

        'empRecWt': 'N',

        'laserPlanRec': 'Y',

        'polishOut': 'N',

        'stockLimit': '',

        'target': '',

        'kachaIss': 'N',

        'manType': 'Days',

        'manPktDayLimit': '',

        'manPktHourLimit': '',

        'empType': 'Days',

        'empPktDayLimit': '',

        'empPktHourLimit': '',

        'empPktLimit': '',
      };
    });

    /// ── RESET ERP FORM STATE ────────────────

    /// ── FORCE UPDATE FORM FIELDS ────────────

    final form = _erpFormKey.currentState;

    form?.updateFieldValue('counterTypeCode', null);
    form?.updateFieldValue('divisionCode', null);
    form?.updateFieldValue('deptGroupCode', null);
    form?.updateFieldValue('deptCode', null);
    form?.updateFieldValue('teamCode', null);
    form?.updateFieldValue('userGrp', null);

    form?.updateFieldValue('logInName', '');
    form?.updateFieldValue('crPass', '');
    form?.updateFieldValue('crName', '');

    form?.updateFieldValue('sortID', nextSort);

    form?.updateFieldValue('mfgDeptCode', null);

    form?.updateFieldValue('crEdit', 'Y');
    form?.updateFieldValue('crDel', 'Y');
    form?.updateFieldValue('autoRec', 'Y');

    form?.updateFieldValue('empIssRec', 'N');
    form?.updateFieldValue('empRecWt', 'N');

    form?.updateFieldValue('laserPlanRec', 'Y');
    form?.updateFieldValue('polishOut', 'N');

    form?.updateFieldValue('stockLimit', '');
    form?.updateFieldValue('target', '');

    form?.updateFieldValue('kachaIss', 'N');

    form?.updateFieldValue('manType', 'Days');
    form?.updateFieldValue('manPktDayLimit', '');
    form?.updateFieldValue('manPktHourLimit', '');

    form?.updateFieldValue('empType', 'Days');
    form?.updateFieldValue('empPktDayLimit', '');
    form?.updateFieldValue('empPktHourLimit', '');
    form?.updateFieldValue('empPktLimit', '');
    form?.updateFieldValue('empPktLimit', '');

    /// ── FORCE UPDATE IMPORTANT FIELDS ───────

    _erpFormKey.currentState?.updateFieldValue('sortID', nextSort);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Consumer<CounterProvider>(
          builder: (context, counterProvider, _) {
            final isMobile = Responsive.isMobile(context);
            if (isMobile && (_showSearch || _showTableOnMobile)) {
              return Padding(
                padding: const EdgeInsets.all(8),
                child: _buildTable(counterProvider),
              );
            }
            return Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: _showSearch ? 2 : 1,
                    child: _buildFormWrapper(),
                  ),
                  if (_showSearch) ...[
                    const SizedBox(width: 12),
                    Expanded(flex: 2, child: _buildTable(counterProvider)),
                  ],
                ],
              ),
            );
          },
        ),
        if (_isSaving)
          Container(
            color: Colors.black.withOpacity(0.4),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 28,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 12)],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(AppImages.logo, height: 60),
                    const SizedBox(height: 16),
                    CircularProgressIndicator(color: _theme.primary),
                    const SizedBox(height: 12),
                    Text(
                      'Saving...',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _theme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ── FORM WRAPPER ──────────────────────────────────────────────────────────
  Widget _buildFormWrapper() {
    return Consumer5<
      CounterTypeProvider,
      DivisionProvider,
      DeptGroupProvider,
      DeptProvider,
      TeamProvider
    >(
      builder: (context, ctP, divP, dgP, deptP, teamP, _) {
        final counterTypeItems = ctP.list
            .map(
              (e) => ErpDropdownItem(
                label: e.counterTypeName ?? '',
                value: e.counterTypeCode?.toString() ?? '',
              ),
            )
            .toList();
        final divisionItems = divP.divisions
            .map(
              (e) => ErpDropdownItem(
                label: e.divisionName ?? '',
                value: e.divisionCode?.toString() ?? '',
              ),
            )
            .toList();
        final deptGroupItems = dgP.list
            .map(
              (e) => ErpDropdownItem(
                label: e.deptGroupName ?? '',
                value: e.deptGroupCode?.toString() ?? '',
              ),
            )
            .toList();

        final filteredDepts = _selectedDeptGroupCode != null
            ? deptP.list
                  .where(
                    (e) =>
                        e.deptGroupCode?.toString() == _selectedDeptGroupCode,
                  )
                  .toList()
            : deptP.list;
        final departmentItems = filteredDepts
            .map(
              (e) => ErpDropdownItem(
                label: e.deptName ?? '',
                value: e.deptCode?.toString() ?? '',
              ),
            )
            .toList();
        final mfgDeptItems = filteredDepts
            .map(
              (e) => ErpDropdownItem(
                label: e.deptName ?? '',
                value: e.deptCode?.toString() ?? '',
              ),
            )
            .toList();
        final teamItems = teamP.list
            .map(
              (e) => ErpDropdownItem(
                label: e.teamName ?? '',
                value: e.teamCode?.toString() ?? '',
              ),
            )
            .toList();

        return Consumer5<
          UserVisibilityProvider,
          MainMenuMstProvider,
          MenuMstProvider,
          CounterOperatorDetProvider,
          CounterManagerDetProvider
        >(
          builder: (context, visP, mainMenuP, menuP, opP, mgP, _) {
            final tabsEnabled = _savedCrId != null;
            return ErpForm(
              logo: AppImages.logo,
              isFirstTabSave: true,
              title: 'COUNTER MASTER',
              subtitle: 'Counter Configuration',
              tabs: const [
                'BASIC',
                'PROCESS',
                'SELECT RIGHTS',
                'ALLOW MANAGER ISSUE',
                'ALLOW MANAGER RECEIVE',
                'ALLOW OPERATOR',
                'ALLOW MANAGER',
                'ALLOW DEPARTMENT',
                'SHAPE LOCK',
                'ALLOW STOCK TYPE',
                'REPORT RIGHTS',
              ],
              initialTabIndex: _currentTabIndex,
              tabBarBackgroundColor: const Color(0xFFF1F5F9),
              tabBarSelectedColor: _theme.primaryGradient.first,
              tabBarSelectedTxtColor: Colors.white,
              onTabChanged: (i) => setState(() => _currentTabIndex = i),
              rows: _buildFormRows(
                counterTypeItems: counterTypeItems,
                divisionItems: divisionItems,
                deptGroupItems: deptGroupItems,
                departmentItems: departmentItems,
                teamItems: teamItems,
                mfgDeptItems: mfgDeptItems,
                dgP: dgP,
              ),
              initialValues: _formValues,
              isEditMode: _isEditMode,
              isShowSearch: true,
              onSearch: () => setState(() => _showSearch = !_showSearch),
              onFieldChanged: (key, value) {
                _formValues[key] = value;
                if (key == 'deptGroupCode') {
                  setState(() {
                    _selectedDeptGroupCode = value.isEmpty ? null : value;
                    _formValues['deptCode'] = '';
                    _formValues['mfgDeptCode'] = '';
                    _erpFormKey.currentState?.updateFieldValue(
                      'deptCode',
                      null,
                    );
                    _erpFormKey.currentState?.updateFieldValue(
                      'mfgDeptCode',
                      null,
                    );
                  });
                }
                if (key == 'deptCode')
                  setState(
                    () => _selectedDeptCode = value.isEmpty ? null : value,
                  );
                if (key == 'manType') setState(() => _selectedManType = value);
                if (key == 'empType') setState(() => _selectedEmpType = value);
              },
              onSave: _onSave,
              onCancel: _resetForm,
              onDelete: _isEditMode ? _onDelete : null,
              detailBuilder: (ctx) => _buildTabDetail(
                visP,
                mainMenuP,
                menuP,
                opP,
                mgP,
                tabsEnabled,
                counterTypeItems,
                divisionItems,
                deptGroupItems,
                departmentItems,
                teamItems,
                mfgDeptItems,
              ),
            );
          },
        );
      },
    );
  }

  List<List<ErpFieldConfig>> _buildFormRows({
    required List<ErpDropdownItem> counterTypeItems,
    required List<ErpDropdownItem> divisionItems,
    required List<ErpDropdownItem> deptGroupItems,
    required List<ErpDropdownItem> departmentItems,
    required List<ErpDropdownItem> teamItems,
    required List<ErpDropdownItem> mfgDeptItems,
    required DeptGroupProvider dgP,
  }) {
    final selectedGroup = dgP.list.firstWhereOrNull(
      (e) => e.deptGroupCode?.toString() == _selectedDeptGroupCode,
    );

    final isMfg = (selectedGroup?.deptGroupName ?? '').toUpperCase().contains(
      'MFG',
    );
    return [
      [
        ErpFieldConfig(
          key: 'counterTypeCode',
          label: 'TYPE',
          type: ErpFieldType.dropdown,
          dropdownItems: counterTypeItems,
          sectionTitle: 'BASIC INFORMATION',
          sectionIndex: 0,
          tabIndex: 0,
        ),
        ErpFieldConfig(
          key: 'divisionCode',
          label: 'DIVISION',
          type: ErpFieldType.dropdown,
          dropdownItems: divisionItems,
          sectionIndex: 0,
          tabIndex: 0,
          required: true,
        ),
        ErpFieldConfig(
          key: 'deptGroupCode',
          label: 'GROUP',
          type: ErpFieldType.dropdown,
          dropdownItems: deptGroupItems,
          sectionIndex: 0,
          tabIndex: 0,
          required: true,
        ),
        ErpFieldConfig(
          key: 'deptCode',
          label: 'DEPARTMENT',
          type: ErpFieldType.dropdown,
          dropdownItems: departmentItems,
          sectionIndex: 0,
          tabIndex: 0,
          required: true,
        ),
      ],
      [
        ErpFieldConfig(
          key: 'teamCode',
          label: 'TEAM',
          type: ErpFieldType.dropdown,
          dropdownItems: teamItems,
          sectionIndex: 0,
          tabIndex: 0,
          required: true,
        ),
        ErpFieldConfig(
          key: 'userGrp',
          label: 'RIGHTS',
          type: ErpFieldType.dropdown,
          dropdownItems: const [
            ErpDropdownItem(label: 'Admin', value: 'Admin'),
            ErpDropdownItem(label: 'User', value: 'User'),
          ],
          sectionIndex: 0,
          tabIndex: 0,
          required: true,
        ),
        ErpFieldConfig(
          key: 'logInName',
          label: 'LOGIN NAME',
          required: true,
          sectionIndex: 0,
          tabIndex: 0,
        ),
        ErpFieldConfig(
          key: 'crPass',
          label: 'PASSWORD',
          sectionIndex: 0,
          tabIndex: 0,
          required: true,
        ),
      ],
      [
        ErpFieldConfig(
          key: 'crName',
          label: 'NAME',
          required: true,
          sectionIndex: 0,
          tabIndex: 0,
          inputFormatters: [UpperCaseTextFormatter()],
          onDuplicateCheck: (value, allValues) async {
            return await _checkDuplicate(fields: {'CrName': value});
          },
        ),
        ErpFieldConfig(
          key: 'sortID',
          label: 'SORT ID',
          type: ErpFieldType.number,
          sectionIndex: 0,
          tabIndex: 0,
          initialDropValue: true,
          required: true,
        ),
        ErpFieldConfig(
          key: 'mfgDeptCode',
          label: 'MFG RATE ON DEPT',
          type: ErpFieldType.dropdown,
          dropdownItems: isMfg ? mfgDeptItems : const [],

          readOnly: !isMfg,
          sectionIndex: 0,
          tabIndex: 0,
        ),
        // ErpFieldConfig(key: 'mfgDeptCode', label: 'MFG RATE ON DEPT', type: ErpFieldType.dropdown, dropdownItems: mfgDeptItems, sectionIndex: 0, tabIndex: 0),
        ErpFieldConfig(
          key: 'active',
          label: 'ACTIVE',
          type: ErpFieldType.checkbox,
          checkboxDbType: 'BIT',
          sectionIndex: 0,
          tabIndex: 0,
          initialBoolValue: true,
        ),
      ],
      [
        ErpFieldConfig(
          key: 'crEdit',
          label: 'EDIT',
          type: ErpFieldType.dropdown,
          dropdownItems: _ynItems,
          sectionTitle: 'PERMISSIONS',
          sectionIndex: 1,
          tabIndex: 0,
          initialDropValue: true,
        ),
        ErpFieldConfig(
          key: 'crDel',
          label: 'DELETE',
          type: ErpFieldType.dropdown,
          dropdownItems: _ynItems,
          sectionIndex: 1,
          tabIndex: 0,
          initialDropValue: true,
        ),
        ErpFieldConfig(
          key: 'autoRec',
          label: 'CONFIRM REC',
          type: ErpFieldType.dropdown,
          dropdownItems: _ynItems,
          sectionIndex: 1,
          tabIndex: 0,
          initialDropValue: true,
        ),
        ErpFieldConfig(
          key: 'empIssRec',
          label: 'EMP ISS REC',
          type: ErpFieldType.dropdown,
          dropdownItems: _ynItems,
          sectionIndex: 1,
          tabIndex: 0,
          initialDropValue: true,
          initialDropIndex: 1,
        ),
        ErpFieldConfig(
          key: 'empRecWt',
          label: 'EMP REC WT',
          type: ErpFieldType.dropdown,
          dropdownItems: _ynItems,
          sectionIndex: 1,
          tabIndex: 0,
          initialDropValue: true,
          initialDropIndex: 1,
        ),
        ErpFieldConfig(
          key: 'laserPlanRec',
          label: 'LASER PLAN REC',
          type: ErpFieldType.dropdown,
          dropdownItems: _ynItems,
          sectionIndex: 1,
          tabIndex: 0,
          initialDropValue: true,
        ),
      ],
      [
        ErpFieldConfig(
          key: 'polishOut',
          label: 'POLISH OUT',
          type: ErpFieldType.dropdown,
          dropdownItems: _ynItems,
          sectionIndex: 1,
          tabIndex: 0,
          initialDropValue: true,
          initialDropIndex: 1,
        ),
        ErpFieldConfig(
          key: 'stockLimit',
          label: 'STOCK LIMIT',
          type: ErpFieldType.number,
          sectionIndex: 1,
          tabIndex: 0,
        ),
        ErpFieldConfig(
          key: 'target',
          label: 'TARGET',
          type: ErpFieldType.number,
          sectionIndex: 1,
          tabIndex: 0,
        ),
        ErpFieldConfig(
          key: 'kachaIss',
          label: 'KACHA ISS',
          type: ErpFieldType.dropdown,
          dropdownItems: _ynItems,
          sectionIndex: 1,
          tabIndex: 0,
          initialDropValue: true,
          initialDropIndex: 1,
        ),
      ],
      [
        ErpFieldConfig(
          key: 'manType',
          label: 'MAN TYPE',
          type: ErpFieldType.dropdown,
          initialDropValue: true,
          dropdownItems: const [
            ErpDropdownItem(label: 'Days', value: 'Days'),
            ErpDropdownItem(label: 'Hours', value: 'Hours'),
          ],
          sectionTitle: 'LIMITS',
          sectionIndex: 2,
          tabIndex: 0,
        ),
        ErpFieldConfig(
          key: 'manPktDayLimit',
          label: 'MAN PKT DAY LIMIT',
          type: ErpFieldType.number,
          readOnly: _selectedManType == 'Hours',
          sectionIndex: 2,
          tabIndex: 0,
        ),
        ErpFieldConfig(
          key: 'manPktHourLimit',
          label: 'MAN PKT HOUR LIMIT',
          type: ErpFieldType.number,
          readOnly: _selectedManType == 'Days',
          sectionIndex: 2,
          tabIndex: 0,
        ),
      ],
      [
        ErpFieldConfig(
          key: 'empType',
          label: 'EMP TYPE',
          type: ErpFieldType.dropdown,
          initialDropValue: true,
          dropdownItems: const [
            ErpDropdownItem(label: 'Days', value: 'Days'),
            ErpDropdownItem(label: 'Hours', value: 'Hours'),
          ],
          sectionIndex: 2,
          tabIndex: 0,
        ),
        ErpFieldConfig(
          key: 'empPktDayLimit',
          label: 'EMP PKT DAY LIMIT',
          type: ErpFieldType.number,
          readOnly: _selectedEmpType == 'Hours',
          sectionIndex: 2,
          tabIndex: 0,
        ),
        ErpFieldConfig(
          key: 'empPktHourLimit',
          label: 'EMP PKT HOUR LIMIT',
          type: ErpFieldType.number,
          readOnly: _selectedEmpType == 'Days',
          sectionIndex: 2,
          tabIndex: 0,
        ),
        ErpFieldConfig(
          key: 'empPktLimit',
          label: 'EMP PKT LIMIT',
          type: ErpFieldType.number,
          sectionIndex: 2,
          tabIndex: 0,
        ),
      ],
    ];
  }

  Future<bool> _checkDuplicate({required Map<dynamic, dynamic> fields}) async {
    /// ── SKIP SAME VALUE IN EDIT ───────────────
    final skip = shouldSkipDuplicateCheck(
      isEditMode: _isEditMode,
      selectedRow: _selectedRow,
      newFields: Map<String, dynamic>.from(fields),
      fieldMapping: {'CrName': 'crName'},
    );

    if (skip) {
      debugPrint('⏩ DUPLICATE CHECK SKIPPED');
      return false;
    }

    /// ── API CHECK ─────────────────────────────
    return await checkDuplicateRecord(
      context: context,
      theme: _theme,
      formName: 'Counter',
      fields: fields,
    );
  }

  // ── DETAIL BUILDER ────────────────────────────────────────────────────────
  Widget _buildTabDetail(
    UserVisibilityProvider visP,
    MainMenuMstProvider mainMenuP,
    MenuMstProvider menuP,
    CounterOperatorDetProvider opP,
    CounterManagerDetProvider mgP,
    bool tabsEnabled,
    List<ErpDropdownItem> counterTypeItems,
    List<ErpDropdownItem> divisionItems,
    List<ErpDropdownItem> deptGroupItems,
    List<ErpDropdownItem> departmentItems,
    List<ErpDropdownItem> teamItems,
    List<ErpDropdownItem> mfgDeptItems,
  ) {
    final theme = context.erpTheme;
    // Tab 0 pe BASIC already form mein hai — skip
    // Tab 1-9 pe BASIC editable summary dikhao
    Widget basicSummary() {
      if (_currentTabIndex == 0) return const SizedBox.shrink();
      return _buildBasicInfoSummary(
        theme,
        counterTypeItems,
        divisionItems,
        deptGroupItems,
        departmentItems,
        teamItems,
        mfgDeptItems,
      );
    }

    Widget content() {
      switch (_currentTabIndex) {
        case 0:
          return _buildDisplaySetting(visP, theme);
        case 1:
          return _buildProcessTab(theme);
        case 2:
          return _buildMenuRightsTree(mainMenuP, menuP, theme);
        case 3:
          return _buildAllowManagerIssueTab(theme);
        case 4:
          return _buildAllowManagerReceiveTab(theme);
        case 5:
          return _buildAllowOperatorTab(opP, theme);
        case 6:
          return _buildAllowManagerTab(opP, theme);
        case 7:
          return _buildAllowDeptTab(theme);
        case 8:
          return _buildShapeLockTab(theme);
        case 9:
          return _buildAllowStockTypeTab(theme);
        case 10:
          return _buildReportRightsTab(theme);
        default:
          return const SizedBox.shrink();
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [basicSummary(), content()],
    );
  }

  // ── BASIC INFO SUMMARY (editable, shown in Tab 1-9) ───────────────────────
  Widget _buildBasicInfoSummary(
    ErpTheme theme,
    List<ErpDropdownItem> counterTypeItems,
    List<ErpDropdownItem> divisionItems,
    List<ErpDropdownItem> deptGroupItems,
    List<ErpDropdownItem> departmentItems,
    List<ErpDropdownItem> teamItems,
    List<ErpDropdownItem> mfgDeptItems,
  ) {
    final rightsItems = [
      ErpDropdownItem(label: 'Admin', value: 'Admin'),
      ErpDropdownItem(label: 'User', value: 'User'),
    ];

    InputDecoration dec = InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: theme.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: theme.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: theme.primary, width: 1.5),
      ),
    );
    Widget dropField(
      String label,
      String key,
      List<ErpDropdownItem> items, {
      bool req = false,
      bool enabled = true,
    }) {
      final raw = _formValues[key];
      final val = (raw == null || raw.isEmpty) ? null : raw;
      final validVal = items.any((e) => e.value == val) ? val : null;
      return _BasicField(
        label: label,
        required: req,
        child: IgnorePointer(
          ignoring: !enabled,
          child: Opacity(
            opacity: enabled ? 1.0 : 0.45,
            child: DropdownButtonFormField<String>(
              value: validVal,
              isDense: true,
              isExpanded: true,
              style: TextStyle(fontSize: 11, color: theme.text),
              decoration: dec.copyWith(
                filled: true,
                fillColor: enabled ? Colors.white : theme.bg,
              ),
              hint: Text(
                'Select $label',
                style: TextStyle(fontSize: 11, color: theme.textLight),
              ),
              items: items
                  .map(
                    (e) => DropdownMenuItem<String>(
                      value: e.value,
                      child: Text(
                        e.label,
                        style: TextStyle(fontSize: 11, color: theme.text),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: enabled
                  ? (v) => setState(() {
                      _formValues[key] = v ?? '';
                      if (key == 'deptGroupCode') {
                        _selectedDeptGroupCode = (v == null || v.isEmpty)
                            ? null
                            : v;
                        _formValues['deptCode'] = '';
                        _formValues['mfgDeptCode'] = '';
                      }
                      if (key == 'deptCode') {
                        _selectedDeptCode = (v == null || v.isEmpty) ? null : v;
                      }
                    })
                  : null,
            ),
          ),
        ),
      );
    }

    Widget txtField(
      String label,
      String key, {
      bool req = false,
      bool num = false,
      bool autoCapital = false,
    }) {
      final controller = TextEditingController(text: _formValues[key] ?? '');

      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length),
      );

      return _BasicField(
        label: label,
        required: req,
        child: TextFormField(
          controller: controller,
          textCapitalization: autoCapital
              ? TextCapitalization.characters
              : TextCapitalization.none,

          style: TextStyle(fontSize: 11, color: theme.text),

          keyboardType: num ? TextInputType.number : TextInputType.text,

          decoration: dec,

          onChanged: (v) {
            final value = autoCapital ? v.toUpperCase() : v;

            if (controller.text != value) {
              controller.value = TextEditingValue(
                text: value,
                selection: TextSelection.collapsed(offset: value.length),
              );
            }

            setState(() {
              _formValues[key] = value;
            });
          },
        ),
      );
    }

    // ── checkbox field helper ──
    Widget checkField(String label, String key) {
      final val = _formValues[key] == 'true' || _formValues[key] == '1';
      return _BasicField(
        label: '',
        child: Row(
          children: [
            Checkbox(
              value: val,
              activeColor: theme.primary,
              visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onChanged: (v) => setState(
                () => _formValues[key] = (v == true) ? 'true' : 'false',
              ),
            ),
            Text(label, style: TextStyle(fontSize: 11, color: theme.text)),
          ],
        ),
      );
    }

    final deptGroupName =
        deptGroupItems
            .firstWhereOrNull((e) => e.value == _formValues['deptGroupCode'])
            ?.label ??
        '';
    final isMfgGroup = deptGroupName.toUpperCase().contains('MFG');
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.primary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.primary.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: theme.primaryGradient
                    .map((c) => c.withOpacity(0.15))
                    .toList(),
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(10),
              ),
              border: Border(
                bottom: BorderSide(color: theme.primary.withOpacity(0.15)),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.person_outline_rounded,
                  size: 13,
                  color: theme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'BASIC INFORMATION',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: theme.primary,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),

          // ── Fields ──
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                // Row 1: TYPE, DIVISION, GROUP, DEPARTMENT
                Row(
                  children: [
                    Expanded(
                      child: dropField(
                        'TYPE',
                        'counterTypeCode',
                        counterTypeItems,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: dropField(
                        'DIVISION',
                        'divisionCode',
                        divisionItems,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: dropField(
                        'GROUP',
                        'deptGroupCode',
                        deptGroupItems,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: dropField(
                        'DEPARTMENT',
                        'deptCode',
                        departmentItems,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Row 2: TEAM, RIGHTS, LOGIN NAME, PASSWORD
                Row(
                  children: [
                    Expanded(child: dropField('TEAM', 'teamCode', teamItems)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: dropField('RIGHTS', 'userGrp', rightsItems),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: txtField('LOGIN NAME', 'logInName', req: true),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: txtField('PASSWORD', 'crPass')),
                  ],
                ),
                const SizedBox(height: 6),

                // Row 3: NAME, SORT ID, MFG RATE ON DEPT, ACTIVE
                Row(
                  children: [
                    Expanded(
                      child: txtField(
                        'NAME',
                        'crName',
                        req: true,
                        autoCapital: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: txtField('SORT ID', 'sortID', num: true)),
                    const SizedBox(width: 8),

                    Expanded(
                      child: dropField(
                        'MFG RATE ON DEPT',
                        'mfgDeptCode',
                        mfgDeptItems,
                        enabled: isMfgGroup,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: checkField('ACTIVE', 'active')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _lockedMsg(ErpTheme theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline_rounded,
            size: 32,
            color: theme.textLight.withOpacity(0.4),
          ),
          const SizedBox(height: 8),
          Text(
            'Please save the BASIC tab first.',
            style: TextStyle(fontSize: 12, color: theme.textLight),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDisplaySetting(UserVisibilityProvider visP, ErpTheme theme) {
    final deptItems =
        visP.list.where((e) => e.entryType?.toUpperCase() == 'DEPT').toList()
          ..sort((a, b) {
            // ✅ Pehle type wise, phir sortId wise
            final typeCompare = (a.entryType ?? '').compareTo(
              b.entryType ?? '',
            );
            if (typeCompare != 0) return typeCompare;
            return (a.sortID ?? 0).compareTo(b.sortID ?? 0);
          });

    final toItems = deptItems.isNotEmpty ? deptItems : visP.list;

    // ✅ visP.list bhi sort karo (From Display Setting ke liye)
    final sortedList = [...visP.list]
      ..sort((a, b) {
        final typeCompare = (a.entryType ?? '').compareTo(b.entryType ?? '');
        if (typeCompare != 0) return typeCompare;
        return (a.sortID ?? 0).compareTo(b.sortID ?? 0);
      });
    if (visP.list.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionHeader(theme, 'DISPLAY SETTING'),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _DisplayCheckboxPanel(
                  theme: theme,
                  title: 'From Display Setting',
                  items: sortedList,
                  selected: _fromSelected,
                  onChanged: (code, val) => setState(() {
                    if (val) {
                      _fromSelected.add(code);
                    } else {
                      _fromSelected.remove(code);
                    }
                  }),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DisplayCheckboxPanel(
                  theme: theme,
                  title: 'To Display Setting',
                  items: toItems,
                  selected: _toSelected,
                  onChanged: (code, val) => setState(() {
                    if (val) {
                      _toSelected.add(code);
                    } else {
                      _toSelected.remove(code);
                    }
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProcessTab(ErpTheme theme) {
    return Consumer<DeptProcessProvider>(
      builder: (context, procP, _) {
        final deptCode = _selectedDeptCode;
        if (deptCode == null || deptCode.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Please select a Department in BASIC tab first.',
              style: TextStyle(fontSize: 12, color: theme.textLight),
              textAlign: TextAlign.center,
            ),
          );
        }
        final filtered = procP.list
            .where((p) => p.deptCode?.toString() == deptCode)
            .toList();

        final allProcessCodes = filtered
            .where((e) => e.deptProcessCode != null)
            .map((e) => e.deptProcessCode!)
            .toSet();

        final allSelected =
            allProcessCodes.isNotEmpty &&
            allProcessCodes.every((e) => _selectedProcessCodes.contains(e));

        final someSelected = allProcessCodes.any(
          (e) => _selectedProcessCodes.contains(e),
        );

        if (filtered.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'No processes found for selected department.',
              style: TextStyle(fontSize: 12, color: theme.textLight),
              textAlign: TextAlign.center,
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _sectionHeader(theme, 'DEPT PROCESSES'),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: theme.primary.withOpacity(.06),
                  borderRadius: BorderRadius.circular(8),
                ),

                child: Row(
                  children: [
                    Checkbox(
                      value: allSelected
                          ? true
                          : someSelected
                          ? null
                          : false,

                      tristate: true,

                      activeColor: theme.primary,

                      onChanged: (_) {
                        setState(() {
                          if (allSelected) {
                            _selectedProcessCodes.removeAll(allProcessCodes);
                          } else {
                            _selectedProcessCodes.addAll(allProcessCodes);
                          }
                        });
                      },
                    ),

                    Text(
                      'Select All Processes',

                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: theme.text,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: theme.border),
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 13,
                    crossAxisSpacing: 0,
                    mainAxisSpacing: 0,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) {
                    final proc = filtered[i];
                    final code = proc.deptProcessCode ?? 0;
                    final checked = _selectedProcessCodes.contains(code);
                    return InkWell(
                      onTap: () => setState(() {
                        if (checked) {
                          _selectedProcessCodes.remove(code);
                        } else {
                          _selectedProcessCodes.add(code);
                        }
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: checked
                              ? theme.primary.withOpacity(0.07)
                              : i ~/ 2 % 2 == 0
                              ? Colors.white
                              : theme.bg.withOpacity(0.4),
                          border: Border(
                            bottom: BorderSide(
                              color: theme.border.withOpacity(0.4),
                            ),
                            right: i % 2 == 0
                                ? BorderSide(
                                    color: theme.border.withOpacity(0.4),
                                  )
                                : BorderSide.none,
                          ),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 18,
                              height: 22,
                              child: Checkbox(
                                value: checked,
                                activeColor: theme.primary,
                                onChanged: (v) => setState(() {
                                  if (v == true) {
                                    _selectedProcessCodes.add(code);
                                  } else {
                                    _selectedProcessCodes.remove(code);
                                  }
                                }),
                                visualDensity: const VisualDensity(
                                  vertical: -4,
                                  horizontal: -4,
                                ),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                proc.deptProcessName ?? '',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: checked ? theme.primary : theme.text,
                                  fontWeight: checked
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            Text(
                              code.toString(),
                              style: TextStyle(
                                fontSize: 9,
                                color: theme.textLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAllowManagerIssueTab(ErpTheme theme) {
    return Consumer2<CounterProvider, DeptProcessProvider>(
      builder: (context, counterP, procP, _) {
        final deptProvider = context.read<DeptProvider>();
        final allDepts = List.of(deptProvider.list)
          ..sort((a, b) => (a.sortID ?? 0).compareTo(b.sortID ?? 0));
        if (allDepts.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'No departments found.',
              style: TextStyle(fontSize: 12, color: theme.textLight),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _sectionHeader(theme, 'ALLOW MANAGER ISSUE'),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: theme.border),
                ),
                child: Column(
                  children: allDepts.asMap().entries.map((dEntry) {
                    final dept = dEntry.value;
                    final deptCode = dept.deptCode ?? 0;
                    final isDeptOpen = _expandedIssueDepts.contains(deptCode);
                    final deptCounters = counterP.list
                        .where(
                          (c) => c.deptCode == deptCode && c.active == true,
                        )
                        .toList();
                    if (deptCounters.isEmpty) return const SizedBox.shrink();
                    final deptSelectedCount = deptCounters
                        .where(
                          (c) =>
                              (_managerIssueSelected[c.crId ?? 0]?.isNotEmpty ??
                              false),
                        )
                        .length;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        InkWell(
                          onTap: () => setState(() {
                            if (isDeptOpen) {
                              _expandedIssueDepts.remove(deptCode);
                            } else {
                              _expandedIssueDepts.add(deptCode);
                            }
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isDeptOpen
                                  ? theme.primary.withOpacity(0.08)
                                  : theme.bg,
                              border: Border(
                                top: dEntry.key == 0
                                    ? BorderSide.none
                                    : BorderSide(color: theme.border),
                              ),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 18,
                                  height: 22,
                                  child: Checkbox(
                                    activeColor: theme.primary,
                                    visualDensity: const VisualDensity(
                                      vertical: -4,
                                      horizontal: -4,
                                    ),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    tristate: true,
                                    value: () {
                                      final allProcs = deptCounters.expand((c) {
                                        final cId = c.crId ?? 0;
                                        return procP.list
                                            .where(
                                              (p) => p.deptCode == c.deptCode,
                                            )
                                            .map(
                                              (p) => MapEntry(
                                                cId,
                                                p.deptProcessCode ?? 0,
                                              ),
                                            );
                                      }).toList();
                                      if (allProcs.isEmpty) return false;
                                      final allSel = allProcs.every(
                                        (e) =>
                                            _managerIssueSelected[e.key]
                                                ?.contains(e.value) ??
                                            false,
                                      );
                                      final anySel = allProcs.any(
                                        (e) =>
                                            _managerIssueSelected[e.key]
                                                ?.contains(e.value) ??
                                            false,
                                      );
                                      return allSel
                                          ? true
                                          : anySel
                                          ? null
                                          : false;
                                    }(),
                                    onChanged: (v) => setState(() {
                                      for (final c in deptCounters) {
                                        final cId = c.crId ?? 0;
                                        final procs = procP.list
                                            .where(
                                              (p) => p.deptCode == c.deptCode,
                                            )
                                            .map((p) => p.deptProcessCode ?? 0);
                                        if (v == true) {
                                          _managerIssueSelected
                                              .putIfAbsent(cId, () => {})
                                              .addAll(procs);
                                        } else {
                                          _managerIssueSelected.remove(cId);
                                        }
                                      }
                                    }),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                AnimatedRotation(
                                  turns: isDeptOpen ? 0 : -0.25,
                                  duration: const Duration(milliseconds: 180),
                                  child: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 16,
                                    color: theme.primary,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.business_rounded,
                                  size: 13,
                                  color: theme.primary,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    dept.deptName ?? '',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: theme.primary,
                                    ),
                                  ),
                                ),
                                if (deptSelectedCount > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.primary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '$deptSelectedCount',
                                      style: const TextStyle(
                                        fontSize: 9,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        if (isDeptOpen)
                          ...deptCounters.asMap().entries.map((cEntry) {
                            final counter = cEntry.value;
                            final crId = counter.crId ?? 0;
                            final isCounterOpen = _expandedIssueCounters
                                .contains(crId);
                            final selectedProcs =
                                _managerIssueSelected[crId] ?? {};
                            final counterProcs = procP.list
                                .where((p) => p.deptCode == counter.deptCode)
                                .toList();
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                InkWell(
                                  onTap: () => setState(() {
                                    if (isCounterOpen) {
                                      _expandedIssueCounters.remove(crId);
                                    } else {
                                      _expandedIssueCounters.add(crId);
                                    }
                                  }),
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                      left: 28,
                                      right: 10,
                                      top: 4,
                                      bottom: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isCounterOpen
                                          ? theme.primary.withOpacity(0.05)
                                          : cEntry.key.isEven
                                          ? Colors.white
                                          : theme.bg.withOpacity(0.4),
                                      border: Border(
                                        top: BorderSide(
                                          color: theme.border.withOpacity(0.5),
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 18,
                                          height: 22,
                                          child: Checkbox(
                                            activeColor: theme.primary,
                                            visualDensity: const VisualDensity(
                                              vertical: -4,
                                              horizontal: -4,
                                            ),
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                            tristate: true,
                                            value: () {
                                              if (counterProcs.isEmpty)
                                                return false;
                                              final allSel = counterProcs.every(
                                                (p) => selectedProcs.contains(
                                                  p.deptProcessCode ?? 0,
                                                ),
                                              );
                                              final anySel = counterProcs.any(
                                                (p) => selectedProcs.contains(
                                                  p.deptProcessCode ?? 0,
                                                ),
                                              );
                                              return allSel
                                                  ? true
                                                  : anySel
                                                  ? null
                                                  : false;
                                            }(),
                                            onChanged: (v) => setState(() {
                                              final set = _managerIssueSelected
                                                  .putIfAbsent(crId, () => {});
                                              if (v == true) {
                                                set.addAll(
                                                  counterProcs.map(
                                                    (p) =>
                                                        p.deptProcessCode ?? 0,
                                                  ),
                                                );
                                              } else {
                                                _managerIssueSelected.remove(
                                                  crId,
                                                );
                                              }
                                            }),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        AnimatedRotation(
                                          turns: isCounterOpen ? 0 : -0.25,
                                          duration: const Duration(
                                            milliseconds: 180,
                                          ),
                                          child: Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            size: 14,
                                            color: theme.primary.withOpacity(
                                              0.7,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Icon(
                                          Icons.person_outline_rounded,
                                          size: 12,
                                          color: theme.textLight,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            counter.crName ?? '',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: theme.text,
                                              fontWeight:
                                                  selectedProcs.isNotEmpty
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                        if (selectedProcs.isNotEmpty)
                                          Text(
                                            '${selectedProcs.length}/${counterProcs.length}',
                                            style: TextStyle(
                                              fontSize: 9,
                                              color: theme.primary,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (isCounterOpen)
                                  ...counterProcs.asMap().entries.map((pEntry) {
                                    final proc = pEntry.value;
                                    final procCode = proc.deptProcessCode ?? 0;
                                    final isChecked = selectedProcs.contains(
                                      procCode,
                                    );
                                    return InkWell(
                                      onTap: () => setState(() {
                                        final set = _managerIssueSelected
                                            .putIfAbsent(crId, () => {});
                                        if (isChecked) {
                                          set.remove(procCode);
                                        } else {
                                          set.add(procCode);
                                        }
                                        if (set.isEmpty)
                                          _managerIssueSelected.remove(crId);
                                      }),
                                      child: Container(
                                        padding: const EdgeInsets.only(
                                          left: 52,
                                          right: 10,
                                          top: 3,
                                          bottom: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isChecked
                                              ? theme.primary.withOpacity(0.06)
                                              : Colors.white,
                                          border: Border(
                                            top: BorderSide(
                                              color: theme.border.withOpacity(
                                                0.4,
                                              ),
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 18,
                                              height: 22,
                                              child: Checkbox(
                                                value: isChecked,
                                                activeColor: theme.primary,
                                                onChanged: (v) => setState(() {
                                                  final set =
                                                      _managerIssueSelected
                                                          .putIfAbsent(
                                                            crId,
                                                            () => {},
                                                          );
                                                  if (v == true) {
                                                    set.add(procCode);
                                                  } else {
                                                    set.remove(procCode);
                                                  }
                                                  if (set.isEmpty)
                                                    _managerIssueSelected
                                                        .remove(crId);
                                                }),
                                                visualDensity:
                                                    const VisualDensity(
                                                      vertical: -4,
                                                      horizontal: -4,
                                                    ),
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                proc.deptProcessName ?? '',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: isChecked
                                                      ? theme.primary
                                                      : theme.text,
                                                  fontWeight: isChecked
                                                      ? FontWeight.w600
                                                      : FontWeight.normal,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                              ],
                            );
                          }),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAllowManagerReceiveTab(ErpTheme theme) {
    return Consumer2<CounterProvider, DeptProcessProvider>(
      builder: (context, counterP, procP, _) {
        final deptProvider = context.read<DeptProvider>();
        final allDepts = List.of(deptProvider.list)
          ..sort((a, b) => (a.sortID ?? 0).compareTo(b.sortID ?? 0));

        // ✅ Tab 1 (PROCESS) se selected processes
        if (_selectedProcessCodes.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Please select processes in PROCESS tab first.',
              style: TextStyle(fontSize: 12, color: theme.textLight),
              textAlign: TextAlign.center,
            ),
          );
        }

        // if (issueAllowCrIds.isEmpty) {
        //   return Padding(
        //     padding: const EdgeInsets.all(24),
        //     child: Text(
        //       'Please select counters in Allow Manager Issue tab first.',
        //       style: TextStyle(fontSize: 12, color: theme.textLight),
        //       textAlign: TextAlign.center,
        //     ),
        //   );
        // }

        // ✅ Tab 1 selected processes filter
        final matchProcs = procP.list
            .where((p) => _selectedProcessCodes.contains(p.deptProcessCode))
            .toList();

        return Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _sectionHeader(theme, 'ALLOW MANAGER RECEIVE'),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: theme.border),
                ),
                child: Column(
                  children: allDepts.asMap().entries.map((dEntry) {
                    final dept = dEntry.value;
                    final deptCode = dept.deptCode ?? 0;
                    final isDeptOpen = _expandedRecvDepts.contains(deptCode);

                    final deptCounters = counterP.list
                        .where(
                          (c) => c.deptCode == deptCode && c.active == true,
                          // &&
                          // issueAllowCrIds.contains(c.crId)
                        )
                        .toList();

                    if (deptCounters.isEmpty) return const SizedBox.shrink();

                    final deptSelectedCount = deptCounters
                        .where(
                          (c) =>
                              (_managerRecvSelected[c.crId ?? 0]?.isNotEmpty ??
                              false),
                        )
                        .length;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        InkWell(
                          onTap: () => setState(() {
                            if (isDeptOpen) {
                              _expandedRecvDepts.remove(deptCode);
                            } else {
                              _expandedRecvDepts.add(deptCode);
                            }
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isDeptOpen
                                  ? theme.primary.withOpacity(0.08)
                                  : theme.bg,
                              border: Border(
                                top: dEntry.key == 0
                                    ? BorderSide.none
                                    : BorderSide(color: theme.border),
                              ),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 18,
                                  height: 22,
                                  child: Checkbox(
                                    activeColor: theme.primary,
                                    visualDensity: const VisualDensity(
                                      vertical: -4,
                                      horizontal: -4,
                                    ),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    tristate: true,
                                    value: () {
                                      final allPairs = deptCounters.expand((c) {
                                        final cId = c.crId ?? 0;
                                        return matchProcs.map(
                                          (p) => MapEntry(
                                            cId,
                                            p.deptProcessCode ?? 0,
                                          ),
                                        );
                                      }).toList();
                                      if (allPairs.isEmpty) return false;
                                      final allSel = allPairs.every(
                                        (e) =>
                                            _managerRecvSelected[e.key]
                                                ?.contains(e.value) ??
                                            false,
                                      );
                                      final anySel = allPairs.any(
                                        (e) =>
                                            _managerRecvSelected[e.key]
                                                ?.contains(e.value) ??
                                            false,
                                      );
                                      return allSel
                                          ? true
                                          : anySel
                                          ? null
                                          : false;
                                    }(),
                                    onChanged: (v) => setState(() {
                                      for (final c in deptCounters) {
                                        final cId = c.crId ?? 0;
                                        if (v == true) {
                                          _managerRecvSelected
                                              .putIfAbsent(cId, () => {})
                                              .addAll(
                                                matchProcs.map(
                                                  (p) => p.deptProcessCode ?? 0,
                                                ),
                                              );
                                        } else {
                                          _managerRecvSelected.remove(cId);
                                        }
                                      }
                                    }),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                AnimatedRotation(
                                  turns: isDeptOpen ? 0 : -0.25,
                                  duration: const Duration(milliseconds: 180),
                                  child: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 16,
                                    color: theme.primary,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.business_rounded,
                                  size: 13,
                                  color: theme.primary,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    dept.deptName ?? '',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: theme.primary,
                                    ),
                                  ),
                                ),
                                if (deptSelectedCount > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.primary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '$deptSelectedCount',
                                      style: const TextStyle(
                                        fontSize: 9,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        if (isDeptOpen)
                          ...deptCounters.asMap().entries.map((cEntry) {
                            final counter = cEntry.value;
                            final crId = counter.crId ?? 0;
                            final isCounterOpen = _expandedRecvCounters
                                .contains(crId);
                            final selectedProcs =
                                _managerRecvSelected[crId] ?? {};

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                InkWell(
                                  onTap: () => setState(() {
                                    if (isCounterOpen) {
                                      _expandedRecvCounters.remove(crId);
                                    } else {
                                      _expandedRecvCounters.add(crId);
                                    }
                                  }),
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                      left: 28,
                                      right: 10,
                                      top: 4,
                                      bottom: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isCounterOpen
                                          ? theme.primary.withOpacity(0.05)
                                          : cEntry.key.isEven
                                          ? Colors.white
                                          : theme.bg.withOpacity(0.4),
                                      border: Border(
                                        top: BorderSide(
                                          color: theme.border.withOpacity(0.5),
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 18,
                                          height: 22,
                                          child: Checkbox(
                                            activeColor: theme.primary,
                                            visualDensity: const VisualDensity(
                                              vertical: -4,
                                              horizontal: -4,
                                            ),
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                            tristate: true,
                                            value: () {
                                              if (matchProcs.isEmpty)
                                                return false;
                                              final allSel = matchProcs.every(
                                                (p) => selectedProcs.contains(
                                                  p.deptProcessCode ?? 0,
                                                ),
                                              );
                                              final anySel = matchProcs.any(
                                                (p) => selectedProcs.contains(
                                                  p.deptProcessCode ?? 0,
                                                ),
                                              );
                                              return allSel
                                                  ? true
                                                  : anySel
                                                  ? null
                                                  : false;
                                            }(),
                                            onChanged: (v) => setState(() {
                                              final set = _managerRecvSelected
                                                  .putIfAbsent(crId, () => {});
                                              if (v == true) {
                                                set.addAll(
                                                  matchProcs.map(
                                                    (p) =>
                                                        p.deptProcessCode ?? 0,
                                                  ),
                                                );
                                              } else {
                                                _managerRecvSelected.remove(
                                                  crId,
                                                );
                                              }
                                            }),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        AnimatedRotation(
                                          turns: isCounterOpen ? 0 : -0.25,
                                          duration: const Duration(
                                            milliseconds: 180,
                                          ),
                                          child: Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            size: 14,
                                            color: theme.primary.withOpacity(
                                              0.7,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Icon(
                                          Icons.person_outline_rounded,
                                          size: 12,
                                          color: theme.textLight,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            counter.crName ?? '',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: theme.text,
                                              fontWeight:
                                                  selectedProcs.isNotEmpty
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                        if (selectedProcs.isNotEmpty)
                                          Text(
                                            '${selectedProcs.length}/${matchProcs.length}',
                                            style: TextStyle(
                                              fontSize: 9,
                                              color: theme.primary,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),

                                if (isCounterOpen)
                                  ...matchProcs.asMap().entries.map((pEntry) {
                                    final proc = pEntry.value;
                                    final procCode = proc.deptProcessCode ?? 0;
                                    final isChecked = selectedProcs.contains(
                                      procCode,
                                    );
                                    return InkWell(
                                      onTap: () => setState(() {
                                        final set = _managerRecvSelected
                                            .putIfAbsent(crId, () => {});
                                        if (isChecked) {
                                          set.remove(procCode);
                                        } else {
                                          set.add(procCode);
                                        }
                                        if (set.isEmpty)
                                          _managerRecvSelected.remove(crId);
                                      }),
                                      child: Container(
                                        padding: const EdgeInsets.only(
                                          left: 52,
                                          right: 10,
                                          top: 3,
                                          bottom: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isChecked
                                              ? theme.primary.withOpacity(0.06)
                                              : Colors.white,
                                          border: Border(
                                            top: BorderSide(
                                              color: theme.border.withOpacity(
                                                0.4,
                                              ),
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 18,
                                              height: 22,
                                              child: Checkbox(
                                                value: isChecked,
                                                activeColor: theme.primary,
                                                onChanged: (v) => setState(() {
                                                  final set =
                                                      _managerRecvSelected
                                                          .putIfAbsent(
                                                            crId,
                                                            () => {},
                                                          );
                                                  if (v == true) {
                                                    set.add(procCode);
                                                  } else {
                                                    set.remove(procCode);
                                                  }
                                                  if (set.isEmpty)
                                                    _managerRecvSelected.remove(
                                                      crId,
                                                    );
                                                }),
                                                visualDensity:
                                                    const VisualDensity(
                                                      vertical: -4,
                                                      horizontal: -4,
                                                    ),
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                proc.deptProcessName ?? '',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: isChecked
                                                      ? theme.primary
                                                      : theme.text,
                                                  fontWeight: isChecked
                                                      ? FontWeight.w600
                                                      : FontWeight.normal,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                              ],
                            );
                          }),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReportRightsTab(ErpTheme theme) {
    return Consumer3<TestProvider, ReportMstProvider, ReportTypeProvider>(
      builder: (context, testP, reportP, typeP, _) {
        final allTests = List.of(testP.list)
          ..sort((a, b) => (a.sortID ?? 0).compareTo(b.sortID ?? 0));

        if (allTests.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'No report types found.',
              style: TextStyle(fontSize: 12, color: theme.textLight),
              textAlign: TextAlign.center,
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _sectionHeader(theme, 'REPORT RIGHTS'),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: theme.border),
                ),
                child: Column(
                  children: allTests.asMap().entries.map((tEntry) {
                    final test = tEntry.value;
                    final testCode = test.testCode ?? 0;
                    final isExpanded = !_collapsedMainMenus.contains(
                      testCode + 10000,
                    ); // reuse collapsed set
                    final testReports =
                        reportP.list
                            .where((r) => r.testCode == testCode)
                            .toList()
                          ..sort(
                            (a, b) => (a.sortID ?? 0).compareTo(b.sortID ?? 0),
                          );

                    if (testReports.isEmpty) return const SizedBox.shrink();

                    final childIds = testReports
                        .where((r) => r.reportCode != null)
                        .map((r) => '${testCode}_${r.reportCode}')
                        .toSet();
                    final allChecked =
                        childIds.isNotEmpty &&
                        childIds.every(
                          (id) => _selectedReportKeys.contains(id),
                        );
                    final anyChecked = childIds.any(
                      (id) => _selectedReportKeys.contains(id),
                    );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        InkWell(
                          onTap: () => setState(() {
                            final key = testCode + 10000;
                            if (_collapsedMainMenus.contains(key)) {
                              _collapsedMainMenus.remove(key);
                            } else {
                              _collapsedMainMenus.add(key);
                            }
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: theme.bg,
                              border: Border(
                                top: tEntry.key == 0
                                    ? BorderSide.none
                                    : BorderSide(color: theme.border),
                              ),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 22,
                                  child: Checkbox(
                                    value: allChecked
                                        ? true
                                        : anyChecked
                                        ? null
                                        : false,
                                    tristate: true,
                                    activeColor: theme.primary,
                                    visualDensity: const VisualDensity(
                                      vertical: -4,
                                      horizontal: -4,
                                    ),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    onChanged: (v) => setState(() {
                                      if (!allChecked) {
                                        _selectedReportKeys.addAll(childIds);
                                      } else {
                                        _selectedReportKeys.removeAll(childIds);
                                      }
                                    }),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                AnimatedRotation(
                                  turns: isExpanded ? 0 : -0.25,
                                  duration: const Duration(milliseconds: 180),
                                  child: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 16,
                                    color: theme.primary,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.folder_outlined,
                                  size: 13,
                                  color: theme.primary,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Type: ${test.testName ?? ''}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: theme.primary,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${childIds.intersection(_selectedReportKeys).length}/${childIds.length}',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: theme.textLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isExpanded)
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 15,
                                  crossAxisSpacing: 0,
                                  mainAxisSpacing: 0,
                                ),
                            itemCount: testReports.length,
                            itemBuilder: (ctx, i) {
                              final report = testReports[i];
                              final code = report.reportCode ?? 0;

                              final uniqueKey = '${testCode}_$code';

                              final isChecked = _selectedReportKeys.contains(
                                uniqueKey,
                              );

                              return InkWell(
                                onTap: () => setState(() {
                                  if (isChecked) {
                                    _selectedReportKeys.remove(uniqueKey);
                                  } else {
                                    _selectedReportKeys.add(uniqueKey);
                                  }
                                }),
                                child: Container(
                                  padding: const EdgeInsets.only(
                                    left: 10,
                                    right: 6,
                                    top: 2,
                                    bottom: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isChecked
                                        ? theme.primary.withOpacity(0.06)
                                        : i ~/ 2 % 2 == 0
                                        ? Colors.white
                                        : theme.bg.withOpacity(0.4),
                                    border: Border(
                                      top: BorderSide(
                                        color: theme.border.withOpacity(0.4),
                                      ),
                                      right: i % 2 == 0
                                          ? BorderSide(
                                              color: theme.border.withOpacity(
                                                0.4,
                                              ),
                                            )
                                          : BorderSide.none,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 18,
                                        height: 22,
                                        child: Checkbox(
                                          value: isChecked,
                                          activeColor: theme.primary,
                                          onChanged: (v) => setState(() {
                                            if (v == true) {
                                              _selectedReportKeys.add(
                                                uniqueKey,
                                              );
                                            } else {
                                              _selectedReportKeys.remove(
                                                uniqueKey,
                                              );
                                            }
                                          }),
                                          visualDensity: const VisualDensity(
                                            vertical: -4,
                                            horizontal: -4,
                                          ),
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          report.reportName ?? '',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: isChecked
                                                ? theme.primary
                                                : theme.text,
                                            fontWeight: isChecked
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        // if (isExpanded)
                        //   ...testReports.asMap().entries.map((rEntry) {
                        //     final report    = rEntry.value;
                        //     final code      = report.reportCode ?? 0;
                        //     final isChecked = _selectedReportCodes.contains(code);
                        //     return InkWell(
                        //       onTap: () => setState(() {
                        //         if (isChecked) _selectedReportCodes.remove(code);
                        //         else           _selectedReportCodes.add(code);
                        //       }),
                        //       child: Container(
                        //         padding: const EdgeInsets.only(left: 44, right: 10, top: 3, bottom: 3),
                        //         decoration: BoxDecoration(
                        //           color: isChecked ? theme.primary.withOpacity(0.06) : Colors.white,
                        //           border: Border(top: BorderSide(color: theme.border.withOpacity(0.5))),
                        //         ),
                        //         child: Row(children: [
                        //           SizedBox(width: 18, height: 22,
                        //             child: Checkbox(
                        //               value: isChecked,
                        //               activeColor: theme.primary,
                        //               visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
                        //               materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        //               onChanged: (v) => setState(() {
                        //                 if (v == true) _selectedReportCodes.add(code);
                        //                 else           _selectedReportCodes.remove(code);
                        //               }),
                        //             ),
                        //           ),
                        //           const SizedBox(width: 8),
                        //           Icon(Icons.description_outlined, size: 11, color: theme.textLight),
                        //           const SizedBox(width: 6),
                        //           Expanded(child: Text(report.reportName ?? '',
                        //               style: TextStyle(fontSize: 11,
                        //                   color: isChecked ? theme.primary : theme.text,
                        //                   fontWeight: isChecked ? FontWeight.w600 : FontWeight.normal))),
                        //         ]),
                        //       ),
                        //     );
                        //   }),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuRightsTree(
    MainMenuMstProvider mainMenuP,
    MenuMstProvider menuP,
    ErpTheme theme,
  ) {
    final allMainMenus = mainMenuP.list;
    final allMenus = menuP.list;
    if (allMainMenus.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Loading menu rights...',
          style: TextStyle(color: theme.textLight, fontSize: 12),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionHeader(theme, 'MENU RIGHTS'),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: theme.border),
            ),
            child: Column(
              children: allMainMenus.map((mainMenu) {
                if (mainMenu.mainMenuMstID == null) {
                  return const SizedBox.shrink();
                }
                final mainMenuId = mainMenu.mainMenuMstID!;
                final children = allMenus
                    .where((m) => m.mainMenuMstID == mainMenuId)
                    .toList();
                final childIds = children
                    .where((m) => m.menuMstID != null)
                    .map((m) => '${mainMenuId}_${m.menuMstID!}')
                    .toSet();
                final allChecked =
                    childIds.isNotEmpty &&
                    childIds.every((id) => _selectedMenuIds.contains(id));
                final someChecked = childIds.any(
                  (id) => _selectedMenuIds.contains(id),
                );
                final isCollapsed = _collapsedMainMenus.contains(mainMenuId);
                return Column(
                  key: ValueKey(mainMenuId),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GestureDetector(
                      onTap: () => setState(() {
                        if (isCollapsed) {
                          _collapsedMainMenus.remove(mainMenuId);
                        } else {
                          _collapsedMainMenus.add(mainMenuId);
                        }
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: theme.bg,
                          border: Border(top: BorderSide(color: theme.border)),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 22,
                              child: Checkbox(
                                value: allChecked
                                    ? true
                                    : someChecked
                                    ? null
                                    : false,
                                tristate: true,
                                activeColor: theme.primary,
                                onChanged: (v) => setState(() {
                                  if (!allChecked) {
                                    _selectedMenuIds.addAll(childIds);
                                  } else {
                                    _selectedMenuIds.removeAll(childIds);
                                  }
                                }),
                                visualDensity: const VisualDensity(
                                  vertical: -4,
                                  horizontal: -4,
                                ),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                            const SizedBox(width: 4),
                            AnimatedRotation(
                              turns: isCollapsed ? -0.25 : 0,
                              duration: const Duration(milliseconds: 180),
                              child: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 16,
                                color: theme.primary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.folder_outlined,
                              size: 13,
                              color: theme.primary,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Menu: ${mainMenu.mainMenuName ?? ''}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: theme.primary,
                                ),
                              ),
                            ),
                            Text(
                              '${childIds.intersection(_selectedMenuIds).length}/${childIds.length}',
                              style: TextStyle(
                                fontSize: 9,
                                color: theme.textLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // if (!isCollapsed) ke baad:
                    if (!isCollapsed)
                      GridView.builder(
                        key: ValueKey('grid_$mainMenuId'),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 13,
                              crossAxisSpacing: 0,
                              mainAxisSpacing: 0,
                            ),
                        itemCount: children.length,
                        itemBuilder: (ctx, i) {
                          final menu = children[i];
                          if (menu.menuMstID == null) {
                            return const SizedBox.shrink();
                          }
                          final menuId = menu.menuMstID!;

                          final uniqueMenuKey = '${mainMenuId}_$menuId';
                          final isChecked = _selectedMenuIds.contains(
                            uniqueMenuKey,
                          );
                          return InkWell(
                            key: ValueKey(menuId),
                            onTap: () => setState(() {
                              if (isChecked) {
                                _selectedMenuIds.remove(uniqueMenuKey);
                              } else {
                                _selectedMenuIds.add(uniqueMenuKey);
                              }
                            }),
                            child: Container(
                              padding: const EdgeInsets.only(
                                left: 10,
                                right: 6,
                                top: 2,
                                bottom: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isChecked
                                    ? theme.primary.withOpacity(0.06)
                                    : i ~/ 2 % 2 == 0
                                    ? Colors.white
                                    : theme.bg.withOpacity(0.4),
                                border: Border(
                                  top: BorderSide(
                                    color: theme.border.withOpacity(0.4),
                                  ),
                                  right: i % 2 == 0
                                      ? BorderSide(
                                          color: theme.border.withOpacity(0.4),
                                        )
                                      : BorderSide.none,
                                ),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 18,
                                    height: 22,
                                    child: Checkbox(
                                      value: isChecked,
                                      activeColor: theme.primary,
                                      onChanged: (v) => setState(() {
                                        if (v == true) {
                                          _selectedMenuIds.add(uniqueMenuKey);
                                        } else {
                                          _selectedMenuIds.remove(
                                            uniqueMenuKey,
                                          );
                                        }
                                      }),
                                      visualDensity: const VisualDensity(
                                        vertical: -4,
                                        horizontal: -4,
                                      ),
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      menu.menuName ?? '',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isChecked
                                            ? theme.primary
                                            : theme.text,
                                        fontWeight: isChecked
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllowOperatorTab(
    CounterOperatorDetProvider opP,
    ErpTheme theme,
  ) {
    return Consumer<CounterProvider>(
      builder: (context, counterP, _) {
        final allCounters = counterP.list;
        final allOperatorIds = allCounters
            .where((e) => e.crId != null)
            .map((e) => e.crId!)
            .toSet();

        final allSelected =
            allOperatorIds.isNotEmpty &&
            allOperatorIds.every((e) => _selectedOperatorIds.contains(e));

        final someSelected = allOperatorIds.any(
          (e) => _selectedOperatorIds.contains(e),
        );
        if (allCounters.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'No counters found.',
              style: TextStyle(fontSize: 12, color: theme.textLight),
              textAlign: TextAlign.center,
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _sectionHeader(theme, 'ALLOW OPERATOR'),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: theme.primary.withOpacity(.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: allSelected
                          ? true
                          : someSelected
                          ? null
                          : false,
                      tristate: true,
                      activeColor: theme.primary,
                      onChanged: (_) {
                        setState(() {
                          if (allSelected) {
                            _selectedOperatorIds.removeAll(allOperatorIds);
                          } else {
                            _selectedOperatorIds.addAll(allOperatorIds);
                          }
                        });
                      },
                    ),

                    Text(
                      'Select All Operators',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: theme.text,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              _buildAllowCheckboxList(
                theme: theme,
                items: allCounters
                    .map(
                      (c) => _AllowItem(
                        crId: c.crId ?? 0,
                        label: c.crName ?? '',
                        subLabel: c.logInName ?? '',
                      ),
                    )
                    .toList(),
                selected: _selectedOperatorIds,
                onChanged: (id, val) => setState(() {
                  if (val) {
                    _selectedOperatorIds.add(id);
                  } else {
                    _selectedOperatorIds.remove(id);
                  }
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAllowManagerTab(CounterOperatorDetProvider mgP, ErpTheme theme) {
    return Consumer<CounterProvider>(
      builder: (context, counterP, _) {
        final managerCounters = counterP.list
            .where((c) => c.counterTypeCode == 1 || c.counterTypeCode == 3)
            .toList();
        final managerList = counterP.list.where((e) => e.crId != null).toList();

        final allManagerIds = managerList.map((e) => e.crId!).toSet();

        final allSelected =
            allManagerIds.isNotEmpty &&
            allManagerIds.every((e) => _selectedManagerIds.contains(e));

        final someSelected = allManagerIds.any(
          (e) => _selectedManagerIds.contains(e),
        );
        if (managerCounters.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'No manager counters found (type 1 or 3).',
              style: TextStyle(fontSize: 12, color: theme.textLight),
              textAlign: TextAlign.center,
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _sectionHeader(theme, 'ALLOW MANAGER'),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),

                margin: const EdgeInsets.only(bottom: 6),

                decoration: BoxDecoration(
                  color: theme.primary.withOpacity(.06),
                  borderRadius: BorderRadius.circular(8),
                ),

                child: Row(
                  children: [
                    Checkbox(
                      value: allSelected
                          ? true
                          : someSelected
                          ? null
                          : false,

                      tristate: true,

                      activeColor: theme.primary,

                      onChanged: (_) {
                        setState(() {
                          if (allSelected) {
                            _selectedManagerIds.removeAll(allManagerIds);
                          } else {
                            _selectedManagerIds.addAll(allManagerIds);
                          }
                        });
                      },
                    ),

                    Text(
                      'Select All Managers',

                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: theme.text,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              _buildAllowCheckboxList(
                theme: theme,
                items: managerCounters
                    .map(
                      (c) => _AllowItem(
                        crId: c.crId ?? 0,
                        label: c.crName ?? '',
                        subLabel: c.logInName ?? '',
                      ),
                    )
                    .toList(),
                selected: _selectedManagerIds,
                onChanged: (id, val) => setState(() {
                  if (val) {
                    _selectedManagerIds.add(id);
                  } else {
                    _selectedManagerIds.remove(id);
                  }
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAllowStockTypeTab(ErpTheme theme) {
    return Consumer<StockTypeProvider>(
      builder: (context, stP, _) {
        final allTypes = List.of(stP.list)
          ..sort((a, b) => (a.sortID ?? 0).compareTo(b.sortID ?? 0));
        final stockTypeList = stP.list
            .where((e) => e.stockTypeCode != null)
            .toList();

        final allStockTypeIds = stockTypeList
            .map((e) => e.stockTypeCode!)
            .toSet();

        final allSelected =
            allStockTypeIds.isNotEmpty &&
            allStockTypeIds.every((e) => _selectedStockTypeIds.contains(e));

        final someSelected = allStockTypeIds.any(
          (e) => _selectedStockTypeIds.contains(e),
        );
        if (allTypes.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'No stock types found.',
              style: TextStyle(fontSize: 12, color: theme.textLight),
              textAlign: TextAlign.center,
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _sectionHeader(theme, 'ALLOW STOCK TYPE'),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),

                margin: const EdgeInsets.only(bottom: 6),

                decoration: BoxDecoration(
                  color: theme.primary.withOpacity(.06),
                  borderRadius: BorderRadius.circular(8),
                ),

                child: Row(
                  children: [
                    Checkbox(
                      value: allSelected
                          ? true
                          : someSelected
                          ? null
                          : false,

                      tristate: true,

                      activeColor: theme.primary,

                      onChanged: (_) {
                        setState(() {
                          if (allSelected) {
                            _selectedStockTypeIds.removeAll(allStockTypeIds);
                          } else {
                            _selectedStockTypeIds.addAll(allStockTypeIds);
                          }
                        });
                      },
                    ),

                    Text(
                      'Select All Stock Types',

                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: theme.text,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: theme.border),
                ),
                child: Column(
                  children: allTypes.asMap().entries.map((entry) {
                    final i = entry.key;
                    final st = entry.value;
                    final code = st.stockTypeCode ?? 0;
                    final checked = _selectedStockTypeIds.contains(code);
                    return InkWell(
                      onTap: () => setState(() {
                        if (checked) {
                          _selectedStockTypeIds.remove(code);
                        } else {
                          _selectedStockTypeIds.add(code);
                        }
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: checked
                              ? theme.primary.withOpacity(0.07)
                              : i.isEven
                              ? Colors.white
                              : theme.bg.withOpacity(0.5),
                          border: Border(
                            top: i == 0
                                ? BorderSide.none
                                : BorderSide(
                                    color: theme.border.withOpacity(0.5),
                                  ),
                          ),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 26,
                              child: Checkbox(
                                value: checked,
                                activeColor: theme.primary,
                                onChanged: (v) => setState(() {
                                  if (v == true) {
                                    _selectedStockTypeIds.add(code);
                                  } else {
                                    _selectedStockTypeIds.remove(code);
                                  }
                                }),
                                visualDensity: const VisualDensity(
                                  vertical: -4,
                                  horizontal: -4,
                                ),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                st.stockTypeName ?? '',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: checked ? theme.primary : theme.text,
                                  fontWeight: checked
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            if ((st.sortID ?? 0) > 0)
                              Text(
                                '${st.sortID}',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: theme.textLight,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShapeLockTab(ErpTheme theme) {
    return Consumer<ShapeProvider>(
      builder: (context, shapeP, _) {
        final allShapes = List.of(shapeP.list)
          ..sort((a, b) => (a.sortID ?? 0).compareTo(b.sortID ?? 0));
        final shapeList = shapeP.list
            .where((e) => e.shapeCode != null)
            .toList();

        final allShapeIds = shapeList.map((e) => e.shapeCode!).toSet();

        final allSelected =
            allShapeIds.isNotEmpty &&
            allShapeIds.every((e) => _selectedShapeIds.contains(e));

        final someSelected = allShapeIds.any(
          (e) => _selectedShapeIds.contains(e),
        );
        if (allShapes.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'No shapes found.',
              style: TextStyle(fontSize: 12, color: theme.textLight),
              textAlign: TextAlign.center,
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _sectionHeader(theme, 'SHAPE LOCK'),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),

                margin: const EdgeInsets.only(bottom: 6),

                decoration: BoxDecoration(
                  color: theme.primary.withOpacity(.06),
                  borderRadius: BorderRadius.circular(8),
                ),

                child: Row(
                  children: [
                    Checkbox(
                      value: allSelected
                          ? true
                          : someSelected
                          ? null
                          : false,

                      tristate: true,

                      activeColor: theme.primary,

                      onChanged: (_) {
                        setState(() {
                          if (allSelected) {
                            _selectedShapeIds.removeAll(allShapeIds);
                          } else {
                            _selectedShapeIds.addAll(allShapeIds);
                          }
                        });
                      },
                    ),

                    Text(
                      'Select All Shapes',

                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: theme.text,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: theme.border),
                ),
                child: Column(
                  children: allShapes.asMap().entries.map((entry) {
                    final i = entry.key;
                    final shape = entry.value;
                    final code = shape.shapeCode ?? 0;
                    final checked = _selectedShapeIds.contains(code);
                    return InkWell(
                      onTap: () => setState(() {
                        if (checked) {
                          _selectedShapeIds.remove(code);
                        } else {
                          _selectedShapeIds.add(code);
                        }
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: checked
                              ? theme.primary.withOpacity(0.07)
                              : i.isEven
                              ? Colors.white
                              : theme.bg.withOpacity(0.5),
                          border: Border(
                            top: i == 0
                                ? BorderSide.none
                                : BorderSide(
                                    color: theme.border.withOpacity(0.5),
                                  ),
                          ),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 26,
                              child: Checkbox(
                                value: checked,
                                activeColor: theme.primary,
                                onChanged: (v) => setState(() {
                                  if (v == true) {
                                    _selectedShapeIds.add(code);
                                  } else {
                                    _selectedShapeIds.remove(code);
                                  }
                                }),
                                visualDensity: const VisualDensity(
                                  vertical: -4,
                                  horizontal: -4,
                                ),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                shape.shapeName ?? '',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: checked ? theme.primary : theme.text,
                                  fontWeight: checked
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            if (shape.sortID != null)
                              Text(
                                shape.sortID.toString(),
                                style: TextStyle(
                                  fontSize: 9,
                                  color: theme.textLight,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTable(CounterProvider p) {
    return Consumer4<
      CounterTypeProvider,
      DivisionProvider,
      DeptGroupProvider,
      DeptProvider
    >(
      builder: (context, ctP, divP, dgP, deptP, _) {
        // Join names
        final enrichedData = p.list.map((c) {
          return {
            '_raw': c,
            'crId': c.crId?.toString() ?? '',
            'logInName': c.logInName ?? '',
            'crName': c.crName ?? '',
            'userGrp': c.userGrp ?? '',
            'sortID': c.sortID?.toString() ?? '',
            'active': c.active == true ? '✓' : '',
            'counterTypeName':
                ctP.list
                    .firstWhereOrNull(
                      (e) => e.counterTypeCode == c.counterTypeCode,
                    )
                    ?.counterTypeName ??
                '-',
            'divisionCode': c.divisionCode ?? '',
            'divisionName':
                divP.divisions
                    .firstWhereOrNull((e) => e.divisionCode == c.divisionCode)
                    ?.divisionName ??
                '-',
            'deptGroupName':
                dgP.list
                    .firstWhereOrNull((e) => e.deptGroupCode == c.deptGroupCode)
                    ?.deptGroupName ??
                '-',
            'deptName':
                deptP.list
                    .firstWhereOrNull((e) => e.deptCode == c.deptCode)
                    ?.deptName ??
                '-',
            'teamName': '-', // TeamProvider add karo agar chahiye
            'mfgDeptName':
                deptP.list
                    .firstWhereOrNull((e) => e.deptCode == c.mfgDeptCode)
                    ?.deptName ??
                '-',
          };
        }).toList();

        return ErpDataTable(
          isReportRow: false,
          token: token ?? '',
          url: baseUrl,
          title: 'COUNTER LIST',
          columns: _tableColumns,
          data: enrichedData,
          showSearch: true,
          selectedRow: _selectedRow,
          onRowTap: _onRowTap,
          emptyMessage: p.isLoaded ? 'No counters found' : 'Loading...',
        );
      },
    );
  }

  Widget _buildAllowDeptTab(ErpTheme theme) {
    return Consumer<DeptProvider>(
      builder: (context, deptP, _) {
        final allDepts = List.of(deptP.list)
          ..sort((a, b) => (a.sortID ?? 0).compareTo(b.sortID ?? 0));
        final departmentList = deptP.list
            .where((e) => e.deptCode != null)
            .toList();

        final allDeptIds = departmentList.map((e) => e.deptCode!).toSet();

        final allSelected =
            allDeptIds.isNotEmpty &&
            allDeptIds.every((e) => _selectedDeptIds.contains(e));

        final someSelected = allDeptIds.any(
          (e) => _selectedDeptIds.contains(e),
        );
        if (allDepts.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'No departments found.',
              style: TextStyle(fontSize: 12, color: theme.textLight),
              textAlign: TextAlign.center,
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _sectionHeader(theme, 'ALLOW DEPARTMENT'),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),

                margin: const EdgeInsets.only(bottom: 6),

                decoration: BoxDecoration(
                  color: theme.primary.withOpacity(.06),
                  borderRadius: BorderRadius.circular(8),
                ),

                child: Row(
                  children: [
                    Checkbox(
                      value: allSelected
                          ? true
                          : someSelected
                          ? null
                          : false,

                      tristate: true,

                      activeColor: theme.primary,

                      onChanged: (_) {
                        setState(() {
                          if (allSelected) {
                            _selectedDeptIds.removeAll(allDeptIds);
                          } else {
                            _selectedDeptIds.addAll(allDeptIds);
                          }
                        });
                      },
                    ),

                    Text(
                      'Select All Departments',

                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: theme.text,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: theme.border),
                ),
                child: Column(
                  children: allDepts.asMap().entries.map((entry) {
                    final i = entry.key;
                    final dept = entry.value;
                    final code = dept.deptCode ?? 0;
                    final checked = _selectedDeptIds.contains(code);
                    return InkWell(
                      onTap: () => setState(() {
                        if (checked) {
                          _selectedDeptIds.remove(code);
                        } else {
                          _selectedDeptIds.add(code);
                        }
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: checked
                              ? theme.primary.withOpacity(0.07)
                              : i.isEven
                              ? Colors.white
                              : theme.bg.withOpacity(0.5),
                          border: Border(
                            top: i == 0
                                ? BorderSide.none
                                : BorderSide(
                                    color: theme.border.withOpacity(0.5),
                                  ),
                          ),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 26,
                              child: Checkbox(
                                value: checked,
                                activeColor: theme.primary,
                                onChanged: (v) => setState(() {
                                  if (v == true) {
                                    _selectedDeptIds.add(code);
                                  } else {
                                    _selectedDeptIds.remove(code);
                                  }
                                }),
                                visualDensity: const VisualDensity(
                                  vertical: -4,
                                  horizontal: -4,
                                ),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                dept.deptName ?? '',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: checked ? theme.primary : theme.text,
                                  fontWeight: checked
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            if ((dept.sortID ?? 0) > 0)
                              Text(
                                '${dept.sortID}',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: theme.textLight,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAllowCheckboxList({
    required ErpTheme theme,
    required List<_AllowItem> items,
    required Set<int> selected,
    required void Function(int id, bool val) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.border),
      ),
      // child: Column(
      //   children: items.asMap().entries.map((entry) {
      //     final i       = entry.key;
      //     final item    = entry.value;
      //     final checked = selected.contains(item.crId);
      //     return InkWell(
      //       onTap: () => onChanged(item.crId, !checked),
      //       child: Container(
      //         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      //         decoration: BoxDecoration(
      //           color: checked ? theme.primary.withOpacity(0.07)
      //               : i.isEven ? Colors.white : theme.bg.withOpacity(0.5),
      //           border: Border(top: i == 0 ? BorderSide.none
      //               : BorderSide(color: theme.border.withOpacity(0.5))),
      //         ),
      //         child: Row(children: [
      //           SizedBox(width: 20, height: 26, child: Checkbox(
      //             value: checked, activeColor: theme.primary,
      //             onChanged: (v) => onChanged(item.crId, v ?? false),
      //             visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
      //             materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      //           )),
      //           const SizedBox(width: 8),
      //           Expanded(child: Text(item.label,
      //               style: TextStyle(fontSize: 11,
      //                   color: checked ? theme.primary : theme.text,
      //                   fontWeight: checked ? FontWeight.w600 : FontWeight.normal))),
      //           if (item.subLabel.isNotEmpty)
      //             Text(item.subLabel, style: TextStyle(fontSize: 9, color: theme.textLight)),
      //         ]),
      //       ),
      //     );
      //   }).toList(),
      // ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 13,
          crossAxisSpacing: 0,
          mainAxisSpacing: 0,
        ),
        itemCount: items.length,
        itemBuilder: (ctx, i) {
          final item = items[i];
          final checked = selected.contains(item.crId);

          return InkWell(
            onTap: () => onChanged(item.crId, !checked),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: checked
                    ? theme.primary.withOpacity(0.08)
                    : i ~/ 2 % 2 == 0
                    ? Colors.white
                    : theme.bg.withOpacity(0.4),
                border: Border(
                  bottom: BorderSide(color: theme.border.withOpacity(0.4)),
                  right: i % 2 == 0
                      ? BorderSide(color: theme.border.withOpacity(0.4))
                      : BorderSide.none,
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 18,
                    height: 22,
                    child: Checkbox(
                      value: checked,
                      activeColor: theme.primary,
                      onChanged: (v) => onChanged(item.crId, v ?? false),
                      visualDensity: const VisualDensity(
                        vertical: -4,
                        horizontal: -4,
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 10,
                        color: checked ? theme.primary : theme.text,
                        fontWeight: checked
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  if (item.subLabel.isNotEmpty)
                    Text(
                      item.subLabel,
                      style: TextStyle(fontSize: 9, color: theme.textLight),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _sectionHeader(ErpTheme theme, String title) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: theme.primaryGradient
              .map((c) => c.withOpacity(0.13))
              .toList(),
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.primary.withOpacity(0.3)),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: theme.primary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ─── _BasicField helper ───────────────────────────────────────────────────────
class _BasicField extends StatelessWidget {
  final String label;
  final bool required;
  final Widget child;

  const _BasicField({
    required this.label,
    this.required = false,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.erpTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label.isNotEmpty)
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: label,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: theme.textLight,
                    letterSpacing: 0.3,
                  ),
                ),
                if (required)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(fontSize: 9, color: Colors.red),
                  ),
              ],
            ),
          ),
        if (label.isNotEmpty) const SizedBox(height: 2),
        child,
      ],
    );
  }
}

// ─── Allow Item helper ────────────────────────────────────────────────────────
class _AllowItem {
  final int crId;
  final String label;
  final String subLabel;

  const _AllowItem({
    required this.crId,
    required this.label,
    required this.subLabel,
  });
}

// ─── Display Checkbox Panel ───────────────────────────────────────────────────
class _DisplayCheckboxPanel extends StatelessWidget {
  final ErpTheme theme;
  final String title;
  final List<UserVisibilityModel> items;
  final Set<int> selected;
  final void Function(int code, bool val) onChanged;

  const _DisplayCheckboxPanel({
    required this.theme,
    required this.title,
    required this.items,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: t.primaryGradient
                  .map((c) => c.withOpacity(0.15))
                  .toList(),
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border.all(color: t.primary.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(
                title.toLowerCase().contains('from')
                    ? Icons.arrow_forward_rounded
                    : Icons.arrow_back_rounded,
                size: 13,
                color: t.primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: t.primary,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: t.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${selected.length}',
                  style: const TextStyle(
                    fontSize: 9,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          // constraints: const BoxConstraints(maxHeight: 200),
          decoration: BoxDecoration(
            color: t.surface,
            border: Border.all(color: t.border),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(8),
            ),
          ),
          // child: ListView.builder(
          //   shrinkWrap: true, itemCount: items.length,
          //   itemBuilder: (ctx, i) {
          //     final item    = items[i];
          //     final code    = item.userVisibilityCode ?? 0;
          //     final checked = selected.contains(code);
          //     final isEven  = i % 2 == 0;
          //     return InkWell(
          //       onTap: () => onChanged(code, !checked),
          //       child: Container(
          //         padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          //         color: checked
          //             ? t.primary.withOpacity(0.08)
          //             : isEven ? Colors.white : t.bg.withOpacity(0.5),
          //         child: Row(children: [
          //           SizedBox(width: 20, height: 24, child: Checkbox(
          //             value: checked, activeColor: t.primary,
          //             onChanged: (v) => onChanged(code, v ?? false),
          //             visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
          //             materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          //           )),
          //           const SizedBox(width: 6),
          //           Expanded(child: Text(item.userVisibilityName ?? '',
          //               style: TextStyle(fontSize: 10,
          //                   color: checked ? t.primary : t.text,
          //                   fontWeight: checked ? FontWeight.w600 : FontWeight.normal))),
          //           if (item.entryType != null)
          //             Container(
          //               padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          //               decoration: BoxDecoration(
          //                   color: t.primary.withOpacity(0.1),
          //                   borderRadius: BorderRadius.circular(4)),
          //               child: Text(item.entryType!,
          //                   style: TextStyle(
          //                       fontSize: 7, color: t.primary, fontWeight: FontWeight.w700)),
          //             ),
          //         ]),
          //       ),
          //     );
          //   },
          // ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 10,
              crossAxisSpacing: 0,
              mainAxisSpacing: 0,
            ),
            itemCount: items.length,
            itemBuilder: (ctx, i) {
              final item = items[i];
              final code = item.userVisibilityCode ?? 0;
              final checked = selected.contains(code);

              return InkWell(
                onTap: () => onChanged(code, !checked),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: checked
                        ? t.primary.withOpacity(0.08)
                        : i ~/ 2 % 2 == 0
                        ? Colors.white
                        : t.bg.withOpacity(0.4),
                    border: Border(
                      bottom: BorderSide(color: t.border.withOpacity(0.4)),
                      right: i % 2 == 0
                          ? BorderSide(color: t.border.withOpacity(0.4))
                          : BorderSide.none,
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 18,
                        height: 22,
                        child: Checkbox(
                          value: checked,
                          activeColor: t.primary,
                          onChanged: (v) => onChanged(code, v ?? false),
                          visualDensity: const VisualDensity(
                            vertical: -4,
                            horizontal: -4,
                          ),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.userVisibilityName ?? '',
                          style: TextStyle(
                            fontSize: 10,
                            color: checked ? t.primary : t.text,
                            fontWeight: checked
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      if (item.entryType != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 3,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: t.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.entryType!,
                            style: TextStyle(
                              fontSize: 7,
                              color: t.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
