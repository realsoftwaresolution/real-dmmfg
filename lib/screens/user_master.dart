

// import 'package:collection/collection.dart';
// import 'package:diam_mfg/providers/counter_stock_type_det_provider.dart';
// import 'package:erp_data_table/erp_data_table.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:rs_dashboard/rs_dashboard.dart';
//
// import '../models/counter_model.dart';
// import '../models/user_visibility_model.dart';
// import '../providers/counter_dept_det_provider.dart';
// import '../providers/counter_provider.dart';
// import '../providers/counter_display_det_provider.dart';
// import '../providers/counter_det_provider.dart';
// import '../providers/counter_process_provider.dart';
// import '../providers/counter_shape_det_provider.dart';
// import '../providers/dept_provider.dart';
// import '../providers/main_menuMst_provider.dart';
// import '../providers/shape_provider.dart';
// import '../providers/stock_type_provider.dart';
// import '../providers/user_visibility_provider.dart';
// import '../providers/counter_type_provider.dart';
// import '../providers/division_provider.dart';
// import '../providers/dept_group_provider.dart';
// import '../providers/team_provider.dart';
// import '../providers/menu_mst_provider.dart';
// import '../providers/dept_process_provider.dart';
// import '../utils/app_images.dart';
// import '../utils/delete_dialogue.dart';
// import '../utils/msg_dialogue.dart';
// import '../providers/counter_operator_det_provider.dart';
// import '../providers/counter_manager_det_provider.dart';
//
// class MstCounter extends StatefulWidget {
//   const MstCounter({super.key});
//
//   @override
//   State<MstCounter> createState() => _MstCounterState();
// }
//
// class _MstCounterState extends State<MstCounter> {
//   final ErpThemeVariant _themeVariant = ErpThemeVariant.frost;
//   ErpTheme get _theme => ErpTheme(_themeVariant);
//
//   final GlobalKey<ErpFormState> _erpFormKey = GlobalKey<ErpFormState>();
//   Key _formKey = UniqueKey(); // Tab lock force-reset ke liye
//   Map<String, dynamic>? _selectedRow;
//   bool _isEditMode        = false;
//   bool _showSearch        = false;
//   bool _showTableOnMobile = false;
//   Map<String, String> _formValues = {};
//   Set<int> _selectedDeptIds = {};
//
//
//   // After Tab 0 save → crId/mstID set → Tab 1/2 unlock
//   int? _savedCrId;
//   int? _savedMstID;
//   int? _savedDeptCode;
//
//   int _currentTabIndex = 0;
//
//   // Dependent dropdowns
//   String? _selectedDeptGroupCode;
//   String? _selectedDeptCode;
//   String? _selectedManType;
//   String? _selectedEmpType;
// // Tab 4: Allow Manager Issue — { allowCrId: Set<deptProcessCode> }
//   Map<int, Set<int>> _managerIssueSelected  = {}; // allowCrId → selected processes
//   Set<int> _expandedIssueDepts    = {};
//   Set<int> _expandedIssueCounters = {};
//
// // Tab 5: Allow Manager Receive
//   Map<int, Set<int>> _managerRecvSelected  = {};
//   Set<int> _expandedRecvDepts    = {};
//   Set<int> _expandedRecvCounters = {};
//   // Tab 0: Display Setting
//   Set<int> _fromSelected = {};
//   Set<int> _toSelected   = {};
//
//   // Tab 1: Process
//   Set<int> _selectedProcessCodes = {};
//   final Set<int> _selectedShapeIds    = {};
//   Set<int> _selectedStockTypeIds = {};
//
//   // Tab 3: Allow Operator — selected AllowCrId list
//   Set<int> _selectedOperatorIds = {};
//
//   // Tab 4: Allow Manager — selected AllowCrId list
//   Set<int> _selectedManagerIds  = {};
//
//   // Tab 2: Menu Rights
//   Set<int> _selectedMenuIds    = {};
//   final Set<int> _collapsedMainMenus = {};
//
//   final String? token = AppStorage.getString("token");
//
//   List<ErpColumnConfig> get _tableColumns => [
//     ErpColumnConfig(key: 'crId',      label: 'CR ID',  width: 80),
//     ErpColumnConfig(key: 'crName',    label: 'NAME',   width: 180),
//     ErpColumnConfig(key: 'logInName', label: 'LOGIN',  width: 140),
//     ErpColumnConfig(key: 'userGrp',   label: 'GROUP',  width: 110),
//     ErpColumnConfig(key: 'deptCode',  label: 'DEPT',   width: 90),
//     ErpColumnConfig(key: 'active',    label: 'ACTIVE', width: 90),
//   ];
//
//   List<ErpDropdownItem> get _ynItems => const [
//     ErpDropdownItem(label: 'Y', value: 'Y'),
//     ErpDropdownItem(label: 'N', value: 'N'),
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       await Future.wait([
//         context.read<CounterTypeProvider>().load(),
//         context.read<DivisionProvider>().loadDivisions(),
//         context.read<DeptGroupProvider>().load(),
//         context.read<DeptProvider>().load(),
//         context.read<TeamProvider>().load(),
//         context.read<UserVisibilityProvider>().load(),
//         context.read<MainMenuMstProvider>().load(),
//         context.read<MenuMstProvider>().load(),
//         context.read<DeptProcessProvider>().load(),
//         context.read<CounterOperatorDetProvider>().load(),
//         context.read<CounterManagerDetProvider>().load(),
//         context.read<CounterDeptDetProvider>().load(),
//         context.read<CounterShapeDetProvider>().load(),
//         context.read<ShapeProvider>().load(),
//         context.read<CounterStockTypeDetProvider>().load(),
//         context.read<StockTypeProvider>().load(), // ✅ ADD
//
//       ]);
//       if (!mounted) return;
//       await context.read<CounterProvider>().load();
//     });
//   }
//
//   void _onRowTap(Map<String, dynamic> row) {
//     final raw = row['_raw'] as CounterModel;
//     setState(() {
//       _selectedRow           = row;
//       _isEditMode            = true;
//       _showSearch            = false;
//       _selectedDeptGroupCode = raw.deptGroupCode?.toString();
//       _selectedDeptCode      = raw.deptCode?.toString();
//       _selectedManType       = raw.manType ?? 'Days';
//       _selectedEmpType       = raw.empType ?? 'Days';
//       _currentTabIndex       = 0;
//       _selectedOperatorIds   = {};
//       _selectedManagerIds    = {};
//       _selectedDeptIds       = {};
//       _savedCrId             = raw.crId;
//       _savedMstID            = raw.counterMstID;
//       _formValues = {
//         'counterTypeCode': raw.counterTypeCode?.toString() ?? '',
//         'divisionCode':    raw.divisionCode?.toString()    ?? '',
//         'deptGroupCode':   raw.deptGroupCode?.toString()   ?? '',
//         'deptCode':        raw.deptCode?.toString()        ?? '',
//         'teamCode':        raw.teamCode?.toString()        ?? '',
//         'userGrp':         raw.userGrp          ?? '',
//         'logInName':       raw.logInName         ?? '',
//         'crPass':          raw.crPass            ?? '',
//         'crName':          raw.crName            ?? '',
//         'sortID':          raw.sortID?.toString() ?? '',
//         'active':          raw.active == true ? 'true' : 'false',
//         'mfgDeptCode':     raw.mfgDeptCode?.toString()    ?? '',
//         'crEdit':          raw.crEdit       ?? 'Y',
//         'crDel':           raw.crDel        ?? 'Y',
//         'autoRec':         raw.autoRec      ?? 'Y',
//         'empIssRec':       raw.empIssRec    ?? 'N',
//         'empRecWt':        raw.empRecWt     ?? 'N',
//         'laserPlanRec':    raw.laserPlanRec ?? 'N',
//         'polishOut':       raw.polishOut    ?? 'N',
//         'stockLimit':      raw.stockLimit?.toString()     ?? '',
//         'target':          raw.target?.toString()         ?? '',
//         'kachaIss':        raw.kachaIss     ?? 'Y',
//         'manType':         raw.manType      ?? 'Days',
//         'manPktDayLimit':  raw.manPktDayLimit?.toString()  ?? '',
//         'manPktHourLimit': raw.manPktHourLimit?.toString() ?? '',
//         'empType':         raw.empType      ?? 'Days',
//         'empPktDayLimit':  raw.empPktDayLimit?.toString()  ?? '',
//         'empPktHourLimit': raw.empPktHourLimit?.toString() ?? '',
//         'empPktLimit':     raw.empPktLimit?.toString()     ?? '',
//       };
//     });
//     if (raw.counterMstID != null) _loadDisplaySettings(raw.counterMstID!);
//     _loadMenuRights(raw.crId!);
//     _loadProcessRights(raw.crId!);
//     _loadOperatorRights(raw.crId!);
//     _loadManagerRights(raw.crId!);
//     _loadDeptRights(raw.crId!);
//     _loadShapeRights(raw.crId!);
//     _loadStockTypeRights(raw.crId!);
//     _loadManagerIssueReceiveRights(raw.crId!);
//
//     if (Responsive.isMobile(context)) setState(() => _showTableOnMobile = false);
//   }
//
//   Future<void> _loadDisplaySettings(int counterMstID) async {
//     final dp = context.read<CounterDisplayDetProvider>();
//     await dp.loadByCounter(counterMstID);
//     final records = dp.counterList;
//     setState(() {
//       _fromSelected = records
//           .where((r) => r.counterType == 'FROM' && r.userVisibilityCode != null)
//           .map((r) => r.userVisibilityCode!).toSet();
//       _toSelected = records
//           .where((r) => r.counterType == 'TO' && r.userVisibilityCode != null)
//           .map((r) => r.userVisibilityCode!).toSet();
//     });
//   }
//
//   Future<void> _loadMenuRights(int crId) async {
//     final dp = context.read<CounterDetProvider>();
//     await dp.loadByCounter(crId);
//     setState(() {
//       _selectedMenuIds = dp.counterList
//           .where((r) => r.menuMstID != null)
//           .map((r) => r.menuMstID!).toSet();
//     });
//   }
//
//   Future<void> _loadProcessRights(int crId) async {
//     final dp = context.read<CounterProcessProvider>();
//     await dp.loadByCounter(crId);
//     setState(() {
//       _selectedProcessCodes = dp.counterList
//           .where((r) => r.deptProcessCode != null)
//           .map((r) => r.deptProcessCode!).toSet();
//     });
//   }
//
//   Future<void> _loadOperatorRights(int crId) async {
//     final dp = context.read<CounterOperatorDetProvider>();
//     await dp.loadByCrId(crId);
//     setState(() {
//       _selectedOperatorIds = dp.list
//           .where((r) => r.allowCrId != null)
//           .map((r) => r.allowCrId!).toSet();
//     });
//   }
//
//   Future<void> _loadManagerRights(int crId) async {
//     final dp = context.read<CounterManagerDetProvider>();
//     await dp.loadByCrId(crId);
//     setState(() {
//       _selectedManagerIds = dp.list
//           .where((r) => r.allowCrId != null)
//           .map((r) => r.allowCrId!).toSet();
//     });
//   }
//   Future<void> _loadDeptRights(int crId) async {
//     final dp = context.read<CounterDeptDetProvider>();
//     await dp.loadByCrId(crId);
//     setState(() {
//       _selectedDeptIds = dp.list
//           .where((r) => r.deptCode != null)
//           .map((r) => r.deptCode!).toSet();
//     });
//   }
//   Future<void> _loadShapeRights(int crId) async {
//     final dp = context.read<CounterShapeDetProvider>();
//     await dp.loadByCrId(crId);
//     setState(() {
//       _selectedDeptIds = dp.list
//           .where((r) => r.shapeCode != null)
//           .map((r) => r.shapeCode!).toSet();
//     });
//   }
//   Future<void> _loadStockTypeRights(int crId) async {
//     final dp = context.read<CounterStockTypeDetProvider>();
//     await dp.loadByCrId(crId);
//     setState(() {
//       _selectedStockTypeIds = dp.list
//           .where((r) => r.stockTypeCode != null)
//           .map((r) => r.stockTypeCode!).toSet();
//     });
//   }
//   // REPLACE existing _loadManagerRights:
//   Future<void> _loadManagerIssueReceiveRights(int crId) async {
//
//     final dp = context.read<CounterManagerDetProvider>();
//     await dp.loadByCrId(crId);
//
//     final Map<int, Set<int>> issueMap = {};
//     final Map<int, Set<int>> recvMap  = {};
//
//     for (final r in dp.list) {
//       if (r.allowCrId == null) continue;
//       // deptProcessCode null = Issue only (no process = receive tab)
//       // aap apni logic ke hisaab se split karo
//       // filhaal: deptCode present = issue, absent = receive
//       if (r.deptCode != null) {
//         issueMap.putIfAbsent(r.allowCrId!, () => {});
//         if (r.deptProcessCode != null) {
//           issueMap[r.allowCrId!]!.add(r.deptProcessCode!);
//         }
//       } else {
//         recvMap.putIfAbsent(r.allowCrId!, () => {});
//         if (r.deptProcessCode != null) {
//           recvMap[r.allowCrId!]!.add(r.deptProcessCode!);
//         }
//       }
//     }
//
//     setState(() {
//       _managerIssueSelected = issueMap;
//       _managerRecvSelected  = recvMap;
//     });
//   }
//   // ── SAVE — tab 0 only (Basic + Display Setting) ───────────────────────────
//   Future<void> _onSave(Map<String, dynamic> values) async {
//     // Tab 0 save karo Counter master
//     if (_currentTabIndex == 0) {
//       final counterProvider = context.read<CounterProvider>();
//       CounterModel? savedCounter;
//       if (_isEditMode && _selectedRow != null) {
//         final raw    = _selectedRow!['_raw'] as CounterModel;
//         savedCounter = await counterProvider.updateAndReturn(raw.crId!, values);
//       } else {
//         savedCounter = await counterProvider.createAndReturn(values);
//       }
//       if (savedCounter == null || !mounted) return;
//
//       setState(() {
//         _savedCrId  = savedCounter!.crId;
//         _savedMstID = savedCounter.counterMstID;
//         _savedDeptCode = savedCounter.deptCode;
//       });
//
//       // CounterDisplayDet save
//       if (_savedMstID != null) {
//         final displayProvider = context.read<CounterDisplayDetProvider>();
//         await displayProvider.deleteByCounter(_savedMstID!);
//         for (final v in _fromSelected) {
//           await displayProvider.create({
//             'crId': _savedMstID.toString(),
//             'userVisibilityCode': v.toString(),
//             'counterType': 'FROM',
//           });
//         }
//         for (final v in _toSelected) {
//           await displayProvider.create({
//             'crId': _savedMstID.toString(),
//             'userVisibilityCode': v.toString(),
//             'counterType': 'TO',
//           });
//         }
//       }
//
//       if (!mounted) return;
//       await ErpResultDialog.showSuccess(
//         context: context, theme: _theme,
//         title:   _isEditMode ? 'Updated' : 'Saved',
//         message: 'Counter saved. Process & Rights tabs are now unlocked.',
//       );
//       // Tab 0 save ho gaya — Tab 1 pe jaao aur ErpForm reinit karo correct tab pe
//       if (mounted) {
//         setState(() {
//           _currentTabIndex = 1;
//           // _formKey = UniqueKey();
//         });
//       }
//     }
//
//     // Tab 1 save — Process
//     else if (_currentTabIndex == 1 && _savedCrId != null) {
//       final processProvider = context.read<CounterProcessProvider>();
//       final processList     = context.read<DeptProcessProvider>().list;
//       final existingProc    = List.of(processProvider.counterList);
//       for (final r in existingProc) {
//         if (r.counterProcessDetID != null) await processProvider.delete(r.counterProcessDetID!);
//       }
//       for (final procCode in _selectedProcessCodes) {
//         final proc = processList.where((p) => p.deptProcessCode == procCode).firstOrNull;
//         await processProvider.create({
//           'crId':            _savedCrId.toString(),
//           'deptCode':        (proc?.deptCode ?? 0).toString(),
//           'deptProcessCode': procCode.toString(),
//         });
//       }
//       if (!mounted) return;
//       await ErpResultDialog.showSuccess(
//         context: context, theme: _theme,
//         title: 'Saved', message: 'Process rights saved successfully.',
//       );
//     }
//
//     // Tab 2 save — Menu Rights
//     else if (_currentTabIndex == 2 && _savedCrId != null) {
//       final detProvider = context.read<CounterDetProvider>();
//       final menuList    = context.read<MenuMstProvider>().list;
//       final existingDet = List.of(detProvider.counterList);
//       for (final r in existingDet) {
//         if (r.counterDetID != null) await detProvider.delete(r.counterDetID!);
//       }
//       for (final menuId in _selectedMenuIds) {
//         final menu = menuList.where((m) => m.menuMstID == menuId).firstOrNull;
//         await detProvider.create({
//           'crId':          _savedCrId.toString(),
//           'mainMenuMstID': (menu?.mainMenuMstID ?? 0).toString(),
//           'menuMstID':     menuId.toString(),
//         });
//       }
//       if (!mounted) return;
//       await ErpResultDialog.showSuccess(
//         context: context, theme: _theme,
//         title: 'Saved', message: 'Menu rights saved successfully.',
//       );
//     }
//     else if (_currentTabIndex == 3 && _savedCrId != null) {
//       final mgProvider = context.read<CounterManagerDetProvider>();
//       await mgProvider.deleteByCrId(_savedCrId!);
//
//       final procP = context.read<DeptProcessProvider>();
//
//       for (final entry in _managerIssueSelected.entries) {
//         final allowCrId = entry.key;
//         final processCodes = entry.value;
//         for (final procCode in processCodes) {
//           final proc = procP.list.firstWhereOrNull((p) => p.deptProcessCode == procCode);
//           await mgProvider.create({
//             'crId':            _savedCrId.toString(),
//             'allowCrId':       allowCrId.toString(),
//             'deptCode':        (proc?.deptCode ?? 0).toString(),
//             'deptProcessCode': procCode.toString(),
//           });
//         }
//       }
//       if (!mounted) return;
//       await ErpResultDialog.showSuccess(
//         context: context, theme: _theme,
//         title: 'Saved', message: 'Allow Manager Issue saved.',
//       );
//     }
//
//
//     else if (_currentTabIndex == 4 && _savedCrId != null) {
//       final mgProvider = context.read<CounterManagerDetProvider>();
//
//
//       for (final entry in _managerRecvSelected.entries) {
//         final allowCrId = entry.key;
//         final processCodes = entry.value;
//         for (final procCode in processCodes) {
//           await mgProvider.create({
//             'crId':            allowCrId.toString(),
//             'allowCrId':       _savedCrId.toString(),
//             'deptCode':        _savedDeptCode,
//             'deptProcessCode': procCode.toString(),
//           });
//         }
//       }
//       if (!mounted) return;
//       await ErpResultDialog.showSuccess(
//         context: context, theme: _theme,
//         title: 'Saved', message: 'Allow Manager Receive saved.',
//       );
//     }
//     // Tab 3 save — Allow Operator
//     else if (_currentTabIndex == 5 && _savedCrId != null) {
//       final opProvider = context.read<CounterOperatorDetProvider>();
//       await opProvider.deleteByCrId(_savedCrId!);
//       for (final allowId in _selectedOperatorIds) {
//         await opProvider.create({
//           'crId':      allowId.toString(),
//           'allowCrId': _savedCrId.toString(),
//         });
//       }
//       if (!mounted) return;
//       await ErpResultDialog.showSuccess(
//         context: context, theme: _theme,
//         title: 'Saved', message: 'Allow Operator saved successfully.',
//       );
//     }
//
//     // Tab 4 save — Allow Manager
//     else if (_currentTabIndex == 6 && _savedCrId != null) {
//       final mgProvider = context.read<CounterOperatorDetProvider>();
//       await mgProvider.deleteByCrId(_savedCrId!);
//       for (final allowId in _selectedManagerIds) {
//         await mgProvider.create({
//           'crId':      _savedCrId.toString(),
//           'allowCrId': allowId.toString(),
//         });
//       }
//       if (!mounted) return;
//       await ErpResultDialog.showSuccess(
//         context: context, theme: _theme,
//         title: 'Saved', message: 'Allow Manager saved successfully.',
//       );
//     }
//     else if (_currentTabIndex == 7 && _savedCrId != null) {
//       final deptDetProvider = context.read<CounterDeptDetProvider>();
//       await deptDetProvider.deleteByCrId(_savedCrId!);
//       for (final deptCode in _selectedDeptIds) {
//         await deptDetProvider.create({
//           'crId':     _savedCrId.toString(),
//           'deptCode': deptCode.toString(),
//         });
//       }
//       if (!mounted) return;
//       await ErpResultDialog.showSuccess(
//         context: context, theme: _theme,
//         title: 'Saved', message: 'Allow Department saved successfully.',
//       );
//     }
//     else if (_currentTabIndex == 8 && _savedCrId != null) {
//       final shapeProvider = context.read<CounterShapeDetProvider>();
//       await shapeProvider.deleteByCrId(_savedCrId!);
//       for (final shapeCode in _selectedShapeIds) {
//         await shapeProvider.create({
//           'allowCrId': _savedCrId.toString(),
//           'shapeCode': shapeCode.toString(),
//         });
//       }
//       if (!mounted) return;
//       await ErpResultDialog.showSuccess(
//         context: context, theme: _theme,
//         title: 'Saved', message: 'Shape Lock saved successfully.',
//       );
//     }
//     else if (_currentTabIndex == 9 && _savedCrId != null) {
//       final stProvider = context.read<CounterStockTypeDetProvider>();
//       await stProvider.deleteByCrId(_savedCrId!);
//       for (final code in _selectedStockTypeIds) {
//         await stProvider.create({
//           'allowCrId':    _savedCrId.toString(),
//           'stockTypeCode': code.toString(),
//         });
//       }
//       if (!mounted) return;
//       await ErpResultDialog.showSuccess(
//         context: context, theme: _theme,
//         title: 'Saved', message: 'Allow Stock Type saved successfully.',
//       );
//     }
//   }
//
//   Future<void> _onDelete() async {
//     final raw = _selectedRow?['_raw'] as CounterModel?;
//     if (raw?.crId == null) return;
//     final confirm = await ErpDeleteDialog.show(
//       context: context, theme: _theme, title: 'Counter', itemName: raw!.crName ?? '',
//     );
//     if (confirm != true || !mounted) return;
//
//     final crId   = raw.crId!;
//     final mstID  = raw.counterMstID;
//
//     // Sare related records delete karo pehle
//     if (mstID != null) {
//       await context.read<CounterDisplayDetProvider>().deleteByCounter(mstID);
//     }
//     await context.read<CounterDetProvider>().deleteByCrId(crId);
//     await context.read<CounterProcessProvider>().deleteByCrId(crId);
//     await context.read<CounterOperatorDetProvider>().deleteByCrId(crId);
//     await context.read<CounterManagerDetProvider>().deleteByCrId(crId);
//     await context.read<CounterDeptDetProvider>().deleteByCrId(crId);
//     await context.read<CounterShapeDetProvider>().deleteByCrId(crId);
//     await context.read<CounterStockTypeDetProvider>().deleteByCrId(crId);
//     await context.read<CounterManagerDetProvider>().deleteByCrId(crId);
//
//     if (!mounted) return;
//
//     // Ab Counter master delete karo
//     final success = await context.read<CounterProvider>().delete(crId);
//     if (success && mounted) {
//       _resetForm();
//       await ErpResultDialog.showDeleted(context: context, theme: _theme, itemName: raw.crName ?? '');
//     }
//   }
//   // Future<void> _onDelete() async {
//   //   final raw = _selectedRow?['_raw'] as CounterModel?;
//   //   if (raw?.crId == null) return;
//   //   final confirm = await ErpDeleteDialog.show(
//   //     context: context, theme: _theme, title: 'Counter', itemName: raw!.crName ?? '',
//   //   );
//   //   if (confirm != true || !mounted) return;
//   //   final success = await context.read<CounterProvider>().delete(raw!.crId!);
//   //   if (success && mounted) {
//   //     _resetForm();
//   //     await ErpResultDialog.showDeleted(context: context, theme: _theme, itemName: raw.crName ?? '');
//   //   }
//   // }
//
//   void _resetForm() {
//     setState(() {
//       _selectedRow           = null;
//       _isEditMode            = false;
//       _formValues            = {};
//       _showTableOnMobile     = false;
//       _showSearch            = false;
//       _selectedDeptGroupCode = null;
//       _selectedDeptCode      = null;
//       _selectedManType       = null;
//       _selectedEmpType       = null;
//       _savedCrId             = null;
//       _savedMstID            = null;
//       _fromSelected          = {};
//       _selectedStockTypeIds = {};
//
//       _toSelected            = {};
//       _selectedDeptIds       = {};
//       _managerIssueSelected  = {};
//       _managerRecvSelected   = {};
//       _expandedIssueDepts    = {};
//       _expandedIssueCounters = {};
//       _expandedRecvDepts     = {};
//       _expandedRecvCounters  = {};
//       _selectedMenuIds       = {};
//       _selectedProcessCodes  = {};
//       _selectedOperatorIds   = {};
//       _selectedManagerIds    = {};
//       _currentTabIndex       = 0;
//       _formKey               = UniqueKey();
//     });
//     _erpFormKey.currentState?.resetForm();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<CounterProvider>(
//       builder: (context, counterProvider, _) {
//         final isMobile = Responsive.isMobile(context);
//         if (isMobile && (_showSearch || _showTableOnMobile)) {
//           return Padding(padding: const EdgeInsets.all(8), child: _buildTable(counterProvider));
//         }
//         return Padding(
//           padding: const EdgeInsets.all(8),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Expanded(flex: _showSearch ? 2 : 1, child: _buildFormWrapper()),
//               if (_showSearch) ...[
//                 const SizedBox(width: 12),
//                 Expanded(flex: 2, child: _buildTable(counterProvider)),
//               ],
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildTable(CounterProvider p) => ErpDataTable(
//     isReportRow: false, token: token ?? '',
//     url: baseUrl, title: 'COUNTER LIST',
//     columns: _tableColumns, data: p.tableData, showSearch: true,
//     selectedRow: _selectedRow, onRowTap: _onRowTap,
//     emptyMessage: p.isLoaded ? 'No counters found' : 'Loading...',
//   );
//
//   // ── FORM WRAPPER ──────────────────────────────────────────────────────────
//   Widget _buildFormWrapper() {
//     return Consumer5<CounterTypeProvider, DivisionProvider, DeptGroupProvider,
//         DeptProvider, TeamProvider>(
//       builder: (context, ctP, divP, dgP, deptP, teamP, _) {
//         final counterTypeItems = ctP.list.map((e) => ErpDropdownItem(
//             label: e.counterTypeName ?? '', value: e.counterTypeCode?.toString() ?? '')).toList();
//         final divisionItems = divP.divisions.map((e) => ErpDropdownItem(
//             label: e.divisionName ?? '', value: e.divisionCode?.toString() ?? '')).toList();
//         final deptGroupItems = dgP.list.map((e) => ErpDropdownItem(
//             label: e.deptGroupName ?? '', value: e.deptGroupCode?.toString() ?? '')).toList();
//
//         final filteredDepts = _selectedDeptGroupCode != null
//             ? deptP.list.where((e) => e.deptGroupCode?.toString() == _selectedDeptGroupCode).toList()
//             : deptP.list;
//         final departmentItems = filteredDepts.map((e) => ErpDropdownItem(
//             label: e.deptName ?? '', value: e.deptCode?.toString() ?? '')).toList();
//
//         // MFG Rate on Dept — same deptGroupCode filter
//         final mfgDeptItems = filteredDepts.map((e) => ErpDropdownItem(
//             label: e.deptName ?? '', value: e.deptCode?.toString() ?? '')).toList();
//
//         final teamItems = teamP.list.map((e) => ErpDropdownItem(
//             label: e.teamName ?? '', value: e.teamCode?.toString() ?? '')).toList();
//
//         return Consumer5<UserVisibilityProvider, MainMenuMstProvider, MenuMstProvider, CounterOperatorDetProvider, CounterManagerDetProvider>(
//           builder: (context, visP, mainMenuP, menuP, opP, mgP, _) {
//             final tabsEnabled = _savedCrId != null;
//             return ErpForm(
//               logo:          AppImages.logo,
//               isFirstTabSave: true,
//               key:           _formKey,
//               title:         'COUNTER MASTER',
//               subtitle:      'Counter Configuration',
//               // ── 3 tabs ──
//               tabs: const ['BASIC', 'PROCESS', 'SELECT RIGHTS','ALLOW MANAGER ISSUE', 'ALLOW MANAGER RECEIVE', 'ALLOW OPERATOR', 'ALLOW MANAGER', 'ALLOW DEPARTMENT', 'SHAPE LOCK', 'ALLOW STOCK TYPE'], // ✅ ADD
//               initialTabIndex:        _currentTabIndex,
//               tabBarBackgroundColor:  const Color(0xFFF1F5F9),
//               tabBarSelectedColor:    _theme.primaryGradient.first,
//               tabBarSelectedTxtColor: Colors.white,
//               onTabChanged: (i) {
//                 // if (i > 0 && !tabsEnabled) {
//                 //   // Tab 0 save nahi hua — ErpForm ko wapas Tab 0 pe force karo
//                 //   // key change se ErpForm reinit hoga initialTabIndex: 0 ke saath
//                 //   setState(() {
//                 //     _currentTabIndex = 0;
//                 //     _formKey = UniqueKey();
//                 //   });
//                 //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                 //     content: const Text('Please save BASIC tab first.'),
//                 //     backgroundColor: Colors.orange.shade700,
//                 //     duration: const Duration(seconds: 2),
//                 //     behavior: SnackBarBehavior.floating,
//                 //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                 //     margin: const EdgeInsets.all(12),
//                 //   ));
//                 //   return;
//                 // }
//                 setState(() => _currentTabIndex = i);
//               },
//               rows: _buildFormRows(
//                 counterTypeItems: counterTypeItems,
//                 divisionItems:    divisionItems,
//                 deptGroupItems:   deptGroupItems,
//                 departmentItems:  departmentItems,
//                 teamItems:        teamItems,
//                 mfgDeptItems:     mfgDeptItems,
//               ),
//               initialValues: _formValues,
//               isEditMode:    _isEditMode,
//               onSearch:      () => setState(() => _showSearch = !_showSearch),
//               onFieldChanged: (key, value) {
//                 _formValues[key] = value;
//                 if (key == 'deptGroupCode') {
//                   setState(() {
//                     _selectedDeptGroupCode = value.isEmpty ? null : value;
//                     _formValues['deptCode']    = '';
//                     _formValues['mfgDeptCode'] = '';
//                     _erpFormKey.currentState?.updateFieldValue('deptCode',    null);
//                     _erpFormKey.currentState?.updateFieldValue('mfgDeptCode', null);
//                   });
//                 }
//                 if (key == 'deptCode')  setState(() => _selectedDeptCode  = value.isEmpty ? null : value);
//                 if (key == 'manType')   setState(() => _selectedManType   = value);
//                 if (key == 'empType')   setState(() => _selectedEmpType   = value);
//               },
//               onSave:   _onSave,
//               onCancel: _resetForm,
//               onDelete: _isEditMode ? _onDelete : null,
//               // ── detailBuilder — tab-aware content ──
//               detailBuilder: (ctx) => _buildTabDetail(visP, mainMenuP, menuP, opP, mgP, tabsEnabled),
//             );
//           },
//         );
//       },
//     );
//   }
//
//
//   List<List<ErpFieldConfig>> _buildFormRows({
//     required List<ErpDropdownItem> counterTypeItems,
//     required List<ErpDropdownItem> divisionItems,
//     required List<ErpDropdownItem> deptGroupItems,
//     required List<ErpDropdownItem> departmentItems,
//     required List<ErpDropdownItem> teamItems,
//     required List<ErpDropdownItem> mfgDeptItems,
//   }) =>
//       [
//         // ── Tab 0: BASIC INFORMATION ──────────────────────────────────────
//         [
//           ErpFieldConfig(key: 'counterTypeCode', label: 'TYPE',       type: ErpFieldType.dropdown, dropdownItems: counterTypeItems, sectionTitle: 'BASIC INFORMATION', sectionIndex: 0, tabIndex: 0),
//           ErpFieldConfig(key: 'divisionCode',    label: 'DIVISION',   type: ErpFieldType.dropdown, dropdownItems: divisionItems,    sectionIndex: 0, tabIndex: 0),
//           ErpFieldConfig(key: 'deptGroupCode',   label: 'GROUP',      type: ErpFieldType.dropdown, dropdownItems: deptGroupItems,   sectionIndex: 0, tabIndex: 0),
//           ErpFieldConfig(key: 'deptCode',        label: 'DEPARTMENT', type: ErpFieldType.dropdown, dropdownItems: departmentItems,  sectionIndex: 0, tabIndex: 0),
//         ],
//         [
//           ErpFieldConfig(key: 'teamCode', label: 'TEAM',   type: ErpFieldType.dropdown, dropdownItems: teamItems, sectionIndex: 0, tabIndex: 0),
//           ErpFieldConfig(key: 'userGrp',  label: 'RIGHTS', type: ErpFieldType.dropdown,
//               dropdownItems: const [ErpDropdownItem(label: 'Admin', value: 'Admin'), ErpDropdownItem(label: 'User', value: 'User')],
//               sectionIndex: 0, tabIndex: 0),
//           ErpFieldConfig(key: 'logInName', label: 'LOGIN NAME', required: true, sectionIndex: 0, tabIndex: 0),
//           ErpFieldConfig(key: 'crPass',    label: 'PASSWORD',                   sectionIndex: 0, tabIndex: 0),
//         ],
//         [
//           ErpFieldConfig(key: 'crName',      label: 'NAME',             required: true,              sectionIndex: 0, tabIndex: 0),
//           ErpFieldConfig(key: 'sortID',      label: 'SORT ID',          type: ErpFieldType.number,   sectionIndex: 0, tabIndex: 0),
//           ErpFieldConfig(key: 'mfgDeptCode', label: 'MFG RATE ON DEPT', type: ErpFieldType.dropdown, dropdownItems: mfgDeptItems, sectionIndex: 0, tabIndex: 0),
//           ErpFieldConfig(key: 'active',      label: 'ACTIVE',           type: ErpFieldType.checkbox, checkboxDbType: 'BIT', sectionIndex: 0, tabIndex: 0),
//         ],
//
//         // ── Tab 0: PERMISSIONS ────────────────────────────────────────────
//         [
//           ErpFieldConfig(key: 'crEdit',       label: 'EDIT',           type: ErpFieldType.dropdown, dropdownItems: _ynItems, sectionTitle: 'PERMISSIONS', sectionIndex: 1, tabIndex: 0),
//           ErpFieldConfig(key: 'crDel',        label: 'DELETE',         type: ErpFieldType.dropdown, dropdownItems: _ynItems, sectionIndex: 1, tabIndex: 0),
//           ErpFieldConfig(key: 'autoRec',      label: 'CONFIRM REC',    type: ErpFieldType.dropdown, dropdownItems: _ynItems, sectionIndex: 1, tabIndex: 0),
//           ErpFieldConfig(key: 'empIssRec',    label: 'EMP ISS REC',    type: ErpFieldType.dropdown, dropdownItems: _ynItems, sectionIndex: 1, tabIndex: 0),
//           ErpFieldConfig(key: 'empRecWt',     label: 'EMP REC WT',     type: ErpFieldType.dropdown, dropdownItems: _ynItems, sectionIndex: 1, tabIndex: 0),
//           ErpFieldConfig(key: 'laserPlanRec', label: 'LASER PLAN REC', type: ErpFieldType.dropdown, dropdownItems: _ynItems, sectionIndex: 1, tabIndex: 0),
//         ],
//         [
//           ErpFieldConfig(key: 'polishOut',  label: 'POLISH OUT',  type: ErpFieldType.dropdown, dropdownItems: _ynItems, sectionIndex: 1, tabIndex: 0),
//           ErpFieldConfig(key: 'stockLimit', label: 'STOCK LIMIT', type: ErpFieldType.number,                            sectionIndex: 1, tabIndex: 0),
//           ErpFieldConfig(key: 'target',     label: 'TARGET',      type: ErpFieldType.number,                            sectionIndex: 1, tabIndex: 0),
//           ErpFieldConfig(key: 'kachaIss',   label: 'KACHA ISS',   type: ErpFieldType.dropdown, dropdownItems: _ynItems, sectionIndex: 1, tabIndex: 0),
//         ],
//
//         // ── Tab 0: LIMITS ─────────────────────────────────────────────────
//         [
//           ErpFieldConfig(key: 'manType',         label: 'MAN TYPE',           type: ErpFieldType.dropdown, dropdownItems: const [ErpDropdownItem(label: 'Days', value: 'Days'), ErpDropdownItem(label: 'Hours', value: 'Hours')], sectionTitle: 'LIMITS', sectionIndex: 2, tabIndex: 0),
//           ErpFieldConfig(key: 'manPktDayLimit',  label: 'MAN PKT DAY LIMIT',  type: ErpFieldType.number, readOnly: _selectedManType == 'Hours', sectionIndex: 2, tabIndex: 0),
//           ErpFieldConfig(key: 'manPktHourLimit', label: 'MAN PKT HOUR LIMIT', type: ErpFieldType.number, readOnly: _selectedManType == 'Days',  sectionIndex: 2, tabIndex: 0),
//         ],
//         [
//           ErpFieldConfig(key: 'empType',         label: 'EMP TYPE',           type: ErpFieldType.dropdown, dropdownItems: const [ErpDropdownItem(label: 'Days', value: 'Days'), ErpDropdownItem(label: 'Hours', value: 'Hours')], sectionIndex: 2, tabIndex: 0),
//           ErpFieldConfig(key: 'empPktDayLimit',  label: 'EMP PKT DAY LIMIT',  type: ErpFieldType.number, readOnly: _selectedEmpType == 'Hours', sectionIndex: 2, tabIndex: 0),
//           ErpFieldConfig(key: 'empPktHourLimit', label: 'EMP PKT HOUR LIMIT', type: ErpFieldType.number, readOnly: _selectedEmpType == 'Days',  sectionIndex: 2, tabIndex: 0),
//           ErpFieldConfig(key: 'empPktLimit',     label: 'EMP PKT LIMIT',      type: ErpFieldType.number,                                        sectionIndex: 2, tabIndex: 0),
//         ],
//
//         // ── Tab 1 & 2: no ErpForm fields — content via detailBuilder ──────
//         // (empty placeholder rows so ErpForm knows these tabs exist)
//       ];
//
//   Widget _buildTabDetail(
//       UserVisibilityProvider visP,
//       MainMenuMstProvider mainMenuP,
//       MenuMstProvider menuP,
//       CounterOperatorDetProvider opP,
//       CounterManagerDetProvider mgP,
//       bool tabsEnabled,
//       ) {
//     final theme = context.erpTheme;
//
//     switch (_currentTabIndex) {
//       case 0:
//         return _buildDisplaySetting(visP, theme);
//
//       case 1:
//         if (!tabsEnabled) return _lockedMsg(theme);
//         return _buildProcessTab(theme);
//
//       case 2:
//         if (!tabsEnabled) return _lockedMsg(theme);
//         return _buildMenuRightsTree(mainMenuP, menuP, theme);
//
//       case 3:
//         if (!tabsEnabled) return _lockedMsg(theme);
//         return _buildAllowManagerIssueTab(theme);
//
//       case 4:
//         if (!tabsEnabled) return _lockedMsg(theme);
//         return _buildAllowManagerReceiveTab(theme);
//       case 5:
//         if (!tabsEnabled) return _lockedMsg(theme);
//
//         return _buildAllowOperatorTab(opP, theme);
//
//       case 6:
//         if (!tabsEnabled) return _lockedMsg(theme);
//
//         return _buildAllowManagerTab(opP, theme);
//       case 7:
//         if (!tabsEnabled) return _lockedMsg(theme);
//         return _buildAllowDeptTab(theme);
//
//       case 8:
//         if (!tabsEnabled) return _lockedMsg(theme);
//         return _buildShapeLockTab(theme);
//       case 9:
//         if (!tabsEnabled) return _lockedMsg(theme);
//         return _buildAllowStockTypeTab(theme);
//       default:
//         return const SizedBox.shrink();
//     }
//   }
//
//   Widget _lockedMsg(ErpTheme theme) {
//     return Padding(
//       padding: const EdgeInsets.all(24),
//       child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//         Icon(Icons.lock_outline_rounded, size: 32, color: theme.textLight.withOpacity(0.4)),
//         const SizedBox(height: 8),
//         Text('Please save the BASIC tab first.',
//             style: TextStyle(fontSize: 12, color: theme.textLight), textAlign: TextAlign.center),
//       ]),
//     );
//   }
//
//   Widget _buildDisplaySetting(UserVisibilityProvider visP, ErpTheme theme) {
//     final deptItems = visP.list.where((e) => e.entryType?.toUpperCase() == 'DEPT').toList();
//     final toItems   = deptItems.isNotEmpty ? deptItems : visP.list;
//     if (visP.list.isEmpty) return const SizedBox.shrink();
//
//     return Padding(
//       padding: const EdgeInsets.only(top: 4),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
//         _sectionHeader(theme, 'DISPLAY SETTING'),
//         const SizedBox(height: 6),
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Expanded(child: _DisplayCheckboxPanel(
//               theme: theme, title: 'From Display Setting',
//               items: visP.list, selected: _fromSelected,
//               onChanged: (code, val) => setState(() {
//                 if (val) {
//                   _fromSelected.add(code);
//                 } else {
//                   _fromSelected.remove(code);
//                 }
//               }),
//             )),
//             const SizedBox(width: 8),
//             Expanded(child: _DisplayCheckboxPanel(
//               theme: theme, title: 'To Display Setting',
//               items: toItems, selected: _toSelected,
//               onChanged: (code, val) => setState(() {
//                 if (val) {
//                   _toSelected.add(code);
//                 } else {
//                   _toSelected.remove(code);
//                 }
//               }),
//             )),
//           ],
//         ),
//       ]),
//     );
//   }
//
//   Widget _buildProcessTab(ErpTheme theme) {
//     return Consumer<DeptProcessProvider>(builder: (context, procP, _) {
//       final filtered = _selectedDeptCode != null
//           ? procP.list.where((p) => p.deptCode?.toString() == _selectedDeptCode).toList()
//           : procP.list;
//
//       if (filtered.isEmpty) {
//         return Padding(padding: const EdgeInsets.all(24),
//           child: Text(
//             _selectedDeptCode == null
//                 ? 'Please select a Department in BASIC tab first.'
//                 : 'No processes found for selected department.',
//             style: TextStyle(fontSize: 12, color: theme.textLight), textAlign: TextAlign.center,
//           ),
//         );
//       }
//
//       return Padding(
//         padding: const EdgeInsets.only(top: 4),
//         child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
//           _sectionHeader(theme, 'DEPT PROCESSES'),
//           const SizedBox(height: 6),
//           Container(
//             decoration: BoxDecoration(
//               color: theme.surface, borderRadius: BorderRadius.circular(10),
//               border: Border.all(color: theme.border),
//             ),
//             child: Column(
//               children: filtered.asMap().entries.map((entry) {
//                 final i = entry.key; final proc = entry.value;
//                 final code = proc.deptProcessCode ?? 0;
//                 final isChecked = _selectedProcessCodes.contains(code);
//                 return InkWell(
//                   onTap: () => setState(() {
//                     if (isChecked) {
//                       _selectedProcessCodes.remove(code);
//                     } else {
//                       _selectedProcessCodes.add(code);
//                     }
//                   }),
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: isChecked ? theme.primary.withOpacity(0.07)
//                           : i.isEven ? Colors.white : theme.bg.withOpacity(0.5),
//                       border: Border(top: i == 0 ? BorderSide.none
//                           : BorderSide(color: theme.border.withOpacity(0.5))),
//                     ),
//                     child: Row(children: [
//                       SizedBox(width: 20, height: 26, child: Checkbox(
//                         value: isChecked, activeColor: theme.primary,
//                         onChanged: (v) => setState(() {
//                           if (v == true) {
//                             _selectedProcessCodes.add(code);
//                           } else {
//                             _selectedProcessCodes.remove(code);
//                           }
//                         }),
//                         visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
//                         materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                       )),
//                       const SizedBox(width: 8),
//                       Expanded(child: Text(proc.deptProcessName ?? '',
//                           style: TextStyle(fontSize: 11,
//                               color: isChecked ? theme.primary : theme.text,
//                               fontWeight: isChecked ? FontWeight.w600 : FontWeight.normal))),
//                       Text(code.toString(), style: TextStyle(fontSize: 9, color: theme.textLight)),
//                     ]),
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//         ]),
//       );
//     });
//   }
//   Widget _buildAllowManagerIssueTab(ErpTheme theme) {
//     return Consumer2<CounterProvider, DeptProcessProvider>(
//       builder: (context, counterP, procP, _) {
//         // Departments group karo — active counters se
//         final deptProvider = context.read<DeptProvider>();
//         final allDepts = List.of(deptProvider.list)
//           ..sort((a, b) => (a.sortID ?? 0).compareTo(b.sortID ?? 0));
//
//         if (allDepts.isEmpty) {
//           return Padding(
//             padding: const EdgeInsets.all(24),
//             child: Text('No departments found.',
//                 style: TextStyle(fontSize: 12, color: theme.textLight)),
//           );
//         }
//
//         return Padding(
//           padding: const EdgeInsets.only(top: 4),
//           child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
//             _sectionHeader(theme, 'ALLOW MANAGER ISSUE'),
//             const SizedBox(height: 6),
//             Container(
//               decoration: BoxDecoration(
//                 color: theme.surface,
//                 borderRadius: BorderRadius.circular(10),
//                 border: Border.all(color: theme.border),
//               ),
//               child: Column(
//                 children: allDepts.asMap().entries.map((dEntry) {
//                   final dept        = dEntry.value;
//                   final deptCode    = dept.deptCode ?? 0;
//                   final isDeptOpen  = _expandedIssueDepts.contains(deptCode);
//
//                   // Is dept ke active counters
//                   final deptCounters = counterP.list
//                       .where((c) => c.deptCode == deptCode && c.active == true)
//                       .toList();
//
//                   if (deptCounters.isEmpty) return const SizedBox.shrink();
//
//                   // Dept level: kitne counters selected hain
//                   final deptSelectedCount = deptCounters
//                       .where((c) => (_managerIssueSelected[c.crId ?? 0]?.isNotEmpty ?? false))
//                       .length;
//
//                   return Column(
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: [
//                       // ── DEPT HEADER ──
// // ── DEPT HEADER — checkbox add karo ──
//                       InkWell(
//                         onTap: () => setState(() {
//                           if (isDeptOpen) {
//                             _expandedIssueDepts.remove(deptCode);
//                           } else {
//                             _expandedIssueDepts.add(deptCode);
//                           }
//                         }),
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                           decoration: BoxDecoration(
//                             color: isDeptOpen ? theme.primary.withOpacity(0.08) : theme.bg,
//                             border: Border(
//                               top: dEntry.key == 0 ? BorderSide.none : BorderSide(color: theme.border),
//                             ),
//                           ),
//                           child: Row(children: [
//                             // ✅ DEPT CHECKBOX — all counters ke sare processes select/deselect
//                             SizedBox(
//                               width: 18, height: 22,
//                               child: Checkbox(
//                                 activeColor: theme.primary,
//                                 visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
//                                 materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                                 value: () {
//                                   final allProcs = deptCounters.expand((c) {
//                                     final cId = c.crId ?? 0;
//                                     return procP.list.where((p) => p.deptCode == c.deptCode)
//                                         .map((p) => MapEntry(cId, p.deptProcessCode ?? 0));
//                                   }).toList();
//                                   if (allProcs.isEmpty) return false;
//                                   final allSelected = allProcs.every((e) =>
//                                   _managerIssueSelected[e.key]?.contains(e.value) ?? false);
//                                   final anySelected = allProcs.any((e) =>
//                                   _managerIssueSelected[e.key]?.contains(e.value) ?? false);
//                                   return allSelected ? true : anySelected ? null : false;
//                                 }(),
//                                 tristate: true,
//                                 onChanged: (v) => setState(() {
//                                   for (final c in deptCounters) {
//                                     final cId = c.crId ?? 0;
//                                     final procs = procP.list
//                                         .where((p) => p.deptCode == c.deptCode)
//                                         .map((p) => p.deptProcessCode ?? 0);
//                                     if (v == true) {
//                                       _managerIssueSelected.putIfAbsent(cId, () => {}).addAll(procs);
//                                     } else {
//                                       _managerIssueSelected.remove(cId);
//                                     }
//                                   }
//                                 }),
//                               ),
//                             ),
//                             const SizedBox(width: 4),
//                             AnimatedRotation(
//                               turns: isDeptOpen ? 0 : -0.25,
//                               duration: const Duration(milliseconds: 180),
//                               child: Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: theme.primary),
//                             ),
//                             const SizedBox(width: 6),
//                             Icon(Icons.business_rounded, size: 13, color: theme.primary),
//                             const SizedBox(width: 6),
//                             Expanded(
//                               child: Text(dept.deptName ?? '',
//                                   style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: theme.primary)),
//                             ),
//                             if (deptSelectedCount > 0)
//                               Container(
//                                 padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                                 decoration: BoxDecoration(color: theme.primary, borderRadius: BorderRadius.circular(8)),
//                                 child: Text('$deptSelectedCount',
//                                     style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w700)),
//                               ),
//                           ]),
//                         ),
//                       ),
//                       // ── COUNTERS under dept ──
//                       if (isDeptOpen)
//                         ...deptCounters.asMap().entries.map((cEntry) {
//                           final counter      = cEntry.value;
//                           final crId         = counter.crId ?? 0;
//                           final isCounterOpen = _expandedIssueCounters.contains(crId);
//                           final selectedProcs = _managerIssueSelected[crId] ?? {};
//
//                           // Is counter ki processes
//                           final counterProcs = procP.list
//                               .where((p) => p.deptCode == counter.deptCode)
//                               .toList();
//
//                           return Column(
//                             crossAxisAlignment: CrossAxisAlignment.stretch,
//                             children: [
//                               // ── COUNTER ROW ──
// // ── COUNTER ROW — checkbox add karo ──
//                               InkWell(
//                                 onTap: () => setState(() {
//                                   if (isCounterOpen) {
//                                     _expandedIssueCounters.remove(crId);
//                                   } else {
//                                     _expandedIssueCounters.add(crId);
//                                   }
//                                 }),
//                                 child: Container(
//                                   padding: const EdgeInsets.only(left: 28, right: 10, top: 4, bottom: 4),
//                                   decoration: BoxDecoration(
//                                     color: isCounterOpen
//                                         ? theme.primary.withOpacity(0.05)
//                                         : cEntry.key.isEven ? Colors.white : theme.bg.withOpacity(0.4),
//                                     border: Border(top: BorderSide(color: theme.border.withOpacity(0.5))),
//                                   ),
//                                   child: Row(children: [
//                                     // ✅ COUNTER CHECKBOX — is counter ki sari processes select/deselect
//                                     SizedBox(
//                                       width: 18, height: 22,
//                                       child: Checkbox(
//                                         activeColor: theme.primary,
//                                         visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
//                                         materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                                         tristate: true,
//                                         value: () {
//                                           if (counterProcs.isEmpty) return false;
//                                           final allSel = counterProcs.every((p) =>
//                                               selectedProcs.contains(p.deptProcessCode ?? 0));
//                                           final anySel = counterProcs.any((p) =>
//                                               selectedProcs.contains(p.deptProcessCode ?? 0));
//                                           return allSel ? true : anySel ? null : false;
//                                         }(),
//                                         onChanged: (v) => setState(() {
//                                           final set = _managerIssueSelected.putIfAbsent(crId, () => {});
//                                           if (v == true) {
//                                             set.addAll(counterProcs.map((p) => p.deptProcessCode ?? 0));
//                                           } else {
//                                             _managerIssueSelected.remove(crId);
//                                           }
//                                         }),
//                                       ),
//                                     ),
//                                     const SizedBox(width: 4),
//                                     AnimatedRotation(
//                                       turns: isCounterOpen ? 0 : -0.25,
//                                       duration: const Duration(milliseconds: 180),
//                                       child: Icon(Icons.keyboard_arrow_down_rounded,
//                                           size: 14, color: theme.primary.withOpacity(0.7)),
//                                     ),
//                                     const SizedBox(width: 6),
//                                     Icon(Icons.person_outline_rounded, size: 12, color: theme.textLight),
//                                     const SizedBox(width: 6),
//                                     Expanded(
//                                       child: Text(counter.crName ?? '',
//                                           style: TextStyle(
//                                               fontSize: 11, color: theme.text,
//                                               fontWeight: selectedProcs.isNotEmpty ? FontWeight.w600 : FontWeight.normal)),
//                                     ),
//                                     if (selectedProcs.isNotEmpty)
//                                       Text('${selectedProcs.length}/${counterProcs.length}',
//                                           style: TextStyle(fontSize: 9, color: theme.primary)),
//                                   ]),
//                                 ),
//                               ),
//                               // ── PROCESSES under counter ──
//                               if (isCounterOpen)
//                                 ...counterProcs.asMap().entries.map((pEntry) {
//                                   final proc      = pEntry.value;
//                                   final procCode  = proc.deptProcessCode ?? 0;
//                                   final isChecked = selectedProcs.contains(procCode);
//
//                                   return InkWell(
//                                     onTap: () => setState(() {
//                                       final set = _managerIssueSelected
//                                           .putIfAbsent(crId, () => {});
//                                       if (isChecked) {
//                                         set.remove(procCode);
//                                       } else {
//                                         set.add(procCode);
//                                       }
//                                       if (set.isEmpty) _managerIssueSelected.remove(crId);
//                                     }),
//                                     child: Container(
//                                       padding: const EdgeInsets.only(
//                                           left: 52, right: 10, top: 3, bottom: 3),
//                                       decoration: BoxDecoration(
//                                         color: isChecked
//                                             ? theme.primary.withOpacity(0.06)
//                                             : Colors.white,
//                                         border: Border(
//                                             top: BorderSide(
//                                                 color: theme.border.withOpacity(0.4))),
//                                       ),
//                                       child: Row(children: [
//                                         SizedBox(
//                                           width: 18, height: 22,
//                                           child: Checkbox(
//                                             value: isChecked,
//                                             activeColor: theme.primary,
//                                             onChanged: (v) => setState(() {
//                                               final set = _managerIssueSelected
//                                                   .putIfAbsent(crId, () => {});
//                                               if (v == true) {
//                                                 set.add(procCode);
//                                               } else {
//                                                 set.remove(procCode);
//                                               }
//                                               if (set.isEmpty) _managerIssueSelected.remove(crId);
//                                             }),
//                                             visualDensity: const VisualDensity(
//                                                 vertical: -4, horizontal: -4),
//                                             materialTapTargetSize:
//                                             MaterialTapTargetSize.shrinkWrap,
//                                           ),
//                                         ),
//                                         const SizedBox(width: 8),
//                                         Expanded(
//                                           child: Text(proc.deptProcessName ?? '',
//                                               style: TextStyle(
//                                                   fontSize: 10,
//                                                   color: isChecked
//                                                       ? theme.primary
//                                                       : theme.text,
//                                                   fontWeight: isChecked
//                                                       ? FontWeight.w600
//                                                       : FontWeight.normal)),
//                                         ),
//                                       ]),
//                                     ),
//                                   );
//                                 }),
//                             ],
//                           );
//                         }),
//                     ],
//                   );
//                 }).toList(),
//               ),
//             ),
//           ]),
//         );
//       },
//     );
//   }
//   Widget _buildAllowManagerReceiveTab(ErpTheme theme) {
//     return Consumer2<CounterProvider, DeptProcessProvider>(
//       builder: (context, counterP, procP, _) {
//         final deptProvider = context.read<DeptProvider>();
//         final allDepts = List.of(deptProvider.list)
//           ..sort((a, b) => (a.sortID ?? 0).compareTo(b.sortID ?? 0));
//
//         // Issue tab mein jo counters/processes select hue hain — unhi se filter
//      /*   final issueAllowCrIds = _managerIssueSelected.keys.toSet();
//
//         if (issueAllowCrIds.isEmpty) {
//           return Padding(
//             padding: const EdgeInsets.all(24),
//             child: Text(
//               'Please select counters in Allow Manager Issue tab first.',
//               style: TextStyle(fontSize: 12, color: theme.textLight),
//               textAlign: TextAlign.center,
//             ),
//           );
//         }*/
//         // WITH:
//         final issueAllowCrIds = _managerIssueSelected.keys.toSet();
//
// // ✅ Process tab mein kuch selected nahi to msg dikhao
//         if (_selectedProcessCodes.isEmpty) {
//           return Padding(
//             padding: const EdgeInsets.all(24),
//             child: Text(
//               'Please select processes in PROCESS tab first.',
//               style: TextStyle(fontSize: 12, color: theme.textLight),
//               textAlign: TextAlign.center,
//             ),
//           );
//         }
//
//         if (issueAllowCrIds.isEmpty) {
//           return Padding(
//             padding: const EdgeInsets.all(24),
//             child: Text(
//               'Please select counters in Allow Manager Issue tab first.',
//               style: TextStyle(fontSize: 12, color: theme.textLight),
//               textAlign: TextAlign.center,
//             ),
//           );
//         }
//
//         return Padding(
//           padding: const EdgeInsets.only(top: 4),
//           child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
//             _sectionHeader(theme, 'ALLOW MANAGER RECEIVE'),
//             const SizedBox(height: 6),
//             Container(
//               decoration: BoxDecoration(
//                 color: theme.surface,
//                 borderRadius: BorderRadius.circular(10),
//                 border: Border.all(color: theme.border),
//               ),
//               child: Column(
//                 children: allDepts.asMap().entries.map((dEntry) {
//                   final dept       = dEntry.value;
//                   final deptCode   = dept.deptCode ?? 0;
//                   final isDeptOpen = _expandedRecvDepts.contains(deptCode);
//
//                   // Sirf Issue tab mein selected counters jo is dept ke hain
//                   final deptCounters = counterP.list
//                       .where((c) =>
//                   c.deptCode == deptCode &&
//                       c.active == true &&
//                       issueAllowCrIds.contains(c.crId))
//                       .toList();
//
//                   if (deptCounters.isEmpty) return const SizedBox.shrink();
//
//                   final deptSelectedCount = deptCounters
//                       .where((c) => (_managerRecvSelected[c.crId ?? 0]?.isNotEmpty ?? false))
//                       .length;
//
//                   return Column(
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: [
//                       InkWell(
//                         onTap: () => setState(() {
//                           if (isDeptOpen) {
//                             _expandedRecvDepts.remove(deptCode);
//                           } else {
//                             _expandedRecvDepts.add(deptCode);
//                           }
//                         }),
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 10, vertical: 6),
//                           decoration: BoxDecoration(
//                             color: isDeptOpen
//                                 ? theme.primary.withOpacity(0.08)
//                                 : theme.bg,
//                             border: Border(
//                               top: dEntry.key == 0
//                                   ? BorderSide.none
//                                   : BorderSide(color: theme.border),
//                             ),
//                           ),
//                           child: Row(children: [
//                             AnimatedRotation(
//                               turns: isDeptOpen ? 0 : -0.25,
//                               duration: const Duration(milliseconds: 180),
//                               child: Icon(Icons.keyboard_arrow_down_rounded,
//                                   size: 16, color: theme.primary),
//                             ),
//                             const SizedBox(width: 6),
//                             Icon(Icons.business_rounded,
//                                 size: 13, color: theme.primary),
//                             const SizedBox(width: 6),
//                             Expanded(
//                               child: Text(dept.deptName ?? '',
//                                   style: TextStyle(
//                                       fontSize: 11,
//                                       fontWeight: FontWeight.w700,
//                                       color: theme.primary)),
//                             ),
//                             if (deptSelectedCount > 0)
//                               Container(
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 6, vertical: 2),
//                                 decoration: BoxDecoration(
//                                     color: theme.primary,
//                                     borderRadius: BorderRadius.circular(8)),
//                                 child: Text('$deptSelectedCount',
//                                     style: const TextStyle(
//                                         fontSize: 9,
//                                         color: Colors.white,
//                                         fontWeight: FontWeight.w700)),
//                               ),
//                           ]),
//                         ),
//                       ),
//
//                       if (isDeptOpen)
//                         ...deptCounters.asMap().entries.map((cEntry) {
//                           final counter       = cEntry.value;
//                           final crId          = counter.crId ?? 0;
//                           final isCounterOpen = _expandedRecvCounters.contains(crId);
//                           final selectedProcs = _managerRecvSelected[crId] ?? {};
//
//                           // Issue tab mein is counter ki jo processes select hain — wahi dikhao
//                           // final issueProcs = _managerIssueSelected[crId] ?? {};
//                           // final matchProcs = procP.list
//                           //     .where((p) => issueProcs.contains(p.deptProcessCode))
//                           //     .toList();
//                           final matchProcs = procP.list
//                               .where((p) => _selectedProcessCodes.contains(p.deptProcessCode))
//                               .toList();
//                           return Column(
//                             crossAxisAlignment: CrossAxisAlignment.stretch,
//                             children: [
//                               InkWell(
//                                 onTap: () => setState(() {
//                                   if (isCounterOpen) {
//                                     _expandedRecvCounters.remove(crId);
//                                   } else {
//                                     _expandedRecvCounters.add(crId);
//                                   }
//                                 }),
//                                 child: Container(
//                                   padding: const EdgeInsets.only(
//                                       left: 28, right: 10, top: 4, bottom: 4),
//                                   decoration: BoxDecoration(
//                                     color: isCounterOpen
//                                         ? theme.primary.withOpacity(0.05)
//                                         : cEntry.key.isEven
//                                         ? Colors.white
//                                         : theme.bg.withOpacity(0.4),
//                                     border: Border(
//                                         top: BorderSide(
//                                             color: theme.border.withOpacity(0.5))),
//                                   ),
//                                   child: Row(children: [
//                                     AnimatedRotation(
//                                       turns: isCounterOpen ? 0 : -0.25,
//                                       duration: const Duration(milliseconds: 180),
//                                       child: Icon(Icons.keyboard_arrow_down_rounded,
//                                           size: 14,
//                                           color: theme.primary.withOpacity(0.7)),
//                                     ),
//                                     const SizedBox(width: 6),
//                                     Icon(Icons.person_outline_rounded,
//                                         size: 12, color: theme.textLight),
//                                     const SizedBox(width: 6),
//                                     Expanded(
//                                       child: Text(counter.crName ?? '',
//                                           style: TextStyle(
//                                               fontSize: 11,
//                                               color: theme.text,
//                                               fontWeight: selectedProcs.isNotEmpty
//                                                   ? FontWeight.w600
//                                                   : FontWeight.normal)),
//                                     ),
//                                     if (selectedProcs.isNotEmpty)
//                                       Text('${selectedProcs.length}/${matchProcs.length}',
//                                           style: TextStyle(
//                                               fontSize: 9, color: theme.primary)),
//                                   ]),
//                                 ),
//                               ),
//
//                               if (isCounterOpen)
//                                 ...matchProcs.asMap().entries.map((pEntry) {
//                                   final proc      = pEntry.value;
//                                   final procCode  = proc.deptProcessCode ?? 0;
//                                   final isChecked = selectedProcs.contains(procCode);
//
//                                   return InkWell(
//                                     onTap: () => setState(() {
//                                       final set = _managerRecvSelected
//                                           .putIfAbsent(crId, () => {});
//                                       if (isChecked) {
//                                         set.remove(procCode);
//                                       } else {
//                                         set.add(procCode);
//                                       }
//                                       if (set.isEmpty) _managerRecvSelected.remove(crId);
//                                     }),
//                                     child: Container(
//                                       padding: const EdgeInsets.only(
//                                           left: 52, right: 10, top: 3, bottom: 3),
//                                       decoration: BoxDecoration(
//                                         color: isChecked
//                                             ? theme.primary.withOpacity(0.06)
//                                             : Colors.white,
//                                         border: Border(
//                                             top: BorderSide(
//                                                 color: theme.border.withOpacity(0.4))),
//                                       ),
//                                       child: Row(children: [
//                                         SizedBox(
//                                           width: 18, height: 22,
//                                           child: Checkbox(
//                                             value: isChecked,
//                                             activeColor: theme.primary,
//                                             onChanged: (v) => setState(() {
//                                               final set = _managerRecvSelected
//                                                   .putIfAbsent(crId, () => {});
//                                               if (v == true) {
//                                                 set.add(procCode);
//                                               } else {
//                                                 set.remove(procCode);
//                                               }
//                                               if (set.isEmpty) _managerRecvSelected.remove(crId);
//                                             }),
//                                             visualDensity: const VisualDensity(
//                                                 vertical: -4, horizontal: -4),
//                                             materialTapTargetSize:
//                                             MaterialTapTargetSize.shrinkWrap,
//                                           ),
//                                         ),
//                                         const SizedBox(width: 8),
//                                         Expanded(
//                                           child: Text(proc.deptProcessName ?? '',
//                                               style: TextStyle(
//                                                   fontSize: 10,
//                                                   color: isChecked
//                                                       ? theme.primary
//                                                       : theme.text,
//                                                   fontWeight: isChecked
//                                                       ? FontWeight.w600
//                                                       : FontWeight.normal)),
//                                         ),
//                                       ]),
//                                     ),
//                                   );
//                                 }),
//                             ],
//                           );
//                         }),
//                     ],
//                   );
//                 }).toList(),
//               ),
//             ),
//           ]),
//         );
//       },
//     );
//   }
//
//
//   Widget _buildMenuRightsTree(MainMenuMstProvider mainMenuP, MenuMstProvider menuP, ErpTheme theme) {
//     final allMainMenus = mainMenuP.list;
//     final allMenus     = menuP.list;
//     if (allMainMenus.isEmpty) {
//       return Padding(padding: const EdgeInsets.all(16),
//           child: Text('Loading menu rights...', style: TextStyle(color: theme.textLight, fontSize: 12)));
//     }
//
//     return Padding(
//       padding: const EdgeInsets.only(top: 4),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
//         _sectionHeader(theme, 'MENU RIGHTS'),
//         const SizedBox(height: 6),
//         Container(
//           decoration: BoxDecoration(
//             color: theme.surface, borderRadius: BorderRadius.circular(10),
//             border: Border.all(color: theme.border),
//           ),
//           child: Column(
//             children: allMainMenus.map((mainMenu) {
//               final mainMenuId  = mainMenu.mainMenuMstID ?? 0;
//               final children    = allMenus.where((m) => m.mainMenuMstID == mainMenuId).toList();
//               final childIds    = children.map((m) => m.menuMstID ?? 0).toSet();
//               final allChecked  = childIds.isNotEmpty && childIds.every((id) => _selectedMenuIds.contains(id));
//               final someChecked = childIds.any((id) => _selectedMenuIds.contains(id));
//               final isCollapsed = _collapsedMainMenus.contains(mainMenuId);
//
//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   GestureDetector(
//                     onTap: () => setState(() {
//                       if (isCollapsed) {
//                         _collapsedMainMenus.remove(mainMenuId);
//                       } else {
//                         _collapsedMainMenus.add(mainMenuId);
//                       }
//                     }),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                       decoration: BoxDecoration(
//                         color: theme.bg,
//                         border: Border(top: BorderSide(color: theme.border)),
//                       ),
//                       child: Row(children: [
//                         SizedBox(width: 20, height: 22, child: Checkbox(
//                           value: allChecked ? true : someChecked ? null : false,
//                           tristate: true, activeColor: theme.primary,
//                           onChanged: (v) => setState(() {
//                             if (v == true || someChecked) {
//                               _selectedMenuIds.addAll(childIds);
//                             } else {
//                               _selectedMenuIds.removeAll(childIds);
//                             }
//                           }),
//                           visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
//                           materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                         )),
//                         const SizedBox(width: 4),
//                         AnimatedRotation(
//                           turns: isCollapsed ? -0.25 : 0,
//                           duration: const Duration(milliseconds: 180),
//                           child: Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: theme.primary),
//                         ),
//                         const SizedBox(width: 4),
//                         Icon(Icons.folder_outlined, size: 13, color: theme.primary),
//                         const SizedBox(width: 6),
//                         Expanded(child: Text('Menu: ${mainMenu.mainMenuName ?? ''}',
//                             style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: theme.primary))),
//                         Text('${childIds.intersection(_selectedMenuIds).length}/${childIds.length}',
//                             style: TextStyle(fontSize: 9, color: theme.textLight)),
//                       ]),
//                     ),
//                   ),
//                   if (!isCollapsed)
//                     ...children.map((menu) {
//                       final menuId    = menu.menuMstID ?? 0;
//                       final isChecked = _selectedMenuIds.contains(menuId);
//                       return InkWell(
//                         onTap: () => setState(() {
//                           if (isChecked) {
//                             _selectedMenuIds.remove(menuId);
//                           } else {
//                             _selectedMenuIds.add(menuId);
//                           }
//                         }),
//                         child: Container(
//                           padding: const EdgeInsets.only(left: 44, right: 10, top: 3, bottom: 3),
//                           decoration: BoxDecoration(
//                             color: isChecked ? theme.primary.withOpacity(0.06) : Colors.white,
//                             border: Border(top: BorderSide(color: theme.border.withOpacity(0.5))),
//                           ),
//                           child: Row(children: [
//                             SizedBox(width: 18, height: 22, child: Checkbox(
//                               value: isChecked, activeColor: theme.primary,
//                               onChanged: (v) => setState(() {
//                                 if (v == true) {
//                                   _selectedMenuIds.add(menuId);
//                                 } else {
//                                   _selectedMenuIds.remove(menuId);
//                                 }
//                               }),
//                               visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
//                               materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                             )),
//                             const SizedBox(width: 8),
//                             Icon(Icons.check_box_outline_blank_rounded, size: 11, color: theme.textLight),
//                             const SizedBox(width: 6),
//                             Expanded(child: Text(menu.menuName ?? '',
//                                 style: TextStyle(fontSize: 11,
//                                     color: isChecked ? theme.primary : theme.text,
//                                     fontWeight: isChecked ? FontWeight.w600 : FontWeight.normal))),
//                           ]),
//                         ),
//                       );
//                     }),
//                 ],
//               );
//             }).toList(),
//           ),
//         ),
//       ]),
//     );
//   }
//
//
//
//   Widget _buildAllowOperatorTab(CounterOperatorDetProvider opP, ErpTheme theme) {
//     return Consumer<CounterProvider>(builder: (context, counterP, _) {
//       final allCounters = counterP.list; // CounterProvider.list = List<CounterModel>
//       if (allCounters.isEmpty) {
//         return Padding(
//           padding: const EdgeInsets.all(24),
//           child: Text('No counters found.', style: TextStyle(fontSize: 12, color: theme.textLight), textAlign: TextAlign.center),
//         );
//       }
//       return Padding(
//         padding: const EdgeInsets.only(top: 4),
//         child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
//           _sectionHeader(theme, 'ALLOW OPERATOR'),
//           const SizedBox(height: 6),
//           _buildAllowCheckboxList(
//             theme:      theme,
//             items:      allCounters.map((c) => _AllowItem(crId: c.crId ?? 0, label: c.crName ?? '', subLabel: c.logInName ?? '')).toList(),
//             selected:   _selectedOperatorIds,
//             onChanged:  (id, val) => setState(() {
//               if (val) {
//                 _selectedOperatorIds.add(id);
//               } else {
//                 _selectedOperatorIds.remove(id);
//               }
//             }),
//           ),
//         ]),
//       );
//     });
//   }
//
//
//
//   Widget _buildAllowManagerTab(CounterOperatorDetProvider mgP, ErpTheme theme) {
//     return Consumer<CounterProvider>(builder: (context, counterP, _) {
//       final managerCounters = counterP.list
//           .where((c) => c.counterTypeCode == 1 || c.counterTypeCode == 3)
//           .toList();
//       if (managerCounters.isEmpty) {
//         return Padding(
//           padding: const EdgeInsets.all(24),
//           child: Text('No manager counters found (type 1 or 3).', style: TextStyle(fontSize: 12, color: theme.textLight), textAlign: TextAlign.center),
//         );
//       }
//       return Padding(
//         padding: const EdgeInsets.only(top: 4),
//         child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
//           _sectionHeader(theme, 'ALLOW MANAGER'),
//           const SizedBox(height: 6),
//           _buildAllowCheckboxList(
//             theme:      theme,
//             items:      managerCounters.map((c) => _AllowItem(crId: c.crId ?? 0, label: c.crName ?? '', subLabel: c.logInName ?? '')).toList(),
//             selected:   _selectedManagerIds,
//             onChanged:  (id, val) => setState(() {
//               if (val) {
//                 _selectedManagerIds.add(id);
//               } else {
//                 _selectedManagerIds.remove(id);
//               }
//             }),
//           ),
//         ]),
//       );
//     });
//   }
//
//
//   Widget _buildAllowStockTypeTab(ErpTheme theme) {
//     return Consumer<StockTypeProvider>(builder: (context, stP, _) {
//       final allTypes = List.of(stP.list)
//         ..sort((a, b) => (a.sortID ?? 0).compareTo(b.sortID ?? 0));
//
//       if (allTypes.isEmpty) {
//         return Padding(
//           padding: const EdgeInsets.all(24),
//           child: Text('No stock types found.',
//               style: TextStyle(fontSize: 12, color: theme.textLight),
//               textAlign: TextAlign.center),
//         );
//       }
//
//       return Padding(
//         padding: const EdgeInsets.only(top: 4),
//         child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
//           _sectionHeader(theme, 'ALLOW STOCK TYPE'),
//           const SizedBox(height: 6),
//           Container(
//             decoration: BoxDecoration(
//               color: theme.surface,
//               borderRadius: BorderRadius.circular(10),
//               border: Border.all(color: theme.border),
//             ),
//             child: Column(
//               children: allTypes.asMap().entries.map((entry) {
//                 final i         = entry.key;
//                 final st        = entry.value;
//                 final code      = st.stockTypeCode ?? 0;
//                 final isChecked = _selectedStockTypeIds.contains(code);
//                 return InkWell(
//                   onTap: () => setState(() {
//                     if (isChecked) {
//                       _selectedStockTypeIds.remove(code);
//                     } else {
//                       _selectedStockTypeIds.add(code);
//                     }
//                   }),
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: isChecked
//                           ? theme.primary.withOpacity(0.07)
//                           : i.isEven ? Colors.white : theme.bg.withOpacity(0.5),
//                       border: Border(top: i == 0
//                           ? BorderSide.none
//                           : BorderSide(color: theme.border.withOpacity(0.5))),
//                     ),
//                     child: Row(children: [
//                       SizedBox(width: 20, height: 26, child: Checkbox(
//                         value: isChecked, activeColor: theme.primary,
//                         onChanged: (v) => setState(() {
//                           if (v == true) {
//                             _selectedStockTypeIds.add(code);
//                           } else {
//                             _selectedStockTypeIds.remove(code);
//                           }
//                         }),
//                         visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
//                         materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                       )),
//                       const SizedBox(width: 8),
//                       Expanded(child: Text(st.stockTypeName ?? '',
//                           style: TextStyle(fontSize: 11,
//                               color: isChecked ? theme.primary : theme.text,
//                               fontWeight: isChecked ? FontWeight.w600 : FontWeight.normal))),
//                       if ((st.sortID ?? 0) > 0)
//                         Text('${st.sortID}',
//                             style: TextStyle(fontSize: 9, color: theme.textLight)),
//                     ]),
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//         ]),
//       );
//     });
//   }
//
//
//   Widget _buildShapeLockTab(ErpTheme theme) {
//     return Consumer<ShapeProvider>(builder: (context, shapeP, _) {
//       final allShapes = List.of(shapeP.list)
//         ..sort((a, b) => (a.sortID ?? 0).compareTo(b.sortID ?? 0));
//
//       if (allShapes.isEmpty) {
//         return Padding(
//           padding: const EdgeInsets.all(24),
//           child: Text('No shapes found.',
//               style: TextStyle(fontSize: 12, color: theme.textLight),
//               textAlign: TextAlign.center),
//         );
//       }
//
//       return Padding(
//         padding: const EdgeInsets.only(top: 4),
//         child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
//           _sectionHeader(theme, 'SHAPE LOCK'),
//           const SizedBox(height: 6),
//           Container(
//             decoration: BoxDecoration(
//               color: theme.surface, borderRadius: BorderRadius.circular(10),
//               border: Border.all(color: theme.border),
//             ),
//             child: Column(
//               children: allShapes.asMap().entries.map((entry) {
//                 final i         = entry.key;
//                 final shape     = entry.value;
//                 final code      = shape.shapeCode ?? 0;
//                 final isChecked = _selectedShapeIds.contains(code);
//                 return InkWell(
//                   onTap: () => setState(() {
//                     if (isChecked) {
//                       _selectedShapeIds.remove(code);
//                     } else {
//                       _selectedShapeIds.add(code);
//                     }
//                   }),
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: isChecked ? theme.primary.withOpacity(0.07)
//                           : i.isEven ? Colors.white : theme.bg.withOpacity(0.5),
//                       border: Border(top: i == 0 ? BorderSide.none
//                           : BorderSide(color: theme.border.withOpacity(0.5))),
//                     ),
//                     child: Row(children: [
//                       SizedBox(width: 20, height: 26, child: Checkbox(
//                         value: isChecked, activeColor: theme.primary,
//                         onChanged: (v) => setState(() {
//                           if (v == true) {
//                             _selectedShapeIds.add(code);
//                           } else {
//                             _selectedShapeIds.remove(code);
//                           }
//                         }),
//                         visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
//                         materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                       )),
//                       const SizedBox(width: 8),
//                       Expanded(child: Text(shape.shapeName ?? '',
//                           style: TextStyle(fontSize: 11,
//                               color: isChecked ? theme.primary : theme.text,
//                               fontWeight: isChecked ? FontWeight.w600 : FontWeight.normal))),
//                       if (shape.sortID != null)
//                         Text(shape.sortID.toString(),
//                             style: TextStyle(fontSize: 9, color: theme.textLight)),
//                     ]),
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//         ]),
//       );
//     });
//   }
//
//
//
//   Widget _buildAllowDeptTab(ErpTheme theme) {
//     return Consumer<DeptProvider>(builder: (context, deptP, _) {
//       // SortID wise sort karo
//       final allDepts = List.of(deptP.list)
//         ..sort((a, b) => (a.sortID ?? 0).compareTo(b.sortID ?? 0));
//
//       if (allDepts.isEmpty) {
//         return Padding(
//           padding: const EdgeInsets.all(24),
//           child: Text('No departments found.', style: TextStyle(fontSize: 12, color: theme.textLight), textAlign: TextAlign.center),
//         );
//       }
//       return Padding(
//         padding: const EdgeInsets.only(top: 4),
//         child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
//           _sectionHeader(theme, 'ALLOW DEPARTMENT'),
//           const SizedBox(height: 6),
//           _buildAllowDeptCheckboxList(theme, allDepts),
//         ]),
//       );
//     });
//   }
//
//   Widget _buildAllowDeptCheckboxList(ErpTheme theme, List allDepts) {
//     return Container(
//       decoration: BoxDecoration(
//         color: theme.surface, borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: theme.border),
//       ),
//       child: Column(
//         children: allDepts.asMap().entries.map((entry) {
//           final i       = entry.key;
//           final dept    = entry.value;
//           final code    = dept.deptCode ?? 0;
//           final isChecked = _selectedDeptIds.contains(code);
//           return InkWell(
//             onTap: () => setState(() {
//               if (isChecked) {
//                 _selectedDeptIds.remove(code);
//               } else {
//                 _selectedDeptIds.add(code);
//               }
//             }),
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//               decoration: BoxDecoration(
//                 color: isChecked ? theme.primary.withOpacity(0.07)
//                     : i.isEven ? Colors.white : theme.bg.withOpacity(0.5),
//                 border: Border(top: i == 0 ? BorderSide.none
//                     : BorderSide(color: theme.border.withOpacity(0.5))),
//               ),
//               child: Row(children: [
//                 SizedBox(width: 20, height: 26, child: Checkbox(
//                   value: isChecked, activeColor: theme.primary,
//                   onChanged: (v) => setState(() {
//                     if (v == true) {
//                       _selectedDeptIds.add(code);
//                     } else {
//                       _selectedDeptIds.remove(code);
//                     }
//                   }),
//                   visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
//                   materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                 )),
//                 const SizedBox(width: 8),
//                 Expanded(child: Text(dept.deptName ?? '',
//                     style: TextStyle(fontSize: 11,
//                         color: isChecked ? theme.primary : theme.text,
//                         fontWeight: isChecked ? FontWeight.w600 : FontWeight.normal))),
//                 if ((dept.sortID ?? 0) > 0)
//                   Text('${dept.sortID}',
//                       style: TextStyle(fontSize: 9, color: theme.textLight)),
//               ]),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }
//
//   Widget _buildAllowCheckboxList({
//     required ErpTheme theme,
//     required List<_AllowItem> items,
//     required Set<int> selected,
//     required void Function(int id, bool val) onChanged,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         color: theme.surface, borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: theme.border),
//       ),
//       child: Column(
//         children: items.asMap().entries.map((entry) {
//           final i         = entry.key;
//           final item      = entry.value;
//           final isChecked = selected.contains(item.crId);
//           return InkWell(
//             onTap: () => onChanged(item.crId, !isChecked),
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//               decoration: BoxDecoration(
//                 color: isChecked ? theme.primary.withOpacity(0.07)
//                     : i.isEven ? Colors.white : theme.bg.withOpacity(0.5),
//                 border: Border(top: i == 0 ? BorderSide.none
//                     : BorderSide(color: theme.border.withOpacity(0.5))),
//               ),
//               child: Row(children: [
//                 SizedBox(width: 20, height: 26, child: Checkbox(
//                   value: isChecked, activeColor: theme.primary,
//                   onChanged: (v) => onChanged(item.crId, v ?? false),
//                   visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
//                   materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                 )),
//                 const SizedBox(width: 8),
//                 Expanded(child: Text(item.label,
//                     style: TextStyle(fontSize: 11,
//                         color: isChecked ? theme.primary : theme.text,
//                         fontWeight: isChecked ? FontWeight.w600 : FontWeight.normal))),
//                 if (item.subLabel.isNotEmpty)
//                   Text(item.subLabel,
//                       style: TextStyle(fontSize: 9, color: theme.textLight)),
//               ]),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }
//
//   Widget _sectionHeader(ErpTheme theme, String title) {
//     return Container(
//       alignment: Alignment.center,
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(colors: theme.primaryGradient.map((c) => c.withOpacity(0.13)).toList()),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: theme.primary.withOpacity(0.3)),
//       ),
//       child: Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: theme.primary, letterSpacing: 0.8)),
//     );
//   }
// }
//
// // ─── Allow Item helper ────────────────────────────────────────────────────────
// class _AllowItem {
//   final int    crId;
//   final String label;
//   final String subLabel;
//   const _AllowItem({required this.crId, required this.label, required this.subLabel});
// }
//
// // ─── Display Checkbox Panel ───────────────────────────────────────────────────
// class _DisplayCheckboxPanel extends StatelessWidget {
//   final ErpTheme theme;
//   final String title;
//   final List<UserVisibilityModel> items;
//   final Set<int> selected;
//   final void Function(int code, bool val) onChanged;
//
//   const _DisplayCheckboxPanel({
//     required this.theme, required this.title,
//     required this.items, required this.selected, required this.onChanged,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final t = theme;
//     return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
//       Container(
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(colors: t.primaryGradient.map((c) => c.withOpacity(0.15)).toList()),
//           borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
//           border: Border.all(color: t.primary.withOpacity(0.3)),
//         ),
//         child: Row(children: [
//           Icon(title.toLowerCase().contains('from') ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded,
//               size: 13, color: t.primary),
//           const SizedBox(width: 6),
//           Expanded(child: Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: t.primary, letterSpacing: 0.4))),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//             decoration: BoxDecoration(color: t.primary, borderRadius: BorderRadius.circular(8)),
//             child: Text('${selected.length}', style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w700)),
//           ),
//         ]),
//       ),
//       Container(
//         constraints: const BoxConstraints(maxHeight: 200),
//         decoration: BoxDecoration(
//           color: t.surface, border: Border.all(color: t.border),
//           borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
//         ),
//         child: ListView.builder(
//           shrinkWrap: true, itemCount: items.length,
//           itemBuilder: (ctx, i) {
//             final item = items[i]; final code = item.userVisibilityCode ?? 0;
//             final isChecked = selected.contains(code); final isEven = i % 2 == 0;
//             return InkWell(
//               onTap: () => onChanged(code, !isChecked),
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
//                 color: isChecked ? t.primary.withOpacity(0.08) : isEven ? Colors.white : t.bg.withOpacity(0.5),
//                 child: Row(children: [
//                   SizedBox(width: 20, height: 24, child: Checkbox(
//                     value: isChecked, activeColor: t.primary,
//                     onChanged: (v) => onChanged(code, v ?? false),
//                     visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
//                     materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                   )),
//                   const SizedBox(width: 6),
//                   Expanded(child: Text(item.userVisibilityName ?? '',
//                       style: TextStyle(fontSize: 10, color: isChecked ? t.primary : t.text,
//                           fontWeight: isChecked ? FontWeight.w600 : FontWeight.normal))),
//                   if (item.entryType != null)
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
//                       decoration: BoxDecoration(color: t.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
//                       child: Text(item.entryType!, style: TextStyle(fontSize: 7, color: t.primary, fontWeight: FontWeight.w700)),
//                     ),
//                 ]),
//               ),
//             );
//           },
//         ),
//       ),
//     ]);
//   }
// }

import 'package:collection/collection.dart';
import 'package:diam_mfg/providers/counter_stock_type_det_provider.dart';
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
  Set<int> _selectedReportCodes = {};
  final GlobalKey<ErpFormState> _erpFormKey = GlobalKey<ErpFormState>();
  Key _formKey = UniqueKey();
  Map<String, dynamic>? _selectedRow;
  bool _isEditMode        = false;
  bool _showSearch        = false;
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

  Map<int, Set<int>> _managerIssueSelected  = {};
  Set<int> _expandedIssueDepts    = {};
  Set<int> _expandedIssueCounters = {};

  Map<int, Set<int>> _managerRecvSelected  = {};
  Set<int> _expandedRecvDepts    = {};
  Set<int> _expandedRecvCounters = {};

  Set<int> _fromSelected = {};
  Set<int> _toSelected   = {};

  Set<int> _selectedProcessCodes  = {};
  Set<int> _selectedShapeIds      = {};
  Set<int> _selectedStockTypeIds  = {};
  Set<int> _selectedOperatorIds   = {};
  Set<int> _selectedManagerIds    = {};
  Set<int> _selectedMenuIds       = {};
  final Set<int> _collapsedMainMenus = {};

  final String? token = AppStorage.getString("token");

  // List<ErpColumnConfig> get _tableColumns => [
  //   ErpColumnConfig(key: 'crId',      label: 'CR ID',  width: 80),
  //   ErpColumnConfig(key: 'crName',    label: 'NAME',   width: 180),
  //   ErpColumnConfig(key: 'logInName', label: 'LOGIN',  width: 140),
  //   ErpColumnConfig(key: 'userGrp',   label: 'GROUP',  width: 110),
  //   ErpColumnConfig(key: 'deptCode',  label: 'DEPT',   width: 90),
  //   ErpColumnConfig(key: 'active',    label: 'ACTIVE', width: 90),
  // ];
  List<ErpColumnConfig> get _tableColumns => [
    ErpColumnConfig(key: 'crId',            label: 'CODE',       width: 140),
    ErpColumnConfig(key: 'logInName',        label: 'LOGIN',      width: 130),
    ErpColumnConfig(key: 'crName',           label: 'NAME',       width: 180),
    ErpColumnConfig(key: 'userGrp',          label: 'USER GRP',   width: 160),
    ErpColumnConfig(key: 'sortID',           label: 'SORT ID',    width: 160),
    ErpColumnConfig(key: 'active',           label: 'ACTIVE',     width: 130),
    ErpColumnConfig(key: 'counterTypeName',  label: 'TYPE',       width: 130),
    ErpColumnConfig(key: 'divisionName',     label: 'DIVISION',   width: 160),
    ErpColumnConfig(key: 'deptGroupName',    label: 'GROUP',      width: 130),
    ErpColumnConfig(key: 'deptName',         label: 'DEPARTMENT', width: 170),
    ErpColumnConfig(key: 'teamName',         label: 'TEAM',       width: 130),
    ErpColumnConfig(key: 'mfgDeptName',      label: 'MFG DEPT',   width: 160),
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
        'CounterType':        context.read<CounterTypeProvider>().load(),
        'Division':           context.read<DivisionProvider>().loadDivisions(),
        'DeptGroup':          context.read<DeptGroupProvider>().load(),
        'Dept':               context.read<DeptProvider>().load(),
        'Team':               context.read<TeamProvider>().load(),
        'UserVisibility':     context.read<UserVisibilityProvider>().load(),
        'MainMenuMst':        context.read<MainMenuMstProvider>().load(),
        'MenuMst':            context.read<MenuMstProvider>().load(),
        'DeptProcess':        context.read<DeptProcessProvider>().load(),
        'CounterOperatorDet': context.read<CounterOperatorDetProvider>().load(),
        'CounterManagerDet':  context.read<CounterManagerDetProvider>().load(),
        'CounterDeptDet':     context.read<CounterDeptDetProvider>().load(),
        'CounterShapeDet':    context.read<CounterShapeDetProvider>().load(),
        'Shape':              context.read<ShapeProvider>().load(),
        'CounterStockTypeDet':context.read<CounterStockTypeDetProvider>().load(),
        'StockType':          context.read<StockTypeProvider>().load(),
        'ReportType': context.read<ReportTypeProvider>().load(),
        'ReportMst':  context.read<ReportMstProvider>().load(),
        'Test':       context.read<TestProvider>().load(),
        'CounterReportDet': context.read<CounterReportDetProvider>().load(),
      };

      await Future.wait(
        providers.entries.map((e) =>
            e.value
                .then((_) => debugPrint('✅ ${e.key} loaded'))
                .catchError((err) => debugPrint('❌ ${e.key} FAILED: $err')),
        ),
      );

      if (!mounted) return;


      await context.read<CounterProvider>().load()
          .then((_) {
        debugPrint('✅ Counter loaded');
        if (!mounted) return;

        final list = context.read<CounterProvider>().list;
        final maxSort = list.isEmpty ? 0
            : list.map((c) => c.sortID ?? 0).reduce((a, b) => a > b ? a : b);
        setState(() {
          _formValues['sortID'] = (maxSort + 1).toString();
          _formKey = UniqueKey();
        });
      })
          .catchError((err) => debugPrint("❌ Counter FAILED: $err"));
    });

  }
  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((_) async {
  //     await Future.wait([
  //       context.read<CounterTypeProvider>().load(),
  //       context.read<DivisionProvider>().loadDivisions(),
  //       context.read<DeptGroupProvider>().load(),
  //       context.read<DeptProvider>().load(),
  //       context.read<TeamProvider>().load(),
  //       context.read<UserVisibilityProvider>().load(),
  //       context.read<MainMenuMstProvider>().load(),
  //       context.read<MenuMstProvider>().load(),
  //       context.read<DeptProcessProvider>().load(),
  //       context.read<CounterOperatorDetProvider>().load(),
  //       context.read<CounterManagerDetProvider>().load(),
  //       context.read<CounterDeptDetProvider>().load(),
  //       context.read<CounterShapeDetProvider>().load(),
  //       context.read<ShapeProvider>().load(),
  //       context.read<CounterStockTypeDetProvider>().load(),
  //       context.read<StockTypeProvider>().load(),
  //     ]);
  //     if (!mounted) return;
  //     await context.read<CounterProvider>().load();
  //   });
  // }

  void _onRowTap(Map<String, dynamic> row) {
    final raw = row['_raw'] as CounterModel;
    setState(() {
      _selectedRow           = row;
      _isEditMode            = true;
      _showSearch            = false;
      _selectedDeptGroupCode = raw.deptGroupCode?.toString();
      _selectedDeptCode      = raw.deptCode?.toString();
      _selectedManType       = raw.manType ?? 'Days';
      _selectedEmpType       = raw.empType ?? 'Days';
      _currentTabIndex       = 0;
      _selectedOperatorIds   = {};
      _selectedManagerIds    = {};
      _selectedDeptIds       = {};
      _savedCrId             = raw.crId;
      _savedMstID            = raw.counterMstID;
      _savedDeptCode         = raw.deptCode;
      _formValues = {
        'counterTypeCode': raw.counterTypeCode?.toString() ?? '',
        'divisionCode':    raw.divisionCode?.toString()    ?? '',
        'deptGroupCode':   raw.deptGroupCode?.toString()   ?? '',
        'deptCode':        raw.deptCode?.toString()        ?? '',
        'teamCode':        raw.teamCode?.toString()        ?? '',
        'userGrp':         raw.userGrp          ?? '',
        'logInName':       raw.logInName         ?? '',
        'crPass':          raw.crPass            ?? '',
        'crName':          raw.crName            ?? '',
        'sortID':          raw.sortID?.toString() ?? '',
        'active':          raw.active == true ? 'true' : 'false',
        'mfgDeptCode':     raw.mfgDeptCode?.toString()    ?? '',
        'crEdit':          raw.crEdit       ?? 'Y',
        'crDel':           raw.crDel        ?? 'Y',
        'autoRec':         raw.autoRec      ?? 'Y',
        'empIssRec':       raw.empIssRec    ?? 'N',
        'empRecWt':        raw.empRecWt     ?? 'N',
        'laserPlanRec':    raw.laserPlanRec ?? 'N',
        'polishOut':       raw.polishOut    ?? 'N',
        'stockLimit':      raw.stockLimit?.toString()     ?? '',
        'target':          raw.target?.toString()         ?? '',
        'kachaIss':        raw.kachaIss     ?? 'Y',
        'manType':         raw.manType      ?? 'Days',
        'manPktDayLimit':  raw.manPktDayLimit?.toString()  ?? '',
        'manPktHourLimit': raw.manPktHourLimit?.toString() ?? '',
        'empType':         raw.empType      ?? 'Days',
        'empPktDayLimit':  raw.empPktDayLimit?.toString()  ?? '',
        'empPktHourLimit': raw.empPktHourLimit?.toString() ?? '',
        'empPktLimit':     raw.empPktLimit?.toString()     ?? '',
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
    if (Responsive.isMobile(context)) setState(() => _showTableOnMobile = false);
  }

  Future<void> _loadDisplaySettings(int counterMstID) async {
    final dp = context.read<CounterDisplayDetProvider>();
    await dp.loadByCounter(counterMstID);
    final records = dp.counterList;
    setState(() {
      _fromSelected = records
          .where((r) => r.counterType == 'FROM' && r.userVisibilityCode != null)
          .map((r) => r.userVisibilityCode!).toSet();
      _toSelected = records
          .where((r) => r.counterType == 'TO' && r.userVisibilityCode != null)
          .map((r) => r.userVisibilityCode!).toSet();
    });
  }

  Future<void> _loadMenuRights(int crId) async {
    final dp = context.read<CounterDetProvider>();
    await dp.loadByCounter(crId);
    setState(() {
      _selectedMenuIds = dp.counterList
          .where((r) => r.menuMstID != null)
          .map((r) => r.menuMstID!).toSet();
    });
  }
  Future<void> _loadReportRights(int crId) async {
    final dp = context.read<CounterReportDetProvider>();
    await dp.loadByCrId(crId);
    setState(() {
      _selectedReportCodes = dp.list
          .where((r) => r.reportCode != null)
          .map((r) => r.reportCode!).toSet();
    });
  }
  Future<void> _loadProcessRights(int crId) async {
    final dp = context.read<CounterProcessProvider>();
    await dp.loadByCounter(crId);
    setState(() {
      _selectedProcessCodes = dp.counterList
          .where((r) => r.deptProcessCode != null)
          .map((r) => r.deptProcessCode!).toSet();
    });
  }

  Future<void> _loadOperatorRights(int crId) async {
    final dp = context.read<CounterOperatorDetProvider>();
    await dp.loadByCrId(crId);
    setState(() {
      _selectedOperatorIds = dp.list
          .where((r) => r.crId != null)
          .map((r) => r.crId!).toSet();
      // _selectedOperatorIds = dp.list
      //     .where((r) => r.allowCrId != null)
      //     .map((r) => r.allowCrId!).toSet();
    });
  }

  Future<void> _loadManagerRights(int crId) async {
    final dp = context.read<CounterOperatorDetProvider>();
    await dp.loadByCrId(crId);
    setState(() {
      _selectedManagerIds = dp.list
          .where((r) => r.allowCrId != null)
          .map((r) => r.allowCrId!).toSet();
    });
  }

  Future<void> _loadDeptRights(int crId) async {
    final dp = context.read<CounterDeptDetProvider>();
    await dp.loadByCrId(crId);
    setState(() {
      _selectedDeptIds = dp.list
          .where((r) => r.deptCode != null)
          .map((r) => r.deptCode!).toSet();
    });
  }

  Future<void> _loadShapeRights(int crId) async {
    final dp = context.read<CounterShapeDetProvider>();
    await dp.loadByCrId(crId);
    setState(() {
      _selectedShapeIds = dp.list
          .where((r) => r.shapeCode != null)
          .map((r) => r.shapeCode!).toSet();
    });
  }

  Future<void> _loadStockTypeRights(int crId) async {
    final dp = context.read<CounterStockTypeDetProvider>();
    await dp.loadByCrId(crId);
    setState(() {
      _selectedStockTypeIds = dp.list
          .where((r) => r.stockTypeCode != null)
          .map((r) => r.stockTypeCode!).toSet();
    });
  }

  // Future<void> _loadManagerIssueReceiveRights(int crId) async {
  //   final dp = context.read<CounterManagerDetProvider>();
  //   await dp.loadByCrId(crId);
  //   final Map<int, Set<int>> issueMap = {};
  //   final Map<int, Set<int>> recvMap  = {};
  //   for (final r in dp.list) {
  //     if (r.allowCrId == null) continue;
  //     if (r.deptCode != null) {
  //       issueMap.putIfAbsent(r.allowCrId!, () => {});
  //       if (r.deptProcessCode != null) {
  //         issueMap[r.allowCrId!]!.add(r.deptProcessCode!);
  //       }
  //     } else {
  //       recvMap.putIfAbsent(r.allowCrId!, () => {});
  //       if (r.deptProcessCode != null) {
  //         recvMap[r.allowCrId!]!.add(r.deptProcessCode!);
  //       }
  //     }
  //   }
  //   setState(() {
  //     _managerIssueSelected = issueMap;
  //     _managerRecvSelected  = recvMap;
  //   });
  // }
  Future<void> _loadManagerIssueReceiveRights(int crId) async {
    final dp = context.read<CounterManagerDetProvider>();
    await dp.loadByCrId(crId);

    final Map<int, Set<int>> issueMap = {};
    final Map<int, Set<int>> recvMap  = {};

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
      _managerRecvSelected  = recvMap;
    });
  }
  // Future<void> _onSave(Map<String, dynamic> values) async {
  //
  //   // ✅ Tab 1-9 pe save karte waqt BASIC bhi update karo
  //   if (_currentTabIndex != 0 && _savedCrId != null) {
  //     await context.read<CounterProvider>().updateAndReturn(
  //       _savedCrId!,
  //       Map<String, dynamic>.from(_formValues),
  //     );
  //   }
  //
  //   if (_currentTabIndex == 0) {
  //     final counterProvider = context.read<CounterProvider>();
  //     CounterModel? savedCounter;
  //     if (_isEditMode && _selectedRow != null) {
  //       final raw = _selectedRow!['_raw'] as CounterModel;
  //       savedCounter = await counterProvider.updateAndReturn(raw.crId!, values);
  //     } else {
  //       savedCounter = await counterProvider.createAndReturn(values);
  //     }
  //     if (savedCounter == null || !mounted) return;
  //     setState(() {
  //       _savedCrId     = savedCounter!.crId;
  //       _savedMstID    = savedCounter.counterMstID;
  //       _savedDeptCode = savedCounter.deptCode;
  //     });
  //
  //     if (_savedMstID != null) {
  //       final displayProvider = context.read<CounterDisplayDetProvider>();
  //       await displayProvider.deleteByCounter(_savedMstID!);
  //       for (final v in _fromSelected) {
  //         await displayProvider.create({
  //           'crId': _savedMstID.toString(),
  //           'userVisibilityCode': v.toString(),
  //           'counterType': 'FROM',
  //         });
  //       }
  //       for (final v in _toSelected) {
  //         await displayProvider.create({
  //           'crId': _savedMstID.toString(),
  //           'userVisibilityCode': v.toString(),
  //           'counterType': 'TO',
  //         });
  //       }
  //     }
  //     if (!mounted) return;
  //     await ErpResultDialog.showSuccess(
  //       context: context, theme: _theme,
  //       title:   _isEditMode ? 'Updated' : 'Saved',
  //       message: 'Counter saved. Process & Rights tabs are now unlocked.',
  //     );
  //     // if (mounted) setState(() => _currentTabIndex = 1);
  //   }
  //
  //   else if (_currentTabIndex == 1 && _savedCrId != null) {
  //     final processProvider = context.read<CounterProcessProvider>();
  //     final processList     = context.read<DeptProcessProvider>().list;
  //     final existingProc    = List.of(processProvider.counterList);
  //     for (final r in existingProc) {
  //       if (r.counterProcessDetID != null) await processProvider.delete(r.counterProcessDetID!);
  //     }
  //     for (final procCode in _selectedProcessCodes) {
  //       final proc = processList.firstWhereOrNull((p) => p.deptProcessCode == procCode);
  //       await processProvider.create({
  //         'crId':            _savedCrId.toString(),
  //         'deptCode':        (proc?.deptCode ?? 0).toString(),
  //         'deptProcessCode': procCode.toString(),
  //       });
  //     }
  //     if (!mounted) return;
  //     await ErpResultDialog.showSuccess(
  //       context: context, theme: _theme,
  //       title: 'Saved', message: 'Process rights saved successfully.',
  //     );
  //   }
  //
  //   else if (_currentTabIndex == 2 && _savedCrId != null) {
  //     final detProvider = context.read<CounterDetProvider>();
  //     final menuList    = context.read<MenuMstProvider>().list;
  //     final existingDet = List.of(detProvider.counterList);
  //     for (final r in existingDet) {
  //       if (r.counterDetID != null) await detProvider.delete(r.counterDetID!);
  //     }
  //     for (final menuId in _selectedMenuIds) {
  //       final menu = menuList.firstWhereOrNull((m) => m.menuMstID == menuId);
  //       await detProvider.create({
  //         'crId':          _savedCrId.toString(),
  //         'mainMenuMstID': (menu?.mainMenuMstID ?? 0).toString(),
  //         'menuMstID':     menuId.toString(),
  //       });
  //     }
  //     if (!mounted) return;
  //     await ErpResultDialog.showSuccess(
  //       context: context, theme: _theme,
  //       title: 'Saved', message: 'Menu rights saved successfully.',
  //     );
  //   }
  //
  //   else if (_currentTabIndex == 3 && _savedCrId != null) {
  //     final mgProvider = context.read<CounterManagerDetProvider>();
  //     await mgProvider.deleteByCrId(_savedCrId!);
  //     final procP = context.read<DeptProcessProvider>();
  //     for (final entry in _managerIssueSelected.entries) {
  //       final allowCrId    = entry.key;
  //       final processCodes = entry.value;
  //       for (final procCode in processCodes) {
  //         final proc = procP.list.firstWhereOrNull((p) => p.deptProcessCode == procCode);
  //         await mgProvider.create({
  //           'crId':            _savedCrId.toString(),
  //           'allowCrId':       allowCrId.toString(),
  //           'deptCode':        (proc?.deptCode ?? 0).toString(),
  //           'deptProcessCode': procCode.toString(),
  //         });
  //       }
  //     }
  //     if (!mounted) return;
  //     await ErpResultDialog.showSuccess(
  //       context: context, theme: _theme,
  //       title: 'Saved', message: 'Allow Manager Issue saved.',
  //     );
  //   }
  //
  //   else if (_currentTabIndex == 4 && _savedCrId != null) {
  //     final mgProvider = context.read<CounterManagerDetProvider>();
  //     for (final entry in _managerRecvSelected.entries) {
  //       final allowCrId    = entry.key;
  //       final processCodes = entry.value;
  //       for (final procCode in processCodes) {
  //         await mgProvider.create({
  //           'crId':            allowCrId.toString(),
  //           'allowCrId':       _savedCrId.toString(),
  //           'deptCode':        _savedDeptCode,
  //           'deptProcessCode': procCode.toString(),
  //         });
  //       }
  //     }
  //     if (!mounted) return;
  //     await ErpResultDialog.showSuccess(
  //       context: context, theme: _theme,
  //       title: 'Saved', message: 'Allow Manager Receive saved.',
  //     );
  //   }
  //
  //   else if (_currentTabIndex == 5 && _savedCrId != null) {
  //     final opProvider = context.read<CounterOperatorDetProvider>();
  //     await opProvider.deleteByCrId(_savedCrId!);
  //     for (final allowId in _selectedOperatorIds) {
  //       await opProvider.create({
  //         'crId':      allowId.toString(),
  //         'allowCrId': _savedCrId.toString(),
  //       });
  //     }
  //     if (!mounted) return;
  //     await ErpResultDialog.showSuccess(
  //       context: context, theme: _theme,
  //       title: 'Saved', message: 'Allow Operator saved successfully.',
  //     );
  //   }
  //
  //   else if (_currentTabIndex == 6 && _savedCrId != null) {
  //     final mgProvider = context.read<CounterOperatorDetProvider>();
  //     await mgProvider.deleteByCrId(_savedCrId!);
  //     for (final allowId in _selectedManagerIds) {
  //       await mgProvider.create({
  //         'crId':      _savedCrId.toString(),
  //         'allowCrId': allowId.toString(),
  //       });
  //     }
  //     if (!mounted) return;
  //     await ErpResultDialog.showSuccess(
  //       context: context, theme: _theme,
  //       title: 'Saved', message: 'Allow Manager saved successfully.',
  //     );
  //   }
  //
  //   else if (_currentTabIndex == 7 && _savedCrId != null) {
  //     final deptDetProvider = context.read<CounterDeptDetProvider>();
  //     await deptDetProvider.deleteByCrId(_savedCrId!);
  //     for (final deptCode in _selectedDeptIds) {
  //       await deptDetProvider.create({
  //         'crId':     _savedCrId.toString(),
  //         'deptCode': deptCode.toString(),
  //       });
  //     }
  //     if (!mounted) return;
  //     await ErpResultDialog.showSuccess(
  //       context: context, theme: _theme,
  //       title: 'Saved', message: 'Allow Department saved successfully.',
  //     );
  //   }
  //
  //   else if (_currentTabIndex == 8 && _savedCrId != null) {
  //     final shapeProvider = context.read<CounterShapeDetProvider>();
  //     await shapeProvider.deleteByCrId(_savedCrId!);
  //     for (final shapeCode in _selectedShapeIds) {
  //       await shapeProvider.create({
  //         'allowCrId': _savedCrId.toString(),
  //         'shapeCode': shapeCode.toString(),
  //       });
  //     }
  //     if (!mounted) return;
  //     await ErpResultDialog.showSuccess(
  //       context: context, theme: _theme,
  //       title: 'Saved', message: 'Shape Lock saved successfully.',
  //     );
  //   }
  //
  //   else if (_currentTabIndex == 9 && _savedCrId != null) {
  //     final stProvider = context.read<CounterStockTypeDetProvider>();
  //     await stProvider.deleteByCrId(_savedCrId!);
  //     for (final code in _selectedStockTypeIds) {
  //       await stProvider.create({
  //         'allowCrId':     _savedCrId.toString(),
  //         'stockTypeCode': code.toString(),
  //       });
  //     }
  //     if (!mounted) return;
  //     await ErpResultDialog.showSuccess(
  //       context: context, theme: _theme,
  //       title: 'Saved', message: 'Allow Stock Type saved successfully.',
  //     );
  //     // ✅ Last tab saved — reset to add mode
  //     // if (mounted) setState(() => _formKey = UniqueKey());
  //   }else if (_currentTabIndex == 10 && _savedCrId != null) {
  //     final repProvider  = context.read<CounterReportDetProvider>();
  //     final reportList   = context.read<ReportMstProvider>().list;
  //
  //     await repProvider.deleteByCrId(_savedCrId!);
  //
  //     for (final code in _selectedReportCodes) {
  //       // ✅ reportCode se testCode find karo
  //       final report = reportList.firstWhereOrNull((r) => r.reportCode == code);
  //       await repProvider.create(
  //         CounterReportDetModel(
  //           crID: _savedCrId,
  //           reportCode: code,
  //           testCode: report?.testCode ?? 0,
  //         ).toJson(),
  //       );
  //     }
  //
  //     if (!mounted) return;
  //     await ErpResultDialog.showSuccess(
  //       context: context, theme: _theme,
  //       title: 'Saved', message: 'Report rights saved successfully.',
  //     );
  //   }
  // }
  Future<void> _onSave(Map<String, dynamic> values) async {
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

      if (savedCounter == null || !mounted) { setState(() => _isSaving = false); return; }

      final crId  = savedCounter.crId!;
      final mstID = savedCounter.counterMstID;
      final wasEdit = _isEditMode;

      setState(() {
        _savedCrId     = crId;
        _savedMstID    = mstID;
        _savedDeptCode = savedCounter!.deptCode;
        _isEditMode    = true;
        _selectedRow   = {'_raw': savedCounter};
      });

      if (mstID != null) {
        final dp = context.read<CounterDisplayDetProvider>();
        await dp.deleteByCounter(mstID);
        for (final v in _fromSelected) {
          await dp.create({'crId': mstID.toString(), 'userVisibilityCode': v.toString(), 'counterType': 'FROM'});
        }
        for (final v in _toSelected) {
          await dp.create({'crId': mstID.toString(), 'userVisibilityCode': v.toString(), 'counterType': 'TO'});
        }
      }
      if (!mounted) return;
      setState(() => _isSaving = false);  // ✅ dialog se PEHLE
      await ErpResultDialog.showSuccess(context: context, theme: _theme,
          title: wasEdit ? 'Updated' : 'Saved', message: 'Basic info saved.');
      return;
    }

    // ── Baaki tabs ke liye _savedCrId zaruri ────────────────────────────────
    if (_savedCrId == null) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please save BASIC tab first.'),
        backgroundColor: Colors.orange,
      ));
      return;
    }

    final crId     = _savedCrId!;
    final deptCode = _savedDeptCode;

    // ── Tab 1: Process Rights ───────────────────────────────────────────────
    if (_currentTabIndex == 1) {
      final processProvider = context.read<CounterProcessProvider>();
      final processList     = context.read<DeptProcessProvider>().list;
      for (final r in List.of(processProvider.counterList)) {
        if (r.counterProcessDetID != null) await processProvider.delete(r.counterProcessDetID!);
      }
      for (final procCode in _selectedProcessCodes) {
        final proc = processList.firstWhereOrNull((p) => p.deptProcessCode == procCode);
        await processProvider.create({
          'crId': crId.toString(),
          'deptCode': (proc?.deptCode ?? 0).toString(),
          'deptProcessCode': procCode.toString(),
        });
      }
      if (!mounted) return;
      setState(() => _isSaving = false);
      await ErpResultDialog.showSuccess(context: context, theme: _theme, title: 'Saved', message: 'Process rights saved.');
      return;
    }

    // ── Tab 2: Menu Rights ─────────────────────────────────────────────────
    if (_currentTabIndex == 2) {
      final detProvider = context.read<CounterDetProvider>();
      final menuList    = context.read<MenuMstProvider>().list;
      for (final r in List.of(detProvider.counterList)) {
        if (r.counterDetID != null) await detProvider.delete(r.counterDetID!);
      }
      for (final menuId in _selectedMenuIds) {
        final menu = menuList.firstWhereOrNull((m) => m.menuMstID == menuId);
        await detProvider.create({
          'crId': crId.toString(),
          'mainMenuMstID': (menu?.mainMenuMstID ?? 0).toString(),
          'menuMstID': menuId.toString(),
        });
      }
      if (!mounted) return;
      setState(() => _isSaving = false);
      await ErpResultDialog.showSuccess(context: context, theme: _theme, title: 'Saved', message: 'Menu rights saved.');
      return;
    }

    // ── Tab 3: Allow Manager Issue ─────────────────────────────────────────
    if (_currentTabIndex == 3) {
      final mgProvider = context.read<CounterManagerDetProvider>();
      await mgProvider.deleteByCrId(crId);
      final procP = context.read<DeptProcessProvider>();
      for (final entry in _managerIssueSelected.entries) {
        for (final procCode in entry.value) {
          final proc = procP.list.firstWhereOrNull((p) => p.deptProcessCode == procCode);
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
      await ErpResultDialog.showSuccess(context: context, theme: _theme, title: 'Saved', message: 'Allow Manager Issue saved.');
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
      await ErpResultDialog.showSuccess(context: context, theme: _theme, title: 'Saved', message: 'Allow Manager Receive saved.');
      return;
    }

    // ── Tab 5: Allow Operator ──────────────────────────────────────────────
    if (_currentTabIndex == 5) {
      final opProvider = context.read<CounterOperatorDetProvider>();
      await opProvider.deleteByCrId(crId);
      for (final allowId in _selectedOperatorIds) {
        await opProvider.create({'crId': allowId.toString(), 'allowCrId': crId.toString()});
      }
      if (!mounted) return;
      setState(() => _isSaving = false);
      await ErpResultDialog.showSuccess(context: context, theme: _theme, title: 'Saved', message: 'Allow Operator saved.');
      return;
    }

    // ── Tab 6: Allow Manager ───────────────────────────────────────────────
    if (_currentTabIndex == 6) {
      final opProvider = context.read<CounterOperatorDetProvider>();
      await opProvider.deleteByCrId(crId);
      for (final allowId in _selectedManagerIds) {
        await opProvider.create({'crId': crId.toString(), 'allowCrId': allowId.toString()});
      }
      if (!mounted) return;
      setState(() => _isSaving = false);
      await ErpResultDialog.showSuccess(context: context, theme: _theme, title: 'Saved', message: 'Allow Manager saved.');
      return;
    }

    // ── Tab 7: Allow Department ────────────────────────────────────────────
    if (_currentTabIndex == 7) {
      final deptDetProvider = context.read<CounterDeptDetProvider>();
      await deptDetProvider.deleteByCrId(crId);
      for (final dc in _selectedDeptIds) {
        await deptDetProvider.create({'crId': crId.toString(), 'deptCode': dc.toString()});
      }
      if (!mounted) return;
      setState(() => _isSaving = false);
      await ErpResultDialog.showSuccess(context: context, theme: _theme, title: 'Saved', message: 'Allow Department saved.');
      return;
    }

    // ── Tab 8: Shape Lock ──────────────────────────────────────────────────
    if (_currentTabIndex == 8) {
      final shapeProvider = context.read<CounterShapeDetProvider>();
      await shapeProvider.deleteByCrId(crId);
      for (final shapeCode in _selectedShapeIds) {
        await shapeProvider.create({'allowCrId': crId.toString(), 'shapeCode': shapeCode.toString()});
      }
      if (!mounted) return;
      setState(() => _isSaving = false);
      await ErpResultDialog.showSuccess(context: context, theme: _theme, title: 'Saved', message: 'Shape Lock saved.');
      return;
    }

    // ── Tab 9: Allow Stock Type ────────────────────────────────────────────
    if (_currentTabIndex == 9) {
      final stProvider = context.read<CounterStockTypeDetProvider>();
      await stProvider.deleteByCrId(crId);
      for (final code in _selectedStockTypeIds) {
        await stProvider.create({'allowCrId': crId.toString(), 'stockTypeCode': code.toString()});
      }
      if (!mounted) return;
      setState(() => _isSaving = false);
      await ErpResultDialog.showSuccess(context: context, theme: _theme, title: 'Saved', message: 'Allow Stock Type saved.');
      return;
    }

    // ── Tab 10: Report Rights ──────────────────────────────────────────────
    if (_currentTabIndex == 10) {
      final repProvider = context.read<CounterReportDetProvider>();
      final reportList  = context.read<ReportMstProvider>().list;
      await repProvider.deleteByCrId(crId);
      for (final code in _selectedReportCodes) {
        final report = reportList.firstWhereOrNull((r) => r.reportCode == code);
        await repProvider.create(
          CounterReportDetModel(crID: crId, reportCode: code, testCode: report?.testCode ?? 0).toJson(),
        );
      }
      if (!mounted) return;
      setState(() => _isSaving = false);
      await ErpResultDialog.showSuccess(context: context, theme: _theme, title: 'Saved', message: 'Report rights saved.');
      return;
    }

    setState(() => _isSaving = false);
  }
  // Future<void> _onSave(Map<String, dynamic> values) async {
  //   setState(() => _isSaving = true);
  //
  //   final counterProvider = context.read<CounterProvider>();
  //   CounterModel? savedCounter;
  //
  //   // ✅ Step 1: Counter save/update
  //   if (_isEditMode && _selectedRow != null) {
  //     final raw = _selectedRow!['_raw'] as CounterModel;
  //     savedCounter = await counterProvider.updateAndReturn(raw.crId!, values);
  //   } else {
  //     savedCounter = await counterProvider.createAndReturn(values);
  //   }
  //
  //   if (savedCounter == null || !mounted) return;
  //
  //   final crId  = savedCounter.crId!;
  //   final mstID = savedCounter.counterMstID;
  //   final deptCode = savedCounter.deptCode;
  //
  //   setState(() {
  //     _savedCrId     = crId;
  //     _savedMstID    = mstID;
  //     _savedDeptCode = deptCode;
  //   });
  //
  //   // ✅ Step 2: Display Settings
  //   if (mstID != null) {
  //     final displayProvider = context.read<CounterDisplayDetProvider>();
  //     await displayProvider.deleteByCounter(mstID);
  //     for (final v in _fromSelected) {
  //       await displayProvider.create({
  //         'crId': mstID.toString(),
  //         'userVisibilityCode': v.toString(),
  //         'counterType': 'FROM',
  //       });
  //     }
  //     for (final v in _toSelected) {
  //       await displayProvider.create({
  //         'crId': mstID.toString(),
  //         'userVisibilityCode': v.toString(),
  //         'counterType': 'TO',
  //       });
  //     }
  //   }
  //
  //   // ✅ Step 3: Process Rights
  //   final processProvider = context.read<CounterProcessProvider>();
  //   final processList     = context.read<DeptProcessProvider>().list;
  //   final existingProc    = List.of(processProvider.counterList);
  //   for (final r in existingProc) {
  //     if (r.counterProcessDetID != null) await processProvider.delete(r.counterProcessDetID!);
  //   }
  //   for (final procCode in _selectedProcessCodes) {
  //     final proc = processList.firstWhereOrNull((p) => p.deptProcessCode == procCode);
  //     await processProvider.create({
  //       'crId':            crId.toString(),
  //       'deptCode':        (proc?.deptCode ?? 0).toString(),
  //       'deptProcessCode': procCode.toString(),
  //     });
  //   }
  //
  //   // ✅ Step 4: Menu Rights
  //   final detProvider = context.read<CounterDetProvider>();
  //   final menuList    = context.read<MenuMstProvider>().list;
  //   final existingDet = List.of(detProvider.counterList);
  //   for (final r in existingDet) {
  //     if (r.counterDetID != null) await detProvider.delete(r.counterDetID!);
  //   }
  //   for (final menuId in _selectedMenuIds) {
  //     final menu = menuList.firstWhereOrNull((m) => m.menuMstID == menuId);
  //     await detProvider.create({
  //       'crId':          crId.toString(),
  //       'mainMenuMstID': (menu?.mainMenuMstID ?? 0).toString(),
  //       'menuMstID':     menuId.toString(),
  //     });
  //   }
  //
  //   // ✅ Step 5: Allow Manager Issue
  //   final mgProvider = context.read<CounterManagerDetProvider>();
  //   await mgProvider.deleteByCrId(crId);
  //   final procP = context.read<DeptProcessProvider>();
  //   for (final entry in _managerIssueSelected.entries) {
  //     final allowCrId    = entry.key;
  //     final processCodes = entry.value;
  //     for (final procCode in processCodes) {
  //       final proc = procP.list.firstWhereOrNull((p) => p.deptProcessCode == procCode);
  //       await mgProvider.create({
  //         'crId':            crId.toString(),
  //         'allowCrId':       allowCrId.toString(),
  //         'deptCode':        (proc?.deptCode ?? 0).toString(),
  //         'deptProcessCode': procCode.toString(),
  //       });
  //     }
  //   }
  //
  //   // ✅ Step 6: Allow Manager Receive
  //   for (final entry in _managerRecvSelected.entries) {
  //     final allowCrId    = entry.key;
  //     final processCodes = entry.value;
  //     for (final procCode in processCodes) {
  //       await mgProvider.create({
  //         'crId':            allowCrId.toString(),
  //         'allowCrId':       crId.toString(),
  //         'deptCode':        deptCode?.toString() ?? '0',
  //         'deptProcessCode': procCode.toString(),
  //       });
  //     }
  //   }
  //
  //   // ✅ Step 7: Allow Operator
  //   final opProvider = context.read<CounterOperatorDetProvider>();
  //   await opProvider.deleteByCrId(crId);
  //   for (final allowId in _selectedOperatorIds) {
  //     await opProvider.create({
  //       'crId':      allowId.toString(),
  //       'allowCrId': crId.toString(),
  //     });
  //   }
  //
  //   // ✅ Step 8: Allow Manager
  //   for (final allowId in _selectedManagerIds) {
  //     await opProvider.create({
  //       'crId':      crId.toString(),
  //       'allowCrId': allowId.toString(),
  //     });
  //   }
  //
  //   // ✅ Step 9: Allow Department
  //   final deptDetProvider = context.read<CounterDeptDetProvider>();
  //   await deptDetProvider.deleteByCrId(crId);
  //   for (final dc in _selectedDeptIds) {
  //     await deptDetProvider.create({
  //       'crId':     crId.toString(),
  //       'deptCode': dc.toString(),
  //     });
  //   }
  //
  //   // ✅ Step 10: Shape Lock
  //   final shapeProvider = context.read<CounterShapeDetProvider>();
  //   await shapeProvider.deleteByCrId(crId);
  //   for (final shapeCode in _selectedShapeIds) {
  //     await shapeProvider.create({
  //       'allowCrId': crId.toString(),
  //       'shapeCode': shapeCode.toString(),
  //     });
  //   }
  //
  //   // ✅ Step 11: Allow Stock Type
  //   final stProvider = context.read<CounterStockTypeDetProvider>();
  //   await stProvider.deleteByCrId(crId);
  //   for (final code in _selectedStockTypeIds) {
  //     await stProvider.create({
  //       'allowCrId':     crId.toString(),
  //       'stockTypeCode': code.toString(),
  //     });
  //   }
  //
  //   // ✅ Step 12: Report Rights
  //   final repProvider = context.read<CounterReportDetProvider>();
  //   final reportList  = context.read<ReportMstProvider>().list;
  //   await repProvider.deleteByCrId(crId);
  //   for (final code in _selectedReportCodes) {
  //     final report = reportList.firstWhereOrNull((r) => r.reportCode == code);
  //     await repProvider.create(
  //       CounterReportDetModel(
  //         crID: crId,
  //         reportCode: code,
  //         testCode: report?.testCode ?? 0,
  //       ).toJson(),
  //     );
  //   }
  //
  //   if (!mounted) return;
  //   if (mounted) setState(() => _isSaving = false);
  //
  //   await ErpResultDialog.showSuccess(
  //     context: context, theme: _theme,
  //     title:   _isEditMode ? 'Updated' : 'Saved',
  //     message: 'Counter and all rights saved successfully.',
  //   );
  //   setState(() {
  //     _formValues.clear();
  //     // _formKey=UniqueKey();
  //   });
  // }
  Future<void> _onDelete() async {
    setState(() => _isSaving = true);
    final raw = _selectedRow?['_raw'] as CounterModel?;
    if (raw?.crId == null) return;
    final confirm = await ErpDeleteDialog.show(
      context: context, theme: _theme, title: 'Counter', itemName: raw!.crName ?? '',
    );
    if (confirm != true || !mounted) return;
    final crId  = raw.crId!;
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
        _formKey=UniqueKey();
      });
      await ErpResultDialog.showDeleted(context: context, theme: _theme, itemName: raw.crName ?? '');
    }
  }

  void _resetForm() {
    final list = context.read<CounterProvider>().list;
    final maxSort = list.isEmpty ? 0
        : list.map((c) => c.sortID ?? 0).reduce((a, b) => a > b ? a : b);
    setState(() {
      _selectedRow           = null;
      _isEditMode            = false;
      _formValues            = {};
      _showTableOnMobile     = false;
      _showSearch            = false;
      _selectedDeptGroupCode = null;
      _selectedDeptCode      = null;
      _selectedManType       = null;
      _selectedEmpType       = null;
      _savedCrId             = null;
      _savedMstID            = null;
      _savedDeptCode         = null;
      _fromSelected          = {};
      _selectedReportCodes   = {};
      _toSelected            = {};
      _selectedDeptIds       = {};
      _selectedStockTypeIds  = {};
      _managerIssueSelected  = {};
      _managerRecvSelected   = {};
      _expandedIssueDepts    = {};
      _expandedIssueCounters = {};
      _expandedRecvDepts     = {};
      _expandedRecvCounters  = {};
      _selectedMenuIds       = {};
      _selectedProcessCodes  = {};
      _selectedOperatorIds   = {};
      _selectedManagerIds    = {};
      _selectedShapeIds      = {};
      _currentTabIndex       = 0;
      _formValues['sortID'] = (maxSort + 1).toString();  // ✅ ADD

      _formKey               = UniqueKey();

    });
    _erpFormKey.currentState?.resetForm();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Consumer<CounterProvider>(
          builder: (context, counterProvider, _) {
            final isMobile = Responsive.isMobile(context);
            if (isMobile && (_showSearch || _showTableOnMobile)) {
              return Padding(padding: const EdgeInsets.all(8), child: _buildTable(counterProvider));
            }
            return Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: _showSearch ? 2 : 1, child: _buildFormWrapper()),
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
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
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
                    Text('Saving...', style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600, color: _theme.primary,
                    )),
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
    return Consumer5<CounterTypeProvider, DivisionProvider, DeptGroupProvider,
        DeptProvider, TeamProvider>(
      builder: (context, ctP, divP, dgP, deptP, teamP, _) {
        final counterTypeItems = ctP.list.map((e) => ErpDropdownItem(
            label: e.counterTypeName ?? '', value: e.counterTypeCode?.toString() ?? '')).toList();
        final divisionItems = divP.divisions.map((e) => ErpDropdownItem(
            label: e.divisionName ?? '', value: e.divisionCode?.toString() ?? '')).toList();
        final deptGroupItems = dgP.list.map((e) => ErpDropdownItem(
            label: e.deptGroupName ?? '', value: e.deptGroupCode?.toString() ?? '')).toList();

        final filteredDepts = _selectedDeptGroupCode != null
            ? deptP.list.where((e) => e.deptGroupCode?.toString() == _selectedDeptGroupCode).toList()
            : deptP.list;
        final departmentItems = filteredDepts.map((e) => ErpDropdownItem(
            label: e.deptName ?? '', value: e.deptCode?.toString() ?? '')).toList();
        final mfgDeptItems = filteredDepts.map((e) => ErpDropdownItem(
            label: e.deptName ?? '', value: e.deptCode?.toString() ?? '')).toList();
        final teamItems = teamP.list.map((e) => ErpDropdownItem(
            label: e.teamName ?? '', value: e.teamCode?.toString() ?? '')).toList();

        return Consumer5<UserVisibilityProvider, MainMenuMstProvider, MenuMstProvider,
            CounterOperatorDetProvider, CounterManagerDetProvider>(
          builder: (context, visP, mainMenuP, menuP, opP, mgP, _) {
            final tabsEnabled = _savedCrId != null;
            return ErpForm(
              logo:           AppImages.logo,
              isFirstTabSave: true,
              key:            _formKey,
              title:          'COUNTER MASTER',
              subtitle:       'Counter Configuration',
              tabs: const [
                'BASIC', 'PROCESS', 'SELECT RIGHTS',
                'ALLOW MANAGER ISSUE', 'ALLOW MANAGER RECEIVE',
                'ALLOW OPERATOR', 'ALLOW MANAGER',
                'ALLOW DEPARTMENT', 'SHAPE LOCK', 'ALLOW STOCK TYPE',
                'REPORT RIGHTS'
              ],
              initialTabIndex:        _currentTabIndex,
              tabBarBackgroundColor:  const Color(0xFFF1F5F9),
              tabBarSelectedColor:    _theme.primaryGradient.first,
              tabBarSelectedTxtColor: Colors.white,
              onTabChanged: (i) => setState(() => _currentTabIndex = i),
              rows: _buildFormRows(
                counterTypeItems: counterTypeItems,
                divisionItems:    divisionItems,
                deptGroupItems:   deptGroupItems,
                departmentItems:  departmentItems,
                teamItems:        teamItems,
                mfgDeptItems:     mfgDeptItems,
                dgP: dgP
              ),
              initialValues: _formValues,
              isEditMode:    _isEditMode,
              isShowSearch: true,
              onSearch:      () => setState(() => _showSearch = !_showSearch),
              onFieldChanged: (key, value) {
                _formValues[key] = value;
                if (key == 'deptGroupCode') {
                  setState(() {
                    _selectedDeptGroupCode = value.isEmpty ? null : value;
                    _formValues['deptCode']    = '';
                    _formValues['mfgDeptCode'] = '';
                    _erpFormKey.currentState?.updateFieldValue('deptCode',    null);
                    _erpFormKey.currentState?.updateFieldValue('mfgDeptCode', null);
                  });
                }
                if (key == 'deptCode')  setState(() => _selectedDeptCode  = value.isEmpty ? null : value);
                if (key == 'manType')   setState(() => _selectedManType   = value);
                if (key == 'empType')   setState(() => _selectedEmpType   = value);
              },
              onSave:   _onSave,
              onCancel: _resetForm,
              onDelete: _isEditMode ? _onDelete : null,
              detailBuilder: (ctx) => _buildTabDetail(
                visP, mainMenuP, menuP, opP, mgP, tabsEnabled,
                counterTypeItems, divisionItems, deptGroupItems,
                departmentItems, teamItems, mfgDeptItems,
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
    required DeptGroupProvider dgP
  }) {
    final selectedGroup = dgP.list.firstWhereOrNull(
          (e) => e.deptGroupCode?.toString() == _selectedDeptGroupCode,
    );

    final isMfg = (selectedGroup?.deptGroupName ?? '')
        .toUpperCase()
        .contains('MFG');

    final counterList = context.read<CounterProvider>().list;
    final maxSortId = counterList.isEmpty
        ? 0
        : counterList.map((c) => c.sortID ?? 0).reduce((a, b) => a > b ? a : b);
    final nextSortId = (maxSortId + 1).toString();
    return  [
        [
          ErpFieldConfig(key: 'counterTypeCode', label: 'TYPE',       type: ErpFieldType.dropdown, dropdownItems: counterTypeItems, sectionTitle: 'BASIC INFORMATION', sectionIndex: 0, tabIndex: 0,initialDropValue: true),
          ErpFieldConfig(key: 'divisionCode',    label: 'DIVISION',   type: ErpFieldType.dropdown, dropdownItems: divisionItems,    sectionIndex: 0, tabIndex: 0,initialDropValue: true,required: true,),
          ErpFieldConfig(key: 'deptGroupCode',   label: 'GROUP',      type: ErpFieldType.dropdown, dropdownItems: deptGroupItems,   sectionIndex: 0, tabIndex: 0,initialDropValue: true,required: true,),
          ErpFieldConfig(key: 'deptCode',        label: 'DEPARTMENT', type: ErpFieldType.dropdown, dropdownItems: departmentItems,  sectionIndex: 0, tabIndex: 0,initialDropValue: true,required: true,),
        ],
        [
          ErpFieldConfig(key: 'teamCode', label: 'TEAM',   type: ErpFieldType.dropdown, dropdownItems: teamItems, sectionIndex: 0, tabIndex: 0,initialDropValue: true,required: true,),
          ErpFieldConfig(key: 'userGrp',  label: 'RIGHTS', type: ErpFieldType.dropdown,
              dropdownItems: const [ErpDropdownItem(label: 'Admin', value: 'Admin'), ErpDropdownItem(label: 'User', value: 'User')],
              sectionIndex: 0, tabIndex: 0,initialDropValue: true,required: true,),
          ErpFieldConfig(key: 'logInName', label: 'LOGIN NAME', required: true, sectionIndex: 0, tabIndex: 0,initialDropValue: true,),
          ErpFieldConfig(key: 'crPass',    label: 'PASSWORD',                   sectionIndex: 0, tabIndex: 0,initialDropValue: true,required: true,),
        ],
        [
          ErpFieldConfig(key: 'crName',      label: 'NAME',             required: true,              sectionIndex: 0, tabIndex: 0,initialDropValue: true,),
          ErpFieldConfig(key: 'sortID',      label: 'SORT ID',          type: ErpFieldType.number,   sectionIndex: 0, tabIndex: 0,initialDropValue: true,required: true,),
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
          ErpFieldConfig(key: 'active',      label: 'ACTIVE',           type: ErpFieldType.checkbox, checkboxDbType: 'BIT', sectionIndex: 0, tabIndex: 0,initialBoolValue: true),
        ],
        [
          ErpFieldConfig(key: 'crEdit',       label: 'EDIT',           type: ErpFieldType.dropdown, dropdownItems: _ynItems, sectionTitle: 'PERMISSIONS', sectionIndex: 1, tabIndex: 0,initialDropValue: true),
          ErpFieldConfig(key: 'crDel',        label: 'DELETE',         type: ErpFieldType.dropdown, dropdownItems: _ynItems, sectionIndex: 1, tabIndex: 0,initialDropValue: true),
          ErpFieldConfig(key: 'autoRec',      label: 'CONFIRM REC',    type: ErpFieldType.dropdown, dropdownItems: _ynItems, sectionIndex: 1, tabIndex: 0,initialDropValue: true),
          ErpFieldConfig(key: 'empIssRec',    label: 'EMP ISS REC',    type: ErpFieldType.dropdown, dropdownItems: _ynItems, sectionIndex: 1, tabIndex: 0,initialDropValue: true,initialDropIndex: 1),
          ErpFieldConfig(key: 'empRecWt',     label: 'EMP REC WT',     type: ErpFieldType.dropdown, dropdownItems: _ynItems, sectionIndex: 1, tabIndex: 0,initialDropValue: true,initialDropIndex: 1),
          ErpFieldConfig(key: 'laserPlanRec', label: 'LASER PLAN REC', type: ErpFieldType.dropdown, dropdownItems: _ynItems, sectionIndex: 1, tabIndex: 0,initialDropValue: true),
        ],
        [
          ErpFieldConfig(key: 'polishOut',  label: 'POLISH OUT',  type: ErpFieldType.dropdown, dropdownItems: _ynItems, sectionIndex: 1, tabIndex: 0,initialDropValue: true,initialDropIndex: 1),
          ErpFieldConfig(key: 'stockLimit', label: 'STOCK LIMIT', type: ErpFieldType.number,                            sectionIndex: 1, tabIndex: 0),
          ErpFieldConfig(key: 'target',     label: 'TARGET',      type: ErpFieldType.number,                            sectionIndex: 1, tabIndex: 0),
          ErpFieldConfig(key: 'kachaIss',   label: 'KACHA ISS',   type: ErpFieldType.dropdown, dropdownItems: _ynItems, sectionIndex: 1, tabIndex: 0,initialDropValue: true,initialDropIndex: 1),
        ],
        [
          ErpFieldConfig(key: 'manType',         label: 'MAN TYPE',           type: ErpFieldType.dropdown,initialDropValue: true, dropdownItems: const [ErpDropdownItem(label: 'Days', value: 'Days'), ErpDropdownItem(label: 'Hours', value: 'Hours')], sectionTitle: 'LIMITS', sectionIndex: 2, tabIndex: 0),
          ErpFieldConfig(key: 'manPktDayLimit',  label: 'MAN PKT DAY LIMIT',  type: ErpFieldType.number, readOnly: _selectedManType == 'Hours', sectionIndex: 2, tabIndex: 0),
          ErpFieldConfig(key: 'manPktHourLimit', label: 'MAN PKT HOUR LIMIT', type: ErpFieldType.number, readOnly: _selectedManType == 'Days',  sectionIndex: 2, tabIndex: 0),
        ],
        [
          ErpFieldConfig(key: 'empType',         label: 'EMP TYPE',           type: ErpFieldType.dropdown, initialDropValue: true,dropdownItems: const [ErpDropdownItem(label: 'Days', value: 'Days'), ErpDropdownItem(label: 'Hours', value: 'Hours')], sectionIndex: 2, tabIndex: 0),
          ErpFieldConfig(key: 'empPktDayLimit',  label: 'EMP PKT DAY LIMIT',  type: ErpFieldType.number, readOnly: _selectedEmpType == 'Hours', sectionIndex: 2, tabIndex: 0),
          ErpFieldConfig(key: 'empPktHourLimit', label: 'EMP PKT HOUR LIMIT', type: ErpFieldType.number, readOnly: _selectedEmpType == 'Days',  sectionIndex: 2, tabIndex: 0),
          ErpFieldConfig(key: 'empPktLimit',     label: 'EMP PKT LIMIT',      type: ErpFieldType.number,                                        sectionIndex: 2, tabIndex: 0),
        ],
      ];}

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
        counterTypeItems, divisionItems, deptGroupItems,
        departmentItems, teamItems, mfgDeptItems,
      );
    }

    Widget content() {
      switch (_currentTabIndex) {
        case 0:  return _buildDisplaySetting(visP, theme);
        case 1:  return tabsEnabled ? _buildProcessTab(theme)                      : _lockedMsg(theme);
        case 2:  return tabsEnabled ? _buildMenuRightsTree(mainMenuP, menuP, theme): _lockedMsg(theme);
        case 3:  return tabsEnabled ? _buildAllowManagerIssueTab(theme)            : _lockedMsg(theme);
        case 4:  return tabsEnabled ? _buildAllowManagerReceiveTab(theme)          : _lockedMsg(theme);
        case 5:  return tabsEnabled ? _buildAllowOperatorTab(opP, theme)           : _lockedMsg(theme);
        case 6:  return tabsEnabled ? _buildAllowManagerTab(opP, theme)            : _lockedMsg(theme);
        case 7:  return tabsEnabled ? _buildAllowDeptTab(theme)                    : _lockedMsg(theme);
        case 8:  return tabsEnabled ? _buildShapeLockTab(theme)                    : _lockedMsg(theme);
        case 9:  return tabsEnabled ? _buildAllowStockTypeTab(theme)               : _lockedMsg(theme);
        case 10: return tabsEnabled ? _buildReportRightsTab(theme) : _lockedMsg(theme);
        default: return const SizedBox.shrink();
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        basicSummary(),
        content(),
      ],
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
      ErpDropdownItem(label: 'User',  value: 'User'),
    ];

    InputDecoration dec = InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: theme.border)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: theme.border)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: theme.primary, width: 1.5)),
    );
    Widget dropField(String label, String key, List<ErpDropdownItem> items,
        {bool req = false, bool enabled = true}) {
      final raw      = _formValues[key];
      final val      = (raw == null || raw.isEmpty) ? null : raw;
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
              hint: Text('Select $label',
                  style: TextStyle(fontSize: 11, color: theme.textLight)),
              items: items.map((e) => DropdownMenuItem<String>(
                value: e.value,
                child: Text(e.label, style: TextStyle(fontSize: 11, color: theme.text)),
              )).toList(),
              onChanged: enabled ? (v) => setState(() {
                _formValues[key] = v ?? '';
                if (key == 'deptGroupCode') {
                  _selectedDeptGroupCode = (v == null || v.isEmpty) ? null : v;
                  _formValues['deptCode']    = '';
                  _formValues['mfgDeptCode'] = '';
                }
                if (key == 'deptCode') {
                  _selectedDeptCode = (v == null || v.isEmpty) ? null : v;
                }
              }) : null,
            ),
          ),
        ),
      );
    }
    // ── dropdown field helper ──
    // Widget dropField(String label, String key, List<ErpDropdownItem> items,
    //     {bool req = false}) {
    //   final raw      = _formValues[key];
    //   final val      = (raw == null || raw.isEmpty) ? null : raw;
    //   final validVal = items.any((e) => e.value == val) ? val : null;
    //   return _BasicField(
    //     label: label,
    //     required: req,
    //     child: DropdownButtonFormField<String>(
    //       value: validVal,
    //       isDense: true,
    //       isExpanded: true,
    //       style: TextStyle(fontSize: 11, color: theme.text),
    //       decoration: dec,
    //       hint: Text('Select $label',
    //           style: TextStyle(fontSize: 11, color: theme.textLight)),
    //       items: items
    //           .map((e) => DropdownMenuItem<String>(
    //         value: e.value,
    //         child: Text(e.label,
    //             style: TextStyle(fontSize: 11, color: theme.text)),
    //       ))
    //           .toList(),
    //       onChanged: (v) => setState(() {
    //         _formValues[key] = v ?? '';
    //         if (key == 'deptGroupCode') {
    //           _selectedDeptGroupCode = (v == null || v.isEmpty) ? null : v;
    //           _formValues['deptCode']    = '';
    //           _formValues['mfgDeptCode'] = '';
    //         }
    //         if (key == 'deptCode') {
    //           _selectedDeptCode = (v == null || v.isEmpty) ? null : v;
    //         }
    //       }),
    //     ),
    //   );
    // }

    // ── text field helper ──
    Widget txtField(String label, String key,
        {bool req = false, bool num = false}) {
      return _BasicField(
        label: label,
        required: req,
        child: TextFormField(
          initialValue: _formValues[key] ?? '',
          style: TextStyle(fontSize: 11, color: theme.text),
          keyboardType: num ? TextInputType.number : TextInputType.text,
          decoration: dec,
          onChanged: (v) => setState(() => _formValues[key] = v),
        ),
      );
    }

    // ── checkbox field helper ──
    Widget checkField(String label, String key) {
      final val = _formValues[key] == 'true' || _formValues[key] == '1';
      return _BasicField(
        label: '',
        child: Row(children: [
          Checkbox(
            value: val,
            activeColor: theme.primary,
            visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onChanged: (v) =>
                setState(() => _formValues[key] = (v == true) ? 'true' : 'false'),
          ),
          Text(label, style: TextStyle(fontSize: 11, color: theme.text)),
        ]),
      );
    }
    final deptGroupName = deptGroupItems
        .firstWhereOrNull((e) => e.value == _formValues['deptGroupCode'])
        ?.label ?? '';
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
                colors: theme.primaryGradient.map((c) => c.withOpacity(0.15)).toList(),
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              border: Border(
                  bottom: BorderSide(color: theme.primary.withOpacity(0.15))),
            ),
            child: Row(children: [
              Icon(Icons.person_outline_rounded, size: 13, color: theme.primary),
              const SizedBox(width: 6),
              Text('BASIC INFORMATION',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: theme.primary,
                      letterSpacing: 0.6)),
            ]),
          ),

          // ── Fields ──
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                // Row 1: TYPE, DIVISION, GROUP, DEPARTMENT
                Row(children: [
                  Expanded(child: dropField('TYPE',       'counterTypeCode', counterTypeItems)),
                  const SizedBox(width: 8),
                  Expanded(child: dropField('DIVISION',   'divisionCode',    divisionItems)),
                  const SizedBox(width: 8),
                  Expanded(child: dropField('GROUP',      'deptGroupCode',   deptGroupItems)),
                  const SizedBox(width: 8),
                  Expanded(child: dropField('DEPARTMENT', 'deptCode',        departmentItems)),
                ]),
                const SizedBox(height: 6),

                // Row 2: TEAM, RIGHTS, LOGIN NAME, PASSWORD
                Row(children: [
                  Expanded(child: dropField('TEAM',   'teamCode', teamItems)),
                  const SizedBox(width: 8),
                  Expanded(child: dropField('RIGHTS', 'userGrp',  rightsItems)),
                  const SizedBox(width: 8),
                  Expanded(child: txtField('LOGIN NAME', 'logInName', req: true)),
                  const SizedBox(width: 8),
                  Expanded(child: txtField('PASSWORD', 'crPass')),
                ]),
                const SizedBox(height: 6),

                // Row 3: NAME, SORT ID, MFG RATE ON DEPT, ACTIVE
                Row(children: [
                  Expanded(child: txtField('NAME',    'crName',  req: true)),
                  const SizedBox(width: 8),
                  Expanded(child: txtField('SORT ID', 'sortID',  num: true)),
                  const SizedBox(width: 8),

                  Expanded(child: dropField('MFG RATE ON DEPT', 'mfgDeptCode', mfgDeptItems,enabled: isMfgGroup)),
                  const SizedBox(width: 8),
                  Expanded(child: checkField('ACTIVE', 'active')),
                ]),
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
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.lock_outline_rounded, size: 32, color: theme.textLight.withOpacity(0.4)),
        const SizedBox(height: 8),
        Text('Please save the BASIC tab first.',
            style: TextStyle(fontSize: 12, color: theme.textLight),
            textAlign: TextAlign.center),
      ]),
    );
  }

  Widget _buildDisplaySetting(UserVisibilityProvider visP, ErpTheme theme) {
    // final deptItems = visP.list.where((e) => e.entryType?.toUpperCase() == 'DEPT').toList();
    // final toItems   = deptItems.isNotEmpty ? deptItems : visP.list;
    final deptItems = visP.list
        .where((e) => e.entryType?.toUpperCase() == 'DEPT')
        .toList()
      ..sort((a, b) {
        // ✅ Pehle type wise, phir sortId wise
        final typeCompare = (a.entryType ?? '').compareTo(b.entryType ?? '');
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
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _sectionHeader(theme, 'DISPLAY SETTING'),
        const SizedBox(height: 6),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: _DisplayCheckboxPanel(
            theme: theme, title: 'From Display Setting',
            items: sortedList, selected: _fromSelected,
            onChanged: (code, val) => setState(() {
              if (val) {
                _fromSelected.add(code);
              } else {
                _fromSelected.remove(code);
              }
            }),
          )),
          const SizedBox(width: 8),
          Expanded(child: _DisplayCheckboxPanel(
            theme: theme, title: 'To Display Setting',
            items: toItems, selected: _toSelected,
            onChanged: (code, val) => setState(() {
              if (val) {
                _toSelected.add(code);
              } else {
                _toSelected.remove(code);
              }
            }),
          )),
        ]),
      ]),
    );
  }

  Widget _buildProcessTab(ErpTheme theme) {
    return Consumer<DeptProcessProvider>(builder: (context, procP, _) {
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
      // final filtered = _selectedDeptCode != null
      //     ? procP.list.where((p) => p.deptCode?.toString() == _selectedDeptCode).toList()
      //     : procP.list;
      // if (filtered.isEmpty) {
      //   return Padding(
      //     padding: const EdgeInsets.all(24),
      //     child: Text(
      //       _selectedDeptCode == null
      //           ? 'Please select a Department in BASIC tab first.'
      //           : 'No processes found for selected department.',
      //       style: TextStyle(fontSize: 12, color: theme.textLight),
      //       textAlign: TextAlign.center,
      //     ),
      //   );
      // }
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _sectionHeader(theme, 'DEPT PROCESSES'),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: theme.surface, borderRadius: BorderRadius.circular(10),
              border: Border.all(color: theme.border),
            ),
            // child: Column(
            //   children: filtered.asMap().entries.map((entry) {
            //     final i       = entry.key;
            //     final proc    = entry.value;
            //     final code    = proc.deptProcessCode ?? 0;
            //     final checked = _selectedProcessCodes.contains(code);
            //     return InkWell(
            //       onTap: () => setState(() {
            //         if (checked) _selectedProcessCodes.remove(code);
            //         else         _selectedProcessCodes.add(code);
            //       }),
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
            //             onChanged: (v) => setState(() {
            //               if (v == true) _selectedProcessCodes.add(code);
            //               else           _selectedProcessCodes.remove(code);
            //             }),
            //             visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
            //             materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            //           )),
            //           const SizedBox(width: 8),
            //           Expanded(child: Text(proc.deptProcessName ?? '',
            //               style: TextStyle(fontSize: 11,
            //                   color: checked ? theme.primary : theme.text,
            //                   fontWeight: checked ? FontWeight.w600 : FontWeight.normal))),
            //           Text(code.toString(), style: TextStyle(fontSize: 9, color: theme.textLight)),
            //         ]),
            //       ),
            //     );
            //   }).toList(),
            // ),
            // Column ke andar Container replace karo:

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
            final proc    = filtered[i];
            final code    = proc.deptProcessCode ?? 0;
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
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: checked
                      ? theme.primary.withOpacity(0.07)
                      : i ~/ 2 % 2 == 0 ? Colors.white : theme.bg.withOpacity(0.4),
                  border: Border(
                    bottom: BorderSide(color: theme.border.withOpacity(0.4)),
                    right: i % 2 == 0
                        ? BorderSide(color: theme.border.withOpacity(0.4))
                        : BorderSide.none,
                  ),
                ),
                child: Row(children: [
                  SizedBox(width: 18, height: 22, child: Checkbox(
                    value: checked, activeColor: theme.primary,
                    onChanged: (v) => setState(() {
                      if (v == true) {
                        _selectedProcessCodes.add(code);
                      } else {
                        _selectedProcessCodes.remove(code);
                      }
                    }),
                    visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  )),
                  const SizedBox(width: 4),
                  Expanded(child: Text(proc.deptProcessName ?? '',
                      style: TextStyle(fontSize: 10,
                          color: checked ? theme.primary : theme.text,
                          fontWeight: checked ? FontWeight.w600 : FontWeight.normal),
                      overflow: TextOverflow.ellipsis, maxLines: 1)),
                  Text(code.toString(), style: TextStyle(fontSize: 9, color: theme.textLight)),
                ]),
              ),
            );
          },
        ),
          ),
        ]),
      );
    });
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
            child: Text('No departments found.',
                style: TextStyle(fontSize: 12, color: theme.textLight)),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
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
                  final dept     = dEntry.value;
                  final deptCode = dept.deptCode ?? 0;
                  final isDeptOpen = _expandedIssueDepts.contains(deptCode);
                  final deptCounters = counterP.list
                      .where((c) => c.deptCode == deptCode && c.active == true)
                      .toList();
                  if (deptCounters.isEmpty) return const SizedBox.shrink();
                  final deptSelectedCount = deptCounters
                      .where((c) => (_managerIssueSelected[c.crId ?? 0]?.isNotEmpty ?? false))
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
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDeptOpen ? theme.primary.withOpacity(0.08) : theme.bg,
                            border: Border(
                              top: dEntry.key == 0 ? BorderSide.none : BorderSide(color: theme.border),
                            ),
                          ),
                          child: Row(children: [
                            SizedBox(width: 18, height: 22,
                              child: Checkbox(
                                activeColor: theme.primary,
                                visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                tristate: true,
                                value: () {
                                  final allProcs = deptCounters.expand((c) {
                                    final cId = c.crId ?? 0;
                                    return procP.list.where((p) => p.deptCode == c.deptCode)
                                        .map((p) => MapEntry(cId, p.deptProcessCode ?? 0));
                                  }).toList();
                                  if (allProcs.isEmpty) return false;
                                  final allSel = allProcs.every((e) =>
                                  _managerIssueSelected[e.key]?.contains(e.value) ?? false);
                                  final anySel = allProcs.any((e) =>
                                  _managerIssueSelected[e.key]?.contains(e.value) ?? false);
                                  return allSel ? true : anySel ? null : false;
                                }(),
                                onChanged: (v) => setState(() {
                                  for (final c in deptCounters) {
                                    final cId   = c.crId ?? 0;
                                    final procs = procP.list
                                        .where((p) => p.deptCode == c.deptCode)
                                        .map((p) => p.deptProcessCode ?? 0);
                                    if (v == true) {
                                      _managerIssueSelected.putIfAbsent(cId, () => {}).addAll(procs);
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
                              child: Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: theme.primary),
                            ),
                            const SizedBox(width: 6),
                            Icon(Icons.business_rounded, size: 13, color: theme.primary),
                            const SizedBox(width: 6),
                            Expanded(child: Text(dept.deptName ?? '',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: theme.primary))),
                            if (deptSelectedCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: theme.primary, borderRadius: BorderRadius.circular(8)),
                                child: Text('$deptSelectedCount',
                                    style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w700)),
                              ),
                          ]),
                        ),
                      ),
                      if (isDeptOpen)
                        ...deptCounters.asMap().entries.map((cEntry) {
                          final counter       = cEntry.value;
                          final crId          = counter.crId ?? 0;
                          final isCounterOpen = _expandedIssueCounters.contains(crId);
                          final selectedProcs = _managerIssueSelected[crId] ?? {};
                          final counterProcs  = procP.list
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
                                  padding: const EdgeInsets.only(left: 28, right: 10, top: 4, bottom: 4),
                                  decoration: BoxDecoration(
                                    color: isCounterOpen
                                        ? theme.primary.withOpacity(0.05)
                                        : cEntry.key.isEven ? Colors.white : theme.bg.withOpacity(0.4),
                                    border: Border(top: BorderSide(color: theme.border.withOpacity(0.5))),
                                  ),
                                  child: Row(children: [
                                    SizedBox(width: 18, height: 22,
                                      child: Checkbox(
                                        activeColor: theme.primary,
                                        visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        tristate: true,
                                        value: () {
                                          if (counterProcs.isEmpty) return false;
                                          final allSel = counterProcs.every((p) =>
                                              selectedProcs.contains(p.deptProcessCode ?? 0));
                                          final anySel = counterProcs.any((p) =>
                                              selectedProcs.contains(p.deptProcessCode ?? 0));
                                          return allSel ? true : anySel ? null : false;
                                        }(),
                                        onChanged: (v) => setState(() {
                                          final set = _managerIssueSelected.putIfAbsent(crId, () => {});
                                          if (v == true) {
                                            set.addAll(counterProcs.map((p) => p.deptProcessCode ?? 0));
                                          } else {
                                            _managerIssueSelected.remove(crId);
                                          }
                                        }),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    AnimatedRotation(
                                      turns: isCounterOpen ? 0 : -0.25,
                                      duration: const Duration(milliseconds: 180),
                                      child: Icon(Icons.keyboard_arrow_down_rounded,
                                          size: 14, color: theme.primary.withOpacity(0.7)),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(Icons.person_outline_rounded, size: 12, color: theme.textLight),
                                    const SizedBox(width: 6),
                                    Expanded(child: Text(counter.crName ?? '',
                                        style: TextStyle(fontSize: 11, color: theme.text,
                                            fontWeight: selectedProcs.isNotEmpty ? FontWeight.w600 : FontWeight.normal))),
                                    if (selectedProcs.isNotEmpty)
                                      Text('${selectedProcs.length}/${counterProcs.length}',
                                          style: TextStyle(fontSize: 9, color: theme.primary)),
                                  ]),
                                ),
                              ),
                              if (isCounterOpen)
                                ...counterProcs.asMap().entries.map((pEntry) {
                                  final proc      = pEntry.value;
                                  final procCode  = proc.deptProcessCode ?? 0;
                                  final isChecked = selectedProcs.contains(procCode);
                                  return InkWell(
                                    onTap: () => setState(() {
                                      final set = _managerIssueSelected.putIfAbsent(crId, () => {});
                                      if (isChecked) {
                                        set.remove(procCode);
                                      } else {
                                        set.add(procCode);
                                      }
                                      if (set.isEmpty) _managerIssueSelected.remove(crId);
                                    }),
                                    child: Container(
                                      padding: const EdgeInsets.only(left: 52, right: 10, top: 3, bottom: 3),
                                      decoration: BoxDecoration(
                                        color: isChecked ? theme.primary.withOpacity(0.06) : Colors.white,
                                        border: Border(top: BorderSide(color: theme.border.withOpacity(0.4))),
                                      ),
                                      child: Row(children: [
                                        SizedBox(width: 18, height: 22,
                                          child: Checkbox(
                                            value: isChecked, activeColor: theme.primary,
                                            onChanged: (v) => setState(() {
                                              final set = _managerIssueSelected.putIfAbsent(crId, () => {});
                                              if (v == true) {
                                                set.add(procCode);
                                              } else {
                                                set.remove(procCode);
                                              }
                                              if (set.isEmpty) _managerIssueSelected.remove(crId);
                                            }),
                                            visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(child: Text(proc.deptProcessName ?? '',
                                            style: TextStyle(fontSize: 10,
                                                color: isChecked ? theme.primary : theme.text,
                                                fontWeight: isChecked ? FontWeight.w600 : FontWeight.normal))),
                                      ]),
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
          ]),
        );
      },
    );
  }

  // Widget _buildAllowManagerReceiveTab(ErpTheme theme) {
  //   return Consumer2<CounterProvider, DeptProcessProvider>(
  //     builder: (context, counterP, procP, _) {
  //       final deptProvider   = context.read<DeptProvider>();
  //       final allDepts       = List.of(deptProvider.list)
  //         ..sort((a, b) => (a.sortID ?? 0).compareTo(b.sortID ?? 0));
  //       final issueAllowCrIds = _managerIssueSelected.keys.toSet();
  //
  //       if (_selectedProcessCodes.isEmpty) {
  //         return Padding(
  //           padding: const EdgeInsets.all(24),
  //           child: Text('Please select processes in PROCESS tab first.',
  //               style: TextStyle(fontSize: 12, color: theme.textLight),
  //               textAlign: TextAlign.center),
  //         );
  //       }
  //       if (issueAllowCrIds.isEmpty) {
  //         return Padding(
  //           padding: const EdgeInsets.all(24),
  //           child: Text('Please select counters in Allow Manager Issue tab first.',
  //               style: TextStyle(fontSize: 12, color: theme.textLight),
  //               textAlign: TextAlign.center),
  //         );
  //       }
  //
  //       return Padding(
  //         padding: const EdgeInsets.only(top: 4),
  //         child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
  //           _sectionHeader(theme, 'ALLOW MANAGER RECEIVE'),
  //           const SizedBox(height: 6),
  //           Container(
  //             decoration: BoxDecoration(
  //               color: theme.surface,
  //               borderRadius: BorderRadius.circular(10),
  //               border: Border.all(color: theme.border),
  //             ),
  //             child: Column(
  //               children: allDepts.asMap().entries.map((dEntry) {
  //                 final dept       = dEntry.value;
  //                 final deptCode   = dept.deptCode ?? 0;
  //                 final isDeptOpen = _expandedRecvDepts.contains(deptCode);
  //                 final deptCounters = counterP.list
  //                     .where((c) =>
  //                 c.deptCode == deptCode &&
  //                     c.active == true &&
  //                     issueAllowCrIds.contains(c.crId))
  //                     .toList();
  //                 if (deptCounters.isEmpty) return const SizedBox.shrink();
  //                 final deptSelectedCount = deptCounters
  //                     .where((c) => (_managerRecvSelected[c.crId ?? 0]?.isNotEmpty ?? false))
  //                     .length;
  //                 final matchProcs = procP.list
  //                     .where((p) => _selectedProcessCodes.contains(p.deptProcessCode))
  //                     .toList();
  //
  //                 return Column(
  //                   crossAxisAlignment: CrossAxisAlignment.stretch,
  //                   children: [
  //                     InkWell(
  //                       onTap: () => setState(() {
  //                         if (isDeptOpen) _expandedRecvDepts.remove(deptCode);
  //                         else            _expandedRecvDepts.add(deptCode);
  //                       }),
  //                       child: Container(
  //                         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  //                         decoration: BoxDecoration(
  //                           color: isDeptOpen ? theme.primary.withOpacity(0.08) : theme.bg,
  //                           border: Border(
  //                             top: dEntry.key == 0 ? BorderSide.none : BorderSide(color: theme.border),
  //                           ),
  //                         ),
  //                         child: Row(children: [
  //                           SizedBox(width: 18, height: 22,
  //                             child: Checkbox(
  //                               activeColor: theme.primary,
  //                               visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
  //                               materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  //                               tristate: true,
  //                               value: () {
  //                                 final allPairs = deptCounters.expand((c) {
  //                                   final cId = c.crId ?? 0;
  //                                   return matchProcs.map((p) => MapEntry(cId, p.deptProcessCode ?? 0));
  //                                 }).toList();
  //                                 if (allPairs.isEmpty) return false;
  //                                 final allSel = allPairs.every((e) =>
  //                                 _managerRecvSelected[e.key]?.contains(e.value) ?? false);
  //                                 final anySel = allPairs.any((e) =>
  //                                 _managerRecvSelected[e.key]?.contains(e.value) ?? false);
  //                                 return allSel ? true : anySel ? null : false;
  //                               }(),
  //                               onChanged: (v) => setState(() {
  //                                 for (final c in deptCounters) {
  //                                   final cId = c.crId ?? 0;
  //                                   if (v == true) {
  //                                     _managerRecvSelected.putIfAbsent(cId, () => {})
  //                                         .addAll(matchProcs.map((p) => p.deptProcessCode ?? 0));
  //                                   } else {
  //                                     _managerRecvSelected.remove(cId);
  //                                   }
  //                                 }
  //                               }),
  //                             ),
  //                           ),
  //                           const SizedBox(width: 4),
  //                           AnimatedRotation(
  //                             turns: isDeptOpen ? 0 : -0.25,
  //                             duration: const Duration(milliseconds: 180),
  //                             child: Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: theme.primary),
  //                           ),
  //                           const SizedBox(width: 6),
  //                           Icon(Icons.business_rounded, size: 13, color: theme.primary),
  //                           const SizedBox(width: 6),
  //                           Expanded(child: Text(dept.deptName ?? '',
  //                               style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: theme.primary))),
  //                           if (deptSelectedCount > 0)
  //                             Container(
  //                               padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
  //                               decoration: BoxDecoration(color: theme.primary, borderRadius: BorderRadius.circular(8)),
  //                               child: Text('$deptSelectedCount',
  //                                   style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w700)),
  //                             ),
  //                         ]),
  //                       ),
  //                     ),
  //                     if (isDeptOpen)
  //                       ...deptCounters.asMap().entries.map((cEntry) {
  //                         final counter       = cEntry.value;
  //                         final crId          = counter.crId ?? 0;
  //                         final isCounterOpen = _expandedRecvCounters.contains(crId);
  //                         final selectedProcs = _managerRecvSelected[crId] ?? {};
  //                         return Column(
  //                           crossAxisAlignment: CrossAxisAlignment.stretch,
  //                           children: [
  //                             InkWell(
  //                               onTap: () => setState(() {
  //                                 if (isCounterOpen) _expandedRecvCounters.remove(crId);
  //                                 else               _expandedRecvCounters.add(crId);
  //                               }),
  //                               child: Container(
  //                                 padding: const EdgeInsets.only(left: 28, right: 10, top: 4, bottom: 4),
  //                                 decoration: BoxDecoration(
  //                                   color: isCounterOpen
  //                                       ? theme.primary.withOpacity(0.05)
  //                                       : cEntry.key.isEven ? Colors.white : theme.bg.withOpacity(0.4),
  //                                   border: Border(top: BorderSide(color: theme.border.withOpacity(0.5))),
  //                                 ),
  //                                 child: Row(children: [
  //                                   SizedBox(width: 18, height: 22,
  //                                     child: Checkbox(
  //                                       activeColor: theme.primary,
  //                                       visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
  //                                       materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  //                                       tristate: true,
  //                                       value: () {
  //                                         if (matchProcs.isEmpty) return false;
  //                                         final allSel = matchProcs.every((p) =>
  //                                             selectedProcs.contains(p.deptProcessCode ?? 0));
  //                                         final anySel = matchProcs.any((p) =>
  //                                             selectedProcs.contains(p.deptProcessCode ?? 0));
  //                                         return allSel ? true : anySel ? null : false;
  //                                       }(),
  //                                       onChanged: (v) => setState(() {
  //                                         final set = _managerRecvSelected.putIfAbsent(crId, () => {});
  //                                         if (v == true) {
  //                                           set.addAll(matchProcs.map((p) => p.deptProcessCode ?? 0));
  //                                         } else {
  //                                           _managerRecvSelected.remove(crId);
  //                                         }
  //                                       }),
  //                                     ),
  //                                   ),
  //                                   const SizedBox(width: 4),
  //                                   AnimatedRotation(
  //                                     turns: isCounterOpen ? 0 : -0.25,
  //                                     duration: const Duration(milliseconds: 180),
  //                                     child: Icon(Icons.keyboard_arrow_down_rounded,
  //                                         size: 14, color: theme.primary.withOpacity(0.7)),
  //                                   ),
  //                                   const SizedBox(width: 6),
  //                                   Icon(Icons.person_outline_rounded, size: 12, color: theme.textLight),
  //                                   const SizedBox(width: 6),
  //                                   Expanded(child: Text(counter.crName ?? '',
  //                                       style: TextStyle(fontSize: 11, color: theme.text,
  //                                           fontWeight: selectedProcs.isNotEmpty ? FontWeight.w600 : FontWeight.normal))),
  //                                   if (selectedProcs.isNotEmpty)
  //                                     Text('${selectedProcs.length}/${matchProcs.length}',
  //                                         style: TextStyle(fontSize: 9, color: theme.primary)),
  //                                 ]),
  //                               ),
  //                             ),
  //                             if (isCounterOpen)
  //                               ...matchProcs.asMap().entries.map((pEntry) {
  //                                 final proc      = pEntry.value;
  //                                 final procCode  = proc.deptProcessCode ?? 0;
  //                                 final isChecked = selectedProcs.contains(procCode);
  //                                 return InkWell(
  //                                   onTap: () => setState(() {
  //                                     final set = _managerRecvSelected.putIfAbsent(crId, () => {});
  //                                     if (isChecked) set.remove(procCode); else set.add(procCode);
  //                                     if (set.isEmpty) _managerRecvSelected.remove(crId);
  //                                   }),
  //                                   child: Container(
  //                                     padding: const EdgeInsets.only(left: 52, right: 10, top: 3, bottom: 3),
  //                                     decoration: BoxDecoration(
  //                                       color: isChecked ? theme.primary.withOpacity(0.06) : Colors.white,
  //                                       border: Border(top: BorderSide(color: theme.border.withOpacity(0.4))),
  //                                     ),
  //                                     child: Row(children: [
  //                                       SizedBox(width: 18, height: 22,
  //                                         child: Checkbox(
  //                                           value: isChecked, activeColor: theme.primary,
  //                                           onChanged: (v) => setState(() {
  //                                             final set = _managerRecvSelected.putIfAbsent(crId, () => {});
  //                                             if (v == true) set.add(procCode); else set.remove(procCode);
  //                                             if (set.isEmpty) _managerRecvSelected.remove(crId);
  //                                           }),
  //                                           visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
  //                                           materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  //                                         ),
  //                                       ),
  //                                       const SizedBox(width: 8),
  //                                       Expanded(child: Text(proc.deptProcessName ?? '',
  //                                           style: TextStyle(fontSize: 10,
  //                                               color: isChecked ? theme.primary : theme.text,
  //                                               fontWeight: isChecked ? FontWeight.w600 : FontWeight.normal))),
  //                                     ]),
  //                                   ),
  //                                 );
  //                               }),
  //                           ],
  //                         );
  //                       }),
  //                   ],
  //                 );
  //               }).toList(),
  //             ),
  //           ),
  //         ]),
  //       );
  //     },
  //   );
  // }
  Widget _buildAllowManagerReceiveTab(ErpTheme theme) {
    return Consumer2<CounterProvider, DeptProcessProvider>(
      builder: (context, counterP, procP, _) {
        final deptProvider    = context.read<DeptProvider>();
        final allDepts        = List.of(deptProvider.list)
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
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
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
                  final dept       = dEntry.value;
                  final deptCode   = dept.deptCode ?? 0;
                  final isDeptOpen = _expandedRecvDepts.contains(deptCode);

                  final deptCounters = counterP.list
                      .where((c) =>
                  c.deptCode == deptCode &&
                      c.active == true
                      // &&
                      // issueAllowCrIds.contains(c.crId)
                  )
                      .toList();

                  if (deptCounters.isEmpty) return const SizedBox.shrink();

                  final deptSelectedCount = deptCounters
                      .where((c) => (_managerRecvSelected[c.crId ?? 0]?.isNotEmpty ?? false))
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
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDeptOpen ? theme.primary.withOpacity(0.08) : theme.bg,
                            border: Border(
                              top: dEntry.key == 0 ? BorderSide.none : BorderSide(color: theme.border),
                            ),
                          ),
                          child: Row(children: [
                            SizedBox(width: 18, height: 22,
                              child: Checkbox(
                                activeColor: theme.primary,
                                visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                tristate: true,
                                value: () {
                                  final allPairs = deptCounters.expand((c) {
                                    final cId = c.crId ?? 0;
                                    return matchProcs.map((p) => MapEntry(cId, p.deptProcessCode ?? 0));
                                  }).toList();
                                  if (allPairs.isEmpty) return false;
                                  final allSel = allPairs.every((e) =>
                                  _managerRecvSelected[e.key]?.contains(e.value) ?? false);
                                  final anySel = allPairs.any((e) =>
                                  _managerRecvSelected[e.key]?.contains(e.value) ?? false);
                                  return allSel ? true : anySel ? null : false;
                                }(),
                                onChanged: (v) => setState(() {
                                  for (final c in deptCounters) {
                                    final cId = c.crId ?? 0;
                                    if (v == true) {
                                      _managerRecvSelected
                                          .putIfAbsent(cId, () => {})
                                          .addAll(matchProcs.map((p) => p.deptProcessCode ?? 0));
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
                              child: Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: theme.primary),
                            ),
                            const SizedBox(width: 6),
                            Icon(Icons.business_rounded, size: 13, color: theme.primary),
                            const SizedBox(width: 6),
                            Expanded(child: Text(dept.deptName ?? '',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: theme.primary))),
                            if (deptSelectedCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: theme.primary, borderRadius: BorderRadius.circular(8)),
                                child: Text('$deptSelectedCount',
                                    style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w700)),
                              ),
                          ]),
                        ),
                      ),

                      if (isDeptOpen)
                        ...deptCounters.asMap().entries.map((cEntry) {
                          final counter       = cEntry.value;
                          final crId          = counter.crId ?? 0;
                          final isCounterOpen = _expandedRecvCounters.contains(crId);
                          final selectedProcs = _managerRecvSelected[crId] ?? {};

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
                                  padding: const EdgeInsets.only(left: 28, right: 10, top: 4, bottom: 4),
                                  decoration: BoxDecoration(
                                    color: isCounterOpen
                                        ? theme.primary.withOpacity(0.05)
                                        : cEntry.key.isEven ? Colors.white : theme.bg.withOpacity(0.4),
                                    border: Border(top: BorderSide(color: theme.border.withOpacity(0.5))),
                                  ),
                                  child: Row(children: [
                                    SizedBox(width: 18, height: 22,
                                      child: Checkbox(
                                        activeColor: theme.primary,
                                        visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        tristate: true,
                                        value: () {
                                          if (matchProcs.isEmpty) return false;
                                          final allSel = matchProcs.every((p) =>
                                              selectedProcs.contains(p.deptProcessCode ?? 0));
                                          final anySel = matchProcs.any((p) =>
                                              selectedProcs.contains(p.deptProcessCode ?? 0));
                                          return allSel ? true : anySel ? null : false;
                                        }(),
                                        onChanged: (v) => setState(() {
                                          final set = _managerRecvSelected.putIfAbsent(crId, () => {});
                                          if (v == true) {
                                            set.addAll(matchProcs.map((p) => p.deptProcessCode ?? 0));
                                          } else {
                                            _managerRecvSelected.remove(crId);
                                          }
                                        }),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    AnimatedRotation(
                                      turns: isCounterOpen ? 0 : -0.25,
                                      duration: const Duration(milliseconds: 180),
                                      child: Icon(Icons.keyboard_arrow_down_rounded,
                                          size: 14, color: theme.primary.withOpacity(0.7)),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(Icons.person_outline_rounded, size: 12, color: theme.textLight),
                                    const SizedBox(width: 6),
                                    Expanded(child: Text(counter.crName ?? '',
                                        style: TextStyle(fontSize: 11, color: theme.text,
                                            fontWeight: selectedProcs.isNotEmpty ? FontWeight.w600 : FontWeight.normal))),
                                    if (selectedProcs.isNotEmpty)
                                      Text('${selectedProcs.length}/${matchProcs.length}',
                                          style: TextStyle(fontSize: 9, color: theme.primary)),
                                  ]),
                                ),
                              ),

                              if (isCounterOpen)
                                ...matchProcs.asMap().entries.map((pEntry) {
                                  final proc      = pEntry.value;
                                  final procCode  = proc.deptProcessCode ?? 0;
                                  final isChecked = selectedProcs.contains(procCode);
                                  return InkWell(
                                    onTap: () => setState(() {
                                      final set = _managerRecvSelected.putIfAbsent(crId, () => {});
                                      if (isChecked) {
                                        set.remove(procCode);
                                      } else {
                                        set.add(procCode);
                                      }
                                      if (set.isEmpty) _managerRecvSelected.remove(crId);
                                    }),
                                    child: Container(
                                      padding: const EdgeInsets.only(left: 52, right: 10, top: 3, bottom: 3),
                                      decoration: BoxDecoration(
                                        color: isChecked ? theme.primary.withOpacity(0.06) : Colors.white,
                                        border: Border(top: BorderSide(color: theme.border.withOpacity(0.4))),
                                      ),
                                      child: Row(children: [
                                        SizedBox(width: 18, height: 22,
                                          child: Checkbox(
                                            value: isChecked, activeColor: theme.primary,
                                            onChanged: (v) => setState(() {
                                              final set = _managerRecvSelected.putIfAbsent(crId, () => {});
                                              if (v == true) {
                                                set.add(procCode);
                                              } else {
                                                set.remove(procCode);
                                              }
                                              if (set.isEmpty) _managerRecvSelected.remove(crId);
                                            }),
                                            visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(child: Text(proc.deptProcessName ?? '',
                                            style: TextStyle(fontSize: 10,
                                                color: isChecked ? theme.primary : theme.text,
                                                fontWeight: isChecked ? FontWeight.w600 : FontWeight.normal))),
                                      ]),
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
          ]),
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
            child: Text('No report types found.',
                style: TextStyle(fontSize: 12, color: theme.textLight),
                textAlign: TextAlign.center),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
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
                  final test       = tEntry.value;
                  final testCode   = test.testCode ?? 0;
                  final isExpanded = !_collapsedMainMenus.contains(testCode + 10000); // reuse collapsed set
                  final testReports = reportP.list
                      .where((r) => r.testCode == testCode)
                      .toList()
                    ..sort((a, b) => (a.sortID ?? 0).compareTo(b.sortID ?? 0));

                  if (testReports.isEmpty) return const SizedBox.shrink();

                  final childIds   = testReports.map((r) => r.reportCode ?? 0).toSet();
                  final allChecked = childIds.isNotEmpty &&
                      childIds.every((id) => _selectedReportCodes.contains(id));
                  final anyChecked = childIds.any((id) => _selectedReportCodes.contains(id));

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
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: theme.bg,
                            border: Border(top: tEntry.key == 0
                                ? BorderSide.none
                                : BorderSide(color: theme.border)),
                          ),
                          child: Row(children: [
                            SizedBox(width: 20, height: 22,
                              child: Checkbox(
                                value: allChecked ? true : anyChecked ? null : false,
                                tristate: true,
                                activeColor: theme.primary,
                                visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                onChanged: (v) => setState(() {
                                  if (!allChecked) {
                                    _selectedReportCodes.addAll(childIds);
                                  } else {
                                    _selectedReportCodes.removeAll(childIds);
                                  }
                                }),
                              ),
                            ),
                            const SizedBox(width: 4),
                            AnimatedRotation(
                              turns: isExpanded ? 0 : -0.25,
                              duration: const Duration(milliseconds: 180),
                              child: Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: theme.primary),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.folder_outlined, size: 13, color: theme.primary),
                            const SizedBox(width: 6),
                            Expanded(child: Text('Type: ${test.testName ?? ''}',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: theme.primary))),
                            Text('${childIds.intersection(_selectedReportCodes).length}/${childIds.length}',
                                style: TextStyle(fontSize: 9, color: theme.textLight)),
                          ]),
                        ),
                      ),
                      if (isExpanded)
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 15,
                            crossAxisSpacing: 0,
                            mainAxisSpacing: 0,
                          ),
                          itemCount: testReports.length,
                          itemBuilder: (ctx, i) {
                            final report    = testReports[i];
                            final code      = report.reportCode ?? 0;
                            final isChecked = _selectedReportCodes.contains(code);
                            return InkWell(
                              onTap: () => setState(() {
                                if (isChecked) {
                                  _selectedReportCodes.remove(code);
                                } else {
                                  _selectedReportCodes.add(code);
                                }
                              }),
                              child: Container(
                                padding: const EdgeInsets.only(left: 10, right: 6, top: 2, bottom: 2),
                                decoration: BoxDecoration(
                                  color: isChecked
                                      ? theme.primary.withOpacity(0.06)
                                      : i ~/ 2 % 2 == 0 ? Colors.white : theme.bg.withOpacity(0.4),
                                  border: Border(
                                    top: BorderSide(color: theme.border.withOpacity(0.4)),
                                    right: i % 2 == 0
                                        ? BorderSide(color: theme.border.withOpacity(0.4))
                                        : BorderSide.none,
                                  ),
                                ),
                                child: Row(children: [
                                  SizedBox(width: 18, height: 22, child: Checkbox(
                                    value: isChecked, activeColor: theme.primary,
                                    onChanged: (v) => setState(() {
                                      if (v == true) {
                                        _selectedReportCodes.add(code);
                                      } else {
                                        _selectedReportCodes.remove(code);
                                      }
                                    }),
                                    visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  )),
                                  const SizedBox(width: 4),
                                  Expanded(child: Text(report.reportName ?? '',
                                      style: TextStyle(fontSize: 10,
                                          color: isChecked ? theme.primary : theme.text,
                                          fontWeight: isChecked ? FontWeight.w600 : FontWeight.normal),
                                      overflow: TextOverflow.ellipsis, maxLines: 1)),
                                ]),
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
          ]),
        );
      },
    );
  }

  Widget _buildMenuRightsTree(MainMenuMstProvider mainMenuP, MenuMstProvider menuP, ErpTheme theme) {
    final allMainMenus = mainMenuP.list;
    final allMenus     = menuP.list;
    if (allMainMenus.isEmpty) {
      return Padding(padding: const EdgeInsets.all(16),
          child: Text('Loading menu rights...', style: TextStyle(color: theme.textLight, fontSize: 12)));
    }
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _sectionHeader(theme, 'MENU RIGHTS'),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: theme.surface, borderRadius: BorderRadius.circular(10),
            border: Border.all(color: theme.border),
          ),
          child: Column(
            children: allMainMenus.map((mainMenu) {
              final mainMenuId  = mainMenu.mainMenuMstID ?? 0;
              final children    = allMenus.where((m) => m.mainMenuMstID == mainMenuId).toList();
              final childIds    = children.map((m) => m.menuMstID ?? 0).toSet();
              final allChecked  = childIds.isNotEmpty && childIds.every((id) => _selectedMenuIds.contains(id));
              final someChecked = childIds.any((id) => _selectedMenuIds.contains(id));
              final isCollapsed = _collapsedMainMenus.contains(mainMenuId);
              return Column(
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
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: theme.bg,
                        border: Border(top: BorderSide(color: theme.border)),
                      ),
                      child: Row(children: [
                        SizedBox(width: 20, height: 22, child: Checkbox(
                          value: allChecked ? true : someChecked ? null : false,
                          tristate: true, activeColor: theme.primary,
                          onChanged: (v) => setState(() {
                            if (!allChecked) {
                              _selectedMenuIds.addAll(childIds);
                            } else {
                              _selectedMenuIds.removeAll(childIds);
                            }
                          }),
                          visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        )),
                        const SizedBox(width: 4),
                        AnimatedRotation(
                          turns: isCollapsed ? -0.25 : 0,
                          duration: const Duration(milliseconds: 180),
                          child: Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: theme.primary),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.folder_outlined, size: 13, color: theme.primary),
                        const SizedBox(width: 6),
                        Expanded(child: Text('Menu: ${mainMenu.mainMenuName ?? ''}',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: theme.primary))),
                        Text('${childIds.intersection(_selectedMenuIds).length}/${childIds.length}',
                            style: TextStyle(fontSize: 9, color: theme.textLight)),
                      ]),
                    ),
                  ),
                  // if (!isCollapsed) ke baad:
                  if (!isCollapsed)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 13,
                        crossAxisSpacing: 0,
                        mainAxisSpacing: 0,
                      ),
                      itemCount: children.length,
                      itemBuilder: (ctx, i) {
                        final menu      = children[i];
                        final menuId    = menu.menuMstID ?? 0;
                        final isChecked = _selectedMenuIds.contains(menuId);
                        return InkWell(
                          onTap: () => setState(() {
                            if (isChecked) {
                              _selectedMenuIds.remove(menuId);
                            } else {
                              _selectedMenuIds.add(menuId);
                            }
                          }),
                          child: Container(
                            padding: const EdgeInsets.only(left: 10, right: 6, top: 2, bottom: 2),
                            decoration: BoxDecoration(
                              color: isChecked
                                  ? theme.primary.withOpacity(0.06)
                                  : i ~/ 2 % 2 == 0 ? Colors.white : theme.bg.withOpacity(0.4),
                              border: Border(
                                top: BorderSide(color: theme.border.withOpacity(0.4)),
                                right: i % 2 == 0
                                    ? BorderSide(color: theme.border.withOpacity(0.4))
                                    : BorderSide.none,
                              ),
                            ),
                            child: Row(children: [
                              SizedBox(width: 18, height: 22, child: Checkbox(
                                value: isChecked, activeColor: theme.primary,
                                onChanged: (v) => setState(() {
                                  if (v == true) {
                                    _selectedMenuIds.add(menuId);
                                  } else {
                                    _selectedMenuIds.remove(menuId);
                                  }
                                }),
                                visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              )),
                              const SizedBox(width: 4),
                              Expanded(child: Text(menu.menuName ?? '',
                                  style: TextStyle(fontSize: 10,
                                      color: isChecked ? theme.primary : theme.text,
                                      fontWeight: isChecked ? FontWeight.w600 : FontWeight.normal),
                                  overflow: TextOverflow.ellipsis, maxLines: 1)),
                            ]),
                          ),
                        );
                      },
                    ),
                  // if (!isCollapsed)
                  //   ...children.map((menu) {
                  //     final menuId    = menu.menuMstID ?? 0;
                  //     final isChecked = _selectedMenuIds.contains(menuId);
                  //     return InkWell(
                  //       onTap: () => setState(() {
                  //         if (isChecked) _selectedMenuIds.remove(menuId);
                  //         else           _selectedMenuIds.add(menuId);
                  //       }),
                  //       child: Container(
                  //         padding: const EdgeInsets.only(left: 44, right: 10, top: 3, bottom: 3),
                  //         decoration: BoxDecoration(
                  //           color: isChecked ? theme.primary.withOpacity(0.06) : Colors.white,
                  //           border: Border(top: BorderSide(color: theme.border.withOpacity(0.5))),
                  //         ),
                  //         child: Row(children: [
                  //           SizedBox(width: 18, height: 22, child: Checkbox(
                  //             value: isChecked, activeColor: theme.primary,
                  //             onChanged: (v) => setState(() {
                  //               if (v == true) _selectedMenuIds.add(menuId);
                  //               else           _selectedMenuIds.remove(menuId);
                  //             }),
                  //             visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
                  //             materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  //           )),
                  //           const SizedBox(width: 8),
                  //           Icon(Icons.check_box_outline_blank_rounded, size: 11, color: theme.textLight),
                  //           const SizedBox(width: 6),
                  //           Expanded(child: Text(menu.menuName ?? '',
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
      ]),
    );
  }

  Widget _buildAllowOperatorTab(CounterOperatorDetProvider opP, ErpTheme theme) {
    return Consumer<CounterProvider>(builder: (context, counterP, _) {
      final allCounters = counterP.list;
      if (allCounters.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Text('No counters found.',
              style: TextStyle(fontSize: 12, color: theme.textLight), textAlign: TextAlign.center),
        );
      }
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _sectionHeader(theme, 'ALLOW OPERATOR'),
          const SizedBox(height: 6),
          _buildAllowCheckboxList(
            theme:     theme,
            items:     allCounters.map((c) => _AllowItem(crId: c.crId ?? 0, label: c.crName ?? '', subLabel: c.logInName ?? '')).toList(),
            selected:  _selectedOperatorIds,
            onChanged: (id, val) => setState(() {
              if (val) {
                _selectedOperatorIds.add(id);
              } else {
                _selectedOperatorIds.remove(id);
              }
            }),
          ),
        ]),
      );
    });
  }

  Widget _buildAllowManagerTab(CounterOperatorDetProvider mgP, ErpTheme theme) {
    return Consumer<CounterProvider>(builder: (context, counterP, _) {
      final managerCounters = counterP.list
          .where((c) => c.counterTypeCode == 1 || c.counterTypeCode == 3)
          .toList();
      if (managerCounters.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Text('No manager counters found (type 1 or 3).',
              style: TextStyle(fontSize: 12, color: theme.textLight), textAlign: TextAlign.center),
        );
      }
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _sectionHeader(theme, 'ALLOW MANAGER'),
          const SizedBox(height: 6),
          _buildAllowCheckboxList(
            theme:     theme,
            items:     managerCounters.map((c) => _AllowItem(crId: c.crId ?? 0, label: c.crName ?? '', subLabel: c.logInName ?? '')).toList(),
            selected:  _selectedManagerIds,
            onChanged: (id, val) => setState(() {
              if (val) {
                _selectedManagerIds.add(id);
              } else {
                _selectedManagerIds.remove(id);
              }
            }),
          ),
        ]),
      );
    });
  }

  Widget _buildAllowStockTypeTab(ErpTheme theme) {
    return Consumer<StockTypeProvider>(builder: (context, stP, _) {
      final allTypes = List.of(stP.list)..sort((a, b) => (a.sortID ?? 0).compareTo(b.sortID ?? 0));
      if (allTypes.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Text('No stock types found.',
              style: TextStyle(fontSize: 12, color: theme.textLight), textAlign: TextAlign.center),
        );
      }
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _sectionHeader(theme, 'ALLOW STOCK TYPE'),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: theme.surface, borderRadius: BorderRadius.circular(10),
              border: Border.all(color: theme.border),
            ),
            child: Column(
              children: allTypes.asMap().entries.map((entry) {
                final i       = entry.key;
                final st      = entry.value;
                final code    = st.stockTypeCode ?? 0;
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: checked ? theme.primary.withOpacity(0.07)
                          : i.isEven ? Colors.white : theme.bg.withOpacity(0.5),
                      border: Border(top: i == 0 ? BorderSide.none
                          : BorderSide(color: theme.border.withOpacity(0.5))),
                    ),
                    child: Row(children: [
                      SizedBox(width: 20, height: 26, child: Checkbox(
                        value: checked, activeColor: theme.primary,
                        onChanged: (v) => setState(() {
                          if (v == true) {
                            _selectedStockTypeIds.add(code);
                          } else {
                            _selectedStockTypeIds.remove(code);
                          }
                        }),
                        visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      )),
                      const SizedBox(width: 8),
                      Expanded(child: Text(st.stockTypeName ?? '',
                          style: TextStyle(fontSize: 11,
                              color: checked ? theme.primary : theme.text,
                              fontWeight: checked ? FontWeight.w600 : FontWeight.normal))),
                      if ((st.sortID ?? 0) > 0)
                        Text('${st.sortID}', style: TextStyle(fontSize: 9, color: theme.textLight)),
                    ]),
                  ),
                );
              }).toList(),
            ),
          ),
        ]),
      );
    });
  }

  Widget _buildShapeLockTab(ErpTheme theme) {
    return Consumer<ShapeProvider>(builder: (context, shapeP, _) {
      final allShapes = List.of(shapeP.list)..sort((a, b) => (a.sortID ?? 0).compareTo(b.sortID ?? 0));
      if (allShapes.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Text('No shapes found.',
              style: TextStyle(fontSize: 12, color: theme.textLight), textAlign: TextAlign.center),
        );
      }
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _sectionHeader(theme, 'SHAPE LOCK'),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: theme.surface, borderRadius: BorderRadius.circular(10),
              border: Border.all(color: theme.border),
            ),
            child: Column(
              children: allShapes.asMap().entries.map((entry) {
                final i       = entry.key;
                final shape   = entry.value;
                final code    = shape.shapeCode ?? 0;
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: checked ? theme.primary.withOpacity(0.07)
                          : i.isEven ? Colors.white : theme.bg.withOpacity(0.5),
                      border: Border(top: i == 0 ? BorderSide.none
                          : BorderSide(color: theme.border.withOpacity(0.5))),
                    ),
                    child: Row(children: [
                      SizedBox(width: 20, height: 26, child: Checkbox(
                        value: checked, activeColor: theme.primary,
                        onChanged: (v) => setState(() {
                          if (v == true) {
                            _selectedShapeIds.add(code);
                          } else {
                            _selectedShapeIds.remove(code);
                          }
                        }),
                        visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      )),
                      const SizedBox(width: 8),
                      Expanded(child: Text(shape.shapeName ?? '',
                          style: TextStyle(fontSize: 11,
                              color: checked ? theme.primary : theme.text,
                              fontWeight: checked ? FontWeight.w600 : FontWeight.normal))),
                      if (shape.sortID != null)
                        Text(shape.sortID.toString(), style: TextStyle(fontSize: 9, color: theme.textLight)),
                    ]),
                  ),
                );
              }).toList(),
            ),
          ),
        ]),
      );
    });
  }
  Widget _buildTable(CounterProvider p) {
    return Consumer4<CounterTypeProvider, DivisionProvider, DeptGroupProvider, DeptProvider>(
      builder: (context, ctP, divP, dgP, deptP, _) {
        // Join names
        final enrichedData = p.list.map((c) {
          return {
            '_raw': c,
            'crId':           c.crId?.toString() ?? '',
            'logInName':      c.logInName ?? '',
            'crName':         c.crName ?? '',
            'userGrp':        c.userGrp ?? '',
            'sortID':         c.sortID?.toString() ?? '',
            'active':         c.active == true ? '✓' : '',
            'counterTypeName': ctP.list.firstWhereOrNull((e) => e.counterTypeCode == c.counterTypeCode)?.counterTypeName ?? '-',
            'divisionName':   divP.divisions.firstWhereOrNull((e) => e.divisionCode == c.divisionCode)?.divisionName ?? '-',
            'deptGroupName':  dgP.list.firstWhereOrNull((e) => e.deptGroupCode == c.deptGroupCode)?.deptGroupName ?? '-',
            'deptName':       deptP.list.firstWhereOrNull((e) => e.deptCode == c.deptCode)?.deptName ?? '-',
            'teamName':       '-', // TeamProvider add karo agar chahiye
            'mfgDeptName':    deptP.list.firstWhereOrNull((e) => e.deptCode == c.mfgDeptCode)?.deptName ?? '-',
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
    return Consumer<DeptProvider>(builder: (context, deptP, _) {
      final allDepts = List.of(deptP.list)..sort((a, b) => (a.sortID ?? 0).compareTo(b.sortID ?? 0));
      if (allDepts.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Text('No departments found.',
              style: TextStyle(fontSize: 12, color: theme.textLight), textAlign: TextAlign.center),
        );
      }
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _sectionHeader(theme, 'ALLOW DEPARTMENT'),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: theme.surface, borderRadius: BorderRadius.circular(10),
              border: Border.all(color: theme.border),
            ),
            child: Column(
              children: allDepts.asMap().entries.map((entry) {
                final i       = entry.key;
                final dept    = entry.value;
                final code    = dept.deptCode ?? 0;
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: checked ? theme.primary.withOpacity(0.07)
                          : i.isEven ? Colors.white : theme.bg.withOpacity(0.5),
                      border: Border(top: i == 0 ? BorderSide.none
                          : BorderSide(color: theme.border.withOpacity(0.5))),
                    ),
                    child: Row(children: [
                      SizedBox(width: 20, height: 26, child: Checkbox(
                        value: checked, activeColor: theme.primary,
                        onChanged: (v) => setState(() {
                          if (v == true) {
                            _selectedDeptIds.add(code);
                          } else {
                            _selectedDeptIds.remove(code);
                          }
                        }),
                        visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      )),
                      const SizedBox(width: 8),
                      Expanded(child: Text(dept.deptName ?? '',
                          style: TextStyle(fontSize: 11,
                              color: checked ? theme.primary : theme.text,
                              fontWeight: checked ? FontWeight.w600 : FontWeight.normal))),
                      if ((dept.sortID ?? 0) > 0)
                        Text('${dept.sortID}', style: TextStyle(fontSize: 9, color: theme.textLight)),
                    ]),
                  ),
                );
              }).toList(),
            ),
          ),
        ]),
      );
    });
  }

  Widget _buildAllowCheckboxList({
    required ErpTheme theme,
    required List<_AllowItem> items,
    required Set<int> selected,
    required void Function(int id, bool val) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.surface, borderRadius: BorderRadius.circular(10),
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
          final item    = items[i];
          final checked = selected.contains(item.crId);

          return InkWell(
            onTap: () => onChanged(item.crId, !checked),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: checked
                    ? theme.primary.withOpacity(0.08)
                    : i ~/ 2 % 2 == 0 ? Colors.white : theme.bg.withOpacity(0.4),
                border: Border(
                  bottom: BorderSide(color: theme.border.withOpacity(0.4)),
                  right: i % 2 == 0
                      ? BorderSide(color: theme.border.withOpacity(0.4))
                      : BorderSide.none,
                ),
              ),
              child: Row(children: [
                SizedBox(width: 18, height: 22, child: Checkbox(
                  value: checked, activeColor: theme.primary,
                  onChanged: (v) => onChanged(item.crId, v ?? false),
                  visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                )),
                const SizedBox(width: 4),
                Expanded(child: Text(item.label,
                    style: TextStyle(
                        fontSize: 10,
                        color: checked ? theme.primary : theme.text,
                        fontWeight: checked ? FontWeight.w600 : FontWeight.normal),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1)),
                if (item.subLabel.isNotEmpty)
                  Text(item.subLabel,
                      style: TextStyle(fontSize: 9, color: theme.textLight)),
              ]),
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
            colors: theme.primaryGradient.map((c) => c.withOpacity(0.13)).toList()),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.primary.withOpacity(0.3)),
      ),
      child: Text(title,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: theme.primary,
              letterSpacing: 0.8)),
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
            text: TextSpan(children: [
              TextSpan(
                text: label,
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: theme.textLight,
                    letterSpacing: 0.3),
              ),
              if (required)
                const TextSpan(
                    text: ' *',
                    style: TextStyle(fontSize: 9, color: Colors.red)),
            ]),
          ),
        if (label.isNotEmpty) const SizedBox(height: 2),
        child,
      ],
    );
  }
}

// ─── Allow Item helper ────────────────────────────────────────────────────────
class _AllowItem {
  final int    crId;
  final String label;
  final String subLabel;
  const _AllowItem({required this.crId, required this.label, required this.subLabel});
}

// ─── Display Checkbox Panel ───────────────────────────────────────────────────
class _DisplayCheckboxPanel extends StatelessWidget {
  final ErpTheme theme;
  final String title;
  final List<UserVisibilityModel> items;
  final Set<int> selected;
  final void Function(int code, bool val) onChanged;

  const _DisplayCheckboxPanel({
    required this.theme, required this.title,
    required this.items, required this.selected, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: t.primaryGradient.map((c) => c.withOpacity(0.15)).toList()),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          border: Border.all(color: t.primary.withOpacity(0.3)),
        ),
        child: Row(children: [
          Icon(
              title.toLowerCase().contains('from')
                  ? Icons.arrow_forward_rounded
                  : Icons.arrow_back_rounded,
              size: 13, color: t.primary),
          const SizedBox(width: 6),
          Expanded(child: Text(title,
              style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w700,
                  color: t.primary, letterSpacing: 0.4))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: t.primary, borderRadius: BorderRadius.circular(8)),
            child: Text('${selected.length}',
                style: const TextStyle(
                    fontSize: 9, color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ]),
      ),
      Container(
        // constraints: const BoxConstraints(maxHeight: 200),
        decoration: BoxDecoration(
          color: t.surface, border: Border.all(color: t.border),
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
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
            final item    = items[i];
            final code    = item.userVisibilityCode ?? 0;
            final checked = selected.contains(code);

            return InkWell(
              onTap: () => onChanged(code, !checked),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: checked
                      ? t.primary.withOpacity(0.08)
                      : i ~/ 2 % 2 == 0 ? Colors.white : t.bg.withOpacity(0.4),
                  border: Border(
                    bottom: BorderSide(color: t.border.withOpacity(0.4)),
                    right: i % 2 == 0
                        ? BorderSide(color: t.border.withOpacity(0.4))
                        : BorderSide.none,
                  ),
                ),
                child: Row(children: [
                  SizedBox(width: 18, height: 22, child: Checkbox(
                    value: checked, activeColor: t.primary,
                    onChanged: (v) => onChanged(code, v ?? false),
                    visualDensity: const VisualDensity(
                        vertical: -4, horizontal: -4),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  )),
                  const SizedBox(width: 4),
                  Expanded(child: Text(item.userVisibilityName ?? '',
                      style: TextStyle(
                          fontSize: 10,
                          color: checked ? t.primary : t.text,
                          fontWeight: checked
                              ? FontWeight.w600
                              : FontWeight.normal),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1)),
                  if (item.entryType != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 3, vertical: 1),
                      decoration: BoxDecoration(
                          color: t.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4)),
                      child: Text(item.entryType!,
                          style: TextStyle(
                              fontSize: 7,
                              color: t.primary,
                              fontWeight: FontWeight.w700)),
                    ),
                ]),
              ),
            );
          },
        ),
      ),
    ]);
  }
}

// import 'package:erp_data_table/erp_data_table.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:rs_dashboard/rs_dashboard.dart';
//
// import '../models/counter_model.dart';
// import '../models/user_visibility_model.dart';
// import '../providers/counter_provider.dart';
// import '../providers/counter_display_det_provider.dart';
// import '../providers/counter_det_provider.dart';
// import '../providers/counter_process_provider.dart';
// import '../providers/dept_provider.dart';
// import '../providers/main_menuMst_provider.dart';
// import '../providers/user_visibility_provider.dart';
// import '../providers/counter_type_provider.dart';
// import '../providers/division_provider.dart';
// import '../providers/dept_group_provider.dart';
// import '../providers/team_provider.dart';
// import '../providers/menu_mst_provider.dart';
// import '../providers/dept_process_provider.dart';
// import '../utils/app_images.dart';
// import '../utils/delete_dialogue.dart';
// import '../utils/msg_dialogue.dart';
//
// class MstCounter extends StatefulWidget {
//   const MstCounter({super.key});
//
//   @override
//   State<MstCounter> createState() => _MstCounterState();
// }
//
// class _MstCounterState extends State<MstCounter> {
//   ErpThemeVariant _themeVariant = ErpThemeVariant.frost;
//   ErpTheme get _theme => ErpTheme(_themeVariant);
//
//   final GlobalKey<ErpFormState> _erpFormKey = GlobalKey<ErpFormState>();
//   Map<String, dynamic>? _selectedRow;
//   bool _isEditMode        = false;
//   bool _showSearch        = false;
//   bool _showTableOnMobile = false;
//   Map<String, String> _formValues = {};
//
//   // Dependent dropdowns
//   String? _selectedDeptGroupCode;
//   String? _selectedDeptCode;   // Process tab filter ke liye
//   String? _selectedManType;
//   String? _selectedEmpType;
//
//   // Tab tracking (ErpForm ke tab index se sync)
//   int _currentTabIndex = 0;
//
//   // USER tab: Display Setting checkboxes
//   Set<int> _fromSelected = {};
//   Set<int> _toSelected   = {};
//
//   // USER tab: Menu Rights tree
//   Set<int> _selectedMenuIds     = {};
//   Set<int> _collapsedMainMenus  = {};
//
//   // PROCESS tab: selected processes
//   Set<int> _selectedProcessCodes = {};
//
//   final String? token = AppStorage.getString("token");
//
//   // ── TABLE COLUMNS ─────────────────────────────────────────────────────────
//   List<ErpColumnConfig> get _tableColumns => [
//     ErpColumnConfig(key: 'crId',      label: 'CR ID',  width: 80),
//     ErpColumnConfig(key: 'crName',    label: 'NAME',   width: 180),
//     ErpColumnConfig(key: 'logInName', label: 'LOGIN',  width: 140),
//     ErpColumnConfig(key: 'userGrp',   label: 'GROUP',  width: 110),
//     ErpColumnConfig(key: 'deptCode',  label: 'DEPT',   width: 90),
//     ErpColumnConfig(key: 'active',    label: 'ACTIVE', width: 90),
//   ];
//
//   List<ErpDropdownItem> get _ynItems => const [
//     ErpDropdownItem(label: 'Y', value: 'Y'),
//     ErpDropdownItem(label: 'N', value: 'N'),
//   ];
//
//   // ── INIT ──────────────────────────────────────────────────────────────────
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       await Future.wait([
//         context.read<CounterTypeProvider>().load(),
//         context.read<DivisionProvider>().loadDivisions(),
//         context.read<DeptGroupProvider>().load(),
//         context.read<DeptProvider>().load(),
//         context.read<TeamProvider>().load(),
//         context.read<UserVisibilityProvider>().load(),
//         context.read<MainMenuMstProvider>().load(),
//         context.read<MenuMstProvider>().load(),
//         context.read<DeptProcessProvider>().load(),
//       ]);
//       if (!mounted) return;
//       await context.read<CounterProvider>().load();
//     });
//   }
//
//   // ── ROW TAP ───────────────────────────────────────────────────────────────
//   void _onRowTap(Map<String, dynamic> row) {
//     final raw = row['_raw'] as CounterModel;
//     setState(() {
//       _selectedRow           = row;
//       _isEditMode            = true;
//       _showSearch            = false;
//       _selectedDeptGroupCode = raw.deptGroupCode?.toString();
//       _selectedDeptCode      = raw.deptCode?.toString();
//       _selectedManType       = raw.manType ?? 'Days';
//       _selectedEmpType       = raw.empType ?? 'Days';
//       _currentTabIndex       = 0;
//       _formValues = {
//         'counterTypeCode': raw.counterTypeCode?.toString() ?? '',
//         'divisionCode':    raw.divisionCode?.toString()    ?? '',
//         'deptGroupCode':   raw.deptGroupCode?.toString()   ?? '',
//         'deptCode':        raw.deptCode?.toString()        ?? '',
//         'teamCode':        raw.teamCode?.toString()        ?? '',
//         'userGrp':         raw.userGrp          ?? '',
//         'logInName':       raw.logInName         ?? '',
//         'crPass':          raw.crPass            ?? '',
//         'crName':          raw.crName            ?? '',
//         'sortID':          raw.sortID?.toString() ?? '',
//         'active':          raw.active == true ? 'true' : 'false',
//         'crEdit':          raw.crEdit       ?? 'Y',
//         'crDel':           raw.crDel        ?? 'Y',
//         'autoRec':         raw.autoRec      ?? 'Y',
//         'empIssRec':       raw.empIssRec    ?? 'N',
//         'empRecWt':        raw.empRecWt     ?? 'N',
//         'laserPlanRec':    raw.laserPlanRec ?? 'N',
//         'polishOut':       raw.polishOut    ?? 'N',
//         'stockLimit':      raw.stockLimit?.toString()     ?? '',
//         'target':          raw.target?.toString()         ?? '',
//         'kachaIss':        raw.kachaIss     ?? 'Y',
//         'manType':         raw.manType      ?? 'Days',
//         'manPktDayLimit':  raw.manPktDayLimit?.toString()  ?? '',
//         'manPktHourLimit': raw.manPktHourLimit?.toString() ?? '',
//         'empType':         raw.empType      ?? 'Days',
//         'empPktDayLimit':  raw.empPktDayLimit?.toString()  ?? '',
//         'empPktHourLimit': raw.empPktHourLimit?.toString() ?? '',
//         'empPktLimit':     raw.empPktLimit?.toString()     ?? '',
//       };
//     });
//
//     if (raw.counterMstID != null) _loadDisplaySettings(raw.counterMstID!);
//     _loadMenuRights(raw.crId!);
//     _loadProcessRights(raw.crId!);
//
//     if (Responsive.isMobile(context)) {
//       setState(() => _showTableOnMobile = false);
//     }
//   }
//
//   // ── LOAD HELPERS ──────────────────────────────────────────────────────────
//   Future<void> _loadDisplaySettings(int counterMstID) async {
//     final dp = context.read<CounterDisplayDetProvider>();
//     await dp.loadByCounter(counterMstID);
//     final records = dp.counterList;
//     setState(() {
//       _fromSelected = records
//           .where((r) => r.counterType == 'FROM' && r.userVisibilityCode != null)
//           .map((r) => r.userVisibilityCode!)
//           .toSet();
//       _toSelected = records
//           .where((r) => r.counterType == 'TO' && r.userVisibilityCode != null)
//           .map((r) => r.userVisibilityCode!)
//           .toSet();
//     });
//   }
//
//   Future<void> _loadMenuRights(int crId) async {
//     final dp = context.read<CounterDetProvider>();
//     await dp.loadByCounter(crId);
//     setState(() {
//       _selectedMenuIds = dp.counterList
//           .where((r) => r.menuMstID != null)
//           .map((r) => r.menuMstID!)
//           .toSet();
//     });
//   }
//
//   Future<void> _loadProcessRights(int crId) async {
//     final dp = context.read<CounterProcessProvider>();
//     await dp.loadByCounter(crId);
//     setState(() {
//       _selectedProcessCodes = dp.counterList
//           .where((r) => r.deptProcessCode != null)
//           .map((r) => r.deptProcessCode!)
//           .toSet();
//     });
//   }
//
//   // ── SAVE ──────────────────────────────────────────────────────────────────
//   Future<void> _onSave(Map<String, dynamic> values) async {
//     final counterProvider = context.read<CounterProvider>();
//     final displayProvider = context.read<CounterDisplayDetProvider>();
//     final detProvider     = context.read<CounterDetProvider>();
//     final processProvider = context.read<CounterProcessProvider>();
//
//     // 1. Save Counter master
//     CounterModel? savedCounter;
//     if (_isEditMode && _selectedRow != null) {
//       final raw    = _selectedRow!['_raw'] as CounterModel;
//       savedCounter = await counterProvider.updateAndReturn(raw.crId!, values);
//     } else {
//       savedCounter = await counterProvider.createAndReturn(values);
//     }
//
//     final int? savedMstID = savedCounter?.counterMstID;
//     final int? savedCrId  = savedCounter?.crId;
//     if (savedCounter == null || savedMstID == null || savedCrId == null || !mounted) return;
//
//     // 2. CounterDisplayDet (FROM/TO) — CrId = CounterMstID
//     await displayProvider.deleteByCounter(savedMstID);
//     for (final v in _fromSelected) {
//       await displayProvider.create({
//         'crId': savedMstID.toString(),
//         'userVisibilityCode': v.toString(),
//         'counterType': 'FROM',
//       });
//     }
//     for (final v in _toSelected) {
//       await displayProvider.create({
//         'crId': savedMstID.toString(),
//         'userVisibilityCode': v.toString(),
//         'counterType': 'TO',
//       });
//     }
//
//     // 3. CounterDet (Menu Rights) — delete existing then re-insert
//     final existingDet = List.of(detProvider.counterList);
//     for (final r in existingDet) {
//       if (r.counterDetID != null) await detProvider.delete(r.counterDetID!);
//     }
//     final menuList = context.read<MenuMstProvider>().list;
//     for (final menuId in _selectedMenuIds) {
//       final menu = menuList.where((m) => m.menuMstID == menuId).firstOrNull;
//       await detProvider.create({
//         'crId':          savedCrId.toString(),
//         'mainMenuMstID': (menu?.mainMenuMstID ?? 0).toString(),
//         'menuMstID':     menuId.toString(),
//       });
//     }
//
//     // 4. CounterProcessDet — delete existing then re-insert
//     final existingProc = List.of(processProvider.counterList);
//     for (final r in existingProc) {
//       if (r.counterProcessDetID != null) {
//         await processProvider.delete(r.counterProcessDetID!);
//       }
//     }
//     final processList = context.read<DeptProcessProvider>().list;
//     for (final procCode in _selectedProcessCodes) {
//       final proc = processList.where((p) => p.deptProcessCode == procCode).firstOrNull;
//       await processProvider.create({
//         'crId':            savedCrId.toString(),
//         'deptCode':        (proc?.deptCode ?? 0).toString(),
//         'deptProcessCode': procCode.toString(),
//       });
//     }
//
//     if (!mounted) return;
//     _resetForm();
//     await ErpResultDialog.showSuccess(
//       context: context, theme: _theme,
//       title:   _isEditMode ? 'Updated' : 'Saved',
//       message: _isEditMode ? 'Counter updated successfully.' : 'Counter saved successfully.',
//     );
//   }
//
//   // ── DELETE ────────────────────────────────────────────────────────────────
//   Future<void> _onDelete() async {
//     final raw = _selectedRow?['_raw'] as CounterModel?;
//     if (raw?.crId == null) return;
//     final confirm = await ErpDeleteDialog.show(
//       context: context, theme: _theme,
//       title: 'Counter', itemName: raw!.crName ?? '',
//     );
//     if (confirm != true || !mounted) return;
//     final success = await context.read<CounterProvider>().delete(raw!.crId!);
//     if (success && mounted) {
//       _resetForm();
//       await ErpResultDialog.showDeleted(
//           context: context, theme: _theme, itemName: raw.crName ?? '');
//     }
//   }
//
//   // ── RESET ─────────────────────────────────────────────────────────────────
//   void _resetForm() {
//     setState(() {
//       _selectedRow           = null;
//       _isEditMode            = false;
//       _formValues            = {};
//       _showTableOnMobile     = false;
//       _showSearch            = false;
//       _selectedDeptGroupCode = null;
//       _selectedDeptCode      = null;
//       _selectedManType       = null;
//       _selectedEmpType       = null;
//       _fromSelected          = {};
//       _toSelected            = {};
//       _selectedMenuIds       = {};
//       _selectedProcessCodes  = {};
//       _currentTabIndex       = 0;
//     });
//     _erpFormKey.currentState?.resetForm();
//   }
//
//   // ── BUILD ─────────────────────────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<CounterProvider>(
//       builder: (context, counterProvider, _) {
//         final isMobile = Responsive.isMobile(context);
//         if (isMobile && (_showSearch || _showTableOnMobile)) {
//           return Padding(
//             padding: const EdgeInsets.all(8),
//             child: _buildTable(counterProvider),
//           );
//         }
//         return Padding(
//           padding: const EdgeInsets.all(8),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Expanded(flex: _showSearch ? 2 : 1, child: _buildFormWrapper()),
//               if (_showSearch) ...[
//                 const SizedBox(width: 12),
//                 Expanded(flex: 2, child: _buildTable(counterProvider)),
//               ],
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildTable(CounterProvider p) => ErpDataTable(
//     isReportRow: false,
//     token:       token ?? '',
//     url:         baseUrl,
//     title:       'COUNTER LIST',
//     columns:     _tableColumns,
//     data:        p.tableData,
//     showSearch:  true,
//     selectedRow: _selectedRow,
//     onRowTap:    _onRowTap,
//     emptyMessage: p.isLoaded ? 'No counters found' : 'Loading...',
//   );
//
//   // ── FORM WRAPPER ──────────────────────────────────────────────────────────
//   Widget _buildFormWrapper() {
//     return Consumer5<CounterTypeProvider, DivisionProvider, DeptGroupProvider,
//         DeptProvider, TeamProvider>(
//       builder: (context, ctP, divP, dgP, deptP, teamP, _) {
//
//         final counterTypeItems = ctP.list.map((e) => ErpDropdownItem(
//             label: e.counterTypeName ?? '',
//             value: e.counterTypeCode?.toString() ?? '')).toList();
//
//         final divisionItems = divP.divisions.map((e) => ErpDropdownItem(
//             label: e.divisionName ?? '',
//             value: e.divisionCode?.toString() ?? '')).toList();
//
//         final deptGroupItems = dgP.list.map((e) => ErpDropdownItem(
//             label: e.deptGroupName ?? '',
//             value: e.deptGroupCode?.toString() ?? '')).toList();
//
//         final filteredDepts = _selectedDeptGroupCode != null
//             ? deptP.list.where((e) =>
//         e.deptGroupCode?.toString() == _selectedDeptGroupCode).toList()
//             : deptP.list;
//         final departmentItems = filteredDepts.map((e) => ErpDropdownItem(
//             label: e.deptName ?? '',
//             value: e.deptCode?.toString() ?? '')).toList();
//
//         final teamItems = teamP.list.map((e) => ErpDropdownItem(
//             label: e.teamName ?? '',
//             value: e.teamCode?.toString() ?? '')).toList();
//
//         return Consumer3<UserVisibilityProvider, MainMenuMstProvider,
//             MenuMstProvider>(
//           builder: (context, visP, mainMenuP, menuP, _) {
//             return ErpForm(
//               logo:          AppImages.logo,
//               key:           _erpFormKey,
//               title:         'COUNTER MASTER',
//               subtitle:      'Counter Configuration',
//               // ── 2 tabs: USER and PROCESS ──
//               tabs:                   const ['USER', 'PROCESS'],
//               initialTabIndex:        _currentTabIndex,
//               tabBarBackgroundColor:  const Color(0xFFF1F5F9),
//               tabBarSelectedColor:    _theme.primaryGradient.first,
//               tabBarSelectedTxtColor: Colors.white,
//               onTabChanged: (i) => setState(() => _currentTabIndex = i),
//               rows:          _formRows(
//                 counterTypeItems: counterTypeItems,
//                 divisionItems:    divisionItems,
//                 deptGroupItems:   deptGroupItems,
//                 departmentItems:  departmentItems,
//                 teamItems:        teamItems,
//               ),
//               initialValues: _formValues,
//               isEditMode:    _isEditMode,
//               onSearch:      () => setState(() => _showSearch = !_showSearch),
//               onFieldChanged: (key, value) {
//                 _formValues[key] = value;
//                 if (key == 'deptGroupCode') {
//                   setState(() {
//                     _selectedDeptGroupCode = value.isEmpty ? null : value;
//                     _formValues['deptCode'] = '';
//                     _erpFormKey.currentState?.updateFieldValue('deptCode', null);
//                   });
//                 }
//                 if (key == 'deptCode') {
//                   setState(() => _selectedDeptCode = value.isEmpty ? null : value);
//                 }
//                 if (key == 'manType') setState(() => _selectedManType = value);
//                 if (key == 'empType') setState(() => _selectedEmpType = value);
//               },
//               onSave:   _onSave,
//               onCancel: _resetForm,
//               onDelete: _isEditMode ? _onDelete : null,
//               // ── detailBuilder — tab content inject karo ──
//               detailBuilder: (ctx) => _buildTabContent(visP, mainMenuP, menuP),
//             );
//           },
//         );
//       },
//     );
//   }
//
//   // ── TAB CONTENT SWITCHER ──────────────────────────────────────────────────
//   // detailBuilder always renders, but we show content based on _currentTabIndex
//   Widget _buildTabContent(
//       UserVisibilityProvider visP,
//       MainMenuMstProvider mainMenuP,
//       MenuMstProvider menuP,
//       ) {
//     final theme = context.erpTheme;
//     switch (_currentTabIndex) {
//       case 0:
//         return _buildUserTab(visP, mainMenuP, menuP, theme);
//       case 1:
//         return _buildProcessTab(theme);
//       default:
//         return const SizedBox.shrink();
//     }
//   }
//
//   // ── TAB 0: USER ───────────────────────────────────────────────────────────
//   Widget _buildUserTab(
//       UserVisibilityProvider visP,
//       MainMenuMstProvider mainMenuP,
//       MenuMstProvider menuP,
//       ErpTheme theme,
//       ) {
//     // DEPT type items for display setting
//     final deptItems = visP.list
//         .where((e) => e.entryType?.toUpperCase() == 'DEPT')
//         .toList();
//     final displayItems = deptItems.isNotEmpty ? deptItems : visP.list;
//
//     return Padding(
//       padding: const EdgeInsets.only(top: 4),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           // ── Display Setting ──────────────────────────────────────────────
//           if (displayItems.isNotEmpty) ...[
//             _sectionHeader(theme, 'DISPLAY SETTING'),
//             const SizedBox(height: 6),
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Expanded(
//                   child: _DisplayCheckboxPanel(
//                     theme:    theme,
//                     title:    'From Display Setting',
//                     items:    visP.list,
//                     selected: _fromSelected,
//                     onChanged: (code, val) => setState(() {
//                       if (val) _fromSelected.add(code);
//                       else     _fromSelected.remove(code);
//                     }),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: _DisplayCheckboxPanel(
//                     theme:    theme,
//                     title:    'To Display Setting',
//                     items:    displayItems,
//                     selected: _toSelected,
//                     onChanged: (code, val) => setState(() {
//                       if (val) _toSelected.add(code);
//                       else     _toSelected.remove(code);
//                     }),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 10),
//           ],
//
//           // ── Menu Rights Tree ────────────────────────────────────────────
//           _sectionHeader(theme, 'MENU RIGHTS'),
//           const SizedBox(height: 6),
//           _buildMenuRightsTree(mainMenuP, menuP, theme),
//         ],
//       ),
//     );
//   }
//
//   // ── MENU RIGHTS TREE ──────────────────────────────────────────────────────
//   Widget _buildMenuRightsTree(
//       MainMenuMstProvider mainMenuP,
//       MenuMstProvider menuP,
//       ErpTheme theme,
//       ) {
//     final t           = theme;
//     final allMainMenus = mainMenuP.list;
//     final allMenus     = menuP.list;
//
//     if (allMainMenus.isEmpty) {
//       return Padding(
//         padding: const EdgeInsets.all(16),
//         child: Text('Loading menu rights...',
//             style: TextStyle(color: t.textLight, fontSize: 12)),
//       );
//     }
//
//     return Container(
//       decoration: BoxDecoration(
//         color:        t.surface,
//         borderRadius: BorderRadius.circular(10),
//         border:       Border.all(color: t.border),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: allMainMenus.map((mainMenu) {
//           final mainMenuId  = mainMenu.mainMenuMstID ?? 0;
//           final children    = allMenus
//               .where((m) => m.mainMenuMstID == mainMenuId)
//               .toList();
//           final childIds    = children.map((m) => m.menuMstID ?? 0).toSet();
//           final allChecked  = childIds.isNotEmpty &&
//               childIds.every((id) => _selectedMenuIds.contains(id));
//           final someChecked = childIds.any((id) => _selectedMenuIds.contains(id));
//           final isCollapsed = _collapsedMainMenus.contains(mainMenuId);
//
//           return Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // ── Main menu header ────────────────────────────────────────
//               GestureDetector(
//                 onTap: () => setState(() {
//                   if (isCollapsed) _collapsedMainMenus.remove(mainMenuId);
//                   else             _collapsedMainMenus.add(mainMenuId);
//                 }),
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                   decoration: BoxDecoration(
//                     color:  t.bg,
//                     border: Border(top: BorderSide(color: t.border)),
//                   ),
//                   child: Row(
//                     children: [
//                       SizedBox(
//                         width: 20, height: 22,
//                         child: Checkbox(
//                           value:     allChecked ? true
//                               : someChecked ? null : false,
//                           tristate:  true,
//                           activeColor: t.primary,
//                           onChanged: (v) {
//                             setState(() {
//                               if (v == true || someChecked) {
//                                 _selectedMenuIds.addAll(childIds);
//                               } else {
//                                 _selectedMenuIds.removeAll(childIds);
//                               }
//                             });
//                           },
//                           visualDensity: const VisualDensity(
//                               vertical: -4, horizontal: -4),
//                           materialTapTargetSize:
//                           MaterialTapTargetSize.shrinkWrap,
//                         ),
//                       ),
//                       const SizedBox(width: 4),
//                       AnimatedRotation(
//                         turns: isCollapsed ? -0.25 : 0,
//                         duration: const Duration(milliseconds: 180),
//                         child: Icon(Icons.keyboard_arrow_down_rounded,
//                             size: 16, color: t.primary),
//                       ),
//                       const SizedBox(width: 4),
//                       Icon(Icons.folder_outlined, size: 13, color: t.primary),
//                       const SizedBox(width: 6),
//                       Expanded(
//                         child: Text(
//                           'Menu: ${mainMenu.mainMenuName ?? ''}',
//                           style: TextStyle(
//                             fontSize:   11,
//                             fontWeight: FontWeight.w700,
//                             color:      t.primary,
//                           ),
//                         ),
//                       ),
//                       Text(
//                         '${childIds.intersection(_selectedMenuIds).length}/${childIds.length}',
//                         style: TextStyle(fontSize: 9, color: t.textLight),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//
//               // ── Child menu items ────────────────────────────────────────
//               if (!isCollapsed)
//                 ...children.map((menu) {
//                   final menuId    = menu.menuMstID ?? 0;
//                   final isChecked = _selectedMenuIds.contains(menuId);
//                   return InkWell(
//                     onTap: () => setState(() {
//                       if (isChecked) _selectedMenuIds.remove(menuId);
//                       else           _selectedMenuIds.add(menuId);
//                     }),
//                     child: Container(
//                       padding: const EdgeInsets.only(
//                           left: 44, right: 10, top: 3, bottom: 3),
//                       decoration: BoxDecoration(
//                         color:  isChecked
//                             ? t.primary.withOpacity(0.06)
//                             : Colors.white,
//                         border: Border(
//                             top: BorderSide(
//                                 color: t.border.withOpacity(0.5))),
//                       ),
//                       child: Row(
//                         children: [
//                           SizedBox(
//                             width: 18, height: 22,
//                             child: Checkbox(
//                               value:       isChecked,
//                               activeColor: t.primary,
//                               onChanged:   (v) => setState(() {
//                                 if (v == true) _selectedMenuIds.add(menuId);
//                                 else           _selectedMenuIds.remove(menuId);
//                               }),
//                               visualDensity: const VisualDensity(
//                                   vertical: -4, horizontal: -4),
//                               materialTapTargetSize:
//                               MaterialTapTargetSize.shrinkWrap,
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           Icon(Icons.check_box_outline_blank_rounded,
//                               size: 11, color: t.textLight),
//                           const SizedBox(width: 6),
//                           Expanded(
//                             child: Text(
//                               menu.menuName ?? '',
//                               style: TextStyle(
//                                 fontSize:   11,
//                                 color:      isChecked ? t.primary : t.text,
//                                 fontWeight: isChecked
//                                     ? FontWeight.w600
//                                     : FontWeight.normal,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 }),
//             ],
//           );
//         }).toList(),
//       ),
//     );
//   }
//
//   // ── TAB 1: PROCESS ────────────────────────────────────────────────────────
//   Widget _buildProcessTab(ErpTheme theme) {
//     return Consumer<DeptProcessProvider>(
//       builder: (context, procP, _) {
//         // Filter by selected deptCode from USER tab
//         final filtered = _selectedDeptCode != null
//             ? procP.list
//             .where((p) => p.deptCode?.toString() == _selectedDeptCode)
//             .toList()
//             : procP.list;
//
//         if (filtered.isEmpty) {
//           return Padding(
//             padding: const EdgeInsets.all(24),
//             child: Text(
//               _selectedDeptCode == null
//                   ? 'Please select a Department in USER tab first.'
//                   : 'No processes found for selected department.',
//               style: TextStyle(fontSize: 12, color: theme.textLight),
//               textAlign: TextAlign.center,
//             ),
//           );
//         }
//
//         return Padding(
//           padding: const EdgeInsets.only(top: 4),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               _sectionHeader(theme, 'DEPT PROCESSES'),
//               const SizedBox(height: 6),
//               Container(
//                 decoration: BoxDecoration(
//                   color:        theme.surface,
//                   borderRadius: BorderRadius.circular(10),
//                   border:       Border.all(color: theme.border),
//                 ),
//                 child: Column(
//                   children: filtered.asMap().entries.map((entry) {
//                     final i         = entry.key;
//                     final proc      = entry.value;
//                     final code      = proc.deptProcessCode ?? 0;
//                     final isChecked = _selectedProcessCodes.contains(code);
//                     final isEven    = i % 2 == 0;
//
//                     return InkWell(
//                       onTap: () => setState(() {
//                         if (isChecked) _selectedProcessCodes.remove(code);
//                         else           _selectedProcessCodes.add(code);
//                       }),
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 10, vertical: 4),
//                         decoration: BoxDecoration(
//                           color: isChecked
//                               ? theme.primary.withOpacity(0.07)
//                               : isEven
//                               ? Colors.white
//                               : theme.bg.withOpacity(0.5),
//                           border: Border(
//                             top: i == 0
//                                 ? BorderSide.none
//                                 : BorderSide(
//                                 color: theme.border.withOpacity(0.5)),
//                           ),
//                         ),
//                         child: Row(
//                           children: [
//                             SizedBox(
//                               width: 20, height: 28,
//                               child: Checkbox(
//                                 value:       isChecked,
//                                 activeColor: theme.primary,
//                                 onChanged:   (v) => setState(() {
//                                   if (v == true) _selectedProcessCodes.add(code);
//                                   else _selectedProcessCodes.remove(code);
//                                 }),
//                                 visualDensity: const VisualDensity(
//                                     vertical: -4, horizontal: -4),
//                                 materialTapTargetSize:
//                                 MaterialTapTargetSize.shrinkWrap,
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             Expanded(
//                               child: Text(
//                                 proc.deptProcessName ?? '',
//                                 style: TextStyle(
//                                   fontSize:   11,
//                                   color:      isChecked
//                                       ? theme.primary
//                                       : theme.text,
//                                   fontWeight: isChecked
//                                       ? FontWeight.w600
//                                       : FontWeight.normal,
//                                 ),
//                               ),
//                             ),
//                             Text(
//                               code.toString(),
//                               style: TextStyle(
//                                   fontSize: 9, color: theme.textLight),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   }).toList(),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   // ── SECTION HEADER ────────────────────────────────────────────────────────
//   Widget _sectionHeader(ErpTheme theme, String title) {
//     return Container(
//       alignment: Alignment.center,
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: theme.primaryGradient
//               .map((c) => c.withOpacity(0.13))
//               .toList(),
//         ),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: theme.primary.withOpacity(0.3)),
//       ),
//       child: Text(
//         title,
//         style: TextStyle(
//           fontSize:   11,
//           fontWeight: FontWeight.w700,
//           color:      theme.primary,
//           letterSpacing: 0.8,
//         ),
//       ),
//     );
//   }
//
//   // ── FORM ROWS ─────────────────────────────────────────────────────────────
//   // tabIndex nahi diya — ErpForm ke tabs se content switch hoga
//   // detailBuilder se tab content inject hoga
//   List<List<ErpFieldConfig>> _formRows({
//     required List<ErpDropdownItem> counterTypeItems,
//     required List<ErpDropdownItem> divisionItems,
//     required List<ErpDropdownItem> deptGroupItems,
//     required List<ErpDropdownItem> departmentItems,
//     required List<ErpDropdownItem> teamItems,
//   }) =>
//       [
//         // ── BASIC INFORMATION ─────────────────────────────────────────────
//         [
//           ErpFieldConfig(key: 'counterTypeCode', label: 'TYPE',       type: ErpFieldType.dropdown, dropdownItems: counterTypeItems, sectionTitle: 'BASIC INFORMATION', sectionIndex: 0),
//           ErpFieldConfig(key: 'divisionCode',    label: 'DIVISION',   type: ErpFieldType.dropdown, dropdownItems: divisionItems,    sectionIndex: 0),
//           ErpFieldConfig(key: 'deptGroupCode',   label: 'GROUP',      type: ErpFieldType.dropdown, dropdownItems: deptGroupItems,   sectionIndex: 0),
//           ErpFieldConfig(key: 'deptCode',        label: 'DEPARTMENT', type: ErpFieldType.dropdown, dropdownItems: departmentItems,  sectionIndex: 0),
//         ],
//         [
//           ErpFieldConfig(key: 'teamCode', label: 'TEAM',   type: ErpFieldType.dropdown, dropdownItems: teamItems, sectionIndex: 0),
//           ErpFieldConfig(key: 'userGrp',  label: 'RIGHTS', type: ErpFieldType.dropdown,
//               dropdownItems: const [
//                 ErpDropdownItem(label: 'Admin', value: 'Admin'),
//                 ErpDropdownItem(label: 'User',  value: 'User'),
//               ], sectionIndex: 0),
//           ErpFieldConfig(key: 'logInName', label: 'LOGIN NAME', required: true, sectionIndex: 0),
//           ErpFieldConfig(key: 'crPass',    label: 'PASSWORD',                   sectionIndex: 0),
//         ],
//         [
//           ErpFieldConfig(key: 'crName', label: 'NAME',    required: true,              sectionIndex: 0),
//           ErpFieldConfig(key: 'sortID', label: 'SORT ID', type: ErpFieldType.number,   sectionIndex: 0),
//           ErpFieldConfig(key: 'active', label: 'ACTIVE',  type: ErpFieldType.checkbox, checkboxDbType: 'BIT', sectionIndex: 0),
//         ],
//
//         // ── PERMISSIONS ───────────────────────────────────────────────────
//         [
//           ErpFieldConfig(key: 'crEdit',       label: 'EDIT',           type: ErpFieldType.dropdown, dropdownItems: _ynItems, sectionTitle: 'PERMISSIONS', sectionIndex: 1),
//           ErpFieldConfig(key: 'crDel',        label: 'DELETE',         type: ErpFieldType.dropdown, dropdownItems: _ynItems, sectionIndex: 1),
//           ErpFieldConfig(key: 'autoRec',      label: 'CONFIRM REC',    type: ErpFieldType.dropdown, dropdownItems: _ynItems, sectionIndex: 1),
//           ErpFieldConfig(key: 'empIssRec',    label: 'EMP ISS REC',    type: ErpFieldType.dropdown, dropdownItems: _ynItems, sectionIndex: 1),
//           ErpFieldConfig(key: 'empRecWt',     label: 'EMP REC WT',     type: ErpFieldType.dropdown, dropdownItems: _ynItems, sectionIndex: 1),
//           ErpFieldConfig(key: 'laserPlanRec', label: 'LASER PLAN REC', type: ErpFieldType.dropdown, dropdownItems: _ynItems, sectionIndex: 1),
//         ],
//         [
//           ErpFieldConfig(key: 'polishOut',  label: 'POLISH OUT',  type: ErpFieldType.dropdown, dropdownItems: _ynItems, sectionIndex: 1),
//           ErpFieldConfig(key: 'stockLimit', label: 'STOCK LIMIT', type: ErpFieldType.number,                            sectionIndex: 1),
//           ErpFieldConfig(key: 'target',     label: 'TARGET',      type: ErpFieldType.number,                            sectionIndex: 1),
//           ErpFieldConfig(key: 'kachaIss',   label: 'KACHA ISS',   type: ErpFieldType.dropdown, dropdownItems: _ynItems, sectionIndex: 1),
//         ],
//
//         // ── LIMITS ────────────────────────────────────────────────────────
//         [
//           ErpFieldConfig(key: 'manType',         label: 'MAN TYPE',           type: ErpFieldType.dropdown, dropdownItems: const [ErpDropdownItem(label: 'Days', value: 'Days'), ErpDropdownItem(label: 'Hours', value: 'Hours')], sectionTitle: 'LIMITS', sectionIndex: 2),
//           ErpFieldConfig(key: 'manPktDayLimit',  label: 'MAN PKT DAY LIMIT',  type: ErpFieldType.number, readOnly: _selectedManType == 'Hours', sectionIndex: 2),
//           ErpFieldConfig(key: 'manPktHourLimit', label: 'MAN PKT HOUR LIMIT', type: ErpFieldType.number, readOnly: _selectedManType == 'Days',  sectionIndex: 2),
//         ],
//         [
//           ErpFieldConfig(key: 'empType',         label: 'EMP TYPE',           type: ErpFieldType.dropdown, dropdownItems: const [ErpDropdownItem(label: 'Days', value: 'Days'), ErpDropdownItem(label: 'Hours', value: 'Hours')], sectionIndex: 2),
//           ErpFieldConfig(key: 'empPktDayLimit',  label: 'EMP PKT DAY LIMIT',  type: ErpFieldType.number, readOnly: _selectedEmpType == 'Hours', sectionIndex: 2),
//           ErpFieldConfig(key: 'empPktHourLimit', label: 'EMP PKT HOUR LIMIT', type: ErpFieldType.number, readOnly: _selectedEmpType == 'Days',  sectionIndex: 2),
//         ],
//         [
//           ErpFieldConfig(key: 'empPktLimit', label: 'EMP PKT LIMIT', type: ErpFieldType.number, sectionIndex: 2),
//         ],
//       ];
// }
//
// // ─── Display Checkbox Panel ───────────────────────────────────────────────────
// class _DisplayCheckboxPanel extends StatelessWidget {
//   final ErpTheme theme;
//   final String title;
//   final List<UserVisibilityModel> items;
//   final Set<int> selected;
//   final void Function(int code, bool val) onChanged;
//
//   const _DisplayCheckboxPanel({
//     required this.theme,
//     required this.title,
//     required this.items,
//     required this.selected,
//     required this.onChanged,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final t = theme;
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         // Header
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: t.primaryGradient
//                   .map((c) => c.withOpacity(0.15))
//                   .toList(),
//             ),
//             borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
//             border: Border.all(color: t.primary.withOpacity(0.3)),
//           ),
//           child: Row(
//             children: [
//               Icon(
//                 title.toLowerCase().contains('from')
//                     ? Icons.arrow_forward_rounded
//                     : Icons.arrow_back_rounded,
//                 size: 13, color: t.primary,
//               ),
//               const SizedBox(width: 6),
//               Expanded(
//                 child: Text(title,
//                     style: TextStyle(
//                         fontSize:   10,
//                         fontWeight: FontWeight.w700,
//                         color:      t.primary,
//                         letterSpacing: 0.4)),
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                 decoration: BoxDecoration(
//                     color: t.primary, borderRadius: BorderRadius.circular(8)),
//                 child: Text('${selected.length}',
//                     style: const TextStyle(
//                         fontSize: 9,
//                         color: Colors.white,
//                         fontWeight: FontWeight.w700)),
//               ),
//             ],
//           ),
//         ),
//         // List
//         Container(
//           constraints: const BoxConstraints(maxHeight: 220),
//           decoration: BoxDecoration(
//             color:        t.surface,
//             border:       Border.all(color: t.border),
//             borderRadius:
//             const BorderRadius.vertical(bottom: Radius.circular(8)),
//           ),
//           child: ListView.builder(
//             shrinkWrap: true,
//             itemCount:  items.length,
//             itemBuilder: (ctx, i) {
//               final item      = items[i];
//               final code      = item.userVisibilityCode ?? 0;
//               final isChecked = selected.contains(code);
//               final isEven    = i % 2 == 0;
//               return InkWell(
//                 onTap: () => onChanged(code, !isChecked),
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 6, vertical: 1),
//                   color: isChecked
//                       ? t.primary.withOpacity(0.08)
//                       : isEven
//                       ? Colors.white
//                       : t.bg.withOpacity(0.5),
//                   child: Row(
//                     children: [
//                       SizedBox(
//                         width: 20, height: 24,
//                         child: Checkbox(
//                           value:       isChecked,
//                           activeColor: t.primary,
//                           onChanged:   (v) => onChanged(code, v ?? false),
//                           visualDensity: const VisualDensity(
//                               vertical: -4, horizontal: -4),
//                           materialTapTargetSize:
//                           MaterialTapTargetSize.shrinkWrap,
//                         ),
//                       ),
//                       const SizedBox(width: 6),
//                       Expanded(
//                         child: Text(item.userVisibilityName ?? '',
//                             style: TextStyle(
//                               fontSize:   10,
//                               color:      isChecked ? t.primary : t.text,
//                               fontWeight: isChecked
//                                   ? FontWeight.w600
//                                   : FontWeight.normal,
//                             )),
//                       ),
//                       if (item.entryType != null)
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 4, vertical: 1),
//                           decoration: BoxDecoration(
//                             color: t.primary.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                           child: Text(item.entryType!,
//                               style: TextStyle(
//                                   fontSize:   7,
//                                   color:      t.primary,
//                                   fontWeight: FontWeight.w700)),
//                         ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }