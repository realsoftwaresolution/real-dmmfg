
import 'package:diam_mfg/models/factory_model.dart';
import 'package:diam_mfg/providers/division_provider.dart';
import 'package:diam_mfg/providers/factory_man_group_provider.dart';
import 'package:diam_mfg/providers/factory_provider.dart';
import 'package:erp_data_table/erp_data_table.dart';
import 'package:erp_formatter/erp_formatter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rs_dashboard/rs_dashboard.dart';

import '../bootstrap.dart' show baseUrl;
import '../models/company_model.dart';
import '../providers/company_provider.dart';
import '../utils/app_images.dart' show AppImages;
import '../utils/delete_dialogue.dart';
import '../utils/msg_dialogue.dart';

class MstFirmFactory extends StatefulWidget {
  const MstFirmFactory({super.key});

  @override
  State<MstFirmFactory> createState() => _MstFirmFactoryState();
}

class _MstFirmFactoryState extends State<MstFirmFactory> {
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
    ErpColumnConfig(key: 'factoryCode', label: 'CODE', width: 130),
    ErpColumnConfig(key: 'factoryName', label: 'FACTORY NAME', width: 200),
    ErpColumnConfig(key: 'contactPerson', label: 'CONTACT', width: 200),
    ErpColumnConfig(key: 'phone1', label: 'PHONE', width: 150),
    ErpColumnConfig(key: 'mob1', label: 'MOBILE', width: 150),
    ErpColumnConfig(key: 'email1', label: 'EMAIL', width: 150),
    ErpColumnConfig(key: 'gstNo', label: 'GST', width: 150),
    ErpColumnConfig(key: 'rateOnShape', label: 'RATE SHAPE', width: 200),
    ErpColumnConfig(key: 'rateOnCut', label: 'RATE CUT', width: 180),
    ErpColumnConfig(key: 'diamEntry', label: 'DIAM ENTRY', width: 200),
    ErpColumnConfig(key: 'active', label: 'ACTIVE', width: 150),
    ErpColumnConfig(key: 'address', label: 'ADDRESS', width: 180),

    /// PHONE
    ErpColumnConfig(key: 'phone2', label: 'PHONE 2',width: 180),
    ErpColumnConfig(key: 'phone3', label: 'PHONE 3',width: 180),

    /// MOBILE
    ErpColumnConfig(key: 'mob2', label: 'MOBILE 2',width: 180),
    ErpColumnConfig(key: 'mob3', label: 'MOBILE 3',width: 180),

    /// EMAIL
    ErpColumnConfig(key: 'email1', label: 'EMAIL',width: 160),

    /// COMPANY & STRUCTURE
    ErpColumnConfig(key: 'factoryType', label: 'FACTORY TYPE',width: 200),
    ErpColumnConfig(key: 'factoryManGroupCode', label: 'MAN GROUP CODE',width: 200),
    ErpColumnConfig(key: 'divisionCode', label: 'DIVISION CODE',width: 200),
    ErpColumnConfig(key: 'companyCode', label: 'COMPANY CODE',width: 200),
  ];
  // ── EXTRA COLUMNS (pool) ──────────────────────────────────────────────────
  List<ErpColumnConfig> get _extraColumns => [

    /// BASIC
    ErpColumnConfig(key: 'address', label: 'ADDRESS', flex: 2),

    /// PHONE
    ErpColumnConfig(key: 'phone2', label: 'PHONE 2'),
    ErpColumnConfig(key: 'phone3', label: 'PHONE 3'),

    /// MOBILE
    ErpColumnConfig(key: 'mob2', label: 'MOBILE 2'),
    ErpColumnConfig(key: 'mob3', label: 'MOBILE 3'),

    /// EMAIL
    ErpColumnConfig(key: 'email1', label: 'EMAIL'),

    /// COMPANY & STRUCTURE
    ErpColumnConfig(key: 'factoryType', label: 'FACTORY TYPE'),
    ErpColumnConfig(key: 'factoryManGroupCode', label: 'MAN GROUP CODE'),
    ErpColumnConfig(key: 'divisionCode', label: 'DIVISION CODE'),
    ErpColumnConfig(key: 'companyCode', label: 'COMPANY CODE'),

    /// FLAGS (Already in main but can repeat if needed)
    ErpColumnConfig(key: 'rateOnShape', label: 'RATE ON SHAPE'),
    ErpColumnConfig(key: 'rateOnCut', label: 'RATE ON CUT'),
    ErpColumnConfig(key: 'diamEntry', label: 'DIAM ENTRY'),

  ];

  // ── FORM ROWS ─────────────────────────────────────────────────────────────
  List<List<ErpFieldConfig>>  _formRows(CompanyProvider companyProvider,FactoryManGroupProvider factoryManGroupProvider,DivisionProvider divisionProvider) => [

    /// ───────── BASIC INFO ─────────
    // [
    //   // ErpFieldConfig(
    //   //   key: 'factoryCode',
    //   //   label: 'FACTORY CODE',
    //   //   type: ErpFieldType.number,
    //   //   required: true,
    //   //   sectionTitle: 'BASIC INFORMATION',
    //   //   sectionIndex: 0,
    //   // ),
    //   ErpFieldConfig(
    //     key: 'factoryName',
    //     label: 'FACTORY NAME',
    //     required: true,
    //     sectionIndex: 0,
    //   ),
    // ],

    [
      ErpFieldConfig(
        key: 'factoryName',
        label: 'FACTORY NAME',
        required: true,
        sectionIndex: 0,
      ),
      ErpFieldConfig(
        key: 'contactPerson',
        label: 'CONTACT PERSON',
        sectionIndex: 0,
      ),
      // ErpFieldConfig(
      //   key: 'factoryType',
      //   label: 'TYPE',
      //   sectionIndex: 0,
      // ),
      ErpFieldConfig(
        key: 'factoryType',
        label: 'TYPE',
        required: true,
        type: ErpFieldType.dropdown,
        initialDropValue: true,
        dropdownItems: const [
          ErpDropdownItem(label: 'Self', value: 'Self'),
          ErpDropdownItem(label: 'Out', value: 'Out'),
        ],
        sectionIndex: 0,
      ),
    ],

    [
      ErpFieldConfig(
        key: 'factoryManGroupCode',
        // label: 'MAN GROUP CODE',
        label: 'GROUP',
        required: true,
        initialDropValue: true,
        type: ErpFieldType.dropdown,
        dropdownItems: factoryManGroupProvider.groups
            .where((element) {
          return element.active==true;
        },).map((e) {
          return ErpDropdownItem(
            label: e.factoryManGroupName ?? '',
            value: e.factoryManGroupCode?.toString() ?? '',
          );
        }).toList(),
        // dropdownItems:companyProvider
        //     .companies
        //     .map((e) => e.companyName.toString())
        //     .toList(),
        sectionIndex: 0,

      ),
      // ErpFieldConfig(
      //   key: 'factoryManGroupCode',
      //   label: 'MAN GROUP CODE',
      //   type: ErpFieldType.number,
      //   sectionIndex: 0,
      // ),
      ErpFieldConfig(
        key: 'divisionCode',
        label: 'DIVISION CODE',
        type: ErpFieldType.dropdown,
        required: true,
        initialDropValue: true,
        dropdownItems: divisionProvider.divisions
            .where((element) {
          return element.active==true;
        },).map((e) {
          return ErpDropdownItem(
            label: e.divisionName ?? '',
            value: e.divisionCode?.toString() ?? '',
          );
        }).toList(),
        // dropdownItems:companyProvider
        //     .companies
        //     .map((e) => e.companyName.toString())
        //     .toList(),
        sectionIndex: 0,

      ),
      // ErpFieldConfig(
      //   key: 'divisionCode',
      //   label: 'DIVISION CODE',
      //   type: ErpFieldType.number,
      //   sectionIndex: 0,
      // ),
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
    //     // dropdownItems:companyProvider
    //     //     .companies
    //     //     .map((e) => e.companyName.toString())
    //     //     .toList(),
    //     sectionIndex: 0,
    //
    //   ),
    // ],

    /// ───────── CONTACT DETAILS ─────────
    [
      ErpFieldConfig(
        key: 'address',
        label: 'ADDRESS',
        maxLines: 2,
        sectionTitle: 'CONTACT DETAILS',
        sectionIndex: 1,
      ),
    ],

    [
      ErpFieldConfig(key: 'phone1', label: 'PHONE 1', sectionIndex: 1,keyboardType: TextInputType.phone,validator: ErpValidators.phone()),
      ErpFieldConfig(key: 'phone2', label: 'PHONE 2', sectionIndex: 1,keyboardType: TextInputType.phone,validator: ErpValidators.phone()),
      ErpFieldConfig(key: 'phone3', label: 'PHONE 3', sectionIndex: 1,keyboardType: TextInputType.phone,validator: ErpValidators.phone()),
    ],

    [
      ErpFieldConfig(key: 'mob1', label: 'MOBILE 1', sectionIndex: 1,keyboardType: TextInputType.phone,validator: ErpValidators.phone()),
      ErpFieldConfig(key: 'mob2', label: 'MOBILE 2', sectionIndex: 1,keyboardType: TextInputType.phone,validator: ErpValidators.phone()),
      ErpFieldConfig(key: 'mob3', label: 'MOBILE 3', sectionIndex: 1,keyboardType: TextInputType.phone,validator: ErpValidators.phone()),
    ],

    [
      ErpFieldConfig(key: 'email1', label: 'EMAIL', sectionIndex: 1,keyboardType: TextInputType.text,validator: ErpValidators.email()),
      // ErpFieldConfig(key: 'gstNo', label: 'GST NO', sectionIndex: 1),
    ],

    /// ───────── FLAGS ─────────
    [
      ErpFieldConfig(
        key: 'rateOnShape',
        label: 'RATE ON SHAPE',
        type: ErpFieldType.checkbox,
        // dropdownItems: const [
        //   ErpDropdownItem(label: 'Yes', value: 'Y'),
        //   ErpDropdownItem(label: 'No', value: 'N'),
        // ],
        sectionTitle: 'SETTINGS',
        checkboxDbType: 'YN',
        sectionIndex: 2,
      ),
      ErpFieldConfig(
        key: 'rateOnCut',
        label: 'RATE ON CUT',
        type: ErpFieldType.checkbox,
        checkboxDbType: 'YN',
        // dropdownItems: const [
        //   ErpDropdownItem(label: 'Yes', value: 'Y'),
        //   ErpDropdownItem(label: 'No', value: 'N'),
        // ],
        sectionIndex: 2,
      ),
    ],

    [
      ErpFieldConfig(
        key: 'diamEntry',
        label: 'DIAMETER ENTRY',
        type: ErpFieldType.checkbox,
        checkboxDbType: 'YN',
        // dropdownItems: const [
        //   ErpDropdownItem(label: 'Yes', value: 'Y'),
        //   ErpDropdownItem(label: 'No', value: 'N'),
        // ],
        sectionIndex: 2,
      ),
      ErpFieldConfig(
        key: 'active',
        label: 'ACTIVE',
        type: ErpFieldType.checkbox,
        checkboxDbType: 'BIT',
        initialBoolValue: true,
        // dropdownItems: const [
        //   ErpDropdownItem(label: 'Yes', value: 'Y'),
        //   ErpDropdownItem(label: 'No', value: 'N'),
        // ],
        sectionIndex: 2,
      ),
    ],
  ];  // ── INIT ──────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {

      context.read<FactoryProvider>().loadFactories();
      context.read<CompanyProvider>().loadCompanies();
      context.read<DivisionProvider>().loadDivisions();
      context.read<FactoryManGroupProvider>().loadGroups();
      final selectedCode = context.read<CompanyProvider>().selectedCompanyCode;
      context.read<FactoryProvider>().setSelectedCompany(selectedCode);
    });
  }

  // ── ROW TAP → populate form (same as PurchaseDemo onRowTap) ───────────────
  void _onRowTap(Map<String, dynamic> row) {
    final raw = row['_raw'] as FactoryModel;
    // final companyProvider = context.read<CompanyProvider>();
    //
    //
    // if (companyProvider.companies.isEmpty) {
    //   return; // 🔥 prevent crash
    // }

    setState(() {
      _selectedRow = row;
      _isEditMode = true;

      _formValues = {
        'factoryCode': raw.factoryCode?.toString() ?? '',
        'factoryName': raw.factoryName ?? '',
        'contactPerson': raw.contactPerson ?? '',
        'address': raw.address ?? '',
        'phone1': raw.phone1 ?? '',
        'phone2': raw.phone2 ?? '',
        'phone3': raw.phone3 ?? '',
        'mob1': raw.mob1 ?? '',
        'mob2': raw.mob2 ?? '',
        'mob3': raw.mob3 ?? '',
        'email1': raw.email1 ?? '',
        'gstNo': raw.gstNo ?? '',
        'factoryType': raw.factoryType ?? '',
        'factoryManGroupCode': raw.factoryManGroupCode?.toString() ?? '',
        'divisionCode': raw.divisionCode?.toString() ?? '',
        'companyCode': context.read<CompanyProvider>().selectedCompanyCode?.toString()
            ?? raw.companyCode?.toString() ?? '',
        'rateOnShape': raw.rateOnShape == 'Y' ? 'true' : 'false',
        'rateOnCut': raw.rateOnCut == 'Y' ? 'true' : 'false',
        'diamEntry': raw.diamEntry == 'Y' ? 'true' : 'false',
        // 'delRights': raw.delRights == 'Y' ? 'true' : 'false',

        'active': raw.active == true ? 'true' : 'false',
        // 'rateOnShape': raw.rateOnShape == 'Y' ? 'Yes' : 'No',
        // 'rateOnCut': raw.rateOnCut == 'Y' ? 'Yes' : 'No',
        // 'diamEntry': raw.diamEntry == 'Y' ? 'Yes' : 'No',
        // 'active': raw.active == true ? 'Yes' : 'No',
      };
    });
    if (Responsive.isMobile(context)) {
      setState(() => _showTableOnMobile = false);
    }
  }
  // ── SAVE ──────────────────────────────────────────────────────────────────
  Future<void> _onSave(Map<String, dynamic> values) async {
    final provider = context.read<FactoryProvider>();

    bool success;
    if (_isEditMode && _selectedRow != null) {
      final raw  = _selectedRow!['_raw'] as FactoryModel;
      final code = raw.factoryCode!;
      success = await provider.updateFactory(code, values);
    } else {
      success = await provider.createFactory(values);
    }

    if (!mounted) return;

    if (success) {
      _resetForm();
      await ErpResultDialog.showSuccess(
        context: context,
        theme: _theme,
        title: _isEditMode ? 'Updated' : 'Saved',
        message: _isEditMode
            ? 'Factory updated successfully.'
            : 'Factory saved successfully.',
      );
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(
      //       _isEditMode
      //           ? 'Factory updated successfully'
      //           : 'Factory saved successfully',
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
    final raw = _selectedRow?['_raw'] as FactoryModel?;
    if (raw?.companyCode == null) return;
    final confirm = await ErpDeleteDialog.show(context: context, theme: _theme, title: 'Factory', itemName: raw!.factoryName??"");

    // final confirm = await showDialog<bool>(
    //   context: context,
    //   builder: (_) => AlertDialog(
    //     title: const Text('Delete Factory'),
    //     content: Text('Delete "${raw!.factoryName}"? This cannot be undone.'),
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
    await context.read<FactoryProvider>().deleteFactory(raw.factoryCode!);

    if (success && mounted) {
      _resetForm();
      await ErpResultDialog.showDeleted(
        context: context,
        theme: _theme,
        itemName: raw.factoryName ?? '',
      );
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: const Text('Factory deleted successfully'),
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
    final factoryManGroupProvider = context.watch<FactoryManGroupProvider>();
    final divisionProvider = context.watch<DivisionProvider>();

    return Consumer<FactoryProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child:
                Responsive.isMobile(context)?_showTableOnMobile?ErpDataTable(
                  isReportRow: false,

                  token: token ?? '',
                  url: baseUrl,
                  title: 'FACTORY LIST',
                  columns: _tableColumns,
                  // availableExtraColumns: _extraColumns,
                  data: provider.tableData,
                  // theme: _theme,
                  showSearch: true,
                  showFooterTotals: false,
                  selectedRow: _selectedRow,
                  onRowTap: _onRowTap,
                  emptyMessage: provider.isLoaded
        ? 'No Factory found'
        : 'Loading...',
                ):ErpForm(
                  onExit: () {
                    context.read<TabProvider>().closeCurrentTab();
                  },
                  logo: AppImages.logo,

                  key: _erpFormKey,
                  title: 'FACTORY MASTER',
                  subtitle: 'Firm / Factory Information',
                  // tabs: ['Basic Info', 'Tax Info', 'Bank Details'],
                  initialTabIndex: 0,
                  onSearch: () => setState(() => _showTableOnMobile = true),

                  tabBarBackgroundColor: const Color(0xfff2f0ef),
                  tabBarSelectedColor: _theme.primaryGradient.first,
                  tabBarSelectedTxtColor: Colors.white,
                  rows: _formRows(companyProvider,factoryManGroupProvider,divisionProvider),
                  // theme: _theme,
                  initialValues: _formValues,
                  isEditMode: _isEditMode,
                  onFieldChanged: (key, value) {

                    if (key == 'companyCode') {

        final selectedCompany = companyProvider.companies.firstWhere(
              (c) => c.companyName == value,
          orElse: () => CompanyModel(),
        );

        _formValues['companyCode'] =
            selectedCompany.companyCode?.toString() ?? '';

                    } else {
        _formValues[key] = value;
                    }
                  },
                  // onFieldChanged: (key, value) {
                  //   _formValues[key] = value;
                  // },
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
                  title: 'FACTORY MASTER',
                  subtitle: 'Firm / Factory Information',
                  // tabs: ['Basic Info', 'Tax Info', 'Bank Details'],
                  initialTabIndex: 0,
                  tabBarBackgroundColor: const Color(0xfff2f0ef),
                  tabBarSelectedColor: _theme.primaryGradient.first,
                  tabBarSelectedTxtColor: Colors.white,
                  rows: _formRows(companyProvider,factoryManGroupProvider,divisionProvider),
                  // theme: _theme,
                  initialValues: _formValues,
                  isEditMode: _isEditMode,
                  onFieldChanged: (key, value) {

                    if (key == 'companyCode') {

                      final selectedCompany = companyProvider.companies.firstWhere(
                            (c) => c.companyName == value,
                        orElse: () => CompanyModel(),
                      );

                      _formValues['companyCode'] =
                          selectedCompany.companyCode?.toString() ?? '';

                    } else {
                      _formValues[key] = value;
                    }
                  },
                  // onFieldChanged: (key, value) {
                  //   _formValues[key] = value;
                  // },
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
                  url: baseUrl,
                  title: 'FACTORY LIST',
                  columns: _tableColumns,
                  // availableExtraColumns: _extraColumns,
                  data: provider.tableData,
                  // theme: _theme,
                  showSearch: true,
                  showFooterTotals: false,
                  selectedRow: _selectedRow,
                  onRowTap: _onRowTap,
                  emptyMessage: provider.isLoaded
                      ? 'No Factory found'
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