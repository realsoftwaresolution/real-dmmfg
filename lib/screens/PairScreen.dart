import 'package:diam_mfg/providers/PairProvider.dart';
import 'package:diam_mfg/providers/color_provider.dart';
import 'package:diam_mfg/providers/purity_provider.dart';
import 'package:diam_mfg/providers/shape_provider.dart';
import 'package:diam_mfg/utils/app_images.dart';
import 'package:erp_data_table/erp_data_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rs_dashboard/rs_dashboard.dart';

class PairScreen extends StatefulWidget {
  const PairScreen({super.key});

  @override
  State<PairScreen> createState() => _PairScreenState();
}

// ─────────────────────────────────────────────────────────────────────────────
//  STATE
// ─────────────────────────────────────────────────────────────────────────────

class _PairScreenState extends State<PairScreen> {
  // ── Theme ──────────────────────────────────────────────────────────────────
  final ErpThemeVariant _themeVariant = ErpThemeVariant.frost;

  ErpTheme get _theme => ErpTheme(_themeVariant);

  // ── Form ───────────────────────────────────────────────────────────────────
  GlobalKey<ErpFormState> _erpFormKey = GlobalKey<ErpFormState>();
  Map<String, String> _formValues = {};
  final Map<String, String> _entryVals = {};
  List<Map<String, dynamic>> _selectedRows = [];   // ← ADD
  bool _showTableOnMobile = false;

  // ── Auth ───────────────────────────────────────────────────────────────────
  final String? token = AppStorage.getString('token');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.wait([
        context.read<ColorProvider>().load(),
        context.read<ShapeProvider>().load(),
        context.read<PurityProvider>().load(),
      ]);
    });
  }
// ── ADD: called when Save/Print is tapped ─────────
  void _onSaveSelected() {
    if (_selectedRows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one row.'),
        ),
      );
      return;
    }
  }

  List<List<ErpFieldConfig>> _buildFormRows() {
    final colorProv = context.read<ColorProvider>();
    final shapeProv = context.read<ShapeProvider>();
    final purityProv = context.read<PurityProvider>();
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

    // ─────────────────────────────────────────────────────────────────────
    //  MASTER SECTION (sectionIndex 0)
    // ─────────────────────────────────────────────────────────────────────
    final List<List<ErpFieldConfig>> rows = [
      // Row 1
      [
        ErpFieldConfig(
          key: 'shapeCode',
          label: 'SHAPE',
          type: ErpFieldType.dropdown,
          dropdownItems: shapeItems,
          sectionIndex: 0,
          required: true
        ),
        ErpFieldConfig(
          key: 'colorCode',
          label: 'COLOR',
          type: ErpFieldType.dropdown,
          dropdownItems: colorItems,
          sectionIndex: 0,
          required: true
        ),
        ErpFieldConfig(
          key: 'purityCode',
          label: 'PURITY',
          type: ErpFieldType.dropdown,
          dropdownItems: purityItems,
          sectionIndex: 0,
        ),
        ErpFieldConfig(
          key: 'fromWeight',
          label: 'FROM WEIGHT',
          type: ErpFieldType.amount,
          sectionIndex: 0,
        ),
        ErpFieldConfig(
          key: 'toWeight',
          label: 'TO WEIGHT',
          type: ErpFieldType.amount,
          sectionIndex: 0,
        ),
      ],
      // Row 2
      [
        ErpFieldConfig(
          key: 'fromDia',
          label: 'FROM DIA',
          type: ErpFieldType.amount,
          sectionIndex: 1,
        ),
        ErpFieldConfig(
          key: 'toDia',
          label: 'TO DIA',
          type: ErpFieldType.amount,
          sectionIndex: 1,
        ),
        ErpFieldConfig(
          key: 'fromLength',
          label: 'FROM LENGTH',
          type: ErpFieldType.number,
          sectionIndex: 1,
        ),
        ErpFieldConfig(
          key: 'toLength',
          label: 'TO LENGTH',
          type: ErpFieldType.number,
          sectionIndex: 1,
        ),
        ErpFieldConfig(
          key: 'fromWidth',
          label: 'FROM WIDTH',
          type: ErpFieldType.amount,
          sectionIndex: 1,
        ),
        ErpFieldConfig(
          key: 'toWidth',
          label: 'TO WIDTH',
          type: ErpFieldType.amount,
          sectionIndex: 1,
        ),
        ErpFieldConfig(
          key: 'fromHeight',
          label: 'FROM HEIGHT',
          type: ErpFieldType.amount,
          sectionIndex: 1,
        ),
        ErpFieldConfig(
          key: 'toHeight',
          label: 'TO HEIGHT',
          type: ErpFieldType.amount,
          sectionIndex: 1,
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

  // ── In _PairScreenState ─────────────────────────────────────

  /// "Rough Detail" → "ROUGH_DETAIL"
  String _toRegistryKey(String reportName) =>
      reportName.trim().toUpperCase().replaceAll(' ', '_');

  Future<void> _onSearch() async {
    final prov = context.read<PairProvider>();

    final filter = {
      "purityCode": int.tryParse(_formValues['purityCode'] ?? ''),
      "colorCode": int.tryParse(_formValues['colorCode'] ?? ''),
      "shapeCode": int.tryParse(_formValues['shapeCode'] ?? ''),
      "fromWeight": _formValues['fromWeight'] ?? '',
      "toWeight": _formValues['toWeight'] ?? '',
      "fromDia": _formValues['fromDia'],
      "toDia": _formValues['toDia'],
      "fromLength": _formValues['fromLength'],
      "toLength": _formValues['toLength'],
      "fromWidth": _formValues['fromWidth'],
      "toWidth": _formValues['toWidth'],
      "fromHeight": _formValues['fromHeight'],
      "toHeight": _formValues['toHeight'],
    };
    await prov.loadPairData( filter: filter);
    setState(() => _showTableOnMobile = true);
  }

  void _resetForm() {
    _erpFormKey.currentState?.resetForm();
    _entryVals.clear();
    final prov = context.read<PairProvider>();
    prov.clear();
    setState(() {
      // _erpFormKey = GlobalKey<ErpFormState>();
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
    return Consumer<PairProvider>(
      builder: (ctx, prov, _) => Padding(
        padding: const EdgeInsets.all(8),
        child: Responsive.isMobile(context)
            ? (_showTableOnMobile ? _buildTable() : _buildForm(context,prov))
            : Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_showTableOnMobile)
              Expanded(flex: 2, child: _buildForm(context,prov)),
            if (_showTableOnMobile)
              Expanded(flex: 2, child: _buildTable()),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, PairProvider prov) {
    return ErpForm(
      logo: AppImages.logo,
      key: _erpFormKey,
      title: 'PAIR',
      rows: _buildFormRows(),
      initialValues: _formValues,
      onCancel: _resetForm,
      onSearch: _onSearch,
      isShowSaveButton: true,                      // ← show save button
      isEditMode: false,
      isShowSearch: true,
      onFieldChanged: (key, value) {
        _formValues[key] = value.toString();
        switch (key) {
          default:
            _entryVals[key] = value.toString();
        }
      },
      onSave: (_) => _onSaveSelected(),            // ← ADD: wire save to selected rows

      detailBuilder: (ctx) {
        final prov = context.watch<PairProvider>();
        if (prov.tableData.isEmpty) {
          return const SizedBox.shrink();
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight.isFinite
                  ? constraints.maxHeight
                  : 570,
              child: ErpDataTable(
                key: ValueKey('${prov.tableData.length}'),
                data: prov.tableData,
                columns: prov.columns,
                showSearch: false,
                title: 'PAIR ENTRY',
                token: '',
                url: '',
                isReportRow: false,
                showFooterTotals: true,
                showCheckBox: true,                // ← ADD
                onSelectionChanged: (rows) {       // ← ADD
                  setState(() => _selectedRows = rows);
                },
              ),
            );
          },
        );
      },
    );
  }





  // ─────────────────────────────────────────────────────────────────────────
  //  TABLE WIDGET
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildTable() {
    final prov = context.watch<PairProvider>();
    if (prov.tableData.isEmpty) {
      return const SizedBox.shrink();
    }
    return ErpDataTable(
      isReportRow: false,
      token: token ?? '',
      url: '',
      title: 'PAIR ENTRY',
      columns: prov.columns,
      data: prov.tableData,
      showSearch: true,
      dateFilter: true,
      // selectedRow: _selectedRow,
      // onRowTap: _onRowTap,
      emptyMessage: prov.isLoaded ? 'No entries found' : 'Loading...',
    );
  }
}
