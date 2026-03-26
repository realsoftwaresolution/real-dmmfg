import 'package:diam_mfg/providers/color_group_provider.dart';
import 'package:diam_mfg/providers/color_provider.dart';
import 'package:diam_mfg/providers/company_provider.dart';
import 'package:erp_data_table/erp_data_table.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rs_dashboard/rs_dashboard.dart';

import '../bootstrap.dart';
import '../models/color_model.dart';
import '../utils/app_images.dart';
import '../utils/delete_dialogue.dart';
import '../utils/msg_dialogue.dart';

class MstColor extends StatefulWidget {
  const MstColor({super.key});

  @override
  State<MstColor> createState() => _MstColorState();
}

class _MstColorState extends State<MstColor> {
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
    ErpColumnConfig(key: 'colorCode', label: 'CODE', width: 130),
    ErpColumnConfig(key: 'colorName', label: 'NAME', width: 220),
    ErpColumnConfig(key: 'colorRptGroupCode', label: 'RPT GROUP', width: 180),
    ErpColumnConfig(key: 'companyCode', label: 'COMPANY', width: 160),
    ErpColumnConfig(key: 'sortID', label: 'SORT ID', width: 160),
    ErpColumnConfig(key: 'active', label: 'ACTIVE', width: 140),
  ];

  // ── FORM ROWS ─────────────────────────────────────────────────────────────
  List<List<ErpFieldConfig>> _formRows(CompanyProvider companyProvider,ColorGroupProvider colorGroupProvider) => [
    /// ── BASIC INFO ──
    // [
    //   // ErpFieldConfig(
    //   //   key: 'colorCode',
    //   //   label: 'CODE',
    //   //   type: ErpFieldType.number,
    //   //   required: true,
    //   //   sectionTitle: 'BASIC INFORMATION',
    //   //   sectionIndex: 0,
    //   // ),
    //   ErpFieldConfig(
    //     key: 'colorName',
    //     label: 'NAME',
    //     required: true,
    //     sectionIndex: 0,
    //   ),
    // ],

    [
      ErpFieldConfig(
        key: 'colorName',
        label: 'NAME',
        required: true,
        sectionIndex: 0,
      ),
      ErpFieldConfig(
        key: 'colorRptGroupCode',
        label: 'GROUP CODE',
        type: ErpFieldType.dropdown,
        sectionIndex: 0,
        required: true,
        initialDropValue: true,
        dropdownItems: colorGroupProvider.list
            .where((element) {
          return element.active==true;
        },).map((e) {
          return ErpDropdownItem(
            label: e.colorGroupName ?? '',
            value: e.colorGroupCode?.toString() ?? '',
          );
        }).toList(),
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

    // [
    //   ErpFieldConfig(
    //     key: 'sortID',
    //     label: 'SORT ID',
    //     type: ErpFieldType.number,
    //     sectionIndex: 0,
    //   ),
    // ],

    /// ── SETTINGS ──
    [
      ErpFieldConfig(
        key: 'active',
        label: 'ACTIVE',
        type: ErpFieldType.checkbox,
        sectionTitle: 'SETTINGS',
        initialBoolValue: true,
        sectionIndex: 1,
        checkboxDbType: 'BIT'
      ),
      ErpFieldConfig(
        key: 'pg',
          label: 'POLISH GRADE',
        type: ErpFieldType.checkbox,
        sectionIndex: 1,
        checkboxDbType: 'BIT'
      ),
    ],
  ];

  // // ── INIT ──────────────────────────────────────────────────────────────────
  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     context.read<ColorProvider>().load();
  //     context.read<CompanyProvider>().loadCompanies();
  //   });
  // }
  void _setDefaultSortId() {
    final provider = context.read<ColorProvider>();

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
      context.read<ColorGroupProvider>().load();

      if (!mounted) return;
      final selectedCode = context.read<CompanyProvider>().selectedCompanyCode;
      context.read<ColorProvider>().setSelectedCompany(selectedCode);

      final companies = context.read<CompanyProvider>().companies;
      context.read<ColorProvider>().setCompanies(companies);


      await context.read<ColorProvider>().load();
      _setDefaultSortId();

    });
  }
  // ── ROW TAP ───────────────────────────────────────────────────────────────
  void _onRowTap(Map<String, dynamic> row) {
    final raw = row['_raw'] as ColorModel;

    setState(() {
      _selectedRow = row;
      _isEditMode = true;
      _formValues = {
        'colorCode': raw.colorCode?.toString() ?? '',
        'colorName': raw.colorName ?? '',
        'colorRptGroupCode': raw.colorRptGroupCode?.toString() ?? '',
        'companyCode': context.read<CompanyProvider>().selectedCompanyCode?.toString()
            ?? raw.companyCode?.toString() ?? '',
        'sortID': raw.sortID?.toString() ?? '',
        'active': raw.active == true ? 'true' : 'false',
        'pg': raw.pg == true ? 'true' : 'false',
      };
    });
    if (Responsive.isMobile(context)) {
      setState(() => _showTableOnMobile = false);
    }
  }

  // ── SAVE ──────────────────────────────────────────────────────────────────
  Future<void> _onSave(Map<String, dynamic> values) async {
    final provider = context.read<ColorProvider>();

    bool success;
    if (_isEditMode && _selectedRow != null) {
      final raw = _selectedRow!['_raw'] as ColorModel;
      success = await provider.update(raw.colorCode!, values);
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
            ? 'Color updated successfully.'
            : 'Color saved successfully.',
      );
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(_isEditMode
      //         ? 'Color updated successfully'
      //         : 'Color saved successfully'),
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
    final raw = _selectedRow?['_raw'] as ColorModel?;
    if (raw?.colorCode == null) return;
    final confirm = await ErpDeleteDialog.show(context: context, theme: _theme, title: 'Color', itemName: raw!.colorName??"");

    // final confirm = await showDialog<bool>(
    //   context: context,
    //   builder: (_) => AlertDialog(
    //     title: const Text('Delete Color'),
    //     content: Text('Delete "${raw!.colorName}"? This cannot be undone.'),
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
    await context.read<ColorProvider>().delete(raw.colorCode!);

    if (success && mounted) {
      _resetForm();
      await ErpResultDialog.showDeleted(
        context: context,
        theme: _theme,
        itemName: raw.colorName ?? '',
      );
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: const Text('Color deleted successfully'),
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
    final colorGroupProvider = context.watch<ColorGroupProvider>();

    return Consumer<ColorProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child:
              Responsive.isMobile(context)?_showTableOnMobile?ErpDataTable(
                isReportRow: false,

                token: token ?? '',
                url: baseUrl,
                title: 'COLOR LIST',
                columns: _tableColumns,
                data: provider.tableData,
                // theme: _theme,
                showSearch: true,
                showFooterTotals: false,
                selectedRow: _selectedRow,
                onRowTap: _onRowTap,
                emptyMessage: provider.isLoaded
                    ? 'No Color found'
                    : 'Loading...',
              ):ErpForm(
                onExit: () {
                  context.read<TabProvider>().closeCurrentTab();
                },
                logo: AppImages.logo,

                key: _erpFormKey,
                title: 'COLOR MASTER',
                onSearch: () => setState(() => _showTableOnMobile = true),
                subtitle: 'Color Information',
                initialTabIndex: 0,
                tabBarBackgroundColor: const Color(0xfff2f0ef),
                tabBarSelectedColor: _theme.primaryGradient.first,
                tabBarSelectedTxtColor: Colors.white,
                rows: _formRows(companyProvider,colorGroupProvider),
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
                  title: 'COLOR MASTER',
                  subtitle: 'Color Information',
                  initialTabIndex: 0,
                  tabBarBackgroundColor: const Color(0xfff2f0ef),
                  tabBarSelectedColor: _theme.primaryGradient.first,
                  tabBarSelectedTxtColor: Colors.white,
                  rows: _formRows(companyProvider,colorGroupProvider),
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
                  title: 'COLOR LIST',
                  columns: _tableColumns,
                  data: provider.tableData,
                  // theme: _theme,
                  showSearch: true,
                  showFooterTotals: false,
                  selectedRow: _selectedRow,
                  onRowTap: _onRowTap,
                  emptyMessage: provider.isLoaded
                      ? 'No Color found'
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