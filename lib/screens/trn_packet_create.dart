// lib/screens/trn_packet_create_entry.dart

import 'package:collection/collection.dart';
import 'package:diam_mfg/models/cut_create_model.dart';
import 'package:diam_mfg/models/packet_model.dart';
import 'package:diam_mfg/providers/color_provider.dart';
import 'package:diam_mfg/providers/cut_create_provider.dart';
import 'package:diam_mfg/providers/fluo_provider.dart';
import 'package:diam_mfg/providers/packet_provider.dart';
import 'package:diam_mfg/providers/pkt_type_provider.dart';
import 'package:diam_mfg/providers/purity_provider.dart';
import 'package:diam_mfg/providers/tensions_provider.dart';
import 'package:diam_mfg/utils/app_images.dart';
import 'package:diam_mfg/utils/delete_dialogue.dart';
import 'package:diam_mfg/utils/helper_functions.dart';
import 'package:diam_mfg/utils/msg_dialogue.dart';
import 'package:erp_data_table/erp_data_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rs_dashboard/rs_dashboard.dart';

import '../bootstrap.dart';

// ── helpers ───────────────────────────────────────────────────────────────────
String _f3(double? v) => v == null ? '0.00' : v.toStringAsFixed(2);


// ── Lot group size ─────────────────────────────────────────────────────────────
const int _kLotSize = 20;

// ══════════════════════════════════════════════════════════════════════════════
class TrnPacketCreateEntry extends StatefulWidget {
  const TrnPacketCreateEntry({super.key});
  @override
  State<TrnPacketCreateEntry> createState() => _TrnPacketCreateEntryState();
}

class _TrnPacketCreateEntryState extends State<TrnPacketCreateEntry> {
  // ── theme ──────────────────────────────────────────────────────────────────
  final ErpThemeVariant _themeVariant = ErpThemeVariant.frost;
  ErpTheme get _theme => ErpTheme(_themeVariant);
  final GlobalKey<ErpFormState> _erpFormKey = GlobalKey<ErpFormState>();

  // ── selection ──────────────────────────────────────────────────────────────
  Map<String, dynamic>? _selectedRow;
  PacketMstModel?       _selectedMst;
  bool _isEditMode        = false;
  bool _showTableOnMobile = false;

  // ── master form values ─────────────────────────────────────────────────────
  Map<String, String> _formValues = {};

  // ── selected CutCreate record ──────────────────────────────────────────────
  CutCreateModel?           _selectedCut;
  List<CutCreateDetModel>   _cutDets     = []; // SPK details of selected cut
  double _pendingWt = 0;
  int    _pendingPc = 0;

  // ── detail rows ───────────────────────────────────────────────────────────
  List<PacketDetModel>       _detRows    = [];
  List<Map<String, dynamic>> _detDisplay = [];
  int? _editingDetIndex;

  // ── entry field values ─────────────────────────────────────────────────────
  final Map<String, String> _entryVals = {};

  // ── lotNo auto-increment per cutNo ────────────────────────────────────────
  // key = cutNo, value = last lotNo used
  final Map<String, int> _lotNoMap = {};

  final String? token = AppStorage.getString('token');

  // ══════════════════════════════════════════════════════════════════════════
  //  TABLE COLUMNS (right side list)
  // ══════════════════════════════════════════════════════════════════════════
  List<ErpColumnConfig> get _tableColumns => [
    ErpColumnConfig(key: 'packetMstID', label: 'ID',     width: 70,  required: true),
    ErpColumnConfig(key: 'packetDate',  label: 'DATE',   width: 110, required: true, isDate: true),
    ErpColumnConfig(key: 'cutNo',       label: 'CUT NO', width: 170),
    ErpColumnConfig(key: 'entryType',   label: 'TYPE',   width: 130),
    ErpColumnConfig(key: 'totalPc',     label: 'TOT PC',   width: 160,  align: ColumnAlign.right),  // ✅
    ErpColumnConfig(key: 'totalWt',     label: 'TOT WT',   width: 160, align: ColumnAlign.right),  // ✅
  ];

  // ══════════════════════════════════════════════════════════════════════════
  //  FORM ROWS
  // ══════════════════════════════════════════════════════════════════════════
  List<List<ErpFieldConfig>> _buildFormRows() {
    final cutProv     = context.read<CutCreateProvider>();
    final pktTypeProv = context.read<PktTypeProvider>();
    final colorProv   = context.read<ColorProvider>();
    final fluoProv    = context.read<FluoProvider>();
    final tensProv    = context.read<TensionsProvider>();
// _buildFormRows mein cutNoItems filter update karo:
    final cutNoItems = cutProv.list
        .where((cc) {
      if (!cc.details.any((d) => d.cutType == 'SPK')) return false;

      final spkDet = cc.details.firstWhere(
            (d) => d.cutType == 'SPK',
        orElse: () => cc.details.first,
      );

      // ✅ Edit mode mein current selected cutNo hamesha dikhao
      if (_isEditMode && spkDet.cutNo == _formValues['cutNo']) return true;

      final pendingWt = _getPendingWtForCut(cc);
      return pendingWt > 0.0001;
    })
        .map((cc) {
      final spkDet = cc.details.firstWhere(
            (d) => d.cutType == 'SPK',
        orElse: () => cc.details.first,
      );
      final pendingWt = _getPendingWtForCut(cc);
      return ErpDropdownItem(
        // ✅ Edit mode mein current cut ka label
        label: 'Cut: ${spkDet.cutNo ?? ''}  Pending WT: ${_f3(pendingWt)}',
        value: spkDet.cutNo ?? '',
      );
    })
        .fold<List<ErpDropdownItem>>([], (acc, item) {
      if (!acc.any((x) => x.value == item.value)) acc.add(item);
      return acc;
    });
    // ── CutNo dropdown — CutCreate records with SPK type det, pendingWt > 0 ──
    // final cutNoItems = cutProv.list
    //     .where((cc) =>
    // cc.details.any((d) => d.cutType == 'SPK'))
    //     // &&
    //     // _getPendingWtForCut(cc) > 0.0001)
    //     .map((cc) => ErpDropdownItem(
    //   label: 'Cut: ${cc.details.firstWhere((d) => d.cutType == 'SPK', orElse: () => cc.details.first).cutNo ?? ''}'
    //       '  WT: ${_f3(_getPendingWtForCut(cc))}',
    //   value: cc.details.firstWhere((d) => d.cutType == 'SPK', orElse: () => cc.details.first).cutNo ?? '',
    // ))
    //     .fold<List<ErpDropdownItem>>([], (acc, item) {
    //   if (!acc.any((x) => x.value == item.value)) acc.add(item);
    //   return acc;
    // });

    // ── PktType dropdown — active, sorted by sortID ──────────────────────────
    final pktTypeItems = pktTypeProv.list
        .where((e) => e.active == true)
        .toList()
      ..sort((a, b) => (a.sortID ?? 0).compareTo(b.sortID ?? 0));
    final pktTypeDropdown = pktTypeItems
        .map((e) => ErpDropdownItem(label: e.pktTypeName ?? '', value: e.pktTypeCode?.toString() ?? ''))
        .toList();

    // ── Color dropdown — active, sorted ──────────────────────────────────────
    final colorItems = colorProv.list
        .where((e) => e.active == true)
        .toList()
      ..sort((a, b) => (a.sortID ?? 0).compareTo(b.sortID ?? 0));
    final colorDropdown = colorItems
        .map((e) => ErpDropdownItem(label: e.colorName ?? '', value: e.colorCode?.toString() ?? ''))
        .toList();

    // ── Fluo dropdown ─────────────────────────────────────────────────────────
    final fluoItems = fluoProv.list
        .where((e) => e.active == true)
        .toList()
      ..sort((a, b) => (a.sortID ?? 0).compareTo(b.sortID ?? 0));
    final fluoDropdown = fluoItems
        .map((e) => ErpDropdownItem(label: e.fluoName ?? '', value: e.fluoCode?.toString() ?? ''))
        .toList();

    // ── Tensions dropdown ─────────────────────────────────────────────────────
    final tensItems = tensProv.list
        .where((e) => e.active == true)
        .toList()
      ..sort((a, b) => (a.sortID ?? 0).compareTo(b.sortID ?? 0));
    final tensDropdown = tensItems
        .map((e) => ErpDropdownItem(label: e.tensionsName ?? '', value: e.tensionsCode?.toString() ?? ''))
        .toList();

    return [
      // ── SECTION 0: MASTER ──────────────────────────────────────────────────
      [
        ErpFieldConfig(
          key: 'packetDate', label: 'DATE',
          type: ErpFieldType.date,
          readOnly: true, required: true, flex: 2,
          sectionTitle: 'PACKET CREATE ENTRY', sectionIndex: 0,
        ),
        ErpFieldConfig(
          key: 'packetMstID', label: 'ID',
          type: ErpFieldType.number,
          readOnly: true, flex: 1, sectionIndex: 0,
        ),
        ErpFieldConfig(
          key: 'cutNo', label: 'CUT NO',
          type: ErpFieldType.dropdown,
          dropdownItems: cutNoItems,
          required: true, flex: 2, sectionIndex: 0,
        ),
        ErpFieldConfig(
          key: 'pendPc', label: 'PEND PC',
          type: ErpFieldType.number,
          readOnly: true, flex: 1, sectionIndex: 0,
        ),
        ErpFieldConfig(
          key: 'pendWt', label: 'PEND WT',
          type: ErpFieldType.amount,
          readOnly: true, flex: 1, sectionIndex: 0,
        ),
      ],

      // ── SECTION 1: ENTRY ───────────────────────────────────────────────────
      [
        ErpFieldConfig(
          key: 'entryType', label: 'TYPE',
          type: ErpFieldType.dropdown,
          dropdownItems: pktTypeDropdown,
          flex: 1,
          sectionTitle: 'ENTRY', sectionIndex: 1,
          isEntryField: true, isEntryRequired: true,
        ),
        ErpFieldConfig(
          key: 'entryColor', label: 'COLOR',
          type: ErpFieldType.dropdown,
          dropdownItems: colorDropdown,
          flex: 1, sectionIndex: 1,
          isEntryField: true, isEntryRequired: true,
        ),
        ErpFieldConfig(
          key: 'entryTensions', label: 'ASS.TENSIONS',
          type: ErpFieldType.dropdown,
          dropdownItems: tensDropdown,
          flex: 1, sectionIndex: 1,
          isEntryField: true, isEntryRequired: true,
        ),
        ErpFieldConfig(
          key: 'entryFluo', label: 'FLUO',
          type: ErpFieldType.dropdown,
          dropdownItems: fluoDropdown,
          flex: 1, sectionIndex: 1,
          isEntryField: true, isEntryRequired: true,
        ),
        ErpFieldConfig(
          key: 'entryLotNo', label: 'LOT NO',
          type: ErpFieldType.number,
          flex: 1, sectionIndex: 1, isEntryField: true,
        ),
        ErpFieldConfig(
          key: 'entryPlusWt', label: 'PLUS WT',
          type: ErpFieldType.amount,
          readOnly: true, flex: 1, sectionIndex: 1, isEntryField: true,
        ),
        ErpFieldConfig(
          key: 'entryPc', label: 'PC',
          type: ErpFieldType.number,
          readOnly: true, flex: 1, sectionIndex: 1, isEntryField: true,
        ),
        // ErpFieldConfig(
        //   key: 'entryPdmPer', label: 'PDm %',
        //   type: ErpFieldType.amount,
        //   flex: 1, sectionIndex: 1, isEntryField: true,
        // ),
        ErpFieldConfig(
          key: 'entryWt', label: 'WT',
          type: ErpFieldType.amount,
          flex: 1, sectionIndex: 1,
          isEntryField: true, isEntryRequired: true,
          showAddButton: true,
        ),
      ],
    ];
  }
// Color, Tensions, Fluo ke liye alag helpers banao
  String _colorName(int? code) {
    if (code == null) return '';
    final list = context.read<ColorProvider>().list;
    try { return list.firstWhere((e) => e.colorCode == code).colorName ?? ''; }
    catch (_) { return ''; }
  }

  String _tensionsName(int? code) {
    if (code == null) return '';
    final list = context.read<TensionsProvider>().list;
    try { return list.firstWhere((e) => e.tensionsCode == code).tensionsName ?? ''; }
    catch (_) { return ''; }
  }

  String _fluoName(int? code) {
    if (code == null) return '';
    final list = context.read<FluoProvider>().list;
    try { return list.firstWhere((e) => e.fluoCode == code).fluoName ?? ''; }
    catch (_) { return ''; }
  }

  String _pktTypeName(String? code) {
    if (code == null || code.isEmpty) return '';
    final list = context.read<PktTypeProvider>().list;
    try { return list.firstWhere((e) => e.pktTypeCode?.toString() == code).pktTypeName ?? ''; }
    catch (_) { return code; }
  }
  // ══════════════════════════════════════════════════════════════════════════
  //  INIT
  // ══════════════════════════════════════════════════════════════════════════
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PacketProvider>().load();
      context.read<CutCreateProvider>().load();
      context.read<PktTypeProvider>().load();
      context.read<ColorProvider>().load();
      context.read<FluoProvider>().load();
      context.read<TensionsProvider>().load();
      context.read<PurityProvider>().load();
      _setDefaultFormValues();
    });
  }

  void _setDefaultFormValues() {
    final today = DateFormat('dd/MM/yyyy').format(DateTime.now());
    _formValues = {
      'packetDate':  today,
      'packetMstID': '0',
      'pendPc':      '0',
      'pendWt':      '0.000',
    };
    if (mounted) setState(() {});
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  PENDING WT CALC for a CutCreate record
  // ══════════════════════════════════════════════════════════════════════════
  double _getPendingWtForCut(CutCreateModel cc) {
    final totalWt = cc.details
        .where((d) => d.cutType == 'SPK')
        .fold(0.0, (s, d) => s + (d.wt ?? 0));

    final cutNo = cc.details
        .firstWhere((d) => d.cutType == 'SPK',
        orElse: () => cc.details.first)
        .cutNo;

    // ✅ Ab totalWt DB se aayega — 0 nahi hoga
    final usedWt = context.read<PacketProvider>().list
        .where((p) =>
    p.cutNo == cutNo &&
        p.packetMstID != _selectedMst?.packetMstID)
        .fold(0.0, (s, p) => s + p.totalWt);

    return totalWt - usedWt;
  }

  // ── CutNo selected ────────────────────────────────────────────────────────
  Future<void> _onCutNoSelected(String cutNo) async {
    final cutProv = context.read<CutCreateProvider>();

    // Find CutCreate record with this cutNo in SPK dets
    CutCreateModel? found;
    for (final cc in cutProv.list) {
      if (cc.details.any((d) => d.cutType == 'SPK' && d.cutNo == cutNo)) {
        found = cc;
        break;
      }
    }
    if (found == null) return;

    // Load full details if not loaded
    final details = found.details.isNotEmpty
        ? found.details
        : await cutProv.loadDetails(found.cutCreateMstID!);

    final spkDets = details.where((d) => d.cutType == 'SPK').toList();

    final totalWt  = spkDets.fold(0.0, (s, d) => s + (d.wt ?? 0));
    final totalPc  = spkDets.fold(0,   (s, d) => s + (d.pc ?? 0));

    // Already used in other Packet records
    final usedWt = context.read<PacketProvider>().list
        .where((p) =>
    p.cutNo == cutNo &&
        p.packetMstID != _selectedMst?.packetMstID)
        .fold(0.0, (s, p) => s + p.totalWt);
    final usedPc = context.read<PacketProvider>().list
        .where((p) =>
    p.cutNo == cutNo &&
        p.packetMstID != _selectedMst?.packetMstID)
        .fold(0, (s, p) => s + p.totalPc);

    // Used in current form det rows
    final formUsedWt = _detRows.fold(0.0, (s, r) => s + (r.wt ?? 0));
    final formUsedPc = _detRows.fold(0,   (s, r) => s + (r.pc ?? 0));

    final pendWt = totalWt  - usedWt  - formUsedWt;
    final pendPc = totalPc  - usedPc  - formUsedPc;

    _selectedCut = found;
    _cutDets     = spkDets;
    _pendingWt   = totalWt - usedWt;
    _pendingPc   = totalPc - usedPc;

    // plusWt = pendWt * 0.15 / 100
    final plusWt = pendWt * 0.15 / 100;

    _formValues['pendWt'] = _f3(pendWt);
    _formValues['pendPc'] = '$pendPc';

    _erpFormKey.currentState?.updateFieldValue('pendWt', _f3(pendWt));
    _erpFormKey.currentState?.updateFieldValue('pendPc', '$pendPc');

    // Auto-fill entry fields
    _entryVals['entryPc']     = '1';
    _entryVals['entryPlusWt'] = _f3(plusWt);
    _erpFormKey.currentState?.updateFieldValue('entryPc',     '1');
    _erpFormKey.currentState?.updateFieldValue('entryPlusWt', _f3(plusWt));

    // Auto lotNo for this cutNo
    final lastLot = _lotNoMap[cutNo] ?? 0;
    final nextLot = lastLot + 1;
    _entryVals['entryLotNo'] = '$nextLot';
    _erpFormKey.currentState?.updateFieldValue('entryLotNo', '$nextLot');
    final nextLotNo = await context.read<PacketProvider>().getNextLotNo(cutNo);
    _lotNoMap[cutNo] = nextLotNo - 1; // map mein last used store karo

    _entryVals['entryLotNo'] = '$nextLotNo';
    _erpFormKey.currentState?.updateFieldValue('entryLotNo', '$nextLotNo');

    setState(() {});
  }

  // ── Recalc pending after det change ──────────────────────────────────────
  void _recalcPending() {
    final formUsedWt = _detRows.fold(0.0, (s, r) => s + (r.wt ?? 0));
    final formUsedPc = _detRows.fold(0,   (s, r) => s + (r.pc ?? 0));
    final pendWt = _pendingWt - formUsedWt;
    final pendPc = _pendingPc - formUsedPc;

    _formValues['pendWt'] = _f3(pendWt);
    _formValues['pendPc'] = '$pendPc';
    _erpFormKey.currentState?.updateFieldValue('pendWt', _f3(pendWt));
    _erpFormKey.currentState?.updateFieldValue('pendPc', '$pendPc');

    // Update plusWt based on new pendWt
    final plusWt = pendWt * 0.15 / 100;
    _entryVals['entryPlusWt'] = _f3(plusWt);
    _erpFormKey.currentState?.updateFieldValue('entryPlusWt', _f3(plusWt));
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  ADD ENTRY
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> _addEntry() async {
    final typeVal    = _entryVals['entryType']     ?? '';
    final colorVal   = _entryVals['entryColor']    ?? '';
    final tensVal    = _entryVals['entryTensions']  ?? '';
    final fluoVal    = _entryVals['entryFluo']     ?? '';
    final lotNoStr   = _entryVals['entryLotNo']    ?? '';
    final wtStr      = _entryVals['entryWt']       ?? '';
    // final pdmPerStr  = _entryVals['entryPdmPer']   ?? '';
    final cutNo      = _formValues['cutNo']        ?? '';

    // ── Validations ───────────────────────────────────────────────────────
    if (cutNo.isEmpty) {
      _showSnack('Please select a Cut No first');
      return;
    }
    if (typeVal.isEmpty) {
      _showSnack('Type required');
      _erpFormKey.currentState?.focusField('entryType');
      return;
    }
    if (colorVal.isEmpty) {
      _showSnack('Color required');
      _erpFormKey.currentState?.focusField('entryColor');
      return;
    }
    if (tensVal.isEmpty) {
      _showSnack('Tensions required');
      _erpFormKey.currentState?.focusField('entryTensions');
      return;
    }
    if (fluoVal.isEmpty) {
      _showSnack('Fluo required');
      _erpFormKey.currentState?.focusField('entryFluo');
      return;
    }
    if (wtStr.isEmpty) {
      _showSnack('Weight required');
      _erpFormKey.currentState?.focusField('entryWt');
      return;
    }

    final lotNo  = int.tryParse(lotNoStr) ?? 1;
    final entryWt = double.tryParse(wtStr) ?? 0;

    // ── Duplicate LotNo check (per cutNo) ────────────────────────────────
    final isDuplicate = _detRows.asMap().entries.any(
          (e) =>
      e.value.lotNo == lotNo &&
          e.value.cutNo == cutNo &&
          e.key != _editingDetIndex,
    );
    if (isDuplicate) {
      await ErpResultDialog.showError(
        context: context, theme: _theme,
        title: 'Duplicate Lot No',
        message: 'Lot No $lotNo already exists for Cut No $cutNo.\nPlease use a different Lot No.',
      );
      _erpFormKey.currentState?.focusField('entryLotNo');
      return;
    }

    // ── Wt validation ─────────────────────────────────────────────────────
    final oldWt = _editingDetIndex != null
        ? (_detRows[_editingDetIndex!].wt ?? 0)
        : 0.0;
    final formUsedWt = _detRows.fold(0.0, (s, r) => s + (r.wt ?? 0)) - oldWt;
    final pendWt = _pendingWt - formUsedWt;

    if (entryWt > pendWt + 0.0001) {
      await ErpResultDialog.showError(
        context: context, theme: _theme,
        title: 'Weight Exceeded',
        message:
        'Entry Wt (${_f3(entryWt)}) exceeds Pending Wt (${_f3(pendWt)}).\n'
            'Please reduce weight.',
      );
      _erpFormKey.currentState?.focusField('entryWt');
      return;
    }

    final srno = _editingDetIndex != null
        ? _detRows[_editingDetIndex!].srno
        : _detRows.length + 1;

    final newRow = PacketDetModel(
      srno:         srno,
      cutNo:        cutNo,
      lotNo:        lotNo,
      lotCode:      'A',
      pc:           1,
      wt:           entryWt,
      pktType:      typeVal,
      colorCode:    int.tryParse(colorVal),
      tensionsCode: int.tryParse(tensVal),
      fluoCode:     int.tryParse(fluoVal),
      // pDmPer:       double.tryParse(pdmPerStr),
      jno:          int.tryParse(_formValues['jno'] ?? ''),
      packetDate:   _formValues['packetDate'],
      entryType:    'Packet Create',
      lastProcess:  'PACKET CREATE',
      pktValid:     'Y',
    );

    setState(() {
      if (_editingDetIndex != null) {
        _detRows[_editingDetIndex!] = newRow;
        _editingDetIndex = null;
      } else {
        _detRows.add(newRow);
      }
      // Update lotNo map
      _lotNoMap[cutNo] = lotNo;
      _syncDetGrid();
    });

    _recalcPending();

    // ── Partial clear: keep type/color/tensions/fluo, clear only pdm% and wt
    _partialClearEntry(nextLotNo: lotNo + 1);
  }

  // ── Partial clear — keep type/color/tensions/fluo ──────────────────────
  void _partialClearEntry({required int nextLotNo}) {
    // Clear only pdm% and wt
    // _entryVals.remove('entryPdmPer');
    _entryVals.remove('entryWt');
    // _erpFormKey.currentState?.updateFieldValue('entryPdmPer', '');
    _erpFormKey.currentState?.updateFieldValue('entryWt', '');

    // Advance lotNo
    _entryVals['entryLotNo'] = '$nextLotNo';
    _erpFormKey.currentState?.updateFieldValue('entryLotNo', '$nextLotNo');

    // Recalc plusWt with updated pending
    final formUsedWt = _detRows.fold(0.0, (s, r) => s + (r.wt ?? 0));
    final pendWt     = _pendingWt - formUsedWt;
    final plusWt     = pendWt * 0.15 / 100;
    _entryVals['entryPlusWt'] = _f3(plusWt);
    _erpFormKey.currentState?.updateFieldValue('entryPlusWt', _f3(plusWt));

    Future.delayed(const Duration(milliseconds: 50),
            () => _erpFormKey.currentState?.focusField('entryWt'));
  }

  // ── Edit det row ──────────────────────────────────────────────────────────
  void _editDetRow(int idx) {
    final r = _detRows[idx];
    setState(() => _editingDetIndex = idx);

    void set(String k, String? v) {
      _entryVals[k] = v ?? '';
      _erpFormKey.currentState?.updateFieldValue(k, v ?? '');
    }

    set('entryType',     r.pktType);
    set('entryColor',    r.colorCode?.toString());
    set('entryTensions', r.tensionsCode?.toString());
    set('entryFluo',     r.fluoCode?.toString());
    set('entryLotNo',    r.lotNo?.toString());
    // set('entryPdmPer',   _f2(r.pDmPer));
    set('entryWt',       _f3(r.wt));
    set('entryPc',       '1');

    final formUsedWt = _detRows.fold(0.0, (s, d) => s + (d.wt ?? 0)) - (r.wt ?? 0);
    final pendWt     = _pendingWt - formUsedWt;
    set('entryPlusWt', _f3(pendWt * 0.15 / 100));

    Future.delayed(const Duration(milliseconds: 50),
            () => _erpFormKey.currentState?.focusField('entryType'));
  }

  void _deleteDetRow(int idx) {
    setState(() {
      _detRows.removeAt(idx);
      _detRows = _detRows.asMap().entries
          .map((e) => PacketDetModel(
        srno:         e.key + 1,
        packetMstID:  e.value.packetMstID,
        cutNo:        e.value.cutNo,
        lotNo:        e.value.lotNo,
        lotCode:      e.value.lotCode,
        pc:           e.value.pc,
        wt:           e.value.wt,
        pktType:      e.value.pktType,
        colorCode:    e.value.colorCode,
        tensionsCode: e.value.tensionsCode,
        fluoCode:     e.value.fluoCode,
        pDmPer:       e.value.pDmPer,
        jno:          e.value.jno,
        packetDate:   e.value.packetDate,
        entryType:    e.value.entryType,
        lastProcess:  e.value.lastProcess,
        pktValid:     e.value.pktValid,
      ))
          .toList();
      _syncDetGrid();
      if (_editingDetIndex == idx) _editingDetIndex = null;
    });
    _recalcPending();
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  SYNC DISPLAY GRID
  // ══════════════════════════════════════════════════════════════════════════
  void _syncDetGrid() {
    _detDisplay = _detRows.map((r) {

      return {
        'bCode':    r.bCode?.toString()    ?? '',
        'srno':     r.srno?.toString()     ?? '',
        'lotNo':    r.lotNo?.toString()    ?? '',
        'lotCode':  r.lotCode              ?? 'A',
        'pc':       r.pc?.toString()       ?? '',
        'wt':       _f3(r.wt),
        'pktType':  _pktTypeName(r.pktType),  // ✅ name
        'color':    _colorName(r.colorCode),   // ✅ name
        'tensions': _tensionsName(r.tensionsCode), // ✅ name
        'fluo':     _fluoName(r.fluoCode),
        // 'pdmPer':   _f2(r.pDmPer),
      };
    }).toList();
  }

  String _nameFromCode(List<dynamic> list, int? code) {
    if (code == null) return '';
    try {
      final item = list.firstWhere((e) => e.code == code);
      return item.name ?? '';
    } catch (_) {
      return '';
    }
  }

  List<String> get _detGridColumns => [
    'bCode', 'srno', 'lotNo', 'lotCode', 'pc', 'wt',
    'pktType', 'color', 'tensions', 'fluo',
    // 'pdmPer',
  ];

  // ══════════════════════════════════════════════════════════════════════════
  //  LOT GROUP SUMMARY (every _kLotSize rows)
  // ══════════════════════════════════════════════════════════════════════════
  // Returns list of group summaries: each group has { srFrom, srTo, pc, wt }
  List<Map<String, dynamic>> get _lotGroupSummaries {
    if (_detRows.isEmpty) return [];
    final groups = <Map<String, dynamic>>[];
    for (int i = 0; i < _detRows.length; i += _kLotSize) {
      final chunk = _detRows.sublist(
        i,
        (i + _kLotSize) < _detRows.length ? (i + _kLotSize) : _detRows.length,
      );
      groups.add({
        'srFrom': i + 1,
        'srTo':   i + chunk.length,
        'pc':     chunk.fold(0,   (s, r) => s + (r.pc ?? 0)),
        'wt':     chunk.fold(0.0, (s, r) => s + (r.wt ?? 0)),
      });
    }
    return groups;
  }

  Map<String, dynamic> get _footerTotals => {
    'count': _detRows.length,
    'pc':    _detRows.fold(0,   (s, r) => s + (r.pc ?? 0)),
    'wt':    _detRows.fold(0.0, (s, r) => s + (r.wt ?? 0)),
  };

  // ══════════════════════════════════════════════════════════════════════════
  //  UTILS
  // ══════════════════════════════════════════════════════════════════════════
  void _showSnack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  // ══════════════════════════════════════════════════════════════════════════
  //  ROW TAP
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> _onRowTap(Map<String, dynamic> row) async {
    final raw     = row['_raw'] as PacketMstModel;
    final prov    = context.read<PacketProvider>();
    final details = await prov.loadDetails(raw.packetMstID!);
    if (!mounted) return;

    setState(() => _selectedMst = raw);
    if (raw.cutNo != null) await _onCutNoSelected(raw.cutNo!);
    if (!mounted) return;

    setState(() {
      _selectedRow     = row;
      _isEditMode      = true;
      _detRows         = details;
      _editingDetIndex = null;
      _formValues = {
        'packetMstID': raw.packetMstID?.toString() ?? '0',
        'packetDate':  toDisplayDate(raw.packetDate),
        'cutNo':       raw.cutNo ?? '',
        'pendWt':      _f3(_pendingWt - details.fold(0.0, (s, r) => s + (r.wt ?? 0))),
        'pendPc':      '${_pendingPc  - details.fold(0,   (s, r) => s + (r.pc ?? 0))}',
      };
      _syncDetGrid();
      if (Responsive.isMobile(context)) _showTableOnMobile = false;
    });
    for (final det in details) {
      if (det.cutNo != null && det.lotNo != null) {
        final current = _lotNoMap[det.cutNo!] ?? 0;
        if (det.lotNo! > current) {
          _lotNoMap[det.cutNo!] = det.lotNo!;
        }
      }
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  SAVE
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> _onSave(Map<String, dynamic> values) async {
    final prov = context.read<PacketProvider>();

    String toIso(String? v) {
      if (v == null || v.isEmpty) return '';
      try {
        return DateFormat('yyyy-MM-dd').format(DateFormat('dd/MM/yyyy').parse(v));
      } catch (_) { return v; }
    }

    final merged = Map<String, dynamic>.from(values);
    merged['packetDate'] = toIso(merged['packetDate']?.toString());
    merged['cutNo']      = _formValues['cutNo'] ?? '';

    bool success;
    if (_isEditMode && _selectedMst != null) {
      success = await prov.update(_selectedMst!.packetMstID!, merged, _detRows);
    } else {
      success = await prov.create(merged, _detRows);
    }
    if (!mounted) return;
    if (success) {
      final wasEdit = _isEditMode;
      _resetForm();
      await ErpResultDialog.showSuccess(
        context: context, theme: _theme,
        title:   wasEdit ? 'Updated' : 'Saved',
        message: wasEdit ? 'Packet Create updated.' : 'Packet Create saved.',
      );
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  DELETE
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> _onDelete() async {
    if (_selectedMst?.packetMstID == null) return;
    final confirm = await ErpDeleteDialog.show(
      context: context, theme: _theme,
      title:    'Packet Create',
      itemName: 'Cut: ${_selectedMst!.cutNo ?? ''}',
    );
    if (confirm != true || !mounted) return;
    final success = await context.read<PacketProvider>().delete(_selectedMst!.packetMstID!);
    if (success && mounted) {
      final cn = _selectedMst?.cutNo;
      _resetForm();
      await ErpResultDialog.showDeleted(context: context, theme: _theme, itemName: 'Packet $cn');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  RESET
  // ══════════════════════════════════════════════════════════════════════════
  void _resetForm() {
    _erpFormKey.currentState?.resetForm();
    final today = DateFormat('dd/MM/yyyy').format(DateTime.now());
    _entryVals.clear();
    setState(() {
      _selectedRow       = null;
      _selectedMst       = null;
      _isEditMode        = false;
      _showTableOnMobile = false;
      _detRows           = [];
      _detDisplay        = [];
      _editingDetIndex   = null;
      _selectedCut       = null;
      _cutDets           = [];
      _pendingWt         = 0;
      _pendingPc         = 0;
      _lotNoMap.clear();
      _formValues = {
        'packetDate':  today,
        'packetMstID': '0',
        'pendPc':      '0',
        'pendWt':      '0.000',
      };
    });
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Consumer<PacketProvider>(
      builder: (ctx, prov, _) => Padding(
        padding: const EdgeInsets.all(8),
        child: Responsive.isMobile(context)
            ? _showTableOnMobile
            ? _buildTable(prov)
            : _buildForm(context)
            : Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: _buildForm(context)),
            const SizedBox(width: 12),
            Expanded(flex: 2, child: _buildTable(prov)),
          ],
        ),
      ),
    );
  }

  // ── ErpForm ────────────────────────────────────────────────────────────────
  Widget _buildForm(BuildContext context) {
    return ErpForm(
      screenName: 'PACKET_CREATE_ENTRY',
      addButtonSections: const {1},
      logo:       AppImages.logo,
      key:        _erpFormKey,
      title:      'PACKET CREATE ENTRY',
      tabBarBackgroundColor:  const Color(0xfff2f0ef),
      tabBarSelectedColor:    _theme.primaryGradient.first,
      tabBarSelectedTxtColor: Colors.white,
      rows:          _buildFormRows(),
      initialValues: _formValues,
      isEditMode:    _isEditMode,

      // ── Extra actions: Open Port / Close Port ──────────────────────────
      // extraActions: [
      //   ErpThemeIconButton(
      //     // label: 'Open Port',
      //     icon:  Icons.usb,
      //     onPressed: () {
      //       // TODO: implement serial port open
      //       _showSnack('Open Port tapped');
      //     }, tooltip: 'Open Port', activeColor: Colors.blue,
      //   ),
      //   ErpThemeIconButton(
      //     // label: 'Close Port',
      //     icon:  Icons.usb_off,
      //     onPressed: () {
      //       // TODO: implement serial port close
      //       _showSnack('Close Port tapped');
      //     }, tooltip: 'Close Port', activeColor: Colors.blue,
      //   ),
      // ],

      onEntryAdd: (sectionIndex) {
        if (sectionIndex == 1) _addEntry();
      },

      onFieldChanged: (key, value) {
        const masterFields = {'packetDate', 'packetMstID', 'cutNo', 'pendPc', 'pendWt'};
        if (masterFields.contains(key)) {
          _formValues[key] = value.toString();
          if (key == 'cutNo') _onCutNoSelected(value.toString());
        } else {
          _entryVals[key] = value.toString();
        }
      },

      onExit:   () => context.read<TabProvider>().closeCurrentTab(),
      onSave:   _onSave,
      onCancel: _resetForm,
      onDelete: _isEditMode ? _onDelete : null,
      onSearch: () => setState(() => _showTableOnMobile = true),

      detailBuilder: (ctx) {
        final t    = ctx.erpTheme;
        final tots = _footerTotals;
        final groups = _lotGroupSummaries;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Main grid ────────────────────────────────────────────────
            if (_detDisplay.isNotEmpty) ...[
              ErpEntryGrid(
                data:         _detDisplay,
                columns:      _detGridColumns,
                title:        'PACKET DETAILS',
                theme:        t,
                onDeleteRow:  _deleteDetRow,
                onEditRow:    _editDetRow,
                editingIndex: _editingDetIndex,
                columnLabels: const {
                  'bCode':    'BCODE',
                  'srno':     'SR NO',
                  'lotNo':    'LOT NO',
                  'lotCode':  'LOT CODE',
                  'pc':       'PC',
                  'wt':       'WT',
                  'pktType':  'PKT TYPE',
                  'color':    'COLOR',
                  'tensions': 'TENSIONS',
                  'fluo':     'FLUO',
                  // 'pdmPer':   'PDm %',
                },
              ),

              // ── Footer totals row ──────────────────────────────────────
              const SizedBox(height: 4),
              _buildFooterRow(t, tots),

              // ── Lot group summary (every 20) ──────────────────────────
              if (groups.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildGroupSummary(t, groups),
              ],
            ],
          ],
        );
      },
    );
  }

  // ── Footer row ─────────────────────────────────────────────────────────────
  Widget _buildFooterRow(ErpTheme t, Map<String, dynamic> tots) {
    Widget cell(String label, String value) => Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(label, style: TextStyle(fontSize: 8, color: t.textLight,
                fontWeight: FontWeight.w700, letterSpacing: 0.4)),
            const SizedBox(height: 2),
            Text(value, style: TextStyle(fontSize: 11,
                fontWeight: FontWeight.w700, color: t.primary)),
          ],
        ),
      ),
    );
    Widget blank() => Expanded(child: const SizedBox());

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          t.primary.withOpacity(0.06), t.accent.withOpacity(0.04),
        ]),
        borderRadius: BorderRadius.circular(8),
        border: Border(top: BorderSide(color: t.primary.withOpacity(0.3), width: 1.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Text('Tot:${tots['count']}',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
                    color: t.primary, letterSpacing: 0.5)),
          ),
          blank(), blank(), blank(),
          cell('PC', '${tots['pc']}'),
          cell('WT', _f3(tots['wt'] as double)),
          blank(), blank(), blank(), blank(), blank(),
          const SizedBox(width: 35),
          const SizedBox(width: 35),
        ],
      ),
    );
  }

  // ── Lot group summary widget ───────────────────────────────────────────────
  // Shows running totals every 20 entries: Sr No | Pc | Wt
  Widget _buildGroupSummary(ErpTheme t, List<Map<String, dynamic>> groups) {
    return Container(
      decoration: BoxDecoration(
        color: t.primary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: t.primary.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: t.primary.withOpacity(0.10),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: [
                Expanded(flex: 2,
                    child: Text('SR NO', style: TextStyle(fontSize: 10,
                        fontWeight: FontWeight.w800, color: t.primary, letterSpacing: 0.5))),
                Expanded(child: Text('PC', textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: t.primary))),
                Expanded(child: Text('WT', textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: t.primary))),
              ],
            ),
          ),
          // Group rows
          ...groups.map((g) {
            final isLast = g == groups.last;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                border: isLast ? null : Border(
                  bottom: BorderSide(color: t.primary.withOpacity(0.08)),
                ),
              ),
              child: Row(
                children: [
                  Expanded(flex: 2,
                      child: Text('${g['srFrom']} – ${g['srTo']}',
                          style: TextStyle(fontSize: 11, color: t.primary,
                              fontWeight: FontWeight.w600))),
                  Expanded(
                      child: Text('${g['pc']}', textAlign: TextAlign.right,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                              color: t.primary))),
                  Expanded(
                      child: Text(_f3(g['wt'] as double), textAlign: TextAlign.right,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                              color: t.primary))),
                ],
              ),
            );
          }),
          // Grand total row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: t.primary.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
              border: Border(top: BorderSide(color: t.primary.withOpacity(0.2), width: 1.5)),
            ),
            child: Row(
              children: [
                Expanded(flex: 2,
                    child: Text('Tot:${groups.length} groups',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
                            color: t.primary))),
                Expanded(
                    child: Text(
                      '${groups.fold(0, (s, g) => s + (g['pc'] as int))}',
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: t.primary),
                    )),
                Expanded(
                    child: Text(
                      _f3(groups.fold(0.0, (s, g) => s! + (g['wt'] as double))),
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: t.primary),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── ErpDataTable ───────────────────────────────────────────────────────────
  Widget _buildTable(PacketProvider prov) {
    final pktTypeProv = context.read<PktTypeProvider>();

    // final data = prov.list.map((e) => e.toTableRow()).toList();
    final data = prov.list.map((e) {
      final row = e.toTableRow();
      // ✅ entryType code → name
      row['entryType'] = pktTypeProv.list
          .firstWhereOrNull((p) => p.pktTypeName == e.entryType || p.pktTypeCode?.toString() == e.entryType)
          ?.pktTypeName ?? e.entryType ?? '';
      return row;
    }).toList();
    return ErpDataTable(
      isReportRow: false,
      dateFilter: true,

      token:       token ?? '',
      url:         baseUrl,
      title:       'PACKET CREATE LIST',
      columns:     _tableColumns,
      data:        data,
      showSearch:  true,
      searchFields: const [
        ErpSearchFieldConfig(key: 'cutNo',    label: 'CUT NO',    width: 150),
        // ErpSearchFieldConfig(key: 'entryType', label: 'ENTRY TYPE', width: 120),
      ],
      selectedRow: _selectedRow,
      onRowTap:    _onRowTap,
      emptyMessage: prov.isLoaded ? 'No entries found' : 'Loading...',
    );
  }
}