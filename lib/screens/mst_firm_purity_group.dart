import 'package:diam_mfg/providers/purity_group_provider.dart';
import 'package:diam_mfg/providers/company_provider.dart';
import 'package:diam_mfg/providers/purity_type_provider.dart';
import 'package:erp_data_table/erp_data_table.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rs_dashboard/rs_dashboard.dart';

import '../bootstrap.dart';
import '../models/purity_group_model.dart';
import '../utils/app_images.dart' show AppImages;
import '../utils/delete_dialogue.dart';
import '../utils/msg_dialogue.dart';

class MstPurityGroup extends StatefulWidget {
  const MstPurityGroup({super.key});

  @override
  State<MstPurityGroup> createState() => _MstPurityGroupState();
}

class _MstPurityGroupState extends State<MstPurityGroup> {
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
    ErpColumnConfig(key: 'purityGroupCode', label: 'CODE', width: 130),
    ErpColumnConfig(key: 'purityGroupName', label: 'NAME', width: 200),
    ErpColumnConfig(key: 'purityTypeCode', label: 'PURITY TYPE', width: 180),
    ErpColumnConfig(key: 'companyCode', label: 'COMPANY', width: 160),
    ErpColumnConfig(key: 'sortID', label: 'SORT ID', width: 160),
    ErpColumnConfig(key: 'active', label: 'ACTIVE', width: 140),
  ];

  // ── FORM ROWS ─────────────────────────────────────────────────────────────
  List<List<ErpFieldConfig>> _formRows(CompanyProvider companyProvider,PurityTypeProvider purityTypeProvider) => [
    /// ── BASIC INFO ──
    [
      // ErpFieldConfig(
      //   key: 'purityGroupCode',
      //   label: 'CODE',
      //   type: ErpFieldType.number,
      //   required: true,
      //   sectionTitle: 'BASIC INFORMATION',
      //   sectionIndex: 0,
      // ),
      ErpFieldConfig(
        key: 'purityGroupName',
        label: 'NAME',
        required: true,
        sectionIndex: 0,
      ),
    ],

    [
      ErpFieldConfig(
        key: 'purityTypeCode',
        label: 'PURITY TYPE CODE',
        type: ErpFieldType.dropdown,
        required: true,
        initialDropValue: true,
        sectionIndex: 0,
        dropdownItems: purityTypeProvider.list
            .where((element) {
          return element.active==true;
        },).map((e) {
          return ErpDropdownItem(
            label: e.purityTypeName ?? '',
            value: e.purityTypeCode?.toString() ?? '',
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
    //   // ErpFieldConfig(
    //   //   key: 'delRights',
    //   //   label: 'DEL RIGHTS',
    //   //   sectionIndex: 0,
    //   // ),
    // ],

    /// ── SETTINGS ──
    [
      ErpFieldConfig(
        key: 'delRights',
        label: 'DEL RIGHTS',
        type: ErpFieldType.checkbox,
        sectionTitle: 'SETTINGS',
        sectionIndex: 1,
        checkboxDbType: 'YN'
      ),
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
  //     context.read<PurityGroupProvider>().load();
  //     context.read<CompanyProvider>().loadCompanies();
  //   });
  // }
  void _setDefaultSortId() {
    final provider = context.read<PurityGroupProvider>();

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
      // ← pehle companies load karo aur AWAIT karo
      await context.read<CompanyProvider>().loadCompanies();
      context.read<PurityTypeProvider>().load();

      if (!mounted) return;

      // ← ab companies available hain, division provider ko pass karo
      final companies = context.read<CompanyProvider>().companies;
      context.read<PurityGroupProvider>().setCompanies(companies);
      final selectedCode = context.read<CompanyProvider>().selectedCompanyCode;
      context.read<PurityGroupProvider>().setSelectedCompany(selectedCode);
      // ← last mein divisions load karo
      await context.read<PurityGroupProvider>().load();
      _setDefaultSortId();

    });
  }
  // ── ROW TAP ───────────────────────────────────────────────────────────────
  void _onRowTap(Map<String, dynamic> row) {
    final raw = row['_raw'] as PurityGroupModel;

    setState(() {
      _selectedRow = row;
      _isEditMode = true;
      _formValues = {
        'purityGroupCode': raw.purityGroupCode?.toString() ?? '',
        'purityGroupName': raw.purityGroupName ?? '',
        'purityTypeCode': raw.purityTypeCode?.toString() ?? '',
        'companyCode': context.read<CompanyProvider>().selectedCompanyCode?.toString()
            ?? raw.companyCode?.toString() ?? '',
        'sortID': raw.sortID?.toString() ?? '',
        // 'delRights': raw.delRights ?? 'Y',
        // 'delRights': raw.delRights ?? 'Y',
        // 'active': raw.active == true ? 'Y' : 'N',
        // 'delRights': raw.delRights == 'Y' ? 'Y' : 'N',
        // 'active': raw.active == true ? 'Y' : 'N',
        'active': raw.active == true ? 'true' : 'false',
        'delRights': raw.delRights == 'Y' ? 'true' : 'false',
      };
    });
    if (Responsive.isMobile(context)) {
      setState(() => _showTableOnMobile = false);
    }
  }

  // ── SAVE ──────────────────────────────────────────────────────────────────
  Future<void> _onSave(Map<String, dynamic> values) async {
    final provider = context.read<PurityGroupProvider>();
    // values['delRights'] = values['delRights'] == 'Y' ? 'Y' : 'N';
    //
    // values['active'] = values['active'] == 'true' ? '1' : '0';
    // values['active'] =
    // values['active'] == 'true' || values['active'] == '1' ? '1' : '0';

    // values['delRights'] =
    // values['delRights'] == 'true' || values['delRights'] == 'Y'
    //     ? 'Y'
    //     : 'N';
    bool success;
    if (_isEditMode && _selectedRow != null) {
      final raw = _selectedRow!['_raw'] as PurityGroupModel;
      success = await provider.update(raw.purityGroupCode!, values);
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
            ? 'Purity Group updated successfully.'
            : 'Purity Group saved successfully.',
      );
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(_isEditMode
      //         ? 'Purity Group updated successfully'
      //         : 'Purity Group saved successfully'),
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
    final raw = _selectedRow?['_raw'] as PurityGroupModel?;
    if (raw?.purityGroupCode == null) return;
    final confirm = await ErpDeleteDialog.show(context: context, theme: _theme, title: 'Purity Group', itemName: raw!.purityGroupName??"");

    // final confirm = await showDialog<bool>(
    //   context: context,
    //   builder: (_) => AlertDialog(
    //     title: const Text('Delete Purity Group'),
    //     content: Text(
    //         'Delete "${raw!.purityGroupName}"? This cannot be undone.'),
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
        .read<PurityGroupProvider>()
        .delete(raw.purityGroupCode!);

    if (success && mounted) {
      _resetForm();
      await ErpResultDialog.showDeleted(
        context: context,
        theme: _theme,
        itemName: raw.purityGroupName ?? '',
      );
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: const Text('Purity Group deleted successfully'),
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
    _setDefaultSortId();
  }
  bool _showTableOnMobile = false;

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {

    final companyProvider = context.watch<CompanyProvider>();
    final purityTypeProvider = context.watch<PurityTypeProvider>();

    return Consumer<PurityGroupProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child:
              Responsive.isMobile(context)?_showTableOnMobile?ErpDataTable(
                isReportRow: false,

                token: token ?? '',
                url: baseUrl,
                title: 'PURITY GROUP LIST',
                columns: _tableColumns,
                data: provider.tableData,
                // theme: _theme,
                showSearch: true,
                showFooterTotals: false,
                selectedRow: _selectedRow,
                onRowTap: _onRowTap,
                emptyMessage: provider.isLoaded
                    ? 'No Purity Group found'
                    : 'Loading...',
              ):ErpForm(
                onExit: () {
                  context.read<TabProvider>().closeCurrentTab();
                },
                logo: AppImages.logo,

                key: _erpFormKey,
                title: 'PURITY GROUP MASTER',
                subtitle: 'Purity Group Information',
                initialTabIndex: 0,
                onSearch: () => setState(() => _showTableOnMobile = true),

                tabBarBackgroundColor: const Color(0xfff2f0ef),
                tabBarSelectedColor: _theme.primaryGradient.first,
                tabBarSelectedTxtColor: Colors.white,
                rows: _formRows(companyProvider,purityTypeProvider),
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
                  title: 'PURITY GROUP MASTER',
                  subtitle: 'Purity Group Information',
                  initialTabIndex: 0,
                  tabBarBackgroundColor: const Color(0xfff2f0ef),
                  tabBarSelectedColor: _theme.primaryGradient.first,
                  tabBarSelectedTxtColor: Colors.white,
                  rows: _formRows(companyProvider,purityTypeProvider),
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
                  title: 'PURITY GROUP LIST',
                  columns: _tableColumns,
                  data: provider.tableData,
                  // theme: _theme,
                  showSearch: true,
                  showFooterTotals: false,
                  selectedRow: _selectedRow,
                  onRowTap: _onRowTap,
                  emptyMessage: provider.isLoaded
                      ? 'No Purity Group found'
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