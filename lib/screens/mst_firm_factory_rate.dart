import 'package:diam_mfg/models/factory_rate_model.dart';
import 'package:diam_mfg/providers/article_provider.dart';
import 'package:diam_mfg/providers/company_provider.dart';
import 'package:diam_mfg/providers/cut_provider.dart';
import 'package:diam_mfg/providers/factory_provider.dart';
import 'package:diam_mfg/providers/factory_rate_provider.dart';
import 'package:diam_mfg/providers/lab_provider.dart';
import 'package:diam_mfg/providers/polish_provider.dart';
import 'package:diam_mfg/providers/symmetry_provider.dart';
import 'package:diam_mfg/utils/panel.dart';
import 'package:erp_data_table/erp_data_table.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rs_dashboard/rs_dashboard.dart';
import '../bootstrap.dart';
import '../providers/dept_provider.dart';
import '../providers/shape_provider.dart';
import '../utils/app_images.dart';
import '../utils/delete_dialogue.dart';
import '../utils/msg_dialogue.dart';

class MstFactoryRate extends StatefulWidget {
  const MstFactoryRate({super.key});

  @override
  State<MstFactoryRate> createState() => _MstFactoryRateState();
}

class _MstFactoryRateState extends State<MstFactoryRate> {
  final GlobalKey<ErpFormState> _erpFormKey = GlobalKey<ErpFormState>();
  Map<String, dynamic>? _selectedRow;
  bool _isEditMode = false;
  Map<String, String> _formValues = {};

  // selection arrays for detail panels (persisted to API on save)
  Set<int> _selectedShapes = {};
  Set<int> _selectedCuts = {};
  Set<int> _selectedArticles = {};
  Set<int> _selectedPolish = {};
  Set<int> _selectedSymentry = {};
  Set<int> _selectedCertificate = {};

  // ── Track selected department ──────────────────────────────────────────────
  int? _selectedDeptCode;
  String? _selectedDeptRateOn; // Will store 'Y' or 'N'

  final String? token = AppStorage.getString("token");

  // Table columns matching model.toTableRow keys
  List<ErpColumnConfig> get _tableColumns => [
    ErpColumnConfig(
      key: 'factoryName', // was: 'deptName'
      label: 'FACTORY', // was: 'DEPT'
      width: 150,
    ),
    ErpColumnConfig(
      key: 'factRateCode', // was: 'deptRateCode'
      label: 'RATE CODE',
      width: 200,
    ),
    ErpColumnConfig(key: 'rateon', label: 'RATE ON', width: 150),
    ErpColumnConfig(key: 'sizeon', label: 'SIZE ON', width: 150),
    ErpColumnConfig(key: 'fromWt', label: 'FROM WT', width: 150),
    ErpColumnConfig(key: 'toWt', label: 'TO WT', width: 150),
    ErpColumnConfig(key: 'companyName', label: 'COMPANY', width: 200),
    ErpColumnConfig(key: 'rate', label: 'RATE', width: 150),
    ErpColumnConfig(key: 'articles', label: 'ARTICALS', width: 150),
    ErpColumnConfig(key: 'cuts', label: 'CUTS', width: 150),
    ErpColumnConfig(key: 'shapes', label: 'SHAPES', width: 150),
    ErpColumnConfig(key: 'polish', label: 'POLISH', width: 150),
    ErpColumnConfig(key: 'symmetry', label: 'SYMENTRY', width: 150),
    ErpColumnConfig(key: 'certificate', label: 'CERTIFICATE', width: 150),
    ErpColumnConfig(key: 'active', label: 'ACTIVE', width: 200),
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
    final factoryProvider = context.read<FactoryProvider>();

    return [
      [
        ErpFieldConfig(
          key: 'factoryCode',
          label: 'FACTORY',
          type: ErpFieldType.dropdown,
          sectionIndex: 0,
          dropdownItems: factoryProvider.factories
              .where((e) => e.active == true)
              .map(
                (e) => ErpDropdownItem(
                  label: e.factoryName ?? '',
                  value: e.factoryCode?.toString() ?? '',
                ),
              )
              .toList(),
        ),
      ],

      [
        ErpFieldConfig(
          key: 'rateID',
          label: 'RATE ID',
          type: ErpFieldType.number,
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
        context.read<FactoryRateProvider>().loadFactoryRates(),
        context.read<FactoryProvider>().loadFactories(),
        context.read<CutProvider>().loadCuts(),
        context.read<ShapeProvider>().load(),
        context.read<LabProvider>().loadCuts(),
        context.read<ArticleProvider>().load(),
        context.read<PolishProvider>().loadPolish(),
        context.read<SymmetryProvider>().loadSymmetry(),
        context.read<LabProvider>().loadCuts(),
      ]);
    });
  }

  void _onRowTap(Map<String, dynamic> row) {
    print(row);
    final raw = row['_raw'] as FactoryRateModel?; // ← correct cast
    if (raw == null) return;

    setState(() {
      _selectedRow = row;
      _isEditMode = true;
      _formValues = {
        'factoryCode': raw.factoryCode.toString(), // Changed field access
        'rateID': raw.rateID.toString(),
        'rateOn': raw.rateon,
        'rateSizeOn': raw.sizeon,
        'fromWt': raw.fromWt.toString(),
        'toWt': raw.toWt.toString(),
        'rate': raw.rate.toString(),
        'sortID': raw.sortID.toString(),
        'active': raw.active == 1 ? 'true' : 'false',
      };
      _selectedShapes = raw.shapeCodes.toSet(); // was: raw.shapesIds
      _selectedCuts = raw.cutCodes.toSet(); // was: raw.cutsIds
      _selectedArticles = raw.articalCodes.toSet(); // was: raw.articlesIds
      _selectedCertificate = raw.certificateCodes
          .toSet(); // was: raw.articlesIds
      _selectedSymentry = raw.symmetryCodes.toSet(); // was: raw.articlesIds
      _selectedPolish = raw.polishCodes.toSet(); // was: raw.articlesIds
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
    if (_selectedShapes.isEmpty) {
      await ErpResultDialog.showError(
        context: context,
        theme: context.erpTheme,
        title: 'Validation Error',
        message: 'Please select at least one Shape.',
      );
      return;
    }
    if (_selectedCuts.isEmpty) {
      await ErpResultDialog.showError(
        context: context,
        theme: context.erpTheme,
        title: 'Validation Error',
        message: 'Please select at least one Cut.',
      );
      return;
    }
    if (_selectedArticles.isEmpty) {
      await ErpResultDialog.showError(
        context: context,
        theme: context.erpTheme,
        title: 'Validation Error',
        message: 'Please select at least one Article.',
      );
      return;
    }

    if (_selectedCertificate.isEmpty) {
      await ErpResultDialog.showError(
        context: context,
        theme: context.erpTheme,
        title: 'Validation Error',
        message: 'Please select at least one Certificate.',
      );
      return;
    }

    if (_selectedSymentry.isEmpty) {
      await ErpResultDialog.showError(
        context: context,
        theme: context.erpTheme,
        title: 'Validation Error',
        message: 'Please select at least one Symentry.',
      );
      return;
    }

    if (_selectedPolish.isEmpty) {
      await ErpResultDialog.showError(
        context: context,
        theme: context.erpTheme,
        title: 'Validation Error',
        message: 'Please select at least one Polish.',
      );
      return;
    }

    final provider = context.read<FactoryRateProvider>();

    // Map form values to API payload
    final payload = {
      'FactoryCode':
          int.tryParse(
            _formValues['factoryCode'] ??
                values['factoryCode']?.toString() ??
                '',
          ) ??
          0,
      'RateID':
          int.tryParse(
            _formValues['rateID'] ?? values['rateID']?.toString() ?? '',
          ) ??
          0,
      'Rateon': _formValues['rateOn'] ?? values['rateOn']?.toString() ?? '',
      'Sizeon':
          _formValues['rateSizeOn'] ?? values['rateSizeOn']?.toString() ?? '',
      'FromWt':
          double.tryParse(
            _formValues['fromWt'] ?? values['fromWt']?.toString() ?? '',
          ) ??
          0.0,
      'ToWt':
          double.tryParse(
            _formValues['toWt'] ?? values['toWt']?.toString() ?? '',
          ) ??
          0.0,
      'Rate':
          double.tryParse(
            _formValues['rate'] ?? values['rate']?.toString() ?? '',
          ) ??
          0.0,
      'CompanyCode': context.read<CompanyProvider>().selectedCompanyCode ?? 0,
      'SortID':
          int.tryParse(
            _formValues['sortID'] ?? values['sortID']?.toString() ?? '',
          ) ??
          0,
      'Active':
          (values['active'] == 'true' ||
              values['active'] == '1' ||
              values['active'] == true)
          ? 1
          : 0,
      'shapes': _selectedShapes.isEmpty ? [] : _selectedShapes.toList(),
      'cuts': _selectedCuts.isEmpty ? [] : _selectedCuts.toList(),
      'articles': _selectedArticles.isEmpty ? [] : _selectedArticles.toList(),
      'certificate': _selectedCertificate.isEmpty
          ? []
          : _selectedCertificate.toList(),
      'symmetry': _selectedSymentry.isEmpty ? [] : _selectedSymentry.toList(),
      'polish': _selectedPolish.isEmpty ? [] : _selectedPolish.toList(),
    };

    bool success;
    if (_isEditMode && _selectedRow != null) {
      final raw = _selectedRow!['_raw'] as FactoryRateModel;
      final id = raw.factRateMstID;
      success = await provider.updateFactoryRate(id, payload);
    } else {
      success = await provider.createFactoryRate(payload);
    }

    if (!mounted) return;
    if (success) {
      _resetForm();
      await ErpResultDialog.showSuccess(
        context: context,
        theme: context.erpTheme,
        title: _isEditMode ? 'Updated' : 'Saved',
        message: _isEditMode ? 'Factory Rate updated.' : 'Factory Rate saved.',
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
    final raw = _selectedRow?['_raw'] as FactoryRateModel?;
    if (raw?.factRateMstID == null) return;
    final confirm = await ErpDeleteDialog.show(
      context: context,
      theme: context.erpTheme,
      title: 'Factory Rate',
      itemName: raw!.factRateCode?.toString() ?? 'Rate',
    );
    if (confirm != true || !mounted) return;
    final success = await context.read<FactoryRateProvider>().deleteFactoryRate(
      raw.factRateMstID!,
    );
    if (success && mounted) {
      await ErpResultDialog.showDeleted(
        context: context,
        theme: context.erpTheme,
        itemName: raw.factRateCode?.toString() ?? '',
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
      // ── clear panel selections ──
      _selectedShapes = {};
      _selectedCuts = {};
      _selectedArticles = {};
      _selectedPolish = {};
      _selectedSymentry = {};
      _selectedCertificate = {};
    });
    _erpFormKey.currentState?.resetForm();
    _formValues['active'] = 'true';
    _erpFormKey.currentState?.updateFieldValue('active', 'true');
  }

  bool _showTableOnMobile = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<FactoryRateProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child: Responsive.isMobile(context)
              ? _showTableOnMobile
                    ? buildErpDataTable(provider)
                    : ErpForm(
                        logo: AppImages.logo,
                        key: _erpFormKey,
                        title: 'FACTORY RATE MASTER',
                        subtitle: 'Factory Rate configuration',
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
                        title: 'FACTORY RATE MASTER',
                        subtitle: 'Factory Rate configuration',
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
                          final polishProv = context.watch<PolishProvider>();
                          final symentryProv = context
                              .watch<SymmetryProvider>();
                          final certificateProv = context.watch<LabProvider>();

                          final panels = [
                            PanelConfig(
                              title: 'SHAPE',
                              items: shapeProv.list
                                  .map(
                                    (s) => PanelItem(
                                      id: s.shapeCode ?? 0,
                                      name: s.shapeName ?? '',
                                    ),
                                  )
                                  .toList(),
                              selectedIds: _selectedShapes,
                              onChanged: (set) =>
                                  setState(() => _selectedShapes = set),
                            ),
                            PanelConfig(
                              title: 'CUT',
                              items: cutProv.cuts
                                  .map(
                                    (c) => PanelItem(
                                      id: c.cutCode ?? 0,
                                      name: c.cutName ?? '',
                                    ),
                                  )
                                  .toList(),
                              selectedIds: _selectedCuts,
                              onChanged: (set) =>
                                  setState(() => _selectedCuts = set),
                            ),
                            PanelConfig(
                              title: 'POLISH',
                              items: polishProv.polishs
                                  .map(
                                    (a) => PanelItem(
                                      id: a.polishCode ?? 0,
                                      name: a.polishName ?? '',
                                    ),
                                  )
                                  .toList(),
                              selectedIds: _selectedPolish,
                              onChanged: (set) =>
                                  setState(() => _selectedPolish = set),
                            ),
                            PanelConfig(
                              title: 'SYMENTRY',
                              items: symentryProv.symmetrys
                                  .map(
                                    (a) => PanelItem(
                                      id: a.symmetryCode ?? 0,
                                      name: a.symmetryName ?? '',
                                    ),
                                  )
                                  .toList(),
                              selectedIds: _selectedSymentry,
                              onChanged: (set) =>
                                  setState(() => _selectedSymentry = set),
                            ),
                            PanelConfig(
                              title: 'CERTIFICATE',
                              items: certificateProv.cuts
                                  .map(
                                    (a) => PanelItem(
                                      id: a.certificateCode ?? 0,
                                      name: a.certificateName ?? '',
                                    ),
                                  )
                                  .toList(),
                              selectedIds: _selectedCertificate,
                              onChanged: (set) =>
                                  setState(() => _selectedCertificate = set),
                            ),
                            PanelConfig(
                              title: 'ARTICLE',
                              items: articleProv.list
                                  .map(
                                    (a) => PanelItem(
                                      id: a.articalCode ?? 0,
                                      name: a.articalName ?? '',
                                    ),
                                  )
                                  .toList(),
                              selectedIds: _selectedArticles,
                              onChanged: (set) =>
                                  setState(() => _selectedArticles = set),
                            ),
                          ];

                          return DetailPanels(
                            panels: panels,
                            childAspectRatio: 210 / 225,
                          );
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
    _formValues[key] = value.toString();

    // When department is selected, update the tracking state
    if (key == 'deptCode') {
      final deptCode = int.tryParse(value.toString());
      setState(() {
        _selectedDeptCode = deptCode;
        _selectedDeptRateOn = _getRateOnForDept(deptCode);
        // Clear dependent fields
        _formValues['deptProcessCode'] = '';
      });
      _erpFormKey.currentState?.updateFieldValue('deptProcessCode', '');
    }
  }

  ErpDataTable buildErpDataTable(FactoryRateProvider provider) {
    return ErpDataTable(
      isReportRow: false,
      token: token ?? '',
      url: baseUrl,
      title: 'FACTORY RATE LIST',
      columns: _tableColumns,
      data: provider.tableData,
      showSearch: true,
      selectedRow: _selectedRow,
      onRowTap: _onRowTap,
      emptyMessage: provider.isLoaded ? 'No rates found' : 'Loading...',
    );
  }
}
