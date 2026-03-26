// import 'package:diam_mfg/models/employee_model.dart';
// import 'package:diam_mfg/providers/dept_provider.dart';
// import 'package:diam_mfg/providers/designation_provider.dart';
// import 'package:diam_mfg/providers/employee_provider.dart';
// import 'package:erp_data_table/erp_data_table.dart';
// import 'package:erp_formatter/erp_formatter.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:rs_dashboard/rs_dashboard.dart';
//
// import '../bootstrap.dart';
// import '../providers/company_provider.dart';
// import '../utils/app_images.dart';
// import '../utils/delete_dialogue.dart';
// import '../utils/msg_dialogue.dart';
//
// class MstEmployee extends StatefulWidget {
//   const MstEmployee({super.key});
//
//   @override
//   State<MstEmployee> createState() => _MstEmployeeState();
// }
//
// class _MstEmployeeState extends State<MstEmployee> {
//
//   ErpThemeVariant _themeVariant = ErpThemeVariant.frost;
//   ErpTheme get _theme => ErpTheme(_themeVariant);
//
//   final GlobalKey<ErpFormState> _erpFormKey = GlobalKey<ErpFormState>();
//
//   Map<String, dynamic>? _selectedRow;
//   bool _isEditMode = false;
//   Map<String, String> _formValues = {};
//
//   final String? token = AppStorage.getString("token");
//
//   // ───────── TABLE ─────────
//   List<ErpColumnConfig> get _tableColumns => [
//     ErpColumnConfig(key: 'employeeCode', label: 'CODE', width: 100),
//     ErpColumnConfig(key: 'employeeName', label: 'NAME', width: 200),
//     ErpColumnConfig(key: 'mobile', label: 'MOBILE'),
//     ErpColumnConfig(key: 'department', label: 'DEPT'),
//     ErpColumnConfig(key: 'salary', label: 'SALARY'),
//     ErpColumnConfig(
//       key: 'active',
//       label: 'ACTIVE',
//       align: ColumnAlign.center,
//     ),
//   ];
//
//   // ───────── FORM ─────────
//   List<List<ErpFieldConfig>> _formRows(DeptProvider deptProvider,DesignationProvider designationProvider) => [
//
//     /// BASIC
//     [
//       ErpFieldConfig(
//         key: 'employeeName',
//         label: 'EMPLOYEE NAME',
//         required: true,
//         flex: 3,
//         sectionTitle: 'BASIC INFORMATION',
//         sectionIndex: 0,
//       ),
//       ErpFieldConfig(
//         key: 'aliasName',
//         label: 'ALIAS NAME',
//         flex: 2,
//         sectionIndex: 0,
//       ),
//     ],
//
//     [
//       ErpFieldConfig(
//         key: 'deptCode',
//         label: 'DEPARTMENT CODE',
//         type: ErpFieldType.dropdown,
//         dropdownItems: deptProvider.list
//             .where((e) => e.active == true)
//             .map((e) => ErpDropdownItem(
//           label: e.deptName ?? '',
//           value: e.deptCode.toString(),
//         ))
//             .toList(),
//         flex: 1,
//         sectionIndex: 0,
//       ),
//       ErpFieldConfig(
//         key: 'designationCode',
//         label: 'DESIGNATION CODE',
//         type: ErpFieldType.dropdown,
//         dropdownItems: designationProvider.list
//             .where((e) => e.active == true)
//             .map((e) => ErpDropdownItem(
//           label: e.designationName ?? '',
//           value: e.designationCode.toString(),
//         ))
//             .toList(),
//         flex: 1,
//         sectionIndex: 0,
//       ),
//     ],
//
//     /// CONTACT
//     [
//       ErpFieldConfig(
//         key: 'address',
//         label: 'ADDRESS',
//         maxLines: 2,
//         flex: 4,
//         sectionTitle: 'CONTACT DETAILS',
//         sectionIndex: 1,
//       ),
//     ],
//
//     [
//       ErpFieldConfig(key: 'phone1', label: 'PHONE 1',flex: 1, sectionIndex: 1,type: ErpFieldType.phone,),
//       ErpFieldConfig(key: 'phone2', label: 'PHONE 2',flex: 1, sectionIndex: 1,type: ErpFieldType.phone,),
//       ErpFieldConfig(key: 'phone3', label: 'PHONE 3',flex: 1, sectionIndex: 1,type: ErpFieldType.phone,),
//     ],
//
//     [
//       ErpFieldConfig(key: 'mob1', label: 'MOBILE 1',flex: 1, sectionIndex: 1,type: ErpFieldType.phone,),
//       ErpFieldConfig(key: 'mob2', label: 'MOBILE 2',flex: 1, sectionIndex: 1,type: ErpFieldType.phone,),
//       ErpFieldConfig(key: 'mob3', label: 'MOBILE 3',flex: 1, sectionIndex: 1,type: ErpFieldType.phone,),
//       ErpFieldConfig(key: 'email1', label: 'EMAIL', flex: 1, sectionIndex: 1,),
//
//     // ],
//     //
//     // [
//     ],
//
//     /// SALARY
//     [
//       ErpFieldConfig(
//         key: 'salaryType',
//         label: 'SALARY TYPE',
//         type: ErpFieldType.dropdown,
//         sectionTitle: 'SALARY DETAILS',
//         sectionIndex: 2,
//         initialDropValue: true,
//         dropdownItems: const [
//           ErpDropdownItem(label: 'FIX', value: 'FIX'),
//           ErpDropdownItem(label: 'WORKING', value: 'WORKING'),
//         ],
//       ),
//       ErpFieldConfig(
//         key: 'salary',
//         label: 'SALARY',
//         type: ErpFieldType.number,
//         sectionIndex: 2,
//       ),
//     ],
//
//     [
//       ErpFieldConfig(
//           key: 'active',
//           label: 'ACTIVE',
//           type: ErpFieldType.checkbox,
//           flex: 1,
//           // sectionIndex: 0,
//           initialBoolValue: true,
//           checkboxDbType: 'BIT'
//       ),
//       // ErpFieldConfig(
//       //   key: 'active',
//       //   label: 'ACTIVE',
//       //   type: ErpFieldType.checkbox,
//       //   initialBoolValue: true,
//       //   checkboxDbType: 'BIT',
//       // ),
//     ],
//   ];
//
//   // ───────── INIT ─────────
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<EmployeeProvider>().loadEmployees();
//       context.read<DesignationProvider>().load();
//       context.read<DeptProvider>().load();
//
//       final selectedCode =
//           context.read<CompanyProvider>().selectedCompanyCode;
//
//       context.read<EmployeeProvider>().setSelectedCompany(selectedCode);
//     });
//   }
//
//   // ───────── ROW TAP ─────────
//   void _onRowTap(Map<String, dynamic> row) {
//     final raw = row['_raw'] as EmployeeModel;
//
//     setState(() {
//       _selectedRow = row;
//       _isEditMode = true;
//
//       _formValues = {
//         'employeeCode': raw.employeeCode?.toString() ?? '',
//         'employeeName': raw.employeeName ?? '',
//         'aliasName': raw.aliasName ?? '',
//         'address': raw.address ?? '',
//
//         'phone1': raw.phone1 ?? '',
//         'phone2': raw.phone2 ?? '',
//         'phone3': raw.phone3 ?? '',
//
//         'mob1': raw.mob1 ?? '',
//         'mob2': raw.mob2 ?? '',
//         'mob3': raw.mob3 ?? '',
//
//         'email1': raw.email1 ?? '',
//
//         'deptCode': raw.deptCode?.toString() ?? '',
//         'designationCode': raw.designationCode?.toString() ?? '',
//
//         'salaryType': raw.salaryType ?? '',
//         'salary': raw.salary?.toString() ?? '',
//
//         'active': raw.active == true ? 'true' : 'false',
//       };
//     });
//   }
//
//   // ───────── SAVE ─────────
//   Future<void> _onSave(Map<String, dynamic> values) async {
//     final provider = context.read<EmployeeProvider>();
//
//     bool success;
//
//     if (_isEditMode && _selectedRow != null) {
//       final raw = _selectedRow!['_raw'] as EmployeeModel;
//       success = await provider.updateEmployee(raw.employeeCode!, values);
//     } else {
//       success = await provider.createEmployee(values);
//     }
//
//     if (success && mounted) {
//       _resetForm();
//
//       await ErpResultDialog.showSuccess(
//         context: context,
//         theme: _theme,
//         title: _isEditMode ? 'Updated' : 'Saved',
//         message: 'Employee saved successfully',
//       );
//     }
//   }
//
//   // ───────── DELETE ─────────
//   Future<void> _onDelete() async {
//     final raw = _selectedRow?['_raw'] as EmployeeModel?;
//
//     if (raw == null) return;
//
//     final confirm = await ErpDeleteDialog.show(
//       context: context,
//       theme: _theme,
//       title: 'Employee',
//       itemName: raw.employeeName ?? '',
//     );
//
//     if (confirm != true) return;
//
//     final success =
//     await context.read<EmployeeProvider>().deleteEmployee(raw.employeeCode!);
//
//     if (success && mounted) {
//       _resetForm();
//
//       await ErpResultDialog.showDeleted(
//         context: context,
//         theme: _theme,
//         itemName: raw.employeeName ?? '',
//       );
//     }
//   }
//
//   void _resetForm() {
//     setState(() {
//       _selectedRow = null;
//       _isEditMode = false;
//       _formValues = {};
//     });
//
//     _erpFormKey.currentState?.resetForm();
//   }
//
//   // ───────── UI ─────────
//   @override
//   Widget build(BuildContext context) {
//     final designationProv=context.read<DesignationProvider>();
//     final deptProv=context.read<DeptProvider>();
//     return Consumer<EmployeeProvider>(
//       builder: (context, provider, _) {
//         return Padding(
//           padding: const EdgeInsets.all(8),
//           child: Row(
//             children: [
//
//               /// FORM
//               Expanded(
//                 flex: 2,
//                 child: ErpForm(
//                   logo: AppImages.logo,
//                   key: _erpFormKey,
//                   title: 'EMPLOYEE MASTER',
//                   rows: _formRows(deptProv,designationProv),
//                   initialValues: _formValues,
//                   isEditMode: _isEditMode,
//                   onFieldChanged: (k, v) => _formValues[k] = v,
//                   onSave: _onSave,
//                   onCancel: _resetForm,
//                   onDelete: _isEditMode ? _onDelete : null,
//                 ),
//               ),
//
//               const SizedBox(width: 12),
//
//               /// TABLE
//               Expanded(
//                 flex: 2,
//                 child: ErpDataTable(
//                   token: token ?? '',
//                   url: baseUrl,
//                   title: 'EMPLOYEE LIST',
//                   columns: _tableColumns,
//                   data: provider.tableData,
//                   selectedRow: _selectedRow,
//                   onRowTap: _onRowTap,
//                   emptyMessage:
//                   provider.isLoaded ? 'No Employee found' : 'Loading...', isReportRow: false,
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
// lib/screens/mst_employee.dart

import 'package:collection/collection.dart';
import 'package:diam_mfg/models/employee_model.dart';
import 'package:diam_mfg/providers/counter_provider.dart';
import 'package:diam_mfg/providers/dept_provider.dart';
import 'package:diam_mfg/providers/dept_process_provider.dart';
import 'package:diam_mfg/providers/designation_provider.dart';
import 'package:diam_mfg/providers/employee_dept_det_provider.dart';
import 'package:diam_mfg/providers/employee_manager_det_provider.dart';
import 'package:diam_mfg/providers/employee_provider.dart';
import 'package:erp_data_table/erp_data_table.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rs_dashboard/rs_dashboard.dart';

import '../bootstrap.dart';
import '../providers/company_provider.dart';
import '../utils/app_images.dart';
import '../utils/delete_dialogue.dart';
import '../utils/msg_dialogue.dart';

class MstEmployee extends StatefulWidget {
  const MstEmployee({super.key});

  @override
  State<MstEmployee> createState() => _MstEmployeeState();
}

class _MstEmployeeState extends State<MstEmployee> {
  ErpThemeVariant _themeVariant = ErpThemeVariant.frost;
  ErpTheme get _theme => ErpTheme(_themeVariant);

  final GlobalKey<ErpFormState> _erpFormKey = GlobalKey<ErpFormState>();

  Map<String, dynamic>? _selectedRow;
  bool _isEditMode = false;
  bool _isSaving   = false;
  Map<String, String> _formValues = {};

  int? _savedEmployeeCode;

  // ── ALLOW MANAGER: { crId: Set<deptProcessCode> }
  // Dept checkboxes LEFT → filter jo depts selected hain unke managers RIGHT mein
  // Manager check → sari processes check
  // "Select Dept Rights" ka alag section NAHI — sirf Allow Manager mein
  // LEFT mein dept checkbox = filter + select all managers of that dept
  // RIGHT mein managers default expanded

  // LEFT panel: selected dept codes (filter + select-all ke liye)
  Set<int> _selectedDeptIds = {};

  // Manager rights: { crId → Set<processCode> }
  Map<int, Set<int>> _managerSelected = {};

  // Collapsed counters (by default ALL expanded, toh yahan sirf collapsed ones store karo)
  Set<int> _collapsedCounters = {};

  final String? token = AppStorage.getString("token");

  List<ErpColumnConfig> get _tableColumns => [
    ErpColumnConfig(key: 'employeeCode', label: 'CODE',   width: 100),
    ErpColumnConfig(key: 'employeeName', label: 'NAME',   width: 200),
    ErpColumnConfig(key: 'mobile',       label: 'MOBILE', width: 140),
    ErpColumnConfig(key: 'department',   label: 'DEPT',   width: 140),
    ErpColumnConfig(key: 'salary',       label: 'SALARY', width: 110),
    ErpColumnConfig(key: 'active',       label: 'ACTIVE', width: 90, align: ColumnAlign.center),
  ];

  List<List<ErpFieldConfig>> _formRows(DeptProvider deptP, DesignationProvider desigP) => [
    [
      ErpFieldConfig(key: 'employeeName', label: 'EMPLOYEE NAME', required: true, flex: 3, sectionTitle: 'BASIC INFORMATION', sectionIndex: 0),
      ErpFieldConfig(key: 'aliasName',    label: 'ALIAS NAME',    flex: 2, sectionIndex: 0),
    ],
    [
      ErpFieldConfig(
        key: 'deptCode', label: 'DEPARTMENT',
        type: ErpFieldType.dropdown,
        dropdownItems: deptP.list.where((e) => e.active == true)
            .map((e) => ErpDropdownItem(label: e.deptName ?? '', value: e.deptCode.toString())).toList(),
        flex: 1, sectionIndex: 0,
      ),
      ErpFieldConfig(
        key: 'designationCode', label: 'DESIGNATION',
        type: ErpFieldType.dropdown,
        dropdownItems: desigP.list.where((e) => e.active == true)
            .map((e) => ErpDropdownItem(label: e.designationName ?? '', value: e.designationCode.toString())).toList(),
        flex: 1, sectionIndex: 0,
      ),
    ],
    [
      ErpFieldConfig(key: 'address', label: 'ADDRESS', maxLines: 2, flex: 4, sectionTitle: 'CONTACT DETAILS', sectionIndex: 1),
    ],
    [
      ErpFieldConfig(key: 'phone1', label: 'PHONE 1', flex: 1, sectionIndex: 1, type: ErpFieldType.phone),
      ErpFieldConfig(key: 'phone2', label: 'PHONE 2', flex: 1, sectionIndex: 1, type: ErpFieldType.phone),
      ErpFieldConfig(key: 'phone3', label: 'PHONE 3', flex: 1, sectionIndex: 1, type: ErpFieldType.phone),
    ],
    [
      ErpFieldConfig(key: 'mob1',   label: 'MOBILE 1', flex: 1, sectionIndex: 1, type: ErpFieldType.phone),
      ErpFieldConfig(key: 'mob2',   label: 'MOBILE 2', flex: 1, sectionIndex: 1, type: ErpFieldType.phone),
      ErpFieldConfig(key: 'mob3',   label: 'MOBILE 3', flex: 1, sectionIndex: 1, type: ErpFieldType.phone),
      ErpFieldConfig(key: 'email1', label: 'EMAIL',    flex: 1, sectionIndex: 1),
    ],
    [
      ErpFieldConfig(
        key: 'salaryType', label: 'SALARY TYPE',
        type: ErpFieldType.dropdown,
        sectionTitle: 'SALARY DETAILS', sectionIndex: 2,
        initialDropValue: true,
        dropdownItems: const [
          ErpDropdownItem(label: 'FIX',     value: 'FIX'),
          ErpDropdownItem(label: 'WORKING', value: 'WORKING'),
        ],
      ),
      ErpFieldConfig(key: 'salary', label: 'SALARY', type: ErpFieldType.number, sectionIndex: 2),
    ],
    [
      ErpFieldConfig(key: 'active', label: 'ACTIVE', type: ErpFieldType.checkbox, flex: 1, initialBoolValue: true, checkboxDbType: 'BIT'),
    ],
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.wait([
        context.read<EmployeeProvider>().loadEmployees(),
        context.read<DesignationProvider>().load(),
        context.read<DeptProvider>().load(),
        context.read<CounterProvider>().load(),
        context.read<DeptProcessProvider>().load(),
        context.read<EmployeeDeptDetProvider>().load(),
        context.read<EmployeeManagerDetProvider>().load(),
      ]);
      final code = context.read<CompanyProvider>().selectedCompanyCode;
      context.read<EmployeeProvider>().setSelectedCompany(code);
    });
  }

  Future<void> _loadRights(int empCode) async {
    final deptDetP = context.read<EmployeeDeptDetProvider>();
    final mgP      = context.read<EmployeeManagerDetProvider>();
    setState(() {
      // Dept selections
      _selectedDeptIds = deptDetP.list
          .where((r) => r.employeeCode == empCode && r.deptCode != null)
          .map((r) => r.deptCode!).toSet();

      // Manager selections
      final map = <int, Set<int>>{};
      for (final r in mgP.list.where((r) => r.employeeCode == empCode)) {
        if (r.crId == null) continue;
        map.putIfAbsent(r.crId!, () => {});
        if (r.deptProcessCode != null) map[r.crId!]!.add(r.deptProcessCode!);
      }
      _managerSelected   = map;
      _collapsedCounters = {}; // default: all expanded
    });
  }

  Future<void> _onRowTap(Map<String, dynamic> row) async {
    final raw = row['_raw'] as EmployeeModel;
    setState(() {
      _selectedRow       = row;
      _isEditMode        = true;
      _savedEmployeeCode = raw.employeeCode;
      _selectedDeptIds   = {};
      _managerSelected   = {};
      _collapsedCounters = {};
      _formValues = {
        'employeeCode':    raw.employeeCode?.toString() ?? '',
        'employeeName':    raw.employeeName ?? '',
        'aliasName':       raw.aliasName ?? '',
        'address':         raw.address ?? '',
        'phone1':          raw.phone1 ?? '',
        'phone2':          raw.phone2 ?? '',
        'phone3':          raw.phone3 ?? '',
        'mob1':            raw.mob1 ?? '',
        'mob2':            raw.mob2 ?? '',
        'mob3':            raw.mob3 ?? '',
        'email1':          raw.email1 ?? '',
        'deptCode':        raw.deptCode?.toString() ?? '',
        'designationCode': raw.designationCode?.toString() ?? '',
        'salaryType':      raw.salaryType ?? '',
        'salary':          raw.salary?.toString() ?? '',
        'active':          raw.active == true ? 'true' : 'false',
      };
    });
    if (raw.employeeCode != null) await _loadRights(raw.employeeCode!);
  }

  // ── SINGLE SAVE ───────────────────────────────────────────────────────────
  // Future<void> _onSave(Map<String, dynamic> values) async {
  //   setState(() => _isSaving = true);
  //
  //   final empProv  = context.read<EmployeeProvider>();
  //   final deptDetP = context.read<EmployeeDeptDetProvider>();
  //   final mgP      = context.read<EmployeeManagerDetProvider>();
  //   final procProv = context.read<DeptProcessProvider>();
  //
  //   // 1. Employee
  //   bool empSuccess;
  //   int? empCode;
  //   if (_isEditMode && _selectedRow != null) {
  //     final raw  = _selectedRow!['_raw'] as EmployeeModel;
  //     empSuccess = await empProv.updateEmployee(raw.employeeCode!, values);
  //     empCode    = raw.employeeCode;
  //   } else {
  //     empSuccess = await empProv.createEmployee(values);
  //     if (empSuccess && empProv.list.isNotEmpty) empCode = empProv.list.first.employeeCode;
  //   }
  //
  //   if (!empSuccess || empCode == null || !mounted) {
  //     setState(() => _isSaving = false);
  //     return;
  //   }
  //   setState(() { _savedEmployeeCode = empCode; _isEditMode = true; });
  //
  //   // 2. Dept rights
  //   for (final r in deptDetP.list.where((r) => r.employeeCode == empCode).toList()) {
  //     if (r.employeeDeptDetID != null) await deptDetP.delete(r.employeeDeptDetID!);
  //   }
  //   for (final dc in _selectedDeptIds) {
  //     await deptDetP.create({'employeeCode': empCode.toString(), 'deptCode': dc.toString()});
  //   }
  //
  //   // 3. Manager rights
  //   for (final r in mgP.list.where((r) => r.employeeCode == empCode).toList()) {
  //     if (r.employeeManagerDetID != null) await mgP.delete(r.employeeManagerDetID!);
  //   }
  //   for (final entry in _managerSelected.entries) {
  //     final crId = entry.key;
  //     for (final procCode in entry.value) {
  //       final proc = procProv.list.firstWhereOrNull((p) => p.deptProcessCode == procCode);
  //       await mgP.create({
  //         'employeeCode':    empCode.toString(),
  //         'crId':            crId.toString(),
  //         'deptProcessCode': procCode.toString(),
  //         'deptCode':        (proc?.deptCode ?? 0).toString(),
  //       });
  //     }
  //   }
  //
  //   if (!mounted) return;
  //   setState(() => _isSaving = false);
  //   await ErpResultDialog.showSuccess(
  //     context: context, theme: _theme,
  //     title:   _isEditMode ? 'Updated' : 'Saved',
  //     message: 'Employee saved successfully.',
  //   );
  // }
// ❌ CURRENT mein success dialog ke baad return nahi hota properly
// ✅ FIX — `wasEdit` pehle capture karo, dialog LAST mein aaye

  Future<void> _onSave(Map<String, dynamic> values) async {
    setState(() => _isSaving = true);

    final empProv  = context.read<EmployeeProvider>();
    final deptDetP = context.read<EmployeeDeptDetProvider>();
    final mgP      = context.read<EmployeeManagerDetProvider>();
    final procProv = context.read<DeptProcessProvider>();

    final wasEdit = _isEditMode;  // ← pehle capture karo

    // 1. Employee
    bool empSuccess;
    int? empCode;
    if (_isEditMode && _selectedRow != null) {
      final raw  = _selectedRow!['_raw'] as EmployeeModel;
      empSuccess = await empProv.updateEmployee(raw.employeeCode!, values);
      empCode    = raw.employeeCode;
    } else {
      empSuccess = await empProv.createEmployee(values);
      if (empSuccess && empProv.list.isNotEmpty) empCode = empProv.list.first.employeeCode;
    }

    if (!empSuccess || empCode == null || !mounted) {
      setState(() => _isSaving = false);
      return;
    }
    setState(() { _savedEmployeeCode = empCode; });

    // 2. Dept rights
    for (final r in deptDetP.list.where((r) => r.employeeCode == empCode).toList()) {
      if (r.employeeDeptDetID != null) await deptDetP.delete(r.employeeDeptDetID!);
    }
    for (final dc in _selectedDeptIds) {
      await deptDetP.create({'employeeCode': empCode.toString(), 'deptCode': dc.toString()});
    }

    // 3. Manager rights
    for (final r in mgP.list.where((r) => r.employeeCode == empCode).toList()) {
      if (r.employeeManagerDetID != null) await mgP.delete(r.employeeManagerDetID!);
    }
    for (final entry in _managerSelected.entries) {
      final crId = entry.key;
      for (final procCode in entry.value) {
        final proc = procProv.list.firstWhereOrNull((p) => p.deptProcessCode == procCode);
        await mgP.create({
          'employeeCode':    empCode.toString(),
          'crId':            crId.toString(),
          'deptProcessCode': procCode.toString(),
          'deptCode':        (proc?.deptCode ?? 0).toString(),
        });
      }
    }

    if (!mounted) return;
    setState(() => _isSaving = false);
    await ErpResultDialog.showSuccess(
      context: context, theme: _theme,
      title:   wasEdit ? 'Updated' : 'Saved',
      message: 'Employee saved successfully.',
    );
    if (mounted) _resetForm();  // ← ADD THIS
  }
  Future<void> _onDelete() async {
    final raw = _selectedRow?['_raw'] as EmployeeModel?;
    if (raw == null) return;
    final confirm = await ErpDeleteDialog.show(
      context: context, theme: _theme, title: 'Employee', itemName: raw.employeeName ?? '',
    );
    if (confirm != true) return;
    setState(() => _isSaving = true);
    final deptDetP = context.read<EmployeeDeptDetProvider>();
    final mgP      = context.read<EmployeeManagerDetProvider>();
    if (raw.employeeCode != null) {
      for (final r in deptDetP.list.where((r) => r.employeeCode == raw.employeeCode).toList()) {
        if (r.employeeDeptDetID != null) await deptDetP.delete(r.employeeDeptDetID!);
      }
      for (final r in mgP.list.where((r) => r.employeeCode == raw.employeeCode).toList()) {
        if (r.employeeManagerDetID != null) await mgP.delete(r.employeeManagerDetID!);
      }
    }
    final success = await context.read<EmployeeProvider>().deleteEmployee(raw.employeeCode!);
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (success) {
      _resetForm();
      await ErpResultDialog.showDeleted(context: context, theme: _theme, itemName: raw.employeeName ?? '');
    }
  }

  void _resetForm() {
    setState(() {
      _selectedRow       = null;
      _isEditMode        = false;
      _formValues        = {};
      _savedEmployeeCode = null;
      _selectedDeptIds   = {};
      _managerSelected   = {};
      _collapsedCounters = {};
    });
    _erpFormKey.currentState?.resetForm();
  }

  @override
  Widget build(BuildContext context) {
    final desigP = context.read<DesignationProvider>();
    final deptP  = context.read<DeptProvider>();

    return Stack(
      children: [
        Consumer<EmployeeProvider>(
          builder: (context, empProv, _) => Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: ErpForm(
                    logo:          AppImages.logo,
                    key:           _erpFormKey,
                    title:         'EMPLOYEE MASTER',
                    rows:          _formRows(deptP, desigP),
                    initialValues: _formValues,
                    isEditMode:    _isEditMode,
                    onFieldChanged: (k, v) => _formValues[k] = v,
                    onSave:   _onSave,
                    onCancel: _resetForm,
                    onDelete: _isEditMode ? _onDelete : null,
                    detailBuilder: (ctx) {
                      final theme   = ctx.erpTheme;
                      final enabled = true;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildAllowManagerSection(theme, enabled),
                          const SizedBox(height: 8),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ErpDataTable(
                    token: token ?? '', url: baseUrl,
                    title: 'EMPLOYEE LIST',
                    columns: _tableColumns,
                    data:    empProv.tableData,
                    selectedRow: _selectedRow,
                    onRowTap:    _onRowTap,
                    emptyMessage: empProv.isLoaded ? 'No Employee found' : 'Loading...',
                    isReportRow: false,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isSaving)
          Container(
            color: Colors.black.withOpacity(0.4),
            child: Center(child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 12)],
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Image.asset(AppImages.logo, height: 60),
                const SizedBox(height: 16),
                CircularProgressIndicator(color: _theme.primary),
                const SizedBox(height: 12),
                Text('Saving...', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _theme.primary)),
              ]),
            )),
          ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  ALLOW MANAGER & PROCESS
  //  LEFT:  Dept checkboxes — multiple select
  //         check dept → uske sare managers + processes selected
  //  RIGHT: Jo depts selected hain unke managers (default expanded)
  //         Manager checkbox → sari processes
  //         Process individual checkbox
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildAllowManagerSection(ErpTheme theme, bool enabled) {
    return Consumer2<CounterProvider, DeptProcessProvider>(
      builder: (context, counterP, procP, _) {
        final deptP    = context.read<DeptProvider>();
        final allDepts = List.of(deptP.list)
          ..sort((a, b) => (a.sortID ?? 0).compareTo(b.sortID ?? 0));
        final visibleDepts = _selectedDeptIds.isEmpty
            ? <dynamic>[]
            : allDepts.where((d) => _selectedDeptIds.contains(d.deptCode ?? 0)).toList();
        // RIGHT panel: show managers of selected depts only
        // // If nothing selected → show all
        // final visibleDepts = _selectedDeptIds.isEmpty
        //     ? allDepts
        //     : allDepts.where((d) => _selectedDeptIds.contains(d.deptCode ?? 0)).toList();

        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _sectionHeader(theme, 'ALLOW MANAGER & PROCESS'),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: theme.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ──────────────────────────────────────────────────────────
                //  LEFT: Department checkboxes
                // ──────────────────────────────────────────────────────────
                SizedBox(
                  width: 165,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.bg,
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(10)),
                          border: Border(
                            bottom: BorderSide(color: theme.border),
                            right:  BorderSide(color: theme.border),
                          ),
                        ),
                        child: Row(children: [
                          Icon(Icons.business_rounded, size: 11, color: theme.primary),
                          const SizedBox(width: 5),
                          Text('Department',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: theme.primary)),
                          const Spacer(),
                          // Select All checkbox
                          SizedBox(width: 16, height: 16, child: Checkbox(
                            activeColor: theme.primary,
                            visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            tristate: true,
                            value: () {
                              if (_selectedDeptIds.isEmpty) return false;
                              if (_selectedDeptIds.length == allDepts.length) return true;
                              return null;
                            }(),
                            onChanged: enabled ? (v) => setState(() {
                              if (v == true) {
                                // Select all depts + all their managers
                                for (final d in allDepts) {
                                  final dc = d.deptCode ?? 0;
                                  _selectedDeptIds.add(dc);
                                  _selectAllManagersOfDept(dc, counterP, procP);
                                }
                              } else {
                                _selectedDeptIds.clear();
                                _managerSelected.clear();
                              }
                            }) : null,
                          )),
                        ]),
                      ),

                      // Dept list with checkboxes
                      ...allDepts.asMap().entries.map((entry) {
                        final i       = entry.key;
                        final dept    = entry.value;
                        final code    = dept.deptCode ?? 0;
                        final checked = _selectedDeptIds.contains(code);

                        // Tristate: check karo agar is dept ke sare managers selected hain
                        final deptCounters = counterP.list
                            .where((c) => c.deptCode == code && c.active == true)
                            .toList();
                        final deptProcs = <MapEntry<int, int>>[];
                        for (final c in deptCounters) {
                          final cProcs = procP.list.where((p) => p.deptCode == c.deptCode);
                          for (final p in cProcs) {
                            deptProcs.add(MapEntry(c.crId ?? 0, p.deptProcessCode ?? 0));
                          }
                        }
                        final allSel = deptProcs.isNotEmpty &&
                            deptProcs.every((e) => _managerSelected[e.key]?.contains(e.value) ?? false);
                        final anySel = deptProcs.any((e) => _managerSelected[e.key]?.contains(e.value) ?? false);
                        final triVal = allSel ? true : anySel ? null : false;

                        return InkWell(
                          onTap: enabled ? () => setState(() {
                            if (checked) {
                              _selectedDeptIds.remove(code);
                              // Deselect all managers of this dept
                              for (final c in deptCounters) {
                                _managerSelected.remove(c.crId ?? 0);
                              }
                            } else {
                              _selectedDeptIds.add(code);
                              _selectAllManagersOfDept(code, counterP, procP);
                            }
                          }) : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                            decoration: BoxDecoration(
                              color: checked
                                  ? theme.primary.withOpacity(0.08)
                                  : i.isEven ? Colors.white : theme.bg.withOpacity(0.4),
                              border: Border(
                                top:   BorderSide(color: theme.border.withOpacity(0.5)),
                                right: BorderSide(color: theme.border),
                                left:  checked
                                    ? BorderSide(color: theme.primary, width: 3)
                                    : const BorderSide(color: Colors.transparent, width: 3),
                              ),
                            ),
                            child: Row(children: [
                              SizedBox(width: 16, height: 20, child: Checkbox(
                                value: triVal,
                                tristate: true,
                                activeColor: theme.primary,
                                onChanged: enabled ? (v) => setState(() {
                                  if (!checked || v == true) {
                                    _selectedDeptIds.add(code);
                                    _selectAllManagersOfDept(code, counterP, procP);
                                  } else {
                                    _selectedDeptIds.remove(code);
                                    for (final c in deptCounters) {
                                      _managerSelected.remove(c.crId ?? 0);
                                    }
                                  }
                                }) : null,
                                visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              )),
                              const SizedBox(width: 5),
                              Expanded(child: Text(dept.deptName ?? '',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: !enabled ? theme.textLight : checked ? theme.primary : theme.text,
                                    fontWeight: checked ? FontWeight.w700 : FontWeight.normal,
                                  ),
                                  overflow: TextOverflow.ellipsis, maxLines: 1)),
                              // Badge: how many managers selected
                              if (anySel)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: theme.primary, borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${deptCounters.where((c) => _managerSelected.containsKey(c.crId ?? 0)).length}',
                                    style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.w700),
                                  ),
                                ),
                            ]),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),

                // ──────────────────────────────────────────────────────────
                //  RIGHT: Manager → Process (default expanded)
                // ──────────────────────────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.bg,
                          borderRadius: const BorderRadius.only(topRight: Radius.circular(10)),
                          border: Border(bottom: BorderSide(color: theme.border)),
                        ),
                        child: Row(children: [
                          Icon(Icons.manage_accounts_rounded, size: 11, color: theme.primary),
                          const SizedBox(width: 5),
                          Text('Select Manager And Process',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: theme.primary)),
                        ]),
                      ),

                      // No dept selected message
                      if (visibleDepts.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text('Select a department from the left to view managers.',
                              style: TextStyle(fontSize: 11, color: theme.textLight),
                              textAlign: TextAlign.center),
                        ),

                      // Manager + Process tree
                      ...visibleDepts.expand((dept) {
                        final deptCode     = dept.deptCode ?? 0;
                        final deptCounters = counterP.list
                            .where((c) => c.deptCode == deptCode && c.active == true)
                            .toList();
                        if (deptCounters.isEmpty) return <Widget>[];

                        return deptCounters.map((counter) {
                          final crId          = counter.crId ?? 0;
                          final isExpanded    = !_collapsedCounters.contains(crId); // default expanded
                          final selectedProcs = _managerSelected[crId] ?? const <int>{};
                          final counterProcs  = procP.list
                              .where((p) => p.deptCode == counter.deptCode)
                              .toList();

                          final allSel = counterProcs.isNotEmpty &&
                              counterProcs.every((p) => selectedProcs.contains(p.deptProcessCode ?? 0));
                          final anySel = counterProcs.any((p) => selectedProcs.contains(p.deptProcessCode ?? 0));

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // ── MANAGER ROW ──
                              InkWell(
                                onTap: () => setState(() {
                                  if (isExpanded) _collapsedCounters.add(crId);
                                  else            _collapsedCounters.remove(crId);
                                }),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: isExpanded
                                        ? theme.primary.withOpacity(0.06)
                                        : theme.bg.withOpacity(0.5),
                                    border: Border(top: BorderSide(color: theme.border.withOpacity(0.5))),
                                  ),
                                  child: Row(children: [
                                    // Manager tristate checkbox
                                    SizedBox(width: 18, height: 20, child: Checkbox(
                                      activeColor: theme.primary,
                                      visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      tristate: true,
                                      value: allSel ? true : anySel ? null : false,
                                      onChanged: enabled ? (v) => setState(() {
                                        final set = _managerSelected.putIfAbsent(crId, () => {});
                                        if (v == true) {
                                          set.addAll(counterProcs.map((p) => p.deptProcessCode ?? 0));
                                        } else {
                                          _managerSelected.remove(crId);
                                        }
                                      }) : null,
                                    )),
                                    const SizedBox(width: 4),
                                    // Expand/collapse arrow
                                    AnimatedRotation(
                                      turns: isExpanded ? 0 : -0.25,
                                      duration: const Duration(milliseconds: 150),
                                      child: Icon(Icons.keyboard_arrow_down_rounded,
                                          size: 14, color: theme.primary.withOpacity(0.7)),
                                    ),
                                    const SizedBox(width: 5),
                                    Icon(Icons.person_outline_rounded, size: 12, color: theme.primary),
                                    const SizedBox(width: 5),
                                    Expanded(child: Text(
                                      'Manager: ${counter.crName ?? ''}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: anySel ? theme.primary : theme.text,
                                        fontWeight: anySel ? FontWeight.w700 : FontWeight.normal,
                                      ),
                                      overflow: TextOverflow.ellipsis, maxLines: 1,
                                    )),
                                    if (anySel)
                                      Text('${selectedProcs.length}/${counterProcs.length}',
                                          style: TextStyle(fontSize: 9, color: theme.primary)),
                                  ]),
                                ),
                              ),

                              // ── PROCESSES (visible when expanded) ──
                              if (isExpanded)
                                ...counterProcs.map((proc) {
                                  final procCode  = proc.deptProcessCode ?? 0;
                                  final isChecked = selectedProcs.contains(procCode);
                                  return InkWell(
                                    onTap: enabled ? () => setState(() {
                                      final set = _managerSelected.putIfAbsent(crId, () => {});
                                      if (isChecked) { set.remove(procCode); } else { set.add(procCode); }
                                      if (set.isEmpty) _managerSelected.remove(crId);
                                    }) : null,
                                    child: Container(
                                      padding: const EdgeInsets.only(left: 36, right: 8, top: 3, bottom: 3),
                                      decoration: BoxDecoration(
                                        color: isChecked ? theme.primary.withOpacity(0.05) : Colors.white,
                                        border: Border(top: BorderSide(color: theme.border.withOpacity(0.25))),
                                      ),
                                      child: Row(children: [
                                        SizedBox(width: 16, height: 18, child: Checkbox(
                                          value: isChecked, activeColor: theme.primary,
                                          onChanged: enabled ? (v) => setState(() {
                                            final set = _managerSelected.putIfAbsent(crId, () => {});
                                            if (v == true) { set.add(procCode); } else { set.remove(procCode); }
                                            if (set.isEmpty) _managerSelected.remove(crId);
                                          }) : null,
                                          visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
                                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        )),
                                        const SizedBox(width: 6),
                                        Expanded(child: Text(proc.deptProcessName ?? '',
                                            style: TextStyle(fontSize: 10,
                                                color: isChecked ? theme.primary : theme.text,
                                                fontWeight: isChecked ? FontWeight.w600 : FontWeight.normal))),
                                      ]),
                                    ),
                                  );
                                }).toList(),
                            ],
                          );
                        }).toList();
                      }).toList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ]);
      },
    );
  }

  // ── Helper: select all managers + processes of a dept ──────────────────────
  void _selectAllManagersOfDept(int deptCode, CounterProvider counterP, DeptProcessProvider procP) {
    final counters = counterP.list.where((c) => c.deptCode == deptCode && c.active == true);
    for (final c in counters) {
      final crId = c.crId ?? 0;
      final procs = procP.list.where((p) => p.deptCode == c.deptCode).map((p) => p.deptProcessCode ?? 0);
      _managerSelected.putIfAbsent(crId, () => {}).addAll(procs);
    }
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
      child: Text(title, style: TextStyle(
          fontSize: 11, fontWeight: FontWeight.w700, color: theme.primary, letterSpacing: 0.8)),
    );
  }
}