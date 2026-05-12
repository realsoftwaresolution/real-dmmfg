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
import 'package:diam_mfg/utils/constants.dart';
import 'package:erp_data_table/erp_data_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rs_dashboard/rs_dashboard.dart';

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
  GlobalKey<ErpFormState> _erpFormKey = GlobalKey<ErpFormState>();
  Map<String, String> _formValues = {};
  final Map<String, String> _entryVals = {};
  int? _selectedTestCode; // 🔥 ADD THIS
  int? _selectedReportTypeCode; // 🔥 ADD THIS
  String? _activeReportType = ''; // add this field

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

  List<Map<String, dynamic>> _reportData = [];

  @override
  void initState() {
    super.initState();
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
                    (c) => c.crId == allowId,
                  );
                  return ErpDropdownItem(
                    label: '${c.crName ?? ''}  |  ${_deptNameFor(c.deptCode)}',
                    value: c.crId?.toString() ?? '',
                  );
                } catch (_) {
                  return ErpDropdownItem(
                    label: 'ID:$allowId',
                    value: '$allowId',
                  );
                }
              })
              .toList();

    // ── PROCESS dropdown — intersection of FROM-issue ∩ TO-receive codes ──
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
        .map((cc) {
          final spkDet = cc.details.firstWhere(
            (d) => d.cutType == 'SPK',
            orElse: () => cc.details.first,
          );
          return ErpDropdownItem(
            // ✅ Edit mode mein current cut ka label
            label: spkDet.cutNo ?? '',
            value: spkDet.cutNo ?? '',
          );
        })
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
    // AFTER 🔥
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
    //  MASTER SECTION (sectionIndex 0)
    // ─────────────────────────────────────────────────────────────────────
    final List<List<ErpFieldConfig>> rows = [
      // Row 1 — date / time / ID
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
        ),
        ErpFieldConfig(
          key: 'dateTo',
          label: 'TO',
          type: ErpFieldType.date,
          sectionIndex: 0,
        ),
        ErpFieldConfig(
          key: 'timeFrom',
          label: 'TIME',
          type: ErpFieldType.time,
          sectionIndex: 0,
        ),
        ErpFieldConfig(
          key: 'timeTo',
          label: 'TO',
          type: ErpFieldType.time,
          sectionIndex: 0,
        ),
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

      // Row 2
      [
        ErpFieldConfig(
          key: 'mainCut',
          label: 'MAIN CUT',
          type: ErpFieldType.dropdown,
          dropdownItems: mainCutNoItems,
          sectionIndex: 1,
        ),
        ErpFieldConfig(
          key: 'kNo',
          label: 'KNO',
          type: ErpFieldType.dropdown,
          dropdownItems: roughItems,
          sectionIndex: 1,
        ),
        ErpFieldConfig(
          key: 'cutNo',
          label: 'CUT NO',
          type: ErpFieldType.dropdown,
          dropdownItems: cutItems,
          sectionIndex: 1,
        ),
        ErpFieldConfig(
          key: 'fromCrId',
          label: 'FROM',
          type: ErpFieldType.dropdown,
          dropdownItems: fromItems,
          sectionIndex: 1,
        ),
        ErpFieldConfig(
          key: 'fromDept',
          label: 'MAN',
          type: ErpFieldType.text,
          readOnly: true,
          sectionIndex: 1,
        ),
        ErpFieldConfig(
          key: 'toCrId',
          label: 'TO',
          type: ErpFieldType.dropdown,
          dropdownItems: toItems,
          readOnly: !isFromSelected,
          sectionIndex: 1,
        ),
        ErpFieldConfig(
          key: 'toDept',
          label: 'MAN',
          type: ErpFieldType.text,
          readOnly: true,
          sectionIndex: 1,
        ),
        ErpFieldConfig(
          key: 'remarks',
          label: 'REMARKS',
          type: ErpFieldType.dropdown,
          dropdownItems: remarksItems,
          sectionIndex: 1,
        ),
        ErpFieldConfig(
          key: 'deptProcessCode',
          label: 'PROCESS',
          type: ErpFieldType.dropdown,
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
          type: ErpFieldType.dropdown,
          dropdownItems: purityItems,
          sectionIndex: 1,
        ),
        ErpFieldConfig(
          key: 'colorCode',
          label: 'COLOR',
          type: ErpFieldType.dropdown,
          dropdownItems: colorItems,
          sectionIndex: 1,
        ),
        ErpFieldConfig(
          key: 'tensionCode',
          label: 'TENSION',
          type: ErpFieldType.dropdown,
          dropdownItems: tensDropdown,
          sectionIndex: 1,
        ),
        ErpFieldConfig(
          key: 'shapeCode',
          label: 'SHAPE',
          type: ErpFieldType.dropdown,
          dropdownItems: shapeItems,
          sectionIndex: 1,
        ),
      ],

      // Row 3
      [
        ErpFieldConfig(
          key: 'typeSecond',
          label: 'TYPE',
          type: ErpFieldType.dropdown,
          dropdownItems: [],
          sectionIndex: 2,
        ),
        ErpFieldConfig(
          key: 'factoryCode',
          label: 'FACTORY',
          type: ErpFieldType.dropdown,
          dropdownItems: factoryItems,
          sectionIndex: 2,
        ),
        ErpFieldConfig(
          key: 'divisionCode',
          label: 'DIVISION',
          type: ErpFieldType.dropdown,
          dropdownItems: divisionItems,
          sectionIndex: 2,
        ),
        ErpFieldConfig(
          key: 'employeeCode',
          label: 'EMP',
          type: ErpFieldType.dropdown,
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

  // ── In _ReportScreenState ─────────────────────────────────────

  /// "Rough Detail" → "ROUGH_DETAIL"
  String _toRegistryKey(String reportName) =>
      reportName.trim().toUpperCase().replaceAll(' ', '_');

  Future<void> _onSearch() async {
    final testCode = _formValues['type'];
    final reportName = _formValues['report'];

    if (reportName == null || reportName.isEmpty) return;

    // 🔥 normalize: "Rough Detail" → "ROUGH_DETAIL"
    final registryKey = _toRegistryKey(reportName);

    final config = ReportRegistry.of(registryKey);
    if (config == null) {
      return;
    }

    setState(() => _activeReportType = registryKey);

    final prov = context.read<ReportProvider>();

    final filter = {
      "reportType": int.tryParse(testCode ?? ''),
      "sel": int.tryParse(_formValues['sel'] ?? ''),
      "finish": _formValues['finish'],
      "MainCutNo": _formValues['mainCut'],
      "KapanNo": _formValues['kNo'],
      "cutNo": _formValues['cutNo'],
      "fromManager": int.tryParse(_formValues['fromCrId'] ?? ''),
      "toManager": int.tryParse(_formValues['toCrId'] ?? ''),
      "Remarks": int.tryParse(_formValues['remarks'] ?? ''),
      "deptProcessCode": int.tryParse(_formValues['deptProcessCode'] ?? ''),
      "purityCode": int.tryParse(_formValues['purityCode'] ?? ''),
      "colorCode": int.tryParse(_formValues['colorCode'] ?? ''),
      "tensionCode": int.tryParse(_formValues['tensionCode'] ?? ''),
      "shapeCode": int.tryParse(_formValues['shapeCode'] ?? ''),
      "factoryCode": int.tryParse(_formValues['factoryCode'] ?? ''),
      "divisionCode": int.tryParse(_formValues['divisionCode'] ?? ''),
      "employeeCode": int.tryParse(_formValues['employeeCode'] ?? ''),
      "repairing": _formValues['repairing'],
      "shift": _formValues['shift'],
      "lotNoFrom": int.tryParse(_formValues['lotNoFrom'] ?? ''),
      "lotNoTo": int.tryParse(_formValues['lotNoTo'] ?? ''),
      "pktType": _formValues['pktType'],
      "dateFrom": _formValues['dateFrom'],
      "dateTo": _formValues['dateTo'],
      "timeFrom": _formValues['timeFrom'],
      "timeTo": _formValues['timeTo'],
    };

    await prov.loadReport(reportTypeCode: registryKey, filter: filter);
  }

  void _resetForm() {
    _erpFormKey.currentState?.resetForm();
    _entryVals.clear();
    final prov = context.read<ReportProvider>();
    prov.clear();
    setState(() {
      _editingDetIndex = null;
      _fromCrId = _toCrId = null;
      _fromDeptName = _toDeptName = null;
      _fromDeptCode = _toDeptCodeVal = null;
      _selectedRadioCode = null;
      _toDisplayFields.clear();
      _fromDisplayFields.clear();
      _erpFormKey = GlobalKey<ErpFormState>();
      _formValues.clear();
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
    if (mounted) setState(() {});
  }

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
      key: _erpFormKey,
      title: 'REPORT',
      rows: _buildFormRows(),
      initialValues: _formValues,
      onCancel: _resetForm,

      /// 🔥 SEARCH BUTTON
      onSearch: _onSearch,
      isShowSaveButton: false,
      isEditMode: false,
      isShowSearch: true,
      onFieldChanged: (key, value) {
        _formValues[key] = value.toString();
        switch (key) {
          case 'type':
            final testCode = int.tryParse(value.toString());

            // 🔥 Find first matching reportType for this testCode
            final firstReportType = context
                .read<ReportTypeProvider>()
                .list
                .firstWhereOrNull(
                  (e) => testCode == null || e.TestCode == testCode,
                );

            final firstReportTypeCode = firstReportType?.reportTypeCode;
            final firstReportTypeCodeStr =
                firstReportTypeCode?.toString() ?? '';

            // 🔥 Now filter reports by BOTH testCode AND reportTypeCode
            final filtered = context
                .read<ReportMstProvider>()
                .list
                .where(
                  (e) =>
                      (testCode == null || e.testCode == testCode) &&
                      (firstReportTypeCode == null ||
                          e.reportTypeCode == firstReportTypeCode),
                )
                .toList();

            final firstReportName = filtered.isNotEmpty
                ? filtered.first.reportName ?? ''
                : '';

            setState(() {
              _selectedTestCode = testCode;
              _selectedReportTypeCode = firstReportTypeCode; // 🔥 reset sel too
              _formValues['sel'] = firstReportTypeCodeStr;
              _formValues['report'] = firstReportName;
              _activeReportType = _toRegistryKey(firstReportName);
            });

            // 🔥 Update both fields in the form UI
            _erpFormKey.currentState?.updateFieldValue(
              'sel',
              firstReportTypeCodeStr,
            );
            _erpFormKey.currentState?.updateFieldValue(
              'report',
              firstReportName,
            );

            if (firstReportName.isNotEmpty) {
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) _onSearch();
              });
            }

          case 'sel':
            _entryVals[key] = value.toString();
            _selectedReportTypeCode = int.tryParse(
              value.toString(),
            ); // 🔥 use tryParse

            // 🔥 Auto-set report to first matching record
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
            if (firstReportName.isNotEmpty) {
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) _onSearch();
              });
            }

          case 'report':
            _entryVals[key] = value.toString();
            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted) _onSearch();
            });

          case 'fromCrId':
            _onFromSelected(value.toString());
            Future.delayed(
              const Duration(milliseconds: 50),
              () => _erpFormKey.currentState?.focusField('toCrId'),
            );

          case 'toCrId':
            _onToSelected(value.toString());

          default:
            _entryVals[key] = value.toString();
        }
      },

      detailBuilder: (ctx) {
        final prov = context.watch<ReportProvider>();
        final config = ReportRegistry.of(
          _toRegistryKey(_activeReportType ?? ''),
        );

        if (config == null || prov.tableData.isEmpty) {
          return const SizedBox.shrink();
        }

        final erpColumns = config.columns.map((c) => c.toErpColumn()).toList();

        // 🔥 LayoutBuilder gives explicit constraints to the table
        return LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight.isFinite
                  ? constraints.maxHeight
                  : 500, // fallback height if parent is unbounded
              child: ErpDataTable(
                key: ValueKey('${_activeReportType}_${prov.tableData.length}'),
                data: prov.tableData,
                columns: erpColumns,
                showSearch: false,
                title: _activeReportType!.isEmpty
                    ? 'REPORT DATA'
                    : _activeReportType!.replaceAll('_', ' '),
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
