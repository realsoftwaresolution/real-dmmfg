import 'package:diam_mfg/providers/charni_group_provider.dart';
import 'package:diam_mfg/providers/charni_provider.dart';
import 'package:diam_mfg/providers/company_provider.dart';
import 'package:diam_mfg/providers/dept_provider.dart';
import 'package:diam_mfg/providers/shape_provider.dart';
import 'package:erp_data_table/erp_data_table.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rs_dashboard/rs_dashboard.dart';

import '../models/charni_model.dart';
import '../utils/app_images.dart';
import '../utils/delete_dialogue.dart';
import '../utils/msg_dialogue.dart';

class MstCharni extends StatefulWidget {
  const MstCharni({super.key});

  @override
  State<MstCharni> createState() => _MstCharniState();
}

class _MstCharniState extends State<MstCharni> {
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
    ErpColumnConfig(key: 'charniCode', label: 'CODE', width: 130),
    ErpColumnConfig(key: 'charniName', label: 'NAME', width: 200),
    // ErpColumnConfig(key: 'charniGroup', label: 'GROUP', width: 150),
    ErpColumnConfig(key: 'companyCode', label: 'COMPANY', width: 160),
    ErpColumnConfig(key: 'sortID', label: 'SORT ID', width: 160),
    ErpColumnConfig(key: 'active', label: 'ACTIVE', width: 140),
  ];

  // ── FORM ROWS ─────────────────────────────────────────────────────────────
  List<List<ErpFieldConfig>> _formRows(CompanyProvider companyProvider,DeptProvider deptProvider,ShapeProvider shapeProvider,CharniGroupProvider charniGroupProvider) => [
    /// ── BASIC INFO ──
    [
      // ErpFieldConfig(
      //   key: 'charniCode',
      //   label: 'CODE',
      //   type: ErpFieldType.number,
      //   required: true,
      //   sectionTitle: 'BASIC INFORMATION',
      //   sectionIndex: 0,
      // ),
      ErpFieldConfig(
        key: 'charniName',
        sectionTitle: 'BASIC INFORMATION',
        label: 'NAME',
        required: true,
        sectionIndex: 0,
      ),
      ErpFieldConfig(
        key: 'charniRptGroupCode',
        label: 'REPORT GROUP CODE',
        type: ErpFieldType.dropdown,
        dropdownItems: charniGroupProvider.list
            .where((element) {
          return element.active==true;
        },).map((e) {
          return ErpDropdownItem(
            label: e.charniGroupName ?? '',
            value: e.charniGroupCode?.toString() ?? '',
          );
        }).toList(),
        sectionIndex: 0,
      ),
    ],

    // [
    //   // ErpFieldConfig(
    //   //   key: 'charniGroup',
    //   //   label: 'CHARNI GROUP',
    //   //   sectionIndex: 0,
    //   // ),
    //
    // ],

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

    /// ── SIZE RANGE ──
    [
      ErpFieldConfig(
        key: 'fromSize',
        label: 'FROM SIZE',
        type: ErpFieldType.number,
        sectionTitle: 'SIZE RANGE',
        sectionIndex: 1,
      ),
      ErpFieldConfig(
        key: 'toSize',
        label: 'TO SIZE',
        type: ErpFieldType.number,
        sectionIndex: 1,
      ),
    ],

    [
      // ErpFieldConfig(
      //   key: 'shapeCode',
      //   label: 'SHAPE CODE',
      //   type: ErpFieldType.number,
      //   sectionIndex: 1,
      // ),
      ErpFieldConfig(
        key: 'shapeCode',
        label: 'SHAPE CODE',
        type: ErpFieldType.dropdown,
        dropdownItems: shapeProvider.list
            .where((element) {
          return element.active==true;
        },).map((e) {
          return ErpDropdownItem(
            label: e.shapeName ?? '',
            value: e.shapeCode?.toString() ?? '',
          );
        }).toList(),
        // dropdownItems:companyProvider
        //     .companies
        //     .map((e) => e.companyName.toString())
        //     .toList(),
        sectionIndex: 1,

      ),
      // ErpFieldConfig(
      //   key: 'deptCode',
      //   label: 'DEPT CODE',
      //   type: ErpFieldType.number,
      //   sectionIndex: 1,
      // ),
      ErpFieldConfig(
        key: 'deptCode',
        label: 'DEPT CODE',
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
        // dropdownItems:companyProvider
        //     .companies
        //     .map((e) => e.companyName.toString())
        //     .toList(),
        sectionIndex: 1,

      ),
    ],

    /// ── SETTINGS ──
    [
      ErpFieldConfig(
        key: 'active',
        label: 'ACTIVE',
        type: ErpFieldType.checkbox,
        sectionTitle: 'SETTINGS',
        sectionIndex: 2,
        checkboxDbType: 'BIT'
      ),
      ErpFieldConfig(
        key: 'pg',
        label: 'PG',
        type: ErpFieldType.checkbox,
        sectionIndex: 2,
        checkboxDbType: 'BIT'
      ),
    ],
  ];

  // ── INIT ──────────────────────────────────────────────────────────────────
  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     context.read<CharniProvider>().load();
  //     context.read<CompanyProvider>().loadCompanies();
  //     context.read<ShapeProvider>().load();
  //     context.read<DeptProvider>().load();
  //   });
  // }
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // ← pehle companies load karo aur AWAIT karo
      await context.read<CompanyProvider>().loadCompanies();
      context.read<ShapeProvider>().load();
      context.read<DeptProvider>().load();
      context.read<CharniGroupProvider>().load();

      if (!mounted) return;

      // ← ab companies available hain, division provider ko pass karo
      final companies = context.read<CompanyProvider>().companies;
      context.read<CharniProvider>().setCompanies(companies);

      // ← last mein divisions load karo
      await context.read<CharniProvider>().load();

    });
  }
  // ── ROW TAP ───────────────────────────────────────────────────────────────
  void _onRowTap(Map<String, dynamic> row) {
    final raw = row['_raw'] as CharniModel;

    setState(() {
      _selectedRow = row;
      _isEditMode = true;
      _formValues = {
        'charniCode': raw.charniCode?.toString() ?? '',
        'charniName': raw.charniName ?? '',
        'charniGroup': raw.charniGroup ?? '',
        'charniRptGroupCode': raw.charniRptGroupCode?.toString() ?? '',
        'companyCode': raw.companyCode?.toString() ?? '',
        'sortID': raw.sortID?.toString() ?? '',
        'fromSize': raw.fromSize?.toString() ?? '',
        'toSize': raw.toSize?.toString() ?? '',
        'shapeCode': raw.shapeCode?.toString() ?? '',
        'deptCode': raw.deptCode?.toString() ?? '',
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
    final provider = context.read<CharniProvider>();

    bool success;
    if (_isEditMode && _selectedRow != null) {
      final raw = _selectedRow!['_raw'] as CharniModel;
      success = await provider.update(raw.charniCode!, values);
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
            ? 'Charni updated successfully.'
            : 'Charni saved successfully.',
      );
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(_isEditMode
      //         ? 'Charni updated successfully'
      //         : 'Charni saved successfully'),
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
    final raw = _selectedRow?['_raw'] as CharniModel?;
    if (raw?.charniCode == null) return;
    final confirm = await ErpDeleteDialog.show(context: context, theme: _theme, title: 'Charni', itemName: raw!.charniName??"");

    // final confirm = await showDialog<bool>(
    //   context: context,
    //   builder: (_) => AlertDialog(
    //     title: const Text('Delete Charni'),
    //     content: Text(
    //         'Delete "${raw!.charniName}"? This cannot be undone.'),
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
    await context.read<CharniProvider>().delete(raw!.charniCode!);

    if (success && mounted) {
      _resetForm();
      await ErpResultDialog.showDeleted(
        context: context,
        theme: _theme,
        itemName: raw.charniName ?? '',
      );
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: const Text('Charni deleted successfully'),
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
  }
  bool _showTableOnMobile = false;

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final companyProvider = context.watch<CompanyProvider>();
    final deptProvider = context.watch<DeptProvider>();
    final shapeProvider = context.watch<ShapeProvider>();
    final charniGroupProvider = context.watch<CharniGroupProvider>();

    return Consumer<CharniProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child:
              Responsive.isMobile(context)?_showTableOnMobile?ErpDataTable(
                isReportRow: false,

                token: token ?? '',
                url: 'http://50.62.183.116:5000',
                title: 'CHARNI LIST',
                columns: _tableColumns,
                data: provider.tableData,
                // theme: _theme,
                showSearch: true,
                showFooterTotals: false,
                selectedRow: _selectedRow,
                onRowTap: _onRowTap,
                emptyMessage: provider.isLoaded
        ? 'No Charni found'
        : 'Loading...',
              ): ErpForm(
                logo: AppImages.logo,

                key: _erpFormKey,
                title: 'CHARNI MASTER',
                subtitle: 'Charni Information',
                initialTabIndex: 0,
                onSearch: () => setState(() => _showTableOnMobile = true),

                tabBarBackgroundColor: const Color(0xfff2f0ef),
                tabBarSelectedColor: _theme.primaryGradient.first,
                tabBarSelectedTxtColor: Colors.white,
                rows: _formRows(companyProvider,deptProvider,shapeProvider,charniGroupProvider),
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
                  title: 'CHARNI MASTER',
                  subtitle: 'Charni Information',
                  initialTabIndex: 0,
                  tabBarBackgroundColor: const Color(0xfff2f0ef),
                  tabBarSelectedColor: _theme.primaryGradient.first,
                  tabBarSelectedTxtColor: Colors.white,
                  rows: _formRows(companyProvider,deptProvider,shapeProvider,charniGroupProvider),
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
                  title: 'CHARNI LIST',
                  columns: _tableColumns,
                  data: provider.tableData,
                  // theme: _theme,
                  showSearch: true,
                  showFooterTotals: false,
                  selectedRow: _selectedRow,
                  onRowTap: _onRowTap,
                  emptyMessage: provider.isLoaded
                      ? 'No Charni found'
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