// lib/screens/mst_firm_company.dart

import 'package:diam_mfg/models/party_model.dart';
import 'package:diam_mfg/providers/party_provider.dart';
import 'package:erp_data_table/erp_data_table.dart';
import 'package:erp_formatter/erp_formatter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rs_dashboard/rs_dashboard.dart';

import '../models/company_model.dart';
import '../providers/company_provider.dart';
import '../utils/app_images.dart';
import '../utils/delete_dialogue.dart';
import '../utils/msg_dialogue.dart';

class MstFirmParty extends StatefulWidget {
  const MstFirmParty({super.key});

  @override
  State<MstFirmParty> createState() => _MstFirmPartyState();
}

class _MstFirmPartyState extends State<MstFirmParty> {
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
      key: 'partyCode',
      label: 'CODE',
      width: 100,
      required: true,
    ),
    ErpColumnConfig(
      key: 'partyName',
      label: 'PARTY NAME',
      width: 220,
      required: true,
    ),
    ErpColumnConfig(key: 'mob1', label: 'MOBILE'),
    ErpColumnConfig(key: 'gstNo', label: 'GST NO'),
    ErpColumnConfig(key: 'panNo', label: 'PAN NO'),
    ErpColumnConfig(
      key: 'active',
      label: 'ACTIVE',
      width: 90,
      align: ColumnAlign.center,
    ),
    ErpColumnConfig(key: 'emailID',   label: 'EMAIL',      flex: 1.5),
    ErpColumnConfig(key: 'panNo',      label: 'PAN NO',     flex: 1.0),
    ErpColumnConfig(key: 'bankName',   label: 'BANK',       flex: 1.2),
    ErpColumnConfig(key: 'branchName', label: 'BRANCH',     width: 160),
    ErpColumnConfig(key: 'ifscCode',   label: 'IFSC',       flex: 1.0),
    ErpColumnConfig(key: 'bankAcNo',   label: 'AC NO',      flex: 1.2),
    ErpColumnConfig(key: 'fromYear',   label: 'FROM YEAR',  width: 180, isDate: true),
    ErpColumnConfig(key: 'toYear',     label: 'TO YEAR',    width: 160, isDate: true),
  ];
  // ── EXTRA COLUMNS (pool) ──────────────────────────────────────────────────
  List<ErpColumnConfig> get _extraColumns => [
    ErpColumnConfig(key: 'emailID',   label: 'EMAIL',      flex: 1.5),
    ErpColumnConfig(key: 'panNo',      label: 'PAN NO',     flex: 1.0),
    ErpColumnConfig(key: 'bankName',   label: 'BANK',       flex: 1.2),
    ErpColumnConfig(key: 'branchName', label: 'BRANCH',     flex: 1.0),
    ErpColumnConfig(key: 'ifscCode',   label: 'IFSC',       flex: 1.0),
    ErpColumnConfig(key: 'bankAcNo',   label: 'AC NO',      flex: 1.2),
    ErpColumnConfig(key: 'fromYear',   label: 'FROM YEAR',  flex: 0.8, isDate: true),
    ErpColumnConfig(key: 'toYear',     label: 'TO YEAR',    flex: 0.8, isDate: true),
  ];

  // ── FORM ROWS ─────────────────────────────────────────────────────────────
  List<List<ErpFieldConfig>>  _formRows (CompanyProvider companyProvider)=> [

    /// ───────────────── BASIC INFORMATION ─────────────────
    [
      // ErpFieldConfig(
      //   key: 'partyMstID',
      //   label: 'PARTY MST ID',
      //   type: ErpFieldType.number,
      //   readOnly: true,
      //   flex: 1,
      //   sectionTitle: 'BASIC INFORMATION',
      //   sectionIndex: 0,
      // ),
      // ErpFieldConfig(
      //   key: 'partyCode',
      //   label: 'PARTY CODE',
      //   type: ErpFieldType.number,
      //   required: true,
      //   flex: 1,
      //   sectionIndex: 0,
      // ),
      ErpFieldConfig(
        key: 'partyName',
        label: 'PARTY NAME',
        required: true,
        flex: 3,
        sectionIndex: 0,
      ),
    ],

    [
      ErpFieldConfig(
        key: 'partyType',
        label: 'PARTY TYPE',
        type: ErpFieldType.dropdown,
        dropdownItems: const [
          ErpDropdownItem(label: 'Customer', value: 'Customer'),
          ErpDropdownItem(label: 'Supplier', value: 'Supplier'),
          ErpDropdownItem(label: 'Broker', value: 'Broker'),
        ],
        flex: 2,
        sectionIndex: 0,
      ),
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
        // dropdownItems:companyProvider
        //     .companies
        //     .map((e) => e.companyName.toString())
        //     .toList(),
        sectionIndex: 0,

      ),
      // ErpFieldConfig(
      //   key: 'companyCode',
      //   label: 'COMPANY CODE',
      //   type: ErpFieldType.number,
      //   flex: 1,
      //   sectionIndex: 0,
      // ),
    ],

    [
      ErpFieldConfig(
        key: 'active',
        label: 'ACTIVE',
        type: ErpFieldType.checkbox,
        flex: 1,
        sectionIndex: 0,
        checkboxDbType: 'BIT'
      ),
      ErpFieldConfig(
        key: 'mainCutCompulsory',
        label: 'MAIN CUT COMPULSORY',
        type: ErpFieldType.checkbox,
        flex: 2,
        sectionIndex: 0,
          checkboxDbType: 'BIT'

      ),
    ],

    /// ───────────────── CONTACT DETAILS ─────────────────
    [
      ErpFieldConfig(
        key: 'address',
        label: 'ADDRESS',
        maxLines: 2,
        flex: 4,
        sectionTitle: 'CONTACT DETAILS',
        sectionIndex: 1,
      ),
    ],

    [
      ErpFieldConfig(key: 'phone1', label: 'PHONE 1', flex: 1, sectionIndex: 1,type: ErpFieldType.phone,validator: ErpValidators.phone()),
      ErpFieldConfig(key: 'phone2', label: 'PHONE 2', flex: 1, sectionIndex: 1,type: ErpFieldType.phone,validator: ErpValidators.phone()),
      ErpFieldConfig(key: 'phone3', label: 'PHONE 3', flex: 1, sectionIndex: 1,type: ErpFieldType.phone,validator: ErpValidators.phone()),
    ],

    [
      ErpFieldConfig(key: 'mob1', label: 'MOBILE 1', flex: 1, sectionIndex: 1,type: ErpFieldType.phone,validator: ErpValidators.phone()),
      ErpFieldConfig(key: 'mob2', label: 'MOBILE 2', flex: 1, sectionIndex: 1,type: ErpFieldType.phone,validator: ErpValidators.phone()),
      ErpFieldConfig(key: 'mob3', label: 'MOBILE 3', flex: 1, sectionIndex: 1,type: ErpFieldType.phone,validator: ErpValidators.phone()),
    ],

    [
      ErpFieldConfig(key: 'email1', label: 'EMAIL 1', flex: 1, sectionIndex: 1,validator: ErpValidators.email()),
      ErpFieldConfig(key: 'email2', label: 'EMAIL 2', flex: 1, sectionIndex: 1,validator: ErpValidators.email()),
      ErpFieldConfig(key: 'email3', label: 'EMAIL 3', flex: 1, sectionIndex: 1,validator: ErpValidators.email()),
    ],

    /// ───────────────── TAX DETAILS ─────────────────
    [
      ErpFieldConfig(
        key: 'gstNo',
        label: 'GST NO',
        flex: 2,
        sectionTitle: 'TAX DETAILS',
        sectionIndex: 2,
          validator: ErpValidators.gstNoOptional
      ),
      ErpFieldConfig(key: 'cstNo', label: 'CST NO', flex: 2, sectionIndex: 2),
      ErpFieldConfig(key: 'tinNo', label: 'TIN NO', flex: 2, sectionIndex: 2),
    ],

    [
      ErpFieldConfig(key: 'panNo', label: 'PAN NO', flex: 2, sectionIndex: 2,        validator:
      ErpValidators.compose([
        ErpValidators.minLength('PAN No', 10),
        ErpValidators.panNo(),
      ])
        ,),
      ErpFieldConfig(key: 'state', label: 'STATE', flex: 2, sectionIndex: 2),
      ErpFieldConfig(
        key: 'stateCode',
        label: 'STATE CODE',
        type: ErpFieldType.number,
        flex: 1,
        sectionIndex: 2,
      ),
    ],
  ];
  // ── INIT ──────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PartyProvider>().loadParties();
      context.read<CompanyProvider>().loadCompanies();
    });
  }

  // ── ROW TAP → populate form (same as PurchaseDemo onRowTap) ───────────────
  void _onRowTap(Map<String, dynamic> row) {
    final raw = row['_raw'] as PartyModel;

    setState(() {
      _selectedRow = row;
      _isEditMode  = true;
      _formValues = {
        'partyMstID': raw.partyMstID?.toString() ?? '',
        'partyCode': raw.partyCode?.toString() ?? '',
        'partyName': raw.partyName ?? '',
        'partyType': raw.partyType ?? '',
        'companyCode': raw.companyCode?.toString() ?? '',
        'address': raw.address ?? '',
        'phone1': raw.phone1 ?? '',
        'phone2': raw.phone2 ?? '',
        'phone3': raw.phone3 ?? '',
        'mob1': raw.mob1 ?? '',
        'mob2': raw.mob2 ?? '',
        'mob3': raw.mob3 ?? '',
        'email1': raw.email1 ?? '',
        'email2': raw.email2 ?? '',
        'email3': raw.email3 ?? '',
        'gstNo': raw.gstNo ?? '',
        'cstNo': raw.cstNo ?? '',
        'tinNo': raw.tinNo ?? '',
        'state': raw.state ?? '',
        'stateCode': raw.stateCode?.toString() ?? '',
        'panNo': raw.panNo ?? '',
        'active': raw.active == true ? 'true' : 'false',
        'mainCutCompulsory': raw.mainCutCompulsory == true ? 'true' : 'false',
      };
    });
    if (Responsive.isMobile(context)) {
      setState(() => _showTableOnMobile = false);
    }
  }

  // ── SAVE ──────────────────────────────────────────────────────────────────
  Future<void> _onSave(Map<String, dynamic> values) async {
    final provider = context.read<PartyProvider>();

    bool success;
    if (_isEditMode && _selectedRow != null) {
      final raw  = _selectedRow!['_raw'] as PartyModel;
      final code = raw.partyCode!;
      success = await provider.updateParty(code, values);
    } else {
      success = await provider.createParty(values);
    }

    if (!mounted) return;

    if (success) {
      _resetForm();
      await ErpResultDialog.showSuccess(
        context: context,
        theme: _theme,
        title: _isEditMode ? 'Updated' : 'Saved',
        message: _isEditMode
            ? 'Party updated successfully.'
            : 'Party saved successfully.',
      );
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(
      //       _isEditMode
      //           ? 'Party updated successfully'
      //           : 'Party saved successfully',
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
    final raw = _selectedRow?['_raw'] as PartyModel?;
    if (raw?.companyCode == null) return;
    final confirm = await ErpDeleteDialog.show(context: context, theme: _theme, title: 'Party', itemName: raw!.partyName??"");

    // final confirm = await showDialog<bool>(
    //   context: context,
    //   builder: (_) => AlertDialog(
    //     title: const Text('Delete Party'),
    //     content: Text('Delete "${raw!.partyName}"? This cannot be undone.'),
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
    await context.read<PartyProvider>().deleteParty(raw!.partyCode!);

    if (success && mounted) {
      _resetForm();
      await ErpResultDialog.showDeleted(
        context: context,
        theme: _theme,
        itemName: raw.partyName ?? '',
      );
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: const Text('Party deleted successfully'),
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
      _showTableOnMobile = false;
    });
    _erpFormKey.currentState?.resetForm();
  }
  bool _showTableOnMobile = false;

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final companyProvider = context.watch<CompanyProvider>();

    return Consumer<PartyProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child:
              Responsive.isMobile(context)?_showTableOnMobile?ErpDataTable(
                isReportRow: false,

                token: token ?? '',
                url: 'http://50.62.183.116:5000',
                title: 'PARTY LIST',
                columns: _tableColumns,
                // availableExtraColumns: _extraColumns,
                data: provider.tableData,
                // theme: _theme,
                showSearch: true,
                showFooterTotals: false,
                selectedRow: _selectedRow,
                onRowTap: _onRowTap,
                emptyMessage: provider.isLoaded
                    ? 'No Party found'
                    : 'Loading...',
              ):ErpForm(
                logo: AppImages.logo,

                key: _erpFormKey,
                title: 'PARTY MASTER',
                subtitle: 'Firm / Party Information',
                // tabs: ['Basic Info', 'Tax Info', 'Bank Details'],
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
              // ── LEFT: Form ─────────────────────────────────────────
              Expanded(
                flex: 2,
                child: ErpForm(
                  logo: AppImages.logo,

                  key: _erpFormKey,
                  title: 'PARTY MASTER',
                  subtitle: 'Firm / Party Information',
                  // tabs: ['Basic Info', 'Tax Info', 'Bank Details'],
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

              // ── RIGHT: Table ───────────────────────────────────────
              Expanded(
                flex: 2,
                child: ErpDataTable(
                  isReportRow: false,

                  token: token ?? '',
                  url: 'http://50.62.183.116:5000',
                  title: 'PARTY LIST',
                  columns: _tableColumns,
                  // availableExtraColumns: _extraColumns,
                  data: provider.tableData,
                  // theme: _theme,
                  showSearch: true,
                  showFooterTotals: false,
                  selectedRow: _selectedRow,
                  onRowTap: _onRowTap,
                  emptyMessage: provider.isLoaded
                      ? 'No Party found'
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