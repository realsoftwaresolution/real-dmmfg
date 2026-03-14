// // // lib/screens/trn_rough_entry.dart
// //
// // import 'package:erp_data_table/erp_data_table/widgets/erp_buttons.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:intl/intl.dart';
// // import 'package:provider/provider.dart';
// // import 'package:rs_dashboard/rs_dashboard.dart';
// // import 'package:erp_data_table/erp_data_table.dart';
// //
// // import '../models/rough_model.dart';
// // import '../providers/rough_provider.dart';
// // import '../utils/delete_dialogue.dart';
// // import '../utils/msg_dialogue.dart';
// //
// // class TrnRoughEntry extends StatefulWidget {
// //   const TrnRoughEntry({super.key});
// //
// //   @override
// //   State<TrnRoughEntry> createState() => _TrnRoughEntryState();
// // }
// //
// // class _TrnRoughEntryState extends State<TrnRoughEntry> {
// //   // ── Theme ──────────────────────────────────────────────────────────────────
// //   ErpThemeVariant _themeVariant = ErpThemeVariant.frost;
// //   ErpTheme get _theme => ErpTheme(_themeVariant);
// //
// //   // ── Mode flags ─────────────────────────────────────────────────────────────
// //   bool _isEditMode = false;
// //   bool _isAdding   = false;
// //   bool _isEditing  = false;
// //   bool get _formEnabled => _isAdding || _isEditing;
// //
// //   // ── Selected row (search table) ────────────────────────────────────────────
// //   Map<String, dynamic>? _selectedRow;
// //   RoughModel?           _selectedRough;
// //
// //   // ── Header form controllers ────────────────────────────────────────────────
// //   final _dateCtrl       = TextEditingController();
// //   final _idCtrl         = TextEditingController(text: '0');
// //   final _jnoCtrl        = TextEditingController();
// //   final _knoCtrl        = TextEditingController();
// //   final _siteCtrl       = TextEditingController();
// //   final _invCtrl        = TextEditingController();
// //   final _partyCtrl      = TextEditingController();
// //   final _typeCtrl       = TextEditingController();
// //   final _articalCtrl    = TextEditingController();
// //   final _janCharniCtrl  = TextEditingController();
// //   final _exRateCtrl     = TextEditingController();
// //   final _rateDollarCtrl = TextEditingController();
// //   final _amtDollarCtrl  = TextEditingController();
// //   final _rateRsCtrl     = TextEditingController();
// //   final _amtRsCtrl      = TextEditingController();
// //   final _rgExpPerCtrl   = TextEditingController();
// //   final _poExpPerCtrl   = TextEditingController();
// //   final _rgSizeCtrl     = TextEditingController();
// //   final _poSizeCtrl     = TextEditingController();
// //   final _lsPerCtrl      = TextEditingController();
// //   final _mainCutNoCtrl  = TextEditingController();
// //   final _dueDayCtrl     = TextEditingController();
// //   final _dueDateCtrl    = TextEditingController();
// //   final _remarksCtrl    = TextEditingController();
// //
// //   // ── Charni detail rows ─────────────────────────────────────────────────────
// //   // Each entry: {charni: '', pc: '', wt: '', per: '' (auto)}
// //   List<Map<String, TextEditingController>> _charniRows = [];
// //
// //   // ── Process days rows ─────────────────────────────────────────────────────
// //   List<Map<String, TextEditingController>> _processDaysRows = [];
// //
// //   // ── Charni entry controllers (top input row) ───────────────────────────────
// //   final _charniInputCtrl = TextEditingController();
// //   final _charniPcCtrl    = TextEditingController();
// //   final _charniWtCtrl    = TextEditingController();
// //   final _charniPerCtrl   = TextEditingController(); // readonly
// //
// //   // ── Process days input row ────────────────────────────────────────────────
// //   final _stockTypeCtrl   = TextEditingController();
// //   final _daysCtrl        = TextEditingController();
// //
// //   // ── Mobile toggle ─────────────────────────────────────────────────────────
// //   bool _showTableOnMobile = false;
// //
// //   final String? token = AppStorage.getString("token");
// //
// //   // ── Table columns for search list ─────────────────────────────────────────
// //   List<ErpColumnConfig> get _tableColumns => [
// //     ErpColumnConfig(key: 'roughMstID', label: 'ID',      width: 60),
// //     ErpColumnConfig(key: 'roughDate',  label: 'DATE',    width: 120),
// //     ErpColumnConfig(key: 'jno',        label: 'JNO',     width: 80),
// //     ErpColumnConfig(key: 'site',       label: 'SITE',    width: 100),
// //     ErpColumnConfig(key: 'partyCode',  label: 'PARTY',   flex: 1),
// //     ErpColumnConfig(key: 'totWt',      label: 'TOT WT',  width: 100, align: ColumnAlign.right),
// //     ErpColumnConfig(key: 'amtDollar',  label: 'AMT \$',  width: 110, align: ColumnAlign.right),
// //     ErpColumnConfig(key: 'amtRs',      label: 'AMT RS',  width: 110, align: ColumnAlign.right),
// //   ];
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     // Set today's date
// //     final today = DateFormat('dd/MM/yyyy').format(DateTime.now());
// //     _dateCtrl.text = today;
// //     _dueDateCtrl.text = today;
// //
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       context.read<RoughProvider>().loadRoughs();
// //     });
// //
// //     // Auto-calc listeners
// //     _exRateCtrl.addListener(_recalcAmounts);
// //     _rateDollarCtrl.addListener(_recalcAmounts);
// //     _dueDayCtrl.addListener(_recalcDueDate);
// //     _dateCtrl.addListener(_recalcDueDate);
// //   }
// //
// //   @override
// //   void dispose() {
// //     for (final c in [
// //       _dateCtrl, _idCtrl, _jnoCtrl, _knoCtrl, _siteCtrl, _invCtrl,
// //       _partyCtrl, _typeCtrl, _articalCtrl, _janCharniCtrl, _exRateCtrl,
// //       _rateDollarCtrl, _amtDollarCtrl, _rateRsCtrl, _amtRsCtrl,
// //       _rgExpPerCtrl, _poExpPerCtrl, _rgSizeCtrl, _poSizeCtrl, _lsPerCtrl,
// //       _mainCutNoCtrl, _dueDayCtrl, _dueDateCtrl, _remarksCtrl,
// //       _charniInputCtrl, _charniPcCtrl, _charniWtCtrl, _charniPerCtrl,
// //       _stockTypeCtrl, _daysCtrl,
// //     ]) {
// //       c.dispose();
// //     }
// //     _disposeCharniRows();
// //     _disposeProcessRows();
// //     super.dispose();
// //   }
// //
// //   void _disposeCharniRows() {
// //     for (final r in _charniRows) {
// //       r.values.forEach((c) => c.dispose());
// //     }
// //   }
// //
// //   void _disposeProcessRows() {
// //     for (final r in _processDaysRows) {
// //       r.values.forEach((c) => c.dispose());
// //     }
// //   }
// //
// //   // ── CALCULATIONS ──────────────────────────────────────────────────────────
// //
// //   /// totalWt = sum of all charni 'wt' entries
// //   double get _totalWt {
// //     double sum = 0;
// //     for (final r in _charniRows) {
// //       sum += double.tryParse(r['wt']!.text) ?? 0;
// //     }
// //     return sum;
// //   }
// //
// //   void _recalcAmounts() {
// //     final exRate    = double.tryParse(_exRateCtrl.text) ?? 0;
// //     final rateDollar = double.tryParse(_rateDollarCtrl.text) ?? 0;
// //     final totWt      = _totalWt;
// //
// //     final rateRs  = exRate * rateDollar;
// //     final amtDollar = rateDollar * totWt;
// //     final amtRs   = rateRs * totWt;
// //
// //     _rateRsCtrl.text   = rateRs.toStringAsFixed(2);
// //     _amtDollarCtrl.text = amtDollar.toStringAsFixed(2);
// //     _amtRsCtrl.text    = amtRs.toStringAsFixed(2);
// //   }
// //
// //   void _recalcDueDate() {
// //     final dateStr = _dateCtrl.text;
// //     final days    = int.tryParse(_dueDayCtrl.text) ?? 0;
// //     try {
// //       final base    = DateFormat('dd/MM/yyyy').parse(dateStr);
// //       final due     = base.add(Duration(days: days));
// //       _dueDateCtrl.text = DateFormat('dd/MM/yyyy').format(due);
// //     } catch (_) {}
// //   }
// //
// //   /// Recalc per for a single charni row (per = wt/totalWt * 100)
// //   void _recalcCharniPer() {
// //     final totWt = _totalWt;
// //     for (final r in _charniRows) {
// //       final wt = double.tryParse(r['wt']!.text) ?? 0;
// //       final per = totWt > 0 ? (wt / totWt * 100) : 0.0;
// //       r['per']!.text = per.toStringAsFixed(2);
// //     }
// //     _recalcAmounts();
// //   }
// //
// //   // ── ADD CHARNI ROW ────────────────────────────────────────────────────────
// //   void _addCharniRow() {
// //     final charni = _charniInputCtrl.text.trim();
// //     final pc     = _charniPcCtrl.text.trim();
// //     final wt     = _charniWtCtrl.text.trim();
// //     if (charni.isEmpty && pc.isEmpty && wt.isEmpty) return;
// //
// //     final wtVal = double.tryParse(wt) ?? 0;
// //     final srno  = _charniRows.length + 1;
// //
// //     final row = {
// //       'srno':   TextEditingController(text: srno.toString()),
// //       'charni': TextEditingController(text: charni),
// //       'pc':     TextEditingController(text: pc),
// //       'wt':     TextEditingController(text: wt),
// //       'per':    TextEditingController(text: '0.00'),
// //     };
// //
// //     // Listen to wt changes for per recalc
// //     row['wt']!.addListener(_recalcCharniPer);
// //
// //     setState(() {
// //       _charniRows.add(row);
// //     });
// //
// //     _charniInputCtrl.clear();
// //     _charniPcCtrl.clear();
// //     _charniWtCtrl.clear();
// //     _charniPerCtrl.clear();
// //
// //     _recalcCharniPer();
// //   }
// //
// //   // ── ADD PROCESS DAYS ROW ──────────────────────────────────────────────────
// //   void _addProcessDaysRow() {
// //     final stockType = _stockTypeCtrl.text.trim();
// //     final days      = _daysCtrl.text.trim();
// //     if (stockType.isEmpty) return;
// //
// //     final srno = _processDaysRows.length + 1;
// //     final row = {
// //       'srno':      TextEditingController(text: srno.toString()),
// //       'stockType': TextEditingController(text: stockType),
// //       'days':      TextEditingController(text: days),
// //     };
// //
// //     setState(() {
// //       _processDaysRows.add(row);
// //     });
// //
// //     _stockTypeCtrl.clear();
// //     _daysCtrl.clear();
// //   }
// //
// //   // ── DELETE CHARNI ROW ─────────────────────────────────────────────────────
// //   void _deleteCharniRow(int index) {
// //     final row = _charniRows[index];
// //     row.values.forEach((c) => c.dispose());
// //     setState(() {
// //       _charniRows.removeAt(index);
// //       // Renumber
// //       for (int i = 0; i < _charniRows.length; i++) {
// //         _charniRows[i]['srno']!.text = (i + 1).toString();
// //       }
// //     });
// //     _recalcCharniPer();
// //   }
// //
// //   // ── DELETE PROCESS ROW ────────────────────────────────────────────────────
// //   void _deleteProcessRow(int index) {
// //     final row = _processDaysRows[index];
// //     row.values.forEach((c) => c.dispose());
// //     setState(() {
// //       _processDaysRows.removeAt(index);
// //       for (int i = 0; i < _processDaysRows.length; i++) {
// //         _processDaysRows[i]['srno']!.text = (i + 1).toString();
// //       }
// //     });
// //   }
// //
// //   // ── SAVE ──────────────────────────────────────────────────────────────────
// //   Future<void> _onSave() async {
// //     final provider = context.read<RoughProvider>();
// //
// //     // Build values map
// //     final values = {
// //       'roughDate':    _dateCtrl.text,
// //       'jno':          _jnoCtrl.text,
// //       'kapanNo':      _knoCtrl.text,
// //       'site':         _siteCtrl.text,
// //       'inv':          _invCtrl.text,
// //       'partyCode':    _partyCtrl.text,
// //       'roughTypeCode':_typeCtrl.text,
// //       'articalCode':  _articalCtrl.text,
// //       'jangadCharniCode': _janCharniCtrl.text,
// //       'exRate':       _exRateCtrl.text,
// //       'rateDollar':   _rateDollarCtrl.text,
// //       'amtDollar':    _amtDollarCtrl.text,
// //       'rateRs':       _rateRsCtrl.text,
// //       'amtRs':        _amtRsCtrl.text,
// //       'rgExpPer':     _rgExpPerCtrl.text,
// //       'poExpPer':     _poExpPerCtrl.text,
// //       'rgSize':       _rgSizeCtrl.text,
// //       'poSize':       _poSizeCtrl.text,
// //       'lsPer':        _lsPerCtrl.text,
// //       'mainCutNo':    _mainCutNoCtrl.text,
// //       'dueDay':       _dueDayCtrl.text,
// //       'dueDate':      _dueDateCtrl.text,
// //       'remarks':      _remarksCtrl.text,
// //     };
// //
// //     // Build detail models
// //     final details = _charniRows.asMap().entries.map((e) {
// //       final i = e.key;
// //       final r = e.value;
// //       return RoughDetModel(
// //         srno:       i + 1,
// //         charniCode: int.tryParse(r['charni']!.text),
// //         pc:         int.tryParse(r['pc']!.text),
// //         wt:         double.tryParse(r['wt']!.text),
// //         per:        double.tryParse(r['per']!.text),
// //       );
// //     }).toList();
// //
// //     // Build process days models
// //     final processDays = _processDaysRows.asMap().entries.map((e) {
// //       final i = e.key;
// //       final r = e.value;
// //       return RoughProcessDaysModel(
// //         srno:          i + 1,
// //         stockTypeCode: int.tryParse(r['stockType']!.text),
// //         days:          double.tryParse(r['days']!.text),
// //       );
// //     }).toList();
// //
// //     bool success;
// //     if (_isEditMode && _selectedRough != null) {
// //       success = await provider.updateRough(
// //         _selectedRough!.roughMstID!,
// //         values,
// //         details,
// //         processDays,
// //       );
// //     } else {
// //       success = await provider.createRough(values, details, processDays);
// //     }
// //
// //     if (!mounted) return;
// //     if (success) {
// //       _resetForm();
// //       await ErpResultDialog.showSuccess(
// //         context: context,
// //         theme: _theme,
// //         title: _isEditMode ? 'Updated' : 'Saved',
// //         message: _isEditMode
// //             ? 'Rough entry updated successfully.'
// //             : 'Rough entry saved successfully.',
// //       );
// //     }
// //   }
// //
// //   // ── DELETE ────────────────────────────────────────────────────────────────
// //   Future<void> _onDelete() async {
// //     if (_selectedRough?.roughMstID == null) return;
// //     final confirm = await ErpDeleteDialog.show(
// //       context: context,
// //       theme: _theme,
// //       title: 'Rough Entry',
// //       itemName: 'JNO: ${_selectedRough!.jno}',
// //     );
// //     if (confirm != true || !mounted) return;
// //
// //     final success = await context
// //         .read<RoughProvider>()
// //         .deleteRough(_selectedRough!.roughMstID!);
// //
// //     if (success && mounted) {
// //       _resetForm();
// //       await ErpResultDialog.showDeleted(
// //         context: context,
// //         theme: _theme,
// //         itemName: 'Rough Entry ${_selectedRough?.jno ?? ''}',
// //       );
// //     }
// //   }
// //
// //   // ── ROW TAP ───────────────────────────────────────────────────────────────
// //   Future<void> _onRowTap(Map<String, dynamic> row) async {
// //     final raw = row['_raw'] as RoughModel;
// //
// //     // Load sub-tables
// //     final provider = context.read<RoughProvider>();
// //     final details     = await provider.loadDetails(raw.roughMstID!);
// //     final processDays = await provider.loadProcessDays(raw.roughMstID!);
// //
// //     setState(() {
// //       _selectedRow   = row;
// //       _selectedRough = raw;
// //       _isEditMode    = true;
// //       _isEditing     = false;
// //       _isAdding      = false;
// //
// //       // Populate header fields
// //       _dateCtrl.text       = raw.roughDate ?? '';
// //       _idCtrl.text         = raw.roughMstID?.toString() ?? '0';
// //       _jnoCtrl.text        = raw.jno?.toString() ?? '';
// //       _knoCtrl.text        = raw.kapanNo ?? '';
// //       _siteCtrl.text       = raw.site ?? '';
// //       _invCtrl.text        = raw.inv ?? '';
// //       _partyCtrl.text      = raw.partyCode?.toString() ?? '';
// //       _typeCtrl.text       = raw.roughTypeCode?.toString() ?? '';
// //       _articalCtrl.text    = raw.articalCode?.toString() ?? '';
// //       _janCharniCtrl.text  = raw.jangadCharniCode?.toString() ?? '';
// //       _exRateCtrl.text     = raw.exRate?.toStringAsFixed(2) ?? '';
// //       _rateDollarCtrl.text = raw.rateDollar?.toStringAsFixed(2) ?? '';
// //       _amtDollarCtrl.text  = raw.amtDollar?.toStringAsFixed(2) ?? '';
// //       _rateRsCtrl.text     = raw.rateRs?.toStringAsFixed(2) ?? '';
// //       _amtRsCtrl.text      = raw.amtRs?.toStringAsFixed(2) ?? '';
// //       _rgExpPerCtrl.text   = raw.rgExpPer?.toStringAsFixed(2) ?? '';
// //       _poExpPerCtrl.text   = raw.poExpPer?.toStringAsFixed(2) ?? '';
// //       _rgSizeCtrl.text     = raw.rgSize?.toStringAsFixed(2) ?? '';
// //       _poSizeCtrl.text     = raw.poSize?.toStringAsFixed(2) ?? '';
// //       _lsPerCtrl.text      = raw.lsPer?.toStringAsFixed(2) ?? '';
// //       _mainCutNoCtrl.text  = raw.mainCutNo ?? '';
// //       _dueDayCtrl.text     = raw.dueDay?.toString() ?? '';
// //       _dueDateCtrl.text    = raw.dueDate ?? '';
// //       _remarksCtrl.text    = raw.remarks ?? '';
// //
// //       // Populate charni rows
// //       _disposeCharniRows();
// //       _charniRows = details.map((d) {
// //         final r = {
// //           'srno':   TextEditingController(text: d.srno?.toString() ?? ''),
// //           'charni': TextEditingController(text: d.charniCode?.toString() ?? ''),
// //           'pc':     TextEditingController(text: d.pc?.toString() ?? ''),
// //           'wt':     TextEditingController(text: d.wt?.toStringAsFixed(3) ?? ''),
// //           'per':    TextEditingController(text: d.per?.toStringAsFixed(2) ?? ''),
// //         };
// //         r['wt']!.addListener(_recalcCharniPer);
// //         return r;
// //       }).toList();
// //
// //       // Populate process days rows
// //       _disposeProcessRows();
// //       _processDaysRows = processDays.map((p) {
// //         return {
// //           'srno':      TextEditingController(text: p.srno?.toString() ?? ''),
// //           'stockType': TextEditingController(text: p.stockTypeCode?.toString() ?? ''),
// //           'days':      TextEditingController(text: p.days?.toStringAsFixed(0) ?? ''),
// //         };
// //       }).toList();
// //
// //       if (Responsive.isMobile(context)) {
// //         _showTableOnMobile = false;
// //       }
// //     });
// //   }
// //
// //   // ── RESET ─────────────────────────────────────────────────────────────────
// //   void _resetForm() {
// //     final today = DateFormat('dd/MM/yyyy').format(DateTime.now());
// //     setState(() {
// //       _isEditMode        = false;
// //       _isAdding          = false;
// //       _isEditing         = false;
// //       _selectedRow       = null;
// //       _selectedRough     = null;
// //       _showTableOnMobile = false;
// //
// //       for (final c in [
// //         _jnoCtrl, _knoCtrl, _siteCtrl, _invCtrl, _partyCtrl, _typeCtrl,
// //         _articalCtrl, _janCharniCtrl, _exRateCtrl, _rateDollarCtrl,
// //         _amtDollarCtrl, _rateRsCtrl, _amtRsCtrl, _rgExpPerCtrl, _poExpPerCtrl,
// //         _rgSizeCtrl, _poSizeCtrl, _lsPerCtrl, _mainCutNoCtrl, _dueDayCtrl,
// //         _remarksCtrl, _charniInputCtrl, _charniPcCtrl, _charniWtCtrl,
// //         _charniPerCtrl, _stockTypeCtrl, _daysCtrl,
// //       ]) {
// //         c.clear();
// //       }
// //       _idCtrl.text       = '0';
// //       _dateCtrl.text     = today;
// //       _dueDateCtrl.text  = today;
// //
// //       _disposeCharniRows();
// //       _charniRows = [];
// //       _disposeProcessRows();
// //       _processDaysRows = [];
// //     });
// //   }
// //
// //   // ── BUILD ─────────────────────────────────────────────────────────────────
// //   @override
// //   Widget build(BuildContext context) {
// //     return Consumer<RoughProvider>(
// //       builder: (context, provider, _) {
// //         final isMobile = Responsive.isMobile(context);
// //
// //         if (isMobile) {
// //           return Padding(
// //             padding: const EdgeInsets.all(8),
// //             child: _showTableOnMobile
// //                 ? _buildTable(provider)
// //                 : _buildFormArea(),
// //           );
// //         }
// //
// //         return Padding(
// //           padding: const EdgeInsets.all(8),
// //           child: Row(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               Expanded(flex: 3, child: _buildFormArea()),
// //               const SizedBox(width: 12),
// //               Expanded(flex: 2, child: _buildTable(provider)),
// //             ],
// //           ),
// //         );
// //       },
// //     );
// //   }
// //
// //   // ── FORM AREA (left) ──────────────────────────────────────────────────────
// //   Widget _buildFormArea() {
// //     return Container(
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(16),
// //         boxShadow: [
// //           BoxShadow(
// //             color: _theme.primary.withOpacity(0.08),
// //             blurRadius: 24,
// //             offset: const Offset(0, 8),
// //           ),
// //         ],
// //       ),
// //       child: Column(
// //         children: [
// //           _buildFormHeader(),
// //           Expanded(
// //             child: SingleChildScrollView(
// //               padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.stretch,
// //                 children: [
// //                   _buildHeaderRow(),
// //                   const SizedBox(height: 6),
// //                   // Two sub-tables side by side
// //                   Row(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Expanded(child: _buildCharniSection()),
// //                       const SizedBox(width: 12),
// //                       Expanded(child: _buildProcessDaysSection()),
// //                     ],
// //                   ),
// //                   const SizedBox(height: 80),
// //                 ],
// //               ),
// //             ),
// //           ),
// //           _buildFooterActions(),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // ── FORM HEADER ───────────────────────────────────────────────────────────
// //   Widget _buildFormHeader() {
// //     return Container(
// //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
// //       decoration: BoxDecoration(
// //         gradient: LinearGradient(
// //           colors: _theme.primaryGradient,
// //           begin: Alignment.centerLeft,
// //           end: Alignment.centerRight,
// //         ),
// //         borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
// //       ),
// //       child: Row(
// //         children: [
// //           Container(
// //             padding: const EdgeInsets.all(6),
// //             decoration: BoxDecoration(
// //               color: Colors.white.withOpacity(0.2),
// //               borderRadius: BorderRadius.circular(8),
// //             ),
// //             child: const Icon(Icons.diamond_outlined, color: Colors.white, size: 16),
// //           ),
// //           const SizedBox(width: 10),
// //           Expanded(
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 const Text(
// //                   'ROUGH ENTRY',
// //                   style: TextStyle(
// //                     color: Colors.white,
// //                     fontWeight: FontWeight.w700,
// //                     fontSize: 14,
// //                     letterSpacing: 0.3,
// //                   ),
// //                 ),
// //                 Text(
// //                   'Transaction / Rough Stock Entry',
// //                   style: TextStyle(
// //                     color: Colors.white.withOpacity(0.75),
// //                     fontSize: 11,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //           if (_isEditMode)
// //             Container(
// //               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
// //               decoration: BoxDecoration(
// //                 color: Colors.white.withOpacity(0.2),
// //                 borderRadius: BorderRadius.circular(20),
// //                 border: Border.all(color: Colors.white.withOpacity(0.4)),
// //               ),
// //               child: const Text(
// //                 'EDIT MODE',
// //                 style: TextStyle(
// //                   color: Colors.white,
// //                   fontSize: 9,
// //                   fontWeight: FontWeight.w700,
// //                   letterSpacing: 1,
// //                 ),
// //               ),
// //             ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // ── HEADER FIELDS SECTION ─────────────────────────────────────────────────
// //   Widget _buildHeaderRow() {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.stretch,
// //       children: [
// //         // Row 1: Date, ID
// //         _fieldRow([
// //           _labeledField('Date', _dateCtrl, enabled: _formEnabled, isDate: true, flex: 2),
// //           _labeledField('ID',   _idCtrl,   enabled: false, flex: 1),
// //         ]),
// //         const SizedBox(height: 6),
// //         // Row 2: Jno, Kno, Site, Inv
// //         _fieldRow([
// //           _labeledField('Jno',  _jnoCtrl,  enabled: _formEnabled, flex: 1, isNumber: true),
// //           _labeledField('Kno',  _knoCtrl,  enabled: _formEnabled, flex: 1),
// //           _labeledField('Site', _siteCtrl, enabled: _formEnabled, flex: 1),
// //           _labeledField('Inv',  _invCtrl,  enabled: _formEnabled, flex: 1),
// //         ]),
// //         const SizedBox(height: 6),
// //         // Row 3: Party, Type, Artical
// //         _fieldRow([
// //           _labeledField('Party',   _partyCtrl,   enabled: _formEnabled, flex: 2),
// //           _labeledField('Type',    _typeCtrl,    enabled: _formEnabled, flex: 2),
// //           _labeledField('Artical', _articalCtrl, enabled: _formEnabled, flex: 2),
// //         ]),
// //         const SizedBox(height: 6),
// //         // Row 4: Jan. Charni
// //         _fieldRow([
// //           _labeledField('Jan. Charni', _janCharniCtrl, enabled: _formEnabled, flex: 1),
// //         ]),
// //         const SizedBox(height: 6),
// //         // Row 5: Ex Rate | Rate $ | Amt $ (auto)
// //         _fieldRow([
// //           _labeledField('Ex Rate',  _exRateCtrl,    enabled: _formEnabled,  flex: 1, isDecimal: true),
// //           _labeledField('Rate \$',  _rateDollarCtrl, enabled: _formEnabled,  flex: 1, isDecimal: true),
// //           _labeledField('Amt \$',   _amtDollarCtrl,  enabled: false,         flex: 1, isDecimal: true, autoCalc: true),
// //         ]),
// //         const SizedBox(height: 6),
// //         // Row 6: Rate Rs (auto) | Amt Rs (auto)
// //         _fieldRow([
// //           _labeledField('Rate Rs', _rateRsCtrl, enabled: false, flex: 1, isDecimal: true, autoCalc: true),
// //           _labeledField('Amt Rs',  _amtRsCtrl,  enabled: false, flex: 1, isDecimal: true, autoCalc: true),
// //         ]),
// //         const SizedBox(height: 6),
// //         // Row 7: Rg Exp %, Po Exp %
// //         _fieldRow([
// //           _labeledField('Rg Exp %', _rgExpPerCtrl, enabled: _formEnabled, flex: 1, isDecimal: true),
// //           _labeledField('Po Exp %', _poExpPerCtrl, enabled: _formEnabled, flex: 1, isDecimal: true),
// //         ]),
// //         const SizedBox(height: 6),
// //         // Row 8: Rg Size, Po Size
// //         _fieldRow([
// //           _labeledField('Rg Size', _rgSizeCtrl, enabled: _formEnabled, flex: 1, isDecimal: true),
// //           _labeledField('Po Size', _poSizeCtrl, enabled: _formEnabled, flex: 1, isDecimal: true),
// //         ]),
// //         const SizedBox(height: 6),
// //         // Row 9: Ls %
// //         _fieldRow([
// //           _labeledField('Ls %', _lsPerCtrl, enabled: _formEnabled, flex: 1, isDecimal: true),
// //         ]),
// //         const SizedBox(height: 6),
// //         // Row 10: Main CutNo | Due Day | Due Date (readonly)
// //         _fieldRow([
// //           _labeledField('Main CutNo', _mainCutNoCtrl, enabled: _formEnabled, flex: 2),
// //           _labeledField('Due Day',    _dueDayCtrl,    enabled: _formEnabled, flex: 1, isNumber: true),
// //           _labeledField('Due Date',   _dueDateCtrl,   enabled: false, flex: 2, autoCalc: true),
// //         ]),
// //         const SizedBox(height: 6),
// //         // Row 11: Remarks
// //         _fieldRow([
// //           _labeledField('Remarks', _remarksCtrl, enabled: _formEnabled, flex: 1, maxLines: 2),
// //         ]),
// //       ],
// //     );
// //   }
// //
// //   // ── CHARNI SECTION ────────────────────────────────────────────────────────
// //   Widget _buildCharniSection() {
// //     return _SubTableCard(
// //       title: 'CHARNI DETAILS',
// //       accentColor: _theme.primary,
// //       inputRow: _formEnabled
// //           ? Row(
// //         children: [
// //           Expanded(flex: 2, child: _compactField('Charni', _charniInputCtrl)),
// //           const SizedBox(width: 4),
// //           Expanded(flex: 1, child: _compactField('Pc', _charniPcCtrl, isNumber: true)),
// //           const SizedBox(width: 4),
// //           Expanded(flex: 1, child: _compactField('Wt', _charniWtCtrl, isDecimal: true)),
// //           const SizedBox(width: 4),
// //           Expanded(
// //             flex: 1,
// //             child: _compactField('Per', _charniPerCtrl, enabled: false),
// //           ),
// //           const SizedBox(width: 4),
// //           GestureDetector(
// //             onTap: _addCharniRow,
// //             child: Container(
// //               padding: const EdgeInsets.all(6),
// //               decoration: BoxDecoration(
// //                 color: _theme.primary,
// //                 borderRadius: BorderRadius.circular(6),
// //               ),
// //               child: const Icon(Icons.add, color: Colors.white, size: 16),
// //             ),
// //           ),
// //         ],
// //       )
// //           : null,
// //       tableHeader: const ['Sr', 'Charni', 'Pc', 'Wt', 'Per', ''],
// //       rows: _charniRows.asMap().entries.map((e) {
// //         final i = e.key;
// //         final r = e.value;
// //         return [
// //           r['srno']!.text,
// //           r['charni']!.text,
// //           r['pc']!.text,
// //           r['wt']!.text,
// //           r['per']!.text,
// //           '', // delete col
// //         ];
// //       }).toList(),
// //       onDeleteRow: _formEnabled ? _deleteCharniRow : null,
// //       footer: 'Total: ${_totalWt.toStringAsFixed(3)}',
// //     );
// //   }
// //
// //   // ── PROCESS DAYS SECTION ──────────────────────────────────────────────────
// //   Widget _buildProcessDaysSection() {
// //     return _SubTableCard(
// //       title: 'PROCESS DAYS',
// //       accentColor: _theme.primary,
// //       inputRow: _formEnabled
// //           ? Row(
// //         children: [
// //           Expanded(flex: 3, child: _compactField('StockType', _stockTypeCtrl)),
// //           const SizedBox(width: 4),
// //           Expanded(flex: 2, child: _compactField('Days', _daysCtrl, isNumber: true)),
// //           const SizedBox(width: 4),
// //           GestureDetector(
// //             onTap: _addProcessDaysRow,
// //             child: Container(
// //               padding: const EdgeInsets.all(6),
// //               decoration: BoxDecoration(
// //                 color: _theme.primary,
// //                 borderRadius: BorderRadius.circular(6),
// //               ),
// //               child: const Icon(Icons.add, color: Colors.white, size: 16),
// //             ),
// //           ),
// //         ],
// //       )
// //           : null,
// //       tableHeader: const ['Sr', 'StockType', 'Days', ''],
// //       rows: _processDaysRows.asMap().entries.map((e) {
// //         final i = e.key;
// //         final r = e.value;
// //         return [
// //           r['srno']!.text,
// //           r['stockType']!.text,
// //           r['days']!.text,
// //           '',
// //         ];
// //       }).toList(),
// //       onDeleteRow: _formEnabled ? _deleteProcessRow : null,
// //     );
// //   }
// //
// //   // ── TABLE (search list) ───────────────────────────────────────────────────
// //   Widget _buildTable(RoughProvider provider) {
// //     return ErpDataTable(
// //       token: token ?? '',
// //       url: 'http://50.62.183.116:5000',
// //       title: 'ROUGH ENTRY LIST',
// //       columns: _tableColumns,
// //       data: provider.tableData,
// //       showSearch: true,
// //       showFooterTotals: false,
// //       selectedRow: _selectedRow,
// //       onRowTap: _onRowTap,
// //       emptyMessage: provider.isLoaded ? 'No entries found' : 'Loading...',
// //     );
// //   }
// //
// //   // ── FOOTER ACTIONS ────────────────────────────────────────────────────────
// //   Widget _buildFooterActions() {
// //     return Container(
// //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
// //       decoration: BoxDecoration(
// //         border: Border(top: BorderSide(color: Colors.grey.shade200)),
// //       ),
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.end,
// //         children: [
// //           // Add button
// //           if (!_isEditMode) ...[
// //             CustomButtons.add(
// //               onPressed: _isAdding
// //                   ? null
// //                   : () => setState(() => _isAdding = true),
// //             ),
// //             const SizedBox(width: 8),
// //           ],
// //           // Edit button
// //           if (_isEditMode) ...[
// //             CustomButtons.edit(
// //               onPressed: _isEditing
// //                   ? null
// //                   : () => setState(() => _isEditing = true),
// //             ),
// //             const SizedBox(width: 8),
// //             CustomButtons.delete(
// //               onPressed: _isEditing ? _onDelete : null,
// //             ),
// //             const SizedBox(width: 8),
// //           ],
// //           CustomButtons.cancel(onPressed: _resetForm),
// //           const SizedBox(width: 8),
// //           CustomButtons.save(
// //             isOutlined: false,
// //             onPressed: _formEnabled ? _onSave : null,
// //           ),
// //           if (Responsive.isMobile(context)) ...[
// //             const SizedBox(width: 8),
// //             CustomButtons.search(
// //               onPressed: () => setState(() => _showTableOnMobile = true),
// //             ),
// //           ],
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // ── HELPERS: labeled field ────────────────────────────────────────────────
// //   Widget _labeledField(
// //       String label,
// //       TextEditingController ctrl, {
// //         bool enabled = true,
// //         int flex = 1,
// //         bool isNumber  = false,
// //         bool isDecimal = false,
// //         bool isDate    = false,
// //         bool autoCalc  = false,
// //         int maxLines   = 1,
// //       }) {
// //     return Expanded(
// //       flex: flex,
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Text(
// //             label,
// //             style: TextStyle(
// //               fontSize: 10,
// //               fontWeight: FontWeight.w600,
// //               color: autoCalc
// //                   ? Colors.teal.shade700
// //                   : _theme.primary.withOpacity(0.8),
// //               letterSpacing: 0.3,
// //             ),
// //           ),
// //           const SizedBox(height: 2),
// //           TextFormField(
// //             controller: ctrl,
// //             enabled: enabled,
// //             maxLines: maxLines,
// //             keyboardType: isNumber
// //                 ? TextInputType.number
// //                 : isDecimal
// //                 ? const TextInputType.numberWithOptions(decimal: true)
// //                 : TextInputType.text,
// //             inputFormatters: isNumber
// //                 ? [FilteringTextInputFormatter.digitsOnly]
// //                 : isDecimal
// //                 ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))]
// //                 : [],
// //             style: TextStyle(
// //               fontSize: 12,
// //               color: enabled ? Colors.black87 : Colors.black54,
// //             ),
// //             decoration: InputDecoration(
// //               isDense: true,
// //               filled: true,
// //               fillColor: autoCalc
// //                   ? Colors.teal.withOpacity(0.06)
// //                   : enabled
// //                   ? Colors.white
// //                   : const Color(0xFFF5F5F5),
// //               contentPadding: const EdgeInsets.symmetric(
// //                 horizontal: 8,
// //                 vertical: 6,
// //               ),
// //               border: OutlineInputBorder(
// //                 borderRadius: BorderRadius.circular(6),
// //                 borderSide: BorderSide(color: Colors.grey.shade300),
// //               ),
// //               enabledBorder: OutlineInputBorder(
// //                 borderRadius: BorderRadius.circular(6),
// //                 borderSide: BorderSide(color: Colors.grey.shade300),
// //               ),
// //               focusedBorder: OutlineInputBorder(
// //                 borderRadius: BorderRadius.circular(6),
// //                 borderSide: BorderSide(color: _theme.primary, width: 1.5),
// //               ),
// //               disabledBorder: OutlineInputBorder(
// //                 borderRadius: BorderRadius.circular(6),
// //                 borderSide: BorderSide(
// //                   color: autoCalc
// //                       ? Colors.teal.withOpacity(0.3)
// //                       : Colors.grey.shade200,
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _fieldRow(List<Widget> children) {
// //     return IntrinsicHeight(
// //       child: Row(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: children
// //             .asMap()
// //             .entries
// //             .map(
// //               (e) => Padding(
// //             padding: EdgeInsets.only(
// //               right: e.key < children.length - 1 ? 6 : 0,
// //             ),
// //             child: e.value,
// //           ),
// //         )
// //             .toList(),
// //       ),
// //     );
// //   }
// //
// //   Widget _compactField(
// //       String hint,
// //       TextEditingController ctrl, {
// //         bool enabled   = true,
// //         bool isNumber  = false,
// //         bool isDecimal = false,
// //       }) {
// //     return TextFormField(
// //       controller: ctrl,
// //       enabled: enabled,
// //       keyboardType: isNumber
// //           ? TextInputType.number
// //           : isDecimal
// //           ? const TextInputType.numberWithOptions(decimal: true)
// //           : TextInputType.text,
// //       inputFormatters: isNumber
// //           ? [FilteringTextInputFormatter.digitsOnly]
// //           : isDecimal
// //           ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))]
// //           : [],
// //       style: const TextStyle(fontSize: 11),
// //       decoration: InputDecoration(
// //         hintText: hint,
// //         hintStyle: TextStyle(fontSize: 10, color: Colors.grey.shade400),
// //         isDense: true,
// //         filled: true,
// //         fillColor: enabled ? Colors.white : const Color(0xFFF5F5F5),
// //         contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
// //         border: OutlineInputBorder(
// //           borderRadius: BorderRadius.circular(5),
// //           borderSide: BorderSide(color: Colors.grey.shade300),
// //         ),
// //         enabledBorder: OutlineInputBorder(
// //           borderRadius: BorderRadius.circular(5),
// //           borderSide: BorderSide(color: Colors.grey.shade300),
// //         ),
// //         focusedBorder: OutlineInputBorder(
// //           borderRadius: BorderRadius.circular(5),
// //           borderSide: BorderSide(color: _theme.primary),
// //         ),
// //         disabledBorder: OutlineInputBorder(
// //           borderRadius: BorderRadius.circular(5),
// //           borderSide: BorderSide(color: Colors.grey.shade200),
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // // ── SUB TABLE CARD WIDGET ─────────────────────────────────────────────────
// // class _SubTableCard extends StatelessWidget {
// //   final String title;
// //   final Color accentColor;
// //   final Widget? inputRow;
// //   final List<String> tableHeader;
// //   final List<List<String>> rows;
// //   final void Function(int index)? onDeleteRow;
// //   final String? footer;
// //
// //   const _SubTableCard({
// //     required this.title,
// //     required this.accentColor,
// //     required this.tableHeader,
// //     required this.rows,
// //     this.inputRow,
// //     this.onDeleteRow,
// //     this.footer,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       decoration: BoxDecoration(
// //         border: Border.all(color: accentColor.withOpacity(0.25)),
// //         borderRadius: BorderRadius.circular(10),
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.stretch,
// //         children: [
// //           // Section header
// //           Container(
// //             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
// //             decoration: BoxDecoration(
// //               color: accentColor.withOpacity(0.08),
// //               borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
// //               border: Border(
// //                 bottom: BorderSide(color: accentColor.withOpacity(0.2)),
// //               ),
// //             ),
// //             child: Text(
// //               title,
// //               style: TextStyle(
// //                 fontSize: 10,
// //                 fontWeight: FontWeight.w700,
// //                 color: accentColor,
// //                 letterSpacing: 0.5,
// //               ),
// //             ),
// //           ),
// //           // Input row
// //           if (inputRow != null)
// //             Padding(
// //               padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
// //               child: inputRow!,
// //             ),
// //           // Table header
// //           Container(
// //             color: accentColor.withOpacity(0.05),
// //             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// //             child: Row(
// //               children: tableHeader.asMap().entries.map((e) {
// //                 final isLast = e.key == tableHeader.length - 1;
// //                 return Expanded(
// //                   flex: isLast ? 0 : 1,
// //                   child: isLast
// //                       ? const SizedBox(width: 24)
// //                       : Text(
// //                     e.value,
// //                     style: TextStyle(
// //                       fontSize: 9,
// //                       fontWeight: FontWeight.w700,
// //                       color: accentColor.withOpacity(0.7),
// //                       letterSpacing: 0.3,
// //                     ),
// //                   ),
// //                 );
// //               }).toList(),
// //             ),
// //           ),
// //           // Table rows
// //           ...rows.asMap().entries.map((e) {
// //             final i = e.key;
// //             final cols = e.value;
// //             return Container(
// //               decoration: BoxDecoration(
// //                 color: i.isEven ? Colors.white : Colors.grey.shade50,
// //                 border: Border(
// //                   bottom: BorderSide(color: Colors.grey.shade100),
// //                 ),
// //               ),
// //               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// //               child: Row(
// //                 children: cols.asMap().entries.map((ce) {
// //                   final isLast = ce.key == cols.length - 1;
// //                   return Expanded(
// //                     flex: isLast ? 0 : 1,
// //                     child: isLast
// //                         ? (onDeleteRow != null
// //                         ? GestureDetector(
// //                       onTap: () => onDeleteRow!(i),
// //                       child: const Icon(
// //                         Icons.close,
// //                         size: 14,
// //                         color: Colors.redAccent,
// //                       ),
// //                     )
// //                         : const SizedBox(width: 24))
// //                         : Text(
// //                       ce.value,
// //                       style: const TextStyle(fontSize: 11),
// //                       overflow: TextOverflow.ellipsis,
// //                     ),
// //                   );
// //                 }).toList(),
// //               ),
// //             );
// //           }),
// //           // Footer
// //           if (footer != null)
// //             Container(
// //               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// //               decoration: BoxDecoration(
// //                 color: accentColor.withOpacity(0.06),
// //                 borderRadius: const BorderRadius.vertical(
// //                   bottom: Radius.circular(10),
// //                 ),
// //                 border: Border(
// //                   top: BorderSide(color: accentColor.withOpacity(0.15)),
// //                 ),
// //               ),
// //               child: Text(
// //                 footer!,
// //                 textAlign: TextAlign.right,
// //                 style: TextStyle(
// //                   fontSize: 10,
// //                   fontWeight: FontWeight.w700,
// //                   color: accentColor,
// //                 ),
// //               ),
// //             ),
// //         ],
// //       ),
// //     );
// //   }
// // }
//
// import 'package:diam_mfg/models/rough_model.dart';
// import 'package:diam_mfg/providers/article_provider.dart';
// import 'package:diam_mfg/providers/charni_provider.dart';
// import 'package:diam_mfg/providers/jangad_charni_provider.dart';
// import 'package:diam_mfg/providers/party_provider.dart';
// import 'package:diam_mfg/providers/rough_provider.dart';
// import 'package:diam_mfg/providers/rough_type_provider.dart';
// import 'package:diam_mfg/providers/stock_type_provider.dart';
// import 'package:erp_data_table/erp_data_table.dart';
// import 'package:erp_formatter/erp_formatter.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:rs_dashboard/rs_dashboard.dart';
//
// import '../utils/delete_dialogue.dart';
// import '../utils/msg_dialogue.dart';
//
// class TrnRoughEntry extends StatefulWidget {
//   const TrnRoughEntry({super.key});
//
//   @override
//   State<TrnRoughEntry> createState() => _TrnRoughEntryState();
// }
//
// class _TrnRoughEntryState extends State<TrnRoughEntry> {
//   // ── Theme ──────────────────────────────────────────────────────────────────
//   ErpThemeVariant _themeVariant = ErpThemeVariant.frost;
//
//   ErpTheme get _theme => ErpTheme(_themeVariant);
//
//   // ── ErpForm global key (same as MstFirmParty) ──────────────────────────────
//   final GlobalKey<ErpFormState> _erpFormKey = GlobalKey<ErpFormState>();
//
//   // ── State ──────────────────────────────────────────────────────────────────
//   Map<String, dynamic>? _selectedRow;
//   RoughModel? _selectedRough;
//   bool _isEditMode = false;
//   Map<String, String> _formValues = {};
//   bool _showTableOnMobile = false;
//
//   // ── Sub-table rows ─────────────────────────────────────────────────────────
//   List<RoughDetModel> _charniRows = [];
//   List<RoughProcessDaysModel> _processDaysRows = [];
//
//   // ── Sub-table input controllers ────────────────────────────────────────────
//   final _charniCodeCtrl = TextEditingController();
//   final _charniPcCtrl = TextEditingController();
//   final _charniWtCtrl = TextEditingController();
//   final _stockTypeCtrl = TextEditingController();
//   final _daysCtrl = TextEditingController();
//
//   final String? token = AppStorage.getString("token");
//
//   // ══════════════════════════════════════════════════════════════════════════
//   //  TABLE COLUMNS
//   // ══════════════════════════════════════════════════════════════════════════
//   List<ErpColumnConfig> get _tableColumns => [
//     ErpColumnConfig(key: 'roughMstID', label: 'ID', width: 70, required: true),
//     ErpColumnConfig(
//       key: 'roughDate',
//       label: 'DATE',
//       width: 110,
//       required: true,
//       isDate: true,
//     ),
//     ErpColumnConfig(key: 'jno', label: 'JNO', width: 80),
//     ErpColumnConfig(key: 'site', label: 'SITE', width: 100),
//     ErpColumnConfig(key: 'partyCode', label: 'PARTY', flex: 1.0),
//     ErpColumnConfig(
//       key: 'totWt',
//       label: 'TOT WT',
//       width: 100,
//       align: ColumnAlign.right,
//     ),
//     ErpColumnConfig(
//       key: 'amtDollar',
//       label: 'AMT \$',
//       width: 110,
//       align: ColumnAlign.right,
//     ),
//     ErpColumnConfig(
//       key: 'amtRs',
//       label: 'AMT RS',
//       width: 110,
//       align: ColumnAlign.right,
//     ),
//   ];
//
//   // ══════════════════════════════════════════════════════════════════════════
//   //  FORM ROWS  (ErpForm)
//   // ══════════════════════════════════════════════════════════════════════════
//   List<List<ErpFieldConfig>>  _formRows(PartyProvider partyProvider,RoughTypeProvider roughTypeProvider,ArticleProvider articleProvider,JangadCharaniProvider jangadCharniProvider,StockTypeProvider stockTypeProvider,CharniProvider charniProvider)=> [
//     // ─── SECTION 0: BASIC INFORMATION ─────────────────────────────────────
//     [
//       ErpFieldConfig(
//         key: 'roughDate',
//         label: 'DATE',
//         type: ErpFieldType.date,
//         required: true,
//         flex: 2,
//         sectionTitle: 'BASIC INFORMATION',
//         sectionIndex: 0,
//       ),
//       ErpFieldConfig(
//         key: 'roughMstID',
//         label: 'ID',
//         type: ErpFieldType.number,
//         readOnly: true,
//         flex: 1,
//         sectionIndex: 0,
//       ),
//     ],
//
//     [
//       ErpFieldConfig(
//         key: 'jno',
//         label: 'JNO',
//         type: ErpFieldType.number,
//         flex: 1,
//         sectionIndex: 0,
//       ),
//       ErpFieldConfig(key: 'kapanNo', label: 'KNO', flex: 1, sectionIndex: 0),
//       ErpFieldConfig(key: 'site', label: 'SITE', flex: 1, sectionIndex: 0),
//       ErpFieldConfig(key: 'inv', label: 'INV', flex: 1, sectionIndex: 0),
//     ],
//
//     [
//       ErpFieldConfig(
//           key: 'partyCode',
//           label: 'PARTY',
//           type: ErpFieldType.dropdown,
//           dropdownItems: partyProvider.list
//               .where((element) {
//             return element.active==true;
//           },).map((e) {
//             return ErpDropdownItem(
//               label: e.partyName ?? '',
//               value: e.partyCode?.toString() ?? '',
//             );
//           }).toList(),
//           sectionIndex: 0,
//           flex: 2
//       ),
//       ErpFieldConfig(
//           key: 'roughTypeCode',
//           label: 'TYPE',
//           type: ErpFieldType.dropdown,
//           dropdownItems: roughTypeProvider.roughTypes
//               .where((element) {
//             return element.active==true;
//           },).map((e) {
//             return ErpDropdownItem(
//               label: e.roughTypeName ?? '',
//               value: e.roughTypeCode?.toString() ?? '',
//             );
//           }).toList(),
//           sectionIndex: 0,
//           flex: 2
//
//       ),
//       ErpFieldConfig(
//           key: 'articalCode',
//           label: 'ARTICAL',
//           type: ErpFieldType.dropdown,
//           dropdownItems: articleProvider.list
//               .where((element) {
//             return element.active==true;
//           },).map((e) {
//             return ErpDropdownItem(
//               label: e.articalName ?? '',
//               value: e.articalCode?.toString() ?? '',
//             );
//           }).toList(),
//           sectionIndex: 0,
//           flex: 2
//
//       ),
//       // ErpFieldConfig(
//       //   key: 'partyCode',
//       //   label: 'PARTY',
//       //   type: ErpFieldType.number,
//       //   flex: 2,
//       //   sectionIndex: 0,
//       // ),
//       // ErpFieldConfig(
//       //   key: 'roughTypeCode',
//       //   label: 'TYPE',
//       //   type: ErpFieldType.number,
//       //   flex: 2,
//       //   sectionIndex: 0,
//       // ),
//       // ErpFieldConfig(
//       //   key: 'articalCode',
//       //   label: 'ARTICAL',
//       //   type: ErpFieldType.number,
//       //   flex: 2,
//       //   sectionIndex: 0,
//       // ),
//     ],
//
//     [
//       ErpFieldConfig(
//           key: 'jangadCharniCode',
//           label: 'JAN. CHARNI',
//           type: ErpFieldType.dropdown,
//           dropdownItems: jangadCharniProvider.list
//               .where((element) {
//             return element.active==true;
//           },).map((e) {
//             return ErpDropdownItem(
//               label: e.jangadCharniName ?? '',
//               value: e.jangadCharniCode?.toString() ?? '',
//             );
//           }).toList(),
//           sectionIndex: 0,
//           flex: 1
//
//       ),
//       // ErpFieldConfig(
//       //   key: 'jangadCharniCode',
//       //   label: 'JAN. CHARNI',
//       //   type: ErpFieldType.number,
//       //   flex: 1,
//       //   sectionIndex: 0,
//       // ),
//     ],
//
//     // ─── SECTION 1: RATES & AMOUNTS ───────────────────────────────────────
//     [
//       ErpFieldConfig(
//         key: 'exRate',
//         label: 'EX RATE',
//         type: ErpFieldType.amount,
//         flex: 1,
//         sectionTitle: 'RATES & AMOUNTS',
//         sectionIndex: 1,
//       ),
//       ErpFieldConfig(
//         key: 'rateDollar',
//         label: 'RATE \$',
//         type: ErpFieldType.amount,
//         flex: 1,
//         sectionIndex: 1,
//       ),
//       ErpFieldConfig(
//         key: 'amtDollar',
//         label: 'AMT \$',
//         type: ErpFieldType.amount,
//         readOnly: true,
//         flex: 1,
//         sectionIndex: 1,
//         helperText: 'Auto: Rate\$ × Tot.Wt',
//       ),
//     ],
//
//
//     [
//       ErpFieldConfig(
//         key: 'rateRs',
//         label: 'RATE RS',
//         type: ErpFieldType.amount,
//         readOnly: true,
//         flex: 1,
//         sectionIndex: 1,
//         helperText: 'Auto: ExRate × Rate\$',
//       ),
//       ErpFieldConfig(
//         key: 'amtRs',
//         label: 'AMT RS',
//         type: ErpFieldType.amount,
//         readOnly: true,
//         flex: 1,
//         sectionIndex: 1,
//         helperText: 'Auto: RateRs × Tot.Wt',
//       ),
//     ],
//
//     // ─── SECTION 2: EXPENSES & SIZE ───────────────────────────────────────
//     [
//       ErpFieldConfig(
//         key: 'rgExpPer',
//         label: 'RG EXP %',
//         type: ErpFieldType.amount,
//         flex: 1,
//         sectionTitle: 'EXPENSES & SIZE',
//         sectionIndex: 2,
//       ),
//       ErpFieldConfig(
//         key: 'poExpPer',
//         label: 'PO EXP %',
//         type: ErpFieldType.amount,
//         flex: 1,
//         sectionIndex: 2,
//       ),
//     ],
//
//     [
//       ErpFieldConfig(
//         key: 'rgSize',
//         label: 'RG SIZE',
//         type: ErpFieldType.amount,
//         flex: 1,
//         sectionIndex: 2,
//       ),
//       ErpFieldConfig(
//         key: 'poSize',
//         label: 'PO SIZE',
//         type: ErpFieldType.amount,
//         flex: 1,
//         sectionIndex: 2,
//       ),
//     ],
//
//     [
//       ErpFieldConfig(
//         key: 'lsPer',
//         label: 'LS %',
//         type: ErpFieldType.amount,
//         flex: 1,
//         sectionIndex: 2,
//       ),
//     ],
//
//     // ─── SECTION 3: OTHER ─────────────────────────────────────────────────
//     [
//       ErpFieldConfig(
//         key: 'mainCutNo',
//         label: 'MAIN CUT NO',
//         flex: 2,
//         sectionTitle: 'OTHER',
//         sectionIndex: 3,
//       ),
//       ErpFieldConfig(
//         key: 'dueDay',
//         label: 'DUE DAY',
//         type: ErpFieldType.number,
//         flex: 1,
//         sectionIndex: 3,
//       ),
//       ErpFieldConfig(
//         key: 'dueDate',
//         label: 'DUE DATE',
//         type: ErpFieldType.date,
//         readOnly: true,
//         flex: 2,
//         sectionIndex: 3,
//         helperText: 'Auto: Date + Due Day',
//       ),
//     ],
//
//     [
//       ErpFieldConfig(
//         key: 'remarks',
//         label: 'REMARKS',
//         maxLines: 2,
//         flex: 1,
//         sectionIndex: 3,
//       ),
//     ],
//     [
//       ErpFieldConfig(
//         key: 'charniCode',
//         label: 'CHARNI',
//         type: ErpFieldType.dropdown,
//         dropdownItems: charniProvider.list
//             .where((element) {
//           return element.active==true;
//         },).map((e) {
//           return ErpDropdownItem(
//             label: e.charniName ?? '',
//             value: e.charniCode?.toString() ?? '',
//           );
//         }).toList(),
//         flex: 2,
//         sectionTitle: 'CHARNI ENTRY',
//         sectionIndex: 4,
//         isEntryField: true,
//         isEntryRequired: true,
//       ),
//       // ErpFieldConfig(
//       //   key: 'charniCode',
//       //   label: 'CHARNI',
//       //   type: ErpFieldType.number,
//       //   flex: 2,
//       //   sectionTitle: 'CHARNI ENTRY',
//       //   sectionIndex: 4,
//       //   isEntryField: true,
//       //   isEntryRequired: true,
//       // ),
//       ErpFieldConfig(
//         key: 'charniPc',
//         label: 'PC',
//         type: ErpFieldType.number,
//         flex: 1,
//         sectionIndex: 4,
//         isEntryField: true,
//       ),
//       ErpFieldConfig(
//         key: 'charniWt',
//         label: 'WT',
//         type: ErpFieldType.amount,
//         flex: 1,
//         sectionIndex: 4,
//         isEntryField: true,
//         isEntryRequired: true,
//       ),
//     ],
//
//     // ─── PROCESS DAYS ENTRY fields ─────────────────────────────────────────
//     [
//       ErpFieldConfig(
//         key: 'stockTypeCode',
//         label: 'STOCK TYPE',
//         type: ErpFieldType.dropdown,
//         dropdownItems: stockTypeProvider.list
//             .where((element) {
//           return element.active==true;
//         },).map((e) {
//           return ErpDropdownItem(
//             label: e.stockTypeName ?? '',
//             value: e.stockTypeCode?.toString() ?? '',
//           );
//         }).toList(),
//         flex: 2,
//         sectionTitle: 'PROCESS DAYS ENTRY',
//         sectionIndex: 5,
//         isEntryField: true,
//         isEntryRequired: true,
//       ),
//       // ErpFieldConfig(
//       //   key: 'stockTypeCode',
//       //   label: 'STOCK TYPE',
//       //   type: ErpFieldType.number,
//       //   flex: 2,
//       //   sectionTitle: 'PROCESS DAYS ENTRY',
//       //   sectionIndex: 5,
//       //   isEntryField: true,
//       //   isEntryRequired: true,
//       // ),
//       ErpFieldConfig(
//         key: 'entryDays',
//         label: 'DAYS',
//         type: ErpFieldType.number,
//         flex: 1,
//         sectionIndex: 5,
//         isEntryField: true,
//       ),
//     ],
//   ];
//   void _addCharniEntry() {
//     final entryFields = _formRows(
//       context.read<PartyProvider>(),
//       context.read<RoughTypeProvider>(),
//       context.read<ArticleProvider>(),
//       context.read<JangadCharaniProvider>(),
//       context.read<StockTypeProvider>(),
//       context.read<CharniProvider>(),
//     ).expand((r) => r).where((f) => f.isEntryField && (f.sectionIndex == 4)).toList();
//
//     // Validate required
//     for (final field in entryFields.where((f) => f.isEntryRequired)) {
//       final value = _formValues[field.key];
//       if (value == null || value.trim().isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('${field.label} required')),
//         );
//         _erpFormKey.currentState?.focusField(field.key);
//         return;
//       }
//     }
//
//     final entry = <String, dynamic>{};
//     final srno = _charniEntryData.length + 1;
//     entry['srno'] = srno.toString();
//     for (final field in entryFields) {
//       entry[field.key] = _formValues[field.key] ?? '';
//     }
//
//     // ✅ RoughDetModel mein bhi add karo (save ke liye)
//     setState(() {
//       _charniEntryData.add(entry);
//       _charniRows.add(RoughDetModel(
//         srno: srno,
//         charniCode: int.tryParse(_formValues['charniCode'] ?? ''),
//         pc: int.tryParse(_formValues['charniPc'] ?? ''),
//         wt: double.tryParse(_formValues['charniWt'] ?? ''),
//         per: 0,
//       ));
//       _recalcCharniPer();
//       _recalcRates();
//       _pushCalcToForm();
//     });
//
//     // Clear entry fields
//     for (final field in entryFields) {
//       _erpFormKey.currentState?.updateFieldValue(field.key, '');
//       _formValues.remove(field.key);
//     }
//     _erpFormKey.currentState?.focusField(entryFields.first.key);
//   }
//
//   void _addProcessDaysEntry() {
//     final entryFields = _formRows(
//       context.read<PartyProvider>(),
//       context.read<RoughTypeProvider>(),
//       context.read<ArticleProvider>(),
//       context.read<JangadCharaniProvider>(),
//       context.read<StockTypeProvider>(),
//       context.read<CharniProvider>(),
//
//     ).expand((r) => r).where((f) => f.isEntryField && (f.sectionIndex == 5)).toList();
//
//     for (final field in entryFields.where((f) => f.isEntryRequired)) {
//       final value = _formValues[field.key];
//       if (value == null || value.trim().isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('${field.label} required')),
//         );
//         _erpFormKey.currentState?.focusField(field.key);
//         return;
//       }
//     }
//
//     final entry = <String, dynamic>{};
//     final srno = _processDaysEntryData.length + 1;
//     entry['srno'] = srno.toString();
//     for (final field in entryFields) {
//       entry[field.key] = _formValues[field.key] ?? '';
//     }
//
//     setState(() {
//       _processDaysEntryData.add(entry);
//       _processDaysRows.add(RoughProcessDaysModel(
//         srno: srno,
//         stockTypeCode: int.tryParse(_formValues['stockTypeCode'] ?? ''),
//         days: double.tryParse(_formValues['entryDays'] ?? ''),
//       ));
//     });
//
//     for (final field in entryFields) {
//       _erpFormKey.currentState?.updateFieldValue(field.key, '');
//       _formValues.remove(field.key);
//     }
//     _erpFormKey.currentState?.focusField(entryFields.first.key);
//   }
//   // ══════════════════════════════════════════════════════════════════════════
//   //  INIT / DISPOSE
//   // ══════════════════════════════════════════════════════════════════════════
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<RoughProvider>().loadRoughs();
//       context.read<PartyProvider>().loadParties();
//       context.read<ArticleProvider>().load();
//       context.read<StockTypeProvider>().load();
//       context.read<CharniProvider>().load();
//       context.read<RoughTypeProvider>().loadRoughTypes();
//       context.read<JangadCharaniProvider>().load();
//       final today = DateFormat('dd/MM/yyyy').format(DateTime.now());
//       setState(() {
//         _formValues = {'roughDate': today, 'dueDate': today, 'roughMstID': '0'};
//       });
//     });
//     _charniEntryKeys = ['srno', 'charniCode', 'pc', 'wt', 'per'];
//     _processDaysEntryKeys = ['srno', 'stockTypeCode', 'days'];
//   }
//
//   @override
//   void dispose() {
//     _charniCodeCtrl.dispose();
//     _charniPcCtrl.dispose();
//     _charniWtCtrl.dispose();
//     _stockTypeCtrl.dispose();
//     _daysCtrl.dispose();
//     super.dispose();
//   }
//
//   // ══════════════════════════════════════════════════════════════════════════
//   //  CALCULATIONS
//   // ══════════════════════════════════════════════════════════════════════════
//
//   double get _totalWt => _charniRows.fold(0.0, (s, r) => s + (r.wt ?? 0));
//
//   void _recalcRates() {
//     final exRate = double.tryParse(_formValues['exRate'] ?? '') ?? 0;
//     final rateDollar = double.tryParse(_formValues['rateDollar'] ?? '') ?? 0;
//     final totWt = _totalWt;
//     _formValues['rateRs'] = (exRate * rateDollar).toStringAsFixed(2);
//     _formValues['amtDollar'] = (rateDollar * totWt).toStringAsFixed(2);
//     _formValues['amtRs'] = (exRate * rateDollar * totWt).toStringAsFixed(2);
//   }
//
//   void _recalcDueDate() {
//     try {
//       final base = DateFormat(
//         'dd/MM/yyyy',
//       ).parse(_formValues['roughDate'] ?? '');
//       final days = int.tryParse(_formValues['dueDay'] ?? '') ?? 0;
//       _formValues['dueDate'] = DateFormat(
//         'dd/MM/yyyy',
//       ).format(base.add(Duration(days: days)));
//     } catch (_) {}
//   }
//
//   void _recalcCharniPer() {
//     final totWt = _totalWt;
//     _charniRows = _charniRows.asMap().entries.map((e) {
//       final per = totWt > 0 ? ((e.value.wt ?? 0) / totWt * 100) : 0.0;
//       return RoughDetModel(
//         srno: e.value.srno,
//         charniCode: e.value.charniCode,
//         pc: e.value.pc,
//         wt: e.value.wt,
//         per: per,
//       );
//     }).toList();
//   }
//
//   /// Push auto-calc readonly values into ErpForm text controllers
//   void _pushCalcToForm() {
//     _erpFormKey.currentState?.updateFieldValue('rateRs', _formValues['rateRs']);
//     _erpFormKey.currentState?.updateFieldValue(
//       'amtDollar',
//       _formValues['amtDollar'],
//     );
//     _erpFormKey.currentState?.updateFieldValue('amtRs', _formValues['amtRs']);
//     _erpFormKey.currentState?.updateFieldValue(
//       'dueDate',
//       _formValues['dueDate'],
//     );
//   }
//
//   // ══════════════════════════════════════════════════════════════════════════
//   //  CHARNI sub-table operations
//   // ══════════════════════════════════════════════════════════════════════════
// // ── Entry data (ErpEntryGrid ke liye) ─────────────────────────────────────
//   final List<Map<String, dynamic>> _charniEntryData = [];
//   final List<Map<String, dynamic>> _processDaysEntryData = [];
//
//   late final List<String> _charniEntryKeys;
//   late final List<String> _processDaysEntryKeys;
//   void _addCharniRow() {
//     final code = int.tryParse(_charniCodeCtrl.text.trim());
//     final pc = int.tryParse(_charniPcCtrl.text.trim());
//     final wt = double.tryParse(_charniWtCtrl.text.trim());
//     if (code == null && wt == null) return;
//
//     setState(() {
//       _charniRows.add(
//         RoughDetModel(
//           srno: _charniRows.length + 1,
//           charniCode: code,
//           pc: pc,
//           wt: wt,
//           per: 0,
//         ),
//       );
//       _recalcCharniPer();
//       _recalcRates();
//     });
//
//     _charniCodeCtrl.clear();
//     _charniPcCtrl.clear();
//     _charniWtCtrl.clear();
//     _pushCalcToForm();
//   }
//
//   void _deleteCharniRow(int index) {
//     setState(() {
//       _charniRows.removeAt(index);
//       _charniRows = _charniRows
//           .asMap()
//           .entries
//           .map(
//             (e) => RoughDetModel(
//           srno: e.key + 1,
//           charniCode: e.value.charniCode,
//           pc: e.value.pc,
//           wt: e.value.wt,
//           per: e.value.per,
//         ),
//       )
//           .toList();
//       _recalcCharniPer();
//       _recalcRates();
//     });
//     _pushCalcToForm();
//   }
//
//   // ══════════════════════════════════════════════════════════════════════════
//   //  PROCESS DAYS sub-table operations
//   // ══════════════════════════════════════════════════════════════════════════
//
//   void _addProcessDaysRow() {
//     final code = int.tryParse(_stockTypeCtrl.text.trim());
//     final days = double.tryParse(_daysCtrl.text.trim());
//     if (code == null) return;
//
//     setState(() {
//       _processDaysRows.add(
//         RoughProcessDaysModel(
//           srno: _processDaysRows.length + 1,
//           stockTypeCode: code,
//           days: days,
//         ),
//       );
//     });
//     _stockTypeCtrl.clear();
//     _daysCtrl.clear();
//   }
//
//   void _deleteProcessDaysRow(int index) {
//     setState(() {
//       _processDaysRows.removeAt(index);
//       _processDaysRows = _processDaysRows
//           .asMap()
//           .entries
//           .map(
//             (e) => RoughProcessDaysModel(
//           srno: e.key + 1,
//           stockTypeCode: e.value.stockTypeCode,
//           days: e.value.days,
//         ),
//       )
//           .toList();
//     });
//   }
//
//   // ══════════════════════════════════════════════════════════════════════════
//   //  ROW TAP  (same pattern as MstFirmParty._onRowTap)
//   // ══════════════════════════════════════════════════════════════════════════
//   Future<void> _onRowTap(Map<String, dynamic> row) async {
//     final raw = row['_raw'] as RoughModel;
//     final provider = context.read<RoughProvider>();
//
//     final details = await provider.loadDetails(raw.roughMstID!);
//     final processDays = await provider.loadProcessDays(raw.roughMstID!);
//
//     setState(() {
//       _selectedRow = row;
//       _selectedRough = raw;
//       _isEditMode = true;
//       _charniRows = details;
//       _processDaysRows = processDays;
//
//       _formValues = {
//         'roughMstID': raw.roughMstID?.toString() ?? '0',
//         'roughDate': raw.roughDate ?? '',
//         'jno': raw.jno?.toString() ?? '',
//         'kapanNo': raw.kapanNo ?? '',
//         'site': raw.site ?? '',
//         'inv': raw.inv ?? '',
//         'partyCode': raw.partyCode?.toString() ?? '',
//         'roughTypeCode': raw.roughTypeCode?.toString() ?? '',
//         'articalCode': raw.articalCode?.toString() ?? '',
//         'jangadCharniCode': raw.jangadCharniCode?.toString() ?? '',
//         'exRate': raw.exRate?.toStringAsFixed(2) ?? '',
//         'rateDollar': raw.rateDollar?.toStringAsFixed(2) ?? '',
//         'amtDollar': raw.amtDollar?.toStringAsFixed(2) ?? '',
//         'rateRs': raw.rateRs?.toStringAsFixed(2) ?? '',
//         'amtRs': raw.amtRs?.toStringAsFixed(2) ?? '',
//         'rgExpPer': raw.rgExpPer?.toStringAsFixed(2) ?? '',
//         'poExpPer': raw.poExpPer?.toStringAsFixed(2) ?? '',
//         'rgSize': raw.rgSize?.toStringAsFixed(2) ?? '',
//         'poSize': raw.poSize?.toStringAsFixed(2) ?? '',
//         'lsPer': raw.lsPer?.toStringAsFixed(2) ?? '',
//         'mainCutNo': raw.mainCutNo ?? '',
//         'dueDay': raw.dueDay?.toString() ?? '',
//         'dueDate': raw.dueDate ?? '',
//         'remarks': raw.remarks ?? '',
//       };
//       _charniEntryData.clear();
//       _charniEntryData.addAll(details.map((d) => {
//         'srno': d.srno?.toString() ?? '',
//         'charniCode': d.charniCode?.toString() ?? '',
//         'pc': d.pc?.toString() ?? '',
//         'wt': d.wt?.toStringAsFixed(3) ?? '',
//         'per': d.per?.toStringAsFixed(2) ?? '',
//       }));
//
//       _processDaysEntryData.clear();
//       _processDaysEntryData.addAll(processDays.map((p) => {
//         'srno': p.srno?.toString() ?? '',
//         'stockTypeCode': p.stockTypeCode?.toString() ?? '',
//         'days': p.days?.toStringAsFixed(0) ?? '',
//       }));
//
//       if (Responsive.isMobile(context)) _showTableOnMobile = false;
//     });
//   }
//
//   // ══════════════════════════════════════════════════════════════════════════
//   //  SAVE  (same pattern as MstFirmParty._onSave)
//   // ══════════════════════════════════════════════════════════════════════════
//   Future<void> _onSave(Map<String, dynamic> values) async {
//     final provider = context.read<RoughProvider>();
//
//     // ErpForm._handleSave passes controller values; readOnly fields (rateRs,
//     // amtDollar, amtRs, dueDate) are also collected because updateFieldValue
//     // sets their controllers. Merge our local copy just to be safe.
//     final merged = Map<String, dynamic>.from(values);
//     merged['rateRs'] = _formValues['rateRs'] ?? '0';
//     merged['amtDollar'] = _formValues['amtDollar'] ?? '0';
//     merged['amtRs'] = _formValues['amtRs'] ?? '0';
//     merged['dueDate'] = _formValues['dueDate'] ?? '';
//
//     bool success;
//     if (_isEditMode && _selectedRough != null) {
//       success = await provider.updateRough(
//         _selectedRough!.roughMstID!,
//         merged,
//         _charniRows,
//         _processDaysRows,
//       );
//     } else {
//       success = await provider.createRough(
//         merged,
//         _charniRows,
//         _processDaysRows,
//       );
//     }
//
//     if (!mounted) return;
//     if (success) {
//       _resetForm();
//       await ErpResultDialog.showSuccess(
//         context: context,
//         theme: _theme,
//         title: _isEditMode ? 'Updated' : 'Saved',
//         message: _isEditMode
//             ? 'Rough entry updated successfully.'
//             : 'Rough entry saved successfully.',
//       );
//     }
//   }
//
//   // ══════════════════════════════════════════════════════════════════════════
//   //  DELETE  (same pattern as MstFirmParty._onDelete)
//   // ══════════════════════════════════════════════════════════════════════════
//   Future<void> _onDelete() async {
//     if (_selectedRough?.roughMstID == null) return;
//     final confirm = await ErpDeleteDialog.show(
//       context: context,
//       theme: _theme,
//       title: 'Rough Entry',
//       itemName: 'JNO: ${_selectedRough!.jno ?? ''}',
//     );
//     if (confirm != true || !mounted) return;
//
//     final success = await context.read<RoughProvider>().deleteRough(
//       _selectedRough!.roughMstID!,
//     );
//
//     if (success && mounted) {
//       _resetForm();
//       await ErpResultDialog.showDeleted(
//         context: context,
//         theme: _theme,
//         itemName: 'Rough Entry ${_selectedRough?.jno ?? ''}',
//       );
//     }
//   }
//
//   // ══════════════════════════════════════════════════════════════════════════
//   //  RESET  (same pattern as MstFirmParty._resetForm)
//   // ══════════════════════════════════════════════════════════════════════════
//   void _resetForm() {
//     final today = DateFormat('dd/MM/yyyy').format(DateTime.now());
//     setState(() {
//       _selectedRow = null;
//       _selectedRough = null;
//       _isEditMode = false;
//       _showTableOnMobile = false;
//       _charniRows = [];
//       _processDaysRows = [];
//       _formValues = {'roughDate': today, 'dueDate': today, 'roughMstID': '0'};
//       _charniCodeCtrl.clear();
//       _charniPcCtrl.clear();
//       _charniWtCtrl.clear();
//       _stockTypeCtrl.clear();
//       _charniEntryData.clear();      // ✅
//       _processDaysEntryData.clear(); // ✅
//       _daysCtrl.clear();
//     });
//     _erpFormKey.currentState?.resetForm();
//   }
//
//   // ══════════════════════════════════════════════════════════════════════════
//   //  BUILD  (same layout as MstFirmParty.build)
//   // ══════════════════════════════════════════════════════════════════════════
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<RoughProvider>(
//       builder: (context, provider, _) {
//         return Padding(
//           padding: const EdgeInsets.all(8),
//           child: Responsive.isMobile(context)
//               ? _showTableOnMobile
//               ? _buildTable(provider)
//               : _buildErpForm(context)
//               : Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Expanded(flex: 2, child: _buildErpForm(context)),
//               const SizedBox(width: 12),
//               Expanded(flex: 2, child: _buildTable(provider)),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   // ── ErpForm (LEFT) ─────────────────────────────────────────────────────────
//   Widget _buildErpForm(BuildContext context) {
//     final partyProvider = context.watch<PartyProvider>();
//     final roughTypeProvider = context.watch<RoughTypeProvider>();
//     final articleProvider = context.watch<ArticleProvider>();
//     final jangadCharniProvider = context.watch<JangadCharaniProvider>();
//     final stockTypeProvider = context.watch<StockTypeProvider>();
//     final charniProvider = context.watch<CharniProvider>();
//     return ErpForm(
//       key: _erpFormKey,
//       title: 'ROUGH ENTRY',
//       subtitle: 'Transaction / Rough Stock Entry',
//       tabBarBackgroundColor: const Color(0xfff2f0ef),
//       tabBarSelectedColor: _theme.primaryGradient.first,
//       tabBarSelectedTxtColor: Colors.white,
//       rows: _formRows(partyProvider,roughTypeProvider,articleProvider,jangadCharniProvider,stockTypeProvider,charniProvider),
//       initialValues: _formValues,
//       isEditMode: _isEditMode,
//       extraActions: [
//         IconButton(
//           tooltip: "Add Charni Entry",
//           icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 18),
//           onPressed: _addCharniEntry,
//         ),
//         IconButton(
//           tooltip: "Add Process Days Entry",
//           icon: const Icon(Icons.add_box_outlined, color: Colors.white, size: 18),
//           onPressed: _addProcessDaysEntry,
//         ),
//       ],
//       onFieldChanged: (key, value) {
//         setState(() {
//           _formValues[key] = value.toString();
//           if (key == 'exRate' || key == 'rateDollar') {
//             _recalcRates();
//             _pushCalcToForm();
//           }
//           if (key == 'roughDate' || key == 'dueDay') {
//             _recalcDueDate();
//             _pushCalcToForm();
//           }
//         });
//       },
//       onSave: _onSave,
//       onCancel: _resetForm,
//       onDelete: _isEditMode ? _onDelete : null,
//       onSearch: () => setState(() => _showTableOnMobile = true),
//       detailBuilder: (ctx) {
//         final theme = ctx.erpTheme;
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // ✅ Charni entries grid
//             ErpEntryGrid(
//               data: _charniEntryData,
//               columns: _charniEntryKeys,
//               title: 'CHARNI DETAILS',
//               theme: theme,
//             ),
//             if (_charniEntryData.isNotEmpty && _processDaysEntryData.isNotEmpty)
//               const SizedBox(height: 10),
//             // ✅ Process days entries grid
//             ErpEntryGrid(
//               data: _processDaysEntryData,
//               columns: _processDaysEntryKeys,
//               title: 'PROCESS DAYS',
//               theme: theme,
//             ),
//           ],
//         );
//       },
//       // detailBuilder: (ctx) {
//       //   // Use ctx.erpTheme so sub-tables respect active theme
//       //   final theme = ctx.erpTheme;
//       //   return Row(
//       //     crossAxisAlignment: CrossAxisAlignment.start,
//       //     children: [
//       //       Expanded(child: _buildCharniTable(theme)),
//       //       const SizedBox(width: 10),
//       //       Expanded(child: _buildProcessDaysTable(theme)),
//       //     ],
//       //   );
//       // },
//     );
//   }
//
//   // ── ErpDataTable (RIGHT) ───────────────────────────────────────────────────
//   Widget _buildTable(RoughProvider provider) {
//     return ErpDataTable(
//       token: token ?? '',
//       url: 'http://50.62.183.116:5000',
//       title: 'ROUGH ENTRY LIST',
//       columns: _tableColumns,
//       data: provider.tableData,
//       showSearch: true,
//       showFooterTotals: false,
//       selectedRow: _selectedRow,
//       onRowTap: _onRowTap,
//       emptyMessage: provider.isLoaded ? 'No entries found' : 'Loading...',
//     );
//   }
//
//   // ── Charni sub-table ───────────────────────────────────────────────────────
//   Widget _buildCharniTable(ErpTheme theme) {
//     return _SubTableCard(
//       title: 'CHARNI DETAILS',
//       theme: theme,
//       totalLabel: 'Total Wt: ${_totalWt.toStringAsFixed(3)}',
//       inputRow: Row(
//         children: [
//           Expanded(
//             flex: 2,
//             child: _miniField('Charni', _charniCodeCtrl, theme, isNumber: true),
//           ),
//           const SizedBox(width: 4),
//           Expanded(
//             child: _miniField('Pc', _charniPcCtrl, theme, isNumber: true),
//           ),
//           const SizedBox(width: 4),
//           Expanded(
//             child: _miniField('Wt', _charniWtCtrl, theme, isDecimal: true),
//           ),
//           const SizedBox(width: 4),
//           _addBtn(theme, _addCharniRow),
//         ],
//       ),
//       headers: const ['Sr', 'Charni', 'Pc', 'Wt', 'Per%', ''],
//       rows: _charniRows
//           .map(
//             (r) => [
//           r.srno?.toString() ?? '',
//           r.charniCode?.toString() ?? '',
//           r.pc?.toString() ?? '',
//           r.wt?.toStringAsFixed(3) ?? '',
//           r.per?.toStringAsFixed(2) ?? '',
//           '',
//         ],
//       )
//           .toList(),
//       onDeleteRow: _deleteCharniRow,
//     );
//   }
//
//   // ── Process Days sub-table ─────────────────────────────────────────────────
//   Widget _buildProcessDaysTable(ErpTheme theme) {
//     return _SubTableCard(
//       title: 'PROCESS DAYS',
//       theme: theme,
//       inputRow: Row(
//         children: [
//           Expanded(
//             flex: 3,
//             child: _miniField(
//               'StockType',
//               _stockTypeCtrl,
//               theme,
//               isNumber: true,
//             ),
//           ),
//           const SizedBox(width: 4),
//           Expanded(
//             flex: 2,
//             child: _miniField('Days', _daysCtrl, theme, isDecimal: true),
//           ),
//           const SizedBox(width: 4),
//           _addBtn(theme, _addProcessDaysRow),
//         ],
//       ),
//       headers: const ['Sr', 'StockType', 'Days', ''],
//       rows: _processDaysRows
//           .map(
//             (r) => [
//           r.srno?.toString() ?? '',
//           r.stockTypeCode?.toString() ?? '',
//           r.days?.toStringAsFixed(0) ?? '',
//           '',
//         ],
//       )
//           .toList(),
//       onDeleteRow: _deleteProcessDaysRow,
//     );
//   }
//
//   // ── Mini field (sub-table input row) ──────────────────────────────────────
//   Widget _miniField(
//       String hint,
//       TextEditingController ctrl,
//       ErpTheme theme, {
//         bool isNumber = false,
//         bool isDecimal = false,
//       }) {
//     return SizedBox(
//       height: 28,
//       child: TextField(
//         controller: ctrl,
//         keyboardType: isNumber
//             ? TextInputType.number
//             : isDecimal
//             ? const TextInputType.numberWithOptions(decimal: true)
//             : TextInputType.text,
//         style: const TextStyle(fontSize: 11),
//         decoration: InputDecoration(
//           hintText: hint,
//           hintStyle: TextStyle(fontSize: 10, color: theme.textLight),
//           isDense: true,
//           filled: true,
//           fillColor: Colors.white,
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 6,
//             vertical: 5,
//           ),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(5),
//             borderSide: BorderSide(color: theme.border),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(5),
//             borderSide: BorderSide(color: theme.border),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(5),
//             borderSide: BorderSide(color: theme.primary),
//           ),
//         ),
//         onSubmitted: (_) {
//           if (hint == 'Wt') _addCharniRow();
//           if (hint == 'Days') _addProcessDaysRow();
//         },
//       ),
//     );
//   }
//
//   Widget _addBtn(ErpTheme theme, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: 28,
//         height: 28,
//         decoration: BoxDecoration(
//           color: theme.primary,
//           borderRadius: BorderRadius.circular(6),
//         ),
//         child: const Icon(Icons.add, color: Colors.white, size: 16),
//       ),
//     );
//   }
// }
//
// // ═══════════════════════════════════════════════════════════════════════════════
// //  _SubTableCard  —  Reusable inline entry/detail sub-table
// // ═══════════════════════════════════════════════════════════════════════════════
// class _SubTableCard extends StatelessWidget {
//   final String title;
//   final ErpTheme theme;
//   final Widget inputRow;
//   final List<String> headers;
//   final List<List<String>> rows;
//   final void Function(int index)? onDeleteRow;
//   final String? totalLabel;
//
//   const _SubTableCard({
//     required this.title,
//     required this.theme,
//     required this.inputRow,
//     required this.headers,
//     required this.rows,
//     this.onDeleteRow,
//     this.totalLabel,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final t = theme;
//     return Container(
//       decoration: BoxDecoration(
//         color: t.surface,
//         border: Border.all(color: t.primary.withOpacity(0.25)),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           // Title
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//             decoration: BoxDecoration(
//               color: t.primary.withOpacity(0.08),
//               borderRadius: const BorderRadius.vertical(
//                 top: Radius.circular(10),
//               ),
//               border: Border(
//                 bottom: BorderSide(color: t.primary.withOpacity(0.2)),
//               ),
//             ),
//             child: Text(
//               title,
//               style: TextStyle(
//                 fontSize: 10,
//                 fontWeight: FontWeight.w700,
//                 color: t.primary,
//                 letterSpacing: 0.5,
//               ),
//             ),
//           ),
//
//           // Input row
//           Padding(
//             padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
//             child: inputRow,
//           ),
//
//           // Column headers
//           Container(
//             color: t.primary.withOpacity(0.05),
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             child: Row(
//               children: headers.asMap().entries.map((e) {
//                 final isAction = e.key == headers.length - 1;
//                 return isAction
//                     ? const SizedBox(width: 20)
//                     : Expanded(
//                   child: Text(
//                     e.value,
//                     style: TextStyle(
//                       fontSize: 9,
//                       fontWeight: FontWeight.w700,
//                       color: t.primary.withOpacity(0.7),
//                       letterSpacing: 0.3,
//                     ),
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//
//           // Data rows
//           ...rows.asMap().entries.map((e) {
//             final idx = e.key;
//             final cols = e.value;
//             return Container(
//               decoration: BoxDecoration(
//                 color: idx.isEven ? Colors.white : t.bg.withOpacity(0.5),
//                 border: Border(
//                   bottom: BorderSide(color: t.border.withOpacity(0.5)),
//                 ),
//               ),
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               child: Row(
//                 children: cols.asMap().entries.map((ce) {
//                   final isAction = ce.key == cols.length - 1;
//                   return isAction
//                       ? SizedBox(
//                     width: 20,
//                     child: onDeleteRow != null
//                         ? GestureDetector(
//                       onTap: () => onDeleteRow!(idx),
//                       child: Icon(
//                         Icons.close,
//                         size: 14,
//                         color: Colors.red.shade400,
//                       ),
//                     )
//                         : const SizedBox.shrink(),
//                   )
//                       : Expanded(
//                     child: Text(
//                       ce.value,
//                       style: TextStyle(fontSize: 11, color: t.text),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   );
//                 }).toList(),
//               ),
//             );
//           }),
//
//           // Footer total
//           if (totalLabel != null)
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
//               decoration: BoxDecoration(
//                 color: t.primary.withOpacity(0.06),
//                 borderRadius: const BorderRadius.vertical(
//                   bottom: Radius.circular(10),
//                 ),
//                 border: Border(
//                   top: BorderSide(color: t.primary.withOpacity(0.15)),
//                 ),
//               ),
//               child: Text(
//                 totalLabel!,
//                 textAlign: TextAlign.right,
//                 style: TextStyle(
//                   fontSize: 10,
//                   fontWeight: FontWeight.w700,
//                   color: t.primary,
//                 ),
//               ),
//             )
//           else
//             const SizedBox(height: 4),
//         ],
//       ),
//     );
//   }
// }
