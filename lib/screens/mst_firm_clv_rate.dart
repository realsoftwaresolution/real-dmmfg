// lib/screens/mst_firm_clv_rate.dart
import 'package:diam_mfg/models/dept_process_model.dart';
import 'package:diam_mfg/providers/article_provider.dart';
import 'package:diam_mfg/providers/company_provider.dart';
import 'package:diam_mfg/providers/counter_provider.dart';
import 'package:diam_mfg/utils/panel.dart';
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
  DeptProcessModel? _selectedDept;

  // selection arrays for detail panels (persisted to API on save)
  Set<int> _selectedArticles = {};

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
      key: 'articles',
      label: 'ARTICALS',
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
      final exists = context.read<DeptProvider>().list.any(
        (d) => d.deptCode == deptCode,
      );
      return exists ? 'Y' : 'N';
    } catch (_) {
      return 'N';
    }
  }

  String _deptNameFor(int? deptCode) {
    if (deptCode == null) return '';
    try {
      return context
          .read<DeptProvider>()
          .list
          .firstWhere((d) => d.deptCode == deptCode)
          .deptName ??
          '';
    } catch (_) {
      return '';
    }
  }

  // Form fields - DYNAMIC based on selected department
  List<List<ErpFieldConfig>> _buildFormRows() {
    final deptProvider = context.read<DeptProvider>();
    final counterProvider = context.read<CounterProvider>();
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
          key: 'crId',
          label: 'PARTY',
          type: ErpFieldType.dropdown,
          required: !isPartyDisabled,
          sectionIndex: 0,
          readOnly: isPartyDisabled,
          dropdownItems: isPartyDisabled
              ? []
              : counterProvider.list
                    .where((e) => e.active == true)
                    .map(
                      (e) => ErpDropdownItem(
                        label:  '${e.crName ?? ''}  |  ${_deptNameFor(e.deptCode)}',
                        value: e.crId?.toString() ?? '',
                      ),
                    )
                    .toList(),
        ),
        ErpFieldConfig(
          key: 'deptCode',
          label: 'DEPARTMENT',
          type: ErpFieldType.dropdown,
          readOnly: true,
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
          key: 'deptProcessCode',
          label: 'PROCESS',
          type: ErpFieldType.multiselectDropdown,
          sectionIndex: 0,
          dropdownItems: processItems,
        ),
        ErpFieldConfig(
          key: 'shapeCode',
          label: 'SHAPE',
          type: ErpFieldType.multiselectDropdown,
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
        context.read<CounterProvider>().load(),
        context.read<PartyProvider>().loadParties(),
        context.read<DeptProcessProvider>().load(),
        context.read<RemarksProvider>().load(),
        context.read<ShapeProvider>().load(),
        context.read<ArticleProvider>().load(),
      ]);
    });
  }

  void _onRowTap(Map<String, dynamic> row) {
    final raw = row['_raw'] as ClvRateModel;
    setState(() {
      _selectedRow = row;
      _isEditMode = true;
      _selectedDeptCode = raw.deptCode;
      _selectedDept = context
          .read<DeptProcessProvider>()
          .list
          .where((e) => e.deptCode == raw.deptCode)
          .firstOrNull;
      _selectedDeptRateOn = _getRateOnForDept(raw.deptCode);

      final deptProcessStr = raw.deptProcessCodes.isNotEmpty
          ? raw.deptProcessCodes.join(',')
          : (raw.deptProcessCode?.toString() ?? '');

      final shapeStr = raw.shapeCodes.isNotEmpty
          ? raw.shapeCodes.join(',')
          : (raw.shapeCode?.toString() ?? '');

      _formValues = {
        'type': raw.type ?? '',
        'clvRateCode': raw.clvRateCode?.toString() ?? '',
        'sortID': raw.sortID?.toString() ?? '',
        'active': raw.active == true ? 'true' : 'false',
        'companyCode': raw.companyCode?.toString() ?? '',
        'deptCode': raw.deptCode?.toString() ?? '',
        'crId': raw.crId?.toString() ?? '',
        'deptProcessCode': deptProcessStr,
        'shapeCode': shapeStr,
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
      _selectedArticles = raw.articlesIds.toSet();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _formValues.forEach((key, value) {
        _erpFormKey.currentState?.updateFieldValue(key, value);
      });
    });

    if (Responsive.isMobile(context)) {
      setState(() => _showTableOnMobile = false);
    }
  }

  Future<void> _onSave(Map<String, dynamic> values) async {
    if (_selectedDept?.rateOnArticle == 'Y' && _selectedArticles.isEmpty) {
      await ErpResultDialog.showError(
        context: context,
        theme: context.erpTheme,
        title: 'Validation Error',
        message: 'Please select at least one Article.',
      );
      return;
    }

    final provider = context.read<ClvRateProvider>();

    final deptProcessStr = _formValues['deptProcessCode'] ?? values['deptProcessCode']?.toString() ?? '';
    final deptProcessList = deptProcessStr
        .split(',')
        .where((e) => e.isNotEmpty)
        .map((e) => int.tryParse(e) ?? 0)
        .where((e) => e != 0)
        .toList();

    final shapeStr = _formValues['shapeCode'] ?? values['shapeCode']?.toString() ?? '';
    final shapeList = shapeStr
        .split(',')
        .where((e) => e.isNotEmpty)
        .map((e) => int.tryParse(e) ?? 0)
        .where((e) => e != 0)
        .toList();

    final articleList = _selectedArticles.isEmpty ? [] : _selectedArticles.toList();

    // Map form values to API payload
    final payload = {
      'DeptCode': int.tryParse(_formValues['deptCode'] ?? values['deptCode']?.toString() ?? '') ?? 0,
      'CrId': int.tryParse(_formValues['crId'] ?? values['crId']?.toString() ?? '') ?? 0,
      'deptProcesses': deptProcessList,
      'RateID': _formValues['rateID'] ?? values['rateID']?.toString() ?? 0,
      'shapes': shapeList,
      'articles': articleList,
      'Type': _formValues['type'] ?? values['type']?.toString() ?? 'SPK',
      'Rateon': _formValues['rateOn'] ?? values['rateOn']?.toString() ?? '',
      'RateSizeOn': _formValues['rateSizeOn'] ?? values['rateSizeOn']?.toString() ?? '',
      'FromWt': double.tryParse(_formValues['fromWt'] ?? values['fromWt']?.toString() ?? '') ?? 0.0,
      'ToWt': double.tryParse(_formValues['toWt'] ?? values['toWt']?.toString() ?? '') ?? 0.0,
      'Rate': double.tryParse(_formValues['rate'] ?? values['rate']?.toString() ?? '') ?? 0.0,
      'RepairRate': double.tryParse(_formValues['repairRate'] ?? values['repairRate']?.toString() ?? '') ?? 0.0,
      'PieRate': double.tryParse(_formValues['pieRate'] ?? values['pieRate']?.toString() ?? '') ?? 0.0,
      'LSRate': double.tryParse(_formValues['lsRate'] ?? values['lsRate']?.toString() ?? '') ?? 0.0,
      'Bonus': double.tryParse(_formValues['bonus'] ?? values['bonus']?.toString() ?? '') ?? 0.0,
      'RepairBonus': double.tryParse(_formValues['repairBonus'] ?? values['repairBonus']?.toString() ?? '') ?? 0.0,
      'Ever': double.tryParse(_formValues['ever'] ?? values['ever']?.toString() ?? '') ?? 0.0,
      'RemarksCode': int.tryParse(_formValues['remarksCode'] ?? values['remarksCode']?.toString() ?? '') ?? 0,
      'SortID': int.tryParse(_formValues['sortID'] ?? values['sortID']?.toString() ?? '') ?? 0,
      'Active': (values['active'] == '1' || values['active'] == 'true' || values['active'] == true) ? true : false,
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
      final wasEditMode = _isEditMode;
      if (wasEditMode) {
        _resetForm();
      } else {
        _resetRateFieldsOnly();
      }
      await ErpResultDialog.showSuccess(
        context: context,
        theme: context.erpTheme,
        title: wasEditMode ? 'Updated' : 'Saved',
        message: wasEditMode ? 'CLV Process Rate updated.' : 'CLV Process Rate saved.',
      );
      if (!wasEditMode) {
        _focusRateIdField();
      }
    } else {
      await ErpResultDialog.showError(
        context: context,
        theme: context.erpTheme,
        title: 'Error',
        message: 'Save failed.',
      );
    }
  }

  void _focusRateIdField() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          _erpFormKey.currentState?.focusField('rateID');
        }
      });
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) {
          _erpFormKey.currentState?.focusField('rateID');
        }
      });
    });
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

  void _resetRateFieldsOnly() {
    setState(() {
      _selectedRow = null;
      _isEditMode = false;

      // Reset sectionIndex 1 & 2 fields in _formValues and UI
      const section1And2Keys = [
        'rateID',
        'rateOn',
        'rateSizeOn',
        'fromWt',
        'toWt',
        'rate',
        'repairRate',
        'pieRate',
        'lsRate',
        'bonus',
        'repairBonus',
        'ever',
        'sortID',
      ];

      for (final key in section1And2Keys) {
        _formValues.remove(key);
        _erpFormKey.currentState?.updateFieldValue(key, '');
      }

      _formValues['active'] = 'true';
      _erpFormKey.currentState?.updateFieldValue('active', 'true');
    });
    _focusRateIdField();
  }

  void _resetForm() {
    setState(() {
      _selectedRow = null;
      _isEditMode = false;
      _formValues = {};
      _showTableOnMobile = false;
      _selectedDeptCode = null;
      _selectedDeptRateOn = null;
      _selectedDept = null;
      _selectedArticles = {};
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
                        detailBuilder: _buildDetailPanels,
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
                        detailBuilder: _buildDetailPanels,
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

  Widget _buildDetailPanels(BuildContext ctx) {
    final articleProv = context.watch<ArticleProvider>();
    final deptProcessList = context.watch<DeptProcessProvider>().list;
    final panels = <PanelConfig>[];

    final selectedProcessIds = (_formValues['deptProcessCode'] ?? '')
        .split(',')
        .where((e) => e.isNotEmpty)
        .map((e) => int.tryParse(e) ?? 0)
        .where((e) => e != 0)
        .toList();

    bool isArticleAllowed = false;

    if (selectedProcessIds.isNotEmpty) {
      isArticleAllowed = deptProcessList.any(
        (p) => selectedProcessIds.contains(p.deptProcessCode) && p.rateOnArticle == 'Y',
      );
    }

    if (!isArticleAllowed && _selectedDeptCode != null) {
      final deptProcesses = deptProcessList.where((p) => p.deptCode == _selectedDeptCode);
      if (deptProcesses.isEmpty || deptProcesses.any((p) => p.rateOnArticle != 'N')) {
        isArticleAllowed = true;
      }
    }

    if (_selectedDept?.rateOnArticle == 'Y' || _selectedArticles.isNotEmpty) {
      isArticleAllowed = true;
    }

    if (isArticleAllowed && articleProv.list.isNotEmpty) {
      panels.add(
        PanelConfig(
          title: 'ARTICLE',
          items: articleProv.list
              .map(
                (e) => PanelItem(
                  id: e.articalCode ?? 0,
                  name: e.articalName ?? '',
                ),
              )
              .toList(),
          selectedIds: _selectedArticles,
          onChanged: (set) {
            setState(() {
              _selectedArticles = set;
            });
          },
        ),
      );
    }

    return DetailPanels(panels: panels, childAspectRatio: 210 / 400);
  }

  void _onFieldChanged(String key, dynamic value) {
    if (value is List) {
      _formValues[key] = value.join(',');
    } else {
      _formValues[key] = value?.toString() ?? '';
    }

    // When department is selected, update the tracking state
    if (key == 'deptCode') {
      final deptCode = int.tryParse(value.toString());
      final deptProcessList = context.read<DeptProcessProvider>().list;
      final matching = deptProcessList.where((e) => e.deptCode == deptCode);
      final dept = matching.isEmpty
          ? null
          : matching.firstWhere(
              (e) => e.rateOnArticle == 'Y',
              orElse: () => matching.first,
            );

      setState(() {
        _selectedDept = dept;
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

    if (key == 'deptProcessCode') {
      final selectedProcessIds = (value is List ? value.join(',') : value.toString())
          .split(',')
          .where((e) => e.isNotEmpty)
          .map((e) => int.tryParse(e) ?? 0)
          .where((e) => e != 0)
          .toList();

      final deptProcessList = context.read<DeptProcessProvider>().list;
      final matchedProcess = deptProcessList.isEmpty
          ? null
          : deptProcessList.firstWhere(
              (e) => selectedProcessIds.contains(e.deptProcessCode) && e.rateOnArticle == 'Y',
              orElse: () => deptProcessList.firstWhere(
                (e) => selectedProcessIds.contains(e.deptProcessCode),
                orElse: () => _selectedDept ?? deptProcessList.first,
              ),
            );

      if (matchedProcess != null) {
        setState(() {
          _selectedDept = matchedProcess;
        });
      }
    }

    // When Party (crId) is selected, auto-set department (deptCode) from counter
    if (key == 'crId') {
      final crId = int.tryParse(value.toString());
      final partyObj = context
          .read<CounterProvider>()
          .list
          .where((e) => e.crId == crId)
          .firstOrNull;

      final deptCode = partyObj?.deptCode;

      if (deptCode != null) {
        final deptProcessList = context.read<DeptProcessProvider>().list;
        final matching = deptProcessList.where((e) => e.deptCode == deptCode);
        final dept = matching.isEmpty
            ? null
            : matching.firstWhere(
                (e) => e.rateOnArticle == 'Y',
                orElse: () => matching.first,
              );

        setState(() {
          _selectedDept = dept;
          _selectedDeptCode = deptCode;
          _selectedDeptRateOn = _getRateOnForDept(deptCode);
          _formValues['deptCode'] = deptCode.toString();

          // Clear dependent fields
          _formValues['deptProcessCode'] = '';
        });

        _erpFormKey.currentState?.updateFieldValue(
          'deptCode',
          deptCode.toString(),
        );
        _erpFormKey.currentState?.updateFieldValue(
          'deptProcessCode',
          '',
        );
      }

      Future.delayed(const Duration(milliseconds: 50), () {
        _erpFormKey.currentState?.focusField('deptProcessCode');
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

