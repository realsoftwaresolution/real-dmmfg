// import 'package:diam_mfg/models/rough_assort_model.dart';
// import 'package:diam_mfg/providers/purity_group_provider.dart';
// import 'package:diam_mfg/providers/rough_assort_provider.dart';
// import 'package:diam_mfg/providers/rough_provider.dart';
// import 'package:diam_mfg/utils/app_images.dart';
// import 'package:diam_mfg/utils/delete_dialogue.dart';
// import 'package:diam_mfg/utils/helper_functions.dart';
// import 'package:diam_mfg/utils/msg_dialogue.dart';
// import 'package:erp_data_table/erp_data_table.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:rs_dashboard/rs_dashboard.dart';
//
// import '../models/purity_group_model.dart';
// import '../models/rough_model.dart';
//
// // ─── field fmt helpers ────────────────────────────────────────────────────────
// String _f2(double? v) => v == null ? '' : v.toStringAsFixed(2);
// String _f3(double? v) => v == null ? '' : v.toStringAsFixed(2);
// double _d(dynamic v)  => v == null ? 0 : (double.tryParse(v.toString()) ?? 0);
//
// // ══════════════════════════════════════════════════════════════════════════════
// class TrnRoughAssortEntry extends StatefulWidget {
//   const TrnRoughAssortEntry({super.key});
//
//   @override
//   State<TrnRoughAssortEntry> createState() => _TrnRoughAssortEntryState();
// }
//
// class _TrnRoughAssortEntryState extends State<TrnRoughAssortEntry> {
//   // ── theme ──────────────────────────────────────────────────────────────────
//   final ErpThemeVariant _themeVariant = ErpThemeVariant.frost;
//   ErpTheme get _theme => ErpTheme(_themeVariant);
//
//   final GlobalKey<ErpFormState> _erpFormKey = GlobalKey<ErpFormState>();
//
//   // ── selection ──────────────────────────────────────────────────────────────
//   Map<String, dynamic>? _selectedRow;
//   RoughAssortModel?     _selectedMst;
//   bool                  _isEditMode        = false;
//   bool                  _showTableOnMobile = false;
//
//   // ── master form values ─────────────────────────────────────────────────────
//   Map<String, String> _formValues = {};
//
//   // ── master calculated display ──────────────────────────────────────────────
//   String _pendingWt = '0.000';   // KnoWt − totalWt
//   String _knoWt     = '0.000';   // selected kapan totWt
//
//   // ── detail rows ───────────────────────────────────────────────────────────
//   List<RoughAssortDetModel>   _detRows     = [];
//   List<Map<String, dynamic>>  _detDisplay  = [];
//   int? _editingDetIndex;
//
//   // ── entry field values (current row being typed) ──────────────────────────
//   // These mirror ErpForm entry fields; we maintain them separately for calc.
//   final Map<String, String> _entryVals = {};
//
//   // ── entry calculated (read-only display in entry row) ─────────────────────
//   final Map<String, String> _entryCalc = {};
//
//   final String? token = AppStorage.getString('token');
//
//   // ══════════════════════════════════════════════════════════════════════════
//   //  TABLE COLUMNS
//   // ══════════════════════════════════════════════════════════════════════════
//   List<ErpColumnConfig> get _tableColumns => [
//     ErpColumnConfig(key: 'roughAssortMstID', label: 'ID',      width: 70,  required: true),
//     ErpColumnConfig(key: 'roughAssortDate',  label: 'DATE',    width: 110, required: true, isDate: true),
//     ErpColumnConfig(key: 'kapanNo',          label: 'KAPAN',   width: 120),
//     ErpColumnConfig(key: 'jno',              label: 'JNO',     width: 90),
//     ErpColumnConfig(key: 'remarks',          label: 'REMARKS', width: 200),
//   ];
//
//   // ══════════════════════════════════════════════════════════════════════════
//   //  FORM ROWS
//   // ══════════════════════════════════════════════════════════════════════════
//   List<List<ErpFieldConfig>> _formRows(RoughProvider rp) {
//     // KapanNo dropdown: unique kapanNo from rough list
//     final kapanItems = rp.roughs
//         .where((e) => e.kapanNo != null && e.kapanNo!.isNotEmpty)
//         .map((e) => ErpDropdownItem(
//       label: '${e.kapanNo!}  (JNO: ${e.jno ?? ''})',
//       value: e.kapanNo!,
//     ))
//         .fold<List<ErpDropdownItem>>([], (acc, item) {
//       if (!acc.any((x) => x.value == item.value)) acc.add(item);
//       return acc;
//     });
//
//     return [
//       // SECTION 0: MASTER
//       [
//         ErpFieldConfig(
//           key: 'kapanNo', label: 'KAPAN NO',
//           type: ErpFieldType.dropdown,
//           dropdownItems: kapanItems,
//           required: true, flex: 2,
//           sectionTitle: 'ROUGH ASSORT ENTRY', sectionIndex: 0,
//         ),
//         ErpFieldConfig(
//           key: 'jno', label: 'JNO',
//           type: ErpFieldType.number,
//           readOnly: true, flex: 1, sectionIndex: 0,
//         ),
//         ErpFieldConfig(
//           key: 'roughAssortDate', label: 'DATE',
//           type: ErpFieldType.date,
//           required: true, flex: 1, sectionIndex: 0,
//         ),
//         ErpFieldConfig(
//           key: 'roughAssortMstID', label: 'ID',
//           type: ErpFieldType.number,
//           readOnly: true, flex: 1, sectionIndex: 0,
//         ),
//       ],
//       [
//         ErpFieldConfig(
//           key: 'remarks', label: 'REMARKS',
//           maxLines: 1, flex: 3, sectionIndex: 0,
//         ),
//       ],
//
//       // SECTION 1: ENTRY
//       // Row 1: editable fields
//       [
//         ErpFieldConfig(
//           key: 'purityCode', label: 'PURITY',
//           type: ErpFieldType.dropdown,
//           dropdownItems: const [], // runtime me fill hoga (didUpdateWidget se)
//           flex: 2,
//           sectionTitle: 'ENTRY', sectionIndex: 1,
//           isEntryField: true, isEntryRequired: true,
//         ),
//         ErpFieldConfig(
//           key: 'entryPc', label: 'PC',
//           type: ErpFieldType.number,
//           flex: 1, sectionIndex: 1, isEntryField: true,
//         ),
//         ErpFieldConfig(
//           key: 'entryWt', label: 'WT',
//           type: ErpFieldType.amount,
//           flex: 1, sectionIndex: 1, isEntryField: true, isEntryRequired: true,
//         ),
//         ErpFieldConfig(
//           key: 'entryPer', label: '%',
//           type: ErpFieldType.amount,
//           flex: 1, sectionIndex: 1, isEntryField: true,
//         ),
//         ErpFieldConfig(
//           key: 'entryExRate', label: 'EX RATE',
//           type: ErpFieldType.amount,
//           flex: 1, sectionIndex: 1, isEntryField: true,
//         ),
//         ErpFieldConfig(
//           key: 'entryRateDollar', label: 'RATE \$',
//           type: ErpFieldType.amount,
//           flex: 1, sectionIndex: 1, isEntryField: true,
//         ),
//         ErpFieldConfig(
//           key: 'entryAmtDollar', label: 'AMT \$',
//           type: ErpFieldType.amount,
//           readOnly: true, flex: 1, sectionIndex: 1, isEntryField: true,
//           helperText: 'Wt × Rate\$',
//         ),
//         ErpFieldConfig(
//           key: 'entryLabRateD', label: 'LAB RATE \$',
//           type: ErpFieldType.amount,
//           flex: 1, sectionIndex: 1, isEntryField: true,
//         ),
//         ErpFieldConfig(
//           key: 'entryLabAmtD', label: 'LAB AMT \$',
//           type: ErpFieldType.amount,
//           readOnly: true, flex: 1, sectionIndex: 1, isEntryField: true,
//           helperText: 'Wt × LabRate\$',
//         ),
//       ],
//       // Row 2: read-only calc fields
//       [
//         ErpFieldConfig(
//           key: 'entryRateRs', label: 'RATE RS',
//           type: ErpFieldType.amount,
//           readOnly: true, flex: 1, sectionIndex: 1, isEntryField: true,
//           helperText: 'ExRate × Rate\$',
//         ),
//         ErpFieldConfig(
//           key: 'entryAmtRs', label: 'AMT RS',
//           type: ErpFieldType.amount,
//           readOnly: true, flex: 1, sectionIndex: 1, isEntryField: true,
//           helperText: 'RateRs × Wt',
//         ),
//         ErpFieldConfig(
//           key: 'entryLabRateRs', label: 'LAB RATE RS',
//           type: ErpFieldType.amount,
//           readOnly: true, flex: 1, sectionIndex: 1, isEntryField: true,
//           helperText: 'LabRate\$ × ExRate',
//         ),
//         ErpFieldConfig(
//           key: 'entryLabAmtRs', label: 'LAB AMT RS',
//           type: ErpFieldType.amount,
//           readOnly: true, flex: 1, sectionIndex: 1, isEntryField: true,
//           helperText: 'LabRateRs × Wt',
//         ),
//         ErpFieldConfig(
//           key: 'entryTotRateD', label: 'TOT RATE \$',
//           type: ErpFieldType.amount,
//           readOnly: true, flex: 1, sectionIndex: 1, isEntryField: true,
//           helperText: 'TotAmt\$ / Wt',
//         ),
//         ErpFieldConfig(
//           key: 'entryTotAmtD', label: 'TOT AMT \$',
//           type: ErpFieldType.amount,
//           readOnly: true, flex: 1, sectionIndex: 1, isEntryField: true,
//           helperText: 'Amt\$ + LabAmt\$',
//         ),
//         ErpFieldConfig(
//           key: 'entryTotRateRs', label: 'TOT RATE RS',
//           type: ErpFieldType.amount,
//           readOnly: true, flex: 1, sectionIndex: 1, isEntryField: true,
//           helperText: 'TotAmtRs / Wt',
//         ),
//         ErpFieldConfig(
//           key: 'entryTotAmtRs', label: 'TOT AMT RS',
//           type: ErpFieldType.amount,
//           readOnly: true, flex: 1, sectionIndex: 1, isEntryField: true,
//           helperText: 'AmtRs + LabAmtRs',
//         ),
//       ],
//     ];
//   }
//
//   // ══════════════════════════════════════════════════════════════════════════
//   //  INIT
//   // ══════════════════════════════════════════════════════════════════════════
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<RoughAssortProvider>().load();
//       context.read<RoughProvider>().loadRoughs();
//       context.read<PurityGroupProvider>().load();
//       _setDefaultFormValues();
//     });
//   }
//
//   void _setDefaultFormValues() {
//     final today = DateFormat('dd/MM/yyyy').format(DateTime.now());
//     setState(() {
//       _formValues = {
//         'roughAssortDate': today,
//         'roughAssortMstID': '0',
//       };
//     });
//   }
//
//   // ══════════════════════════════════════════════════════════════════════════
//   //  KAPAN SELECT → auto fill JNO + KNO WT
//   // ══════════════════════════════════════════════════════════════════════════
//   void _onKapanSelected(String kapanNo) {
//     final rp = context.read<RoughProvider>();
//     final match = rp.roughs.firstWhere(
//           (e) => e.kapanNo == kapanNo,
//       orElse: () => RoughModel(),
//     );
//     final jno   = match.jno?.toString() ?? '';
//     final totWt = match.totWt ?? 0;
//     final usedWt = _detRows.fold(0.0, (s, r) => s + (r.wt ?? 0));
//
//     setState(() {
//       _formValues['jno']    = jno;
//       _knoWt                = _f3(totWt);
//       _pendingWt            = _f3(totWt - usedWt);
//     });
//     _erpFormKey.currentState?.updateFieldValue('jno', jno);
//   }
//
//   // ══════════════════════════════════════════════════════════════════════════
//   //  ENTRY CALC
//   // ══════════════════════════════════════════════════════════════════════════
//   void _recalcEntry() {
//     final wt       = _d(_entryVals['entryWt']);
//     final exRate   = _d(_entryVals['entryExRate']);
//     final rateD    = _d(_entryVals['entryRateDollar']);
//     final labRateD = _d(_entryVals['entryLabRateD']);
//
//     // Direct calcs
//     final amtD     = wt * rateD;
//     final labAmtD  = wt * labRateD;
//     final rateRs   = exRate * rateD;
//     final amtRs    = rateRs * wt;
//     final labRateRs = labRateD * exRate;
//     final labAmtRs  = labRateRs * wt;
//     final totAmtD   = amtD + labAmtD;
//     final totAmtRs  = amtRs + labAmtRs;
//     final totRateD  = wt > 0 ? totAmtD / wt : 0.0;
//     final totRateRs = wt > 0 ? totAmtRs / wt : 0.0;
//
//     void push(String key, double val) {
//       final s = _f2(val);
//       _entryCalc[key] = s;
//       _erpFormKey.currentState?.updateFieldValue(key, s);
//     }
//
//     push('entryAmtDollar',  amtD);
//     push('entryLabAmtD',    labAmtD);
//     push('entryRateRs',     rateRs);
//     push('entryAmtRs',      amtRs);
//     push('entryLabRateRs',  labRateRs);
//     push('entryLabAmtRs',   labAmtRs);
//     push('entryTotAmtD',    totAmtD);
//     push('entryTotAmtRs',   totAmtRs);
//     push('entryTotRateD',   totRateD);
//     push('entryTotRateRs',  totRateRs);
//   }
//
//   // ══════════════════════════════════════════════════════════════════════════
//   //  PENDING WT UPDATE
//   // ══════════════════════════════════════════════════════════════════════════
//   void _recalcPendingWt() {
//     final kno  = double.tryParse(_knoWt) ?? 0;
//     final used = _detRows.fold(0.0, (s, r) => s + (r.wt ?? 0));
//     setState(() => _pendingWt = _f3(kno - used));
//   }
//
//   // ══════════════════════════════════════════════════════════════════════════
//   //  ADD / EDIT / DELETE DETAIL ROW
//   // ══════════════════════════════════════════════════════════════════════════
//   void _addDetEntry() {
//     // Required check
//     final pCode = _entryVals['purityCode'] ?? '';
//     final wt    = _entryVals['entryWt'] ?? '';
//     if (pCode.isEmpty) {
//       _showSnack('Purity required');
//       _erpFormKey.currentState?.focusField('purityCode');
//       return;
//     }
//     if (wt.isEmpty) {
//       _showSnack('Weight required');
//       _erpFormKey.currentState?.focusField('entryWt');
//       return;
//     }
//
//     final pg = context.read<PurityGroupProvider>().list
//         .firstWhere((e) => e.purityGroupCode?.toString() == pCode,
//         orElse: () => PurityGroupModel());
//
//     final newRow = RoughAssortDetModel(
//       srno:           _editingDetIndex != null
//           ? _detRows[_editingDetIndex!].srno
//           : _detRows.length + 1,
//       purityCode:     int.tryParse(pCode),
//       purityGroupCode: pg.purityGroupCode,
//       pc:             int.tryParse(_entryVals['entryPc'] ?? ''),
//       wt:             double.tryParse(_entryVals['entryWt'] ?? ''),
//       per:            double.tryParse(_entryVals['entryPer'] ?? ''),
//       exRate:         double.tryParse(_entryVals['entryExRate'] ?? ''),
//       rateDollar:     double.tryParse(_entryVals['entryRateDollar'] ?? ''),
//       amtDollar:      double.tryParse(_entryCalc['entryAmtDollar'] ?? ''),
//       labRateD:       double.tryParse(_entryVals['entryLabRateD'] ?? ''),
//       labAmtD:        double.tryParse(_entryCalc['entryLabAmtD'] ?? ''),
//       rateRs:         double.tryParse(_entryCalc['entryRateRs'] ?? ''),
//       amtRs:          double.tryParse(_entryCalc['entryAmtRs'] ?? ''),
//       labRateRs:      double.tryParse(_entryCalc['entryLabRateRs'] ?? ''),
//       labAmtRs:       double.tryParse(_entryCalc['entryLabAmtRs'] ?? ''),
//       totRateD:       double.tryParse(_entryCalc['entryTotRateD'] ?? ''),
//       totAmtD:        double.tryParse(_entryCalc['entryTotAmtD'] ?? ''),
//       totRateRs:      double.tryParse(_entryCalc['entryTotRateRs'] ?? ''),
//       totAmtRs:       double.tryParse(_entryCalc['entryTotAmtRs'] ?? ''),
//     );
//
//     setState(() {
//       if (_editingDetIndex != null) {
//         _detRows[_editingDetIndex!] = newRow;
//         _editingDetIndex = null;
//       } else {
//         _detRows.add(newRow);
//       }
//       _syncDetGrid();
//       _recalcPendingWt();
//     });
//     _clearEntryFields();
//   }
//
//   void _editDetRow(int idx) {
//     final r = _detRows[idx];
//     setState(() => _editingDetIndex = idx);
//
//     void set(String k, String? v) {
//       _entryVals[k] = v ?? '';
//       _erpFormKey.currentState?.updateFieldValue(k, v ?? '');
//     }
//
//     set('purityCode',       r.purityCode?.toString());
//     set('entryPc',          r.pc?.toString());
//     set('entryWt',          _f3(r.wt));
//     set('entryPer',         _f2(r.per));
//     set('entryExRate',      _f2(r.exRate));
//     set('entryRateDollar',  _f2(r.rateDollar));
//     set('entryAmtDollar',   _f2(r.amtDollar));
//     set('entryLabRateD',    _f2(r.labRateD));
//     set('entryLabAmtD',     _f2(r.labAmtD));
//     set('entryRateRs',      _f2(r.rateRs));
//     set('entryAmtRs',       _f2(r.amtRs));
//     set('entryLabRateRs',   _f2(r.labRateRs));
//     set('entryLabAmtRs',    _f2(r.labAmtRs));
//     set('entryTotRateD',    _f2(r.totRateD));
//     set('entryTotAmtD',     _f2(r.totAmtD));
//     set('entryTotRateRs',   _f2(r.totRateRs));
//     set('entryTotAmtRs',    _f2(r.totAmtRs));
//
//     Future.delayed(const Duration(milliseconds: 50),
//             () => _erpFormKey.currentState?.focusField('purityCode'));
//   }
//
//   void _deleteDetRow(int idx) {
//     setState(() {
//       _detRows.removeAt(idx);
//       // Renumber srno
//       _detRows = _detRows.asMap().entries
//           .map((e) => RoughAssortDetModel(
//         srno:           e.key + 1,
//         roughAssortMstID: e.value.roughAssortMstID,
//         purityCode:     e.value.purityCode,
//         purityGroupCode: e.value.purityGroupCode,
//         pc:             e.value.pc,
//         wt:             e.value.wt,
//         per:            e.value.per,
//         exRate:         e.value.exRate,
//         rateDollar:     e.value.rateDollar,
//         amtDollar:      e.value.amtDollar,
//         labRateD:       e.value.labRateD,
//         labAmtD:        e.value.labAmtD,
//         rateRs:         e.value.rateRs,
//         amtRs:          e.value.amtRs,
//         labRateRs:      e.value.labRateRs,
//         labAmtRs:       e.value.labAmtRs,
//         totRateD:       e.value.totRateD,
//         totAmtD:        e.value.totAmtD,
//         totRateRs:      e.value.totRateRs,
//         totAmtRs:       e.value.totAmtRs,
//       ))
//           .toList();
//       _syncDetGrid();
//       _recalcPendingWt();
//       if (_editingDetIndex == idx) _editingDetIndex = null;
//     });
//   }
//
//   // ══════════════════════════════════════════════════════════════════════════
//   //  SYNC DISPLAY GRID
//   // ══════════════════════════════════════════════════════════════════════════
//   void _syncDetGrid() {
//     final pg = context.read<PurityGroupProvider>();
//
//     _detDisplay = _detRows.map((r) {
//       final pgName = pg.list
//           .firstWhere((e) => e.purityGroupCode == r.purityGroupCode,
//           orElse: () => PurityGroupModel())
//           .purityGroupName ?? '';
//
//       return {
//         'srno':        r.srno?.toString()   ?? '',
//         'purityCode':  r.purityCode?.toString() ?? '',
//         'purityGroup': pgName,
//         'pc':          r.pc?.toString()     ?? '',
//         'wt':          _f3(r.wt),
//         'per':         _f2(r.per),
//         'exRate':      _f2(r.exRate),
//         'rateDollar':  _f2(r.rateDollar),
//         'amtDollar':   _f2(r.amtDollar),
//         'labRateD':    _f2(r.labRateD),
//         'labAmtD':     _f2(r.labAmtD),
//         'rateRs':      _f2(r.rateRs),
//         'amtRs':       _f2(r.amtRs),
//         'labRateRs':   _f2(r.labRateRs),
//         'labAmtRs':    _f2(r.labAmtRs),
//         'totRateD':    _f2(r.totRateD),
//         'totAmtD':     _f2(r.totAmtD),
//         'totRateRs':   _f2(r.totRateRs),
//         'totAmtRs':    _f2(r.totAmtRs),
//       };
//     }).toList();
//   }
//
//   // ══════════════════════════════════════════════════════════════════════════
//   //  GRID COLUMNS for ErpEntryGrid
//   // ══════════════════════════════════════════════════════════════════════════
//   List<String> get _detGridColumns => [
//     'srno', 'purityGroup', 'pc', 'wt', 'per',
//     'exRate', 'rateDollar', 'amtDollar',
//     'labRateD', 'labAmtD',
//     'rateRs', 'amtRs',
//     'labRateRs', 'labAmtRs',
//     'totRateD', 'totAmtD',
//     'totRateRs', 'totAmtRs',
//   ];
//
//   // ══════════════════════════════════════════════════════════════════════════
//   //  FOOTER TOTALS
//   // ══════════════════════════════════════════════════════════════════════════
//   Map<String, double> get _footerTotals {
//     double sum(double? Function(RoughAssortDetModel) f) =>
//         _detRows.fold(0, (s, r) => s + (f(r) ?? 0));
//     return {
//       'pc':       sum((r) => r.pc?.toDouble()),
//       'wt':       sum((r) => r.wt),
//       'amtDollar': sum((r) => r.amtDollar),
//       'labAmtD':  sum((r) => r.labAmtD),
//       'amtRs':    sum((r) => r.amtRs),
//       'labAmtRs': sum((r) => r.labAmtRs),
//       'totAmtD':  sum((r) => r.totAmtD),
//       'totAmtRs': sum((r) => r.totAmtRs),
//     };
//   }
//
//   // ══════════════════════════════════════════════════════════════════════════
//   //  UTILS
//   // ══════════════════════════════════════════════════════════════════════════
//   void _clearEntryFields() {
//     const keys = [
//       'purityCode', 'entryPc', 'entryWt', 'entryPer',
//       'entryExRate', 'entryRateDollar', 'entryAmtDollar',
//       'entryLabRateD', 'entryLabAmtD',
//       'entryRateRs', 'entryAmtRs', 'entryLabRateRs', 'entryLabAmtRs',
//       'entryTotRateD', 'entryTotAmtD', 'entryTotRateRs', 'entryTotAmtRs',
//     ];
//     for (final k in keys) {
//       _entryVals.remove(k);
//       _entryCalc.remove(k);
//       _erpFormKey.currentState?.updateFieldValue(k, '');
//     }
//     Future.delayed(const Duration(milliseconds: 50),
//             () => _erpFormKey.currentState?.focusField('purityCode'));
//   }
//
//   void _showSnack(String msg) =>
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//
//   // ══════════════════════════════════════════════════════════════════════════
//   //  ROW TAP
//   // ══════════════════════════════════════════════════════════════════════════
//   Future<void> _onRowTap(Map<String, dynamic> row) async {
//     final raw    = row['_raw'] as RoughAssortModel;
//     final prov   = context.read<RoughAssortProvider>();
//     final details = await prov.loadDetails(raw.roughAssortMstID!);
//     if (!mounted) return;
//
//     // KNO WT from rough
//     final rp    = context.read<RoughProvider>();
//     final match = rp.roughs.firstWhere(
//             (e) => e.kapanNo == raw.kapanNo, orElse: () => RoughModel());
//     final knoWt = match.totWt ?? 0;
//     final usedWt = details.fold(0.0, (s, r) => s + (r.wt ?? 0));
//
//     setState(() {
//       _selectedRow    = row;
//       _selectedMst    = raw;
//       _isEditMode     = true;
//       _detRows        = details;
//       _editingDetIndex = null;
//       _knoWt          = _f3(knoWt);
//       _pendingWt      = _f3(knoWt - usedWt);
//       _formValues = {
//         'roughAssortMstID': raw.roughAssortMstID?.toString() ?? '0',
//         'roughAssortDate':  toDisplayDate(raw.roughAssortDate),
//         'kapanNo':          raw.kapanNo ?? '',
//         'jno':              raw.jno?.toString() ?? '',
//         'remarks':          raw.remarks ?? '',
//       };
//       _syncDetGrid();
//       if (Responsive.isMobile(context)) _showTableOnMobile = false;
//     });
//   }
//
//   // ══════════════════════════════════════════════════════════════════════════
//   //  SAVE
//   // ══════════════════════════════════════════════════════════════════════════
//   Future<void> _onSave(Map<String, dynamic> values) async {
//     final prov = context.read<RoughAssortProvider>();
//
//     String toIso(String? v) {
//       if (v == null || v.isEmpty) return '';
//       try { return DateFormat('yyyy-MM-dd').format(DateFormat('dd/MM/yyyy').parse(v)); }
//       catch (_) { return v; }
//     }
//
//     final merged = Map<String, dynamic>.from(values);
//     merged['roughAssortDate'] = toIso(merged['roughAssortDate']?.toString());
//
//     bool success;
//     if (_isEditMode && _selectedMst != null) {
//       success = await prov.update(_selectedMst!.roughAssortMstID!, merged, _detRows);
//     } else {
//       success = await prov.create(merged, _detRows);
//     }
//     if (!mounted) return;
//     if (success) {
//       final wasEdit = _isEditMode;
//       _resetForm();
//       await ErpResultDialog.showSuccess(
//         context: context, theme: _theme,
//         title: wasEdit ? 'Updated' : 'Saved',
//         message: wasEdit ? 'Rough Assort Entry updated.' : 'Rough Assort Entry saved.',
//       );
//     }
//   }
//
//   // ══════════════════════════════════════════════════════════════════════════
//   //  DELETE
//   // ══════════════════════════════════════════════════════════════════════════
//   Future<void> _onDelete() async {
//     if (_selectedMst?.roughAssortMstID == null) return;
//     final confirm = await ErpDeleteDialog.show(
//       context: context, theme: _theme,
//       title: 'Rough Assort Entry',
//       itemName: 'Kapan: ${_selectedMst!.kapanNo ?? ''}',
//     );
//     if (confirm != true || !mounted) return;
//     final success = await context.read<RoughAssortProvider>().delete(_selectedMst!.roughAssortMstID!);
//     if (success && mounted) {
//       final kno = _selectedMst?.kapanNo;
//       _resetForm();
//       await ErpResultDialog.showDeleted(
//           context: context, theme: _theme, itemName: 'Rough Assort $kno');
//     }
//   }
//
//   // ══════════════════════════════════════════════════════════════════════════
//   //  RESET
//   // ══════════════════════════════════════════════════════════════════════════
//   void _resetForm() {
//     _erpFormKey.currentState?.resetForm();
//     final today = DateFormat('dd/MM/yyyy').format(DateTime.now());
//     setState(() {
//       _selectedRow     = null;
//       _selectedMst     = null;
//       _isEditMode      = false;
//       _showTableOnMobile = false;
//       _detRows         = [];
//       _detDisplay      = [];
//       _editingDetIndex = null;
//       _knoWt           = '0.000';
//       _pendingWt       = '0.000';
//       _entryVals.clear();
//       _entryCalc.clear();
//       _formValues = {
//         'roughAssortDate': today,
//         'roughAssortMstID': '0',
//       };
//     });
//   }
//
//   // ══════════════════════════════════════════════════════════════════════════
//   //  BUILD
//   // ══════════════════════════════════════════════════════════════════════════
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<RoughAssortProvider>(
//       builder: (ctx, prov, _) => Padding(
//         padding: const EdgeInsets.all(8),
//         child: Responsive.isMobile(context)
//             ? _showTableOnMobile
//             ? _buildTable(prov)
//             : _buildForm(context)
//             : Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Expanded(flex: 2, child: _buildForm(context)),
//             const SizedBox(width: 12),
//             Expanded(flex: 2, child: _buildTable(prov)),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ── ErpForm ────────────────────────────────────────────────────────────────
//   Widget _buildForm(BuildContext context) {
//     final rp = context.watch<RoughProvider>();
//     final pg = context.watch<PurityGroupProvider>();
//
//     // Purity dropdown items
//     final purityItems = pg.list
//         .where((e) => e.active == true)
//         .map((e) => ErpDropdownItem(
//       label: e.purityGroupName ?? '',
//       value: e.purityGroupCode?.toString() ?? '',
//     ))
//         .toList();
//
//     // Inject purity items into form rows (sectionIndex 1, first row, first field)
//     final rows = _formRows(rp);
//     // Find purityCode field and set items
//     for (final row in rows) {
//       for (int i = 0; i < row.length; i++) {
//         if (row[i].key == 'purityCode') {
//           row[i] = ErpFieldConfig(
//             key: 'purityCode', label: 'PURITY',
//             type: ErpFieldType.dropdown,
//             dropdownItems: purityItems,
//             flex: 2, sectionIndex: 1,
//             isEntryField: true, isEntryRequired: true,
//           );
//         }
//       }
//     }
//
//     return ErpForm(
//       logo:      AppImages.logo,
//       key:       _erpFormKey,
//       title:     'ROUGH ASSORT ENTRY',
//       tabBarBackgroundColor:  const Color(0xfff2f0ef),
//       tabBarSelectedColor:    _theme.primaryGradient.first,
//       tabBarSelectedTxtColor: Colors.white,
//       rows:          rows,
//       initialValues: _formValues,
//       isEditMode:    _isEditMode,
//
//       onEntryAdd: (sectionIndex) {
//         if (sectionIndex == 1) _addDetEntry();
//       },
//
//       onFieldChanged: (key, value) {
//         setState(() {
//           _formValues[key] = value.toString();
//           _entryVals[key]  = value.toString();
//
//           if (key == 'kapanNo') {
//             _onKapanSelected(value.toString());
//           }
//
//           // Recalc entry if any entry field changes
//           const entryFields = {
//             'entryWt', 'entryExRate', 'entryRateDollar', 'entryLabRateD',
//           };
//           if (entryFields.contains(key)) {
//             _recalcEntry();
//           }
//         });
//       },
//
//       onExit: () => context.read<TabProvider>().closeCurrentTab(),
//       onSave:   _onSave,
//       onCancel: _resetForm,
//       onDelete: _isEditMode ? _onDelete : null,
//       onSearch: () => setState(() => _showTableOnMobile = true),
//
//       // ── Pending Wt + KNO WT info bar + grid ──────────────────────────
//       detailBuilder: (ctx) {
//         final theme = ctx.erpTheme;
//         final t     = theme;
//         final tots  = _footerTotals;
//
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // ── Info bar: Pending Wt / KNO Wt ──────────────────────────
//             Container(
//               margin: const EdgeInsets.only(bottom: 8),
//               padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [t.primary.withOpacity(0.08), t.accent.withOpacity(0.05)],
//                 ),
//                 borderRadius: BorderRadius.circular(10),
//                 border: Border.all(color: t.primary.withOpacity(0.2)),
//               ),
//               child: Row(
//                 children: [
//                   _infoChip(t, 'PENDING WT', _pendingWt,
//                       double.tryParse(_pendingWt) != null &&
//                           double.parse(_pendingWt) < 0
//                           ? Colors.red
//                           : t.primary),
//                   const SizedBox(width: 16),
//                   _infoChip(t, 'KNO WT', _knoWt, t.primary),
//                   const Spacer(),
//                   if (_detRows.isNotEmpty) ...[
//                     _infoChip(t, 'ROWS', '${_detRows.length}', t.primary),
//                     const SizedBox(width: 16),
//                     _infoChip(t, 'TOT WT',
//                         _f3(tots['wt']), t.primary),
//                   ],
//                 ],
//               ),
//             ),
//
//             // ── Detail Grid ─────────────────────────────────────────────
//             if (_detDisplay.isNotEmpty) ...[
//               ErpEntryGrid(
//                 data:         _detDisplay,
//                 columns:      _detGridColumns,
//                 title:        'PURITY GROUP: ROUGH ASSORT',
//                 theme:        theme,
//                 onDeleteRow:  _deleteDetRow,
//                 onEditRow:    _editDetRow,
//                 editingIndex: _editingDetIndex,
//               ),
//
//               // ── Footer Totals row ─────────────────────────────────────
//               const SizedBox(height: 4),
//               _buildFooterRow(t, tots),
//             ],
//           ],
//         );
//       },
//     );
//   }
//
//   // ── Info chip ──────────────────────────────────────────────────────────────
//   Widget _infoChip(ErpTheme t, String label, String value, Color color) {
//     return Row(mainAxisSize: MainAxisSize.min, children: [
//       Text('$label : ',
//           style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
//               color: t.textLight, letterSpacing: 0.4)),
//       Container(
//         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.10),
//           borderRadius: BorderRadius.circular(6),
//           border: Border.all(color: color.withOpacity(0.3)),
//         ),
//         child: Text(value,
//             style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
//       ),
//     ]);
//   }
//
//   // ── Footer totals row ──────────────────────────────────────────────────────
//   Widget _buildFooterRow(ErpTheme t, Map<String, double> tots) {
//     Widget cell(String label, double? val) => Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
//         child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
//           Text(label,
//               style: TextStyle(fontSize: 8, color: t.textLight,
//                   fontWeight: FontWeight.w700, letterSpacing: 0.4)),
//           const SizedBox(height: 2),
//           Text(val != null ? _f2(val) : '',
//               style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: t.primary)),
//         ]),
//       ),
//     );
//
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//             colors: [t.primary.withOpacity(0.06), t.accent.withOpacity(0.04)]),
//         borderRadius: BorderRadius.circular(8),
//         border: Border(top: BorderSide(color: t.primary.withOpacity(0.3), width: 1.5)),
//       ),
//       child: Row(
//         children: [
//           // Label
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
//             child: Text('Tot...',
//                 style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
//                     color: t.primary, letterSpacing: 0.5)),
//           ),
//           cell('PC',         tots['pc']),
//           cell('WT',         tots['wt']),
//           cell('EX RATE',    null),
//           cell('RATE \$',    null),
//           cell('AMT \$',     tots['amtDollar']),
//           cell('LAB AMT \$', tots['labAmtD']),
//           cell('AMT RS',     tots['amtRs']),
//           cell('LAB AMT RS', tots['labAmtRs']),
//           cell('TOT AMT \$', tots['totAmtD']),
//           cell('TOT AMT RS', tots['totAmtRs']),
//         ],
//       ),
//     );
//   }
//
//   // ── ErpDataTable ───────────────────────────────────────────────────────────
//   Widget _buildTable(RoughAssortProvider prov) {
//     final data = prov.list.map((e) => e.toTableRow()).toList();
//     return ErpDataTable(
//       isReportRow: false,
//       token:       token ?? '',
//       url:         baseUrl,
//       title:       'ROUGH ASSORT LIST',
//       columns:     _tableColumns,
//       data:        data,
//       showSearch:  true,
//       searchFields: const [
//         ErpSearchFieldConfig(key: 'kapanNo', label: 'KAPAN NO', width: 150),
//         ErpSearchFieldConfig(key: 'jno',     label: 'JNO',      width: 120),
//       ],
//       selectedRow: _selectedRow,
//       onRowTap:    _onRowTap,
//       emptyMessage: prov.isLoaded ? 'No entries found' : 'Loading...',
//     );
//   }
// }
import 'package:diam_mfg/models/rough_assort_model.dart';
import 'package:diam_mfg/providers/purity_group_provider.dart';
import 'package:diam_mfg/providers/purity_provider.dart';
import 'package:diam_mfg/providers/rough_assort_provider.dart';
import 'package:diam_mfg/providers/rough_provider.dart';
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
import '../models/purity_group_model.dart';
import '../models/purity_model.dart';
import '../models/rough_model.dart';

// ─── field fmt helpers ────────────────────────────────────────────────────────
String _f2(double? v) => v == null ? '' : v.toStringAsFixed(2);
String _f3(double? v) => v == null ? '' : v.toStringAsFixed(3);
double _d(dynamic v)  => v == null ? 0 : (double.tryParse(v.toString()) ?? 0);

// ══════════════════════════════════════════════════════════════════════════════
class TrnRoughAssortEntry extends StatefulWidget {
  const TrnRoughAssortEntry({super.key});

  @override
  State<TrnRoughAssortEntry> createState() => _TrnRoughAssortEntryState();
}

class _TrnRoughAssortEntryState extends State<TrnRoughAssortEntry> {
  // ── theme ──────────────────────────────────────────────────────────────────
  final ErpThemeVariant _themeVariant = ErpThemeVariant.frost;
  ErpTheme get _theme => ErpTheme(_themeVariant);

  final GlobalKey<ErpFormState> _erpFormKey = GlobalKey<ErpFormState>();

  // ── selection ──────────────────────────────────────────────────────────────
  Map<String, dynamic>? _selectedRow;
  RoughAssortModel?     _selectedMst;
  bool                  _isEditMode        = false;
  bool                  _showTableOnMobile = false;

  // ── master form values ─────────────────────────────────────────────────────
  Map<String, String> _formValues = {};

  // ── master calculated display ──────────────────────────────────────────────
  String _pendingWt = '0.000';   // KnoWt − totalWt
  String _knoWt     = '0.000';   // selected kapan totWt

  // ── detail rows ───────────────────────────────────────────────────────────
  List<RoughAssortDetModel>   _detRows     = [];
  List<Map<String, dynamic>>  _detDisplay  = [];
  int? _editingDetIndex;

  // ── entry field values (current row being typed) ──────────────────────────
  final Map<String, String> _entryVals = {};

  // ── entry calculated (read-only display in entry row) ─────────────────────
  final Map<String, String> _entryCalc = {};

  final String? token = AppStorage.getString('token');

  // ══════════════════════════════════════════════════════════════════════════
  //  TABLE COLUMNS
  // ══════════════════════════════════════════════════════════════════════════
  List<ErpColumnConfig> get _tableColumns => [
    ErpColumnConfig(key: 'roughAssortMstID', label: 'ID',      width: 70,  required: true),
    ErpColumnConfig(key: 'roughAssortDate',  label: 'DATE',    width: 110, required: true, isDate: true),
    ErpColumnConfig(key: 'kapanNo',          label: 'KAPAN',   width: 160),
    ErpColumnConfig(key: 'jno',              label: 'JNO',     width: 135),
    ErpColumnConfig(key: 'remarks',          label: 'REMARKS', width: 200),
  ];

  // ══════════════════════════════════════════════════════════════════════════
  //  FORM ROWS
  // ══════════════════════════════════════════════════════════════════════════
  List<List<ErpFieldConfig>> _formRows(RoughProvider rp,RoughAssortProvider assortProv) {
    // KapanNo dropdown
    // final kapanItems = rp.roughs
    //     .where((e) => e.kapanNo != null && e.kapanNo!.isNotEmpty)
    //     .map((e) => ErpDropdownItem(
    //   label: 'Kapan No: ${e.kapanNo!}  Jno: ${e.jno ?? ''}  Wt: ${e.totWt??""}',
    //   value: e.kapanNo!,
    // ))
    //     .fold<List<ErpDropdownItem>>([], (acc, item) {
    //   if (!acc.any((x) => x.value == item.value)) acc.add(item);
    //   return acc;
    // });
    final usedKapans = assortProv.usedKapanNos(
      excludeMstID: _selectedMst?.roughAssortMstID,
    );

    final kapanItems = rp.roughs
        .where((e) => e.kapanNo != null && e.kapanNo!.isNotEmpty)
        .where((e) => !_fullyUsedKapans.contains(e.kapanNo)) // ✅ fully used hide
        .map((e) => ErpDropdownItem(
      label: 'Kapan No: ${e.kapanNo!}  Jno: ${e.jno ?? ''}  Wt: ${e.totWt ?? ""}',
      value: e.kapanNo!,
    ))
        .fold<List<ErpDropdownItem>>([], (acc, item) {
      if (!acc.any((x) => x.value == item.value)) acc.add(item);
      return acc;
    });
    return [
      // ── SECTION 0: MASTER ─────────────────────────────────────────────────
      [
        ErpFieldConfig(
          key: 'kapanNo', label: 'KAPAN NO',
          type: ErpFieldType.dropdown,
          dropdownItems: kapanItems,
          required: true, flex: 2,
          sectionTitle: 'ROUGH ASSORT ENTRY', sectionIndex: 0,
        ),
        ErpFieldConfig(
          key: 'jno', label: 'JNO',
          type: ErpFieldType.number,
          readOnly: true, flex: 1, sectionIndex: 0,
        ),
        ErpFieldConfig(
          key: 'roughAssortDate', label: 'DATE',
          type: ErpFieldType.date,
          required: true, flex: 1, sectionIndex: 0,
        ),
        ErpFieldConfig(
          key: 'roughAssortMstID', label: 'ID',
          type: ErpFieldType.number,
          readOnly: true, flex: 1, sectionIndex: 0,
        ),
      ],
      [
        ErpFieldConfig(
          key: 'remarks', label: 'REMARKS',
          maxLines: 1, flex: 3, sectionIndex: 0,
        ),
      ],

      // ── SECTION 1: ENTRY ROW 1 (editable fields) ─────────────────────────
      [
        ErpFieldConfig(
          key: 'purityCode', label: 'PURITY',
          type: ErpFieldType.dropdown,
          dropdownItems: const [],
          flex: 1,
          sectionTitle: 'ENTRY', sectionIndex: 1,
          isEntryField: true, isEntryRequired: true,
        ),
        ErpFieldConfig(
          key: 'entryPc', label: 'PC',
          type: ErpFieldType.number,
          flex: 1, sectionIndex: 1, isEntryField: true,
        ),
        ErpFieldConfig(
          key: 'entryWt', label: 'WT',
          type: ErpFieldType.amount,
          flex: 1, sectionIndex: 1, isEntryField: true, isEntryRequired: true,
        ),
        // ✅ per field REMOVED from entry form — auto calc, shown only in grid
        ErpFieldConfig(
          key: 'entryExRate', label: 'EX RATE',
          type: ErpFieldType.amount,
          flex: 1, sectionIndex: 1, isEntryField: true,
        ),
        ErpFieldConfig(
          key: 'entryRateDollar', label: 'RATE \$',
          type: ErpFieldType.amount,
          flex: 1, sectionIndex: 1, isEntryField: true,
        ),
        ErpFieldConfig(
          key: 'entryAmtDollar', label: 'AMT \$',
          type: ErpFieldType.amount,
          readOnly: true, flex: 1, sectionIndex: 1, isEntryField: true,
          // helperText: 'Wt × Rate\$',
        ),
        ErpFieldConfig(
          key: 'entryLabRateD', label: 'LAB RATE \$',
          type: ErpFieldType.amount,
          flex: 1, sectionIndex: 1, isEntryField: true,
        ),
        ErpFieldConfig(
          key: 'entryLabAmtD', label: 'LAB AMT \$',
          type: ErpFieldType.amount,
          readOnly: true, flex: 1, sectionIndex: 1, isEntryField: true,
            showAddButton: true
          // helperText: 'Wt × LabRate\$',
        ),
      ],
      // ── SECTION 1: ENTRY ROW 2 (read-only calc fields) ───────────────────
      [
        ErpFieldConfig(
          key: 'entryRateRs', label: 'RATE RS',
          type: ErpFieldType.amount,
          readOnly: true, flex: 1, sectionIndex: 1, isEntryField: true,
          // helperText: 'ExRate × Rate\$',
        ),
        ErpFieldConfig(
          key: 'entryAmtRs', label: 'AMT RS',
          type: ErpFieldType.amount,
          readOnly: true, flex: 1, sectionIndex: 1, isEntryField: true,
          // helperText: 'RateRs × Wt',
        ),
        ErpFieldConfig(
          key: 'entryLabRateRs', label: 'LAB RATE RS',
          type: ErpFieldType.amount,
          readOnly: true, flex: 1, sectionIndex: 1, isEntryField: true,
          // helperText: 'LabRate\$ × ExRate',
        ),
        ErpFieldConfig(
          key: 'entryLabAmtRs', label: 'LAB AMT RS',
          type: ErpFieldType.amount,
          readOnly: true, flex: 1, sectionIndex: 1, isEntryField: true,
          // helperText: 'LabRateRs × Wt',
        ),
        ErpFieldConfig(
          key: 'entryTotRateD', label: 'TOT RATE \$',
          type: ErpFieldType.amount,
          readOnly: true, flex: 1, sectionIndex: 1, isEntryField: true,
          // helperText: 'TotAmt\$ / Wt',
        ),
        ErpFieldConfig(
          key: 'entryTotAmtD', label: 'TOT AMT \$',
          type: ErpFieldType.amount,
          readOnly: true, flex: 1, sectionIndex: 1, isEntryField: true,
          // helperText: 'Amt\$ + LabAmt\$',
        ),
        ErpFieldConfig(
          key: 'entryTotRateRs', label: 'TOT RATE RS',
          type: ErpFieldType.amount,
          readOnly: true, flex: 1, sectionIndex: 1, isEntryField: true,
          // helperText: 'TotAmtRs / Wt',
        ),
        ErpFieldConfig(
          key: 'entryTotAmtRs', label: 'TOT AMT RS',
          type: ErpFieldType.amount,
          readOnly: true, flex: 1, sectionIndex: 1, isEntryField: true,
          // helperText: 'AmtRs + LabAmtRs',
        ),
      ],
    ];
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  INIT
  // ══════════════════════════════════════════════════════════════════════════
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<RoughAssortProvider>().load();
      context.read<RoughProvider>().loadRoughs();
      context.read<PurityGroupProvider>().load();
      context.read<PurityProvider>().load();
      _setDefaultFormValues();
      await _loadFullyUsedKapans(); // ✅

    });
  }
  Set<String> _fullyUsedKapans = {};

// initState ke baad call karo
  Future<void> _loadFullyUsedKapans() async {
    final rp         = context.read<RoughProvider>();
    final assortProv = context.read<RoughAssortProvider>();

    final Set<String> fullyUsed = {};

    for (final rough in rp.roughs) {
      final kapanNo = rough.kapanNo;
      if (kapanNo == null || kapanNo.isEmpty) continue;

      final totWt = rough.totWt ?? 0;
      if (totWt <= 0) continue;

      final usedWt = await assortProv.getUsedWtForKapan(
        kapanNo,
        excludeMstID: _selectedMst?.roughAssortMstID,
      );

      if (usedWt >= totWt - 0.001) { // ✅ fully used
        fullyUsed.add(kapanNo);
      }
    }

    if (mounted) {
      setState(() => _fullyUsedKapans = fullyUsed);
    }
  }
  void _setDefaultFormValues() {
    final today = DateFormat('dd/MM/yyyy').format(DateTime.now());
    setState(() {
      _formValues = {
        'roughAssortDate': today,
        'roughAssortMstID': '0',
      };
    });
  }
  Future<void> _onKapanSelected(String kapanNo) async {
    final rp         = context.read<RoughProvider>();
    final assortProv = context.read<RoughAssortProvider>();

    final match = rp.roughs.firstWhere(
          (e) => e.kapanNo == kapanNo,
      orElse: () => RoughModel(),
    );

    final totWt = match.totWt ?? 0;
    final jno   = match.jno?.toString() ?? '';

    // ✅ Already saved wt fetch karo — current edit exclude
    final alreadySavedWt = await assortProv.getUsedWtForKapan(
      kapanNo,
      excludeMstID: _selectedMst?.roughAssortMstID,
    );

    if (!mounted) return;

    // ✅ Current form rows ka wt
    final formUsedWt = _detRows.fold(0.0, (s, r) => s + (r.wt ?? 0));

    final effectiveKnoWt = totWt - alreadySavedWt;

    setState(() {
      _formValues['jno'] = jno;
      _knoWt     = _f3(totWt);
      _pendingWt = _f3(effectiveKnoWt - formUsedWt);
    });

    _erpFormKey.currentState?.updateFieldValue('jno', jno);
    _recalcEntry();
  }  // ══════════════════════════════════════════════════════════════════════════
  //  KAPAN SELECT → auto fill JNO + KNO WT
  // ══════════════════════════════════════════════════════════════════════════
  // void _onKapanSelected(String kapanNo) {
  //   final rp = context.read<RoughProvider>();
  //   final match = rp.roughs.firstWhere(
  //         (e) => e.kapanNo == kapanNo,
  //     orElse: () => RoughModel(),
  //   );
  //   final jno    = match.jno?.toString() ?? '';
  //   final totWt  = match.totWt ?? 0;
  //   final usedWt = _detRows.fold(0.0, (s, r) => s + (r.wt ?? 0));
  //
  //   setState(() {
  //     _formValues['jno'] = jno;
  //     _knoWt             = _f3(totWt);
  //     _pendingWt         = _f3(totWt - usedWt);
  //   });
  //   _erpFormKey.currentState?.updateFieldValue('jno', jno);
  //
  //   // ✅ FIX 1: Recalc per whenever kapan changes (knoWt changes)
  //   _recalcEntry();
  // }

  // ══════════════════════════════════════════════════════════════════════════
  //  ENTRY CALC  — includes per = entryWt / knoWt × 100
  // ══════════════════════════════════════════════════════════════════════════
  void _recalcEntry() {
    final wt       = _d(_entryVals['entryWt']);
    final exRate   = _d(_entryVals['entryExRate']);
    final rateD    = _d(_entryVals['entryRateDollar']);
    final labRateD = _d(_entryVals['entryLabRateD']);
    final knoWt    = double.tryParse(_knoWt) ?? 0;

    // ✅ FIX 1: per = (wt / knoWt) × 100  (auto calc, not manual)
    final per      = knoWt > 0 ? (wt / knoWt) * 100 : 0.0;

    final amtD      = wt * rateD;
    final labAmtD   = wt * labRateD;
    final rateRs    = exRate * rateD;
    final amtRs     = rateRs * wt;
    final labRateRs = labRateD * exRate;
    final labAmtRs  = labRateRs * wt;
    final totAmtD   = amtD + labAmtD;
    final totAmtRs  = amtRs + labAmtRs;
    final totRateD  = wt > 0 ? totAmtD / wt : 0.0;
    final totRateRs = wt > 0 ? totAmtRs / wt : 0.0;

    void push(String key, double val) {
      final s = _f2(val);
      _entryCalc[key] = s;
      _erpFormKey.currentState?.updateFieldValue(key, s);
    }

    // ✅ per only stored in _entryCalc — NOT pushed to form (field not in form)
    final perStr = _f2(per);
    _entryCalc['entryPer'] = perStr;
    // No updateFieldValue for entryPer — field doesn't exist in entry form

    push('entryAmtDollar',  amtD);
    push('entryLabAmtD',    labAmtD);
    push('entryRateRs',     rateRs);
    push('entryAmtRs',      amtRs);
    push('entryLabRateRs',  labRateRs);
    push('entryLabAmtRs',   labAmtRs);
    push('entryTotAmtD',    totAmtD);
    push('entryTotAmtRs',   totAmtRs);
    push('entryTotRateD',   totRateD);
    push('entryTotRateRs',  totRateRs);
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  PENDING WT UPDATE
  // ══════════════════════════════════════════════════════════════════════════
  // void _recalcPendingWt() {
  //   final kno  = double.tryParse(_knoWt) ?? 0;
  //   final used = _detRows.fold(0.0, (s, r) => s + (r.wt ?? 0));
  //   setState(() => _pendingWt = _f3(kno - used));
  // }
  Future<void> _recalcPendingWt() async {
    final rp         = context.read<RoughProvider>();
    final assortProv = context.read<RoughAssortProvider>();
    final kapanNo    = _formValues['kapanNo'] ?? '';

    if (kapanNo.isEmpty) return;

    final match  = rp.roughs.firstWhere(
          (e) => e.kapanNo == kapanNo,
      orElse: () => RoughModel(),
    );
    final totWt = match.totWt ?? 0;

    // ✅ Saved wt from other records
    final alreadySavedWt = await assortProv.getUsedWtForKapan(
      kapanNo,
      excludeMstID: _selectedMst?.roughAssortMstID,
    );

    if (!mounted) return;

    final formUsedWt     = _detRows.fold(0.0, (s, r) => s + (r.wt ?? 0));
    final effectiveKnoWt = totWt - alreadySavedWt;

    setState(() {
      _knoWt     = _f3(effectiveKnoWt);
      _pendingWt = _f3(effectiveKnoWt - formUsedWt);
    });
  }
  // ══════════════════════════════════════════════════════════════════════════
  //  ADD / EDIT / DELETE DETAIL ROW
  // ══════════════════════════════════════════════════════════════════════════
  void _addDetEntry() {
    final pCode = _entryVals['purityCode'] ?? '';
    final wt    = _entryVals['entryWt'] ?? '';
    if (pCode.isEmpty) {
      _showSnack('Purity required');
      _erpFormKey.currentState?.focusField('purityCode');
      return;
    }
    if (wt.isEmpty) {
      _showSnack('Weight required');
      _erpFormKey.currentState?.focusField('entryWt');
      return;
    }
    final entryWt   = double.tryParse(wt) ?? 0;
    final knoWt     = double.tryParse(_knoWt) ?? 0;

    // Edit mode mein: current row ka purana wt hatao, baaki wt = pending
    final currentRowOldWt = _editingDetIndex != null
        ? (_detRows[_editingDetIndex!].wt ?? 0)
        : 0.0;
    final usedWt    = _detRows.fold(0.0, (s, r) => s + (r.wt ?? 0)) - currentRowOldWt;
    final pendingWt = knoWt - usedWt;

    if (entryWt > pendingWt + 0.0001) {
      // 0.0001 tolerance for floating point
      _showWtExceededDialog(
        entryWt:   entryWt,
        pendingWt: pendingWt,
        knoWt:     knoWt,
      );
      return;
    }
    final pg = context.read<PurityGroupProvider>().list
        .firstWhere((e) => e.purityGroupCode?.toString() == pCode,
        orElse: () => PurityGroupModel());

    final newRow = RoughAssortDetModel(
      srno:            _editingDetIndex != null
          ? _detRows[_editingDetIndex!].srno
          : _detRows.length + 1,
      purityCode:      int.tryParse(pCode),
      purityGroupCode: pg.purityGroupCode,
      pc:              int.tryParse(_entryVals['entryPc'] ?? ''),
      wt:              double.tryParse(_entryVals['entryWt'] ?? ''),
      // ✅ FIX 1: per from _entryCalc (auto calculated)
      per:             double.tryParse(_entryCalc['entryPer'] ?? ''),
      exRate:          double.tryParse(_entryVals['entryExRate'] ?? ''),
      rateDollar:      double.tryParse(_entryVals['entryRateDollar'] ?? ''),
      amtDollar:       double.tryParse(_entryCalc['entryAmtDollar'] ?? ''),
      labRateD:        double.tryParse(_entryVals['entryLabRateD'] ?? ''),
      labAmtD:         double.tryParse(_entryCalc['entryLabAmtD'] ?? ''),
      rateRs:          double.tryParse(_entryCalc['entryRateRs'] ?? ''),
      amtRs:           double.tryParse(_entryCalc['entryAmtRs'] ?? ''),
      labRateRs:       double.tryParse(_entryCalc['entryLabRateRs'] ?? ''),
      labAmtRs:        double.tryParse(_entryCalc['entryLabAmtRs'] ?? ''),
      totRateD:        double.tryParse(_entryCalc['entryTotRateD'] ?? ''),
      totAmtD:         double.tryParse(_entryCalc['entryTotAmtD'] ?? ''),
      totRateRs:       double.tryParse(_entryCalc['entryTotRateRs'] ?? ''),
      totAmtRs:        double.tryParse(_entryCalc['entryTotAmtRs'] ?? ''),
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
    _recalcPendingWt();

    _clearEntryFields();
  }
  Future<void> _showWtExceededDialog({
    required double entryWt,
    required double pendingWt,
    required double knoWt,
  }) async {
    await ErpResultDialog.showError(
      context: context,
      theme: _theme,
      title: 'Weight Limit Exceeded',
      message:
      'Entry weight (${_f3(entryWt)}) exceeds the pending weight '
          '(${_f3(pendingWt)}).\n\n'
          'KNO Total : ${_f3(knoWt)}\n'
          'Pending   : ${_f3(pendingWt)}\n'
          'Entered   : ${_f3(entryWt)}\n\n'
          'Please reduce the weight to ${_f3(pendingWt)} or less.',
    );
    // Refocus WT field after dialog closes
    _erpFormKey.currentState?.focusField('entryWt');
  }
  void _editDetRow(int idx) {
    final r = _detRows[idx];
    setState(() => _editingDetIndex = idx);

    void set(String k, String? v) {
      _entryVals[k] = v ?? '';
      _erpFormKey.currentState?.updateFieldValue(k, v ?? '');
    }

    set('purityCode',       r.purityCode?.toString());
    set('entryPc',          r.pc?.toString());
    set('entryWt',          _f3(r.wt));
    set('entryPer',         _f2(r.per));
    set('entryExRate',      _f2(r.exRate));
    set('entryRateDollar',  _f2(r.rateDollar));
    set('entryAmtDollar',   _f2(r.amtDollar));
    set('entryLabRateD',    _f2(r.labRateD));
    set('entryLabAmtD',     _f2(r.labAmtD));
    set('entryRateRs',      _f2(r.rateRs));
    set('entryAmtRs',       _f2(r.amtRs));
    set('entryLabRateRs',   _f2(r.labRateRs));
    set('entryLabAmtRs',    _f2(r.labAmtRs));
    set('entryTotRateD',    _f2(r.totRateD));
    set('entryTotAmtD',     _f2(r.totAmtD));
    set('entryTotRateRs',   _f2(r.totRateRs));
    set('entryTotAmtRs',    _f2(r.totAmtRs));

    Future.delayed(const Duration(milliseconds: 50),
            () => _erpFormKey.currentState?.focusField('purityCode'));
  }

  void _deleteDetRow(int idx) {
    setState(() {
      _detRows.removeAt(idx);
      _detRows = _detRows.asMap().entries
          .map((e) => RoughAssortDetModel(
        srno:            e.key + 1,
        roughAssortMstID: e.value.roughAssortMstID,
        purityCode:      e.value.purityCode,
        purityGroupCode: e.value.purityGroupCode,
        pc:              e.value.pc,
        wt:              e.value.wt,
        per:             e.value.per,
        exRate:          e.value.exRate,
        rateDollar:      e.value.rateDollar,
        amtDollar:       e.value.amtDollar,
        labRateD:        e.value.labRateD,
        labAmtD:         e.value.labAmtD,
        rateRs:          e.value.rateRs,
        amtRs:           e.value.amtRs,
        labRateRs:       e.value.labRateRs,
        labAmtRs:        e.value.labAmtRs,
        totRateD:        e.value.totRateD,
        totAmtD:         e.value.totAmtD,
        totRateRs:       e.value.totRateRs,
        totAmtRs:        e.value.totAmtRs,
      ))
          .toList();
      _syncDetGrid();
      if (_editingDetIndex == idx) _editingDetIndex = null;
    });
    _recalcPendingWt();

  }

  // ══════════════════════════════════════════════════════════════════════════
  //  SYNC DISPLAY GRID
  // ══════════════════════════════════════════════════════════════════════════
  void _syncDetGrid() {
    final pg = context.read<PurityProvider>();

    _detDisplay = _detRows.map((r) {
      final pgName = pg.list
          .firstWhere((e) => e.purityCode == r.purityCode,
          orElse: () => PurityModel())
          .purityName ?? '';

      // Sr No|Purity|Pc|Wt|%|Ex Rate|Rate$|Amt$|Rate Rs|Amt Rs|Lab Rate$|Lab Amt$|Lab Rate Rs|Lab Amt Rs
      return {
        'srno':        r.srno?.toString()  ?? '',
        'purityGroup': pgName,
        'pc':          r.pc?.toString()    ?? '',
        'wt':          _f3(r.wt),
        'per':         _f2(r.per),
        'exRate':      _f2(r.exRate),
        'rateDollar':  _f2(r.rateDollar),
        'amtDollar':   _f2(r.amtDollar),
        'rateRs':      _f2(r.rateRs),
        'amtRs':       _f2(r.amtRs),
        'labRateD':    _f2(r.labRateD),
        'labAmtD':     _f2(r.labAmtD),
        'labRateRs':   _f2(r.labRateRs),
        'labAmtRs':    _f2(r.labAmtRs),
      };
    }).toList();
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  GRID COLUMNS  ← ✅ FIX 2: Only image-visible columns, removed extras
  // ══════════════════════════════════════════════════════════════════════════
  // Sr No|Purity|Pc|Wt|%|Ex Rate|Rate$|Amt$|Rate Rs|Amt Rs|Lab Rate$|Lab Amt$|Lab Rate Rs|Lab Amt Rs
  List<String> get _detGridColumns => [
    'srno',        // Sr No
    'purityGroup', // Purity
    'pc',          // Pc
    'wt',          // Wt
    'per',         // % (auto calc)
    'exRate',      // Ex Rate
    'rateDollar',  // Rate $
    'amtDollar',   // Amt $
    'rateRs',      // Rate Rs
    'amtRs',       // Amt Rs
    'labRateD',    // Lab Rate $
    'labAmtD',     // Lab Amt $
    'labRateRs',   // Lab Rate Rs
    'labAmtRs',    // Lab Amt Rs
  ];

  // ══════════════════════════════════════════════════════════════════════════
  //  FOOTER TOTALS
  // ══════════════════════════════════════════════════════════════════════════
  Map<String, double> get _footerTotals {
    double sum(double? Function(RoughAssortDetModel) f) =>
        _detRows.fold(0, (s, r) => s + (f(r) ?? 0));
    return {
      'pc':        sum((r) => r.pc?.toDouble()),
      'wt':        sum((r) => r.wt),
      'per':       _detRows.isNotEmpty ? 100.0 : 0.0, // always 100%
      'amtDollar': sum((r) => r.amtDollar),
      'amtRs':     sum((r) => r.amtRs),
      'labAmtD':   sum((r) => r.labAmtD),
      'labAmtRs':  sum((r) => r.labAmtRs),
    };
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  UTILS
  // ══════════════════════════════════════════════════════════════════════════
  void _clearEntryFields() {
    const keys = [
      'purityCode', 'entryPc', 'entryWt',
      // entryPer removed — not in form, only in _entryCalc internally
      'entryExRate', 'entryRateDollar', 'entryAmtDollar',
      'entryLabRateD', 'entryLabAmtD',
      'entryRateRs', 'entryAmtRs', 'entryLabRateRs', 'entryLabAmtRs',
      'entryTotRateD', 'entryTotAmtD', 'entryTotRateRs', 'entryTotAmtRs',
    ];
    for (final k in keys) {
      _entryVals.remove(k);
      _entryCalc.remove(k);
      _erpFormKey.currentState?.updateFieldValue(k, '');
    }
    Future.delayed(const Duration(milliseconds: 50),
            () => _erpFormKey.currentState?.focusField('purityCode'));
  }

  void _showSnack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  // ══════════════════════════════════════════════════════════════════════════
  //  ROW TAP
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> _onRowTap(Map<String, dynamic> row) async {
    final raw     = row['_raw'] as RoughAssortModel;
    final prov    = context.read<RoughAssortProvider>();
    final details = await prov.loadDetails(raw.roughAssortMstID!);
    if (!mounted) return;

    final rp    = context.read<RoughProvider>();
    final match = rp.roughs.firstWhere(
            (e) => e.kapanNo == raw.kapanNo, orElse: () => RoughModel());
    final knoWt  = match.totWt ?? 0;
    final usedWt = details.fold(0.0, (s, r) => s + (r.wt ?? 0));

    setState(() {
      _selectedRow     = row;
      _selectedMst     = raw;
      _isEditMode      = true;
      _detRows         = details;
      _editingDetIndex = null;
      _knoWt           = _f3(knoWt);
      _pendingWt       = _f3(knoWt - usedWt);
      _formValues = {
        'roughAssortMstID': raw.roughAssortMstID?.toString() ?? '0',
        'roughAssortDate':  toDisplayDate(raw.roughAssortDate),
        'kapanNo':          raw.kapanNo ?? '',
        'jno':              raw.jno?.toString() ?? '',
        'remarks':          raw.remarks ?? '',
      };
      _syncDetGrid();
      if (Responsive.isMobile(context)) _showTableOnMobile = false;
    });
    await _loadFullyUsedKapans(); // ✅ current kapan wapas aayega dropdown mein

  }

  // ══════════════════════════════════════════════════════════════════════════
  //  SAVE
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> _onSave(Map<String, dynamic> values) async {
    final prov = context.read<RoughAssortProvider>();
    if(_detDisplay.isEmpty){
      await ErpResultDialog.showError(
        context: context,
        theme: _theme,
        title: 'Purity Required',
        message: 'Purity entry is required to proceed.\n'
            'Please enter purity before continuing.',
      );
    }else{
      String toIso(String? v) {
        if (v == null || v.isEmpty) return '';
        try { return DateFormat('yyyy-MM-dd').format(DateFormat('dd/MM/yyyy').parse(v)); }
        catch (_) { return v; }
      }

      final merged = Map<String, dynamic>.from(values);
      merged['roughAssortDate'] = toIso(merged['roughAssortDate']?.toString());

      bool success;
      if (_isEditMode && _selectedMst != null) {
        success = await prov.update(_selectedMst!.roughAssortMstID!, merged, _detRows);

      } else {
        success = await prov.create(merged, _detRows);
      }
      if (!mounted) return;
      if (success) {
        final wasEdit = _isEditMode;
        _resetForm();
        await ErpResultDialog.showSuccess(
          context: context, theme: _theme,
          title: wasEdit ? 'Updated' : 'Saved',
          message: wasEdit ? 'Rough Assort Entry updated.' : 'Rough Assort Entry saved.',
        );
      }
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  DELETE
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> _onDelete() async {
    if (_selectedMst?.roughAssortMstID == null) return;
    final confirm = await ErpDeleteDialog.show(
      context: context, theme: _theme,
      title: 'Rough Assort Entry',
      itemName: 'Kapan: ${_selectedMst!.kapanNo ?? ''}',
    );
    if (confirm != true || !mounted) return;
    final success = await context.read<RoughAssortProvider>().delete(_selectedMst!.roughAssortMstID!);
    if (success && mounted) {
      final kno = _selectedMst?.kapanNo;
      _resetForm();
      await ErpResultDialog.showDeleted(
          context: context, theme: _theme, itemName: 'Rough Assort $kno');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  RESET
  // ══════════════════════════════════════════════════════════════════════════
  void _resetForm() {
    _erpFormKey.currentState?.resetForm();
    final today = DateFormat('dd/MM/yyyy').format(DateTime.now());
    setState(() {
      _selectedRow     = null;
      _selectedMst     = null;
      _isEditMode      = false;
      _showTableOnMobile = false;
      _detRows         = [];
      _detDisplay      = [];
      _editingDetIndex = null;
      _knoWt           = '0.000';
      _pendingWt       = '0.000';
      _entryVals.clear();
      _entryCalc.clear();
      _formValues = {
        'roughAssortDate': today,
        'roughAssortMstID': '0',
      };
    });
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Consumer<RoughAssortProvider>(
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
    final rp = context.watch<RoughProvider>();
    final ra = context.watch<RoughAssortProvider>();

    // final pg = context.watch<PurityGroupProvider>();
    //
    // final purityItems = pg.list
    //     .where((e) => e.active == true)
    //     .map((e) => ErpDropdownItem(
    //   label: e.purityGroupName ?? '',
    //   value: e.purityGroupCode?.toString() ?? '',
    // ))
    //     .toList();
    final pu = context.watch<PurityProvider>();

    final purityItems = pu.list
        .where((e) => e.active == true &&
        [2, 5, 8].contains(e.purityGroupCode))
        .map((e) => ErpDropdownItem(
      label: e.purityName ?? '',
      value: e.purityCode?.toString() ?? '',
    ))
        .toList();

    final rows = _formRows(rp,ra);
    for (final row in rows) {
      for (int i = 0; i < row.length; i++) {
        if (row[i].key == 'purityCode') {
          row[i] = ErpFieldConfig(
            key: 'purityCode', label: 'PURITY',
            type: ErpFieldType.dropdown,
            dropdownItems: purityItems,
            flex: 2, sectionIndex: 1,
            isEntryField: true, isEntryRequired: true,
          );
        }
      }
    }

    return ErpForm(
      addButtonSections: const {1}, // ✅ sirf section 1 mein add button

      logo:      AppImages.logo,
      key:       _erpFormKey,
      title:     'ROUGH ASSORT ENTRY',
      tabBarBackgroundColor:  const Color(0xfff2f0ef),
      tabBarSelectedColor:    _theme.primaryGradient.first,
      tabBarSelectedTxtColor: Colors.white,
      rows:          rows,
      initialValues: _formValues,
      isEditMode:    _isEditMode,

      onEntryAdd: (sectionIndex) {
        if (sectionIndex == 1) _addDetEntry();
      },

      onFieldChanged: (key, value) {
        setState(() {
          _formValues[key] = value.toString();
          _entryVals[key]  = value.toString();

          if (key == 'kapanNo'&& value.toString().isNotEmpty) {
            _onKapanSelected(value.toString());
          }

          // ✅ FIX 1: per no longer in entryFields — removed 'entryPer'
          const entryFields = {
            'entryWt', 'entryExRate', 'entryRateDollar', 'entryLabRateD',
          };
          if (entryFields.contains(key)) {
            _recalcEntry();
          }
        });
      },

      onExit:   () => context.read<TabProvider>().closeCurrentTab(),
      onSave:   _onSave,
      onCancel: _resetForm,
      onDelete: _isEditMode ? _onDelete : null,
      onSearch: () => setState(() => _showTableOnMobile = true),

      // ── Detail area ──────────────────────────────────────────────────
      detailBuilder: (ctx) {
        final theme = ctx.erpTheme;
        final t     = theme;
        final tots  = _footerTotals;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Info bar: Pending Wt / KNO Wt ────────────────────────
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [t.primary.withOpacity(0.08), t.accent.withOpacity(0.05)],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: t.primary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  _infoChip(t, 'PENDING WT', _pendingWt,
                      double.tryParse(_pendingWt) != null &&
                          double.parse(_pendingWt) < 0
                          ? Colors.red
                          : t.primary),
                  const SizedBox(width: 16),
                  _infoChip(t, 'KNO WT', _knoWt, t.primary),
                  const Spacer(),
                  if (_detRows.isNotEmpty) ...[
                    _infoChip(t, 'ROWS', '${_detRows.length}', t.primary),
                    const SizedBox(width: 16),
                    _infoChip(t, 'TOT WT', _f3(tots['wt']), t.primary),
                  ],
                ],
              ),
            ),

            // ── Detail Grid ──────────────────────────────────────────
            if (_detDisplay.isNotEmpty) ...[
              ErpEntryGrid(
                data:         _detDisplay,
                columns:      _detGridColumns,
                title:        'PURITY GROUP: ROUGH ASSORT',
                theme:        theme,
                onDeleteRow:  _deleteDetRow,
                onEditRow:    _editDetRow,
                editingIndex: _editingDetIndex,
                // ✅ Custom column header labels matching image exactly
                columnLabels: const {
                  'srno':        'SR NO',
                  'purityGroup': 'PURITY',
                  'pc':          'PC',
                  'wt':          'WT',
                  'per':         '%',
                  'exRate':      'EX RATE',
                  'rateDollar':  'RATE \$',
                  'amtDollar':   'AMT \$',
                  'rateRs':      'RATE RS',
                  'amtRs':       'AMT RS',
                  'labRateD':    'LAB RATE \$',
                  'labAmtD':     'LAB AMT \$',
                  'labRateRs':   'LAB RATE RS',
                  'labAmtRs':    'LAB AMT RS',
                },
              ),

              // ── Footer Totals ─────────────────────────────────────
              const SizedBox(height: 4),
              _buildFooterRow(t, tots),
            ],
          ],
        );
      },
    );
  }

  // ── Info chip ──────────────────────────────────────────────────────────────
  Widget _infoChip(ErpTheme t, String label, String value, Color color) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Text('$label : ',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
              color: t.textLight, letterSpacing: 0.4)),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Text(value,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
      ),
    ]);
  }

  // ── Footer totals row — 14 cols aligned to _detGridColumns ──────────────
  Widget _buildFooterRow(ErpTheme t, Map<String, double> tots) {
    // Columns (14): srno|purityGroup|pc|wt|per|exRate|rateDollar|amtDollar
    //               |rateRs|amtRs|labRateD|labAmtD|labRateRs|labAmtRs
    // + edit(28) + delete(28) spacers

    Widget cell(String label, double? val, {bool isPercent = false}) => Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(label,
              style: TextStyle(fontSize: 8, color: t.textLight,
                  fontWeight: FontWeight.w700, letterSpacing: 0.4)),
          const SizedBox(height: 2),
          Text(
            val != null ? (isPercent ? '${_f2(val)}%' : _f2(val)) : '-',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                color: val != null ? t.primary : t.textLight),
          ),
        ]),
      ),
    );

    Widget blank() => Expanded(child: const SizedBox());

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [t.primary.withOpacity(0.06), t.accent.withOpacity(0.04)]),
        borderRadius: BorderRadius.circular(8),
        border: Border(top: BorderSide(color: t.primary.withOpacity(0.3), width: 1.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Text('TOTAL',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
                    color: t.primary, letterSpacing: 0.5)),
          ),
          // blank(),                                            // srno
          blank(),                                            // purityGroup
          cell('PC',          tots['pc']),                    // Pc
          cell('WT',          tots['wt']),                    // Wt
          cell('%',           tots['per'], isPercent: true),  // % = 100
          blank(),                                            // exRate
          blank(),                                            // rateDollar
          cell('AMT \$',      tots['amtDollar']),             // Amt \$
          blank(),                                            // rateRs
          cell('AMT RS',      tots['amtRs']),                 // Amt Rs
          blank(),                                            // labRateD
          cell('LAB AMT \$',  tots['labAmtD']),               // Lab Amt \$
          blank(),                                            // labRateRs
          cell('LAB AMT RS',  tots['labAmtRs']),              // Lab Amt Rs
          const SizedBox(width: 35),                          // edit col
          const SizedBox(width: 35),                          // delete col
        ],
      ),
    );
  }

  // ── ErpDataTable ───────────────────────────────────────────────────────────
  Widget _buildTable(RoughAssortProvider prov) {
    final data = prov.list.map((e) => e.toTableRow()).toList();
    return ErpDataTable(
      isReportRow: false,
      token:       token ?? '',
      dateFilter: true,

      url:         baseUrl,
      title:       'ROUGH ASSORT LIST',
      columns:     _tableColumns,
      data:        data,
      showSearch:  true,
      searchFields: const [
        ErpSearchFieldConfig(key: 'kapanNo', label: 'KAPAN NO', width: 150),
        ErpSearchFieldConfig(key: 'jno',     label: 'JNO',      width: 120),
      ],
      selectedRow: _selectedRow,
      onRowTap:    _onRowTap,
      emptyMessage: prov.isLoaded ? 'No entries found' : 'Loading...',
    );
  }
}