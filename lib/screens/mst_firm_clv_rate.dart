// lib/screens/mst_firm_clv_rate.dart
import 'dart:convert';

import 'package:diam_mfg/providers/company_provider.dart';
import 'package:erp_data_table/erp_data_table.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rs_dashboard/rs_dashboard.dart';

import '../bootstrap.dart';
import '../models/clv_rate_model.dart';
import '../providers/clv_rate_provider.dart';
import '../providers/dept_provider.dart';
import '../providers/dept_process_provider.dart';
import '../providers/party_provider.dart';
import '../providers/remarks_provider.dart';
import '../providers/shape_provider.dart';
import '../utils/app_images.dart';
import '../utils/delete_dialogue.dart';
import '../utils/msg_dialogue.dart';

class MstClvRate extends StatefulWidget {
  const MstClvRate({super.key});

  @override
  State<MstClvRate> createState() => _MstClvRateState();
}

class _MstClvRateState extends State<MstClvRate> {
  final GlobalKey<ErpFormState> _erpFormKey = GlobalKey<ErpFormState>();
  Map<String, dynamic>? _selectedRow;
  bool _isEditMode = false;
  Map<String, String> _formValues = {};

  // ── Track selected department ──────────────────────────────────────────────
  int? _selectedDeptCode;
  String? _selectedDeptRateOn; // Will store 'Y' or 'N'

  final String? token = AppStorage.getString("token");

  // Table columns matching model.toTableRow keys
  List<ErpColumnConfig> get _tableColumns => [
    ErpColumnConfig(
      key: 'deptName',
      label: 'DEPT',
      width: 150,
      align: ColumnAlign.center,
    ),
    ErpColumnConfig(
      key: 'crName',
      label: 'PARTY',
      width: 150,
      align: ColumnAlign.center,
    ),
    ErpColumnConfig(
      key: 'deptProcessName',
      label: 'PROCESS',
      width: 150,
      align: ColumnAlign.center,
    ),
    ErpColumnConfig(
      key: 'remarksName',
      label: 'REMARKS',
      width: 200,
      align: ColumnAlign.center,
    ),
    ErpColumnConfig(
      key: 'shapeName',
      label: 'SHAPE',
      width: 150,
      align: ColumnAlign.center,
    ),
    ErpColumnConfig(
      key: 'clvProcessRateCode',
      label: 'RATE CODE',
      width: 200,
      align: ColumnAlign.center,
    ),
    ErpColumnConfig(
      key: 'rateOn',
      label: 'RATE ON',
      width: 150,
      align: ColumnAlign.center,
    ),
    ErpColumnConfig(
      key: 'rateSizeOn',
      label: 'SIZE ON',
      width: 150,
      align: ColumnAlign.center,
    ),
    ErpColumnConfig(
      key: 'fromWt',
      label: 'FROM WT',
      width: 150,
      align: ColumnAlign.center,
    ),
    ErpColumnConfig(
      key: 'toWt',
      label: 'TO WT',
      width: 150,
      align: ColumnAlign.center,
    ),
    ErpColumnConfig(
      key: 'companyName',
      label: 'COMPANY',
      width: 200,
      align: ColumnAlign.center,
    ),
    ErpColumnConfig(
      key: 'type',
      label: 'TYPE',
      width: 150,
      align: ColumnAlign.center,
    ),
    ErpColumnConfig(
      key: 'rate',
      label: 'RATE',
      width: 150,
      align: ColumnAlign.center,
    ),
    ErpColumnConfig(
      key: 'repairRate',
      label: 'REP RATE',
      width: 150,
      align: ColumnAlign.center,
    ),
    ErpColumnConfig(
      key: 'sortID',
      label: 'SORT ID',
      width: 150,
      align: ColumnAlign.center,
    ),
    ErpColumnConfig(
      key: 'active',
      label: 'ACTIVE',
      width: 150,
      align: ColumnAlign.center,
    ),
    ErpColumnConfig(
      key: 'pieRate',
      label: 'PIE RATE',
      width: 150,
      align: ColumnAlign.center,
    ),
    ErpColumnConfig(
      key: 'lsRate',
      label: 'LS RATE',
      width: 150,
      align: ColumnAlign.center,
    ),
  ];

  // ── Helper: Get rateOn for selected department ──────────────────────────
  String _getRateOnForDept(int? deptCode) {
    if (deptCode == null) return 'N';
    try {
      final dept = context.read<DeptProvider>().list.firstWhere(
        (d) => d.deptCode == deptCode,
      );
      // Adjust based on your actual model field
      return 'Y'; // Default to 'Y' if field doesn't exist
    } catch (_) {
      return 'N';
    }
  }

  // Form fields - DYNAMIC based on selected department
  List<List<ErpFieldConfig>> _buildFormRows() {
    final deptProvider = context.read<DeptProvider>();
    final partyProvider = context.read<PartyProvider>();
    final deptProcessProvider = context.read<DeptProcessProvider>();
    final remarksProvider = context.read<RemarksProvider>();
    final shapeProvider = context.read<ShapeProvider>();

    // Filter dept process by selected department
    final processItems = deptProcessProvider.list
        .where((p) {
          if (_selectedDeptCode == null) return false;
          // Filter process by department code
          return p.active == true && p.deptCode == _selectedDeptCode;
        })
        .map(
          (e) => ErpDropdownItem(
            label: e.deptProcessName ?? '',
            value: e.deptProcessCode?.toString() ?? '',
          ),
        )
        .toList();

    // Check if party should be disabled
    final isPartyDisabled = _selectedDeptRateOn == 'N';

    return [
      [
        ErpFieldConfig(
          key: 'deptCode',
          label: 'DEPARTMENT',
          type: ErpFieldType.dropdown,
          sectionIndex: 0,
          dropdownItems: deptProvider.list
              .where((e) => e.active == true)
              .map(
                (e) => ErpDropdownItem(
                  label: e.deptName ?? '',
                  value: e.deptCode?.toString() ?? '',
                ),
              )
              .toList(),
        ),
        ErpFieldConfig(
          key: 'crId',
          label: 'PARTY',
          type: ErpFieldType.dropdown,
          required: !isPartyDisabled,
          sectionIndex: 0,
          readOnly: isPartyDisabled,
          dropdownItems: isPartyDisabled
              ? []
              : partyProvider.list
                    .where((e) => e.active == true)
                    .map(
                      (e) => ErpDropdownItem(
                        label: e.partyName ?? '',
                        value: e.partyCode?.toString() ?? '',
                      ),
                    )
                    .toList(),
        ),
        ErpFieldConfig(
          key: 'deptProcessCode',
          label: 'PROCESS',
          type: ErpFieldType.dropdown,
          sectionIndex: 0,
          dropdownItems: processItems,
        ),
        ErpFieldConfig(
          key: 'shapeCode',
          label: 'SHAPE',
          type: ErpFieldType.dropdown,
          sectionIndex: 0,
          dropdownItems: shapeProvider.list
              .where((e) => e.active == true)
              .map(
                (e) => ErpDropdownItem(
                  label: e.shapeName ?? '',
                  value: e.shapeCode?.toString() ?? '',
                ),
              )
              .toList(),
        ),
        ErpFieldConfig(
          key: 'remarksCode',
          label: 'REMARKS',
          type: ErpFieldType.dropdown,
          sectionIndex: 0,
          dropdownItems: remarksProvider.list
              .where((e) => e.active == true)
              .map(
                (e) => ErpDropdownItem(
                  label: e.remarksName ?? '',
                  value: e.remarksCode?.toString() ?? '',
                ),
              )
              .toList(),
        ),
      ],
      [
        ErpFieldConfig(
          key: 'rateID',
          label: 'RATE ID',
          type: ErpFieldType.text,
          sectionIndex: 1,
        ),
        ErpFieldConfig(
          key: 'rateOn',
          label: 'RATE ON',
          type: ErpFieldType.dropdown,
          dropdownItems: const [
            ErpDropdownItem(label: 'DMWT', value: 'DmWt'),
            ErpDropdownItem(label: 'PC', value: 'Pc'),
            ErpDropdownItem(label: 'ISSWT', value: 'IssWt'),
            ErpDropdownItem(label: 'RECWT', value: 'RecWt'),
            ErpDropdownItem(label: 'MAKABLEWT', value: 'MakableWt'),
            ErpDropdownItem(label: 'CALWT', value: 'CalWt'),
          ],
          sectionIndex: 1,
        ),
        ErpFieldConfig(
          key: 'rateSizeOn',
          label: 'SIZE ON',
          type: ErpFieldType.dropdown,
          dropdownItems: const [
            ErpDropdownItem(label: 'DMWT', value: 'DmWt'),
            ErpDropdownItem(label: 'ISSWT', value: 'IssWt'),
            ErpDropdownItem(label: 'DIAM', value: 'Diam'),
            ErpDropdownItem(label: 'RECWT', value: 'RecWt'),
            ErpDropdownItem(label: 'MAKABLEWT', value: 'MakableWt'),
          ],
          sectionIndex: 1,
        ),
        ErpFieldConfig(
          key: 'fromWt',
          label: 'FROM WT',
          type: ErpFieldType.wt,
          sectionIndex: 1,
        ),
        ErpFieldConfig(
          key: 'toWt',
          label: 'TO WT',
          type: ErpFieldType.wt,
          sectionIndex: 1,
        ),
      ],
      [
        ErpFieldConfig(
          key: 'rate',
          label: 'RATE',
          type: ErpFieldType.amount,
          sectionIndex: 2,
        ),
        ErpFieldConfig(
          key: 'sortID',
          label: 'SORT ID',
          type: ErpFieldType.number,
          sectionIndex: 2,
        ),
        ErpFieldConfig(
          key: 'active',
          label: 'ACTIVE',
          type: ErpFieldType.checkbox,
          checkboxDbType: 'BIT',
          sectionIndex: 2,
          initialBoolValue: true,
        ),
      ],
    ];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.wait([
        context.read<ClvRateProvider>().loadClvRates(),
        context.read<DeptProvider>().load(),
        context.read<PartyProvider>().loadParties(),
        context.read<DeptProcessProvider>().load(),
        context.read<RemarksProvider>().load(),
        context.read<ShapeProvider>().load(),
      ]);
    });
  }

  void _onRowTap(Map<String, dynamic> row) {
    final raw = row['_raw'] as ClvRateModel;
    setState(() {
      _selectedRow = row;
      _isEditMode = true;
      _selectedDeptCode = raw.deptCode;
      _selectedDeptRateOn = _getRateOnForDept(raw.deptCode);
      _formValues = {
        'type': raw.type ?? '',
        'clvRateCode': raw.clvRateCode?.toString() ?? '',
        'sortID': raw.sortID?.toString() ?? '',
        'active': raw.active == true ? 'true' : 'false',
        'companyCode': raw.companyCode?.toString() ?? '',
        'deptCode': raw.deptCode?.toString() ?? '',
        'crId': raw.crId?.toString() ?? '',
        'deptProcessCode': raw.deptProcessCode?.toString() ?? '',
        'shapeCode': raw.shapeCode?.toString() ?? '',
        'rateID': raw.rateID?.toString() ?? '',
        'rateOn': raw.rateOn?.trim() ?? '',
        'rateSizeOn': raw.rateSizeOn?.trim() ?? '',
        'fromWt': raw.fromWt?.toString() ?? '',
        'toWt': raw.toWt?.toString() ?? '',
        'rate': raw.rate?.toString() ?? '',
        'repairRate': raw.repairRate?.toString() ?? '',
        'pieRate': raw.pieRate?.toString() ?? '',
        'lsRate': raw.lsRate?.toString() ?? '',
        'bonus': raw.bonus?.toString() ?? '',
        'repairBonus': raw.repairBonus?.toString() ?? '',
        'ever': raw.ever?.toString() ?? '',
        'remarksCode': raw.remarksCode?.toString() ?? '',
      };
    });
    if (Responsive.isMobile(context)) {
      setState(() => _showTableOnMobile = false);
    }
  }

  Future<void> _onSave(Map<String, dynamic> values) async {
    print(values);
    final provider = context.read<ClvRateProvider>();

    // Map form values to API payload
    final payload = {
      'DeptCode': int.tryParse(values['deptCode']?.toString() ?? '') ?? 0,
      'CrId': int.tryParse(values['crId']?.toString() ?? '') ?? 0,
      'DeptProcessCode':
          int.tryParse(values['deptProcessCode']?.toString() ?? '') ?? 0,
      'RateID': values['rateID']?.toString() ?? 0,
      'ShapeCode': int.tryParse(values['shapeCode']?.toString() ?? '') ?? 0,
      'Type': values['type']?.toString() ?? 'SPK',
      'Rateon': values['rateOn']?.toString() ?? '',
      'RateSizeOn': values['rateSizeOn']?.toString() ?? '',
      'FromWt': double.tryParse(values['fromWt']?.toString() ?? '') ?? 0.0,
      'ToWt': double.tryParse(values['toWt']?.toString() ?? '') ?? 0.0,
      'Rate': double.tryParse(values['rate']?.toString() ?? '') ?? 0.0,
      'RepairRate':
          double.tryParse(values['repairRate']?.toString() ?? '') ?? 0.0,
      'PieRate': double.tryParse(values['pieRate']?.toString() ?? '') ?? 0.0,
      'LSRate': double.tryParse(values['lsRate']?.toString() ?? '') ?? 0.0,
      'Bonus': double.tryParse(values['bonus']?.toString() ?? '') ?? 0.0,
      'RepairBonus':
          double.tryParse(values['repairBonus']?.toString() ?? '') ?? 0.0,
      'Ever': double.tryParse(values['ever']?.toString() ?? '') ?? 0.0,
      'RemarksCode': int.tryParse(values['remarksCode']?.toString() ?? '') ?? 0,
      'SortID': int.tryParse(values['sortID']?.toString() ?? '') ?? 0,
      'Active': values['active'] == '1' ? true : false,
      'CompanyCode': context
          .read<CompanyProvider>()
          .selectedCompanyCode
          ?.toString(),
    };

    bool success;
    if (_isEditMode && _selectedRow != null) {
      final raw = _selectedRow!['_raw'] as ClvRateModel;
      final id = raw.clvRateMstID ?? raw.clvRateCode ?? 0;
      success = await provider.updateClvRate(id, payload);
    } else {
      success = await provider.createClvRate(payload);
    }

    if (!mounted) return;
    if (success) {
      _resetForm();
      await ErpResultDialog.showSuccess(
        context: context,
        theme: context.erpTheme,
        title: _isEditMode ? 'Updated' : 'Saved',
        message: _isEditMode ? 'CLV Process Rate updated.' : 'CLV Process Rate saved.',
      );
    } else {
      await ErpResultDialog.showError(
        context: context,
        theme: context.erpTheme,
        title: 'Error',
        message: 'Save failed.',
      );
    }
  }

  Future<void> _onDelete() async {
    final raw = _selectedRow?['_raw'] as ClvRateModel?;
    if (raw?.clvRateMstID == null) return;
    final confirm = await ErpDeleteDialog.show(
      context: context,
      theme: context.erpTheme,
      title: 'CLV Rate',
      itemName: raw!.clvRateCode?.toString() ?? 'Rate',
    );
    if (confirm != true || !mounted) return;
    final success = await context.read<ClvRateProvider>().deleteClvRate(
      raw.clvRateMstID!,
    );
    if (success && mounted) {
      await ErpResultDialog.showDeleted(
        context: context,
        theme: context.erpTheme,
        itemName: raw.clvRateCode?.toString() ?? '',
      );
      _resetForm();
    }
  }

  void _resetForm() {
    setState(() {
      _selectedRow = null;
      _isEditMode = false;
      _formValues = {};
      _showTableOnMobile = false;
      _selectedDeptCode = null;
      _selectedDeptRateOn = null;
    });
    _erpFormKey.currentState?.resetForm();
    _formValues['active'] = 'true';
    _erpFormKey.currentState?.updateFieldValue('active', 'true');
  }

  bool _showTableOnMobile = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<ClvRateProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child: Responsive.isMobile(context)
              ? _showTableOnMobile
                    ? buildErpDataTable(provider)
                    : ErpForm(
                        logo: AppImages.logo,
                        key: _erpFormKey,
                        title: 'CLV PROCESS RATE MASTER',
                        subtitle: 'CLV Process Rate configuration',
                        initialTabIndex: 0,
                        onSearch: () =>
                            setState(() => _showTableOnMobile = true),
                        tabBarBackgroundColor: const Color(0xfff2f0ef),
                        tabBarSelectedColor:
                            context.erpTheme.primaryGradient.first,
                        tabBarSelectedTxtColor: Colors.white,
                        rows: _buildFormRows(),
                        initialValues: _formValues,
                        isEditMode: _isEditMode,
                        onFieldChanged: _onFieldChanged,
                        onSave: _onSave,
                        onCancel: _resetForm,
                        onDelete: _isEditMode ? _onDelete : null,
                      )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: ErpForm(
                        logo: AppImages.logo,
                        key: _erpFormKey,
                        title: 'CLV PROCESS RATE MASTER',
                        subtitle: 'CLV Process Rate configuration',
                        initialTabIndex: 0,
                        tabBarBackgroundColor: const Color(0xfff2f0ef),
                        tabBarSelectedColor:
                            context.erpTheme.primaryGradient.first,
                        tabBarSelectedTxtColor: Colors.white,
                        rows: _buildFormRows(),
                        initialValues: _formValues,
                        isEditMode: _isEditMode,
                        onFieldChanged: _onFieldChanged,
                        onSave: _onSave,
                        onCancel: _resetForm,
                        onDelete: _isEditMode ? _onDelete : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(flex: 2, child: buildErpDataTable(provider)),
                  ],
                ),
        );
      },
    );
  }

  void _onFieldChanged(String key, dynamic value) {
    _formValues[key] = value.toString();

    // When department is selected, update the tracking state
    if (key == 'deptCode') {
      final deptCode = int.tryParse(value.toString());
      setState(() {
        _selectedDeptCode = deptCode;
        _selectedDeptRateOn = _getRateOnForDept(deptCode);
        // Clear dependent fields
        _formValues['deptProcessCode'] = '';
        _formValues['crId'] = '';
      });
      _erpFormKey.currentState?.updateFieldValue('deptProcessCode', '');
      _erpFormKey.currentState?.updateFieldValue('crId', '');

      // ✅ Focus to next field after department is selected
      Future.delayed(const Duration(milliseconds: 50), () {
        _erpFormKey.currentState?.focusField('crId');
      });
    }

    // ✅ ADD FOCUS MANAGEMENT FOR OTHER FIELDS
    if (key == 'crId') {
      Future.delayed(const Duration(milliseconds: 50), () {
        _erpFormKey.currentState?.focusField('deptProcessCode');
      });
    }

    if (key == 'deptProcessCode') {
      Future.delayed(const Duration(milliseconds: 50), () {
        _erpFormKey.currentState?.focusField('shapeCode');
      });
    }

    if (key == 'shapeCode') {
      Future.delayed(const Duration(milliseconds: 50), () {
        _erpFormKey.currentState?.focusField('remarksCode');
      });
    }
    if (key == 'remarksCode') {
      Future.delayed(const Duration(milliseconds: 50), () {
        _erpFormKey.currentState?.focusField('rateID');
      });
    }
  }

  ErpDataTable buildErpDataTable(ClvRateProvider provider) {
    return ErpDataTable(
      isReportRow: false,
      token: token ?? '',
      url: baseUrl,
      title: 'CLV PROCESS RATE LIST',
      columns: _tableColumns,
      data: provider.tableData,
      showSearch: true,
      selectedRow: _selectedRow,
      onRowTap: _onRowTap,
      emptyMessage: provider.isLoaded ? 'No rates found' : 'Loading...',
    );
  }
}
