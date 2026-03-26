// lib/screens/trn_spk_dept_iss_entry.dart

import 'package:collection/collection.dart';
import 'package:diam_mfg/providers/charni_provider.dart';
import 'package:diam_mfg/providers/counter_manager_det_provider.dart';
import 'package:diam_mfg/providers/counter_provider.dart';
import 'package:diam_mfg/providers/dept_provider.dart';
import 'package:diam_mfg/providers/dept_group_provider.dart';
import 'package:diam_mfg/providers/dept_process_provider.dart';
import 'package:diam_mfg/providers/employee_provider.dart';
import 'package:diam_mfg/providers/remarks_provider.dart';
import 'package:diam_mfg/providers/spk_dept_iss_provider.dart';
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
import '../models/spkDeptIss_mst_model.dart';
import '../models/user_visibility_model.dart';
import '../providers/auth_provider.dart';
import '../providers/counter_display_det_provider.dart';
import '../providers/purity_provider.dart';
import '../providers/shape_provider.dart';
import '../providers/user_visibility_provider.dart';

String _f3(double? v) => v == null ? '0.000' : v.toStringAsFixed(3);

// ══════════════════════════════════════════════════════════════════════════════
class TrnSpkDeptIssEntry extends StatefulWidget {
  const TrnSpkDeptIssEntry({super.key});
  @override
  State<TrnSpkDeptIssEntry> createState() => _TrnSpkDeptIssEntryState();
}

class _TrnSpkDeptIssEntryState extends State<TrnSpkDeptIssEntry> {
  final ErpThemeVariant _themeVariant = ErpThemeVariant.frost;
  ErpTheme get _theme => ErpTheme(_themeVariant);
   GlobalKey<ErpFormState> _erpFormKey = GlobalKey<ErpFormState>();
  SpkDeptIssDetModel? _scannedDet;
  Map<String, dynamic>? _selectedRow;
  SpkDeptIssMstModel?   _selectedMst;
  bool _isEditMode        = false;
  bool _showTableOnMobile = false;

  Map<String, String> _formValues = {};

  int?    _fromCrId;
  String? _fromDeptName;
  int?    _toCrId;
  String? _toDeptName;

  List<SpkDeptIssDetModel>   _detRows    = [];
  List<Map<String, dynamic>> _detDisplay = [];
  int? _editingDetIndex;

  final Map<String, String> _entryVals = {};
  final String? token = AppStorage.getString('token');

  // ──────────────────────────────────────────────────────────────────────────
  //  HELPERS
  // ──────────────────────────────────────────────────────────────────────────
  // deptCode → deptName via DeptProvider
  String _deptNameFor(int? deptCode) {
    if (deptCode == null) return '';
    try {
      return context.read<DeptProvider>().list
          .firstWhere((d) => d.deptCode == deptCode).deptName ?? '';
    } catch (_) { return ''; }
  }

  // deptGroupCode → deptGroupName via DeptGroupProvider
  String _deptGroupNameFor(int? code) {
    if (code == null) return '';
    try {
      return context.read<DeptGroupProvider>().list
          .firstWhere((d) => d.deptGroupCode == code).deptGroupName ?? '';
    } catch (_) { return ''; }
  }

  // ──────────────────────────────────────────────────────────────────────────
  //  TABLE COLUMNS
  // ──────────────────────────────────────────────────────────────────────────
  // List<ErpColumnConfig> get _tableColumns => [
  //   ErpColumnConfig(key: 'spkDeptIssMstID', label: 'ID',      width: 70,  required: true),
  //   ErpColumnConfig(key: 'spkDeptIssDate',  label: 'DATE',    width: 110, required: true, isDate: true),
  //   ErpColumnConfig(key: 'fromName',        label: 'FROM',    width: 150),
  //   ErpColumnConfig(key: 'toName',          label: 'TO',      width: 150),
  //   ErpColumnConfig(key: 'processName',     label: 'PROCESS', width: 130),
  //   ErpColumnConfig(key: 'totalPc',         label: 'TOT PC',  width: 80,  align: ColumnAlign.right),
  //   ErpColumnConfig(key: 'totalWt',         label: 'TOT WT',  width: 100, align: ColumnAlign.right),
  // ];
  List<ErpColumnConfig> get _tableColumns => [
    ErpColumnConfig(key: 'spkDeptIssMstID', label: 'ID',        width: 70,  required: true),
    ErpColumnConfig(key: 'spkDeptIssDate',  label: 'DATE',      width: 160, isDate: true),
    ErpColumnConfig(key: 'spkDeptIssTime',  label: 'TIME',      width: 140),
    ErpColumnConfig(key: 'fromName',        label: 'FROM MGR',  width: 180),
    ErpColumnConfig(key: 'fromDeptName',    label: 'FROM DEPT', width: 180),
    ErpColumnConfig(key: 'toName',          label: 'TO MGR',    width: 160),
    ErpColumnConfig(key: 'toDeptName',      label: 'TO DEPT',   width: 160),
    ErpColumnConfig(key: 'processName',     label: 'PROCESS',   width: 150),
    ErpColumnConfig(key: 'deptName',        label: 'DEPT',      width: 140),
    ErpColumnConfig(key: 'jno',             label: 'JNO',       width: 140,  align: ColumnAlign.right),
    ErpColumnConfig(key: 'totPkt',          label: 'TOT PKT',   width: 170,  align: ColumnAlign.right),
    ErpColumnConfig(key: 'totalPc',         label: 'TOT PC',    width: 170,  align: ColumnAlign.right),
    ErpColumnConfig(key: 'totalWt',         label: 'TOT WT',    width: 170,  align: ColumnAlign.right),
    // ErpColumnConfig(key: 'users',           label: 'USERS',     width: 120),
  ];
  String? _selectedRadioCode;
//   List<List<ErpFieldConfig>> _buildFormRows() {
//     final counterProv = context.read<CounterProvider>();
//     final mgDetProv   = context.read<CounterManagerDetProvider>();
//     final procProv    = context.read<DeptProcessProvider>();
//     final charniProv  = context.read<CharniProvider>();
//     final tensProv    = context.read<TensionsProvider>();
//
//     bool isFromSelected    = _fromCrId != null;
//     bool isToSelected      = _toCrId != null;
//     bool isProcessSelected = _processSelected;
//
//   final fromItems = counterProv.list
//           .where((c) {
//         final grp = _deptGroupNameFor(c.deptGroupCode).toUpperCase();
//         return grp.contains('CLEAVING') || grp.contains('CLV');
//       })
//           .map((c) => ErpDropdownItem(
//         label: '${c.crName ?? ''}  |  ${_deptNameFor(c.deptCode)}',
//         value: c.crId?.toString() ?? '',
//       ))
//           .toList();
//
//       // ── To Manager: CounterManagerDet where crId == _fromCrId → allowCrId ─
//       final List<ErpDropdownItem> toItems = _fromCrId == null
//           ? []
//           : mgDetProv.list
//           .where((m) => m.crId == _fromCrId && m.allowCrId != null)
//           .map((m) => m.allowCrId!)
//           .toSet()
//           .map((allowId) {
//         try {
//           final c = counterProv.list.firstWhere((c) => c.crId == allowId);
//           return ErpDropdownItem(
//             label: '${c.crName ?? ''}  |  ${_deptNameFor(c.deptCode)}',
//             value: c.crId?.toString() ?? '',
//           );
//         } catch (_) {
//           return ErpDropdownItem(label: 'ID:$allowId', value: '$allowId');
//         }
//       })
//           .toList();
//
//       // ── Process: (From issue codes) ∩ (To receive codes) ─────────────────
//       // Issue codes: CounterManagerDet where crId == _fromCrId
//       // Receive codes: CounterManagerDet where allowCrId == _toCrId
//       final List<ErpDropdownItem> processItems = (_fromCrId == null || _toCrId == null)
//           ? []
//           : () {
//         final issueCodes = mgDetProv.list
//             .where((m) => m.crId == _fromCrId && m.deptProcessCode != null)
//             .map((m) => m.deptProcessCode!)
//             .toSet();
//
//         final recvCodes = mgDetProv.list
//             .where((m) => m.allowCrId == _toCrId && m.deptProcessCode != null)
//             .map((m) => m.deptProcessCode!)
//             .toSet();
//
//         final matched = issueCodes.intersection(recvCodes);
//
//         return matched.map((code) {
//           String label = '$code';
//           try {
//             label = procProv.list
//                 .firstWhere((p) => p.deptProcessCode == code)
//                 .deptProcessName ?? '$code';
//           } catch (_) {}
//           return ErpDropdownItem(label: label, value: code.toString());
//         }).toList();
//       }();
//
//       // ── Charni ────────────────────────────────────────────────────────────
//       final charniItems = charniProv.list
//           .where((e) => e.active == true)
//           .map((e) => ErpDropdownItem(
//         label: e.charniName ?? '',
//         value: e.charniCode?.toString() ?? '',
//       ))
//           .toList();
//
//       // ── Tensions ──────────────────────────────────────────────────────────
//       final tensItems = tensProv.list.where((e) => e.active == true).toList()
//         ..sort((a, b) => (a.sortID ?? 0).compareTo(b.sortID ?? 0));
//       final tensDropdown = tensItems
//           .map((e) => ErpDropdownItem(
//         label: e.tensionsName ?? '',
//         value: e.tensionsCode?.toString() ?? '',
//       ))
//           .toList();
//
//     List<ErpFieldConfig> entryFields = [
//       ErpFieldConfig(
//         key: 'orgPc',
//         label: 'ORG PC',
//         type: ErpFieldType.number,
//         readOnly: true,
//         sectionIndex: 1,
//         isEntryField: true,
//       ),
//       ErpFieldConfig(
//         key: 'orgWt',
//         label: 'ORG WT',
//         type: ErpFieldType.amount,
//         readOnly: true,
//         sectionIndex: 1,
//         isEntryField: true,
//       ),
//       ErpFieldConfig(
//         key: 'issPc',
//         label: 'ISS PC',
//         type: ErpFieldType.number,
//         readOnly: true,
//         sectionIndex: 1,
//         isEntryField: true,
//       ),
//       ErpFieldConfig(
//         key: 'issWt',
//         label: 'ISS WT',
//         type: ErpFieldType.amount,
//         readOnly: true,
//         sectionIndex: 1,
//         isEntryField: true,
//         showAddButton: true,
//       ),
//     ];
//
//     // ✅ Dynamic entry fields (TO)
//     if (isProcessSelected) {
//       for (final f in _toDisplayFields) {
//         if (f.userVisibilityCode == null) continue;
//         if ((f.userVisibilityName ?? '').isEmpty) continue;
//         entryFields.add(
//           ErpFieldConfig(
//             key: 'entry_${f.userVisibilityCode}',
//             label: f.userVisibilityName ?? '',
//             type: ErpFieldType.text,
//             readOnly: false,
//             sectionIndex: 1,
//             isEntryField: true,
//           ),
//         );
//       }
//
//     }
//     List<ErpRadioOption> _buildRadioOptions() {
//       const radioNames = ['BCODE', 'ID', 'CUT LOT', 'QR CODE','JNO'];
//
//       return _fromDisplayFields
//           .where((f) =>
//       f.userVisibilityCode != null &&
//           radioNames.contains((f.userVisibilityName ?? '').toUpperCase()))
//           .map((f) => ErpRadioOption(
//         label: f.userVisibilityName ?? '',
//         value: f.userVisibilityCode.toString(),
//       ))
//           .toList();
//     }
//     // ───────── MAIN SECTIONS ─────────
//     List<List<ErpFieldConfig>> rows = [
//       // ───── MASTER ─────
//       [
//         ErpFieldConfig(
//           key: 'spkDeptIssDate',
//           label: 'DATE',
//           type: ErpFieldType.date,
//           readOnly: true,
//           sectionTitle: 'DEPT ISSUE ENTRY',
//           sectionIndex: 0, // ✅ FIX
//
//         ),
//         ErpFieldConfig(
//           key: 'time',
//           label: 'TIME',
//           type: ErpFieldType.text,
//           readOnly: true,
//           sectionIndex: 0, // ✅ FIX
//
//         ),
//         ErpFieldConfig(
//           key: 'spkDeptIssMstID',
//           label: 'ID',
//           type: ErpFieldType.number,
//           readOnly: true,
//           sectionIndex: 0, // ✅ FIX
//
//         ),
//         ErpFieldConfig(
//           key: 'fromCrId',
//           label: 'FROM',
//           type: ErpFieldType.dropdown,
//           dropdownItems: fromItems,
//           sectionIndex: 0, // ✅ FIX
//
//         ),
//         ErpFieldConfig(
//           key: 'fromDept',
//           label: 'DEPT',
//           sectionIndex: 0, // ✅ FIX
//
//           type: ErpFieldType.text,
//           readOnly: true,
//         ),
//         ErpFieldConfig(
//           key: 'toCrId',
//           label: 'TO',
//           type: ErpFieldType.dropdown,
//           dropdownItems: toItems,
//           sectionIndex: 0, // ✅ FIX
//
//           readOnly: !isFromSelected,
//         ),
//         ErpFieldConfig(
//           key: 'toDept',
//           label: 'DEPT',
//           sectionIndex: 0, // ✅ FIX
//
//           type: ErpFieldType.text,
//           readOnly: true,
//         ),
//         ErpFieldConfig(
//           key: 'deptProcessCode',
//           label: 'PROCESS',
//           sectionIndex: 0, // ✅ FIX
//
//           type: ErpFieldType.dropdown,
//           dropdownItems: processItems,
//           readOnly: !isToSelected,
//         ),
//         ErpFieldConfig(
//           key: 'deptName',
//           label: 'DEPT',
//           type: ErpFieldType.text,
//           readOnly: true,
//           sectionIndex: 0, // ✅ FIX
//
//         ),
//         // ErpFieldConfig(
//         //   key: 'qrCode',
//         //   label: 'QR',
//         //   sectionIndex: 0, // ✅ FIX
//         //
//         //   type: ErpFieldType.text,
//         // ),
//       ],
//
//       // ───── ENTRY ─────
//       // entryFields,
//     ];
//
//     // ───── CHARNI + TENSION ─────
//     if (isProcessSelected && _toDisplayFields.isNotEmpty) {
//       rows.add([
//         ErpFieldConfig(
//           key: 'charniCode',
//           label: 'CHARNI',
//           sectionIndex: 2, // ✅ FIX
//
//           type: ErpFieldType.dropdown,
//           dropdownItems: charniItems,
//         ),
//         ErpFieldConfig(
//           key: 'tensionsCode',
//           label: 'TENSION',    sectionIndex: 2, // ✅ FIX
//
//
//           type: ErpFieldType.dropdown,
//           dropdownItems: tensDropdown,
//         ),
//       ]);
//     }
//
//     // ───── DYNAMIC DISPLAY FIELDS ─────
//     // if (isProcessSelected && _toDisplayFields.isNotEmpty) {
//     //   List<ErpFieldConfig> dynamicFields = [];
//     //
//     //   for (final f in _fromDisplayFields) {
//     //     if (f.userVisibilityCode == null) continue;
//     //     if ((f.userVisibilityName ?? '').isEmpty) continue;
//     //     dynamicFields.add(
//     //       ErpFieldConfig(
//     //         key: 'from_${f.userVisibilityCode}',
//     //         label: f.userVisibilityName ?? '',
//     //         type: ErpFieldType.text,
//     //         sectionIndex: 3, // ✅ FIX
//     //
//     //         readOnly: true,
//     //       ),
//     //     );
//     //   }
//     //   //
//     //   // for (final f in _toDisplayFields) {
//     //   //   if (f.userVisibilityCode == null) continue;
//     //   //   if ((f.userVisibilityName ?? '').isEmpty) continue;
//     //   //
//     //   //   dynamicFields.add(
//     //   //     ErpFieldConfig(
//     //   //       key: 'to_${f.userVisibilityCode}',
//     //   //       label: f.userVisibilityName ?? '',
//     //   //       type: ErpFieldType.text,
//     //   //       sectionIndex: 3, // ✅ FIX
//     //   //
//     //   //     ),
//     //   //   );
//     //   // }
//     //
//     //   if (dynamicFields.isNotEmpty) {
//     //     rows.add(dynamicFields);
//     //   }
//     //   if (isProcessSelected && _toDisplayFields.isNotEmpty) {
//     //
//     //     rows.add(entryFields);
//     //   }
//     // }
//     if (isProcessSelected && _toDisplayFields.isNotEmpty) {
//       const radioNames = ['BCODE', 'ID', 'CUT LOT', 'QR CODE','JNO'];
//
//       /// 🔥 RADIO OPTIONS BUILD
//       final radioItems = _fromDisplayFields
//           .where((f) =>
//       f.userVisibilityCode != null &&
//           radioNames.contains((f.userVisibilityName ?? '').toUpperCase()))
//           .map((f) => ErpRadioOption(
//         label: f.userVisibilityName ?? '',
//         value: f.userVisibilityCode.toString(),
//       ))
//           .toList();
//
//       /// 🔥 NORMAL FIELDS
//       final normalFields = _fromDisplayFields
//           .where((f) =>
//       f.userVisibilityCode != null &&
//           !radioNames.contains((f.userVisibilityName ?? '').toUpperCase()))
//           .map((f) => ErpFieldConfig(
//         key: 'from_${f.userVisibilityCode}',
//         label: f.userVisibilityName ?? '',
//         type: ErpFieldType.text,
//         sectionIndex: 3,
//       ))
//           .toList();
//
//       /// 🔥 RADIO + INPUT SAME ROW
//       if (radioItems.isNotEmpty) {
//         rows.add([
//           ErpFieldConfig(
//             key: 'scanType',
//             label: 'TYPE',
//             type: ErpFieldType.radio,
//             radioItems: radioItems,
//             sectionIndex: 3,
//             flex: 2,
//           ),
//
//           ErpFieldConfig(
//             key: 'scanValue',
//             label: '',
//             type: ErpFieldType.text,
//             sectionIndex: 3,
//             flex: 3,
//           ),
//         ]);
//       }
//
//       /// 🔥 NORMAL TEXTFIELDS BELOW
//       if (normalFields.isNotEmpty) {
//         rows.add(normalFields);
//       }
//
//       /// ENTRY FIELDS
//       rows.add(entryFields);
//     }
// // 🔥 IMPORTANT FIX
//     if (isProcessSelected) {
//       for (final f in _toDisplayFields) {
//         if (f.userVisibilityCode == null) continue;
//
//         _formValues.putIfAbsent(
//             'entry_${f.userVisibilityCode}', () => '');
//         _formValues.putIfAbsent(
//             'to_${f.userVisibilityCode}', () => '');
//       }
//
//       for (final f in _fromDisplayFields) {
//         if (f.userVisibilityCode == null) continue;
//
//         _formValues.putIfAbsent(
//             'from_${f.userVisibilityCode}', () => '');
//       }
//     }
//     for (int s = 0; s < rows.length; s++) {
//       for (int f = 0; f < rows[s].length; f++) {
//         final field = rows[s][f];
//         if (field.sectionIndex == null) {
//           debugPrint('⚠️ NULL sectionIndex → section[$s] field[$f] key=${field.key}');
//         }
//         final nullItems = (field.dropdownItems ?? [])
//             .where((item) => item == null || item.value == null || item.value.isEmpty)
//             .toList();
//         if (nullItems.isNotEmpty) {
//           debugPrint('⚠️ NULL dropdown item → section[$s] field[$f] key=${field.key}');
//         }
//       }
//     }
//     return _sanitizeRows(rows);
//   }
  Future<void> _onBCodeScanned(String bCode) async {
    final rows = await context.read<SpkDeptIssProvider>().fetchByBCode(
      bCode:    bCode,
      fromCrId: _fromCrId!.toString(),
    );

    if (!mounted) return;
    _isBCodePending = false;  // ← ADD: scan complete

    // ── INVALID BCODE ────────────────────────────────────────────────────
    if (rows.isEmpty) {
      _showSnack('BCode "$bCode" not found!');  // ← dialog hatao, snackbar rakho

      // Field clear karo aur focus wapas bhejo
      _entryVals['scanValue'] = '';
      _erpFormKey.currentState?.updateFieldValue('scanValue', '');
      Future.delayed(
        const Duration(milliseconds: 100),
            () => _erpFormKey.currentState?.focusField('scanValue'),
      );
      return;
    }

    final r = rows.first;

    void set(String k, String? v) {
      _entryVals[k] = v ?? '';
      _erpFormKey.currentState?.updateFieldValue(k, v ?? '');
    }

    set('orgPc', r.pc?.toString());
    set('orgWt', _f3(r.wt));
    set('issPc', r.issPc?.toString());
    set('issWt', _f3(r.issWt));
    set('jnoRecPc',  r.jnoRecPc?.toString());
    set('shapeCode', r.shapeCode?.toString());
    set('purityCode', r.purityCode?.toString());
    setState(() => _scannedDet = r);

    // ── Valid — aage focus karo ──────────────────────────────────────────
    Future.delayed(
      const Duration(milliseconds: 100),
          () => _erpFormKey.currentState?.focusField('recpc'),
    );
  }
  // Future<void> _onBCodeScanned(String bCode) async {
  //   final rows = await context.read<SpkDeptIssProvider>().fetchByBCode(
  //     bCode:    bCode,
  //     fromCrId: _fromCrId!.toString(),
  //   );
  //   if (!mounted || rows.isEmpty) return;
  //
  //   final r = rows.first;
  //
  //   void set(String k, String? v) {
  //     _entryVals[k] = v ?? '';
  //     _erpFormKey.currentState?.updateFieldValue(k, v ?? '');
  //   }
  //
  //   set('orgPc',  r.pc?.toString());
  //   set('orgWt',  _f3(r.wt));
  //   set('issPc',  r.issPc?.toString());
  //   set('issWt',  _f3(r.issWt));
  //
  //   // Store for det row save
  //   setState(() {
  //     _scannedDet = r; // temp store
  //   });
  // }
  void _calcDmWt() {

    final recWt  = double.tryParse(_entryVals['recwt']  ?? '') ?? 0;
    final issWt  = double.tryParse(_entryVals['issWt']  ?? '') ?? 0;
    final baseWt = recWt > 0 ? recWt : issWt;
    final dmPer  = double.tryParse(_entryVals['dmper']  ?? '') ?? 0;
    final dmWt   = baseWt * dmPer / 100;
    _entryVals['dmwt'] = _f3(dmWt);
    _erpFormKey.currentState?.updateFieldValue('dmwt', _f3(dmWt));
  }
// Dm Wt = Rec Wt * Dm Per / 100
//   void _calcDmWt() {
//     final recWt  = double.tryParse(_entryVals['recwt']  ?? '') ?? 0;
//     final dmPer  = double.tryParse(_entryVals['dmper']  ?? '') ?? 0;
//     final dmWt   = recWt * dmPer / 100;
//     _entryVals['dmwt'] = _f3(dmWt);
//     _erpFormKey.currentState?.updateFieldValue('dmwt', _f3(dmWt));
//   }

// Loss Wt = Iss Wt - K Wt,  Loss Pc = Iss Pc - K Pc
  void _calcLoss() {
    final issWt  = double.tryParse(_entryVals['issWt']  ?? '') ?? 0;
    final kWt    = double.tryParse(_entryVals['kwt']    ?? '') ?? 0;
    final issPc  = int.tryParse(_entryVals['issPc']     ?? '') ?? 0;
    final kPc    = int.tryParse(_entryVals['kpc']       ?? '') ?? 0;

    final lossWt = issWt - kWt;
    final lossPc = issPc - kPc;

    _entryVals['losswt'] = _f3(lossWt);
    _entryVals['losspc'] = '$lossPc';
    _erpFormKey.currentState?.updateFieldValue('losswt', _f3(lossWt));
    _erpFormKey.currentState?.updateFieldValue('losspc', '$lossPc');
  }
  bool _lockMasterFields = false;
  List<List<ErpFieldConfig>> _buildFormRows() {
    final counterProv = context.read<CounterProvider>();
    final mgDetProv   = context.read<CounterManagerDetProvider>();
    final procProv    = context.read<DeptProcessProvider>();
    final charniProv    = context.read<CharniProvider>();
    final tensProv    = context.read<TensionsProvider>();

    bool isFromSelected    = _fromCrId != null;
    bool isToSelected      = _toCrId != null;
    bool isProcessSelected = _processSelected;

      final fromItems = counterProv.list
          .where((c) {
        final grp = _deptGroupNameFor(c.deptGroupCode).toUpperCase();
        return grp.contains('CLEAVING') || grp.contains('CLV');
      })
          .map((c) => ErpDropdownItem(
        label: '${c.crName ?? ''}  |  ${_deptNameFor(c.deptCode)}',
        value: c.crId?.toString() ?? '',
      ))
          .toList();

      // ── To Manager: CounterManagerDet where crId == _fromCrId → allowCrId ─
      final List<ErpDropdownItem> toItems = _fromCrId == null
          ? []
          : mgDetProv.list
          .where((m) => m.crId == _fromCrId && m.allowCrId != null)
          .map((m) => m.allowCrId!)
          .toSet()
          .map((allowId) {
        try {
          final c = counterProv.list.firstWhere((c) => c.crId == allowId);
          return ErpDropdownItem(
            label: '${c.crName ?? ''}  |  ${_deptNameFor(c.deptCode)}',
            value: c.crId?.toString() ?? '',
          );
        } catch (_) {
          return ErpDropdownItem(label: 'ID:$allowId', value: '$allowId');
        }
      })
          .toList();

      // ── Process: (From issue codes) ∩ (To receive codes) ─────────────────
      // Issue codes: CounterManagerDet where crId == _fromCrId
      // Receive codes: CounterManagerDet where allowCrId == _toCrId
      final List<ErpDropdownItem> processItems = (_fromCrId == null || _toCrId == null)
          ? []
          : () {
        final issueCodes = mgDetProv.list
            .where((m) => m.crId == _fromCrId && m.deptProcessCode != null)
            .map((m) => m.deptProcessCode!)
            .toSet();

        final recvCodes = mgDetProv.list
            .where((m) => m.allowCrId == _toCrId && m.deptProcessCode != null)
            .map((m) => m.deptProcessCode!)
            .toSet();

        final matched = issueCodes.intersection(recvCodes);

        return matched.map((code) {
          String label = '$code';
          try {
            label = procProv.list
                .firstWhere((p) => p.deptProcessCode == code)
                .deptProcessName ?? '$code';
          } catch (_) {}
          return ErpDropdownItem(label: label, value: code.toString());
        }).toList();
      }();

      // ── Charni ────────────────────────────────────────────────────────────
      final charniItems = charniProv.list
          .where((e) => e.active == true)
          .map((e) => ErpDropdownItem(
        label: e.charniName ?? '',
        value: e.charniCode?.toString() ?? '',
      ))
          .toList();

      // ── Tensions ──────────────────────────────────────────────────────────
      final tensItems = tensProv.list.where((e) => e.active == true).toList()
        ..sort((a, b) => (a.sortID ?? 0).compareTo(b.sortID ?? 0));
      final tensDropdown = tensItems
          .map((e) => ErpDropdownItem(
        label: e.tensionsName ?? '',
        value: e.tensionsCode?.toString() ?? '',
      ))
          .toList();


    /// ───────── MASTER ROW ─────────
    List<List<ErpFieldConfig>> rows = [
      [
        ErpFieldConfig(key: 'spkDeptIssDate', label: 'DATE', type: ErpFieldType.date, readOnly: true, sectionIndex: 0),
        ErpFieldConfig(key: 'time', label: 'TIME', type: ErpFieldType.text, readOnly: true, sectionIndex: 0),
        ErpFieldConfig(key: 'spkDeptIssMstID', label: 'ID', type: ErpFieldType.number, readOnly: true, sectionIndex: 0),
      ],

      [
        ErpFieldConfig(key: 'fromCrId', label: 'FROM', type: ErpFieldType.dropdown, dropdownItems: fromItems, sectionIndex: 0, readOnly:  _lockMasterFields||_isEditMode),
        ErpFieldConfig(key: 'fromDept', label: 'DEPT', type: ErpFieldType.text, readOnly: true, sectionIndex: 0),
        ErpFieldConfig(key: 'toCrId', label: 'TO', type: ErpFieldType.dropdown, dropdownItems: toItems, readOnly: !isFromSelected ||  _lockMasterFields||_isEditMode, sectionIndex: 0),
        ErpFieldConfig(key: 'toDept', label: 'DEPT', type: ErpFieldType.text, readOnly: true, sectionIndex: 0),
        ErpFieldConfig(key: 'deptProcessCode', label: 'PROCESS', type: ErpFieldType.dropdown, dropdownItems: processItems, readOnly: !isToSelected || _lockMasterFields|| _isEditMode, sectionIndex: 0),
        ErpFieldConfig(key: 'deptName', label: 'DEPT', type: ErpFieldType.text, readOnly: true, sectionIndex: 0),
      ],
      // [
      //   ErpFieldConfig(key: 'spkDeptIssDate', label: 'DATE', type: ErpFieldType.date, readOnly: true, sectionIndex: 0,),
      //   ErpFieldConfig(key: 'time', label: 'TIME', type: ErpFieldType.text, readOnly: true, sectionIndex: 0),
      //   ErpFieldConfig(key: 'spkDeptIssMstID', label: 'ID', type: ErpFieldType.number, readOnly: true, sectionIndex: 0),
      //   ErpFieldConfig(key: 'fromCrId', label: 'FROM', type: ErpFieldType.dropdown, dropdownItems: fromItems, sectionIndex: 0,readOnly: _isAdding|| _isEditMode),
      //   ErpFieldConfig(key: 'fromDept', label: 'DEPT', type: ErpFieldType.text, readOnly: true, sectionIndex: 0),
      //   ErpFieldConfig(key: 'toCrId', label: 'TO', type: ErpFieldType.dropdown, dropdownItems: toItems, readOnly:!isFromSelected || _isAdding|| _isEditMode, sectionIndex: 0,),
      //   ErpFieldConfig(key: 'toDept', label: 'DEPT', type: ErpFieldType.text, readOnly: true, sectionIndex: 0),
      //   ErpFieldConfig(key: 'deptProcessCode', label: 'PROCESS', type: ErpFieldType.dropdown, dropdownItems: processItems, readOnly: !isToSelected || _isAdding|| _isEditMode, sectionIndex: 0),
      //   ErpFieldConfig(key: 'deptName', label: 'DEPT', type: ErpFieldType.text, readOnly: true, sectionIndex: 0),
      // ],
    ];
    final Map<String, UserVisibilityModel> merged = {};

    for (var f in [..._fromDisplayFields, ..._toDisplayFields]) {
      final name = (f.userVisibilityName ?? '').toUpperCase();

      if (f.entryType != 'DEPT') continue; // ✅ ONLY DEPT
      if (['ALL'].contains(name)) continue;

      merged[name] = f; // ✅ remove duplicate
    }
    if (isProcessSelected) {
      final hasCharni   = merged.containsKey('CHARNI');
      final hasTensions = merged.containsKey('TENSIONS');

      final List<ErpFieldConfig> charniTensRow = [];

      if (hasCharni) {
        charniTensRow.add(ErpFieldConfig(
          key: 'charniCode', label: 'CHARNI',
          type: ErpFieldType.dropdown,
          dropdownItems: charniItems,
          sectionIndex: 2,
          width: 200
        ));
      }
      if (hasTensions) {
        charniTensRow.add(ErpFieldConfig(
          key: 'tensionsCode', label: 'TENSION',
          type: ErpFieldType.dropdown,
          dropdownItems: tensDropdown,
          sectionIndex: 2,
            width: 200

        ));
      }
      if (charniTensRow.isNotEmpty) {
        rows.add(charniTensRow);
      }
    }
    /// ───────── 🔥 CHARNI + TENSION (PROCESS BASED) ─────────
    // if (isProcessSelected) {
    //   rows.add([
    //     ErpFieldConfig(
    //       key: 'charniCode',
    //       label: 'CHARNI',
    //       type: ErpFieldType.dropdown,
    //       dropdownItems: charniItems,
    //       sectionIndex: 2,
    //     ),
    //     ErpFieldConfig(
    //       key: 'tensionsCode',
    //       label: 'TENSION',
    //       type: ErpFieldType.dropdown,
    //       dropdownItems: tensDropdown,
    //       sectionIndex: 2,
    //     ),
    //   ]);
    // }
    /// ───────── 🔥 MERGE FROM + TO (MAIN CHANGE) ─────────


    /// ───────── 🔥 RADIO TOP LINE ─────────
  if(_processSelected){
    const radioNames = ['BCODE','ID','JNO','CUT LOT','QR CODE'];

    final radioItems = merged.values
        .where((f) => radioNames.contains((f.userVisibilityName ?? '').toUpperCase()))
        .map((f) => ErpRadioOption(
      label: f.userVisibilityName ?? '',
      value: f.userVisibilityCode.toString(),
    ))
        .toList();
    final selectedField = merged.values.firstWhereOrNull(
          (f) => f.userVisibilityCode.toString() == _selectedRadioCode,
    );
    final itemCount = radioItems.length;

    double radioWidth;

    if (itemCount <= 1) {
      radioWidth = 150;
    }else if (itemCount <= 2) {
      radioWidth = 200;
    } else if (itemCount == 3) {
      radioWidth = 300;
    } else if (itemCount == 4) {
      radioWidth = 400;
    } else {
      radioWidth = 500;
    }
    final selectedName = (selectedField?.userVisibilityName ?? '').toUpperCase();
    if (radioItems.isNotEmpty) {
      rows.add([
        ErpFieldConfig(
          key: 'scanType',
          label: '',
          type: ErpFieldType.radio,
          radioItems: radioItems,
          isEntryField: true,
          sectionIndex: 3,
          width: radioWidth,

          // flex: 5,
        ),
        ErpFieldConfig(
          key: 'scanValue',
          label: '',
          isEntryField: true,

          type: ErpFieldType.text,
          readOnly: selectedName == 'CUT LOT',   // ✅ FIX

          sectionIndex: 3,
          width: 200,

          // flex: 3,
        ),
      ]);
    }


    /// ───────── 🔥 CUT NO SPECIAL ─────────
    if (selectedName=='CUT LOT') {
      rows.add([
        ErpFieldConfig(key: 'cutNo', label: 'CUT NO', type: ErpFieldType.text, sectionIndex: 3,          isEntryField: true,
        ),
        ErpFieldConfig(key: 'cutFrom', label: 'FROM', type: ErpFieldType.text, sectionIndex: 3,          isEntryField: true,
        ),
        ErpFieldConfig(key: 'cutTo', label: 'TO', type: ErpFieldType.text, sectionIndex: 3,          isEntryField: true,
        ),
      ]);
    }

    /// ───────── 🔥 PC-WT PAIRS ─────────
    // final pairs = [
    //   ['REC PC', 'REC WT'],
    //   ['K PC', 'K WT'],
    //   ['BR PC', 'BR WT'],
    //   ['TOPS PC', 'TOPS WT'],
    //   ['LOSS PC', 'LOSS WT'],
    //   ['DM PER', 'DM WT'],
    // ];
    //
    // for (var pair in pairs) {
    //   if (merged.containsKey(pair[0]) || merged.containsKey(pair[1])) {
    //     rows.add([
    //       ErpFieldConfig(
    //         key: pair[0].replaceAll(' ', '').toLowerCase(),
    //         label: pair[0],
    //         type: ErpFieldType.text,
    //         sectionIndex: 3,
    //         readOnly: pair[0]=='LOSS PC', // ✅ FIRST readonly
    //       ),
    //       ErpFieldConfig(
    //         key: pair[1].replaceAll(' ', '').toLowerCase(),
    //         label: pair[1],
    //         type: ErpFieldType.text,
    //         sectionIndex: 3,
    //         readOnly: pair[1] == 'DM WT'||pair[1]=='LOSS WT', // ✅ ONLY DM WT readonly
    //       ),
    //     ]);
    //   }
    // }
    //
    // /// ───────── 🔥 LAST ROW ─────────
    // final lastRow = <ErpFieldConfig>[];
    //
    // if (merged.containsKey('EMPLOYEE')) {
    //   lastRow.add(
    //     ErpFieldConfig(
    //       key: 'employee',
    //       label: 'EMPLOYEE',
    //       type: ErpFieldType.text,
    //       sectionIndex: 3,
    //     ),
    //   );
    // }
    //
    // if (merged.containsKey('SIGNER')) {
    //   lastRow.add(
    //     ErpFieldConfig(
    //       key: 'signer',
    //       label: 'SIGNER',
    //       type: ErpFieldType.text,
    //       sectionIndex: 3,
    //     ),
    //   );
    // }
    //
    // if (merged.containsKey('REMARKS')) {
    //   lastRow.add(
    //     ErpFieldConfig(
    //       key: 'remarks',
    //       label: 'REMARKS',
    //       type: ErpFieldType.dropdown,
    //       dropdownItems: context.read<RemarksProvider>().list
    //           .map((e) => ErpDropdownItem(
    //         label: e.remarksName ?? '',
    //         value: e.remarksCode?.toString() ?? '',
    //       ))
    //           .toList(),
    //       sectionIndex: 3,
    //     ),
    //   );
    // }
    //
    // /// ✅ ADD ONLY IF NOT EMPTY
    // if (lastRow.isNotEmpty) {
    //   rows.add(lastRow);
    // }
    final pairs = [
      ['REC PC', 'REC WT'],
      ['K PC', 'K WT'],
      ['BR PC', 'BR WT'],
      ['TOPS PC', 'TOPS WT'],
      ['LOSS PC', 'LOSS WT'],
      ['DM PER', 'DM WT'],
    ];
    bool hasAnyPair = pairs.any((pair) =>
    merged.containsKey(pair[0]) || merged.containsKey(pair[1]));

    /// ───────── 🔥 ALL FIELDS IN SINGLE ROW ─────────
    final List<ErpFieldConfig> singleRowFields = [];

    /// ✅ FIRST → ADD FIXED 4 FIELDS (ONLY IF PAIR EXISTS)
    if (hasAnyPair) {
      singleRowFields.addAll([
        ErpFieldConfig(
          key: 'orgPc',
          label: 'ORG PC',
          type: ErpFieldType.number,
          readOnly: true,
          sectionIndex: 3,
          isEntryField: true,

          flex: 1,
        ),
        ErpFieldConfig(
          key: 'orgWt',
          label: 'ORG WT',
          type: ErpFieldType.amount,
          readOnly: true,
          sectionIndex: 3,
          isEntryField: true,
          flex: 1,
        ),
        ErpFieldConfig(
          key: 'issPc',
          label: 'ISS PC',
          type: ErpFieldType.number,
          readOnly: true,
          sectionIndex: 3,
          isEntryField: true,
          flex: 1,
        ),
        ErpFieldConfig(
          key: 'issWt',
          label: 'ISS WT',
          type: ErpFieldType.amount,
          readOnly: true,
          sectionIndex: 3,
          isEntryField: true,
          showAddButton: true,
          flex: 1,
        ),
      ]);
    }
    /// 🔥 PC-WT PAIRS


    for (var pair in pairs) {
      if (merged.containsKey(pair[0]) || merged.containsKey(pair[1])) {

        singleRowFields.add(
          ErpFieldConfig(
            key: pair[0].replaceAll(' ', '').toLowerCase(),
            label: pair[0],
            type: ErpFieldType.text,
            sectionIndex: 3,
            readOnly: pair[0] == 'LOSS PC',
            isEntryField: true,

            flex: 1,
          ),
        );

        singleRowFields.add(
          ErpFieldConfig(
            key: pair[1].replaceAll(' ', '').toLowerCase(),
            label: pair[1],
            type: ErpFieldType.text,
            sectionIndex: 3,
            isEntryField: true,

            readOnly: pair[1] == 'DM WT' || pair[1] == 'LOSS WT',
            flex: 1,
          ),
        );
      }
    }

    /// 🔥 EMPLOYEE
    if (merged.containsKey('EMPLOYEE')) {
      singleRowFields.add(
        ErpFieldConfig(
          key: 'employee',
          label: 'EMPLOYEE',
          type: ErpFieldType.dropdown,
          dropdownItems: context.read<EmployeeProvider>().list
              .map((e) => ErpDropdownItem(
            label: e.employeeName ?? '',
            value: e.employeeCode?.toString() ?? '',
          ))
              .toList(),
          sectionIndex: 3,
          isEntryField: true,

          flex: 2,
        ),
      );
    }
    if (merged.containsKey('SIGNER')) {

      final signerCounters = context.read<CounterProvider>().list.where((c) {
        final deptName = _deptNameFor(c.deptCode).toUpperCase();
        return deptName == 'SIGNER';
      }).toList();

      singleRowFields.add(
        ErpFieldConfig(
          key: 'signer',
          label: 'SIGNER',
          type: ErpFieldType.dropdown,
          isEntryField: true,
// ✅ dropdown
          dropdownItems: signerCounters
              .map((e) => ErpDropdownItem(
            label: e.logInName ?? '',
            value: e.crId?.toString() ?? '',
          ))
              .toList(),
          sectionIndex: 3,
          flex: 2,
        ),
      );
    }
    /// 🔥 SIGNER
    // if (merged.containsKey('SIGNER')) {
    //   singleRowFields.add(
    //     ErpFieldConfig(
    //       key: 'signer',
    //       label: 'SIGNER',
    //       type: ErpFieldType.text,
    //       sectionIndex: 3,
    //       flex: 2,
    //     ),
    //   );
    // }

    /// 🔥 REMARKS
    if (merged.containsKey('REMARKS')) {
      final selectedProcess = int.tryParse(_formValues['deptProcessCode'] ?? '');
      final remarksItems = context.read<RemarksProvider>().list
          .where((e) =>
      e.active == true &&
          (selectedProcess == null || e.deptProcessCode == selectedProcess))
          .map((e) => ErpDropdownItem(
        label: e.remarksName ?? '',
        value: e.remarksCode?.toString() ?? '',
      ))
          .toList();
      singleRowFields.add(
        ErpFieldConfig(
          key: 'remarks',
          label: 'REMARKS',
          isEntryField: true,

          type: ErpFieldType.dropdown,
          dropdownItems: remarksItems,
          sectionIndex: 3,
          flex: 2,
        ),
      );
    }
    if (merged.containsKey('DUE DAY')) {
      singleRowFields.add(
        ErpFieldConfig(
          key: 'dueDay',
          label: 'DUE DAY',
          isEntryField: true,
          showAddButton: true,


          type: ErpFieldType.text,
          sectionIndex: 3,
          flex: 1,
        ),
      );
    }

    /// ✅ FINAL ADD (ONLY ONE ROW)
    if (singleRowFields.isNotEmpty) {
      rows.add(singleRowFields);
      // rows.add(singleRowFields.skip(4).take(4).toList());
      // rows.add(singleRowFields.skip(8).toList());
    }
  }
    return _sanitizeRows(rows);
  }
  // ── NULL SAFETY WRAPPER ────────────────────────────────────────────────────
  List<List<ErpFieldConfig>> _sanitizeRows(List<List<ErpFieldConfig>> rows) {
    return rows.map((section) {
      return section
          .whereType<ErpFieldConfig>()          // ✅ removes any null ErpFieldConfig
          .map((field) {

        final safeItems = (field.dropdownItems ?? [])
            .whereType<ErpDropdownItem>()   // removes null items
            .where((item) =>
        item.value.isNotEmpty &&
            item.label.isNotEmpty)
            .toList();


        // Return a clean copy only if items changed, else original
        if (safeItems.length != (field.dropdownItems?.length ?? 0)) {
          return ErpFieldConfig(
            key:             field.key,
            label:           field.label,
            type:            field.type,
            flex:            field.flex,
            readOnly:        field.readOnly,
            required:        field.required,
            sectionIndex:    field.sectionIndex ?? 0,   // ✅ never null
            sectionTitle:    field.sectionTitle,
            isEntryField:    field.isEntryField,
            isEntryRequired: field.isEntryRequired,
            showAddButton:   field.showAddButton,

            // is:          field.isDate,
            dropdownItems:   safeItems,
          );
        }
        return field;
      })
          .toList();
    }).toList();
  }
  // ──────────────────────────────────────────────────────────────────────────
  //  INIT
  // ──────────────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.wait([
        context.read<SpkDeptIssProvider>().load(),
        context.read<CounterProvider>().load(),
        context.read<CounterManagerDetProvider>().load(),
        context.read<DeptProvider>().load(),
        context.read<DeptGroupProvider>().load(),
        context.read<DeptProcessProvider>().load(),
        context.read<CharniProvider>().load(),
        context.read<TensionsProvider>().load(),
        context.read<CounterDisplayDetProvider>().load(),
        context.read<UserVisibilityProvider>().load(),
        context.read<EmployeeProvider>().loadEmployees(),
        context.read<RemarksProvider>().load(),
        context.read<ShapeProvider>().load(),
        context.read<PurityProvider>().load(),

      ]);
      if (!mounted) return;
      _setDefaultFormValues();

      // ── Auto-fill From from logged user ─────────────────────────────────
      final loggedUser = context.read<AuthProvider>().user;
      if (loggedUser?.crId != null) {           // ✅ crId (lowercase d)
        _onFromSelected(loggedUser!.crId!.toString());
      }
    });
  }
  List<UserVisibilityModel> _fromDisplayFields = [];
  List<UserVisibilityModel> _toDisplayFields   = [];
  bool _processSelected = false;
  CounterDisplayDetProvider get _displayProv => context.read<CounterDisplayDetProvider>();
  UserVisibilityProvider    get _visProv     => context.read<UserVisibilityProvider>();
  void _setDefaultFormValues() {
    final now   = DateTime.now();
    final today = DateFormat('dd/MM/yyyy').format(now);
    final time  = DateFormat('hh:mm a').format(now);
    _formValues = {
      'spkDeptIssDate':  today,
      'spkDeptIssMstID': '0',
      'time':            time,
    };
    if (mounted) setState(() {});
  }
  // Future<void> _loadFromDisplayFields(int crId) async {
  //   final counter = context.read<CounterProvider>().list
  //       .firstWhereOrNull((c) => c.crId == crId);
  //
  //   if (counter == null) return;
  //
  //   await _displayProv.loadByCounter(counter.counterMstID!);
  //   final data = _displayProv.counterList;
  //
  //
  //   setState(() {
  //     _fromDisplayFields = data
  //         .where((r) =>
  //     r.counterType == 'FROM' &&
  //         r.userVisibilityCode != null)
  //         .map((r) => _visProv.list.firstWhereOrNull(
  //           (v) => v.userVisibilityCode == r.userVisibilityCode,
  //     ))
  //         .whereType<UserVisibilityModel>() // 🔥 NULL FIX
  //         .toList()
  //       ..sort((a, b) => (a.sortID ?? 0).compareTo(b.sortID ?? 0));
  //   });
  //   if (_toDisplayFields.isNotEmpty) {
  //     print('from---${_toDisplayFields.first.userVisibilityName}');
  //   }
  // }
  Future<void> _loadFromDisplayFields(int crId) async {
    final counter = context.read<CounterProvider>().list
        .firstWhereOrNull((c) => c.crId == crId);

    if (counter == null || counter.counterMstID == null) return;

    await _displayProv.loadByCounter(counter.counterMstID!);

    final data = _displayProv.counterList;

    if (!mounted) return;

    setState(() {
      _fromDisplayFields = data
          .where((r) =>
      r.counterType == 'FROM' &&
          r.userVisibilityCode != null &&
          _visProv.list.any((v) =>
          v.userVisibilityCode == r.userVisibilityCode))
          .map((r) {
        final v = _visProv.list.firstWhereOrNull(
                (v) => v.userVisibilityCode == r.userVisibilityCode);
        return v;
      })
          .where((v) =>
      v != null &&
          v.userVisibilityCode != null &&
          (v.userVisibilityName ?? '').isNotEmpty)
          .cast<UserVisibilityModel>()
          .toList()
        ..sort((a, b) =>
            (a.sortID ?? 0).compareTo(b.sortID ?? 0));
    });

    // ✅ safe print
    if (_fromDisplayFields.isNotEmpty) {
      print('FROM → ${_fromDisplayFields.first.userVisibilityName}');
    }
  }
  // ──────────────────────────────────────────────────────────────────────────
  //  FROM SELECTED
  // ──────────────────────────────────────────────────────────────────────────
  int? _fromDeptCode;
  int? _toDeptCodeVal;

  void _onFromSelected(String crIdStr) {
    final crId = int.tryParse(crIdStr);
    if (crId == null) return;
    try {
      final counter  = context.read<CounterProvider>().list.firstWhere((c) => c.crId == crId);
      final deptName = _deptNameFor(counter.deptCode); // ✅ deptCode from CounterModel

      setState(() {
        _fromCrId     = crId;
        _fromDeptName = deptName;
        _toCrId       = null;
        _toDeptName   = null;
        _fromDeptCode = counter.deptCode;  // ← ADD

        _formValues['fromCrId'] = crIdStr;
        _formValues['fromDept'] = deptName;
      });
      _erpFormKey.currentState?.updateFieldValue('fromDept', deptName);
      _erpFormKey.currentState?.updateFieldValue('toCrId', '');
      _erpFormKey.currentState?.updateFieldValue('toDept', '');
      _erpFormKey.currentState?.updateFieldValue('deptProcessCode', '');
      _erpFormKey.currentState?.updateFieldValue('deptName', '');
      _loadFromDisplayFields(crId);
    } catch (_) {}
  }
  Future<void> _loadToDisplayFields(int crId) async {
    final counter = context.read<CounterProvider>().list
        .firstWhereOrNull((c) => c.crId == crId);

    if (counter == null || counter.counterMstID == null) return;

    await _displayProv.loadByCounter(counter.counterMstID!);

    final data = _displayProv.counterList;

    if (!mounted) return;

    setState(() {
      _toDisplayFields = data
          .where((r) =>
      r.counterType == 'TO' &&
          r.userVisibilityCode != null &&
          _visProv.list.any((v) =>
          v.userVisibilityCode == r.userVisibilityCode))
          .map((r) {
        final v = _visProv.list.firstWhereOrNull(
                (v) => v.userVisibilityCode == r.userVisibilityCode);
        return v;
      })
          .where((v) =>
      v != null &&
          v.userVisibilityCode != null &&
          (v.userVisibilityName ?? '').isNotEmpty)
          .cast<UserVisibilityModel>()
          .toList()
        ..sort((a, b) =>
            (a.sortID ?? 0).compareTo(b.sortID ?? 0));
    });

    // ✅ safe print
    if (_toDisplayFields.isNotEmpty) {
      print('TO → ${_toDisplayFields.first.userVisibilityName}');
    }
  }  // Future<void> _loadToDisplayFields(int crId) async {
  //   // Counter ka mstID nikalna padega (agar crId se direct na mile to CounterProvider se)
  //   final counter = context.read<CounterProvider>().list.firstWhereOrNull((c) => c.crId == crId);
  //   if (counter?.counterMstID == null) return;
  //
  //   await _displayProv.loadByCounter(counter?.counterMstID??0);
  //
  //   setState(() {
  //     _toDisplayFields = _displayProv.counterList
  //         .where((r) => r.counterType == 'TO' && r.userVisibilityCode != null)
  //         .map((r) => _visProv.list.firstWhereOrNull((v) => v.userVisibilityCode == r.userVisibilityCode) ?? UserVisibilityModel())
  //         .where((v) => v.userVisibilityCode != null)
  //         .toList()
  //       ..sort((a, b) => (a.sortID ?? 0).compareTo(b.sortID ?? 0));
  //   });
  // }
  // ──────────────────────────────────────────────────────────────────────────
  //  TO SELECTED
  // ──────────────────────────────────────────────────────────────────────────
  void _onToSelected(String crIdStr) {
    final crId = int.tryParse(crIdStr);
    if (crId == null) return;
    try {
      final counter  = context.read<CounterProvider>().list.firstWhere((c) => c.crId == crId);
      final deptName = _deptNameFor(counter.deptCode); // ✅ deptCode

      setState(() {
        _toCrId     = crId;
        _toDeptName = deptName;
        _formValues['toCrId'] = crIdStr;
        _formValues['toDept'] = deptName;
        _toDeptCodeVal = counter.deptCode;  // ← ADD

      });
      _erpFormKey.currentState?.updateFieldValue('toDept', deptName);
      _erpFormKey.currentState?.updateFieldValue('deptName', deptName);
      _erpFormKey.currentState?.updateFieldValue('deptProcessCode', '');
      _loadToDisplayFields(crId);
    } catch (_) {}
  }
  List<ErpFieldConfig> _buildDynamicFields() {
    if (!_processSelected) return [];

    final List<ErpFieldConfig> fields = [];

    // FROM fields
    for (final field in _fromDisplayFields) {
      fields.add(ErpFieldConfig(
        key: 'dyn_from_${field.userVisibilityCode}',
        label: field.userVisibilityName ?? 'Field ${field.userVisibilityCode}',
        type: ErpFieldType.text,          // ya number, date, dropdown — aapke requirement ke hisaab se
        flex: 2,
        sectionIndex: 2,                  // naya section bana sakte ho
        sectionTitle: 'FROM Display Fields',
        // hint, required, etc. aap decide karo
      ));
    }

    // TO fields
    for (final field in _toDisplayFields) {
      fields.add(ErpFieldConfig(
        key: 'dyn_to_${field.userVisibilityCode}',
        label: field.userVisibilityName ?? 'Field ${field.userVisibilityCode}',
        type: ErpFieldType.text,
        flex: 2,
        sectionIndex: 2,
        sectionTitle: _toDisplayFields.isNotEmpty && fields.isEmpty ? 'TO Display Fields' : null,
      ));
    }

    return fields;
  }
  Map<String, UserVisibilityModel> _getMergedFields() {
    final merged = <String, UserVisibilityModel>{};

    for (var f in [..._fromDisplayFields, ..._toDisplayFields]) {
      final name = (f.userVisibilityName ?? '').toUpperCase();

      if (f.entryType != 'DEPT') continue;
      if (['CHARNI', 'TENSIONS', 'ALL'].contains(name)) continue;

      merged[name] = f;
    }

    return merged;
  }
  // ──────────────────────────────────────────────────────────────────────────
  //  PROCESS SELECTED
  // ──────────────────────────────────────────────────────────────────────────
  // void _onProcessSelected(String procCodeStr) {
  //   _formValues['deptProcessCode'] = procCodeStr;
  //   _erpFormKey.currentState?.updateFieldValue('deptName', _toDeptName ?? '');
  // }
   Future<void> _onProcessSelected(String procCodeStr) async {
    _formValues['deptProcessCode'] = procCodeStr;

    if (procCodeStr.isEmpty || _toCrId == null) {
      setState(() => _processSelected = false);
      return;
    }

    await _loadToDisplayFields(_toCrId!);

    if (!mounted) return;

    // 🔥 ADD THIS
    for (final f in _toDisplayFields) {
      if (f.userVisibilityCode == null) continue;
      _formValues['entry_${f.userVisibilityCode}'] ??= '';
      _formValues['to_${f.userVisibilityCode}'] ??= '';
    }

    for (final f in _fromDisplayFields) {
      if (f.userVisibilityCode == null) continue;
      _formValues['from_${f.userVisibilityCode}'] ??= '';
    }
    setState(() {
      _processSelected = _toDisplayFields.isNotEmpty;
      _isAdding = _toDisplayFields.isNotEmpty;

      // ✅ deptName preserve karo — rebuild ke baad bhi dikhega
      _formValues['deptName']  = _toDeptName ?? '';
      _formValues['toDept']    = _toDeptName ?? '';
      _formValues['fromDept']  = _fromDeptName ?? '';
      _formValues['toCrId']    = _toCrId?.toString() ?? '';
      _formValues['fromCrId']  = _fromCrId?.toString() ?? '';

      final merged = _getMergedFields();
      final radioNames = ['BCODE','ID','JNO','CUT LOT','QR CODE'];

      final firstRadio = merged.values.firstWhereOrNull(
            (f) => radioNames.contains((f.userVisibilityName ?? '').toUpperCase()),
      );

      if (firstRadio != null) {
        _selectedRadioCode = firstRadio.userVisibilityCode.toString();
        _formValues['scanType'] = _selectedRadioCode!;
      }
    });
    _rebuildForm();
    // setState(() {
    //   _processSelected = _toDisplayFields.isNotEmpty;
    //   _isAdding = _toDisplayFields.isNotEmpty; // ← process select hone pe auto-start
    //
    //   final merged = _getMergedFields();
    //   final radioNames = ['BCODE','ID','JNO','CUT LOT','QR CODE'];
    //
    //   final firstRadio = merged.values.firstWhereOrNull(
    //         (f) => radioNames.contains((f.userVisibilityName ?? '').toUpperCase()),
    //   );
    //
    //   if (firstRadio != null) {
    //     _selectedRadioCode = firstRadio.userVisibilityCode.toString();
    //     _formValues['scanType'] = _selectedRadioCode!;
    //   }
    // });
    // _rebuildForm();  // ← ADD THIS

     // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _erpFormKey.currentState?.resetForm();
    // });
  }
  // ──────────────────────────────────────────────────────────────────────────
  //  ADD ENTRY
  // ──────────────────────────────────────────────────────────────────────────
//   void _addEntry() {
//     final issPcStr = _entryVals['issPc'] ?? '';
//     final issWtStr = _entryVals['issWt'] ?? '';
//     // if (issPcStr.isEmpty && issWtStr.isEmpty) {
//     //   _showSnack('Iss Pc ya Iss Wt required');
//     //   return;
//     // }
//     final srno = _editingDetIndex != null
//         ? _detRows[_editingDetIndex!].srno
//         : _detRows.length + 1;
//     final recWt = double.tryParse(_entryVals['recwt'] ?? '');
//     final recPc = int.tryParse(_entryVals['recpc']    ?? '');
//
//     final newRow = SpkDeptIssDetModel(
//       srno:         srno,
//       // Scanned packet data
//       id:           _scannedDet?.id,
//       jno:          _scannedDet?.jno,
//       bCode:        _scannedDet?.bCode ?? _entryVals['scanValue'],
//       pktNo:        _scannedDet?.pktNo,
//       cutNo:        _scannedDet?.cutNo,
//       clvCut:       _scannedDet?.clvCut,
//       shapeCode:    _scannedDet?.shapeCode,
//       purityCode:   _scannedDet?.purityCode,
//       colorCode:    _scannedDet?.colorCode,
//       diam:         _scannedDet?.diam,
//       kachaRec:     _scannedDet?.kachaRec ?? 'Y',
//       // Entry values
//       pc:           int.tryParse(_entryVals['orgPc']  ?? ''),
//       wt:           double.tryParse(_entryVals['orgWt'] ?? ''),
//       issPc:        int.tryParse(issPcStr),
//       issWt:        double.tryParse(issWtStr),
//       recPc:        recPc ?? int.tryParse(issPcStr),
//       recWt:        recWt ?? double.tryParse(issWtStr),
//       // Agar recPc nahi to issPc/issWt hi store hoga
//       totalPc:      recPc ?? int.tryParse(issPcStr) ?? 0,
//       totalWt:      recWt ?? double.tryParse(issWtStr),
//       dmWt:         double.tryParse(_entryVals['dmwt']  ?? ''),
//       dmPer:        double.tryParse(_entryVals['dmper'] ?? ''),
//       kPc:          int.tryParse(_entryVals['kpc']      ?? ''),
//       kWt:          double.tryParse(_entryVals['kwt']   ?? ''),
//       brPc:         int.tryParse(_entryVals['brpc']     ?? ''),
//       brWt:         double.tryParse(_entryVals['brwt']  ?? ''),
//       lossPc:       int.tryParse(_entryVals['losspc']   ?? ''),
//       lossWt:       double.tryParse(_entryVals['losswt'] ?? ''),
//       topsPc:       int.tryParse(_entryVals['topspc']   ?? ''),
//       topsWt:       double.tryParse(_entryVals['topswt'] ?? ''),
//       charniCode:   int.tryParse(_formValues['charniCode']  ?? ''),
//       tensionsCode: int.tryParse(_formValues['tensionsCode'] ?? ''),
//       employeeCode: int.tryParse(_entryVals['employee']  ?? ''),
//       signerCode:   int.tryParse(_entryVals['signer']    ?? ''),
//       remarksCode:  int.tryParse(_entryVals['remarks']   ?? ''),
//       dueDay:       int.tryParse(_entryVals['dueDay']    ?? ''),
//       entryType:    'I',
//       formType:     'SPK',
//       pktType:      'A',
//     );
// // Reset scanned det after adding
//     // final newRow = SpkDeptIssDetModel(
//     //   srno:         srno,
//     //   pc:           int.tryParse(_entryVals['orgPc']        ?? ''),
//     //   wt:           double.tryParse(_entryVals['orgWt']     ?? ''),
//     //   issPc:        int.tryParse(issPcStr),
//     //   issWt:        double.tryParse(issWtStr),
//     //   recPc:        int.tryParse(_entryVals['recPc']        ?? ''),
//     //   recWt:        double.tryParse(_entryVals['recWt']     ?? ''),
//     //   employeeCode: int.tryParse(_entryVals['employeeCode'] ?? ''),
//     //   remarksCode:  int.tryParse(_entryVals['signer']       ?? ''),
//     //   entryType:    'DEPT ISS',
//     // );
//
//     setState(() {
//       if (_editingDetIndex != null) {
//         _detRows[_editingDetIndex!] = newRow;
//         _editingDetIndex = null;
//       } else {
//         _detRows.add(newRow);
//       }
//       _syncDetGrid();
//     });
//     _clearEntryFields();
//   }
  // ✅ shape name from code
  String _shapeNameFor(int? code) {
    if (code == null) return '';
    try {
      return context.read<ShapeProvider>().list
          .firstWhere((s) => s.shapeCode == code).shapeName ?? '';
    } catch (_) { return ''; }
  }

// ✅ purity name from code
  String _purityNameFor(int? code) {
    if (code == null) return '';
    try {
      return context.read<PurityProvider>().list
          .firstWhere((p) => p.purityCode == code).purityName ?? '';
    } catch (_) { return ''; }
  }
  bool _isBCodePending = false;
  void _addEntry() {
    final merged = _getMergedFields();
    // if (merged.isEmpty && _editingDetIndex == null) return;
    //
    //
    // final pairs = [
    //   ['REC PC', 'REC WT'], ['K PC', 'K WT'], ['BR PC', 'BR WT'],
    //   ['TOPS PC', 'TOPS WT'], ['LOSS PC', 'LOSS WT'], ['DM PER', 'DM WT'],
    // ];
    // final hasAnyPair = pairs.any((pair) =>
    // merged.containsKey(pair[0]) || merged.containsKey(pair[1]));
    //
    // final hasEmployee = merged.containsKey('EMPLOYEE');
    // final hasSigner   = merged.containsKey('SIGNER');
    // final hasRemarks  = merged.containsKey('REMARKS');
    // final hasDueDay   = merged.containsKey('DUE DAY');
    //
    //
    // final hasAnyEntryField = hasAnyPair || hasEmployee || hasSigner || hasRemarks || hasDueDay;
    //
    // if (!hasAnyEntryField && _editingDetIndex == null) {
    //   Future.delayed(const Duration(milliseconds: 50),
    //           () => _erpFormKey.currentState?.focusField('scanValue'));
    //   return;
    // }

    final selectedName = () {
      final f = merged.values.firstWhereOrNull(
              (f) => f.userVisibilityCode.toString() == _selectedRadioCode);
      return (f?.userVisibilityName ?? '').toUpperCase();
    }();

    if (selectedName == 'BCODE' && _editingDetIndex == null) {
      if (_scannedDet == null) {
        _isBCodePending = false;
        Future.delayed(const Duration(milliseconds: 50),
                () => _erpFormKey.currentState?.focusField('scanValue'));
        return;
      }
    }
    final issPc = int.tryParse(_entryVals['issPc'] ?? '') ?? 0;
    final issWt = double.tryParse(_entryVals['issWt'] ?? '') ?? 0;
    final recPc = int.tryParse(_entryVals['recpc'] ?? '') ?? 0;
    final recWt = double.tryParse(_entryVals['recwt'] ?? '') ?? 0;
    final kPc   = int.tryParse(_entryVals['kpc']   ?? '') ?? 0;
    final kWt   = double.tryParse(_entryVals['kwt'] ?? '') ?? 0;

    final totalPc = recPc + kPc;
    final totalWt = recWt + kWt;


    final hasRecPair  = merged.containsKey('REC PC') || merged.containsKey('REC WT');
    final hasKPair    = merged.containsKey('K PC')   || merged.containsKey('K WT');

    if (hasRecPair || hasKPair) {
      if (totalPc > issPc && issPc > 0) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Rec PC ($recPc) + K PC ($kPc) = $totalPc cannot exceed Iss PC ($issPc)'),
          backgroundColor: Colors.red,
        ));
        return;
      }
      if (totalWt > issWt + 0.0005 && issWt > 0) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Rec Wt (${_f3(recWt)}) + K Wt (${_f3(kWt)}) = ${_f3(totalWt)} cannot exceed Iss Wt (${_f3(issWt)})'),
          backgroundColor: Colors.red,
        ));
        return;
      }
    }

    // ✅ FIX 2: Rec PC/WT pair validation — sirf tab jab field exist kare
    if (hasRecPair) {
      final recPcStr = _entryVals['recpc'] ?? '';
      final recWtStr = _entryVals['recwt'] ?? '';
      if (recPcStr.isNotEmpty && recWtStr.isEmpty) {
        _showSnack('Rec WT required when Rec PC entered!');
        _erpFormKey.currentState?.focusField('recwt');
        return;
      }
      if (recWtStr.isNotEmpty && recPcStr.isEmpty) {
        _showSnack('Rec PC required when Rec WT entered!');
        _erpFormKey.currentState?.focusField('recpc');
        return;
      }
    }

    // ✅ FIX 2: K PC/WT pair validation — sirf tab jab field exist kare
    if (hasKPair) {
      final kPcStr = _entryVals['kpc'] ?? '';
      final kWtStr = _entryVals['kwt'] ?? '';
      if (kPcStr.isNotEmpty && kWtStr.isEmpty) {
        _showSnack('K WT required when K PC entered!');
        _erpFormKey.currentState?.focusField('kwt');
        return;
      }
      if (kWtStr.isNotEmpty && kPcStr.isEmpty) {
        _showSnack('K PC required when K WT entered!');
        _erpFormKey.currentState?.focusField('kpc');
        return;
      }
    }
//     final issPc = int.tryParse(_entryVals['issPc']  ?? '') ?? 0;
//     final issWt = double.tryParse(_entryVals['issWt'] ?? '') ?? 0;
//     final recPc = int.tryParse(_entryVals['recpc']  ?? '') ?? 0;
//     final recWt = double.tryParse(_entryVals['recwt'] ?? '') ?? 0;
//     final kPc   = int.tryParse(_entryVals['kpc']    ?? '') ?? 0;
//     final kWt   = double.tryParse(_entryVals['kwt']  ?? '') ?? 0;
//
//     final totalPc = recPc + kPc;
//     final totalWt = recWt + kWt;
//
//     if (totalPc > issPc) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text('Rec PC ($recPc) + K PC ($kPc) = $totalPc cannot exceed Iss PC ($issPc)'),
//         backgroundColor: Colors.red,
//       ));
//       return;
//     }
// // Rec PC/WT validation
//     final recPcStr = _entryVals['recpc'] ?? '';
//     final recWtStr = _entryVals['recwt'] ?? '';
//     if (recPcStr.isNotEmpty && recWtStr.isEmpty) {
//       _showSnack('Rec WT required when Rec PC entered!');
//       _erpFormKey.currentState?.focusField('recwt');
//       return;
//     }
//     if (recWtStr.isNotEmpty && recPcStr.isEmpty) {
//       _showSnack('Rec PC required when Rec WT entered!');
//       _erpFormKey.currentState?.focusField('recpc');
//       return;
//     }
//
// // K PC/WT validation
//     final kPcStr = _entryVals['kpc'] ?? '';
//     final kWtStr = _entryVals['kwt'] ?? '';
//     if (kPcStr.isNotEmpty && kWtStr.isEmpty) {
//       _showSnack('K WT required when K PC entered!');
//       _erpFormKey.currentState?.focusField('kwt');
//       return;
//     }
//     if (kWtStr.isNotEmpty && kPcStr.isEmpty) {
//       _showSnack('K PC required when K WT entered!');
//       _erpFormKey.currentState?.focusField('kpc');
//       return;
//     }
//     if (totalWt > issWt + 0.0005) { // 0.0005 tolerance for decimal rounding
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text('Rec Wt (${_f3(recWt)}) + K Wt (${_f3(kWt)}) = ${_f3(totalWt)} cannot exceed Iss Wt (${_f3(issWt)})'),
//         backgroundColor: Colors.red,
//       ));
//       return;
//     }

    final issPcStr = _entryVals['issPc'] ?? '';
    final issWtStr = _entryVals['issWt'] ?? '';

    final srno = _editingDetIndex != null
        ? _detRows[_editingDetIndex!].srno
        : _detRows.length + 1;


    SpkDeptIssDetModel newRow;

    if (_editingDetIndex != null) {
      // ── EDIT MODE — existing row ka data preserve karo ──────────────────
      final existing = _detRows[_editingDetIndex!];
      newRow = SpkDeptIssDetModel(
        srno:         srno,
        spkDeptIssMstID: existing.spkDeptIssMstID,
        // Preserved — scan se aaya data touch mat karo
        id:           existing.id,
        jno:          existing.jno,
        bCode:        existing.bCode,

        fromDeptCode: _fromDeptCode,   // ← ADD
        toDeptCode:   _toDeptCodeVal,  // ← ADD
        pktNo:        existing.pktNo,
        cutNo:        existing.cutNo,
        clvCut:       existing.clvCut,
        shapeCode:    existing.shapeCode,
        purityCode:   existing.purityCode,
        colorCode:    existing.colorCode,
        diam:         existing.diam,
        kachaRec:     existing.kachaRec,
        qrCode:       existing.qrCode,
        entryType:    existing.entryType,
        formType:     existing.formType,
        pktType:      existing.pktType,
        // Entry fields — user ne jo fill kiye
        pc:           int.tryParse(_entryVals['orgPc']   ?? '') ?? existing.pc,
        wt:           double.tryParse(_entryVals['orgWt'] ?? '') ?? existing.wt,
        issPc:        int.tryParse(issPcStr),
        issWt:        double.tryParse(issWtStr),
        recPc:        recPc ,
        recWt:        recWt ,
        totalPc:      recPc ,
        totalWt:      recWt ,
        dmWt:         double.tryParse(_entryVals['dmwt']   ?? ''),
        dmPer:        double.tryParse(_entryVals['dmper']  ?? ''),
        kPc:          int.tryParse(_entryVals['kpc']       ?? ''),
        kWt:          double.tryParse(_entryVals['kwt']    ?? ''),
        brPc:         int.tryParse(_entryVals['brpc']      ?? ''),
        brWt:         double.tryParse(_entryVals['brwt']   ?? ''),
        lossPc:       int.tryParse(_entryVals['losspc']    ?? ''),
        lossWt:       double.tryParse(_entryVals['losswt'] ?? ''),
        topsPc:       int.tryParse(_entryVals['topspc']    ?? ''),
        topsWt:       double.tryParse(_entryVals['topswt'] ?? ''),
        charniCode:   int.tryParse(_formValues['charniCode']   ?? ''),
        tensionsCode: int.tryParse(_formValues['tensionsCode'] ?? ''),
        employeeCode: int.tryParse(_entryVals['employee'] ?? ''),
        signerCode:   int.tryParse(_entryVals['signer']   ?? ''),
        remarksCode:  int.tryParse(_entryVals['remarks']  ?? ''),
        dueDay:       int.tryParse(_entryVals['dueDay']   ?? ''),
        fromCrId:        _fromCrId,           // ← ADD
        toCrId:          _toCrId,             // ← ADD
        deptProcessCode: int.tryParse(_formValues['deptProcessCode'] ?? ''), // ← ADD
      );
    } else {
      // ── ADD MODE — scan se aaya data use karo ────────────────────────────
      newRow = SpkDeptIssDetModel(
        srno:         srno,
        id:           _scannedDet?.id,
        jno:          _scannedDet?.jno,
        jnoRecPc: _scannedDet?.jnoRecPc,  // ← ADD

        bCode:        _scannedDet?.bCode ?? _entryVals['scanValue'],
        pktNo:        _scannedDet?.pktNo,
        cutNo:        _scannedDet?.cutNo,
        clvCut:       _scannedDet?.clvCut,
        fromDeptCode: _fromDeptCode,   // ← ADD
        toDeptCode:   _toDeptCodeVal,  // ← ADD
        shapeCode:    _scannedDet?.shapeCode,
        purityCode:   _scannedDet?.purityCode,
        colorCode:    _scannedDet?.colorCode,
        diam:         _scannedDet?.diam,
        charniCode:   int.tryParse(_formValues['charniCode']   ?? ''),
        tensionsCode: int.tryParse(_formValues['tensionsCode'] ?? ''),
        kachaRec:     _scannedDet?.kachaRec ?? 'Y',
        pc:           int.tryParse(_entryVals['orgPc']   ?? ''),
        wt:           double.tryParse(_entryVals['orgWt'] ?? ''),
        issPc:        int.tryParse(issPcStr),
        issWt:        double.tryParse(issWtStr),
        recPc:        recPc ,
        recWt:        recWt ,
        totalPc:      recPc ,
        totalWt:      recWt ,
        dmWt:         double.tryParse(_entryVals['dmwt']   ?? ''),
        dmPer:        double.tryParse(_entryVals['dmper']  ?? ''),
        kPc:          int.tryParse(_entryVals['kpc']       ?? ''),
        kWt:          double.tryParse(_entryVals['kwt']    ?? ''),
        brPc:         int.tryParse(_entryVals['brpc']      ?? ''),
        brWt:         double.tryParse(_entryVals['brwt']   ?? ''),
        lossPc:       int.tryParse(_entryVals['losspc']    ?? ''),
        lossWt:       double.tryParse(_entryVals['losswt'] ?? ''),
        topsPc:       int.tryParse(_entryVals['topspc']    ?? ''),
        topsWt:       double.tryParse(_entryVals['topswt'] ?? ''),
        employeeCode: int.tryParse(_entryVals['employee'] ?? ''),
        signerCode:   int.tryParse(_entryVals['signer']   ?? ''),
        remarksCode:  int.tryParse(_entryVals['remarks']  ?? ''),
        dueDay:       int.tryParse(_entryVals['dueDay']   ?? ''),
        fromCrId:        _fromCrId,           // ← ADD
        toCrId:          _toCrId,             // ← ADD
        deptProcessCode: int.tryParse(_formValues['deptProcessCode'] ?? ''), // ← ADD
        entryType:    'I',
        formType:     'SPK',
        pktType:      'A',
      );
    }

    setState(() {
      if (_editingDetIndex != null) {
        _detRows[_editingDetIndex!] = newRow;
        _editingDetIndex = null;
      } else {
        _detRows.add(newRow);
      }
      _lockMasterFields = true;   // 🔥 MAIN LINE

      _syncDetGrid();
    });
    _clearEntryFields();
    // Focus wapas scanValue pe
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _erpFormKey.currentState?.focusField('scanValue');
    });
    _erpFormKey.currentState?.setFieldReadOnly('fromCrId', true);
    _erpFormKey.currentState?.setFieldReadOnly('toCrId', true);
    _erpFormKey.currentState?.setFieldReadOnly('deptProcessCode', true);
  }
  void _clearEntryFields() {
    const keys = ['orgPc','orgWt','issPc','issWt','recpc','recwt',
      'dmwt','dmper','kpc','kwt','brpc','brwt','losspc','losswt',
      'topspc','topswt','employee','signer','remarks','dueDay','scanValue'];
    for (final k in keys) {
      _entryVals.remove(k);
      _erpFormKey.currentState?.updateFieldValue(k, '');
    }
    _scannedDet = null;
    _isBCodePending = false;
    _entryVals['scanValue'] = '';  // ← EXPLICIT CLEAR

  }
  // void _clearEntryFields() {
  //   const keys = ['orgPc','orgWt','issPc','issWt','recPc','recWt',
  //     'dmWt','dmPer','kPc','kWt','brPc','brWt','lossPc','lossWt',
  //     'topsPc','topsWt','employeeCode','signer','dueDay'];
  //   for (final k in keys) {
  //     _entryVals.remove(k);
  //     _erpFormKey.currentState?.updateFieldValue(k, '');
  //   }
  //   _scannedDet = null;
  //
  // }

  // void _editDetRow(int idx) {
  //   final r = _detRows[idx];
  //   setState(() => _editingDetIndex = idx);
  //   void set(String k, String? v) {
  //     _entryVals[k] = v ?? '';
  //     _erpFormKey.currentState?.updateFieldValue(k, v ?? '');
  //   }
  //   set('orgPc',        r.pc?.toString());
  //   set('orgWt',        _f3(r.wt));
  //   set('issPc',        r.issPc?.toString());
  //   set('issWt',        _f3(r.issWt));
  //   set('recPc',        r.recPc?.toString());
  //   set('recWt',        _f3(r.recWt));
  //   set('employeeCode', r.employeeCode?.toString());
  //   set('signer',       r.remarksCode?.toString());
  // }
  void _editDetRow(int idx) {
    final r = _detRows[idx];
    setState(() => _editingDetIndex = idx);
    void set(String k, String? v) {
      _entryVals[k] = v ?? '';
      _erpFormKey.currentState?.updateFieldValue(k, v ?? '');
    }
    // ORG/ISS fields
    set('orgPc',   r.pc?.toString());
    set('orgWt',   _f3(r.wt));
    set('issPc',   r.issPc?.toString());
    set('issWt',   _f3(r.issWt));
    // REC fields (lowercase — form field key ke saath match)
    set('recpc',   r.recPc?.toString());
    set('recwt',   _f3(r.recWt));
    // DM fields
    set('dmper',   r.dmPer?.toStringAsFixed(2));
    set('dmwt',    _f3(r.dmWt));
    // K fields
    set('kpc',     r.kPc?.toString());
    set('kwt',     _f3(r.kWt));
    // BR fields
    set('brpc',    r.brPc?.toString());
    set('brwt',    _f3(r.brWt));
    // LOSS fields
    set('losspc',  r.lossPc?.toString());
    set('losswt',  _f3(r.lossWt));
    // TOPS fields
    set('topspc',  r.topsPc?.toString());
    set('topswt',  _f3(r.topsWt));
    // Others
    set('employee', r.employeeCode?.toString());
    set('signer',   r.signerCode?.toString());
    set('remarks',  r.remarksCode?.toString());
    set('dueDay',   r.dueDay?.toString());
  }
  void _deleteDetRow(int idx) {
    setState(() {
      _detRows.removeAt(idx);
      _detRows = _detRows.asMap().entries.map((e) => SpkDeptIssDetModel(
        srno:            e.key + 1,
        spkDeptIssMstID: e.value.spkDeptIssMstID,
        id:              e.value.id,
        jno:             e.value.jno,
        bCode:           e.value.bCode,
        pktNo:           e.value.pktNo,
        cutNo:           e.value.cutNo,
        pc:              e.value.pc,
        wt:              e.value.wt,
        issPc:           e.value.issPc,
        fromDeptCode: e.value.fromDeptCode,
        toDeptCode:   e.value.toDeptCode,
        issWt:           e.value.issWt,
        recPc:           e.value.recPc,
        recWt:           e.value.recWt,
        dmPer:           e.value.dmPer,
        dmWt:            e.value.dmWt,
        kPc:             e.value.kPc,
        kWt:             e.value.kWt,
        brPc:            e.value.brPc,
        brWt:            e.value.brWt,
        lossPc:          e.value.lossPc,
        lossWt:          e.value.lossWt,
        topsPc:          e.value.topsPc,
        topsWt:          e.value.topsWt,
        totalPc:         e.value.totalPc,
        totalWt:         e.value.totalWt,
        charniCode:      e.value.charniCode,
        tensionsCode:    e.value.tensionsCode,
        employeeCode:    e.value.employeeCode,
        signerCode:      e.value.signerCode,
        remarksCode:     e.value.remarksCode,
        dueDay:          e.value.dueDay,
        fromCrId:        e.value.fromCrId,        // ← ADD
        toCrId:          e.value.toCrId,          // ← ADD
        deptProcessCode: e.value.deptProcessCode, // ← ADD
        entryType:       e.value.entryType,
        formType:        e.value.formType,
        pktType:         e.value.pktType,
        shapeCode:       e.value.shapeCode,
        purityCode:      e.value.purityCode,
        colorCode:       e.value.colorCode,
        diam:            e.value.diam,
        kachaRec:        e.value.kachaRec,
      )).toList();
      // _detRows = _detRows.asMap().entries.map((e) => SpkDeptIssDetModel(
      //   srno:            e.key + 1,
      //   spkDeptIssMstID: e.value.spkDeptIssMstID,
      //   id:              e.value.id, jno: e.value.jno,
      //   bCode:           e.value.bCode, pktNo: e.value.pktNo,
      //   cutNo:           e.value.cutNo, pc: e.value.pc, wt: e.value.wt,
      //   issPc:           e.value.issPc, issWt: e.value.issWt,
      //   recPc:           e.value.recPc, recWt: e.value.recWt,
      //   employeeCode:    e.value.employeeCode, remarksCode: e.value.remarksCode,
      //   entryType:       e.value.entryType,
      // )).toList();
      _syncDetGrid();
      if (_editingDetIndex == idx) _editingDetIndex = null;
    });
  }
  // ✅ FIX: resolve employee name from code
  String _employeeNameFor(int? code) {
    if (code == null) return '';
    try {
      return context.read<EmployeeProvider>().list
          .firstWhere((e) => e.employeeCode == code).employeeName ?? '';
    } catch (_) { return ''; }
  }

// ✅ FIX: resolve signer name from crId
  String _signerNameFor(int? crId) {
    if (crId == null) return '';
    try {
      return context.read<CounterProvider>().list
          .firstWhere((c) => c.crId == crId).logInName ?? '';
    } catch (_) { return ''; }
  }

// ✅ FIX: resolve remarks name from code
  String _remarksNameFor(int? code) {
    if (code == null) return '';
    try {
      return context.read<RemarksProvider>().list
          .firstWhere((r) => r.remarksCode == code).remarksName ?? '';
    } catch (_) { return ''; }
  }
  void _syncDetGrid() {
    // Dynamic columns — sirf wo jo merged mein hain
    final merged = _getMergedFields();

    final List<String> cols = ['srno', 'bCode', 'pktNo', 'cutNo', 'orgPc', 'orgWt', 'issPc', 'issWt'];

    if (merged.containsKey('REC PC') || merged.containsKey('REC WT')) {
      cols.addAll(['recPc', 'recWt']);
    }
    if (merged.containsKey('DM PER') || merged.containsKey('DM WT')) {
      cols.addAll(['dmPer', 'dmWt']);
    }
    if (merged.containsKey('K PC') || merged.containsKey('K WT')) {
      cols.addAll(['kPc', 'kWt']);
    }
    if (merged.containsKey('BR PC') || merged.containsKey('BR WT')) {
      cols.addAll(['brPc', 'brWt']);
    }
    if (merged.containsKey('LOSS PC') || merged.containsKey('LOSS WT')) {
      cols.addAll(['lossPc', 'lossWt']);
    }
    if (merged.containsKey('TOPS PC') || merged.containsKey('TOPS WT')) {
      cols.addAll(['topsPc', 'topsWt']);
    }
    if (merged.containsKey('REMARKS')) {
      cols.add('remarks');
    }
    if (merged.containsKey('EMPLOYEE')) {
      cols.add('employee');
    }
    if (merged.containsKey('SIGNER')) {
      cols.add('signer');
    }
    cols.addAll(['jnoRecPc', 'shapeCode', 'purityCode']);

    _activeDetColumns = cols;

    _detDisplay = _detRows.map((r) {
      final employeeName = _employeeNameFor(r.employeeCode);
      final signerName   = _signerNameFor(r.signerCode);
      final remarksName  = _remarksNameFor(r.remarksCode);
      return {
      'srno':    r.srno?.toString()  ?? '',
      'bCode':   r.bCode             ?? '',
      'pktNo':   r.pktNo             ?? '',
      'cutNo':   r.cutNo             ?? '',
      'orgPc':   r.pc?.toString()    ?? '',
      'orgWt':   _f3(r.wt),
      'issPc':   r.issPc?.toString() ?? '',
      'issWt':   _f3(r.issWt),
      'recPc':   r.recPc?.toString() ?? '',
      'jnoRecPc':  r.jnoRecPc?.toString() ?? '',
        'shapeCode': _shapeNameFor(r.shapeCode),
        'purityCode': _purityNameFor(r.purityCode),
      'recWt':   _f3(r.recWt),
      'dmWt':    _f3(r.dmWt),
      'dmPer':   r.dmPer?.toStringAsFixed(2) ?? '',
      'kPc':     r.kPc?.toString()   ?? '',
      'kWt':     _f3(r.kWt),
      'brPc':    r.brPc?.toString()  ?? '',
      // 'remarks': r.remarksCode?.toString() ?? '',
      // 'employee': r.employeeCode?.toString() ?? '',
      // 'signer': r.signerCode?.toString() ?? '',
      'brWt':    _f3(r.brWt),
      'lossPc':  r.lossPc?.toString() ?? '',
      'lossWt':  _f3(r.lossWt),
      'topsPc':  r.topsPc?.toString() ?? '',
      'topsWt':  _f3(r.topsWt),
      'employee': employeeName,   // ✅ NAME not code
      'signer':   signerName,     // ✅ NAME not code
      'remarks':  remarksName,    // ✅ NAME not code
    };}).toList();
  }
  // void _syncDetGrid() {
  //   _detDisplay = _detRows.map((r) => {
  //     'srno':    r.srno?.toString()  ?? '',
  //     'bCode':   r.bCode             ?? '',
  //     'pktNo':   r.pktNo             ?? '',
  //     'cutNo':   r.cutNo             ?? '',
  //     'orgPc':   r.pc?.toString()    ?? '',
  //     'orgWt':   _f3(r.wt),
  //     'issPc':   r.issPc?.toString() ?? '',
  //     'issWt':   _f3(r.issWt),
  //     'recPc':   r.recPc?.toString() ?? '',
  //     'recWt':   _f3(r.recWt),
  //     'dmWt':    _f3(r.dmWt),
  //     'dmPer':   r.dmPer?.toStringAsFixed(2) ?? '',
  //     'kPc':     r.kPc?.toString()   ?? '',
  //     'kWt':     _f3(r.kWt),
  //     'brPc':    r.brPc?.toString()  ?? '',
  //     'brWt':    _f3(r.brWt),
  //     'lossPc':  r.lossPc?.toString() ?? '',
  //     'lossWt':  _f3(r.lossWt),
  //     'topsPc':  r.topsPc?.toString() ?? '',
  //     'topsWt':  _f3(r.topsWt),
  //   }).toList();
  // }

  // void _syncDetGrid() {
  //   _detDisplay = _detRows.map((r) => {
  //     'srno':  r.srno?.toString()  ?? '',
  //     'bCode': r.bCode             ?? '',
  //     'pktNo': r.pktNo             ?? '',
  //     'orgPc': r.pc?.toString()    ?? '',
  //     'orgWt': _f3(r.wt),
  //     'issPc': r.issPc?.toString() ?? '',
  //     'issWt': _f3(r.issWt),
  //     'recPc': r.recPc?.toString() ?? '',
  //     'recWt': _f3(r.recWt),
  //   }).toList();
  // }
  //
  // List<String> get _detGridColumns =>
  //     ['srno', 'bCode', 'pktNo', 'orgPc', 'orgWt', 'issPc', 'issWt', 'recPc', 'recWt'];

  Map<String, dynamic> get _footerTotals => {
    'count': _detRows.length,
    'issPc': _detRows.fold(0,   (s, r) => s + (r.issPc ?? 0)),
    'issWt': _detRows.fold(0.0, (s, r) => s + (r.issWt ?? 0)),
  };

  void _showSnack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  // ──────────────────────────────────────────────────────────────────────────
  //  ROW TAP
  // ──────────────────────────────────────────────────────────────────────────
  Future<void> _onRowTap(Map<String, dynamic> row) async {
    final raw     = row['_raw'] as SpkDeptIssMstModel;
    final prov    = context.read<SpkDeptIssProvider>();
    final details = await prov.loadDetails(raw.spkDeptIssMstID!);
    if (!mounted) return;

    if (raw.fromCrID != null) _onFromSelected(raw.fromCrID.toString());
    if (raw.toCrID   != null) _onToSelected(raw.toCrID.toString());
    if (raw.deptProcessCode != null && _toCrId != null && _fromCrId != null) {
      await _loadToDisplayFields(_toCrId!);
      await _loadFromDisplayFields(_fromCrId!);
    }

    if (!mounted) return;

// Radio first item set karo
    final mergedFields = _getMergedFields();
    const radioNames = ['BCODE','ID','JNO','CUT LOT','QR CODE'];
    final firstRadio = mergedFields.values.firstWhereOrNull(
          (f) => radioNames.contains((f.userVisibilityName ?? '').toUpperCase()),
    );
    if (firstRadio != null) {
      _selectedRadioCode = firstRadio.userVisibilityCode.toString();
    }
    final lastDet = details.isNotEmpty ? details.last : null;

    setState(() {
      // _selectedRow = row; _selectedMst = raw;
      // _isEditMode  = true; _detRows = details; _editingDetIndex = null;
      _selectedRow     = row;
      _selectedMst     = raw;
      _isEditMode      = true;
      _detRows         = details;
      _editingDetIndex = null;
      _processSelected = raw.deptProcessCode != null; // ← KEY FIX
      _isAdding        = false;
      _showTableOnMobile = false;
      _formValues = {
        'spkDeptIssMstID': raw.spkDeptIssMstID?.toString() ?? '0',
        'spkDeptIssDate':  toDisplayDate(raw.spkDeptIssDate),
        'time': () {
          if (raw.stime == null || raw.stime!.isEmpty) {
            return DateFormat('hh:mm a').format(DateTime.now());
          }
          try {
            final dt = DateTime.parse(raw.stime!);
            return DateFormat('hh:mm a').format(dt);
          } catch (_) {
            return raw.stime!;
          }
        }(),
        'fromCrId':        raw.fromCrID?.toString() ?? '',
        'fromDept':        _fromDeptName ?? '',
        'toCrId':          raw.toCrID?.toString() ?? '',
        'toDept':          _toDeptName ?? '',
        'deptProcessCode': raw.deptProcessCode?.toString() ?? '',
        'deptName':        _toDeptName ?? '',
        // ── Det se charni/tension ─────────────────────────────────────────
        if (lastDet?.charniCode   != null) 'charniCode':   lastDet!.charniCode!.toString(),
        if (lastDet?.tensionsCode != null) 'tensionsCode': lastDet!.tensionsCode!.toString(),
        if (_selectedRadioCode    != null) 'scanType':     _selectedRadioCode!,
      };
      _syncDetGrid();
      setState(() => _showTableOnMobile = false);
      // if (Responsive.isMobile(context)) _showTableOnMobile = false;
    });
    _rebuildForm();   // ← form rebuild karo taaki fields dikhein

  }

  // ──────────────────────────────────────────────────────────────────────────
  //  SAVE
  // ──────────────────────────────────────────────────────────────────────────
  Future<void> _onSave(Map<String, dynamic> values) async {
    final prov = context.read<SpkDeptIssProvider>();

    String toIso(String? v) {
      if (v == null || v.isEmpty) return '';
      try { return DateFormat('yyyy-MM-dd').format(DateFormat('dd/MM/yyyy').parse(v)); }
      catch (_) { return v; }
    }

    // To counter ka deptCode get karo
    int? toDeptCode;
    if (_toCrId != null) {
      try {
        toDeptCode = context.read<CounterProvider>().list
            .firstWhere((c) => c.crId == _toCrId).deptCode;
      } catch (_) {}
    }

    final merged = Map<String, dynamic>.from(values);
    merged['Stime'] = DateFormat('hh:mm a').format(DateTime.now());
    merged['Sdate'] = DateFormat('yyyy-MM-dd').format(DateTime.now());
    merged['spkDeptIssDate'] = toIso(merged['spkDeptIssDate']?.toString());
    merged['fromCrID']       = _fromCrId?.toString() ?? '';
    merged['toCrID']         = _toCrId?.toString() ?? '';
    merged['deptCode']       = toDeptCode?.toString() ?? '';

    bool success;
    if (_isEditMode && _selectedMst != null) {
      success = await prov.update(_selectedMst!.spkDeptIssMstID!, merged, _detRows);
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
        message: wasEdit ? 'Dept Issue updated.' : 'Dept Issue saved.',
      );
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  //  DELETE
  // ──────────────────────────────────────────────────────────────────────────
  Future<void> _onDelete() async {
    if (_selectedMst?.spkDeptIssMstID == null) return;
    final confirm = await ErpDeleteDialog.show(
      context: context, theme: _theme,
      title: 'Dept Issue', itemName: 'ID: ${_selectedMst!.spkDeptIssMstID}',
    );
    if (confirm != true || !mounted) return;
    final success = await context.read<SpkDeptIssProvider>().delete(_selectedMst!.spkDeptIssMstID!);
    if (success && mounted) {
      final id = _selectedMst?.spkDeptIssMstID;
      _resetForm();
      await ErpResultDialog.showDeleted(context: context, theme: _theme, itemName: 'Dept Issue $id');
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  //  RESET
  // ──────────────────────────────────────────────────────────────────────────
  // void _resetForm() {
  //   _erpFormKey.currentState?.resetForm();
  //   _entryVals.clear();
  //   setState(() {
  //     _selectedRow = _selectedMst = null;
  //     _isEditMode = _showTableOnMobile = false;
  //     _detRows = []; _detDisplay = []; _editingDetIndex = null;
  //     _fromCrId = _toCrId = null;
  //     _fromDeptName = _toDeptName = null;
  //         _processSelected = false;
  //     _toDisplayFields.clear();
  //     _fromDisplayFields.clear();
  //     _erpFormKey = GlobalKey<ErpFormState>(); // ← ADD
  //
  //     _formValues.clear(); // optional but recommended
  //   });
  //   _setDefaultFormValues();
  // }
  void _resetForm() {
    _erpFormKey.currentState?.resetForm();
    _entryVals.clear();
    setState(() {
      _selectedRow = _selectedMst = null;
      _isEditMode = _showTableOnMobile = false;
      _detRows = []; _detDisplay = []; _editingDetIndex = null;
      _fromCrId = _toCrId = null;
      _fromDeptName = _toDeptName = null;
      _processSelected = false;
      _toDisplayFields.clear();
      _fromDisplayFields.clear();
      _scannedDet = null;        // ← ADD
      _selectedRadioCode = null; // ← ADD
      _erpFormKey = GlobalKey<ErpFormState>();
      _formValues.clear();
      _isAdding = false;
      _fromDeptCode  = null;  // ← ADD
      _toDeptCodeVal = null;  // ← ADD

    });
    _setDefaultFormValues();
  }
  // ──────────────────────────────────────────────────────────────────────────
  //  BUILD
  // ──────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Consumer<SpkDeptIssProvider>(
      builder: (ctx, prov, _) => Padding(
        padding: const EdgeInsets.all(8),
        child: Responsive.isMobile(context)
            ? _showTableOnMobile ? _buildTable(prov) : _buildForm(context)
            : Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // if (!_showTableOnMobile) ...[
            //   Expanded(flex: 2, child: _buildForm(context)),
            //   const SizedBox(width: 12),
            // ],
            if (!_showTableOnMobile)
              Expanded(flex: 2, child: _buildForm(context)),
            if (_showTableOnMobile)
              Expanded(flex: 2, child: _buildTable(prov)),
            // Expanded(flex: 2, child: _buildForm(context)),
            // // const SizedBox(width: 12),
            // // Expanded(flex: 2, child: _buildTable(prov)),
          ],
        ),
      ),
    );
  }
  void _rebuildForm() {
    setState(() {
      _erpFormKey = GlobalKey<ErpFormState>(); // naya GlobalKey = naya ErpForm = _initFields() runs
    });
  }
  bool _isAdding = false;
  List<String> _activeDetColumns = [];
  Widget _buildForm(BuildContext context) {
    return ErpForm(
      isShowSearch: true,


      // key: ValueKey(
      //     _processSelected.toString() +
      //         _toDisplayFields.length.toString() +
      //         _fromDisplayFields.length.toString()
      // ),
      autoStartAdding: _isAdding,  // ← SIRF YE ADD KARO
      addButtonSections: const {3},   // ← entry fields sectionIndex 3 pe hain
      logo:       AppImages.logo,
      key:        _erpFormKey,
      title:      'DEPT ISSUE ENTRY',
      tabBarBackgroundColor:  const Color(0xfff2f0ef),
      tabBarSelectedColor:    _theme.primaryGradient.first,
      tabBarSelectedTxtColor: Colors.white,
      rows:          _buildFormRows(),
      initialValues: _formValues,
      isEditMode:    _isEditMode,

      onEntryAdd: (sectionIndex) {
        if (sectionIndex == 3) {

          final merged = _getMergedFields();
          final selectedName = () {
            final f = merged.values.firstWhereOrNull(
                    (f) => f.userVisibilityCode.toString() == _selectedRadioCode);
            return (f?.userVisibilityName ?? '').toUpperCase();
          }();

          if (selectedName == 'BCODE' && _scannedDet == null && _editingDetIndex == null) {
            Future.delayed(const Duration(milliseconds: 50),
                    () => _erpFormKey.currentState?.focusField('scanValue'));
            return;
          }

          _addEntry();
        }
        },


      onFieldChanged: (key, value) {
        _formValues[key] = value.toString();

        switch (key) {
          case 'fromCrId':
            _onFromSelected(value.toString());
            // Move to 'To' counter
            Future.delayed(const Duration(milliseconds: 50), () => _erpFormKey.currentState?.focusField('toCrId'));
            break;

          case 'toCrId':
            _onToSelected(value.toString());
            // Move to Process
            Future.delayed(const Duration(milliseconds: 50), () => _erpFormKey.currentState?.focusField('deptProcessCode'));
            break;
          case 'dmper':
            final dmPerVal = double.tryParse(value.toString()) ?? 0;
            if (dmPerVal > 100) {
              _erpFormKey.currentState?.updateFieldValue('dmper', '100');
              _entryVals['dmper'] = '100';
            } else {
              _entryVals[key] = value.toString();
            }
            _calcDmWt();
            break;
          case 'deptProcessCode':
            _onProcessSelected(value.toString());
            // Move to Charni
            Future.delayed(const Duration(milliseconds: 100), () => _erpFormKey.currentState?.focusField('charniCode'));
            break;
          case 'scanValue':
            _entryVals[key] = value.toString();
            // BCode scan
            // if (_selectedRadioCode != null && value.toString().isNotEmpty) {
            //   final merged = _getMergedFields();
            //   final selectedField = merged.values.firstWhereOrNull(
            //         (f) => f.userVisibilityCode.toString() == _selectedRadioCode,
            //   );
            //   final selectedName = (selectedField?.userVisibilityName ?? '').toUpperCase();
            //   if (selectedName == 'BCODE' && _fromCrId != null) {
            //     _onBCodeScanned(value.toString());
            //   }
            // }
            break;

          case 'recwt':
            _entryVals[key] = value.toString();
            _calcDmWt();
            break;


          case 'kwt':
            _entryVals[key] = value.toString();
            _calcLoss();
            break;

          case 'kpc':
            _entryVals[key] = value.toString();
            _calcLoss();
            break;
          // case 'scanType':
          //   setState(() => _selectedRadioCode = value.toString());
          //   _formValues['scanValue'] = '';
          //   _erpFormKey.currentState?.updateFieldValue('scanValue', '');
          //   // If Cut Lot selected, focus CutNo, else focus ScanValue
          //   // Future.delayed(const Duration(milliseconds: 50), () {
          //   //   if (_selectedRadioCode == 'CUT LOT CODE') { // Use your specific code here
          //   //     _erpFormKey.currentState?.focusField('cutNo');
          //   //   } else {
          //   //     _erpFormKey.currentState?.focusField('scanValue');
          //   //   }
          //   // });
          //   break;

          default:
            _entryVals[key] = value.toString();
        }
      },
      onExit:   () => context.read<TabProvider>().closeCurrentTab(),
      onSave:   _onSave,
      // onFieldSubmitted: (key, value) {
      //   if (key != 'scanValue') return;
      //   final scanVal = value.toString().trim();
      //   if (scanVal.isEmpty || _selectedRadioCode == null || _fromCrId == null) return;
      //   final merged = _getMergedFields();
      //   final selectedField = merged.values.firstWhereOrNull(
      //         (f) => f.userVisibilityCode.toString() == _selectedRadioCode,
      //   );
      //   final selectedName = (selectedField?.userVisibilityName ?? '').toUpperCase();
      //   if (selectedName == 'BCODE') _onBCodeScanned(scanVal);
      //   // final scanVal = _entryVals['scanValue'] ?? '';
      //   if (scanVal.isNotEmpty && _editingDetIndex == null) {
      //     final isDuplicate = _detRows.any((r) =>
      //     r.bCode?.toString() == scanVal ||
      //         r.id?.toString() == scanVal ||
      //         r.jno?.toString() == scanVal);
      //     if (isDuplicate) {
      //       ErpResultDialog.showError(  // ya showSnack use karo agar ye nahi hai
      //         context: context, theme: _theme,
      //         title: 'Duplicate',
      //         message: 'This bCode already done.',
      //       );
      //       return;
      //     }
      //   }
      // },
      onFieldSubmitted: (key, value) {
        if (key != 'scanValue') return;

        final scanVal = value.toString().trim();

        // ✅ FIX 3: Empty scanValue pe kuch mat karo
        if (scanVal.isEmpty) return;

        if (_selectedRadioCode == null || _fromCrId == null) return;

        final merged = _getMergedFields();

        // ✅ FIX 4: Koi field na ho to entry nahi honi chahiye
        if (merged.isEmpty) return;

        final selectedField = merged.values.firstWhereOrNull(
              (f) => f.userVisibilityCode.toString() == _selectedRadioCode,
        );
        final selectedName = (selectedField?.userVisibilityName ?? '').toUpperCase();

        // ✅ FIX 2: BCODE case — pehle scan karo, _addEntry mat chalaao
        // _addEntry tab chalega jab _scannedDet set ho (recpc focus pe)
        if (selectedName == 'BCODE') {
          // Duplicate check pehle
          if (_editingDetIndex == null) {
            final isDuplicate = _detRows.any((r) => r.bCode?.toString() == scanVal);
            if (isDuplicate) {
              ErpResultDialog.showError(
                context: context, theme: _theme,
                title: 'Duplicate',
                message: 'This bCode already added.',
              );
              _erpFormKey.currentState?.updateFieldValue('scanValue', '');
              _entryVals['scanValue'] = '';
              Future.delayed(const Duration(milliseconds: 100),
                      () => _erpFormKey.currentState?.focusField('scanValue'));
              return;
            }
          }
          _isBCodePending = true;
          _onBCodeScanned(scanVal);
          return;  // ← IMPORTANT: yahan return karo, _addEntry mat chalaao
        }

        // Non-BCODE case — duplicate check
        if (_editingDetIndex == null) {
          final isDuplicate = _detRows.any((r) =>
          r.id?.toString() == scanVal ||
              r.jno?.toString() == scanVal);
          if (isDuplicate) {
            ErpResultDialog.showError(
              context: context, theme: _theme,
              title: 'Duplicate',
              message: 'This entry already added.',
            );
            return;
          }
        }
      },
      onCancel: _resetForm,
      onDelete: _isEditMode ? _onDelete : null,
      onSearch: () => setState(() => _showTableOnMobile = true),

      detailBuilder: (ctx) {
        final t    = ctx.erpTheme;
        final tots = _footerTotals;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_detDisplay.isNotEmpty) ...[
              ErpEntryGrid(
                data: _detDisplay,
                columns: _activeDetColumns,
                title: 'ISSUE DETAILS',
                theme: t,
                onDeleteRow: _deleteDetRow,
                onEditRow: _editDetRow,
                editingIndex: _editingDetIndex,
                columnLabels: { for (final c in _activeDetColumns) c: _colLabel(c) },
                columnAlignments: {
                  'orgPc':  TextAlign.right,
                  'orgWt':  TextAlign.right,
                  'issPc':  TextAlign.right,
                  'issWt':  TextAlign.right,
                  'recPc':  TextAlign.right,
                  'recWt':  TextAlign.right,
                  'dmPer':  TextAlign.right,
                  'dmWt':   TextAlign.right,
                  'kPc':    TextAlign.right,
                  'kWt':    TextAlign.right,
                  'brPc':   TextAlign.right,
                  'brWt':   TextAlign.right,
                  'lossPc': TextAlign.right,
                  'lossWt': TextAlign.right,
                  'topsPc': TextAlign.right,
                  'topsWt': TextAlign.right,
                  'remarks': TextAlign.right,
                  'employee': TextAlign.right,
                  'signer': TextAlign.right,
                  'jnoRecPc': TextAlign.right,
                  'shapeCode': TextAlign.right,
                  'purityCode': TextAlign.right,
                },

                footerTotCount: 'Tot: ${_detRows.length}',
                // footerTotals: {
                //   'issPc':  '${_detRows.fold(0,   (s, r) => s + (r.issPc  ?? 0))}',
                //   'issWt':  _f3(_detRows.fold(0.0, (s, r) => s! + (r.issWt  ?? 0))),
                //   'recPc':  '${_detRows.fold(0,   (s, r) => s + (r.recPc  ?? 0))}',
                //   'recWt':  _f3(_detRows.fold(0.0, (s, r) => s! + (r.recWt  ?? 0))),
                //   'dmWt':   _f3(_detRows.fold(0.0, (s, r) => s! + (r.dmWt   ?? 0))),
                //   'kPc':    '${_detRows.fold(0,   (s, r) => s + (r.kPc    ?? 0))}',
                //   'kWt':    _f3(_detRows.fold(0.0, (s, r) => s! + (r.kWt    ?? 0))),
                //   'brPc':   '${_detRows.fold(0,   (s, r) => s + (r.brPc   ?? 0))}',
                //   'brWt':   _f3(_detRows.fold(0.0, (s, r) => s! + (r.brWt   ?? 0))),
                //   'lossPc': '${_detRows.fold(0,   (s, r) => s + (r.lossPc ?? 0))}',
                //   'lossWt': _f3(_detRows.fold(0.0, (s, r) => s! + (r.lossWt ?? 0))),
                //   'topsPc': '${_detRows.fold(0,   (s, r) => s + (r.topsPc ?? 0))}',
                //   'topsWt': _f3(_detRows.fold(0.0, (s, r) => s! + (r.topsWt ?? 0))),
                // },
                // footerTotals mein add karo:
                footerTotals: {
                  'orgPc':  '${_detRows.fold(0,   (s, r) => s + (r.pc    ?? 0))}',   // ← ADD
                  'orgWt':  _f3(_detRows.fold(0.0, (s, r) => s! + (r.wt    ?? 0))),   // ← ADD
                  'issPc':  '${_detRows.fold(0,   (s, r) => s + (r.issPc  ?? 0))}',
                  'issWt':  _f3(_detRows.fold(0.0, (s, r) => s! + (r.issWt  ?? 0))),
                  'recPc':  '${_detRows.fold(0,   (s, r) => s + (r.recPc  ?? 0))}',
                  'recWt':  _f3(_detRows.fold(0.0, (s, r) => s! + (r.recWt  ?? 0))),
                  'dmPer':  () {                                                        // ← ADD formula
                    final totDmWt  = _detRows.fold(0.0, (s, r) => s + (r.dmWt  ?? 0));
                    final totRecWt = _detRows.fold(0.0, (s, r) => s + (r.recWt ?? 0));
                    final totIssWt = _detRows.fold(0.0, (s, r) => s + (r.issWt ?? 0));
                    final base = totRecWt > 0 ? totRecWt : totIssWt;
                    return base > 0 ? (totDmWt / base * 100).toStringAsFixed(2) : '0.00';
                  }(),
                  'dmWt':   _f3(_detRows.fold(0.0, (s, r) => s! + (r.dmWt   ?? 0))),
                  'kPc':    '${_detRows.fold(0,   (s, r) => s + (r.kPc    ?? 0))}',
                  'kWt':    _f3(_detRows.fold(0.0, (s, r) => s! + (r.kWt    ?? 0))),
                  'brPc':   '${_detRows.fold(0,   (s, r) => s + (r.brPc   ?? 0))}',
                  'brWt':   _f3(_detRows.fold(0.0, (s, r) => s! + (r.brWt   ?? 0))),
                  'lossPc': '${_detRows.fold(0,   (s, r) => s + (r.lossPc ?? 0))}',
                  'lossWt': _f3(_detRows.fold(0.0, (s, r) => s! + (r.lossWt ?? 0))),
                  'topsPc': '${_detRows.fold(0,   (s, r) => s + (r.topsPc ?? 0))}',
                  'topsWt': _f3(_detRows.fold(0.0, (s, r) => s! + (r.topsWt ?? 0))),
                },
              ),
              // ErpEntryGrid(
              //   data: _detDisplay, columns: _activeDetColumns,
              //   title: 'ISSUE DETAILS', theme: t,
              //   onDeleteRow: _deleteDetRow, onEditRow: _editDetRow,
              //   editingIndex: _editingDetIndex,
              //   columnLabels: _activeDetColumns.isEmpty
              //       ? {
              //     'srno': 'SR NO', 'bCode': 'BCODE', 'pktNo': 'PKT NO', 'cutNo': 'CUT NO',
              //     'orgPc': 'ORG PC', 'orgWt': 'ORG WT', 'issPc': 'ISS PC', 'issWt': 'ISS WT',
              //   }
              //       : { for (final c in _activeDetColumns) c: _colLabel(c) },
              // ),
              // const SizedBox(height: 4),
              // _buildFooterRow(t, tots),
            ],
          ],
        );
      },
    );
  }
  String _colLabel(String key) {
    const labels = {
      'srno':   'SR NO',  'bCode':  'BCODE',   'pktNo': 'PKT NO', 'cutNo': 'CUT NO',
      'orgPc':  'ORG PC', 'orgWt':  'ORG WT',
      'issPc':  'ISS PC', 'issWt':  'ISS WT',
      'recPc':  'REC PC', 'recWt':  'REC WT',
      'dmWt':   'DM WT',  'dmPer':  'DM PER',
      'kPc':    'K PC',   'kWt':    'K WT',
      'brPc':   'BR PC',  'brWt':   'BR WT',
      'lossPc': 'LOSS PC','lossWt': 'LOSS WT',
      'topsPc': 'TOPS PC','topsWt': 'TOPS WT',
      'remarks': 'REMARKS','jnoRecPc':  'JNO REC PC',
      'shapeCode': 'SHAPE',
      'purityCode': 'PURITY',
    };
    return labels[key] ?? key;
  }
  // Widget _buildFooterRow(ErpTheme t, Map<String, dynamic> tots) {
  //   Widget cell(String label, String value) => Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
  //     child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
  //       Text(label, style: TextStyle(fontSize: 8, color: t.textLight, fontWeight: FontWeight.w700)),
  //       const SizedBox(height: 2),
  //       Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: t.primary)),
  //     ]),
  //   );
  //   Widget blank() => const SizedBox();
  //
  //   return Container(
  //     decoration: BoxDecoration(
  //       gradient: LinearGradient(colors: [t.primary.withOpacity(0.06), t.accent.withOpacity(0.04)]),
  //       borderRadius: BorderRadius.circular(8),
  //       border: Border(top: BorderSide(color: t.primary.withOpacity(0.3), width: 1.5)),
  //     ),
  //     child: Row(children: [
  //       Container(
  //         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  //         child: Text('Tot:${tots['count']}',
  //             style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: t.primary)),
  //       ),
  //       blank(),blank(),
  //       cell('ISS PC', '${tots['issPc']}'),
  //       cell('ISS WT', _f3(tots['issWt'] as double)),
  //       const SizedBox(width: 35), const SizedBox(width: 35),
  //     ]),
  //   );
  // }
  //   final counterProv = context.read<CounterProvider>();
  //   final procProv    = context.read<DeptProcessProvider>();
  //
  //   final data = prov.list.map((e) {
  //     String fromName = '', toName = '', processName = '';
  //     try { fromName    = counterProv.list.firstWhere((c) => c.crId == e.fromCrID).crName ?? ''; } catch (_) {}
  //     try { toName      = counterProv.list.firstWhere((c) => c.crId == e.toCrID).crName   ?? ''; } catch (_) {}
  //     try { processName = procProv.list.firstWhere((p) => p.deptProcessCode == e.deptProcessCode).deptProcessName ?? ''; } catch (_) {}
  //     final row          = e.toTableRow();
  //     row['fromName']    = fromName;
  //     row['toName']      = toName;
  //     row['processName'] = processName;
  //     return row;
  //   }).toList();
  //
  //   return ErpDataTable(
  //     isReportRow: false, token: token ?? '', url: baseUrl,
  //     title: 'DEPT ISSUE LIST', columns: _tableColumns, data: data,
  //     showSearch: true,
  //     searchFields: const [
  //       ErpSearchFieldConfig(key: 'fromName', label: 'FROM', width: 150),
  //       ErpSearchFieldConfig(key: 'toName',   label: 'TO',   width: 150),
  //     ],
  //     selectedRow: _selectedRow, onRowTap: _onRowTap,
  //     emptyMessage: prov.isLoaded ? 'No entries found' : 'Loading...',
  //   );
  // }
  Widget _buildTable(SpkDeptIssProvider prov) {
    final counterProv = context.read<CounterProvider>();
    final procProv    = context.read<DeptProcessProvider>();

    final data = prov.list.map((e) {

      String fromName = '', toName = '', processName = '';
      String fromDeptName = '', toDeptName = '', deptName = '';

      try {
        final fromCounter = counterProv.list.firstWhere((c) => c.crId == e.fromCrID);
        fromName     = fromCounter.crName ?? '';
        fromDeptName = _deptNameFor(fromCounter.deptCode);
      } catch (_) {}

      try {
        final toCounter = counterProv.list.firstWhere((c) => c.crId == e.toCrID);
        toName     = toCounter.crName ?? '';
        toDeptName = _deptNameFor(toCounter.deptCode);
        deptName   = toDeptName;
      } catch (_) {}

      try {
        processName = procProv.list
            .firstWhere((p) => p.deptProcessCode == e.deptProcessCode)
            .deptProcessName ?? '';
      } catch (_) {}


      final dets = prov.detMap[e.spkDeptIssMstID] ?? [];
      final totPkt = dets.length;
      final totPc  = dets.fold<int>(0, (s, r) => s + (r.totalPc ?? 0));
      final totWt  = dets.fold<double>(0.0, (s, r) => s + (r.totalWt ?? 0.0));


      final jno = dets.isNotEmpty ? (dets.first.jno?.toString() ?? '') : '';

      // Time format
      // String timeStr = '';
      // try {
      //   if (e.spkDeptIssDate != null) {
      //     timeStr = DateFormat('hh:mm a').format(DateTime.parse(e.spkDeptIssDate!));
      //   }
      // } catch (_) {}

      final row = e.toTableRow();
      row['fromName']     = fromName;
      row['fromDeptName'] = fromDeptName;
      row['toName']       = toName;
      row['toDeptName']   = toDeptName;
      row['processName']  = processName;
      row['deptName']     = deptName;
      row['spkDeptIssTime'] = () {
        if (e.stime == null || e.stime!.isEmpty) return '';
        try {
          // ISO datetime string se time nikaalo
          final dt = DateTime.parse(e.stime!);
          return DateFormat('hh:mm a').format(dt);
        } catch (_) {
          // Already formatted string hai
          return e.stime!;
        }
      }();
      return row;
    }).toList();

    return ErpDataTable(
      isReportRow: false, token: token ?? '', url: baseUrl,
      title: 'DEPT ISSUE LIST', columns: _tableColumns, data: data,
      showSearch: true,
      dateFilter: true,
      searchFields: const [
        ErpSearchFieldConfig(key: 'fromName',  label: 'FROM', width: 150),
        ErpSearchFieldConfig(key: 'toName',    label: 'TO',   width: 150),
      ],
      selectedRow: _selectedRow, onRowTap: _onRowTap,
      emptyMessage: prov.isLoaded ? 'No entries found' : 'Loading...',
    );
  }
}