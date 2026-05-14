import 'package:diam_mfg/providers/PacketEdit_provider.dart';
import 'package:diam_mfg/utils/app_images.dart';
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

  void _showSnack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  // ── Auth ───────────────────────────────────────────────────────────────────
  final String? token = AppStorage.getString('token');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _resetForm();
      // await Future.wait([context.read<RemarksProvider>().load()]);
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
          sectionIndex: 1,
          flex: 1,
        ),
        ErpFieldConfig(
          key: 'recWt',
          label: 'REC WT',
          type: ErpFieldType.amount,
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
          type: ErpFieldType.number,
          sectionIndex: 1,
          flex: 1,
        ),
        ErpFieldConfig(
          key: 'topsWt',
          label: 'TOPS WT',
          type: ErpFieldType.amount,
          sectionIndex: 1,
          flex: 1,
        ),
        ErpFieldConfig(
          key: 'kPc',
          label: 'K PC',
          type: ErpFieldType.number,
          sectionIndex: 1,
          flex: 1,
        ),
        ErpFieldConfig(
          key: 'kWt',
          label: 'K WT',
          type: ErpFieldType.amount,
          sectionIndex: 1,
          flex: 1,
        ),
        ErpFieldConfig(
          key: 'brPc',
          label: 'BR PC',
          type: ErpFieldType.number,
          sectionIndex: 1,
          flex: 1,
        ),
        ErpFieldConfig(
          key: 'brWt',
          label: 'BR WT',
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
          readOnly: true,
          sectionIndex: 1,
          flex: 1,
        ),
        ErpFieldConfig(
          key: 'pelPc',
          label: 'PEL PC',
          type: ErpFieldType.number,
          readOnly: true,
          sectionIndex: 1,
          flex: 1,
        ),
        ErpFieldConfig(
          key: 'repPc',
          label: 'REP PC',
          type: ErpFieldType.number,
          readOnly: true,
          sectionIndex: 1,
          flex: 1,
        ),
        ErpFieldConfig(
          key: 'sarinMistake',
          label: 'SARIN MIST',
          type: ErpFieldType.number,
          readOnly: true,
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

  // ── In _PacketEditScreenState ─────────────────────────────────────

  Future<void> _onSearch() async {
    final prov = context.read<PacketEditProvider>();

    final filter = {"bcode": _formValues['bCode']};

    await prov.loadPacketEditList(filter: filter);
  }

  void _resetForm() {
    _erpFormKey.currentState?.resetForm();
    _entryVals.clear();
    final prov = context.read<PacketEditProvider>();
    prov.clear();
    setState(() {
      _formValues.clear();
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
      onCancel: _resetForm,
      isEditMode: false,
      isShowSearch: false,
      onSave: (val) {},
      onEntryAdd: (val) {
        print(val);
      },
      onFieldSubmitted: (key, value) async {
        final scanVal = value.toString().trim();
        if (key == 'bCode') {
          if (scanVal.isEmpty) {
            _showSnack('Please enter BCode');
            _erpFormKey.currentState?.focusField('bCode');
            return;
          }
          await _onSearch();
          return;
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
                        e['DetId'] == row['DetId'],
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
