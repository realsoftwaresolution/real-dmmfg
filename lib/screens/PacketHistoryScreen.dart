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
  List<ErpDropdownItem> _shapeItems = [];

  List<ErpDropdownItem> _colorItems = [];

  List<ErpDropdownItem> _purityItems = [];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.wait([
        context.read<ColorProvider>().load(),
        context.read<ShapeProvider>().load(),
        context.read<PurityProvider>().load(),
      ]);

      if (!mounted) return;

      final colorProv = context.read<ColorProvider>();
      final shapeProv = context.read<ShapeProvider>();
      final purityProv = context.read<PurityProvider>();

      _shapeItems = shapeProv.list
          .map((e) => ErpDropdownItem(
        label: e.shapeName ?? '',
        value: e.shapeCode?.toString() ?? '',
      ))
          .toList(growable: false);

      _colorItems = colorProv.list
          .map((e) => ErpDropdownItem(
        label: e.colorName ?? '',
        value: e.colorCode?.toString() ?? '',
      ))
          .toList(growable: false);

      _purityItems = purityProv.list
          .map((e) => ErpDropdownItem(
        label: e.purityName ?? '',
        value: e.purityCode?.toString() ?? '',
      ))
          .toList(growable: false);

      setState(() {});
    });
  }

  List<List<ErpFieldConfig>> _buildFormRows() {
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
        ),

        /// ── BCODE FIELD ─────────────────────────
        if (selectedType == 'BCODE')
          ErpFieldConfig(
            key: 'bCode',
            label: 'BCODE',
            type: ErpFieldType.number,
            sectionIndex: 0,
          ),

        /// ── CUT NO FIELD ────────────────────────
        if (selectedType == 'CUTNO')
          ErpFieldConfig(
            key: 'cutNo',
            label: 'CUT NO',
            type: ErpFieldType.text,
            sectionIndex: 0,
          ),

        /// ── PKT NO ──────────────────────────────
        if (selectedType == 'CUTNO')
          ErpFieldConfig(
            key: 'pktNo',
            label: 'PKT NO',
            type: ErpFieldType.text,
            sectionIndex: 0,
          ),

        ErpFieldConfig(
          key: 'shapeCode',
          label: 'SHAPE',
          type: ErpFieldType.dropdown,
          dropdownItems: _shapeItems,
          sectionIndex: 0,
          readOnly: true,
        ),

        ErpFieldConfig(
          key: 'purityCode',
          label: 'PURITY',
          type: ErpFieldType.dropdown,
          dropdownItems: _purityItems,
          sectionIndex: 0,
          readOnly: true,
        ),

        ErpFieldConfig(
          key: 'colorCode',
          label: 'COLOR',
          type: ErpFieldType.dropdown,
          dropdownItems: _colorItems,
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
      "cutNo": _formValues['cutNo'],
      "pktNo": _formValues['pktNo'],
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

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;

            Future.delayed(const Duration(milliseconds: 100), () {
              if (type == 'BCODE') {
                _erpFormKey.currentState?.focusField('bCode');
              }
            });
          });

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
          await _onSearch();

          return;
        }

        /// ── PKT NO SEARCH ────────────────────────

        if (key == 'pktNo') {

          final cutNo = (_formValues['cutNo'] ?? '').trim();

          final pktNo = (_formValues['pktNo'] ?? '').trim();

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

          /// API CALL

          await _onSearch();

          return;
        }
      },
      onFieldChanged: (key, value) {
        _formValues[key] = value.toString();
        if (key == 'type') {
          if (value == 'BCODE') {
            _formValues.remove('cutNo');
            _formValues.remove('pktNo');
            _erpFormKey.currentState?.updateFieldValue('cutNo','');
            _erpFormKey.currentState?.updateFieldValue('pktNo','');
          } else {
            _formValues.remove('bCode');
            _erpFormKey.currentState?.updateFieldValue('bCode','');
          }

          Future.delayed(const Duration(milliseconds: 50), () {
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
                title: 'PACKET HISTORY ENTRY',
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
