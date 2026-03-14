import 'package:diam_mfg/providers/holiday_provider.dart';
import 'package:diam_mfg/providers/company_provider.dart';
import 'package:erp_data_table/erp_data_table.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rs_dashboard/rs_dashboard.dart';

import '../models/holiday_model.dart';
import '../utils/app_images.dart';
import '../utils/delete_dialogue.dart';
import '../utils/msg_dialogue.dart';

class MstHoliday extends StatefulWidget {
  const MstHoliday({super.key});

  @override
  State<MstHoliday> createState() => _MstHolidayState();
}

class _MstHolidayState extends State<MstHoliday> {
  ErpThemeVariant _themeVariant = ErpThemeVariant.frost;
  ErpTheme get _theme => ErpTheme(_themeVariant);

  final GlobalKey<ErpFormState> _erpFormKey = GlobalKey<ErpFormState>();
  Map<String, dynamic>? _selectedRow;
  bool _isEditMode = false;
  Map<String, String> _formValues = {};

  final String? token = AppStorage.getString("token");

  List<ErpColumnConfig> get _tableColumns => [
    ErpColumnConfig(key: 'holidayCode', label: 'CODE', width: 130),
    ErpColumnConfig(key: 'holidayName', label: 'NAME', width: 130),
    ErpColumnConfig(key: 'holidayDate', label: 'DATE', width: 130),
    ErpColumnConfig(key: 'companyCode', label: 'COMPANY', width: 160),
    ErpColumnConfig(key: 'sortID', label: 'SORT ID', width: 160),
    ErpColumnConfig(key: 'active', label: 'ACTIVE', width: 140),
  ];

  List<List<ErpFieldConfig>> _formRows(CompanyProvider companyProvider) => [
    [
      // ErpFieldConfig(
      //   key: 'holidayCode',
      //   label: 'CODE',
      //   type: ErpFieldType.number,
      //   required: true,
      //   sectionTitle: 'BASIC INFORMATION',
      //   sectionIndex: 0,
      // ),
      ErpFieldConfig(
        key: 'holidayName',
        label: 'NAME',
        required: true,
        sectionIndex: 0,
      ),
    ],
    [
      ErpFieldConfig(
        key: 'holidayDate',
        label: 'HOLIDAY DATE',
        type: ErpFieldType.date,
        required: true,
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
        sectionIndex: 0,
      ),
    ],
    [
      ErpFieldConfig(
        key: 'sortID',
        label: 'SORT ID',
        type: ErpFieldType.number,
        sectionIndex: 0,
      ),
    ],
    [
      ErpFieldConfig(
        key: 'active',
        label: 'ACTIVE',
        type: ErpFieldType.checkbox,
        sectionTitle: 'SETTINGS',
        sectionIndex: 1,
        checkboxDbType: 'BIT'
      ),
    ],
  ];

  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     context.read<HolidayProvider>().load();
  //     context.read<CompanyProvider>().loadCompanies();
  //   });
  // }
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {

      await context.read<CompanyProvider>().loadCompanies();

      if (!mounted) return;


      final companies = context.read<CompanyProvider>().companies;
      context.read<HolidayProvider>().setCompanies(companies);


      await context.read<HolidayProvider>().load();

    });
  }
  void _onRowTap(Map<String, dynamic> row) {
    final raw = row['_raw'] as HolidayModel;
    String dateVal = '';
    if (raw.holidayDate != null && raw.holidayDate!.length >= 10) {
      final parts = raw.holidayDate!.substring(0, 10).split('-'); // [yyyy, MM, dd]
      if (parts.length == 3) {
        dateVal = '${parts[2]}/${parts[1]}/${parts[0]}'; // dd/MM/yyyy ← slash
      }
    }

    setState(() {
      _selectedRow = row;
      _isEditMode = true;
      _formValues = {
        'holidayCode': raw.holidayCode?.toString() ?? '',
        'holidayName': raw.holidayName ?? '',
        'holidayDate': dateVal,
        'companyCode': raw.companyCode?.toString() ?? '',
        'sortID': raw.sortID?.toString() ?? '',
        'active': raw.active == true ? 'true' : 'false',
      };
    });
    if (Responsive.isMobile(context)) {
      setState(() => _showTableOnMobile = false);
    }
  }

  Future<void> _onSave(Map<String, dynamic> values) async {
    final provider = context.read<HolidayProvider>();
    bool success;
    if (_isEditMode && _selectedRow != null) {
      final raw = _selectedRow!['_raw'] as HolidayModel;
      success = await provider.update(raw.holidayCode!, values);
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
            ? 'Holiday updated successfully.'
            : 'Holiday saved successfully.',
      );
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(_isEditMode
      //         ? 'Holiday updated successfully'
      //         : 'Holiday saved successfully'),
      //     backgroundColor: _theme.primary,
      //     behavior: SnackBarBehavior.floating,
      //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      //     margin: const EdgeInsets.all(12),
      //   ),
      // );
    }
  }

  Future<void> _onDelete() async {
    final raw = _selectedRow?['_raw'] as HolidayModel?;
    if (raw?.holidayCode == null) return;
    final confirm = await ErpDeleteDialog.show(context: context, theme: _theme, title: 'Holiday', itemName: raw!.holidayName??"");

    // final confirm = await showDialog<bool>(
    //   context: context,
    //   builder: (_) => AlertDialog(
    //     title: const Text('Delete Holiday'),
    //     content: Text('Delete "${raw!.holidayName}"? This cannot be undone.'),
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
    await context.read<HolidayProvider>().delete(raw!.holidayCode!);
    if (success && mounted) {
      _resetForm();
      await ErpResultDialog.showDeleted(
        context: context,
        theme: _theme,
        itemName: raw.holidayName ?? '',
      );
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: const Text('Holiday deleted successfully'),
      //     backgroundColor: Colors.red.shade600,
      //     behavior: SnackBarBehavior.floating,
      //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      //     margin: const EdgeInsets.all(12),
      //   ),
      // );
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final companyProvider = context.watch<CompanyProvider>();

    return Consumer<HolidayProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child:
                Responsive.isMobile(context)?_showTableOnMobile?ErpDataTable(
                  isReportRow: false,

                  token: token ?? '',
                  url: 'http://50.62.183.116:5000',
                  title: 'HOLIDAY LIST',
                  columns: _tableColumns,
                  data: provider.tableData,
                  // theme: _theme,
                  showSearch: true,
                  showFooterTotals: false,
                  selectedRow: _selectedRow,
                  onRowTap: _onRowTap,
                  emptyMessage: provider.isLoaded
        ? 'No Holiday found'
        : 'Loading...',
                ):ErpForm(
                  logo: AppImages.logo,

                  key: _erpFormKey,
                  title: 'HOLIDAY MASTER',
                  subtitle: 'Holiday Information',
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
              Expanded(
                flex: 2,
                child: ErpForm(
                  logo: AppImages.logo,

                  key: _erpFormKey,
                  title: 'HOLIDAY MASTER',
                  subtitle: 'Holiday Information',
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
              Expanded(
                flex: 2,
                child: ErpDataTable(
                  isReportRow: false,

                  token: token ?? '',
                  url: 'http://50.62.183.116:5000',
                  title: 'HOLIDAY LIST',
                  columns: _tableColumns,
                  data: provider.tableData,
                  // theme: _theme,
                  showSearch: true,
                  showFooterTotals: false,
                  selectedRow: _selectedRow,
                  onRowTap: _onRowTap,
                  emptyMessage: provider.isLoaded
                      ? 'No Holiday found'
                      : 'Loading...',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

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