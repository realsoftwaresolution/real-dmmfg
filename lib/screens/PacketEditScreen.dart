import 'package:diam_mfg/providers/PacketEdit_provider.dart';
import 'package:diam_mfg/utils/app_images.dart';
import 'package:diam_mfg/utils/msg_dialogue.dart';
import 'package:erp_data_table/erp_data_table.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rs_dashboard/rs_dashboard.dart';

class PacketEditScreen extends StatefulWidget {
  const PacketEditScreen({super.key});

  @override
  State<PacketEditScreen> createState() => _PacketEditScreenState();
}

// ─────────────────────────────────────────────────────────────────────────────
//  STATE
// ─────────────────────────────────────────────────────────────────────────────

class _PacketEditScreenState extends State<PacketEditScreen> {
  // ── Theme ──────────────────────────────────────────────────────────────────
  final ErpThemeVariant _themeVariant = ErpThemeVariant.frost;

  ErpTheme get _theme => ErpTheme(_themeVariant);
  Map<String, dynamic>? selectedRow;

  // ── Form ───────────────────────────────────────────────────────────────────
  GlobalKey<ErpFormState> _erpFormKey = GlobalKey<ErpFormState>();
  Map<String, String> _formValues = {};
  final Map<String, String> _entryVals = {};
  bool _isRowEditMode = false;
  void _showSnack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  // ── Auth ───────────────────────────────────────────────────────────────────
  final String? token = AppStorage.getString('token');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _resetForm();
    });
  }

  List<List<ErpFieldConfig>> _buildFormRows() {
    // ─────────────────────────────────────────────────────────────────────
    //  MASTER SECTION (sectionIndex 0)
    // ─────────────────────────────────────────────────────────────────────
    final List<List<ErpFieldConfig>> rows = [
      [
        /// ── BCODE FIELD ─────────────────────────
        ErpFieldConfig(
          key: 'bCode',
          label: 'BCODE',
          type: ErpFieldType.number,
          sectionIndex: 0,
          width: 200,
        ),
        ErpFieldConfig(
          key: 'qrCode',
          label: 'QR CODE',
          type: ErpFieldType.number,
          sectionIndex: 0,
          readOnly: true,
          width: 200,
        ),
        ErpFieldConfig(
          key: 'cutNo',
          label: 'CUT NO',
          type: ErpFieldType.number,
          sectionIndex: 0,
          readOnly: true,
          width: 200,
        ),
        ErpFieldConfig(
          key: 'clv Cut',
          label: 'CLV CUT',
          type: ErpFieldType.number,
          sectionIndex: 0,
          readOnly: true,
          width: 200,
        ),
        ErpFieldConfig(
          key: 'pktNo',
          label: 'PKT NO',
          type: ErpFieldType.number,
          sectionIndex: 0,
          readOnly: true,
          width: 200,
        ),
        ErpFieldConfig(
          key: 'remarks',
          label: 'REMARKS',
          type: ErpFieldType.text,
          sectionIndex: 0,
        ),
      ],
      [
        ErpFieldConfig(
          key: 'ghatWt',
          label: 'GHAT WT',
          type: ErpFieldType.amount,
          readOnly: true,
          isEntryField: true,
          sectionIndex: 1,
          flex: 1,
        ),
        ErpFieldConfig(
          key: 'pc',
          label: 'PC',
          type: ErpFieldType.number,
          readOnly: true,
          isEntryField: true,
          sectionIndex: 1,
          flex: 1,
        ),
        ErpFieldConfig(
          key: 'wt',
          label: 'WT',
          type: ErpFieldType.amount,
          readOnly: true,
          sectionIndex: 1,
          flex: 1,
        ),
        ErpFieldConfig(
          key: 'issPc',
          label: 'ISS PC',
          type: ErpFieldType.number,
          readOnly: true,
          sectionIndex: 1,
          flex: 1,
        ),
        ErpFieldConfig(
          key: 'issWt',
          label: 'ISS WT',
          type: ErpFieldType.amount,
          readOnly: true,
          sectionIndex: 1,
          flex: 1,
        ),
        ErpFieldConfig(
          key: 'recPc',
          label: 'REC PC',
          type: ErpFieldType.number,
          readOnly: !_isRowEditMode,
          sectionIndex: 1,
          flex: 1,
        ),
        ErpFieldConfig(
          key: 'recWt',
          label: 'REC WT',
          type: ErpFieldType.amount,
          readOnly: !_isRowEditMode,
          sectionIndex: 1,
          flex: 1,
        ),
        ErpFieldConfig(
          key: 'dmWt',
          label: 'DM WT',
          type: ErpFieldType.amount,
          sectionIndex: 1,
          flex: 1,
          readOnly: true,
        ),
        ErpFieldConfig(
          key: 'dmPer',
          label: 'DM PER',
          type: ErpFieldType.amount,
          sectionIndex: 1,
          flex: 1,
          readOnly: true,
        ),
        ErpFieldConfig(
          key: 'topsPc',
          label: 'TOPS PC',
          readOnly: true,
          type: ErpFieldType.number,
          sectionIndex: 1,
          flex: 1,
        ),
        ErpFieldConfig(
          key: 'topsWt',
          label: 'TOPS WT',
          readOnly: true,
          type: ErpFieldType.amount,
          sectionIndex: 1,
          flex: 1,
        ),
        ErpFieldConfig(
          key: 'kPc',
          label: 'K PC',
          type: ErpFieldType.number,
          readOnly: !_isRowEditMode,
          sectionIndex: 1,
          flex: 1,
        ),
        ErpFieldConfig(
          key: 'kWt',
          label: 'K WT',
          type: ErpFieldType.amount,
          readOnly: !_isRowEditMode,
          sectionIndex: 1,
          flex: 1,
        ),
        ErpFieldConfig(
          key: 'brPc',
          label: 'BR PC',
          readOnly: !_isRowEditMode,
          type: ErpFieldType.number,
          sectionIndex: 1,
          flex: 1,
        ),
        ErpFieldConfig(
          key: 'brWt',
          label: 'BR WT',
          readOnly: !_isRowEditMode,
          type: ErpFieldType.amount,
          sectionIndex: 1,
          flex: 1,
        ),
        ErpFieldConfig(
          key: 'lossPc',
          label: 'LOSS PC',
          type: ErpFieldType.number,
          readOnly: true,
          sectionIndex: 1,
          flex: 1,
        ),
        ErpFieldConfig(
          key: 'lossWt',
          label: 'LOSS WT',
          type: ErpFieldType.amount,
          readOnly: true,
          sectionIndex: 1,
          flex: 1,
        ),
        ErpFieldConfig(
          key: 'crossPc',
          label: 'CROSS PC',
          type: ErpFieldType.number,
          readOnly: !_isRowEditMode,
          sectionIndex: 1,
          flex: 1,
        ),
        ErpFieldConfig(
          key: 'pelPc',
          label: 'PEL PC',
          type: ErpFieldType.number,
          readOnly: !_isRowEditMode,
          sectionIndex: 1,
          flex: 1,
        ),
        ErpFieldConfig(
          key: 'repPc',
          label: 'REP PC',
          type: ErpFieldType.number,
          readOnly: !_isRowEditMode,
          sectionIndex: 1,
          flex: 1,
        ),
        ErpFieldConfig(
          key: 'sarinMistake',
          label: 'SARIN MIST',
          type: ErpFieldType.number,
          readOnly: !_isRowEditMode,
          sectionIndex: 1,
          flex: 1,
        ),
        ErpFieldConfig(
          key: 'totalPc',
          label: 'TOTAL PC',
          type: ErpFieldType.number,
          readOnly: true,
          sectionIndex: 1,
          flex: 1,
        ),
        ErpFieldConfig(
          key: 'totalWt',
          label: 'TOTAL WT',
          type: ErpFieldType.number,
          readOnly: true,
          sectionIndex: 1,
          flex: 1,
          showAddButton: true,
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

  Future<void> _onSave(Map<String, dynamic> values) async {
    final prov = context.read<PacketEditProvider>();

    final rowIndex = prov.tableData.indexWhere(
      (e) =>
          e['MstID'] == selectedRow?['MstID'] &&
          e['DetID'] == selectedRow?['DetID'],
    );
    if (rowIndex != -1) {
      final updatedRow = Map<String, dynamic>.from(prov.tableData[rowIndex]);
      updatedRow['GhatWt'] =
          double.tryParse(values['ghatWt']?.toString() ?? '') ?? 0.0;
      updatedRow['Pc'] = int.tryParse(values['pc']?.toString() ?? '') ?? 0;
      updatedRow['Wt'] = double.tryParse(values['wt']?.toString() ?? '') ?? 0.0;
      updatedRow['IssPc'] =
          int.tryParse(values['issPc']?.toString() ?? '') ?? 0;
      updatedRow['IssWt'] =
          double.tryParse(values['issWt']?.toString() ?? '') ?? 0.0;
      updatedRow['RecPc'] =
          int.tryParse(values['recPc']?.toString() ?? '') ?? 0;
      updatedRow['RecWt'] =
          double.tryParse(values['recWt']?.toString() ?? '') ?? 0.0;
      updatedRow['DmWt'] =
          double.tryParse(values['dmWt']?.toString() ?? '') ?? 0.0;
      updatedRow['DmPer'] =
          double.tryParse(values['dmPer']?.toString() ?? '') ?? 0.0;
      updatedRow['TopsPc'] =
          int.tryParse(values['topsPc']?.toString() ?? '') ?? 0;
      updatedRow['TopsWt'] =
          double.tryParse(values['topsWt']?.toString() ?? '') ?? 0.0;
      updatedRow['KPc'] = int.tryParse(values['kPc']?.toString() ?? '') ?? 0;
      updatedRow['KWt'] =
          double.tryParse(values['kWt']?.toString() ?? '') ?? 0.0;
      updatedRow['BrPc'] = int.tryParse(values['brPc']?.toString() ?? '') ?? 0;
      updatedRow['BrWt'] =
          double.tryParse(values['brWt']?.toString() ?? '') ?? 0.0;
      updatedRow['LossPc'] =
          int.tryParse(values['lossPc']?.toString() ?? '') ?? 0;
      updatedRow['LossWt'] =
          double.tryParse(values['lossWt']?.toString() ?? '') ?? 0.0;
      updatedRow['CrossPc'] =
          int.tryParse(values['crossPc']?.toString() ?? '') ?? 0;
      updatedRow['PelPc'] =
          int.tryParse(values['pelPc']?.toString() ?? '') ?? 0;
      updatedRow['RepPc'] =
          int.tryParse(values['repPc']?.toString() ?? '') ?? 0;
      updatedRow['SarinMistake'] =
          double.tryParse(values['sarinMistake']?.toString() ?? '') ?? 0.0;
      updatedRow['TotalPc'] =
          int.tryParse(values['totalPc']?.toString() ?? '') ?? 0;
      updatedRow['TotalWt'] =
          double.tryParse(values['totalWt']?.toString() ?? '') ?? 0.0;

      prov.tableData[rowIndex] = updatedRow;
    }

    bool result = await prov.savePacketEditApi(payload: prov.tableData);
    if (!mounted) return;

    if (result) {
      _resetForm();
      await ErpResultDialog.showSuccess(
        context: context,
        theme: _theme,
        title: 'Saved',
        message: 'Packet edit details saved successfully.',
      );
    } else {
      ErpResultDialog.showError(
        context: context,
        theme: _theme,
        title: 'Error',
        message: prov.error ?? 'Failed to save packet edit details.',
      );
    }
  }

  void _onAddEntry() {
    if (selectedRow == null) {
      ErpResultDialog.showError(
        context: context,
        theme: _theme,
        title: 'Error',
        message: 'Please select a row from the data table to edit.',
      );
      return;
    }

    final prov = context.read<PacketEditProvider>();

    final rowIndex = prov.tableData.indexWhere(
      (e) =>
          e['MstID'] == selectedRow?['MstID'] &&
          e['DetID'] == selectedRow?['DetID'],
    );

    if (rowIndex == -1) return;

    final originalRow = prov.tableData[rowIndex];
    final originalRecWtStr = originalRow['RecWt']?.toString() ?? '0.000';
    final originalIssWtStr = originalRow['IssWt']?.toString() ?? '0.000';

    final newRecWtStr = _formValues['recWt'] ?? originalRecWtStr;
    final newIssWtStr = _formValues['issWt'] ?? originalIssWtStr;

    final originalRecWt = double.tryParse(originalRecWtStr) ?? 0.0;
    final originalIssWt = double.tryParse(originalIssWtStr) ?? 0.0;
    final newRecWt = double.tryParse(newRecWtStr) ?? 0.0;
    final newIssWt = double.tryParse(newIssWtStr) ?? 0.0;

    final isRecWtChanged = (newRecWt - originalRecWt).abs() > 0.0001;
    final isIssWtChanged = (newIssWt - originalIssWt).abs() > 0.0001;

    String d(double value) => value.toStringAsFixed(3);

    final updatedTableData = List<Map<String, dynamic>>.from(prov.tableData);

      for (int i = rowIndex; i < updatedTableData.length; i++) {
        final row = Map<String, dynamic>.from(updatedTableData[i]);

        if (i == rowIndex) {
          row['GhatWt'] = d(double.tryParse(_formValues['ghatWt']?.toString() ?? '') ?? double.tryParse(originalRow['GhatWt']?.toString() ?? '') ?? 0.0);
          row['Pc'] = int.tryParse(_formValues['pc']?.toString() ?? '') ?? int.tryParse(originalRow['Pc']?.toString() ?? '') ?? 0;
          row['Wt'] = d(double.tryParse(_formValues['wt']?.toString() ?? '') ?? double.tryParse(originalRow['Wt']?.toString() ?? '') ?? 0.0);
          row['IssPc'] = int.tryParse(_formValues['issPc']?.toString() ?? '') ?? int.tryParse(originalRow['IssPc']?.toString() ?? '') ?? 0;
          row['IssWt'] = d(newIssWt);
          row['RecPc'] = int.tryParse(_formValues['recPc']?.toString() ?? '') ?? int.tryParse(originalRow['RecPc']?.toString() ?? '') ?? 0;
          row['RecWt'] = d(newRecWt);
          row['DmWt'] = d(double.tryParse(_formValues['dmWt']?.toString() ?? '') ?? double.tryParse(originalRow['DmWt']?.toString() ?? '') ?? 0.0);
          row['DmPer'] = d(double.tryParse(_formValues['dmPer']?.toString() ?? '') ?? double.tryParse(originalRow['DmPer']?.toString() ?? '') ?? 0.0);
          row['TopsPc'] = int.tryParse(_formValues['topsPc']?.toString() ?? '') ?? int.tryParse(originalRow['TopsPc']?.toString() ?? '') ?? 0;
          row['TopsWt'] = d(double.tryParse(_formValues['topsWt']?.toString() ?? '') ?? double.tryParse(originalRow['TopsWt']?.toString() ?? '') ?? 0.0);
          row['KPc'] = int.tryParse(_formValues['kPc']?.toString() ?? '') ?? int.tryParse(originalRow['KPc']?.toString() ?? '') ?? 0;
          row['KWt'] = d(double.tryParse(_formValues['kWt']?.toString() ?? '') ?? double.tryParse(originalRow['KWt']?.toString() ?? '') ?? 0.0);
          row['BrPc'] = int.tryParse(_formValues['brPc']?.toString() ?? '') ?? int.tryParse(originalRow['BrPc']?.toString() ?? '') ?? 0;
          row['BrWt'] = d(double.tryParse(_formValues['brWt']?.toString() ?? '') ?? double.tryParse(originalRow['BrWt']?.toString() ?? '') ?? 0.0);
          row['LossPc'] = int.tryParse(_formValues['lossPc']?.toString() ?? '') ?? int.tryParse(originalRow['LossPc']?.toString() ?? '') ?? 0;
          row['LossWt'] = d(double.tryParse(_formValues['lossWt']?.toString() ?? '') ?? double.tryParse(originalRow['LossWt']?.toString() ?? '') ?? 0.0);
          row['CrossPc'] = int.tryParse(_formValues['crossPc']?.toString() ?? '') ?? int.tryParse(originalRow['CrossPc']?.toString() ?? '') ?? 0;
          row['PelPc'] = int.tryParse(_formValues['pelPc']?.toString() ?? '') ?? int.tryParse(originalRow['PelPc']?.toString() ?? '') ?? 0;
          row['RepPc'] = int.tryParse(_formValues['repPc']?.toString() ?? '') ?? int.tryParse(originalRow['RepPc']?.toString() ?? '') ?? 0;
          row['SarinMistake'] = d(double.tryParse(_formValues['sarinMistake']?.toString() ?? '') ?? double.tryParse(originalRow['SarinMistake']?.toString() ?? '') ?? 0.0);
          row['TotalPc'] = int.tryParse(_formValues['totalPc']?.toString() ?? '') ?? int.tryParse(originalRow['TotalPc']?.toString() ?? '') ?? 0;
          row['TotalWt'] = d(double.tryParse(_formValues['totalWt']?.toString() ?? '') ?? double.tryParse(originalRow['TotalWt']?.toString() ?? '') ?? 0.0);
        } else {
          if (isRecWtChanged) {
            row['RecWt'] = d(newRecWt);
          }
          if (isIssWtChanged) {
            row['IssWt'] = d(newIssWt);
          }
        }

        updatedTableData[i] = row;
      }

      setState(() {
        selectedRow = null;
        _isRowEditMode = false;
      });

      prov.updateTableData(updatedTableData);

    final entryKeys = [
      'ghatWt', 'pc', 'wt', 'issPc', 'issWt', 'recPc', 'recWt', 'dmWt', 'dmPer',
      'topsPc', 'topsWt', 'kPc', 'kWt', 'brPc', 'brWt', 'lossPc', 'lossWt',
      'crossPc', 'pelPc', 'repPc', 'sarinMistake', 'totalPc', 'totalWt'
    ];
    for (final key in entryKeys) {
      _formValues.remove(key);
    }

    for (final key in entryKeys) {
      _erpFormKey.currentState?.updateFieldValue(key, '');
    }

    _erpFormKey.currentState?.focusField('bCode');
  }

  void _resetForm() {
    _erpFormKey.currentState?.resetForm();
    _entryVals.clear();
    final prov = context.read<PacketEditProvider>();
    prov.clear();
    setState(() {
      _formValues.clear();
      _isRowEditMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PacketEditProvider>(
      builder: (ctx, prov, _) => Padding(
        padding: const EdgeInsets.all(8),
        child: _buildForm(context, prov),
      ),
    );
  }

  Widget _buildForm(BuildContext context, PacketEditProvider prov) {
    return ErpForm(
      logo: AppImages.logo,
      key: _erpFormKey,
      title: 'PACKET EDIT',
      rows: _buildFormRows(),
      addButtonSections: const {1},
      initialValues: _formValues,
      autoStartAdding: true,
      onCancel: _resetForm,
      isEditMode: false,
      isShowSearch: false,
      isShowSaveButton: true,
      onSave: _onSave,
      onEntryAdd: (sectionIndex) {
        if (sectionIndex == 1) {
          _onAddEntry();
        }
      },
      onFieldSubmitted: (key, value) async {
        final scanVal = value.toString().trim();
        if (key == 'bCode') {
          if (scanVal.isEmpty) {
            _showSnack('Please enter BCode');
            _erpFormKey.currentState?.focusField('bCode');
            return;
          }
          final prov = context.read<PacketEditProvider>();
          final data = await prov.scanBcodeWiseData(bCode: scanVal);

          if (data != null) {
            _formValues.addAll({
              'cutNo': data['CutNo']?.toString() ?? '',
              'clv Cut': data['ClvCut']?.toString() ?? '',
              'pktNo': data['PktNo']?.toString() ?? '',
              'remarks': data['RemarksName']?.toString() ?? '',
            });

            _erpFormKey.currentState?.updateFieldValue(
              'cutNo',
              data['CutNo']?.toString() ?? '',
            );

            _erpFormKey.currentState?.updateFieldValue(
              'clv Cut',
              data['ClvCut']?.toString() ?? '',
            );

            _erpFormKey.currentState?.updateFieldValue(
              'pktNo',
              data['PktNo']?.toString() ?? '',
            );

            _erpFormKey.currentState?.updateFieldValue(
              'remarks',
              data['RemarksName']?.toString() ?? '',
            );
          } else {
            ErpResultDialog.showError(
              context: context,
              theme: _theme,
              title: 'BCode',
              message: 'No packet details found for BCode: $scanVal',
            );
            _entryVals['scanValue'] = '';
            _erpFormKey.currentState?.updateFieldValue('bCode', '');
            Future.delayed(
              const Duration(milliseconds: 100),
              () => _erpFormKey.currentState?.focusField('bCode'),
            );
          }
        }
        if (key == 'remarks') {
          return;
        }
      },
      onFieldChanged: (key, value) {
        _formValues[key] = value.toString();
        switch (key) {
          default:
            _entryVals[key] = value.toString();
        }
      },
      detailBuilder: (ctx) {
        final prov = context.watch<PacketEditProvider>();
        if (prov.tableData.isEmpty) {
          return const SizedBox.shrink();
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            final screenHeight = MediaQuery.of(context).size.height;
            final isMobile = Responsive.isMobile(context);
            final double subtractHeight = isMobile ? 340.0 : 210.0;
            final dynamicHeight = (screenHeight - subtractHeight).clamp(
              450.0,
              1500.0,
            );
            return SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight.isFinite
                  ? constraints.maxHeight
                  : dynamicHeight,
              child: ErpDataTable(
                key: ValueKey('${prov.tableData.length}'),
                data: prov.tableData,
                columns: prov.columns,
                showSearch: false,
                title: 'PACKET EDIT ENTRY',
                token: '',
                url: '',
                isReportRow: false,
                showFooterTotals: true,
                selectedRow: selectedRow,
                onRowTap: (row) async {
                  setState(() {
                    selectedRow = row;
                  });
                  final prov = context.read<PacketEditProvider>();

                  final rowIndex = prov.tableData.indexWhere(
                    (e) =>
                        e['MstID'] == row['MstID'] &&
                        e['DetID'] == row['DetID'],
                  );

                  await _showEditPopup(context, rowIndex);
                },
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showEditPopup(BuildContext context, int rowIndex) async {
    final prov = context.read<PacketEditProvider>();
    final isYes = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Edit Confirmation'),
          content: Text('Are You Sure You Want To Edit?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Edit'),
            ),
          ],
        );
      },
    );

    if (isYes != true) return;
    setState(() {
      _isRowEditMode = true;
    });
    final rowData = prov.tableData[rowIndex];
    _formValues.addAll({
      'ghatWt': rowData['GhatWt']?.toString() ?? '',
      'pc': rowData['Pc']?.toString() ?? '',
      'wt': rowData['Wt']?.toString() ?? '',
      'issPc': rowData['IssPc']?.toString() ?? '',
      'issWt': rowData['IssWt']?.toString() ?? '',
      'recPc': rowData['RecPc']?.toString() ?? '',
      'recWt': rowData['RecWt']?.toString() ?? '',
      'dmWt': rowData['DmWt']?.toString() ?? '',
      'dmPer': rowData['DmPer']?.toString() ?? '',
      'topsPc': rowData['TopsPc']?.toString() ?? '',
      'topsWt': rowData['TopsWt']?.toString() ?? '',
      'kPc': rowData['KPc']?.toString() ?? '',
      'kWt': rowData['KWt']?.toString() ?? '',
      'brPc': rowData['BrPc']?.toString() ?? '',
      'brWt': rowData['BrWt']?.toString() ?? '',
      'lossPc': rowData['LossPc']?.toString() ?? '',
      'lossWt': rowData['LossWt']?.toString() ?? '',
      'crossPc': rowData['CrossPc']?.toString() ?? '',
      'pelPc': rowData['PelPc']?.toString() ?? '',
      'repPc': rowData['RepPc']?.toString() ?? '',
      'sarinMistake': rowData['SarinMistake']?.toString() ?? '',
      'totalPc': rowData['TotalPc']?.toString() ?? '',
      'totalWt': rowData['TotalWt']?.toString() ?? '',
    });
    _formValues.forEach((key, value) {
      _erpFormKey.currentState?.updateFieldValue(key, value);
    });
    setState(() {});

    /// set row data on section 1 row field
    if (!mounted) return;
  }
}
