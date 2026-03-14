// import 'package:erp_data_table/erp_data_table.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:rs_dashboard/rs_dashboard.dart';
//
// import '../models/counter_model.dart';
// import '../models/user_visibility_model.dart';
// import '../providers/counter_provider.dart';
// import '../providers/counter_display_det_provider.dart';
// import '../providers/dept_provider.dart';
// import '../providers/user_visibility_provider.dart';
// import '../providers/counter_type_provider.dart';
// import '../providers/division_provider.dart';
// import '../providers/dept_group_provider.dart';
// import '../providers/team_provider.dart';
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
//   String? _selectedManType;
//   String? _selectedEmpType;
//
//   // Display setting checkboxes
//   Set<int> _fromSelected = {};
//   Set<int> _toSelected   = {};
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
//       _selectedManType       = raw.manType ?? 'Days';
//       _selectedEmpType       = raw.empType ?? 'Days';
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
//         'crEdit':          raw.crEdit    ?? 'Y',
//         'crDel':           raw.crDel     ?? 'Y',
//         'autoRec':         raw.autoRec   ?? 'Y',
//         'empIssRec':       raw.empIssRec ?? 'N',
//         'empRecWt':        raw.empRecWt  ?? 'N',
//         'laserPlanRec':    raw.laserPlanRec ?? 'N',
//         'polishOut':       raw.polishOut ?? 'N',
//         'stockLimit':      raw.stockLimit?.toString() ?? '',
//         'target':          raw.target?.toString()     ?? '',
//         'kachaIss':        raw.kachaIss  ?? 'Y',
//         'manType':         raw.manType   ?? 'Days',
//         'manPktDayLimit':  raw.manPktDayLimit?.toString()  ?? '',
//         'manPktHourLimit': raw.manPktHourLimit?.toString() ?? '',
//         'empType':         raw.empType   ?? 'Days',
//         'empPktDayLimit':  raw.empPktDayLimit?.toString()  ?? '',
//         'empPktHourLimit': raw.empPktHourLimit?.toString() ?? '',
//         'empPktLimit':     raw.empPktLimit?.toString()     ?? '',
//       };
//     });
//     // CounterDisplayDet.CrId = CounterMstID (API response se aata hai)
//     if (raw.counterMstID != null) {
//       _loadDisplaySettings(raw.counterMstID!);
//     }
//     if (Responsive.isMobile(context)) {
//       setState(() => _showTableOnMobile = false);
//     }
//   }
//
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
//   Future<void> _onSave(Map<String, dynamic> values) async {
//     final counterProvider = context.read<CounterProvider>();
//     final displayProvider = context.read<CounterDisplayDetProvider>();
//
//     // API response se saved CounterModel lo — CounterMstID usme hoga
//     CounterModel? savedCounter;
//
//     if (_isEditMode && _selectedRow != null) {
//       final raw    = _selectedRow!['_raw'] as CounterModel;
//       savedCounter = await counterProvider.updateAndReturn(raw.crId!, values);
//     } else {
//       savedCounter = await counterProvider.createAndReturn(values);
//     }
//
//     // CounterMstID API response se lo — yahi CrId ke roop mein CounterDisplayDet mein save hoga
//     final int? savedMstID = savedCounter?.counterMstID;
//     if (savedCounter == null || savedMstID == null || !mounted) return;
//
//     // Purane display records delete karo phir fresh insert
//     await displayProvider.deleteByCounter(savedMstID);
//     for (final v in _fromSelected) {
//       await displayProvider.create({
//         'crId':               savedMstID.toString(),  // CounterMstID
//         'userVisibilityCode': v.toString(),
//         'counterType':        'FROM',
//       });
//     }
//     for (final v in _toSelected) {
//       await displayProvider.create({
//         'crId':               savedMstID.toString(),  // CounterMstID
//         'userVisibilityCode': v.toString(),
//         'counterType':        'TO',
//       });
//     }
//     if (!mounted) return;
//     _resetForm();
//     await ErpResultDialog.showSuccess(
//       context: context, theme: _theme,
//       title:   _isEditMode ? 'Updated' : 'Saved',
//       message: _isEditMode ? 'Counter updated successfully.' : 'Counter saved successfully.',
//     );
//   }
//
//   Future<void> _onDelete() async {
//     final raw = _selectedRow?['_raw'] as CounterModel?;
//     if (raw?.crId == null) return;
//     final confirm = await ErpDeleteDialog.show(
//       context: context, theme: _theme, title: 'Counter', itemName: raw!.crName ?? '',
//     );
//     if (confirm != true || !mounted) return;
//     final success = await context.read<CounterProvider>().delete(raw!.crId!);
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
//       _selectedManType       = null;
//       _selectedEmpType       = null;
//       _fromSelected          = {};
//       _toSelected            = {};
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
//     url:         'http://50.62.183.116:5000',
//     title:       'COUNTER LIST',
//     columns:     _tableColumns,
//     data:        p.tableData,
//     showSearch:  true,
//     selectedRow: _selectedRow,
//     onRowTap:    _onRowTap,
//     emptyMessage: p.isLoaded ? 'No counters found' : 'Loading...',
//   );
//
//   Widget _buildFormWrapper() {
//     return Consumer5<CounterTypeProvider, DivisionProvider, DeptGroupProvider,
//         DeptProvider, TeamProvider>(
//       builder: (context, ctP, divP, dgP, deptP, teamP, _) {
//         final counterTypeItems = ctP.list
//             .map((e) => ErpDropdownItem(
//             label: e.counterTypeName ?? '', value: e.counterTypeCode?.toString() ?? ''))
//             .toList();
//
//         final divisionItems = divP.divisions
//             .map((e) => ErpDropdownItem(
//             label: e.divisionName ?? '', value: e.divisionCode?.toString() ?? ''))
//             .toList();
//
//         final deptGroupItems = dgP.list
//             .map((e) => ErpDropdownItem(
//             label: e.deptGroupName ?? '', value: e.deptGroupCode?.toString() ?? ''))
//             .toList();
//
//         final filteredDepts = _selectedDeptGroupCode != null
//             ? deptP.list.where((e) => e.deptGroupCode?.toString() == _selectedDeptGroupCode).toList()
//             : deptP.list;
//         final departmentItems = filteredDepts
//             .map((e) => ErpDropdownItem(
//             label: e.deptName ?? '', value: e.deptCode?.toString() ?? ''))
//             .toList();
//
//         final teamItems = teamP.list
//             .map((e) => ErpDropdownItem(
//             label: e.teamName ?? '', value: e.teamCode?.toString() ?? ''))
//             .toList();
//
//         return Consumer<UserVisibilityProvider>(
//           builder: (context, visP, _) => _buildErpForm(
//             counterTypeItems: counterTypeItems,
//             divisionItems:    divisionItems,
//             deptGroupItems:   deptGroupItems,
//             departmentItems:  departmentItems,
//             teamItems:        teamItems,
//             visibilityProvider: visP,
//           ),
//         );
//       },
//     );
//   }
//
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
//           ErpFieldConfig(key: 'polishOut',  label: 'POLISH OUT',  type: ErpFieldType.dropdown, dropdownItems: _ynItems,         sectionIndex: 1),
//           ErpFieldConfig(key: 'stockLimit', label: 'STOCK LIMIT', type: ErpFieldType.number,                                    sectionIndex: 1),
//           ErpFieldConfig(key: 'target',     label: 'TARGET',      type: ErpFieldType.number,                                    sectionIndex: 1),
//           ErpFieldConfig(key: 'kachaIss',   label: 'KACHA ISS',   type: ErpFieldType.dropdown, dropdownItems: _ynItems,         sectionIndex: 1),
//         ],
//
//         // ── LIMITS ────────────────────────────────────────────────────────
//         [
//           ErpFieldConfig(key: 'manType',        label: 'MAN TYPE',           type: ErpFieldType.dropdown, dropdownItems: const [ErpDropdownItem(label: 'Days', value: 'Days'), ErpDropdownItem(label: 'Hours', value: 'Hours')], sectionTitle: 'LIMITS', sectionIndex: 2),
//           ErpFieldConfig(key: 'manPktDayLimit',  label: 'MAN PKT DAY LIMIT',  type: ErpFieldType.number, readOnly: _selectedManType == 'Hours', sectionIndex: 2),
//           ErpFieldConfig(key: 'manPktHourLimit', label: 'MAN PKT HOUR LIMIT', type: ErpFieldType.number, readOnly: _selectedManType == 'Days',  sectionIndex: 2),
//         ],
//         [
//           ErpFieldConfig(key: 'empType',        label: 'EMP TYPE',           type: ErpFieldType.dropdown, dropdownItems: const [ErpDropdownItem(label: 'Days', value: 'Days'), ErpDropdownItem(label: 'Hours', value: 'Hours')], sectionIndex: 2),
//           ErpFieldConfig(key: 'empPktDayLimit',  label: 'EMP PKT DAY LIMIT',  type: ErpFieldType.number, readOnly: _selectedEmpType == 'Hours', sectionIndex: 2),
//           ErpFieldConfig(key: 'empPktHourLimit', label: 'EMP PKT HOUR LIMIT', type: ErpFieldType.number, readOnly: _selectedEmpType == 'Days',  sectionIndex: 2),
//         ],
//         [
//           ErpFieldConfig(key: 'empPktLimit', label: 'EMP PKT LIMIT', type: ErpFieldType.number, sectionIndex: 2),
//         ],
//       ];
//
//   Widget _buildErpForm({
//     required List<ErpDropdownItem> counterTypeItems,
//     required List<ErpDropdownItem> divisionItems,
//     required List<ErpDropdownItem> deptGroupItems,
//     required List<ErpDropdownItem> departmentItems,
//     required List<ErpDropdownItem> teamItems,
//     required UserVisibilityProvider visibilityProvider,
//   }) {
//     return ErpForm(
//       logo:          AppImages.logo,
//       key:           _erpFormKey,
//       title:         'COUNTER MASTER',
//       subtitle:      'Counter Configuration',
//       rows:          _formRows(
//         counterTypeItems: counterTypeItems,
//         divisionItems:    divisionItems,
//         deptGroupItems:   deptGroupItems,
//         departmentItems:  departmentItems,
//         teamItems:        teamItems,
//       ),
//       initialValues: _formValues,
//       isEditMode:    _isEditMode,
//       onSearch:      () => setState(() => _showSearch = !_showSearch),
//       onFieldChanged: (key, value) {
//         _formValues[key] = value;
//         if (key == 'deptGroupCode') {
//           setState(() {
//             _selectedDeptGroupCode = value.isEmpty ? null : value;
//             _formValues['deptCode'] = '';
//             _erpFormKey.currentState?.updateFieldValue('deptCode', null);
//           });
//         }
//         if (key == 'manType') setState(() => _selectedManType = value);
//         if (key == 'empType') setState(() => _selectedEmpType = value);
//       },
//       onSave:   _onSave,
//       onCancel: _resetForm,
//       onDelete: _isEditMode ? _onDelete : null,
//       detailBuilder: (ctx) => _buildDisplaySettingSection(visibilityProvider),
//     );
//   }
//
//   Widget _buildDisplaySettingSection(UserVisibilityProvider visibilityProvider) {
//     final theme = context.erpTheme;
//
//     // Sirf DEPT type wale dikhao
//     final deptItems = visibilityProvider.list
//         .where((e) =>
//     (e.entryType?.toUpperCase() =='DEPT')
//         // ||
//         // (e.userVisibilityName?.toUpperCase().contains('DEPT') == true)
//     )
//         .toList();
//
//     final displayItems = deptItems.isNotEmpty ? deptItems : visibilityProvider.list;
//     if (displayItems.isEmpty) return const SizedBox.shrink();
//
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           Container(
//             alignment: Alignment.center,
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: theme.primaryGradient.map((c) => c.withOpacity(0.13)).toList(),
//               ),
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: theme.primary.withOpacity(0.3)),
//             ),
//             child: Text(
//               'DISPLAY SETTING',
//               style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: theme.primary, letterSpacing: 0.8),
//             ),
//           ),
//           const SizedBox(height: 6),
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Expanded(
//                 child: _DisplayCheckboxPanel(
//                   theme: theme, title: 'From Display Setting',
//                   items: visibilityProvider.list, selected: _fromSelected,
//                   onChanged: (code, val) => setState(() {
//                     if (val) _fromSelected.add(code); else _fromSelected.remove(code);
//                   }),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: _DisplayCheckboxPanel(
//                   theme: theme, title: 'To Display Setting',
//                   items: displayItems, selected: _toSelected,
//                   onChanged: (code, val) => setState(() {
//                     if (val) _toSelected.add(code); else _toSelected.remove(code);
//                   }),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
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
//     required this.items,  required this.selected,
//     required this.onChanged,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final t = theme;
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(colors: t.primaryGradient.map((c) => c.withOpacity(0.15)).toList()),
//             borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
//             border: Border.all(color: t.primary.withOpacity(0.3)),
//           ),
//           child: Row(
//             children: [
//               Icon(
//                 title.toLowerCase().contains('from') ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded,
//                 size: 13, color: t.primary,
//               ),
//               const SizedBox(width: 6),
//               Expanded(
//                 child: Text(title,
//                     style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: t.primary, letterSpacing: 0.4)),
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                 decoration: BoxDecoration(color: t.primary, borderRadius: BorderRadius.circular(8)),
//                 child: Text('${selected.length}',
//                     style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w700)),
//               ),
//             ],
//           ),
//         ),
//         Container(
//           constraints: const BoxConstraints(maxHeight: 280),
//           decoration: BoxDecoration(
//             color: t.surface,
//             border: Border.all(color: t.border),
//             borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
//           ),
//           child: ListView.builder(
//             shrinkWrap: true,
//             itemCount: items.length,
//             itemBuilder: (ctx, i) {
//               final item      = items[i];
//               final code      = item.userVisibilityCode ?? 0;
//               final isChecked = selected.contains(code);
//               final isEven    = i % 2 == 0;
//               return InkWell(
//                 onTap: () => onChanged(code, !isChecked),
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
//                   color: isChecked
//                       ? t.primary.withOpacity(0.08)
//                       : isEven ? Colors.white : t.bg.withOpacity(0.5),
//                   child: Row(
//                     children: [
//                       SizedBox(
//                         width: 20, height: 26,
//                         child: Checkbox(
//                           value: isChecked, activeColor: t.primary,
//                           onChanged: (v) => onChanged(code, v ?? false),
//                           visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
//                           materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                         ),
//                       ),
//                       const SizedBox(width: 6),
//                       Expanded(
//                         child: Text(item.userVisibilityName ?? '',
//                             style: TextStyle(
//                               fontSize: 10,
//                               color: isChecked ? t.primary : t.text,
//                               fontWeight: isChecked ? FontWeight.w600 : FontWeight.normal,
//                             )),
//                       ),
//                       if (item.entryType != null)
//                         Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
//                           decoration: BoxDecoration(
//                             color: t.primary.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                           child: Text(item.entryType!,
//                               style: TextStyle(fontSize: 7, color: t.primary, fontWeight: FontWeight.w700)),
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
// lib/screens/mst_counter.dart

// lib/screens/mst_counter.dart

import 'package:erp_data_table/erp_data_table.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rs_dashboard/rs_dashboard.dart';

import '../models/counter_model.dart';
import '../models/user_visibility_model.dart';
import '../providers/counter_provider.dart';
import '../providers/counter_display_det_provider.dart';
import '../providers/counter_det_provider.dart';
import '../providers/counter_process_provider.dart';
import '../providers/dept_provider.dart';
import '../providers/main_menuMst_provider.dart';
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

class MstCounter extends StatefulWidget {
  const MstCounter({super.key});

  @override
  State<MstCounter> createState() => _MstCounterState();
}

class _MstCounterState extends State<MstCounter> {
  ErpThemeVariant _themeVariant = ErpThemeVariant.frost;
  ErpTheme get _theme => ErpTheme(_themeVariant);

  final GlobalKey<ErpFormState> _erpFormKey = GlobalKey<ErpFormState>();
  // Jab tab lock hota hai, ErpForm ko rebuild karte hain at tab 0
  Key _formKey = UniqueKey();
  Map<String, dynamic>? _selectedRow;
  bool _isEditMode        = false;
  bool _showSearch        = false;
  bool _showTableOnMobile = false;
  Map<String, String> _formValues = {};

  // After Tab 0 save → crId/mstID set → Tab 1/2 unlock
  int? _savedCrId;
  int? _savedMstID;

  int _currentTabIndex = 0;

  // Dependent dropdowns
  String? _selectedDeptGroupCode;
  String? _selectedDeptCode;
  String? _selectedManType;
  String? _selectedEmpType;

  // Tab 0: Display Setting
  Set<int> _fromSelected = {};
  Set<int> _toSelected   = {};

  // Tab 1: Process
  Set<int> _selectedProcessCodes = {};

  // Tab 2: Menu Rights
  Set<int> _selectedMenuIds    = {};
  Set<int> _collapsedMainMenus = {};

  final String? token = AppStorage.getString("token");

  List<ErpColumnConfig> get _tableColumns => [
    ErpColumnConfig(key: 'crId',      label: 'CR ID',  width: 80),
    ErpColumnConfig(key: 'crName',    label: 'NAME',   width: 180),
    ErpColumnConfig(key: 'logInName', label: 'LOGIN',  width: 140),
    ErpColumnConfig(key: 'userGrp',   label: 'GROUP',  width: 110),
    ErpColumnConfig(key: 'deptCode',  label: 'DEPT',   width: 90),
    ErpColumnConfig(key: 'active',    label: 'ACTIVE', width: 90),
  ];

  List<ErpDropdownItem> get _ynItems => const [
    ErpDropdownItem(label: 'Y', value: 'Y'),
    ErpDropdownItem(label: 'N', value: 'N'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.wait([
        context.read<CounterTypeProvider>().load(),
        context.read<DivisionProvider>().loadDivisions(),
        context.read<DeptGroupProvider>().load(),
        context.read<DeptProvider>().load(),
        context.read<TeamProvider>().load(),
        context.read<UserVisibilityProvider>().load(),
        context.read<MainMenuMstProvider>().load(),
        context.read<MenuMstProvider>().load(),
        context.read<DeptProcessProvider>().load(),
      ]);
      if (!mounted) return;
      await context.read<CounterProvider>().load();
    });
  }

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
      _savedCrId             = raw.crId;
      _savedMstID            = raw.counterMstID;
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

  Future<void> _loadProcessRights(int crId) async {
    final dp = context.read<CounterProcessProvider>();
    await dp.loadByCounter(crId);
    setState(() {
      _selectedProcessCodes = dp.counterList
          .where((r) => r.deptProcessCode != null)
          .map((r) => r.deptProcessCode!).toSet();
    });
  }

  // ── SAVE — tab 0 only (Basic + Display Setting) ───────────────────────────
  Future<void> _onSave(Map<String, dynamic> values) async {
    // Tab 0 save karo Counter master
    if (_currentTabIndex == 0) {
      final counterProvider = context.read<CounterProvider>();
      CounterModel? savedCounter;
      if (_isEditMode && _selectedRow != null) {
        final raw    = _selectedRow!['_raw'] as CounterModel;
        savedCounter = await counterProvider.updateAndReturn(raw.crId!, values);
      } else {
        savedCounter = await counterProvider.createAndReturn(values);
      }
      if (savedCounter == null || !mounted) return;

      setState(() {
        _savedCrId  = savedCounter!.crId;
        _savedMstID = savedCounter!.counterMstID;
      });

      // CounterDisplayDet save
      if (_savedMstID != null) {
        final displayProvider = context.read<CounterDisplayDetProvider>();
        await displayProvider.deleteByCounter(_savedMstID!);
        for (final v in _fromSelected) {
          await displayProvider.create({
            'crId': _savedMstID.toString(),
            'userVisibilityCode': v.toString(),
            'counterType': 'FROM',
          });
        }
        for (final v in _toSelected) {
          await displayProvider.create({
            'crId': _savedMstID.toString(),
            'userVisibilityCode': v.toString(),
            'counterType': 'TO',
          });
        }
      }

      if (!mounted) return;
      await ErpResultDialog.showSuccess(
        context: context, theme: _theme,
        title:   _isEditMode ? 'Updated' : 'Saved',
        message: 'Counter saved. Process & Rights tabs are now unlocked.',
      );
    }

    // Tab 1 save — Process
    else if (_currentTabIndex == 1 && _savedCrId != null) {
      final processProvider = context.read<CounterProcessProvider>();
      final processList     = context.read<DeptProcessProvider>().list;
      final existingProc    = List.of(processProvider.counterList);
      for (final r in existingProc) {
        if (r.counterProcessDetID != null) await processProvider.delete(r.counterProcessDetID!);
      }
      for (final procCode in _selectedProcessCodes) {
        final proc = processList.where((p) => p.deptProcessCode == procCode).firstOrNull;
        await processProvider.create({
          'crId':            _savedCrId.toString(),
          'deptCode':        (proc?.deptCode ?? 0).toString(),
          'deptProcessCode': procCode.toString(),
        });
      }
      if (!mounted) return;
      await ErpResultDialog.showSuccess(
        context: context, theme: _theme,
        title: 'Saved', message: 'Process rights saved successfully.',
      );
    }

    // Tab 2 save — Menu Rights
    else if (_currentTabIndex == 2 && _savedCrId != null) {
      final detProvider = context.read<CounterDetProvider>();
      final menuList    = context.read<MenuMstProvider>().list;
      final existingDet = List.of(detProvider.counterList);
      for (final r in existingDet) {
        if (r.counterDetID != null) await detProvider.delete(r.counterDetID!);
      }
      for (final menuId in _selectedMenuIds) {
        final menu = menuList.where((m) => m.menuMstID == menuId).firstOrNull;
        await detProvider.create({
          'crId':          _savedCrId.toString(),
          'mainMenuMstID': (menu?.mainMenuMstID ?? 0).toString(),
          'menuMstID':     menuId.toString(),
        });
      }
      if (!mounted) return;
      await ErpResultDialog.showSuccess(
        context: context, theme: _theme,
        title: 'Saved', message: 'Menu rights saved successfully.',
      );
    }
  }

  Future<void> _onDelete() async {
    final raw = _selectedRow?['_raw'] as CounterModel?;
    if (raw?.crId == null) return;
    final confirm = await ErpDeleteDialog.show(
      context: context, theme: _theme, title: 'Counter', itemName: raw!.crName ?? '',
    );
    if (confirm != true || !mounted) return;
    final success = await context.read<CounterProvider>().delete(raw!.crId!);
    if (success && mounted) {
      _resetForm();
      await ErpResultDialog.showDeleted(context: context, theme: _theme, itemName: raw.crName ?? '');
    }
  }

  void _resetForm() {
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
      _fromSelected          = {};
      _toSelected            = {};
      _selectedMenuIds       = {};
      _selectedProcessCodes  = {};
      _currentTabIndex       = 0;
      _formKey               = UniqueKey();
    });
    _erpFormKey.currentState?.resetForm();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CounterProvider>(
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
    );
  }

  Widget _buildTable(CounterProvider p) => ErpDataTable(
    isReportRow: false, token: token ?? '',
    url: 'http://50.62.183.116:5000', title: 'COUNTER LIST',
    columns: _tableColumns, data: p.tableData, showSearch: true,
    selectedRow: _selectedRow, onRowTap: _onRowTap,
    emptyMessage: p.isLoaded ? 'No counters found' : 'Loading...',
  );

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

        // MFG Rate on Dept — same deptGroupCode filter
        final mfgDeptItems = filteredDepts.map((e) => ErpDropdownItem(
            label: e.deptName ?? '', value: e.deptCode?.toString() ?? '')).toList();

        final teamItems = teamP.list.map((e) => ErpDropdownItem(
            label: e.teamName ?? '', value: e.teamCode?.toString() ?? '')).toList();

        return Consumer3<UserVisibilityProvider, MainMenuMstProvider, MenuMstProvider>(
          builder: (context, visP, mainMenuP, menuP, _) {
            // final tabsEnabled = _savedCrId != null;
            return ErpForm(
              logo:          AppImages.logo,
              key:           _formKey,
              title:         'COUNTER MASTER',
              subtitle:      'Counter Configuration',
              // ── 3 tabs ──
              tabs: const ['BASIC', 'PROCESS', 'SELECT RIGHTS'],
              initialTabIndex:        _currentTabIndex,
              tabBarBackgroundColor:  const Color(0xFFF1F5F9),
              tabBarSelectedColor:    _theme.primaryGradient.first,
              tabBarSelectedTxtColor: Colors.white,
              onTabChanged: (i) {
                // Tab 1/2 locked until Tab 0 saved — snackbar + content block
                // if (i > 0 && !tabsEnabled) {
                  // ErpForm ne tab visual change kar diya, lekin
                  // _currentTabIndex update nahi karte so detailBuilder
                  // abhi bhi lock message dikhata rahega.
                  // ErpForm key change karke internal tab bhi reset karo.
                  // setState(() {
                  //   _currentTabIndex = 0;
                  //   _formKey = UniqueKey();   // forces ErpForm rebuild at tab 0
                  // });
                  // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  //   content: const Text('Please save the BASIC tab first.'),
                  //   backgroundColor: Colors.orange.shade700,
                  //   duration: const Duration(seconds: 2),
                  //   behavior: SnackBarBehavior.floating,
                  //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  //   margin: const EdgeInsets.all(12),
                  // ));
                  // return;
                // }
                setState(() => _currentTabIndex = i);
              },
              rows: _buildFormRows(
                counterTypeItems: counterTypeItems,
                divisionItems:    divisionItems,
                deptGroupItems:   deptGroupItems,
                departmentItems:  departmentItems,
                teamItems:        teamItems,
                mfgDeptItems:     mfgDeptItems,
              ),
              initialValues: _formValues,
              isEditMode:    _isEditMode,
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
              // ── detailBuilder — tab-aware content ──
              detailBuilder: (ctx) => _buildTabDetail(visP, mainMenuP, menuP,),
            );
          },
        );
      },
    );
  }

  // ── FORM ROWS — tabIndex divides fields into tabs ─────────────────────────
  // tabIndex 0 = BASIC tab, other tabs show no ErpForm fields (only detailBuilder)
  List<List<ErpFieldConfig>> _buildFormRows({
    required List<ErpDropdownItem> counterTypeItems,
    required List<ErpDropdownItem> divisionItems,
    required List<ErpDropdownItem> deptGroupItems,
    required List<ErpDropdownItem> departmentItems,
    required List<ErpDropdownItem> teamItems,
    required List<ErpDropdownItem> mfgDeptItems,
  }) =>
      [
        // ── Tab 0: BASIC INFORMATION ──────────────────────────────────────
        [
          ErpFieldConfig(key: 'counterTypeCode', label: 'TYPE',       type: ErpFieldType.dropdown, dropdownItems: counterTypeItems, sectionTitle: 'BASIC INFORMATION', sectionIndex: 0, tabIndex: 0),
          ErpFieldConfig(key: 'divisionCode',    label: 'DIVISION',   type: ErpFieldType.dropdown, dropdownItems: divisionItems,    sectionIndex: 0, tabIndex: 0),
          ErpFieldConfig(key: 'deptGroupCode',   label: 'GROUP',      type: ErpFieldType.dropdown, dropdownItems: deptGroupItems,   sectionIndex: 0, tabIndex: 0),
          ErpFieldConfig(key: 'deptCode',        label: 'DEPARTMENT', type: ErpFieldType.dropdown, dropdownItems: departmentItems,  sectionIndex: 0, tabIndex: 0),
        ],
        [
          ErpFieldConfig(key: 'teamCode', label: 'TEAM',   type: ErpFieldType.dropdown, dropdownItems: teamItems, sectionIndex: 0, tabIndex: 0),
          ErpFieldConfig(key: 'userGrp',  label: 'RIGHTS', type: ErpFieldType.dropdown,
              dropdownItems: const [ErpDropdownItem(label: 'Admin', value: 'Admin'), ErpDropdownItem(label: 'User', value: 'User')],
              sectionIndex: 0, tabIndex: 0),
          ErpFieldConfig(key: 'logInName', label: 'LOGIN NAME', required: true, sectionIndex: 0, tabIndex: 0),
          ErpFieldConfig(key: 'crPass',    label: 'PASSWORD',                   sectionIndex: 0, tabIndex: 0),
        ],
        [
          ErpFieldConfig(key: 'crName',      label: 'NAME',             required: true,              sectionIndex: 0, tabIndex: 0),
          ErpFieldConfig(key: 'sortID',      label: 'SORT ID',          type: ErpFieldType.number,   sectionIndex: 0, tabIndex: 0),
          ErpFieldConfig(key: 'mfgDeptCode', label: 'MFG RATE ON DEPT', type: ErpFieldType.dropdown, dropdownItems: mfgDeptItems, sectionIndex: 0, tabIndex: 0),
          ErpFieldConfig(key: 'active',      label: 'ACTIVE',           type: ErpFieldType.checkbox, checkboxDbType: 'BIT', sectionIndex: 0, tabIndex: 0),
        ],

        // ── Tab 0: PERMISSIONS ────────────────────────────────────────────
        [
          ErpFieldConfig(key: 'crEdit',       label: 'EDIT',           type: ErpFieldType.dropdown, dropdownItems: _ynItems, sectionTitle: 'PERMISSIONS', sectionIndex: 1, tabIndex: 0),
          ErpFieldConfig(key: 'crDel',        label: 'DELETE',         type: ErpFieldType.dropdown, dropdownItems: _ynItems, sectionIndex: 1, tabIndex: 0),
          ErpFieldConfig(key: 'autoRec',      label: 'CONFIRM REC',    type: ErpFieldType.dropdown, dropdownItems: _ynItems, sectionIndex: 1, tabIndex: 0),
          ErpFieldConfig(key: 'empIssRec',    label: 'EMP ISS REC',    type: ErpFieldType.dropdown, dropdownItems: _ynItems, sectionIndex: 1, tabIndex: 0),
          ErpFieldConfig(key: 'empRecWt',     label: 'EMP REC WT',     type: ErpFieldType.dropdown, dropdownItems: _ynItems, sectionIndex: 1, tabIndex: 0),
          ErpFieldConfig(key: 'laserPlanRec', label: 'LASER PLAN REC', type: ErpFieldType.dropdown, dropdownItems: _ynItems, sectionIndex: 1, tabIndex: 0),
        ],
        [
          ErpFieldConfig(key: 'polishOut',  label: 'POLISH OUT',  type: ErpFieldType.dropdown, dropdownItems: _ynItems, sectionIndex: 1, tabIndex: 0),
          ErpFieldConfig(key: 'stockLimit', label: 'STOCK LIMIT', type: ErpFieldType.number,                            sectionIndex: 1, tabIndex: 0),
          ErpFieldConfig(key: 'target',     label: 'TARGET',      type: ErpFieldType.number,                            sectionIndex: 1, tabIndex: 0),
          ErpFieldConfig(key: 'kachaIss',   label: 'KACHA ISS',   type: ErpFieldType.dropdown, dropdownItems: _ynItems, sectionIndex: 1, tabIndex: 0),
        ],

        // ── Tab 0: LIMITS ─────────────────────────────────────────────────
        [
          ErpFieldConfig(key: 'manType',         label: 'MAN TYPE',           type: ErpFieldType.dropdown, dropdownItems: const [ErpDropdownItem(label: 'Days', value: 'Days'), ErpDropdownItem(label: 'Hours', value: 'Hours')], sectionTitle: 'LIMITS', sectionIndex: 2, tabIndex: 0),
          ErpFieldConfig(key: 'manPktDayLimit',  label: 'MAN PKT DAY LIMIT',  type: ErpFieldType.number, readOnly: _selectedManType == 'Hours', sectionIndex: 2, tabIndex: 0),
          ErpFieldConfig(key: 'manPktHourLimit', label: 'MAN PKT HOUR LIMIT', type: ErpFieldType.number, readOnly: _selectedManType == 'Days',  sectionIndex: 2, tabIndex: 0),
        ],
        [
          ErpFieldConfig(key: 'empType',         label: 'EMP TYPE',           type: ErpFieldType.dropdown, dropdownItems: const [ErpDropdownItem(label: 'Days', value: 'Days'), ErpDropdownItem(label: 'Hours', value: 'Hours')], sectionIndex: 2, tabIndex: 0),
          ErpFieldConfig(key: 'empPktDayLimit',  label: 'EMP PKT DAY LIMIT',  type: ErpFieldType.number, readOnly: _selectedEmpType == 'Hours', sectionIndex: 2, tabIndex: 0),
          ErpFieldConfig(key: 'empPktHourLimit', label: 'EMP PKT HOUR LIMIT', type: ErpFieldType.number, readOnly: _selectedEmpType == 'Days',  sectionIndex: 2, tabIndex: 0),
          ErpFieldConfig(key: 'empPktLimit',     label: 'EMP PKT LIMIT',      type: ErpFieldType.number,                                        sectionIndex: 2, tabIndex: 0),
        ],

        // ── Tab 1 & 2: no ErpForm fields — content via detailBuilder ──────
        // (empty placeholder rows so ErpForm knows these tabs exist)
      ];

  // ── DETAIL BUILDER — tab-aware ────────────────────────────────────────────
  Widget _buildTabDetail(
      UserVisibilityProvider visP,
      MainMenuMstProvider mainMenuP,
      MenuMstProvider menuP,
      // bool tabsEnabled,
      ) {
    final theme = context.erpTheme;

    switch (_currentTabIndex) {
    // Tab 0: Display Setting (below form fields)
      case 0:
        return _buildDisplaySetting(visP, theme);

    // Tab 1: Process
      case 1:
        // if (!tabsEnabled) return _lockedMsg(theme);
        return _buildProcessTab(theme);

    // Tab 2: Select Rights
      case 2:
        // if (!tabsEnabled) return _lockedMsg(theme);
        return _buildMenuRightsTree(mainMenuP, menuP, theme);

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _lockedMsg(ErpTheme theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.lock_outline_rounded, size: 32, color: theme.textLight.withOpacity(0.4)),
        const SizedBox(height: 8),
        Text('Please save the BASIC tab first.',
            style: TextStyle(fontSize: 12, color: theme.textLight), textAlign: TextAlign.center),
      ]),
    );
  }

  // ── DISPLAY SETTING ───────────────────────────────────────────────────────
  Widget _buildDisplaySetting(UserVisibilityProvider visP, ErpTheme theme) {
    final deptItems = visP.list.where((e) => e.entryType?.toUpperCase() == 'DEPT').toList();
    final toItems   = deptItems.isNotEmpty ? deptItems : visP.list;
    if (visP.list.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _sectionHeader(theme, 'DISPLAY SETTING'),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _DisplayCheckboxPanel(
              theme: theme, title: 'From Display Setting',
              items: visP.list, selected: _fromSelected,
              onChanged: (code, val) => setState(() {
                if (val) _fromSelected.add(code); else _fromSelected.remove(code);
              }),
            )),
            const SizedBox(width: 8),
            Expanded(child: _DisplayCheckboxPanel(
              theme: theme, title: 'To Display Setting',
              items: toItems, selected: _toSelected,
              onChanged: (code, val) => setState(() {
                if (val) _toSelected.add(code); else _toSelected.remove(code);
              }),
            )),
          ],
        ),
      ]),
    );
  }

  // ── PROCESS TAB ───────────────────────────────────────────────────────────
  Widget _buildProcessTab(ErpTheme theme) {
    return Consumer<DeptProcessProvider>(builder: (context, procP, _) {
      final filtered = _selectedDeptCode != null
          ? procP.list.where((p) => p.deptCode?.toString() == _selectedDeptCode).toList()
          : procP.list;

      if (filtered.isEmpty) {
        return Padding(padding: const EdgeInsets.all(24),
          child: Text(
            _selectedDeptCode == null
                ? 'Please select a Department in BASIC tab first.'
                : 'No processes found for selected department.',
            style: TextStyle(fontSize: 12, color: theme.textLight), textAlign: TextAlign.center,
          ),
        );
      }

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
            child: Column(
              children: filtered.asMap().entries.map((entry) {
                final i = entry.key; final proc = entry.value;
                final code = proc.deptProcessCode ?? 0;
                final isChecked = _selectedProcessCodes.contains(code);
                return InkWell(
                  onTap: () => setState(() {
                    if (isChecked) _selectedProcessCodes.remove(code);
                    else           _selectedProcessCodes.add(code);
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isChecked ? theme.primary.withOpacity(0.07)
                          : i.isEven ? Colors.white : theme.bg.withOpacity(0.5),
                      border: Border(top: i == 0 ? BorderSide.none
                          : BorderSide(color: theme.border.withOpacity(0.5))),
                    ),
                    child: Row(children: [
                      SizedBox(width: 20, height: 26, child: Checkbox(
                        value: isChecked, activeColor: theme.primary,
                        onChanged: (v) => setState(() {
                          if (v == true) _selectedProcessCodes.add(code);
                          else _selectedProcessCodes.remove(code);
                        }),
                        visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      )),
                      const SizedBox(width: 8),
                      Expanded(child: Text(proc.deptProcessName ?? '',
                          style: TextStyle(fontSize: 11,
                              color: isChecked ? theme.primary : theme.text,
                              fontWeight: isChecked ? FontWeight.w600 : FontWeight.normal))),
                      Text(code.toString(), style: TextStyle(fontSize: 9, color: theme.textLight)),
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

  // ── MENU RIGHTS TREE ──────────────────────────────────────────────────────
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
                      if (isCollapsed) _collapsedMainMenus.remove(mainMenuId);
                      else _collapsedMainMenus.add(mainMenuId);
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
                            if (v == true || someChecked) _selectedMenuIds.addAll(childIds);
                            else _selectedMenuIds.removeAll(childIds);
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
                  if (!isCollapsed)
                    ...children.map((menu) {
                      final menuId    = menu.menuMstID ?? 0;
                      final isChecked = _selectedMenuIds.contains(menuId);
                      return InkWell(
                        onTap: () => setState(() {
                          if (isChecked) _selectedMenuIds.remove(menuId);
                          else _selectedMenuIds.add(menuId);
                        }),
                        child: Container(
                          padding: const EdgeInsets.only(left: 44, right: 10, top: 3, bottom: 3),
                          decoration: BoxDecoration(
                            color: isChecked ? theme.primary.withOpacity(0.06) : Colors.white,
                            border: Border(top: BorderSide(color: theme.border.withOpacity(0.5))),
                          ),
                          child: Row(children: [
                            SizedBox(width: 18, height: 22, child: Checkbox(
                              value: isChecked, activeColor: theme.primary,
                              onChanged: (v) => setState(() {
                                if (v == true) _selectedMenuIds.add(menuId);
                                else _selectedMenuIds.remove(menuId);
                              }),
                              visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            )),
                            const SizedBox(width: 8),
                            Icon(Icons.check_box_outline_blank_rounded, size: 11, color: theme.textLight),
                            const SizedBox(width: 6),
                            Expanded(child: Text(menu.menuName ?? '',
                                style: TextStyle(fontSize: 11,
                                    color: isChecked ? theme.primary : theme.text,
                                    fontWeight: isChecked ? FontWeight.w600 : FontWeight.normal))),
                          ]),
                        ),
                      );
                    }),
                ],
              );
            }).toList(),
          ),
        ),
      ]),
    );
  }

  Widget _sectionHeader(ErpTheme theme, String title) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: theme.primaryGradient.map((c) => c.withOpacity(0.13)).toList()),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.primary.withOpacity(0.3)),
      ),
      child: Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: theme.primary, letterSpacing: 0.8)),
    );
  }
}


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
          gradient: LinearGradient(colors: t.primaryGradient.map((c) => c.withOpacity(0.15)).toList()),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          border: Border.all(color: t.primary.withOpacity(0.3)),
        ),
        child: Row(children: [
          Icon(title.toLowerCase().contains('from') ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded,
              size: 13, color: t.primary),
          const SizedBox(width: 6),
          Expanded(child: Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: t.primary, letterSpacing: 0.4))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: t.primary, borderRadius: BorderRadius.circular(8)),
            child: Text('${selected.length}', style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ]),
      ),
      Container(
        constraints: const BoxConstraints(maxHeight: 200),
        decoration: BoxDecoration(
          color: t.surface, border: Border.all(color: t.border),
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
        ),
        child: ListView.builder(
          shrinkWrap: true, itemCount: items.length,
          itemBuilder: (ctx, i) {
            final item = items[i]; final code = item.userVisibilityCode ?? 0;
            final isChecked = selected.contains(code); final isEven = i % 2 == 0;
            return InkWell(
              onTap: () => onChanged(code, !isChecked),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                color: isChecked ? t.primary.withOpacity(0.08) : isEven ? Colors.white : t.bg.withOpacity(0.5),
                child: Row(children: [
                  SizedBox(width: 20, height: 24, child: Checkbox(
                    value: isChecked, activeColor: t.primary,
                    onChanged: (v) => onChanged(code, v ?? false),
                    visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  )),
                  const SizedBox(width: 6),
                  Expanded(child: Text(item.userVisibilityName ?? '',
                      style: TextStyle(fontSize: 10, color: isChecked ? t.primary : t.text,
                          fontWeight: isChecked ? FontWeight.w600 : FontWeight.normal))),
                  if (item.entryType != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(color: t.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                      child: Text(item.entryType!, style: TextStyle(fontSize: 7, color: t.primary, fontWeight: FontWeight.w700)),
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
//     url:         'http://50.62.183.116:5000',
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