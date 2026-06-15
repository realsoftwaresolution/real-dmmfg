import 'package:diam_mfg/models/job_work_rec_model.dart';
import 'package:diam_mfg/providers/counter_provider.dart';
import 'package:diam_mfg/providers/dept_process_provider.dart';
import 'package:diam_mfg/providers/job_work_rec_entry_provider.dart';
import 'package:diam_mfg/utils/app_images.dart';
import 'package:diam_mfg/utils/constants.dart';
import 'package:diam_mfg/utils/delete_dialogue.dart';
import 'package:diam_mfg/utils/msg_dialogue.dart';
import 'package:erp_data_table/erp_data_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rs_dashboard/rs_dashboard.dart';
import '../models/user_visibility_model.dart';

class TrnJobWorkRecEntry extends StatefulWidget {
  const TrnJobWorkRecEntry({super.key});

  @override
  State<TrnJobWorkRecEntry> createState() => _TrnJobWorkRecEntryState();
}

class _TrnJobWorkRecEntryState extends State<TrnJobWorkRecEntry> {
  // ── Theme ──────────────────────────────────────────────────────────────────
  final ErpThemeVariant _themeVariant = ErpThemeVariant.frost;

  ErpTheme get _theme => ErpTheme(_themeVariant);

  // ── Form ───────────────────────────────────────────────────────────────────
  GlobalKey<ErpFormState> _erpFormKey = GlobalKey<ErpFormState>();
  Map<String, String> _formValues = {};
  final Map<String, String> _entryVals = {};

  // ── Auth ───────────────────────────────────────────────────────────────────
  final String? token = AppStorage.getString('token');

  // ── Selection state ────────────────────────────────────────────────────────
  Map<String, dynamic>? _selectedRow;

  // ── UI flags ───────────────────────────────────────────────────────────────
  bool _isEditMode = false;
  bool _isAdding = false;
  bool _showTableOnMobile = false;
  bool _isBCodePending = false;

  // ── Master form fields ─────────────────────────────────────────────────────
  int? _selectedPartyMstID;
  int? _selectedDeptProcessCode;

  // ── Detail rows ────────────────────────────────────────────────────────────
  List<JobWorkRecDetModel> _detRows = [];
  List<Map<String, dynamic>> _detDisplay = [];
  List<String> _activeDetColumns = [];

  // ── Display fields ────────────────────────────────────────────────────────
  List<UserVisibilityModel> _displayFields = [];
  int? _selectedDeptCode;

  @override
  void initState() {
    super.initState();
    _resetForm();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.wait([
        context.read<JobWorkRecEntryProvider>().load(),
        context.read<DeptProcessProvider>().load(),
        context.read<CounterProvider>().load(),
      ]);
      if (!mounted) return;
      _setDefaultFormValues();
    });
  }

  void _setDefaultFormValues() {
    final now = DateTime.now();
    _formValues = {'date': DateFormat('dd/MM/yyyy').format(now)};
    if (mounted) setState(() {});
  }

  void _focusScan() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (!mounted) return;

      try {
        _erpFormKey.currentState?.focusField('scanValue');
      } catch (_) {}
    });
  }

  Future<void> _onBCodeScanned(String bCode) async {
    if (_isBCodePending) return;
    _isBCodePending = true;

    final rows = await context.read<JobWorkRecEntryProvider>().fetchByBCode(
      partyMst: int.parse(_formValues['partyMstID']!),
      deptProcessCode: _selectedDeptCode.toString(),
      bCode: bCode,
    );

    if (!mounted) return;

    _isBCodePending = false;

    if (rows.isEmpty) {
      _showSnack('BCode "$bCode" not found!');
      _focusScan();
      return;
    }

    final r = rows.first;

    // ✅ Duplicate check
    final exists = _detRows.any(
      (e) => e.bCode?.toString() == r.bCode?.toString(),
    );

    if (exists) {
      _showSnack('BCode already exists!');
      _focusScan();
      return;
    }

    final newRow = JobWorkRecDetModel(
      jobWorkRecDetID: r.jobWorkRecDetID,
      jobWorkRecMstID: r.jobWorkRecMstID,
      jno: r.jno,
      srno: _detRows.length + 1,

      // Cut & Package Info
      cutNo: r.cutNo ?? '',
      mfgCut: r.mfgCut ?? r.cutNo ?? '',
      bCode: r.bCode ?? 0,
      pktNo: r.pktNo ?? '',
      pairNo: r.pairNo,

      // Pieces & Weight
      pc: r.pc ?? 0,
      wt: r.wt ?? 0.0,
      issPc: r.issPc ?? r.pc ?? 0,
      issWt: r.issWt ?? r.wt ?? 0.0,
      recPc: r.recPc,
      recWt: r.recWt,

      // Kapan / Breakage / Loss
      kPc: r.kPc,
      kWt: r.kWt,
      brPc: r.brPc,
      brWt: r.brWt,
      lossPc: r.lossPc,
      lossWt: r.lossWt,

      // Diamond Info
      purityCode: r.purityCode,
      charniCode: r.charniCode,
      colorCode: r.colorCode,
      shapeCode: r.shapeCode,

      purityName: r.purityName,
      charniName: r.charniName,
      colorName: r.colorName,
      shapeName: r.shapeName,

      dmWt: r.dmWt ?? 0.0,
      dmPer: r.dmPer ?? 0.0,

      // Percentages
      recPer: r.recPer,
      diffPer: r.diffPer,
      diffWt: r.diffWt,

      // Dimensions
      size: r.size ?? 0.0,
      cutCode: r.cutCode,
      diam: r.diam ?? 0.0,
      height: r.height,
      length: r.length ?? 0.0,

      // Quality
      polishCode: r.polishCode,
      symmetryCode: r.symmetryCode,
      fluoCode: r.fluoCode,
      tensionsCode: r.tensionsCode,

      qrCode: r.qrCode ?? '',

      cutName: r.cutName,
      polishName: r.polishName,
      symmetryName: r.symmetryName,
      fluoName: r.fluoName,

      // Status
      jobRec: r.jobRec,

      // IDs
      polishCheckerRecMstID: r.polishCheckerRecMstID,
      orderMstID: r.orderMstID,
      markerMstID: r.markerMstID,
      fromCrID: r.fromCrID,
      lastCrID: r.lastCrID,
      crID: r.crID,

      // FC Details
      topSide: r.topSide,
      fcIntentCode: r.fcIntentCode,
      fcOverCode: r.fcOverCode,
      fColorCode1: r.fColorCode1,
      fColorCode2: r.fColorCode2,

      // Other Details
      ha: r.ha,

      // Transaction Details
      jobWorkRecDate: r.jobWorkRecDate,
      partyMstID: r.partyMstID,
      deptCode: r.deptCode,
      deptProcessCode: r.deptProcessCode,
      sflag: r.sflag,
      sdate: r.sdate,
      logID: r.logID,
      pcID: r.pcID,
      ever: r.ever,
      time: r.time,

      // Names
      purity: r.purity,
      charni: r.charni,
      color: r.color,
      shape: r.shape,
      cut: r.cut,
      polish: r.polish,
      symmetry: r.symmetry,
      fluo: r.fluo,

      // Article Details
      articalName: r.articalName,
      articalCode: r.articalCode,

      // Rate Details
      rate: r.rate,
      amount: r.amount,
      rateID: r.rateID,
      rateon: r.rateon,

      // Message
      message: r.message,
    );

    setState(() {
      _detRows.add(newRow);
      _syncDetGrid();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      try {
        _erpFormKey.currentState?.updateFieldValue('scanValue', '');
        _erpFormKey.currentState?.focusField('scanValue');
      } catch (_) {}
    });
  }

  dynamic _deleteDetRow(int idx) async {
    final actualIdx = _detRows.length - 1 - idx;

    if (_isEditMode) {
      final confirm = await ErpDeleteDialog.show(
        context: context,
        theme: _theme,
        title: 'Job Work Issue',
        itemName: 'ID: ${_detRows[actualIdx].jobWorkRecDetID?.toString()}',
      );
      if (confirm != true || !mounted) return;

      final success = await context.read<JobWorkRecEntryProvider>().deleteRow(
        _detRows[actualIdx].jobWorkRecMstID ?? 0,
        _detRows[actualIdx].jobWorkRecDetID ?? 0,
        _detRows[actualIdx].bCode ?? 0,
        theme: _theme,
        context: context,
      );

      if (success && mounted) {
        setState(() {
          _detRows.removeAt(actualIdx);

          _detRows = _detRows.asMap().entries.map((e) {
            return e.value.copyWith(srno: e.key + 1);
          }).toList();

          _syncDetGrid();
        });

        await ErpResultDialog.showDeleted(
          context: context,
          theme: _theme,
          itemName: '1 row(s) deleted successfully',
        );
      }
    } else {
      setState(() {
        _detRows.removeAt(actualIdx);

        _detRows = _detRows.asMap().entries.map((e) {
          return e.value.copyWith(srno: e.key + 1);
        }).toList();

        _syncDetGrid();
      });
    }
    if (_detRows.isEmpty) {
      _resetForm();
    }
  }

  void _syncDetGrid() {
    _activeDetColumns = [
      'srno',
      'mfgCut',
      'qrCode',
      'bCode',
      'pktNo',
      'pairNo',
      'pc',
      'wt',
      'issPc',
      'issWt',
      'purityCode',
      'charniCode',
      'colorCode',
      'shapeCode',
      'dmWt',
      'dmPer',
      'size',
      'cutCode',
      'diam',
      'height',
      'length',
      'polishCode',
      'symmetryCode',
      'fluoCode',
    ];

    _detDisplay = _detRows.reversed
        .map(
          (r) => {
            'srno': r.srno?.toString() ?? '',
            'mfgCut': r.mfgCut ?? '',
            'qrCode': r.qrCode ?? '',
            'bCode': r.bCode?.toString() ?? '',
            'pktNo': r.pktNo ?? '',
            'pairNo': r.pairNo?.toString() ?? '',
            'pc': (r.pc ?? 0).toString(),
            'wt': fThreeDecimal(r.wt ?? 0),
            'issPc': (r.issPc ?? 0).toString(),
            'issWt': fThreeDecimal(r.issWt ?? 0),
            'purityCode': r.purityName ?? '',
            'charniCode': r.charniName ?? '',
            'colorCode': r.colorName ?? '',
            'shapeCode': r.shapeName ?? '',

            'cutCode': r.cutName ?? '',
            'polishCode': r.polishName ?? '',
            'symmetryCode': r.symmetryName ?? '',
            'fluoCode': r.fluoName ?? '',
            'dmWt': fThreeDecimal(r.dmWt ?? 0),
            'dmPer': (r.dmPer ?? 0).toStringAsFixed(2),
            'size': fThreeDecimal(r.size ?? 0),
            'diam': (r.diam ?? 0).toStringAsFixed(2),
            'height': (r.height ?? 0).toStringAsFixed(2),
            'length': (r.length ?? 0).toStringAsFixed(2),
          },
        )
        .toList();
  }

  String _s(dynamic v, [String def = '']) => v?.toString() ?? def;

  String _date(dynamic v) {
    if (v == null) return '';
    try {
      if (v is String && v.contains('/')) return v;
      final dt = DateTime.parse(v.toString());
      return DateFormat('dd/MM/yyyy').format(dt.toLocal());
    } catch (_) {
      return v.toString();
    }
  }

  Future<void> _onRowTap(Map<String, dynamic> row) async {
    final prov = context.read<JobWorkRecEntryProvider>();
    final id = int.tryParse(row['jobWorkRecMstID'].toString()) ?? 0;
    print(row);
    final details = await prov.loadDetails(id);

    if (!mounted) return;

    setState(() {
      _selectedRow = row;
      _isEditMode = true;
      _detRows = details;
      _isAdding = false;
      _showTableOnMobile = false;

      _formValues = {
        'date': _date(row['date']),
        'jobWorkRecMstID': _s(row['jobWorkRecMstID'], '0'),
        'partyMstID': _s(row['partyMstID'], '0'),
        'deptProcessCode': _s(row['deptProcessCode'], '0'),
        'scanValue': _s(_detRows.isNotEmpty ? _detRows.first.bCode : ''),
      };
      _selectedPartyMstID = int.tryParse(_formValues['partyMstID'] ?? '0');
      final counterProvider = context.read<CounterProvider>();

      try {
        final party = counterProvider.list.firstWhere(
          (e) => e.crId == _selectedPartyMstID,
        );

        _selectedDeptCode = party.deptCode;
      } catch (_) {
        _selectedDeptCode = null;
      }
      _selectedDeptProcessCode = int.tryParse(
        _formValues['deptProcessCode'] ?? '0',
      );
      _syncDetGrid();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      try {
        _erpFormKey.currentState?.focusField('scanValue');
      } catch (_) {}
    });
  }

  Future<void> _onSave(Map<String, dynamic> values) async {
    final prov = context.read<JobWorkRecEntryProvider>();

    if (_detRows.isEmpty) {
      await ErpResultDialog.showError(
        context: context,
        theme: _theme,
        title: 'No Entries',
        message: 'Please add at least one entry.',
      );
      return;
    }

    // ✅ BUILD PAYLOAD MATCHING NEW API STRUCTURE
    final payload = {
      "JobWorkRecDate": toUtcIso(_formValues['date']),
      "PartyMstID": int.tryParse(_formValues['partyMstID'] ?? '') ?? 0,
      "DeptCode": _selectedDeptCode ?? 0,
      "DeptProcessCode": _detRows.first.deptProcessCode ?? 0,
      "details": _detRows.map((r) {
        return {
          "Jno": r.jno ?? 0,
          "Srno": r.srno ?? 0,

          "CutNo": r.cutNo,
          "MfgCut": r.mfgCut,
          "BCode": r.bCode,
          "PktNo": r.pktNo,
          "PairNo": r.pairNo ?? 0,

          "Pc": r.pc,
          "Wt": r.wt,
          "IssPc": r.issPc,
          "IssWt": r.issWt,

          "RecPc": r.recPc ?? 0,
          "RecWt": r.recWt ?? 0.0,

          "KPc": r.kPc ?? 0,
          "KWt": r.kWt ?? 0.0,

          "BrPc": r.brPc ?? 0,
          "BrWt": r.brWt ?? 0.0,

          "LossPc": r.lossPc ?? 0,
          "LossWt": r.lossWt ?? 0.0,

          "PurityCode": r.purityCode ?? 0,
          "CharniCode": r.charniCode ?? 0,
          "ColorCode": r.colorCode ?? 0,
          "ShapeCode": r.shapeCode ?? 0,

          "DmWt": r.dmWt,
          "DmPer": r.dmPer,

          "Size": r.size,

          "CutCode": r.cutCode ?? 0,

          "Diam": r.diam,
          "Height": r.height ?? 0.0,
          "Length": r.length,

          "PolishCode": r.polishCode ?? 0,
          "SymmetryCode": r.symmetryCode ?? 0,
          "FluoCode": r.fluoCode ?? 0,
          "TensionsCode": r.tensionsCode ?? 0,

          "QRCode": r.qrCode,

          "RecPer": r.recPer ?? 0.0,
          "DiffPer": r.diffPer ?? 0.0,
          "DiffWt": r.diffWt ?? 0.0,

          "JobRec": r.jobRec ?? 'N',

          "PolishCheckerRecMstID": r.polishCheckerRecMstID ?? 0,
          "OrderMstID": r.orderMstID ?? 0,
          "MarkerMstID": r.markerMstID ?? 0,
          "FromCrID": r.fromCrID ?? 0,
          "LastCrID": r.lastCrID ?? 0,
          "CrID": r.crID ?? 0,

          "TopSide": r.topSide,
          "FcIntentCode": r.fcIntentCode ?? 0,
          "FcOverCode": r.fcOverCode ?? 0,
          "FColorCode1": r.fColorCode1 ?? 0,
          "FColorCode2": r.fColorCode2 ?? 0,

          "HA": r.ha ?? 'N',

          "Rate": r.rate ?? 0.0,
          "Amount": r.amount ?? 0.0,
          "RateID": r.rateID,
          "Rateon": r.rateon,
        };
      }).toList(),
    };

    bool success;
    if (_isEditMode) {
      final mstID = int.tryParse(_formValues['jobWorkRecMstID'] ?? '0') ?? 0;
      success = await prov.update(mstID, payload);
    } else {
      success = await prov.create(payload);
    }

    if (!mounted) return;

    if (success) {
      final wasEdit = _isEditMode;
      await ErpResultDialog.showSuccess(
        context: context,
        theme: _theme,
        title: wasEdit ? 'Updated' : 'Saved',
        message: wasEdit
            ? 'Job Work Rec updated successfully.'
            : 'Job Work Rec saved successfully.',
      );
      _resetForm();
      await prov.load();
    }
  }

  Future<void> _onDelete() async {
    if (_formValues['jobWorkRecMstID'] == null ||
        _formValues['jobWorkRecMstID'] == '0')
      return;

    final confirm = await ErpDeleteDialog.show(
      context: context,
      theme: _theme,
      title: 'Job Work Rec',
      itemName: 'ID: ${_formValues['jobWorkRecMstID'].toString()}',
    );
    if (confirm != true || !mounted) return;

    final mstID = int.tryParse(_formValues['jobWorkRecMstID'] ?? '0') ?? 0;
    final success = await context.read<JobWorkRecEntryProvider>().delete(
      mstID,
      theme: _theme,
      context: context,
      bCodeArray: _detRows
          .where((r) => r.bCode != 0)
          .map((r) => num.parse(r.bCode.toString()))
          .toList(),
    );

    if (success && mounted) {
      final id = _formValues['jobWorkRecMstID'].toString();
      _resetForm();
      await ErpResultDialog.showDeleted(
        context: context,
        theme: _theme,
        itemName: 'Job Work Rec $id',
      );
    }
  }

  void _resetForm() {
    FocusManager.instance.primaryFocus?.unfocus();

    try {
      _erpFormKey.currentState?.resetForm();
    } catch (_) {}

    _entryVals.clear();

    setState(() {
      _isEditMode = false;
      _showTableOnMobile = false;
      _isAdding = false;

      _detRows = [];
      _detDisplay = [];

      _selectedPartyMstID = null;
      _selectedDeptProcessCode = null;
      _selectedDeptCode = null;

      _displayFields.clear();

      _formValues.clear();
    });

    _setDefaultFormValues();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focusScan();
    });
  }

  void _showSnack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  List<List<ErpFieldConfig>> _buildFormRows() {
    final counterProvider = context.read<CounterProvider>();

    final List<List<ErpFieldConfig>> rows = [
      [
        ErpFieldConfig(
          key: 'date',
          label: 'DATE',
          type: ErpFieldType.date,
          readOnly: true,
          sectionIndex: 0,
          width: 250,
        ),
        ErpFieldConfig(
          key: 'partyMstID',
          label: 'PARTY',
          type: ErpFieldType.dropdown,
          sectionIndex: 0,
          required: true,
          readOnly: _detRows.isNotEmpty,
          dropdownItems: counterProvider.list
              .where((e) => e.active == true)
              .map(
                (e) => ErpDropdownItem(
                  label: e.crName ?? '',
                  value: e.crId?.toString() ?? '',
                ),
              )
              .toList(),
          width: 250,
        ),
        ErpFieldConfig(
          key: 'scanValue',
          label: 'BCODE',
          type: ErpFieldType.text,
          sectionIndex: 0,
          width: 250,
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

  List<ErpColumnConfig> get _tableColumns => [
    ErpColumnConfig(key: 'jobWorkRecMstID', label: 'ID', width: 120),
    ErpColumnConfig(key: 'date', label: 'DATE', width: 140, isDate: true),
    ErpColumnConfig(key: 'partyName', label: 'PARTY', width: 140),
    ErpColumnConfig(
      key: 'totalPc',
      label: 'PC',
      width: 140,
      align: ColumnAlign.right,
    ),
    ErpColumnConfig(
      key: 'totalWt',
      label: 'WT',
      width: 120,
      align: ColumnAlign.right,
    ),
  ];

  String _colLabel(String key) {
    const labels = {
      'srno': 'SR NO',
      'mfgCut': 'MFG CUT',
      'qrCode': 'QR CODE',
      'bCode': 'BCODE',
      'pktNo': 'PKT NO',
      'pairNo': 'PAIR NO',
      'pc': 'PC',
      'wt': 'WT',
      'issPc': 'ISS PC',
      'issWt': 'ISS WT',
      'purityCode': 'PURITY',
      'charniCode': 'CHARNI',
      'colorCode': 'COLOR',
      'shapeCode': 'SHAPE',
      'dmWt': 'DM WT',
      'dmPer': 'DM %',
      'size': 'SIZE',
      'cutCode': 'CUT',
      'diam': 'DIAM',
      'height': 'HEIGHT',
      'length': 'LENGTH',
      'polishCode': 'POLISH',
      'symmetryCode': 'SYMMETRY',
      'fluoCode': 'FLUO',
    };
    return labels[key] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<JobWorkRecEntryProvider>(
      builder: (ctx, prov, _) => Padding(
        padding: const EdgeInsets.all(8),
        child: Responsive.isMobile(context)
            ? (_showTableOnMobile ? _buildTable(prov) : _buildForm(context))
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!_showTableOnMobile)
                    Expanded(flex: 2, child: _buildForm(context)),
                  if (_showTableOnMobile)
                    Expanded(flex: 2, child: _buildTable(prov)),
                ],
              ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return ErpForm(
      key: _erpFormKey,
      isShowSearch: true,
      autoStartAdding: _isAdding,
      logo: AppImages.logo,
      title: 'JOB WORK REC ENTRY',
      tabBarBackgroundColor: const Color(0xfff2f0ef),
      tabBarSelectedColor: _theme.primaryGradient.first,
      tabBarSelectedTxtColor: Colors.white,
      rows: _buildFormRows(),
      initialValues: _formValues,
      isEditMode: _isEditMode,
      onFieldChanged: (key, value) {
        _formValues[key] = value.toString();
        switch (key) {
          case 'deptProcessCode':
            _selectedDeptProcessCode = int.tryParse(value.toString());
            break;
          case 'partyMstID':
            _selectedPartyMstID = int.tryParse(value.toString());

            final counterProvider = context.read<CounterProvider>();

            final party = counterProvider.list.firstWhere(
              (e) => e.crId == _selectedPartyMstID,
            );

            setState(() {
              _selectedDeptCode = party.deptCode;

              _selectedDeptProcessCode = null;

              _formValues['deptProcessCode'] = '';
            });

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;

              try {
                _erpFormKey.currentState?.updateFieldValue(
                  'deptProcessCode',
                  '',
                );
              } catch (_) {}
            });
            break;
          default:
            break;
        }
      },
      onFieldSubmitted: (key, value) async {
        if (key != 'scanValue') return;

        FocusManager.instance.primaryFocus?.unfocus();

        final scanVal = value.toString().trim();

        if (scanVal.isEmpty) {
          _focusScan();
          return;
        }

        await _onBCodeScanned(scanVal);
      },
      isShowPrintButton: false,
      onExit: () => context.read<TabProvider>().closeCurrentTab(),
      onSave: _onSave,
      isShowSaveButton: !_isEditMode,
      onCancel: _resetForm,
      onDelete: _isEditMode ? _onDelete : null,
      onSearch: () => setState(() => _showTableOnMobile = true),
      detailBuilder: (ctx) {
        final t = ctx.erpTheme;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_detRows.isNotEmpty)
              ErpEntryGrid(
                data: _detDisplay,
                columns: _activeDetColumns,
                title: 'JOB WORK DETAILS',
                theme: t,
                onDeleteRow: _deleteDetRow,
                columnLabels: {
                  for (final c in _activeDetColumns) c: _colLabel(c),
                },
                columnWidths: const {'srno': 40, 'mfgCut': 120},
                footerTotCount: 'Tot: ${_detRows.length}',
                footerTotals: _buildFooterTotals(),
              ),
          ],
        );
      },
    );
  }

  Map<String, String> _buildFooterTotals() {
    double sumDouble(double Function(JobWorkRecDetModel) fn) =>
        _detRows.fold(0.0, (s, r) => s + fn(r));

    int sumInt(int Function(JobWorkRecDetModel) fn) =>
        _detRows.fold(0, (s, r) => s + fn(r));

    final totPc = sumInt((r) => r.pc ?? 0);
    final totWt = sumDouble((r) => r.wt ?? 0);
    final totIssPc = sumInt((r) => r.issPc ?? 0);
    final totIssWt = sumDouble((r) => r.issWt ?? 0);
    final totDmWt = sumDouble((r) => r.dmWt ?? 0);
    final dmPer = sumDouble((r) => r.dmPer ?? 0);

    return {
      'srno': 'Tot...',
      'pc': '$totPc',
      'wt': fThreeDecimal(totWt),
      'issPc': '$totIssPc',
      'issWt': fThreeDecimal(totIssWt),
      'dmWt': fThreeDecimal(totDmWt),
      'dmPer': dmPer.toStringAsFixed(2),
    };
  }

  String _formatDate(String? value) {
    if (value == null || value.isEmpty) return '';
    try {
      final dt = DateTime.parse(value).toLocal();
      return DateFormat('dd/MM/yyyy').format(dt);
    } catch (_) {
      return value;
    }
  }

  Widget _buildTable(JobWorkRecEntryProvider prov) {
    final data = prov.list.map((e) {
      return {
        'jobWorkRecMstID': e.jobWorkRecMstID?.toString() ?? '',
        'date': _formatDate(e.jobWorkRecDate),
        'time': e.time ?? '',
        'partyName': e.partyName ?? '',
        'deptProcessCode': e.deptProcessCode,
        'deptProcessName': e.deptProcessName ?? '',
        'jno': (e.jno ?? 0).toString(),
        'pkt': (e.pkt ?? 0).toString(),
        'totalPc': (e.totalPc ?? 0).toString(),
        'totalWt': fThreeDecimal(e.totalWt ?? 0),
        'issPc': (e.issPc ?? 0).toString(),
        'totalDmWt': fThreeDecimal(e.totalDmWt ?? 0),
        'totalDmPer': (e.totalDmPer ?? 0).toStringAsFixed(2),
      };
    }).toList();

    return ErpDataTable(
      isReportRow: false,
      token: token ?? '',
      url: '',
      title: 'JOB WORK REC LIST',
      columns: _tableColumns,
      data: data,
      showSearch: true,
      dateFilter: true,
      onClose: () {
        setState(() {
          _showTableOnMobile = false;
        });
      },
      selectedRow: _selectedRow,
      onRowTap: _onRowTap,
      emptyMessage: prov.isLoaded ? 'No entries found' : 'Loading...',
    );
  }
}
