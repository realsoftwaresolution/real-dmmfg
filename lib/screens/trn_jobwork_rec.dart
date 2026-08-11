import 'package:diam_mfg/models/job_work_rec_model.dart';
import 'package:diam_mfg/providers/charni_provider.dart';
import 'package:diam_mfg/providers/color_provider.dart';
import 'package:diam_mfg/providers/counter_provider.dart';
import 'package:diam_mfg/providers/cut_provider.dart';
import 'package:diam_mfg/providers/dept_process_provider.dart';
import 'package:diam_mfg/providers/dept_provider.dart';
import 'package:diam_mfg/providers/fColor_provider.dart';
import 'package:diam_mfg/providers/fluo_provider.dart';
import 'package:diam_mfg/providers/intent_provider.dart';
import 'package:diam_mfg/providers/job_work_rec_entry_provider.dart';
import 'package:diam_mfg/providers/over_provider.dart';
import 'package:diam_mfg/providers/polish_provider.dart';
import 'package:diam_mfg/providers/purity_provider.dart';
import 'package:diam_mfg/providers/shape_provider.dart';
import 'package:diam_mfg/providers/symmetry_provider.dart';
import 'package:diam_mfg/providers/tensions_provider.dart';
import 'package:diam_mfg/utils/app_images.dart';
import 'package:diam_mfg/utils/constants.dart';
import 'package:diam_mfg/utils/delete_dialogue.dart';
import 'package:diam_mfg/utils/msg_dialogue.dart';
import 'package:diam_mfg/utils/process_constants.dart';
import 'package:erp_data_table/erp_data_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rs_dashboard/rs_dashboard.dart';

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
  final GlobalKey<ErpFormState> _erpFormKey = GlobalKey<ErpFormState>();
  Map<String, String> _formValues = {};
  final Map<String, String> _entryVals = {};
  final Map<String, dynamic> _pickedMediaFiles = {};
  final Map<String, bool> _mediaUpdatedFlags = {};

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
  int? _selectedDeptCode;

  // ── Detail rows ────────────────────────────────────────────────────────────
  List<JobWorkRecDetModel> _detRows = [];
  List<Map<String, dynamic>> _detDisplay = [];
  List<String> _activeDetColumns = [];
  int? _editingDetIndex;
  JobWorkRecDetModel? _scannedRow;
  int _maxSrNo = 0;

  int _parseSrno(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    if (val is num) return val.toInt();
    return int.tryParse(val.toString()) ?? 0;
  }

  void _updateMaxSrNo([List<JobWorkRecDetModel>? rows]) {
    final list = rows ?? _detRows;
    for (final r in list) {
      final s = _parseSrno(r.srno);
      if (s > _maxSrNo) {
        _maxSrNo = s;
      }
    }
  }

  // ── LOOKUP HELPERS ─────────────────────────────────────────────────────────
  String? _purityNameFor(int? code) {
    if (code == null) return null;
    try {
      return context
          .read<PurityProvider>()
          .list
          .firstWhere((p) => p.purityCode.toString() == code.toString())
          .purityName;
    } catch (_) {
      return null;
    }
  }

  String? _charniNameFor(int? code) {
    if (code == null) return null;
    try {
      return context
          .read<CharniProvider>()
          .list
          .firstWhere((p) => p.charniCode.toString() == code.toString())
          .charniName;
    } catch (_) {
      return null;
    }
  }

  String? _colorNameFor(int? code) {
    if (code == null) return null;
    try {
      return context
          .read<ColorProvider>()
          .list
          .firstWhere((p) => p.colorCode.toString() == code.toString())
          .colorName;
    } catch (_) {
      return null;
    }
  }

  String? _shapeNameFor(int? code) {
    if (code == null) return null;
    try {
      return context
          .read<ShapeProvider>()
          .list
          .firstWhere((p) => p.shapeCode.toString() == code.toString())
          .shapeName;
    } catch (_) {
      return null;
    }
  }

  String? _cutNameFor(int? code) {
    if (code == null) return null;
    try {
      return context
          .read<CutProvider>()
          .cuts
          .firstWhere((p) => p.cutCode.toString() == code.toString())
          .cutName;
    } catch (_) {
      return null;
    }
  }

  String? _polishNameFor(int? code) {
    if (code == null) return null;
    try {
      return context
          .read<PolishProvider>()
          .polishs
          .firstWhere((p) => p.polishCode.toString() == code.toString())
          .polishName;
    } catch (_) {
      return null;
    }
  }

  String? _symmetryNameFor(int? code) {
    if (code == null) return null;
    try {
      return context
          .read<SymmetryProvider>()
          .symmetrys
          .firstWhere((p) => p.symmetryCode.toString() == code.toString())
          .symmetryName;
    } catch (_) {
      return null;
    }
  }

  String? _fluoNameFor(int? code) {
    if (code == null) return null;
    try {
      return context
          .read<FluoProvider>()
          .list
          .firstWhere((p) => p.fluoCode.toString() == code.toString())
          .fluoName;
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _resetForm();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.wait([
        context.read<JobWorkRecEntryProvider>().load(),
        context.read<DeptProcessProvider>().load(),
        context.read<CounterProvider>().load(),
        context.read<CharniProvider>().load(),
        context.read<TensionsProvider>().load(),
        context.read<ShapeProvider>().load(),
        context.read<PurityProvider>().load(),
        context.read<ColorProvider>().load(),
        context.read<CutProvider>().loadCuts(),
        context.read<FluoProvider>().load(),
        context.read<SymmetryProvider>().loadSymmetry(),
        context.read<PolishProvider>().loadPolish(),
        context.read<FColorProvider>().loadColors(),
        context.read<OverProvider>().loadOvers(),
        context.read<IntentProvider>().loadIntents(),
        context.read<DeptProvider>().load(),
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

  void _calcLoss() {
    final issWt = double.tryParse(_entryVals['issWt'] ?? '') ?? 0;
    final recWt = double.tryParse(_entryVals['recWt'] ?? '') ?? 0;
    final kWt = double.tryParse(_entryVals['kWt'] ?? '') ?? 0;
    final brWt = double.tryParse(_entryVals['brWt'] ?? '') ?? 0;

    final issPc = int.tryParse(_entryVals['issPc'] ?? '') ?? 0;
    final recPc = int.tryParse(_entryVals['recPc'] ?? '') ?? 0;
    final kPc = int.tryParse(_entryVals['kPc'] ?? '') ?? 0;
    final brPc = int.tryParse(_entryVals['brPc'] ?? '') ?? 0;

    final lossWt = issWt - (recWt + kWt + brWt);
    final lossPc = issPc - (recPc + kPc + brPc);

    final double safeLossWt = lossWt < 0 ? 0.0 : lossWt;
    final safeLossPc = lossPc < 0 ? 0 : lossPc;

    _entryVals['lossWt'] = fThreeDecimal(safeLossWt);
    _entryVals['lossPc'] = '$safeLossPc';

    try {
      _erpFormKey.currentState?.updateFieldValue(
        'lossWt',
        fThreeDecimal(safeLossWt),
      );
      _erpFormKey.currentState?.updateFieldValue('lossPc', '$safeLossPc');
    } catch (_) {}
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

    // Duplicate check
    final exists = _detRows.any(
          (e) => e.bCode.toString() == r.bCode.toString(),
    );

    if (exists) {
      _showSnack('BCode already exists!');
      _focusScan();
      return;
    }

    final newRow = JobWorkRecDetModel(
      jobWorkRecDetID: r.jobWorkRecDetID,
      jobWorkRecMstID: r.jobWorkRecMstID,
      jobWorkIssMstID: r.jobWorkIssMstID,
      jno: r.jno,
      srno: _maxSrNo + 1,

      // Cut & Package Info
      cutNo: r.cutNo,
      mfgCut: r.mfgCut,
      bCode: r.bCode,
      pktNo: r.pktNo,
      pairNo: r.pairNo,

      // Pieces & Weight
      pc: r.pc,
      wt: r.wt,
      issPc: r.issPc != 0 ? r.issPc : r.pc,
      issWt: r.issWt != 0.0 ? r.issWt : r.wt,
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

      dmWt: r.dmWt,
      dmPer: r.dmPer,

      // Percentages
      recPer: r.recPer,
      diffPer: r.diffPer,
      diffWt: r.diffWt,

      // Dimensions
      size: r.size,
      cutCode: r.cutCode,
      diam: r.diam,
      height: r.height,
      length: r.length,

      // Quality
      polishCode: r.polishCode,
      symmetryCode: r.symmetryCode,
      fluoCode: r.fluoCode,
      tensionsCode: r.tensionsCode,

      qrCode: r.qrCode,

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
      _scannedRow = newRow;
      _editingDetIndex = null;
    });

    _loadRowIntoFields(newRow);
  }

  void _loadRowIntoFields(JobWorkRecDetModel r) {
    _pickedMediaFiles.clear();
    _mediaUpdatedFlags.clear();

    void set(String k, String? v) {
      _entryVals[k] = v ?? '';
      _formValues[k] = v ?? '';
      try {
        _erpFormKey.currentState?.updateFieldValue(k, v ?? '');
      } catch (_) {}
    }

    set('scanValue', r.bCode.toString());
    set('qrCode', r.qrCode);
    set('jno', r.jno?.toString());
    set('mfgCut', r.mfgCut);
    set('pktNo', r.pktNo);
    set('orgPc', r.pc.toString());
    set('orgWt', fThreeDecimal(r.wt));
    set('issPc', r.issPc.toString());
    set('issWt', fThreeDecimal(r.issWt));
    set('recPc', r.recPc?.toString());
    set('recWt', r.recWt != null ? fThreeDecimal(r.recWt!) : '');
    set('kPc', r.kPc?.toString());
    set('kWt', r.kWt != null ? fThreeDecimal(r.kWt!) : '');
    set('brPc', r.brPc?.toString());
    set('brWt', r.brWt != null ? fThreeDecimal(r.brWt!) : '');
    set('lossPc', r.lossPc?.toString());
    set('lossWt', r.lossWt != null ? fThreeDecimal(r.lossWt!) : '');
    set('dmWt', fThreeDecimal(r.dmWt));
    set('dmPer', r.dmPer.toStringAsFixed(2));
    set('size', fThreeDecimal(r.size));
    set('purity', r.purityCode?.toString());
    set('charni', r.charniCode?.toString());
    set('color', r.colorCode?.toString());
    set('shapeCode', r.shapeCode?.toString());
    set('cutCode', r.cutCode?.toString());
    set('polishCode', r.polishCode?.toString());
    set('symmetryCode', r.symmetryCode?.toString());
    set('fluo', r.fluoCode?.toString());
    set('tensionCode', r.tensionsCode?.toString());
    set('FcIntentCode', r.fcIntentCode?.toString());
    set('FColorCode1', r.fColorCode1?.toString());
    set('FColorCode2', r.fColorCode2?.toString());
    set('FcOverCode', r.fcOverCode?.toString());
    set('TopSide', r.topSide);
    set('HA', r.ha);
    set('diam', r.diam.toString());
    set('height', r.height?.toString());
    set('length', r.length.toString());
    set('pairNo', r.pairNo?.toString());
  }

  void _editDetRow(int idx) {
    final actualIdx = _detRows.length - 1 - idx;
    if (actualIdx < 0 || actualIdx >= _detRows.length) return;
    setState(() {
      _editingDetIndex = actualIdx;
      _scannedRow = null;
    });
    _loadRowIntoFields(_detRows[actualIdx]);
  }

  void _updateEditedRow() {
    if (_editingDetIndex == null ||
        _editingDetIndex! < 0 ||
        _editingDetIndex! >= _detRows.length) {
      return;
    }

    final existing = _detRows[_editingDetIndex!];

    final purityCode = int.tryParse(_entryVals['purity'] ?? '');
    final charniCode = int.tryParse(_entryVals['charni'] ?? '');
    final colorCode = int.tryParse(_entryVals['color'] ?? '');
    final shapeCode = int.tryParse(_entryVals['shapeCode'] ?? '');
    final cutCode = int.tryParse(_entryVals['cutCode'] ?? '');
    final polishCode = int.tryParse(_entryVals['polishCode'] ?? '');
    final symmetryCode = int.tryParse(_entryVals['symmetryCode'] ?? '');
    final fluoCode = int.tryParse(_entryVals['fluo'] ?? '');
    final tensionsCode = int.tryParse(_entryVals['tensionCode'] ?? '');

    final updated = existing.copyWith(
      recPc: int.tryParse(_entryVals['recPc'] ?? ''),
      recWt: double.tryParse(_entryVals['recWt'] ?? ''),
      kPc: int.tryParse(_entryVals['kPc'] ?? ''),
      kWt: double.tryParse(_entryVals['kWt'] ?? ''),
      brPc: int.tryParse(_entryVals['brPc'] ?? ''),
      brWt: double.tryParse(_entryVals['brWt'] ?? ''),
      lossPc: int.tryParse(_entryVals['lossPc'] ?? ''),
      lossWt: double.tryParse(_entryVals['lossWt'] ?? ''),
      dmWt: double.tryParse(_entryVals['dmWt'] ?? ''),
      dmPer: double.tryParse(_entryVals['dmPer'] ?? ''),
      size: double.tryParse(_entryVals['size'] ?? ''),
      diam: double.tryParse(_entryVals['diam'] ?? ''),
      height: double.tryParse(_entryVals['height'] ?? ''),
      length: double.tryParse(_entryVals['length'] ?? ''),
      pairNo: _entryVals['pairNo'] ?? '',
      purityCode: purityCode,
      charniCode: charniCode,
      colorCode: colorCode,
      shapeCode: shapeCode,
      cutCode: cutCode,
      polishCode: polishCode,
      symmetryCode: symmetryCode,
      fluoCode: fluoCode,
      tensionsCode: tensionsCode,
      topSide: _entryVals['TopSide'],
      fcIntentCode: int.tryParse(_entryVals['FcIntentCode'] ?? ''),
      fcOverCode: int.tryParse(_entryVals['FcOverCode'] ?? ''),
      fColorCode1: int.tryParse(_entryVals['FColorCode1'] ?? ''),
      fColorCode2: int.tryParse(_entryVals['FColorCode2'] ?? ''),
      ha: _entryVals['HA'],
      rate: double.tryParse(_entryVals['rate'] ?? ''),
      amount: double.tryParse(_entryVals['amount'] ?? ''),
      purityName: _purityNameFor(purityCode) ?? existing.purityName,
      charniName: _charniNameFor(charniCode) ?? existing.charniName,
      colorName: _colorNameFor(colorCode) ?? existing.colorName,
      shapeName: _shapeNameFor(shapeCode) ?? existing.shapeName,
      cutName: _cutNameFor(cutCode) ?? existing.cutName,
      polishName: _polishNameFor(polishCode) ?? existing.polishName,
      symmetryName: _symmetryNameFor(symmetryCode) ?? existing.symmetryName,
      fluoName: _fluoNameFor(fluoCode) ?? existing.fluoName,
    );

    setState(() {
      _detRows[_editingDetIndex!] = updated;
      _syncDetGrid();
    });
  }

  void _clearEntryFields() {
    const keys = [
      'scanValue',
      'qrCode',
      'jno',
      'mfgCut',
      'pktNo',
      'orgPc',
      'orgWt',
      'issPc',
      'issWt',
      'recPc',
      'recWt',
      'kPc',
      'kWt',
      'brPc',
      'brWt',
      'lossPc',
      'lossWt',
      'dmWt',
      'dmPer',
      'size',
      'purity',
      'charni',
      'color',
      'shapeCode',
      'cutCode',
      'polishCode',
      'symmetryCode',
      'fluo',
      'tensionCode',
      'FcIntentCode',
      'FColorCode1',
      'FColorCode2',
      'FcOverCode',
      'TopSide',
      'HA',
      'diam',
      'height',
      'length',
      'pairNo',
      'rate',
      'amount',
      'certificate',
      'Certificate',
      'images',
      'Images',
      'videoAttachment',
      'videoattachment',
      'video',
      'Video',
    ];

    for (final k in keys) {
      _entryVals.remove(k);
      _formValues.remove(k);
      try {
        _erpFormKey.currentState?.updateFieldValue(k, null);
      } catch (_) {}
      try {
        _erpFormKey.currentState?.updateFieldValue(k, '');
      } catch (_) {}
    }

    _pickedMediaFiles.clear();
    _mediaUpdatedFlags.clear();

    setState(() {
      _editingDetIndex = null;
      _scannedRow = null;
    });

    _focusScan();
  }

  Future<bool> _uploadPendingMedia(
      JobWorkRecEntryProvider prov,
      String bCodeStr,
      ) async {
    bool hasFile(dynamic val) {
      if (val == null) return false;
      if (val is List) return val.isNotEmpty;
      if (val is String) {
        final s = val.trim();
        return s.isNotEmpty && s != 'null' && s != '[]';
      }
      return true;
    }

    dynamic getMediaValue(List<String> keys) {
      for (final k in keys) {
        final val = _pickedMediaFiles[k] ?? _pickedMediaFiles[k.toLowerCase()];
        if (hasFile(val)) return val;
      }
      for (final k in keys) {
        final val = _entryVals[k] ?? _formValues[k];
        if (hasFile(val)) return val;
      }
      return null;
    }

    // 1. CERTIFICATE Upload
    final certVal = getMediaValue(['certificate', 'Certificate', 'CERTIFICATE', 'certi']);
    if (hasFile(certVal)) {
      final ok = await prov.uploadMedia(
        bCode: bCodeStr,
        mediaType: 'CERTIFICATE',
        fileVal: certVal,
        theme: _theme,
        context: context,
      );
      if (!ok) return false;
    }

    // 2. IMAGE Upload
    final imgVal = getMediaValue(['images', 'Images', 'IMAGES', 'image', 'Image', 'IMAGE']);
    if (hasFile(imgVal)) {
      final ok = await prov.uploadMedia(
        bCode: bCodeStr,
        mediaType: 'IMAGE',
        fileVal: imgVal,
        theme: _theme,
        context: context,
      );
      if (!ok) return false;
    }

    // 3. VIDEO Upload
    final videoVal = getMediaValue(['videoAttachment', 'videoattachment', 'VideoAttachment', 'VIDEOATTACHMENT', 'video', 'Video', 'VIDEO']);
    if (hasFile(videoVal)) {
      final ok = await prov.uploadMedia(
        bCode: bCodeStr,
        mediaType: 'VIDEO',
        fileVal: videoVal,
        theme: _theme,
        context: context,
      );
      if (!ok) return false;
    }

    return true;
  }

  Future<void> _onAddEntry() async {
    JobWorkRecDetModel? r;

    if (_editingDetIndex != null &&
        _editingDetIndex! >= 0 &&
        _editingDetIndex! < _detRows.length) {
      _updateEditedRow();
      r = _detRows[_editingDetIndex!];
    } else if (_scannedRow != null) {
      final purityCode = int.tryParse(_entryVals['purity'] ?? '');
      final charniCode = int.tryParse(_entryVals['charni'] ?? '');
      final colorCode = int.tryParse(_entryVals['color'] ?? '');
      final shapeCode = int.tryParse(_entryVals['shapeCode'] ?? '');
      final cutCode = int.tryParse(_entryVals['cutCode'] ?? '');
      final polishCode = int.tryParse(_entryVals['polishCode'] ?? '');
      final symmetryCode = int.tryParse(_entryVals['symmetryCode'] ?? '');
      final fluoCode = int.tryParse(_entryVals['fluo'] ?? '');
      final tensionsCode = int.tryParse(_entryVals['tensionCode'] ?? '');

      final currentScannedSrno = _parseSrno(_scannedRow!.srno);
      int targetSrno = currentScannedSrno > 0 ? currentScannedSrno : (_maxSrNo + 1);
      if (targetSrno <= _maxSrNo) {
        targetSrno = _maxSrNo + 1;
      }
      if (targetSrno > _maxSrNo) {
        _maxSrNo = targetSrno;
      }

      r = _scannedRow!.copyWith(
        srno: targetSrno,
        recPc: int.tryParse(_entryVals['recPc'] ?? ''),
        recWt: double.tryParse(_entryVals['recWt'] ?? ''),
        kPc: int.tryParse(_entryVals['kPc'] ?? ''),
        kWt: double.tryParse(_entryVals['kWt'] ?? ''),
        brPc: int.tryParse(_entryVals['brPc'] ?? ''),
        brWt: double.tryParse(_entryVals['brWt'] ?? ''),
        lossPc: int.tryParse(_entryVals['lossPc'] ?? ''),
        lossWt: double.tryParse(_entryVals['lossWt'] ?? ''),
        dmWt: double.tryParse(_entryVals['dmWt'] ?? ''),
        dmPer: double.tryParse(_entryVals['dmPer'] ?? ''),
        size: double.tryParse(_entryVals['size'] ?? ''),
        diam: double.tryParse(_entryVals['diam'] ?? ''),
        height: double.tryParse(_entryVals['height'] ?? ''),
        length: double.tryParse(_entryVals['length'] ?? ''),
        pairNo: _entryVals['pairNo'] ?? '',
        purityCode: purityCode,
        charniCode: charniCode,
        colorCode: colorCode,
        shapeCode: shapeCode,
        cutCode: cutCode,
        polishCode: polishCode,
        symmetryCode: symmetryCode,
        fluoCode: fluoCode,
        tensionsCode: tensionsCode,
        topSide: _entryVals['TopSide'],
        fcIntentCode: int.tryParse(_entryVals['FcIntentCode'] ?? ''),
        fcOverCode: int.tryParse(_entryVals['FcOverCode'] ?? ''),
        fColorCode1: int.tryParse(_entryVals['FColorCode1'] ?? ''),
        fColorCode2: int.tryParse(_entryVals['FColorCode2'] ?? ''),
        ha: _entryVals['HA'],
        rate: double.tryParse(_entryVals['rate'] ?? ''),
        amount: double.tryParse(_entryVals['amount'] ?? ''),
        purityName: _purityNameFor(purityCode) ?? _scannedRow!.purityName,
        charniName: _charniNameFor(charniCode) ?? _scannedRow!.charniName,
        colorName: _colorNameFor(colorCode) ?? _scannedRow!.colorName,
        shapeName: _shapeNameFor(shapeCode) ?? _scannedRow!.shapeName,
        cutName: _cutNameFor(cutCode) ?? _scannedRow!.cutName,
        polishName: _polishNameFor(polishCode) ?? _scannedRow!.polishName,
        symmetryName: _symmetryNameFor(symmetryCode) ?? _scannedRow!.symmetryName,
        fluoName: _fluoNameFor(fluoCode) ?? _scannedRow!.fluoName,
      );
    }

    if (r == null) return;

    final detID = r.jobWorkRecDetID;
    final mstID =
        r.jobWorkRecMstID ??
            int.tryParse(_formValues['jobWorkRecMstID'] ?? '0') ??
            0;
    final prov = context.read<JobWorkRecEntryProvider>();

    // ── Media Upload (first upload media if files were updated) ──
    final bCodeStr = (r.bCode != 0)
        ? r.bCode.toString()
        : (_entryVals['scanValue'] ??
                _formValues['scanValue'] ??
                _entryVals['bCode'] ??
                _formValues['bCode'] ??
                r.bCode.toString())
            .toString();
    final mediaSuccess = await _uploadPendingMedia(prov, bCodeStr);
    if (!mounted || !mediaSuccess) return;

    if (detID != null && detID != 0) {
      final singleRowPayload = {
        "JobWorkRecMstID": mstID,
        "JobWorkRecDetID": detID,
        "JobWorkIssMstID": r.jobWorkIssMstID,
        "BCode": r.bCode,
        "PairNo": r.pairNo ?? '',
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
        "PolishCheckerRecMstID": r.polishCheckerRecMstID ?? 0,
        "MarkerMstID": r.markerMstID ?? 0,
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
        "expectedProcess": ProcessConstants.jobWorkRec,
      };

      final success = await prov.update(singleRowPayload, _theme, context);

      if (!mounted || !success) return;

      _clearEntryFields();
      if (mstID != 0) {
        final updatedDetails = await prov.loadDetails(mstID);
        if (mounted) {
          setState(() {
            if (updatedDetails.isNotEmpty) {
              _detRows = updatedDetails;
              _updateMaxSrNo();
            }
            _syncDetGrid();
          });
        }
      }
      await ErpResultDialog.showSuccess(
        context: context,
        theme: _theme,
        title: 'Updated',
        message: 'Job Work Rec entry updated successfully.',
      );
      _focusScan();
    } else {
      final singleDetailPayload = {
        // if (mstID != 0) "JobWorkRecMstID": mstID,
        "JobWorkIssMstID": r.jobWorkIssMstID,
        "Jno": r.jno ?? 0,
        "Srno": r.srno ?? (_maxSrNo + 1),

        "CutNo": r.cutNo,
        "MfgCut": r.mfgCut,
        "BCode": r.bCode,
        "PktNo": r.pktNo,
        "PairNo": r.pairNo ?? '',

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

      final createPayload = {
        if (mstID != 0) "JobWorkRecMstID": mstID,
        if (mstID != 0) "PreSrno": _detRows.length,
        "JobWorkRecDate": toUtcIso(_formValues['date']),
        "PartyMstID": int.tryParse(_formValues['partyMstID'] ?? '') ?? 0,
        "DeptCode": _selectedDeptCode ?? 0,
        "DeptProcessCode": r.deptProcessCode ?? 0,
        "details": [singleDetailPayload],
      };

      final createdMst = await prov.create(createPayload);
      if (!mounted || createdMst == null) return;

      final newMstID = createdMst.jobWorkRecMstID ?? mstID;

      setState(() {
        if (newMstID != 0) {
          _formValues['jobWorkRecMstID'] = newMstID.toString();
          _isEditMode = true;
        }
      });

      _clearEntryFields();
      if (newMstID != 0) {
        final updatedDetails = await prov.loadDetails(newMstID);
        if (mounted) {
          setState(() {
            if (updatedDetails.isNotEmpty) {
              _detRows = updatedDetails;
            } else {
              _detRows.add(r!);
            }
            _updateMaxSrNo();
            _syncDetGrid();
          });
        }
      } else {
        setState(() {
          _detRows.add(r!);
          _updateMaxSrNo();
          _syncDetGrid();
        });
      }
      _focusScan();
    }
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
        _detRows[actualIdx].bCode,
        theme: _theme,
        context: context,
      );

      if (success && mounted) {
        setState(() {
          if (_editingDetIndex == actualIdx) _editingDetIndex = null;
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
        if (_editingDetIndex == actualIdx) _editingDetIndex = null;
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
      'recPc',
      'recWt',
      'kPc',
      'kWt',
      'brPc',
      'brWt',
      'lossPc',
      'lossWt',
      'purityCode',
      'charniCode',
      'colorCode',
      'shapeCode',
      'cutCode',
      'polishCode',
      'symmetryCode',
      'fluoCode',
      'dmWt',
      'dmPer',
      'size',
      'diam',
      'height',
      'length',
    ];

    _detDisplay = _detRows.reversed
        .map(
          (r) => {
        'srno': r.srno?.toString() ?? '',
        'mfgCut': r.mfgCut,
        'qrCode': r.qrCode,
        'bCode': r.bCode.toString(),
        'pktNo': r.pktNo,
        'pairNo': r.pairNo?.toString() ?? '',
        'pc': r.pc.toString(),
        'wt': fThreeDecimal(r.wt),
        'issPc': r.issPc.toString(),
        'issWt': fThreeDecimal(r.issWt),
        'recPc': (r.recPc ?? 0).toString(),
        'recWt': fThreeDecimal(r.recWt ?? 0),
        'kPc': (r.kPc ?? 0).toString(),
        'kWt': fThreeDecimal(r.kWt ?? 0),
        'brPc': (r.brPc ?? 0).toString(),
        'brWt': fThreeDecimal(r.brWt ?? 0),
        'lossPc': (r.lossPc ?? 0).toString(),
        'lossWt': fThreeDecimal(r.lossWt ?? 0),
        'purityCode': r.purityName ?? _purityNameFor(r.purityCode) ?? '',
        'charniCode': r.charniName ?? _charniNameFor(r.charniCode) ?? '',
        'colorCode': r.colorName ?? _colorNameFor(r.colorCode) ?? '',
        'shapeCode': r.shapeName ?? _shapeNameFor(r.shapeCode) ?? '',
        'cutCode': r.cutName ?? _cutNameFor(r.cutCode) ?? '',
        'polishCode': r.polishName ?? _polishNameFor(r.polishCode) ?? '',
        'symmetryCode':
        r.symmetryName ?? _symmetryNameFor(r.symmetryCode) ?? '',
        'fluoCode': r.fluoName ?? _fluoNameFor(r.fluoCode) ?? '',
        'dmWt': fThreeDecimal(r.dmWt),
        'dmPer': r.dmPer.toStringAsFixed(2),
        'size': fThreeDecimal(r.size),
        'diam': r.diam.toStringAsFixed(2),
        'height': (r.height ?? 0).toStringAsFixed(2),
        'length': r.length.toStringAsFixed(2),
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
    final details = await prov.loadDetails(id);

    if (!mounted) return;

    setState(() {
      _selectedRow = row;
      _isEditMode = true;
      _detRows = details;
      _maxSrNo = 0;
      _updateMaxSrNo(details);
      _editingDetIndex = null;
      _scannedRow = null;
      _isAdding = false;
      _showTableOnMobile = false;

      _formValues = {
        'date': _date(row['date']),
        'jobWorkRecMstID': _s(row['jobWorkRecMstID'], '0'),
        'partyMstID': _s(row['partyMstID'], '0'),
        'deptProcessCode': _s(row['deptProcessCode'], '0'),
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

    final mstID = int.tryParse(_formValues['jobWorkRecMstID'] ?? '0') ?? 0;

    final payload = {
      if (mstID != 0) "JobWorkRecMstID": mstID,
      if (mstID != 0) "PreSrno": mstID,
      "JobWorkRecDate": toUtcIso(_formValues['date']),
      "PartyMstID": int.tryParse(_formValues['partyMstID'] ?? '') ?? 0,
      "DeptCode": _selectedDeptCode ?? 0,
      "DeptProcessCode": _detRows.first.deptProcessCode ?? 0,
      "details": _detRows.map((r) {
        return {
          if (mstID != 0) "JobWorkRecMstID": r.jobWorkRecMstID ?? mstID,
          if (r.jobWorkRecDetID != null && r.jobWorkRecDetID != 0)
            "JobWorkRecDetID": r.jobWorkRecDetID,
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

    final result = await prov.create(payload);

    if (!mounted) return;

    if (result != null) {
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
        _formValues['jobWorkRecMstID'] == '0') {
      return;
    }

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
      _editingDetIndex = null;
      _scannedRow = null;

      _detRows = [];
      _detDisplay = [];
      _maxSrNo = 0;

      _selectedPartyMstID = null;
      _selectedDeptCode = null;

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
  String _deptNameFor(int? deptCode) {
    if (deptCode == null) return '';
    try {
      return context
          .read<DeptProvider>()
          .list
          .firstWhere((d) => d.deptCode == deptCode)
          .deptName ??
          '';
    } catch (_) {
      return '';
    }
  }
  List<List<ErpFieldConfig>> _buildFormRows() {
    final counterProvider = context.watch<CounterProvider>();
    final colorProv = context.watch<ColorProvider>();
    final purityProv = context.watch<PurityProvider>();
    final cutProv = context.watch<CutProvider>();
    final charniProv = context.watch<CharniProvider>();
    final polishProv = context.watch<PolishProvider>();
    final symmetryProv = context.watch<SymmetryProvider>();
    final fluoProv = context.watch<FluoProvider>();
    final tensionProv = context.watch<TensionsProvider>();
    final fcIntentProv = context.watch<IntentProvider>();
    final fColorProv = context.watch<FColorProvider>();
    final fcOverProv = context.watch<OverProvider>();

    final colorDropdown = colorProv.list
        .where((e) => e.active == true)
        .map(
          (e) => ErpDropdownItem(
        label: e.colorName ?? '',
        value: e.colorCode?.toString() ?? '',
      ),
    )
        .toList();

    final purityDropdown = purityProv.list
        .where((e) => e.active == true)
        .map(
          (e) => ErpDropdownItem(
        label: e.purityName ?? '',
        value: e.purityCode?.toString() ?? '',
      ),
    )
        .toList();

    final cutDropdown = cutProv.cuts
        .where((e) => e.active == true)
        .map(
          (e) => ErpDropdownItem(
        label: e.cutName ?? '',
        value: e.cutCode?.toString() ?? '',
      ),
    )
        .toList();

    final charniDropdown = charniProv.list
        .where((e) => e.active == true)
        .map(
          (e) => ErpDropdownItem(
        label: e.charniName ?? '',
        value: e.charniCode?.toString() ?? '',
      ),
    )
        .toList();

    final polishDropdown = polishProv.polishs
        .where((e) => e.active == true)
        .map(
          (e) => ErpDropdownItem(
        label: e.polishName ?? '',
        value: e.polishCode?.toString() ?? '',
      ),
    )
        .toList();

    final symmetryDropdown = symmetryProv.symmetrys
        .where((e) => e.active == true)
        .map(
          (e) => ErpDropdownItem(
        label: e.symmetryName ?? '',
        value: e.symmetryCode?.toString() ?? '',
      ),
    )
        .toList();

    final fluoDropdown = fluoProv.list
        .where((e) => e.active == true)
        .map(
          (e) => ErpDropdownItem(
        label: e.fluoName ?? '',
        value: e.fluoCode?.toString() ?? '',
      ),
    )
        .toList();

    final tensionDropdown = tensionProv.list
        .where((e) => e.active == true)
        .map(
          (e) => ErpDropdownItem(
        label: e.tensionsName ?? '',
        value: e.tensionsCode?.toString() ?? '',
      ),
    )
        .toList();

    final fcIntentDropdown = fcIntentProv.cuts
        .where((e) => e.active == true)
        .map(
          (e) => ErpDropdownItem(
        label: e.fcIntentName ?? '',
        value: e.fcIntentCode?.toString() ?? '',
      ),
    )
        .toList();

    final fColor1Dropdown = fColorProv.cuts
        .where((e) => e.active == true && e.type == 'color1')
        .map(
          (e) => ErpDropdownItem(
        label: e.fColorName ?? '',
        value: e.fColorCode?.toString() ?? '',
      ),
    )
        .toList();

    final fColor2Dropdown = fColorProv.cuts
        .where((e) => e.active == true && e.type == 'color2')
        .map(
          (e) => ErpDropdownItem(
        label: e.fColorName ?? '',
        value: e.fColorCode?.toString() ?? '',
      ),
    )
        .toList();

    final fcOverDropdown = fcOverProv.cuts
        .where((e) => e.active == true)
        .map(
          (e) => ErpDropdownItem(
        label: e.fcOverName ?? '',
        value: e.fcOverCode?.toString() ?? '',
      ),
    )
        .toList();

    final List<List<ErpFieldConfig>> rows = [
      // Section 0: Master & Scan
      [
        ErpFieldConfig(
          key: 'date',
          label: 'DATE',
          type: ErpFieldType.date,
          readOnly: true,
          sectionIndex: 0,
          width: 120,
        ),
        ErpFieldConfig(
          key: 'partyMstID',
          label: 'PARTY',
          type: ErpFieldType.dropdown,
          sectionIndex: 0,
          required: true,
          width: 200,
          readOnly: _detRows.isNotEmpty,
          dropdownItems: counterProvider.list
              .where((e) => e.active == true)
              .map(
                (e) => ErpDropdownItem(
                  label:  '${e.crName ?? ''}  |  ${_deptNameFor(e.deptCode)}',
              value: e.crId?.toString() ?? '',
            ),
          )
              .toList(),
        ),
        ErpFieldConfig(
          key: 'scanValue',
          label: 'BCODE',
          type: ErpFieldType.text,
          sectionIndex: 0,
        ),
        ErpFieldConfig(
          key: 'qrCode',
          label: 'QRCODE',
          type: ErpFieldType.text,
          readOnly: true,
          sectionIndex: 0,
        ),
        ErpFieldConfig(
          key: 'jno',
          label: 'JNO',
          type: ErpFieldType.number,
          readOnly: true,
          sectionIndex: 0,
        ),
        ErpFieldConfig(
          key: 'mfgCut',
          label: 'MFG CUT',
          type: ErpFieldType.text,
          readOnly: true,
          sectionIndex: 0,
        ),
        ErpFieldConfig(
          key: 'pktNo',
          label: 'PKT NO',
          type: ErpFieldType.text,
          readOnly: true,
          sectionIndex: 0,
        ),
        ErpFieldConfig(
          key: 'orgPc',
          label: 'ORG PC',
          type: ErpFieldType.number,
          readOnly: true,
          isEntryField: true,
          sectionIndex: 0,
        ),
        ErpFieldConfig(
          key: 'orgWt',
          label: 'ORG WT',
          type: ErpFieldType.amount,
          readOnly: true,
          isEntryField: true,
          sectionIndex: 0,
        ),
        ErpFieldConfig(
          key: 'issPc',
          label: 'ISS PC',
          type: ErpFieldType.number,
          readOnly: true,
          sectionIndex: 0,
        ),
        ErpFieldConfig(
          key: 'issWt',
          label: 'ISS WT',
          type: ErpFieldType.amount,
          readOnly: true,
          sectionIndex: 0,
        ),
      ],
      // Section 1: Quality Attributes
      [
        ErpFieldConfig(
          key: 'recPc',
          label: 'REC PC',
          type: ErpFieldType.number,
          readOnly: true,
          sectionIndex: 1,
          width: 110,
        ),
        ErpFieldConfig(
          key: 'recWt',
          label: 'REC WT',
          type: ErpFieldType.amount,
          sectionIndex: 1,
          width: 110,
        ),
        ErpFieldConfig(
          key: 'dmWt',
          label: 'DM WT',
          type: ErpFieldType.amount,
          sectionIndex: 1,
          readOnly: true,
          width: 110,
        ),
        ErpFieldConfig(
          key: 'dmPer',
          label: 'DM PER',
          type: ErpFieldType.number,
          readOnly: true,
          sectionIndex: 1,
          width: 110,
        ),
        ErpFieldConfig(
          key: 'size',
          label: 'SIZE',
          type: ErpFieldType.number,
          readOnly: true,
          sectionIndex: 1,
          width: 110,
        ),
        ErpFieldConfig(
          key: 'purity',
          label: 'PURITY',
          type: ErpFieldType.dropdown,
          dropdownItems: purityDropdown,
          sectionIndex: 1,
          flex: 1,
        ),
        ErpFieldConfig(
          key: 'charni',
          label: 'CHARNI',
          type: ErpFieldType.dropdown,
          dropdownItems: charniDropdown,
          sectionIndex: 1,
          flex: 1,
        ),
        ErpFieldConfig(
          key: 'color',
          label: 'COLOR',
          type: ErpFieldType.dropdown,
          dropdownItems: colorDropdown,
          sectionIndex: 1,
          flex: 1,
        ),
        ErpFieldConfig(
          key: 'cutCode',
          label: 'CUT',
          type: ErpFieldType.dropdown,
          dropdownItems: cutDropdown,
          sectionIndex: 1,
          flex: 1,
        ),
        ErpFieldConfig(
          key: 'polishCode',
          label: 'POLISH',
          type: ErpFieldType.dropdown,
          dropdownItems: polishDropdown,
          sectionIndex: 1,
          flex: 1,
        ),
      ],
      // Section 2: FC & Extended Attributes
      [
        ErpFieldConfig(
          key: 'symmetryCode',
          label: 'SYMMETRY',
          type: ErpFieldType.dropdown,
          dropdownItems: symmetryDropdown,
          sectionIndex: 2,
          flex: 1,
        ),
        ErpFieldConfig(
          key: 'fluo',
          label: 'FLUO',
          type: ErpFieldType.dropdown,
          dropdownItems: fluoDropdown,
          sectionIndex: 2,
          flex: 1,
        ),
        ErpFieldConfig(
          key: 'tensionCode',
          label: 'TENSIONS',
          type: ErpFieldType.dropdown,
          dropdownItems: tensionDropdown,
          sectionIndex: 2,
          flex: 1,
        ),
        ErpFieldConfig(
          key: 'FcIntentCode',
          label: 'FC INTENT CODE',
          type: ErpFieldType.dropdown,
          dropdownItems: fcIntentDropdown,
          sectionIndex: 2,
        ),
        ErpFieldConfig(
          key: 'FColorCode1',
          label: 'FC COLOR CODE 1',
          type: ErpFieldType.dropdown,
          dropdownItems: fColor1Dropdown,
          sectionIndex: 2,
        ),
        ErpFieldConfig(
          key: 'FColorCode2',
          label: 'FC COLOR CODE 2',
          type: ErpFieldType.dropdown,
          dropdownItems: fColor2Dropdown,
          sectionIndex: 2,
        ),
        ErpFieldConfig(
          key: 'FcOverCode',
          label: 'FC OVER CODE',
          type: ErpFieldType.dropdown,
          dropdownItems: fcOverDropdown,
          sectionIndex: 2,
        ),
        ErpFieldConfig(
          key: 'HA',
          label: 'H&A',
          sectionIndex: 2,
          type: ErpFieldType.dropdown,
          initialDropValue: true,
          dropdownItems: const [
            ErpDropdownItem(label: 'N', value: 'N'),
            ErpDropdownItem(label: 'Y', value: 'Y'),
          ],
        ),
      ],
      // Section 3: Attachment
      [
        ErpFieldConfig(
          key: 'length',
          label: 'LENGTH',
          type: ErpFieldType.amount,
          sectionIndex: 3,
          width: 110,
          flex: 1,
        ),
        ErpFieldConfig(
          key: 'diam',
          label: 'DIAM',
          type: ErpFieldType.amount,
          sectionIndex: 3,
          width: 110,
          flex: 1,
        ),
        ErpFieldConfig(
          key: 'height',
          label: 'HEIGHT',
          type: ErpFieldType.amount,
          sectionIndex: 3,
          width: 110,
          flex: 1,
        ),
        ErpFieldConfig(
          key: 'TopSide',
          label: 'TOP SIDE',
          type: ErpFieldType.text,
          sectionIndex: 3,
          width: 110,
          flex: 1,
        ),
        ErpFieldConfig(
          key: 'pairNo',
          label: 'PAIR NO',
          type: ErpFieldType.text,
          sectionIndex: 3,
          width: 150,
          flex: 1,
        ),
        ErpFieldConfig(
          key: 'certificate',
          label: 'CERTIFICATE',
          type: ErpFieldType.attachment,
          hint: 'Select document',
          allowMultiple: false,
          allowExtension: ['pdf', 'jpg', 'jpeg', 'png', 'webp'],
          // or 'pdf, png, jpg', jpeg'
          sectionIndex: 3,
        ),
        ErpFieldConfig(
          key: 'images',
          label: 'IMAGES',
          type: ErpFieldType.attachment,
          hint: 'Select images',
          maxFileSizeMB: 10,
          allowMultiple: true,
          allowExtension: ['png', 'jpg', 'jpeg'],
          // or 'png, jpg', jpeg'
          sectionIndex: 3,
        ),
        ErpFieldConfig(
          key: 'videoAttachment',
          label: 'VIDEO',
          type: ErpFieldType.attachment,
          hint: 'Select Video File',
          allowMultiple: false,
          allowExtension: ['AVI', 'WMV', 'MP4', 'MOV', 'MKV', 'OGG'],
          sectionIndex: 3,
          showAddButton: true,
          isEntryField: true,
          showSaveButtonInsteadOfAdd: true,
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
    ErpColumnConfig(key: 'jobWorkRecMstID', label: 'ID', width: 70),
    ErpColumnConfig(key: 'date', label: 'DATE', width: 100, isDate: true),
    ErpColumnConfig(key: 'partyName', label: 'PARTY', width: 140),
    ErpColumnConfig(
      key: 'totalPc',
      label: 'PC',
      width: 70,
      align: ColumnAlign.center,
    ),
    ErpColumnConfig(
      key: 'totalWt',
      label: 'WT',
      width: 100,
      align: ColumnAlign.center,
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
      'recPc': 'REC PC',
      'recWt': 'REC WT',
      'kPc': 'K PC',
      'kWt': 'K WT',
      'brPc': 'BR PC',
      'brWt': 'BR WT',
      'lossPc': 'LOSS PC',
      'lossWt': 'LOSS WT',
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
      addButtonSections: const {3},
      showSaveButtonInsteadOfAdd: true,
      onEntryAdd: (sectionIndex) async {
        await _onAddEntry();
      },
      initialValues: _formValues,
      isEditMode: _isEditMode,
      onFieldChanged: (key, value) {
        final lowerKey = key.toLowerCase();
        if (lowerKey == 'certificate' ||
            lowerKey == 'images' ||
            lowerKey == 'image' ||
            lowerKey == 'videoattachment' ||
            lowerKey == 'video') {
          _pickedMediaFiles[key] = value;
          _pickedMediaFiles[lowerKey] = value;
          _mediaUpdatedFlags[key] = true;
          _mediaUpdatedFlags[lowerKey] = true;

          if (lowerKey == 'certificate') {
            Future.microtask(() {
              _erpFormKey.currentState?.focusField('images');
            });
          } else if (lowerKey == 'images' || lowerKey == 'image') {
            Future.microtask(() {
              _erpFormKey.currentState?.focusField('videoAttachment');
            });
          } else if (lowerKey == 'videoattachment' || lowerKey == 'video') {
            Future.microtask(() async {
              await _onAddEntry();
            });
          }
        }

        final val = value.toString();
        _formValues[key] = val;
        _entryVals[key] = val;

        switch (key) {
          case 'partyMstID':
            _selectedPartyMstID = int.tryParse(val);

            final counterProvider = context.read<CounterProvider>();

            try {
              final party = counterProvider.list.firstWhere(
                    (e) => e.crId == _selectedPartyMstID,
              );

              setState(() {
                _selectedDeptCode = party.deptCode;
              });
            } catch (_) {}
            break;
          case 'recWt':
          case 'kWt':
          case 'brWt':
          case 'recPc':
          case 'kPc':
          case 'brPc':
            _calcLoss();
            if (_editingDetIndex != null) {
              _updateEditedRow();
            }
            break;
          default:
            if (_editingDetIndex != null) {
              _updateEditedRow();
            }
            break;
        }
      },
      onFieldSubmitted: (key, value) async {
        if (key == 'pairNo' || key == 'PairNo') {
          _erpFormKey.currentState?.focusField('certificate');
          return;
        }

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
      isShowSaveButton: false,
      onCancel: _resetForm,
      onDelete: _isEditMode ? _onDelete : null,
      onSearch: () {
        final prov = context.read<JobWorkRecEntryProvider>();
        prov.load();
        setState(() => _showTableOnMobile = true);
      },
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
                onEditRow: _editDetRow,
                editingIndex: _editingDetIndex != null
                    ? (_detRows.length - 1 - _editingDetIndex!)
                    : null,
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

    final totPc = sumInt((r) => r.pc);
    final totWt = sumDouble((r) => r.wt);
    final totIssPc = sumInt((r) => r.issPc);
    final totIssWt = sumDouble((r) => r.issWt);
    final totDmWt = sumDouble((r) => r.dmWt);
    final dmPer = sumDouble((r) => r.dmPer);

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
