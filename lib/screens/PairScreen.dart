import 'package:diam_mfg/providers/PairProvider.dart';
import 'package:diam_mfg/providers/color_provider.dart';
import 'package:diam_mfg/providers/purity_provider.dart';
import 'package:diam_mfg/providers/shape_provider.dart';
import 'package:diam_mfg/services/duplicate_check_service.dart';
import 'package:diam_mfg/services/duplicate_utils.dart';
import 'package:diam_mfg/utils/app_images.dart';
import 'package:diam_mfg/utils/constants.dart';
import 'package:diam_mfg/utils/msg_dialogue.dart';
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
  List<Map<String, dynamic>> _selectedRows = []; // ← ADD
  bool _showTableOnMobile = false;
  bool _isEditMode = false;
  // ── Auth ───────────────────────────────────────────────────────────────────
  final String? token = AppStorage.getString('token');
  List<ErpDropdownItem> _shapeItems = [];
  List<ErpDropdownItem> _colorItems = [];
  List<ErpDropdownItem> _purityItems = [];
  Map<String, dynamic>? _selectedRow;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.wait([
        context.read<PairProvider>().loadPairData(filter: {}),
        context.read<ColorProvider>().load(),
        context.read<ShapeProvider>().load(),
        context.read<PurityProvider>().load(),
      ]);

      final colorProv = context.read<ColorProvider>();
      final shapeProv = context.read<ShapeProvider>();
      final purityProv = context.read<PurityProvider>();

      _shapeItems = shapeProv.list
          .map(
            (e) => ErpDropdownItem(
              label: e.shapeName ?? '',
              value: e.shapeCode?.toString() ?? '',
            ),
          )
          .toList();

      _colorItems = colorProv.list
          .map(
            (e) => ErpDropdownItem(
              label: e.colorName ?? '',
              value: e.colorCode?.toString() ?? '',
            ),
          )
          .toList();

      _purityItems = purityProv.list
          .map(
            (e) => ErpDropdownItem(
              label: e.purityName ?? '',
              value: e.purityCode?.toString() ?? '',
            ),
          )
          .toList();

      if (mounted) setState(() {});
    });
  }

  // ── ADD: called when Save/Print is tapped ─────────
  Future<void> _onSaveSelected() async {

    if (_formValues['pairName'] == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter pair name.')));
      return;
    } else if (_selectedRows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one row.')),
      );
      return;
    } else {
      final exists = await _checkDuplicate(
        fields: {'PairName': _formValues['pairName']},
      );
      if (exists) return;
      final selectedBCodes = _selectedRows
          .map((e) => int.tryParse(e['bCode'].toString()) ?? 0)
          .where((e) => e > 0)
          .toList();
      bool success = false;
      if (_isEditMode){
        final pairMstId =
            int.tryParse(
              _selectedRow!['PairMstID']
                  .toString(),
            ) ??
                0;

        success = await context.read<PairProvider>().updatePair(
          pairMstID: pairMstId,
          pairName: _formValues['pairName'] ?? '',
          bCodes: selectedBCodes,
        );
      }else{
         success = await context.read<PairProvider>().savePair(
          pairName: _formValues['pairName'] ?? '',
          bCodes: selectedBCodes,
        );
      }

      if (success) {
        _formValues['pairName'] = '';
        _erpFormKey.currentState?.updateFieldValue('pairName', '');
        await ErpResultDialog.showSuccess(
          context: context,
          theme: _theme,
          title: 'Saved',
          message: 'Pair saved and packets updated successfully',
        );
        await context.read<PairProvider>().loadPairData(filter: _buildFilter());
      }
    }
  }

  List<List<ErpFieldConfig>> _buildFormRows() {
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
          dropdownItems: _shapeItems,
          sectionIndex: 0,
        ),
        ErpFieldConfig(
          key: 'colorCode',
          label: 'COLOR',
          type: ErpFieldType.dropdown,
          dropdownItems: _colorItems,
          sectionIndex: 0,
        ),
        ErpFieldConfig(
          key: 'purityCode',
          label: 'PURITY',
          type: ErpFieldType.dropdown,
          dropdownItems: _purityItems,
          sectionIndex: 0,
        ),
        ErpFieldConfig(
          key: 'pairName',
          label: 'PAIR NAME',
          type: ErpFieldType.text,
          sectionIndex: 0,
          isEntryRequired: true,
          isEntryField: true,
            inputFormatters: [UpperCaseTextFormatter()],
            onDuplicateCheck: (value, allValues) async {
              return await _checkDuplicate(
                fields: {'PairName': value},
              );
            },
          readOnly: _selectedRows.isEmpty
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
          key: 'fromDiam',
          label: 'FROM DIA',
          type: ErpFieldType.amount,
          sectionIndex: 1,
        ),
        ErpFieldConfig(
          key: 'toDiam',
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

  Future<bool> _checkDuplicate({
    required Map<dynamic, dynamic> fields,
  }) async {
    /// ── SKIP SAME VALUE IN EDIT ───────────────
    final skip = shouldSkipDuplicateCheck(
      isEditMode: _isEditMode,
      selectedRow: _selectedRow,
      newFields: Map<String, dynamic>.from(fields),
      fieldMapping: {'PairName': 'PairName'},
    );

    if (skip) {
      return false;
    }

    /// ── API CHECK ─────────────────────────────
    return await checkDuplicateRecord(
      context: context,
      theme: _theme,
      formName: 'Pair',
      fields: fields,
    );
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

  Future<void> _onSearch() async {
    final prov = context.read<PairProvider>();
    await prov.loadSearchListData();
    setState(() => _showTableOnMobile = true);
  }

  Future<void> _resetForm() async {
    _erpFormKey.currentState?.resetForm();

    _entryVals.clear();

    setState(() {
      _formValues.clear();

      _selectedRows.clear();

      _selectedRow = null;

      _isEditMode = false;
    });

    await context.read<PairProvider>().loadPairData(
      filter: {},
    );
  }

  Map<String, dynamic> _buildFilter() {
    final filter = <String, dynamic>{};

    // DROPDOWNS
    if ((_formValues['shapeCode'] ?? '').isNotEmpty) {
      filter['ShapeCode'] = int.tryParse(_formValues['shapeCode']!);
    }

    if ((_formValues['colorCode'] ?? '').isNotEmpty) {
      filter['ColorCode'] = int.tryParse(_formValues['colorCode']!);
    }

    if ((_formValues['purityCode'] ?? '').isNotEmpty) {
      filter['PurityCode'] = int.tryParse(_formValues['purityCode']!);
    }

    // WEIGHT
    if ((_formValues['fromWeight'] ?? '').isNotEmpty) {
      filter['fromWt'] = _formValues['fromWeight'];
    }

    if ((_formValues['toWeight'] ?? '').isNotEmpty) {
      filter['toWt'] = _formValues['toWeight'];
    }

    // DIAM
    if ((_formValues['fromDiam'] ?? '').isNotEmpty) {
      filter['fromDiam'] = _formValues['fromDiam'];
    }

    if ((_formValues['toDiam'] ?? '').isNotEmpty) {
      filter['toDiam'] = _formValues['toDiam'];
    }

    // LENGTH
    if ((_formValues['fromLength'] ?? '').isNotEmpty) {
      filter['fromLength'] = _formValues['fromLength'];
    }

    if ((_formValues['toLength'] ?? '').isNotEmpty) {
      filter['toLength'] = _formValues['toLength'];
    }

    // HEIGHT
    if ((_formValues['fromHeight'] ?? '').isNotEmpty) {
      filter['fromHeight'] = _formValues['fromHeight'];
    }

    if ((_formValues['toHeight'] ?? '').isNotEmpty) {
      filter['toHeight'] = _formValues['toHeight'];
    }

    return filter;
  }

  Future<void> _onRowTap(
      Map<String, dynamic> row,
      ) async {
    _selectedRow = row;
    _isEditMode = true;
    print(row);
    final pairMstId =
        int.tryParse(
          row['PairMstID']?.toString() ?? '0',
        ) ??
            0;

    await context.read<PairProvider>().loadPairData(
      filter: _buildFilter(),
      pairMstId: pairMstId,
    );

    final prov = context.read<PairProvider>();

    // AUTO SELECT SAME PAIR RECORDS
    _selectedRows = prov.tableData.where((e) {
      return e['PairMstID'] == pairMstId;
    }).toList();
    _formValues['pairName'] = row['PairName'] ?? '';
    _erpFormKey.currentState?.updateFieldValue('pairName', row['PairName'] ?? '');
    if (mounted) {
      setState(() {
        _showTableOnMobile = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PairProvider>(
      builder: (ctx, prov, _) => Padding(
        padding: const EdgeInsets.all(8),
        child: Responsive.isMobile(context)
            ? (_showTableOnMobile ? _buildTable() : _buildForm(context, prov))
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!_showTableOnMobile)
                    Expanded(flex: 2, child: _buildForm(context, prov)),
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
      isShowSaveButton: true,
      isEditMode: _isEditMode,
      isShowSearch: true,
      onFieldChanged: (key, value) async {
        _formValues[key] = value.toString();

        final dropdownFields = ['shapeCode', 'colorCode', 'purityCode'];

        if (!dropdownFields.contains(key)) return;

        await context.read<PairProvider>().loadPairData(filter: _buildFilter());
      },
      onFieldSubmitted: (key, value) async {
        _formValues[key] = value.toString();
        if (key != 'pairName') {
          await context.read<PairProvider>().loadPairData(
            filter: _buildFilter(),
          );
        }
      },
      onSave: (_) => _onSaveSelected(),
      // ← ADD: wire save to selected rows
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
                showCheckBox: true,
                selectedRowsCheckBox: _selectedRows,
                // ← ADD
                onSelectionChanged: (rows) {
                  // ← ADD
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
    return ErpDataTable(
      isReportRow: false,
      token: token ?? '',
      url: '',
      title: 'PAIR ENTRY',
      columns: prov.columns,
      onClose: () {
        setState(() => _showTableOnMobile = false);
      },
      data: prov.tableSearchListData,
      showSearch: true,
      selectedRow: _selectedRow,
      onRowTap: _onRowTap,
      emptyMessage: prov.isLoaded ? 'No entries found' : 'Loading...',
    );
  }
}
