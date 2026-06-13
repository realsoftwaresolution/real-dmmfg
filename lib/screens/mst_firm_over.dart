import 'package:diam_mfg/models/cut_model.dart';
import 'package:diam_mfg/models/intent_model.dart';
import 'package:diam_mfg/models/lab_model.dart';
import 'package:diam_mfg/models/over_model.dart';
import 'package:diam_mfg/providers/cut_provider.dart';
import 'package:diam_mfg/providers/company_provider.dart';
import 'package:diam_mfg/providers/certificate_provider.dart';
import 'package:diam_mfg/providers/intent_provider.dart';
import 'package:diam_mfg/services/duplicate_check_service.dart';
import 'package:diam_mfg/services/duplicate_utils.dart';
import 'package:diam_mfg/utils/constants.dart';
import 'package:erp_data_table/erp_data_table.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rs_dashboard/rs_dashboard.dart';

import '../bootstrap.dart';
import '../providers/over_provider.dart';
import '../utils/app_images.dart';
import '../utils/delete_dialogue.dart';
import '../utils/msg_dialogue.dart';

class MstOver extends StatefulWidget {
  const MstOver({super.key});

  @override
  State<MstOver> createState() => _MstOverState();
}

class _MstOverState extends State<MstOver> {
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
    ErpColumnConfig(key: 'fcOverCode', label: 'CODE', width: 130),
    ErpColumnConfig(key: 'fcOverName', label: 'FC OVER NAME', width: 220),
    ErpColumnConfig(key: 'CompanyName', label: 'COMPANY', width: 160),
    ErpColumnConfig(key: 'sortID', label: 'SORT ID', width: 160),
    ErpColumnConfig(key: 'active', label: 'ACTIVE', width: 140),
  ];

  void _setDefaultSortId() {
    final provider = context.read<OverProvider>();

    int nextSortId = 1;
    if (provider.cuts.isNotEmpty) {
      nextSortId =
          provider.cuts
              .map((e) => e.sortID ?? 0)
              .reduce((a, b) => a > b ? a : b) +
              1;
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

  // ── FORM ROWS ─────────────────────────────────────────────────────────────
  List<List<ErpFieldConfig>> _formRows(CompanyProvider companyProvider) => [
    /// ── BASIC INFO ──
    [
      ErpFieldConfig(
        key: 'fcOverName',
        label: 'FC OVER NAME',
        required: true,
        sectionIndex: 0,
        inputFormatters: [UpperCaseTextFormatter()],
        onDuplicateCheck: (value, allValues) async {
          return await _checkCutNameAndSortIdDuplicate(
            fields: {'FcOverName': value},
          );
        },
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
        sectionIndex: 1,
        initialBoolValue: true,
        checkboxDbType: 'BIT',
      ),
    ],
  ];

  Future<bool> _checkCutNameAndSortIdDuplicate({
    required Map<dynamic, dynamic> fields,
  }) async {
    /// ── SKIP SAME VALUE IN EDIT ───────────────
    final skip = shouldSkipDuplicateCheck(
      isEditMode: _isEditMode,
      selectedRow: _selectedRow,
      newFields: Map<String, dynamic>.from(fields),
      fieldMapping: {'FcOverName': 'fcOverName'},
    );

    if (skip) {
      return false;
    }

    /// ── API CHECK ─────────────────────────────
    return await checkDuplicateRecord(
      context: context,
      theme: _theme,
      formName: 'FcOver',
      fields: fields,
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // ← pehle companies load karo aur AWAIT karo
      await context.read<CompanyProvider>().loadCompanies();
      if (!mounted) return;
      final selectedCode = context.read<CompanyProvider>().selectedCompanyCode;
      context.read<OverProvider>().setSelectedCompany(selectedCode);
      // ← ab companies available hain, division provider ko pass karo
      final companies = context.read<CompanyProvider>().companies;
      context.read<OverProvider>().setCompanies(companies);
      // ← last mein divisions load karo
      await context.read<OverProvider>().loadOvers();
      _setDefaultSortId();
    });
  }

  // ── ROW TAP ───────────────────────────────────────────────────────────────
  void _onRowTap(Map<String, dynamic> row) {
    final raw = row['_raw'] as OverModel;

    setState(() {
      _selectedRow = row;
      _isEditMode = true;
      _formValues = {
        'fcOverCode': raw.fcOverCode?.toString() ?? '',
        'fcOverName': raw.fcOverName ?? '',
        'companyCode':
        context.read<CompanyProvider>().selectedCompanyCode?.toString() ??
            raw.companyCode?.toString() ??
            '',
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
    final exists = await _checkCutNameAndSortIdDuplicate(
      fields: {'FcOverName': values['fcOverName']},
    );
    if (exists) return;
    final provider = context.read<OverProvider>();

    bool success;
    if (_isEditMode && _selectedRow != null) {
      final raw = _selectedRow!['_raw'] as OverModel;
      success = await provider.updateOver(raw.fcOverMstID!, values);
    } else {
      success = await provider.createOver(values);
    }

    if (!mounted) return;

    if (success) {
      _resetForm();
      await ErpResultDialog.showSuccess(
        context: context,
        theme: _theme,
        title: _isEditMode ? 'Updated' : 'Saved',
        message: _isEditMode
            ? 'FC Over updated successfully.'
            : 'FC Over saved successfully.',
      );
    }
  }

  // ── DELETE ────────────────────────────────────────────────────────────────
  Future<void> _onDelete() async {
    final raw = _selectedRow?['_raw'] as OverModel?;
    if (raw?.fcOverCode == null) return;
    final confirm = await ErpDeleteDialog.show(
      context: context,
      theme: _theme,
      title: 'FC Over',
      itemName: raw!.fcOverName ?? "",
    );

    if (confirm != true || !mounted) return;

    final success = await context.read<OverProvider>().deleteOver(raw.fcOverMstID!);

    if (success && mounted) {
      _resetForm();
      await ErpResultDialog.showDeleted(
        context: context,
        theme: _theme,
        itemName: raw.fcOverName ?? '',
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

    return Consumer<OverProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child: Responsive.isMobile(context)
              ? _showTableOnMobile
              ? ErpDataTable(
            isReportRow: false,
            token: token ?? '',
            url: baseUrl,
            title: 'FC OVER LIST',
            columns: _tableColumns,
            data: provider.tableData,
            showSearch: true,
            showFooterTotals: false,
            selectedRow: _selectedRow,
            onRowTap: _onRowTap,
            emptyMessage: provider.isLoaded
                ? 'No overs found'
                : 'Loading...',
          )
              : ErpForm(
            onExit: () {
              context.read<TabProvider>().closeCurrentTab();
            },
            logo: AppImages.logo,
            key: _erpFormKey,
            title: 'FC OVER MASTER',
            subtitle: 'Fc Over Information',
            initialTabIndex: 0,
            onSearch: () =>
                setState(() => _showTableOnMobile = true),
            tabBarBackgroundColor: const Color(0xfff2f0ef),
            tabBarSelectedColor: _theme.primaryGradient.first,
            tabBarSelectedTxtColor: Colors.white,
            rows: _formRows(companyProvider),
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
                  title: 'FC OVER MASTER',
                  subtitle: 'Fc Over Information',
                  initialTabIndex: 0,
                  tabBarBackgroundColor: const Color(0xfff2f0ef),
                  tabBarSelectedColor: _theme.primaryGradient.first,
                  tabBarSelectedTxtColor: Colors.white,
                  rows: _formRows(companyProvider),
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
                  title: 'FC OVER LIST',
                  columns: _tableColumns,
                  data: provider.tableData,
                  showSearch: true,
                  showFooterTotals: false,
                  selectedRow: _selectedRow,
                  onRowTap: _onRowTap,
                  emptyMessage: provider.isLoaded
                      ? 'No overs found'
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
