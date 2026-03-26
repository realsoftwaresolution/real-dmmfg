import 'package:diam_mfg/models/cut_model.dart';
import 'package:diam_mfg/providers/cut_provider.dart';
import 'package:diam_mfg/providers/company_provider.dart';
import 'package:erp_data_table/erp_data_table.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rs_dashboard/rs_dashboard.dart';

import '../bootstrap.dart';
import '../utils/app_images.dart';
import '../utils/delete_dialogue.dart';
import '../utils/msg_dialogue.dart';

class MstCut extends StatefulWidget {
  const MstCut({super.key});

  @override
  State<MstCut> createState() => _MstCutState();
}

class _MstCutState extends State<MstCut> {
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
    ErpColumnConfig(key: 'cutCode', label: 'CODE', width: 130),
    ErpColumnConfig(key: 'cutName', label: 'CUT NAME', width: 220),
    ErpColumnConfig(key: 'companyCode', label: 'COMPANY', width: 160),
    ErpColumnConfig(key: 'sortID', label: 'SORT ID', width: 160),
    ErpColumnConfig(key: 'active', label: 'ACTIVE', width: 140),
  ];
  void _setDefaultSortId() {
    final provider = context.read<CutProvider>();

    int nextSortId = 1;
    if (provider.cuts.isNotEmpty) {
      nextSortId = provider.cuts
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

  // // ── EXTRA COLUMNS ─────────────────────────────────────────────────────────
  // List<ErpColumnConfig> get _extraColumns => [
  //   ErpColumnConfig(key: 'cutCode', label: 'CODE'),
  //   ErpColumnConfig(key: 'companyCode', label: 'COMPANY CODE'),
  //   ErpColumnConfig(key: 'sortID', label: 'SORT ID'),
  // ];

  // ── FORM ROWS ─────────────────────────────────────────────────────────────
  List<List<ErpFieldConfig>> _formRows(CompanyProvider companyProvider) => [
    /// ── BASIC INFO ──
    [
      // ErpFieldConfig(
      //   key: 'cutCode',
      //   label: 'CUT CODE',
      //   type: ErpFieldType.number,
      //   required: true,
      //   sectionTitle: 'BASIC INFORMATION',
      //   sectionIndex: 0,
      // ),
      ErpFieldConfig(
        key: 'cutName',
        label: 'CUT NAME',
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

    /// ── SETTINGS ──
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // ← pehle companies load karo aur AWAIT karo

      await context.read<CompanyProvider>().loadCompanies();

      if (!mounted) return;
      final selectedCode = context.read<CompanyProvider>().selectedCompanyCode;
      context.read<CutProvider>().setSelectedCompany(selectedCode);
      // ← ab companies available hain, division provider ko pass karo
      final companies = context.read<CompanyProvider>().companies;
      context.read<CutProvider>().setCompanies(companies);

      // ← last mein divisions load karo
      await context.read<CutProvider>().loadCuts();
      _setDefaultSortId();
    });
  }
  // ── INIT ──────────────────────────────────────────────────────────────────
  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     context.read<CutProvider>().loadCuts();
  //     context.read<CompanyProvider>().loadCompanies();
  //   });
  // }

  // ── ROW TAP ───────────────────────────────────────────────────────────────
  void _onRowTap(Map<String, dynamic> row) {
    final raw = row['_raw'] as CutModel;

    setState(() {
      _selectedRow = row;
      _isEditMode = true;
      _formValues = {
        'cutCode': raw.cutCode?.toString() ?? '',
        'cutName': raw.cutName ?? '',
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
    final provider = context.read<CutProvider>();

    bool success;
    if (_isEditMode && _selectedRow != null) {
      final raw = _selectedRow!['_raw'] as CutModel;
      success = await provider.updateCut(raw.cutCode!, values);
    } else {
      success = await provider.createCut(values);
    }

    if (!mounted) return;

    if (success) {
      _resetForm();
      await ErpResultDialog.showSuccess(
        context: context,
        theme: _theme,
        title: _isEditMode ? 'Updated' : 'Saved',
        message: _isEditMode
            ? 'Cut updated successfully.'
            : 'Cut saved successfully.',
      );
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(
      //         _isEditMode ? 'Cut updated successfully' : 'Cut saved successfully'),
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
    final raw = _selectedRow?['_raw'] as CutModel?;
    if (raw?.cutCode == null) return;
    final confirm = await ErpDeleteDialog.show(context: context, theme: _theme, title: 'Cut', itemName: raw!.cutName??"");

    // final confirm = await showDialog<bool>(
    //   context: context,
    //   builder: (_) => AlertDialog(
    //     title: const Text('Delete Cut'),
    //     content: Text('Delete "${raw!.cutName}"? This cannot be undone.'),
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
    await context.read<CutProvider>().deleteCut(raw.cutCode!);

    if (success && mounted) {
      _resetForm();
      await ErpResultDialog.showDeleted(
        context: context,
        theme: _theme,
        itemName: raw.cutName ?? '',
      );
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: const Text('Cut deleted successfully'),
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

    return Consumer<CutProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child:
              Responsive.isMobile(context)?_showTableOnMobile?ErpDataTable(
                isReportRow: false,

                token: token ?? '',
                url: baseUrl,
                title: 'CUT LIST',
                columns: _tableColumns,
                // availableExtraColumns: _extraColumns,
                data: provider.tableData,
                // theme: _theme,
                showSearch: true,
                showFooterTotals: false,
                selectedRow: _selectedRow,
                onRowTap: _onRowTap,
                emptyMessage:
                provider.isLoaded ? 'No cuts found' : 'Loading...',
              ):ErpForm(
                onExit: () {
                  context.read<TabProvider>().closeCurrentTab();
                },
                logo: AppImages.logo,

                key: _erpFormKey,
                title: 'CUT MASTER',
                subtitle: 'Cut Information',
                initialTabIndex: 0,
                onSearch: () => setState(() => _showTableOnMobile = true),

                tabBarBackgroundColor: const Color(0xfff2f0ef),
                tabBarSelectedColor: _theme.primaryGradient.first,
                tabBarSelectedTxtColor: Colors.white,
                rows: _formRows(companyProvider),
                // theme: _theme,
                initialValues: _formValues,
                isEditMode: _isEditMode,
                onFieldChanged: (key, value) {
                if (key == 'companyCode') {
        _formValues['companyCode'] = value;
                } else {
        _formValues[key] = value;
                }
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
                  title: 'CUT MASTER',
                  subtitle: 'Cut Information',
                  initialTabIndex: 0,
                  tabBarBackgroundColor: const Color(0xfff2f0ef),
                  tabBarSelectedColor: _theme.primaryGradient.first,
                  tabBarSelectedTxtColor: Colors.white,
                  rows: _formRows(companyProvider),
                  // theme: _theme,
                  initialValues: _formValues,
                  isEditMode: _isEditMode,
                  onFieldChanged: (key, value) {
                    if (key == 'companyCode') {
                      _formValues['companyCode'] = value;
                    } else {
                      _formValues[key] = value;
                    }
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
                  title: 'CUT LIST',
                  columns: _tableColumns,
                  // availableExtraColumns: _extraColumns,
                  data: provider.tableData,
                  // theme: _theme,
                  showSearch: true,
                  showFooterTotals: false,
                  selectedRow: _selectedRow,
                  onRowTap: _onRowTap,
                  emptyMessage:
                  provider.isLoaded ? 'No cuts found' : 'Loading...',
                ),
              ),
            ],
          ),
        );
      },
    );
  }


}