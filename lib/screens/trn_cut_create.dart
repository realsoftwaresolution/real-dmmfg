import 'dart:convert';

import 'package:diam_mfg/models/cut_create_model.dart';
import 'package:diam_mfg/providers/cut_create_provider.dart';
import 'package:diam_mfg/providers/purity_provider.dart';
import 'package:diam_mfg/providers/rough_assort_provider.dart';
import 'package:diam_mfg/providers/rough_provider.dart';
import 'package:diam_mfg/services/duplicate_check_service.dart';
import 'package:diam_mfg/services/duplicate_utils.dart';
import 'package:diam_mfg/utils/app_images.dart';
import 'package:diam_mfg/utils/constants.dart';
import 'package:diam_mfg/utils/delete_dialogue.dart';
import 'package:diam_mfg/utils/helper_functions.dart';
import 'package:diam_mfg/utils/msg_dialogue.dart';
import 'package:erp_data_table/erp_data_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rs_dashboard/rs_dashboard.dart';

import '../bootstrap.dart';
import '../models/rough_assort_model.dart';
import '../models/rough_model.dart';

const List<ErpDropdownItem> _cutTypeItems = [
  ErpDropdownItem(label: 'GENERAL', value: 'GENERAL'),
  ErpDropdownItem(label: 'SPK', value: 'SPK'),
];

class TrnCutCreateEntry extends StatefulWidget {
  const TrnCutCreateEntry({super.key});

  @override
  State<TrnCutCreateEntry> createState() => _TrnCutCreateEntryState();
}

class _TrnCutCreateEntryState extends State<TrnCutCreateEntry> {
  final ErpThemeVariant _themeVariant = ErpThemeVariant.frost;

  ErpTheme get _theme => ErpTheme(_themeVariant);
  final GlobalKey<ErpFormState> _erpFormKey = GlobalKey<ErpFormState>();

  Map<String, dynamic>? _selectedRow;
  CutCreateModel? _selectedMst;
  bool _isEditMode = false;
  bool _showTableOnMobile = false;

  Map<String, String> _formValues = {};

  String _pendingPc = '0';
  String _pendingWt = '0.000';

  List<RoughAssortDetModel> _assortDets = [];
  String _assortNo = '';

  // ✅ FIX 2: Track total assort wt/pc separately from pending
  double _totalAssortWt = 0;
  int _totalAssortPc = 0;

  List<CutCreateDetModel> _detRows = [];
  List<Map<String, dynamic>> _detDisplay = [];
  int? _editingDetIndex;

  final Map<String, String> _entryVals = {};
  final String? token = AppStorage.getString('token');

  // ── TABLE COLUMNS ──────────────────────────────────────────────────────────
  List<ErpColumnConfig> get _tableColumns => [
    ErpColumnConfig(
      key: 'cutCreateMstID',
      label: 'ID',
      width: 70,
      required: true,
    ),
    ErpColumnConfig(
      key: 'cutCreateDate',
      label: 'DATE',
      width: 110,
      required: true,
      isDate: true,
    ),
    ErpColumnConfig(key: 'kapanNo', label: 'KAPAN', width: 150),
    ErpColumnConfig(key: 'jno', label: 'JNO', width: 130),
    ErpColumnConfig(key: 'totalPc', label: 'TOT PC', width: 140), // ✅
    ErpColumnConfig(key: 'totalWt', label: 'TOT WT', width: 140), // ✅
  ];

  // ── FORM ROWS ──────────────────────────────────────────────────────────────
  List<List<ErpFieldConfig>> _formRows(
    RoughAssortProvider rap,
    CutCreateProvider cutProv,
  ) {
    final pu = context.read<PurityProvider>();
    // ✅ FIX 2: Kapan dropdown — sirf woh kapan dikhao jinki
    //           RoughAssort total wt > already used wt in CutCreate
    final kapanItems = rap.list
        .where((assort) {
          if (assort.kapanNo == null || assort.kapanNo!.isEmpty) return false;
          if (!assort.details.any((d) => d.purityCode == 2)) return false;

          // Assort total wt for this kapan
          final assortWt = assort.details.fold(0.0, (s, d) => s + (d.wt ?? 0));

          // Already used wt in existing CutCreate records (excluding current edit)
          final usedWt = cutProv.list
              .where(
                (cc) =>
                    cc.kapanNo == assort.kapanNo &&
                    cc.cutCreateMstID != _selectedMst?.cutCreateMstID,
              )
              .fold(0.0, (s, cc) => s + cc.totalWt);

          final pendingWt = assortWt - usedWt;
          return pendingWt > 0.0001; // sirf positive pending wale dikhao
        })
        .map((e) {
          final makable = e.details.firstWhere(
            (d) => d.purityCode == 2,
            orElse: () => e.details.first,
          );
          return ErpDropdownItem(
            label:
                'Kapan: ${e.kapanNo!}  Purity: ${getPurityName(pu.list, makable.purityCode)}',
            value: e.kapanNo!,
          );
        })
        .toList();

    return [
      // SECTION 0: MASTER
      [
        ErpFieldConfig(
          key: 'cutCreateDate',
          label: 'DATE',
          type: ErpFieldType.date,
          readOnly: true,
          required: true,
          flex: 2,
          sectionTitle: 'CUT CREATE ENTRY',
          sectionIndex: 0,
        ),
        ErpFieldConfig(
          key: 'cutCreateMstID',
          label: 'ID',
          type: ErpFieldType.number,
          readOnly: true,
          flex: 1,
          sectionIndex: 0,
        ),
        ErpFieldConfig(
          key: 'kapanNo',
          label: 'KAPAN NO',
          type: ErpFieldType.dropdown,
          dropdownItems: kapanItems,
          readOnly: _detDisplay.isNotEmpty || _isEditMode,
          required: true,
          flex: 2,
          sectionIndex: 0,
        ),
        ErpFieldConfig(
          key: 'jno',
          label: 'JNO',
          type: ErpFieldType.number,
          readOnly: true,
          flex: 1,
          sectionIndex: 0,
        ),
      ],
      // SECTION 1: ENTRY
      [
        ErpFieldConfig(
          key: 'entryCutType',
          label: 'TYPE',
          type: ErpFieldType.dropdown,
          dropdownItems: _cutTypeItems,
          flex: 1,
          sectionTitle: 'ENTRY',
          sectionIndex: 1,
          isEntryField: true,
          isEntryRequired: true,
        ),
        ErpFieldConfig(
          key: 'entryCutNo',
          label: 'CUT NO',
          type: ErpFieldType.text,
          flex: 1,
          sectionIndex: 1,
          isEntryField: true,
          isEntryRequired: true,
          onDuplicateCheck: (value, allValues) async {
            return await _checkDuplicate(
              fields: {
                'CutNo': value,
              },
            );
          },
        ),
        ErpFieldConfig(
          key: 'entryPc',
          label: 'PC',
          type: ErpFieldType.number,
          flex: 1,
          sectionIndex: 1,
          isEntryField: true,
        ),
        ErpFieldConfig(
          key: 'entryWt',
          label: 'WT',
          type: ErpFieldType.amount,
          flex: 1,
          sectionIndex: 1,
          isEntryField: true,
          isEntryRequired: true,
        ),
        ErpFieldConfig(
          key: 'entryComparisionCode',
          label: 'COMPARISION CODE',
          type: ErpFieldType.amount,
          flex: 1,
          sectionIndex: 1,
          isEntryField: true,
        ),
        ErpFieldConfig(
          key: 'entryAssortNo',
          label: 'ASSORT NO',
          type: ErpFieldType.text,
          readOnly: true,
          flex: 1,
          sectionIndex: 1,
          isEntryField: true,
        ),
        ErpFieldConfig(
          key: 'entryPurityType',
          label: 'PURITY TYPE',
          type: ErpFieldType.text,
          flex: 1,
          sectionIndex: 1,
          isEntryField: true,
          showAddButton: true,
        ),
      ],
    ];
  }

  Future<bool> _checkDuplicate({required Map<dynamic, dynamic> fields}) async {
    /// ── SKIP SAME VALUE IN EDIT ───────────────
    final skip = shouldSkipDuplicateCheck(
      isEditMode: _isEditMode,
      selectedRow: _selectedRow,
      allowRowData: false,
      newFields: Map<String, dynamic>.from(fields),
      fieldMapping: {'CutNo': 'CutNo'},
    );

    if (skip) {
      return false;
    }

    /// ── API CHECK ─────────────────────────────
    return await checkDuplicateRecord(
      context: context,
      theme: _theme,
      formName: 'CutCreate',
      fields: fields,
    );
  }

  // ── INIT ───────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CutCreateProvider>().load();
      context.read<RoughProvider>().loadRoughs();
      context.read<RoughAssortProvider>().load();
      context.read<PurityProvider>().load();
      _setDefaultFormValues();
    });
  }

  void _setDefaultFormValues() {
    final today = DateFormat('dd/MM/yyyy').format(DateTime.now());
    _formValues = {'cutCreateDate': today, 'cutCreateMstID': '0'};
    if (mounted) setState(() {});
  }

  // ── KAPAN SELECT ───────────────────────────────────────────────────────────
  Future<void> _onKapanSelected(String kapanNo) async {
    final rp = context.read<RoughProvider>();
    final match = rp.roughs.firstWhere(
      (e) => e.kapanNo == kapanNo,
      orElse: () => RoughModel(),
    );
    final jno = match.jno?.toString() ?? '';
    _formValues['jno'] = jno;
    _erpFormKey.currentState?.updateFieldValue('jno', jno);
    await _loadAssortTotals(kapanNo);
  }

  // ── LOAD ASSORT TOTALS ─────────────────────────────────────────────────────
  Future<void> _loadAssortTotals(String kapanNo) async {
    final pu = context.read<PurityProvider>();
    final assortProv = context.read<RoughAssortProvider>();
    final cutProv = context.read<CutCreateProvider>();

    final mst = assortProv.list.firstWhere(
      (e) => e.kapanNo == kapanNo,
      orElse: () => RoughAssortModel(),
    );

    if (mst.roughAssortMstID == null) {
      setState(() {
        _assortDets = [];
        _pendingPc = '0';
        _pendingWt = '0.000';
        _assortNo = '';
        _totalAssortWt = 0;
        _totalAssortPc = 0;
      });
      return;
    }

    final dets = await assortProv.loadDetails(mst.roughAssortMstID!);
    if (!mounted) return;

    // Total from assort
    final totalPc = dets.fold(0, (s, r) => s + (r.pc ?? 0));
    final totalWt = dets.fold(0.0, (s, r) => s + (r.wt ?? 0));

    // ✅ FIX 2: Already used in OTHER CutCreate records (not current edit)
    final alreadyUsedPc = cutProv.list
        .where(
          (cc) =>
              cc.kapanNo == kapanNo &&
              cc.cutCreateMstID != _selectedMst?.cutCreateMstID,
        )
        .fold(0, (s, cc) => s + cc.totalPc);
    final alreadyUsedWt = cutProv.list
        .where(
          (cc) =>
              cc.kapanNo == kapanNo &&
              cc.cutCreateMstID != _selectedMst?.cutCreateMstID,
        )
        .fold(0.0, (s, cc) => s + cc.totalWt);

    // Used in current entry form's _detRows
    final formUsedPc = _detRows.fold(0, (s, r) => s + (r.pc ?? 0));
    final formUsedWt = _detRows.fold(0.0, (s, r) => s + (r.wt ?? 0));

    final newAssortNo = dets.isNotEmpty
        ? getPurityName(pu.list, dets.first.purityCode)
        : '';

    _assortNo = newAssortNo;
    _totalAssortWt = totalWt - alreadyUsedWt;
    _totalAssortPc = totalPc - alreadyUsedPc;

    _erpFormKey.currentState?.updateFieldValue('entryAssortNo', newAssortNo);

    setState(() {
      _assortDets = dets;
      _pendingPc = '${_totalAssortPc - formUsedPc}';
      _pendingWt = fThreeDecimal(_totalAssortWt - formUsedWt);
    });
  }

  // ── RECALC PENDING ─────────────────────────────────────────────────────────
  void _recalcPending() {

    final formUsedPc =
    _detRows.fold(0, (s, r) => s + (r.pc ?? 0));

    final formUsedWt =
    _detRows.fold(0.0, (s, r) => s + (r.wt ?? 0));

    final newPendPc =
        _totalAssortPc - formUsedPc;

    final newPendWt =
        _totalAssortWt - formUsedWt;

    setState(() {

      _pendingPc = '$newPendPc';

      _pendingWt =
          fThreeDecimal(newPendWt);

    });

    debugPrint(
      'Pending WT => $_pendingWt',
    );
  }

  // ── ADD DET ENTRY ──────────────────────────────────────────────────────────
  Future<void> _addDetEntry() async {

    final exists = await _checkDuplicate(
      fields: {
        'CutNo': _entryVals['entryCutNo'].toString(),
      },
    );
    if (exists) return;

    final cutType = _entryVals['entryCutType'] ?? '';
    final cutNo = _entryVals['entryCutNo'] ?? '';
    final wtStr = _entryVals['entryWt'] ?? '';
    final purityType = _entryVals['entryPurityType'] ?? '';

    if (cutType.isEmpty) {
      _showSnack('Type required');
      _erpFormKey.currentState?.focusField('entryCutType');
      return;
    }
    if (cutNo.isEmpty) {
      _showSnack('Cut No required');
      _erpFormKey.currentState?.focusField('entryCutNo');
      return;
    }
    if (wtStr.isEmpty) {
      _showSnack('Weight required');
      _erpFormKey.currentState?.focusField('entryWt');
      return;
    }

    final isDuplicate = _detRows.asMap().entries.any(
      (e) =>
          e.value.cutNo?.toLowerCase() == cutNo.toLowerCase() &&
          e.key != _editingDetIndex,
    );
    if (isDuplicate) {
      await ErpResultDialog.showError(
        context: context,
        theme: _theme,
        title: 'Duplicate Cut No',
        message:
            'Cut No "$cutNo" already exists.\nPlease enter a different Cut No.',
      );
      _erpFormKey.currentState?.focusField('entryCutNo');
      return;
    }

    final entryWt = double.tryParse(wtStr) ?? 0;


    // CHECK WT
    if (_editingDetIndex != null) {

      final editingRow =
      _detRows[_editingDetIndex!];

      final usedWt =
      await context
          .read<CutCreateProvider>()
          .getPacketCreateUsedWt(
        editingRow.cutNo ?? '',
      );

      if (entryWt < usedWt) {

        if (!mounted) return;

        await ErpResultDialog.showError(

          context: context,

          theme: _theme,

          title: 'Invalid Weight',

          message:
          'This Cut\'s '
              '${fThreeDecimal(usedWt)} WT '
              'has already been used in Packet Create.\n\n'
              'Therefore, WT cannot be entered less than '
              '${fThreeDecimal(usedWt)}.',
        );

        _erpFormKey.currentState
            ?.focusField('entryWt');

        return;
      }
    }



    final oldWt = _editingDetIndex != null
        ? (_detRows[_editingDetIndex!].wt ?? 0)
        : 0.0;
    final formUsedWt = _detRows.fold(0.0, (s, r) => s + (r.wt ?? 0)) - oldWt;
    final pendWt = _totalAssortWt - formUsedWt;

    if (entryWt > pendWt + 0.0001) {
      await ErpResultDialog.showError(
        context: context,
        theme: _theme,
        title: 'Weight Exceeded',
        message:
            'Entry Wt (${fThreeDecimal(entryWt)}) exceeds Pending Wt (${fThreeDecimal(pendWt)}).\n\n'
            'Available : ${fThreeDecimal(_totalAssortWt)}\n'
            'Pending   : ${fThreeDecimal(pendWt)}\n'
            'Entered   : ${fThreeDecimal(entryWt)}\n\n'
            'Please reduce weight to ${fThreeDecimal(pendWt)} or less.',
      );
      _erpFormKey.currentState?.focusField('entryWt');
      return;
    }
    final assortProv = context.read<RoughAssortProvider>();
    final mst = assortProv.list.firstWhere(
      (e) => e.kapanNo == _formValues['kapanNo'],
      orElse: () => RoughAssortModel(),
    );

    final dets = await assortProv.loadDetails(mst.roughAssortMstID!);
    final newRow = CutCreateDetModel(
      srno: _editingDetIndex != null
          ? _detRows[_editingDetIndex!].srno
          : _detRows.length + 1,
      cutType: cutType,
      cutNo: cutNo,
      pc: int.tryParse(_entryVals['entryPc'] ?? ''),
      wt: double.parse(
        (double.tryParse(wtStr) ?? 0).toStringAsFixed(3),
      ),
      comparisionCode: double.tryParse(
        _entryVals['entryComparisionCode'] ?? '',
      ),
      purityType: purityType.isEmpty ? null : purityType,
      kapanNo: _formValues['kapanNo'],
      finish: 'N',
      clvFinish: 'N',
      pmFinish: 'N',
      lsFinish: 'N',
      cutRec: 'N',
      autoPktCreate: true,
      purityCode: dets.first.purityCode,
      lastCrId: 1,
    );

    setState(() {
      if (_editingDetIndex != null) {
        _detRows[_editingDetIndex!] = newRow;
        _editingDetIndex = null;
      } else {
        _detRows.add(newRow);
      }
      _syncDetGrid();
    });
    _recalcPending();
    _clearEntryFields();
  }

  void _editDetRow(int idx) {
    final r = _detRows[idx];
    setState(() => _editingDetIndex = idx);

    void set(String k, String? v) {
      _entryVals[k] = v ?? '';
      _erpFormKey.currentState?.updateFieldValue(k, v ?? '');
    }

    set('entryCutType', r.cutType);
    set('entryCutNo', r.cutNo);
    set('entryPc', r.pc?.toString());
    set('entryWt', fThreeDecimal(r.wt));
    set('entryComparisionCode', f2TwoDecimal(r.comparisionCode));
    set('entryAssortNo', _assortNo);
    set('entryPurityType', r.purityType);

    Future.delayed(
      const Duration(milliseconds: 50),
      () => _erpFormKey.currentState?.focusField('entryCutType'),
    );
  }

  void _deleteDetRow(int idx) {
    setState(() {
      _detRows.removeAt(idx);
      _detRows = _detRows
          .asMap()
          .entries
          .map(
            (e) => CutCreateDetModel(
              srno: e.key + 1,
              cutCreateMstID: e.value.cutCreateMstID,
              cutType: e.value.cutType,
              cutNo: e.value.cutNo,
              pc: e.value.pc,
              wt: e.value.wt,
              comparisionCode: e.value.comparisionCode,
              purityType: e.value.purityType,
              kapanNo: e.value.kapanNo,
            ),
          )
          .toList();
      _syncDetGrid();
      if (_editingDetIndex == idx) _editingDetIndex = null;
    });
    _recalcPending();
  }

  void _syncDetGrid() {
    _detDisplay = _detRows
        .map(
          (r) => {
            'srno': r.srno?.toString() ?? '',
            'cutType': r.cutType ?? '',
            'cutNo': r.cutNo ?? '',
            'pc': r.pc?.toString() ?? '',
            'wt': fThreeDecimal(r.wt),
            'comparisionCode': r.comparisionCode != null
                ? f2TwoDecimal(r.comparisionCode)
                : '',
            'assortNo': _assortNo,
            'purityType': r.purityType ?? '',
          },
        )
        .toList();
  }

  List<String> get _detGridColumns => [
    'srno',
    'cutType',
    'cutNo',
    'pc',
    'wt',
    'comparisionCode',
    'assortNo',
    'purityType',
  ];

  Map<String, dynamic> get _footerTotals => {
    'count': _detRows.length,
    'pc': _detRows.fold(0, (s, r) => s + (r.pc ?? 0)),
    'wt': _detRows.fold(0.0, (s, r) => s + (r.wt ?? 0)),
  };

  void _clearEntryFields() {
    const keys = [
      'entryCutType',
      'entryCutNo',
      'entryPc',
      'entryWt',
      'entryComparisionCode',
      'entryPurityType',
    ];
    for (final k in keys) {
      _entryVals.remove(k);
      _erpFormKey.currentState?.updateFieldValue(k, '');
    }
    _erpFormKey.currentState?.updateFieldValue('entryAssortNo', _assortNo);
    Future.delayed(
      const Duration(milliseconds: 50),
      () => _erpFormKey.currentState?.focusField('entryCutType'),
    );
  }

  void _showSnack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  // ── ROW TAP ────────────────────────────────────────────────────────────────
  Future<void> _onRowTap(Map<String, dynamic> row) async {
    final raw = row['_raw'] as CutCreateModel;
    final prov = context.read<CutCreateProvider>();
    final details = await prov.loadDetails(raw.cutCreateMstID!);
    if (!mounted) return;

    // Set _selectedMst before loading assort totals so used-wt calc excludes this record
    setState(() => _selectedMst = raw);

    await _loadAssortTotals(raw.kapanNo ?? '');
    if (!mounted) return;

    setState(() {
      _selectedRow = row;
      _isEditMode = true;
      _detRows = details;
      _editingDetIndex = null;
      _formValues = {
        'cutCreateMstID': raw.cutCreateMstID?.toString() ?? '0',
        'cutCreateDate': toDisplayDate(raw.cutCreateDate),
        'kapanNo': raw.kapanNo ?? '',
        'jno': raw.jno?.toString() ?? '',
      };
      _syncDetGrid();
      if (Responsive.isMobile(context)) _showTableOnMobile = false;
    });
    _recalcPending();
  }

  // ── SAVE ───────────────────────────────────────────────────────────────────
  Future<void> _onSave(Map<String, dynamic> values) async {
    if (_detDisplay.isNotEmpty) {
      final prov = context.read<CutCreateProvider>();
      final merged = Map<String, dynamic>.from(values);
      merged['cutCreateDate'] = toUtcIso(merged['cutCreateDate']?.toString());
      merged['Sdate'] = DateTime.now().toUtc().toIso8601String();

      bool success;
      if (_isEditMode && _selectedMst != null) {
        success = await prov.update(
          _selectedMst!.cutCreateMstID!,
          merged,
          _detRows,
        );
      } else {
        success = await prov.create(merged, _detRows);
      }
      if (!mounted) return;
      if (success) {
        final wasEdit = _isEditMode;
        _resetForm();
        await ErpResultDialog.showSuccess(
          context: context,
          theme: _theme,
          title: wasEdit ? 'Updated' : 'Saved',
          message: wasEdit
              ? 'Cut Create Entry updated.'
              : 'Cut Create Entry saved.',
        );
      }
    }else {
      await ErpResultDialog.showError(
        context: context,
        theme: _theme,
        title: 'Entry Required',
        message:
        'Entry is required to proceed.\n'
            'Please enter entry before continuing.',
      );
    }
  }

  // ── DELETE ─────────────────────────────────────────────────────────────────
  Future<void> _onDelete() async {
    if (_selectedMst?.cutCreateMstID == null) return;
    final confirm = await ErpDeleteDialog.show(
      context: context,
      theme: _theme,
      title: 'Cut Create Entry',
      itemName: 'Kapan: ${_selectedMst!.kapanNo ?? ''}',
    );
    if (confirm != true || !mounted) return;
    final success = await context.read<CutCreateProvider>().delete(
      _selectedMst!.cutCreateMstID!,
      context
    );
    if (success && mounted) {
      final kno = _selectedMst?.kapanNo;
      _resetForm();
      await ErpResultDialog.showDeleted(
        context: context,
        theme: _theme,
        itemName: 'Cut Create $kno',
      );
    }
  }

  // ── RESET ──────────────────────────────────────────────────────────────────
  void _resetForm() {
    _erpFormKey.currentState?.resetForm();
    final today = DateFormat('dd/MM/yyyy').format(DateTime.now());
    _entryVals.clear();
    setState(() {
      _selectedRow = null;
      _selectedMst = null;
      _isEditMode = false;
      _showTableOnMobile = false;
      _detRows = [];
      _detDisplay = [];
      _editingDetIndex = null;
      _assortDets = [];
      _assortNo = '';
      _pendingPc = '0';
      _pendingWt = '0.000';
      _totalAssortWt = 0;
      _totalAssortPc = 0;
      _formValues = {'cutCreateDate': today, 'cutCreateMstID': '0'};
    });
  }

  // ── BUILD ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Consumer<CutCreateProvider>(
      builder: (ctx, prov, _) => Padding(
        padding: const EdgeInsets.all(8),
        child: Responsive.isMobile(context)
            ? _showTableOnMobile
                  ? _buildTable(prov)
                  : _buildForm(context, prov)
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _buildForm(context, prov)),
                  const SizedBox(width: 12),
                  Expanded(flex: 2, child: _buildTable(prov)),
                ],
              ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, CutCreateProvider cutProv) {
    final rap = context.watch<RoughAssortProvider>();

    return ErpForm(
      addButtonSections: const {1},
      logo: AppImages.logo,
      key: _erpFormKey,
      title: 'CUT CREATE ENTRY',
      tabBarBackgroundColor: const Color(0xfff2f0ef),
      tabBarSelectedColor: _theme.primaryGradient.first,
      tabBarSelectedTxtColor: Colors.white,
      rows: _formRows(rap, cutProv),
      initialValues: _formValues,
      isEditMode: _isEditMode,

      onEntryAdd: (sectionIndex) {
        if (sectionIndex == 1) _addDetEntry();
      },

      onFieldChanged: (key, value) {
        const masterFields = {
          'kapanNo',
          'cutCreateDate',
          'cutCreateMstID',
          'jno',
        };
        if (masterFields.contains(key)) {
          _formValues[key] = value.toString();
          if (key == 'kapanNo') _onKapanSelected(value.toString());
        } else {
          _entryVals[key] = value.toString();
        }
      },

      onExit: () => context.read<TabProvider>().closeCurrentTab(),
      onSave: _onSave,
      onCancel: _resetForm,
      onDelete: _isEditMode ? _onDelete : null,
      onSearch: () => setState(() => _showTableOnMobile = true),

      detailBuilder: (ctx) {
        final t = ctx.erpTheme;
        final tots = _footerTotals;
        debugPrint('UI PEND WT => $_pendingWt');
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info bar
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    t.primary.withOpacity(0.08),
                    t.accent.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: t.primary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  _infoChip(
                    t,
                    'PEND PC',
                    _pendingPc,
                    (int.tryParse(_pendingPc) ?? 0) < 0
                        ? Colors.red
                        : t.primary,
                  ),
                  const SizedBox(width: 16),
                  _infoChip(
                    t,
                    'PEND WT',
                    _pendingWt,
                    (double.tryParse(_pendingWt) ?? 0) < 0
                        ? Colors.red
                        : t.primary,
                  ),
                  const Spacer(),
                  if (_detRows.isNotEmpty) ...[
                    _infoChip(t, 'ROWS', '${_detRows.length}', t.primary),
                    const SizedBox(width: 16),
                    _infoChip(
                      t,
                      'TOT WT',
                      fThreeDecimal(tots['wt'] as double),
                      t.primary,
                    ),
                  ],
                ],
              ),
            ),

            ErpEntryGrid(
              data: _detDisplay,
              columns: _detGridColumns,
              title: 'CUT CREATE DETAILS',
              theme: t,
              onDeleteRow: _isEditMode ?null:_deleteDetRow,
              onEditRow: _editDetRow,
              editingIndex: _editingDetIndex,
              columnLabels: const {
                'srno': 'SR NO',
                'cutType': 'TYPE',
                'cutNo': 'CUT NO',
                'pc': 'PC',
                'wt': 'WT',
                'comparisionCode': 'COMPARISION CODE',
                'assortNo': 'ASSORT NO',
                'purityType': 'PURITY TYPE',
              },
            ),
        if (_detDisplay.isNotEmpty) ...[
          const SizedBox(height: 4),
          _buildFooterRow(t, tots),
        ]
          ],
        );
      },
    );
  }

  Widget _infoChip(ErpTheme t, String label, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label : ',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: t.textLight,
            letterSpacing: 0.4,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.10),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterRow(ErpTheme t, Map<String, dynamic> tots) {
    Widget cell(String label, String value) => Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 8,
                color: t.textLight,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: t.primary,
              ),
            ),
          ],
        ),
      ),
    );
    Widget blank() => Expanded(child: const SizedBox());

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [t.primary.withOpacity(0.06), t.accent.withOpacity(0.04)],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          top: BorderSide(color: t.primary.withOpacity(0.3), width: 1.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Text(
              'Tot:${tots['count']}',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: t.primary,
                letterSpacing: 0.5,
              ),
            ),
          ),
          blank(),
          const SizedBox(width: 35),
          cell('PC', '${tots['pc']}'),
          cell('WT', fThreeDecimal(tots['wt'] as double)),
          blank(),
          blank(),
          blank(),
          const SizedBox(width: 35),
          const SizedBox(width: 35),
        ],
      ),
    );
  }

  Widget _buildTable(CutCreateProvider prov) {
    final data = prov.list.map((e) => e.toTableRow()).toList();
    return ErpDataTable(
      isReportRow: false,
      token: token ?? '',
      url: baseUrl,
      title: 'CUT CREATE LIST',
      columns: _tableColumns,
      data: data,
      dateFilter: true,
      showSearch: true,
      searchFields: const [
        ErpSearchFieldConfig(key: 'kapanNo', label: 'KAPAN NO', width: 150),
        ErpSearchFieldConfig(key: 'jno', label: 'JNO', width: 120),
      ],
      selectedRow: _selectedRow,
      onRowTap: _onRowTap,
      emptyMessage: prov.isLoaded ? 'No entries found' : 'Loading...',
    );
  }
}
