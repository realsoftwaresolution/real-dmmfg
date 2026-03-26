import 'package:diam_mfg/providers/fluo_provider.dart';
import 'package:diam_mfg/providers/company_provider.dart';
import 'package:erp_data_table/erp_data_table.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rs_dashboard/rs_dashboard.dart';

import '../bootstrap.dart';
import '../models/fluo_model.dart';
import '../utils/app_images.dart';
import '../utils/delete_dialogue.dart';
import '../utils/msg_dialogue.dart';

class MstFluo extends StatefulWidget {
  const MstFluo({super.key});

  @override
  State<MstFluo> createState() => _MstFluoState();
}

class _MstFluoState extends State<MstFluo> {
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
    ErpColumnConfig(key: 'fluoCode', label: 'CODE', width: 130),
    ErpColumnConfig(key: 'fluoName', label: 'NAME', width: 220),
    ErpColumnConfig(key: 'companyCode', label: 'COMPANY', width: 160),
    ErpColumnConfig(key: 'sortID', label: 'SORT ID', width: 160),
    ErpColumnConfig(key: 'active', label: 'ACTIVE', width: 140),
  ];

  // ── FORM ROWS ─────────────────────────────────────────────────────────────
  List<List<ErpFieldConfig>> _formRows(CompanyProvider companyProvider) => [
    [
      // ErpFieldConfig(
      //   key: 'fluoCode',
      //   label: 'CODE',
      //   type: ErpFieldType.number,
      //   required: true,
      //   sectionTitle: 'BASIC INFORMATION',
      //   sectionIndex: 0,
      // ),
      ErpFieldConfig(
        key: 'fluoName',
        label: 'NAME',
        required: true,
        sectionIndex: 0,
      ),
      ErpFieldConfig(
        key: 'sortID',
        label: 'SORT ID',
        type: ErpFieldType.number,
        sectionIndex: 0,
      ),
    ],
    // [
    //   ErpFieldConfig(
    //     key: 'companyCode',
    //     label: 'COMPANY',
    //     type: ErpFieldType.dropdown,
    //     dropdownItems: companyProvider.companies
    //         .where((element) {
    //       return element.active==true;
    //     },).map((e) {
    //       return ErpDropdownItem(
    //         label: e.companyName ?? '',
    //         value: e.companyCode?.toString() ?? '',
    //       );
    //     }).toList(),
    //     sectionIndex: 0,
    //   ),
    //   ErpFieldConfig(
    //     key: 'sortID',
    //     label: 'SORT ID',
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

  // // ── INIT ──────────────────────────────────────────────────────────────────
  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     context.read<FluoProvider>().load();
  //     context.read<CompanyProvider>().loadCompanies();
  //   });
  // }
  void _setDefaultSortId() {
    final provider = context.read<FluoProvider>();

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

      await context.read<CompanyProvider>().loadCompanies();

      if (!mounted) return;


      final companies = context.read<CompanyProvider>().companies;
      context.read<FluoProvider>().setCompanies(companies);
      final selectedCode = context.read<CompanyProvider>().selectedCompanyCode;
      context.read<FluoProvider>().setSelectedCompany(selectedCode);

      await context.read<FluoProvider>().load();
      _setDefaultSortId();

    });
  }
  // ── ROW TAP ───────────────────────────────────────────────────────────────
  void _onRowTap(Map<String, dynamic> row) {
    final raw = row['_raw'] as FluoModel;
    setState(() {
      _selectedRow = row;
      _isEditMode = true;
      _formValues = {
        'fluoCode': raw.fluoCode?.toString() ?? '',
        'fluoName': raw.fluoName ?? '',
        'companyCode': context.read<CompanyProvider>().selectedCompanyCode?.toString()
            ?? raw.companyCode?.toString() ?? '',
        'sortID': raw.sortID?.toString() ?? '',
        'active': raw.active == true ? 'true' : 'false',
      };
    });
    if (Responsive.isMobile(context)) {
      setState(() => _showTableOnMobile = false);
    }
  }

  // ── SAVE ──────────────────────────────────────────────────────────────────
  Future<void> _onSave(Map<String, dynamic> values) async {
    final provider = context.read<FluoProvider>();
    bool success;
    if (_isEditMode && _selectedRow != null) {
      final raw = _selectedRow!['_raw'] as FluoModel;
      success = await provider.update(raw.fluoCode!, values);
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
            ? 'Fluo updated successfully.'
            : 'Fluo saved successfully.',
      );
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(_isEditMode
      //         ? 'Fluo updated successfully'
      //         : 'Fluo saved successfully'),
      //     backgroundColor: _theme.primary,
      //     behavior: SnackBarBehavior.floating,
      //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      //     margin: const EdgeInsets.all(12),
      //   ),
      // );
    }
  }

  // ── DELETE ────────────────────────────────────────────────────────────────
  Future<void> _onDelete() async {
    final raw = _selectedRow?['_raw'] as FluoModel?;
    if (raw?.fluoCode == null) return;
    final confirm = await ErpDeleteDialog.show(context: context, theme: _theme, title: 'Fluo', itemName: raw!.fluoName??"");

    // final confirm = await showDialog<bool>(
    //   context: context,
    //   builder: (_) => AlertDialog(
    //     title: const Text('Delete Fluo'),
    //     content: Text('Delete "${raw!.fluoName}"? This cannot be undone.'),
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
    final success = await context.read<FluoProvider>().delete(raw.fluoCode!);
    if (success && mounted) {
      _resetForm();
      await ErpResultDialog.showDeleted(
        context: context,
        theme: _theme,
        itemName: raw.fluoName ?? '',
      );
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: const Text('Fluo deleted successfully'),
      //     backgroundColor: Colors.red.shade600,
      //     behavior: SnackBarBehavior.floating,
      //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
    _setDefaultSortId();
  }
  bool _showTableOnMobile = false;

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final companyProvider = context.watch<CompanyProvider>();

    return Consumer<FluoProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child:
                Responsive.isMobile(context)?_showTableOnMobile?ErpDataTable(
                  token: token ?? '',
                  isReportRow: false,

                  url: baseUrl,
                  title: 'FLUO LIST',
                  columns: _tableColumns,
                  data: provider.tableData,
                  // theme: _theme,
                  showSearch: true,
                  showFooterTotals: false,
                  selectedRow: _selectedRow,
                  onRowTap: _onRowTap,
                  emptyMessage:
                  provider.isLoaded ? 'No Fluo found' : 'Loading...',
                ):ErpForm(
                  onExit: () {
                    context.read<TabProvider>().closeCurrentTab();
                  },
                  logo: AppImages.logo,

                  key: _erpFormKey,
                  title: 'FLUO MASTER',
                  subtitle: 'Fluorescence Information',
                  initialTabIndex: 0,
                  tabBarBackgroundColor: const Color(0xfff2f0ef),
                  tabBarSelectedColor: _theme.primaryGradient.first,
                  tabBarSelectedTxtColor: Colors.white,
                  rows: _formRows(companyProvider),
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
                  title: 'FLUO MASTER',
                  subtitle: 'Fluorescence Information',
                  initialTabIndex: 0,
                  tabBarBackgroundColor: const Color(0xfff2f0ef),
                  tabBarSelectedColor: _theme.primaryGradient.first,
                  tabBarSelectedTxtColor: Colors.white,
                  rows: _formRows(companyProvider),
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
                  title: 'FLUO LIST',
                  columns: _tableColumns,
                  data: provider.tableData,
                  // theme: _theme,
                  showSearch: true,
                  showFooterTotals: false,
                  selectedRow: _selectedRow,
                  onRowTap: _onRowTap,
                  emptyMessage:
                  provider.isLoaded ? 'No Fluo found' : 'Loading...',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}