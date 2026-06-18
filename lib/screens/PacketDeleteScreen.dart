import 'package:diam_mfg/providers/PacketDelete_provider.dart';
import 'package:diam_mfg/providers/remarks_provider.dart';
import 'package:diam_mfg/utils/app_images.dart';
import 'package:erp_data_table/erp_data_table.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rs_dashboard/rs_dashboard.dart';

class PacketDeleteScreen extends StatefulWidget {
  const PacketDeleteScreen({super.key});

  @override
  State<PacketDeleteScreen> createState() => _PacketDeleteScreenState();
}

// ─────────────────────────────────────────────────────────────────────────────
//  STATE
// ─────────────────────────────────────────────────────────────────────────────

class _PacketDeleteScreenState extends State<PacketDeleteScreen> {
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
      await Future.wait([context.read<RemarksProvider>().load()]);
    });
  }

  List<List<ErpFieldConfig>> _buildFormRows() {
    final remarksProv = context.read<RemarksProvider>();

    final remarkItems = remarksProv.list
        .map(
          (e) => ErpDropdownItem(
            label: e.remarksName ?? '',
            value: e.remarksCode?.toString() ?? '',
          ),
        )
        .toList();

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
          width: 200
        ),
        ErpFieldConfig(
          key: 'qrCode',
          label: 'QR CODE',
          type: ErpFieldType.number,
          sectionIndex: 0,
          readOnly: true,
          width: 200
        ),
        // ErpFieldConfig(
        //   key: 'remarks',
        //   label: 'REMARKS',
        //   type: ErpFieldType.text,
        //   sectionIndex: 0,
        // ),
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

  // ── In _PacketDeleteScreenState ─────────────────────────────────────

  Future<void> _onSearch() async {
    final prov = context.read<PacketDeleteProvider>();

    final filter = {"bCode": _formValues['bCode']};

    await prov.loadPacketDeleteList(filter: filter);
  }

  void _resetForm() {
    _erpFormKey.currentState?.resetForm();
    _entryVals.clear();
    final prov = context.read<PacketDeleteProvider>();
    prov.clear();
    setState(() {
      _formValues.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PacketDeleteProvider>(
      builder: (ctx, prov, _) => Padding(
        padding: const EdgeInsets.all(8),
        child: _buildForm(context, prov),
      ),
    );
  }

  Widget _buildForm(BuildContext context, PacketDeleteProvider prov) {
    return ErpForm(
      logo: AppImages.logo,
      key: _erpFormKey,
      title: 'PACKET DELETE',
      rows: _buildFormRows(),
      initialValues: _formValues,
      onCancel: _resetForm,
      isShowSaveButton: false,
      isEditMode: false,
      isShowSearch: false,
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
      },
      onFieldChanged: (key, value) {
        _formValues[key] = value.toString();
        switch (key) {
          default:
            _entryVals[key] = value.toString();
        }
      },
      detailBuilder: (ctx) {
        final prov = context.watch<PacketDeleteProvider>();
        if (prov.tableData.isEmpty) {
          return const SizedBox.shrink();
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            final screenHeight = MediaQuery.of(context).size.height;
            final isMobile = Responsive.isMobile(context);
            final double subtractHeight = isMobile ? 340.0 : 160.0;
            final dynamicHeight = (screenHeight - subtractHeight).clamp(450.0, 1500.0);
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
                title: 'PACKET DELETE ENTRY',
                token: '',
                url: '',
                isReportRow: false,
                showFooterTotals: true,
                selectedRow: selectedRow,
                onRowTap: (row) async {
                  setState(() {
                    selectedRow = row;
                  });

                  final prov = context.read<PacketDeleteProvider>();

                  final rowIndex = prov.tableData.indexWhere(
                    (e) =>
                        e['MstID'] == row['MstID'] &&
                        e['DetId'] == row['DetId'],
                  );

                  if (rowIndex == -1) return;

                  await _showDeletePopup(context, rowIndex);
                },
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showDeletePopup(BuildContext context, int rowIndex) async {
    final prov = context.read<PacketDeleteProvider>();
    final rowsToDelete = prov.tableData.take(rowIndex + 1).toList();
    final body = rowsToDelete.map((e) {
      return {"bcode": e['BCode'], "mstId": e['MstID']};
    }).toList();
    final isYes = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Delete Confirmation'),
          content: Text('Are You Sure You Want To Delete?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (isYes != true) return;

    /// API CALL
    await prov.deleteBulkPktApi(selectedRows: body);
    _onSearch();
    if (!mounted) return;
  }
}