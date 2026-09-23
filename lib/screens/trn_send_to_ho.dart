import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:erp_data_table/erp_data_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rs_dashboard/rs_dashboard.dart';

import '../bootstrap.dart';
import '../providers/article_provider.dart';
import '../providers/certificate_provider.dart';
import '../providers/charni_provider.dart';
import '../providers/color_provider.dart';
import '../providers/company_provider.dart';
import '../providers/counter_display_det_provider.dart';
import '../providers/counter_manager_det_provider.dart';
import '../providers/counter_provider.dart';
import '../providers/cut_create_provider.dart';
import '../providers/cut_provider.dart';
import '../providers/dept_group_provider.dart';
import '../providers/dept_process_provider.dart';
import '../providers/dept_provider.dart';
import '../providers/division_provider.dart';
import '../providers/employee_provider.dart';
import '../providers/factory_provider.dart';
import '../providers/fluo_provider.dart';
import '../providers/purity_provider.dart';
import '../providers/remarks_provider.dart';
import '../providers/report_mst_provider.dart';
import '../providers/report_type_provider.dart';
import '../providers/rough_provider.dart';
import '../providers/safe_provider.dart';
import '../providers/shape_provider.dart';
import '../providers/tensions_provider.dart';
import '../providers/test_provider.dart';
import '../providers/trn_send_to_ho_provider.dart';
import '../providers/user_visibility_provider.dart';
import '../utils/app_images.dart';
import '../utils/msg_dialogue.dart';
import '../widgets/report_filter_drawer.dart';
import 'pair_media_detail_dialog.dart';

class TrnSendToHo extends StatefulWidget {
  const TrnSendToHo({super.key});

  @override
  State<TrnSendToHo> createState() => _TrnSendToHoState();
}

typedef TrnSendToHoEntry = TrnSendToHo;

class _TrnSendToHoState extends State<TrnSendToHo> {
  final GlobalKey<ErpFormState> _erpFormKey = GlobalKey<ErpFormState>();
  GlobalKey<ScaffoldState>? _scaffoldKey;
  GlobalKey<ScaffoldState> get scaffoldKey =>
      _scaffoldKey ??= GlobalKey<ScaffoldState>();

  final Map<String, String> _formValues = {};
  final Map<String, String> _filterDrawerValues = {};
  final Map<String, List<String>> _filterDrawerMultiSelectValues = {};
  final Map<String, dynamic> _lastFilter = {};
  List<Map<String, dynamic>> _selectedTableRows = [];
  bool _isSaving = false;
  bool _showSearchTable = false;
  Map<String, dynamic>? _selectedSearchRow;
  bool _isEditMode = false;
  int _tableVersion = 0;

  // ── Theme ──────────────────────────────────────────────────────────────────
  final ErpThemeVariant _themeVariant = ErpThemeVariant.frost;

  ErpTheme get _theme => ErpTheme(_themeVariant);

  @override
  void initState() {
    super.initState();
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _formValues['date'] = todayStr;
    _formValues['fromSafe'] = '1';
    _formValues['toSafe'] = '1';
    _filterDrawerValues['sendToHo'] = 'N';

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.wait([
        context.read<CompanyProvider>().loadCompanies(),
        context.read<ArticleProvider>().load(),
        context.read<SafeProvider>().load(),
        context.read<LabProvider>().loadCuts(),
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
        context.read<FactoryProvider>().loadFactories(),
        context.read<ColorProvider>().load(),
        context.read<ReportTypeProvider>().load(),
        context.read<TestProvider>().load(),
        context.read<CutProvider>().loadCuts(),
        context.read<RoughProvider>().loadRoughs(),
        context.read<CutCreateProvider>().load(),
        context.read<DivisionProvider>().loadDivisions(),
        context.read<ReportMstProvider>().load(),
        context.read<FluoProvider>().load(),
      ]);
    });
  }

  void _resetForm() {
    _erpFormKey.currentState?.resetForm();
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    setState(() {
      _tableVersion++;
      _formValues.clear();
      _formValues['date'] = todayStr;
      _formValues['fromSafe'] = '1';
      _formValues['toSafe'] = '1';
      _filterDrawerValues.clear();
      _filterDrawerValues['sendToHo'] = 'N';
      _filterDrawerMultiSelectValues.clear();
      _selectedTableRows.clear();
      _lastFilter.clear();
      _showSearchTable = false;
      _isEditMode = false;
      _selectedSearchRow = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _erpFormKey.currentState?.updateFieldValue('mstId', '');
      _erpFormKey.currentState?.updateFieldValue('date', todayStr);
      _erpFormKey.currentState?.updateFieldValue('type', '');
      _erpFormKey.currentState?.updateFieldValue('articalCode', '');
      _erpFormKey.currentState?.updateFieldValue('companyCode', '');
      _erpFormKey.currentState?.updateFieldValue('certificateCode', '');
      _erpFormKey.currentState?.updateFieldValue('fromSafe', '1');
      _erpFormKey.currentState?.updateFieldValue('toSafe', '1');
      _erpFormKey.currentState?.updateFieldValue('naration', '');
    });
    context.read<TrnSendToHoProvider>().clear();
  }

  Future<void> _onSave() async {
    if (_isSaving) return;
    _isSaving = true;

    try {
      final prov = context.read<TrnSendToHoProvider>();
      final selectedType = _formValues['type'] ?? '';
      final List<Map<String, dynamic>> rowsToSend = _selectedTableRows;

      if (rowsToSend.isEmpty) {
        const msg = 'Please select at least one row.';
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(msg),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
        await ErpResultDialog.showError(
          context: context,
          theme: _theme,
          title: 'Validation',
          message: msg,
        );
        return;
      }

      final articalCodeStr = _formValues['articalCode'] ?? '';
      final articalModel = context.read<ArticleProvider>().list.firstWhereOrNull(
        (e) =>
            e.articalCode?.toString() == articalCodeStr ||
            e.articalName == articalCodeStr,
      );
      final articalCode =
          articalModel?.articalCode ?? int.tryParse(articalCodeStr) ?? 0;
      final articalName = articalModel?.articalName ?? articalCodeStr;

      final companyCodeStr = _formValues['companyCode'] ?? '';
      final companyModel = context.read<CompanyProvider>().companies.firstWhereOrNull(
        (e) =>
            e.companyCode?.toString() == companyCodeStr ||
            e.companyName == companyCodeStr,
      );
      final companyCode =
          companyModel?.companyCode ?? int.tryParse(companyCodeStr) ?? 0;
      final hoParty = companyModel?.companyName ?? companyCodeStr;

      final certCodeStr = _formValues['certificateCode'] ?? '';
      final certModel = context.read<LabProvider>().cuts.firstWhereOrNull(
        (e) =>
            e.certificateCode?.toString() == certCodeStr ||
            e.certificateName == certCodeStr,
      );
      final certificate = certModel?.certificateName ?? certCodeStr;

      final fromSafe = _formValues['fromSafe'] ?? '1';
      final toSafe = _formValues['toSafe'] ?? '1';
      final naration = _formValues['naration'] ?? '';
      final date = _formValues['date'] ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
      final type = _formValues['type'] ?? '';
      final mstId = int.tryParse(_formValues['mstId'] ?? '') ?? 0;
      final factoryRecMstId = int.tryParse(_formValues['factoryRecMstID'] ?? '') ?? 0;

      final mstData = <String, dynamic>{
        if (mstId > 0) 'SendToHoMstID': mstId,
        if (mstId > 0) 'MstID': mstId,
        if (factoryRecMstId > 0) 'FactoryRecMstID': factoryRecMstId,
        'Date': date,
        'Type': type,
        'ArticalCode': articalCode,
        'ArticalName': articalName,
        'CompanyCode': companyCode,
        'CompanyName': hoParty,
        'Certificate': certificate,
        'FromSafe': fromSafe,
        'ToSafe': toSafe,
        'Narration': naration,
      };

      bool success;
      if (_isEditMode && mstId > 0) {
        success = await prov.updateSendToHo(
          sendToHoMstId: mstId,
          selectedRows: rowsToSend,
          mstData: mstData,
        );
      } else {
        success = await prov.sendToHo(
          selectedRows: rowsToSend,
          mstData: mstData,
        );
      }

      if (!mounted) return;

      if (success) {
        await ErpResultDialog.showSuccess(
          context: context,
          theme: _theme,
          title: 'Success',
          message: prov.lastMessage ?? (_isEditMode ? 'Send to HO updated successfully.' : 'Data sent to HO successfully.'),
        );
        _resetForm();
      } else {
        await ErpResultDialog.showError(
          context: context,
          theme: _theme,
          title: 'Error',
          message: prov.error ?? (_isEditMode ? 'Failed to update Send to HO.' : 'Failed to send data to HO.'),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _handleFieldChanged(String key, dynamic value) async {
    final strVal = value?.toString().trim() ?? '';
    _formValues[key] = strVal;

    if (key == 'type') {
      if (_isEditMode) return;

      final prov = context.read<TrnSendToHoProvider>();
      prov.setSelectedType(strVal);
      setState(() {
        _selectedTableRows.clear();
      });

      if (strVal == 'Pair Data' || strVal == 'PAIR_DATA') {
        final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
        _lastFilter.clear();
        _lastFilter.addAll({
          'fromDate': todayStr,
          'toDate': todayStr,
          'sendToHo': _filterDrawerValues['sendToHo'] ?? 'N',
        });
        await prov.loadPairData(filter: _lastFilter,showLoader: true);
      } else if (strVal == 'Layout' || strVal == 'LAYOUT') {
        final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
        _lastFilter.clear();
        _lastFilter.addAll({
          'fromDate': todayStr,
          'toDate': todayStr,
          'sendToHo': _filterDrawerValues['sendToHo'] ?? 'N',
        });
        await prov.loadLayoutData(filter: _lastFilter,showLoader: true);
      } else {
        _lastFilter.clear();
        prov.clear();
      }
    }
  }

  Future<void> _onSearch() async {
    final prov = context.read<TrnSendToHoProvider>();
    await prov.loadSearchMstRecords();
    if (mounted) {
      setState(() {
        _showSearchTable = true;
      });
    }
  }

  Future<void> _onMstRowTap(Map<String, dynamic> row) async {
    final prov = context.read<TrnSendToHoProvider>();

    final sendToHoMstId = int.tryParse(
      '${row['SendToHoMstID'] ?? row['sendToHoMstID'] ?? row['mstId'] ?? row['MstID'] ?? 0}',
    ) ?? 0;
    final factoryRecMstId = int.tryParse(
      '${row['FactoryRecMstID'] ?? row['factoryRecMstID'] ?? 0}',
    ) ?? 0;
    final effectiveMstId = sendToHoMstId > 0 ? sendToHoMstId : factoryRecMstId;

    final rawType = (row['Type'] ?? row['type'] ?? _formValues['type'] ?? '').toString().trim();
    String normalizedType = rawType;
    if (rawType.toUpperCase() == 'PAIR_DATA' || rawType.toLowerCase() == 'pair data') {
      normalizedType = 'Pair Data';
    } else if (rawType.toUpperCase() == 'LAYOUT' || rawType.toLowerCase() == 'layout') {
      normalizedType = 'Layout';
    }

    prov.setSelectedType(normalizedType);
    final details = await prov.loadMstDetails(effectiveMstId, type: normalizedType);

    String rawDate = (row['Date'] ?? row['SendToHoDate'] ?? row['date'] ?? '').toString();
    String dateStr = rawDate;
    if (dateStr.contains('T')) {
      dateStr = dateStr.split('T').first;
    }

    final artCode = (row['ArticalCode'] ?? row['articalCode'] ?? '').toString();
    final artName = (row['ArticalName'] ?? row['articalName'] ?? '').toString();
    final compCode = (row['CompanyCode'] ?? row['companyCode'] ?? '').toString();
    final compName = (row['CompanyName'] ?? row['companyName'] ?? row['HOParty'] ?? row['hoParty'] ?? '').toString();
    final cert = (row['Certificate'] ?? row['certificate'] ?? '').toString();

    String rawFromSafe = (row['FromSafe'] ?? row['fromSafe'] ?? '').toString();
    if (rawFromSafe.isEmpty) rawFromSafe = '1';
    String rawToSafe = (row['ToSafe'] ?? row['toSafe'] ?? '').toString();
    if (rawToSafe.isEmpty) rawToSafe = '1';

    String resolvedFromSafe = rawFromSafe;
    final fromSafeObj = context.read<SafeProvider>().list.firstWhereOrNull(
          (e) =>
              e.safeName?.toLowerCase() == rawFromSafe.toLowerCase() ||
              e.safeCode?.toString() == rawFromSafe,
        );
    if (fromSafeObj?.safeCode != null) {
      resolvedFromSafe = fromSafeObj!.safeCode.toString();
    }

    String resolvedToSafe = rawToSafe;
    final toSafeObj = context.read<SafeProvider>().list.firstWhereOrNull(
          (e) =>
              e.safeName?.toLowerCase() == rawToSafe.toLowerCase() ||
              e.safeCode?.toString() == rawToSafe,
        );
    if (toSafeObj?.safeCode != null) {
      resolvedToSafe = toSafeObj!.safeCode.toString();
    }

    final narration = (row['Narration'] ?? row['narration'] ?? row['Naration'] ?? '').toString();

    String resolvedArticalCode = artCode;
    if (resolvedArticalCode.isEmpty || resolvedArticalCode == '0') {
      final a = context.read<ArticleProvider>().list.firstWhereOrNull(
            (e) => e.articalName?.toLowerCase() == artName.toLowerCase(),
          );
      if (a?.articalCode != null) {
        resolvedArticalCode = a!.articalCode.toString();
      } else if (artName.isNotEmpty) {
        resolvedArticalCode = artName;
      }
    }

    String resolvedCompanyCode = compCode;
    if (resolvedCompanyCode.isEmpty || resolvedCompanyCode == '0') {
      final c = context.read<CompanyProvider>().companies.firstWhereOrNull(
            (e) => e.companyName?.toLowerCase() == compName.toLowerCase(),
          );
      if (c?.companyCode != null) {
        resolvedCompanyCode = c!.companyCode.toString();
      } else if (compName.isNotEmpty) {
        resolvedCompanyCode = compName;
      }
    }

    setState(() {
      _tableVersion++;
      _selectedSearchRow = row;
      _showSearchTable = false;
      _isEditMode = true;

      _formValues['mstId'] = effectiveMstId > 0 ? effectiveMstId.toString() : '';
      _formValues['factoryRecMstID'] = factoryRecMstId > 0 ? factoryRecMstId.toString() : '';
      if (dateStr.isNotEmpty) _formValues['date'] = dateStr;
      if (normalizedType.isNotEmpty) _formValues['type'] = normalizedType;
      _formValues['articalCode'] = resolvedArticalCode;
      _formValues['companyCode'] = resolvedCompanyCode;
      _formValues['certificateCode'] = cert;
      _formValues['fromSafe'] = resolvedFromSafe;
      _formValues['toSafe'] = resolvedToSafe;
      _formValues['naration'] = narration;

      final dataToSelect = prov.tableData.isNotEmpty ? prov.tableData : details;
      _selectedTableRows = List<Map<String, dynamic>>.from(dataToSelect);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _erpFormKey.currentState?.updateFieldValue('mstId', _formValues['mstId'] ?? '');
      _erpFormKey.currentState?.updateFieldValue('date', _formValues['date'] ?? '');
      _erpFormKey.currentState?.updateFieldValue('type', _formValues['type'] ?? '');
      _erpFormKey.currentState?.updateFieldValue('articalCode', _formValues['articalCode'] ?? '');
      _erpFormKey.currentState?.updateFieldValue('companyCode', _formValues['companyCode'] ?? '');
      _erpFormKey.currentState?.updateFieldValue('certificateCode', _formValues['certificateCode'] ?? '');
      _erpFormKey.currentState?.updateFieldValue('fromSafe', _formValues['fromSafe'] ?? '');
      _erpFormKey.currentState?.updateFieldValue('toSafe', _formValues['toSafe'] ?? '');
      _erpFormKey.currentState?.updateFieldValue('naration', _formValues['naration'] ?? '');
    });
  }

  Future<void> _showRemoveFromSendToHoDialog(Map<String, dynamic> row) async {
    final pktNo = row['PktNo'] ?? row['pktNo'] ?? row['BCode'] ?? row['bCode'] ?? '';
    final isYes = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text(
            'Remove from Send to HO',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          content: Text(
            pktNo.toString().isNotEmpty
                ? 'Are you sure you want to remove packet $pktNo from Send to HO?'
                : 'Are you sure you want to remove this record from Send to HO?',
            style: const TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('No'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (isYes != true) return;

    int detId = int.tryParse(
      '${row['DetID'] ?? row['detId'] ?? row['FactoryRecDetID'] ?? row['factoryRecDetID'] ?? row['Id'] ?? row['id'] ?? 0}',
    ) ?? 0;
    if (detId == 0 && row['raw'] is Map) {
      final rawMap = row['raw'] as Map;
      detId = int.tryParse(
        '${rawMap['DetID'] ?? rawMap['detId'] ?? rawMap['FactoryRecDetID'] ?? rawMap['factoryRecDetID'] ?? 0}',
      ) ?? 0;
    }
    if (detId == 0 && row['_raw'] is Map) {
      final rawMap = row['_raw'] as Map;
      detId = int.tryParse(
        '${rawMap['DetID'] ?? rawMap['detId'] ?? rawMap['FactoryRecDetID'] ?? rawMap['factoryRecDetID'] ?? 0}',
      ) ?? 0;
    }

    if (detId == 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: DetID not found for this row.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    final prov = context.read<TrnSendToHoProvider>();
    final success = await prov.updateSendToHoStatus(detId: detId, sendToHo: 'N');

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Removed from Send to HO successfully.'),
          duration: Duration(seconds: 2),
        ),
      );

      int mstId = int.tryParse('${_formValues['mstId'] ?? _formValues['factoryRecMstID'] ?? ''}') ?? 0;
      if (mstId == 0) {
        mstId = int.tryParse('${prov.jsonResponse['SendToHoMstID'] ?? prov.jsonResponse['FactoryRecMstID'] ?? 0}') ?? 0;
      }
      final typeStr = (_formValues['type'] ?? prov.selectedType ?? '').trim();
      if (mstId > 0) {
        final details = await prov.loadMstDetails(
          mstId,
          type: typeStr,
          showLoader: false,
          notify: false,
        );
        if (mounted) {
          setState(() {
            _tableVersion++;
            final dataToSelect = prov.tableData.isNotEmpty ? prov.tableData : details;
            _selectedTableRows = List<Map<String, dynamic>>.from(dataToSelect);
          });
        }
      } else {
        setState(() {
          _tableVersion++;
          _selectedTableRows.removeWhere((e) => _isSameRow(e, row));
        });
        prov.removeRow(row);
      }
    } else {
      await ErpResultDialog.showError(
        context: context,
        theme: _theme,
        title: 'Error',
        message: prov.error ?? 'Failed to update status.',
      );
    }
  }

  bool _isSameRow(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (identical(a, b)) return true;
    final aId = a['DetID'] ?? a['detId'] ?? a['FactoryRecDetID'] ?? a['factoryRecDetID'] ?? a['PktNo'] ?? a['pktNo'] ?? a['BCode'] ?? a['bCode'];
    final bId = b['DetID'] ?? b['detId'] ?? b['FactoryRecDetID'] ?? b['factoryRecDetID'] ?? b['PktNo'] ?? b['pktNo'] ?? b['BCode'] ?? b['bCode'];
    if (aId != null && bId != null && aId.toString().isNotEmpty && aId.toString() != '-' && bId.toString().isNotEmpty && bId.toString() != '-') {
      return aId.toString() == bId.toString();
    }
    return a == b;
  }

  List<ErpDropdownItem> _getArticleItems(ArticleProvider prov, String? currentVal) {
    final list = prov.list
        .where((e) => e.active != false)
        .map(
          (e) => ErpDropdownItem(
            label: e.articalName ?? '',
            value: e.articalCode?.toString() ?? '',
          ),
        )
        .toList();
    if (currentVal != null && currentVal.isNotEmpty && !list.any((item) => item.value == currentVal)) {
      list.insert(0, ErpDropdownItem(label: currentVal, value: currentVal));
    }
    return list;
  }

  List<ErpDropdownItem> _getCompanyItems(CompanyProvider prov, String? currentVal) {
    final list = prov.companies
        .where((e) => e.active != false)
        .map(
          (e) => ErpDropdownItem(
            label: e.companyName ?? '',
            value: e.companyCode?.toString() ?? '',
          ),
        )
        .toList();
    if (currentVal != null && currentVal.isNotEmpty && !list.any((item) => item.value == currentVal)) {
      list.insert(0, ErpDropdownItem(label: currentVal, value: currentVal));
    }
    return list;
  }

  List<ErpDropdownItem> _getCertificateItems(LabProvider prov, String? currentVal) {
    final list = prov.cuts
        .where((e) => e.active != false)
        .map(
          (e) => ErpDropdownItem(
            label: e.certificateName ?? '',
            value: e.certificateCode?.toString() ?? '',
          ),
        )
        .toList();
    if (currentVal != null && currentVal.isNotEmpty && !list.any((item) => item.value == currentVal)) {
      list.insert(0, ErpDropdownItem(label: currentVal, value: currentVal));
    }
    return list;
  }

  List<ErpDropdownItem> _getSafeItems(SafeProvider prov, String? currentVal) {
    final list = prov.list
        .where((e) => e.active != false)
        .map(
          (e) => ErpDropdownItem(
            label: e.safeName ?? '',
            value: e.safeCode?.toString() ?? '',
          ),
        )
        .toList();
    if (list.isEmpty) {
      list.add(const ErpDropdownItem(label: 'MAIN', value: '1'));
    }
    if (currentVal != null && currentVal.isNotEmpty && !list.any((item) => item.value == currentVal)) {
      list.insert(0, ErpDropdownItem(label: currentVal, value: currentVal));
    }
    return list;
  }

  List<List<ErpFieldConfig>> _buildFormRows(BuildContext context) {
    final artProv = context.watch<ArticleProvider>();
    final compProv = context.watch<CompanyProvider>();
    final safeProv = context.watch<SafeProvider>();
    return [
      [
        ErpFieldConfig(
          key: 'mstId',
          label: 'Jno',
          type: ErpFieldType.text,
          width: 100,
          readOnly: true,
          skipFocus: true,
          sectionIndex: 0,
        ),
        ErpFieldConfig(
          key: 'date',
          label: 'DATE',
          type: ErpFieldType.date,
          skipFocus: true,
          sectionIndex: 0,
        ),
        ErpFieldConfig(
          key: 'type',
          label: 'TYPE',
          type: ErpFieldType.dropdown,
          readOnly: _isEditMode,
          dropdownItems: const [
            ErpDropdownItem(label: 'Layout', value: 'Layout'),
            ErpDropdownItem(label: 'Pair Data', value: 'Pair Data'),
          ],
          sectionIndex: 0,
        ),
        ErpFieldConfig(
          key: 'articalCode',
          label: 'ARTICLE',
          type: ErpFieldType.dropdown,
          skipFocus: true,
          dropdownItems: _getArticleItems(artProv, _formValues['articalCode']),
          sectionIndex: 0,
        ),
        ErpFieldConfig(
          key: 'companyCode',
          label: 'HO PARTY',
          type: ErpFieldType.dropdown,
          skipFocus: true,
          dropdownItems: _getCompanyItems(compProv, _formValues['companyCode']),
          sectionIndex: 0,
        ),
        ErpFieldConfig(
          key: 'certificateCode',
          label: 'CERTIFICATE',
          skipFocus: true,
          type: ErpFieldType.dropdown,
          dropdownItems: [
            ErpDropdownItem(label: 'GIA', value: 'GIA'),
            ErpDropdownItem(label: 'IGI', value: 'IGI'),
            ErpDropdownItem(label: 'NON', value: 'NON')
          ],
          sectionIndex: 0,
        ),
        ErpFieldConfig(
          key: 'fromSafe',
          label: 'FROM SAFE',
          type: ErpFieldType.dropdown,
          skipFocus: true,
          dropdownItems: _getSafeItems(safeProv, _formValues['fromSafe']),
          sectionIndex: 0,
        ),
        ErpFieldConfig(
          key: 'toSafe',
          label: 'TO SAFE',
          type: ErpFieldType.dropdown,
          skipFocus: true,
          dropdownItems: _getSafeItems(safeProv, _formValues['toSafe']),
          sectionIndex: 0,
        ),
      ],
      [
        ErpFieldConfig(
          key: 'naration',
          label: 'NARRATION',
          type: ErpFieldType.text,
          skipFocus: true,
          width: 320,
          sectionIndex: 1,
        ),
      ],
    ];
  }

  Widget _buildSearchTable(TrnSendToHoProvider prov) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = Responsive.isMobile(context);
    final double subtractHeight = isMobile ? 120.0 : 80.0;
    final dynamicHeight = (screenHeight - subtractHeight).clamp(400.0, 3000.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight.isFinite ? constraints.maxHeight : dynamicHeight,
          child: ErpDataTable(
            key: const ValueKey('send_to_ho_search_table'),
            isReportRow: false,
            token: '',
            url: '',
            title: 'SEND TO HO - MASTER RECORDS',
            columns: prov.searchMstColumns,
            data: prov.searchMstList,
            showSearch: true,
            showFooterTotals: true,
            selectedRow: _selectedSearchRow,
            onRowTap: _onMstRowTap,
            onClose: () {
              setState(() {
                _showSearchTable = false;
              });
            },
            emptyMessage: prov.isLoading ? 'Loading master records...' : 'No records found',
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.transparent,
      endDrawer: ReportFilterDrawer(
        showReportSelection: false,
        initialFormValues: _filterDrawerValues,
        initialMultiSelectValues: _filterDrawerMultiSelectValues,
        onStateChanged: (formVals, multiSelectVals) {
          _filterDrawerValues.clear();
          _filterDrawerValues.addAll(formVals);
          _filterDrawerMultiSelectValues.clear();
          _filterDrawerMultiSelectValues.addAll(multiSelectVals);
        },
        onApply: (filter) {
          final selectedType = _formValues['type'] ?? '';
          if (selectedType == 'Pair Data' || selectedType == 'PAIR_DATA') {
            _lastFilter.clear();
            _lastFilter.addAll(filter);
            context.read<TrnSendToHoProvider>().loadPairData(filter: filter, showLoader: true);
          } else if (selectedType == 'Layout' || selectedType == 'LAYOUT') {
            _lastFilter.clear();
            _lastFilter.addAll(filter);
            context.read<TrnSendToHoProvider>().loadLayoutData(filter: filter, showLoader: true);
          } else {
            if (selectedType.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please select TYPE first'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          }
        },
        onReset: () {
          final selectedType = _formValues['type'] ?? '';
          if (selectedType == 'Pair Data' || selectedType == 'PAIR_DATA') {
            _lastFilter.clear();
            context.read<TrnSendToHoProvider>().loadPairData(showLoader: true);
          } else if (selectedType == 'Layout' || selectedType == 'LAYOUT') {
            _lastFilter.clear();
            context.read<TrnSendToHoProvider>().loadLayoutData(showLoader: true);
          }
        },
      ),
      body: Consumer<TrnSendToHoProvider>(
        builder: (ctx, prov, _) => Padding(
          padding: const EdgeInsets.all(8),
          child: _showSearchTable
              ? _buildSearchTable(prov)
              : _buildForm(context, prov),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, TrnSendToHoProvider prov) {
    return ErpForm(
      logo: AppImages.logo,
      key: _erpFormKey,
      title: 'SEND TO HO',
      rows: _buildFormRows(context),
      initialValues: _formValues,
      onCancel: _resetForm,
      isShowSaveButton: true,
      isShowAddButton: true,
      autoStartAdding: true,
      onSave: (_) => _onSave(),
      isEditMode: _isEditMode,
      isShowSearch: true,
      onSearch: _onSearch,
      filter: _isEditMode ?null:() {
        scaffoldKey.currentState?.openEndDrawer();
      },
      onFieldChanged: _handleFieldChanged,
      detailBuilder: (ctx) {
        final screenHeight = MediaQuery.of(context).size.height;
        final isMobile = Responsive.isMobile(context);
        final double subtractHeight = isMobile ? 220.0 : 210.0;
        final dynamicHeight = (screenHeight - subtractHeight).clamp(
          400.0,
          3000.0,
        );

        if (prov.isLoading) {
          return SizedBox(
            height: dynamicHeight,
            width: double.infinity,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final selectedType = (_formValues['type'] ?? prov.selectedType ?? '').trim();
        if (selectedType.isEmpty) {
          return SizedBox(
            height: dynamicHeight,
            width: double.infinity,
            child: const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.touch_app_outlined, size: 50, color: Colors.grey),
                    SizedBox(height: 12),
                    Text(
                      'Please select an option from TYPE dropdown',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (prov.tableData.isEmpty) {
          return SizedBox(
            height: dynamicHeight,
            width: double.infinity,
            child: const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline, size: 50, color: Colors.grey),
                    SizedBox(height: 12),
                    Text(
                      'No Data Found',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'No records available for the selected option.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight.isFinite
                  ? constraints.maxHeight
                  : dynamicHeight,
              child: ErpDataTable(
                key: ValueKey(
                  'send_to_ho_${_tableVersion}_${_isEditMode ? "edit_${_formValues['mstId']}" : "new"}_${prov.selectedType ?? selectedType}_${prov.tableData.length}',
                ),
                data: prov.tableData,
                columns: prov.columns,
                showSearch: false,
                title: selectedType.toUpperCase(),
                token: '',
                url: '',
                isReportRow: false,
                showFooterTotals: true,
                onRowTap: (row) {
                  if (_isEditMode) {
                    _showRemoveFromSendToHoDialog(row);
                  }
                },
                showCheckBox: true,
                selectedRowsCheckBox: _selectedTableRows,
                onSelectionChanged: (rows) {
                  setState(() {
                    _selectedTableRows = rows;
                  });
                },
                cellBuilder: (context, row, colKey) {
                  if (colKey == 'Jno' || colKey == 'jno') {
                    final val = row['Jno'] ?? row['jno'] ?? row['FactoryRecMstID'] ?? row['MstID'] ?? '';
                    final text = val.toString().trim();
                    if (text.isNotEmpty && text != 'null') {
                      return Text(
                        text,
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      );
                    }
                  }
                  if (colKey == 'ArticalName' || colKey == 'articalName') {
                    final val = row['ArticalName'] ?? row['articalName'] ?? row['ArticleName'] ?? row['articleName'] ?? '';
                    final text = val.toString().trim();
                    if (text.isNotEmpty && text != 'null') {
                      return Text(
                        text,
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      );
                    }
                  }
                  if (colKey == 'PktNo' || colKey == 'pktNo') {
                    final images = row['images'] ?? row['Images'];
                    final videos = row['videos'] ?? row['Videos'];
                    final certs = row['certificates'] ?? row['Certificates'];
                    final bool hasMedia = (images is List && images.isNotEmpty) ||
                        (videos is List && videos.isNotEmpty) ||
                        (certs is List && certs.isNotEmpty) ||
                        (images is String && images.trim().isNotEmpty) ||
                        (videos is String && videos.trim().isNotEmpty) ||
                        (certs is String && certs.trim().isNotEmpty);

                    if (hasMedia) {
                      final pktNoText = row['PktNo'] ?? row['pktNo'] ?? '--';
                      return MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => PairMediaDetailDialog(row: row),
                            );
                          },
                          child: Text(
                            '$pktNoText',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blue.shade700,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    }
                  }
                  return null;
                },
              ),
            );
          },
        );
      },
    );
  }
}
