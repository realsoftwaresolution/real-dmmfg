import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:diam_mfg/models/user_visibility_model.dart';
import 'package:diam_mfg/providers/ReportProvider.dart';
import 'package:diam_mfg/providers/charni_provider.dart';
import 'package:diam_mfg/providers/color_provider.dart';
import 'package:diam_mfg/providers/counter_display_det_provider.dart';
import 'package:diam_mfg/providers/counter_manager_det_provider.dart';
import 'package:diam_mfg/providers/counter_provider.dart';
import 'package:diam_mfg/providers/cut_create_provider.dart';
import 'package:diam_mfg/providers/cut_provider.dart';
import 'package:diam_mfg/providers/dept_group_provider.dart';
import 'package:diam_mfg/providers/dept_process_provider.dart';
import 'package:diam_mfg/providers/dept_provider.dart';
import 'package:diam_mfg/providers/division_provider.dart';
import 'package:diam_mfg/providers/employee_provider.dart';
import 'package:diam_mfg/providers/factory_provider.dart';
import 'package:diam_mfg/providers/purity_provider.dart';
import 'package:diam_mfg/providers/remarks_provider.dart';
import 'package:diam_mfg/providers/report_mst_provider.dart';
import 'package:diam_mfg/providers/report_type_provider.dart';
import 'package:diam_mfg/providers/rough_provider.dart';
import 'package:diam_mfg/providers/shape_provider.dart';
import 'package:diam_mfg/providers/tensions_provider.dart';
import 'package:diam_mfg/providers/test_provider.dart';
import 'package:diam_mfg/providers/user_visibility_provider.dart';
import 'package:diam_mfg/utils/ReportRegistry.dart';
import 'package:diam_mfg/utils/app_images.dart';
import 'package:dio/dio.dart';
import 'package:erp_data_table/erp_data_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rs_dashboard/rs_dashboard.dart';

import 'dart:typed_data';

import 'package:universal_html/html.dart' as html;
import 'package:pdfx/pdfx.dart';

import '../bootstrap.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

// ─────────────────────────────────────────────────────────────────────────────
//  STATE
// ─────────────────────────────────────────────────────────────────────────────

class _ReportScreenState extends State<ReportScreen> {
  // ── Theme ──────────────────────────────────────────────────────────────────
  final ErpThemeVariant _themeVariant = ErpThemeVariant.frost;

  ErpTheme get _theme => ErpTheme(_themeVariant);

  // ── Form ───────────────────────────────────────────────────────────────────
  // ⚠️  Never reassign _erpFormKey inside setState — that causes the
  //     "_elements.contains(element)" assertion.  Use a stable key always.
  //     To force a clean widget rebuild on reset, increment _formResetCount
  //     which is passed as the ValueKey on ErpForm.
  final GlobalKey<ErpFormState> _erpFormKey = GlobalKey<ErpFormState>();
  int _formResetCount = 0; // ← bumped on reset to give ErpForm a new ValueKey
  Map<String, String> _formValues = {};
  final Map<String, String> _entryVals = {};

  /// Parallel map that keeps the raw List<String> for every multi-select field.
  /// _formValues[key] holds the comma-joined string (for display / reset).
  /// _multiSelectValues[key] holds the typed list (for API calls).
  Map<String, List<String>>? _multiSelectValues; // ← ADD
  int? _selectedTestCode;
  int? _selectedReportTypeCode;
  String? _activeReportType = '';

  // ── Auth ───────────────────────────────────────────────────────────────────
  final String? token = AppStorage.getString('token');

  // ── From / To counter ─────────────────────────────────────────────────────
  int? _fromCrId;
  String? _fromDeptName;
  int? _fromDeptCode;

  int? _toCrId;
  String? _toDeptName;
  int? _toDeptCodeVal;

  int? _editingDetIndex;

  // ── Display fields (from UserVisibility) ───────────────────────────────────
  List<UserVisibilityModel> _fromDisplayFields = [];
  List<UserVisibilityModel> _toDisplayFields = [];
  String? _selectedRadioCode;

  CounterDisplayDetProvider get _displayProv =>
      context.read<CounterDisplayDetProvider>();

  UserVisibilityProvider get _visProv => context.read<UserVisibilityProvider>();

  // ── Keys that are multi-select ─────────────────────────────────────────────
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

  // ─────────────────────────────────────────────────────────────────────────
  //  API FILTER HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  /// Returns a List<int> for a multi-select field (empty list if nothing selected).
  List<int> _intList(String key) => (_multiSelectValues?[key] ?? [])
      .map((e) => int.tryParse(e))
      .whereType<int>()
      .toList();

  /// Returns a single nullable int for normal (single) dropdown / text fields.
  int? _intVal(String key) => int.tryParse(_formValues[key] ?? '');

  // ─────────────────────────────────────────────────────────────────────────
  //  LOOKUP HELPERS
  // ─────────────────────────────────────────────────────────────────────────

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

  String _deptGroupNameFor(int? code) {
    if (code == null) return '';
    try {
      return context
              .read<DeptGroupProvider>()
              .list
              .firstWhere((d) => d.deptGroupCode == code)
              .deptGroupName ??
          '';
    } catch (_) {
      return '';
    }
  }

  String _shapeNameFor(int? code) {
    if (code == null) return '';
    try {
      return context
              .read<ShapeProvider>()
              .list
              .firstWhere((s) => s.shapeCode == code)
              .shapeName ??
          '';
    } catch (_) {
      return '';
    }
  }

  String _purityNameFor(int? code) {
    if (code == null) return '';
    try {
      return context
              .read<PurityProvider>()
              .list
              .firstWhere((p) => p.purityCode == code)
              .purityName ??
          '';
    } catch (_) {
      return '';
    }
  }

  String _employeeNameFor(int? code) {
    if (code == null) return '';
    try {
      return context
              .read<EmployeeProvider>()
              .list
              .firstWhere((e) => e.employeeCode == code)
              .employeeName ??
          '';
    } catch (_) {
      return '';
    }
  }

  String _signerNameFor(int? crId) {
    if (crId == null) return '';
    try {
      return context
              .read<CounterProvider>()
              .list
              .firstWhere((c) => c.crId == crId)
              .logInName ??
          '';
    } catch (_) {
      return '';
    }
  }

  String _remarksNameFor(int? code) {
    if (code == null) return '';
    try {
      return context
              .read<RemarksProvider>()
              .list
              .firstWhere((r) => r.remarksCode == code)
              .remarksName ??
          '';
    } catch (_) {
      return '';
    }
  }

  /// Shared logic for building a sorted, validated UserVisibilityModel list.
  List<UserVisibilityModel> _buildVisibilityList({
    required List<dynamic> rawList,
    required String counterType,
  }) {
    return rawList
        .where(
          (r) =>
              r.counterType == counterType &&
              r.userVisibilityCode != null &&
              _visProv.list.any(
                (v) => v.userVisibilityCode == r.userVisibilityCode,
              ),
        )
        .map(
          (r) => _visProv.list.firstWhereOrNull(
            (v) => v.userVisibilityCode == r.userVisibilityCode,
          ),
        )
        .where(
          (v) =>
              v != null &&
              v!.userVisibilityCode != null &&
              (v.userVisibilityName ?? '').isNotEmpty,
        )
        .cast<UserVisibilityModel>()
        .toList()
      ..sort((a, b) => (a.sortID ?? 0).compareTo(b.sortID ?? 0));
  }

  Future<void> _loadToDisplayFields(int crId) async {
    final counter = context.read<CounterProvider>().list.firstWhereOrNull(
      (c) => c.crId == crId,
    );
    if (counter == null || counter.counterMstID == null) return;

    await _displayProv.loadByCounter(counter.counterMstID!);
    if (!mounted) return;

    setState(() {
      _toDisplayFields = _buildVisibilityList(
        rawList: _displayProv.counterList,
        counterType: 'TO',
      );
    });
  }

  Future<void> _loadFromDisplayFields(int crId) async {
    final counter = context.read<CounterProvider>().list.firstWhereOrNull(
      (c) => c.crId == crId,
    );
    if (counter == null || counter.counterMstID == null) return;

    await _displayProv.loadByCounter(counter.counterMstID!);
    if (!mounted) return;

    setState(() {
      _fromDisplayFields = _buildVisibilityList(
        rawList: _displayProv.counterList,
        counterType: 'FROM',
      );
    });
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
        _fromDeptName = deptName;
        _fromDeptCode = counter.deptCode;
        _toCrId = null;
        _toDeptName = null;
        _formValues['fromCrId'] = crIdStr;
        _formValues['fromDept'] = deptName;
      });

      _erpFormKey.currentState?.updateFieldValue('fromDept', deptName);
      _erpFormKey.currentState?.updateFieldValue('toCrId', '');
      _erpFormKey.currentState?.updateFieldValue('toDept', '');
      _erpFormKey.currentState?.updateFieldValue('deptProcessCode', '');
      _erpFormKey.currentState?.updateFieldValue('deptName', '');

      _loadFromDisplayFields(crId);
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
        _toDeptName = deptName;
        _toDeptCodeVal = counter.deptCode;
        _formValues['toCrId'] = crIdStr;
        _formValues['toDept'] = deptName;
      });

      _erpFormKey.currentState?.updateFieldValue('toDept', deptName);
      _erpFormKey.currentState?.updateFieldValue('deptName', deptName);
      _erpFormKey.currentState?.updateFieldValue('deptProcessCode', '');

      _loadToDisplayFields(crId);
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();
    _setDefaultFormValues();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.wait([
        context.read<CounterProvider>().load(),
        context.read<CounterManagerDetProvider>().load(),
        context.read<DeptProvider>().load(),
        context.read<DeptGroupProvider>().load(),
        context.read<DeptProcessProvider>().load(),
        context.read<CharniProvider>().load(),
        context.read<TensionsProvider>().load(),
        context.read<CounterDisplayDetProvider>().load(),
        context.read<UserVisibilityProvider>().load(),
        context.read<EmployeeProvider>().loadEmployees(),
        context.read<RemarksProvider>().load(),
        context.read<ShapeProvider>().load(),
        context.read<PurityProvider>().load(),
        context.read<FactoryProvider>().loadFactories(),
        context.read<ColorProvider>().load(),
        context.read<ReportTypeProvider>().load(),
        context.read<TestProvider>().load(),
        context.read<CutProvider>().loadCuts(),
        context.read<RoughProvider>().loadRoughs(),
        context.read<CutCreateProvider>().load(),
        context.read<DivisionProvider>().loadDivisions(),
        context.read<ReportMstProvider>().load(),
      ]);
    });
  }

  List<List<ErpFieldConfig>> _buildFormRows() {
    final counterProv = context.read<CounterProvider>();
    final mgDetProv = context.read<CounterManagerDetProvider>();
    final procProv = context.read<DeptProcessProvider>();
    final tensProv = context.read<TensionsProvider>();
    final colorProv = context.read<ColorProvider>();
    final shapeProv = context.read<ShapeProvider>();
    final purityProv = context.read<PurityProvider>();
    final remarksProv = context.read<RemarksProvider>();
    final employeeProv = context.read<EmployeeProvider>();
    final divisionProv = context.read<DivisionProvider>();
    final factoryProv = context.read<FactoryProvider>();
    final typeProv = context.read<TestProvider>();
    final reportTypeProv = context.read<ReportTypeProvider>();
    final cutProv = context.read<CutCreateProvider>();
    final roughProv = context.watch<RoughProvider>();
    final reportsProv = context.watch<ReportMstProvider>();

    final isFromSelected = _fromCrId != null;
    final isToSelected = _toCrId != null;

    // ── FROM dropdown ────────────────────────────────────────────────────────
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

    // ── TO dropdown — allowCrIds from CounterManagerDet ───────────────────
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

    // ── PROCESS dropdown ──────────────────────────────────────────────────
    final processItems = (_fromCrId == null || _toCrId == null)
        ? <ErpDropdownItem>[]
        : () {
            final issueCodes = mgDetProv.list
                .where((m) => m.crId == _fromCrId && m.deptProcessCode != null)
                .map((m) => m.deptProcessCode!)
                .toSet();

            final recvCodes = mgDetProv.list
                .where(
                  (m) => m.allowCrId == _toCrId && m.deptProcessCode != null,
                )
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

    // ── TENSIONS dropdown ─────────────────────────────────────────────────
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

    final reportTypeItems = reportTypeProv.list
        .where(
          (e) => _selectedTestCode == null || e.TestCode == _selectedTestCode,
        )
        .map(
          (e) => ErpDropdownItem(
            label: e.reportTypeName ?? '',
            value: e.reportTypeCode?.toString() ?? '',
          ),
        )
        .toList();

    final typeItems = typeProv.list
        .map(
          (e) => ErpDropdownItem(
            label: e.testName ?? '',
            value: e.testCode?.toString() ?? '',
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

    final empItems = employeeProv.list
        .map(
          (e) => ErpDropdownItem(
            label: e.employeeName ?? '',
            value: e.employeeCode?.toString() ?? '',
          ),
        )
        .toList();

    final divisionItems = divisionProv.divisions
        .map(
          (e) => ErpDropdownItem(
            label: e.divisionName ?? '',
            value: e.divisionCode?.toString() ?? '',
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

    final reportsItems = reportsProv.list
        .where(
          (e) =>
              (_selectedTestCode == null || e.testCode == _selectedTestCode) &&
              (_selectedReportTypeCode == null ||
                  e.reportTypeCode == _selectedReportTypeCode),
        )
        .map(
          (e) => ErpDropdownItem(
            label: e.reportName ?? '',
            value: e.reportName ?? '',
          ),
        )
        .toList();

    // ─────────────────────────────────────────────────────────────────────
    //  ROWS
    // ─────────────────────────────────────────────────────────────────────
    final List<List<ErpFieldConfig>> rows = [
      // Row 1 — type / sel / report / dates / times / finish
      [
        ErpFieldConfig(
          key: 'type',
          label: 'TYPE',
          type: ErpFieldType.dropdown,
          dropdownItems: typeItems,
          sectionIndex: 0,
          required: true,
        ),
        ErpFieldConfig(
          key: 'sel',
          label: 'SEL.',
          type: ErpFieldType.dropdown,
          dropdownItems: reportTypeItems,
          sectionIndex: 0,
          required: true,
        ),
        ErpFieldConfig(
          key: 'report',
          label: 'Reports',
          type: ErpFieldType.dropdown,
          dropdownItems: reportsItems,
          sectionIndex: 0,
          required: true,
        ),
        ErpFieldConfig(
          key: 'dateFrom',
          label: 'DATE',
          type: ErpFieldType.date,
          sectionIndex: 0,
          isEntryRequired: true,
          isEntryField: true,
          skipFocus: true,
        ),
        ErpFieldConfig(
          key: 'dateTo',
          label: 'TO',
          type: ErpFieldType.date,
          sectionIndex: 0,
          isEntryRequired: true,
          isEntryField: true,
          skipFocus: true,
        ),
        // ErpFieldConfig(
        //   key: 'timeFrom',
        //   label: 'TIME',
        //   type: ErpFieldType.time,
        //   sectionIndex: 0,
        //   isEntryRequired: true,
        //   isEntryField: true,
        //   skipFocus: true,
        // ),
        // ErpFieldConfig(
        //   key: 'timeTo',
        //   label: 'TO',
        //   type: ErpFieldType.time,
        //   sectionIndex: 0,
        //   isEntryRequired: true,
        //   isEntryField: true,
        //   skipFocus: true,
        // ),
        ErpFieldConfig(
          key: 'finish',
          label: 'finish',
          type: ErpFieldType.dropdown,
          dropdownItems: [
            ErpDropdownItem(value: 'N', label: 'N'),
            ErpDropdownItem(value: 'Y', label: 'Y'),
          ],
          sectionIndex: 0,
        ),
      ],

      // Row 2 — multi-select filters
      [
        ErpFieldConfig(
          key: 'mainCut',
          label: 'MAIN CUT',
          type: ErpFieldType.multiselectDropdown,
          dropdownItems: mainCutNoItems,
          sectionIndex: 1,
        ),
        ErpFieldConfig(
          key: 'kNo',
          label: 'KNO',
          type: ErpFieldType.multiselectDropdown,
          dropdownItems: roughItems,
          sectionIndex: 1,
        ),
        ErpFieldConfig(
          key: 'cutNo',
          label: 'CUT NO',
          type: ErpFieldType.multiselectDropdown,
          dropdownItems: cutItems,
          sectionIndex: 1,
        ),
        ErpFieldConfig(
          key: 'fromCrId',
          label: 'FROM',
          type: ErpFieldType.multiselectDropdown,
          dropdownItems: fromItems,
          sectionIndex: 1,
        ),
        ErpFieldConfig(
          key: 'fromDept',
          label: 'MAN',
          type: ErpFieldType.multiselectDropdown,
          readOnly: true,
          sectionIndex: 1,
        ),
        ErpFieldConfig(
          key: 'toCrId',
          label: 'TO',
          type: ErpFieldType.multiselectDropdown,
          dropdownItems: toItems,
          readOnly: !isFromSelected,
          sectionIndex: 1,
        ),
        ErpFieldConfig(
          key: 'toDept',
          label: 'MAN',
          type: ErpFieldType.multiselectDropdown,
          readOnly: true,
          sectionIndex: 1,
        ),
        ErpFieldConfig(
          key: 'remarks',
          label: 'REMARKS',
          type: ErpFieldType.multiselectDropdown,
          dropdownItems: remarksItems,
          sectionIndex: 1,
        ),
        ErpFieldConfig(
          key: 'deptProcessCode',
          label: 'PROCESS',
          type: ErpFieldType.multiselectDropdown,
          dropdownItems: processItems,
          readOnly: !isToSelected,
          sectionIndex: 1,
        ),
        ErpFieldConfig(
          key: 'deptName',
          label: 'DEPT',
          type: ErpFieldType.text,
          readOnly: true,
          sectionIndex: 1,
        ),
        ErpFieldConfig(
          key: 'purityCode',
          label: 'PURITY',
          type: ErpFieldType.multiselectDropdown,
          dropdownItems: purityItems,
          sectionIndex: 1,
        ),
        ErpFieldConfig(
          key: 'colorCode',
          label: 'COLOR',
          type: ErpFieldType.multiselectDropdown,
          dropdownItems: colorItems,
          sectionIndex: 1,
        ),
        ErpFieldConfig(
          key: 'tensionCode',
          label: 'TENSION',
          type: ErpFieldType.multiselectDropdown,
          dropdownItems: tensDropdown,
          sectionIndex: 1,
        ),
        ErpFieldConfig(
          key: 'shapeCode',
          label: 'SHAPE',
          type: ErpFieldType.multiselectDropdown,
          dropdownItems: shapeItems,
          sectionIndex: 1,
        ),
      ],

      // Row 3 — additional filters
      [
        ErpFieldConfig(
          key: 'typeSecond',
          label: 'TYPE',
          type: ErpFieldType.multiselectDropdown,
          dropdownItems: [],
          sectionIndex: 2,
        ),
        ErpFieldConfig(
          key: 'factoryCode',
          label: 'FACTORY',
          type: ErpFieldType.multiselectDropdown,
          dropdownItems: factoryItems,
          sectionIndex: 2,
        ),
        ErpFieldConfig(
          key: 'divisionCode',
          label: 'DIVISION',
          type: ErpFieldType.multiselectDropdown,
          dropdownItems: divisionItems,
          sectionIndex: 2,
        ),
        ErpFieldConfig(
          key: 'employeeCode',
          label: 'EMP',
          type: ErpFieldType.multiselectDropdown,
          dropdownItems: empItems,
          sectionIndex: 2,
        ),
        ErpFieldConfig(
          key: 'repairing',
          label: 'REPAIRING',
          type: ErpFieldType.dropdown,
          dropdownItems: [
            ErpDropdownItem(value: 'Y', label: 'Y'),
            ErpDropdownItem(value: 'N', label: 'N'),
          ],
          sectionIndex: 2,
        ),
        ErpFieldConfig(
          key: 'shift',
          label: 'SHIFT',
          type: ErpFieldType.dropdown,
          dropdownItems: [
            ErpDropdownItem(label: 'DAY', value: 'DAY'),
            ErpDropdownItem(label: 'NIGHT', value: 'NIGHT'),
          ],
          sectionIndex: 2,
        ),
        ErpFieldConfig(
          key: 'lotNoFrom',
          label: 'LOT NO',
          type: ErpFieldType.text,
          sectionIndex: 2,
        ),
        ErpFieldConfig(
          key: 'lotNoTo',
          label: 'TO',
          type: ErpFieldType.text,
          sectionIndex: 2,
        ),
        ErpFieldConfig(
          key: 'pktType',
          label: 'PKT TYPE',
          type: ErpFieldType.dropdown,
          dropdownItems: const [
            ErpDropdownItem(label: 'ALL', value: 'ALL'),
            ErpDropdownItem(label: 'SINGLE', value: 'SINGLE'),
            ErpDropdownItem(label: 'LOOSE', value: 'LOOSE'),
          ],
          sectionIndex: 2,
        ),
      ],
    ];

    return _sanitizeRows(rows);
  }

  List<List<ErpFieldConfig>> _sanitizeRows(List<List<ErpFieldConfig>> rows) {
    return rows.map((section) {
      return section.whereType<ErpFieldConfig>().map((field) {
        final safeItems = (field.dropdownItems ?? [])
            .whereType<ErpDropdownItem>()
            .where((item) => item.value.isNotEmpty && item.label.isNotEmpty)
            .toList();

        if (safeItems.length == (field.dropdownItems?.length ?? 0)) {
          return field;
        }
        return ErpFieldConfig(
          key: field.key,
          label: field.label,
          type: field.type,
          flex: field.flex,
          readOnly: field.readOnly,
          required: field.required,
          sectionIndex: field.sectionIndex ?? 0,
          sectionTitle: field.sectionTitle,
          isEntryField: field.isEntryField,
          isEntryRequired: field.isEntryRequired,
          showAddButton: field.showAddButton,
          dropdownItems: safeItems,
        );
      }).toList();
    }).toList();
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  REGISTRY KEY HELPER
  // ─────────────────────────────────────────────────────────────────────────

  String _toRegistryKey(String reportName) =>
      reportName.trim().toUpperCase().replaceAll(' ', '_');

  // ─────────────────────────────────────────────────────────────────────────
  //  SEARCH
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _onSearch() async {
    final reportName = _formValues['report'];
    if (reportName == null || reportName.isEmpty) return;
    context.read<ReportProvider>().clear();

    final registryKey = _toRegistryKey(reportName);
    print(registryKey);
    final config = ReportRegistry.of(registryKey);
    if (config == null) return;

    setState(() => _activeReportType = registryKey);

    final prov = context.read<ReportProvider>();

    final filter = <String, dynamic>{
      // Single-value fields
      "reportType": _intVal('type'),
      "sel": _intVal('sel'),
      "finish": _formValues['finish'],
      "repairing": _formValues['repairing'],
      "shift": _formValues['shift'],
      "lotNoFrom": _intVal('lotNoFrom'),
      "lotNoTo": _intVal('lotNoTo'),
      "pktType": _formValues['pktType'],

      // Multi-select fields (KEEP AS LISTS)
      "MainCutNo": _multiSelectValues?['mainCut'] ?? [],
      "KapanNo": _multiSelectValues?['kNo'] ?? [],
      "cutNo": _multiSelectValues?['cutNo'] ?? [],

      "fromManager": _intList('fromCrId'),
      "toManager": _intList('toCrId'),
      "Remarks": _intList('remarks'),
      "deptProcessCode": _intList('deptProcessCode'),
      "purityCode": _intList('purityCode'),
      "colorCode": _intList('colorCode'),
      "tensionCode": _intList('tensionCode'),
      "shapeCode": _intList('shapeCode'),
      "factoryCode": _intList('factoryCode'),
      "divisionCode": _intList('divisionCode'),
      "employeeCode": _intList('employeeCode'),
    };

    // Remove nulls and empty lists
    filter.removeWhere((key, value) {
      if (value == null) return true;
      if (value is String && value.trim().isEmpty) return true;
      if (value is List && value.isEmpty) return true;
      return false;
    });

    // Date / Time
    if (registryKey != 'PACKET_WISE_PLANNING_SUMMARY' &&
        registryKey != 'PACKET_WISE_PLANNING_DETAIL') {
      filter.addAll({
        "fromDate": DateFormat(
          'yyyy-MM-dd',
        ).format(DateFormat('dd/MM/yyyy').parse(_formValues['dateFrom']!)),

        "toDate": DateFormat(
          'yyyy-MM-dd',
        ).format(DateFormat('dd/MM/yyyy').parse(_formValues['dateTo']!)),

        // "fromTime": DateFormat('HH:mm:ss')
        //     .format(DateFormat('hh:mm a').parse(_formValues['timeFrom']!)),
        //
        // "toTime": DateFormat('HH:mm:ss')
        //     .format(DateFormat('hh:mm a').parse(_formValues['timeTo']!)),
      });
    }

    // Special case
    if (registryKey == 'KAPAN_PERFORMANCE') {
      filter['kapanNos'] = _multiSelectValues?['cutNo'] ?? [];
    }

    print('FINAL FILTER');
    print(jsonEncode(filter));

    await prov.loadReport(
      reportTypeCode: registryKey,
      filter: filter,
      theme: _theme,
      context: context,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  RESET
  // ─────────────────────────────────────────────────────────────────────────

  void _resetForm() {
    // ⚠️  Do NOT reassign _erpFormKey — that triggers the
    //     "_elements.contains(element)" assertion during the next rebuild.
    //     Instead, call resetForm() on the existing state and bump
    //     _formResetCount so ErpForm receives a new ValueKey and rebuilds
    //     its internal widget tree cleanly.
    _erpFormKey.currentState?.resetForm();

    _entryVals.clear();
    _multiSelectValues?.clear();
    context.read<ReportProvider>().clear();

    setState(() {
      _editingDetIndex = null;
      _fromCrId = _toCrId = null;
      _fromDeptName = _toDeptName = null;
      _fromDeptCode = _toDeptCodeVal = null;
      _selectedRadioCode = null;
      _selectedTestCode = null;
      _selectedReportTypeCode = null;
      _activeReportType = '';
      _toDisplayFields.clear();
      _fromDisplayFields.clear();
      _formValues.clear();
      _formResetCount++; // ← gives ErpForm a new ValueKey, forces clean rebuild
    });

    _setDefaultFormValues();
  }

  void _setDefaultFormValues() {
    final now = DateTime.now();
    _formValues = {
      'dateFrom': DateFormat('dd/MM/yyyy').format(now),
      'dateTo': DateFormat('dd/MM/yyyy').format(now),
      'timeFrom': DateFormat('hh:mm a').format(now),
      'timeTo': DateFormat('hh:mm a').format(now),
    };
    _multiSelectValues?.clear();
    if (mounted) setState(() {});
    // After reset the ErpForm subtree is recreated (new ValueKey), so wait
    // two frames before requesting focus so the new State is mounted.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 80), () {
        if (mounted) _erpFormKey.currentState?.focusField('type');
      });
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportProvider>(
      builder: (ctx, prov, _) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child: _buildForm(context, prov),
        );
      },
    );
  }

  Widget _buildForm(BuildContext context, ReportProvider prov) {
    return ErpForm(
      logo: AppImages.logo,
      // _erpFormKey is stable (never reassigned).
      // ValueKey(_formResetCount) tells Flutter to discard and recreate the
      // ErpForm subtree when cancel is pressed, without touching the GlobalKey.
      key: ValueKey('erp_form_$_formResetCount'),
      title: 'REPORT',
      rows: _buildFormRows(),
      initialValues: _formValues,
      onCancel: _resetForm,
      autoStartAdding: true,
      onSearch: _onSearch,
      isShowSaveButton: false,
      isEditMode: false,
      isShowSearch: true,
      onFieldChanged: (key, value) {
        print('KEY = $key   VALUE = $value');

        setState(() {
          if (_multiSelectKeys.contains(key)) {
            _multiSelectValues ??= {};

            if (value is List<String>) {
              _multiSelectValues![key] = value;

              // Optional: display માટે
              _formValues[key] = value.join(',');
            }
          } else {
            _formValues[key] = value.toString();
          }
        });

        switch (key) {
          // ── TYPE ────────────────────────────────────────────────────────
          case 'type':
            final testCode = int.tryParse(value.toString());
            final firstReportType = context
                .read<ReportTypeProvider>()
                .list
                .firstWhereOrNull(
                  (e) => testCode == null || e.TestCode == testCode,
                );

            final firstReportTypeCode = firstReportType?.reportTypeCode;
            final firstReportTypeCodeStr =
                firstReportTypeCode?.toString() ?? '';

            setState(() {
              _selectedTestCode = testCode;
              _selectedReportTypeCode = firstReportTypeCode;
              _formValues['sel'] = firstReportTypeCodeStr;
            });

            _erpFormKey.currentState?.updateFieldValue(
              'sel',
              firstReportTypeCodeStr,
            );

          // ── SEL ─────────────────────────────────────────────────────────
          case 'sel':
            _entryVals[key] = value.toString();
            context.read<ReportProvider>().clear();
            _selectedReportTypeCode = int.tryParse(value.toString());

            final filtered = context
                .read<ReportMstProvider>()
                .list
                .where(
                  (e) =>
                      (_selectedTestCode == null ||
                          e.testCode == _selectedTestCode) &&
                      (_selectedReportTypeCode == null ||
                          e.reportTypeCode == _selectedReportTypeCode),
                )
                .toList();

            final firstReportName = filtered.isNotEmpty
                ? filtered.first.reportName ?? ''
                : '';

            setState(() {
              _formValues['report'] = firstReportName;
              _activeReportType = _toRegistryKey(firstReportName);
            });

            _erpFormKey.currentState?.updateFieldValue(
              'report',
              firstReportName,
            );

            Future.delayed(
              const Duration(milliseconds: 50),
              () => _erpFormKey.currentState?.focusField('report'),
            );

          // ── REPORT ──────────────────────────────────────────────────────
          case 'report':
            _entryVals[key] = value.toString();
            context.read<ReportProvider>().clear();

          // ── FROM (multi-select: use first selected for dept lookup) ─────
          case 'fromCrId':
            final firstId =
                (_multiSelectValues?['fromCrId'] ?? []).firstOrNull ?? '';
            if (firstId.isNotEmpty) {
              _onFromSelected(firstId);
            }
            Future.delayed(
              const Duration(milliseconds: 50),
              () => _erpFormKey.currentState?.focusField('toCrId'),
            );

          // ── TO (multi-select: use first selected for dept lookup) ────────
          case 'toCrId':
            final firstId =
                (_multiSelectValues?['toCrId'] ?? []).firstOrNull ?? '';
            if (firstId.isNotEmpty) {
              _onToSelected(firstId);
            }

          // ── ALL OTHER FIELDS ────────────────────────────────────────────
          default:
            _entryVals[key] = value.toString();
            _formValues[key] = value.toString();
        }
      },

      detailBuilder: (ctx) {
        final prov = context.watch<ReportProvider>();
        final registryKey = _toRegistryKey(_activeReportType ?? '');
        final config = ReportRegistry.of(registryKey);

        if (config == null) return const SizedBox.shrink();

        // ── PDF branch ───────────────────────────────────────────────────
        if (config.isPdf) {
          if (prov.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (prov.pdfBytes == null) return const SizedBox.shrink();

          return LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight.isFinite
                    ? constraints.maxHeight
                    : 600.0,
                child: _PdfReportView(
                  filter: _formValues,
                  pdfBytes: prov.pdfBytes!,
                  reportTitle: registryKey,
                ),
              );
            },
          );
        }
        final erpColumns = config.columns.map((c) => c.toErpColumn()).toList();

        return LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight.isFinite
                  ? constraints.maxHeight
                  : 500,
              child: prov.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : prov.tableData.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.info_outline, size: 60),
                            const SizedBox(height: 12),
                            const Text(
                              'No Data Found',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'No records match the selected filters.\nPlease adjust your filters and try again.',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : ErpDataTable(
                      key: ValueKey(
                        '${_activeReportType}_${prov.tableData.length}',
                      ),
                      data: prov.tableData,
                      columns: erpColumns,
                      showSearch: false,
                      title: registryKey.isEmpty
                          ? 'REPORT DATA'
                          : registryKey.replaceAll('_', ' '),
                      token: '',
                      url: '',
                      isReportRow: false,
                      showFooterTotals: true,
                    ),
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  PDF VIEWER
// ─────────────────────────────────────────────────────────────────────────────

class _PdfReportView extends StatefulWidget {
  final Uint8List pdfBytes;
  final String reportTitle;
  final dynamic filter;

  const _PdfReportView({
    required this.pdfBytes,
    required this.reportTitle,
    this.filter,
  });

  @override
  State<_PdfReportView> createState() => _PdfReportViewState();
}

class _PdfReportViewState extends State<_PdfReportView> {
  late PdfControllerPinch _pdfController;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfControllerPinch(
      document: PdfDocument.openData(widget.pdfBytes),
    );
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  Future<void> _openInNewTab(BuildContext context) async {
    final dio = Dio();
    final String? token = AppStorage.getString('token');
    final config = ReportRegistry.of(widget.reportTitle);
    if (config == null) return;

    final queryParams =
        config.queryBuilder?.call(widget.filter) ?? widget.filter;

    final response = await dio.get(
      '$baseUrl${config.endpoint}',
      queryParameters: queryParams,
      options: Options(
        responseType: ResponseType.bytes,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/pdf',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    final blob = html.Blob([response.data], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.window.open(url, '_blank');
    Future.delayed(
      const Duration(seconds: 10),
      () => html.Url.revokeObjectUrl(url),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : 600.0;

        return SizedBox(
          width: constraints.maxWidth,
          height: height,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Align(
                alignment: AlignmentGeometry.topRight,
                child: ElevatedButton.icon(
                  onPressed: () => _openInNewTab(context),
                  icon: const Icon(Icons.print, size: 18),
                  label: const Text('Open'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PdfViewPinch(
                  controller: _pdfController,
                  scrollDirection: Axis.vertical,
                  builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
                    options: const DefaultBuilderOptions(),
                    errorBuilder: (_, error) =>
                        Center(child: Text('Error loading PDF: $error')),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
