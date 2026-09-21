import 'package:collection/collection.dart';
import 'package:erp_data_table/erp_data_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rs_dashboard/rs_dashboard.dart';

import '../providers/color_provider.dart';
import '../providers/counter_manager_det_provider.dart';
import '../providers/counter_provider.dart';
import '../providers/cut_create_provider.dart';
import '../providers/cut_provider.dart';
import '../providers/dept_group_provider.dart';
import '../providers/dept_process_provider.dart';
import '../providers/dept_provider.dart';
import '../providers/division_provider.dart';
import '../providers/employee_provider.dart';
import '../providers/factory_provider.dart';
import '../providers/purity_provider.dart';
import '../providers/remarks_provider.dart';
import '../providers/report_mst_provider.dart';
import '../providers/report_type_provider.dart';
import '../providers/rough_provider.dart';
import '../providers/shape_provider.dart';
import '../providers/tensions_provider.dart';
import '../providers/test_provider.dart';

class ReportFilterDrawer extends StatefulWidget {
  final Map<String, String>? initialFormValues;
  final Map<String, List<String>>? initialMultiSelectValues;
  final ValueChanged<Map<String, dynamic>> onApply;
  final VoidCallback? onReset;
  final void Function(Map<String, String> formValues, Map<String, List<String>> multiSelectValues)? onStateChanged;
  final bool showReportSelection;

  const ReportFilterDrawer({
    super.key,
    this.initialFormValues,
    this.initialMultiSelectValues,
    required this.onApply,
    this.onReset,
    this.onStateChanged,
    this.showReportSelection = true,
  });

  @override
  State<ReportFilterDrawer> createState() => _ReportFilterDrawerState();
}

class _ReportFilterDrawerState extends State<ReportFilterDrawer> {
  late Map<String, String> _formValues;
  late Map<String, List<String>> _multiSelectValues;

  int? _fromCrId;
  int? _toCrId;
  int? _selectedTestCode;
  int? _selectedReportTypeCode;
  bool _isAdvancedFiltersExpanded = false;

  static const _multiSelectKeys = {
    'mainCut',
    'kNo',
    'cutNo',
    'fromCrId',
    'toCrId',
    'remarks',
    'deptProcessCode',
    'purityCode',
    'colorCode',
    'tensionCode',
    'shapeCode',
    'typeSecond',
    'factoryCode',
    'divisionCode',
    'employeeCode',
    'fromDept',
    'toDept',
  };

  @override
  void initState() {
    super.initState();
    _formValues = Map<String, String>.from(widget.initialFormValues ?? {});
    _multiSelectValues = {};
    if (widget.initialMultiSelectValues != null) {
      widget.initialMultiSelectValues!.forEach((k, v) {
        _multiSelectValues[k] = List<String>.from(v);
      });
    }

    if (_formValues['dateFrom'] == null || _formValues['dateFrom']!.isEmpty) {
      _formValues['dateFrom'] = DateFormat('dd/MM/yy').format(DateTime.now());
    }
    if (_formValues['dateTo'] == null || _formValues['dateTo']!.isEmpty) {
      _formValues['dateTo'] = DateFormat('dd/MM/yy').format(DateTime.now());
    }
    if (_formValues['sendToHo'] == null || _formValues['sendToHo']!.isEmpty) {
      _formValues['sendToHo'] = 'N';
    }
  }

  String _deptGroupNameFor(int? code) {
    if (code == null) return '';
    try {
      return context
              .read<DeptGroupProvider>()
              .list
              .firstWhere((g) => g.deptGroupCode == code)
              .deptGroupName ??
          '';
    } catch (_) {
      return '';
    }
  }

  String _deptNameFor(int? code) {
    if (code == null) return '';
    try {
      return context
              .read<DeptProvider>()
              .list
              .firstWhere((d) => d.deptCode == code)
              .deptName ??
          '';
    } catch (_) {
      return '';
    }
  }

  void _onFromSelected(String crIdStr) {
    final crId = int.tryParse(crIdStr);
    if (crId == null) return;

    try {
      final counter = context.read<CounterProvider>().list.firstWhere(
        (c) => c.crId == crId,
      );
      final deptName = _deptNameFor(counter.deptCode);

      setState(() {
        _fromCrId = crId;
        _toCrId = null;
        _formValues['fromCrId'] = crIdStr;
        _formValues['fromDept'] = deptName;
        _formValues['toCrId'] = '';
        _formValues['toDept'] = '';
        _formValues['deptProcessCode'] = '';
        _formValues['deptName'] = '';
      });
    } catch (_) {}
  }

  void _onToSelected(String crIdStr) {
    final crId = int.tryParse(crIdStr);
    if (crId == null) return;

    try {
      final counter = context.read<CounterProvider>().list.firstWhere(
        (c) => c.crId == crId,
      );
      final deptName = _deptNameFor(counter.deptCode);

      setState(() {
        _toCrId = crId;
        _formValues['toCrId'] = crIdStr;
        _formValues['toDept'] = deptName;
        _formValues['deptName'] = deptName;
        _formValues['deptProcessCode'] = '';
      });
    } catch (_) {}
  }

  void _handleFieldValueChanged(String key, dynamic value) {
    setState(() {
      if (_multiSelectKeys.contains(key)) {
        if (value is List<String>) {
          _multiSelectValues[key] = value;
          _formValues[key] = value.join(',');
        } else if (value == null || (value is List && value.isEmpty)) {
          _multiSelectValues[key] = [];
          _formValues[key] = '';
        }
      } else {
        _formValues[key] = value?.toString() ?? '';
      }
    });

    switch (key) {
      case 'type':
        final testCode = int.tryParse(value.toString());
        final firstReportType = context
            .read<ReportTypeProvider>()
            .list
            .firstWhereOrNull(
              (e) => testCode == null || e.TestCode == testCode,
            );
        final firstReportTypeCode = firstReportType?.reportTypeCode;
        final firstReportTypeCodeStr = firstReportTypeCode?.toString() ?? '';
        setState(() {
          _selectedTestCode = testCode;
          _selectedReportTypeCode = firstReportTypeCode;
          _formValues['sel'] = firstReportTypeCodeStr;
        });
        break;

      case 'sel':
        _selectedReportTypeCode = int.tryParse(value.toString());
        final filtered = context
            .read<ReportMstProvider>()
            .list
            .where(
              (e) =>
                  (_selectedTestCode == null || e.testCode == _selectedTestCode) &&
                  (_selectedReportTypeCode == null || e.reportTypeCode == _selectedReportTypeCode),
            )
            .toList();
        final firstReportName = filtered.isNotEmpty ? filtered.first.reportName ?? '' : '';
        setState(() {
          _formValues['report'] = firstReportName;
        });
        break;

      case 'fromCrId':
        final firstId = (_multiSelectValues['fromCrId'] ?? []).firstOrNull ?? '';
        if (firstId.isNotEmpty) {
          _onFromSelected(firstId);
        } else {
          setState(() {
            _fromCrId = null;
            _toCrId = null;
            _formValues['fromDept'] = '';
            _formValues['toCrId'] = '';
            _formValues['toDept'] = '';
            _formValues['deptProcessCode'] = '';
            _formValues['deptName'] = '';
          });
        }
        break;

      case 'toCrId':
        final firstId = (_multiSelectValues['toCrId'] ?? []).firstOrNull ?? '';
        if (firstId.isNotEmpty) {
          _onToSelected(firstId);
        } else {
          setState(() {
            _toCrId = null;
            _formValues['toDept'] = '';
            _formValues['deptProcessCode'] = '';
            _formValues['deptName'] = '';
          });
        }
        break;
    }
  }

  Map<String, dynamic> _buildFilterMap() {
    final colorProv = context.read<ColorProvider>();
    final purityProv = context.read<PurityProvider>();

    final selectedColorCodes = _multiSelectValues['colorCode'] ?? [];
    final selectedColorNames = <String>[];
    for (final codeStr in selectedColorCodes) {
      final codeInt = int.tryParse(codeStr);
      final match = colorProv.list.firstWhereOrNull((c) => c.colorCode == codeInt);
      if (match?.colorName != null && match!.colorName!.isNotEmpty) {
        selectedColorNames.add(match.colorName!);
      } else {
        selectedColorNames.add(codeStr);
      }
    }

    final selectedPurityCodes = _multiSelectValues['purityCode'] ?? [];
    final selectedPurityNames = <String>[];
    for (final codeStr in selectedPurityCodes) {
      final codeInt = int.tryParse(codeStr);
      final match = purityProv.list.firstWhereOrNull((p) => p.purityCode == codeInt);
      if (match?.purityName != null && match!.purityName!.isNotEmpty) {
        selectedPurityNames.add(match.purityName!);
      } else {
        selectedPurityNames.add(codeStr);
      }
    }

    int? intVal(String key) {
      final v = _formValues[key];
      return (v != null && v.isNotEmpty) ? int.tryParse(v) : null;
    }

    List<int> intList(String key) {
      return (_multiSelectValues[key] ?? [])
          .map((e) => int.tryParse(e))
          .whereType<int>()
          .toList();
    }

    final filter = <String, dynamic>{
      "reportType": intVal('type'),
      "sel": intVal('sel'),
      "finish": _formValues['finish'],
      "repairing": _formValues['repairing'],
      "shift": _formValues['shift'],
      "lotNoFrom": intVal('lotNoFrom'),
      "lotNoTo": intVal('lotNoTo'),
      "pktType": _formValues['pktType'],
      "GroupType": _formValues['groupType'] ?? _formValues['GroupType'],

      "from_Length": _formValues['lengthFrom'],
      "to_Length": _formValues['lengthTo'],
      "from_Width": _formValues['widthFrom'],
      "to_Width": _formValues['widthTo'],
      "from_PoWt": _formValues['weightFrom'],
      "to_PoWt": _formValues['weightTo'],

      "ColorName": selectedColorNames,
      "PurityName": selectedPurityNames,

      "MainCutNo": _multiSelectValues['mainCut'] ?? [],
      "KapanNo": _multiSelectValues['kNo'] ?? [],
      "cutNo": _multiSelectValues['cutNo'] ?? [],

      "fromManager": intList('fromCrId'),
      "toManager": intList('toCrId'),
      "Remarks": intList('remarks'),
      "deptProcessCode": intList('deptProcessCode'),
      "purityCode": intList('purityCode'),
      "colorCode": intList('colorCode'),
      "tensionCode": intList('tensionCode'),
      "shapeCode": intList('shapeCode'),
      "factoryCode": intList('factoryCode'),
      "divisionCode": intList('divisionCode'),
      "employeeCode": intList('employeeCode'),
      "sendToHo": _formValues['sendToHo'] ?? 'N',
    };

    if (_formValues['dateFrom'] != null && _formValues['dateFrom']!.isNotEmpty) {
      try {
        filter['fromDate'] = DateFormat('yyyy-MM-dd').format(
          DateFormat('dd/MM/yy').parseStrict(_formValues['dateFrom']!),
        );
      } catch (_) {
        try {
          filter['fromDate'] = DateFormat('yyyy-MM-dd').format(
            DateFormat('dd/MM/yyyy').parse(_formValues['dateFrom']!),
          );
        } catch (_) {}
      }
    }

    if (_formValues['dateTo'] != null && _formValues['dateTo']!.isNotEmpty) {
      try {
        filter['toDate'] = DateFormat('yyyy-MM-dd').format(
          DateFormat('dd/MM/yy').parseStrict(_formValues['dateTo']!),
        );
      } catch (_) {
        try {
          filter['toDate'] = DateFormat('yyyy-MM-dd').format(
            DateFormat('dd/MM/yyyy').parse(_formValues['dateTo']!),
          );
        } catch (_) {}
      }
    }

    filter.removeWhere((key, value) {
      if (value == null) return true;
      if (value is String && value.trim().isEmpty) return true;
      if (value is List && value.isEmpty) return true;
      return false;
    });

    return filter;
  }

  void _reset() {
    setState(() {
      _formValues.clear();
      _multiSelectValues.clear();
      _fromCrId = null;
      _toCrId = null;
      _formValues['dateFrom'] = DateFormat('dd/MM/yy').format(DateTime.now());
      _formValues['dateTo'] = DateFormat('dd/MM/yy').format(DateTime.now());
      _formValues['sendToHo'] = 'N';
    });
    Navigator.of(context).pop();
    widget.onStateChanged?.call(_formValues, _multiSelectValues);
    widget.onReset?.call();
  }

  void _apply() {
    final filter = _buildFilterMap();
    Navigator.of(context).pop();
    widget.onStateChanged?.call(_formValues, _multiSelectValues);
    widget.onApply(filter);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final counterProv = context.read<CounterProvider>();
    final mgDetProv = context.read<CounterManagerDetProvider>();
    final procProv = context.read<DeptProcessProvider>();
    final tensProv = context.read<TensionsProvider>();
    final colorProv = context.read<ColorProvider>();
    final shapeProv = context.read<ShapeProvider>();
    final purityProv = context.read<PurityProvider>();
    final remarksProv = context.read<RemarksProvider>();
    final factoryProv = context.read<FactoryProvider>();
    final cutProv = context.read<CutCreateProvider>();
    final roughProv = context.watch<RoughProvider>();

    final isFromSelected = _fromCrId != null;
    final isToSelected = _toCrId != null;

    final fromItems = counterProv.list
        .where((c) {
          final grp = _deptGroupNameFor(c.deptGroupCode).toUpperCase();
          return grp.contains('CLEAVING') || grp.contains('CLV');
        })
        .map(
          (c) => ErpDropdownItem(
            label: '${c.crName ?? ''}  |  ${_deptNameFor(c.deptCode)}',
            value: c.crId?.toString() ?? '',
          ),
        )
        .toList();

    final toItems = _fromCrId == null
        ? <ErpDropdownItem>[]
        : mgDetProv.list
              .where((m) => m.crId == _fromCrId && m.allowCrId != null)
              .map((m) => m.allowCrId!)
              .toSet()
              .map((allowId) {
                try {
                  final c = counterProv.list.firstWhere(
                    (c) => c.crId == allowId && c.active == true,
                  );
                  if (c.crId == _fromCrId) return null;
                  return ErpDropdownItem(
                    label: '${c.crName ?? ''} | ${_deptNameFor(c.deptCode)}',
                    value: c.crId?.toString() ?? '',
                  );
                } catch (_) {
                  return null;
                }
              })
              .whereType<ErpDropdownItem>()
              .toList();

    final processItems = (_fromCrId == null || _toCrId == null)
        ? <ErpDropdownItem>[]
        : () {
            final issueCodes = mgDetProv.list
                .where((m) => m.crId == _fromCrId && m.deptProcessCode != null)
                .map((m) => m.deptProcessCode!)
                .toSet();

            final recvCodes = mgDetProv.list
                .where((m) => m.allowCrId == _toCrId && m.deptProcessCode != null)
                .map((m) => m.deptProcessCode!)
                .toSet();

            return issueCodes.intersection(recvCodes).map((code) {
              String label = '$code';
              try {
                label =
                    procProv.list
                        .firstWhere((p) => p.deptProcessCode == code)
                        .deptProcessName ??
                    '$code';
              } catch (_) {}
              return ErpDropdownItem(label: label, value: code.toString());
            }).toList();
          }();

    final tensItems = tensProv.list.where((e) => e.active == true).toList()
      ..sort((a, b) => (a.sortID ?? 0).compareTo(b.sortID ?? 0));
    final tensDropdown = tensItems
        .map(
          (e) => ErpDropdownItem(
            label: e.tensionsName ?? '',
            value: e.tensionsCode?.toString() ?? '',
          ),
        )
        .toList();

    final factoryItems = factoryProv.factories
        .map(
          (e) => ErpDropdownItem(
            label: e.factoryName ?? '',
            value: e.factoryCode?.toString() ?? '',
          ),
        )
        .toList();

    final purityItems = purityProv.list
        .map(
          (e) => ErpDropdownItem(
            label: e.purityName ?? '',
            value: e.purityCode?.toString() ?? '',
          ),
        )
        .toList();

    final colorItems = colorProv.list
        .map(
          (e) => ErpDropdownItem(
            label: e.colorName ?? '',
            value: e.colorCode?.toString() ?? '',
          ),
        )
        .toList();

    final shapeItems = shapeProv.list
        .map(
          (e) => ErpDropdownItem(
            label: e.shapeName ?? '',
            value: e.shapeCode?.toString() ?? '',
          ),
        )
        .toList();

    final remarksItems = remarksProv.list
        .map(
          (e) => ErpDropdownItem(
            label: e.remarksName ?? '',
            value: e.remarksCode?.toString() ?? '',
          ),
        )
        .toList();

    final cutItems = cutProv.list
        .where((cc) => cc.details.isNotEmpty)
        .map((cc) {
          final spkDet = cc.details.firstWhere(
            (d) => d.cutType == 'SPK',
            orElse: () => cc.details.first,
          );
          return ErpDropdownItem(
            label: spkDet.cutNo ?? '',
            value: spkDet.cutNo ?? '',
          );
        })
        .where((e) => e.value.isNotEmpty)
        .fold<List<ErpDropdownItem>>([], (acc, item) {
          if (!acc.any((x) => x.value == item.value)) acc.add(item);
          return acc;
        });

    final roughItems = roughProv.roughs
        .map(
          (e) => ErpDropdownItem(
            label: e.kapanNo ?? '',
            value: e.kapanNo?.toString() ?? '',
          ),
        )
        .toList();

    final mainCutNoItems = roughProv.roughs
        .map(
          (e) => ErpDropdownItem(
            label: e.mainCutNo ?? '',
            value: e.mainCutNo?.toString() ?? '',
          ),
        )
        .toList();

    final typeProv = context.read<TestProvider>();
    final reportTypeProv = context.read<ReportTypeProvider>();
    final reportsProv = context.watch<ReportMstProvider>();

    final typeItems = typeProv.list
        .map(
          (e) => ErpDropdownItem(
            label: e.testName ?? '',
            value: e.testCode?.toString() ?? '',
          ),
        )
        .toList();

    final reportTypeItems = reportTypeProv.list
        .where((e) => _selectedTestCode == null || e.TestCode == _selectedTestCode)
        .map(
          (e) => ErpDropdownItem(
            label: e.reportTypeName ?? '',
            value: e.reportTypeCode?.toString() ?? '',
          ),
        )
        .toList();

    final reportsItems = reportsProv.list
        .where(
          (e) =>
              (_selectedTestCode == null || e.testCode == _selectedTestCode) &&
              (_selectedReportTypeCode == null || e.reportTypeCode == _selectedReportTypeCode),
        )
        .map(
          (e) => ErpDropdownItem(
            label: e.reportName ?? '',
            value: e.reportName ?? '',
          ),
        )
        .toList();

    return Drawer(
      width: 500,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              color: const Color(0xFF1A1F3D),
              child: Row(
                children: [
                  const Icon(
                    Icons.filter_list_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Filter Panel',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    tooltip: 'Close Sidebar',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (widget.showReportSelection) ...[
                    _buildSidebarSectionHeader(
                      'Report Selection',
                      Icons.description_rounded,
                    ),
                    _buildGridRow(
                      _buildSidebarSingleSelectWithItems('type', 'TYPE', typeItems),
                      _buildSidebarSingleSelectWithItems('sel', 'SEL', reportTypeItems),
                    ),
                    _buildGridRow(
                      _buildSidebarSingleSelectWithItems('report', 'REPORTS', reportsItems),
                      _buildSidebarSingleSelect('finish', 'FINISH', const ['N', 'Y']),
                    ),
                  ],

                  _buildSidebarSectionHeader('Date Range', Icons.calendar_today_rounded),
                  _buildGridRow(
                    _buildSidebarDateField('dateFrom', 'FROM DATE'),
                    _buildSidebarDateField('dateTo', 'TO DATE'),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _buildDatePresetChip('Today', () => _setPresetDates(0)),
                        _buildDatePresetChip('Yesterday', () => _setPresetDates(1)),
                        _buildDatePresetChip('Last 7 Days', () => _setPresetDates(7)),
                        _buildDatePresetChip('This Month', () => _setMonthlyPreset()),
                      ],
                    ),
                  ),

                  _buildSidebarSectionHeader('Kapan & Cut Filters', Icons.content_cut_rounded),
                  _buildGridRow(
                    _buildSidebarMultiSelect(context, 'mainCut', 'MAIN CUT', mainCutNoItems),
                    _buildSidebarMultiSelect(context, 'kNo', 'KNO', roughItems),
                  ),
                  _buildGridRow(
                    _buildSidebarMultiSelect(context, 'cutNo', 'CUT NO', cutItems),
                    _buildSidebarSingleSelect('sendToHo', 'SEND TO HO', const ['N', 'Y']),
                  ),

                  _buildSidebarSectionHeader('Manager & Dept Transfer', Icons.swap_horiz_rounded),
                  _buildGridRow(
                    _buildSidebarMultiSelect(context, 'fromCrId', 'FROM MANAGER', fromItems),
                    _buildSidebarDisplayField('FROM DEPT', _formValues['fromDept'] ?? ''),
                  ),
                  _buildGridRow(
                    _buildSidebarMultiSelect(context, 'toCrId', 'TO MANAGER', toItems, enabled: isFromSelected),
                    _buildSidebarDisplayField('TO DEPT', _formValues['toDept'] ?? ''),
                  ),
                  _buildGridRow(
                    _buildSidebarMultiSelect(context, 'deptProcessCode', 'PROCESS', processItems, enabled: isToSelected),
                    _buildSidebarDisplayField('DEPT NAME', _formValues['deptName'] ?? ''),
                  ),

                  _buildSidebarSectionHeader('Organization & Staff', Icons.business_rounded),
                  _buildGridRow(
                    _buildSidebarMultiSelect(context, 'factoryCode', 'FACTORY', factoryItems),
                    _buildSidebarSingleSelect('pktType', 'PKT TYPE', const ['ALL', 'SINGLE', 'LOOSE']),
                  ),
                  _buildGridRow(
                    _buildSidebarTextField('lotNoFrom', 'LOT NO FROM'),
                    _buildSidebarTextField('lotNoTo', 'LOT NO TO'),
                  ),
                  _buildGridRow(
                    _buildSidebarMultiSelect(context, 'remarks', 'REMARKS', remarksItems),
                  ),

                  const SizedBox(height: 6),
                  const Divider(height: 1),
                  const SizedBox(height: 6),

                  Theme(
                    data: theme.copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      initiallyExpanded: _isAdvancedFiltersExpanded,
                      onExpansionChanged: (expanded) {
                        setState(() {
                          _isAdvancedFiltersExpanded = expanded;
                        });
                      },
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: const EdgeInsets.only(top: 4, bottom: 10),
                      title: const Row(
                        children: [
                          Icon(Icons.tune_rounded, size: 18, color: Color(0xFF556EE6)),
                          SizedBox(width: 8),
                          Text(
                            'Advanced Filters',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF556EE6),
                            ),
                          ),
                        ],
                      ),
                      children: [
                        _buildGridRow(
                          _buildSidebarMultiSelect(context, 'shapeCode', 'SHAPE', shapeItems),
                          _buildSidebarMultiSelect(context, 'colorCode', 'COLOR', colorItems),
                        ),
                        _buildGridRow(
                          _buildSidebarMultiSelect(context, 'purityCode', 'PURITY', purityItems),
                          _buildSidebarMultiSelect(context, 'tensionCode', 'TENSION', tensDropdown),
                        ),
                        _buildGridRow(
                          _buildSidebarTextField('lengthFrom', 'LENGTH FROM'),
                          _buildSidebarTextField('lengthTo', 'LENGTH TO'),
                        ),
                        _buildGridRow(
                          _buildSidebarTextField('widthFrom', 'WIDTH FROM'),
                          _buildSidebarTextField('widthTo', 'WIDTH TO'),
                        ),
                        _buildGridRow(
                          _buildSidebarTextField('weightFrom', 'WEIGHT FROM'),
                          _buildSidebarTextField('weightTo', 'WEIGHT TO'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, -2),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.cleaning_services_rounded, size: 18, color: Color(0xFF556EE6)),
                      label: const Text(
                        'Reset All',
                        style: TextStyle(color: Color(0xFF556EE6), fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF556EE6)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: _reset,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle_rounded, size: 18),
                      label: const Text('Apply'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF556EE6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: _apply,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridRow(Widget left, [Widget? right]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: left),
          const SizedBox(width: 10),
          Expanded(child: right ?? const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildSidebarSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 15, color: const Color(0xFF556EE6)),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF556EE6),
            ),
          ),
          const SizedBox(width: 6),
          const Expanded(child: Divider(height: 1)),
        ],
      ),
    );
  }

  Widget _buildSidebarMultiSelect(
    BuildContext context,
    String key,
    String label,
    List<ErpDropdownItem> items, {
    bool enabled = true,
  }) {
    final selectedList = _multiSelectValues[key] ?? [];
    final displayCount = selectedList.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: enabled ? Colors.grey.shade700 : Colors.grey.shade400,
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: enabled
              ? () {
                  _showMultiSelectDialog(
                    context: context,
                    title: label,
                    items: items,
                    initialSelected: selectedList,
                    onConfirm: (newList) {
                      _handleFieldValueChanged(key, newList);
                    },
                  );
                }
              : null,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            height: 35,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: enabled ? Colors.white : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: enabled ? Colors.grey.shade300 : Colors.grey.shade200,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: displayCount == 0
                      ? Text(
                          'Select $label...',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: enabled ? Colors.grey.shade500 : Colors.grey.shade400,
                          ),
                        )
                      : Text(
                          '$displayCount (${selectedList.join(", ")})',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  size: 20,
                  color: enabled ? Colors.grey.shade600 : Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarSingleSelectWithItems(
    String key,
    String label,
    List<ErpDropdownItem> items, {
    bool enabled = true,
  }) {
    final currentVal = _formValues[key] ?? '';
    final validItems = items.where((i) => i.value.isNotEmpty).toList();
    final matchedItem = validItems.firstWhereOrNull((i) => i.value == currentVal);
    final displayLabel = matchedItem?.label ?? currentVal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: enabled ? Colors.grey.shade700 : Colors.grey.shade400,
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: enabled && validItems.isNotEmpty
              ? () {
                  _showSingleSelectDialog(
                    context: context,
                    title: label,
                    items: validItems,
                    initialSelected: currentVal,
                    onConfirm: (selectedVal) {
                      _handleFieldValueChanged(key, selectedVal);
                    },
                  );
                }
              : null,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            height: 35,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: enabled ? Colors.white : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: enabled ? Colors.grey.shade300 : Colors.grey.shade200,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    displayLabel.isEmpty ? 'Select $label...' : displayLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: displayLabel.isEmpty ? FontWeight.normal : FontWeight.w500,
                      color: displayLabel.isEmpty
                          ? (enabled ? Colors.grey.shade500 : Colors.grey.shade400)
                          : Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  size: 20,
                  color: enabled ? Colors.grey.shade600 : Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarDateField(String key, String label) {
    final val = _formValues[key] ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () => _pickDate(key),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            height: 35,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 14,
                  color: Color(0xFF556EE6),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    val.isEmpty ? 'Pick Date' : val,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: val.isNotEmpty ? const Color(0xFF556EE6) : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate(String key) async {
    final initialDateStr = _formValues[key];
    DateTime initialDate = DateTime.now();
    if (initialDateStr != null && initialDateStr.isNotEmpty) {
      try {
        initialDate = DateFormat('dd/MM/yy').parseStrict(initialDateStr);
      } catch (_) {
        try {
          initialDate = DateFormat('dd/MM/yyyy').parse(initialDateStr);
        } catch (_) {}
      }
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      final formatted = DateFormat('dd/MM/yy').format(picked);
      _handleFieldValueChanged(key, formatted);
    }
  }

  void _setPresetDates(int daysAgo) {
    final now = DateTime.now();
    final fromDate = now.subtract(Duration(days: daysAgo));
    final format = DateFormat('dd/MM/yy');
    setState(() {
      _formValues['dateFrom'] = format.format(fromDate);
      _formValues['dateTo'] = format.format(now);
    });
    _handleFieldValueChanged('dateFrom', format.format(fromDate));
    _handleFieldValueChanged('dateTo', format.format(now));
  }

  void _setMonthlyPreset() {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final format = DateFormat('dd/MM/yy');
    setState(() {
      _formValues['dateFrom'] = format.format(firstDay);
      _formValues['dateTo'] = format.format(now);
    });
    _handleFieldValueChanged('dateFrom', format.format(firstDay));
    _handleFieldValueChanged('dateTo', format.format(now));
  }

  Widget _buildDatePresetChip(String label, VoidCallback onTap) {
    return ActionChip(
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF556EE6),
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: const Color(0xFF556EE6).withOpacity(0.08),
      side: const BorderSide(
        color: Color(0x40556EE6),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      visualDensity: VisualDensity.compact,
      onPressed: onTap,
    );
  }

  Widget _buildSidebarDisplayField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 35,
          width: double.infinity,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            value.isEmpty ? '-' : value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarSingleSelect(
    String key,
    String label,
    List<String> options,
  ) {
    final currentVal = _formValues[key] ?? options.first;
    final items = options
        .map(
          (opt) => ErpDropdownItem(label: opt, value: opt == 'ALL' ? '' : opt),
        )
        .toList();

    final matchedItem = items.firstWhereOrNull(
      (i) => (currentVal.isEmpty && i.value.isEmpty) || i.value == currentVal,
    );
    final displayLabel =
        matchedItem?.label ?? (currentVal.isEmpty ? options.first : currentVal);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () {
            _showSingleSelectDialog(
              context: context,
              title: label,
              items: items,
              initialSelected: currentVal.isEmpty ? '' : currentVal,
              onConfirm: (selectedVal) {
                _handleFieldValueChanged(key, selectedVal);
              },
            );
          },
          borderRadius: BorderRadius.circular(6),
          child: Container(
            height: 35,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    displayLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  size: 20,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarTextField(String key, String label) {
    final controller = TextEditingController(text: _formValues[key] ?? '');
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 35,
            child: TextField(
              controller: controller,
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onChanged: (val) {
                _handleFieldValueChanged(key, val);
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showSingleSelectDialog({
    required BuildContext context,
    required String title,
    required List<ErpDropdownItem> items,
    required String initialSelected,
    required ValueChanged<String> onConfirm,
  }) async {
    String searchQuery = '';
    int focusedIndex = 0;
    final scrollController = ScrollController();
    final searchFocusNode = FocusNode();

    final initIndex = items.indexWhere((i) => i.value == initialSelected);
    if (initIndex != -1) {
      focusedIndex = initIndex;
    }

    void scrollToFocused(int index) {
      if (!scrollController.hasClients) return;
      const itemExtent = 36.0;
      final viewportDimension = scrollController.position.viewportDimension;
      final maxScroll = scrollController.position.maxScrollExtent;
      final currentScroll = scrollController.offset;

      final itemTop = index * itemExtent;
      final itemBottom = itemTop + itemExtent;

      if (itemTop < currentScroll) {
        final target = itemTop.clamp(0.0, maxScroll);
        scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 60),
          curve: Curves.easeOut,
        );
      } else if (itemBottom > currentScroll + viewportDimension) {
        final target = (itemBottom - viewportDimension).clamp(0.0, maxScroll);
        scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 60),
          curve: Curves.easeOut,
        );
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      searchFocusNode.requestFocus();
      if (initIndex > 0) {
        scrollToFocused(focusedIndex);
      }
    });

    await showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final filteredItems = items.where((item) {
              return item.label.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  ) ||
                  item.value.toLowerCase().contains(searchQuery.toLowerCase());
            }).toList();

            if (focusedIndex >= filteredItems.length) {
              focusedIndex = (filteredItems.length - 1).clamp(
                0,
                filteredItems.length,
              );
            }

            return AlertDialog(
              titlePadding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Select $title',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              content: SizedBox(
                width: 320,
                height: 380,
                child: Column(
                  children: [
                    TextField(
                      focusNode: searchFocusNode,
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (val) {
                        setDialogState(() {
                          searchQuery = val;
                          focusedIndex = 0;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: filteredItems.isEmpty
                          ? const Center(
                              child: Text(
                                'No items found',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              itemCount: filteredItems.length,
                              itemExtent: 36.0,
                              itemBuilder: (context, idx) {
                                final item = filteredItems[idx];
                                final isSelected = item.value == initialSelected;
                                return ListTile(
                                  dense: true,
                                  visualDensity: VisualDensity.compact,
                                  title: Text(
                                    item.label,
                                    style: TextStyle(
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? const Color(0xFF556EE6)
                                          : Colors.black87,
                                    ),
                                  ),
                                  trailing: isSelected
                                      ? const Icon(
                                          Icons.check,
                                          size: 18,
                                          color: Color(0xFF556EE6),
                                        )
                                      : null,
                                  onTap: () {
                                    onConfirm(item.value);
                                    Navigator.of(context).pop();
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showMultiSelectDialog({
    required BuildContext context,
    required String title,
    required List<ErpDropdownItem> items,
    required List<String> initialSelected,
    required ValueChanged<List<String>> onConfirm,
  }) async {
    final tempSelected = List<String>.from(initialSelected);
    String searchQuery = '';
    int focusedIndex = 0;
    final scrollController = ScrollController();
    final searchFocusNode = FocusNode();

    void scrollToFocused(int index) {
      if (!scrollController.hasClients) return;
      const itemExtent = 36.0;
      final viewportDimension = scrollController.position.viewportDimension;
      final maxScroll = scrollController.position.maxScrollExtent;
      final currentScroll = scrollController.offset;

      final itemTop = index * itemExtent;
      final itemBottom = itemTop + itemExtent;

      if (itemTop < currentScroll) {
        final target = itemTop.clamp(0.0, maxScroll);
        scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 60),
          curve: Curves.easeOut,
        );
      } else if (itemBottom > currentScroll + viewportDimension) {
        final target = (itemBottom - viewportDimension).clamp(0.0, maxScroll);
        scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 60),
          curve: Curves.easeOut,
        );
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      searchFocusNode.requestFocus();
    });

    await showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final filteredItems = items.where((item) {
              return item.label.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  ) ||
                  item.value.toLowerCase().contains(searchQuery.toLowerCase());
            }).toList();

            if (focusedIndex >= filteredItems.length) {
              focusedIndex = (filteredItems.length - 1).clamp(
                0,
                filteredItems.length,
              );
            }

            final isAllSelected = filteredItems.isNotEmpty &&
                filteredItems.every((i) => tempSelected.contains(i.value));

            return AlertDialog(
              titlePadding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Select $title',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              content: SizedBox(
                width: 320,
                height: 420,
                child: Column(
                  children: [
                    TextField(
                      focusNode: searchFocusNode,
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (val) {
                        setDialogState(() {
                          searchQuery = val;
                          focusedIndex = 0;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          icon: Icon(
                            isAllSelected
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            size: 18,
                            color: const Color(0xFF556EE6),
                          ),
                          label: Text(
                            isAllSelected ? 'Deselect All' : 'Select All',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF556EE6),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            setDialogState(() {
                              if (isAllSelected) {
                                for (final item in filteredItems) {
                                  tempSelected.remove(item.value);
                                }
                              } else {
                                for (final item in filteredItems) {
                                  if (!tempSelected.contains(item.value)) {
                                    tempSelected.add(item.value);
                                  }
                                }
                              }
                            });
                          },
                        ),
                        Text(
                          '${tempSelected.length} selected',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: filteredItems.isEmpty
                          ? const Center(
                              child: Text(
                                'No items found',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              itemCount: filteredItems.length,
                              itemExtent: 36.0,
                              itemBuilder: (context, idx) {
                                final item = filteredItems[idx];
                                final isSelected = tempSelected.contains(item.value);
                                return ListTile(
                                  dense: true,
                                  visualDensity: VisualDensity.compact,
                                  title: Text(
                                    item.label,
                                    style: TextStyle(
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? const Color(0xFF556EE6)
                                          : Colors.black87,
                                    ),
                                  ),
                                  leading: Checkbox(
                                    value: isSelected,
                                    activeColor: const Color(0xFF556EE6),
                                    visualDensity: VisualDensity.compact,
                                    onChanged: (val) {
                                      setDialogState(() {
                                        if (val == true) {
                                          tempSelected.add(item.value);
                                        } else {
                                          tempSelected.remove(item.value);
                                        }
                                      });
                                    },
                                  ),
                                  onTap: () {
                                    setDialogState(() {
                                      if (isSelected) {
                                        tempSelected.remove(item.value);
                                      } else {
                                        tempSelected.add(item.value);
                                      }
                                    });
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF556EE6),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    onConfirm(tempSelected);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
