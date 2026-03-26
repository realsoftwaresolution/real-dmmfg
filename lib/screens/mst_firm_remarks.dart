import 'package:diam_mfg/providers/remarks_provider.dart';
import 'package:diam_mfg/providers/dept_provider.dart';
import 'package:diam_mfg/providers/dept_process_provider.dart';
import 'package:diam_mfg/providers/company_provider.dart';
import 'package:erp_data_table/erp_data_table.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rs_dashboard/rs_dashboard.dart';

import '../bootstrap.dart';
import '../models/remarks_model.dart';
import '../utils/app_images.dart';
import '../utils/delete_dialogue.dart';
import '../utils/msg_dialogue.dart';

class MstRemarks extends StatefulWidget {
  const MstRemarks({super.key});

  @override
  State<MstRemarks> createState() => _MstRemarksState();
}

class _MstRemarksState extends State<MstRemarks> {
  ErpThemeVariant _themeVariant = ErpThemeVariant.frost;
  ErpTheme get _theme => ErpTheme(_themeVariant);

  final GlobalKey<ErpFormState> _erpFormKey = GlobalKey<ErpFormState>();
  Map<String, dynamic>? _selectedRow;
  bool _isEditMode = false;
  Map<String, String> _formValues = {};

  final String? token = AppStorage.getString("token");

  List<ErpColumnConfig> get _tableColumns => [
    ErpColumnConfig(key: 'remarksCode', label: 'CODE', width: 130),
    ErpColumnConfig(key: 'remarksName', label: 'NAME', width: 200),
    ErpColumnConfig(key: 'deptCode', label: 'DEPT', width: 130),
    ErpColumnConfig(key: 'deptProcessCode', label: 'PROCESS', width: 170),
    ErpColumnConfig(key: 'tops', label: 'TOPS', width: 130),
    ErpColumnConfig(key: 'companyCode', label: 'COMPANY', width: 160),
    ErpColumnConfig(key: 'sortID', label: 'SORT ID', width: 160),
    ErpColumnConfig(key: 'active', label: 'ACTIVE', width: 140),
  ];

  List<List<ErpFieldConfig>> _formRows(
      CompanyProvider companyProvider,
      DeptProvider deptProvider,
      DeptProcessProvider deptProcessProvider,
      ) =>
      [
        // [
        //   // ErpFieldConfig(
        //   //   key: 'remarksCode',
        //   //   label: 'CODE',
        //   //   type: ErpFieldType.number,
        //   //   required: true,
        //   //   sectionTitle: 'BASIC INFORMATION',
        //   //   sectionIndex: 0,
        //   // ),
        //   ErpFieldConfig(
        //     key: 'remarksName',
        //     label: 'NAME',
        //     required: true,
        //     sectionIndex: 0,
        //   ),
        // ],
        [
          ErpFieldConfig(
            key: 'remarksName',
            label: 'NAME',
            required: true,
            sectionIndex: 0,
          ),
          ErpFieldConfig(
            key: 'deptCode',
            label: 'DEPARTMENT',
            type: ErpFieldType.dropdown,
            initialDropValue: true,
            required: true,
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
            key: 'deptProcessCode',
            label: 'DEPT PROCESS',
            initialDropValue: true,
            required: true,
            type: ErpFieldType.dropdown,
            dropdownItems: deptProcessProvider.list
                .where((element) {
              return element.active==true;
            },).map((e) {
              return ErpDropdownItem(
                label: e.deptProcessName ?? '',
                value: e.deptProcessCode?.toString() ?? '',
              );
            }).toList(),
            sectionIndex: 0,
          ),
        ],
        [
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
          ErpFieldConfig(
            key: 'sortID',
            label: 'SORT ID',
            type: ErpFieldType.number,
            sectionIndex: 0,
          ),
          ErpFieldConfig(
            key: 'tops',
            label: 'TOPS',
            type: ErpFieldType.number,
            sectionIndex: 0,
          ),
        ],
        // [
        //   ErpFieldConfig(
        //     key: 'tops',
        //     label: 'TOPS',
        //     type: ErpFieldType.number,
        //     sectionIndex: 0,
        //   ),
        // ],
        [
          ErpFieldConfig(
            key: 'active',
            label: 'ACTIVE',
            type: ErpFieldType.checkbox,
            sectionTitle: 'SETTINGS',
            sectionIndex: 1,
            initialBoolValue: true,
            checkboxDbType: 'BIT'
          ),
        ],
      ];

  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     context.read<RemarksProvider>().load();
  //     context.read<CompanyProvider>().loadCompanies();
  //     context.read<DeptProvider>().load();
  //     context.read<DeptProcessProvider>().load();
  //   });
  // }
  void _setDefaultSortId() {
    final provider = context.read<RemarksProvider>();

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
      context.read<DeptProvider>().load();
      context.read<DeptProcessProvider>().load();
      await context.read<CompanyProvider>().loadCompanies();

      if (!mounted) return;


      final companies = context.read<CompanyProvider>().companies;
      context.read<RemarksProvider>().setCompanies(companies);

      final selectedCode = context.read<CompanyProvider>().selectedCompanyCode;
      context.read<RemarksProvider>().setSelectedCompany(selectedCode);
      await context.read<RemarksProvider>().load();
      _setDefaultSortId();

    });
  }
  void _onRowTap(Map<String, dynamic> row) {
    final raw = row['_raw'] as RemarksModel;
    setState(() {
      _selectedRow = row;
      _isEditMode = true;
      _formValues = {
        'remarksCode': raw.remarksCode?.toString() ?? '',
        'remarksName': raw.remarksName ?? '',
        'deptCode': raw.deptCode?.toString() ?? '',
        'deptProcessCode': raw.deptProcessCode?.toString() ?? '',
        'companyCode': context.read<CompanyProvider>().selectedCompanyCode?.toString()
            ?? raw.companyCode?.toString() ?? '',
        'sortID': raw.sortID?.toString() ?? '',
        'tops': raw.tops?.toString() ?? '',
        'active': raw.active == true ? 'true' : 'false',
      };
    });
    if (Responsive.isMobile(context)) {
      setState(() => _showTableOnMobile = false);
    }
  }

  Future<void> _onSave(Map<String, dynamic> values) async {
    final provider = context.read<RemarksProvider>();
    bool success;
    if (_isEditMode && _selectedRow != null) {
      final raw = _selectedRow!['_raw'] as RemarksModel;
      success = await provider.update(raw.remarksCode!, values);
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
            ? 'Remarks updated successfully.'
            : 'Remarks saved successfully.',
      );
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(_isEditMode
      //         ? 'Remarks updated successfully'
      //         : 'Remarks saved successfully'),
      //     backgroundColor: _theme.primary,
      //     behavior: SnackBarBehavior.floating,
      //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      //     margin: const EdgeInsets.all(12),
      //   ),
      // );
    }
  }

  Future<void> _onDelete() async {
    final raw = _selectedRow?['_raw'] as RemarksModel?;
    if (raw?.remarksCode == null) return;

    final confirm = await ErpDeleteDialog.show(context: context, theme: _theme, title: 'Remarks', itemName: raw!.remarksName??"");

    // final confirm = await showDialog<bool>(
    //   context: context,
    //   builder: (_) => AlertDialog(
    //     title: const Text('Delete Remarks'),
    //     content: Text('Delete "${raw!.remarksName}"? This cannot be undone.'),
    //     actions: [
    //       TextButton(
    //         onPressed: () => Navigator.pop(context, false),
    //         child: const Text('Cancel'),
    //       ),
    //       TextButton(
    //         onPressed: () => Navigator.pop(context, true),
    //         child: const Text('Delete', style: TextStyle(color: Colors.red)),
    //       ),
    //     ],
    //   ),
    // );
    if (confirm != true || !mounted) return;
    final success =
    await context.read<RemarksProvider>().delete(raw.remarksCode!);
    if (success && mounted) {
      _resetForm();
      await ErpResultDialog.showDeleted(
        context: context,
        theme: _theme,
        itemName: raw.remarksName ?? '',
      );
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: const Text('Remarks deleted successfully'),
      //     backgroundColor: Colors.red.shade600,
      //     behavior: SnackBarBehavior.floating,
      //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      //     margin: const EdgeInsets.all(12),
      //   ),
      // );
    }
  }

  void _resetForm() {
    setState(() {
      _selectedRow = null;
      _isEditMode = false;
      _formValues = {};
      _showTableOnMobile = false;
    });
    _erpFormKey.currentState?.resetForm();
    _setDefaultSortId();
  }
  bool _showTableOnMobile = false;

  @override
  Widget build(BuildContext context) {
    final companyProvider = context.watch<CompanyProvider>();
    final deptProvider = context.watch<DeptProvider>();
    final deptProcessProvider = context.watch<DeptProcessProvider>();

    return Consumer<RemarksProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child:
              Responsive.isMobile(context)?_showTableOnMobile?ErpDataTable(
                isReportRow: false,

                token: token ?? '',
                url: baseUrl,
                title: 'REMARKS LIST',
                columns: _tableColumns,
                data: provider.tableData,
                // theme: _theme,
                showSearch: true,
                showFooterTotals: false,
                selectedRow: _selectedRow,
                onRowTap: _onRowTap,
                emptyMessage: provider.isLoaded
                    ? 'No Remarks found'
                    : 'Loading...',
              ):ErpForm(
                onExit: () {
                  context.read<TabProvider>().closeCurrentTab();
                },
                logo: AppImages.logo,

                key: _erpFormKey,
                title: 'REMARKS MASTER',
                subtitle: 'Remarks Information',
                initialTabIndex: 0,
                tabBarBackgroundColor: const Color(0xfff2f0ef),
                tabBarSelectedColor: _theme.primaryGradient.first,
                tabBarSelectedTxtColor: Colors.white,
                rows: _formRows(
                    companyProvider, deptProvider, deptProcessProvider),
                onSearch: () => setState(() => _showTableOnMobile = true),

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
              Expanded(
                flex: 2,
                child: ErpForm(
                  onExit: () {
                    context.read<TabProvider>().closeCurrentTab();
                  },
                  logo: AppImages.logo,

                  key: _erpFormKey,
                  title: 'REMARKS MASTER',
                  subtitle: 'Remarks Information',
                  initialTabIndex: 0,
                  tabBarBackgroundColor: const Color(0xfff2f0ef),
                  tabBarSelectedColor: _theme.primaryGradient.first,
                  tabBarSelectedTxtColor: Colors.white,
                  rows: _formRows(
                      companyProvider, deptProvider, deptProcessProvider),
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
              Expanded(
                flex: 2,
                child: ErpDataTable(
                  isReportRow: false,

                  token: token ?? '',
                  url: baseUrl,
                  title: 'REMARKS LIST',
                  columns: _tableColumns,
                  data: provider.tableData,
                  // theme: _theme,
                  showSearch: true,
                  showFooterTotals: false,
                  selectedRow: _selectedRow,
                  onRowTap: _onRowTap,
                  emptyMessage: provider.isLoaded
                      ? 'No Remarks found'
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