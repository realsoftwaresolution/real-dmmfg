import 'package:diam_mfg/providers/dept_provider.dart';
import 'package:diam_mfg/providers/dept_group_provider.dart';
import 'package:diam_mfg/providers/company_provider.dart';
import 'package:erp_data_table/erp_data_table.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rs_dashboard/rs_dashboard.dart';

import '../bootstrap.dart';
import '../models/dept_model.dart';
import '../utils/app_images.dart';
import '../utils/delete_dialogue.dart';
import '../utils/msg_dialogue.dart';

class MstDept extends StatefulWidget {
  const MstDept({super.key});

  @override
  State<MstDept> createState() => _MstDeptState();
}

class _MstDeptState extends State<MstDept> {
  // ── Theme ─────────────────────────────────────────────────────────────────
  ErpThemeVariant _themeVariant = ErpThemeVariant.frost;
  ErpTheme get _theme => ErpTheme(_themeVariant);

  // ── State ─────────────────────────────────────────────────────────────────
  final GlobalKey<ErpFormState> _erpFormKey = GlobalKey<ErpFormState>();
  Map<String, dynamic>? _selectedRow;
  bool _isEditMode = false;
  Map<String, String> _formValues = {};

  final String? token = AppStorage.getString("token");

  // ── TABLE COLUMNS ─────────────────────────────────────────────────────────
  List<ErpColumnConfig> get _tableColumns => [
    ErpColumnConfig(key: 'deptCode', label: 'CODE', width: 130),
    ErpColumnConfig(key: 'deptName', label: 'NAME', width: 200),
    ErpColumnConfig(key: 'deptGroupCode', label: 'GROUP', width: 160),
    ErpColumnConfig(key: 'companyCode', label: 'COMPANY', width: 160),
    ErpColumnConfig(key: 'sortID', label: 'SORT ID', width: 160),
    ErpColumnConfig(key: 'active', label: 'ACTIVE', width: 140),
  ];

  // ── FORM ROWS ─────────────────────────────────────────────────────────────
  List<List<ErpFieldConfig>> _formRows(
      CompanyProvider companyProvider,
      DeptGroupProvider deptGroupProvider,
      ) =>
      [
        /// ── SECTION 0: BASIC INFORMATION ──
        // [
        //   // ErpFieldConfig(
        //   //   key: 'deptCode',
        //   //   label: 'CODE',
        //   //   type: ErpFieldType.number,
        //   //   required: true,
        //   //   sectionTitle: 'BASIC INFORMATION',
        //   //   sectionIndex: 0,
        //   // ),
        //   ErpFieldConfig(
        //     key: 'deptName',
        //     label: 'NAME',
        //     required: true,
        //     sectionIndex: 0,
        //   ),
        // ],
        [
          ErpFieldConfig(
            key: 'deptName',
            label: 'NAME',
            required: true,
            sectionIndex: 0,
          ),
          ErpFieldConfig(
            key: 'deptGroupCode',
            label: 'DEPT GROUP',
            type: ErpFieldType.dropdown,
            initialDropValue: true,
            required: true,
            dropdownItems: deptGroupProvider.list
                .where((element) {
              return element.active==true;
            },).map((e) {
              return ErpDropdownItem(
                label: e.deptGroupName ?? '',
                value: e.deptGroupCode?.toString() ?? '',
              );
            }).toList(),
            sectionIndex: 0,
          ),
          ErpFieldConfig(
            key: 'sortID',
            label: 'SORT ID',
            type: ErpFieldType.number,
            sectionIndex: 0,
          ),
          // ErpFieldConfig(
          //   key: 'companyCode',
          //   label: 'COMPANY',
          //   type: ErpFieldType.dropdown,
          //   dropdownItems: companyProvider.companies
          //       .where((element) {
          //     return element.active==true;
          //   },).map((e) {
          //     return ErpDropdownItem(
          //       label: e.companyName ?? '',
          //       value: e.companyCode?.toString() ?? '',
          //     );
          //   }).toList(),
          //   sectionIndex: 0,
          // ),
        ],
        [

          ErpFieldConfig(
            key: 'salaryDeptName',
            label: 'SALARY DEPT NAME',
            sectionIndex: 0,
          ),
          ErpFieldConfig(
            key: 'rateSizeOn',
            label: 'RATE SIZE ON',
            sectionIndex: 1,
          ),
        ],

        /// ── SECTION 1: DISPLAY & RATE ──
        // [
        //   ErpFieldConfig(
        //     key: 'displayStock',
        //     label: 'DISPLAY STOCK',
        //     sectionTitle: 'DISPLAY & RATE',
        //     sectionIndex: 1,
        //   ),
        //   ErpFieldConfig(
        //     key: 'displayWt',
        //     label: 'DISPLAY WT',
        //     sectionIndex: 1,
        //   ),
        // ],
        // [
        //   ErpFieldConfig(
        //     key: 'rptDisp',
        //     label: 'RPT DISP',
        //     sectionIndex: 1,
        //   ),
        //   ErpFieldConfig(
        //     key: 'dashboardRpt',
        //     label: 'DASHBOARD RPT',
        //     sectionIndex: 1,
        //   ),
        // ],
        // [
        //   ErpFieldConfig(
        //     key: 'rateSizeOn',
        //     label: 'RATE SIZE ON',
        //     sectionIndex: 1,
        //   ),
        //   // ErpFieldConfig(
        //   //   key: 'wtLossCheckWith',
        //   //   label: 'WT LOSS CHECK WITH',
        //   //   sectionIndex: 1,
        //   // ),
        // ],
        [
          // ErpFieldConfig(
          //   key: 'checkCharniSize',
          //   label: 'CHECK CHARNI SIZE',
          //   sectionIndex: 1,
          // ),
          ErpFieldConfig(
            key: 'rateOnJanCharni',
            label: 'RATE ON JAN CHARNI',
            type: ErpFieldType.checkbox,
            checkboxDbType: 'YN',
            sectionIndex: 1,
          ),
          ErpFieldConfig(
            key: 'managerRate',
            label: 'MANAGER RATE',
            type: ErpFieldType.checkbox,
            checkboxDbType: 'YN',
            sectionIndex: 2,

          ),
        ],
        [
          ErpFieldConfig(
            key: 'rateOnCutMan',
            label: 'RATE ON CUT MAN',
            type: ErpFieldType.checkbox,
            checkboxDbType: 'YN',
            sectionIndex: 1,
          ),
          ErpFieldConfig(
            key: 'rateOnRgType',
            label: 'RATE ON RG TYPE',
            type: ErpFieldType.checkbox,
            checkboxDbType: 'YN',
            sectionIndex: 1,
          ),
        ],
        [
          ErpFieldConfig(
            key: 'rateOnTension',
            label: 'RATE ON TENSION',
            type: ErpFieldType.checkbox,
            checkboxDbType: 'YN',
            sectionIndex: 1,
          ),
          ErpFieldConfig(
            key: 'rateOnLSPie',
            label: 'RATE ON LS PIE',
            type: ErpFieldType.checkbox,
            checkboxDbType: 'YN',
            sectionIndex: 1,
          ),
        ],

        /// ── SECTION 2: FLAGS (Y/N) ──
        // [
        //   ErpFieldConfig(
        //     key: 'rateCalc',
        //     label: 'RATE CALC',
        //     type: ErpFieldType.checkbox,
        //     sectionTitle: 'FLAGS',
        //     sectionIndex: 2,
        //       checkboxDbType: 'YN'
        //
        //   ),
        //   ErpFieldConfig(
        //     key: 'cutwiseIss',
        //     label: 'CUTWISE ISS',
        //     type: ErpFieldType.checkbox,
        //     sectionIndex: 2,
        //       checkboxDbType: 'YN'
        //
        //   ),
        // ],
        // [
        //   ErpFieldConfig(
        //     key: 'kbMinus',
        //     label: 'KB MINUS',
        //     type: ErpFieldType.checkbox,
        //     sectionIndex: 2,
        //       checkboxDbType: 'YN'
        //
        //   ),
        //   ErpFieldConfig(
        //     key: 'diaPcMinus',
        //     label: 'DIA PC MINUS',
        //     type: ErpFieldType.checkbox,
        //     sectionIndex: 2,
        //       checkboxDbType: 'BIT'
        //
        //   ),
        // ],
        // [
        //   ErpFieldConfig(
        //     key: 'checker',
        //     label: 'CHECKER',
        //     type: ErpFieldType.checkbox,
        //     sectionIndex: 2,
        //       checkboxDbType: 'YN'
        //
        //   ),
        //   ErpFieldConfig(
        //     key: 'topsLock',
        //     label: 'TOPS LOCK',
        //     type: ErpFieldType.checkbox,
        //     sectionIndex: 2,
        //       checkboxDbType: 'YN'
        //
        //   ),
        // ],
        // [
        //
        //   // ErpFieldConfig(
        //   //   key: 'issToTblMan',
        //   //   label: 'ISS TO TBL MAN',
        //   //   type: ErpFieldType.checkbox,
        //   //   sectionIndex: 2,
        //   //     checkboxDbType: 'YN'
        //   //
        //   // ),
        // ],
        // [
        //   ErpFieldConfig(
        //     key: 'mackCheck',
        //     label: 'MACK CHECK',
        //     type: ErpFieldType.checkbox,
        //     sectionIndex: 2,
        //       checkboxDbType: 'YN'
        //
        //   ),
        //   ErpFieldConfig(
        //     key: 'wtLossCheckWithRemarks',
        //     label: 'WT LOSS REMARKS',
        //     type: ErpFieldType.checkbox,
        //     sectionIndex: 2,
        //       checkboxDbType: 'YN'
        //
        //   ),
        // ],
        // [
        //   ErpFieldConfig(
        //     key: 'jnoCreate',
        //     label: 'JNO CREATE',
        //     type: ErpFieldType.checkbox,
        //     sectionIndex: 2,
        //       checkboxDbType: 'YN'
        //
        //   ),
        //   ErpFieldConfig(
        //     key: 'delRights',
        //     label: 'DEL RIGHTS',
        //       type: ErpFieldType.checkbox,
        //
        //       sectionIndex: 2,
        //       checkboxDbType: 'YN'
        //
        //   ),
        // ],

        /// ── SECTION 3: SETTINGS ──
        [
          ErpFieldConfig(
            key: 'active',
            label: 'ACTIVE',
            type: ErpFieldType.checkbox,
            sectionTitle: 'SETTINGS',
            sectionIndex: 3,
            initialBoolValue: true,
            checkboxDbType: 'BIT'
          ),
          // ErpFieldConfig(
          //   key: 'clvActive',
          //   label: 'CLV ACTIVE',
          //   type: ErpFieldType.checkbox,
          //   sectionIndex: 3,
          //     checkboxDbType: 'BIT'
          //
          // ),
        ],
      ];

  // // ── INIT ──────────────────────────────────────────────────────────────────
  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     context.read<DeptProvider>().load();
  //     context.read<CompanyProvider>().loadCompanies();
  //     context.read<DeptGroupProvider>().load();
  //   });
  // }
  void _setDefaultSortId() {
    final provider = context.read<DeptProvider>();

    int nextSortId = 1;
    if (provider.list.isNotEmpty) {
      nextSortId = provider.list
          .map((e) => e.sortID ?? 0)
          .reduce((a, b) => a > b ? a : b) + 1;
    }

    final value = nextSortId.toString();

    setState(() {
      _formValues['sortID'] = value;
      _formValues['active'] = 'true';
    });
    Future.delayed(const Duration(milliseconds: 50), () {
      _erpFormKey.currentState?.updateFieldValue('sortID', value);
      _erpFormKey.currentState?.updateFieldValue('active', 'true');
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {

      context.read<DeptGroupProvider>().load();

      await context.read<CompanyProvider>().loadCompanies();

      if (!mounted) return;

      final selectedCode = context.read<CompanyProvider>().selectedCompanyCode;
      context.read<DeptProvider>().setSelectedCompany(selectedCode);
      final companies = context.read<CompanyProvider>().companies;
      context.read<DeptProvider>().setCompanies(companies);


      await context.read<DeptProvider>().load();
      _setDefaultSortId();

    });
  }
  // ── ROW TAP ───────────────────────────────────────────────────────────────
  void _onRowTap(Map<String, dynamic> row) {
    final raw = row['_raw'] as DeptModel;

    setState(() {
      _selectedRow = row;
      _isEditMode = true;
      _formValues = {
        'deptCode': raw.deptCode?.toString() ?? '',
        'deptName': raw.deptName ?? '',
        'deptGroupCode': raw.deptGroupCode?.toString() ?? '',
        'companyCode': context.read<CompanyProvider>().selectedCompanyCode?.toString()
            ?? raw.companyCode?.toString() ?? '',
        'sortID': raw.sortID?.toString() ?? '',
        'salaryDeptName': raw.salaryDeptName ?? '',
        'active': raw.active == true ? 'true' : 'false',
        // 'delRights': raw.delRights ?? 'Y',
        'delRights': raw.delRights == 'Y' ? 'true' : 'false',

        'clvActive': raw.clvActive == true ? 'true' : 'false',
        'jnoCreate': raw.jnoCreate == 'Y' ? 'true' : 'false',
        'displayStock': raw.displayStock ?? '',
        'displayWt': raw.displayWt ?? '',
        'rateCalc': raw.rateCalc == 'Y' ? 'true' : 'false',
        'cutwiseIss': raw.cutwiseIss ?? 'N',
        'kbMinus': raw.kbMinus == 'Y' ? 'true' : 'false',
        'diaPcMinus': raw.diaPcMinus == true ? 'true' : 'false',
        'rptDisp': raw.rptDisp ?? '',
        'checker': raw.checker == 'Y' ? 'true' : 'false',
        'topsLock': raw.topsLock == 'Y' ? 'true' : 'false',
        'managerRate': raw.managerRate == 'Y' ? 'true' : 'false',
        'rateOnJanCharni': raw.rateOnJanCharni == 'Y' ? 'true' : 'false',
        'rateOnCutMan': raw.rateOnCutMan == 'Y' ? 'true' : 'false',
        'rateSizeOn': raw.rateSizeOn ?? 'ISSWT',
        'issToTblMan': raw.issToTblMan == 'Y' ? 'true' : 'false',
        'dashboardRpt': raw.dashboardRpt ?? 'CLEAVING',
        'mackCheck': raw.mackCheck == 'Y' ? 'true' : 'false',
        'rateOnRgType': raw.rateOnRgType == 'Y' ? 'true' : 'false',
        'rateOnTension': raw.rateOnTension == 'Y' ? 'true' : 'false',
        'wtLossCheckWith': raw.wtLossCheckWith ?? 'ISSWT',
        'wtLossCheckWithRemarks': raw.wtLossCheckWithRemarks == 'Y' ? 'true' : 'false',
        'rateOnLSPie': raw.rateOnLSPie == 'Y' ? 'true' : 'false',
        'checkCharniSize': raw.checkCharniSize ?? 'ISSWT',
      };
    });
    if (Responsive.isMobile(context)) {
      setState(() => _showTableOnMobile = false);
    }
  }

  // ── SAVE ──────────────────────────────────────────────────────────────────
  Future<void> _onSave(Map<String, dynamic> values) async {
    final provider = context.read<DeptProvider>();

    bool success;
    if (_isEditMode && _selectedRow != null) {
      final raw = _selectedRow!['_raw'] as DeptModel;
      success = await provider.update(raw.deptCode!, values);
    } else {
      success = await provider.create(values);
    }

    if (!mounted) return;

    if (success) {
      _resetForm();
      await ErpResultDialog.showSuccess(
        context: context,
        theme: _theme,
        title: _isEditMode ? 'Updated' : 'Saved',
        message: _isEditMode
            ? 'Department updated successfully.'
            : 'Department saved successfully.',
      );
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(_isEditMode
      //         ? 'Department updated successfully'
      //         : 'Department saved successfully'),
      //     backgroundColor: _theme.primary,
      //     behavior: SnackBarBehavior.floating,
      //     shape:
      //     RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      //     margin: const EdgeInsets.all(12),
      //   ),
      // );
    }
  }

  // ── DELETE ────────────────────────────────────────────────────────────────
  Future<void> _onDelete() async {
    final raw = _selectedRow?['_raw'] as DeptModel?;
    if (raw?.deptCode == null) return;
    final confirm = await ErpDeleteDialog.show(context: context, theme: _theme, title: 'Department', itemName: raw!.deptName??"");

    // final confirm = await showDialog<bool>(
    //   context: context,
    //   builder: (_) => AlertDialog(
    //     title: const Text('Delete Department'),
    //     content: Text('Delete "${raw!.deptName}"? This cannot be undone.'),
    //     actions: [
    //       TextButton(
    //         onPressed: () => Navigator.pop(context, false),
    //         child: const Text('Cancel'),
    //       ),
    //       TextButton(
    //         onPressed: () => Navigator.pop(context, true),
    //         child:
    //         const Text('Delete', style: TextStyle(color: Colors.red)),
    //       ),
    //     ],
    //   ),
    // );

    if (confirm != true || !mounted) return;

    final success =
    await context.read<DeptProvider>().delete(raw.deptCode!);

    if (success && mounted) {
      _resetForm();
      await ErpResultDialog.showDeleted(
        context: context,
        theme: _theme,
        itemName: raw.deptName ?? '',
      );
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: const Text('Department deleted successfully'),
      //     backgroundColor: Colors.red.shade600,
      //     behavior: SnackBarBehavior.floating,
      //     shape:
      //     RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      //     margin: const EdgeInsets.all(12),
      //   ),
      // );
    }
  }

  // ── RESET ─────────────────────────────────────────────────────────────────
  void _resetForm() {
    setState(() {
      _selectedRow = null;
      _isEditMode = false;
      _formValues = {};
      _showTableOnMobile=false;
    });
    _erpFormKey.currentState?.resetForm();
    _setDefaultSortId();
  }
  bool _showTableOnMobile = false;

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final companyProvider = context.watch<CompanyProvider>();
    final deptGroupProvider = context.watch<DeptGroupProvider>();

    return Consumer<DeptProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child:
              Responsive.isMobile(context)?_showTableOnMobile?ErpDataTable(
                isReportRow: false,

                token: token ?? '',
                url: baseUrl,
                title: 'DEPARTMENT LIST',
                columns: _tableColumns,
                data: provider.tableData,
                // theme: _theme,
                showSearch: true,
                showFooterTotals: false,
                selectedRow: _selectedRow,
                onRowTap: _onRowTap,
                emptyMessage: provider.isLoaded
        ? 'No Department found'
        : 'Loading...',
              ):ErpForm(
                onExit: () {
                  context.read<TabProvider>().closeCurrentTab();
                },
                logo: AppImages.logo,

                key: _erpFormKey,
                title: 'DEPARTMENT MASTER',
                subtitle: 'Department Information',
                initialTabIndex: 0,
                onSearch: () => setState(() => _showTableOnMobile = true),

                tabBarBackgroundColor: const Color(0xfff2f0ef),
                tabBarSelectedColor: _theme.primaryGradient.first,
                tabBarSelectedTxtColor: Colors.white,
                rows: _formRows(companyProvider, deptGroupProvider),
                // theme: _theme,
                initialValues: _formValues,
                isEditMode: _isEditMode,
                onFieldChanged: (key, value) {
                _formValues[key] = value;
                },
                onSave: _onSave,
                onCancel: _resetForm,
                onDelete: _isEditMode ? _onDelete : null,
              ):
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── LEFT: Form ────────────────────────────────────────
              Expanded(
                flex: 2,
                child: ErpForm(
                  onExit: () {
                    context.read<TabProvider>().closeCurrentTab();
                  },
                  logo: AppImages.logo,

                  key: _erpFormKey,
                  title: 'DEPARTMENT MASTER',
                  subtitle: 'Department Information',
                  initialTabIndex: 0,
                  tabBarBackgroundColor: const Color(0xfff2f0ef),
                  tabBarSelectedColor: _theme.primaryGradient.first,
                  tabBarSelectedTxtColor: Colors.white,
                  rows: _formRows(companyProvider, deptGroupProvider),
                  // theme: _theme,
                  initialValues: _formValues,
                  isEditMode: _isEditMode,
                  onFieldChanged: (key, value) {
                    _formValues[key] = value;
                  },
                  onSave: _onSave,
                  onCancel: _resetForm,
                  onDelete: _isEditMode ? _onDelete : null,
                ),
              ),

              const SizedBox(width: 12),

              // ── RIGHT: Table ──────────────────────────────────────
              Expanded(
                flex: 2,
                child: ErpDataTable(
                  isReportRow: false,

                  token: token ?? '',
                  url: baseUrl,
                  title: 'DEPARTMENT LIST',
                  columns: _tableColumns,
                  data: provider.tableData,
                  // theme: _theme,
                  showSearch: true,
                  showFooterTotals: false,
                  selectedRow: _selectedRow,
                  onRowTap: _onRowTap,
                  emptyMessage: provider.isLoaded
                      ? 'No Department found'
                      : 'Loading...',
                ),
              ),
            ],
          ),
        );
      },
    );
  }


}