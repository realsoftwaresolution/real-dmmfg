// lib/screens/mst_firm_department_rate.dart
import 'package:diam_mfg/models/department_rate_model.dart';
import 'package:diam_mfg/models/dept_process_model.dart';
import 'package:diam_mfg/providers/article_provider.dart';
import 'package:diam_mfg/providers/company_provider.dart';
import 'package:diam_mfg/providers/counter_provider.dart';
import 'package:diam_mfg/providers/cut_provider.dart';
import 'package:diam_mfg/providers/department_rate_provider.dart';
import 'package:diam_mfg/providers/certificate_provider.dart';
import 'package:diam_mfg/providers/polish_provider.dart';
import 'package:diam_mfg/utils/panel.dart';
import 'package:erp_data_table/erp_data_table.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rs_dashboard/rs_dashboard.dart';

import '../bootstrap.dart';
import '../providers/dept_provider.dart';
import '../providers/dept_process_provider.dart';
import '../providers/shape_provider.dart';
import '../utils/app_images.dart';
import '../utils/delete_dialogue.dart';
import '../utils/msg_dialogue.dart';

class MstDepartmentRate extends StatefulWidget {
  const MstDepartmentRate({super.key});

  @override
  State<MstDepartmentRate> createState() => _MstDepartmentRateState();
}

class _MstDepartmentRateState extends State<MstDepartmentRate> {
  final GlobalKey<ErpFormState> _erpFormKey = GlobalKey<ErpFormState>();
  Map<String, dynamic>? _selectedRow;
  bool _isEditMode = false;
  Map<String, String> _formValues = {};
  DeptProcessModel? _selectedDept;
  // selection arrays for detail panels (persisted to API on save)
  Set<int> _selectedShapes = {};
  Set<int> _selectedCuts = {};
  Set<int> _selectedArticles = {};

  // ── Track selected department ──────────────────────────────────────────────
  int? _selectedDeptCode;

  final String? token = AppStorage.getString("token");

  // Table columns matching model.toTableRow keys
  List<ErpColumnConfig> get _tableColumns => [
    ErpColumnConfig(
      key: 'deptName',
      label: 'DEPT',
      width: 150,
    ),
    ErpColumnConfig(
      key: 'deptProcessName',
      label: 'PROCESS',
      width: 150,
    ),
    ErpColumnConfig(
      key: 'deptRateCode',
      label: 'RATE CODE',
      width: 200,
    ),
    ErpColumnConfig(
      key: 'rateon',
      label: 'RATE ON',
      width: 150,
    ),
    ErpColumnConfig(
      key: 'sizeon',
      label: 'SIZE ON',
      width: 150,
    ),
    ErpColumnConfig(
      key: 'fromWt',
      label: 'FROM WT',
      width: 150,
    ),
    ErpColumnConfig(
      key: 'toWt',
      label: 'TO WT',
      width: 150,
    ),
    ErpColumnConfig(
      key: 'companyName',
      label: 'COMPANY',
      width: 200,
    ),
    ErpColumnConfig(
      key: 'rate',
      label: 'RATE',
      width: 150,
    ),
    ErpColumnConfig(
      key: 'articles',
      label: 'ARTICALS',
      width: 150,
    ),
    ErpColumnConfig(
      key: 'cuts',
      label: 'CUTS',
      width: 150,
    ),
    ErpColumnConfig(
      key: 'shapes',
      label: 'SHAPES',
      width: 150,
    ),
    ErpColumnConfig(
      key: 'active',
      label: 'ACTIVE',
      width: 200,
    ),
  ];

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

    return [
      [
        ErpFieldConfig(
          key: 'crId',
          label: 'MANAGER',
          type: ErpFieldType.dropdown,
          sectionIndex: 0,
          dropdownItems: counterProvider.list
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
        context.read<DepartmentRateProvider>().loadClvRates(),
        context.read<DeptProvider>().load(),
        context.read<CounterProvider>().load(),
        context.read<DeptProcessProvider>().load(),
        context.read<CutProvider>().loadCuts(),
        context.read<ShapeProvider>().load(),
        context.read<PolishProvider>().loadPolish(),
        context.read<LabProvider>().loadCuts(),
        context.read<ArticleProvider>().load(),
      ]);
    });
  }

  void _onRowTap(Map<String, dynamic> row) {
    final raw = row['_raw'] as DepartmentRateModel?;  // ← correct cast
    if (raw == null) return;

    final deptProcessStr = raw.deptProcessCodes.isNotEmpty
        ? raw.deptProcessCodes.join(',')
        : (raw.deptProcessCode != 0 ? raw.deptProcessCode.toString() : '');

    setState(() {
      _selectedRow = row;
      _isEditMode = true;
      _selectedDeptCode = raw.deptCode;
      _selectedDept = context
          .read<DeptProcessProvider>()
          .list
          .where((e) => e.deptCode == raw.deptCode)
          .firstOrNull;
      _formValues = {
        'crId': raw.crId.toString(),
        'deptCode': raw.deptCode.toString(),
        'deptProcessCode': deptProcessStr,
        'rateID': raw.rateID.toString(),
        'rateOn': raw.rateon,
        'rateSizeOn': raw.sizeon,
        'fromWt': raw.fromWt.toString(),
        'toWt': raw.toWt.toString(),
        'rate': raw.rate.toString(),
        'sortID': raw.sortID.toString(),
        'active': raw.active == 1 ? 'true' : 'false',
      };
      _selectedShapes = raw.shapesIds.toSet();
      _selectedCuts = raw.cutsIds.toSet();
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
// ── Validate: at least one selection required in each panel ──
    if (_selectedDept?.rateOnShape == 'Y' &&
        _selectedShapes.isEmpty) {
      await ErpResultDialog.showError(
        context: context,
        theme: context.erpTheme,
        title: 'Validation Error',
        message: 'Please select at least one Shape.',
      );
      return;
    }

    if (_selectedDept?.rateOnCut == 'Y' &&
        _selectedCuts.isEmpty) {
      await ErpResultDialog.showError(
        context: context,
        theme: context.erpTheme,
        title: 'Validation Error',
        message: 'Please select at least one Cut.',
      );
      return;
    }

    if (_selectedDept?.rateOnArticle == 'Y' &&
        _selectedArticles.isEmpty) {
      await ErpResultDialog.showError(
        context: context,
        theme: context.erpTheme,
        title: 'Validation Error',
        message: 'Please select at least one Article.',
      );
      return;
    }

    final provider = context.read<DepartmentRateProvider>();

    final deptProcessStr = _formValues['deptProcessCode'] ?? values['deptProcessCode']?.toString() ?? '';
    final deptProcessList = deptProcessStr
        .split(',')
        .where((e) => e.isNotEmpty)
        .map((e) => int.tryParse(e) ?? 0)
        .where((e) => e != 0)
        .toList();

    // Map form values to API payload
    final payload = {
      'DeptCode': int.tryParse(_formValues['deptCode'] ?? values['deptCode']?.toString() ?? '') ?? 0,
      'CrId': int.tryParse(_formValues['crId'] ?? values['crId']?.toString() ?? '') ?? 0,
      'deptProcesses': deptProcessList,
      'RateID': _formValues['rateID'] ?? values['rateID']?.toString() ?? 0,
      'Rateon': _formValues['rateOn'] ?? values['rateOn']?.toString() ?? '',
      'Sizeon': _formValues['rateSizeOn'] ?? values['rateSizeOn']?.toString() ?? '',
      'FromWt': double.tryParse(_formValues['fromWt'] ?? values['fromWt']?.toString() ?? '') ?? 0.0,
      'ToWt': double.tryParse(_formValues['toWt'] ?? values['toWt']?.toString() ?? '') ?? 0.0,
      'Rate': double.tryParse(_formValues['rate'] ?? values['rate']?.toString() ?? '') ?? 0.0,
      'CompanyCode': int.tryParse(values['companyCode']?.toString() ?? '') ??
          context.read<CompanyProvider>().selectedCompanyCode ?? 0,
      'SortID': int.tryParse(_formValues['sortID'] ?? values['sortID']?.toString() ?? '') ?? 0,
      'Active': (values['active'] == 'true' || values['active'] == '1' || values['active'] == true) ? 1 : 0,
      'shapes': _selectedShapes.isEmpty ? [] : _selectedShapes.toList(),
      'cuts': _selectedCuts.isEmpty ? [] : _selectedCuts.toList(),
      'articles': _selectedArticles.isEmpty ? [] : _selectedArticles.toList(),
    };

    bool success;
    if (_isEditMode && _selectedRow != null) {
      final raw = _selectedRow!['_raw'] as DepartmentRateModel;
      final id = raw.clvDeptRateMstID;
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
        message: wasEditMode
            ? 'CLV Department Rate updated.'
            : 'CLV Department Rate saved.',
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
    final raw = _selectedRow?['_raw'] as DepartmentRateModel?;
    if (raw?.clvDeptRateMstID == null) return;
    final confirm = await ErpDeleteDialog.show(
      context: context,
      theme: context.erpTheme,
      title: 'CLV Department Rate',
      itemName: raw!.deptRateCode.toString(),
    );
    if (confirm != true || !mounted) return;
    final success = await context.read<DepartmentRateProvider>().deleteClvRate(
      raw.clvDeptRateMstID,
    );
    if (success && mounted) {
      await ErpResultDialog.showDeleted(
        context: context,
        theme: context.erpTheme,
        itemName: raw.deptRateCode.toString(),
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
      // ── clear panel selections ──
      _selectedShapes = {};
      _selectedCuts = {};
      _selectedArticles = {};
    });
    _erpFormKey.currentState?.resetForm();
    _formValues['active'] = 'true';
    _erpFormKey.currentState?.updateFieldValue('active', 'true');
    _selectedDept = null;
  }

  bool _showTableOnMobile = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<DepartmentRateProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child: Responsive.isMobile(context)
              ? _showTableOnMobile
                    ? buildErpDataTable(provider)
                    : ErpForm(
                        logo: AppImages.logo,
                        key: _erpFormKey,
            title: 'CLV DEPARTMENT RATE MASTER',
            subtitle: 'CLV Department Rate configuration',
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
                        title: 'CLV DEPARTMENT RATE MASTER',
                        subtitle: 'CLV Department Rate configuration',
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
                        detailBuilder: (ctx) {
                          final shapeProv = context.watch<ShapeProvider>();
                          final cutProv = context.watch<CutProvider>();
                          final articleProv = context.watch<ArticleProvider>();

                          final panels = <PanelConfig>[];

                          if (_selectedDept?.rateOnShape == 'Y') {
                            panels.add(
                              PanelConfig(
                                title: 'SHAPE',
                                items: shapeProv.list
                                    .map(
                                      (e) => PanelItem(
                                    id: e.shapeCode ?? 0,
                                    name: e.shapeName ?? '',
                                  ),
                                )
                                    .toList(),
                                selectedIds: _selectedShapes,
                                onChanged: (set) {
                                  setState(() {
                                    _selectedShapes = set;
                                  });
                                },
                              ),
                            );
                          }

                          if (_selectedDept?.rateOnCut == 'Y') {
                            panels.add(
                              PanelConfig(
                                title: 'CUT',
                                items: cutProv.cuts
                                    .map(
                                      (e) => PanelItem(
                                    id: e.cutCode ?? 0,
                                    name: e.cutName ?? '',
                                  ),
                                )
                                    .toList(),
                                selectedIds: _selectedCuts,
                                onChanged: (set) {
                                  setState(() {
                                    _selectedCuts = set;
                                  });
                                },
                              ),
                            );
                          }

                          if (_selectedDept?.rateOnArticle == 'Y') {
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

                          return DetailPanels(panels: panels,childAspectRatio: 210 / 400);
                        },
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
    if (value is List) {
      _formValues[key] = value.join(',');
    } else {
      _formValues[key] = value?.toString() ?? '';
    }

    // When manager (crId) is selected, set deptCode automatically from counter
    if (key == 'crId') {
      final crId = int.tryParse(value.toString());
      final counterProvider = context.read<CounterProvider>();
      final selectedCounter = counterProvider.list
          .where((c) => c.crId == crId)
          .firstOrNull;

      final deptCode = selectedCounter?.deptCode;

      if (deptCode != null) {
        final deptProcessList = context.read<DeptProcessProvider>().list;
        final dept = deptProcessList
            .where((e) => e.deptCode == deptCode)
            .firstOrNull;

        setState(() {
          _selectedDept = dept;
          _selectedDeptCode = deptCode;
          _formValues['deptCode'] = deptCode.toString();

          if (dept?.rateOnShape != 'Y') {
            _selectedShapes.clear();
          }

          if (dept?.rateOnCut != 'Y') {
            _selectedCuts.clear();
          }

          if (dept?.rateOnArticle != 'Y') {
            _selectedArticles.clear();
          }

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
    }

    // When department is selected, update the tracking state
    if (key == 'deptCode') {
      final deptCode = int.tryParse(value.toString());

      final dept = context
          .read<DeptProcessProvider>()
          .list
          .where((e) => e.deptCode == deptCode)
          .firstOrNull;

      setState(() {
        _selectedDept = dept;
        _selectedDeptCode = deptCode;

        if (dept?.rateOnShape != 'Y') {
          _selectedShapes.clear();
        }

        if (dept?.rateOnCut != 'Y') {
          _selectedCuts.clear();
        }

        if (dept?.rateOnArticle != 'Y') {
          _selectedArticles.clear();
        }

        _formValues['deptProcessCode'] = '';
      });

      _erpFormKey.currentState?.updateFieldValue(
        'deptProcessCode',
        '',
      );
    }
  }

  ErpDataTable buildErpDataTable(DepartmentRateProvider provider) {
    return ErpDataTable(
      isReportRow: false,
      token: token ?? '',
      url: baseUrl,
      title: 'CLV DEPARTMENT RATE LIST',
      columns: _tableColumns,
      data: provider.tableData,
      showSearch: true,
      selectedRow: _selectedRow,
      onRowTap: _onRowTap,
      emptyMessage: provider.isLoaded ? 'No rates found' : 'Loading...',
    );
  }
}

