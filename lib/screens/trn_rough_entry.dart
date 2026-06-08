import 'package:diam_mfg/models/rough_model.dart';
import 'package:diam_mfg/providers/article_provider.dart';
import 'package:diam_mfg/providers/charni_provider.dart';
import 'package:diam_mfg/providers/jangad_charni_provider.dart';
import 'package:diam_mfg/providers/party_provider.dart';
import 'package:diam_mfg/providers/rough_provider.dart';
import 'package:diam_mfg/providers/rough_type_provider.dart';
import 'package:diam_mfg/providers/stock_type_provider.dart';
import 'package:diam_mfg/services/duplicate_check_service.dart';
import 'package:diam_mfg/services/duplicate_utils.dart';
import 'package:diam_mfg/utils/constants.dart';
import 'package:diam_mfg/utils/helper_functions.dart';
import 'package:erp_data_table/erp_data_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rs_dashboard/rs_dashboard.dart';
import '../bootstrap.dart';
import '../models/charni_model.dart';
import '../models/stock_type_model.dart';
import '../utils/app_images.dart';
import '../utils/delete_dialogue.dart';
import '../utils/msg_dialogue.dart';

class TrnRoughEntry extends StatefulWidget {
  const TrnRoughEntry({super.key});

  @override
  State<TrnRoughEntry> createState() => _TrnRoughEntryState();
}

class _TrnRoughEntryState extends State<TrnRoughEntry> {
  final ErpThemeVariant _themeVariant = ErpThemeVariant.frost;

  ErpTheme get _theme => ErpTheme(_themeVariant);

  final GlobalKey<ErpFormState> _erpFormKey = GlobalKey<ErpFormState>();

  Map<String, dynamic>? _selectedRow;
  RoughModel? _selectedRough;
  bool _isEditMode = false;
  Map<String, String> _formValues = {};
  bool _showTableOnMobile = false;

  // Model rows (save ke liye)
  List<RoughDetModel> _charniRows = [];
  List<RoughProcessDaysModel> _processDaysRows = [];

  // Display rows (ErpEntryGrid ke liye)
  List<Map<String, dynamic>> _charniEntryData = [];
  List<Map<String, dynamic>> _processDaysEntryData = [];

  // Kaunsa row edit ho raha hai (null = add mode)
  int? _editingCharniIndex;
  int? _editingProcessDaysIndex;

  // ErpEntryGrid column keys
  late final List<String> _charniEntryKeys;
  late final List<String> _processDaysEntryKeys;

  final String? token = AppStorage.getString("token");

  // ══════════════════════════════════════════════════════════════════════════
  //  TABLE COLUMNS
  // ══════════════════════════════════════════════════════════════════════════
  List<ErpColumnConfig> get _tableColumns => [
    ErpColumnConfig(key: 'roughMstID', label: 'ID', width: 90, required: true),
    ErpColumnConfig(
      key: 'roughDate',
      label: 'DATE',
      width: 130,
      required: true,
      isDate: true,
    ),
    ErpColumnConfig(key: 'jno', label: 'JNO', width: 130),
    ErpColumnConfig(key: 'kapanNo', label: 'KNO', width: 130), // ✅ ADD
    ErpColumnConfig(key: 'partyCode', label: 'PARTY', width: 160),
    ErpColumnConfig(key: 'amtDollar', label: 'AMT \$', width: 160),
    ErpColumnConfig(key: 'amtRs', label: 'AMT RS', width: 180),
    ErpColumnConfig(key: 'totPc', label: 'TOT PC', width: 160), // ✅ ADD
    ErpColumnConfig(key: 'totWt', label: 'TOT WT', width: 160), // ✅ ADD
  ];

  // ══════════════════════════════════════════════════════════════════════════
  //  FORM ROWS
  // ══════════════════════════════════════════════════════════════════════════
  List<List<ErpFieldConfig>> _formRows(
    PartyProvider p,
    RoughTypeProvider rt,
    ArticleProvider ar,
    JangadCharaniProvider jc,
    StockTypeProvider st,
    CharniProvider ch,
  ) => [
    // SECTION 0: BASIC INFORMATION
    [
      ErpFieldConfig(
        key: 'roughDate',
        label: 'DATE',
        type: ErpFieldType.date,
        readOnly: true,
        required: true,
        flex: 1,
        sectionTitle: 'BASIC INFORMATION',
        sectionIndex: 0,
      ),
      ErpFieldConfig(
        key: 'roughMstID',
        label: 'ID',
        type: ErpFieldType.number,
        readOnly: true,
        flex: 1,
        sectionIndex: 0,
      ),
      ErpFieldConfig(
        key: 'jno',
        label: 'JNO',
        type: ErpFieldType.number,
        flex: 1,
        sectionIndex: 0,
        readOnly: _isEditMode,
        onDuplicateCheck: (value, allValues) async {
          return await _checkDuplicate(
            fields: {'Jno': num.parse(value.toString())},
          );
        },
      ),
    ],
    [
      ErpFieldConfig(
        key: 'kapanNo',
        label: 'KNO',
        flex: 1,
        sectionIndex: 0,
        readOnly: _isEditMode,
        inputFormatters: [UpperCaseTextFormatter()],
      ),
      ErpFieldConfig(
        key: 'site',
        label: 'SITE',
        flex: 1,
        sectionIndex: 0,
        inputFormatters: [UpperCaseTextFormatter()],
      ),
      ErpFieldConfig(
        key: 'inv',
        label: 'INV',
        flex: 1,
        sectionIndex: 0,
        inputFormatters: [UpperCaseTextFormatter()],
      ),
      ErpFieldConfig(
        key: 'partyCode',
        label: 'PARTY',
        type: ErpFieldType.dropdown,
        dropdownItems: p.list
            .where((e) => e.active == true)
            .map(
              (e) => ErpDropdownItem(
                label: e.partyName ?? '',
                value: e.partyCode?.toString() ?? '',
              ),
            )
            .toList(),
        sectionIndex: 0,
        flex: 1,
      ),
    ],
    [
      ErpFieldConfig(
        key: 'roughTypeCode',
        label: 'TYPE',
        type: ErpFieldType.dropdown,
        dropdownItems: rt.roughTypes
            .where((e) => e.active == true)
            .map(
              (e) => ErpDropdownItem(
                label: e.roughTypeName ?? '',
                value: e.roughTypeCode?.toString() ?? '',
              ),
            )
            .toList(),
        sectionIndex: 0,
        flex: 2,
      ),
      ErpFieldConfig(
        key: 'articalCode',
        label: 'ARTICAL',
        type: ErpFieldType.dropdown,
        dropdownItems: ar.list
            .where((e) => e.active == true)
            .map(
              (e) => ErpDropdownItem(
                label: e.articalName ?? '',
                value: e.articalCode?.toString() ?? '',
              ),
            )
            .toList(),
        sectionIndex: 0,
        flex: 2,
      ),
      ErpFieldConfig(
        key: 'jangadCharniCode',
        label: 'JAN. CHARNI',
        type: ErpFieldType.dropdown,
        dropdownItems: jc.list
            .where((e) => e.active == true)
            .map(
              (e) => ErpDropdownItem(
                label: e.jangadCharniName ?? '',
                value: e.jangadCharniCode?.toString() ?? '',
              ),
            )
            .toList(),
        sectionIndex: 0,
        flex: 2,
      ),
    ],

    // SECTION 1: RATES & AMOUNTS
    [
      ErpFieldConfig(
        key: 'exRate',
        label: 'EX RATE',
        type: ErpFieldType.amount,
        flex: 1,
        sectionTitle: 'RATES & AMOUNTS',
        sectionIndex: 1,
      ),
      ErpFieldConfig(
        key: 'rateDollar',
        label: 'RATE \$',
        type: ErpFieldType.amount,
        flex: 1,
        sectionIndex: 1,
      ),
      ErpFieldConfig(
        key: 'amtDollar',
        label: 'AMT \$',
        type: ErpFieldType.amount,
        readOnly: true,
        flex: 1,
        sectionIndex: 1,
        helperText: 'Rate\$ × Tot.Wt',
      ),
    ],
    [
      ErpFieldConfig(
        key: 'rateRs',
        label: 'RATE RS',
        type: ErpFieldType.amount,
        readOnly: true,
        flex: 1,
        sectionIndex: 1,
        helperText: 'ExRate × Rate\$',
      ),
      ErpFieldConfig(
        key: 'amtRs',
        label: 'AMT RS',
        type: ErpFieldType.amount,
        readOnly: true,
        flex: 1,
        sectionIndex: 1,
        helperText: 'RateRs × Tot.Wt',
      ),
    ],

    // SECTION 2: EXPENSES & SIZE
    [
      ErpFieldConfig(
        key: 'rgExpPer',
        label: 'RG EXP %',
        type: ErpFieldType.amount,
        flex: 1,
        sectionTitle: 'EXPENSES & SIZE',
        sectionIndex: 2,
      ),
      ErpFieldConfig(
        key: 'poExpPer',
        label: 'PO EXP %',
        type: ErpFieldType.amount,
        flex: 1,
        sectionIndex: 2,
      ),
    ],
    [
      ErpFieldConfig(
        key: 'rgSize',
        label: 'RG SIZE',
        type: ErpFieldType.amount,
        flex: 1,
        sectionIndex: 2,
      ),
      ErpFieldConfig(
        key: 'poSize',
        label: 'PO SIZE',
        type: ErpFieldType.amount,
        flex: 1,
        sectionIndex: 2,
      ),
      ErpFieldConfig(
        key: 'lsPer',
        label: 'LS %',
        type: ErpFieldType.amount,
        flex: 1,
        sectionIndex: 2,
      ),
    ],

    // SECTION 3: OTHER
    [
      ErpFieldConfig(
        key: 'mainCutNo',
        label: 'MAIN CUT NO',
        flex: 2,
        sectionTitle: 'OTHER',
        sectionIndex: 3,
        inputFormatters: [UpperCaseTextFormatter()],
      ),
      ErpFieldConfig(
        key: 'dueDay',
        label: 'DUE DAY',
        type: ErpFieldType.number,
        flex: 1,
        sectionIndex: 3,
      ),
      ErpFieldConfig(
        key: 'dueDate',
        label: 'DUE DATE',
        type: ErpFieldType.date,
        readOnly: true,
        flex: 2,
        sectionIndex: 3,
        helperText: 'Date + Due Day',
      ),
    ],
    [
      ErpFieldConfig(
        key: 'remarks',
        label: 'REMARKS',
        maxLines: 2,
        flex: 1,
        sectionIndex: 3,
        inputFormatters: [UpperCaseTextFormatter()],
      ),
    ],

    // SECTION 4: CHARNI ENTRY
    [
      ErpFieldConfig(
        key: 'charniCode',
        label: 'CHARNI',
        type: ErpFieldType.dropdown,
        dropdownItems: ch.list
            .where((e) => e.active == true)
            .map(
              (e) => ErpDropdownItem(
                label: e.charniName ?? '',
                value: e.charniCode?.toString() ?? '',
              ),
            )
            .toList(),
        flex: 2,
        sectionTitle: 'CHARNI ENTRY',
        sectionIndex: 4,
        isEntryField: true,
        isEntryRequired: true,
      ),
      ErpFieldConfig(
        key: 'charniPc',
        label: 'PC',
        type: ErpFieldType.number,
        flex: 1,
        sectionIndex: 4,
        isEntryField: true,
      ),
      ErpFieldConfig(
        key: 'charniWt',
        label: 'WT',
        type: ErpFieldType.amount,
        flex: 1,
        sectionIndex: 4,
        isEntryField: true,
        isEntryRequired: true,
        showAddButton: true,
      ),
    ],

    // SECTION 5: PROCESS DAYS ENTRY
    [
      ErpFieldConfig(
        key: 'stockTypeCode',
        label: 'STOCK TYPE',
        type: ErpFieldType.dropdown,
        dropdownItems: st.list
            .where((e) => e.active == true)
            .map(
              (e) => ErpDropdownItem(
                label: e.stockTypeName ?? '',
                value: e.stockTypeCode?.toString() ?? '',
              ),
            )
            .toList(),
        flex: 2,
        sectionTitle: 'PROCESS DAYS ENTRY',
        sectionIndex: 5,
        isEntryField: true,
        isEntryRequired: true,
        getBlockedValues: () => _processDaysRows
            .map((r) => r.stockTypeCode?.toString() ?? '')
            .where((v) => v.isNotEmpty)
            .toSet(),
      ),
      ErpFieldConfig(
        key: 'entryDays',
        label: 'DAYS',
        type: ErpFieldType.number,
        flex: 1,
        sectionIndex: 5,
        isEntryField: true,
        isEntryRequired: true,
        showAddButton: true,
      ),
    ],
  ];

  Future<bool> _checkDuplicate({required Map<dynamic, dynamic> fields}) async {
    /// ── SKIP SAME VALUE IN EDIT ───────────────
    final skip = shouldSkipDuplicateCheck(
      isEditMode: _isEditMode,
      selectedRow: _selectedRow,
      allowRowData: true,
      newFields: Map<String, dynamic>.from(fields),
      fieldMapping: {'Jno': 'Jno'},
    );

    if (skip) {
      return false;
    }

    /// ── API CHECK ─────────────────────────────
    return await checkDuplicateRecord(
      context: context,
      theme: _theme,
      formName: 'Rough',
      fields: fields,
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  INIT
  // ══════════════════════════════════════════════════════════════════════════
  @override
  void initState() {
    super.initState();
    _charniEntryKeys = ['srno', 'charniName', 'charniPc', 'charniWt', 'per'];
    _processDaysEntryKeys = ['srno', 'stockTypeName', 'entryDays'];
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<RoughProvider>().loadRoughs();
      context.read<PartyProvider>().loadParties();
      context.read<ArticleProvider>().load();
      context.read<StockTypeProvider>().load();
      context.read<CharniProvider>().load();
      context.read<RoughTypeProvider>().loadRoughTypes();
      context.read<JangadCharaniProvider>().load();
      await _setDefaultFormValues();
    });
  }

  Future<void> _setDefaultFormValues() async {
    final today = DateFormat('dd/MM/yyyy').format(DateTime.now());

    // ✅ DB se next JNO lo
    final nextJno = await context.read<RoughProvider>().getNextJno();

    _formValues = {
      'roughDate': today,
      'dueDate': today,
      'roughMstID': '0',
      'jno': nextJno.toString(),
    };

    if (mounted) {
      setState(() {});
      // ✅ Form field bhi update karo
      Future.delayed(const Duration(milliseconds: 50), () {
        _erpFormKey.currentState?.updateFieldValue('jno', nextJno.toString());
      });
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  CALCULATIONS
  // ══════════════════════════════════════════════════════════════════════════
  double get _totalWt => _charniRows.fold(0.0, (s, r) => s + (r.wt ?? 0));

  void _recalcRates() {
    final ex = double.tryParse(_formValues['exRate'] ?? '') ?? 0;
    final rd = double.tryParse(_formValues['rateDollar'] ?? '') ?? 0;
    final wt = _totalWt;
    _formValues['rateRs'] = (ex * rd).toStringAsFixed(2);
    _formValues['amtDollar'] = (rd * wt).toStringAsFixed(2);
    _formValues['amtRs'] = (ex * rd * wt).toStringAsFixed(2);
  }

  void _recalcDueDate() {
    try {
      final base = DateFormat(
        'dd/MM/yyyy',
      ).parse(_formValues['roughDate'] ?? '');
      final days = int.tryParse(_formValues['dueDay'] ?? '') ?? 0;
      _formValues['dueDate'] = DateFormat(
        'dd/MM/yyyy',
      ).format(base.add(Duration(days: days)));
    } catch (_) {}
  }

  void _recalcCharniPer() {
    final tot = _totalWt;
    _charniRows = _charniRows.asMap().entries.map((e) {
      final per = tot > 0 ? (e.value.wt ?? 0) / tot * 100 : 0.0;
      return RoughDetModel(
        srno: e.value.srno,
        charniCode: e.value.charniCode,
        charniName: e.value.charniName,
        pc: e.value.pc,
        wt: e.value.wt,
        per: per,
      );
    }).toList();
  }

  void _pushCalcToForm() {
    _erpFormKey.currentState?.updateFieldValue('rateRs', _formValues['rateRs']);
    _erpFormKey.currentState?.updateFieldValue(
      'amtDollar',
      _formValues['amtDollar'],
    );
    _erpFormKey.currentState?.updateFieldValue('amtRs', _formValues['amtRs']);
    _erpFormKey.currentState?.updateFieldValue(
      'dueDate',
      _formValues['dueDate'],
    );
  }

  // ── Lookup helpers ─────────────────────────────────────────────────────────
  String _charniName(String? code) {
    if (code == null || code.isEmpty) return '';
    return context
            .read<CharniProvider>()
            .list
            .firstWhere(
              (e) => e.charniCode?.toString() == code,
              orElse: () => CharniModel(),
            )
            .charniName ??
        '';
  }

  String _stockTypeName(String? code) {
    if (code == null || code.isEmpty) return '';
    return context
            .read<StockTypeProvider>()
            .list
            .firstWhere(
              (e) => e.stockTypeCode?.toString() == code,
              orElse: () => StockTypeModel(),
            )
            .stockTypeName ??
        '';
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  CHARNI ENTRY — onEntryAdd(4) se call hota hai
  //  ErpForm: last entry field (charniWt) pe Enter → onEntryAdd(4)
  //  Header extraAction button pe bhi call hota hai
  // ══════════════════════════════════════════════════════════════════════════
  void _addCharniEntry() {
    // Required check
    for (final key in ['charniCode', 'charniWt']) {
      if ((_formValues[key] ?? '').trim().isEmpty) {
        _showSnack('${key == 'charniCode' ? 'Charni' : 'Weight'} required');
        _erpFormKey.currentState?.focusField(key);
        return;
      }
    }

    final code = _formValues['charniCode'] ?? '';
    final name = _charniName(code);
    final pc = int.tryParse(_formValues['charniPc'] ?? '');
    final wt = double.tryParse(_formValues['charniWt'] ?? '') ?? 0;

    setState(() {
      if (_editingCharniIndex != null) {
        // ── UPDATE existing row ─────────────────────────────────────────
        final idx = _editingCharniIndex!;
        _charniRows[idx] = RoughDetModel(
          srno: idx + 1,
          charniCode: int.tryParse(code),
          charniName: name,
          pc: pc,
          wt: wt,
          per: 0,
        );
        _editingCharniIndex = null;
      } else {
        // ── ADD new row ─────────────────────────────────────────────────
        final srno = _charniRows.length + 1;
        _charniRows.add(
          RoughDetModel(
            srno: srno,
            charniCode: int.tryParse(code),
            charniName: name,
            pc: pc,
            wt: wt,
            per: 0,
          ),
        );
      }
      _recalcCharniPer();
      _syncCharniGrid();
      _recalcRates();
    });
    _pushCalcToForm();
    _clearFields([
      'charniCode',
      'charniPc',
      'charniWt',
    ], focusFirst: 'charniCode');
  }

  // Edit: row data entry fields mein fill karo
  void _editCharniRow(int idx) {
    final row = _charniRows[idx];
    setState(() => _editingCharniIndex = idx);
    _erpFormKey.currentState?.updateFieldValue(
      'charniCode',
      row.charniCode?.toString(),
    );
    _erpFormKey.currentState?.updateFieldValue('charniPc', row.pc?.toString());
    _erpFormKey.currentState?.updateFieldValue(
      'charniWt',
      fThreeDecimal(row.wt),
    );
    _formValues['charniCode'] = row.charniCode?.toString() ?? '';
    _formValues['charniPc'] = row.pc?.toString() ?? '';
    _formValues['charniWt'] = fThreeDecimal(row.wt);
    Future.delayed(
      const Duration(milliseconds: 50),
      () => _erpFormKey.currentState?.focusField('charniCode'),
    );
  }

  void _deleteCharniRow(int idx) {
    setState(() {
      _charniRows.removeAt(idx);
      _charniEntryData.removeAt(idx);
      _charniRows = _charniRows
          .asMap()
          .entries
          .map(
            (e) => RoughDetModel(
              srno: e.key + 1,
              charniCode: e.value.charniCode,
              charniName: e.value.charniName,
              pc: e.value.pc,
              wt: e.value.wt,
              per: e.value.per,
            ),
          )
          .toList();
      _recalcCharniPer();
      _syncCharniGrid();
      _recalcRates();
      if (_editingCharniIndex == idx) _editingCharniIndex = null;
    });
    _pushCalcToForm();
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  PROCESS DAYS ENTRY — onEntryAdd(5) se call hota hai
  // ══════════════════════════════════════════════════════════════════════════
  void _addProcessDaysEntry() {
    if ((_formValues['stockTypeCode'] ?? '').trim().isEmpty) {
      _showSnack('Stock Type required');

      _erpFormKey.currentState?.focusField('stockTypeCode');
      return;
    }

    final code = _formValues['stockTypeCode'] ?? '';
    final name = _stockTypeName(code);

    final days = double.tryParse(_formValues['entryDays'] ?? '');

    // ✅ NEW VALIDATION
    if (days == null || days <= 0) {
      _showSnack('Days must be greater than 0');

      _erpFormKey.currentState?.focusField('entryDays');
      return;
    }

    setState(() {
      if (_editingProcessDaysIndex != null) {
        final idx = _editingProcessDaysIndex!;

        _processDaysRows[idx] = RoughProcessDaysModel(
          srno: idx + 1,
          stockTypeCode: int.tryParse(code),
          stockTypeName: name,
          days: days,
        );

        _editingProcessDaysIndex = null;
      } else {
        final srno = _processDaysRows.length + 1;

        _processDaysRows.add(
          RoughProcessDaysModel(
            srno: srno,
            stockTypeCode: int.tryParse(code),
            stockTypeName: name,
            days: days,
          ),
        );
      }

      _syncProcessDaysGrid();
    });

    _clearFields(['stockTypeCode', 'entryDays'], focusFirst: 'stockTypeCode');
  }

  void _editProcessDaysRow(int idx) {
    final row = _processDaysRows[idx];
    setState(() => _editingProcessDaysIndex = idx);
    _erpFormKey.currentState?.updateFieldValue(
      'stockTypeCode',
      row.stockTypeCode?.toString(),
    );
    _erpFormKey.currentState?.updateFieldValue(
      'entryDays',
      row.days?.toStringAsFixed(0),
    );
    _formValues['stockTypeCode'] = row.stockTypeCode?.toString() ?? '';
    _formValues['entryDays'] = row.days?.toStringAsFixed(0) ?? '';
    Future.delayed(
      const Duration(milliseconds: 50),
      () => _erpFormKey.currentState?.focusField('stockTypeCode'),
    );
  }

  void _deleteProcessDaysRow(int idx) {
    setState(() {
      _processDaysRows.removeAt(idx);
      _processDaysEntryData.removeAt(idx);
      _processDaysRows = _processDaysRows
          .asMap()
          .entries
          .map(
            (e) => RoughProcessDaysModel(
              srno: e.key + 1,
              stockTypeCode: e.value.stockTypeCode,
              stockTypeName: e.value.stockTypeName,
              days: e.value.days,
            ),
          )
          .toList();
      _syncProcessDaysGrid();
      if (_editingProcessDaysIndex == idx) _editingProcessDaysIndex = null;
    });
  }

  void _syncCharniGrid() {
    _charniEntryData = _charniRows
        .map(
          (r) => {
            'srno': r.srno?.toString() ?? '',
            'charniCode': r.charniCode?.toString() ?? '',
            'charniName': r.charniName ?? _charniName(r.charniCode?.toString()),
            'charniPc': r.pc?.toString() ?? '',
            'charniWt': fThreeDecimal(r.wt),
            'per': r.per?.toStringAsFixed(2) ?? '',
          },
        )
        .toList();
  }

  void _syncProcessDaysGrid() {
    _processDaysEntryData = _processDaysRows
        .map(
          (r) => {
            'srno': r.srno?.toString() ?? '',
            'stockTypeCode': r.stockTypeCode?.toString() ?? '',
            'stockTypeName':
                r.stockTypeName ?? _stockTypeName(r.stockTypeCode?.toString()),
            'entryDays': r.days?.toStringAsFixed(0) ?? '',
          },
        )
        .toList();
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  UTILS
  // ══════════════════════════════════════════════════════════════════════════
  void _clearFields(List<String> keys, {String? focusFirst}) {
    for (final k in keys) {
      _erpFormKey.currentState?.updateFieldValue(k, '');
      _formValues.remove(k);
    }
    if (focusFirst != null) {
      Future.delayed(
        const Duration(milliseconds: 50),
        () => _erpFormKey.currentState?.focusField(focusFirst),
      );
    }
  }

  void _showSnack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  // ══════════════════════════════════════════════════════════════════════════
  //  ROW TAP
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> _onRowTap(Map<String, dynamic> row) async {
    final raw = row['_raw'] as RoughModel;
    final provider = context.read<RoughProvider>();

    final results = await Future.wait([
      provider.loadDetails(raw.roughMstID!),
      provider.loadProcessDays(raw.roughMstID!),
    ]);
    final details = results[0] as List<RoughDetModel>;
    final processDays = results[1] as List<RoughProcessDaysModel>;
    if (!mounted) return;

    setState(() {
      _selectedRow = row;
      _selectedRough = raw;
      _isEditMode = true;
      _charniRows = details;
      _processDaysRows = processDays;
      _editingCharniIndex = null;
      _editingProcessDaysIndex = null;

      // Naya Map object → ErpForm.didUpdateWidget trigger hoga
      _formValues = {
        'roughMstID': raw.roughMstID?.toString() ?? '0',
        'roughDate': toDisplayDate(raw.roughDate),
        'jno': raw.jno?.toString() ?? '',
        'kapanNo': raw.kapanNo ?? '',
        'site': raw.site ?? '',
        'inv': raw.inv ?? '',
        'partyCode': raw.partyCode?.toString() ?? '',
        'roughTypeCode': raw.roughTypeCode?.toString() ?? '',
        'articalCode': raw.articalCode?.toString() ?? '',
        'jangadCharniCode': raw.jangadCharniCode?.toString() ?? '',
        'exRate': raw.exRate?.toStringAsFixed(2) ?? '',
        'rateDollar': raw.rateDollar?.toStringAsFixed(2) ?? '',
        'amtDollar': raw.amtDollar?.toStringAsFixed(2) ?? '',
        'rateRs': raw.rateRs?.toStringAsFixed(2) ?? '',
        'amtRs': raw.amtRs?.toStringAsFixed(2) ?? '',
        'rgExpPer': raw.rgExpPer?.toStringAsFixed(2) ?? '',
        'poExpPer': raw.poExpPer?.toStringAsFixed(2) ?? '',
        'rgSize': raw.rgSize?.toStringAsFixed(2) ?? '',
        'poSize': raw.poSize?.toStringAsFixed(2) ?? '',
        'lsPer': raw.lsPer?.toStringAsFixed(2) ?? '',
        'mainCutNo': raw.mainCutNo ?? '',
        'dueDay': raw.dueDay?.toString() ?? '',
        'dueDate': toDisplayDate(raw.dueDate),
        'remarks': raw.remarks ?? '',
      };

      _syncCharniGrid();
      _syncProcessDaysGrid();
      if (Responsive.isMobile(context)) _showTableOnMobile = false;
    });
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  SAVE
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> _onSave(Map<String, dynamic> values) async {
    final exists = await _checkDuplicate(
      fields: {'Jno': num.parse(values['jno'].toString())},
    );
    if (exists) return;
    final provider = context.read<RoughProvider>();

    String toIso(String? v) {
      if (v == null || v.isEmpty) return '';
      try {
        return DateFormat(
          'yyyy-MM-dd',
        ).format(DateFormat('dd/MM/yyyy').parse(v));
      } catch (_) {
        return v;
      }
    }

    final merged = Map<String, dynamic>.from(values);
    merged['rateRs'] = _formValues['rateRs'] ?? '0';
    merged['amtDollar'] = _formValues['amtDollar'] ?? '0';
    merged['amtRs'] = _formValues['amtRs'] ?? '0';
    merged['totWt'] = _totalWt.toStringAsFixed(2);
    merged['roughDate'] = toIso(merged['roughDate']?.toString());
    merged['dueDate'] = toIso(merged['dueDate']?.toString());
    // ✅ Edit mode mein current record exclude karo
    final isDuplicate = provider.isKapanDuplicate(
      values['kapanNo'],
      excludeMstID: _selectedRough?.roughMstID,
    );

    if (isDuplicate) {
      await ErpResultDialog.showError(
        context: context,
        theme: _theme,
        title: 'Duplicate Kapan No',
        message:
            'Kapan No "${values['kapanNo']}" already exists in Rough entry.\n'
            'Please enter a different Kapan No.',
      );
      Future.delayed(
        const Duration(milliseconds: 50),
        () => _erpFormKey.currentState?.focusField('kapanNo'),
      );
    } else if (_charniEntryData.isEmpty) {
      await ErpResultDialog.showError(
        context: context,
        theme: _theme,
        title: 'Charni Entry Required',
        message:
            'Charni entry is required to proceed.\n'
            'Please complete the Charni entry first.',
      );
    } else {
      // ─────────────────────────────
// ROUGH ASSORT WT VALIDATION
// ─────────────────────────────

      if (_isEditMode &&
          _selectedRough != null) {

        final usedWt =
        await provider.getUsedAssortWt(
          _selectedRough!.kapanNo ?? '',
        );

        final currentWt = _totalWt;

        if (currentWt < usedWt) {

          if (!mounted) return;

          await ErpResultDialog.showError(

            context: context,

            theme: _theme,

            title: 'Invalid Weight',

            message:
            '${usedWt.toStringAsFixed(3)} WT '
                'has already been entered in Rough Assort.\n\n'
                'Therefore, Total WT cannot be saved less than '
                '${usedWt.toStringAsFixed(3)}.',
          );

          return;
        }
      }


      bool success;
      if (_isEditMode && _selectedRough != null) {
        success = await provider.updateRough(
          _selectedRough!.roughMstID!,
          merged,
          _charniRows,
          _processDaysRows,
        );
      } else {
        success = await provider.createRough(
          merged,
          _charniRows,
          _processDaysRows,
        );
      }

      if (!mounted) return;
      if (success) {
        final wasEdit = _isEditMode;
        _resetForm();
        await _setDefaultFormValues();
        await ErpResultDialog.showSuccess(
          context: context,
          theme: _theme,
          title: wasEdit ? 'Updated' : 'Saved',
          message: wasEdit ? 'Rough entry updated.' : 'Rough entry saved.',
        );
      }
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  DELETE
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> _onDelete() async {
    if (_selectedRough?.roughMstID == null) return;
    final confirm = await ErpDeleteDialog.show(
      context: context,
      theme: _theme,
      title: 'Rough Entry',
      itemName: 'JNO: ${_selectedRough!.jno ?? ''}',
    );
    if (confirm != true || !mounted) return;
    final success = await context.read<RoughProvider>().deleteRough(
      _selectedRough!.roughMstID!,
      context
    );
    if (success && mounted) {
      final jno = _selectedRough?.jno;
      _resetForm();
      await _setDefaultFormValues();
      await ErpResultDialog.showDeleted(
        context: context,
        theme: _theme,
        itemName: 'Rough Entry ${jno ?? ''}',
      );
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  RESET
  // ══════════════════════════════════════════════════════════════════════════
  void _resetForm() {
    _erpFormKey.currentState?.resetForm();
    final today = DateFormat('dd/MM/yyyy').format(DateTime.now());
    setState(() {
      _selectedRow = null;
      _selectedRough = null;
      _isEditMode = false;
      _showTableOnMobile = false;
      _charniRows = [];
      _processDaysRows = [];
      _charniEntryData = [];
      _processDaysEntryData = [];
      _editingCharniIndex = null;
      _editingProcessDaysIndex = null;
      _formValues = {'roughDate': today, 'dueDate': today, 'roughMstID': '0'};
    });
    _setDefaultFormValues();
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Consumer<RoughProvider>(
      builder: (context, provider, _) => Padding(
        padding: const EdgeInsets.all(8),
        child: Responsive.isMobile(context)
            ? _showTableOnMobile
                  ? _buildTable(provider)
                  : _buildErpForm(context)
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildErpForm(context)),
                  const SizedBox(width: 12),
                  Expanded(flex: 2, child: _buildTable(provider)),
                ],
              ),
      ),
    );
  }

  // ── ErpForm ────────────────────────────────────────────────────────────────
  Widget _buildErpForm(BuildContext context) {
    final p = context.watch<PartyProvider>();
    final rt = context.watch<RoughTypeProvider>();
    final ar = context.watch<ArticleProvider>();
    final jc = context.watch<JangadCharaniProvider>();
    final st = context.watch<StockTypeProvider>();
    final ch = context.watch<CharniProvider>();

    return ErpForm(
      logo: AppImages.logo,
      key: _erpFormKey,
      isFullFormScrollable: true,
      sectionDetailBuilder: (ctx, sectionIndex) {
        final theme = ctx.erpTheme;

        if (sectionIndex == 4 && _charniEntryData.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: ErpEntryGrid(
              data: _charniEntryData,
              columns: _charniEntryKeys,
              title: 'CHARNI  |  Total Wt: ${fThreeDecimal(_totalWt)}',
              theme: theme,
              onDeleteRow: _isEditMode ? null : _deleteCharniRow,
              onEditRow: _editCharniRow,
              editingIndex: _editingCharniIndex,
            ),
          );
        }

        if (sectionIndex == 5 && _processDaysEntryData.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: ErpEntryGrid(
              data: _processDaysEntryData,
              columns: _processDaysEntryKeys,
              title: 'PROCESS DAYS',
              theme: theme,
              onDeleteRow: _deleteProcessDaysRow,
              onEditRow: _editProcessDaysRow,
              editingIndex: _editingProcessDaysIndex,
            ),
          );
        }

        return null; // other sections ke liye kuch nahi
      },
      title: 'ROUGH ENTRY',
      // subtitle: 'Transaction / Rough Stock Entry',
      tabBarBackgroundColor: const Color(0xfff2f0ef),
      tabBarSelectedColor: _theme.primaryGradient.first,
      tabBarSelectedTxtColor: Colors.white,
      rows: _formRows(p, rt, ar, jc, st, ch),
      initialValues: _formValues,
      isEditMode: _isEditMode,

      // ✅ KEY FIX: Last entry field pe Enter → onEntryAdd(sectionIndex)
      // ErpForm internally: last isEntryField ke TextField onSubmitted mein
      // widget.onEntryAdd?.call(sectionIndex) call hota hai
      onEntryAdd: (sectionIndex) {
        if (sectionIndex == 4) _addCharniEntry();
        if (sectionIndex == 5) _addProcessDaysEntry();
      },

      onFieldChanged: (key, value) {
        setState(() {
          _formValues[key] = value.toString();
          if (key == 'exRate' || key == 'rateDollar') {
            _recalcRates();
            _pushCalcToForm();
          }
          if (key == 'roughDate' || key == 'dueDay') {
            _recalcDueDate();
            _pushCalcToForm();
          }
        });
      },
      onExit: () {
        context.watch<TabProvider>().closeCurrentTab();
      },
      onSave: _onSave,
      onCancel: _resetForm,
      onDelete: _isEditMode ? _onDelete : null,
      onSearch: () => setState(() => _showTableOnMobile = true),
    );
  }

  Widget _buildTable(RoughProvider provider) {
    final partyNames = Map.fromEntries(
      context.read<PartyProvider>().list.map(
        (e) => MapEntry(e.partyCode?.toString() ?? '', e.partyName ?? ''),
      ),
    );
    final roughTypeNames = Map.fromEntries(
      context.read<RoughTypeProvider>().roughTypes.map(
        (e) =>
            MapEntry(e.roughTypeCode?.toString() ?? '', e.roughTypeName ?? ''),
      ),
    );
    final articleNames = Map.fromEntries(
      context.read<ArticleProvider>().list.map(
        (e) => MapEntry(e.articalCode?.toString() ?? '', e.articalName ?? ''),
      ),
    );
    final jangadCharniNames = Map.fromEntries(
      context.read<JangadCharaniProvider>().list.map(
        (e) => MapEntry(
          e.jangadCharniCode?.toString() ?? '',
          e.jangadCharniName ?? '',
        ),
      ),
    );
    return ErpDataTable(
      isReportRow: false,
      token: token ?? '',
      url: '',
      title: 'ROUGH ENTRY LIST',
      columns: _tableColumns,
      dateFilter: true,
      data: provider.tableDataWithNames(
        // ← CHANGED
        partyNames: partyNames,
        roughTypeNames: roughTypeNames,
        articleNames: articleNames,
        jangadCharniNames: jangadCharniNames,
      ),
      searchFields: const [
        ErpSearchFieldConfig(key: 'jno', label: 'JANGAD NO', width: 160),
        ErpSearchFieldConfig(key: 'kapanNo', label: 'KAPAN NO', width: 140),
        ErpSearchFieldConfig(key: 'inv', label: 'INVOICE', width: 140),
      ],
      showSearch: true,
      showFooterTotals: false,
      selectedRow: _selectedRow,
      onRowTap: _onRowTap,
      emptyMessage: provider.isLoaded ? 'No entries found' : 'Loading...',
    );
  }
}
