import 'package:diam_mfg/providers/utility_jobwork_rate_update_provider.dart';
import 'package:diam_mfg/utils/constants.dart';
import 'package:erp_data_table/erp_data_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rs_dashboard/rs_dashboard.dart';
import '../bootstrap.dart';
import '../utils/app_images.dart';

class UtilityJobWorkRateUpdate extends StatefulWidget {
  const UtilityJobWorkRateUpdate({super.key});

  @override
  State<UtilityJobWorkRateUpdate> createState() =>
      _UtilityJobWorkRateUpdateState();
}

class _UtilityJobWorkRateUpdateState extends State<UtilityJobWorkRateUpdate> {
  final GlobalKey<ErpFormState> _erpFormKey = GlobalKey<ErpFormState>();
  bool _isEditMode = false;
  Map<String, String> _formValues = {};
  bool _showTable = false;
  final String? token = AppStorage.getString("token");

  // Form fields - DYNAMIC based on selected department
  List<List<ErpFieldConfig>> _buildFormRows() {
    return [
      [
        ErpFieldConfig(
          key: 'fromDate',
          label: 'FROM DATE',
          type: ErpFieldType.date,
          sectionIndex: 0,
          width: 250,
        ),
        ErpFieldConfig(
          key: 'toDate',
          label: 'TO DATE',
          type: ErpFieldType.date,
          sectionIndex: 0,
          width: 250,
        ),
      ],
    ];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _resetForm();
      await Future.wait([]);
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
    // Map form values to API payload
    final payload = {
      'FromDate': parseDateForApi(
        _formValues['fromDate'] ?? values['fromDate']?.toString(),
      ),
      'ToDate': parseDateForApi(
        _formValues['toDate'] ?? values['toDate']?.toString(),
      ),
    };

    final provider = context.read<UtilityJobWorkRateUpdateProvider>();
    await provider.clvDeptRateUpdate(payload, context);
  }

  void _resetForm() {
    context.read<UtilityJobWorkRateUpdateProvider>().hideRecalculation();

    setState(() {
      _showTable = false;
      _isEditMode = false;
      _formValues = {};
    });

    _erpFormKey.currentState?.resetForm();
    _setDefaultFormValues();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UtilityJobWorkRateUpdateProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child: ErpForm(
            logo: AppImages.logo,
            key: _erpFormKey,
            title: 'JOB WORK RATE UPDATE',
            subtitle: 'Job Work Rate Update',
            initialTabIndex: 0,
            tabBarBackgroundColor: const Color(0xfff2f0ef),
            tabBarSelectedColor: context.erpTheme.primaryGradient.first,
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
                            title: 'JOB WORK RATE UPDATE LIST',
                            columns: _tableColumns,
                            data: provider.recalculationData.map((e) {
                              return {
                                'JobWorkRecDetID': e.jobWorkRecDetID,
                                'JobWorkRecMstID': e.jobWorkRecMstID,
                                'Jno': e.jno,
                                'CutNo': e.cutNo,
                                'MfgCut': e.mfgCut,
                                'Srno': e.srno,
                                'BCode': e.bCode,
                                'PktNo': e.pktNo,
                                'PairNo': e.pairNo,
                                'Pc': e.pc,
                                'Wt': e.wt,
                                'IssPc': e.issPc,
                                'IssWt': e.issWt,
                                'RecPc': e.recPc,
                                'RecWt': e.recWt,
                                'KPc': e.kPc,
                                'KWt': e.kWt,
                                'BrPc': e.brPc,
                                'BrWt': e.brWt,
                                'LossPc': e.lossPc,
                                'LossWt': e.lossWt,
                                'PurityCode': e.purityCode,
                                'CharniCode': e.charniCode,
                                'ColorCode': e.colorCode,
                                'ShapeCode': e.shapeCode,
                                'CutCode': e.cutCode,
                                'DmWt': e.dmWt,
                                'DmPer': e.dmPer,
                                'Size': e.size,
                                'RecPer': e.recPer,
                                'DiffPer': e.diffPer,
                                'DiffWt': e.diffWt,
                                'JobRec': e.jobRec,
                                'RateID': e.rateID,
                                'Rateon': e.rateon,
                                'Rate': e.rate,
                                'Amount': e.amount,
                                'AmountRs': e.amountRs,
                                'PolishCheckerRecMstID': e.polishCheckerRecMstID,
                                'OrderMstID': e.orderMstID,
                                'MarkerMstID': e.markerMstID,
                                'FromCrID': e.fromCrID,
                                'LastCrID': e.lastCrID,
                                'CrID': e.crID,
                                'Diam': e.diam,
                                'Length': e.length,
                                'Height': e.height,
                                'PolishCode': e.polishCode,
                                'SymmetryCode': e.symmetryCode,
                                'FluoCode': e.fluoCode,
                                'TensionsCode': e.tensionsCode,
                                'QRCode': e.qrCode,
                                'TopSide': e.topSide,
                                'FcIntentCode': e.fcIntentCode,
                                'FcOverCode': e.fcOverCode,
                                'FColorCode1': e.fColorCode1,
                                'FColorCode2': e.fColorCode2,
                                'HA': e.ha,
                                'PartyMstID': e.partyMstID,
                                'DeptCode': e.deptCode,
                                'DeptProcessCode': e.deptProcessCode,
                                'ArticalCode': e.articalCode,
                                'Status': e.status,
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
    ErpColumnConfig(key: 'Jno', label: 'JNO', width: 130),
    ErpColumnConfig(key: 'BCode', label: 'BCODE', width: 150),
    ErpColumnConfig(key: 'PktNo', label: 'PKT NO', width: 140),
    ErpColumnConfig(key: 'CutNo', label: 'CUT NO', width: 140),
    ErpColumnConfig(key: 'MfgCut', label: 'MFG CUT', width: 160),

    ErpColumnConfig(key: 'Pc', label: 'PC', width: 120),
    ErpColumnConfig(key: 'Wt', label: 'WT', width: 120),
    ErpColumnConfig(key: 'IssPc', label: 'ISS PC', width: 140),
    ErpColumnConfig(key: 'IssWt', label: 'ISS WT', width: 140),
    ErpColumnConfig(key: 'RecPc', label: 'REC PC', width: 140),
    ErpColumnConfig(key: 'RecWt', label: 'REC WT', width: 140),

    ErpColumnConfig(key: 'KPc', label: 'K PC', width: 140),
    ErpColumnConfig(key: 'KWt', label: 'K WT', width: 140),
    ErpColumnConfig(key: 'BrPc', label: 'BR PC', width: 140),
    ErpColumnConfig(key: 'BrWt', label: 'BR WT', width: 140),
    ErpColumnConfig(key: 'LossPc', label: 'LOSS PC', width: 160),
    ErpColumnConfig(key: 'LossWt', label: 'LOSS WT', width: 160),

    ErpColumnConfig(key: 'ShapeCode', label: 'SHAPE', width: 140),
    ErpColumnConfig(key: 'CutCode', label: 'CUT', width: 140),
    ErpColumnConfig(key: 'PurityCode', label: 'PURITY', width: 140),
    ErpColumnConfig(key: 'ColorCode', label: 'COLOR', width: 140),
    ErpColumnConfig(key: 'CharniCode', label: 'CHARNI', width: 140),

    ErpColumnConfig(key: 'Diam', label: 'DIAM', width: 140),
    ErpColumnConfig(key: 'DmWt', label: 'DM WT', width: 140),
    ErpColumnConfig(key: 'DmPer', label: 'DM %', width: 140),
    ErpColumnConfig(key: 'Size', label: 'SIZE', width: 140),

    ErpColumnConfig(key: 'Length', label: 'LENGTH', width: 160),
    ErpColumnConfig(key: 'Height', label: 'HEIGHT', width: 140),

    ErpColumnConfig(key: 'PolishCode', label: 'POLISH', width: 140),
    ErpColumnConfig(key: 'SymmetryCode', label: 'SYMMETRY', width: 160),
    ErpColumnConfig(key: 'FluoCode', label: 'FLUO', width: 140),

    ErpColumnConfig(key: 'PairNo', label: 'PAIR NO', width: 160),
    ErpColumnConfig(key: 'TensionsCode', label: 'TENSIONS', width: 160),

    ErpColumnConfig(key: 'TopSide', label: 'TOP SIDE', width: 160),

    ErpColumnConfig(key: 'JobRec', label: 'JOB REC', width: 140),

    ErpColumnConfig(key: 'RateID', label: 'RATE ID', width: 140),
    ErpColumnConfig(key: 'Rateon', label: 'RATE ON', width: 160),
    ErpColumnConfig(key: 'Rate', label: 'RATE', width: 140),
    ErpColumnConfig(key: 'Amount', label: 'AMOUNT', width: 160),

    ErpColumnConfig(key: 'PartyMstID', label: 'PARTY', width: 140),
    ErpColumnConfig(key: 'DeptCode', label: 'DEPT', width: 140),
    ErpColumnConfig(key: 'DeptProcessCode', label: 'PROCESS', width: 160),
    ErpColumnConfig(key: 'ArticalCode', label: 'ARTICLE', width: 140),

    ErpColumnConfig(key: 'Status', label: 'STATUS', width: 160),

    ErpColumnConfig(key: 'HA', label: 'HA', width: 120),
  ];

  void _onFieldChanged(String key, dynamic value) {
    _formValues[key] = value.toString();
  }
}
