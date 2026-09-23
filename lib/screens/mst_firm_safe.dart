import 'package:diam_mfg/providers/company_provider.dart';
import 'package:diam_mfg/providers/safe_provider.dart';
import 'package:diam_mfg/services/duplicate_check_service.dart';
import 'package:diam_mfg/services/duplicate_utils.dart';
import 'package:diam_mfg/utils/app_images.dart';
import 'package:diam_mfg/utils/constants.dart';
import 'package:diam_mfg/utils/delete_dialogue.dart';
import 'package:erp_data_table/erp_data_table.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rs_dashboard/rs_dashboard.dart';

import '../bootstrap.dart';
import '../models/safe_model.dart';
import '../utils/msg_dialogue.dart';

class MstSafe extends StatefulWidget {
  const MstSafe({super.key});

  @override
  State<MstSafe> createState() => _MstSafeState();
}

class _MstSafeState extends State<MstSafe> {
  // ── Theme ─────────────────────────────────────────────────────────────────
  final ErpThemeVariant _themeVariant = ErpThemeVariant.frost;

  ErpTheme get _theme => ErpTheme(_themeVariant);

  // ── State ─────────────────────────────────────────────────────────────────
  final GlobalKey<ErpFormState> _erpFormKey = GlobalKey<ErpFormState>();
  Map<String, dynamic>? _selectedRow;
  bool _isEditMode = false;
  Map<String, String> _formValues = {};

  final String? token = AppStorage.getString("token");

  // ── TABLE COLUMNS ─────────────────────────────────────────────────────────
  List<ErpColumnConfig> get _tableColumns => [
    ErpColumnConfig(key: 'safeCode', label: 'CODE', width: 130),
    ErpColumnConfig(key: 'safeName', label: 'NAME', width: 220),
    ErpColumnConfig(key: 'companyCode', label: 'COMPANY', width: 160),
    ErpColumnConfig(key: 'sortID', label: 'SORT ID', width: 160),
    ErpColumnConfig(key: 'active', label: 'ACTIVE', width: 140),
  ];

  // ── FORM ROWS ─────────────────────────────────────────────────────────────
  List<List<ErpFieldConfig>> _formRows(CompanyProvider companyProvider) => [
    /// ── BASIC INFO ──
    [
      ErpFieldConfig(
        key: 'safeName',
        label: 'NAME',
        required: true,
        sectionIndex: 0,
        inputFormatters: [
          UpperCaseTextFormatter(),
        ],
        // onDuplicateCheck: (value, allValues) async {
        //   return await _checkNameAndSortIdDuplicate(
        //     fields: {
        //       'SafeName': value,
        //     },
        //   );
        // },
      ),
      ErpFieldConfig(
        key: 'sortID',
        label: 'SORT ID',
        type: ErpFieldType.number,
        sectionIndex: 0,
      ),
    ],

    /// ── SETTINGS ──
    [
      ErpFieldConfig(
        key: 'active',
        label: 'ACTIVE',
        type: ErpFieldType.checkbox,
        sectionTitle: 'SETTINGS',
        initialBoolValue: true,
        sectionIndex: 1,
        checkboxDbType: 'BIT',
      ),
    ],
  ];

  Future<bool> _checkNameAndSortIdDuplicate({
    required Map<dynamic, dynamic> fields,
  }) async {
    /// ── SKIP SAME VALUE IN EDIT ───────────────
    final skip = shouldSkipDuplicateCheck(
      isEditMode: _isEditMode,
      selectedRow: _selectedRow,
      newFields: Map<String, dynamic>.from(fields),
      fieldMapping: {
        'SafeName': 'safeName',
      },
    );

    if (skip) {
      return false;
    }
    /// ── API CHECK ─────────────────────────────
    return await checkDuplicateRecord(
      context: context,
      theme: _theme,
      formName: 'Safe',
      fields: fields,
    );
  }

  void _setDefaultSortId() {
    final provider = context.read<SafeProvider>();

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
      final selectedCode = context.read<CompanyProvider>().selectedCompanyCode;
      context.read<SafeProvider>().setSelectedCompany(selectedCode);
      final companies = context.read<CompanyProvider>().companies;
      context.read<SafeProvider>().setCompanies(companies);

      await context.read<SafeProvider>().load();
      _setDefaultSortId();
    });
  }

  // ── ROW TAP ───────────────────────────────────────────────────────────────
  void _onRowTap(Map<String, dynamic> row) {
    final raw = row['_raw'] as SafeModel;

    setState(() {
      _selectedRow = row;
      _isEditMode = true;
      _formValues = {
        'safeCode': raw.safeCode?.toString() ?? '',
        'safeName': raw.safeName ?? '',
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
    // final exists = await _checkNameAndSortIdDuplicate(
    //   fields: {
    //     'SafeName': values['safeName'],
    //   },
    // );
    // if (exists) return;
    final provider = context.read<SafeProvider>();

    bool success;
    if (_isEditMode && _selectedRow != null) {
      final raw = _selectedRow!['_raw'] as SafeModel;
      success = await provider.update(raw.safeCode!, values);
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
            ? 'Safe updated successfully.'
            : 'Safe saved successfully.',
      );
    }
  }

  // ── DELETE ────────────────────────────────────────────────────────────────
  Future<void> _onDelete() async {
    final raw = _selectedRow?['_raw'] as SafeModel?;
    if (raw?.safeCode == null) return;
    final confirm = await ErpDeleteDialog.show(
      context: context,
      theme: _theme,
      title: 'Safe',
      itemName: raw!.safeName ?? "",
    );

    if (confirm != true || !mounted) return;

    final success = await context.read<SafeProvider>().delete(
      raw.safeCode!,
    );

    if (success && mounted) {
      _resetForm();
      await ErpResultDialog.showDeleted(
        context: context,
        theme: _theme,
        itemName: raw.safeName ?? '',
      );
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
    _formValues['active'] = 'true';
    _erpFormKey.currentState?.updateFieldValue('active', 'true');
    _setDefaultSortId();
  }

  bool _showTableOnMobile = false;

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final companyProvider = context.watch<CompanyProvider>();

    return Consumer<SafeProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child: Responsive.isMobile(context)
              ? _showTableOnMobile
                  ? ErpDataTable(
                      isReportRow: false,
                      token: token ?? '',
                      url: baseUrl,
                      title: 'SAFE LIST',
                      columns: _tableColumns,
                      data: provider.tableData,
                      showSearch: true,
                      showFooterTotals: false,
                      selectedRow: _selectedRow,
                      onRowTap: _onRowTap,
                      emptyMessage: provider.isLoaded
                          ? 'No Safe found'
                          : 'Loading...',
                    )
                  : ErpForm(
                      logo: AppImages.logo,
                      key: _erpFormKey,
                      onExit: () {
                        context.read<TabProvider>().closeCurrentTab();
                      },
                      title: 'SAFE MASTER',
                      subtitle: 'Safe Information',
                      initialTabIndex: 0,
                      tabBarBackgroundColor: const Color(0xfff2f0ef),
                      tabBarSelectedColor: _theme.primaryGradient.first,
                      tabBarSelectedTxtColor: Colors.white,
                      rows: _formRows(companyProvider),
                      initialValues: _formValues,
                      isEditMode: _isEditMode,
                      onSearch: () =>
                          setState(() => _showTableOnMobile = true),
                      onFieldChanged: (key, value) {
                        _formValues[key] = value;
                      },
                      onSave: _onSave,
                      onCancel: _resetForm,
                      onDelete: _isEditMode ? _onDelete : null,
                    )
              : Row(
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
                        title: 'SAFE MASTER',
                        subtitle: 'Safe Information',
                        initialTabIndex: 0,
                        tabBarBackgroundColor: const Color(0xfff2f0ef),
                        tabBarSelectedColor: _theme.primaryGradient.first,
                        tabBarSelectedTxtColor: Colors.white,
                        rows: _formRows(companyProvider),
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
                        title: 'SAFE LIST',
                        columns: _tableColumns,
                        data: provider.tableData,
                        showSearch: true,
                        showFooterTotals: false,
                        selectedRow: _selectedRow,
                        onRowTap: _onRowTap,
                        emptyMessage: provider.isLoaded
                            ? 'No Safe found'
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
