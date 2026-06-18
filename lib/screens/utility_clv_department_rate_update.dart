import 'package:diam_mfg/providers/counter_provider.dart';
import 'package:diam_mfg/providers/utility_clvdepartment_rate_update_provider.dart';
import 'package:diam_mfg/utils/constants.dart';
import 'package:diam_mfg/utils/msg_dialogue.dart';
import 'package:erp_data_table/erp_data_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rs_dashboard/rs_dashboard.dart';
import '../bootstrap.dart';
import '../providers/dept_provider.dart';
import '../providers/dept_process_provider.dart';
import '../utils/app_images.dart';

class UtilityClvDepartmentRateUpdate extends StatefulWidget {
  const UtilityClvDepartmentRateUpdate({super.key});

  @override
  State<UtilityClvDepartmentRateUpdate> createState() =>
      _UtilityClvDepartmentRateUpdateState();
}

class _UtilityClvDepartmentRateUpdateState
    extends State<UtilityClvDepartmentRateUpdate> {
  final GlobalKey<ErpFormState> _erpFormKey = GlobalKey<ErpFormState>();
  bool _isEditMode = false;
  Map<String, String> _formValues = {};
  bool _showTable = false;
  final String? token = AppStorage.getString("token");

  // ── Track selected department ────────────────────────────────────────
  int? _selectedDeptCode;
  String? _selectedDeptRateOn; // 'Y' or 'N'

  // ── Helper: Get rateOn for selected department ─────────────────────────
  String _getRateOnForDept(int? deptCode) {
    if (deptCode == null) return 'N';
    final exists = context.read<DeptProvider>().list.any(
      (d) => d.deptCode == deptCode,
    );
    // instead, e.g. `return dept.rateOn == true ? 'Y' : 'N';`
    return exists ? 'Y' : 'N';
  }

  // Form fields - DYNAMIC based on selected department
  List<List<ErpFieldConfig>> _buildFormRows() {
    final deptProvider = context.read<DeptProvider>();
    final counterProvider = context.read<CounterProvider>();
    final deptProcessProvider = context.read<DeptProcessProvider>();

    // Filter dept process by selected department
    final processItems = deptProcessProvider.list
        .where((p) {
          if (_selectedDeptCode == null) return false;
          // Filter process by department code
          return p.active == true && p.deptCode == _selectedDeptCode;
        })
        .map(
          (e) => ErpDropdownItem(
            label: e.deptProcessName ?? '',
            value: e.deptProcessCode?.toString() ?? '',
          ),
        )
        .toList();

    return [
      [
        ErpFieldConfig(
          key: 'crId',
          label: 'MANAGER',
          type: ErpFieldType.dropdown,
          sectionIndex: 0,
          dropdownItems: counterProvider.list
              .where((e) => e.active == true)
              .map(
                (e) => ErpDropdownItem(
                  label: e.crName ?? '',
                  value: e.crId?.toString() ?? '',
                ),
              )
              .toList(),
        ),
        ErpFieldConfig(
          key: 'deptCode',
          label: 'DEPARTMENT',
          type: ErpFieldType.dropdown,
          sectionIndex: 0,
          readOnly: true,
          dropdownItems: deptProvider.list
              .where((e) => e.active == true)
              .map(
                (e) => ErpDropdownItem(
                  label: e.deptName ?? '',
                  value: e.deptCode?.toString() ?? '',
                ),
              )
              .toList(),
        ),
        ErpFieldConfig(
          key: 'deptProcessCode',
          label: 'PROCESS',
          type: ErpFieldType.dropdown,
          sectionIndex: 0,
          dropdownItems: processItems,
        ),
        ErpFieldConfig(
          key: 'fromDate',
          label: 'FROM DATE',
          type: ErpFieldType.date,
          sectionIndex: 0,
        ),
        ErpFieldConfig(
          key: 'toDate',
          label: 'TO DATE',
          type: ErpFieldType.date,
          sectionIndex: 0,
        ),
      ],
    ];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _resetForm();
      await Future.wait([
        context.read<DeptProvider>().load(),
        context.read<CounterProvider>().load(),
        context.read<DeptProcessProvider>().load(),
      ]);
    });
  }

  void _setDefaultFormValues() {
    final now = DateTime.now();
    _formValues = {
      'fromDate': DateFormat('dd/MM/yyyy').format(now),
      'toDate': DateFormat('dd/MM/yyyy').format(now),
    };
    if (mounted) setState(() {});
  }

  Future<void> _onSave(Map<String, dynamic> values) async {
    final deptCode = int.tryParse(
      _formValues['deptCode'] ?? values['deptCode']?.toString() ?? '',
    );
    final crId = int.tryParse(
      _formValues['crId'] ?? values['crId']?.toString() ?? '',
    );
    final deptProcessCode = int.tryParse(
      _formValues['deptProcessCode'] ??
          values['deptProcessCode']?.toString() ??
          '',
    );

    if (crId == null || deptCode == null || deptProcessCode == null) {
      await ErpResultDialog.showError(
        context: context,
        theme: context.erpTheme,
        title: 'Missing information',
        message: 'Please select Manager, Department and Process before saving.',
      );
      return;
    }

    // Map form values to API payload
    final payload = {
      'DeptCode': deptCode,
      'CrID': crId,
      'DeptProcessCode': deptProcessCode,
      'FromDate': parseDateForApi(
        _formValues['fromDate'] ?? values['fromDate']?.toString(),
      ),
      'ToDate': parseDateForApi(
        _formValues['toDate'] ?? values['toDate']?.toString(),
      ),
    };

    final provider = context.read<UtilityClvDepartmentRateUpdateProvider>();
    await provider.clvDeptRateUpdate(payload,context);
  }


  void _resetForm() {
    context
        .read<UtilityClvDepartmentRateUpdateProvider>()
        .hideRecalculation();

    setState(() {
      _showTable = false;
      _isEditMode = false;
      _formValues = {};
      _selectedDeptCode = null;
      _selectedDeptRateOn = null;
    });

    _erpFormKey.currentState?.resetForm();
    _setDefaultFormValues();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UtilityClvDepartmentRateUpdateProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child: ErpForm(
            logo: AppImages.logo,
            key: _erpFormKey,
            title: 'CLV DEPARTMENT RATE UPDATE',
            subtitle: 'CLV Department Rate Update',
            initialTabIndex: 0,
            tabBarBackgroundColor: const Color(0xfff2f0ef),
            tabBarSelectedColor:
            context.erpTheme.primaryGradient.first,
            tabBarSelectedTxtColor: Colors.white,
            rows: _buildFormRows(),
            initialValues: _formValues,
            isEditMode: _isEditMode,
            onFieldChanged: _onFieldChanged,
            onSave: _onSave,
            onCancel: _resetForm,
            onDelete: null,
            detailBuilder: (context) {
              return Column(
                children: [
                  if (provider.showRecalculationButton)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _showTable = true;
                            });
                          },
                          child: const Text('SHOW RECALCULATION'),
                        ),
                      ),
                    ),

                  if (_showTable)
                    LayoutBuilder(
                        builder: (context, constraints) {
                          final screenHeight = MediaQuery.of(context).size.height;
                          final isMobile = Responsive.isMobile(context);
                          final double subtractHeight = isMobile ? 340.0 : 220.0;
                          final dynamicHeight = (screenHeight - subtractHeight).clamp(450.0, 1500.0);
                        return SizedBox(
                          height: constraints.maxHeight.isFinite
                              ? constraints.maxHeight
                              : dynamicHeight,
                          child: ErpDataTable(
                            isReportRow: false,
                            token: token ?? '',
                            url: baseUrl,
                            showHeader: false,
                            title: 'CLV DEPARTMENT RATE LIST',
                            columns: _tableColumns,
                            data: provider.recalculationData.map((e) {
                              return {
                                'Jno': e.jno,
                                'BCode': e.bCode,
                                'PktNo': e.pktNo,
                                'CutNo': e.cutNo,
                                'Pc': e.pc,
                                'Wt': e.wt,
                                'RecPc': e.recPc,
                                'RecWt': e.recWt,
                                'DeptCode': e.deptCode,
                                'DeptProcessCode': e.deptProcessCode,
                                'ShapeCode': e.shapeCode,
                                'CutCode': e.cutCode,
                                'PurityCode': e.purityCode,
                                'ColorCode': e.colorCode,
                                'RateID': e.rateID,
                                'Rateon': e.rateon,
                                'Rate': e.rate,
                                'Amount': e.amount,
                                'Remarks': e.remarks,
                              };
                            }).toList(),
                            showSearch: true,
                          ),
                        );
                      }
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
  List<ErpColumnConfig> get _tableColumns => [
    ErpColumnConfig(
      key: 'Jno',
      label: 'JNO',
      width: 130,
    ),
    ErpColumnConfig(
      key: 'BCode',
      label: 'BCODE',
      width: 150,
    ),
    ErpColumnConfig(
      key: 'PktNo',
      label: 'PKT NO',
      width: 150,
    ),
    ErpColumnConfig(
      key: 'CutNo',
      label: 'CUT NO',
      width: 140,
    ),
    ErpColumnConfig(
      key: 'Pc',
      label: 'PC',
      width: 120,
    ),
    ErpColumnConfig(
      key: 'Wt',
      label: 'WT',
      width: 120,
    ),
    ErpColumnConfig(
      key: 'RecPc',
      label: 'REC PC',
      width: 140,
    ),
    ErpColumnConfig(
      key: 'RecWt',
      label: 'REC WT',
      width: 140,
    ),
    ErpColumnConfig(
      key: 'DeptCode',
      label: 'DEPT',
      width: 140,
    ),
    ErpColumnConfig(
      key: 'DeptProcessCode',
      label: 'PROCESS',
      width: 140,
    ),
    ErpColumnConfig(
      key: 'ShapeCode',
      label: 'SHAPE',
      width: 140,
    ),
    ErpColumnConfig(
      key: 'CutCode',
      label: 'CUT',
      width: 140,
    ),
    ErpColumnConfig(
      key: 'PurityCode',
      label: 'PURITY',
      width: 140,
    ),
    ErpColumnConfig(
      key: 'ColorCode',
      label: 'COLOR',
      width: 140,
    ),
    ErpColumnConfig(
      key: 'RateID',
      label: 'RATE ID',
      width: 140,
    ),
    ErpColumnConfig(
      key: 'Rateon',
      label: 'RATE ON',
      width: 140,
    ),
    ErpColumnConfig(
      key: 'Rate',
      label: 'RATE',
      width: 140,
    ),
    ErpColumnConfig(
      key: 'Amount',
      label: 'AMOUNT',
      width: 140,
    ),
    ErpColumnConfig(
      key: 'Remarks',
      label: 'REMARKS',
      width: 200,
    ),
  ];

  void _onFieldChanged(String key, dynamic value) {
    _formValues[key] = value.toString();

    // When Manager is selected
    if (key == 'crId') {
      final crId = int.tryParse(value.toString());

      final counterProvider = context.read<CounterProvider>();
      final matches = counterProvider.list.where((e) => e.crId == crId);
      final deptCode = matches.isNotEmpty ? matches.first.deptCode : null;

      setState(() {
        _selectedDeptCode = deptCode;
        _formValues['deptCode'] = deptCode?.toString() ?? '';
        _selectedDeptRateOn = _getRateOnForDept(deptCode);

        // Clear process because department changed
        _formValues['deptProcessCode'] = '';
      });

      // Update Department dropdown
      _erpFormKey.currentState?.updateFieldValue(
        'deptCode',
        deptCode?.toString() ?? '',
      );

      // Clear Process dropdown
      _erpFormKey.currentState?.updateFieldValue('deptProcessCode', '');
    }

    // When Department is selected manually
    if (key == 'deptCode') {
      final deptCode = int.tryParse(value.toString());

      setState(() {
        _selectedDeptCode = deptCode;
        _selectedDeptRateOn = _getRateOnForDept(deptCode);

        // Clear dependent fields
        _formValues['deptProcessCode'] = '';
      });

      _erpFormKey.currentState?.updateFieldValue('deptProcessCode', '');
    }
  }
}
