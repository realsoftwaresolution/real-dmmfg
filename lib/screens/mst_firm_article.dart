import 'package:diam_mfg/providers/article_provider.dart';
import 'package:diam_mfg/providers/company_provider.dart';
import 'package:diam_mfg/utils/app_images.dart';
import 'package:diam_mfg/utils/delete_dialogue.dart';
import 'package:erp_data_table/erp_data_table.dart';
import 'package:erp_data_table/erp_data_table/widgets/erp_buttons.dart'
    hide Responsive;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rs_dashboard/rs_dashboard.dart';

import '../models/article_model.dart';
import '../utils/msg_dialogue.dart';

class MstArticle extends StatefulWidget {
  const MstArticle({super.key});

  @override
  State<MstArticle> createState() => _MstArticleState();
}

class _MstArticleState extends State<MstArticle> {
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
    ErpColumnConfig(key: 'articalCode', label: 'CODE', width: 130),
    ErpColumnConfig(key: 'articalName', label: 'NAME', width: 220),
    ErpColumnConfig(key: 'companyCode', label: 'COMPANY', width: 160),
    ErpColumnConfig(key: 'sortID', label: 'SORT ID', width: 160),
    ErpColumnConfig(key: 'active', label: 'ACTIVE', width: 140),
  ];

  // ── FORM ROWS ─────────────────────────────────────────────────────────────
  List<List<ErpFieldConfig>> _formRows(CompanyProvider companyProvider) => [
    /// ── BASIC INFO ──
    [
      // ErpFieldConfig(
      //   key: 'articalCode',
      //   label: 'CODE',
      //   type: ErpFieldType.number,
      //   required: true,
      //   sectionTitle: 'BASIC INFORMATION',
      //   sectionIndex: 0,
      // ),
      ErpFieldConfig(
        key: 'articalName',
        label: 'NAME',
        required: true,
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
              return element.active == true;
            })
            .map((e) {
              return ErpDropdownItem(
                label: e.companyName ?? '',
                value: e.companyCode?.toString() ?? '',
              );
            })
            .toList(),
        sectionIndex: 0,
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
        checkboxDbType: 'BIT',
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

      // ← ab companies available hain, division provider ko pass karo
      final companies = context.read<CompanyProvider>().companies;
      context.read<ArticleProvider>().setCompanies(companies);

      // ← last mein divisions load karo
      await context.read<ArticleProvider>().load();
    });
  }

  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     context.read<ArticleProvider>().load();
  //     context.read<CompanyProvider>().loadCompanies();
  //   });
  // }

  // ── ROW TAP ───────────────────────────────────────────────────────────────
  void _onRowTap(Map<String, dynamic> row) {
    final raw = row['_raw'] as ArticleModel;

    setState(() {
      _selectedRow = row;
      _isEditMode = true;
      _formValues = {
        'articalCode': raw.articalCode?.toString() ?? '',
        'articalName': raw.articalName ?? '',
        'companyCode': raw.companyCode?.toString() ?? '',
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
    final provider = context.read<ArticleProvider>();

    bool success;
    if (_isEditMode && _selectedRow != null) {
      final raw = _selectedRow!['_raw'] as ArticleModel;
      success = await provider.update(raw.articalCode!, values);
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
            ? 'Article updated successfully.'
            : 'Article saved successfully.',
      );
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(_isEditMode
      //         ? 'Article updated successfully'
      //         : 'Article saved successfully'),
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
    final raw = _selectedRow?['_raw'] as ArticleModel?;
    if (raw?.articalCode == null) return;
    final confirm = await ErpDeleteDialog.show(
      context: context,
      theme: _theme,
      title: 'Article',
      itemName: raw!.articalName ?? "",
    );
    // final confirm = await showDialog<bool>(
    //   context: context,
    //   builder: (_) => AlertDialog(
    //     title: const Text('Delete Article'),
    //     content:
    //     Text('Delete "${raw!.articalName}"? This cannot be undone.'),
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

    final success = await context.read<ArticleProvider>().delete(
      raw!.articalCode!,
    );

    if (success && mounted) {
      _resetForm();
      await ErpResultDialog.showDeleted(
        context: context,
        theme: _theme,
        itemName: raw.articalName ?? '',
      );
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: const Text('Article deleted successfully'),
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

    return Consumer<ArticleProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child: Responsive.isMobile(context)
              ? _showTableOnMobile
                    ? ErpDataTable(
                        isReportRow: false,

                        token: token ?? '',
                        url: 'http://50.62.183.116:5000',
                        title: 'ARTICLE LIST',
                        columns: _tableColumns,
                        data: provider.tableData,
                        // theme: _theme,
                        showSearch: true,
                        showFooterTotals: false,
                        selectedRow: _selectedRow,
                        onRowTap: _onRowTap,
                        emptyMessage: provider.isLoaded
                            ? 'No Article found'
                            : 'Loading...',
                      )
                    : ErpForm(
                        logo: AppImages.logo,
                        key: _erpFormKey,
                        title: 'ARTICLE MASTER',
                        subtitle: 'Article Information',
                        initialTabIndex: 0,
                        tabBarBackgroundColor: const Color(0xfff2f0ef),
                        tabBarSelectedColor: _theme.primaryGradient.first,
                        tabBarSelectedTxtColor: Colors.white,
                        rows: _formRows(companyProvider),
                        // theme: _theme,
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
                        logo: AppImages.logo,

                        key: _erpFormKey,
                        title: 'ARTICLE MASTER',
                        subtitle: 'Article Information',
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

                    // ── RIGHT: Table ──────────────────────────────────────
                    Expanded(
                      flex: 2,
                      child: ErpDataTable(
                        isReportRow: false,
                        token: token ?? '',
                        url: 'http://50.62.183.116:5000',
                        title: 'ARTICLE LIST',
                        columns: _tableColumns,
                        data: provider.tableData,
                        // theme: _theme,
                        showSearch: true,
                        showFooterTotals: false,
                        selectedRow: _selectedRow,
                        onRowTap: _onRowTap,
                        emptyMessage: provider.isLoaded
                            ? 'No Article found'
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
