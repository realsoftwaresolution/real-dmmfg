import 'package:diam_mfg/providers/Packet_History_provider.dart';
import 'package:diam_mfg/providers/color_provider.dart';
import 'package:diam_mfg/providers/pkt_type_provider.dart';
import 'package:diam_mfg/providers/purity_provider.dart';
import 'package:diam_mfg/providers/shape_provider.dart';
import 'package:diam_mfg/utils/app_images.dart';
import 'package:erp_data_table/erp_data_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rs_dashboard/rs_dashboard.dart';

class PacketHistoryScreen extends StatefulWidget {
  const PacketHistoryScreen({super.key});

  @override
  State<PacketHistoryScreen> createState() => _PacketHistoryScreenState();
}

// ─────────────────────────────────────────────────────────────────────────────
//  STATE
// ─────────────────────────────────────────────────────────────────────────────

class _PacketHistoryScreenState extends State<PacketHistoryScreen> {
  // ── Theme ──────────────────────────────────────────────────────────────────
  final ErpThemeVariant _themeVariant = ErpThemeVariant.frost;

  ErpTheme get _theme => ErpTheme(_themeVariant);

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
      await Future.wait([
        context.read<ColorProvider>().load(),
        context.read<ShapeProvider>().load(),
        context.read<PurityProvider>().load(),
        context.read<PktTypeProvider>().load(),
      ]);
    });
  }

  List<List<ErpFieldConfig>> _buildFormRows() {
    final colorProv = context.read<ColorProvider>();
    final shapeProv = context.read<ShapeProvider>();
    final purityProv = context.read<PurityProvider>();
    final pktTypeProv = context.read<PktTypeProvider>();
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

    final pktTypeItems = pktTypeProv.list
        .map(
          (e) => ErpDropdownItem(
            label: e.pktTypeName ?? '',
            value: e.pktTypeCode?.toString() ?? '',
          ),
        )
        .toList();

    // ─────────────────────────────────────────────────────────────────────
    //  MASTER SECTION (sectionIndex 0)
    // ─────────────────────────────────────────────────────────────────────
    final selectedType = _formValues['type'] ?? 'BCODE';
    final List<List<ErpFieldConfig>> rows = [
      [
        ErpFieldConfig(
          key: 'type',
          label: 'TYPE',
          type: ErpFieldType.dropdown,
          initialDropValue: true,
          dropdownItems: [
            const ErpDropdownItem(label: 'BCODE', value: 'BCODE'),
            const ErpDropdownItem(label: 'CUT NO', value: 'CUTNO'),
          ],
          sectionIndex: 0,
          required: true,
        ),

        /// ── BCODE FIELD ─────────────────────────
        if (selectedType == 'BCODE')
          ErpFieldConfig(
            key: 'bCode',
            label: 'BCODE',
            type: ErpFieldType.number,
            sectionIndex: 0,
            required: true,
          ),

        /// ── CUT NO FIELD ────────────────────────
        if (selectedType == 'CUTNO')
          ErpFieldConfig(
            key: 'pktType',
            label: 'PKT TYPE',
            type: ErpFieldType.dropdown,
            dropdownItems: pktTypeItems,
            initialDropValue: true,
            sectionIndex: 0,
            required: true,
          ),

        if (selectedType == 'CUTNO')
          ErpFieldConfig(
            key: 'cutNo',
            label: 'CUT NO',
            type: ErpFieldType.text,
            sectionIndex: 0,
            required: true,
          ),

        /// ── PKT NO ──────────────────────────────
        if (selectedType == 'CUTNO')
          ErpFieldConfig(
            key: 'pktNo',
            label: 'PKT NO',
            type: ErpFieldType.text,
            sectionIndex: 0,
            required: true,
          ),

        ErpFieldConfig(
          key: 'shapeCode',
          label: 'SHAPE',
          type: ErpFieldType.dropdown,
          dropdownItems: shapeItems,
          sectionIndex: 0,
          readOnly: true,
        ),

        ErpFieldConfig(
          key: 'purityCode',
          label: 'PURITY',
          type: ErpFieldType.dropdown,
          dropdownItems: purityItems,
          sectionIndex: 0,
          readOnly: true,
        ),

        ErpFieldConfig(
          key: 'colorCode',
          label: 'COLOR',
          type: ErpFieldType.dropdown,
          dropdownItems: colorItems,
          sectionIndex: 0,
          readOnly: true,
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

  // ── In _PacketCreateScreenState ─────────────────────────────────────

  Future<void> _onSearch() async {
    final prov = context.read<PacketHistoryProvider>();

    final filter = {
      "purityCode": int.tryParse(_formValues['purityCode'] ?? ''),
      "colorCode": int.tryParse(_formValues['colorCode'] ?? ''),
      "shapeCode": int.tryParse(_formValues['shapeCode'] ?? ''),
      "bcode": _formValues['bCode'],
    };

    await prov.loadPacketHistory(filter: filter);
  }

  void _resetForm() {
    _erpFormKey.currentState?.resetForm();
    _entryVals.clear();
    final prov = context.read<PacketHistoryProvider>();
    prov.clear();
    setState(() {
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
    return Consumer<PacketHistoryProvider>(
      builder: (ctx, prov, _) => Padding(
        padding: const EdgeInsets.all(8),
        child: _buildForm(context, prov),
      ),
    );
  }

  Widget _buildForm(BuildContext context, PacketHistoryProvider prov) {
    return ErpForm(
      logo: AppImages.logo,
      key: _erpFormKey,
      title: 'PACKET HISTORY',
      rows: _buildFormRows(),
      initialValues: _formValues,
      onCancel: _resetForm,
      isShowSaveButton: false,
      isEditMode: false,
      isShowSearch: false,
      onFieldSubmitted: (key, value) async {
        final scanVal = value.toString().trim();

        /// ── TYPE ─────────────────────────────────

        if (key == 'type') {
          final type = (_formValues['type'] ?? '');

          if (type == 'BCODE') {
            _erpFormKey.currentState?.focusField('bCode');
          } else {
            _erpFormKey.currentState?.focusField('pktType');
          }

          return;
        }

        /// ── PKT TYPE ─────────────────────────────

        if (key == 'pktType') {
          _erpFormKey.currentState?.focusField('cutNo');

          return;
        }

        /// ── CUT NO ───────────────────────────────

        if (key == 'cutNo') {
          if (scanVal.isEmpty) {
            _showSnack('Please enter Cut No');

            _erpFormKey.currentState?.focusField('cutNo');

            return;
          }

          _erpFormKey.currentState?.focusField('pktNo');

          return;
        }

        /// ── BCODE SEARCH ─────────────────────────

        if (key == 'bCode') {
          if (scanVal.isEmpty) {
            _showSnack('Please enter BCode');

            _erpFormKey.currentState?.focusField('bCode');

            return;
          }

          FocusScope.of(context).unfocus();

          await _onSearch();

          return;
        }

        /// ── PKT NO SEARCH ────────────────────────

        if (key == 'pktNo') {
          final pktType = (_formValues['pktType'] ?? '').trim();

          final cutNo = (_formValues['cutNo'] ?? '').trim();

          final pktNo = (_formValues['pktNo'] ?? '').trim();

          /// PKT TYPE

          if (pktType.isEmpty) {
            _showSnack('Please select Packet Type');

            _erpFormKey.currentState?.focusField('pktType');

            return;
          }

          /// CUT NO

          if (cutNo.isEmpty) {
            _showSnack('Please enter Cut No');

            _erpFormKey.currentState?.focusField('cutNo');

            return;
          }

          /// PKT NO

          if (pktNo.isEmpty) {
            _showSnack('Please enter Packet No');

            _erpFormKey.currentState?.focusField('pktNo');

            return;
          }

          /// CLOSE KEYBOARD / FOCUS

          FocusScope.of(context).unfocus();

          /// API CALL

          await _onSearch();

          return;
        }
      },
      onFieldChanged: (key, value) {
        _formValues[key] = value.toString();
        if (key == 'type') {
          FocusScope.of(context).unfocus();

          if (value == 'BCODE') {
            _formValues.remove('cutNo');
            _formValues.remove('pktNo');
            _formValues.remove('pktType');
          } else {
            _formValues.remove('bCode');
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;

            setState(() {});
          });

          return;
        }

        switch (key) {
          default:
            _entryVals[key] = value.toString();
        }
      },
      detailBuilder: (ctx) {
        final prov = context.watch<PacketHistoryProvider>();
        if (prov.tableData.isEmpty) {
          return const SizedBox.shrink();
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight.isFinite
                  ? constraints.maxHeight
                  : 620,
              child: ErpDataTable(
                key: ValueKey('${prov.tableData.length}'),
                data: prov.tableData,
                columns: prov.columns,
                showSearch: false,
                title: 'PACKET HISTORY DATA',
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