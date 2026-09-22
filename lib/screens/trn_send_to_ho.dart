import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:erp_data_table/erp_data_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdfx/pdfx.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:rs_dashboard/rs_dashboard.dart';
import 'package:universal_html/html.dart' as html;

import '../bootstrap.dart';
import '../providers/charni_provider.dart';
import '../providers/color_provider.dart';
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
  // ── Theme ──────────────────────────────────────────────────────────────────
  final ErpThemeVariant _themeVariant = ErpThemeVariant.frost;

  ErpTheme get _theme => ErpTheme(_themeVariant);
  @override
  void initState() {
    super.initState();
    _filterDrawerValues['sendToHo'] = 'N';
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.wait([
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
    setState(() {
      _formValues.clear();
      _filterDrawerValues.clear();
      _filterDrawerValues['sendToHo'] = 'N';
      _filterDrawerMultiSelectValues.clear();
      _selectedTableRows.clear();
      _lastFilter.clear();
    });
    context.read<TrnSendToHoProvider>().clear();
  }

  Future<void> _onSave() async {
    if (_isSaving) return;
    _isSaving = true;

    try {
      final prov = context.read<TrnSendToHoProvider>();
      final selectedType = _formValues['type'] ?? '';
      final isPdfMode = prov.pdfBytes != null || selectedType == 'Layout' || selectedType == 'LAYOUT';

      // In PDF mode (Layout), send all loaded JSON rows. In table mode (Pair Data), send checked rows.
      final List<Map<String, dynamic>> rowsToSend = isPdfMode
          ? prov.tableData
          : _selectedTableRows;

      if (rowsToSend.isEmpty) {
        final msg = isPdfMode 
            ? 'No layout data available to send.'
            : 'Please select at least one row.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
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

      final success = await prov.sendToHo(selectedRows: rowsToSend);

      if (!mounted) return;

      if (success) {
        await ErpResultDialog.showSuccess(
          context: context,
          theme: _theme,
          title: 'Success',
          message: prov.lastMessage ?? 'Data sent to HO successfully.',
        );
        setState(() {
          _selectedTableRows.clear();
        });
        final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
        final reloadFilter = _lastFilter.isNotEmpty
            ? _lastFilter
            : {
                'fromDate': todayStr,
                'toDate': todayStr,
                'sendToHo': _filterDrawerValues['sendToHo'] ?? 'N',
                if (isPdfMode) 'format': 'both',
              };
        if (isPdfMode) {
          await prov.loadLayoutData(filter: reloadFilter);
        } else {
          await prov.loadPairData(filter: reloadFilter);
        }
      } else {
        await ErpResultDialog.showError(
          context: context,
          theme: _theme,
          title: 'Error',
          message: prov.error ?? 'Failed to send data to HO.',
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
        await prov.loadPairData(filter: _lastFilter);
      } else if (strVal == 'Layout' || strVal == 'LAYOUT') {
        final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
        _lastFilter.clear();
        _lastFilter.addAll({
          'fromDate': todayStr,
          'toDate': todayStr,
          'sendToHo': _filterDrawerValues['sendToHo'] ?? 'N',
          'format': 'both',
        });
        await prov.loadLayoutData(filter: _lastFilter);
      } else {
        _lastFilter.clear();
        prov.clear();
      }
    }
  }


  List<List<ErpFieldConfig>> _buildFormRows() {
    return [
      [
        ErpFieldConfig(
          key: 'type',
          label: 'TYPE',
          type: ErpFieldType.dropdown,
          width: 200,
          skipFocus: true,
          dropdownItems: const [
            ErpDropdownItem(label: 'Layout', value: 'Layout'),
            ErpDropdownItem(label: 'Pair Data', value: 'Pair Data'),
          ],
          sectionIndex: 0,
        ),
      ],
    ];
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
            context.read<TrnSendToHoProvider>().loadPairData(filter: filter);
          } else if (selectedType == 'Layout' || selectedType == 'LAYOUT') {
            _lastFilter.clear();
            _lastFilter.addAll(filter);
            context.read<TrnSendToHoProvider>().loadLayoutData(filter: filter);
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
            context.read<TrnSendToHoProvider>().loadPairData();
          } else if (selectedType == 'Layout' || selectedType == 'LAYOUT') {
            _lastFilter.clear();
            context.read<TrnSendToHoProvider>().loadLayoutData();
          }
        },
      ),
      body: Consumer<TrnSendToHoProvider>(
        builder: (ctx, prov, _) => Padding(
          padding: const EdgeInsets.all(8),
          child: _buildForm(context, prov),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, TrnSendToHoProvider prov) {
    return ErpForm(
      logo: AppImages.logo,
      key: _erpFormKey,
      title: 'SEND TO HO',
      rows: _buildFormRows(),
      initialValues: _formValues,
      onCancel: _resetForm,
      isShowSaveButton: true,
      isShowAddButton: false,
      autoStartAdding: true,
      onSave: (_) => _onSave(),
      isEditMode: false,
      isShowSearch: false,
      filter: () {
        scaffoldKey.currentState?.openEndDrawer();
      },
      onFieldChanged: _handleFieldChanged,
      detailBuilder: (ctx) {
        final screenHeight = MediaQuery.of(context).size.height;
        final isMobile = Responsive.isMobile(context);
        final double subtractHeight = isMobile ? 220.0 : 180.0;
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

        final selectedType = _formValues['type'] ?? '';
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

        if (prov.pdfBytes != null) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight.isFinite
                    ? constraints.maxHeight
                    : dynamicHeight,
                child: _PdfReportView(
                  pdfBytes: prov.pdfBytes!,
                  reportTitle: selectedType.toUpperCase(),
                  filter: _lastFilter,
                ),
              );
            },
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
                  'send_to_ho_${prov.selectedType}_${prov.tableData.length}',
                ),
                data: prov.tableData,
                columns: prov.columns,
                showSearch: false,
                title: selectedType.toUpperCase(),
                token: '',
                url: '',
                isReportRow: false,
                showFooterTotals: true,
                showCheckBox: true,
                selectedRowsCheckBox: _selectedTableRows,
                onSelectionChanged: (rows) {
                  setState(() {
                    _selectedTableRows = rows;
                  });
                },
                cellBuilder: (context, row, colKey) {
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

// ─────────────────────────────────────────────────────────────────────────────
//  PDF VIEWER
// ─────────────────────────────────────────────────────────────────────────────

class _PdfReportView extends StatefulWidget {
  final Uint8List pdfBytes;
  final String reportTitle;
  final dynamic filter;

  const _PdfReportView({
    required this.pdfBytes,
    required this.reportTitle,
    this.filter,
  });

  @override
  State<_PdfReportView> createState() => _PdfReportViewState();
}

class _PdfReportViewState extends State<_PdfReportView> {
  late PdfControllerPinch _pdfController;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfControllerPinch(
      document: PdfDocument.openData(widget.pdfBytes),
    );
  }

  @override
  void didUpdateWidget(covariant _PdfReportView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pdfBytes != widget.pdfBytes) {
      _pdfController.dispose();
      _pdfController = PdfControllerPinch(
        document: PdfDocument.openData(widget.pdfBytes),
      );
    }
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : 600.0;

        return SizedBox(
          width: constraints.maxWidth,
          height: height,
          child: Column(
            children: [
              Expanded(
                child: PdfViewPinch(
                  controller: _pdfController,
                  scrollDirection: Axis.vertical,
                  builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
                    options: const DefaultBuilderOptions(),
                    errorBuilder: (_, error) =>
                        Center(child: Text('Error loading PDF: $error')),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
