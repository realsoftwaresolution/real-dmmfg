// lib/screens/mst_firm_company.dart

import 'package:erp_data_table/erp_data_table.dart';
import 'package:erp_formatter/erp_formatter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rs_dashboard/rs_dashboard.dart';

import '../bootstrap.dart';
import '../models/company_model.dart';
import '../providers/company_provider.dart';
import '../utils/app_images.dart';
import '../utils/delete_dialogue.dart';
import '../utils/msg_dialogue.dart';

class MstFirmCompany extends StatefulWidget {
  const MstFirmCompany({super.key});

  @override
  State<MstFirmCompany> createState() => _MstFirmCompanyState();
}

class _MstFirmCompanyState extends State<MstFirmCompany> {
  // ── Theme ─────────────────────────────────────────────────────────────────
  ErpThemeVariant _themeVariant = ErpThemeVariant.frost;
  ErpTheme get _theme => ErpTheme(_themeVariant);

  // ── State (same as PurchaseDemo) ──────────────────────────────────────────
  final GlobalKey<ErpFormState> _erpFormKey = GlobalKey<ErpFormState>();
  Map<String, dynamic>? _selectedRow;
  bool _isEditMode = false;
  Map<String, String> _formValues = {};

  final String? token = AppStorage.getString("token");

  // ── TABLE COLUMNS ─────────────────────────────────────────────────────────
  List<ErpColumnConfig> get _tableColumns => [
     ErpColumnConfig(
      key: 'companyCode',
      label: 'CODE',
      // flex: 1,
      width: 100,

      required: true,
    ),
     ErpColumnConfig(
      key: 'companyName',
      label: 'COMPANY NAME',
      width: 200,
      // flex: 1,
      required: true,
    ),
     ErpColumnConfig(
      key: 'contactPerson',
      label: 'CONTACT PERSON',
      width: 220,
      // flex: 1,
    ),
     ErpColumnConfig(
      key: 'phone',
      label: 'PHONE',
      flex: 1.0,

    ),
     ErpColumnConfig(
      key: 'gstNo',
      label: 'GST NO',
      width: 160,
      flex: 1,
    ),
     ErpColumnConfig(
      key: 'state',
      label: 'STATE',
      flex: 1,
    ),
     ErpColumnConfig(
      key: 'active',
      label: 'ACTIVE',
      flex: 1,
      align: ColumnAlign.center,

    ),
    ErpColumnConfig(key: 'emailID',   label: 'EMAIL',      flex: 1.5),
    ErpColumnConfig(key: 'panNo',      label: 'PAN NO',     flex: 1.0),
    ErpColumnConfig(key: 'bankName',   label: 'BANK',       flex: 1.2),
    ErpColumnConfig(key: 'branchName', label: 'BRANCH',     width: 160,),
    ErpColumnConfig(key: 'ifscCode',   label: 'IFSC',       flex: 1.0),
    ErpColumnConfig(key: 'bankAcNo',   label: 'AC NO',      flex: 1.2),
    ErpColumnConfig(key: 'fromYear',   label: 'FROM YEAR',  width: 180, isDate: true),
    ErpColumnConfig(key: 'toYear',     label: 'TO YEAR',    width: 160, isDate: true),
  ];

  // ── EXTRA COLUMNS (pool) ──────────────────────────────────────────────────


  // ── FORM ROWS ─────────────────────────────────────────────────────────────
  List<List<ErpFieldConfig>> get _formRows => [
    // ── Tab 0: Basic Info ─────────────────────────────────────────────
    [
      // ErpFieldConfig(
      //   key: 'companyCode',
      //   label: 'COMPANY CODE',
      //   type: ErpFieldType.number,
      //   hint: '0',
      //   flex: 1,
      //   required: true,
      //
      //   sectionTitle: 'BASIC INFORMATION',
      //   sectionIndex: 0,
      //   // tabIndex: 0,
      // ),
      ErpFieldConfig(
        key: 'companyName',
        label: 'COMPANY NAME',
        hint: 'Enter company name',
        flex: 3,
        required: true,
        sectionIndex: 0,

        // tabIndex: 0,
      ),

      // ErpFieldConfig(
      //   key: 'active',
      //   label: 'ACTIVE',
      //   type: ErpFieldType.dropdown,
      //   hint: 'Select',
      //   flex: 1,
      //   dropdownItems: const [
      //     ErpDropdownItem(label: 'Yes', value: 'Y'),
      //     ErpDropdownItem(label: 'No', value: 'N'),
      //   ],        sectionIndex: 0,
      //   // tabIndex: 0,
      // ),
    ],
    [
      ErpFieldConfig(
        key: 'contactPerson',
        label: 'CONTACT PERSON',
        hint: 'Enter contact person',
        flex: 2,
        sectionIndex: 0,
        // tabIndex: 0,
      ),
      ErpFieldConfig(
        key: 'phone',
        label: 'PHONE',
        hint: 'Enter phone number',
        flex: 2,
        sectionIndex: 0,
        keyboardType: TextInputType.phone,
        validator: ErpValidators.phone(),
        // tabIndex: 0,
      ),
      ErpFieldConfig(
        key: 'emailID',
        label: 'EMAIL',
        hint: 'Enter email address',
        flex: 2,
        sectionIndex: 0,
        validator: ErpValidators.email(),

        // tabIndex: 0,
      ),
    ],
    [
      ErpFieldConfig(
        key: 'address',
        label: 'ADDRESS',
        hint: 'Enter full address',
        flex: 4,
        maxLines: 2,
        sectionIndex: 0,
        // tabIndex: 0,
      ),
      ErpFieldConfig(
        key: 'webSite',
        label: 'WEBSITE',
        hint: 'www.example.com',
        flex: 2,
        sectionIndex: 0,
        // tabIndex: 0,
      ),
    ],

    // ── Tab 1: Tax Info ───────────────────────────────────────────────
    [
      ErpFieldConfig(
        key: 'state',
        label: 'STATE',
        hint: 'Enter state name',
        flex: 2,
        sectionTitle: 'TAX INFORMATION',
        sectionIndex: 1,
        // tabIndex: 1,
      ),
      ErpFieldConfig(
        key: 'stateCode',
        label: 'STATE CODE',
        type: ErpFieldType.number,
        hint: '0',
        flex: 1,
        sectionIndex: 1,
        // tabIndex: 1,
      ),
      ErpFieldConfig(
        key: 'gstNo',
        label: 'GST NO',
        hint: 'Enter GST number',
        flex: 2,
        sectionIndex: 1,

        // tabIndex: 1,
      ),
    ],
    [
      ErpFieldConfig(
        key: 'panNo',
        label: 'PAN NO',
        hint: 'Enter PAN number',
        flex: 2,
        sectionIndex: 1,
        validator:
   ErpValidators.compose([
      ErpValidators.minLength('PAN No', 10),
      ErpValidators.panNo(),
      ])
        ,

        // tabIndex: 1,
      ),
      ErpFieldConfig(
        key: 'cstNo',
        label: 'CST NO',
        hint: 'Enter CST number',
        flex: 2,
        sectionIndex: 1,
        tabIndex: 1,
      ),
      ErpFieldConfig(
        key: 'tinNo',
        label: 'TIN NO',
        hint: 'Enter TIN number',
        flex: 2,
        sectionIndex: 1,
        // tabIndex: 1,
      ),
    ],

    // ── Tab 2: Bank Details ───────────────────────────────────────────
    [
      ErpFieldConfig(
        key: 'bankName',
        label: 'BANK NAME',
        hint: 'Enter bank name',
        flex: 2,
        sectionTitle: 'BANK DETAILS',
        sectionIndex: 2,
        // tabIndex: 2,
      ),
      ErpFieldConfig(
        key: 'branchName',
        label: 'BRANCH NAME',
        hint: 'Enter branch name',
        flex: 2,
        sectionIndex: 2,
        // tabIndex: 2,
      ),
      ErpFieldConfig(
        key: 'ifscCode',
        label: 'IFSC CODE',
        hint: 'e.g. SBIN0001234',
        flex: 2,
        sectionIndex: 2,
        validator: ErpValidators.ifscCode()
        // tabIndex: 2,
      ),
    ],
    [
      ErpFieldConfig(
        key: 'bankAcNo',
        label: 'ACCOUNT NO',
        hint: 'Enter account number',
        flex: 2,
        sectionIndex: 2,
        // tabIndex: 2,
      ),
      ErpFieldConfig(
        key: 'bankAddress',
        label: 'BANK ADDRESS',
        hint: 'Enter bank address',
        flex: 4,
        maxLines: 2,
        sectionIndex: 2,
        // tabIndex: 2,
      ),
    ],
    [
      ErpFieldConfig(
        key: 'fromYear',
        label: 'FROM DATE',
        type: ErpFieldType.date,
        hint: 'dd-mm-yyyy',
        flex: 1,
        sectionIndex: 2,
        // tabIndex: 2,
      ),
      ErpFieldConfig(
        key: 'toYear',
        label: 'TO DATE',
        type: ErpFieldType.date,
        hint: 'dd-mm-yyyy',
        flex: 1,
        sectionIndex: 2,
        // tabIndex: 2,
      ),
    ],
    [
      ErpFieldConfig(
        sectionTitle: 'Settings',
          key: 'active',
          label: 'ACTIVE',
          type: ErpFieldType.checkbox,
          flex: 1,
          sectionIndex: 3,
          checkboxDbType: 'BIT',
        initialBoolValue: true
      ),
    ]
  ];

  // ── INIT ──────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CompanyProvider>().loadCompanies();
    });
  }

  // ── ROW TAP → populate form (same as PurchaseDemo onRowTap) ───────────────
  void _onRowTap(Map<String, dynamic> row) {
    final raw = row['_raw'] as CompanyModel;

    setState(() {
      _selectedRow = row;
      _isEditMode  = true;
      _formValues  = {
        'companyCode':   raw.companyCode?.toString() ?? '',
        'companyName':   raw.companyName   ?? '',
        'contactPerson': raw.contactPerson ?? '',
        'address':       raw.address       ?? '',
        'phone':         raw.phone         ?? '',
        'webSite':       raw.webSite       ?? '',
        'emailID':       raw.emailID       ?? '',
        'state':         raw.state         ?? '',
        'stateCode':     raw.stateCode?.toString() ?? '',
        'gstNo':         raw.gstNo    ?? '',
        'cstNo':         raw.cstNo    ?? '',
        'tinNo':         raw.tinNo    ?? '',
        'bankName':      raw.bankName    ?? '',
        'branchName':    raw.branchName  ?? '',
        'bankAddress':   raw.bankAddress ?? '',
        'ifscCode':      raw.ifscCode    ?? '',
        'bankAcNo':      raw.bankAcNo    ?? '',
        'fromYear':      raw.fromYear    ?? '',
        'toYear':        raw.toYear      ?? '',
        'active': raw.active == true ? 'true' : 'false',
        'panNo':         raw.panNo ?? '',
      };
    });
    if (Responsive.isMobile(context)) {
      setState(() => _showTableOnMobile = false);
    }
  }

  // ── SAVE ──────────────────────────────────────────────────────────────────
  Future<void> _onSave(Map<String, dynamic> values) async {
    final provider = context.read<CompanyProvider>();

    bool success;
    if (_isEditMode && _selectedRow != null) {
      final raw  = _selectedRow!['_raw'] as CompanyModel;
      final code = raw.companyCode!;
      success = await provider.updateCompany(code, values);
    } else {
      success = await provider.createCompany(values);
    }

    if (!mounted) return;

    if (success) {
      _resetForm();
      await ErpResultDialog.showSuccess(
        context: context,
        theme: _theme,
        title: _isEditMode ? 'Updated' : 'Saved',
        message: _isEditMode
            ? 'Company updated successfully.'
            : 'Company saved successfully.',
      );
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(
      //       _isEditMode
      //           ? 'Company updated successfully'
      //           : 'Company saved successfully',
      //     ),
      //     backgroundColor: _theme.primary,
      //     behavior: SnackBarBehavior.floating,
      //     shape: RoundedRectangleBorder(
      //       borderRadius: BorderRadius.circular(8),
      //     ),
      //     margin: const EdgeInsets.all(12),
      //   ),
      // );
    }
  }

  // ── DELETE ────────────────────────────────────────────────────────────────
  Future<void> _onDelete() async {
    final raw = _selectedRow?['_raw'] as CompanyModel?;
    if (raw?.companyCode == null) return;
    final confirm = await ErpDeleteDialog.show(context: context, theme: _theme, title: 'Company', itemName: raw!.companyName??"");

    // final confirm = await showDialog<bool>(
    //   context: context,
    //   builder: (_) => AlertDialog(
    //     title: const Text('Delete Company'),
    //     content: Text('Delete "${raw!.companyName}"? This cannot be undone.'),
    //     actions: [
    //       TextButton(
    //         onPressed: () => Navigator.pop(context, false),
    //         child: const Text('Cancel'),
    //       ),
    //       TextButton(
    //         onPressed: () => Navigator.pop(context, true),
    //         child: const Text(
    //           'Delete',
    //           style: TextStyle(color: Colors.red),
    //         ),
    //       ),
    //     ],
    //   ),
    // );

    if (confirm != true || !mounted) return;

    final success =
    await context.read<CompanyProvider>().deleteCompany(raw.companyCode!);

    if (success && mounted) {
      _resetForm();
      await ErpResultDialog.showDeleted(
        context: context,
        theme: _theme,
        itemName: raw.companyName ?? '',
      );
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: const Text('Company deleted successfully'),
      //     backgroundColor: Colors.red.shade600,
      //     behavior: SnackBarBehavior.floating,
      //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      //     margin: const EdgeInsets.all(12),
      //   ),
      // );
    }
  }

  // ── RESET (same as PurchaseDemo onCancel) ─────────────────────────────────
  void _resetForm() {
    setState(() {
      _selectedRow = null;
      _isEditMode  = false;
      _formValues  = {};
      _showTableOnMobile=false;

    });
    _erpFormKey.currentState?.resetForm();
  }
  bool _showTableOnMobile = false;

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Consumer<CompanyProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child:
              Responsive.isMobile(context)?_showTableOnMobile? buildErpDataTable(provider):ErpForm(
                onExit: () {
                  context.read<TabProvider>().closeCurrentTab();
                },
                logo: AppImages.logo,

                key: _erpFormKey,
                title: 'COMPANY MASTER',
                subtitle: 'Firm / Company Information',
                // tabs: ['Basic Info', 'Tax Info', 'Bank Details'],
                initialTabIndex: 0,
                onSearch: () => setState(() => _showTableOnMobile = true),
                tabBarBackgroundColor: const Color(0xfff2f0ef),
                tabBarSelectedColor: _theme.primaryGradient.first,
                tabBarSelectedTxtColor: Colors.white,
                rows: _formRows,
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
              // ── LEFT: Form ─────────────────────────────────────────
              Expanded(
                flex: 2,
                child: ErpForm(
                  onExit: () {
                    context.read<TabProvider>().closeCurrentTab();
                  },
                  logo: AppImages.logo,

                  key: _erpFormKey,
                  title: 'COMPANY MASTER',
                  subtitle: 'Firm / Company Information',
                  // tabs: ['Basic Info', 'Tax Info', 'Bank Details'],
                  initialTabIndex: 0,
                  tabBarBackgroundColor: const Color(0xfff2f0ef),
                  tabBarSelectedColor: _theme.primaryGradient.first,
                  tabBarSelectedTxtColor: Colors.white,
                  rows: _formRows,
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

              // ── RIGHT: Table ───────────────────────────────────────
              Expanded(
                flex: 2,
                child: buildErpDataTable(provider),
              ),
            ],
          ),
        );
      },
    );
  }

  ErpDataTable buildErpDataTable(CompanyProvider provider) {
    return ErpDataTable(
                isReportRow: false,

                token: token ?? '',
                url: baseUrl,
                title: 'COMPANY LIST',
                columns: _tableColumns,
                // availableExtraColumns: _extraColumns,
                data: provider.tableData,
                // theme: _theme,
                showSearch: true,
                showFooterTotals: false,
                selectedRow: _selectedRow,
                onRowTap: _onRowTap,
                emptyMessage: provider.isLoaded
                    ? 'No companies found'
                    : 'Loading...',
              );
  }


}