import 'package:diam_mfg/providers/utility_sell_price_list_update_provider.dart';
import 'package:diam_mfg/utils/constants.dart';
import 'package:erp_data_table/erp_data_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rs_dashboard/rs_dashboard.dart';
import '../bootstrap.dart';
import '../utils/app_images.dart';

class UtilitySellPriceListUpdate extends StatefulWidget {
  const UtilitySellPriceListUpdate({super.key});

  @override
  State<UtilitySellPriceListUpdate> createState() =>
      _UtilitySellPriceListUpdateState();
}

class _UtilitySellPriceListUpdateState extends State<UtilitySellPriceListUpdate> {
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
    _setDefaultFormValues();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _resetForm();
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

    final provider = context.read<UtilitySellPriceListUpdateProvider>();
    await provider.clvDeptRateUpdate(payload, context);
  }

  void _resetForm() {
    context.read<UtilitySellPriceListUpdateProvider>().hideRecalculation();

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
    return Consumer<UtilitySellPriceListUpdateProvider>(
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
                                'FactoryRecDetID': e.factoryRecDetID,
                                'FactoryRecMstID': e.factoryRecMstID,
                                'CutNo': e.cutNo,
                                'ShapeCode': e.shapeCode,
                                'ColorCode': e.colorCode,
                                'PurityCode': e.purityCode,
                                'RecWt': e.recWt,
                                'GroupType': e.groupType,
                                'ArticalCode': e.articalCode,
                                'SellCode': e.sellCode,
                                'SellRate': e.sellRate,
                                'SellAmount': e.sellAmount,
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
    ErpColumnConfig(key: 'CutNo', label: 'CUT NO', width: 140),
    ErpColumnConfig(key: 'ShapeCode', label: 'SHAPE', width: 140),
    ErpColumnConfig(key: 'ColorCode', label: 'COLOR', width: 140),
    ErpColumnConfig(key: 'PurityCode', label: 'PURITY', width: 140),
    ErpColumnConfig(key: 'RecWt', label: 'REC WT', width: 140),
    ErpColumnConfig(key: 'GroupType', label: 'GROUP TYPE', width: 180),
    ErpColumnConfig(key: 'ArticalCode', label: 'ARTICLE', width: 160),
    ErpColumnConfig(key: 'SellCode', label: 'SELL CODE', width: 160),
    ErpColumnConfig(key: 'SellRate', label: 'SELL RATE', width: 160),
    ErpColumnConfig(key: 'SellAmount', label: 'SELL AMOUNT', width: 180),
  ];

  void _onFieldChanged(String key, dynamic value) {
    _formValues[key] = value.toString();
  }
}
