import 'package:diam_mfg/providers/factory_provider.dart';
import 'package:diam_mfg/providers/utility_factory_rate_update_provider.dart';
import 'package:diam_mfg/utils/constants.dart';
import 'package:diam_mfg/utils/msg_dialogue.dart';
import 'package:erp_data_table/erp_data_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rs_dashboard/rs_dashboard.dart';
import '../bootstrap.dart';
import '../utils/app_images.dart';

class UtilityFactoryRateUpdate extends StatefulWidget {
  const UtilityFactoryRateUpdate({super.key});

  @override
  State<UtilityFactoryRateUpdate> createState() =>
      _UtilityFactoryRateUpdateState();
}

class _UtilityFactoryRateUpdateState
    extends State<UtilityFactoryRateUpdate> {
  final GlobalKey<ErpFormState> _erpFormKey = GlobalKey<ErpFormState>();
  bool _isEditMode = false;
  Map<String, String> _formValues = {};
  bool _showTable = false;
  final String? token = AppStorage.getString("token");

  // Form fields - DYNAMIC based on selected department
  List<List<ErpFieldConfig>> _buildFormRows() {
    final factoryProvider = context.read<FactoryProvider>();

    return [
      [
        ErpFieldConfig(
          key: 'factory',
          label: 'FACTORY',
          type: ErpFieldType.dropdown,
          sectionIndex: 0,
          width: 250,
          dropdownItems: factoryProvider.factories
              .where((e) => e.active == true)
              .map(
                (e) => ErpDropdownItem(
                  label: e.factoryName ?? '',
                  value: e.factoryCode?.toString() ?? '',
                ),
              )
              .toList(),
        ),
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
      await Future.wait([
        context.read<FactoryProvider>().loadFactories(),
      ]);
      _setDefaultFormValues();
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
    final factoryCode = int.tryParse(
      _formValues['factory'] ?? values['factory']?.toString() ?? '',
    );
    
    if (factoryCode == null ) {
      await ErpResultDialog.showError(
        context: context,
        theme: context.erpTheme,
        title: 'Missing information',
        message: 'Please select Factory and Process before saving.',
      );
      return;
    }

    // Map form values to API payload
    final payload = {
      'FactoryCode': factoryCode,
      'FromDate': parseDateForApi(
        _formValues['fromDate'] ?? values['fromDate']?.toString(),
      ),
      'ToDate': parseDateForApi(
        _formValues['toDate'] ?? values['toDate']?.toString(),
      ),
    };

    final provider = context.read<UtilityFactoryRateUpdateProvider>();
    await provider.clvDeptRateUpdate(payload,context);
  }


  void _resetForm() {
    context
        .read<UtilityFactoryRateUpdateProvider>()
        .hideRecalculation();

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
    return Consumer<UtilityFactoryRateUpdateProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child: ErpForm(
            logo: AppImages.logo,
            key: _erpFormKey,
            title: 'FACTORY RATE UPDATE',
            subtitle: 'Factory Rate Update',
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
                            title: 'FACTORY RATE UPDATE LIST',
                            columns: _tableColumns,
                            data: provider.recalculationData.map((e) {
                              return {
                                'FactoryRecDetID': e.factoryRecDetID,
                                'FactoryRecMstID': e.factoryRecMstID,
                                'Srno': e.srno,
                                'Jno': e.jno,
                                'CutNo': e.cutNo,
                                'MfgCut': e.mfgCut,
                                'BCode': e.bCode,
                                'PktNo': e.pktNo,
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
                                'DmWt': e.dmWt,
                                'DmPer': e.dmPer,
                                'Size': e.size,
                                'RecPer': e.recPer,
                                'DiffPer': e.diffPer,
                                'DiffWt': e.diffWt,
                                'FactoryJamaDetID': e.factoryJamaDetID,
                                'FactRec': e.factRec,
                                'RateID': e.rateID,
                                'Rateon': e.rateon,
                                'Rate': e.rate,
                                'Amount': e.amount,
                                'CutCode': e.cutCode,
                                'AmountRs': e.amountRs,
                                'CheckerRec': e.checkerRec,
                                'FromCrID': e.fromCrID,
                                'LastCrID': e.lastCrID,
                                'PolishCheckerRecMstID': e.polishCheckerRecMstID,
                                'CrID': e.crID,
                                'FactoryIssDetID': e.factoryIssDetID,
                                'Diam': e.diam,
                                'QRCode': e.qrCode,
                                'OrderMstID': e.orderMstID,
                                'Length': e.length,
                                'Height': e.height,
                                'PolishCode': e.polishCode,
                                'SymmetryCode': e.symmetryCode,
                                'FluoCode': e.fluoCode,
                                'PairNo': e.pairNo,
                                'TensionsCode': e.tensionsCode,
                                'TopSide': e.topSide,
                                'MarkerMstID': e.markerMstID,
                                'FcIntentCode': e.fcIntentCode,
                                'FcOverCode': e.fcOverCode,
                                'FColorCode1': e.fColorCode1,
                                'FColorCode2': e.fColorCode2,
                                'HA': e.ha,
                                'GroupType': e.groupType,
                                'SellRate': e.sellRate,
                                'SellAmount': e.sellAmount,
                                'SellCode': e.sellCode,
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

    ErpColumnConfig(key: 'FactRec', label: 'FACT REC', width: 160),
    ErpColumnConfig(key: 'GroupType', label: 'GROUP TYPE', width: 160),

    ErpColumnConfig(key: 'RateID', label: 'RATE ID', width: 140),
    ErpColumnConfig(key: 'Rateon', label: 'RATE ON', width: 160),
    ErpColumnConfig(key: 'Rate', label: 'RATE', width: 140),
    ErpColumnConfig(key: 'Amount', label: 'AMOUNT', width: 160),

    ErpColumnConfig(key: 'SellCode', label: 'SELL CODE', width: 160),
    ErpColumnConfig(key: 'SellRate', label: 'SELL RATE', width: 160),
    ErpColumnConfig(key: 'SellAmount', label: 'SELL AMOUNT', width: 180),

    ErpColumnConfig(key: 'HA', label: 'HA', width: 120),
  ];

  void _onFieldChanged(String key, dynamic value) {
    _formValues[key] = value.toString();
  }
}
