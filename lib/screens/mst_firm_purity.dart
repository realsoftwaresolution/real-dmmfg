import 'package:diam_mfg/providers/purity_provider.dart';
import 'package:diam_mfg/providers/purity_group_provider.dart';
import 'package:diam_mfg/providers/purity_rpt_group_provider.dart';
import 'package:diam_mfg/providers/company_provider.dart';
import 'package:erp_data_table/erp_data_table.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rs_dashboard/rs_dashboard.dart';

import '../models/purity_model.dart';
import '../utils/app_images.dart';
import '../utils/delete_dialogue.dart';
import '../utils/msg_dialogue.dart';

class MstPurity extends StatefulWidget {
  const MstPurity({super.key});

  @override
  State<MstPurity> createState() => _MstPurityState();
}

class _MstPurityState extends State<MstPurity> {
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
    ErpColumnConfig(key: 'purityCode', label: 'CODE', width: 130),
    ErpColumnConfig(key: 'purityName', label: 'NAME', width: 180),
    ErpColumnConfig(key: 'purityGroupCode', label: 'GROUP', width: 140),
    ErpColumnConfig(key: 'purityRptGroupCode', label: 'RPT GROUP', width: 180),
    ErpColumnConfig(key: 'labourRate', label: 'LABOUR RATE', width: 200),
    ErpColumnConfig(key: 'companyCode', label: 'COMPANY', width: 160),
    ErpColumnConfig(key: 'sortID', label: 'SORT ID', width: 160),
    ErpColumnConfig(key: 'active', label: 'ACTIVE', width: 140),
  ];

  // ── FORM ROWS ─────────────────────────────────────────────────────────────
  List<List<ErpFieldConfig>> _formRows(
      CompanyProvider companyProvider,
      PurityGroupProvider purityGroupProvider,
      PurityRptGroupProvider purityRptGroupProvider,
      ) =>
      [
        /// ── BASIC INFO ──
        [
          // ErpFieldConfig(
          //   key: 'purityCode',
          //   label: 'CODE',
          //   type: ErpFieldType.number,
          //   required: true,
          //   sectionTitle: 'BASIC INFORMATION',
          //   sectionIndex: 0,
          // ),
          ErpFieldConfig(
            key: 'purityName',
            label: 'NAME',
            required: true,
            sectionIndex: 0,
          ),
        ],

        [
          ErpFieldConfig(
            key: 'purityGroupCode',
            label: 'PURITY GROUP',
            type: ErpFieldType.dropdown,
            dropdownItems: purityGroupProvider.list
                .where((element) {
              return element.active==true;
            },).map((e) {
              return ErpDropdownItem(
                label: e.purityGroupName ?? '',
                value: e.purityGroupCode?.toString() ?? '',
              );
            }).toList(),
            sectionIndex: 0,
          ),
          ErpFieldConfig(
            key: 'purityRptGroupCode',
            label: 'PURITY RPT GROUP',
            type: ErpFieldType.dropdown,
            dropdownItems: purityRptGroupProvider.list
                .where((element) {
              return element.active==true;
            },).map((e) {
              return ErpDropdownItem(
                label: e.purityRptGroupName ?? '',
                value: e.purityRptGroupCode?.toString() ?? '',
              );
            }).toList(),
            sectionIndex: 0,
          ),
        ],

        [
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
          ErpFieldConfig(
            key: 'sortID',
            label: 'SORT ID',
            type: ErpFieldType.number,
            sectionIndex: 0,
          ),
        ],

        /// ── GRADING & REPORT ──
        // [
        //   ErpFieldConfig(
        //     key: 'purityGraddingGroup',
        //     label: 'GRADING GROUP',
        //     sectionTitle: 'GRADING & REPORT',
        //     sectionIndex: 1,
        //   ),
        //   ErpFieldConfig(
        //     key: 'reportGroup',
        //     label: 'REPORT GROUP',
        //     sectionIndex: 1,
        //   ),
        // ],

        /// ── RATE & SETTINGS ──
        [
          ErpFieldConfig(
            key: 'labourRate',
            label: 'LABOUR RATE',
            type: ErpFieldType.number,
            sectionTitle: 'RATE & SETTINGS',
            sectionIndex: 2,
          ),
        ],

        [
          ErpFieldConfig(
            key: 'active',
            label: 'ACTIVE',
            type: ErpFieldType.checkbox,
            sectionIndex: 2,
            checkboxDbType: 'BIT'
          ),
          ErpFieldConfig(
            key: 'pg',
              label: 'POLISH GRADE',
            type: ErpFieldType.checkbox,
            sectionIndex: 2,
            checkboxDbType: 'BIT'
          ),
        ],
      ];

  // // ── INIT ──────────────────────────────────────────────────────────────────
  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     context.read<PurityProvider>().load();
  //     context.read<CompanyProvider>().loadCompanies();
  //     context.read<PurityGroupProvider>().load();
  //     context.read<PurityRptGroupProvider>().load();
  //   });
  // }
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<PurityGroupProvider>().load();
      context.read<PurityRptGroupProvider>().load();
      // ← pehle companies load karo aur AWAIT karo
      await context.read<CompanyProvider>().loadCompanies();

      if (!mounted) return;

      // ← ab companies available hain, division provider ko pass karo
      final companies = context.read<CompanyProvider>().companies;
      context.read<PurityProvider>().setCompanies(companies);

      // ← last mein divisions load karo
      await context.read<PurityProvider>().load();

    });
  }
  // ── ROW TAP ───────────────────────────────────────────────────────────────
  void _onRowTap(Map<String, dynamic> row) {
    final raw = row['_raw'] as PurityModel;

    setState(() {
      _selectedRow = row;
      _isEditMode = true;
      _formValues = {
        'purityCode': raw.purityCode?.toString() ?? '',
        'purityName': raw.purityName ?? '',
        'purityGroupCode': raw.purityGroupCode?.toString() ?? '',
        'purityRptGroupCode': raw.purityRptGroupCode?.toString() ?? '',
        'companyCode': raw.companyCode?.toString() ?? '',
        'sortID': raw.sortID?.toString() ?? '',
        'labourRate': raw.labourRate?.toString() ?? '',
        'pg': raw.pg == true ? 'true' : 'false',
        'purityGraddingGroup': raw.purityGraddingGroup ?? '',
        'reportGroup': raw.reportGroup ?? '',
        'active': raw.active == true ? 'true' : 'false',
      };
    });
    if (Responsive.isMobile(context)) {
      setState(() => _showTableOnMobile = false);
    }
  }

  // ── SAVE ──────────────────────────────────────────────────────────────────
  Future<void> _onSave(Map<String, dynamic> values) async {
    final provider = context.read<PurityProvider>();

    bool success;
    if (_isEditMode && _selectedRow != null) {
      final raw = _selectedRow!['_raw'] as PurityModel;
      success = await provider.update(raw.purityCode!, values);
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
            ? 'Purity updated successfully.'
            : 'Purity saved successfully.',
      );
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(_isEditMode
      //         ? 'Purity updated successfully'
      //         : 'Purity saved successfully'),
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
    final raw = _selectedRow?['_raw'] as PurityModel?;
    if (raw?.purityCode == null) return;
    final confirm = await ErpDeleteDialog.show(context: context, theme: _theme, title: 'Purity', itemName: raw!.purityName??"");

    // final confirm = await showDialog<bool>(
    //   context: context,
    //   builder: (_) => AlertDialog(
    //     title: const Text('Delete Purity'),
    //     content:
    //     Text('Delete "${raw!.purityName}"? This cannot be undone.'),
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
    await context.read<PurityProvider>().delete(raw!.purityCode!);

    if (success && mounted) {
      _resetForm();
      await ErpResultDialog.showDeleted(
        context: context,
        theme: _theme,
        itemName: raw.purityName ?? '',
      );
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: const Text('Purity deleted successfully'),
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
    final purityGroupProvider = context.watch<PurityGroupProvider>();
    final purityRptGroupProvider = context.watch<PurityRptGroupProvider>();

    return Consumer<PurityProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child:
              Responsive.isMobile(context)?_showTableOnMobile?ErpDataTable(
                isReportRow: false,

                token: token ?? '',
                url: 'http://50.62.183.116:5000',
                title: 'PURITY LIST',
                columns: _tableColumns,
                data: provider.tableData,
                // theme: _theme,
                showSearch: true,
                showFooterTotals: false,
                selectedRow: _selectedRow,
                onRowTap: _onRowTap,
                emptyMessage: provider.isLoaded
                    ? 'No Purity found'
                    : 'Loading...',
              ):ErpForm(
                logo: AppImages.logo,

                key: _erpFormKey,
                title: 'PURITY MASTER',
                subtitle: 'Purity Information',
                initialTabIndex: 0,
                onSearch: () => setState(() => _showTableOnMobile = true),

                tabBarBackgroundColor: const Color(0xfff2f0ef),
                tabBarSelectedColor: _theme.primaryGradient.first,
                tabBarSelectedTxtColor: Colors.white,
                rows: _formRows(
                  companyProvider,
                  purityGroupProvider,
                  purityRptGroupProvider,
                ),
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
                  title: 'PURITY MASTER',
                  subtitle: 'Purity Information',
                  initialTabIndex: 0,
                  tabBarBackgroundColor: const Color(0xfff2f0ef),
                  tabBarSelectedColor: _theme.primaryGradient.first,
                  tabBarSelectedTxtColor: Colors.white,
                  rows: _formRows(
                    companyProvider,
                    purityGroupProvider,
                    purityRptGroupProvider,
                  ),
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
                  title: 'PURITY LIST',
                  columns: _tableColumns,
                  data: provider.tableData,
                  // theme: _theme,
                  showSearch: true,
                  showFooterTotals: false,
                  selectedRow: _selectedRow,
                  onRowTap: _onRowTap,
                  emptyMessage: provider.isLoaded
                      ? 'No Purity found'
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