import 'package:diam_mfg/providers/dept_process_provider.dart';
import 'package:diam_mfg/providers/dept_provider.dart';
import 'package:diam_mfg/providers/company_provider.dart';
import 'package:erp_data_table/erp_data_table.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rs_dashboard/rs_dashboard.dart';

import '../models/dept_process_model.dart';
import '../utils/app_images.dart';
import '../utils/delete_dialogue.dart';
import '../utils/msg_dialogue.dart';

class MstDeptProcess extends StatefulWidget {
  const MstDeptProcess({super.key});

  @override
  State<MstDeptProcess> createState() => _MstDeptProcessState();
}

class _MstDeptProcessState extends State<MstDeptProcess> {
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
    ErpColumnConfig(key: 'deptProcessCode', label: 'CODE', width: 130),
    ErpColumnConfig(key: 'deptProcessName', label: 'NAME', width: 200),
    ErpColumnConfig(key: 'deptCode', label: 'DEPT', width: 130),
    ErpColumnConfig(key: 'companyCode', label: 'COMPANY', width: 160),
    ErpColumnConfig(key: 'sortID', label: 'SORT ID', width: 160),
    ErpColumnConfig(key: 'active', label: 'ACTIVE', width: 140),
  ];

  // ── FORM ROWS ─────────────────────────────────────────────────────────────
  List<List<ErpFieldConfig>> _formRows(
      CompanyProvider companyProvider,
      DeptProvider deptProvider,
      ) =>
      [
        /// ── SECTION 0: BASIC INFORMATION ──
        [
          // ErpFieldConfig(
          //   key: 'deptProcessCode',
          //   label: 'CODE',
          //   type: ErpFieldType.number,
          //   required: true,
          //   sectionTitle: 'BASIC INFORMATION',
          //   sectionIndex: 0,
          // ),
          ErpFieldConfig(
            key: 'deptProcessName',
            label: 'NAME',
            required: true,
            sectionIndex: 0,
          ),
        ],
        [
          ErpFieldConfig(
            key: 'deptCode',
            label: 'DEPARTMENT',
            type: ErpFieldType.dropdown,
            dropdownItems: deptProvider.list
                .where((element) {
              return element.active==true;
            },).map((e) {
              return ErpDropdownItem(
                label: e.deptName ?? '',
                value: e.deptCode?.toString() ?? '',
              );
            }).toList(),
            sectionIndex: 0,
          ),
          ErpFieldConfig(
            key: 'companyCode',
            label: 'COMPANY',
            type: ErpFieldType.dropdown,
            dropdownItems: companyProvider.companies
                .where((element) {
              return element.active==true;
            },).map((e) {
              return ErpDropdownItem(
                label: e.companyName ?? '',
                value: e.companyCode?.toString() ?? '',
              );
            }).toList(),
            sectionIndex: 0,
          ),
        ],
        [
          ErpFieldConfig(
            key: 'sortID',
            label: 'SORT ID',
            type: ErpFieldType.number,
            sectionIndex: 0,
          ),
          // ErpFieldConfig(
          //   key: 'tops',
          //   label: 'TOPS',
          //   type: ErpFieldType.number,
          //   sectionIndex: 0,
          // ),
        ],
        [

          ErpFieldConfig(
            key: 'stockType',
            label: 'STOCK TYPE',
            sectionIndex: 0,
          ),
          // ErpFieldConfig(
          //   key: 'stockTypeCode',
          //   label: 'STOCK TYPE CODE',
          //   type: ErpFieldType.number,
          //   sectionIndex: 0,
          // ),
          ErpFieldConfig(
            key: 'rateOnShape',
            label: 'RATE ON SHAPE',
            sectionIndex: 1,
          ),
        ],


        /// ── SECTION 1: RATE & PLAN ──
        // [
        //   // ErpFieldConfig(
        //   //   key: 'planPcAsRatePc',
        //   //   label: 'PLAN PC AS RATE PC',
        //   //   sectionTitle: 'RATE & PLAN',
        //   //   sectionIndex: 1,
        //   // ),
        //   ErpFieldConfig(
        //     key: 'rateOnShape',
        //     label: 'RATE ON SHAPE',
        //     sectionIndex: 1,
        //   ),
        // ],
        // [
        //   ErpFieldConfig(
        //     key: 'getSarinOptData',
        //     label: 'GET SARIN OPT DATA',
        //     sectionIndex: 1,
        //   ),
        // ],

        /// ── SECTION 2: FLAGS ──
        // [
        //   ErpFieldConfig(
        //     key: 'machineActive',
        //     label: 'MACHINE ACTIVE',
        //     type: ErpFieldType.checkbox,
        //     sectionTitle: 'FLAGS',
        //     sectionIndex: 2,
        //       checkboxDbType: 'BIT'
        //
        //   ),
        //   ErpFieldConfig(
        //     key: 'remarksSelect',
        //     label: 'REMARKS SELECT',
        //     type: ErpFieldType.checkbox,
        //     sectionIndex: 2,
        //       checkboxDbType: 'BIT'
        //
        //   ),
        // ],
        // [
        //   ErpFieldConfig(
        //     key: 'multiTimeIss',
        //     label: 'MULTI TIME ISS',
        //     type: ErpFieldType.checkbox,
        //     sectionIndex: 2,
        //     checkboxDbType: 'YN',
        //
        //   ),
        //   ErpFieldConfig(
        //     key: 'multiTimeDeptIss',
        //     label: 'MULTI TIME DEPT ISS',
        //     type: ErpFieldType.checkbox,
        //     sectionIndex: 2,
        //     checkboxDbType: 'YN',
        //
        //   ),
        // ],
        // [
        //   ErpFieldConfig(
        //     key: 'jnoRecPc',
        //     label: 'JNO REC PC',
        //     type: ErpFieldType.checkbox,
        //     sectionIndex: 2,
        //       checkboxDbType: 'BIT'
        //
        //   ),
        //   ErpFieldConfig(
        //     key: 'jnoKPc',
        //     label: 'JNO K PC',
        //     type: ErpFieldType.checkbox,
        //     sectionIndex: 2,
        //       checkboxDbType: 'BIT'
        //
        //   ),
        // ],
        // [
        //   ErpFieldConfig(
        //     key: 'jnoLastPc',
        //     label: 'JNO LAST PC',
        //     type: ErpFieldType.checkbox,
        //     sectionIndex: 2,
        //   ),
        //   ErpFieldConfig(
        //     key: 'jnoExtraPc',
        //     label: 'JNO EXTRA PC',
        //     type: ErpFieldType.checkbox,
        //     sectionIndex: 2,
        //       checkboxDbType: 'BIT'
        //
        //   ),
        // ],
        // [
        //   ErpFieldConfig(
        //     key: 'lsMarkPc',
        //     label: 'LS MARK PC',
        //     type: ErpFieldType.checkbox,
        //     sectionIndex: 2,
        //       checkboxDbType: 'BIT'
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
        [
          // ErpFieldConfig(
          //   key: 'proDirectIss',
          //   label: 'PRO DIRECT ISS',
          //   type: ErpFieldType.checkbox,
          //   sectionIndex: 2,
          //   checkboxDbType: 'YN',
          //
          // ),
          ErpFieldConfig(
            key: 'remarksRate',
            label: 'REMARKS RATE',
            type: ErpFieldType.checkbox,
            sectionIndex: 2,
            checkboxDbType: 'YN',

          ),
        ],
        // [
        //   ErpFieldConfig(
        //     key: 'displayRatePc',
        //     label: 'DISPLAY RATE PC',
        //     type: ErpFieldType.checkbox,
        //     sectionIndex: 2,
        //     checkboxDbType: 'YN',
        //
        //   ),
        //   ErpFieldConfig(
        //     key: 'planCheck',
        //     label: 'PLAN CHECK',
        //     type: ErpFieldType.checkbox,
        //     sectionIndex: 2,
        //     checkboxDbType: 'YN',
        //
        //   ),
        // ],
        // [
        //   ErpFieldConfig(
        //     key: 'displayRemarks',
        //     label: 'DISPLAY REMARKS',
        //     type: ErpFieldType.checkbox,
        //     sectionIndex: 2,
        //     checkboxDbType: 'YN',
        //
        //   ),
        //   ErpFieldConfig(
        //     key: 'makableCheck',
        //     label: 'MAKABLE CHECK',
        //     type: ErpFieldType.checkbox,
        //     sectionIndex: 2,
        //     checkboxDbType: 'YN',
        //
        //   ),
        // ],
        // [
        //   ErpFieldConfig(
        //     key: 'remarksDisplay',
        //     label: 'REMARKS DISPLAY',
        //     type: ErpFieldType.checkbox,
        //     sectionIndex: 2,
        //     checkboxDbType: 'YN',
        //
        //   ),
        //   ErpFieldConfig(
        //     key: 'procCalcWt',
        //     label: 'PROC CALC WT',
        //     type: ErpFieldType.checkbox,
        //     sectionIndex: 2,
        //     checkboxDbType: 'YN',
        //
        //   ),
        // ],
        [
          ErpFieldConfig(
            key: 'countInCostingProduction',
            label: 'COUNT IN COSTING PROD',
            type: ErpFieldType.checkbox,
            sectionIndex: 2,
            checkboxDbType: 'YN',

          ),
          // ErpFieldConfig(
          //   key: 'checkerPlanCheck',
          //   label: 'CHECKER PLAN CHECK',
          //   type: ErpFieldType.checkbox,
          //   sectionIndex: 2,
          //   checkboxDbType: 'YN',
          //
          // ),
        ],

        /// ── SECTION 3: SETTINGS ──
        [
          ErpFieldConfig(
            key: 'active',
            label: 'ACTIVE',
            type: ErpFieldType.checkbox,
            sectionTitle: 'SETTINGS',
            sectionIndex: 3,
            checkboxDbType: 'BIT'
          ),
          // ErpFieldConfig(
          //   key: 'delRights',
          //   label: 'DEL RIGHTS',
          //   checkboxDbType: 'YN',
          //   type: ErpFieldType.checkbox,
          //   sectionIndex: 0,
          // ),
        ],
      ];

  // // ── INIT ──────────────────────────────────────────────────────────────────
  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     context.read<DeptProcessProvider>().load();
  //     context.read<CompanyProvider>().loadCompanies();
  //     context.read<DeptProvider>().load();
  //   });
  // }
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<DeptProvider>().load();

      await context.read<CompanyProvider>().loadCompanies();

      if (!mounted) return;


      final companies = context.read<CompanyProvider>().companies;
      context.read<DeptProcessProvider>().setCompanies(companies);


      await context.read<DeptProcessProvider>().load();

    });
  }

  // ── ROW TAP ───────────────────────────────────────────────────────────────
  void _onRowTap(Map<String, dynamic> row) {
    final raw = row['_raw'] as DeptProcessModel;

    setState(() {
      _selectedRow = row;
      _isEditMode = true;
      _formValues = {
        'deptProcessCode': raw.deptProcessCode?.toString() ?? '',
        'deptProcessName': raw.deptProcessName ?? '',
        'deptCode': raw.deptCode?.toString() ?? '',
        'companyCode': raw.companyCode?.toString() ?? '',
        'sortID': raw.sortID?.toString() ?? '',
        'tops': raw.tops?.toString() ?? '0',
        'delRights': raw.delRights == 'Y' ? 'true' : 'false',
        'stockType': raw.stockType ?? '',
        'stockTypeCode': raw.stockTypeCode?.toString() ?? '',
        'planPcAsRatePc': raw.planPcAsRatePc ?? '',
        'rateOnShape': raw.rateOnShape ?? '',
        'getSarinOptData': raw.getSarinOptData ?? '',
        'active': raw.active == true ? 'Y' : 'N',
        'machineActive': raw.machineActive == true ? 'Y' : 'N',
        'remarksSelect': raw.remarksSelect == true ? 'Y' : 'N',
        'multiTimeIss': raw.multiTimeIss ?? 'N',
        'multiTimeDeptIss': raw.multiTimeDeptIss ?? 'N',
        'jnoRecPc': raw.jnoRecPc == true ? 'Y' : 'N',
        'jnoKPc': raw.jnoKPc == true ? 'Y' : 'N',
        'jnoLastPc': raw.jnoLastPc == true ? 'Y' : 'N',
        'jnoExtraPc': raw.jnoExtraPc == true ? 'Y' : 'N',
        'lsMarkPc': raw.lsMarkPc == true ? 'Y' : 'N',
        'diaPcMinus': raw.diaPcMinus == true ? 'Y' : 'N',
        'proDirectIss': raw.proDirectIss ?? 'Y',
        'remarksRate': raw.remarksRate ?? 'N',
        'displayRatePc': raw.displayRatePc ?? 'N',
        'planCheck': raw.planCheck ?? 'N',
        'displayRemarks': raw.displayRemarks ?? 'N',
        'makableCheck': raw.makableCheck ?? 'N',
        'remarksDisplay': raw.remarksDisplay ?? 'N',
        'procCalcWt': raw.procCalcWt ?? 'N',
        'countInCostingProduction': raw.countInCostingProduction ?? 'N',
        'checkerPlanCheck': raw.checkerPlanCheck ?? 'N',
      };
    });
    if (Responsive.isMobile(context)) {
      setState(() => _showTableOnMobile = false);
    }
  }

  // ── SAVE ──────────────────────────────────────────────────────────────────
  Future<void> _onSave(Map<String, dynamic> values) async {
    final provider = context.read<DeptProcessProvider>();

    bool success;
    if (_isEditMode && _selectedRow != null) {
      final raw = _selectedRow!['_raw'] as DeptProcessModel;
      success = await provider.update(raw.deptProcessCode!, values);
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
            ? 'Dept Process updated successfully.'
            : 'Dept Process saved successfully.',
      );
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(_isEditMode
      //         ? 'Dept Process updated successfully'
      //         : 'Dept Process saved successfully'),
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
    final raw = _selectedRow?['_raw'] as DeptProcessModel?;
    if (raw?.deptProcessCode == null) return;
    final confirm = await ErpDeleteDialog.show(context: context, theme: _theme, title: 'Dept Process', itemName: raw!.deptProcessName??"");

    // final confirm = await showDialog<bool>(
    //   context: context,
    //   builder: (_) => AlertDialog(
    //     title: const Text('Delete Dept Process'),
    //     content: Text(
    //         'Delete "${raw!.deptProcessName}"? This cannot be undone.'),
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

    final success = await context
        .read<DeptProcessProvider>()
        .delete(raw!.deptProcessCode!);

    if (success && mounted) {
      _resetForm();
      await ErpResultDialog.showDeleted(
        context: context,
        theme: _theme,
        itemName: raw.deptProcessName ?? '',
      );
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: const Text('Dept Process deleted successfully'),
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
      _showTableOnMobile = false;
    });
    _erpFormKey.currentState?.resetForm();
  }
  bool _showTableOnMobile = false;

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final companyProvider = context.watch<CompanyProvider>();
    final deptProvider = context.watch<DeptProvider>();

    return Consumer<DeptProcessProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child:
              Responsive.isMobile(context)?_showTableOnMobile?ErpDataTable(
                isReportRow: false,

                token: token ?? '',
                url: 'http://50.62.183.116:5000',
                title: 'DEPT PROCESS LIST',
                columns: _tableColumns,
                data: provider.tableData,
                // theme: _theme,
                showSearch: true,
                showFooterTotals: false,
                selectedRow: _selectedRow,
                onRowTap: _onRowTap,
                emptyMessage: provider.isLoaded
        ? 'No Dept Process found'
        : 'Loading...',
              ):ErpForm(
                logo: AppImages.logo,

                key: _erpFormKey,
                title: 'DEPT PROCESS MASTER',
                subtitle: 'Department Process Information',
                initialTabIndex: 0,
                onSearch: () => setState(() => _showTableOnMobile = true),
                tabBarBackgroundColor: const Color(0xfff2f0ef),
                tabBarSelectedColor: _theme.primaryGradient.first,
                tabBarSelectedTxtColor: Colors.white,
                rows: _formRows(companyProvider, deptProvider),
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
                  logo: AppImages.logo,

                  key: _erpFormKey,
                  title: 'DEPT PROCESS MASTER',
                  subtitle: 'Department Process Information',
                  initialTabIndex: 0,
                  tabBarBackgroundColor: const Color(0xfff2f0ef),
                  tabBarSelectedColor: _theme.primaryGradient.first,
                  tabBarSelectedTxtColor: Colors.white,
                  rows: _formRows(companyProvider, deptProvider),
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
                  url: 'http://50.62.183.116:5000',
                  title: 'DEPT PROCESS LIST',
                  columns: _tableColumns,
                  data: provider.tableData,
                  // theme: _theme,
                  showSearch: true,
                  showFooterTotals: false,
                  selectedRow: _selectedRow,
                  onRowTap: _onRowTap,
                  emptyMessage: provider.isLoaded
                      ? 'No Dept Process found'
                      : 'Loading...',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── TOP BAR ───────────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Spacer(),
          ErpThemeSwitcher(
            current: _themeVariant,
            onChanged: (v) => setState(() => _themeVariant = v),
          ),
        ],
      ),
    );
  }
}