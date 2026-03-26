// // lib/screens/mst_counter.dart
//
// import 'package:erp_data_table/erp_data_table.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:rs_dashboard/rs_dashboard.dart';
//
// import '../bootstrap.dart';
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
// import '../providers/counter_operator_det_provider.dart';
// import '../providers/counter_manager_det_provider.dart';
// import '../providers/counter_dept_det_provider.dart';
// import '../providers/counter_shape_det_provider.dart';
// import '../providers/shape_provider.dart';
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
//   Key _formKey = UniqueKey(); // Tab lock force-reset ke liye
//   Map<String, dynamic>? _selectedRow;
//   bool _isEditMode        = false;
//   bool _showSearch        = false;
//   bool _showTableOnMobile = false;
//   Map<String, String> _formValues = {};
//
//   // After Tab 0 save → crId/mstID set → Tab 1/2 unlock
//   int? _savedCrId;
//   int? _savedMstID;
//
//   int _currentTabIndex = 0;
//
//   // Dependent dropdowns
//   String? _selectedDeptGroupCode;
//   String? _selectedDeptCode;
//   String? _selectedManType;
//   String? _selectedEmpType;
//
//   // Tab 0: Display Setting
//   Set<int> _fromSelected = {};
//   Set<int> _toSelected   = {};
//
//   // Tab 1: Process
//   Set<int> _selectedProcessCodes = {};
//
//   // Tab 3: Allow Operator — selected AllowCrId list
//   Set<int> _selectedOperatorIds = {};
//
//   // Tab 4: Allow Manager — selected AllowCrId list
//   Set<int> _selectedManagerIds  = {};
//
//   // Tab 5: Allow Department — selected DeptCode list
//   Set<int> _selectedDeptIds = {};
//
//   // Tab 2: Menu Rights
//   Set<int> _selectedMenuIds    = {};
//   Set<int> _selectedShapeIds    = {};
//   Set<int> _collapsedMainMenus = {};
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
//
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
//
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
//         _savedMstID = savedCounter!.counterMstID;
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
//           _isEditMode = true;   // saved ho gaya — edit mode mein aa jao
//           _formKey = UniqueKey();
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
//
//     // Tab 3 save — Allow Operator
//     else if (_currentTabIndex == 3 && _savedCrId != null) {
//       final opProvider = context.read<CounterOperatorDetProvider>();
//       await opProvider.deleteByCrId(_savedCrId!);
//       for (final allowId in _selectedOperatorIds) {
//         await opProvider.create({
//           'crId':      _savedCrId.toString(),
//           'allowCrId': allowId.toString(),
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
//     else if (_currentTabIndex == 4 && _savedCrId != null) {
//       final mgProvider = context.read<CounterManagerDetProvider>();
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
//
//     // Tab 5 save — Allow Department
//     else if (_currentTabIndex == 5 && _savedCrId != null) {
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
//
//     // Tab 6 save — Shape Lock
//     else if (_currentTabIndex == 6 && _savedCrId != null) {
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
//     final crId   = raw!.crId!;
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
//       _toSelected            = {};
//       _selectedMenuIds       = {};
//       _selectedProcessCodes  = {};
//       _selectedOperatorIds   = {};
//       _selectedManagerIds    = {};
//       _selectedDeptIds       = {};
//       _selectedShapeIds      = {};
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
//         return Consumer2<CounterDeptDetProvider, CounterShapeDetProvider>(
//             builder: (context, deptDetP, shapeDetP, _) =>
//                 Consumer5<UserVisibilityProvider, MainMenuMstProvider, MenuMstProvider, CounterOperatorDetProvider, CounterManagerDetProvider>(
//                   builder: (context, visP, mainMenuP, menuP, opP, mgP, _) {
//                     final tabsEnabled = _savedCrId != null;
//                     return ErpForm(
//                       logo:          AppImages.logo,
//                       key:           _formKey,
//                       title:         'COUNTER MASTER',
//                       subtitle:      'Counter Configuration',
//                       // ── 3 tabs ──
//                       tabs: const ['BASIC', 'PROCESS', 'SELECT RIGHTS', 'ALLOW OPERATOR', 'ALLOW MANAGER', 'ALLOW DEPARTMENT', 'SHAPE LOCK'],
//                       initialTabIndex:        _currentTabIndex,
//                       tabBarBackgroundColor:  const Color(0xFFF1F5F9),
//                       tabBarSelectedColor:    _theme.primaryGradient.first,
//                       tabBarSelectedTxtColor: Colors.white,
//                       onTabChanged: (i) {
//                         if (i > 0 && !tabsEnabled) {
//                           // Tab 0 save nahi hua — ErpForm ko wapas Tab 0 pe force karo
//                           // key change se ErpForm reinit hoga initialTabIndex: 0 ke saath
//                           setState(() {
//                             _currentTabIndex = 0;
//                             _formKey = UniqueKey();
//                           });
//                           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                             content: const Text('Please save BASIC tab first.'),
//                             backgroundColor: Colors.orange.shade700,
//                             duration: const Duration(seconds: 2),
//                             behavior: SnackBarBehavior.floating,
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                             margin: const EdgeInsets.all(12),
//                           ));
//                           return;
//                         }
//                         setState(() => _currentTabIndex = i);
//                       },
//                       rows: _buildFormRows(
//                         counterTypeItems: counterTypeItems,
//                         divisionItems:    divisionItems,
//                         deptGroupItems:   deptGroupItems,
//                         departmentItems:  departmentItems,
//                         teamItems:        teamItems,
//                         mfgDeptItems:     mfgDeptItems,
//                       ),
//                       initialValues: _formValues,
//                       isEditMode:    _isEditMode,
//                       onSearch:      () => setState(() => _showSearch = !_showSearch),
//                       onFieldChanged: (key, value) {
//                         _formValues[key] = value;
//                         if (key == 'deptGroupCode') {
//                           setState(() {
//                             _selectedDeptGroupCode = value.isEmpty ? null : value;
//                             _formValues['deptCode']    = '';
//                             _formValues['mfgDeptCode'] = '';
//                             _erpFormKey.currentState?.updateFieldValue('deptCode',    null);
//                             _erpFormKey.currentState?.updateFieldValue('mfgDeptCode', null);
//                           });
//                         }
//                         if (key == 'deptCode')  setState(() => _selectedDeptCode  = value.isEmpty ? null : value);
//                         if (key == 'manType')   setState(() => _selectedManType   = value);
//                         if (key == 'empType')   setState(() => _selectedEmpType   = value);
//                       },
//                       onSave:   _onSave,
//                       onCancel: _resetForm,
//                       onDelete: _isEditMode ? _onDelete : null,
//                       // ── detailBuilder — tab-aware content ──
//                       detailBuilder: (ctx) => _buildTabDetail(visP, mainMenuP, menuP, opP, mgP, deptDetP, shapeDetP, tabsEnabled),
//                     );
//                   },
//                 ));
//         },
//     );
//   }
//
//   // ── FORM ROWS — tabIndex divides fields into tabs ─────────────────────────
//   // tabIndex 0 = BASIC tab, other tabs show no ErpForm fields (only detailBuilder)
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
//   // ── DETAIL BUILDER — tab-aware ────────────────────────────────────────────
//   Widget _buildTabDetail(
//       UserVisibilityProvider visP,
//       MainMenuMstProvider mainMenuP,
//       MenuMstProvider menuP,
//       CounterOperatorDetProvider opP,
//       CounterManagerDetProvider mgP,
//       CounterDeptDetProvider deptDetP,
//       CounterShapeDetProvider shapeDetP,
//       bool tabsEnabled,
//       ) {
//     final theme = context.erpTheme;
//
//     switch (_currentTabIndex) {
//     // Tab 0: Display Setting (below form fields)
//       case 0:
//         return _buildDisplaySetting(visP, theme);
//
//     // Tab 1: Process
//       case 1:
//         if (!tabsEnabled) return _lockedMsg(theme);
//         return _buildProcessTab(theme);
//
//     // Tab 2: Select Rights
//       case 2:
//         if (!tabsEnabled) return _lockedMsg(theme);
//         return _buildMenuRightsTree(mainMenuP, menuP, theme);
//
//     // Tab 3: Allow Operator
//       case 3:
//         return _buildAllowOperatorTab(opP, theme);
//
//     // Tab 4: Allow Manager
//       case 4:
//         return _buildAllowManagerTab(mgP, theme);
//
//     // Tab 5: Allow Department
//       case 5:
//         if (!tabsEnabled) return _lockedMsg(theme);
//         return _buildAllowDeptTab(theme);
//
//     // Tab 6: Shape Lock
//       case 6:
//         if (!tabsEnabled) return _lockedMsg(theme);
//         return _buildShapeLockTab(theme);
//
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
//   // ── DISPLAY SETTING ───────────────────────────────────────────────────────
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
//                 if (val) _fromSelected.add(code); else _fromSelected.remove(code);
//               }),
//             )),
//             const SizedBox(width: 8),
//             Expanded(child: _DisplayCheckboxPanel(
//               theme: theme, title: 'To Display Setting',
//               items: toItems, selected: _toSelected,
//               onChanged: (code, val) => setState(() {
//                 if (val) _toSelected.add(code); else _toSelected.remove(code);
//               }),
//             )),
//           ],
//         ),
//       ]),
//     );
//   }
//
//   // ── PROCESS TAB ───────────────────────────────────────────────────────────
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
//                     if (isChecked) _selectedProcessCodes.remove(code);
//                     else           _selectedProcessCodes.add(code);
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
//                           if (v == true) _selectedProcessCodes.add(code);
//                           else _selectedProcessCodes.remove(code);
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
//
//   // ── MENU RIGHTS TREE ──────────────────────────────────────────────────────
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
//                       if (isCollapsed) _collapsedMainMenus.remove(mainMenuId);
//                       else _collapsedMainMenus.add(mainMenuId);
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
//                             if (v == true || someChecked) _selectedMenuIds.addAll(childIds);
//                             else _selectedMenuIds.removeAll(childIds);
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
//                           if (isChecked) _selectedMenuIds.remove(menuId);
//                           else _selectedMenuIds.add(menuId);
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
//                                 if (v == true) _selectedMenuIds.add(menuId);
//                                 else _selectedMenuIds.remove(menuId);
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
//   // ── ALLOW OPERATOR TAB (Tab 3) ───────────────────────────────────────────
//   // Sare counters show honge — checkbox list
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
//               if (val) _selectedOperatorIds.add(id); else _selectedOperatorIds.remove(id);
//             }),
//           ),
//         ]),
//       );
//     });
//   }
//
//   // ── ALLOW MANAGER TAB (Tab 4) ─────────────────────────────────────────────
//   // Sirf counterTypeCode 2 & 3 wale show honge
//   Widget _buildAllowManagerTab(CounterManagerDetProvider mgP, ErpTheme theme) {
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
//               if (val) _selectedManagerIds.add(id); else _selectedManagerIds.remove(id);
//             }),
//           ),
//         ]),
//       );
//     });
//   }
//
//   // ── Reusable checkbox list for Allow Operator / Allow Manager ─────────────
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
//   // ── SHAPE LOCK TAB (Tab 6) ──────────────────────────────────────────────────
//   // Sare shapes sortID wise show honge
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
//                     if (isChecked) _selectedShapeIds.remove(code);
//                     else           _selectedShapeIds.add(code);
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
//                           if (v == true) _selectedShapeIds.add(code);
//                           else _selectedShapeIds.remove(code);
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
//   // ── ALLOW DEPARTMENT TAB (Tab 5) ─────────────────────────────────────────
//   // Sare departments sortID wise show honge
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
//               if (isChecked) _selectedDeptIds.remove(code);
//               else           _selectedDeptIds.add(code);
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
//                     if (v == true) _selectedDeptIds.add(code);
//                     else _selectedDeptIds.remove(code);
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