import 'package:collection/collection.dart';
import 'package:diam_mfg/models/ls_party_wt_calc_entry_model.dart';
import 'package:diam_mfg/providers/Ls_party_wt_calc_entry_provider.dart';
import 'package:diam_mfg/providers/company_provider.dart';
import 'package:diam_mfg/providers/remarks_provider.dart';
import 'package:erp_data_table/erp_data_table.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rs_dashboard/rs_dashboard.dart';
import '../bootstrap.dart';
import '../utils/app_images.dart';
import '../utils/delete_dialogue.dart';
import '../utils/msg_dialogue.dart';

class MstLsPartyWtCalcEntry extends StatefulWidget {
  const MstLsPartyWtCalcEntry({super.key});

  @override
  State<MstLsPartyWtCalcEntry> createState() => _MstLsPartyWtCalcEntryState();
}

class _MstLsPartyWtCalcEntryState extends State<MstLsPartyWtCalcEntry> {
  // ── Theme ──────────────────────────────────────────────────────────────────
  final ErpThemeVariant _themeVariant = ErpThemeVariant.frost;

  ErpTheme get _theme => ErpTheme(_themeVariant);

  // ── State ──────────────────────────────────────────────────────────────────
  final GlobalKey<ErpFormState> _erpFormKey = GlobalKey<ErpFormState>();
  Map<String, dynamic>? _selectedRow;
  bool _isEditMode = false;
  bool _showTableOnMobile = false;
  Map<String, String> _formValues = {};
  List<LsPartyRowModel> _rows = [];
  final String? token = AppStorage.getString('token');
  final List<FocusNode> _pieFocusNodes = [];

  final List<FocusNode> _lsFocusNodes = [];

  // ── Table columns ──────────────────────────────────────────────────────────
  static final List<ErpColumnConfig> _tableColumns = [
    ErpColumnConfig(key: 'lsPartyWtCalcMstId', label: 'ID', width: 140),

    ErpColumnConfig(key: 'lsPartyWtCalcDate', label: 'DATE', width: 140),

    ErpColumnConfig(key: 'remarksName', label: 'REMARKS', width: 160),

    ErpColumnConfig(key: 'remarkTOPS', label: 'TOPS', width: 160),
  ];

  // ── Form rows ──────────────────────────────────────────────────────────────
  List<List<ErpFieldConfig>> _formRows(RemarksProvider rp) => [
    [
      ErpFieldConfig(
        key: 'remarks',
        label: 'REMARKS',
        width: 300,
        type: ErpFieldType.dropdown,
        required: true,
        sectionIndex: 0,
        dropdownItems: rp.list
            .where((e) => e.active == true)
            .map(
              (e) => ErpDropdownItem(
                label: e.remarksName ?? '',
                value: e.remarksCode?.toString() ?? '',
              ),
            )
            .toList(),
      ),
    ],
  ];

  // ── Init ───────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _resetForm();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<MstLsPartyWtCalcEntryProvider>().load();
      await context.read<CompanyProvider>().loadCompanies();

      if (!mounted) return;

      // ← ab companies available hain, division provider ko pass karo
      final companies = context.read<CompanyProvider>().companies;
      context.read<MstLsPartyWtCalcEntryProvider>().setCompanies(companies);
      final selectedCode = context.read<CompanyProvider>().selectedCompanyCode;
      context.read<MstLsPartyWtCalcEntryProvider>().setSelectedCompany(selectedCode);
      // ← last mein divisions load karo

      context.read<RemarksProvider>().load();
    });
  }

  @override
  void dispose() {
    for (final f in _pieFocusNodes) {
      f.dispose();
    }

    for (final f in _lsFocusNodes) {
      f.dispose();
    }

    super.dispose();
  }

  void _applyFormValues(Map<String, String> values) {
    setState(() => _formValues = values);
  }

  // ── Row tap ────────────────────────────────────────────────────────────────
  void _onRowTap(Map<String, dynamic> row) async {

    final provider =
    context.read<MstLsPartyWtCalcEntryProvider>();

    final raw =
    row['_raw'] as MstLsPartyWtCalcEntryModel;

    await provider.loadDetails(
      raw.lsPartyWtCalcMstId!,
    );

    /// CLEAR OLD
    for (final f in _pieFocusNodes) {
      f.dispose();
    }

    for (final f in _lsFocusNodes) {
      f.dispose();
    }

    _pieFocusNodes.clear();
    _lsFocusNodes.clear();

    /// LOAD DETAIL ROWS
    _rows = List.from(provider.detailRows);

    /// CREATE FOCUS NODES
    for (int i = 0; i < _rows.length; i++) {
      _pieFocusNodes.add(FocusNode());
      _lsFocusNodes.add(FocusNode());
    }

    _applyFormValues({
      'remarks': raw.remarksCode?.toString() ?? '',
    });

    setState(() {

      _selectedRow = row;

      _isEditMode = true;

      if (Responsive.isMobile(context)) {
        _showTableOnMobile = false;
      }
    });
  }

  // ── Save ───────────────────────────────────────────────────────────────────
  Future<void> _onSave(Map<String, dynamic> values) async {
    final provider = context.read<MstLsPartyWtCalcEntryProvider>();

    final success = _isEditMode && _selectedRow != null
        ? await provider.update(
            (_selectedRow!['_raw'] as MstLsPartyWtCalcEntryModel)
                .lsPartyWtCalcMstId!,
            values,
            _rows,
          )
        : await provider.create(values, _rows);

    if (!mounted || !success) return;

    final wasEdit = _isEditMode;
    _resetForm();

    await ErpResultDialog.showSuccess(
      context: context,
      theme: _theme,
      title: wasEdit ? 'Updated' : 'Saved',
      message: wasEdit
          ? 'Data updated successfully.'
          : 'Data saved successfully.',
    );
    await context.read<MstLsPartyWtCalcEntryProvider>().load();
  }

  // ── Delete ─────────────────────────────────────────────────────────────────
  Future<void> _onDelete() async {
    final raw = _selectedRow?['_raw'] as MstLsPartyWtCalcEntryModel?;
    if (raw?.lsPartyWtCalcMstId == null) return;

    final confirm = await ErpDeleteDialog.show(
      context: context,
      theme: _theme,
      title: 'Ls Party Wt Calculation Entry',
      itemName: raw!.remarksName ?? '',
    );
    if (confirm != true || !mounted) return;

    final success = await context.read<MstLsPartyWtCalcEntryProvider>().delete(
      raw.lsPartyWtCalcMstId!,
    );

    if (!success || !mounted) return;

    _resetForm();
    await ErpResultDialog.showDeleted(
      context: context,
      theme: _theme,
      itemName: raw.remarksName ?? '',
    );
  }

  // ── Reset ──────────────────────────────────────────────────────────────────
  void _resetForm() {
    _erpFormKey.currentState?.resetForm();

    setState(() {
      _selectedRow = null;

      _isEditMode = false;

      _showTableOnMobile = false;

      /// CLEAR FORM
      _formValues = {};

      /// CLEAR TABLE
      _rows.clear();
    });

    _erpFormKey.currentState?.updateFieldValue('remarks', '');
  }

  void _loadRowsFromRemarks(dynamic remarksCode) {
    final remarksProv = context.read<RemarksProvider>();

    final remark = remarksProv.list.firstWhereOrNull(
      (e) => e.remarksCode.toString() == remarksCode.toString(),
    );

    final remarkTops = remark?.tops;

    _rows.clear();

    for (final f in _pieFocusNodes) {
      f.dispose();
    }

    for (final f in _lsFocusNodes) {
      f.dispose();
    }

    _pieFocusNodes.clear();

    _lsFocusNodes.clear();

    if (remarkTops != null) {
      final topCount = int.tryParse(remarkTops.toString()) ?? 0;

      /// GENERATE ROWS
      _rows = List.generate(topCount, (index) {
        return LsPartyRowModel(
          srNo: index + 1,

          per: 0,

          calcWt: 0,

          piePer: 0,

          pieCalcWt: 0,

          lsPer: 0,

          lsCalcWt: 0,
        );
      });
      for (int i = 0; i < topCount; i++) {
        _pieFocusNodes.add(FocusNode());

        _lsFocusNodes.add(FocusNode());
      }
    }

    setState(() {});
  }

  void _updatePiePer(int index, double value) {
    _rows[index].piePer = value;

    _recalculateRow(index);

    setState(() {});
  }

  void _updateLsPer(int index, double value) {
    _rows[index].lsPer = value;

    _recalculateRow(index);

    setState(() {});
  }

  void _recalculateRow(int index) {
    final row = _rows[index];

    /// BASE WT
    double baseWt = 1;

    if (index > 0) {
      baseWt = _rows[index - 1].calcWt;
    }

    /// PIE CALC
    row.pieCalcWt = (baseWt * row.piePer) / 100;

    /// LS CALC
    row.lsCalcWt = (baseWt * row.lsPer) / 100;

    /// FINAL CALC WT
    row.calcWt = row.pieCalcWt + row.lsCalcWt;

    /// CONTINUE NEXT ROW
    if (index + 1 < _rows.length) {
      _recalculateRow(index + 1);
    }
  }

  // ── Shared widgets ─────────────────────────────────────────────────────────
  Widget _buildForm(RemarksProvider rp) => ErpForm(
    key: _erpFormKey,
    logo: AppImages.logo,
    title: 'LS PARTY WT CALCULATION ENTRY MASTER',
    rows: _formRows(rp),
    initialValues: _formValues,
    isEditMode: _isEditMode,
    tabBarBackgroundColor: const Color(0xfff2f0ef),
    tabBarSelectedColor: _theme.primaryGradient.first,
    tabBarSelectedTxtColor: Colors.white,
    onFieldChanged: (key, value) {
      _formValues[key] = value;

      if (key == 'remarks') {
        _loadRowsFromRemarks(value);
      }
    },
    detailBuilder: (ctx) {
      final t = ctx.erpTheme;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [_buildDetailsTable(t)],
      );
    },
    onSave: _onSave,
    onCancel: _resetForm,
    onDelete: _isEditMode ? _onDelete : null,
    onSearch: () => setState(() => _showTableOnMobile = true),
    onExit: () => context.read<TabProvider>().closeCurrentTab(),
  );

  double get _totalCalcWt => _rows.fold(0, (sum, e) => sum + e.calcWt);

  double get _totalPieCalcWt => _rows.fold(0, (sum, e) => sum + e.pieCalcWt);

  double get _totalLsCalcWt => _rows.fold(0, (sum, e) => sum + e.lsCalcWt);

  Widget _buildDetailsTable(ErpTheme theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.border),
        boxShadow: [
          BoxShadow(
            color: theme.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          /// HEADER
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.bg,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),

            child: Row(
              children: [
                _thExpand('SrNo', theme, flex: 1),
                _thExpand('Per', theme, flex: 2),
                _thExpand('Calc Wt', theme, flex: 2),
                _thExpand('Pie Per', theme, flex: 2),
                _thExpand('Pie Calc Wt', theme, flex: 2),
                _thExpand('LS Per', theme, flex: 2),
                _thExpand('LS Calc Wt', theme, flex: 2),
              ],
            ),
          ),

          /// ROWS
          ...List.generate(_rows.length, (index) {
            final row = _rows[index];

            return Container(
              height: 35,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: index.isEven ? Colors.white : theme.bg.withOpacity(0.4),
                border: Border(
                  top: BorderSide(color: theme.border),
                  left: BorderSide.none,
                ),
              ),

              child: Row(
                children: [
                  _tdExpand(row.srNo.toString(), flex: 1),
                  _tdExpand(row.per.toString(), flex: 2),
                  _tdExpand(row.calcWt.toStringAsFixed(3), flex: 2),

                  /// PIE PER EDIT
                  Expanded(
                    flex: 2,

                    child: TextFormField(
                      focusNode: _pieFocusNodes[index],

                      textInputAction: TextInputAction.next,

                      controller: TextEditingController(
                        text: row.piePer == 0 ? '' : row.piePer.toString(),
                      ),

                      textAlign: TextAlign.center,

                      style: TextStyle(
                        fontSize: 12,
                        color: theme.text,
                        fontWeight: FontWeight.w500,
                      ),

                      decoration: InputDecoration(
                        isDense: true,

                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 8,
                        ),

                        filled: true,

                        fillColor: Colors.yellow.shade100,

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),

                          borderSide: BorderSide(color: theme.border),
                        ),
                      ),

                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),

                      onFieldSubmitted: (v) {
                        _updatePiePer(index, double.tryParse(v) ?? 0);

                        /// MOVE TO LS FIELD
                        FocusScope.of(
                          context,
                        ).requestFocus(_lsFocusNodes[index]);
                      },
                    ),
                  ),

                  _tdExpand(row.pieCalcWt.toStringAsFixed(3), flex: 2),

                  /// LS PER EDIT
                  SizedBox(
                    width: 100,

                    child: TextFormField(
                      focusNode: _lsFocusNodes[index],

                      textInputAction: index == _rows.length - 1
                          ? TextInputAction.done
                          : TextInputAction.next,

                      controller: TextEditingController(
                        text: row.lsPer == 0 ? '' : row.lsPer.toString(),
                      ),

                      textAlign: TextAlign.center,

                      style: TextStyle(
                        fontSize: 12,
                        color: theme.text,
                        fontWeight: FontWeight.w500,
                      ),

                      decoration: InputDecoration(
                        isDense: true,

                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 8,
                        ),

                        filled: true,

                        fillColor: Colors.yellow.shade100,

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),

                          borderSide: BorderSide(color: theme.border),
                        ),
                      ),

                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),

                      onFieldSubmitted: (v) {
                        _updateLsPer(index, double.tryParse(v) ?? 0);

                        /// NEXT ROW PIE FIELD
                        if (index + 1 < _rows.length) {
                          FocusScope.of(
                            context,
                          ).requestFocus(_pieFocusNodes[index + 1]);
                        }
                      },
                    ),
                  ),

                  _tdExpand(row.lsCalcWt.toStringAsFixed(3), flex: 2),
                ],
              ),
            );
          }),

          /// FOOTER
          if (_rows.isNotEmpty)
            Container(
              height: 42,

              padding: const EdgeInsets.symmetric(horizontal: 8),

              decoration: BoxDecoration(
                color: theme.bg,

                border: Border(top: BorderSide(color: theme.border)),

                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
              ),

              child: Row(
                children: [
                  /// TOTAL LABEL
                  Container(
                    width: 140,

                    alignment: Alignment.centerLeft,

                    child: Text(
                      'Total : ${_rows.length}',

                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: theme.text,
                      ),
                    ),
                  ),

                  /// CALC WT
                  Expanded(
                    child: _footerCell(
                      _totalCalcWt.toStringAsFixed(4),
                      100,
                      theme,
                    ),
                  ),

                  /// PIE WT
                  Expanded(
                    child: _footerCell(
                      _totalPieCalcWt.toStringAsFixed(4),
                      100,
                      theme,
                    ),
                  ),

                  /// LS WT
                  Expanded(
                    child: _footerCell(
                      _totalLsCalcWt.toStringAsFixed(4),
                      100,
                      theme,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _thExpand(String text, ErpTheme theme, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: theme.textLight,
        ),
      ),
    );
  }

  Widget _tdExpand(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(text, textAlign: TextAlign.center),
    );
  }

  Widget _footerCell(String text, double width, ErpTheme theme) {
    return Container(
      width: width,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 2),

      child: Text(
        text,

        style: TextStyle(
          fontWeight: FontWeight.w700,

          fontSize: 12,

          color: theme.text,
        ),
      ),
    );
  }

  Widget _buildTable(MstLsPartyWtCalcEntryProvider provider) => ErpDataTable(
    isReportRow: false,
    token: token ?? '',
    url: baseUrl,
    title: 'LS PARTY WT CALCULATION ENTRY LIST',
    columns: _tableColumns,
    data: provider.tableData,
    showSearch: true,
    showFooterTotals: false,
    selectedRow: _selectedRow,
    onRowTap: _onRowTap,
    emptyMessage: provider.isLoaded ? 'No Data found' : 'Loading...',
  );

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Consumer2<MstLsPartyWtCalcEntryProvider, RemarksProvider>(
      builder: (context, provider, rp, _) => Padding(
        padding: const EdgeInsets.all(8),
        child: Responsive.isMobile(context)
            ? _showTableOnMobile
                  ? _buildTable(provider)
                  : _buildForm(rp)
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildForm(rp)),
                  const SizedBox(width: 12),
                  Expanded(flex: 2, child: _buildTable(provider)),
                ],
              ),
      ),
    );
  }
}
